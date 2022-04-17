/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: Cypher/CypherStaking.sol


pragma solidity ^0.8.6;



contract CypherStaking is Ownable {

    event doStake(address _sender, uint256 _amount, uint256 _days);

    uint256 constant MINIMUM_FOR_STAKING = 1 * (10e18);

    enum stakeState { unstarted, started, paused, finished }

    struct stakeType {
        uint256 _days;
        uint256 _apy;
    }

    struct userStakeInfo {
        uint256 _amountStaked;
        uint256 _unclaimedRewards;
        uint256 _timeStarted;
        uint256 _timeUnlocking;
    }

    struct Stake {
        stakeState state;
        stakeType[] types;
        mapping(address => userStakeInfo) stakes;
        uint256 totalStake;
        uint256 totalUnclaimedRewards;
    }

    Stake private _stakeInfo;
    IERC20 private cypherToken;
    address public cypherRouter;

    constructor (address _cypherContract) {

        // SET StakeTypes: (DAYS , APY)
        _stakeInfo.types.push( stakeType(30, 38) );
        _stakeInfo.types.push( stakeType(60, 79) );
        _stakeInfo.types.push( stakeType(90, 92) );

        _stakeInfo.state = stakeState.unstarted;
        cypherToken = IERC20(_cypherContract);
    }

    function setRouter(address _router) public onlyOwner {
        cypherRouter = _router;
    }

    modifier onlyRouter {
        require(msg.sender == cypherRouter);
        _;
    }

    function start() public onlyOwner {
        require(_stakeInfo.state == stakeState.unstarted, "The staking period must be unstarted");

        _stakeInfo.totalStake = 0;
        _stakeInfo.totalUnclaimedRewards = 0;
        _stakeInfo.state = stakeState.started;
    }

    function pause() public onlyOwner {
        require(_stakeInfo.state == stakeState.started, "The staking period must be started to be able to pause it");
        _stakeInfo.state = stakeState.paused;
    }

    function unpause() public onlyOwner {
        require(_stakeInfo.state == stakeState.paused, "The staking period is not paused");
        _stakeInfo.state = stakeState.started;
    }

    function totalStake() public view returns (uint256) {
        return _stakeInfo.totalStake;
    }

    function totalUnclaimedRewards() public view returns (uint256) {
        return _stakeInfo.totalUnclaimedRewards;
    }

    function infoStake(address _user) public view returns(bool _checkStake, uint256 amountStaked, uint256 unclaimedRewards, uint256 timeStarted, uint256 timeUnlocking) {
        bool checkStake = (_stakeInfo.stakes[_user]._amountStaked > 0);
        
        if (checkStake) {
            return (checkStake, _stakeInfo.stakes[_user]._amountStaked, _stakeInfo.stakes[_user]._unclaimedRewards, _stakeInfo.stakes[_user]._timeStarted, _stakeInfo.stakes[_user]._timeUnlocking);
        }

        return (checkStake, 0, 0, 0, 0);
    }

    function stake (address _sender, uint256 _amount, uint256 _stakingType) public onlyRouter returns(bool) {
        require(_amount >= MINIMUM_FOR_STAKING, "The minimum amount to stake is 1 token");
        require(_stakeInfo.state == stakeState.started, "Staking period is not available at this time");
        require(_stakeInfo.types[_stakingType]._days > 0, "The type of staking is non-existent");
        require(_stakeInfo.stakes[_sender]._amountStaked == 0, "You are already participating in staking");

        uint256 _dayProfit = ((_amount * _stakeInfo.types[_stakingType]._apy) / 100) / 365;
        uint256 _calculateRewards = _dayProfit * _stakeInfo.types[_stakingType]._days;
        require(_stakeInfo.totalStake + _stakeInfo.totalUnclaimedRewards + _calculateRewards <= cypherToken.balanceOf(address(this)), "No more rewards available");

        _stakeInfo.stakes[_sender] =  userStakeInfo(_amount, _calculateRewards, block.timestamp, block.timestamp + (_stakeInfo.types[_stakingType]._days * 1 days));
        _stakeInfo.totalStake += _amount;
        _stakeInfo.totalUnclaimedRewards += _calculateRewards;

        emit doStake(_sender, _amount, _stakeInfo.types[_stakingType]._days);
        return true;
    } 

    function unstake () public returns (bool) {
        require(_stakeInfo.state != stakeState.unstarted, "Staking period is not available at this time");
        require(_stakeInfo.stakes[msg.sender]._amountStaked > 0, "You are not participating in staking");
        require(_stakeInfo.stakes[msg.sender]._timeUnlocking <= block.timestamp, "You can't claim the rewards yet");
        require(cypherToken.transfer(msg.sender, _stakeInfo.stakes[msg.sender]._amountStaked + _stakeInfo.stakes[msg.sender]._unclaimedRewards));

        _stakeInfo.stakes[msg.sender]._amountStaked = 0;
        _stakeInfo.totalStake -= _stakeInfo.stakes[msg.sender]._amountStaked;
        _stakeInfo.stakes[msg.sender]._unclaimedRewards = 0;
        _stakeInfo.totalUnclaimedRewards -= _stakeInfo.stakes[msg.sender]._unclaimedRewards;

        return true;
    }
}