// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
/// @title SafeOne Chain Single Staking Pool Rewards Smart Contract 
/// @author @m3tamorphTECH
/// @notice Designed based on the Synthetix staking rewards contract

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

    /* ========== CUSTOM ERRORS ========== */

error InvalidAmount();
error TokensLocked();

contract KiwiStakingPool {
   
    /* ========== STATE VARIABLES ========== */

    address public owner;
    address payable public teamWallet;
    IERC20 public immutable stakedToken;
    IERC20 public immutable rewardToken;
    uint public constant earlyUnstakeFee = 1000;
    uint public poolDuration;
    uint public poolStartTime;
    uint public poolEndTime;
    uint public updatedAt;
    uint public rewardRate; 
    uint public rewardPerTokenStored; 
    uint private _totalStaked;

    mapping(address => uint) public userStakedBalance;
    mapping(address => uint) public userPaidRewards;
    mapping(address => uint) userRewardPerTokenPaid;
    mapping(address => uint) userRewards; 

    /* ========== MODIFIERS ========== */

    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        updatedAt = lastTimeRewardApplicable();
        if (_account != address(0)) {
            userRewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    /* ========== EVENTS ========== */

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 amount);
   
    /* ========== CONSTRUCTOR ========== */

    constructor(address _stakedToken, address _rewardToken) {
        owner = msg.sender;
        stakedToken = IERC20(_stakedToken);
        rewardToken = IERC20(_rewardToken);
        teamWallet = payable(0x6274A79fB83549c430b3D65ae0E69650ed574b76);
    }

    receive() external payable {
        teamWallet.transfer(msg.value);
    }
    
   /* ========== MUTATIVE FUNCTIONS ========== */

    function stake(uint _amount) external updateReward(msg.sender) {
        if(_amount <= 0) revert InvalidAmount();
        userStakedBalance[msg.sender] += _amount;
        _totalStaked += _amount;
        bool success = stakedToken.transferFrom(msg.sender, address(this), _amount);
        if (!success) revert();
        emit Staked(msg.sender, _amount);
    }

    function unstake(uint _amount) external updateReward(msg.sender) {
        if(block.timestamp < poolEndTime) revert TokensLocked();
        if(_amount <= 0) revert InvalidAmount();
        if(_amount > userStakedBalance[msg.sender]) revert InvalidAmount();
        userStakedBalance[msg.sender] -= _amount;
        _totalStaked -= _amount;
        bool success = stakedToken.transfer(msg.sender, _amount);
        if (!success) revert();
        emit Unstaked(msg.sender, _amount);
    }

    function emergencyUnstake() external updateReward(msg.sender) {
        uint _amount = userStakedBalance[msg.sender];
        userStakedBalance[msg.sender] = 0;
        _totalStaked -= _amount;

        uint fee = _amount * earlyUnstakeFee / 10000;
        stakedToken.transfer(teamWallet, fee);

        uint amountReceived = _amount - fee;
        bool success = stakedToken.transfer(msg.sender, amountReceived);
        if (!success) revert();
        emit Unstaked(msg.sender, _amount);
    }

    function claimRewards() public updateReward(msg.sender) {
        uint rewards = userRewards[msg.sender];
        if (rewards > 0) {
            userRewards[msg.sender] = 0;
            userPaidRewards[msg.sender] += rewards;
            bool success = rewardToken.transfer(msg.sender, rewards);
            if (!success) revert();
            emit RewardPaid(msg.sender, rewards);
        }
    }

    /* ========== VIEW & GETTER FUNCTIONS ========== */

    function earned(address _account) public view returns (uint) {
        return (userStakedBalance[_account] * 
            (rewardPerToken() - userRewardPerTokenPaid[_account])) / 1e18
            + userRewards[_account];
    }

    function lastTimeRewardApplicable() internal view returns (uint) {
        return _min(block.timestamp, poolEndTime);
    }

    function rewardPerToken() internal view returns (uint) {
        if (_totalStaked == 0) {
            return rewardPerTokenStored;
        }

        return rewardPerTokenStored + (rewardRate *
        (lastTimeRewardApplicable() - updatedAt) * 1e18
        ) / _totalStaked;
    }

    function _min(uint x, uint y) internal pure returns (uint) {
        return x <= y ? x : y;
    }

    function totalRewardTokens() internal view returns (uint) {
        if (rewardToken == stakedToken) {
            return (rewardToken.balanceOf(address(this)) - _totalStaked);
        }
        return rewardToken.balanceOf(address(this));
    }

    function balanceOf(address _account) external view returns (uint256) {
        return userStakedBalance[_account];
    }

    function totalStaked() external view returns (uint256) {
        return _totalStaked;
    }

    /* ========== OWNER RESTRICTED FUNCTIONS ========== */

    function setPoolDuration(uint _duration) external onlyOwner {
        require(poolEndTime < block.timestamp, "Pool still live");
        poolDuration = _duration;
    }

    function setPoolRewards(uint _amount) external onlyOwner updateReward(address(0)) { 
        if (block.timestamp >= poolEndTime) {
            rewardRate = _amount / poolDuration;
        } else {
            uint remainingRewards = (poolEndTime - block.timestamp) * rewardRate;
            rewardRate = (_amount + remainingRewards) / poolDuration;
        }

        require(rewardRate > 0, "reward rate = 0");
        require(
            rewardRate * poolDuration <= rewardToken.balanceOf(address(this)),
            "reward amount > balance"
        );
        
        poolStartTime = block.timestamp;
        poolEndTime = block.timestamp + poolDuration;
        updatedAt = block.timestamp;
    } 

    function topUpPoolRewards(uint _amount) external onlyOwner updateReward(address(0)) { 
        uint remainingRewards = (poolEndTime - block.timestamp) * rewardRate;
        rewardRate = (_amount + remainingRewards) / poolDuration;
        
        require(rewardRate > 0, "reward rate = 0");
        if(stakedToken == rewardToken) {
            require(
                rewardRate * poolDuration <= rewardToken.balanceOf(address(this)) - _totalStaked,
                "reward amount > balance"
            );
        } else {
            require(
                rewardRate * poolDuration <= rewardToken.balanceOf(address(this)),
                "reward amount > balance"
            );
        }
    
        updatedAt = block.timestamp;
    } 

    function withdrawPoolRewards(uint256 _amount) external onlyOwner updateReward(address(0)) {
        uint remainingRewards = (poolEndTime - block.timestamp) * rewardRate;
        rewardRate = (remainingRewards - _amount) / poolDuration;

        require(rewardRate > 0, "reward rate = 0");
        if(stakedToken == rewardToken) {
            require(
                rewardRate * poolDuration <= rewardToken.balanceOf(address(this)) - _totalStaked,
                "reward amount > balance"
            );
        } else {
            require(
                rewardRate * poolDuration <= rewardToken.balanceOf(address(this)),
                "reward amount > balance"
            );
        }

        bool success = rewardToken.transfer(address(msg.sender), _amount);
        if (!success) revert();
      
        updatedAt = block.timestamp;
    }

    function updateTeamWallet(address payable _teamWallet) external onlyOwner {
        teamWallet = _teamWallet;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}