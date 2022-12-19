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
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity 0.8.13;

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Operator is Context, Ownable {
    address private _operator;

    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);

    constructor() {
        _operator = _msgSender();
        emit OperatorTransferred(address(0), _operator);
    }

    function operator() public view returns (address) {
        return _operator;
    }

    modifier onlyOperator() {
        require(_operator == msg.sender, "operator: caller is not the operator");
        _;
    }

    function isOperator() public view returns (bool) {
        return _msgSender() == _operator;
    }

    function transferOperator(address newOperator_) public onlyOwner {
        _transferOperator(newOperator_);
    }

    function _transferOperator(address newOperator_) internal {
        require(newOperator_ != address(0), "operator: zero address given for new operator");
        emit OperatorTransferred(address(0), newOperator_);
        _operator = newOperator_;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "./lib/SafeMath.sol";
import "./owner/Operator.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ShareTokenRewardPoolV2 is Operator {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;
        uint256 lastRewardTime;
        uint256[18] rewardDebt;
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 token; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. ShareToken to distribute per block.
        uint256 lastRewardTime; // Last time that ShareToken distribution occurs.
        uint256[18] accRewardTokenPerShare; // Accumulated ShareToken per share, times 1e18. See below.
        bool isStarted; // if lastRewardTime has passed
        uint256 depositFeePercent;
    }

    struct RewardInfo {
        uint256 rewardForDao;
        uint256 rewardForDev;
        uint256 rewardForUser;
        uint256 rewardPerSecondForDao;
        uint256 rewardPerSecondForDev;
        uint256 rewardPerSecondForUser;
        uint256 startTime;
    }

    IERC20 public immutable shareToken;

    // Info of each pool.
    PoolInfo[] public poolInfo;

    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    uint256 public totalAllocPoint;

    uint256 public immutable poolStartTime;
    uint256 public immutable poolEndTime;

    uint256 public constant runningTimeMonth = 18; // 18 months

    RewardInfo[18] public rewardInfos;
    uint256 public lastDaoRewardTime;
    uint256 public lastDevRewardTime;
    address public immutable devWallet;
	address public immutable daoWallet;
    address public immutable polWallet;

    uint256 constant public MONTH = 30 * 60;
    uint256 constant public firstMonthReward = 3666 ether;
    uint256 public totalUserReward = 0;
    uint256 public totalDevReward = 0;
    uint256 constant public devPercent = 1000; // 10%
    uint256 public totalDaoReward = 0;
    uint256 constant public daoPercent = 1000; // 10%
    uint256 constant rewardDecreaseEachMonthPercent = 2000; // 20%

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event RewardPaid(address indexed user, uint256 amount);
    event SetDepositFeePercent(uint256 oldValue, uint256 newValue);

    constructor(
        address _token,
        address _daoWallet,
        address _devWallet,
        address _polWallet,
        uint256 _poolStartTime
    ) {
        require(block.timestamp < _poolStartTime, "late");
        require(_token != address(0), "!_token");
        require(_daoWallet != address(0), "!_daoWallet");
        require(_devWallet != address(0), "!_devWallet");
        require(_polWallet != address(0), "!_polWallet");

        shareToken = IERC20(_token);

        daoWallet = _daoWallet;
        devWallet = _devWallet; 
        polWallet = _polWallet;

        totalAllocPoint = 0;
        poolStartTime = _poolStartTime;

        lastDaoRewardTime = poolStartTime;
        lastDevRewardTime = poolStartTime;
        uint256 runningTime = runningTimeMonth * MONTH;
        poolEndTime = poolStartTime + runningTime;

        uint256 devRewardFirstMonth = firstMonthReward * devPercent / 10000;
        uint256 daoRewardFirstMonth = firstMonthReward * daoPercent / 10000;
        uint256 userRewardFirstMonth = firstMonthReward - devRewardFirstMonth - daoRewardFirstMonth;
        uint256 startTime = poolStartTime;
        for (uint256 i = 0; i < runningTimeMonth; ++i) {
            rewardInfos[i].rewardForDev = devRewardFirstMonth;
            rewardInfos[i].rewardForDao = daoRewardFirstMonth;
            rewardInfos[i].rewardForUser = userRewardFirstMonth;
            rewardInfos[i].startTime = startTime;

            rewardInfos[i].rewardPerSecondForDev = devRewardFirstMonth / MONTH;
            rewardInfos[i].rewardPerSecondForDao = daoRewardFirstMonth / MONTH;
            rewardInfos[i].rewardPerSecondForUser = userRewardFirstMonth / MONTH;

            devRewardFirstMonth = devRewardFirstMonth - (devRewardFirstMonth * rewardDecreaseEachMonthPercent / 10000);
            daoRewardFirstMonth = daoRewardFirstMonth - (daoRewardFirstMonth * rewardDecreaseEachMonthPercent / 10000);
            userRewardFirstMonth = userRewardFirstMonth - (userRewardFirstMonth * rewardDecreaseEachMonthPercent / 10000);
            startTime = startTime + MONTH;

            totalDevReward = totalDevReward + rewardInfos[i].rewardForDev;
            totalDaoReward = totalDaoReward + rewardInfos[i].rewardForDao;
            totalUserReward = totalUserReward + rewardInfos[i].rewardForUser;
        }
    }

    function checkPoolDuplicate(IERC20 _token) internal view {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            require(poolInfo[pid].token != _token, "ShareTokenRewardPool: existing pool?");
        }
    }

    // Add a new pool. Can only be called by the Operator.
    function add(
        uint256 _allocPoint,
        address _token,
        uint256 _depositFee,
        uint256 _lastRewardTime
    ) external onlyOperator {
        require(_token != address(0), "!_token");
        require(_depositFee <= 100, 'Max percent is 1%');
        checkPoolDuplicate(IERC20(_token));
        massUpdatePools();
        if (block.timestamp < poolStartTime) {
            // chef is sleeping
            if (_lastRewardTime == 0) {
                _lastRewardTime = poolStartTime;
            } else {
                if (_lastRewardTime < poolStartTime) {
                    _lastRewardTime = poolStartTime;
                }
            }
        } else {
            // chef is cooking
            if (_lastRewardTime == 0 || _lastRewardTime < block.timestamp) {
                _lastRewardTime = block.timestamp;
            }
        }
        bool _isStarted = (_lastRewardTime <= poolStartTime) || (_lastRewardTime <= block.timestamp);
        poolInfo.push(PoolInfo({
            token : IERC20(_token),
            allocPoint : _allocPoint,
            lastRewardTime : _lastRewardTime,
            accRewardTokenPerShare : [uint256(0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            isStarted : _isStarted,
            depositFeePercent: _depositFee
            }));
        if (_isStarted) {
            totalAllocPoint = totalAllocPoint.add(_allocPoint);
        }
    }

    // Update the given pool's ShareToken allocation point. Can only be called by the Operator.
    function set(uint256 _pid, uint256 _allocPoint) external onlyOperator {
        massUpdatePools();
        PoolInfo storage pool = poolInfo[_pid];
        if (pool.isStarted) {
            totalAllocPoint = totalAllocPoint.sub(pool.allocPoint).add(
                _allocPoint
            );
        }
        pool.allocPoint = _allocPoint;
    }

    function setDepositFeePercent(uint256 _pid, uint256 _value) external onlyOperator {
        require(_value <= 100, 'Max percent is 1%');
        PoolInfo storage pool = poolInfo[_pid];
        emit SetDepositFeePercent(pool.depositFeePercent, _value);
        pool.depositFeePercent = _value;
    }

    // View function to see pending on frontend.
    function pending(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo memory pool = poolInfo[_pid];
        uint256 daoReward = pendingDao(_user, lastDaoRewardTime, block.timestamp);
        uint256 devReward = pendingDev(_user, lastDevRewardTime, block.timestamp);
        uint256 userReward = pendingUser(_pid, _user, pool.lastRewardTime, block.timestamp);
        return userReward.add(daoReward).add(devReward);
    }

    function pendingUser(uint256 _pid, address _user, uint256 _fromTime, uint256 _toTime) public view returns (uint256) {
        if (_fromTime > _toTime) return 0;
        if (_toTime >= poolEndTime) {
            if (_fromTime >= poolEndTime) return 0;
            if (_fromTime <= poolStartTime) _fromTime = poolStartTime;
            _toTime = poolEndTime;
        } else {
            if (_toTime <= poolStartTime) return 0;
            if (_fromTime <= poolStartTime) _fromTime = poolStartTime;
        }

        uint256 reward = getUserReward(_pid, _user, _fromTime, _toTime);
        return reward;
    }

    function pendingDao(address _user, uint256 _fromTime, uint256 _toTime) internal view returns (uint256) {
        if (isDao(_user)) {
            if (_fromTime >= _toTime) return 0;
            if (_toTime >= poolEndTime) {
                if (_fromTime >= poolEndTime) return 0;
                if (_fromTime <= poolStartTime) _fromTime = poolStartTime;
                _toTime = poolEndTime;
                uint256 reward = getDaoReward(_fromTime, _toTime);
                return reward;
            } else {
                if (_toTime <= poolStartTime) return 0;
                if (_fromTime <= poolStartTime) _fromTime = poolStartTime;

                uint256 reward = getDaoReward(_fromTime, _toTime);
                return reward;
            }
        }

        return 0;
    }

    function pendingDev(address _user, uint256 _fromTime, uint256 _toTime) internal view returns (uint256) {
        if (isDev(_user)) {
            if (_fromTime >= _toTime) return 0;
            if (_toTime >= poolEndTime) {
                if (_fromTime >= poolEndTime) return 0;
                if (_fromTime <= poolStartTime) _fromTime = poolStartTime;
                _toTime = poolEndTime;
                uint256 reward = getDevReward(_fromTime, _toTime);
                return reward;
            } else {
                if (_toTime <= poolStartTime) return 0;
                if (_fromTime <= poolStartTime) _fromTime = poolStartTime;

                uint256 reward = getDevReward(_fromTime, _toTime);
                return reward;
            }
        }

        return 0;
    }

    function getDaoReward(uint256 _fromTime, uint256 _toTime) internal view returns (uint256) {
        uint256 fromMonth = getMonthFrom(_fromTime);
        uint256 toMonth = getMonthFrom(_toTime);
        uint256 reward = 0;
        for (uint256 i = fromMonth; i <= toMonth; ++i) {
            uint256 timeFrom = _fromTime;
            uint256 timeTo = poolEndTime;
            if (i < runningTimeMonth - 1) {
                timeTo = rewardInfos[i + 1].startTime > _toTime ? _toTime : rewardInfos[i + 1].startTime;
            }
            reward = reward + timeTo.sub(timeFrom).mul(rewardInfos[i].rewardPerSecondForDao);
            _fromTime = timeTo;
        } 
        
        return reward;
    }

    function getDevReward(uint256 _fromTime, uint256 _toTime) internal view returns (uint256) {
        uint256 fromMonth = getMonthFrom(_fromTime);
        uint256 toMonth = getMonthFrom(_toTime);
        uint256 reward = 0;
        for (uint256 i = fromMonth; i <= toMonth; ++i) {
            uint256 timeFrom = _fromTime;
            uint256 timeTo = poolEndTime;
            if (i < runningTimeMonth - 1) {
                timeTo = rewardInfos[i + 1].startTime > _toTime ? _toTime : rewardInfos[i + 1].startTime;
            }
            reward = reward + timeTo.sub(timeFrom).mul(rewardInfos[i].rewardPerSecondForDev);
            _fromTime = timeTo;
        } 
        
        return reward;
    }

    function getUserReward(uint256 _pid, address _user, uint256 _fromTime, uint256 _toTime) internal view returns (uint256) {
        UserInfo memory user = userInfo[_pid][_user];
        PoolInfo memory pool = poolInfo[_pid];
        uint256 reward = 0;
        uint256 userAmount = user.amount;
        uint256 lastUserRewardMonth = getMonthFrom(user.lastRewardTime);
        uint256 fromMonth = getMonthFrom(_fromTime);
        uint256 toMonth = getMonthFrom(_toTime);
        if (fromMonth > lastUserRewardMonth) {
            for (uint256 i = lastUserRewardMonth; i < fromMonth; ++i) {
                reward = reward + userAmount.mul( pool.accRewardTokenPerShare[i]).div(1e18).sub(user.rewardDebt[i]);
            }
        }
        uint256 tokenSupply = pool.token.balanceOf(address(this));
        for (uint256 i = fromMonth; i <= toMonth; ++i) {
            uint256 timeFrom = _fromTime;
            uint256 timeTo = poolEndTime;
            if (i < runningTimeMonth - 1) {
                timeTo = rewardInfos[i + 1].startTime > _toTime ? _toTime : rewardInfos[i + 1].startTime;
            }
            uint256 accRewardTokenPerShare = pool.accRewardTokenPerShare[i];
            if (tokenSupply > 0) {
                uint256 _generatedReward = timeTo.sub(timeFrom).mul(rewardInfos[i].rewardPerSecondForUser);
                uint256 _shareTokenReward = _generatedReward.mul(pool.allocPoint).div(totalAllocPoint);
                accRewardTokenPerShare = accRewardTokenPerShare.add(_shareTokenReward.mul(1e18).div(tokenSupply));
            }
            reward = reward + userAmount.mul(accRewardTokenPerShare).div(1e18).sub(user.rewardDebt[i]);
            _fromTime = timeTo;
        } 
        return reward;
    }

    function getUserRewardToClaim(uint256 _pid, address _user, uint256 _fromTime, uint256 _toTime) internal view returns (uint256) {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];
        uint256 reward = 0;
        uint256 userAmount = user.amount;
        uint256 fromMonth = getMonthFrom(_fromTime);
        uint256 toMonth = getMonthFrom(_toTime);

        for (uint256 i = fromMonth; i <= toMonth; ++i) {
            uint256 accRewardTokenPerShare = pool.accRewardTokenPerShare[i];
            reward = reward + userAmount.mul(accRewardTokenPerShare).div(1e18).sub(user.rewardDebt[i]);
        } 
        
        return reward;
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public onlyOperator {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.timestamp <= pool.lastRewardTime) {
            return;
        }
        uint256 tokenSupply = pool.token.balanceOf(address(this));
        if (tokenSupply == 0) {
            pool.lastRewardTime = block.timestamp;
            return;
        }
        if (!pool.isStarted) {
            pool.isStarted = true;
            totalAllocPoint = totalAllocPoint.add(pool.allocPoint);
        }
        
        if (totalAllocPoint > 0) {
            uint256 _fromTime = pool.lastRewardTime > poolEndTime ? poolEndTime : pool.lastRewardTime;
            uint256 _toTime = block.timestamp;
            uint256 fromMonth = getMonthFrom(_fromTime);
            uint256 toMonth = getMonthFrom(_toTime);
            for (uint256 i = fromMonth; i <= toMonth; ++i) {
                uint256 timeFrom = _fromTime;
                uint256 timeTo = poolEndTime;
                if (i < runningTimeMonth - 1) {
                    timeTo = rewardInfos[i + 1].startTime > _toTime ? _toTime : rewardInfos[i + 1].startTime;
                }

                uint256 _generatedReward = timeTo.sub(timeFrom).mul(rewardInfos[i].rewardPerSecondForUser);
                uint256 _shareTokenReward = _generatedReward.mul(pool.allocPoint).div(totalAllocPoint);
                pool.accRewardTokenPerShare[i] = pool.accRewardTokenPerShare[i].add(_shareTokenReward.mul(1e18).div(tokenSupply));

                _fromTime = timeTo;
            }
        }

        pool.lastRewardTime = block.timestamp;
    }

    // Deposit tokens.
    function deposit(uint256 _pid, uint256 _amount) external {
        address _sender = msg.sender;
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_sender];
        uint256 lastRewardTime = pool.lastRewardTime;
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 _pending = getUserRewardToClaim(_pid, _sender, user.lastRewardTime, block.timestamp);
            if (_pending > 0) {
                safeShareTokenTransfer(_sender, _pending);
                emit RewardPaid(_sender, _pending);
            }
        }
        user.lastRewardTime = block.timestamp;
        if (_amount > 0) {
            if (pool.depositFeePercent > 0) {
                uint256 feeAmount = _amount.mul(pool.depositFeePercent).div(10000);
                pool.token.safeTransferFrom(_sender, polWallet, feeAmount);
                _amount = _amount.sub(feeAmount);
            }

            pool.token.safeTransferFrom(_sender, address(this), _amount);
            user.amount = user.amount.add(_amount);
        }

        uint256 fromMonth = getMonthFrom(lastRewardTime);
        uint256 toMonth = getMonth();
        for (uint256 i = fromMonth; i <= toMonth; ++i) {
            user.rewardDebt[i] = user.amount.mul(pool.accRewardTokenPerShare[i]).div(1e18);
        }
        emit Deposit(_sender, _pid, _amount);
    }

    // Withdraw tokens.
    function withdraw(uint256 _pid, uint256 _amount) external {
        address _sender = msg.sender;
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_sender];
        require(user.amount >= _amount, "withdraw: not good");
        uint256 lastRewardTime = pool.lastRewardTime;
        updatePool(_pid);
        uint256 _pending = getUserRewardToClaim(_pid, _sender, user.lastRewardTime, block.timestamp);
        user.lastRewardTime = block.timestamp;
        uint256 _daoReward = pendingDao(_sender, lastDaoRewardTime, block.timestamp);
        uint256 _devReward = pendingDev(_sender, lastDevRewardTime, block.timestamp);
        uint256 _reward = 0;

        if (_daoReward > 0) {
            _reward = _reward.add(_daoReward);
            lastDaoRewardTime = block.timestamp;
        }

        if (_devReward > 0) {
            _reward = _reward.add(_devReward);
            lastDevRewardTime = block.timestamp;
        }

        if (_pending > 0) {
            _reward = _reward.add(_pending);
        }

        if (_reward > 0) {
            safeShareTokenTransfer(_sender, _reward);
            emit RewardPaid(_sender, _pending);
        }

        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.token.safeTransfer(_sender, _amount);
        }

        uint256 fromMonth = getMonthFrom(lastRewardTime);
        uint256 toMonth = getMonth();
        for (uint256 i = fromMonth; i <= toMonth; ++i) {
            user.rewardDebt[i] = user.amount.mul(pool.accRewardTokenPerShare[i]).div(1e18);
        }

        emit Withdraw(_sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 _amount = user.amount;
        user.amount = 0;
        for (uint256 i = 0; i < 18; ++i) {
            user.rewardDebt[i] = 0;
        }
        pool.token.safeTransfer(msg.sender, _amount);
        emit EmergencyWithdraw(msg.sender, _pid, _amount);
    }

    // Safe ShareToken transfer function, just in case if rounding error causes pool to not have enough ShareToken.
    function safeShareTokenTransfer(address _to, uint256 _amount) internal {
        uint256 _shareTokenBalance = shareToken.balanceOf(address(this));
        if (_shareTokenBalance > 0) {
            if (_amount > _shareTokenBalance) {
                shareToken.safeTransfer(_to, _shareTokenBalance);
            } else {
                shareToken.safeTransfer(_to, _amount);
            }
        }
    }

    function isDev(address _address) public view returns (bool) {
		return _address == devWallet;
	}

	function isDao(address _address) public view returns (bool) {
		return _address == daoWallet;
	}

    function getMonth() public view returns (uint256) {
        if (block.timestamp < poolStartTime) return 0;
        uint256 month = (block.timestamp - poolStartTime) / MONTH;
        return month > runningTimeMonth - 1 ? runningTimeMonth - 1 : month;
    }

    function getMonthFrom(uint256 _time) public view returns (uint256) {
        if (_time < poolStartTime) return 0;
        uint256 month = (_time - poolStartTime) / MONTH;
        return month > runningTimeMonth - 1 ? runningTimeMonth - 1 : month;
    }
}