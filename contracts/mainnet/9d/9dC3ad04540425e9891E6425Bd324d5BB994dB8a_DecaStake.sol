// SPDX-License-Identifier: No License

pragma solidity 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ICornToken {
    function mint(address, uint256) external;
}

contract DecaStake is Ownable {
    
    //Info of each user
    struct UserInfo {
        uint256 stakedAmount;           // User staked amount in the pool
        uint256 lastStakedTimestamp;    // User staked amount in the pool
        uint256 lastUnstakedTimestamp;  // User staking timestamp
        uint256 lastHarvestTimestamp;   // User last harvest timestamp 
    }
    
    // Info of each pool.
    struct PoolInfo {
        uint256 rate;           // Fixed rewards rate
        uint256 stakeLimit;     // Fixed staking amount 
        uint256 totalStaked;    // Total staked tokens in the pool
        bool paused;            // Pause or unpause the pool, failover plan
    }

    // Info of each pool.
    PoolInfo[] public poolInfo;

    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    IERC20 public decaToken;
    ICornToken public cornToken;

    address public feeReceiver;
    uint256 public unstakeFee = 10;
    uint256 public rewardPeriod = 86400;    //daily 86400 seconds

    event Staked(address indexed account, uint256 pid, uint256 startTime, uint256 amount);
    event Harvested(address indexed account, uint256 pid, uint256 value);
    event Unstaked(address indexed account, uint256 pid, uint256 amount);
    event RegisterPool(uint256 rate, uint256 stakeLimit);
    event UpdatePool(uint256 rate, uint256 stakeLimit, bool paused);

    event SetRewardPeriod(uint256 rewardPeriod);
    event SetUnstakeFee(uint256 unstakeFee);
    event SetFeeReceiver(address feeReceiver);
    event ClearStuckBalance(address to, uint256 balance);

    constructor(address _decaToken, address _cornToken, address _feeReceiver) {
        require(_feeReceiver != address(0), "Address Zero");

        decaToken = IERC20(_decaToken);
        cornToken = ICornToken(_cornToken); 
        feeReceiver = _feeReceiver;
    }

    // register a pool. Can only be called by the owner.
    function registerPool(uint256 _rate, uint256 _stakeLimit) public onlyOwner {

        poolInfo.push(PoolInfo({
            rate : _rate,
            stakeLimit : _stakeLimit,
            totalStaked : 0,
            paused: false
        }));
        
        emit RegisterPool(_rate, _stakeLimit);
    }

    // Update the pool detail, given pid of the pool. Can only be called by the owner.
    function updatePool(uint256 _pid, uint256 _rate, uint256 _stakeLimit, bool _paused) public onlyOwner {
        
        PoolInfo storage _poolInfo = poolInfo[_pid];
        _poolInfo.rate = _rate;
        _poolInfo.stakeLimit = _stakeLimit;
        _poolInfo.paused = _paused;

        emit UpdatePool(_rate, _stakeLimit, _paused);
    }

    function stake(uint256 _pid, uint256 _amount) external returns (uint256) {  

        PoolInfo storage _poolInfo = poolInfo[_pid];
        UserInfo storage _userInfo = userInfo[_pid][msg.sender];

        require(!_poolInfo.paused, "stake : Contract paused, please try again later");
        require(_poolInfo.stakeLimit == _amount, "stake : Incorrect staking amount");
        require(_userInfo.stakedAmount == 0, "stake : Already staking in this pool");
        require(decaToken.balanceOf(msg.sender) >= _amount, "stake : Insufficient DECA token");
        
        // Update user staking info
        _userInfo.stakedAmount = _amount;
        _userInfo.lastStakedTimestamp = block.timestamp;
        _userInfo.lastHarvestTimestamp = block.timestamp; //must set lastHarvestTimestamp, used for rewards calculation
        
        // Update pool info
        _poolInfo.totalStaked += _amount;

        decaToken.transferFrom(msg.sender, address(this), _amount);
        emit Staked(msg.sender, _pid, block.timestamp, _amount);
        return _amount;
    }

    function unstake(uint256 _pid) external returns (uint256) {
        PoolInfo storage _poolInfo = poolInfo[_pid];
        UserInfo storage _userInfo = userInfo[_pid][msg.sender];

        require(!_poolInfo.paused, "unstake : Contract paused, please try again later");
        require(_userInfo.stakedAmount > 0, "unstake : You dont have stake");
        require(decaToken.balanceOf(address(this)) >= _userInfo.stakedAmount, "unstake : Contract doesnt have enough DECA, please contact admin");

        uint256 _stakedAmount = _userInfo.stakedAmount;
        uint256 _fee = _userInfo.stakedAmount * unstakeFee / 100;
        uint256 _unstakeAmount = _stakedAmount - _fee;

        // Harvest before unstake
        harvest(_pid);  

        // Update userinfo
        _userInfo.stakedAmount = 0;
        _userInfo.lastUnstakedTimestamp = block.timestamp;

        _poolInfo.totalStaked -= _stakedAmount;    // Update pool total stake token

        decaToken.transfer(feeReceiver, _fee);   // Transfer unstake fee to fee receiver
        decaToken.transfer(msg.sender, _unstakeAmount); // Transfer DECA token back to the owner

        emit Unstaked(msg.sender, _pid, _unstakeAmount);
        return _unstakeAmount;
    }

    function harvest(uint256 _pid) public returns (uint256){

        PoolInfo storage _poolInfo = poolInfo[_pid];
        UserInfo storage _userInfo = userInfo[_pid][msg.sender];

        require(!_poolInfo.paused, "harvest : Contract paused, please try again later");
        require(_userInfo.stakedAmount > 0, "harvest : You dont have stake");

        uint256 _value = getStakeRewards(_pid, msg.sender);
        require(_value > 0, "harvest : You do not have any pending rewards");

        _userInfo.lastHarvestTimestamp = block.timestamp;   // Update user last harvest timestamp
        mintCorn(msg.sender, _value);   // Mint CORN rewards to user

        emit Harvested(msg.sender, _pid, _value);
        return _value;
    }

    function getStakeRewards(uint256 _pid, address _address) public view returns (uint256) {
       
        PoolInfo storage _poolInfo = poolInfo[_pid];
        UserInfo storage _userInfo = userInfo[_pid][_address];

        if (_userInfo.stakedAmount == 0) return (0);

        uint256 _timePassed = block.timestamp - _userInfo.lastHarvestTimestamp;
        uint256 _reward = _timePassed * _poolInfo.rate / rewardPeriod;    //Rewards divided by 1 day, 86400 seconds

        return _reward;
    }

    function mintCorn(address _to, uint256 _amount) internal {
        cornToken.mint(_to, _amount);
    }

    function setRewardPeriod(uint256 _rewardPeriod) external onlyOwner {
        rewardPeriod = _rewardPeriod;

        emit SetRewardPeriod(_rewardPeriod);
    }

    function setUnstakeFee(uint256 _unstakeFee) external onlyOwner {
        require(_unstakeFee <= 10, "Only allow up to 10% unstake fee");
        unstakeFee = _unstakeFee;

        emit SetUnstakeFee(_unstakeFee);
    }

    function setFeeReceiver(address _feeReceiver) external onlyOwner {
        require(feeReceiver != address(0), "Zero address");
        feeReceiver = _feeReceiver;

        emit SetFeeReceiver(_feeReceiver);
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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