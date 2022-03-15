/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
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
        assembly { size := extcodesize(account) }
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
        (bool success, ) = recipient.call{ value: amount }("");
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}
library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
         {
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
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
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
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
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

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
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

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

        _totalSupply += amount;
        _balances[account] += amount;
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

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        _approve(account, _msgSender(), currentAllowance - amount);
        _burn(account, amount);
    }
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ChaTokenPool is Ownable{
     using SafeMath for *;
     using SafeERC20 for ERC20Burnable;
      
      ERC20Burnable public lpt;
         struct Order{
            uint256 amount;
        }

       mapping (address => uint256) public stakes;
      
     constructor(address lptoken_)  {
        lpt = ERC20Burnable(lptoken_);
    }
    uint256 public destroyed = 2*1e18;//销毁数量 
    function setDestroyed(uint256 _destroyed) public onlyOwner{
        destroyed = _destroyed;
    }
    //销毁
    function brunBox() public {
        lpt.burnFrom(msg.sender,destroyed);
    }
   //销毁
    function brun(uint256 brunSum) public {
        lpt.burnFrom(msg.sender,brunSum);
        stakes[msg.sender] += brunSum;
    }

    function getTakeOutNumber(address addr) public view returns (uint256){
        return stakes[addr];
    }

}
contract Transaction is Ownable {
     using SafeMath for uint256;
     using SafeERC20 for IERC20;
    IERC20 public token;
    address public teamWallet;
    constructor (address token_,address teamWallet_) {
        token = IERC20(token_);
        teamWallet = teamWallet_;
    }
    uint256 public freedFirst = 10; //手续费 10%
    uint256 public freedBase = 100;

     uint256 public num = 100000*1e18;//最小值
    
    mapping(string => address) public _addressList;

    function setNum(uint256 _num) public onlyOwner{
        num = _num;
    }

    function setFreedFirst(uint256 _freedFirst) public onlyOwner{
        freedFirst = _freedFirst;
    }

    function exchange(string memory rand, uint256 amount) public{
         require(_addressList[rand] == 0x0000000000000000000000000000000000000000, 'Already exists');
         require(amount >= num, 'less than min');
        _addressList[rand] = _msgSender();
       uint256 number =  amount.mul(freedFirst).div(freedBase);
        token.safeTransferFrom(_msgSender(), teamWallet, number);
        token.safeTransferFrom(_msgSender(), address(this), amount.sub(number));
    }

    //转回
    function transfer_contract() public  onlyOwner{
        token.safeTransfer(msg.sender, token.balanceOf(address(this)));
    }
    //销毁
    
}
contract Purcase is Ownable{
     using SafeMath for uint256;
     using SafeERC20 for IERC20;
    address public teamWallet;
    IERC20 public token;
    IERC20 public chacha;
    IERC20 public usdt;
    address public staks;//销毁质押合约地址
   
     struct Order{
         uint256 number;
        uint256 amount;
        uint256 time;
        address stake_address;
    }
     //uint256 public freed = 5; //0.5%
     //uint256 public freedBase = 1000;
     //uint256 public freedFirst = 100; //首次释放10%
     //uint256 public  DURATION = 86400;
    struct  Player {
        uint256 amount;
        uint256 amountPayed;
        uint256 ordersIndex;
        mapping (uint256 => Order) orders;
        uint256 number; //投资
    }

     mapping (address => Player) public _plyr;//购买某一个token

    constructor(address usdt_,address teamwallet_, address staks_,address chacha_,address token_)  {
        usdt = IERC20(usdt_);
        teamWallet = teamwallet_;
        staks = staks_;//质押合约销毁
        chacha = IERC20(chacha_);//质押本金币种
        token = IERC20(token_);//项目方币种
    }
    modifier checkEnd() {
        require(block.timestamp <= endTime, 'is end');
        require(hasTokenCount <= maxTokenCount,'TokenCount is end');
        _;
    }
        uint256 public price = 52*1e17;
        uint256 public startTime = 1644981925;//开始时间
        uint256 public endTime = 1647401124;//申购结束
        uint256 public minAmount=10*1e18;//最小数量
        uint256 public maxAmount = 500*1e18;//最大数量
        uint256 public hasTokenCount;//进度数量
        uint256 public maxTokenCount = 2000*1e18;//进度额
        uint256 public target = 1000*1e18;//预计值
        uint256 public endDays=432;//释放之后时间
        uint256 public time_days=173;//释放间隔时间
        uint8 public number=2;//分隔数量
    struct Vip{
        uint8 level;
        uint256 start_num;
        uint256 end_num;
    }
     Vip[] public vips;

     struct Burns{
        uint8 proportion;
        uint256 num;
    }
     Burns[] public burnsList;
    mapping (uint256 => uint256) public vipList;   //项目中等级列表

    mapping (uint8=>bool) public isVip;
    uint256  freedBase = 100;
   

    function addBurnProportion(uint8 num_,uint8 proportion_)public onlyOwner{
        burnsList.push(Burns({proportion:proportion_,num:num_}));
    }
     function editMaxTokenCount(uint256 maxTokenCount_) public onlyOwner{
         maxTokenCount = maxTokenCount_;
    }
     function editTarget(uint256 target_) public onlyOwner{
         target = target_;
    }
     function projectPrice(uint256 price_) public onlyOwner{
         price = price_;
    }
    function projectTimeDays(uint256 time_days_) public onlyOwner{
        time_days = time_days_;
    }
    function editEndTime(uint256 endTime_) public onlyOwner{
        endTime = endTime_;
    }
    function editMinAmount(uint256 minAmount_) public onlyOwner{
        minAmount = minAmount_;
    }
    function editMaxAmount(uint256 maxAmount_) public onlyOwner{
        maxAmount = maxAmount_;
    }
    //添加项目中等级 number_最大购买
    function addProjectLevel(uint8 level_,uint256 number_)public onlyOwner{
        require(isVip[level_], 'not Level');
        vipList[level_] = number_;
    }
     //每一个合约币的数量
    function calcUsdtToToken(uint256 amount) public view returns (uint256){

        return amount.mul(1e18).div(price);
    }

    function calcTokenToUsdt(uint256 amount) public view returns (uint256){

        return amount.mul(price).div(1e18);
    }

    //投资
    function stake(uint256 amount) public checkEnd(){

        require(amount >= minAmount,"is not minAmount");

        uint256 receivedToken = calcUsdtToToken(amount);//每一个合约币的价格

        uint256 newAmount  = receivedToken.add(_plyr[msg.sender].amount);//当前合约币的价格数量 + 当前地址已经购买的数量

        uint256 usdtMaxAmount = calcTokenToUsdt(newAmount);//最新的数量 * 价格
        if(vip_level(msg.sender)>0){
           maxAmount = vipList[vip_level(msg.sender)];
        }
        require(usdtMaxAmount <= maxAmount,"is not maxAmount");
       //销毁数量
        uint actualNumber;
        if(burnProportion(msg.sender) >= 0){
            actualNumber = amount.sub(amount.mul(burnProportion(msg.sender)).div(freedBase));
        }else{
            actualNumber = amount;
        }
        usdt.safeTransferFrom(_msgSender(), teamWallet, actualNumber);
         _plyr[msg.sender].amount = newAmount;
         _plyr[msg.sender].number = (_plyr[msg.sender].number).add(actualNumber);
         //某一个token中的地址购买订单记录
         _plyr[msg.sender].orders[_plyr[msg.sender].ordersIndex].number = actualNumber;
         _plyr[msg.sender].orders[_plyr[msg.sender].ordersIndex].amount = receivedToken;
         _plyr[msg.sender].orders[_plyr[msg.sender].ordersIndex].time = block.timestamp;
         _plyr[msg.sender].ordersIndex++;
    
         hasTokenCount = hasTokenCount.add(amount);
    }

    function getUserOrder(address addr) public view returns(uint256[] memory,uint256[] memory){
        uint256[] memory amount = new uint256[](_plyr[addr].ordersIndex);
        uint256[] memory time = new uint256[](_plyr[addr].ordersIndex);
        for(uint256 i=0;i<_plyr[addr].ordersIndex;i++){
            amount[i] = _plyr[addr].orders[i].number;
            time[i] = _plyr[addr].orders[i].time;
        }
        return(amount,time);
    }


    //vip
    function vipLevel(uint8 level_,uint256 start_num_ , uint256 end_num_ ) public onlyOwner{
        require(!isVip[level_], 'Vip Already exists');
        vips.push(Vip({level:level_,start_num:start_num_,end_num:end_num_}));
        isVip[level_] = true;
    }
    function burnProportion(address addr) view public returns (uint8){
        uint burnNumber =  ChaTokenPool(staks).getTakeOutNumber(addr);
        uint8 proportion = 0;
         for(uint256 i=0;i<burnsList.length;i++){
             if(burnNumber >= burnsList[i].num){
                  proportion = burnsList[i].proportion;
             }
        }
         return proportion;
    }
    function vip_level(address addr) view public returns (uint8){
        uint8 level = 0;
         for(uint256 i=0;i<vips.length;i++){
             if(getTakeOutNumber(addr)>= vips[i].start_num){
                  level = vips[i].level;
             }else if(getTakeOutNumber(addr)>= vips[i].start_num && vips[i].end_num == 0){
                  level = vips[i].level;
             }
        }
         return level;
    }

    //修改vip 000000000000000000
    function editVip(uint8 level_,uint256 start_num_, uint256 end_num_) public onlyOwner{
         for(uint256 i=0;i<vips.length;i++){
             if(vips[i].level == level_){
                  vips[i].start_num = start_num_;
                  vips[i].end_num = end_num_;
             }
        }
    }

    function vipLists() public view returns(Vip[] memory){
        return vips;
    }



    function earned(address addr) public view returns(uint256){
        uint256 amount = 0;
        if(block.timestamp > endTime+endDays){
            Player storage user = _plyr[addr];
            //amount = user.amount;//百分之10手续费金额.mul(freedFirst).div(freedBase)
            //uint256 dayAmount = user.amount.mul(freed).div(freedBase);//千分之5手续费金额
           uint256 nu = calcDays(endTime,time_days+endDays);
           uint256 freedAmount;
            if(nu == 0){
                  if(endDays > 0){
                  freedAmount =  user.amount.mul(calcDays(endTime,endDays)).div(number);
                 }else{
                 freedAmount = user.amount.mul(1).div(number);
                 }
             }else{
                  freedAmount = user.amount.mul(1+calcDays(endTime+endDays,time_days)).div(number);//手续费金额* 设置时间内的倍数 （当前时间-开始时间 /设置时间）
             }
            //amount = amount.add(freedAmount);
            if(freedAmount > user.amount){
                amount = user.amount;
            }else{
                amount = freedAmount;
            }
            amount = amount.sub(user.amountPayed);
        }
        return amount;
    }

    function getRewards() public {
        uint256 amount = earned(msg.sender);
        if(amount > 0){
            _plyr[msg.sender].amountPayed = _plyr[msg.sender].amountPayed.add(amount);
            IERC20(token).safeTransfer(msg.sender, amount);
        }
    }
    function calcDays(uint256 start,uint256 time_days_) public view returns(uint256){
        uint256 timeSub = block.timestamp.sub(start);
        return timeSub.div(time_days_);
    }
     struct OrderVip{
            uint256 amount;
            uint256 time;
        }
    mapping (address => OrderVip[]) public ordersVip;
    uint256 public DURATION = 30 days;
    uint256 public _totalSupply;
    mapping(address => uint256) public _balances;
    mapping (address => uint256) public stakes;
    function editDURATION(uint256 _DURATION)public onlyOwner{
       DURATION = _DURATION;
    }
    function stakeVip(uint256 amount) public 
    {
        require(amount > 0, 'Cannot stake 0');
        ordersVip[msg.sender].push(OrderVip({amount:amount,time:block.timestamp.add(DURATION)}));
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        chacha.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount)public 
    {
        require(amount > 0, 'Cannot withdraw 0');
        require(amount <= getTakeOutNumber(msg.sender), 'Cannot withdraw Not enough');
        stakes[msg.sender] = amount;
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        chacha.safeTransfer(msg.sender, amount);
    }

    function getTakeOutNumber(address addr) public view returns (uint256){
        uint256 num = 0;
         for(uint256 i=0;i<ordersVip[addr].length;i++){
             if(block.timestamp >= ordersVip[msg.sender][i].time){
                 num += ordersVip[msg.sender][i].amount;
             }
        }
        return num-stakes[msg.sender];
    }
}
contract PlayerManager is Ownable{

    address public teamWallet;
    uint256 public num = 10000000000000000000;
     
    constructor (address teamwallet_) {
        teamWallet = teamwallet_;
    }

    function setNum(uint256 _num) public onlyOwner{
        num = _num;
    }
    
    function transfer_token() public payable{
       // require(msg.value == num ,'Insufficient balance');
        payable(teamWallet).transfer(msg.value);
    }
}

contract SaleSymbol is Ownable {
    using SafeMath for *;
    using SafeERC20 for IERC20;
    
    uint64 public freedBase = 1000;
    uint8 public freedFirst = 40;// 第一级
    uint8 public freedTwo = 20;//第二级
    uint8 public freedThree = 10;//第三级
    uint8 public freedFour = 8;//第四级
    uint8 public freedFive = 2;//第五级
    //总的百分比
    uint8 public freedAll = 80;//总比例
    uint256 public price = 46 *1e15;//价格
    //最大额度
    uint public totalNum = 1000000 *1e18;//
    //最小购买数量
    uint public minlNum = 100 *1e18;
    
    uint256 public endTime = 1645005600;//申购结束
    uint256 public endDays=432;//释放之后时间
    uint256 public time_days=173;//释放间隔时间
    uint8 public number=2;//分隔数量
    //进度数量
     uint public speed;
     struct Player{
        address oneUser;
        address twoUser;
        address threeUser;
        address fourUser;
        address fiveUser;
        uint256 count;
        bool isRegister;
    }
    mapping (address => Player) public _plyrs;
    IERC20 public token;
    IERC20 public usdt;
    constructor (address usdt_,address token_) {
        usdt = IERC20(usdt_);
        token = IERC20(token_);
    }
    mapping(address=>uint) public profitAddress;//收益
    mapping(address=>uint) public income;//提取出收益
    uint256 public ptAllProfit;//平台总收益

    struct Order{
        uint256 number;
        uint256 amount;
        uint256 time;
    }
    struct  OrderList {
        uint256 amount;
        uint256 amountPayed;
        uint256 ordersIndex;
        mapping (uint256 => Order) orders;
        uint256 number; //投资
    }
     mapping (address => OrderList) public list;
     mapping (address => bool) public ambassador;//是否是大师
     function setAmbassador(address addr) public onlyOwner{
         ambassador[addr] = true;
     }
     function removeAmbassador(address addr) public onlyOwner{
         ambassador[addr] = false;
     }
    function projectTimeDays(uint256 time_days_) public onlyOwner{
        time_days = time_days_;
    }
    function editEndTime(uint256 endTime_) public onlyOwner{
        endTime = endTime_;
    }
    
    function editPrice(uint256 price_) public onlyOwner{
        price = price_;
    }
    function editTotalNum(uint256 totalNum_) public onlyOwner{
        totalNum = totalNum_;
    }
    function editMinlNum(uint256 minlNum_) public onlyOwner{
        minlNum = minlNum_;
    }
   function calcDays(uint256 start,uint256 time_days_) public view returns(uint256){
        uint256 timeSub = block.timestamp.sub(start);
        return timeSub.div(time_days_);
    }
    function sale(uint num,address lastUser) public {
        require(speed <= totalNum,'TokenCount is end');
       address user = msg.sender;
       address lastUserAdd = _plyrs[user].oneUser;
        address lastUserTo = _plyrs[lastUser].oneUser;
       require(num >= minlNum,"Less than minimum");
       require(user != lastUser,"Not for yourself");
       require(user != lastUserTo,"Not for Invitation");
        if(lastUserAdd == address(0)){
             _plyrs[user].isRegister = true;
             _plyrs[user].oneUser = lastUser;
             _plyrs[lastUser].count = _plyrs[lastUser].count.add(1);

             //邀请人是否有二级
          if(_plyrs[lastUser].oneUser != address(0)){
            _plyrs[user].twoUser = _plyrs[lastUser].oneUser;
             //邀请人是否有三级
            if(_plyrs[_plyrs[lastUser].oneUser].oneUser != address(0)){
             _plyrs[user].threeUser = _plyrs[_plyrs[lastUser].oneUser].oneUser;
               //邀请人是否有四级
                if(_plyrs[_plyrs[_plyrs[lastUser].oneUser].oneUser].oneUser != address(0)){
                    _plyrs[user].fourUser = _plyrs[_plyrs[_plyrs[lastUser].oneUser].oneUser].oneUser;
                }
                //邀请人是否有五级
                  if(_plyrs[_plyrs[_plyrs[_plyrs[lastUser].oneUser].oneUser].oneUser].oneUser != address(0)){
                      _plyrs[user].fiveUser = _plyrs[_plyrs[_plyrs[_plyrs[lastUser].oneUser].oneUser].oneUser].oneUser;
                  }
            }  
          }
       }   
          //平台收取比例
             uint256 numbert; 
              address lastAddress;
           if(ambassador[lastUser]){
              uint256 firstProfit =  num.mul(freedFirst).div(freedBase);
              profitAddress[_plyrs[user].oneUser] = profitAddress[_plyrs[user].oneUser].add(firstProfit);
              numbert = numbert.add(freedFirst);
              lastAddress = _plyrs[user].oneUser;
           }

           if(_plyrs[user].twoUser != address(0)&&ambassador[_plyrs[user].twoUser]){
            uint256 twoProfit =  num.mul(freedTwo).div(freedBase);
             profitAddress[_plyrs[user].twoUser] = profitAddress[_plyrs[user].twoUser].add(twoProfit);
             numbert = numbert.add(freedTwo);
             lastAddress = _plyrs[user].twoUser;
           }
           if(_plyrs[user].threeUser != address(0)&&ambassador[_plyrs[user].threeUser]){
             uint256 threeProfit =  num.mul(freedThree).div(freedBase);
             profitAddress[_plyrs[user].threeUser] = profitAddress[_plyrs[user].threeUser].add(threeProfit);
              numbert = numbert.add(freedThree);
              lastAddress = _plyrs[user].threeUser;
           }
            if( _plyrs[user].fourUser != address(0)&&ambassador[_plyrs[user].fourUser]){
                uint256 fourProfit =  num.mul(freedFour).div(freedBase);
                numbert = numbert.add(freedFour);
               profitAddress[_plyrs[user].fourUser] = profitAddress[_plyrs[user].fourUser].add(fourProfit);
               lastAddress = _plyrs[user].fourUser;
            }

            if( _plyrs[user].fiveUser != address(0)&&ambassador[_plyrs[user].fiveUser]){
                uint256 fiveProfit =  num.mul(freedFive).div(freedBase);
                 numbert = numbert.add(freedFive);
                 profitAddress[_plyrs[user].fiveUser] = profitAddress[_plyrs[user].fiveUser].add(fiveProfit);
                 lastAddress = _plyrs[user].fiveUser;
            } 
            if(numbert>0){
               uint256 profits =  num.mul( freedAll.sub(numbert)).div(freedBase);
               profitAddress[lastAddress] = profitAddress[lastAddress].add(profits);
            }else{
                 //剩下给平台的
               uint256 ptProfit =  num.mul(freedAll).div(freedBase);
               ptAllProfit = ptAllProfit.add(ptProfit);
            }        
          uint256 receivedToken = calcUsdtToToken(num);
          uint256 newAmount  = receivedToken.add(list[msg.sender].amount);
          
            list[msg.sender].amount = newAmount;
            list[msg.sender].number = (list[msg.sender].number).add(num);
        //  //某一个token中的地址购买订单记录
           list[msg.sender].orders[list[msg.sender].ordersIndex].number = num;
           list[msg.sender].orders[list[msg.sender].ordersIndex].amount = receivedToken;
           list[msg.sender].orders[list[msg.sender].ordersIndex].time = block.timestamp;
           list[msg.sender].ordersIndex++;
           speed = speed.add(num);
           usdt.safeTransferFrom(msg.sender, address(this), num);
    }
    function earned(address addr) public view returns(uint256){
        uint256 amount = 0;
        if(block.timestamp > endTime+endDays){
            OrderList storage user = list[addr];
           uint256 nu = calcDays(endTime,time_days+endDays);
           uint256 freedAmount;
            if(nu == 0){
                  if(endDays > 0){
                  freedAmount =  user.amount.mul(calcDays(endTime,endDays)).div(number);
                 }else{
                 freedAmount = user.amount.mul(1).div(number);
                 }
             }else{
                  freedAmount = user.amount.mul(1+calcDays(endTime+endDays,time_days)).div(number);//手续费金额* 设置时间内的倍数 （当前时间-开始时间 /设置时间）
             }
            if(freedAmount > user.amount){
                amount = user.amount;
            }else{
                amount = freedAmount;
            }
            amount = amount.sub(user.amountPayed);
        }
        return amount;
    }

    function getRewards() public {
        uint256 amount = earned(msg.sender);
        if(amount > 0){
            list[msg.sender].amountPayed = list[msg.sender].amountPayed.add(amount);
            IERC20(token).safeTransfer(msg.sender, amount);
        }
    }
     function calcUsdtToToken(uint256 amount) public view returns (uint256){
        return amount.mul(1e18).div(price);
    }
    function calcTokenToUsdt(uint256 amount) public view returns (uint256){
        return amount.mul(price).div(1e18);
    }
     //用户提取收益
     function withdrawProfit() public 
    {
        uint income_num = profitAddress[msg.sender].sub(income[msg.sender]);
        if(income_num>0){
           usdt.safeTransfer(msg.sender,income_num);
           income[msg.sender] = income[msg.sender].add(income_num);
        }
        
    }
    function getBToken(uint256 num) public onlyOwner{
        require(num > 0,'num >0');
        token.safeTransfer(msg.sender, num);
    }
    function getBUsdt(uint256 num) public onlyOwner{
        require(num > 0,'num >0');
        usdt.safeTransfer(msg.sender, num);
    }
    function getUserOrder(address addr) public view returns(uint256[] memory,uint256[] memory){
        uint256[] memory amount = new uint256[](list[addr].ordersIndex);
        uint256[] memory time = new uint256[](list[addr].ordersIndex);
        for(uint256 i=0;i<list[addr].ordersIndex;i++){
            amount[i] = list[addr].orders[i].number;
            time[i] = list[addr].orders[i].time;
        }
        return(amount,time);
    }
}