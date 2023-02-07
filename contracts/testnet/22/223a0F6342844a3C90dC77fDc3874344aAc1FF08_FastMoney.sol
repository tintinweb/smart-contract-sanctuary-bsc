// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./VerifySignature.sol";

contract FastMoney is Ownable, Pausable, VerifySignature {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public lastTxnTimestamp;
    IERC20 public paymentToken;

    struct User {
        bool exists;
        address wallet;
        uint256 referrer;
        // Uplines in different rounds
        mapping(uint256 => uint256) uplines;
        // Referrals in different rounds
        mapping(uint256 => uint256[]) referrals;
        uint256 level;
        uint256 balance;
        uint256 profit;
        uint256 accrued;
        uint256 shipped;
        uint256 skipped;
        uint256 received;
    }

    uint256 public LEVEL_TIME_LIFE = 1 << 37;

    uint256 public currentUserID;

    mapping(uint256 => uint256[3]) roundInfo;

    uint256 public totalProfit;
    uint256 public totalShipped;

    uint256[] public levels;
    //Users [userID -> User]
    mapping(uint256 => User) public users;
    // Users [wallet -> userID]
    mapping(address => uint256) public userWallets;

    event RegisterUser(
        address indexed user,
        uint256 userID,
        address indexed referrer,
        uint256 referrerID
    );

    event LevelUp(address indexed user, uint256 userID, uint256 levelID);

    event Transfer(
        address indexed sender,
        uint256 senderID,
        uint256 amount,
        uint256 date
    );

    event Payment(
        address indexed sender,
        address indexed recipient,
        uint256 senderID,
        uint256 recipientID,
        uint256 amount
    );

    event LostProfit(
        address indexed sender,
        address indexed recipient,
        uint256 senderID,
        uint256 recipientID,
        uint256 amount
    );
    event WithdrawEvent(address indexed recipient, uint256 amount, uint time);

    constructor(address[3] memory _techAccounts, address token) {
        levels = [
            50 ether,
            80 ether,
            100 ether,
            160 ether,
            200 ether,
            320 ether,
            400 ether,
            640 ether,
            800 ether,
            1280 ether,
            1600 ether,
            2560 ether,
            3200 ether,
            5120 ether,
            6400 ether,
            10240 ether,
            12800 ether,
            20480 ether,
            25600 ether,
            40960 ether
        ];

        lastTxnTimestamp = block.timestamp;

        paymentToken = IERC20(token);

        for (uint256 i = 0; i < 3; i++) {
            currentUserID++;
            userWallets[_techAccounts[i]] = currentUserID;
            users[currentUserID].exists = true;
            users[currentUserID].wallet = _techAccounts[i];
            users[currentUserID].referrer = 1;
            users[currentUserID].level = 20;

            for (uint256 j = 0; j < 10; j++) {
                users[currentUserID].uplines[j] = 1;
                if (currentUserID > 1) {
                    users[1].referrals[j].push(currentUserID);
                }
            }
        }
    }

    fallback() external payable {
        revert("Not Allowed!");
    }

    receive() external payable {
        revert("Not Allowed");
    }

    function getBalance() public view returns (uint256) {
        return paymentToken.balanceOf(address(this));
    }

    function registerUser(uint256 _referrer) public whenNotPaused {
        require(
            _referrer > 0 && _referrer <= currentUserID,
            "Invalid referrer ID"
        );
        require(userWallets[msg.sender] == 0, "User already registered");
        require(
            paymentToken.allowance(msg.sender, address(this)) >= levels[0],
            "Increase the allowance first,call the approve method"
        );

        currentUserID++;

        // Create user
        users[currentUserID].exists = true;
        users[currentUserID].wallet = msg.sender;
        users[currentUserID].referrer = _referrer;
        users[currentUserID].level = 0;

        userWallets[msg.sender] = currentUserID;

        sendETH(levels[0]);

        emit RegisterUser(
            msg.sender,
            currentUserID,
            users[_referrer].wallet,
            _referrer
        );

        levelUp(currentUserID, 1);
    }

    function upgradeLevel(uint256 levelID) public {
        uint256 userID = userWallets[msg.sender];
        require(userID > 0, "!userRegistered");
        require(users[userID].level < levelID, "levelAlreadyActive");
        require(users[userID].level == levelID - 1, "!prevLevel");
        uint256 priceLevel = levels[levelID - 1];
        // если баланс больше или равен
        if (users[userID].balance >= priceLevel) {
            priceLevel = 0;
        } else {
            priceLevel = levels[levelID - 1] - users[userID].balance;
        }

        require(
            paymentToken.allowance(msg.sender, address(this)) >= priceLevel,
            "Increase the allowance first,call the approve method"
        );

        sendETH(priceLevel);

        users[userID].balance = 0;

        levelUp(userID, levelID);
    }

    function sendETH(uint256 amount) private {
        paymentToken.transferFrom(msg.sender, address(this), amount);
        uint256 userID = userWallets[msg.sender];
        users[userID].shipped = users[userID].shipped.add(amount);
        totalShipped = totalShipped.add(amount);
    }

    function getUserUpline(
        uint256 userID,
        uint256 round,
        uint256 height
    ) public view returns (uint256) {
        while (height > 0) {
            userID = users[userID].uplines[round];
            height--;
        }
        return userID;
    }

    function findUplineUp(uint256 _user, uint256 _round)
        public
        view
        returns (uint256)
    {
        while (users[_user].uplines[_round] == 0) {
            _user = users[_user].uplines[0];
        }
        return _user;
    }

    function findUplineDown(uint256 userID, uint256 round)
        public
        view
        returns (uint256)
    {
        if (users[userID].referrals[round].length < 2) {
            return userID;
        }

        uint256[1024] memory referrals;
        referrals[0] = users[userID].referrals[round][0];
        referrals[1] = users[userID].referrals[round][1];

        uint256 referrer;

        for (uint256 i = 0; i < 1024; i++) {
            if (users[referrals[i]].referrals[round].length < 2) {
                referrer = referrals[i];
                break;
            }

            if (i >= 512) {
                continue;
            }

            referrals[(i + 1) * 2] = users[referrals[i]].referrals[round][0];
            referrals[(i + 1) * 2 + 1] = users[referrals[i]].referrals[round][
                1
            ];
        }

        require(referrer != 0, "Referrer not found");
        return referrer;
    }

    function lvlAmount(uint256 levelID) public view returns (uint256) {
        levelID--;
        uint256 price = levels[levelID];
        return price;
    }

    /// @notice Use for get round and level number by levelID
    /// @param levelID: levelID, starts from 1
    /// @return (round, level), starts from 0
    function getLevelInfo(uint256 levelID)
        public
        view
        returns (uint256, uint256)
    {
        levelID--;
        require(levelID < levels.length, "!levelID");
        uint256 level = levelID % 2;
        uint256 round = (levelID - level) / 2;
        return (round, level);
    }

    function getReferralTree(
        uint256 _user,
        uint256 _treeLevel,
        uint256 _round
    )
        external
        view
        returns (
            uint256[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256
        )
    {
        uint256 tmp = 2**(_treeLevel + 1) - 2;
        uint256[] memory ids = new uint256[](tmp);
        uint256[] memory lvl = new uint256[](tmp);
        uint256[] memory referrers = new uint256[](tmp);

        ids[0] = (users[_user].referrals[_round].length > 0)
            ? users[_user].referrals[_round][0]
            : 0;
        ids[1] = (users[_user].referrals[_round].length > 1)
            ? users[_user].referrals[_round][1]
            : 0;
        lvl[0] = getMaxLevel(ids[0], _round);
        lvl[1] = getMaxLevel(ids[1], _round);
        referrers[0] = users[ids[0]].referrer;
        referrers[1] = users[ids[1]].referrer;

        for (uint256 i = 0; i < (2**_treeLevel - 2); i++) {
            tmp = i * 2 + 2;
            ids[tmp] = (users[ids[i]].referrals[_round].length > 0)
                ? users[ids[i]].referrals[_round][0]
                : 0;
            ids[tmp + 1] = (users[ids[i]].referrals[_round].length > 1)
                ? users[ids[i]].referrals[_round][1]
                : 0;
            lvl[tmp] = getMaxLevel(ids[tmp], _round);
            lvl[tmp + 1] = getMaxLevel(ids[tmp + 1], _round);
            referrers[tmp] = users[ids[tmp]].referrer;
            referrers[tmp + 1] = users[ids[tmp + 1]].referrer;
        }

        uint256 curMax = getMaxLevel(_user, _round);

        return (ids, lvl, referrers, curMax);
    }

    function getMaxLevel(uint256 userID, uint256 _round)
        private
        view
        returns (uint256 _level)
    {
        if (userID == 0) return 0;
        if (!users[userID].exists) return 0;
        (uint256 round, uint256 level) = getLevelInfo(users[userID].level);
        if (round > _round) return 1;
        if (round < _round) return 0;
        if (round == _round) return level;
    }

    function getUplines(uint256 _user, uint256 _round)
        public
        view
        returns (uint256[] memory, address[] memory)
    {
        uint256[] memory uplines = new uint256[](2);
        address[] memory uplinesWallets = new address[](2);

        for (uint256 i = 0; i < 2; i++) {
            _user = users[_user].uplines[_round];
            uplines[i] = _user;
            uplinesWallets[i] = users[_user].wallet;
        }

        return (uplines, uplinesWallets);
    }

    function getUserReferrals(uint256 userID, uint256 round)
        public
        view
        returns (uint256[] memory)
    {
        return users[userID].referrals[round];
    }

    function claimTechAccount() external onlyOwner {
        uint256 amount = users[1].profit;
        users[1].profit = 0;
        users[1].received = users[1].received.add(amount);
        if (!paymentToken.transfer(users[1].wallet, amount)) {
            paymentToken.transfer(users[2].wallet, amount);
        }
    }

    function claimProfit() external {
        uint256 userID = userWallets[msg.sender];
        require(userID > 0, "User not register");
        uint256 amount = users[userID].profit;
        require(
            amount > 0,
            "Insufficient funds profit"
        );
        
        users[userID].profit = 0;
        users[userID].received = users[userID].received.add(amount);
        if (!paymentToken.transfer(msg.sender, amount)) {
            paymentToken.transfer(users[2].wallet, amount);
        }
    }

    function transferProfitToBalance() external {
        uint256 userID = userWallets[msg.sender];
        require(userID > 0, "User not register");
        uint256 amount = users[userID].profit;
        require(amount > 0, 'Small profit');
        emit Transfer(
            msg.sender,
            userID,
            amount,
            block.timestamp
        );

        users[userID].balance = users[userID].balance.add(amount);
        users[userID].profit = 0;
    }

    function getUserInfo(uint256 userID)
        public
        view
        returns (
            uint256 profit,
            uint256 referrer,
            uint256 level,
            uint256 balance
        )
    {
        return (
            users[userID].profit,
            users[userID].referrer,
            users[userID].level,
            users[userID].balance
        );
    }

    function getUserInfoByWallet(address _wallet)
        external
        view
        returns (
            uint256 profit,
            uint256 referrer,
            uint256 level,
            uint256 balance
        )
    {
        return getUserInfo(userWallets[_wallet]);
    }

    function getUserPaymentsInfo(uint256 userID)
        public
        view
        returns (
            uint256 shipped,
            uint256 skipped,
            uint256 accrued,
            uint256 received
        )
    {
        return (
            users[userID].shipped,
            users[userID].skipped,
            users[userID].accrued,
            users[userID].received
        );
    }

    function getUserPaymentsInfoByWallet(address _wallet)
        external
        view
        returns (
            uint256 shipped,
            uint256 skipped,
            uint256 accrued,
            uint256 received
        )
    {
        return getUserPaymentsInfo(userWallets[_wallet]);
    }

    function levelUp(uint256 userID, uint256 levelID) private {
        (uint256 round, uint256 level) = getLevelInfo(levelID);

        // if new round started -> find and set upline
        if (level == 0) {
            uint256 upline = users[userID].referrer;
            if (round > 0) upline = findUplineUp(upline, round);
            upline = findUplineDown(upline, round);
            users[userID].uplines[round] = upline;
            users[upline].referrals[round].push(userID);
        }

        // здесь записываем куда юзер прибавился
        if (level == 0)
            roundInfo[round] = [roundInfo[round][0] + 1, roundInfo[round][1] + 1, roundInfo[round][2]];
        else roundInfo[round] = [roundInfo[round][0] + 1,roundInfo[round][1], roundInfo[round][2] + 1];

        users[userID].level++;

        payForLevel(userID, levelID);

        emit LevelUp(users[userID].wallet, userID, users[userID].level);
    }

    // Check amount and get level info
    function payForLevel(uint256 userID, uint256 levelID) private {
        uint256 amount = lvlAmount(levelID);

        lastTxnTimestamp = block.timestamp;
        (uint256 round, uint256 level) = getLevelInfo(levelID);
        uint256 upline = getUserUpline(userID, round, level + 1);

        payForLevel(userID, upline, levelID, round, level, amount);
    }

    function payForLevel(
        uint256 senderID,
        uint256 userID,
        uint256 levelID,
        uint256 round,
        uint256 level,
        uint256 amount
    ) public {
        // recepient don't have previous level -> pass payment to upline
        if (users[userID].level < levelID) {
            users[userID].skipped += amount;

            emit LostProfit(
                users[senderID].wallet,
                users[userID].wallet,
                senderID,
                userID,
                amount
            );

            userID = getUserUpline(userID, round, level + 1);

            payForLevel(senderID, userID, levelID, round, level, amount);
            return;
        }

        if (userID < 4) {
            users[1].profit = users[1].profit.add(amount);
            totalProfit = totalProfit.add(amount);
        } else {
            if (users[userID].level < levels.length) {
                uint256 nextLevelPrice = lvlAmount(users[senderID].level + 1);

                uint256 prepaymentShare = nextLevelPrice.div(2**(level + 1));

                uint256 profit = amount.sub(prepaymentShare);
                users[userID].profit = users[userID].profit.add(profit);
                users[userID].accrued = users[userID].accrued.add(amount);
                totalProfit = totalProfit.add(profit);

                users[userID].balance = users[userID].balance.add(
                    prepaymentShare
                );
            } else {
                users[userID].profit = users[userID].profit.add(amount);
                totalProfit = totalProfit.add(amount);
            }
        }
    }

    function getRoundInfo(uint256 round)
        public
        view
        returns (uint256[3] memory levelsRound)
    {
        return roundInfo[round];
    }

    function evacuate() external onlyOwner {
        require(
            (block.timestamp - 30 days) > lastTxnTimestamp,
            "cannotEvacuate"
        );
        _pause();
        paymentToken.transfer(
            msg.sender,
            paymentToken.balanceOf(address(this))
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract VerifySignature {

uint256 public test = 21;

    function getMessageHash(
        address _to,
        uint _amount,
        string memory _message,
        uint _nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _amount, _message, _nonce));
    }

    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }

    function verify(
        address _signer,
        address _to,
        uint _amount,
        string memory _message,
        uint _nonce,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(_to, _amount, _message, _nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}