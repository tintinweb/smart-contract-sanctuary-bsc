/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

    function mint(address account, uint256 amount) external returns (bool);
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

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success,) = recipient.call{value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value : value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeMint(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.mint.selector, to, value));
    }

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
    unchecked {
        uint256 oldAllowance = token.allowance(address(this), spender);
        require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
        uint256 newAllowance = oldAllowance - value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }

}

abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

interface FFFExchange {
    function exchange(address contractAddress, address toAddress, uint256 amountToWei) external returns(bool);
    function fff2ffftRatio() external view returns(uint256);
}

contract StakingLocks {
    enum LockType { NULL, DAYS15, DAYS30, DAYS60}

    uint256 internal constant TYPE_NUM = 3;

    LockType[TYPE_NUM] lockTypes = [LockType.DAYS15, LockType.DAYS30, LockType.DAYS60];

    struct LockData {
        uint32 period;
        uint8 multiplicator; // 11 factor is equal 1.1
    }

    mapping(LockType => LockData) public locks; // All our locks

    function _initLocks() internal {
        locks[LockType.DAYS15] = LockData(5 minutes, 20);
        locks[LockType.DAYS30] = LockData(15 minutes, 30);
        locks[LockType.DAYS60] = LockData(30 minutes, 50);
    }
}

contract TokenWrapper is StakingLocks {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IERC20Upgradeable public stakeInToken;

    uint256 internal _totalSupply;
    uint256 internal _totalBalance;
    mapping(address => uint256) internal _balances;
    mapping(address => uint256) internal _demandBalances; // 获取存入的活期余额

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    // 查询活期质押数量
    function demandBalancesOf(address account) public view returns (uint256) {
        return _demandBalances[account];
    }

    function totalBalance() public view returns (uint256) {
        return _totalBalance;
    }

    function stake(uint256 amount) public virtual {
        _totalSupply = _totalSupply + amount;
        _totalBalance = _totalBalance + amount;
        _balances[msg.sender] += amount;
        _demandBalances[msg.sender] += amount;
        stakeInToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public virtual {
        _totalSupply = _totalSupply - amount;
        _totalBalance = _totalBalance - amount;
        _balances[msg.sender] -= amount;
        _demandBalances[msg.sender] -= amount;
        stakeInToken.safeTransfer(msg.sender, amount);
    }
}

contract TokenLockingStaking is TokenWrapper, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    IERC20Upgradeable public stakeOutToken;

    struct LockStaking {
        uint256 orderId;  // 订单ID
        uint256 lockTime; // 锁定时间
        LockType lockType; // 锁定类型
        uint256 amount; // 锁定数量
        RedeemStatus status; // 赎回状态
    }

    enum RedeemStatus {NULL, NON_REDEEM, CAN_REDEEM, REDEEMED} // 空占位/ 不可赎回/ 可以赎回/ 已经赎回

    uint256 public totalOutput = 210000e8;
    uint256 public oneDay = 86400;
    

    uint256 public starttime = 2310886017;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime = 2310886017;
    uint256 public rewardPerTokenStored;
    bool public canWithdraw;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public rewardSums;

    // ----------------------锁仓参数-------------------------------
    FFFExchange public fffExchange; // 兑换合约
    uint256 public withdrawPeriod;  //  质押到期之后的提取时间段, 超过之后自动质押（不进行任何操作）
    mapping(address => uint256) personalOrderId; // 个人的订单ID
    mapping(address => mapping(uint256 => LockStaking)) public personalLockStaking;  //  通过个人订单号获取订单
    mapping(address => LockStaking[]) public lockStakingList;  //  获取个人订单列表
    mapping(address => mapping(LockType => uint256)) public lockStakingAmount; // 个人每一种锁仓类型对应的数量

    uint256 public rewardsGloble; // 全局提取奖励
    uint256 public dayOut; // 每日产出

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event UpdateWithdrawStatus(bool oldStatus, bool newStatus);
    event UpdateStartTime(uint time);

     function initialize() public initializer {        
         canWithdraw =false;
         starttime = 2310886017;
         lastUpdateTime = 2310886017;
        __Ownable_init();
        withdrawPeriod = 2 minutes;
     }

    function init(
        address outToken_, 
        address inToken_,
        uint256 starttime_, // 开始时间
        uint256 dayOut_,    // 每日产出
        uint256 totalAmount_,    // FFF总产量
        address exchangeContract_    // FFF兑换合约
    )  public onlyOwner {        
        oneDay = 86400;
        totalOutput = totalAmount_;
        stakeOutToken = IERC20Upgradeable(outToken_);
        stakeInToken = IERC20Upgradeable(inToken_);
        starttime = starttime_;
        lastUpdateTime = starttime;

        dayOut = dayOut_;
        periodFinish = starttime_ + totalAmount_ * oneDay / dayOut_;
        rewardRate = dayOut_ * 1e18 / oneDay;

        _initLocks();
        fffExchange = FFFExchange(exchangeContract_);
    }

    modifier checkStart() {
        require(block.timestamp >= starttime, "not start");
        _;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function setCanWithdraw(bool _enable) external onlyOwner {
        emit UpdateWithdrawStatus(canWithdraw, _enable);
        canWithdraw = _enable;
    }

    function setStartTime(uint time) external onlyOwner returns(bool){
        require(starttime > block.timestamp,"reward is started");
        require(time < periodFinish, "the start time cannot be greater than the end time" );
        
        if (starttime != time && time > 0 ){
            starttime = time;
            lastUpdateTime = starttime;
            emit UpdateStartTime(time);
            return true;
        }
        return false;
    }

    function setDayOut(uint dayOut_) external onlyOwner returns(bool){
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        rewardRate = dayOut_ * 1e18 / oneDay;
        periodFinish = starttime + totalOutput * oneDay / dayOut_;
        return true;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        uint curTime = block.timestamp;
        if (starttime > curTime){
            return starttime;
        }
        if (periodFinish > curTime) {
            return block.timestamp;
        }

        return periodFinish;
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        //        uint tmp = (lastTimeRewardApplicable() - lastUpdateTime) * rewardRate * 1e18;
        uint tmp = (lastTimeRewardApplicable() - lastUpdateTime) * rewardRate;

        return rewardPerTokenStored + tmp / totalSupply();
    }

    function earned(address account) public view returns (uint256) {

        return rewards[account] + balanceOf(account) * (rewardPerToken() - userRewardPerTokenPaid[account]) / 1e18;
    }

    function stake(uint256 amount)
    public
    override
    updateReward(msg.sender){
        require(amount > 0, ' Cannot stake 0');
        super.stake(amount);
        emit Staked(msg.sender, amount);
    }

    // 锁仓质押
    function lockStake(uint256 amount, LockType _lockType) public updateReward(msg.sender) {
        require(amount > 0, ' Cannot stake 0');
        uint8 multiplicator = locks[_lockType].multiplicator;
        _totalSupply = _totalSupply + amount * multiplicator / 10;  // 权重按照数量*比例计算
        _balances[msg.sender] += amount * multiplicator / 10;       // 权重按照数量*比例计算
        lockStakingAmount[_msgSender()][_lockType] += amount;       // 记录每种锁仓类型的数量
        addLockStackList(amount, _lockType);
        stakeInToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    // 添加到个人锁仓订单记录
    function addLockStackList(uint256 amount, LockType _lockType) internal {
        personalOrderId[_msgSender()] += 1;
        LockStaking memory lock = LockStaking(personalOrderId[_msgSender()], block.timestamp, _lockType, amount, RedeemStatus.NON_REDEEM);
        personalLockStaking[_msgSender()][personalOrderId[_msgSender()]] = lock;
        lockStakingList[_msgSender()].push(lock);
    }

    // 查询锁仓订单
    function getLockStackList(address target) public view returns (LockStaking[] memory) {
        LockStaking[] memory _lockList = lockStakingList[target];
        for(uint i=0; i< _lockList.length; i++){
            if (_lockList[i].status == RedeemStatus.REDEEMED || _lockList[i].status == RedeemStatus.NULL) {
                continue;
            }
            if (canRedeem(_lockList[i].lockTime, _lockList[i].lockType)) {
                _lockList[i].status = RedeemStatus.CAN_REDEEM;
            } else {
                _lockList[i].status = RedeemStatus.NON_REDEEM;
            }
        }
        return _lockList;
    }
    
    // 查询每种锁仓对应的数量
    function listLockStackAmount(address target) public view  returns (uint256[] memory) {
        uint256[] memory listAmount = new uint256[](TYPE_NUM);
        for(uint i=0; i< TYPE_NUM; i++){
            listAmount[i] = lockStakingAmount[target][lockTypes[i]];
        }
        return listAmount;
    }

    // 计算时间周期 在某个时间内是否可赎回
    function getCycle(uint256 _lockTime, LockType _lockType) public view returns (bool, uint256, uint256, uint256, uint256) {
        uint256 curTime = block.timestamp; // 当前时间
        uint256 cycleTime = locks[_lockType].period + withdrawPeriod; // 一个周期的时间
        uint256 cycle = (curTime - _lockTime) / cycleTime;  // 当前到第几个周期
        uint256 remainder = (curTime - _lockTime) % cycleTime;  // 余数，超过该周期多长时间

        return ((remainder > locks[_lockType].period && remainder < cycleTime), curTime, cycleTime, cycle, remainder);
    }

    // 是否在可赎回时间内
    function canRedeem(uint256 _lockTime, LockType _lockType) public view returns (bool) {
        bool inTime;
        (inTime,,,, ) = getCycle(_lockTime, _lockType);
        return inTime;
    }

    // 计算可兑换到的算力数量
    function earnedPower(address account) public view returns (uint256) {
        uint256 reward = earned(account);
        return reward * fffExchange.fff2ffftRatio() / 1e18;
    }

    // 计算已经兑换到的算力数量
    function rewardsSumPower(address account) public view returns (uint256) {
        uint256 reward = rewardSums[account];
        return reward * fffExchange.fff2ffftRatio() / 1e18;
    }

    // 计算剩余可产出的数量, 和日产量
    function outputParams() public view returns (uint256, uint256) {
        uint256 ratio = fffExchange.fff2ffftRatio();
        return ((totalOutput - rewardsGloble) * ratio / 1e18, dayOut * ratio / 1e18);
    }

    function withdraw(uint256 amount)
    public
    override
    updateReward(msg.sender)
    
    {
        require(canWithdraw, "inactive");
        require(amount > 0, ' Cannot withdraw 0');
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    // 锁仓提取(赎回)
    function lockWithdraw(uint256 _orderId) public updateReward(msg.sender) {
        require(canWithdraw, "inactive");
        LockStaking storage lockOrder = personalLockStaking[_msgSender()][_orderId];
        LockStaking storage lockOrderInList = lockStakingList[_msgSender()][lockOrder.orderId-1];
        require(lockOrder.orderId == lockOrderInList.orderId, "TokenLockingStakingPool: Order Id Error");
        require(lockOrder.status != RedeemStatus.REDEEMED, "TokenLockingStakingPool: REDEEMED" );
        require(canRedeem(lockOrder.lockTime, lockOrder.lockType), "TokenLockingStakingPool: NON_REDEEM");
        uint8 multiplicator = locks[lockOrder.lockType].multiplicator;
        lockOrder.status = RedeemStatus.REDEEMED; // 状态修改为已赎回
        lockOrderInList.status = RedeemStatus.REDEEMED;  // 修改列表里订单的状态
        _totalSupply = _totalSupply - lockOrder.amount * multiplicator / 10;  // 权重按照数量*比例计算
        _balances[msg.sender] -= lockOrder.amount * multiplicator / 10;       // 权重按照数量*比例计算
        lockStakingAmount[_msgSender()][lockOrder.lockType] -= lockOrder.amount;       // 记录每种锁仓类型的数量
        stakeInToken.safeTransfer(msg.sender, lockOrder.amount);    
    }

    function exit() external {
        withdraw(demandBalancesOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) checkStart {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            // stakeOutToken.safeTransfer(msg.sender, reward);
            rewardsGloble += reward;
            exchange(msg.sender, reward);
            rewardSums[msg.sender] += reward;
            emit RewardPaid(msg.sender, reward);
        }
    }

    // 兑换FFF到某个地址
    function exchange(address toAddress, uint256 _amount) internal returns(bool) {
        stakeOutToken.approve(address(fffExchange), _amount);  // 先授权
        fffExchange.exchange(address(stakeOutToken), toAddress, _amount); // 再兑换
        return true;
    }
}