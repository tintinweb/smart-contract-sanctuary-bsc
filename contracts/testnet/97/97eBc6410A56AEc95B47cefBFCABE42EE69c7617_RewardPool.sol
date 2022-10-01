/**
 *Submitted for verification at BscScan.com on 2021-04-27
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        require(b > 0, errorMessage);
        return a / b;
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
        require(b > 0, errorMessage);
        return a % b;
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }


    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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
library SafeERC20 {
    using SafeMath for uint256;
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
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface ITokenLocker {
    function startReleaseBlock() external view returns (uint256);

    function endReleaseBlock() external view returns (uint256);

    function totalLock() external view returns (uint256);

    function totalReleased() external view returns (uint256);

    function lockOf(address _account) external view returns (uint256);

    function released(address _account) external view returns (uint256);

    function canUnlockAmount(address _account) external view returns (uint256);

    function lock(address _account, uint256 _amount) external;

    function unlock(uint256 _amount) external;

    function unlockAll() external;

    function claimUnlocked() external;
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return address(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract vBSWAP is ERC20 {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public governance;
    mapping(address => bool) public minters;

    uint256 public cap;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _cap
    ) ERC20(_name, _symbol) {
        _setupDecimals(_decimals);
        cap = _cap;
        governance = msg.sender;
    }

    modifier onlyGovernance() {
        require(msg.sender == governance, "!governance");
        _;
    }

    modifier onlyMinter() {
        require(msg.sender == governance || minters[msg.sender], "!governance && !minter");
        _;
    }

    function mint(address _to, uint256 _amount) external onlyMinter {
        _mint(_to, _amount);
    }

    function burn(uint256 _amount) external {
        _burn(msg.sender, _amount);
    }

    function burnFrom(address _account, uint256 _amount) external {
        uint256 decreasedAllowance = allowance(_account, msg.sender).sub(_amount, "ERC20: burn amount exceeds allowance");
        _approve(_account, msg.sender, decreasedAllowance);
        _burn(_account, _amount);
    }

    function setGovernance(address _governance) external onlyGovernance {
        governance = _governance;
    }

    function addMinter(address _minter) external onlyGovernance {
        minters[_minter] = true;
    }

    function removeMinter(address _minter) external onlyGovernance {
        minters[_minter] = false;
    }

    function setCap(uint256 _cap) external onlyGovernance {
        require(_cap >= totalSupply(), "_cap is below current total supply");
        cap = _cap;
    }

    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - minted tokens must not cause the total supply to go over the cap.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) {
            // When minting tokens
            require(totalSupply().add(amount) <= cap, "ERC20Capped: cap exceeded");
        }
    }

    // This function allows governance to take unsupported tokens out of the contract. This is in an effort to make someone whole, should they seriously mess up.
    // There is no guarantee governance will vote to return these. It also allows for removal of airdropped tokens.
    function governanceRecoverUnsupported(
        IERC20 _token,
        address _to,
        uint256 _amount
    ) external onlyGovernance {
        _token.safeTransfer(_to, _amount);
    }
}


contract RewardPool {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // governance
    address public operator;

    // flags
    bool public initialized;

    address public reserveFund;
    uint256 public reservePercent; // 100 = 1%

    address public exchangeProxy;
    uint256 private _unlocked;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. vBSWAPs to distribute per block.
        uint256 lastRewardBlock; // Last block number that vBSWAPs distribution occurs.
        uint256 accRewardPerShare; // Accumulated vBSWAPs per share, times 1e18. See below.
        bool isStarted; // if lastRewardBlock has passed
    }

    vBSWAP public vbswapToken;

    // Info of each pool.
    PoolInfo[] public poolInfo;

    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint;

    // The block number when vBSWAP mining starts.
    uint256 public startBlock;

    uint256 public constant BLOCKS_PER_DAY = 28800; // 24 * 60 * 60 / 3;
    uint256 public constant BLOCKS_PER_WEEK = 201600; // 28800 * 7;

    uint256 public constant firstEpochRewardPerBlock = 0.0124 ether; // Total 10600 vBSWAP for the first 4 weeks, and decreasing 10% for the next epochs

    uint256[29] public epochEndBlocks;
    uint256[29] public epochRewardPerBlock;

    /* =================== Added variables (need to keep orders for proxy to work) =================== */
    uint256 public rewardFactor; // 106%
    uint256 public lockPoolId;
    uint256 public lockPoolSupply;
    mapping(uint256 => mapping(address => uint256)) public lastActionTimestamp; // pid => user => last action timestamp (deposit/withdraw/claim)
    mapping(uint256 => mapping(address => uint256)) public userPendingRewards; // pid => user => pending (deposit more while reward still in locked)
    mapping(uint256 => uint256) public lockPeriods; // pid => lock time (seconds)
    mapping(uint256 => bool) public stopPaying;
    address public tokenLocker;
    mapping(uint256 => uint256) public tokenLockedPercent;

    event Initialized(address indexed executor, uint256 at);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event RewardPaid(address indexed user, uint256 amount);

    modifier onlyOperator() {
        require(operator == msg.sender, "RewardPool: caller is not the operator");
        _;
    }

    modifier onlyExchangeProxy() {
        require(exchangeProxy == msg.sender, "RewardPool: caller is not the exchangeProxy");
        _;
    }

    modifier lock() {
        require(_unlocked == 1, "StakePoolEpochReward: LOCKED");
        _unlocked = 0;
        _;
        _unlocked = 1;
    }

    modifier notInitialized() {
        require(!initialized, "RewardPool: initialized");
        _;
    }

    function initialize(address _vbSwap, uint256 _block) public notInitialized {
        // require(block.number < _startBlock, "late");

        vbswapToken = vBSWAP(_vbSwap);
        startBlock = _block; // supposed to be 5,128,600 (Tue Feb 23 2021 12:00:00 UTC)
        reservePercent = 600;
        epochEndBlocks[0] = startBlock + BLOCKS_PER_WEEK * 4;
        epochRewardPerBlock[0] = firstEpochRewardPerBlock;
        _unlocked = 1;
        rewardFactor = 10600;
        uint256 i;
        for (i = 1; i < 28; i++) {
            epochEndBlocks[i] = epochEndBlocks[i - 1] + BLOCKS_PER_WEEK * 4;
            epochRewardPerBlock[i] = (epochRewardPerBlock[i - 1] * 9) / 10;
        }
        epochEndBlocks[28] = 2**256 - 1;
        epochRewardPerBlock[28] = 0.00001 ether; // tiny amount
        reservePercent = 600; // 6%
        _unlocked = 1;
        operator = msg.sender;
        reserveFund = msg.sender;
        initialized = true;
        emit Initialized(msg.sender, block.number);
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function startReleaseBlock() public view returns (uint256) {
        return ITokenLocker(tokenLocker).startReleaseBlock();
    }

    function endReleaseBlock() external view returns (uint256) {
        return ITokenLocker(tokenLocker).endReleaseBlock();
    }

    function checkPoolDuplicate(IERC20 _lpToken) internal view {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            require(poolInfo[pid].lpToken != _lpToken, "RewardPool: existing pool?");
        }
    }

    // Add a new lp to the pool. Can only be called by the owner.
    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate,
        uint256 _lastRewardBlock
    ) public onlyOperator {
        if (poolInfo.length > 0 && lockPoolId == 0 && address(_lpToken) == address(poolInfo[0].lpToken)) {
            // to add locked reward pool with same LP with main liquidity pool (vBSWAP-BNB 50/50)
            lockPoolId = poolInfo.length;
        } else {
            checkPoolDuplicate(_lpToken);
        }
        if (_withUpdate) {
            massUpdatePools();
        }
        if (block.number < startBlock) {
            // chef is sleeping
            if (_lastRewardBlock == 0) {
                _lastRewardBlock = startBlock;
            } else {
                if (_lastRewardBlock < startBlock) {
                    _lastRewardBlock = startBlock;
                }
            }
        } else {
            // chef is cooking
            if (_lastRewardBlock == 0 || _lastRewardBlock < block.number) {
                _lastRewardBlock = block.number;
            }
        }
        bool _isStarted = (_lastRewardBlock <= startBlock) || (_lastRewardBlock <= block.number);
        poolInfo.push(PoolInfo({lpToken: _lpToken, allocPoint: _allocPoint, lastRewardBlock: _lastRewardBlock, accRewardPerShare: 0, isStarted: _isStarted}));
        if (_isStarted) {
            totalAllocPoint = totalAllocPoint.add(_allocPoint);
        }
    }

    // Update the given pool's vBSWAP allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint) public onlyOperator {
        massUpdatePools();
        PoolInfo storage pool = poolInfo[_pid];
        if (pool.isStarted) {
            totalAllocPoint = totalAllocPoint.sub(pool.allocPoint).add(_allocPoint);
        }
        pool.allocPoint = _allocPoint;
    }

    function getRewardLockUntil(uint256 _pid, address _user) public view returns (uint256) {
        return lastActionTimestamp[_pid][_user].add(lockPeriods[_pid]);
    }

    // Return accumulate rewards over the given _from to _to block.
    function getGeneratedReward(uint256 _from, uint256 _to) public view returns (uint256) {
        for (uint8 epochId = 28; epochId >= 1; --epochId) {
            if (_to >= epochEndBlocks[epochId - 1]) {
                if (_from >= epochEndBlocks[epochId - 1]) return _to.sub(_from).mul(epochRewardPerBlock[epochId]);
                uint256 _generatedReward = _to.sub(epochEndBlocks[epochId - 1]).mul(epochRewardPerBlock[epochId]);
                if (epochId == 1) return _generatedReward.add(epochEndBlocks[0].sub(_from).mul(epochRewardPerBlock[0]));
                for (epochId = epochId - 1; epochId >= 1; --epochId) {
                    if (_from >= epochEndBlocks[epochId - 1]) return _generatedReward.add(epochEndBlocks[epochId].sub(_from).mul(epochRewardPerBlock[epochId]));
                    _generatedReward = _generatedReward.add(epochEndBlocks[epochId].sub(epochEndBlocks[epochId - 1]).mul(epochRewardPerBlock[epochId]));
                }
                return _generatedReward.add(epochEndBlocks[0].sub(_from).mul(epochRewardPerBlock[0]));
            }
        }
        return _to.sub(_from).mul(epochRewardPerBlock[0]);
    }

    function getCurrentRewardPerBlock() external view returns (uint256) {
        return getGeneratedReward(block.number, block.number + 1);
    }

    // View function to see pending vBSWAPs on frontend.
    function pendingReward(uint256 _pid, address _user) external view returns (uint256 _pendingReward) {
        if (_pid == 0) {
            return 0; // disable first pool
        }
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 lpSupply;
        if (_pid == 0) {
            lpSupply = pool.lpToken.balanceOf(address(this));
            lpSupply = (lpSupply <= lockPoolSupply) ? 0 : lpSupply.sub(lockPoolSupply);
        } else if (_pid == lockPoolId) {
            lpSupply = lockPoolSupply;
        } else {
            lpSupply = pool.lpToken.balanceOf(address(this));
        }
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 _generatedReward = getGeneratedReward(pool.lastRewardBlock, block.number);
            uint256 _vbswapTokenReward = _generatedReward.mul(pool.allocPoint).div(totalAllocPoint);
            accRewardPerShare = accRewardPerShare.add(_vbswapTokenReward.mul(1e18).div(lpSupply));
        }
        _pendingReward = user.amount.mul(accRewardPerShare).div(1e18).sub(user.rewardDebt);
        if (rewardFactor > 0) {
            _pendingReward = _pendingReward.mul(rewardFactor).div(10000);
            if (reservePercent > 0 && reserveFund != address(0)) {
                _pendingReward = _pendingReward.mul(10000 - reservePercent).div(10000);
            }
        }
        _pendingReward = _pendingReward.add(userPendingRewards[_pid][_user]);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply;
        if (_pid == 0) {
            lpSupply = pool.lpToken.balanceOf(address(this));
            lpSupply = (lpSupply <= lockPoolSupply) ? 0 : lpSupply.sub(lockPoolSupply);
        } else if (_pid == lockPoolId) {
            lpSupply = lockPoolSupply;
        } else {
            lpSupply = pool.lpToken.balanceOf(address(this));
        }
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        if (!pool.isStarted) {
            pool.isStarted = true;
            totalAllocPoint = totalAllocPoint.add(pool.allocPoint);
        }
        if (totalAllocPoint > 0) {
            uint256 _generatedReward = getGeneratedReward(pool.lastRewardBlock, block.number);
            uint256 _vbswapTokenReward = _generatedReward.mul(pool.allocPoint).div(totalAllocPoint);
            pool.accRewardPerShare = pool.accRewardPerShare.add(_vbswapTokenReward.mul(1e18).div(lpSupply));
        }
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens
    function _deposit(
        address _account,
        uint256 _pid,
        uint256 _amount
    ) internal lock {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_account];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 _pending = user.amount.mul(pool.accRewardPerShare).div(1e18).sub(user.rewardDebt);
            if (_pending > 0) {
                if (block.timestamp >= getRewardLockUntil(_pid, _account)) {
                    _pending = _pending.add(userPendingRewards[_pid][_account]);
                    userPendingRewards[_pid][_account] = 0;
                    if (_pid != 0 && !stopPaying[_pid]) {
                        // stop pool 0 for emergency
                        safeVbswapMint(_pid, _account, _pending);
                    }
                    emit RewardPaid(_account, _pending);
                } else {
                    require(_amount > 0, "claim while still in locked");
                    userPendingRewards[_pid][_account] = userPendingRewards[_pid][_account].add(_pending);
                }
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(msg.sender, address(this), _amount);
            user.amount = user.amount.add(_amount);
            if (_pid == lockPoolId) {
                lockPoolSupply = lockPoolSupply.add(_amount);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e18);
        lastActionTimestamp[_pid][_account] = block.timestamp;
        emit Deposit(_account, _pid, _amount);
    }

    function deposit(uint256 _pid, uint256 _amount) external {
        _deposit(msg.sender, _pid, _amount);
    }

    function depositFor(
        address _account,
        uint256 _pid,
        uint256 _amount
    ) external onlyExchangeProxy {
        _deposit(_account, _pid, _amount);
    }

    // Withdraw LP tokens.
    function _withdraw(
        address _account,
        uint256 _pid,
        uint256 _amount
    ) internal lock {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_account];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 _pending = user.amount.mul(pool.accRewardPerShare).div(1e18).sub(user.rewardDebt);
        if (_pending > 0) {
            if (block.timestamp >= getRewardLockUntil(_pid, _account)) {
                _pending = _pending.add(userPendingRewards[_pid][_account]);
                userPendingRewards[_pid][_account] = 0;
                if (_pid != 0 && !stopPaying[_pid]) {
                    // stop pool 0 for emergency
                    safeVbswapMint(_pid, _account, _pending);
                }
                emit RewardPaid(_account, _pending);
            } else {
                require(_amount > 0, "claim while still in locked");
                userPendingRewards[_pid][_account] = 0;
            }
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            if (_pid == lockPoolId) {
                lockPoolSupply = lockPoolSupply.sub(_amount);
            }
            pool.lpToken.safeTransfer(_account, _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e18);
        lastActionTimestamp[_pid][_account] = block.timestamp;
        emit Withdraw(_account, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {
        _withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 _amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        lastActionTimestamp[_pid][msg.sender] = 0;
        pool.lpToken.safeTransfer(msg.sender, _amount);
        emit EmergencyWithdraw(msg.sender, _pid, _amount);
    }

    // Safe vbswapToken transfer function
    function safeVbswapMint(
        uint256 _pid,
        address _to,
        uint256 _amount
    ) internal {
        if (vbswapToken.minters(address(this)) && _to != address(0)) {
            uint256 _totalSupply = vbswapToken.totalSupply();
            uint256 _cap = vbswapToken.cap();
            uint256 _mintAmount = (_totalSupply.add(_amount) <= _cap) ? _amount : _cap.sub(_totalSupply);
            if (_mintAmount > 0) {
                if (rewardFactor == 0) {
                    _mintAndLock(_pid, _to, _mintAmount);
                    if (reservePercent > 0 && reserveFund != address(0)) {
                        uint256 _reserveAmount = _mintAmount.mul(reservePercent).div(10000);
                        _totalSupply = vbswapToken.totalSupply();
                        _cap = vbswapToken.cap();
                        _reserveAmount = (_totalSupply.add(_reserveAmount) <= _cap) ? _reserveAmount : _cap.sub(_totalSupply);
                        if (_reserveAmount > 0) {
                            _mintAndLock(_pid, reserveFund, _reserveAmount);
                        }
                    }
                } else {
                    _mintAmount = _mintAmount.mul(rewardFactor).div(10000);
                    _mintAmount = (_totalSupply.add(_mintAmount) <= _cap) ? _mintAmount : _cap.sub(_totalSupply);
                    if (reservePercent > 0 && reserveFund != address(0)) {
                        uint256 _reserveAmount = _mintAmount.mul(reservePercent).div(10000);
                        if (_reserveAmount > 0) {
                            _mintAndLock(_pid, reserveFund, _reserveAmount);
                            _mintAmount = _mintAmount.sub(_reserveAmount);
                        }
                    }
                    _mintAndLock(_pid, _to, _mintAmount);
                }
            }
        }
    }

    function _mintAndLock(
        uint256 _pid,
        address _account,
        uint256 _amount
    ) internal {
        vbswapToken.mint(address(this), _amount);
        uint256 _tokenLockedPercent = tokenLockedPercent[_pid];
        if (_tokenLockedPercent > 0) {
            if (block.number < startReleaseBlock()) {
                uint256 _tokenLockedAmount = _amount.mul(_tokenLockedPercent).div(10000);
                _amount = _amount.sub(_tokenLockedAmount);
                IERC20(vbswapToken).safeIncreaseAllowance(address(tokenLocker), _tokenLockedAmount);
                ITokenLocker(tokenLocker).lock(_account, _tokenLockedAmount);
            }
        }
        IERC20(address(vbswapToken)).safeTransfer(_account, _amount);
    }

    function harvestAllRewards() external {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            if (userInfo[pid][msg.sender].amount > 0) {
                withdraw(pid, 0);
            }
        }
    }

    function setOperator(address _operator) external onlyOperator {
        operator = _operator;
    }

    function setReserveFund(address _reserveFund) external {
        require(reserveFund == msg.sender, "RewardPool: !reserveFund");
        reserveFund = _reserveFund;
    }

    function setReservePercent(uint256 _reservePercent) external onlyOperator {
        require(_reservePercent <= 3000, "_reservePercent > 30%");
        reservePercent = _reservePercent;
    }

    function setEpochEndBlock(uint256 _index, uint256 _value) external onlyOperator {
        require(block.number < epochEndBlocks[_index] && block.number < _value, "late");
        require(_index == 27 || _value < epochEndBlocks[_index + 1], "out of range");
        epochEndBlocks[_index] = _value;
    }

    function setEpochRewardPerBlock(uint256 _index, uint256 _value) external onlyOperator {
        require(_index == 28 || block.number < epochEndBlocks[_index], "late");
        require(_value <= firstEpochRewardPerBlock, "too high");
        massUpdatePools();
        epochRewardPerBlock[_index] = _value;
    }

    function setExchangeProxy(address _exchangeProxy) external onlyOperator {
        exchangeProxy = _exchangeProxy;
    }

    function setRewardFactor(uint256 _rewardFactor) external onlyOperator {
        rewardFactor = _rewardFactor;
    }

    function setLockPeriod(
        uint256 _pid,
        bool _stopPaying,
        uint256 _seconds
    ) external onlyOperator {
        stopPaying[_pid] = _stopPaying;
        lockPeriods[_pid] = _seconds;
    }

    function setTokenLocker(address _tokenLocker) external onlyOperator {
        require(ITokenLocker(_tokenLocker).startReleaseBlock() > 0 && IERC20(_tokenLocker).totalSupply() >= 0, "invalid token locker");
        tokenLocker = _tokenLocker;
    }

    function setTokenLockedPercent(uint256 _pid, uint256 _tokenLockedPercent) external onlyOperator {
        require(_tokenLockedPercent <= 10000, "_tokenLockedPercent > 100%");
        tokenLockedPercent[_pid] = _tokenLockedPercent;
    }

    // This function allows governance to take unsupported tokens out of the contract. This is in an effort to make someone whole, should they seriously mess up.
    // There is no guarantee governance will vote to return these. It also allows for removal of airdropped tokens.
    function governanceRecoverUnsupported(
        IERC20 _token,
        uint256 amount,
        address to
    ) external onlyOperator {
        // do not allow to drain lpToken
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            PoolInfo storage pool = poolInfo[pid];
            require(_token != pool.lpToken, "pool.lpToken");
        }
        _token.safeTransfer(to, amount);
    }
}