//SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Staking Vault Contract
 * @author Chai Hang
 * @notice This contract can be used by only owner
 */
contract StakingVault is Ownable {

    //--------------------------------------
    // Data structure
    //--------------------------------------

    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many AEB tokens the user has provided.
        uint256 stakingRewarded;
        uint256 lastClaimBlockNumber;
        uint256 startStakeTime;         // stake starttime
        uint256 endStakeTime;           // stake endtime
        uint256 busdRewardDebt;
    }

    //--------------------------------------
    // 
    //--------------------------------------

    // Mainnet Address
    IBEP20 public BUSD                                = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address payable public TREASURY_WALLET            = payable(0x67D011931c2Ec0B2af7287B5985EcF0Fc4be9319);
    address public REWARD_TOKEN_WALLET                = 0x474eE70C12Aa25eBDA5b606568B8c4AB9Da550B7;

    // Note: AEB's decimals is 9. Please consider it.
    // CLAIM_FEE = claim_fee / (10 ** 9)
    uint256 public CLAIM_FEE                          = 3 * 10**(14 - 9);   // 0.0003 BNB
    // PENALTY_FEE = penalty_fee / (10 ** 9)
    uint256 public PENALTY_FEE                        = 3 * 10**(15 - 9);   // 0.003 BNB PER AEB
    // MAX_STAKE_AMOUNT_PER_USER * (10 ** decimals)
    uint256 public MAX_STAKE_AMOUNT_PER_USER          = 10000 * (10 ** 9);
    uint256 public STAKING_TIME_UNIT                  = 1 days;
    
    /**
     * staking rewards = 
     *  StakedAmount * (end.block.number - start.block.number)
     *  / RewardRatePerBlockPerToken
     */
    uint256 public RewardRatePerBlockPerToken         = 2880000;
    
    //--------------------------------------
    // State variables
    //--------------------------------------

    IBEP20 public token_;
    uint16 public minStakingTime_;
    uint16 public maxStakingTime_;
    mapping(address => UserInfo) public userInfo_;
    uint256 public totalStakeAmount_;
    uint256 public accBusd_;
    uint256 public busdLastBalance_;

    //-------------------------------------------------------------------------
    // EVENTS
    //-------------------------------------------------------------------------

    event LogBUSD(address indexed BUSD);
    event LogTREASURY(address indexed TREASURY);
    event LogRewardTokenWallet(address indexed RewardTokenWallet);   
    event LogClaimFee(uint256 ClaimFee);
    event LogPenaltyFee(uint256 PenaltyFee);
    event LogMaxStakeAmountPerUser(uint256 MaxStakeAmountPerUser);
    event LogStakingTimeUnit(uint256 StakingTimeUnit);
    event LogRewardRatePerBlockPerToken(uint256 RewardRatePerBlockPerToken);
    event LogAEB(address indexed AEB);
    event LogMinStakingTime(uint16 minStakingTime);
    event LogMaxStakingTime(uint16 maxStakingTime);
    event LogStakeAEB(address indexed staker, uint256 amount);
    event LogUnstakeAEB(address indexed unStaker, uint256 amount, uint256 stakingReward, uint256 busdReward);
    event LogClaimStakingReward(address indexed claimer, uint256 stakingReward);
    event LogClaimBusdReward(address indexed claimer, uint256 busdReward);
    event LogWithdraw(address indexed withdrawer, uint256 bnbAmount, uint256 busdAmount);
    event LogReceive(address indexed spender, uint256 amount);
    event LogFallback(address indexed spender, uint256 amount);

    //-------------------------------------------------------------------------
    // CONSTRUCTOR
    //-------------------------------------------------------------------------

    /**
     * @notice contract constructor
     * @dev initialize the state variables of the contract
     */
    constructor(address _token) {
        require(_token != address(0), "Zero Address");
        token_ = IBEP20(_token);
        minStakingTime_ = 10;
        maxStakingTime_ = 100;
        totalStakeAmount_ = 0;
        accBusd_ = 0;
        busdLastBalance_ = 0;  
    }

    //-------------------------------------------------------------------------
    // FUNCTIONS
    //-------------------------------------------------------------------------
    
    function setBUSD(address _busd) external onlyOwner {
        require(_busd != address(0), "Zero Address");
        BUSD = IBEP20(_busd);
        emit LogBUSD(_busd);
    }

    function setTREASURY(address _treasury) external onlyOwner {
        require(_treasury != address(0), "Zero Address");
        TREASURY_WALLET = payable(_treasury);
        emit LogTREASURY(_treasury);
    }
    
    function setRewardTokenWallet(address _rewardTokenWallet) external onlyOwner {
        require(_rewardTokenWallet != address(0), "Zero Address");
        REWARD_TOKEN_WALLET = _rewardTokenWallet;
        emit LogRewardTokenWallet(_rewardTokenWallet);
    }

    function setClaimFee(uint256 _claimFee) external onlyOwner {
        require(_claimFee > 0, "Zero Value");
        CLAIM_FEE = _claimFee;
        emit LogClaimFee(_claimFee);
    }

    function setPenaltyFee(uint256 _penaltyFee) external onlyOwner {
        require(_penaltyFee > 0, "Zero Value");
        PENALTY_FEE = _penaltyFee;
        emit LogPenaltyFee(_penaltyFee);
    }

    function setMaxStakeAmountPerUser(uint256 _maxStakeAmountPerUser) external onlyOwner {
        require(_maxStakeAmountPerUser > 0, "Zero Value");
        MAX_STAKE_AMOUNT_PER_USER = _maxStakeAmountPerUser;
        emit LogMaxStakeAmountPerUser(_maxStakeAmountPerUser);
    }

    function setStakingTimeUnit(uint256 _stakingTimeUnit) external onlyOwner {
        require(_stakingTimeUnit > 0, "Zero Value");
        STAKING_TIME_UNIT = _stakingTimeUnit;
        emit LogStakingTimeUnit(_stakingTimeUnit);
    }
    
    function setRewardRatePerBlockPerToken(uint256 _rewardRatePerBlockPerToken) external onlyOwner {
        require(_rewardRatePerBlockPerToken > 0, "Zero Value");
        RewardRatePerBlockPerToken = _rewardRatePerBlockPerToken;
        emit LogRewardRatePerBlockPerToken(_rewardRatePerBlockPerToken);
    }

    function setAEB(address _token) external onlyOwner {
        require(_token != address(0), "Zero Address");
        token_ = IBEP20(_token);
        emit LogAEB(_token);
    }

    function setMinStakingTime(uint16 _minStakingTime) external onlyOwner {
        require(_minStakingTime > 0, "Staking Time must be at least 1 days");
        minStakingTime_ = _minStakingTime;
        emit LogMinStakingTime(_minStakingTime);
    }

    function setMaxStakingTime(uint16 _maxStakingTime) external onlyOwner {
        require(_maxStakingTime > minStakingTime_, 
            "Maximum Staking Time must be greater than Minimum Staking Time");
        maxStakingTime_ = _maxStakingTime;
        emit LogMaxStakingTime(_maxStakingTime);   
    }

    function stakeAEB(uint256 _amount, uint16 _stakingTime) external {
        require(_stakingTime >= minStakingTime_, "Staking Time must be at least 10 days");
        require(_stakingTime <= maxStakingTime_, "Staking Time must be less than 100 days");
        require(_amount <= MAX_STAKE_AMOUNT_PER_USER, 
            "Max stake amount per user overflow");
        require(_amount <= token_.balanceOf(msg.sender), "Not enough AEB token to stake");
        require(userInfo_[msg.sender].amount == 0, "Already token is staked");

        uint256 busdBalance = BUSD.balanceOf(address(this));
        uint256 deltaBusd = 0;
        if (busdBalance > busdLastBalance_) {
            deltaBusd = busdBalance - busdLastBalance_;
        }

        token_.transferFrom(msg.sender, address(this), _amount);

        totalStakeAmount_ += _amount;
        userInfo_[msg.sender].amount = _amount;
        userInfo_[msg.sender].startStakeTime = block.timestamp;
        userInfo_[msg.sender].endStakeTime = block.timestamp + _stakingTime * STAKING_TIME_UNIT;
        userInfo_[msg.sender].lastClaimBlockNumber = block.number;

        deltaBusd += BUSD.balanceOf(address(this)) - busdBalance;

        if (deltaBusd > 0) {
            accBusd_ += deltaBusd * 1e8 / totalStakeAmount_;
        }
        busdLastBalance_ = BUSD.balanceOf(address(this));

        emit LogStakeAEB(msg.sender, _amount);
    }

    function unstakeAEB() external payable {
        require(userInfo_[msg.sender].amount > 0, "Have not staked token");
        if(block.timestamp < userInfo_[msg.sender].endStakeTime)
        {
            require(msg.value >= ((CLAIM_FEE + PENALTY_FEE) * userInfo_[msg.sender].amount), 
                "Fee for claim and Penalty is not enough");
        } else {
            require(msg.value >= (CLAIM_FEE * userInfo_[msg.sender].amount), 
                "Claim Fee is not enough");
        }

        uint256 busdBalance = BUSD.balanceOf(address(this));
        uint256 deltaBusd = 0;
        if (busdBalance > busdLastBalance_) {
            deltaBusd = busdBalance - busdLastBalance_;
        }

        uint256 amount = userInfo_[msg.sender].amount;
        userInfo_[msg.sender].amount = 0;
        // reward = AEBAmount*delta*rate 
        // AEBAmount = amount / (10 ** decimals)
        uint256 stakingReward = amount / (10 ** 9) * 
            (block.number - userInfo_[msg.sender].lastClaimBlockNumber) / 
            RewardRatePerBlockPerToken;
        userInfo_[msg.sender].stakingRewarded += stakingReward;
        userInfo_[msg.sender].lastClaimBlockNumber = block.number;
        
        require(token_.balanceOf(REWARD_TOKEN_WALLET) >= stakingReward, 
            "Reward token is not enough.");
        
        token_.transferFrom(REWARD_TOKEN_WALLET, msg.sender, stakingReward);
        token_.transfer(msg.sender, amount);
        (bool sent, ) = TREASURY_WALLET.call{value: msg.value}("");
        require(sent == true, "Failed to send BNB");

        deltaBusd += BUSD.balanceOf(address(this)) - busdBalance;

        if (deltaBusd > 0) {
            accBusd_ += deltaBusd * 1e8 / totalStakeAmount_;
        }

        totalStakeAmount_ -= amount;

        // busd reward
        uint256 busdReward = amount * accBusd_ / 1e8 - userInfo_[msg.sender].busdRewardDebt;

        if (busdReward > BUSD.balanceOf(address(this))) {
            busdReward = BUSD.balanceOf(address(this));
        }
        BUSD.transfer(msg.sender, busdReward);

        userInfo_[msg.sender].busdRewardDebt += busdReward;
        busdLastBalance_ = BUSD.balanceOf(address(this));

        emit LogUnstakeAEB(msg.sender, amount, stakingReward, busdReward);
    }

    function claimStakingReward() external payable {
        require(userInfo_[msg.sender].amount > 0, "Have not staked token");
        require(msg.value >= (CLAIM_FEE * userInfo_[msg.sender].amount), 
            "Claim Fee is not enough");

        uint256 busdBalance = BUSD.balanceOf(address(this));
        uint256 deltaBusd = 0;
        if (busdBalance > busdLastBalance_) {
            deltaBusd = busdBalance - busdLastBalance_;
        }

        // reward = AEBAmount*delta*rate 
        // AEBAmount = amount / (10 ** decimals)
        uint256 stakingReward = userInfo_[msg.sender].amount / (10 ** 9) * 
            (block.number - userInfo_[msg.sender].lastClaimBlockNumber) / 
            RewardRatePerBlockPerToken;

        userInfo_[msg.sender].stakingRewarded += stakingReward;
        userInfo_[msg.sender].lastClaimBlockNumber = block.number;
        require(token_.balanceOf(REWARD_TOKEN_WALLET) >= stakingReward, 
            "Reward token is not enough.");
        token_.transferFrom(REWARD_TOKEN_WALLET, msg.sender, stakingReward);
        (bool sent, ) = TREASURY_WALLET.call{value: msg.value}("");
        require(sent == true, "Failed to send BNB");

        deltaBusd += BUSD.balanceOf(address(this)) - busdBalance;

        if (deltaBusd > 0) {
            accBusd_ += deltaBusd * 1e8 / totalStakeAmount_;
        }
        busdLastBalance_ = BUSD.balanceOf(address(this));

        emit LogClaimStakingReward(msg.sender, stakingReward);
    }

    function claimBusdReward() external {
        require(userInfo_[msg.sender].amount > 0, "Have not staked token");

        uint256 busdBalance = BUSD.balanceOf(address(this));
        uint256 deltaBusd = 0;
        if (busdBalance > busdLastBalance_) {
            deltaBusd = busdBalance - busdLastBalance_;
        }
        if (deltaBusd > 0) {
            accBusd_ += deltaBusd * 1e8 / totalStakeAmount_;
        }

        uint256 busdReward = userInfo_[msg.sender].amount * accBusd_ / 1e8 - userInfo_[msg.sender].busdRewardDebt;

        if (busdReward > busdBalance) {
            busdReward = busdBalance;
        }
        BUSD.transfer(msg.sender, busdReward);

        userInfo_[msg.sender].busdRewardDebt += busdReward;
        busdLastBalance_ = BUSD.balanceOf(address(this));

        emit LogClaimBusdReward(msg.sender, busdReward);
    }

    function withdraw(uint256 _busdAmount) external onlyOwner() {
        uint256 bnbAmount = address(this).balance;
        require(bnbAmount > 0, "Have not BNB");
        (bool sent, ) = payable(msg.sender).call{value:bnbAmount}("");
        require(sent == true, "Failed to send BNB");

        uint256 busdBalance = BUSD.balanceOf(address(this));
        uint256 deltaBusd = 0;
        if (busdBalance > busdLastBalance_) {
            deltaBusd = busdBalance - busdLastBalance_;
        }
        if (deltaBusd > 0) {
            accBusd_ += deltaBusd * 1e8 / totalStakeAmount_;
        }

        if (busdBalance < _busdAmount) {
            BUSD.transfer(msg.sender, busdBalance);
            busdLastBalance_ = 0;
            emit LogWithdraw(msg.sender, bnbAmount, busdBalance);
        } else {
            BUSD.transfer(msg.sender, _busdAmount);
            busdLastBalance_ = busdBalance - _busdAmount;
            emit LogWithdraw(msg.sender, bnbAmount, _busdAmount);
        }
    }

    /**
     * @notice  Function to receive BNB. msg.data must be empty
     */
    receive() external payable {
        emit LogReceive(msg.sender, msg.value);
    }

    /**
     * @notice  Fallback function is called when msg.data is not empty
     */
    fallback() external payable {
        emit LogFallback(msg.sender, msg.value);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}