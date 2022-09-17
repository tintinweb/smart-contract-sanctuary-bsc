/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
pragma experimental ABIEncoderV2;

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)


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

// File: @openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

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


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

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
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// File: @openzeppelin/contracts/utils/Counters.sol


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// File: @openzeppelin/contracts/access/IAccessControl.sol


// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// File: @openzeppelin/contracts/access/AccessControl.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;





/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// File: Emonster/IFO/utils/EmonProfile.sol


pragma solidity 0.8.16;








/** @title PanemonProfile.
 * @notice It is a contract for users to bind their address
 * to a customizable profile by depositing a NFT.
 */
contract EmonProfile is AccessControl, ERC721Holder {
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public emonToken;

    bytes32 public constant NFT_ROLE = keccak256("NFT_ROLE");
    bytes32 public constant POINT_ROLE = keccak256("POINT_ROLE");
    bytes32 public constant SPECIAL_ROLE = keccak256("SPECIAL_ROLE");

    uint256 public numberActiveProfiles;
    uint256 public numberEmonToReactivate;
    uint256 public numberEmonToRegister;
    uint256 public numberEmonToUpdate;
    uint256 public numberTeams;

    mapping(address => bool) public hasRegistered;

    mapping(uint256 => Team) private teams;
    mapping(address => User) private users;

    // Used for generating the teamId
    Counters.Counter private _countTeams;

    // Used for generating the userId
    Counters.Counter private _countUsers;

    // Event to notify a new team is created
    event TeamAdd(uint256 teamId, string teamName);

    // Event to notify that team points are increased
    event TeamPointIncrease(uint256 indexed teamId, uint256 numberPoints, uint256 indexed campaignId);

    event UserChangeTeam(address indexed userAddress, uint256 oldTeamId, uint256 newTeamId);

    // Event to notify that a user is registered
    event UserNew(address indexed userAddress, uint256 teamId, address nftAddress, uint256 tokenId);

    // Event to notify a user pausing her profile
    event UserPause(address indexed userAddress, uint256 teamId);

    // Event to notify that user points are increased
    event UserPointIncrease(address indexed userAddress, uint256 numberPoints, uint256 indexed campaignId);

    // Event to notify that a list of users have an increase in points
    event UserPointIncreaseMultiple(address[] userAddresses, uint256 numberPoints, uint256 indexed campaignId);

    // Event to notify that a user is reactivating her profile
    event UserReactivate(address indexed userAddress, uint256 teamId, address nftAddress, uint256 tokenId);

    // Event to notify that a user is pausing her profile
    event UserUpdate(address indexed userAddress, address nftAddress, uint256 tokenId);

    // Modifier for admin roles
    modifier onlyOwner() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Not the main admin");
        _;
    }

    // Modifier for point roles
    modifier onlyPoint() {
        require(hasRole(POINT_ROLE, _msgSender()), "Not a point admin");
        _;
    }

    // Modifier for special roles
    modifier onlySpecial() {
        require(hasRole(SPECIAL_ROLE, _msgSender()), "Not a special admin");
        _;
    }

    struct Team {
        string teamName;
        string teamDescription;
        uint256 numberUsers;
        uint256 numberPoints;
        bool isJoinable;
    }

    struct User {
        uint256 userId;
        uint256 numberPoints;
        uint256 teamId;
        address nftAddress;
        uint256 tokenId;
        bool isActive;
    }

    constructor(
        IERC20 _emonToken,
        uint256 _numberEmonToReactivate,
        uint256 _numberEmonToRegister,
        uint256 _numberEmonToUpdate
    ) {
        emonToken = _emonToken;
        numberEmonToReactivate = _numberEmonToReactivate;
        numberEmonToRegister = _numberEmonToRegister;
        numberEmonToUpdate = _numberEmonToUpdate;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /**
     * @dev To create a user profile. It sends the NFT to the contract
     * and sends EMON to burn address. Requires 2 token approvals.
     */
    function createProfile(
        uint256 _teamId,
        address _nftAddress,
        uint256 _tokenId
    ) external {
        require(!hasRegistered[_msgSender()], "Already registered");
        require((_teamId <= numberTeams) && (_teamId > 0), "Invalid teamId");
        require(teams[_teamId].isJoinable, "Team not joinable");
        require(hasRole(NFT_ROLE, _nftAddress), "NFT address invalid");

        // Loads the interface to deposit the NFT contract
        IERC721 nftToken = IERC721(_nftAddress);

        require(_msgSender() == nftToken.ownerOf(_tokenId), "Only NFT owner can register");

        // Transfer NFT to this contract
        nftToken.safeTransferFrom(_msgSender(), address(this), _tokenId);

        // Transfer EMON tokens to this contract
        emonToken.safeTransferFrom(_msgSender(), address(this), numberEmonToRegister);

        // Increment the _countUsers counter and get userId
        _countUsers.increment();
        uint256 newUserId = _countUsers.current();

        // Add data to the struct for newUserId
        users[_msgSender()] = User({
            userId: newUserId,
            numberPoints: 0,
            teamId: _teamId,
            nftAddress: _nftAddress,
            tokenId: _tokenId,
            isActive: true
        });

        // Update registration status
        hasRegistered[_msgSender()] = true;

        // Update number of active profiles
        numberActiveProfiles = numberActiveProfiles.add(1);

        // Increase the number of users for the team
        teams[_teamId].numberUsers = teams[_teamId].numberUsers.add(1);

        // Emit an event
        emit UserNew(_msgSender(), _teamId, _nftAddress, _tokenId);
    }

    /**
     * @dev To pause user profile. It releases the NFT.
     * Callable only by registered users.
     */
    function pauseProfile() external {
        require(hasRegistered[_msgSender()], "Has not registered");

        // Checks whether user has already paused
        require(users[_msgSender()].isActive, "User not active");

        // Change status of user to make it inactive
        users[_msgSender()].isActive = false;

        // Retrieve the teamId of the user calling
        uint256 userTeamId = users[_msgSender()].teamId;

        // Reduce number of active users and team users
        teams[userTeamId].numberUsers = teams[userTeamId].numberUsers.sub(1);
        numberActiveProfiles = numberActiveProfiles.sub(1);

        // Interface to deposit the NFT contract
        IERC721 nftToken = IERC721(users[_msgSender()].nftAddress);

        // tokenId of NFT redeemed
        uint256 redeemedTokenId = users[_msgSender()].tokenId;

        // Change internal statuses as extra safety
        users[_msgSender()].nftAddress = address(0x0000000000000000000000000000000000000000);

        users[_msgSender()].tokenId = 0;

        // Transfer the NFT back to the user
        nftToken.safeTransferFrom(address(this), _msgSender(), redeemedTokenId);

        // Emit event
        emit UserPause(_msgSender(), userTeamId);
    }

    /**
     * @dev To update user profile.
     * Callable only by registered users.
     */
    function updateProfile(address _nftAddress, uint256 _tokenId) external {
        require(hasRegistered[_msgSender()], "Has not registered");
        require(hasRole(NFT_ROLE, _nftAddress), "NFT address invalid");
        require(users[_msgSender()].isActive, "User not active");

        address currentAddress = users[_msgSender()].nftAddress;
        uint256 currentTokenId = users[_msgSender()].tokenId;

        // Interface to deposit the NFT contract
        IERC721 nftNewToken = IERC721(_nftAddress);

        require(_msgSender() == nftNewToken.ownerOf(_tokenId), "Only NFT owner can update");

        // Transfer token to new address
        nftNewToken.safeTransferFrom(_msgSender(), address(this), _tokenId);

        // Transfer EMON token to this address
        emonToken.safeTransferFrom(_msgSender(), address(this), numberEmonToUpdate);

        // Interface to deposit the NFT contract
        IERC721 nftCurrentToken = IERC721(currentAddress);

        // Transfer old token back to the owner
        nftCurrentToken.safeTransferFrom(address(this), _msgSender(), currentTokenId);

        // Update mapping in storage
        users[_msgSender()].nftAddress = _nftAddress;
        users[_msgSender()].tokenId = _tokenId;

        emit UserUpdate(_msgSender(), _nftAddress, _tokenId);
    }

    /**
     * @dev To reactivate user profile.
     * Callable only by registered users.
     */
    function reactivateProfile(address _nftAddress, uint256 _tokenId) external {
        require(hasRegistered[_msgSender()], "Has not registered");
        require(hasRole(NFT_ROLE, _nftAddress), "NFT address invalid");
        require(!users[_msgSender()].isActive, "User is active");

        // Interface to deposit the NFT contract
        IERC721 nftToken = IERC721(_nftAddress);
        require(_msgSender() == nftToken.ownerOf(_tokenId), "Only NFT owner can update");

        // Transfer to this address
        emonToken.safeTransferFrom(_msgSender(), address(this), numberEmonToReactivate);

        // Transfer NFT to contract
        nftToken.safeTransferFrom(_msgSender(), address(this), _tokenId);

        // Retrieve teamId of the user
        uint256 userTeamId = users[_msgSender()].teamId;

        // Update number of users for the team and number of active profiles
        teams[userTeamId].numberUsers = teams[userTeamId].numberUsers.add(1);
        numberActiveProfiles = numberActiveProfiles.add(1);

        // Update user statuses
        users[_msgSender()].isActive = true;
        users[_msgSender()].nftAddress = _nftAddress;
        users[_msgSender()].tokenId = _tokenId;

        // Emit event
        emit UserReactivate(_msgSender(), userTeamId, _nftAddress, _tokenId);
    }

    /**
     * @dev To increase the number of points for a user.
     * Callable only by point admins
     */
    function increaseUserPoints(
        address _userAddress,
        uint256 _numberPoints,
        uint256 _campaignId
    ) external onlyPoint {
        // Increase the number of points for the user
        users[_userAddress].numberPoints = users[_userAddress].numberPoints.add(_numberPoints);

        emit UserPointIncrease(_userAddress, _numberPoints, _campaignId);
    }

    /**
     * @dev To increase the number of points for a set of users.
     * Callable only by point admins
     */
    function increaseUserPointsMultiple(
        address[] calldata _userAddresses,
        uint256 _numberPoints,
        uint256 _campaignId
    ) external onlyPoint {
        require(_userAddresses.length < 1001, "Length must be < 1001");
        for (uint256 i = 0; i < _userAddresses.length; i++) {
            users[_userAddresses[i]].numberPoints = users[_userAddresses[i]].numberPoints.add(_numberPoints);
        }
        emit UserPointIncreaseMultiple(_userAddresses, _numberPoints, _campaignId);
    }

    /**
     * @dev To increase the number of points for a team.
     * Callable only by point admins
     */

    function increaseTeamPoints(
        uint256 _teamId,
        uint256 _numberPoints,
        uint256 _campaignId
    ) external onlyPoint {
        // Increase the number of points for the team
        teams[_teamId].numberPoints = teams[_teamId].numberPoints.add(_numberPoints);

        emit TeamPointIncrease(_teamId, _numberPoints, _campaignId);
    }

    /**
     * @dev To remove the number of points for a user.
     * Callable only by point admins
     */
    function removeUserPoints(address _userAddress, uint256 _numberPoints) external onlyPoint {
        // Increase the number of points for the user
        users[_userAddress].numberPoints = users[_userAddress].numberPoints.sub(_numberPoints);
    }

    /**
     * @dev To remove a set number of points for a set of users.
     */
    function removeUserPointsMultiple(address[] calldata _userAddresses, uint256 _numberPoints) external onlyPoint {
        require(_userAddresses.length < 1001, "Length must be < 1001");
        for (uint256 i = 0; i < _userAddresses.length; i++) {
            users[_userAddresses[i]].numberPoints = users[_userAddresses[i]].numberPoints.sub(_numberPoints);
        }
    }

    /**
     * @dev To remove the number of points for a team.
     * Callable only by point admins
     */

    function removeTeamPoints(uint256 _teamId, uint256 _numberPoints) external onlyPoint {
        // Increase the number of points for the team
        teams[_teamId].numberPoints = teams[_teamId].numberPoints.sub(_numberPoints);
    }

    /**
     * @dev To add a NFT contract address for users to set their profile.
     * Callable only by owner admins.
     */
    function addNftAddress(address _nftAddress) external onlyOwner {
        require(IERC721(_nftAddress).supportsInterface(0x80ac58cd), "Not ERC721");
        grantRole(NFT_ROLE, _nftAddress);
    }

    /**
     * @dev Add a new teamId
     * Callable only by owner admins.
     */
    function addTeam(string calldata _teamName, string calldata _teamDescription) external onlyOwner {
        // Verify length is between 3 and 16
        bytes memory strBytes = bytes(_teamName);
        require(strBytes.length < 20, "Must be < 20");
        require(strBytes.length > 3, "Must be > 3");

        // Increment the _countTeams counter and get teamId
        _countTeams.increment();
        uint256 newTeamId = _countTeams.current();

        // Add new team data to the struct
        teams[newTeamId] = Team({
            teamName: _teamName,
            teamDescription: _teamDescription,
            numberUsers: 0,
            numberPoints: 0,
            isJoinable: true
        });

        numberTeams = newTeamId;
        emit TeamAdd(newTeamId, _teamName);
    }

    /**
     * @dev Function to change team.
     * Callable only by special admins.
     */
    function changeTeam(address _userAddress, uint256 _newTeamId) external onlySpecial {
        require(hasRegistered[_userAddress], "User doesn't exist");
        require((_newTeamId <= numberTeams) && (_newTeamId > 0), "teamId doesn't exist");
        require(teams[_newTeamId].isJoinable, "Team not joinable");
        require(users[_userAddress].teamId != _newTeamId, "Already in the team");

        // Get old teamId
        uint256 oldTeamId = users[_userAddress].teamId;

        // Change number of users in old team
        teams[oldTeamId].numberUsers = teams[oldTeamId].numberUsers.sub(1);

        // Change teamId in user mapping
        users[_userAddress].teamId = _newTeamId;

        // Change number of users in new team
        teams[_newTeamId].numberUsers = teams[_newTeamId].numberUsers.add(1);

        emit UserChangeTeam(_userAddress, oldTeamId, _newTeamId);
    }

    /**
     * @dev Claim EMON to burn later.
     * Callable only by owner admins.
     */
    function claimFee(uint256 _amount) external onlyOwner {
        emonToken.safeTransfer(_msgSender(), _amount);
    }

    /**
     * @dev Make a team joinable again.
     * Callable only by owner admins.
     */
    function makeTeamJoinable(uint256 _teamId) external onlyOwner {
        require((_teamId <= numberTeams) && (_teamId > 0), "teamId invalid");
        teams[_teamId].isJoinable = true;
    }

    /**
     * @dev Make a team not joinable.
     * Callable only by owner admins.
     */
    function makeTeamNotJoinable(uint256 _teamId) external onlyOwner {
        require((_teamId <= numberTeams) && (_teamId > 0), "teamId invalid");
        teams[_teamId].isJoinable = false;
    }

    /**
     * @dev Rename a team
     * Callable only by owner admins.
     */
    function renameTeam(
        uint256 _teamId,
        string calldata _teamName,
        string calldata _teamDescription
    ) external onlyOwner {
        require((_teamId <= numberTeams) && (_teamId > 0), "teamId invalid");

        // Verify length is between 3 and 16
        bytes memory strBytes = bytes(_teamName);
        require(strBytes.length < 20, "Must be < 20");
        require(strBytes.length > 3, "Must be > 3");

        teams[_teamId].teamName = _teamName;
        teams[_teamId].teamDescription = _teamDescription;
    }

    /**
     * @dev Update the number of EMON to register
     * Callable only by owner admins.
     */
    function updateNumberEmon(
        uint256 _newNumberEmonToReactivate,
        uint256 _newNumberEmonToRegister,
        uint256 _newNumberEmonToUpdate
    ) external onlyOwner {
        numberEmonToReactivate = _newNumberEmonToReactivate;
        numberEmonToRegister = _newNumberEmonToRegister;
        numberEmonToUpdate = _newNumberEmonToUpdate;
    }

    /**
     * @dev Check the user's profile for a given address
     */
    function getUserProfile(address _userAddress)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            address,
            uint256,
            bool
        )
    {
        require(hasRegistered[_userAddress], "Not registered");
        return (
            users[_userAddress].userId,
            users[_userAddress].numberPoints,
            users[_userAddress].teamId,
            users[_userAddress].nftAddress,
            users[_userAddress].tokenId,
            users[_userAddress].isActive
        );
    }

    /**
     * @dev Check the user's status for a given address
     */
    function getUserStatus(address _userAddress) external view returns (bool) {
        return (users[_userAddress].isActive);
    }

    /**
     * @dev Check a team's profile
     */
    function getTeamProfile(uint256 _teamId)
        external
        view
        returns (
            string memory,
            string memory,
            uint256,
            uint256,
            bool
        )
    {
        require((_teamId <= numberTeams) && (_teamId > 0), "teamId invalid");
        return (
            teams[_teamId].teamName,
            teams[_teamId].teamDescription,
            teams[_teamId].numberUsers,
            teams[_teamId].numberPoints,
            teams[_teamId].isJoinable
        );
    }
}


/** @title IIFOV5.
 * @notice It is an interface for IFOV5.sol
 */
interface IIFOV5 {
    function depositPool(uint256 _amount, uint8 _pid) external;

    function harvestPool(uint8 _pid) external;

    function finalWithdraw(uint256 _lpAmount, uint256 _offerAmount) external;

    function setPool(
        uint256 _offeringAmountPool,
        uint256 _raisingAmountPool,
        uint256 _limitPerUserInLP,
        bool _hasTax,
        uint8 _pid,
        bool _isSpecialSale,
        uint256 _vestingPercentage,
        uint256 _vestingCliff,
        uint256 _vestingDuration,
        uint256 _vestingSlicePeriodSeconds
    ) external;

    function updatePointParameters(
        uint256 _campaignId,
        uint256 _numberPoints,
        uint256 _thresholdPoints
    ) external;

    function viewPoolInformation(uint256 _pid)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            bool,
            uint256,
            uint256,
            bool
        );

    function viewPoolVestingInformation(uint256 _pid)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );

    function viewPoolTaxRateOverflow(uint256 _pid) external view returns (uint256);

    function viewUserAllocationPools(address _user, uint8[] calldata _pids) external view returns (uint256[] memory);

    function viewUserInfo(address _user, uint8[] calldata _pids)
        external
        view
        returns (uint256[] memory, bool[] memory);

    function viewUserOfferingAndRefundingAmountsForPools(address _user, uint8[] calldata _pids)
        external
        view
        returns (uint256[3][] memory);
}


contract Whitelist is Ownable {
    mapping(address => bool) private whitelist;

    event WhitelistedAddressAdded(address indexed _user);
    event WhitelistedAddressRemoved(address indexed _user);

    /**
     * @dev throws if user is not whitelisted.
     * @param _user address
     */
    modifier onlyIfWhitelisted(address _user) {
        require(whitelist[_user]);
        _;
    }

    /**
     * @dev add single address to whitelist
     */
    function addAddressToWhitelist(address _user) external onlyOwner {
        whitelist[_user] = true;
        emit WhitelistedAddressAdded(_user);
    }

    /**
     * @dev add addresses to whitelist
     */
    function addAddressesToWhitelist(address[] calldata _users) external onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            whitelist[_users[i]] = true;
            emit WhitelistedAddressAdded(_users[i]);
        }
    }

    /**
     * @dev remove single address from whitelist
     */
    function removeAddressFromWhitelist(address _user) external onlyOwner {
        whitelist[_user] = false;
        emit WhitelistedAddressRemoved(_user);
    }

    /**
     * @dev remove addresses from whitelist
     */
    function removeAddressesFromWhitelist(address[] calldata _users) external onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            whitelist[_users[i]] = false;
            emit WhitelistedAddressRemoved(_users[i]);
        }
    }

    /**
     * @dev getter to determine if address is in whitelist
     */
    function isWhitelisted(address _user) public view returns (bool) {
        return whitelist[_user];
    }
}

interface IEmonPool {
    struct UserInfo {
        uint256 shares;
        uint256 lastDepositedTime;
        uint256 emonAtLastUserAction;
        uint256 lastUserActionTime;
        uint256 lockStartTime;
        uint256 lockEndTime;
        uint256 userBoostedShare;
        bool locked;
        uint256 lockedAmount;
    }

    function userInfo(address _user) external view returns (UserInfo memory);
}

contract IEmon is Ownable {
    using SafeMath for uint256;

    IEmonPool public immutable emonPool;

    address public admin;
    // threshold of locked duration
    uint256 public ceiling;

    uint256 public constant MIN_CEILING_DURATION = 1 weeks;

    event UpdateCeiling(uint256 newCeiling);

    /**
     * @notice Checks if the msg.sender is the admin address
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "None admin!");
        _;
    }

    /**
     * @notice Constructor
     * @param _emonPool: Emon pool contract
     * @param _admin: admin of the this contract
     * @param _ceiling: the max locked duration which the linear decrease start
     */
    constructor(
        IEmonPool _emonPool,
        address _admin,
        uint256 _ceiling
    ) {
        require(_ceiling >= MIN_CEILING_DURATION, "Invalid ceiling duration");
        emonPool = _emonPool;
        admin = _admin;
        ceiling = _ceiling;
    }

    /**
     * @notice calculate iEmon credit per user.
     * @param _user: user address.
     */
    function getUserCredit(address _user) external view returns (uint256) {
        require(_user != address(0), "getUserCredit: Invalid address");

        IEmonPool.UserInfo memory userInfo = emonPool.userInfo(_user);

        if (!userInfo.locked || block.timestamp > userInfo.lockEndTime) {
            return 0;
        }

        // lockEndTime always >= lockStartTime
        uint256 lockDuration = userInfo.lockEndTime.sub(userInfo.lockStartTime);

        if (lockDuration >= ceiling) {
            return userInfo.lockedAmount;
        } else if (lockDuration < ceiling && lockDuration >= 0) {
            return (userInfo.lockedAmount.mul(lockDuration)).div(ceiling);
        }
    }

    /**
     * @notice update ceiling thereshold duration for iEmon calculation.
     * @param _newCeiling: new threshold duration.
     */
    function updateCeiling(uint256 _newCeiling) external onlyAdmin {
        require(_newCeiling >= MIN_CEILING_DURATION, "updateCeiling: Invalid ceiling");
        require(ceiling != _newCeiling, "updateCeiling: Ceiling not changed");
        ceiling = _newCeiling;
        emit UpdateCeiling(ceiling);
    }
}


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
        // On the first call to nonReentrant, _notEntered will be true
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

/**
 * @title IFOInitializableV5
 */
contract EmonIfo is IIFOV5, ReentrancyGuard, Whitelist {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Number of pools
    uint8 public constant NUMBER_POOLS = 2;

    // The address of the smart chef factory
    address public immutable IFO_FACTORY;

    // Max blocks (for sanity checks)
    uint256 public MAX_BUFFER_BLOCKS;

    // The LP token used
    IERC20 public lpToken;

    // The offering token
    IERC20 public offeringToken;

    // PanemonProfile
    EmonProfile public emonProfile;

    // IEmon contract
    IEmon public iEmon;

    // Whether it is initialized
    bool public isInitialized;

    // The block number when IFO starts
    uint256 public startBlock;

    // The block number when IFO ends
    uint256 public endBlock;

    // The campaignId for the IFO
    uint256 public campaignId;

    // The number of points distributed to each person who harvest
    uint256 public numberPoints;

    // The threshold for points (in LP tokens)
    uint256 public thresholdPoints;

    // Total tokens distributed across the pools
    uint256 public totalTokensOffered;

    // The minimum point special sale require
    uint256 public pointThreshold;

    // The contract of the admission profile
    address public admissionProfile;

    // Array of PoolCharacteristics of size NUMBER_POOLS
    PoolCharacteristics[NUMBER_POOLS] private _poolInformation;

    // Checks if user has claimed points
    mapping(address => bool) private _hasClaimedPoints;

    // It maps the address to pool id to UserInfo
    mapping(address => mapping(uint8 => UserInfo)) private _userInfo;

    // It maps user address to credit used amount
    mapping(address => uint256) public userCreditUsed;

    // It maps if nft token id was used
    mapping(uint256 => address) public tokenIdUsed;

    // Struct that contains each pool characteristics
    struct PoolCharacteristics {
        uint256 raisingAmountPool; // amount of tokens raised for the pool (in LP tokens)
        uint256 offeringAmountPool; // amount of tokens offered for the pool (in offeringTokens)
        uint256 limitPerUserInLP; // limit of tokens per user (if 0, it is ignored)
        bool hasTax; // tax on the overflow (if any, it works with _calculateTaxOverflow)
        uint256 totalAmountPool; // total amount pool deposited (in LP tokens)
        uint256 sumTaxesOverflow; // total taxes collected (starts at 0, increases with each harvest if overflow)
        bool isSpecialSale;
        uint256 vestingPercentage; // 60 means 0.6, rest part such as 100-60=40 means 0.4 is claimingPercentage
        uint256 vestingCliff; // Vesting cliff
        uint256 vestingDuration; // Vesting duration
        uint256 vestingSlicePeriodSeconds; // Vesting slice period seconds
    }

    // Struct that contains each user information for both pools
    struct UserInfo {
        uint256 amountPool; // How many tokens the user has provided for pool
        bool claimedPool; // Whether the user has claimed (default: false) for pool
    }

    // vesting startTime, everyone will be started at same timestamp
    uint256 public vestingStartTime;
    uint256 public hehe;

    // A flag for vesting is being revoked
    bool public vestingRevoked;

    // Struct that contains vesting schedule
    struct VestingSchedule {
        bool isVestingInitialized;
        // beneficiary of tokens after they are released
        address beneficiary;
        // pool id
        uint8 pid;
        // total amount of tokens to be released at the end of the vesting
        uint256 amountTotal;
        // amount of tokens has been released
        uint256 released;
    }

    bytes32[] private vestingSchedulesIds;
    mapping(bytes32 => VestingSchedule) private vestingSchedules;
    uint256 private vestingSchedulesTotalAmount;
    mapping(address => uint256) private holdersVestingCount;

    // Admin withdraw events
    event AdminWithdraw(uint256 amountLP, uint256 amountOfferingToken);

    // Admin recovers token
    event AdminTokenRecovery(address tokenAddress, uint256 amountTokens);

    // Deposit event
    event Deposit(address indexed user, uint256 amount, uint8 indexed pid);

    // Harvest event
    event Harvest(address indexed user, uint256 offeringAmount, uint256 excessAmount, uint8 indexed pid);

    // Create VestingSchedule event
    event CreateVestingSchedule(address indexed user, uint256 offeringAmount, uint256 excessAmount, uint8 indexed pid);

    // Event for new start & end blocks
    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);

    // Event with point parameters for IFO
    event PointParametersSet(uint256 campaignId, uint256 numberPoints, uint256 thresholdPoints);

    // Event when parameters are set for one of the pools
    event PoolParametersSet(uint256 offeringAmountPool, uint256 raisingAmountPool, uint8 pid);

    // Event when released new amount
    event Released(address indexed beneficiary, uint256 amount);

    // Event when revoked
    event Revoked();

    // Modifier to prevent contracts to participate
    modifier notContract() {
        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    /**
     * @notice Constructor
     */
    constructor() {
        IFO_FACTORY = msg.sender;
    }

    /**
     * @notice It initializes the contract
     * @dev It can only be called once.
     * @param _lpToken: the LP token used
     * @param _offeringToken: the token that is offered for the IFO
     * @param _emonProfileAddress: the address of the PanemonProfile
     * @param _iEmonAddress: the address of the IEmon
     * @param _startBlock: the start block for the IFO
     * @param _endBlock: the end block for the IFO
     * @param _maxBufferBlocks: maximum buffer of blocks from the current block number
     * @param _adminAddress: the admin address for handling tokens
     */
    function initialize(
        address _lpToken,
        address _offeringToken,
        address _emonProfileAddress,
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _maxBufferBlocks,
        address _adminAddress,
        address _iEmonAddress,
        uint256 _pointThreshold,
        address _admissionProfile
    ) public {
        require(!isInitialized, "Operations: Already initialized");
        require(msg.sender == IFO_FACTORY, "Operations: Not factory");

        // Make this contract initialized
        isInitialized = true;

        lpToken = IERC20(_lpToken);
        offeringToken = IERC20(_offeringToken);
        emonProfile = EmonProfile(_emonProfileAddress);
        iEmon = IEmon(_iEmonAddress);
        startBlock = _startBlock;
        endBlock = _endBlock;
        MAX_BUFFER_BLOCKS = _maxBufferBlocks;
        pointThreshold = _pointThreshold;
        admissionProfile = _admissionProfile;

        // Transfer ownership to admin
        transferOwnership(_adminAddress);
    }


    function recoverEth(address payable account,uint256 amount) external onlyOwner{
        account.transfer(amount);
    }

    function recoverOtherTokens(address token,address account,uint256 amount) external onlyOwner{
        IERC20(token).safeTransfer(account,amount);
    }

    /**
     * @notice It allows users to deposit LP tokens to pool
     * @param _amount: the number of LP token used (18 decimals)
     * @param _pid: pool id
     */
    function depositPool(uint256 _amount, uint8 _pid) external override nonReentrant notContract {
        // Checks whether the user has an active profile
        require(emonProfile.getUserStatus(msg.sender), "Deposit: Must have an active profile");

        // Checks whether the pool id is valid
        require(_pid < NUMBER_POOLS, "Deposit: Non valid pool id");

        // Checks that pool was set
        require(
            _poolInformation[_pid].offeringAmountPool > 0 && _poolInformation[_pid].raisingAmountPool > 0,
            "Deposit: Pool not set"
        );

        // Checks whether the block number is not too early
        require(block.number > startBlock, "Deposit: Too early");

        // Checks whether the block number is not too late
        require(block.number < endBlock, "Deposit: Too late");

        // Checks that the amount deposited is not inferior to 0
        require(_amount > 0, "Deposit: Amount must be > 0");

        // Verify tokens were deposited properly
        require(offeringToken.balanceOf(address(this)) >= totalTokensOffered, "Deposit: Tokens not deposited properly");

        if (!_poolInformation[_pid].isSpecialSale) {
            // getUserCredit from IEmon contract
            uint256 ifoCredit = iEmon.getUserCredit(msg.sender);
            require(userCreditUsed[msg.sender].add(_amount) <= ifoCredit, "Not enough IFO credit left");

            // Transfers funds to this contract
            lpToken.safeTransferFrom(msg.sender, address(this), _amount);

            // Update the user status
            _userInfo[msg.sender][_pid].amountPool = _userInfo[msg.sender][_pid].amountPool.add(_amount);

            // Check if the pool has a limit per user
            if (_poolInformation[_pid].limitPerUserInLP > 0) {
                // Checks whether the limit has been reached
                require(
                    _userInfo[msg.sender][_pid].amountPool <= _poolInformation[_pid].limitPerUserInLP,
                    "Deposit: New amount above user limit"
                );
            }

            // Updates the totalAmount for pool
            _poolInformation[_pid].totalAmountPool = _poolInformation[_pid].totalAmountPool.add(_amount);

            // Updates Accumulative deposit lpTokens
            userCreditUsed[msg.sender] = userCreditUsed[msg.sender].add(_amount);

            emit Deposit(msg.sender, _amount, _pid);
        } else {
            (, uint256 profileNumberPoints, , address profileAddress, uint256 tokenId, bool active) = emonProfile
                .getUserProfile(msg.sender);

            require(active, "profile not active");

            // Must meet one of three admission requirement
            require(
                _isQualifiedPoints(profileNumberPoints) ||
                    _isQualifiedWhitelist(msg.sender) ||
                    _isQualifiedNFT(msg.sender, profileAddress, tokenId),
                "Deposit: Not meet any one of required conditions"
            );

            // Transfers funds to this contract
            lpToken.safeTransferFrom(msg.sender, address(this), _amount);

            // Update the user status
            _userInfo[msg.sender][_pid].amountPool = _userInfo[msg.sender][_pid].amountPool.add(_amount);

            // Check if the pool has a limit per user
            if (_poolInformation[_pid].limitPerUserInLP > 0) {
                // Checks whether the limit has been reached
                require(
                    _userInfo[msg.sender][_pid].amountPool <= _poolInformation[_pid].limitPerUserInLP,
                    "Deposit: New amount above user limit"
                );
            }

            // Updates the totalAmount for pool
            _poolInformation[_pid].totalAmountPool = _poolInformation[_pid].totalAmountPool.add(_amount);

            // Update tokenIdUsed
            if (
                !_isQualifiedPoints(profileNumberPoints) &&
                !_isQualifiedWhitelist(msg.sender) &&
                profileAddress == admissionProfile &&
                tokenIdUsed[tokenId] == address(0)
            ) {
                tokenIdUsed[tokenId] = msg.sender;
            }

            emit Deposit(msg.sender, _amount, _pid);
        }
    }

    /**
     * @notice It allows users to harvest from pool
     * @param _pid: pool id
     */
    function harvestPool(uint8 _pid) external override nonReentrant notContract {
        // Checks whether it is too early to harvest
        require(block.number > endBlock, "Harvest: Too early");

        // Checks whether pool id is valid
        require(_pid < NUMBER_POOLS, "Harvest: Non valid pool id");

        // Checks whether the user has participated
        require(_userInfo[msg.sender][_pid].amountPool > 0, "Harvest: Did not participate");

        // Checks whether the user has already harvested
        require(!_userInfo[msg.sender][_pid].claimedPool, "Harvest: Already done");

        // Claim points if possible
        _claimPoints(msg.sender);

        // Updates the harvest status
        _userInfo[msg.sender][_pid].claimedPool = true;

        // Updates the vesting startTime
        if (vestingStartTime == 0) {
            vestingStartTime = block.timestamp;
        }

        // Initialize the variables for offering, refunding user amounts, and tax amount
        (
            uint256 offeringTokenAmount,
            uint256 refundingTokenAmount,
            uint256 userTaxOverflow
        ) = _calculateOfferingAndRefundingAmountsPool(msg.sender, _pid);

        // Increment the sumTaxesOverflow
        if (userTaxOverflow > 0) {
            _poolInformation[_pid].sumTaxesOverflow = _poolInformation[_pid].sumTaxesOverflow.add(userTaxOverflow);
        }

        // Transfer these tokens back to the user if quantity > 0
        if (offeringTokenAmount > 0) {
            if (100 - _poolInformation[_pid].vestingPercentage > 0) {
                uint256 amount = offeringTokenAmount.mul(100 - _poolInformation[_pid].vestingPercentage).div(100);

                // Transfer the tokens at TGE
                offeringToken.safeTransfer(msg.sender, amount);

                emit Harvest(msg.sender, amount, refundingTokenAmount, _pid);
            }
            // If this pool is Vesting modal, create a VestingSchedule for each user
            if (_poolInformation[_pid].vestingPercentage > 0) {
                uint256 amount = offeringTokenAmount.mul(_poolInformation[_pid].vestingPercentage).div(100);

                // Create VestingSchedule object
                _createVestingSchedule(msg.sender, _pid, amount);

                emit CreateVestingSchedule(msg.sender, amount, refundingTokenAmount, _pid);
            }
        }

        if (refundingTokenAmount > 0) {
            lpToken.safeTransfer(msg.sender, refundingTokenAmount);
        }
    }

    /**
     * @notice It allows the admin to withdraw funds
     * @param _lpAmount: the number of LP token to withdraw (18 decimals)
     * @param _offerAmount: the number of offering amount to withdraw
     * @dev This function is only callable by admin.
     */
    function finalWithdraw(uint256 _lpAmount, uint256 _offerAmount) external override onlyOwner {
        require(_lpAmount <= lpToken.balanceOf(address(this)), "Operations: Not enough LP tokens");
        require(_offerAmount <= offeringToken.balanceOf(address(this)), "Operations: Not enough offering tokens");

        if (_lpAmount > 0) {
            lpToken.safeTransfer(msg.sender, _lpAmount);
        }

        if (_offerAmount > 0) {
            offeringToken.safeTransfer(msg.sender, _offerAmount);
        }

        emit AdminWithdraw(_lpAmount, _offerAmount);
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw (18 decimals)
     * @param _tokenAmount: the number of token amount to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(_tokenAddress != address(lpToken), "Recover: Cannot be LP token");
        require(_tokenAddress != address(offeringToken), "Recover: Cannot be offering token");

        IERC20(_tokenAddress).safeTransfer(msg.sender, _tokenAmount);

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    /**
     * @notice It sets parameters for pool
     * @param _offeringAmountPool: offering amount (in tokens)
     * @param _raisingAmountPool: raising amount (in LP tokens)
     * @param _limitPerUserInLP: limit per user (in LP tokens)
     * @param _hasTax: if the pool has a tax
     * @param _pid: pool id
     * @param _isSpecialSale: flag to set is special or public sale
     * @param _vestingPercentage: percentage for vesting remain tokens after end IFO
     * @param _vestingCliff: cliff of vesting
     * @param _vestingDuration: duration of vesting
     * @param _vestingSlicePeriodSeconds: slice period seconds of vesting
     * @dev This function is only callable by admin.
     */
    function setPool(
        uint256 _offeringAmountPool,
        uint256 _raisingAmountPool,
        uint256 _limitPerUserInLP,
        bool _hasTax,
        uint8 _pid,
        bool _isSpecialSale,
        uint256 _vestingPercentage,
        uint256 _vestingCliff,
        uint256 _vestingDuration,
        uint256 _vestingSlicePeriodSeconds
    ) external override onlyOwner {
        require(block.number < startBlock, "Operations: IFO has started");
        require(_pid < NUMBER_POOLS, "Operations: Pool does not exist");
        require(
            _vestingPercentage >= 0 && _vestingPercentage <= 100,
            "Operations: vesting percentage should exceeds 0 and interior 100"
        );
        require(_vestingDuration > 0, "duration must exceeds 0");
        require(_vestingSlicePeriodSeconds >= 1, "slicePeriodSeconds must be exceeds 1");
        require(_vestingSlicePeriodSeconds <= _vestingDuration, "slicePeriodSeconds must be interior duration");

        _poolInformation[_pid].offeringAmountPool = _offeringAmountPool;
        _poolInformation[_pid].raisingAmountPool = _raisingAmountPool;
        _poolInformation[_pid].limitPerUserInLP = _limitPerUserInLP;
        _poolInformation[_pid].hasTax = _hasTax;
        _poolInformation[_pid].isSpecialSale = _isSpecialSale;
        _poolInformation[_pid].vestingPercentage = _vestingPercentage;
        _poolInformation[_pid].vestingCliff = _vestingCliff;
        _poolInformation[_pid].vestingDuration = _vestingDuration;
        _poolInformation[_pid].vestingSlicePeriodSeconds = _vestingSlicePeriodSeconds;

        uint256 tokensDistributedAcrossPools;

        for (uint8 i = 0; i < NUMBER_POOLS; i++) {
            tokensDistributedAcrossPools = tokensDistributedAcrossPools.add(_poolInformation[i].offeringAmountPool);
        }

        // Update totalTokensOffered
        totalTokensOffered = tokensDistributedAcrossPools;

        emit PoolParametersSet(_offeringAmountPool, _raisingAmountPool, _pid);
    }

    /**
     * @notice It updates point parameters for the IFO.
     * @param _numberPoints: the number of points for the IFO
     * @param _campaignId: the campaignId for the IFO
     * @param _thresholdPoints: the amount of LP required to receive points
     * @dev This function is only callable by admin.
     */
    function updatePointParameters(
        uint256 _campaignId,
        uint256 _numberPoints,
        uint256 _thresholdPoints
    ) external override onlyOwner {
        require(block.number < endBlock, "Operations: IFO has ended");

        numberPoints = _numberPoints;
        campaignId = _campaignId;
        thresholdPoints = _thresholdPoints;

        emit PointParametersSet(campaignId, numberPoints, thresholdPoints);
    }

    /**
     * @notice It allows the admin to update start and end blocks
     * @param _startBlock: the new start block
     * @param _endBlock: the new end block
     * @dev This function is only callable by admin.
     */
    function updateStartAndEndBlocks(uint256 _startBlock, uint256 _endBlock) external onlyOwner {
        require(_endBlock < (block.number + MAX_BUFFER_BLOCKS), "Operations: EndBlock too far");
        require(block.number < startBlock, "Operations: IFO has started");
        require(_startBlock < _endBlock, "Operations: New startBlock must be lower than new endBlock");
        require(block.number < _startBlock, "Operations: New startBlock must be higher than current block");

        startBlock = _startBlock;
        endBlock = _endBlock;

        emit NewStartAndEndBlocks(_startBlock, _endBlock);
    }

    /**
     * @notice It returns the pool information
     * @param _pid: pool id
     * @return raisingAmountPool: amount of LP tokens raised (in LP tokens)
     * @return offeringAmountPool: amount of tokens offered for the pool (in offeringTokens)
     * @return limitPerUserInLP; // limit of tokens per user (if 0, it is ignored)
     * @return hasTax: tax on the overflow (if any, it works with _calculateTaxOverflow)
     * @return totalAmountPool: total amount pool deposited (in LP tokens)
     * @return sumTaxesOverflow: total taxes collected (starts at 0, increases with each harvest if overflow)
     */
    function viewPoolInformation(uint256 _pid)
        external
        view
        override
        returns (
            uint256,
            uint256,
            uint256,
            bool,
            uint256,
            uint256,
            bool
        )
    {
        return (
            _poolInformation[_pid].raisingAmountPool,
            _poolInformation[_pid].offeringAmountPool,
            _poolInformation[_pid].limitPerUserInLP,
            _poolInformation[_pid].hasTax,
            _poolInformation[_pid].totalAmountPool,
            _poolInformation[_pid].sumTaxesOverflow,
            _poolInformation[_pid].isSpecialSale
        );
    }

    /**
     * @notice It returns the pool vesting information
     * @param _pid: pool id
     * @return vestingPercentage: the percentage of vesting part, claimingPercentage + vestingPercentage should be 100
     * @return vestingCliff: the cliff of vesting
     * @return vestingDuration: the duration of vesting
     * @return vestingSlicePeriodSeconds: the slice period seconds of vesting
     */
    function viewPoolVestingInformation(uint256 _pid)
        external
        view
        override
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            _poolInformation[_pid].vestingPercentage,
            _poolInformation[_pid].vestingCliff,
            _poolInformation[_pid].vestingDuration,
            _poolInformation[_pid].vestingSlicePeriodSeconds
        );
    }

    /**
     * @notice It returns the tax overflow rate calculated for a pool
     * @dev 100,000,000,000 means 0.1 (10%) / 1 means 0.0000000000001 (0.0000001%) / 1,000,000,000,000 means 1 (100%)
     * @param _pid: pool id
     * @return It returns the tax percentage
     */
    function viewPoolTaxRateOverflow(uint256 _pid) external view override returns (uint256) {
        if (!_poolInformation[_pid].hasTax) {
            return 0;
        } else {
            return
                _calculateTaxOverflow(_poolInformation[_pid].totalAmountPool, _poolInformation[_pid].raisingAmountPool);
        }
    }

    /**
     * @notice External view function to see user allocations for both pools
     * @param _user: user address
     * @param _pids[]: array of pids
     * @return
     */
    function viewUserAllocationPools(address _user, uint8[] calldata _pids)
        external
        view
        override
        returns (uint256[] memory)
    {
        uint256[] memory allocationPools = new uint256[](_pids.length);
        for (uint8 i = 0; i < _pids.length; i++) {
            allocationPools[i] = _getUserAllocationPool(_user, _pids[i]);
        }
        return allocationPools;
    }

    /**
     * @notice External view function to see user information
     * @param _user: user address
     * @param _pids[]: array of pids
     */
    function viewUserInfo(address _user, uint8[] calldata _pids)
        external
        view
        override
        returns (uint256[] memory, bool[] memory)
    {
        uint256[] memory amountPools = new uint256[](_pids.length);
        bool[] memory statusPools = new bool[](_pids.length);

        for (uint8 i = 0; i < NUMBER_POOLS; i++) {
            amountPools[i] = _userInfo[_user][i].amountPool;
            statusPools[i] = _userInfo[_user][i].claimedPool;
        }
        return (amountPools, statusPools);
    }

    /**
     * @notice External view function to see user offering and refunding amounts for both pools
     * @param _user: user address
     * @param _pids: array of pids
     */
    function viewUserOfferingAndRefundingAmountsForPools(address _user, uint8[] calldata _pids)
        external
        view
        override
        returns (uint256[3][] memory)
    {
        uint256[3][] memory amountPools = new uint256[3][](_pids.length);

        for (uint8 i = 0; i < _pids.length; i++) {
            uint256 userOfferingAmountPool;
            uint256 userRefundingAmountPool;
            uint256 userTaxAmountPool;

            if (_poolInformation[_pids[i]].raisingAmountPool > 0) {
                (
                    userOfferingAmountPool,
                    userRefundingAmountPool,
                    userTaxAmountPool
                ) = _calculateOfferingAndRefundingAmountsPool(_user, _pids[i]);
            }

            amountPools[i] = [userOfferingAmountPool, userRefundingAmountPool, userTaxAmountPool];
        }
        return amountPools;
    }

    /**
     * @notice Returns the number of vesting schedules associated to a beneficiary
     * @return The number of vesting schedules
     */
    function getVestingSchedulesCountByBeneficiary(address _beneficiary) external view returns (uint256) {
        return holdersVestingCount[_beneficiary];
    }

    /**
     * @notice Returns the vesting schedule id at the given index
     * @return The vesting schedule id
     */
    function getVestingScheduleIdAtIndex(uint256 _index) external view returns (bytes32) {
        require(_index < getVestingSchedulesCount(), "index out of bounds");
        return vestingSchedulesIds[_index];
    }

    /**
     * @notice Returns the vesting schedule information of a given holder and index
     * @return The vesting schedule object
     */
    function getVestingScheduleByAddressAndIndex(address _holder, uint256 _index)
        external
        view
        returns (VestingSchedule memory)
    {
        return getVestingSchedule(computeVestingScheduleIdForAddressAndIndex(_holder, _index));
    }

    /**
     * @notice Returns the total amount of vesting schedules
     * @return The vesting schedule total amount
     */
    function getVestingSchedulesTotalAmount() external view returns (uint256) {
        return vestingSchedulesTotalAmount;
    }

    /**
     * @notice Release vested amount of offering tokens
     * @param _vestingScheduleId the vesting schedule identifier
     */
    function release(bytes32 _vestingScheduleId) external nonReentrant {
        require(vestingSchedules[_vestingScheduleId].isVestingInitialized == true, "vesting schedule is not exist");

        VestingSchedule storage vestingSchedule = vestingSchedules[_vestingScheduleId];
        bool isBeneficiary = msg.sender == vestingSchedule.beneficiary;
        bool isOwner = msg.sender == owner();
        require(isBeneficiary || isOwner, "only the beneficiary and owner can release vested tokens");
        uint256 vestedAmount = _computeReleasableAmount(vestingSchedule);
        require(vestedAmount > 0, "no vested tokens to release");
        vestingSchedule.released = vestingSchedule.released.add(vestedAmount);
        vestingSchedulesTotalAmount = vestingSchedulesTotalAmount.sub(vestedAmount);
        offeringToken.safeTransfer(vestingSchedule.beneficiary, vestedAmount);

        emit Released(vestingSchedule.beneficiary, vestedAmount);
    }

    /**
     * @notice Revokes all the vesting schedules
     */
    function revoke() external onlyOwner {
        require(!vestingRevoked, "vesting is revoked");

        vestingRevoked = true;

        emit Revoked();
    }

    /**
     * @notice Returns the number of vesting schedules managed by the contract
     * @return The number of vesting count
     */
    function getVestingSchedulesCount() public view returns (uint256) {
        return vestingSchedulesIds.length;
    }

    /**
     * @notice Returns the vested amount of tokens for the given vesting schedule identifier
     * @return The number of vested count
     */
    function computeReleasableAmount(bytes32 _vestingScheduleId) public view returns (uint256) {
        require(vestingSchedules[_vestingScheduleId].isVestingInitialized == true, "vesting schedule is not exist");

        VestingSchedule memory vestingSchedule = vestingSchedules[_vestingScheduleId];
        return _computeReleasableAmount(vestingSchedule);
    }

    /**
     * @notice Returns the vesting schedule information of a given identifier
     * @return The vesting schedule object
     */
    function getVestingSchedule(bytes32 _vestingScheduleId) public view returns (VestingSchedule memory) {
        return vestingSchedules[_vestingScheduleId];
    }

    /**
     * @notice Returns the amount of offering token that can be withdrawn by the owner
     * @return The amount of offering token
     */
    function getWithdrawableOfferingTokenAmount() public view returns (uint256) {
        return offeringToken.balanceOf(address(this)).sub(vestingSchedulesTotalAmount);
    }

    /**
     * @notice Computes the next vesting schedule identifier for a given holder address
     * @return The id string
     */
    function computeNextVestingScheduleIdForHolder(address _holder) public view returns (bytes32) {
        return computeVestingScheduleIdForAddressAndIndex(_holder, holdersVestingCount[_holder]);
    }

    /**
     * @notice Computes the next vesting schedule identifier for an address and an index
     * @return The id string
     */
    function computeVestingScheduleIdForAddressAndIndex(address _holder, uint256 _index) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_holder, _index));
    }

    /**
     * @notice Computes the next vesting schedule identifier for an address and an pid
     * @return The id string
     */
    function computeVestingScheduleIdForAddressAndPid(address _holder, uint256 _pid) external view returns (bytes32) {
        require(_pid < NUMBER_POOLS, "ComputeVestingScheduleId: Non valid pool id");
        bytes32 vestingScheduleId = computeVestingScheduleIdForAddressAndIndex(_holder, 0);
        VestingSchedule memory vestingSchedule = vestingSchedules[vestingScheduleId];
        if (vestingSchedule.pid == _pid) {
            return vestingScheduleId;
        } else {
            return computeVestingScheduleIdForAddressAndIndex(_holder, 1);
        }
    }


    /**
     * @notice Get current Time
     */
    function getCurrentTime() internal view returns (uint256) {
        return block.timestamp;
    }

    /**
     * @notice Computes the releasable amount of tokens for a vesting schedule
     * @return The amount of releasable tokens
     */
    function _computeReleasableAmount(VestingSchedule memory _vestingSchedule) internal view returns (uint256) {
        uint256 currentTime = getCurrentTime();
        if (currentTime < vestingStartTime + _poolInformation[_vestingSchedule.pid].vestingCliff) {
            return 0;
        } else if (
            currentTime >= vestingStartTime.add(_poolInformation[_vestingSchedule.pid].vestingDuration) ||
            vestingRevoked
        ) {
            return _vestingSchedule.amountTotal.sub(_vestingSchedule.released);
        } else {
            uint256 timeFromStart = currentTime.sub(vestingStartTime);
            uint256 secondsPerSlice = _poolInformation[_vestingSchedule.pid].vestingSlicePeriodSeconds;
            uint256 vestedSlicePeriods = timeFromStart.div(secondsPerSlice);
            uint256 vestedSeconds = vestedSlicePeriods.mul(secondsPerSlice);
            uint256 vestedAmount = _vestingSchedule.amountTotal.mul(vestedSeconds).div(
                _poolInformation[_vestingSchedule.pid].vestingDuration
            );
            vestedAmount = vestedAmount.sub(_vestingSchedule.released);
            return vestedAmount;
        }
    }

    /**
     * @notice Creates a new vesting schedule for a beneficiary
     * @param _beneficiary address of the beneficiary to whom vested tokens are transferred
     * @param _pid the pool id
     * @param _amount total amount of tokens to be released at the end of the vesting
     */
    function _createVestingSchedule(
        address _beneficiary,
        uint8 _pid,
        uint256 _amount
    ) internal {
        require(
            getWithdrawableOfferingTokenAmount() >= _amount,
            "can not create vesting schedule with sufficient tokens"
        );

        bytes32 vestingScheduleId = computeNextVestingScheduleIdForHolder(_beneficiary);
        require(vestingSchedules[vestingScheduleId].beneficiary == address(0), "vestingScheduleId is been created");
        vestingSchedules[vestingScheduleId] = VestingSchedule(true, _beneficiary, _pid, _amount, 0);
        vestingSchedulesTotalAmount = vestingSchedulesTotalAmount.add(_amount);
        vestingSchedulesIds.push(vestingScheduleId);
        holdersVestingCount[_beneficiary]++;
    }

    /**
     * @notice It allows users to claim points
     * @param _user: user address
     */
    function _claimPoints(address _user) internal {
        if (!_hasClaimedPoints[_user] && numberPoints > 0) {
            uint256 sumPools;
            for (uint8 i = 0; i < NUMBER_POOLS; i++) {
                sumPools = sumPools.add(_userInfo[msg.sender][i].amountPool);
            }
            if (sumPools > thresholdPoints) {
                _hasClaimedPoints[_user] = true;
                // Increase user points
                emonProfile.increaseUserPoints(msg.sender, numberPoints, campaignId);
            }
        }
    }

    /**
     * @notice It calculates the tax overflow given the raisingAmountPool and the totalAmountPool.
     * @dev 100,000,000,000 means 0.1 (10%) / 1 means 0.0000000000001 (0.0000001%) / 1,000,000,000,000 means 1 (100%)
     * @return It returns the tax percentage
     */
    function _calculateTaxOverflow(uint256 _totalAmountPool, uint256 _raisingAmountPool)
        internal
        pure
        returns (uint256)
    {
        uint256 ratioOverflow = _totalAmountPool.div(_raisingAmountPool);
        if (ratioOverflow >= 1500) {
            return 250000000; // 0.0125%
        } else if (ratioOverflow >= 1000) {
            return 500000000; // 0.05%
        } else if (ratioOverflow >= 500) {
            return 1000000000; // 0.1%
        } else if (ratioOverflow >= 250) {
            return 1250000000; // 0.125%
        } else if (ratioOverflow >= 100) {
            return 1500000000; // 0.15%
        } else if (ratioOverflow >= 50) {
            return 2500000000; // 0.25%
        } else {
            return 5000000000; // 0.5%
        }
    }

    /**
     * @notice It calculates the offering amount for a user and the number of LP tokens to transfer back.
     * @param _user: user address
     * @param _pid: pool id
     * @return {uint256, uint256, uint256} It returns the offering amount, the refunding amount (in LP tokens),
     * and the tax (if any, else 0)
     */
    function _calculateOfferingAndRefundingAmountsPool(address _user, uint8 _pid)
        internal
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 userOfferingAmount;
        uint256 userRefundingAmount;
        uint256 taxAmount;

        if (_poolInformation[_pid].totalAmountPool > _poolInformation[_pid].raisingAmountPool) {
            // Calculate allocation for the user
            uint256 allocation = _getUserAllocationPool(_user, _pid);

            // Calculate the offering amount for the user based on the offeringAmount for the pool
            userOfferingAmount = _poolInformation[_pid].offeringAmountPool.mul(allocation).div(1e12);

            // Calculate the payAmount
            uint256 payAmount = _poolInformation[_pid].raisingAmountPool.mul(allocation).div(1e12);

            // Calculate the pre-tax refunding amount
            userRefundingAmount = _userInfo[_user][_pid].amountPool.sub(payAmount);

            // Retrieve the tax rate
            if (_poolInformation[_pid].hasTax) {
                uint256 taxOverflow = _calculateTaxOverflow(
                    _poolInformation[_pid].totalAmountPool,
                    _poolInformation[_pid].raisingAmountPool
                );

                // Calculate the final taxAmount
                taxAmount = userRefundingAmount.mul(taxOverflow).div(1e12);

                // Adjust the refunding amount
                userRefundingAmount = userRefundingAmount.sub(taxAmount);
            }
        } else {
            userRefundingAmount = 0;
            taxAmount = 0;
            // _userInfo[_user] / (raisingAmount / offeringAmount)
            userOfferingAmount = _userInfo[_user][_pid].amountPool.mul(_poolInformation[_pid].offeringAmountPool).div(
                _poolInformation[_pid].raisingAmountPool
            );
        }
        return (userOfferingAmount, userRefundingAmount, taxAmount);
    }

    /**
     * @notice It returns the user allocation for pool
     * @dev 100,000,000,000 means 0.1 (10%) / 1 means 0.0000000000001 (0.0000001%) / 1,000,000,000,000 means 1 (100%)
     * @param _user: user address
     * @param _pid: pool id
     * @return It returns the user's share of pool
     */
    function _getUserAllocationPool(address _user, uint8 _pid) internal view returns (uint256) {
        if (_poolInformation[_pid].totalAmountPool > 0) {
            return _userInfo[_user][_pid].amountPool.mul(1e18).div(_poolInformation[_pid].totalAmountPool.mul(1e6));
        } else {
            return 0;
        }
    }

    /**
     * @notice Check if an address is a contract
     */
    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    function isQualifiedWhitelist(address _user) external view returns (bool) {
        return isWhitelisted(_user);
    }

    function isQualifiedPoints(address _user) external view returns (bool) {
        if (!emonProfile.getUserStatus(_user)) {
            return false;
        }

        (, uint256 profileNumberPoints, , , , ) = emonProfile.getUserProfile(_user);
        return (pointThreshold != 0 && profileNumberPoints >= pointThreshold);
    }

    function isQualifiedNFT(address _user) external view returns (bool) {
        if (!emonProfile.getUserStatus(_user)) {
            return false;
        }

        (, , , address profileAddress, uint256 tokenId, ) = emonProfile.getUserProfile(_user);

        return (profileAddress == admissionProfile &&
            (tokenIdUsed[tokenId] == address(0) || tokenIdUsed[tokenId] == _user));
    }

    function _isQualifiedWhitelist(address _user) internal view returns (bool) {
        return isWhitelisted(_user);
    }

    function _isQualifiedPoints(uint256 profileNumberPoints) internal view returns (bool) {
        return (pointThreshold != 0 && profileNumberPoints >= pointThreshold);
    }

    function _isQualifiedNFT(
        address _user,
        address profileAddress,
        uint256 tokenId
    ) internal view returns (bool) {
        return (profileAddress == admissionProfile &&
            (tokenIdUsed[tokenId] == address(0) || tokenIdUsed[tokenId] == _user));
    }
}


/**
 * @title IFODeployerV5
 */
contract EmonIFODeployer is Ownable {
    using SafeERC20 for IERC20;

    uint256 public constant MAX_BUFFER_BLOCKS = 400000; // 200,000 blocks (6-7 days on BSC)

    address public immutable emonProfile;

    event AdminTokenRecovery(address indexed tokenRecovered, uint256 amount);
    event NewIFOContract(address indexed ifoAddress);

    /**
     * @notice Constructor
     * @param _emonProfile: the address of the PanemonProfile
     */
    constructor(address _emonProfile) {
        emonProfile = _emonProfile;
    }

    /**
     * @notice It creates the IFO contract and initializes the contract.
     * @param _lpToken: the LP token used
     * @param _offeringToken: the token that is offered for the IFO
     * @param _startBlock: the start block for the IFO
     * @param _endBlock: the end block for the IFO
     * @param _adminAddress: the admin address for handling tokens
     * @param _iEmonAddress: iEmon smart contract address, which is used to calculate IFO Limit
     * @param _pointThreshold: The required amount of LP to receive points
     * @param _admissionProfile: PanemonProfile
     */
    function createIFO(
        address _lpToken,
        address _offeringToken,
        uint256 _startBlock,
        uint256 _endBlock,
        address _adminAddress,
        address _iEmonAddress,
        uint256 _pointThreshold,
        address _admissionProfile
    ) external onlyOwner {
        require(IERC20(_lpToken).totalSupply() >= 0);
        require(IERC20(_offeringToken).totalSupply() >= 0);
        require(_lpToken != _offeringToken, "Operations: Tokens must be be different");
        require(_endBlock < (block.number + MAX_BUFFER_BLOCKS), "Operations: EndBlock too far");
        require(_startBlock < _endBlock, "Operations: StartBlock must be inferior to endBlock");
        require(_startBlock > block.number, "Operations: StartBlock must be greater than current block");

        bytes memory bytecode = type(EmonIfo).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_lpToken, _offeringToken, _startBlock));
        address ifoAddress;

        assembly {
            ifoAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        EmonIfo(ifoAddress).initialize(
            _lpToken,
            _offeringToken,
            emonProfile,
            _startBlock,
            _endBlock,
            MAX_BUFFER_BLOCKS,
            _adminAddress,
            _iEmonAddress,
            _pointThreshold,
            _admissionProfile
        );

        emit NewIFOContract(ifoAddress);
    }
   
    function recoverEth(address payable account,uint256 amount) external onlyOwner{
        account.transfer(amount);
    }

    function recoverOtherTokens(address token,address account,uint256 amount) external onlyOwner{
        IERC20(token).safeTransfer(account,amount);
    }
}