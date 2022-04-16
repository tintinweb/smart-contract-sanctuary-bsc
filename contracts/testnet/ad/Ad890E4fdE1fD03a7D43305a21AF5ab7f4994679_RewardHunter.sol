/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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

// File: @openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;


/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/token/ERC1155/IERC1155.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// File: @openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// File: @openzeppelin/contracts/token/ERC1155/ERC1155.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;







/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

// File: contracts/Unbox.sol

/**
 *Develop by CPTRedHawk
 *
 * SPDX-License-Identifier: MIT
 */











pragma solidity ^0.8.11;

 contract Unbox is Ownable {


   

        // Gera Ids para NFT
        using Counters for Counters.Counter;

        Counters.Counter private _boxIds;

        uint private randNonce = 0;

        uint256 public box1;
        uint256 public box2;
        uint256 public box3;

        uint256 private boxChangeOne;
        uint256 private boxChangeTwo;
        uint256 private boxChangeThree;

        uint256 private boxChangeFor;
        uint256 private boxChangeFive;
        uint256 private boxChangeSix;

        uint256 private boxChangeSeven;
        uint256 private boxChangeEight;
        uint256 private boxChangeNine;
        uint256 private boxChangeTen;
        uint256 private boxChangeEleven;

        mapping(uint256 => UnboxUser) private idToMarketItem;

        address public walletBox;

        event luckyBoxer(address indexed from, uint256 numberLucky, uint256 numberUser);

  // Estrutura das NFTs
  struct UnboxUser {
      uint boxId;
      // Id da NFT
      uint boxUser;
      // Limite de Mintage por Box
      uint boxLimit;
      // Atutal Dono da NFT
      address ownerBox;
      // Preço da NFT
      uint numberPercent;
      uint counterBox;
      // Boleano para verificar se a NFT é do User
      bool isBox;
    }


    function randMod(uint _modulus) internal returns(uint){
        randNonce++;
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % _modulus;
    }

 


    function setPercentBoxOne(uint256 _boxChangeOne, uint256 _boxChangeTwo, uint256 _boxChangeThree) public onlyOwner {
      boxChangeOne = _boxChangeOne;
      boxChangeTwo = _boxChangeTwo;
      boxChangeThree = _boxChangeThree;
    }

    function setPercentBoxTwo(uint256 _boxChangeFor, uint256 _boxChangeFive, uint256 _boxChangeSix) public onlyOwner {
      boxChangeFor = _boxChangeFor;
      boxChangeFive = _boxChangeFive;
      boxChangeSix = _boxChangeSix;
    }

    function setPercentBoxThree(uint256 _boxChangeSeven, uint256 _boxChangeEight, uint256 _boxChangeNine, uint256 _boxChangeTen, uint256 _boxChangeEleven) public onlyOwner {
      boxChangeSeven = _boxChangeSeven;
      boxChangeEight = _boxChangeEight;
      boxChangeNine = _boxChangeNine;
      boxChangeTen = _boxChangeTen;
      boxChangeEleven = _boxChangeEleven;
    }








    function _generateNft(uint _index) internal returns(uint256) {
        uint rand = randMod(100);
        uint result;

        UnboxUser storage nft = idToMarketItem[_index];
        
        if (nft.boxUser == 1) {
            if (rand <= boxChangeOne) {
                result = (1);

            }  else  if (rand > boxChangeTwo && rand <= boxChangeThree) {
                result = (2);
            } 
        }

        else if (nft.boxUser == 2) {
            if (rand <= boxChangeFor) {
                result = (1);

            }   else if (rand > boxChangeFive && rand <= boxChangeSix) {
                result = (2);
            } 
        }

        else if (nft.boxUser == 3) {
            if (rand <= boxChangeSeven) {
                result = (1);

            }   else if (rand > boxChangeEight && rand <= boxChangeNine) {
                result = (2);

            }   else if (rand > boxChangeTen && rand <= boxChangeEleven) {
                result = (3);

            }
        }

      return result;
  }

    function setBox1Price(uint _box1) public onlyOwner {
       box1 = _box1;
   }

    function setBox2Price(uint _box2) public onlyOwner {
       box2 = _box2;
   }

    function setBox3Price(uint _box3) public onlyOwner {
       box3 = _box3;
   }

   function setWalletBox(address _newWalletBox) public onlyOwner {
       walletBox = _newWalletBox;
   }

 

    function fetchMyBox(address _usr) public view returns(UnboxUser[] memory) {
      
            uint totalItemCount = _boxIds.current();
            uint itemCount = 0;
            uint currentIndex = 0;

            for (uint i = 0; i < totalItemCount; i++) {
              if (idToMarketItem[i + 1].ownerBox == _usr) {
                itemCount += 1;
              }
            }

            UnboxUser[] memory items = new UnboxUser[](itemCount);
            for (uint i = 0; i < totalItemCount; i++) {
              if (idToMarketItem[i + 1].ownerBox == _usr) {
                uint currentId = i + 1;
                UnboxUser storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
              }
            }
            return items;
    }

   function infoBox(uint _index) public view returns(  uint numberPercent) {
    UnboxUser storage nft = idToMarketItem[_index];
    return( nft.numberPercent);
  }


  function _luckyBox(uint _index) internal returns(uint256 numberPercent){
    UnboxUser storage nft = idToMarketItem[_index];
    require(nft.ownerBox == msg.sender, "RHT:Precisa ser o dono da Box");
    require(nft.isBox, "RHT:Voce precisa ter uma Box");
    require(nft.counterBox < nft.boxLimit, "RHT:Limite de mint por Box excedido");

        nft.counterBox += 1;

        

        if (nft.counterBox == nft.boxLimit) {
            nft.isBox = false;
            nft.ownerBox = address(0);
        }

      

        nft.numberPercent  = _generateNft(_index);

        if(nft.numberPercent == 0) {
          nft.numberPercent == 1;
        }

        emit luckyBoxer(msg.sender, nft.numberPercent, nft.boxUser);

        return nft.numberPercent;
       
  }

    function _fundsBNB() internal {
       (bool success,) = payable(walletBox).call{value: msg.value}("");
        require(success,"RHT:Falha na retirada de fundos");
    }

  function _unboxClass(address _usr) internal{
      

      if (msg.value == box1) {

        _boxIds.increment();
        uint256 newBoxId = _boxIds.current();

       UnboxUser storage nft = idToMarketItem[newBoxId];
       nft.boxId = newBoxId;
       nft.ownerBox = _usr;
       nft.boxUser = 1;
       nft.boxLimit = 4;
       nft.isBox = true;

      _fundsBNB();
 
      } 

      else if (msg.value == box2) {
        
        _boxIds.increment();
        uint256 newBoxId = _boxIds.current();

       UnboxUser storage nft = idToMarketItem[newBoxId];
       nft.boxId = newBoxId;
       nft.ownerBox = _usr;
       nft.boxUser = 2;
       nft.boxLimit = 6;
       nft.isBox = true;

        _fundsBNB();
  
       
      }

       else if (msg.value == box3) {
          
        _boxIds.increment();
        uint256 newBoxId = _boxIds.current();

       UnboxUser storage nft = idToMarketItem[newBoxId];
       nft.boxId = newBoxId;
       nft.ownerBox = _usr;
       nft.boxUser = 3;
       nft.boxLimit = 7;
       nft.isBox = true;

        _fundsBNB();
      }   

      else if (msg.value < box1) {
          require(msg.value == box1, "RHT:Voce precisa por o valor minimo da Box");
      }
       
  }




}



// File: contracts/RHTNft.sol

// contracts/GameItems.sol

pragma solidity ^0.8.12;













// Simples Interface do Contrato do Token

interface IBEP20 {
        function totalSupply() external view returns (uint);
        function allowance(address owner, address spender) external view  returns (uint256);
        function transfer(address recipient, uint256 amount) external returns (bool) ;
        function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
        function balanceOf(address account) external view  returns (uint256);
        function approve(address _spender, uint256 _amount) external returns (bool);
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);  
        }



 contract RewardHunter is ERC1155, Ownable, Unbox, ReentrancyGuard {

    using SafeMath for uint256;
 
    using Address for address;
    // Gera Ids para NFT
    using Counters for Counters.Counter;
    // Id de cada NFT
    Counters.Counter private _tokenIds;
    // Id para Tokens Vendidos
    Counters.Counter private _itemsSold;

    string private _uri;



    uint256 public listingPrice;
    uint256 public _withdrawableBalance;
    uint256 public _whitdrawbleToken;
    uint256 public percentBuy;
    uint256  priceInRHT;
    IBEP20 public token;
    address public wallet;


  event MintNfts(address indexed from, uint256 id, uint256 _amountBnb ,uint256 _amount);
  

  // Mapeamento de estrutura de NFT
  mapping(uint256 => NftUsers) private idToMarketItem;
  mapping(uint256 => NftUsers) private getId;
  mapping(uint => string) tokenUri;

  // Estrutura das NFTs
  struct NftUsers {
      // Id da NFT
      uint256 tokenId;
      // Atutal Dono da NFT
      address payable ownerNft;
      // Vendedor
      address payable sellerNft;
      // Preço da NFT
      uint256 priceToken;
      // Boleano para definir se está vendida ou não
      bool sold;
      // Boleano para verificar se a NFT é do User
      bool isUser;
    }


    constructor(IBEP20 _token, address _wallet )   ERC1155("")

    {
      token = _token;
      wallet = _wallet;
    }

    function setWallet(address _newWallet) public onlyOwner {
       wallet = _newWallet;
   }

    function setListingBNB(uint _listing) public onlyOwner {
      listingPrice = _listing;
    }

    function setListingRHT(uint _rht) public onlyOwner {
      priceInRHT = _rht;
    }



    function _forwardFunds() internal {
       (bool success,) = payable(wallet).call{value: msg.value}("");
        require(success,"RHT FAILED : FORWARD FUNDS FAIL");
    }

    function Boxing(uint _index) public nonReentrant {
      _luckyBox(_index);
       _UnboxUser(msg.sender);
    }

    function mintBox() public nonReentrant payable {
      _unboxClass(msg.sender);
    }




    function _UnboxUser(address _usr) internal returns(uint256) {

        // Gera Ids de cada NFT
        _tokenIds.increment();
  
        uint256 newTokenId = _tokenIds.current();

      // Minta uma NFT atráves de uma Solicitação via VOUCHER
      _mint(msg.sender, newTokenId,1,"");

      NftUsers storage ids = idToMarketItem[newTokenId];
          ids.tokenId = newTokenId;
          ids.ownerNft = payable(_usr);
          ids.sold = false;
          ids.isUser = true;

        NftUsers storage getIds = getId[1];
          getIds.tokenId = newTokenId;

      emit MintNfts(msg.sender, newTokenId, msg.value, 0);
           
      return newTokenId;
    }



   

    function mintNFT(uint256 _amount) external payable nonReentrant returns(uint256) {

        if (priceInRHT != 0) {
          require(msg.value == 0, "RHT:Saldo de BNB precisa ser 0");
          require(_amount == priceInRHT, "RHT:Saldo de Token precisa ser equivalente ao preco de Venda");
          IBEP20(token).transferFrom(msg.sender, wallet, _amount);
        }
        else if (listingPrice != 0) {
          require(_amount == 0, "RHT:Saldo de Token precisa ser equivalente ao preco de Venda");
          require(msg.value >= listingPrice, "RHT:Saldo de BNB precisa ser equivalente ao preco de Venda");
         
          _forwardFunds();
        }
        
        // Gera Ids de cada NFT
        _tokenIds.increment();
  

        uint256 newTokenId = _tokenIds.current();

        NftUsers storage getIds = getId[1];
          getIds.tokenId = newTokenId;

      // Minta uma NFT atráves de uma Solicitação via VOUCHER
      _mint(msg.sender, newTokenId,1,"");
     
       // Saldo no Storage do Contrato inforamações relevantes de cada NFT
       /*
       * @Admin isso permite que o custo de gás seja bem menor e consiga otimizar o contrato com mais facilidade
       * OBS: Uma vez que salvar em storage consome bem menos gás do que sempre precisar usar o FOR LOOP para ITERAR
       */
        NftUsers storage ids = idToMarketItem[newTokenId];
          ids.tokenId = newTokenId;
          ids.ownerNft = payable(msg.sender);
          ids.sold = false;
          ids.isUser = true;

      
      emit MintNfts(msg.sender, newTokenId, msg.value, _amount);
 

      return newTokenId;
    }

    function newIdView(uint256 _index) public view returns(uint256) {
      NftUsers memory getIds = getId[_index];
      return getIds.tokenId;
    }

    function newIdViewStorage(uint256 _index) public view returns(uint256) {
      NftUsers storage getIds = getId[_index];
      return getIds.tokenId;
    }


  

    // Lança a NFT para venda no Marketplace
    function marketItem(uint _tokenId, uint _price) public   {

        NftUsers storage ids = idToMarketItem[_tokenId];

        require(_price > 0, "RHT: Preco de venda em Token precisa ser maior do que zero");
     

        // Requer que seja dono da NFT
        require(ids.ownerNft == payable(msg.sender),"RHT: Precisa ser o Owner dessa NFT");
        // Requer que o ID da nft seja do User e que ela exista!
        require(ids.isUser, "RHT: Esse ID nao existe ou nao pertence a esse User");
          // Nft passa a ser do contrato
          ids.ownerNft = payable(address(this));
          // Seller é o vendedor da NFT
          ids.sellerNft = payable(msg.sender);
          // Preço que o Seller está colocando para venda
          ids.priceToken = _price;
          // Boleano de venda está como TRUE, por que significa que está para venda
          ids.sold = true;
            

          //Transfere de forma Segura a NFT para o contrato de NFTs Marketplace
          _safeTransferFrom(msg.sender, address(this),_tokenId,1,"");
    }

    function _safeTransferFrom(uint _tokenId, address _receiver) virtual nonReentrant public {
          NftUsers storage ids = idToMarketItem[_tokenId];

         // Requer que seja dono da NFT
         require(ids.ownerNft == payable(msg.sender),"RHT: Precisa ser o Owner dessa NFT");
         // Requer que o ID da nft seja do User e que ela exista!
         require(ids.isUser, "RHT: Esse ID nao existe ou nao pertence a esse User");
          // Nft passa a ser do contrato
          ids.ownerNft = payable(_receiver);
          // Seller é o vendedor da NFT
          ids.sellerNft = payable(address(0));
          // Preço que o Seller está colocando para venda
          ids.priceToken = 0;
          // Boleano de venda está como TRUE, por que significa que está para venda
          ids.sold = false;


          //Transfere de forma Segura a NFT para o contrato de NFTs Marketplace
          _safeTransferFrom(msg.sender, _receiver,_tokenId,1,"");
    }
    

    // Retira os Token RHT do contrato e envia para a wallet do Owner
    function removeToken() external nonReentrant onlyOwner {
              // Saldo de Tokens
              _whitdrawbleToken;
              // Transfere o Saldod e Tokens
              IBEP20(token).transfer(wallet, _whitdrawbleToken);
              // Evita reentradas 0 o saldo de Tokens no CONTRATO e transferindo tudo para o Owner
              _whitdrawbleToken = 0;
      }

    function setPercentBuy(uint _percent) external onlyOwner {
      percentBuy = _percent;
    }

    function buyNfts(uint _tokenId, uint _price) public nonReentrant  {

      NftUsers storage ids = idToMarketItem[_tokenId];

          require(_price == ids.priceToken, "RHT:Preco de compra precisa em Token ser indetico ao preco de venda");

          uint256 divisorTax = SafeMath.div(SafeMath.mul(_price,percentBuy),100);

          uint256 transferSeller = SafeMath.sub(_price,divisorTax);

          // Comprador transfere o Token para o Contrato NFT
          IBEP20(token).transferFrom(msg.sender, ids.ownerNft, _price);
          // Salvo o saldo da taxa para o Owner retirar depois
           _whitdrawbleToken += divisorTax;
           // Contrato NFT envia o Token com a taxa descontada para o vendedor
           IBEP20(token).transfer(ids.sellerNft, transferSeller);



            // Após efetuado a compra, a nft passa a ser do comprador
            ids.ownerNft = payable(msg.sender);
            ids.sellerNft = payable(address(0));
            ids.priceToken = 0;
            ids.sold = false;

      //Transfere de forma Segura a NFT para o novo comprador
      _safeTransferFrom(address(this), msg.sender,_tokenId,1,"");


    }

    function fetchMarketItems() public view returns(NftUsers[] memory) {
            uint totalItemCount = _tokenIds.current();
            uint itemCount = 0;
            uint currentIndex = 0;

            for (uint i = 0; i < totalItemCount; i++) {
              if (idToMarketItem[i + 1].ownerNft == address(this)) {
                itemCount += 1;
              }
            }

            NftUsers[] memory items = new NftUsers[](itemCount);
            for (uint i = 0; i < totalItemCount; i++) {
              if (idToMarketItem[i + 1].ownerNft == address(this)) {
                uint currentId = i + 1;
                NftUsers storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
              }
            }
            return items;
    }

          function fetchMySeller(address _usr) public view returns(NftUsers[] memory) {
                  uint totalItemCount = _tokenIds.current();
                  uint itemCount = 0;
                  uint currentIndex = 0;

                  for (uint i = 0; i < totalItemCount; i++) {
                    if (idToMarketItem[i + 1].sellerNft == _usr) {
                      itemCount += 1;
                    }
                  }

                  NftUsers[] memory items = new NftUsers[](itemCount);
                  for (uint i = 0; i < totalItemCount; i++) {
                    if (idToMarketItem[i + 1].sellerNft == _usr) {
                      uint currentId = i + 1;
                      NftUsers storage currentItem = idToMarketItem[currentId];
                      items[currentIndex] = currentItem;
                      currentIndex += 1;
                    }
                  }
                  return items;
          }

        function fetchMyItems(address _usr) public view returns(NftUsers[] memory) {
            uint totalItemCount = _tokenIds.current();
            uint itemCount = 0;
            uint currentIndex = 0;

            for (uint i = 0; i < totalItemCount; i++) {
              if (idToMarketItem[i + 1].ownerNft == _usr) {
                itemCount += 1;
              }
            }

            NftUsers[] memory items = new NftUsers[](itemCount);
            for (uint i = 0; i < totalItemCount; i++) {
              if (idToMarketItem[i + 1].ownerNft == _usr) {
                uint currentId = i + 1;
                NftUsers storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
              }
            }
            return items;
    }

    function removeMarket(uint _tokenId) nonReentrant external {

        NftUsers storage ids = idToMarketItem[_tokenId];
          require(ids.sold, "RHT:Esse ID nao consta no sistema de VENDAS");
          require(ids.sellerNft == payable(msg.sender), "RHT:Voce precisa ser o Seller dessa NFT");
          // NFT retorna para o Dono
          ids.ownerNft = payable(msg.sender);
          // Seller passa a ser o DEAD ADDRESS(ENDEREÇO MORTO) OBS:FUNÇÃO SE TORNA INATIVA OU SEJA NAO TEM RISCO DE REENTRADAS DE INVASÃO
          ids.sellerNft = payable(address(0));
          ids.priceToken = 0;
          // Boleano se torna False por que o user desfez a operação
          ids.sold = false;

          

          
          // Transfere de volta para o Dono da NFT
          _safeTransferFrom(address(this), msg.sender,_tokenId,1,"");

    }

    function getInfosNft(uint256 _tokenId) public view returns(uint256 tokenId, address ownerNft, address  sellerNft,  uint256 priceToken, bool sold) {
        NftUsers storage nft = idToMarketItem[_tokenId];

        return(nft.tokenId, nft.ownerNft, nft.sellerNft, nft.priceToken, nft.sold);

    }


    // Consegue visualizar o preço de cada NFT em BNB com base em suas definições
    function getListingPrice() public view returns (uint256) {
      return listingPrice;
    }

    // Permite que o Owner do Contrato mude a URI das NFTs
    function setURI(string memory _newuri) public onlyOwner {
        _uri = _newuri;
    }


    // Uri das NFTs
      function uri(uint _index) override public view returns(string memory tokenId) {
                
                NftUsers storage nft = idToMarketItem[_index];
                require(nft.isUser, "RHT:Essee Id nao existe");
        return(
            string(abi.encodePacked(
                _uri,Strings.toString(nft.tokenId)
            )
        )
        );
    }


    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
    
  
}