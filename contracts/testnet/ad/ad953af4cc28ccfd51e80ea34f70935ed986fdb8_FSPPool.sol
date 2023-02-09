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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

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
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../Interface/IRematic.sol";
import "../Interface/IFSPFactory.sol";
import "../Interface/IFSPPool.sol";

contract FSPPool is Ownable, ReentrancyGuard, IFSPPool {
    using SafeERC20 for IERC20Metadata;
    using SafeMath for uint256;

    // The address of the token to stake
    IERC20Metadata public stakedToken;

    // Number of reward tokens supplied for the pool
    uint256 public rewardSupply;

    // desired APY
    uint256 public APYPercent;

    // lock time of pool
    uint256 public lockTime;

    // Pool Create Time
    uint256 public poolStartTime;

    // Pool End Time
    uint256 public poolEndTime;

    // maximum number tokens that can be staked in the pool
    // uint256 public maxTokenSupply;

    // recent reflection received amount
    mapping(address => uint256) public Ra;

    // total withdrawn token amount
    uint256 private Tw;

    // total token added
    uint256 private To;

    // total token staked
    uint256 private TTs;

    // total token compounded
    uint256 private TTx;

    // total token harvested
    uint256 private TTv;

    // Reflection contract address if staked token has refection token (null address if none)
    IERC20Metadata public reflectionToken;

    // The reward token
    IERC20Metadata public rewardToken;

    // reflection token or not
    bool public isReflectionToken;

    // The address of the smart chef factory
    IFSPFactory SMART_CHEF_FACTORY;

    // Whether a limit is set for users
    bool public userLimit;

    // Whether it is initialized
    bool public isInitialized;

    bool public isPartition;

    bool public isStopped;

    bool public forceStopped;

    // bool public restWithdrawnByOwner;

    bool public isRewardTokenTransfered;

    // The staked token amount limit per user (0 if none)
    uint256 public limitAmountPerUser;

    // Reward percent
    uint256 public rewardPercent;

    uint256 public stopTime;

    uint256 public totalRewardClaimedByStaker = 0;

    // Info of each user that stakes tokens (stakedToken)
    mapping(address => UserInfo) public userInfo;

    // claimable reflection amount of stakers
    mapping(address => uint256) public reflectionClaimable;

    mapping(address => bool) public isStakedUser;

    bool public isInitialize;

    address public deployer;

    struct UserInfo {
        uint256 stakedAmount; // How many staked tokens the user has staked
        uint256 compoundAmount; // How many staked tokens the user has staked
        uint256 depositTime; // Deposit time
    }

    event Deposit(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event NewUserLimitAmount(uint256 poolLimitPerUser);
    event Withdraw(address indexed user, uint256 amount);
    event RewardClaim(address indexed user, uint256 amount);
    event ReflectionClaim(address indexed user, uint256 amount);
    event UpdateProfileAndThresholdPointsRequirement(
        bool isProfileRequested,
        uint256 thresholdPoints
    );

    event AddToken(address indexed user, uint256 amount);
    event PoolInialized();

    /**
     * @notice Constructor
     */
    constructor() {
        deployer = msg.sender;
    }

    modifier isPoolActive() {
        require(poolEndTime > block.timestamp && !isStopped, "pool is ended");
        _;
    }

    modifier onlyFSPPoolDeployer() {
        require(deployer == msg.sender, "Caller is not FSP pool deployer");
        _;
    }

    /*
     * @notice Initialize the contract
     * @param _stakedToken: staked token address
     * @param _reflectionToken: _reflectionToken token address
     * @param _rewardSupply: Reward Supply Amount
     * @param _APYPercent: APY
     * @param _lockTimeType: Lock Time Type 
               0 - 1 year 
               1- 180 days 
               2- 90 days 
               3 - 30 days
     * @param _limitAmountPerUser: Pool limit per user in stakedToken
     * @param _admin: admin address with ownership
     */
    function initialize(
        address _stakedToken,
        address _reflectionToken,
        uint256 _rewardSupply,
        uint256 _APYPercent,
        uint256 _lockTimeType,
        uint256 _limitAmountPerUser,
        bool _isPartition
    ) external {
        require(!isInitialized, "Already initialized");
        require(msg.sender == address(SMART_CHEF_FACTORY), "Not factory");

        // Make this contract initialized
        isInitialized = true;

        stakedToken = IERC20Metadata(_stakedToken);
        reflectionToken = IERC20Metadata(_reflectionToken);
        APYPercent = _APYPercent;
        if (address(_reflectionToken) != address(0)) {
            isReflectionToken = true;
            reflectionToken = IERC20Metadata(_reflectionToken);
        }
        if (_limitAmountPerUser > 0) {
            userLimit = true;
            limitAmountPerUser = _limitAmountPerUser;
        }

        lockTime = _lockTimeType == 0 ? 365 days : _lockTimeType == 1
            ? 180 days
            : _lockTimeType == 2
            ? 90 days
            : 30 days;

        rewardPercent = _lockTimeType == 0 ? 100000 : _lockTimeType == 1
            ? 49310
            : _lockTimeType == 2
            ? 24650
            : 8291;

        // maxTokenSupply = (((_rewardSupply / _APYPercent) * 100) /
        //     rewardPercent) * 10**5;

        rewardSupply = _rewardSupply;
        isPartition = _isPartition;
    }

    function rewardTokenTransfer() external onlyOwner {
        stakedToken.safeTransferFrom(msg.sender, address(this), rewardSupply);
        isRewardTokenTransfered = true;
        To += rewardSupply;

        isInitialize = true;
        poolStartTime = block.timestamp;
        poolEndTime = poolStartTime + lockTime;
        
        emit PoolInialized();
    }

    function addToken(uint256 _amount) external onlyOwner {
        require(!isInitialize, "Can't add token after i1nitilzed");

        stakedToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        To += _amount;
        emit AddToken(msg.sender, _amount);
    }

    function makeActive() external onlyOwner {
        isInitialize = true;
        poolStartTime = block.timestamp;
        poolEndTime = poolStartTime + lockTime;
        emit PoolInialized();
    }

    /*
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param _amount: amount to deposit
     */
    function deposit(
        uint256 _amount
    ) external payable nonReentrant isPoolActive {
        require(
            isRewardTokenTransfered,
            "Pool owner didn't send the reward tokens"
        );
        require(
            msg.value >= getDepositFee(isReflectionToken),
            "deposit fee is not enough"
        );
        require(_amount <= _getRemainCapacity(), "exceed remain capacity");
        payable(SMART_CHEF_FACTORY.platformOwner()).transfer(msg.value);

        UserInfo storage user = userInfo[msg.sender];
        require(
            !userLimit || ((_amount + user.stakedAmount) <= limitAmountPerUser),
            "Deposit limit exceeded"
        );

        if (!isStakedUser[msg.sender]) {
            isStakedUser[msg.sender] = true;
        }

        if (_amount > 0) {
            stakedToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );

            if(user.stakedAmount == 0){
                Ra[msg.sender] = 0;
            }

            user.stakedAmount = user.stakedAmount + _amount;
            user.depositTime = block.timestamp;
        }

        if (address(stakedToken) == SMART_CHEF_FACTORY.RFTXAddress()) {
            SMART_CHEF_FACTORY.updateTotalDepositAmount(
                msg.sender,
                _amount,
                true
            );
        } else {
            SMART_CHEF_FACTORY.updateTokenDepositAmount(
                address(stakedToken),
                msg.sender,
                _amount,
                true
            );
        }

        _calculateReflections(msg.sender);

        TTs += _amount;

        emit Deposit(msg.sender, _amount);
    }

    /*
     * @notice Claim reflection tokens
     */

    function claimReflections() external payable nonReentrant {
        require(
            msg.value >= getReflectionFee(),
            "reflection fee is not enough"
        );
        require(isReflectionToken, "staked token don't have reflection token");

        payable(SMART_CHEF_FACTORY.platformOwner()).transfer(msg.value);

        uint256 rewardAmount = reflectionClaimable[msg.sender];

        require(rewardAmount > 0, "no reflection claimable tokens");

        _calculateReflections(msg.sender);

        reflectionToken.transfer(msg.sender, rewardAmount.mul(99).div(100));
        reflectionToken.transfer(
            address(SMART_CHEF_FACTORY),
            rewardAmount.mul(1).div(100)
        );

        // Ra[msg.sender] -= rewardAmount;

        reflectionClaimable[msg.sender] = 0;

        emit ReflectionClaim(msg.sender, rewardAmount);
    }

    function claimReward() external payable nonReentrant {
        require(
            msg.value >= getRewardClaimFee(isReflectionToken),
            "claim fee is not enough"
        );
        payable(SMART_CHEF_FACTORY.platformOwner()).transfer(msg.value);

        UserInfo storage user = userInfo[msg.sender];

        uint256 rewardAmount = _getRewardAmount(msg.sender);

        require(rewardAmount > 0, "There are no claimable tokens in this pool");

        if (isPartition) {
            IRematic(address(stakedToken)).transferTokenFromPool(
                msg.sender,
                rewardAmount
            );
        } else {
            stakedToken.safeTransfer(msg.sender, rewardAmount);
        }

        totalRewardClaimedByStaker += rewardAmount;
        (block.timestamp > stopTime && isStopped)
            ? user.depositTime = stopTime
            : user.depositTime = block.timestamp;

        _calculateReflections(msg.sender);

        emit RewardClaim(msg.sender, rewardAmount);
    }

    function compound() external {
        UserInfo storage user = userInfo[msg.sender];
        uint256 rewardAmount = _getRewardAmount(msg.sender);
        require(rewardAmount > 0, "There are no claimable tokens in this pool");
        user.compoundAmount += rewardAmount;
        (block.timestamp > stopTime && isStopped)
            ? user.depositTime = stopTime
            : user.depositTime = block.timestamp;
        _calculateReflections(msg.sender);
    }

    function withdraw() external payable nonReentrant {
        uint256 withdrawFee = (isStopped || poolEndTime < block.timestamp)
            ? getCanceledWithdrawFee(isReflectionToken)
            : getEarlyWithdrawFee(isReflectionToken);
        require(msg.value >= withdrawFee, "withdrawFee is not enough");
        payable(SMART_CHEF_FACTORY.platformOwner()).transfer(msg.value);

        UserInfo storage user = userInfo[msg.sender];
        uint256 wM = user.stakedAmount + user.compoundAmount;

        require(wM > 0, "No tokens have been deposited into this pool");

        _calculateReflections(msg.sender);

        stakedToken.safeTransfer(msg.sender, wM);

        if (address(stakedToken) == SMART_CHEF_FACTORY.RFTXAddress()) {
            SMART_CHEF_FACTORY.updateTotalDepositAmount(msg.sender, 0, false);
        } else {
            SMART_CHEF_FACTORY.updateTokenDepositAmount(
                address(stakedToken),
                msg.sender,
                0,
                false
            );
        }
        isStakedUser[msg.sender] = false;
        Tw += wM;

        userInfo[msg.sender].stakedAmount = 0;
        userInfo[msg.sender].compoundAmount = 0;

        emit Withdraw(msg.sender, wM);
    }

    /*
     * @notice Stop rewards
     * @dev Only callable by owner
     */
    function stopReward() external {
        require(
            msg.sender == owner() ||
                SMART_CHEF_FACTORY.isPlatformOwner(msg.sender),
            "You are not Admin"
        );
        require(!isStopped, "Already Canceled");
        isStopped = true;
        stopTime = block.timestamp;
    }

    /*
     * @notice Update token amount limit per user
     * @dev Only callable by owner.
     * @param _userLimit: whether the limit remains forced
     * @param _limitAmountPerUser: new pool limit per user
     */
    function updatePoolLimitPerUser(
        bool _userLimit,
        uint256 _limitAmountPerUser
    ) external onlyOwner {
        require(userLimit, "Must be set");
        if (_userLimit) {
            require(
                _limitAmountPerUser > limitAmountPerUser,
                "New limit must be higher"
            );
            limitAmountPerUser = _limitAmountPerUser;
        } else {
            userLimit = _userLimit;
            limitAmountPerUser = 0;
        }
        emit NewUserLimitAmount(limitAmountPerUser);
    }

    function getDepositFee(bool _isReflection) public view returns (uint256) {
        return
            SMART_CHEF_FACTORY
                .getDepositFee(_isReflection)
                .mul(rewardPercent)
                .div(10 ** 5);
    }

    function getEarlyWithdrawFee(
        bool _isReflection
    ) public view returns (uint256) {
        return SMART_CHEF_FACTORY.getEarlyWithdrawFee(_isReflection);
    }

    function getCanceledWithdrawFee(
        bool _isReflection
    ) public view returns (uint256) {
        return
            SMART_CHEF_FACTORY
                .getCanceledWithdrawFee(_isReflection)
                .mul(rewardPercent)
                .div(10 ** 5);
    }

    function getRewardClaimFee(
        bool _isReflection
    ) public view returns (uint256) {
        return SMART_CHEF_FACTORY.getRewardClaimFee(_isReflection);
    }

    function getReflectionFee() public view returns (uint256) {
        return SMART_CHEF_FACTORY.getReflectionFee();
    }

    // function getMaxStakeTokenAmount() public view returns (uint256) {
    //     return maxTokenSupply;
    // }

    /*
     * @notice Return Total Staked Tokens
     */
    function getTotalStaked() public pure returns (uint256) {
        uint256 _totalStaked = 0;
        return _totalStaked;
    }

    /*
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingReward(address _user) public view returns (uint256) {
        return _getRewardAmount(_user);
    }

    /*
     * @notice Return reward amount of user.
     * @param _user: user address to calculate reward amount
     */
    function _getRewardAmount(address _user) internal view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 rStaked = user.stakedAmount + user.compoundAmount;
        uint256 rewardPerSecond = (
            ((rStaked.mul(APYPercent)).div(100)).mul(rewardPercent).div(10 ** 5)
        );
        uint256 rewardAmount;
        if (isStopped && stopTime < poolEndTime) {
            rewardAmount = rewardPerSecond
                .mul(stopTime.sub(user.depositTime))
                .div(lockTime);
        } else if (block.timestamp >= poolEndTime) {
            rewardAmount = rewardPerSecond
                .mul(poolEndTime.sub(user.depositTime))
                .div(lockTime);
        } else {
            rewardAmount = rewardPerSecond
                .mul(block.timestamp - user.depositTime)
                .div(lockTime);
        }
        return rewardAmount;
    }

    function _calculateReflections(address _account) internal {
        
        if (isReflectionToken) {
            uint256 Rp = reflectionToken.balanceOf(address(this));
            
            uint256 Tp = stakedToken.balanceOf(address(this));
            
            if (Rp > Ra[_account]) {
                uint256 totalToken = userInfo[_account].stakedAmount +
                    userInfo[_account].compoundAmount;
                
                uint256 Hr = totalToken * 10000 / ((Tp + Tw) - (To - (((block.timestamp - poolStartTime) * To) / lockTime)));

                reflectionClaimable[_account] += (Rp - Ra[_account]) * Hr / 10000;
                Ra[_account] = Rp;
            }
        }
    }

    /*
     * @notice Withdraw the rest staked and reflection token amount if pool is canceled
     * @dev only call by pool owner
     */

    function emergencyWithdrawByPoolOwner() external onlyOwner {
        require(
            poolEndTime < block.timestamp || isStopped,
            "pool is not ended yet"
        );
        // require(!restWithdrawnByOwner, "already withdrawn the rest staked and reflection token");
        uint256 totalRewardAmount = 0;
        uint256 totalStakedAmount = stakedToken.balanceOf(address(this));
        // restWithdrawnByOwner = true;
    }

    function emergencyWithdrawByPlatformOwner() external {
        require(
            SMART_CHEF_FACTORY.isPlatformOwner(msg.sender),
            "You are not Platform Owner"
        );

        if (isReflectionToken && !isPartition) {
            reflectionToken.transfer(
                msg.sender,
                reflectionToken.balanceOf(address(this))
            );
        }
        stakedToken.safeTransfer(
            msg.sender,
            stakedToken.balanceOf(address(this))
        );
        isStopped = true;
        forceStopped = true;
    }

    /*
     * @notice Return user limit is set or zero.
     */
    function hasUserLimit() public view returns (bool) {
        if (!userLimit) {
            return false;
        }

        return true;
    }

    /**
     * @notice Return the Pool Remaining Time.
     */
    function getPoolLifeTime() external view returns (uint256) {
        uint256 lifeTime = 0;

        if (poolEndTime > block.timestamp) {
            lifeTime = poolEndTime - block.timestamp;
        }

        return lifeTime;
    }

    /**
     * @notice Return Status of Pool
     */

    function getPoolStatus() external view returns (bool) {
        return isStopped || poolEndTime < block.timestamp;
    }

    function _getInitialCapacity() internal view returns (uint256) {
        uint256 Syr = 31536000;
        uint256 Ci = (To * Syr * 100) / (APYPercent * lockTime);
        return Ci;
    }

    function _getRemainCapacity() internal view returns (uint256) {
        uint256 Syr = 31536000;
        uint256 Pr = poolEndTime - block.timestamp;
        uint256 Cr1 = Syr * Pr * To * 100 / lockTime / (APYPercent * lockTime);
        uint256 Cr2 = Pr * (TTs + TTx - TTv) / lockTime;
        return Cr1 - Cr2;
    }

    function getInitialCapacity() external view returns (uint256) {
        return _getInitialCapacity();
    }

    function getRemainCapacity() external view returns (uint256) {
        return _getRemainCapacity();
    }

    function setFSPFactory(address _fspFactory) external onlyFSPPoolDeployer {
        SMART_CHEF_FACTORY = IFSPFactory(_fspFactory);
    }
    function transferOwnership(
        address newOwner
    ) public virtual override(IFSPPool, Ownable) onlyOwner {
        _transferOwnership(newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IFSPFactory {

    function totalDepositAmount(address account) external returns (uint256);
    function RFTXAddress() external returns (address);
    function platformOwner() external returns (address);

    function getDepositFee(bool _isReflection) external view returns (uint256);
    function getEarlyWithdrawFee(bool _isReflection) external view returns (uint256);
    function getCanceledWithdrawFee(bool _isReflection) external view returns (uint256);
    function getRewardClaimFee(bool _isReflection) external view returns (uint256);
    function getReflectionFee() external view returns (uint256);

    function updateTotalDepositAmount(address _user, uint256 _amount, bool _type) external;
    function updateTokenDepositAmount(address _tokenAddress, address _user, uint256 _amount, bool _type) external;

    function isPlatformOwner(address _admin) external view returns (bool);

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IFSPPool {
    function initialize(
        address _stakedToken,
        address _reflectionToken,
        uint256 _rewardSupply,
        uint256 _APYPercent,
        uint256 _lockTimeType,
        uint256 _limitAmountPerUser,
        bool _isPartition
    ) external;

    function setFSPFactory (address _fspFactory) external;

    function transferOwnership(address _newOwner) external;

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import '../struct/Tax.sol';
import '../struct/TaxAmount.sol';

interface IRematic is IERC20 {
    function adminContract() external view returns (address);
    function transferTokenFromPool(address to, uint value) external;

    function buyTax() external returns(Tax memory);
    function sellTax() external returns(Tax memory);
    function tax() external returns(Tax memory);

    function buyTaxAmount() external returns(TaxAmount memory);
    function sellTaxAmount() external returns(TaxAmount memory);
    function taxAmount() external returns(TaxAmount memory);
    
    function burnWallet() external returns(address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

struct Tax {
    uint256 stake;
    uint256 burn;
    uint256 liquidity;
    uint256 pension;
    uint256 legal;
    uint256 team;
    uint256 divtracker;
    uint256 partition;
    uint256 k401;
}

/* 
* buyStake
* sellStake
* buyBurn
* sellBurn
* buyLiquidity
* sellLiquidity
* buyPension
* sellPension
* buyLegal
* sellLegal
* buyTeam
* sellTeam
* buyDiv
* sellDiv
* buyBurn
* sellBurn
* Partition
* 401K
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

struct TaxAmount {
    uint256 stake;
    uint256 burn;
    uint256 liquidity;
    uint256 pension;
    uint256 legal;
    uint256 team;
    uint256 divtracker;
    uint256 partition;
    uint256 k401;
}