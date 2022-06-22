/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

contract StakingRewards is Ownable {
    IERC20 public stakingToken;
    IERC20 public rewardsToken;

    uint256 public rewardRate = 100;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public initialTime = 60;

    uint256 public pendingRewardRate;
    uint256 public pendingRewardTime;

    uint256 public pendingInitialTime;
    uint256 public pendingLockTimes;

    uint256 public delayTime = 0 days;
    bool public isPause;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public stakeStart;

    uint256 public _totalSupply;
    mapping(address => uint256) public _balances;

    event StartStaked(address indexed owner, uint256 amount, uint256 time);
    event WitdrawStaked(address indexed owner, uint256 amount, uint256 time);
    event WitdrawRewards(address indexed owner, uint256 amount, uint256 time);
    event ChangeRate(uint256 oldRate, uint256 newRate);
    event ChangeLockTimes(uint256 oldInitialTime, uint256 newInitialTime);

    constructor(address _stakingToken, address _rewardsToken) {
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    modifier updateReward() {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;

        rewards[msg.sender] = earned(msg.sender);
        userRewardPerTokenPaid[msg.sender] = rewardPerTokenStored;
        _;
    }

    modifier overInitTime() {
        require(
            (block.timestamp - stakeStart[msg.sender]) >= initialTime,
            "Not time yet"
        );
        _;
    }

    modifier notPause() {
        require(!isPause, "The Staking is Paused");
        _;
    }

    function pause() public onlyOwner {
        isPause = true;
    }

    function unpause() public onlyOwner {
        isPause = false;
    }

    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return 0;
        }
        return
            rewardPerTokenStored +
            (((block.timestamp - lastUpdateTime) * rewardRate * 1e18) /
                _totalSupply);
    }

    function earned(address account) public view returns (uint256) {
        return
            ((_balances[account] *
                (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18) +
            rewards[account];
    }

    function stake(uint256 _amount) external updateReward notPause {
        _totalSupply += _amount;
        _balances[msg.sender] += _amount;
        stakeStart[msg.sender] = block.timestamp;
        stakingToken.transferFrom(msg.sender, address(this), _amount);

        emit StartStaked(msg.sender, _amount, block.timestamp);
    }

    function withdraw(uint256 _amount) external overInitTime updateReward {
        require(
            _balances[msg.sender] >= _amount,
            "You don't have enought tokens in Staking"
        );

        _totalSupply -= _amount;
        _balances[msg.sender] -= _amount;
        stakingToken.transfer(msg.sender, _amount);

        emit WitdrawStaked(msg.sender, _amount, block.timestamp);
    }

    function getReward() external overInitTime updateReward {
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        rewardsToken.transfer(msg.sender, reward);

        emit WitdrawRewards(msg.sender, reward, block.timestamp);
    }

    function changeLockTimes(uint256 _newInitialTime) public onlyOwner {
        pendingInitialTime = _newInitialTime;
        pendingLockTimes = block.timestamp;
    }

    function applyLockTimes() public onlyOwner {
        require(
            pendingLockTimes != 0,
            "TradeToken: must call changeLockTimes before that"
        );
        require(
            pendingLockTimes + delayTime <= block.timestamp,
            "TradeToken: must wait delayTime"
        );
        pendingLockTimes = 0;
        emit ChangeLockTimes(initialTime, pendingInitialTime);
        initialTime = pendingInitialTime;
    }

    function changeRate(uint256 _newRate) public onlyOwner {
        pendingRewardRate = _newRate;
        pendingRewardTime = block.timestamp;
    }

    function applyRewardRate() public updateReward onlyOwner {
        require(
            pendingRewardTime != 0,
            "TradeToken: must call changeRate before that"
        );
        require(
            pendingRewardTime + delayTime <= block.timestamp,
            "TradeToken: must wait delayTime"
        );
        pendingRewardTime = 0;
        emit ChangeRate(rewardRate, pendingRewardRate);
        rewardRate = pendingRewardRate;
    }

    function getStaked(address _account) external view returns (uint256) {
        return _balances[_account];
    }
}