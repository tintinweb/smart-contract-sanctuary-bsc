/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactionInfos the account sending and
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

/**
 // CAUTION
 // This version of SafeMath should only be used with Solidity 0.8 or later,
 // because it relies on the compiler's built in overflow checks.
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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

        (bool success, ) = recipient.call{value: amount}("");
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

        (bool success, bytes memory returndata) = target.call{value: value}(data);
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
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
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
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

/** 
 @dev StakingPool. Deposit LP tokens to earn rewards in the form of YWT tokens.
 *  This contract mints new YWT tokens everytime a new user deposits LP tokens to the pool
 */
contract JuniorStakingPoolTest2 is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // 用户结构体
    struct UserInfo {
        uint256 totalDepositAmount; // 用户质押的总LP代币数量
        uint256 claimedReward; // 用户已领取的奖励代币数量
		uint256 referralBonus;
        TransactionInfo[] transactionInfos;
    }

    // 交易结构体
    struct TransactionInfo {
        IERC20 lpToken;
        address user;
        uint256 amount; // 用户质押的LP代币数量
        uint256 lastDepositTime; // 用户每个池子的最新质押时间
        uint256 depositDays;
        uint256 deservedReward;
        uint256 claimedReward;
    }

    // 流动池结构体
    struct PoolInfo {
        IERC20 lpToken; // LP代币合约地址
        uint256 allocPoint; // 分配给该池的分配点数  每个块分配的 YWT
        uint256 lastRewardBlock;  // Last block number that YWTs distribution occurs.
        uint256 accYWTPerShare; // 每股累积的YWT
    }

    address public YWT;
    // 每天可以领取多少奖励代币
    uint256 public ywtPerBlock;
    // 需要多少LP代币才能质押
    uint256 public threshold =  50 * 10 **18;
    // 总分配点。 必须是所有池中所有分配点的总和。
    uint256 public totalAllocPoint = 0;
    uint private constant PERCENT_DIVIDER   = 100;
    uint private constant PRICE_DIVIDER     = 1 ether;
    uint private constant TIME_STEP         = 1 days;
	// uint256 public constant ACC_YWT_PRECISION = 1e18;
    // 推荐奖励率
	uint256 public bonusPerReferral = 1;
    // 质押一个月的奖励倍数
    uint256 public oneMonthMultipliter = 2; 
    // 质押三个月的奖励倍数
    uint256 public threeMonthMultipliter = 3;
    // 质押六个月的奖励倍数
    uint256 public sixMonthMultipliter = 4;
    // 质押一年的奖励倍数
    uint256 public oneYearMultipliter = 5;

    TransactionInfo[] public transactionInfos;
    PoolInfo[] public poolInfo;
    // 每个质押了LP代币的用户的信息。
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // 判断池子是否已经存在
    mapping(IERC20 => bool) public poolExistence;
    // 用户的邀请人
    mapping(address => address) public referrals;
    // 用户的邀请数量
    mapping(address => uint256) public referrCount; 
    mapping(address => bool) public isDeposited;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Claim(address indexed user, uint256 indexed pid);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user,uint256 indexed pid,uint256 amount);
    event UpdateReleaseRate(address indexed user, uint256 goosePerBlock);

    constructor(
        address _rewardToken,   // 奖励代币的合约地址
        uint256 _ywtPerBlock     // 每天能够领取的代币数
    ) {
        YWT = _rewardToken;
        ywtPerBlock = _ywtPerBlock;
    }

    // 检查是否已经存在  不能重复加同一个池子
    modifier nonDuplicated(IERC20 _lpToken) {
        require(poolExistence[_lpToken] == false, "nonDuplicated: duplicated");
        _;
    }

    // 返回合约中池子的数量
    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // 添加一个新的lp流动池。 只能由合约所有者调用。
    // 不能重复添加同一个池子
    function add(uint256 _allocPoint,IERC20 _lpToken) public onlyOwner nonDuplicated(_lpToken) {
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolExistence[_lpToken] = true;
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: block.number,
            accYWTPerShare: 0
        }));
    }

    // 重新设置某一个池子的YWT分配点数
    function set(uint256 _pid,uint256 _allocPoint) public onlyOwner {
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

	// Return reward multiplier over the given _from to _to block.
    function getTimeInterval(uint256 _to, uint256 _from) public pure returns (uint256) {
		return _to.sub(_from);
    }

    // 获取用户的奖励乘数
    function getBoostMultiplier(uint256 _indexed) public view returns (uint256 muliplier) {
		TransactionInfo storage transaction = transactionInfos[_indexed];
        if (transaction.depositDays == 3 * 60) {
            return muliplier = oneMonthMultipliter;
        } else if (transaction.depositDays == 5 * 60) {
            return muliplier = threeMonthMultipliter;
        } else if (transaction.depositDays == 7 * 60) {
            return muliplier = sixMonthMultipliter;
        } else if (transaction.depositDays == 9 * 60) {
            return muliplier = oneYearMultipliter;
        } 
    }

    // function pendingCake(uint256 _pid, address _user) external view returns (uint256) {
    //     PoolInfo storage pool = poolInfo[_pid];
    //     UserInfo storage user = userInfo[_pid][_user];
    //     uint256 accCakePerShare = pool.accCakePerShare;
    //     uint256 lpSupply = pool.lpToken.balanceOf(address(this));
    //     if (block.number > pool.lastRewardBlock && lpSupply != 0) {
    //         uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
    //         uint256 cakeReward = multiplier.mul(cakePerBlock).mul(pool.allocPoint).div(totalAllocPoint);
    //         accCakePerShare = accCakePerShare.add(cakeReward.mul(1e12).div(lpSupply));
    //     }
    //     return user.amount.mul(accCakePerShare).div(1e12).sub(user.rewardDebt);
    // }

    function pendingReward(uint256 _pid, address _user) external view returns (uint256 totalDeservedReward,uint256 referralBonus, uint256 finalyPendingReward) {
		PoolInfo storage pool = poolInfo[_pid];
		uint256 accYWTPerShare = pool.accYWTPerShare;
		uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 timeInterval = getTimeInterval(block.number,pool.lastRewardBlock);
            uint256 ywtReward = timeInterval.mul(ywtPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accYWTPerShare = accYWTPerShare.add(ywtReward.mul(1e12).div(lpSupply));
        }

		for (uint i = 0; i < transactionInfos.length; i++) {
			if(transactionInfos[i].lpToken == pool.lpToken && transactionInfos[i].user == _user){
				uint256 deservedReward = transactionInfos[i].amount.mul(getBoostMultiplier(i).mul(accYWTPerShare)).div(1e12).sub(transactionInfos[i].claimedReward);
				totalDeservedReward = totalDeservedReward.add(deservedReward);
			}
		}
		if(referrCount[msg.sender] > 0) {
			referralBonus = totalDeservedReward.mul(bonusPerReferral).div(100).mul(referrCount[msg.sender]);
		}
		finalyPendingReward = totalDeservedReward.add(referralBonus);
        return (totalDeservedReward, referralBonus, finalyPendingReward);
    }

   // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 timeInterval = getTimeInterval(block.number,pool.lastRewardBlock);
        uint256 ywtReward = timeInterval.mul(ywtPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accYWTPerShare = pool.accYWTPerShare.add(ywtReward.mul(1e12).div(lpSupply));
		pool.lastRewardBlock = block.number;
    }

    // 待领取的奖励代币(在前端查看)
    function getPendingReward(uint256 _pid, address _user) private returns (uint256 totalDeservedReward,uint256 finalyPendingReward) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        for (uint i = 0; i < transactionInfos.length; i++) {
            if(transactionInfos[i].lpToken == pool.lpToken && transactionInfos[i].user == _user){
				transactionInfos[i].deservedReward = transactionInfos[i].amount.mul(getBoostMultiplier(i).mul(pool.accYWTPerShare)).div(1e12).sub(transactionInfos[i].claimedReward);
                totalDeservedReward = totalDeservedReward.add(transactionInfos[i].deservedReward);
            }
        }
		if(referrCount[msg.sender] > 0) {
			user.referralBonus = totalDeservedReward.mul(bonusPerReferral).div(100).mul(referrCount[msg.sender]);
		}
		finalyPendingReward = totalDeservedReward.add(user.referralBonus);
		return (totalDeservedReward, finalyPendingReward);
    }

    // 将LP代币存入某一个流动池以赚取奖励代币
    function firstDeposite(uint256 _pid, uint256 _amount, uint256 _depositDays, address _referral) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
		updatePool(_pid);
        require( _amount * 10 ** 18 >= threshold ,"Threshold amount must be met");
        require(_depositDays == 3 || _depositDays == 5 || _depositDays == 7 || _depositDays == 9,"depositDays amount must be met");

        if(_referral == msg.sender) {
            referrals[msg.sender] = _referral;
            isDeposited[msg.sender] = true;
        }

        if(_referral != msg.sender && _referral != address(0)) {
            referrals[msg.sender] = _referral;
            referrCount[_referral]++;
        }
        pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount * 10 ** 18);
        transactionInfos.push(TransactionInfo({
            lpToken: pool.lpToken,
            user: msg.sender,
            amount: _amount * 10 ** 18,
            lastDepositTime: block.timestamp,
            depositDays: _depositDays.mul(60),
            deservedReward: 0,
            claimedReward: 0
        }));
        user.totalDepositAmount = user.totalDepositAmount.add(_amount * 10 ** 18);
        isDeposited[msg.sender] = true;
        emit Deposit(msg.sender, _pid, _amount * 10 ** 18);
    }

    function deposite(uint256 _pid, uint256 _amount, uint256 _depositDays) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
		updatePool(_pid);
        require( _amount * 10 ** 18 >= threshold ,"Threshold amount must be met");
        require(_depositDays == 3 || _depositDays == 5 || _depositDays == 7 || _depositDays == 9,"depositDays amount must be met");
        pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount * 10 ** 18);
        transactionInfos.push(TransactionInfo({
            lpToken: pool.lpToken,
            user: msg.sender,
            amount: _amount * 10 ** 18,
            lastDepositTime: block.timestamp,
            depositDays: _depositDays.mul(60),
            deservedReward: 0,
            claimedReward: 0
        }));
        user.totalDepositAmount = user.totalDepositAmount.add(_amount * 10 ** 18);
        isDeposited[msg.sender] = true;
        emit Deposit(msg.sender, _pid, _amount * 10 ** 18);
    }
        
    // 通过已经质押的LP代币领取奖励代币
    function claim(uint256 _pid) public {
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.totalDepositAmount > 0,"claim: user's amount must be greater than 0");
		updatePool(_pid);
        (,uint256 pending) = getPendingReward(_pid, msg.sender);
        safeYWTTransfer(msg.sender, pending);
        user.claimedReward = user.claimedReward + pending;
        emit Claim(msg.sender, _pid);
    }

    // // 从某一个流动池中撤回LP代币。
    function withdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
		updatePool(_pid);
        (,uint256 pending) = getPendingReward(_pid, msg.sender);
        safeYWTTransfer(msg.sender, pending);
        user.claimedReward = user.claimedReward + pending;
        require(user.totalDepositAmount > 0,"withdraw: user's amount must be greater than 0");
        require(getAllowedWithdrawAmount(_pid,msg.sender) > 0, "withdraw: user's allowedWithdrawLP must be greater than 0");
        uint256 allowedWithdrawLPAmount = getAllowedWithdrawAmount(_pid,msg.sender);
        deleteWithdrawTX(_pid);
        pool.lpToken.safeTransfer(address(msg.sender), allowedWithdrawLPAmount);
        user.totalDepositAmount = user.totalDepositAmount.sub(allowedWithdrawLPAmount);
        emit Withdraw(msg.sender, _pid, allowedWithdrawLPAmount);
    }

    function deleteWithdrawTX(uint256 _pid) private {   
        PoolInfo storage pool = poolInfo[_pid];
        for (uint i = 0; i < transactionInfos.length; i++) {
            if(transactionInfos[i].lpToken == pool.lpToken && transactionInfos[i].user == msg.sender) {
                if(block.timestamp > (transactionInfos[i].lastDepositTime + transactionInfos[i].depositDays)) {
                    delete transactionInfos[i];
                }
            }
        }
    }

    function getAllowedWithdrawAmount(uint256 _pid,address _user) public view returns(uint256 amount){
        PoolInfo storage pool = poolInfo[_pid];
        for (uint i = 0; i < transactionInfos.length; i++) {
            if(transactionInfos[i].lpToken == pool.lpToken && transactionInfos[i].user == _user) {
                if(block.timestamp > (transactionInfos[i].lastDepositTime + transactionInfos[i].depositDays)) {
                    amount = amount + transactionInfos[i].amount;
                }  
            }
        }
        return amount;
    }

    // 不在乎奖励 直接撤池。 仅限紧急情况。因为这意味着只能拿回质押的LP代币 放弃所有还没有领取的奖励代币
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.transfer(address(msg.sender), user.totalDepositAmount);
        emit EmergencyWithdraw(msg.sender, _pid, user.totalDepositAmount);
        delete transactionInfos;
        user.totalDepositAmount = 0;
    }

    function deleteAllWithdrawTX(uint256 _pid) private {        
        PoolInfo storage pool = poolInfo[_pid];
        for (uint i = 0; i <= transactionInfos.length; i++) {
            if(transactionInfos[i].lpToken == pool.lpToken && transactionInfos[i].user == msg.sender) {
                delete transactionInfos[i];
            }
        }
    }

    // 安全的空投奖励函数  用户可以向事先预存的钱包地址领取奖励代币
    function safeYWTTransfer(address _to, uint256 _amount) internal {
        uint256 YWTBal = IERC20(YWT).balanceOf(address(this));
        if (_amount > YWTBal) {
            IERC20(YWT).transfer(_to, YWTBal);
        } else {
            IERC20(YWT).transfer( _to, _amount);
        }
    }

    // 重新设置奖励代币的合约地址
    function setRewardAddress(address _ywt) external onlyOwner {
        YWT = _ywt;
    }

    // 重新设置每天能够领取的代币 只能由所有者调用。
    function updateReleaseRate(uint256 _ywtPerBlock) public onlyOwner {
        ywtPerBlock = _ywtPerBlock;
        emit UpdateReleaseRate(msg.sender, _ywtPerBlock);
    }

    // 重新设置质押门槛
    function setThreshold(uint256 _value) public onlyOwner {
        threshold = _value;
    }

    // 重新设置推荐奖励率
    function setReferralBonus(uint256 _value) public onlyOwner {
        bonusPerReferral = _value;
    }

    // 重新设置质押一个月的奖励乘数
    function setOneMonthMultipliter(uint256 _value) public onlyOwner {
        oneMonthMultipliter = _value;
    }

    // 重新设置质押三个月的奖励乘数
    function setThreeMonthMultipliter(uint256 _value) public onlyOwner {
        threeMonthMultipliter = _value;
    }
    
    // 重新设置质押六个月的奖励乘数
    function setSixMonthMultipliter(uint256 _value) public onlyOwner {
        sixMonthMultipliter = _value;
    }

    // 重新设置质押一年的奖励乘数
    function setOneYearMultipliter(uint256 _value) public onlyOwner {
        oneYearMultipliter = _value;
    }
}