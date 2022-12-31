/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

// Sources flattened with hardhat v2.12.5 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]
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


// File @openzeppelin/contracts/access/[email protected]


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]


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


// File @openzeppelin/contracts/token/ERC20/[email protected]


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


// File @openzeppelin/contracts/utils/[email protected]


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


// File @openzeppelin/contracts/token/ERC20/utils/[email protected]


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;



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


// File @openzeppelin/contracts/utils/math/[email protected]


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


// File contracts/libraries/IterableOrderedOrderSet.sol


pragma solidity ^0.8.0;

library IterableOrderedOrderSet {
    using SafeMath for uint96;
    using IterableOrderedOrderSet for bytes32;

    // represents smallest possible value for an order under comparison of fn smallerThan()
    bytes32 internal constant QUEUE_START =
        0x0000000000000000000000000000000000000000000000000000000000000001;
    // represents highest possible value for an order under comparison of fn smallerThan()
    bytes32 internal constant QUEUE_END =
        0xffffffffffffffffffffffffffffffffffffffff000000000000000000000001;

    /// The struct is used to implement a modified version of a doubly linked
    /// list with sorted elements. The list starts from QUEUE_START to
    /// QUEUE_END, and each node keeps track of its predecessor and successor.
    /// Nodes can be added or removed.
    ///
    /// `next` and `prev` have a different role. The list is supposed to be
    /// traversed with `next`. If `next` is empty, the node is not part of the
    /// list. However, `prev` might be set for elements that are not in the
    /// list, which is why it should not be used for traversing. Having a `prev`
    /// set for elements not in the list is used to keep track of the history of
    /// the position in the list of a removed element.
    struct Data {
        mapping(bytes32 => bytes32) nextMap;
        mapping(bytes32 => bytes32) prevMap;
    }

    struct Order {
        uint64 owner;
        uint96 buyAmount;
        uint96 sellAmount;
    }

    function initializeEmptyList(Data storage self) internal {
        self.nextMap[QUEUE_START] = QUEUE_END;
        self.prevMap[QUEUE_END] = QUEUE_START;
    }

    function isEmpty(Data storage self) internal view returns (bool) {
        return self.nextMap[QUEUE_START] == QUEUE_END;
    }

    function insert(
        Data storage self,
        bytes32 elementToInsert,
        bytes32 elementBeforeNewOne
    ) internal returns (bool) {
        (, , uint96 denominator) = decodeOrder(elementToInsert);
        require(denominator != uint96(0), "Inserting zero is not supported");
        require(
            elementToInsert != QUEUE_START && elementToInsert != QUEUE_END,
            "Inserting element is not valid"
        );
        if (contains(self, elementToInsert)) {
            return false;
        }
        if (
            elementBeforeNewOne != QUEUE_START &&
            self.prevMap[elementBeforeNewOne] == bytes32(0)
        ) {
            return false;
        }
        if (!elementBeforeNewOne.smallerThan(elementToInsert)) {
            return false;
        }

        // `elementBeforeNewOne` might have been removed during the time it
        // took to the transaction calling this function to be mined, so
        // the new order cannot be appended directly to this. We follow the
        // history of previous links backwards until we find an element in
        // the list from which to start our search.
        // Note that following the link backwards returns elements that are
        // before `elementBeforeNewOne` in sorted order.
        while (self.nextMap[elementBeforeNewOne] == bytes32(0)) {
            elementBeforeNewOne = self.prevMap[elementBeforeNewOne];
        }

        // `elementBeforeNewOne` belongs now to the linked list. We search the
        // largest entry that is smaller than the element to insert.
        bytes32 previous;
        bytes32 current = elementBeforeNewOne;
        do {
            previous = current;
            current = self.nextMap[current];
        } while (current.smallerThan(elementToInsert));
        // Note: previous < elementToInsert < current
        self.nextMap[previous] = elementToInsert;
        self.prevMap[current] = elementToInsert;
        self.prevMap[elementToInsert] = previous;
        self.nextMap[elementToInsert] = current;

        return true;
    }

    /// The element is removed from the linked list, but the node retains
    /// information on which predecessor it had, so that a node in the chain
    /// can be reached by following the predecessor chain of deleted elements.
    function removeKeepHistory(Data storage self, bytes32 elementToRemove)
        internal
        returns (bool)
    {
        if (!contains(self, elementToRemove)) {
            return false;
        }
        bytes32 previousElement = self.prevMap[elementToRemove];
        bytes32 nextElement = self.nextMap[elementToRemove];
        self.nextMap[previousElement] = nextElement;
        self.prevMap[nextElement] = previousElement;
        self.nextMap[elementToRemove] = bytes32(0);
        return true;
    }

    /// Remove an element from the chain, clearing all related storage.
    /// Note that no elements should be inserted using as a reference point a
    /// node deleted after calling `remove`, since an element in the `prev`
    /// chain might be missing.
    function remove(Data storage self, bytes32 elementToRemove)
        internal
        returns (bool)
    {
        bool result = removeKeepHistory(self, elementToRemove);
        if (result) {
            self.prevMap[elementToRemove] = bytes32(0);
        }
        return result;
    }

    function contains(Data storage self, bytes32 value)
        internal
        view
        returns (bool)
    {
        if (value == QUEUE_START) {
            return false;
        }
        // Note: QUEUE_END is not contained in the list since it has no
        // successor.
        return self.nextMap[value] != bytes32(0);
    }

    // @dev orders are ordered by
    // 1. their price - buyAmount/sellAmount
    // 2. by the sellAmount
    // 3. their userId,
    function smallerThan(bytes32 orderLeft, bytes32 orderRight)
        internal
        pure
        returns (bool)
    {
        (
            uint64 userIdLeft,
            uint96 priceNumeratorLeft,
            uint96 priceDenominatorLeft
        ) = decodeOrder(orderLeft);
        (
            uint64 userIdRight,
            uint96 priceNumeratorRight,
            uint96 priceDenominatorRight
        ) = decodeOrder(orderRight);

        if (
            priceNumeratorLeft.mul(priceDenominatorRight) <
            priceNumeratorRight.mul(priceDenominatorLeft)
        ) return true;
        if (
            priceNumeratorLeft.mul(priceDenominatorRight) >
            priceNumeratorRight.mul(priceDenominatorLeft)
        ) return false;

        if (priceNumeratorLeft < priceNumeratorRight) return true;
        if (priceNumeratorLeft > priceNumeratorRight) return false;
        require(
            userIdLeft != userIdRight,
            "user is not allowed to place same order twice"
        );
        if (userIdLeft < userIdRight) {
            return true;
        }
        return false;
    }

    function first(Data storage self) internal view returns (bytes32) {
        require(!isEmpty(self), "Trying to get first from empty set");
        return self.nextMap[QUEUE_START];
    }

    function next(Data storage self, bytes32 value)
        internal
        view
        returns (bytes32)
    {
        require(value != QUEUE_END, "Trying to get next of last element");
        bytes32 nextElement = self.nextMap[value];
        require(
            nextElement != bytes32(0),
            "Trying to get next of non-existent element"
        );
        return nextElement;
    }

    function decodeOrder(bytes32 _orderData)
        internal
        pure
        returns (
            uint64 userId,
            uint96 buyAmount,
            uint96 sellAmount
        )
    {
        // Note: converting to uint discards the binary digits that do not fit
        // the type.
        userId = uint64(uint256(_orderData) >> 192);
        buyAmount = uint96(uint256(_orderData) >> 96);
        sellAmount = uint96(uint256(_orderData));
    }

    function encodeOrder(
        uint64 userId,
        uint96 buyAmount,
        uint96 sellAmount
    ) internal pure returns (bytes32) {
        return
            bytes32(
                (uint256(userId) << 192) +
                    (uint256(buyAmount) << 96) +
                    uint256(sellAmount)
            );
    }
}


// File contracts/libraries/IdToAddressBiMap.sol


pragma solidity ^0.8.0;
///////////////////////////////////////////////////////////////////////////////////////////////////////////
// Contract does not have test coverage, as it was nearly copied from:
// https://github.com/gnosis/solidity-data-structures/blob/master/contracts/libraries/IdToAddressBiMap.sol
// The only change is uint16 -> uint64
///////////////////////////////////////////////////////////////////////////////////////////////////////////

library IdToAddressBiMap {
    struct Data {
        mapping(uint64 => address) idToAddress;
        mapping(address => uint64) addressToId;
    }

    function hasId(Data storage self, uint64 id) internal view returns (bool) {
        return self.idToAddress[id + 1] != address(0);
    }

    function hasAddress(Data storage self, address addr)
        internal
        view
        returns (bool)
    {
        return self.addressToId[addr] != 0;
    }

    function getAddressAt(Data storage self, uint64 id)
        internal
        view
        returns (address)
    {
        require(hasId(self, id), "Must have ID to get Address");
        return self.idToAddress[id + 1];
    }

    function getId(Data storage self, address addr)
        internal
        view
        returns (uint64)
    {
        require(hasAddress(self, addr), "Must have Address to get ID");
        return self.addressToId[addr] - 1;
    }

    function insert(
        Data storage self,
        uint64 id,
        address addr
    ) internal returns (bool) {
        require(addr != address(0), "Cannot insert zero address");
        require(id != uint64(int64(-1)), "Cannot insert max uint64");
        // Ensure bijectivity of the mappings
        if (
            self.addressToId[addr] != 0 ||
            self.idToAddress[id + 1] != address(0)
        ) {
            return false;
        }
        self.idToAddress[id + 1] = addr;
        self.addressToId[addr] = id + 1;
        return true;
    }
}


// File contracts/libraries/SafeCast.sol



pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Logic was copied and modified from here: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/SafeCast.sol
 */
library SafeCast {
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value < 2**96, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value < 2**64, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }
}


// File contracts/MutoPool.sol


pragma solidity ^0.8.0;







struct InitialAuctionData{
    string formHash;
    IERC20 auctioningToken;
    IERC20 biddingToken;
    uint40 orderCancellationEndDate;
    uint40 auctionStartDate;
    uint40 auctionEndDate;
    uint96 auctionedSellAmount;
    uint96 minBuyAmount;
    uint256 minimumBiddingAmountPerOrder;
    uint256 minFundingThreshold;
    bool isAtomicClosureAllowed;
}
    
struct AuctionData {
    InitialAuctionData initData;
    address poolOwner;
    bytes32 initialAuctionOrder;
    uint256 interimSumBidAmount;
    bytes32 interimOrder;
    bytes32 clearingPriceOrder;
    uint96 volumeClearingPriceOrder;
    bool minFundingThresholdNotReached;
    uint256 feeNumerator;
    bool isScam;
    bool isDeleted;    
}

contract MutoPool is Ownable {
    
    using SafeERC20 for IERC20;
    using SafeMath for uint40;
    using SafeMath for uint64;
    using SafeMath for uint96;
    using SafeMath for uint256;
    using SafeCast for uint256;
    //using SafeCast for uint64;

    using IterableOrderedOrderSet for bytes32;
    using IdToAddressBiMap for IdToAddressBiMap.Data;
    using IterableOrderedOrderSet for IterableOrderedOrderSet.Data;

    mapping(uint256 => AuctionData) public auctionData;
    mapping(uint256 => IterableOrderedOrderSet.Data) internal sellOrders;

    uint64 public numUsers;
    uint256 public auctionCounter;
    IdToAddressBiMap.Data private registeredUsers;

    constructor()  Ownable() {}

    uint64 public feeReceiverUserId = 1;
    uint256 public feeNumerator = 0;
    uint256 public constant FEE_DENOMINATOR = 1000;

    function iscancellledorDeleted(uint256 auctioId) internal view{
        require(!auctionData[auctioId].isScam);
        require(!auctionData[auctioId].isDeleted);
    }

    modifier atStageOrderPlacementAndCancelation(uint256 auctionId) {
        require(
            block.timestamp < auctionData[auctionId].initData.orderCancellationEndDate,
            "not in  placement/cancelation phase"
        );
        _;
    }
    
    modifier atStageFinished(uint256 auctionId) {
        require(
            auctionData[auctionId].clearingPriceOrder != bytes32(0),
            "auction not finished"
        );
        _;
    }
    
    modifier atStageOrderPlacement(uint256 auctionId) {
        orderplace(auctionId);
        _;
    }

    modifier atStageSolutionSubmission(uint256 auctionId) {
        solutionSubmission(auctionId);
        iscancellledorDeleted(auctionId);   

        _;
    }

    event NewAuction(
        uint256 indexed auctionId,
        IERC20 indexed _auctioningToken,
        IERC20 indexed _biddingToken,
        uint256 orderCancellationEndDate,
        uint256 auctionEndDate,
        uint64 userId,
        uint96 _auctionedSellAmount,
        uint96 _minBuyAmount,
        uint256 minimumBiddingAmountPerOrder,
        uint256 minFundingThreshold
    );

    event ClaimedFromOrder(
        uint256 indexed auctionId,
        uint64 indexed userId,
        uint96 buyAmount,
        uint96 sellAmount
    );

    event AuctionCleared(
        uint256 indexed auctionId,
        uint96 soldAuctioningTokens,
        uint96 soldBiddingTokens,
        bytes32 clearingPriceOrder
    );    

    event NewSellOrder(
        uint256 indexed auctionId,
        uint64 indexed userId,
        uint96 buyAmount,
        uint96 sellAmount
    );

    event CancellationSellOrder(
        uint256 indexed auctionId,
        uint64 indexed userId,
        uint96 buyAmount,
        uint96 sellAmount    
    );

    event NewUser(
        uint64 indexed userId, 
        address indexed userAddress
    );

    event UserRegistration(
        address indexed user, 
        uint64 userId
    );
    
    
    function initiateAuction(
            string memory _formHash,
            IERC20 _auctioningToken,
            IERC20 _biddingToken,
            uint40 _orderCancellationEndDate,  
            uint40 _auctionStartDate,
            uint40 _auctionEndDate,
            uint96 _auctionedSellAmount,
            uint96 _minBuyAmount,
            uint256 _minimumBiddingAmountPerOrder,
            uint256 _minFundingThreshold,
            bool _isAtomicClosureAllowed
        ) public returns (uint256) {
            uint256 _ammount = _auctionedSellAmount.mul(FEE_DENOMINATOR.add(feeNumerator)).div(
                    FEE_DENOMINATOR);
            require(_auctioningToken.balanceOf(msg.sender)>=_ammount);
            require(block.timestamp<_auctionStartDate && _auctionStartDate<_auctionEndDate);
            require(_auctionedSellAmount > 0);
            require(_minBuyAmount > 0);
            require(_minimumBiddingAmountPerOrder > 0);
            require(_orderCancellationEndDate <= _auctionEndDate);
            require(_auctionEndDate > block.timestamp);
            _auctioningToken.safeTransferFrom(
                msg.sender,
                address(this),
                _ammount
            );
            InitialAuctionData memory  data = InitialAuctionData(
                    _formHash,
                    _auctioningToken,
                    _biddingToken,
                    _orderCancellationEndDate,
                    _auctionStartDate,
                    _auctionEndDate,
                    _auctionedSellAmount,
                    _minBuyAmount,
                    _minimumBiddingAmountPerOrder,
                    _minFundingThreshold,
                    _isAtomicClosureAllowed
                );
            auctionCounter = auctionCounter.add(1);
            sellOrders[auctionCounter].initializeEmptyList();
            uint64 userId = getUserId(msg.sender);
            auctionData[auctionCounter] = AuctionData(
                data,
                msg.sender,
                IterableOrderedOrderSet.encodeOrder(
                    userId,
                    _minBuyAmount,
                    _auctionedSellAmount
                ),
                0,
                IterableOrderedOrderSet.QUEUE_START,
                bytes32(0),
                0,
                false,
                feeNumerator,
                false,
                false
            );
            emit NewAuction(
                auctionCounter,
                _auctioningToken,
                _biddingToken,
                _orderCancellationEndDate,
                _auctionEndDate,
                userId,
                _auctionedSellAmount,
                _minBuyAmount,
                _minimumBiddingAmountPerOrder,
                _minFundingThreshold
            );
            return auctionCounter;
        }

    function markSpam(uint256 auctioId) external onlyOwner{
        auctionData[auctioId].isScam = true;
    }

    function deletAuction(uint256 auctioId) external onlyOwner{
        auctionData[auctioId].isDeleted = true;
    }

    function updateAuctionAdmin(uint256 auctionId, uint40 _startTime, uint40 _endTime, uint40 _cancelTime, uint256 _fundingThreshold,uint256 _minBid ) external onlyOwner{
        auctionData[auctionId].initData.auctionStartDate = _startTime;
        auctionData[auctionId].initData.auctionEndDate = _endTime;
        auctionData[auctionId].initData.orderCancellationEndDate = _cancelTime;
        auctionData[auctionId].initData.minFundingThreshold = _fundingThreshold;
        auctionData[auctionId].initData.minimumBiddingAmountPerOrder = _minBid;
    }

    function updateAuctionUser(uint256 auctionId, uint40 _startTime, uint40 _endTime, uint40 _cancelTime, string memory _formHash) external{
        require(msg.sender==auctionData[auctionId].poolOwner);
        auctionData[auctionId].initData.auctionStartDate = _startTime;
        auctionData[auctionId].initData.auctionEndDate = _endTime;
        auctionData[auctionId].initData.orderCancellationEndDate = _cancelTime;
        auctionData[auctionId].initData.formHash = _formHash;
    }
        
    function placeSellOrders(
            uint256 auctionId,
            uint96 _minBuyAmount,
            uint96 _sellAmount,
            bytes32 _prevSellOrder
        ) external atStageOrderPlacement(auctionId) returns (uint64 userId) {
            return
                _placeSellOrders(
                    auctionId,
                    _minBuyAmount,
                    _sellAmount,
                    _prevSellOrder,
                    msg.sender
                );
        }


    function placeSellOrdersOnBehalf(
            uint256 auctionId,
            uint96 _minBuyAmount,
            uint96 _sellAmount,
            bytes32 _prevSellOrder,
            address orderSubmitter
        ) external atStageOrderPlacement(auctionId) returns (uint64 userId) {
            return
                _placeSellOrders(
                    auctionId,
                    _minBuyAmount,
                    _sellAmount,
                    _prevSellOrder,
                    orderSubmitter
                );
        }


    function _placeSellOrders(
            uint256 auctionId,
            uint96 _minBuyAmount,
            uint96 _sellAmount,
            bytes32 _prevSellOrder,
            address orderSubmitter
        ) internal returns (uint64 userId) {
            {
                (   ,
                    uint96 buyAmountOfInitialAuctionOrder,
                    uint96 sellAmountOfInitialAuctionOrder
                ) = auctionData[auctionId].initialAuctionOrder.decodeOrder();
                require(
                        _minBuyAmount.mul(buyAmountOfInitialAuctionOrder) <
                            sellAmountOfInitialAuctionOrder.mul(_sellAmount),
                        "limit price is <  min offer"
                    );
            }
            userId = getUserId(orderSubmitter);
            uint256 minimumBiddingAmountPerOrder =
                auctionData[auctionId].initData.minimumBiddingAmountPerOrder;
                require(_minBuyAmount > 0,"buyAmounts must be < 0");
                require(_sellAmount > minimumBiddingAmountPerOrder,"order too small");
                if (
                    sellOrders[auctionId].insert(
                        IterableOrderedOrderSet.encodeOrder(
                            userId,
                            _minBuyAmount,
                            _sellAmount
                        ),
                        _prevSellOrder
                    )
                ) {
                    emit NewSellOrder(
                        auctionId,
                        userId,
                        _minBuyAmount,
                        _sellAmount
                    );
                }
            auctionData[auctionId].initData.biddingToken.safeTransferFrom(
                msg.sender,
                address(this),
                _sellAmount
            );
        }
            
        
    function cancelSellOrder(uint256 auctionId, bytes32 _sellOrder)
            public
            atStageOrderPlacementAndCancelation(auctionId)
        {
            uint64 userId = getUserId(msg.sender);
            bool success = sellOrders[auctionId].removeKeepHistory(_sellOrder);
            if (success) {
                (
                    uint64 userIdOfIter,
                    uint96 buyAmountOfIter,
                    uint96 sellAmountOfIter
                ) = _sellOrder.decodeOrder();
                require(
                    userIdOfIter == userId,
                    "user can cancel"
                );
                emit CancellationSellOrder(
                    auctionId,
                    userId,
                    buyAmountOfIter,
                    sellAmountOfIter
                );
                auctionData[auctionId].initData.biddingToken.safeTransfer(
                msg.sender,
                sellAmountOfIter
            );
            }
        }


    function sendOutTokens(
            uint256 auctionId,
            uint256 auctioningTokenAmount,
            uint256 biddingTokenAmount,
            uint64 userId
        ) internal {
            address userAddress = registeredUsers.getAddressAt(userId);
            if (auctioningTokenAmount > 0) {
                auctionData[auctionId].initData.auctioningToken.safeTransfer(
                    userAddress,
                    auctioningTokenAmount
                );
            }
            if (biddingTokenAmount > 0) {
                auctionData[auctionId].initData.biddingToken.safeTransfer(
                    userAddress,
                    biddingTokenAmount
                );
            }
        }
        
    function claimFromParticipantOrder(
            uint256 auctionId,
            bytes32 order
        )
            public
            atStageFinished(auctionId)
            returns (
                uint256 auctioningTokenAmount,
                uint256 biddingTokenAmount
            )
        {
            require(sellOrders[auctionId].remove(order),"order not claimable");
            (, uint96 priceNumerator, uint96 priceDenominator) = auctionData[auctionId].clearingPriceOrder.decodeOrder();
            (uint64 userId, uint96 buyAmount, uint96 sellAmount) = order.decodeOrder();
            require(getUserId(msg.sender) == userId,"Claimable by user");
            if (auctionData[auctionId].minFundingThresholdNotReached)
            {
            	biddingTokenAmount = sellAmount;
            }
            else {
            	if (order == auctionData[auctionId].clearingPriceOrder) {
		        auctioningTokenAmount =
		            auctionData[auctionId]
		                .volumeClearingPriceOrder
		                .mul(priceNumerator)
		                .div(priceDenominator);
		        biddingTokenAmount = sellAmount.sub(auctionData[auctionId].volumeClearingPriceOrder);
               } else {
                        if (order.smallerThan(auctionData[auctionId].clearingPriceOrder)) {
                            auctioningTokenAmount =
                                sellAmount.mul(priceNumerator).div(priceDenominator);
                        } else {
                            biddingTokenAmount = sellAmount;
                        }
                    }
            }
            emit ClaimedFromOrder(auctionId, userId, buyAmount, sellAmount);
            sendOutTokens(
                auctionId,
                auctioningTokenAmount,
                biddingTokenAmount,
                userId
            );    
            
        }   
           
    function processFeesAndAuctioneerFunds(
            uint256 auctionId,
            uint256 fillVolumeOfAuctioneerOrder,
            uint64 auctioneerId,
            uint96 fullAuctionedAmount
        ) internal {
            uint256 feeAmount =
                fullAuctionedAmount.mul(auctionData[auctionId].feeNumerator).div(
                    FEE_DENOMINATOR
                ); //[20]
            if (auctionData[auctionId].minFundingThresholdNotReached) {
                sendOutTokens(
                    auctionId,
                    fullAuctionedAmount.add(feeAmount),
                    0,
                    auctioneerId
                ); //[4]
            } else {
                //[11]
                (, uint96 priceNumerator, uint96 priceDenominator) =
                    auctionData[auctionId].clearingPriceOrder.decodeOrder();
                uint256 unsettledAuctionTokens =
                    fullAuctionedAmount.sub(fillVolumeOfAuctioneerOrder);
                uint256 auctioningTokenAmount =
                    unsettledAuctionTokens.add(
                        feeAmount.mul(unsettledAuctionTokens).div(
                            fullAuctionedAmount
                        )
                    );
                uint256 biddingTokenAmount =
                    fillVolumeOfAuctioneerOrder.mul(priceDenominator).div(
                        priceNumerator
                    );
                sendOutTokens(
                    auctionId,
                    auctioningTokenAmount,
                    biddingTokenAmount,
                    auctioneerId
                ); //[5]
                sendOutTokens(
                    auctionId,
                    feeAmount.mul(fillVolumeOfAuctioneerOrder).div(
                        fullAuctionedAmount
                    ),
                    0,
                    feeReceiverUserId
                ); //[7]
            }
        }  
        

    function settleAuctionAtomically(
            uint256 auctionId,
            uint96 _minBuyAmount,
            uint96 _sellAmount,
            bytes32 _prevSellOrder
        ) public atStageSolutionSubmission(auctionId) {
            require(
                auctionData[auctionId].initData.isAtomicClosureAllowed,
                "not allowed"
            );
            uint64 userId = getUserId(msg.sender);
            require(
                auctionData[auctionId].interimOrder.smallerThan(
                    IterableOrderedOrderSet.encodeOrder(
                        userId,
                        _minBuyAmount,
                        _sellAmount
                    )
                )
            );
            _placeSellOrders(
                auctionId,
                _minBuyAmount,
                _sellAmount,
                _prevSellOrder,
                msg.sender
            );
            settleAuction(auctionId);
        }


    function settleAuction(uint256 auctionId)
            public
            atStageSolutionSubmission(auctionId)
            returns (bytes32 clearingOrder)
        {
            (
                uint64 auctioneerId,
                uint96 minAuctionedBuyAmount,
                uint96 fullAuctionedAmount
            ) = auctionData[auctionId].initialAuctionOrder.decodeOrder();

            uint256 currentBidSum = auctionData[auctionId].interimSumBidAmount;
            bytes32 currentOrder = auctionData[auctionId].interimOrder;
            uint256 buyAmountOfIter;
            uint256 sellAmountOfIter;
            uint96 fillVolumeOfAuctioneerOrder = fullAuctionedAmount;
            // Sum order up, until fullAuctionedAmount is fully bought or queue end is reached
            do {
                bytes32 nextOrder = sellOrders[auctionId].next(currentOrder);
                if (nextOrder == IterableOrderedOrderSet.QUEUE_END) {
                    break;
                }
                currentOrder = nextOrder;
                (, buyAmountOfIter, sellAmountOfIter) = currentOrder.decodeOrder();
                currentBidSum = currentBidSum.add(sellAmountOfIter);
            } while (
                currentBidSum.mul(buyAmountOfIter) <
                    fullAuctionedAmount.mul(sellAmountOfIter)
            );

            if (
                currentBidSum > 0 &&
                currentBidSum.mul(buyAmountOfIter) >=
                fullAuctionedAmount.mul(sellAmountOfIter)
            ) {
                // All considered/summed orders are sufficient to close the auction fully
                // at price between current and previous orders.
                uint256 uncoveredBids =
                    currentBidSum.sub(
                        fullAuctionedAmount.mul(sellAmountOfIter).div(
                            buyAmountOfIter
                        )
                    );

                if (sellAmountOfIter >= uncoveredBids) {
                    //[13]
                    // Auction fully filled via partial match of currentOrder
                    uint256 sellAmountClearingOrder =
                        sellAmountOfIter.sub(uncoveredBids);
                    auctionData[auctionId]
                        .volumeClearingPriceOrder = sellAmountClearingOrder
                        .toUint96();
                    currentBidSum = currentBidSum.sub(uncoveredBids);
                    clearingOrder = currentOrder;
                } else {
                    currentBidSum = currentBidSum.sub(sellAmountOfIter);
                    clearingOrder = IterableOrderedOrderSet.encodeOrder(
                        0,
                        fullAuctionedAmount,
                       uint96 (currentBidSum)
                    );
                }
            } else {
                if (currentBidSum > minAuctionedBuyAmount) {
                    clearingOrder = IterableOrderedOrderSet.encodeOrder(
                        0,
                        fullAuctionedAmount,
                        currentBidSum.toUint96()
                    );
                } else {
                    //[16]
                    // Even at the initial auction price, the auction is partially filled
                    clearingOrder = IterableOrderedOrderSet.encodeOrder(
                        0,
                        fullAuctionedAmount,
                        minAuctionedBuyAmount
                    );
                    fillVolumeOfAuctioneerOrder = currentBidSum
                        .mul(fullAuctionedAmount)
                        .div(minAuctionedBuyAmount)
                        .toUint96();
                }
            }
            auctionData[auctionId].clearingPriceOrder = clearingOrder;

            if (auctionData[auctionId].initData.minFundingThreshold > currentBidSum) {
                auctionData[auctionId].minFundingThresholdNotReached = true;
            }
            processFeesAndAuctioneerFunds(
                auctionId,
                fillVolumeOfAuctioneerOrder,
                auctioneerId,
                fullAuctionedAmount
            );
            emit AuctionCleared(
                auctionId,
                fillVolumeOfAuctioneerOrder,
                uint96(currentBidSum),
                clearingOrder
            );

            auctionData[auctionId].initialAuctionOrder = bytes32(0);
            auctionData[auctionId].interimOrder = bytes32(0);
            auctionData[auctionId].interimSumBidAmount = uint256(0);
            auctionData[auctionId].initData.minimumBiddingAmountPerOrder = uint256(0);
        }   
        
        
    function precalculateSellAmountSum(
            uint256 auctionId,
            uint256 iterationSteps
        ) public atStageSolutionSubmission(auctionId) {
            (, , uint96 auctioneerSellAmount) =
                auctionData[auctionId].initialAuctionOrder.decodeOrder();
            uint256 sumBidAmount = auctionData[auctionId].interimSumBidAmount;
            bytes32 iterOrder = auctionData[auctionId].interimOrder;

            for (uint256 i = 0; i < iterationSteps; i++) {
                iterOrder = sellOrders[auctionId].next(iterOrder);
                (, , uint96 sellAmountOfIter) = iterOrder.decodeOrder();
                sumBidAmount = sumBidAmount.add(sellAmountOfIter);
            }

            require(
                iterOrder != IterableOrderedOrderSet.QUEUE_END,
                "reached end"
            );
            (, uint96 buyAmountOfIter, uint96 selAmountOfIter) =
                iterOrder.decodeOrder();
            require(
                sumBidAmount.mul(buyAmountOfIter) <
                    auctioneerSellAmount.mul(selAmountOfIter),
                "too many orders"
            );

            auctionData[auctionId].interimSumBidAmount = sumBidAmount;
            auctionData[auctionId].interimOrder = iterOrder;
        }
           
    function setFeeParameters(
            uint256 newFeeNumerator,
            address newfeeReceiverAddress
        ) public onlyOwner() {
            require(newFeeNumerator <= 15);
            feeReceiverUserId = getUserId(newfeeReceiverAddress);
            feeNumerator = newFeeNumerator;
        }
        
        
    function containsOrder(uint256 auctionId, bytes32 order)
            public
            view
            returns (bool)
        {
            return sellOrders[auctionId].contains(order);
        }
        
        
    function getSecondsRemainingInBatch(uint256 auctionId)
            public
            view
            returns (uint256)
        {
            if (auctionData[auctionId].initData.auctionEndDate < block.timestamp) {
                return 0;
            }
            return auctionData[auctionId].initData.auctionEndDate.sub(block.timestamp);
        }
        
        
    function registerUser(address user) public returns (uint64 userId) {
            numUsers = numUsers.add(1).toUint64();
            require(registeredUsers.insert(numUsers, user),"User Exists");
            userId = numUsers;
            emit UserRegistration(user, userId);
        }


    function getUserId(address user) public returns (uint64 userId) {
            if (registeredUsers.hasAddress(user)) {
                userId = registeredUsers.getId(user);
            } else {
                userId = registerUser(user);
                emit NewUser(userId, user);
            }
        }


    function getFormHash(uint256 auction_id) public view returns(string memory){
        require(auction_id<=auctionCounter, "Invalid Id");
        return auctionData[auction_id].initData.formHash;
    }

    function orderplace(uint256 auctionId) internal view {
        require(
            block.timestamp < auctionData[auctionId].initData.auctionEndDate,
            "Not in order placement phase"
        );
    }

    function solutionSubmission(uint256 auctionId) internal view{
            uint256 auctionEndDate = auctionData[auctionId].initData.auctionEndDate;
            require(
                auctionEndDate != 0 &&
                    block.timestamp >= auctionEndDate &&
                    auctionData[auctionId].clearingPriceOrder == bytes32(0),
                "Not in submission phase"
            );
        }
}