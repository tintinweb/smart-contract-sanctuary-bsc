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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
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

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

interface IAddressesProvider {
  /***************************************************** */
  /*********************GETTERS************************* */
  /***************************************************** */
  function getAddress(bytes32 id) external view returns (address);

  function getSpent() external view returns (address);

  function getSpentLP() external view returns (address);

  function getEusd() external view returns (address);

  function getZapContract() external view returns (address);

  function getBscViaDuctContract() external returns (address);

  function getBarterRouter() external view returns (address);

  function getBarterFactory() external view returns (address);

  function getUpRightContract() external view returns (address);

  function getCropYardContract() external view returns (address);

  function getPrimeContract() external view returns (address);

  function getFiskContract() external view returns (address);

  function getWhitelistContract() external view returns (address);

  function getUprightStableContract() external view returns (address);

  function getUprightLpContract() external view returns (address);

  function getUprightSwapTokenContract() external view returns (address);

  function getUprightBstContract() external view returns (address);

  function getBorrowLendContract() external view returns (address);

  function getTokenomicsContract() external view returns (address);

  function getManagerContract() external view returns (address);

  function getManager() external view returns (address);

  /***************************************************** */
  /*********************SETTERS************************* */
  /***************************************************** */

  function setAddress(bytes32 id, address newAddress) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

// FIXME: seggregate errors
library Errors {
  /*********************************************************** */
  /****************************RBAC*************************** */
  /*********************************************************** */
  string public constant CALLER_NOT_ADMIN = "CALLER_NOT_ADMIN"; // 'The caller of the function is not a pool admin'
  string public constant CALLER_NOT_OWNER = "CALLER_NOT_OWNER"; // 'The caller of the function is not a pool admin'
  string public constant CALLER_NOT_MODERATOR = "CALLER_NOT_MODERATOR"; // 'The caller of the function is not a pool admin'
  string public constant CALLER_NOT_SWAP = "CALLER_NOT_SWAP"; // 'The caller of the function is not a pool admin'
  string public constant ACL_ADMIN_CANNOT_BE_ZERO = "ACL_ADMIN_CANNOT_BE_ZERO";

  /*********************************************************** */
  /*************************WHITELISTING********************** */
  /*********************************************************** */
  string public constant ALREADY_WHITELISTED = "ALREADY_WHITELISTED";
  string public constant CALLER_OR_POOL_NOT_WHITELISTED = "CALLER_OR_POOL_NOT_WHITELISTED";
  string public constant REF_NOT_WHITELISTED = "REF_NOT_WHITELISTED";
  string public constant CANNOT_BE_CALLED_BY_MEMBER = "CANNOT_BE_CALLED_BY_MEMBER";
  /*********************************************************** */
  /****************************ERC20************************** */
  /*********************************************************** */
  string public constant AMOUNT_ZERO = "AMOUNT_ZERO";
  string public constant LOW_ALLOWANCE = "LOW_ALLOWANCE";
  string public constant INSUFFICIENT_AMOUNT = "INSUFFICIENT_AMOUNT";
  string public constant LOW_BALANCE = "LOW_BALANCE";
  /*********************************************************** */
  /*************************ZERO_ERROR************************ */
  /*********************************************************** */
  string public constant LP_AMOUNT_INVALID = "LP_AMOUNT_INVALID";
  string public constant AMOUNT_INVALID = "AMOUNT_INVALID";
  string public constant NO_TOKEN_IN_CONTRACT = "NO_TOKEN_IN_CONTRACT";
  /*********************************************************** */
  /**************************LOCKED*************************** */
  /*********************************************************** */
  string public constant LP_NOT_UNLOCABLE_YET = "LP_NOT_UNLOCABLE_YET";
  /*********************************************************** */
  /**************************STAKE*************************** */
  /*********************************************************** */
  string public constant WRONG_LP = "WRONG_LP";
  string public constant NOT_CLAIMABLE_YET = "NOT_CLAIMABLE_YET";
  string public constant NOT_UNSTAKABLE_YET = "NOT_UNSTAKABLE_YET";
  string public constant LOW_LOCK_DURATION = "LOW_LOCK_DURATION";
  /*********************************************************** */
  /**************************TRANSACTION************************ */
  /************************************************************ */
  string public constant TRANSACTION_FAILED = "TRANSACTION_FAILED";
  /*********************************************************** */
  /**************************VIA-DUCT************************* */
  /*********************************************************** */
  string public constant ZERO_AFTER_DEDUCTIONS = "ZERO_AFTER_DEDUCTIONS";
  string public constant ZERO_AFTER_VALUATIONS = "ZERO_AFTER_VALUATIONS";
  string public constant LOW_eUSD_BALANCE_IN_CONTRACT = "LOW_eUSD_BALANCE_IN_CONTRACT";
  /*********************************************************** */
  /**************************ACL****************************** */
  /*********************************************************** */
  string public constant CALLER_NOT_PRIME_CONTRACT = "CALLER_NOT_PRIME_CONTRACT";
  string public constant CALLER_NOT_WHITELIST_CONTRACT = "CALLER_NOT_WHITELIST_CONTRACT";
  string public constant CALLER_NOT_CROP_YARD_CONTRACT = "CALLER_NOT_CROP_YARD_CONTRACT";
  string public constant CALLER_NOT_BORROW_LEND_CONTRACT = "CALLER_NOT_BORROW_LEND_CONTRACT";

  string public constant CALLER_NOT_UPRIGHT_STABLE_CONTRACT = "CALLER_NOT_UPRIGHT_STABLE_CONTRACT";
  string public constant CALLER_NOT_UPRIGHT_LP_CONTRACT = "CALLER_NOT_UPRIGHT_LP_CONTRACT";
  string public constant CALLER_NOT_UPRIGHT_SWAP_TOKEN_CONTRACT = "CALLER_NOT_UPRIGHT_SWAP_TOKEN_CONTRACT";
  string public constant CALLER_NOT_UPRIGHT_BST_CONTRACT = "CALLER_NOT_UPRIGHT_BST_CONTRACT";

  string public constant CALLER_NOT_MANAGER_CONTRACT = "CALLER_NOT_MANAGER_CONTRACT";
  string public constant CALLER_NOT_MANAGER = "CALLER_NOT_MANAGER";

  string public constant CALLER_NOT_CROP_YARD_OR_UPRIGHT_CONTRACT = "CALLER_NOT_CROP_YARD_OR_UPRIGHT_CONTRACT";

  string public constant CALLER_NOT_BSC_VIADUCT_CONTRACT = "CALLER_NOT_BSC_VIADUCT_CONTRACT";
  string public constant CALLER_NOT_ROUTER_CONTRACT = "CALLER_NOT_ROUTER_CONTRACT";
}

// SPDX-License-Identifier: MIT-1.1
pragma solidity 0.8.10;

library Time {
  uint256 public constant ONE_SECOND = 1;
  uint256 public constant ONE_MINUTE = 60 * ONE_SECOND;
  uint256 public constant ONE_HOUR = 60 * ONE_MINUTE;
  // uint256 public constant ONE_DAY = 24 * ONE_HOUR;
  uint256 public constant ONE_DAY = 180 * ONE_SECOND;
  uint256 public constant ONE_WEEK = 7 * ONE_DAY;
  uint256 public constant ONE_MONTH_OF_30 = 30 * ONE_DAY;
  uint256 public constant THREE_MONTH = 3 * ONE_MONTH_OF_30;
  uint256 public constant SIX_MONTH = 6 * ONE_MONTH_OF_30;
  uint256 public constant NINE_MONTH = 9 * ONE_MONTH_OF_30;
  uint256 public constant ONE_YEAR = 365 * ONE_DAY;
  uint256 public constant ONE_YEAR_RAW = 31536000;
  uint256 public constant FIVE_YEAR = 5 * ONE_YEAR;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface IBarterERC20 {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event AirdropAdded(address indexed account, uint256 amount);

  function name() external pure returns (string memory);

  function symbol() external pure returns (string memory);

  function decimals() external pure returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(address from, address to, uint256 value) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);

  function PERMIT_TYPEHASH() external pure returns (bytes32);

  function nonces(address owner) external view returns (uint256);

  function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

  function addAirDrop(address account, uint256 amount) external returns (bool);

  function subAirDrop(address account, uint256 amount) external returns (bool);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface IBarterFactory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function getPair(address tokenA, address tokenB) external view returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  function createPair(address tokenA, address tokenB) external returns (address pair);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;

  function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface IBarterPair {
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

  function transferFrom(address from, address to, uint256 value) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);

  function PERMIT_TYPEHASH() external pure returns (bytes32);

  function nonces(address owner) external view returns (uint256);

  function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

  event Mint(address indexed sender, uint256 amount0, uint256 amount1);
  event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
  event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint256);

  function factory() external view returns (address);

  function token0() external view returns (address);

  function token1() external view returns (address);

  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

  function price0CumulativeLast() external view returns (uint256);

  function price1CumulativeLast() external view returns (uint256);

  function kLast() external view returns (uint256);

  function mint(address to) external returns (uint256 liquidity);

  function burn(address to) external returns (uint256 amount0, uint256 amount1);

  function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;

  function skim(address to) external;

  function sync() external;

  function initialize(address, address) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2;

interface IBarterRouter {
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
  ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

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

  function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);

  function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountOut);

  function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountIn);

  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import { IAddressesProvider } from "../../common/configuration/AddressProvider/IAddressesProvider.sol";
import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import { Errors } from "../../common/libraries/helpers/Errors.sol";
import { IBarterPair } from "../Barter/interface/IBarterPair.sol";
import { IBarterERC20 } from "../Barter/interface/IBarterERC20.sol";
import { IBarterFactory } from "../Barter/interface/IBarterFactory.sol";
import { IWhitelist } from "../Whitelist/interface/IWhitelist.sol";
import { ICropYard } from "./interface/ICropYard.sol";
import { Time } from "../../common/libraries/helpers/Time.sol";
import { IBarterRouter } from "../Barter/interface/IBarterRouter.sol";
import { IFisk } from "../Fisk/interface/IFisk.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract CropYard is ReentrancyGuard, ICropYard, Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  IAddressesProvider public immutable ADDRESSES_PROVIDER;

  constructor(IAddressesProvider provider) {
    ADDRESSES_PROVIDER = provider;
  }

  modifier onlyPrime() {
    _onlyPrime();
    _;
  }

  function _onlyPrime() internal view virtual {
    require(ADDRESSES_PROVIDER.getPrimeContract() == msg.sender, Errors.CALLER_NOT_PRIME_CONTRACT);
  }

  /********************************************************* */
  /************************STORAGE************************** */
  /********************************************************* */
  uint256 public immutable DIVIDER = 1000;
  uint256[] public fee = [2, 25, 200, 50]; // 0.2% for non-whitelisted , 2.5% for whitelisted ,20% in hold will be given at last, 5% in game amount
  Pool[] private _poolList;
  mapping(uint256 => mapping(address => User)) private _userInfo; // user info for perticular pool
  uint256 private _total_claimed_tokens;
  uint256 private _totalDeposit;

  function _calcMaxReward(uint256 _user_capital, uint256 _apr, uint256 _duration) private pure returns (uint256 total_max_reward) {
    uint256 yearly_reward = _apr.mul(_user_capital);
    yearly_reward = yearly_reward.div(10000);
    uint256 reward_per_day_on_capital = yearly_reward.div(Time.ONE_YEAR);
    total_max_reward = reward_per_day_on_capital.mul(_duration);

    return total_max_reward;
  }

  function _calcDurationFormLastCheckPoint(uint256 _checkPoint, uint256 endpoint) private view returns (uint256 duration) {
    if (block.timestamp > endpoint) {
      if (endpoint > _checkPoint) {
        return endpoint.sub(_checkPoint);
      } else {
        return 0;
      }
    } else {
      return block.timestamp.sub(_checkPoint);
    }
  }

  function _calcCapitalPerDay(uint256 _user_capital, uint256 _duration) private pure returns (uint256 capital_per_day) {
    return _user_capital.div(_duration);
  }

  function _calcRewardPerDay(uint256 _max_reward, uint256 _duration) private pure returns (uint256 reward_per_day) {
    return _max_reward.div(_duration);
  }

  function _clacRewardPerDayRaw(uint256 _amount, uint256 _duration) private pure returns (uint256 reward_per_day) {
    return _amount.div(_duration);
  }

  function _calcClaimableForDuration(
    uint256 capital_per_day,
    uint256 reward_per_day,
    uint256 duration
  ) private pure returns (uint256 claimble_capital, uint256 claimble_reward) {
    claimble_capital = capital_per_day.mul(duration);
    claimble_reward = reward_per_day.mul(duration);

    return (claimble_capital, claimble_reward);
  }

  function _calcRpd_Cpd_maxReward(
    uint256 user_capital,
    uint256 _pool_apr,
    uint256 _pool_duration
  ) private pure returns (uint256 rpd, uint256 cpd, uint256 max_reward) {
    max_reward = _calcMaxReward(user_capital, _pool_apr, _pool_duration);

    rpd = _calcRewardPerDay(max_reward, _pool_duration);

    cpd = _calcCapitalPerDay(user_capital, _pool_duration);

    return (rpd, cpd, max_reward);
  }

  function _stakeRepeat(uint256 capital_in_usd, uint256 _pId, address account) private returns (bool) {
    // clac claimable
    User storage _user = _userInfo[_pId][account];
    uint256 duration = _calcDurationFormLastCheckPoint(_user.checkpoint, _user.endpoint);

    (uint256 claimble_capital, uint256 claimble_reward) = _calcClaimableForDuration(_user.capital_per_day, _user.reward_per_day, duration);
    uint256 sub_cap = _user.capital.sub(claimble_capital);

    _user.capital = sub_cap;

    _user.max_reward = _user.max_reward.sub(claimble_reward);

    _user.stake_repeat_capital_debt += claimble_capital;
    _user.stake_repeat_reward_debt += claimble_reward;

    // update capital to new capital
    _user.capital = _user.capital.add(capital_in_usd);

    return true;
  }

  function stake(uint256 _pId, uint256 amount, address account) public override nonReentrant onlyPrime returns (bool) {
    Pool storage _pool = _poolList[_pId];

    require(IBarterERC20(_pool.inputToken).allowance(account, address(this)) >= amount, Errors.LOW_ALLOWANCE);

    bool _is = IWhitelist(ADDRESSES_PROVIDER.getWhitelistContract()).isWhitelisted(account);
    // whitelisted pool check
    require(_pool.trigger == _is, Errors.CALLER_OR_POOL_NOT_WHITELISTED);
    // trigger is false then _is should be false too
    // i.e not for whitelisted then caller should not be whitelisted

    // transfer amount to this address
    bool transfer = IBarterERC20(_pool.inputToken).transferFrom(account, address(this), amount);
    require(transfer, Errors.TRANSACTION_FAILED);
    // calculate amount value in dollar

    uint256 capital_in_usd = _getAmountUsdValue(amount, _pId);

    // check if alredy staked in this pool
    User storage _user = _userInfo[_pId][account];

    if (_user.capital > 0) {
      _stakeRepeat(capital_in_usd, _pId, account);
      // update rpd and cpd
    }
    if (_user.capital == 0) {
      // add to amount
      _user.capital = capital_in_usd;
    }
    (uint256 rpd, uint256 cpd, uint256 max_reward) = _calcRpd_Cpd_maxReward(_user.capital, _pool.apr, _pool.duration);
    _user.max_reward = max_reward;
    _user.capital_per_day = cpd;
    _user.reward_per_day = rpd;

    // in both case end point will be updated
    _user.endpoint = _pool.duration.add(block.timestamp);
    // update checkpoint
    _user.checkpoint = block.timestamp;

    _pool.tvl_usd += capital_in_usd;
    _totalDeposit++;

    if (_pool.trigger) {
      // lock for 5 years for member
      // _user.lockedTill = block.timestamp + Time.FIVE_YEAR;
      _user.lockedTill = block.timestamp;
    } else {
      // lock for one day for non member
      // NOTE: have to change this , cuz there is a locking period
      // _user.lockedTill = block.timestamp + Time.ONE_DAY;
      _user.lockedTill = block.timestamp;
    }
    // hence staked in pool
    emit CropYardEnable(account, amount, capital_in_usd, _pId);

    return true;
  }

  function claim(uint256 _pId, address account) public override nonReentrant onlyPrime returns (bool) {
    User storage _user = _userInfo[_pId][account];

    require(_user.lockedTill < block.timestamp, Errors.NOT_CLAIMABLE_YET);

    bool _is = IWhitelist(ADDRESSES_PROVIDER.getWhitelistContract()).isWhitelisted(account);

    Pool memory _pool = _poolList[_pId];
    // whitelisted pool check
    require(_pool.trigger == _is, Errors.CALLER_OR_POOL_NOT_WHITELISTED);

    uint256 claim_amount = _claim(_pId, account, _is);

    // IERC20(_pool.outPutToken).transfer(account, claim_amount);
    // transfer from fisk
    IFisk(ADDRESSES_PROVIDER.getFiskContract()).claimV2(account, _pool.outPutToken, claim_amount);

    _user.debt = 0;
    _user.stake_repeat_capital_debt = 0;
    _user.stake_repeat_reward_debt = 0;
    _total_claimed_tokens += claim_amount;

    emit CropYardClaim(account, claim_amount, _pId);

    return true;
  }

  function lock(uint256 _pId, uint256 duration, address account) public override nonReentrant onlyPrime returns (bool) {
    bool _is = IWhitelist(ADDRESSES_PROVIDER.getWhitelistContract()).isWhitelisted(account);
    require(_is == false, Errors.CANNOT_BE_CALLED_BY_MEMBER);

    User storage _user = _userInfo[_pId][account];

    require(duration > _user.lockedTill, Errors.LOW_LOCK_DURATION);

    _user.lockedTill = duration;

    return true;
  }

  function unStake(uint256 _pId, uint256 amount, address account) public override nonReentrant onlyPrime returns (bool) {
    bool _is = IWhitelist(ADDRESSES_PROVIDER.getWhitelistContract()).isWhitelisted(account);

    require(_is == false, Errors.CANNOT_BE_CALLED_BY_MEMBER);

    User storage _user = _userInfo[_pId][account];

    require(amount <= _user.capital, Errors.AMOUNT_INVALID);

    require(_user.lockedTill < block.timestamp, Errors.NOT_UNSTAKABLE_YET);

    // first claim all till now then make amount = 0

    // claim all
    claim(_pId, account);

    // amount 0
    _user.capital = 0;

    return true;
  }

  function _memberClaim(uint256 _pId, address account, uint256 claimble_capital, uint256 claimble_reward) private returns (uint256 total_claimable) {
    User storage _user = _userInfo[_pId][account];

    _user.capital = _user.capital.sub(claimble_capital);
    _user.max_reward = _user.max_reward.sub(claimble_reward);

    uint256 total_amount = claimble_capital + claimble_reward + _user.stake_repeat_capital_debt + _user.stake_repeat_reward_debt;

    claimble_reward += _user.stake_repeat_reward_debt;

    // deduct 0.2 percent
    uint256 claim_mul_fees = total_amount.mul(fee[0]);
    claim_mul_fees = claim_mul_fees.div(DIVIDER);
    _sendCropYardFeesToFisk(claim_mul_fees, _pId);

    total_amount = total_amount.sub(claim_mul_fees);

    // 5 % to game of cr
    uint256 game_fee = claimble_reward.mul(fee[3]);
    game_fee = game_fee.div(DIVIDER);

    _sendGameAmountToFisk(account, game_fee);

    // then 20% to hold
    uint256 hold_amount = claimble_reward.mul(fee[2]);
    hold_amount = hold_amount.div(DIVIDER);

    _user.hold = _user.hold.add(hold_amount); // ok

    uint256 deduction_amt = game_fee + hold_amount;

    total_amount = total_amount - deduction_amt;

    // if eligible add hold amount here
    if (block.timestamp > _user.endpoint) {
      total_amount = total_amount + _user.hold;

      _user.hold = 0;
    }
    // then deduction of 2.5 percent from total amount

    uint256 acc_fees = total_amount.mul(fee[1]);
    acc_fees = acc_fees.div(DIVIDER);

    // send acc fee tokens to vault
    _sendCropYardPerformanceFeeToFisk(acc_fees, _pId);

    total_amount = total_amount - acc_fees;

    uint256 member_claimable = _getAmountTokenValue(total_amount, _pId);

    _user.debt = _user.debt.add(member_claimable);
    // update checkpoint
    _user.checkpoint = block.timestamp;
    _user.total_claimed = _user.total_claimed.add(member_claimable);

    return _user.debt;
  }

  function _claim(uint256 _pId, address account, bool _is) private returns (uint256 total_claimable) {
    User storage _user = _userInfo[_pId][account];
    uint256 duration = _calcDurationFormLastCheckPoint(_user.checkpoint, _user.endpoint);
    (uint256 claimble_capital, uint256 claimble_reward) = _calcClaimableForDuration(_user.capital_per_day, _user.reward_per_day, duration);

    if (_is && duration > 0) {
      _memberClaim(_pId, account, claimble_capital, claimble_reward);
    }
    if (!_is && duration > 0) {
      uint256 sub_cap = _user.capital.sub(claimble_capital);

      _user.capital = sub_cap;

      _user.max_reward = _user.max_reward.sub(claimble_reward);

      uint256 total_amount = claimble_capital.add(claimble_reward);

      total_amount = _user.debt.add(total_amount).add(_user.stake_repeat_capital_debt + _user.stake_repeat_reward_debt);

      uint256 claim_mul_fees = total_amount.mul(fee[0]);
      // fee to fisk
      claim_mul_fees = claim_mul_fees.div(DIVIDER);

      _sendCropYardFeesToFisk(claim_mul_fees, _pId);

      total_amount = total_amount.sub(claim_mul_fees);

      total_amount = _getAmountTokenValue(total_amount, _pId);

      _user.debt = total_amount;

      // update checkpoint
      _user.checkpoint = block.timestamp;
      _user.total_claimed = _user.total_claimed.add(total_amount);
    }

    return _user.debt;
  }

  function _sendCropYardFeesToFisk(uint256 amount, uint256 _pId) private returns (bool) {
    uint256 token_amount = _getAmountTokenValue(amount, _pId);
    IFisk(ADDRESSES_PROVIDER.getFiskContract()).addCropYardFees(token_amount);
    return true;
  }

  function _sendCropYardPerformanceFeeToFisk(uint256 amount, uint256 _pId) private returns (bool) {
    uint256 token_amount = _getAmountTokenValue(amount, _pId);
    IFisk(ADDRESSES_PROVIDER.getFiskContract()).addCropYardPerformanceFees(token_amount);
    return true;
  }

  function _sendGameAmountToFisk(address account, uint256 game_fee) private returns (bool) {
    IFisk(ADDRESSES_PROVIDER.getFiskContract()).addGameAmount(account, game_fee);
    return true;
  }

  function checkClaimable(uint256 _pId, address account) public view returns (uint256 total, uint256 claimble_capital, uint256 claimble_reward) {
    User memory _user = _userInfo[_pId][account];
    uint256 duration = _calcDurationFormLastCheckPoint(_user.checkpoint, _user.endpoint);
    (claimble_capital, claimble_reward) = _calcClaimableForDuration(_user.capital_per_day, _user.reward_per_day, duration);
    total = claimble_capital.add(claimble_reward).add(_user.debt);
    // in spent values
    total = _getAmountTokenValue(total, _pId);
    claimble_capital = _getAmountTokenValue(claimble_capital, _pId);
    claimble_reward = _getAmountTokenValue(claimble_reward, _pId);

    return (total, claimble_capital, claimble_reward);
  }

  function _getReserves(
    uint256 _pId
  )
    private
    view
    returns (
      uint256, // res0
      uint256, // res1
      uint256 // total lp supply
    )
  {
    IBarterPair pair = IBarterPair(_poolList[_pId].inputToken);
    (uint256 Res0, uint256 Res1, ) = pair.getReserves();
    uint256 totalSupply = pair.totalSupply();
    return (Res0, Res1, totalSupply);
  }

  function _getAmountUsdValue(uint256 amount, uint256 _pId) private view returns (uint256 value) {
    // r0 = spent
    // r1 = eusd
    (uint256 r0, uint256 r1, uint256 ts) = _getReserves(_pId);
    uint256 price = IBarterRouter(ADDRESSES_PROVIDER.getBarterRouter()).getAmountOut(1 ether, r0, r1);

    uint256 spent_pool_value = r0.mul(price);
    uint256 total_pool_value = serializeNumberAndAdd(r1, spent_pool_value);

    uint256 value_mul_pool = total_pool_value.mul(amount);
    value = value_mul_pool.div(ts * 1 ether);
    return value;
  }

  function log10(uint256 n) private pure returns (uint256) {
    uint256 count;
    while (n != 0) {
      count++;
      n /= 10;
    }
    return count;
  }

  function serializeNumberAndAdd(uint256 num0, uint256 num1) private pure returns (uint256 value) {
    uint256 log0 = log10(num0);
    uint256 log1 = log10(num1);
    // if log0 < log1 i.e num0 < num1
    // then log1 - log0 > 0 ... pow of this diff mul to num0

    if (log0 < log1) {
      uint256 temp0 = num0 * 10 ** (log1 - log0);
      return temp0 + num1;
    }
    // if log0 > log1 i.e num0 > num1
    // then log0 - log1 > 0 ... pow of this diff mul to num1
    if (log1 > log0) {
      uint256 temp1 = num1 * 10 ** (log0 - log1);
      return temp1 + num0;
    }
    if (log1 == log1) {
      return num0 + num1;
    }
  }

  function create(
    address inputToken,
    address outPutToken,
    bool trigger,
    uint256 duration,
    uint256 apr
  ) external override nonReentrant onlyOwner returns (bool) {
    require(IERC20(outPutToken).balanceOf(address(this)) >= 0, Errors.NO_TOKEN_IN_CONTRACT);
    _poolList.push(Pool(inputToken, outPutToken, trigger, duration, apr, 0, 0));
    return true;
  }

  // OK
  function _getAmountTokenValue(uint256 amount, uint256 _pId) private view returns (uint256 token_value) {
    (uint256 r0, uint256 r1, ) = _getReserves(_pId);
    uint256 price = IBarterRouter(ADDRESSES_PROVIDER.getBarterRouter()).getAmountOut(1 ether, r1, r0);

    token_value = price.mul(amount);
    token_value = token_value.div(1 ether);
    return token_value;
  }

  function poolInfo(uint256 index) public view returns (Pool memory pool) {
    return (_poolList[index]);
  }

  // OK
  function poolCount() public view returns (uint256) {
    return _poolList.length;
  }

  function userInfo(uint256 pId, address account) public view returns (User memory) {
    return _userInfo[pId][account];
  }

  function totalClaimedTokens() public view returns (uint256) {
    return _total_claimed_tokens;
  }

  // OK
  function depositCount() public view returns (uint256) {
    return _totalDeposit;
  }

  function setFee(uint256 index, uint256 amount) external nonReentrant onlyOwner returns (bool) {
    fee[index] = amount;
    return true;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface ICropYard {
  /********************************************************* */
  /***********************EVENTS**************************** */
  /********************************************************* */

  event CropYardEnable(address from, uint256 amountLp, uint256 eusd, uint256 pid);
  event CropYardClaim(address by, uint256 amount, uint256 poolId);

  /********************************************************* */
  /************************STRUCT*************************** */
  /********************************************************* */
  struct Pool {
    address inputToken;
    address outPutToken;
    bool trigger;
    uint256 duration;
    uint256 apr;
    uint256 tvl_usd;
    uint256 total_claimed;
  }
  struct User {
    uint256 checkpoint; // check point in timestamp
    uint256 endpoint; // end of this / latest depoist reward duration
    uint256 capital; // usd amout of asset
    uint256 debt;
    uint256 lockedTill;
    uint256 capital_per_day;
    uint256 max_reward;
    uint256 reward_per_day;
    uint256 total_claimed;
    uint256 hold;
    uint256 stake_repeat_capital_debt;
    uint256 stake_repeat_reward_debt;
  }

  /********************************************************* */
  /************************FUNCTIONS************************ */
  /********************************************************* */
  function stake(uint256 _pId, uint256 amount, address account) external returns (bool);

  function claim(uint256 _pId, address account) external returns (bool);

  function create(address inputToken, address outPutToken, bool trigger, uint256 duration, uint256 apr) external returns (bool);

  function lock(uint256 _pId, uint256 duration, address account) external returns (bool);

  function unStake(uint256 _pId, uint256 amount, address account) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IFisk {
  event claimedFisk(uint256 amount, address account);
  event claimedV2Fisk(uint256 amount, address account);
  event GameAmountAdded(address account, uint256 amount);
  event GameAmountSub(address account, uint256 amount);

  /********************************************************** */

  function addCropYardFees(uint256 amount) external returns (bool);

  function addWhitelistFees(uint256 amount) external returns (bool);

  function addCropYardPerformanceFees(uint256 amount) external returns (bool);

  /***********************STAKE*********************** */
  function addBorrowStakeTokenFees(uint256 amount) external returns (bool);

  function addStableTokensFees(uint256 amount) external returns (bool);

  function addSwapLpTokensFees(uint256 amount) external returns (bool);

  function addSwapTokensFees(uint256 amount) external returns (bool);

  function addBorrowLendFees(uint256 amount) external returns (bool);

  /*************************************************** */

  function claim(address account, address token) external returns (bool);

  function claimV2(address to, address token, uint256 amount) external returns (bool);

  function allowance(address account, address token) external returns (uint256);

  function approve(address account, uint256 amount, address token) external returns (bool);

  /****************************************************** */

  function addGameAmount(address account, uint256 amount) external returns (bool);

  function subGameAmount(address account, uint256 amount) external returns (bool);

  function getGameAmount(address account) external returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IWhitelist {
  /********************************************************* */
  /***********************EVENTS**************************** */
  /********************************************************* */

  event NewWhiteListed(address account, address ref);
  event WhiteListedRemoved(address account);

  /********************************************************* */
  /************************FUNCTIONS************************ */
  /********************************************************* */
  function isWhitelisted(address account) external returns (bool);

  function whitelist(address ref) external returns (bool);

  function remove(address account) external returns (bool);

  function count() external returns (uint256);
}