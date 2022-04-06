// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
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
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

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
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface ISwapPair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function price(address token, uint256 baseDecimal) external view returns (uint256);

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

interface ISwapRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;
pragma experimental ABIEncoderV2;

import './ISwapRouter01.sol';

interface ISwapRouter02 is ISwapRouter01 {
    function tradingPool() external pure returns (address);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IWBNB {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

//SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.5.16;

// a library for performing various math operations

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "../interfaces/ISwapPair.sol";

library SwapLibrary {
    using SafeMath for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "SwapLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "SwapLibrary: ZERamountInWithFeeO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        hex"ef0d2ab30aac9d18fa917ec5b914cd6bdaa7590990542a9b68a26c8f100e1a9a" // init code hash
                    )
                )
            )
        );
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = ISwapPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {
        require(amountA > 0, "SwapLibrary: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "SwapLibrary: INSUFFICIENT_LIQUIDITY");
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "SwapLibrary: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "SwapLibrary: INSUFFICIENT_LIQUIDITY");
        uint256 amountInWithFee = amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, "SwapLibrary: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "SwapLibrary: INSUFFICIENT_LIQUIDITY");
        uint256 numerator = reserveIn.mul(amountOut).mul(1000);
        uint256 denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "SwapLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "SwapLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {

    address private constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }

    function universalTransfer(
        address token,
        address payable to,
        uint256 amount
    ) internal {
        if (amount > 0) {
            if (isETH(token)) {
                to.transfer(amount);
            } else {
                safeTransfer(token, to, amount);
            }
        }
    }

    function universalApproveMax(
        address token,
        address to,
        uint256 amount
    ) internal {
        uint256 allowance = IERC20(token).allowance(address(this), to);
        if (allowance < amount) {
            if (allowance > 0) {
                safeApprove(token, to, 0);
            }
            safeApprove(token, to, uint256(-1));
        }
    }

    function universalBalanceOf(address token, address who) internal view returns (uint256) {
        if (isETH(token)) {
            return who.balance;
        } else {
            return IERC20(token).balanceOf(who);
        }
    }

    function tokenBalanceOf(address token, address who) internal view returns (uint256) {
        return IERC20(token).balanceOf(who);
    }

    function isETH(address token) internal pure returns (bool) {
        return token == ETH_ADDRESS;
    }

    function getETH() internal pure returns (address) {
        return ETH_ADDRESS;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/proxy/Initializable.sol";

import '../interfaces/ISwapPair.sol';
import '../interfaces/ISwapRouter02.sol';
import '../interfaces/IWBNB.sol';
import '../libraries/SwapLibrary.sol';
import "../libraries/TransferHelper.sol";
import '../libraries/Math.sol';

contract Zap is Ownable, Pausable, Initializable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public constant ONE_HUNDRED_PERCENT = 10000;
    uint256 public constant MULTIPLIER = 1e18;
    uint256 public constant SWAP_FEE_PERCENT = 30; // 0.2 %

    /* ========== STATE VARIABLES ========== */

    mapping(address => bool) private notLpToken;
    mapping(address => address) private routePairAddresses;
    mapping(bytes32 => address) private directRoutePairAddresses;
    address[] public tokens;

    address public WBNB;
    address public factory;

    ISwapRouter02 public ROUTER;
    address public USDT;
    address public PAN;
    address public PSR;


    /* ========== EVENT ========== */
    event TransferLeftOverToken(address token, address reciever, uint256 amount);
    event TransferLeftOverBNB(address reciever, uint256 amount);

    event ZapInBNB(address toToken, uint256 zapAmount, uint256 receiveAmount);
    event ZapInBEP20(address fromToken, address toToken, uint256 zapAmount, uint256 receiveAmount);

    event ZapOut(address fromToken, address toToken, uint256 amountIn, uint256 tokenOutMin);
    


    /* ========== INITIALIZER ========== */

    /*
    * Receive BNB sent to this contract
    */
    receive() external payable {}

    /*
     * initialize the addrees list of BEP20 token (not LP token)
     */
    function initialize(address _factory, address _router, address _wbnb, address _usdt, address _pan, address _psr) public initializer {
        factory = _factory;
        ROUTER = ISwapRouter02(_router);

        WBNB = _wbnb;
        USDT = _usdt;
        PAN = _pan;
        PSR = _psr;

        setNotLpToken(_wbnb);
        setNotLpToken(_usdt);
        setNotLpToken(_pan);
        setNotLpToken(_psr);

        setDirectRoutePairAddress(keccak256(abi.encodePacked(_psr, _usdt)), _usdt);
        setDirectRoutePairAddress(keccak256(abi.encodePacked(_psr, _pan)), _pan);
        setDirectRoutePairAddress(keccak256(abi.encodePacked(_pan, _usdt)), _usdt);
    }

    /* ========== View Functions ========== */

    function getIsLpToken(address token) external view returns (bool) {
        return !notLpToken[token];
    }

    function getRouter() external view returns (ISwapRouter02) {
        return ROUTER;
    }

    function getWBNB() external view returns (address) {
        return WBNB;
    }
    function isLpToken(address token) public view returns (bool) {
        return !notLpToken[token];
    }

    function routePair(address token) external view returns (address) {
        return routePairAddresses[token];
    }

    function directRoutePair(bytes32 key) external view returns (address) {
        return directRoutePairAddresses[key];
    }

    function getRoutePath(address fromToken, address toToken) external view returns (address[] memory path) {
        return routePath(fromToken, toToken);
    }

    function getEstimatedLpToken(address fromToken, uint256 fromTokenAmount, address toToken) external view returns (uint256 amountToken0, uint256 amountToken1, uint256 liquidity) {
        if(isLpToken(toToken)) {
            ISwapPair pair = ISwapPair(toToken);
            address token0 = pair.token0();
            address token1 = pair.token1();
            uint256 totalSupply = pair.totalSupply();
            (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
            if(fromToken == token0 || fromToken == token1) {
                amountToken0 = fromTokenAmount.div(2);
                address otherToken = fromToken == token0 ? token1 : token0;
                uint256 otherTokenReserve = fromToken == token0 ? reserve1 : reserve0;
                uint256 fromTokenReserve = fromToken == token0 ? reserve0 : reserve1;
                amountToken1 = getPoolAddedAmount(fromToken, otherToken, amountToken0);
                liquidity = calculateLiquidity(amountToken0, amountToken1, fromTokenReserve, otherTokenReserve, totalSupply);
                
            } else {
                uint256 WBNBAmount = fromToken != WBNB ? getPoolAddedAmount(fromToken, WBNB, fromTokenAmount) : fromTokenAmount;
                uint256 halfWbnbAmount = WBNBAmount.div(2);
                amountToken0 = token0 != WBNB ? getPoolAddedAmount(WBNB, token0, halfWbnbAmount): halfWbnbAmount;
                amountToken1 = token1 != WBNB ? getPoolAddedAmount(WBNB, token1, halfWbnbAmount): halfWbnbAmount;
                liquidity = calculateLiquidity(amountToken0, amountToken1, reserve0, reserve1, totalSupply);
            }
        } else {
            amountToken0 = fromTokenAmount;
            liquidity = getPoolAddedAmount(fromToken, toToken, fromTokenAmount);
            amountToken1 = liquidity;
        }
        return (amountToken0,amountToken1,liquidity);
    }

    function calculateLiquidity(uint256 amount0, uint256 amount1, uint256 reserve0, uint256 reserve1, uint256 totalSupply) private pure returns (uint256 liquidity) {
        if (totalSupply == 0) {
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(10**3);
        } else {
            liquidity = Math.min(amount0.mul(totalSupply).div(reserve0), amount1.mul(totalSupply).div(reserve1));
        }
    }

    function getPoolAddedAmount(address fromToken, address toToken, uint256 swapAmount) public view returns (uint256 amount) {
        address[] memory path = routePath(fromToken, toToken);
        amount = ROUTER.getAmountsOut(swapAmount, path)[path.length - 1];
    }

    function calculatePriceImpact(address fromToken, uint256 amountIn, address toToken) private view returns (uint256 priceImpact) {
        address[] memory path = routePath(fromToken, toToken);

        uint256 midPrice = MULTIPLIER;

        for (uint256 i = 0; i < path.length - 1; i++) {
            (uint256 reserveA, uint256 reserveB) = SwapLibrary.getReserves(factory, path[i], path[i + 1]);

            midPrice = midPrice * reserveB / reserveA;
        }

        uint256 exactQuote = midPrice * amountIn / MULTIPLIER;

        uint256[] memory amountOuts = SwapLibrary.getAmountsOut(factory, amountIn, path);

        uint256 impact = (exactQuote - amountOuts[amountOuts.length - 1]) * ONE_HUNDRED_PERCENT / exactQuote;

        priceImpact = impact - SWAP_FEE_PERCENT;
    }

    function getPriceImpactWhenZapIn(address fromToken, uint256 amountIn, address toToken) public view returns (uint256[] memory priceImpacts) {
        priceImpacts = new uint256[](2);

        if (isLpToken(toToken)) {
            ISwapPair pair = ISwapPair(toToken);

            address token0 = pair.token0();
            address token1 = pair.token1();

            if (fromToken == token0 || fromToken == token1) {
                priceImpacts[0] = calculatePriceImpact(fromToken, amountIn.div(2), fromToken == token0 ? token1 : token0);

            } else {
                priceImpacts[0] = calculatePriceImpact(fromToken, amountIn.div(2), token0);
                priceImpacts[1] = calculatePriceImpact(fromToken, amountIn.div(2), token1);
            }
        } else {
            priceImpacts[0] = calculatePriceImpact(fromToken, amountIn, toToken);
        }
    }

    function getPriceImpactWhenZapOut(address fromToken, address toToken, uint256 amountIn) public view returns (uint256[] memory priceImpacts) {
        priceImpacts = new uint256[](2);

        if (!isLpToken(fromToken)) {
            priceImpacts[0] = calculatePriceImpact(fromToken, amountIn, toToken);
        } else {
            ISwapPair pair = ISwapPair(fromToken);
            address token0 = pair.token0();
            address token1 = pair.token1();
            (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
            uint256 totalSupply = pair.totalSupply();
            uint256 amount0 = reserve0.mul(amountIn).div(totalSupply);
            uint256 amount1 = reserve1.mul(amountIn).div(totalSupply);

            if (toToken == token0 || toToken == token1) {
                uint256 amount = toToken == token0 ? amount1 : amount0;
                priceImpacts[0] = calculatePriceImpact(toToken == token0 ? token1 : token0, amount, toToken);
            } else {
                priceImpacts[0] = calculatePriceImpact(token0, amount0, toToken);
                priceImpacts[1] = calculatePriceImpact(token1, amount1, toToken);
            }
        }
    }

    function getAmountToZapOut(
        address _from,
        uint256 _amount,
        address _toToken
    )
    external
    view
    returns (
        uint256 amountToken0,
        uint256 amountToken1,
        uint256 amountOut
    )
    {
        ISwapPair pair = ISwapPair(_from);
        address token0 = pair.token0();
        address token1 = pair.token1();
        uint256 amount0;
        uint256 amount1;
        {
            uint256 _totalSupply = IERC20(_from).totalSupply();
            amount0 = _amount * IERC20(token0).balanceOf(_from) / _totalSupply;
            amount1 = _amount * IERC20(token1).balanceOf(_from) / _totalSupply;
        }
        amountOut = 0;
        if (token0 != _toToken) {
            address[] memory path0 = routePath(token0, _toToken);
            uint256[] memory amounts = ROUTER.getAmountsOut(amount0, path0);
            amountOut = amounts[amounts.length - 1];
        } else {
            amountOut = amount0;
        }

        if (token1 != _toToken) {
            address[] memory path1 = routePath(token1, _toToken);
            uint256[] memory amounts = ROUTER.getAmountsOut(amount1, path1);
            amountOut = amountOut.add(amounts[amounts.length - 1]);
        } else {
            amountOut = amountOut.add(amount1);
        }

        return (amount0, amount1, amountOut);
    }

    /* ========== External Functions ========== */

    function zapInToken(address fromToken, uint256 amountIn, address toToken, uint256 amountOutMin) external whenNotPaused {
        uint256 fromTokenBalanceBefore = IERC20(fromToken).balanceOf(address(this));

        IERC20(fromToken).safeTransferFrom(msg.sender, address(this), amountIn);
        _approveTokenIfNeeded(fromToken);

        uint256 amountOut;

        if (isLpToken(toToken)) {
            ISwapPair pair = ISwapPair(toToken);
            address token0 = pair.token0();
            address token1 = pair.token1();
            if (fromToken == token0 || fromToken == token1) {
                address otherToken = fromToken == token0 ? token1 : token0;
                _approveTokenIfNeeded(otherToken);
                uint256 otherTokenBalanceBefore = IERC20(otherToken).balanceOf(address(this));

                amountOut = _swapAndAddLiquidity(fromToken, otherToken, amountIn, msg.sender);

                uint256 fromTokenBalanceAfter = IERC20(fromToken).balanceOf(address(this));
                if (fromTokenBalanceAfter > 0 && fromTokenBalanceAfter > fromTokenBalanceBefore) {
                    _transferLeftOverToken(fromToken, msg.sender, fromTokenBalanceAfter.sub(fromTokenBalanceBefore));
                }

                uint256 otherTokenBalanceAfter = IERC20(otherToken).balanceOf(address(this));
                if(otherTokenBalanceAfter > 0 && otherTokenBalanceAfter > otherTokenBalanceBefore) {
                    _transferLeftOverToken(otherToken, msg.sender, otherTokenBalanceAfter.sub(otherTokenBalanceBefore));
                }

            } else {
                uint256 bnbBalanceBefore = address(this).balance;
                uint256 bnbAmount = fromToken == WBNB? _safeSwapToBNB(amountIn) : _swapTokenForBNB(fromToken, amountIn, address(this));
                amountOut = _swapBNBToLpToken(toToken, bnbAmount, msg.sender, bnbBalanceBefore);
            }
        } else {
            amountOut = _swap(fromToken, amountIn, toToken, msg.sender);
        }

        require(amountOut >= amountOutMin);

        emit ZapInBEP20(fromToken, toToken, amountIn , amountOut);
    }

    function zapIn(address toToken, uint256 amountOutMin) external payable whenNotPaused {
        uint256 bnbBalanceBefore = address(this).balance.sub(msg.value);
        uint256 amountOut = _swapBNBToLpToken(toToken, msg.value, msg.sender, bnbBalanceBefore);

        require(amountOut >= amountOutMin);

        emit ZapInBNB(toToken, msg.value , amountOut);
    }

    function zapOut(address fromToken, address toToken, uint256 amountIn, uint256 amountOutMin) payable external  whenNotPaused {
        IERC20(fromToken).safeTransferFrom(msg.sender, address(this), amountIn);
        _approveTokenIfNeeded(fromToken);
        uint256 amountOut = 0;

        if (!isLpToken(fromToken)) {
            amountOut = _swap(fromToken, amountIn, toToken, address(this));
            require(amountOut >= amountOutMin);
        } else {
            ISwapPair pair = ISwapPair(fromToken);
            address token0 = pair.token0();
            address token1 = pair.token1();
            _approveTokenIfNeeded(token0);
            _approveTokenIfNeeded(token1);

            if (token0 == WBNB || token1 == WBNB) {
                address token = token0 != WBNB ? token0 : token1;
                (uint256 amountToken, uint256 amountETH) = ROUTER.removeLiquidityETH(token, amountIn, 1, 1, address(this), block.timestamp);
                if (token != toToken) {
                    amountOut = _swap(token, amountToken, toToken, address(this));
                } else {
                    amountOut = amountToken;
                }
                if (WBNB != toToken) {
                    amountOut = amountOut.add(_swapBNBForToken(toToken, amountETH, address(this)));
                } else {
                    amountOut = amountOut.add(amountETH);
                }
                require(amountOut >= amountOutMin);
            } else {
                (uint256 amountA, uint256 amountB) =  ROUTER.removeLiquidity(token0, token1, amountIn, 1, 1, address(this), block.timestamp);
                if (token0 != toToken) {
                    amountOut = _swap(token0, amountA, toToken, address(this));
                } else {
                    amountOut = amountA;
                }
                if (token1 != toToken) {
                    amountOut = amountOut.add(_swap(token1, amountB, toToken, address(this)));
                } else {
                    amountOut = amountOut.add(amountB);
                }
                require(amountOut >= amountOutMin);
            }
        }

        if (toToken == WBNB) {
            TransferHelper.safeTransferETH(msg.sender, amountOut);
        } else {
            IERC20(toToken).safeTransfer(msg.sender, amountOut);
        }

        emit ZapOut(fromToken, toToken, amountIn, amountOut);
    }

    /* ========== Private Functions ========== */

    /*
    * Swap to other token in the pair. After that it will add liquidity.
    * Used for case: zap A -> A-B or B -> A-B (fromToken is in the pair)
    * This function to avoid CompilerError: Stack too deep, try removing local variables on Solidity
    */
    function _swapAndAddLiquidity(address fromToken, address otherToken, uint256 amount, address receiver) private returns (uint256 liquidity) {
        uint256 sellAmount = amount.div(2);
        uint256 otherAmount = _swap(fromToken, sellAmount, otherToken, address(this));
        ( , , liquidity) = ROUTER.addLiquidity(fromToken, otherToken, amount.sub(sellAmount), otherAmount, 0, 0, receiver, block.timestamp);
    }

    function _transferLeftOverToken(address token, address receiver, uint256 amount) private {
        require(receiver != address(0));
        uint256 currentBalance = IERC20(token).balanceOf(address(this));
        require(currentBalance >= amount);
        IERC20(token).safeTransfer(receiver, amount);
        emit TransferLeftOverToken(token, receiver, amount);
    }

    function _transferLeftOverBNB(address receiver, uint256 amount) private {
        require(receiver != address(0));
        uint256 currentBalance = address(this).balance;
        require(currentBalance >= amount);
        payable(receiver).transfer(amount);
        emit TransferLeftOverBNB(receiver, amount);
    }

    function _approveTokenIfNeeded(address token) private {
        if (IERC20(token).allowance(address(this), address(ROUTER)) == 0) {
            IERC20(token).safeApprove(address(ROUTER), uint256(-1));
        }
    }

    function _swapBNBToLpToken(address lpToken, uint256 amount, address receiver, uint256 bnbBalanceBefore) private returns(uint256 liquidity) {
        if (!isLpToken(lpToken)) {
            _swapBNBForToken(lpToken, amount, receiver);
        } else {
            ISwapPair pair = ISwapPair(lpToken);
            address token0 = pair.token0();
            address token1 = pair.token1();
            if (token0 == WBNB || token1 == WBNB) {
                address token = token0 == WBNB ? token1 : token0;
                liquidity = _addLiquidityBNB(token, amount, receiver, bnbBalanceBefore);
            } else {
                liquidity = _addLiquidity(token0, token1, amount, receiver);
            }
        }
    }

    /*
    * Swap to LP token. The LP token is paired with BNB
    * This function to avoid CompilerError: Stack too deep, try removing local variables on Solidity
    */
    function _addLiquidityBNB(address token, uint256 amount, address receiver, uint256 bnbBalanceBefore) private returns(uint256 liquidity) {
        uint256 tokenBalanceBefore = IERC20(token).balanceOf(address(this));

        uint256 swapValue = amount.div(2);
        uint256 tokenAmount = _swapBNBForToken(token, swapValue, address(this));
        _approveTokenIfNeeded(token);

        (,, liquidity) = ROUTER.addLiquidityETH{value: amount.sub(swapValue)}(token, tokenAmount, 0, 0, receiver, block.timestamp);

        uint256 tokenBalanceAfter = IERC20(token).balanceOf(address(this));
        uint256 bnbBalanceAfter = address(this).balance;

        if (tokenBalanceAfter > 0 && tokenBalanceAfter > tokenBalanceBefore) {
            _transferLeftOverToken(token, msg.sender, tokenBalanceAfter.sub(tokenBalanceBefore));
        }
        if(bnbBalanceAfter > 0 && bnbBalanceAfter > bnbBalanceBefore) {
            _transferLeftOverBNB(receiver, bnbBalanceAfter.sub(bnbBalanceBefore));
        }
    }

    /*
    * Swap to LP token. The LP token is not paired with BNB
    * This function to avoid CompilerError: Stack too deep, try removing local variables on Solidity
    */
    function _addLiquidity(address token0, address token1, uint256 amount, address receiver) private returns (uint256 liquidity) {
        uint256 token0BalanceBefore = IERC20(token0).balanceOf(address(this));
        uint256 token1BalanceBefore = IERC20(token1).balanceOf(address(this));

        uint256 swapValue = amount.div(2);
        uint256 token0Amount = _swapBNBForToken(token0, swapValue, address(this));
        uint256 token1Amount = _swapBNBForToken(token1, amount.sub(swapValue), address(this));

        _approveTokenIfNeeded(token0);
        _approveTokenIfNeeded(token1);

        (,, liquidity) = ROUTER.addLiquidity(token0, token1, token0Amount, token1Amount, 0, 0, receiver, block.timestamp);

        uint256 token0BalanceAfter = IERC20(token0).balanceOf(address(this));
        uint256 token1BalanceAfter = IERC20(token1).balanceOf(address(this));

        if (token0BalanceAfter > 0 && token0BalanceAfter > token0BalanceBefore) {
            _transferLeftOverToken(token0, msg.sender, token0BalanceAfter.sub(token0BalanceBefore));
        }
        if (token1BalanceAfter > 0 && token1BalanceAfter > token1BalanceBefore) {
            _transferLeftOverToken(token1, msg.sender, token1BalanceAfter.sub(token1BalanceBefore));
        }
    }

    function _swapBNBForToken(address token, uint256 value, address receiver) private returns (uint256) {
        address[] memory path;

        if (routePairAddresses[token] != address(0)) {
            path = new address[](3);
            path[0] = WBNB;
            path[1] = routePairAddresses[token];
            path[2] = token;
        } else {
            path = new address[](2);
            path[0] = WBNB;
            path[1] = token;
        }

        uint256[] memory amounts = ROUTER.swapExactETHForTokens{value: value}(0, path, receiver, block.timestamp);
        return amounts[amounts.length - 1];
    }

    function _swapTokenForBNB(address token, uint256 amount, address receiver) private returns (uint256) {
        address[] memory path;
        if (routePairAddresses[token] != address(0)) {
            path = new address[](3);
            path[0] = token;
            path[1] = routePairAddresses[token];
            path[2] = WBNB;
        } else {
            path = new address[](2);
            path[0] = token;
            path[1] = WBNB;
        }

        uint256[] memory amounts = ROUTER.swapExactTokensForETH(amount, 0, path, receiver, block.timestamp);
        return amounts[amounts.length - 1];
    }

    function routePath(address fromToken, address toToken) private view returns (address[] memory path) {
        address intermediate = directRoutePairAddresses[keccak256(abi.encodePacked(fromToken, toToken))];

        if (intermediate == address(0)) {
            intermediate = directRoutePairAddresses[keccak256(abi.encodePacked(toToken, fromToken))];
        }

        if (intermediate == address(0)) {
            intermediate = routePairAddresses[fromToken];
        }

        if (intermediate == address(0)) {
            intermediate = routePairAddresses[toToken];
        }

        if (intermediate != address(0) && (fromToken == WBNB || toToken == WBNB)) {
            path = new address[](3);
            path[0] = fromToken;
            path[1] = intermediate;
            path[2] = toToken;
        } else if (intermediate != address(0) && (fromToken == intermediate || toToken == intermediate)) {
            path = new address[](2);
            path[0] = fromToken;
            path[1] = toToken;
        } else if (intermediate != address(0) && routePairAddresses[fromToken] == routePairAddresses[toToken]) {
            path = new address[](3);
            path[0] = fromToken;
            path[1] = intermediate;
            path[2] = toToken;
        } else if (
            routePairAddresses[fromToken] != address(0) &&
            routePairAddresses[toToken] != address(0) &&
            routePairAddresses[fromToken] != routePairAddresses[toToken]
        ) {
            path = new address[](5);
            path[0] = fromToken;
            path[1] = routePairAddresses[fromToken];
            path[2] = WBNB;
            path[3] = routePairAddresses[toToken];
            path[4] = toToken;
        } else if (intermediate != address(0) && routePairAddresses[fromToken] != address(0)) {
            path = new address[](4);
            path[0] = fromToken;
            path[1] = intermediate;
            path[2] = WBNB;
            path[3] = toToken;
        } else if (intermediate != address(0) && routePairAddresses[toToken] != address(0)) {
            path = new address[](4);
            path[0] = fromToken;
            path[1] = WBNB;
            path[2] = intermediate;
            path[3] = toToken;
        } else if (fromToken == WBNB || toToken == WBNB) {
            path = new address[](2);
            path[0] = fromToken;
            path[1] = toToken;
        } else {
            path = new address[](3);
            path[0] = fromToken;
            path[1] = WBNB;
            path[2] = toToken;
        }
    }

    function _swap(address fromToken, uint256 amount, address toToken, address receiver) private returns (uint256) {
        address[] memory path = routePath(fromToken, toToken);
        uint256[] memory amounts = ROUTER.swapExactTokensForTokens(amount, 0, path, receiver, block.timestamp);
        return amounts[amounts.length - 1];
    }

    function _safeSwapToBNB(uint256 amount) private returns (uint256) {
        require(IERC20(WBNB).balanceOf(address(this)) >= amount);
        require(WBNB != address(0));
        uint256 beforeBNB = address(this).balance;
        IWBNB(WBNB).withdraw(amount);
        return (address(this).balance).sub(beforeBNB);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */
    function saveLeftOverToken(address token, address receiver, uint256 amount) public onlyOwner {
        _transferLeftOverToken(token, receiver, amount);
    }

    function saveLeftOverBNB(address receiver, uint256 amount) public onlyOwner {
        _transferLeftOverBNB(receiver, amount);
    }

    function setRoutePairAddress(address asset, address route) public onlyOwner {
        routePairAddresses[asset] = route;
    }

    function setDirectRoutePairAddress(bytes32 key, address route) public onlyOwner {
        directRoutePairAddresses[key] = route;
    }

    function setNotLpToken(address token) public onlyOwner {
        bool needPush = notLpToken[token] == false;
        notLpToken[token] = true;
        if (needPush) {
            tokens.push(token);
        }
    }

    function removeToken(uint256 i) external onlyOwner {
        address token = tokens[i];
        notLpToken[token] = false;
        tokens[i] = tokens[tokens.length - 1];
        tokens.pop();
    }

    function sweep() external onlyOwner {
        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            if (token == address(0)) continue;
            uint256 amount = IERC20(token).balanceOf(address(this));
            if (amount > 0) {
                _swapTokenForBNB(token, amount, owner());
            }
        }
    }

    function withdraw(address token) external onlyOwner {
        if (token == address(0)) {
            payable(owner()).transfer(address(this).balance);
            return;
        }

        IERC20(token).safeTransfer(owner(), IERC20(token).balanceOf(address(this)));
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}