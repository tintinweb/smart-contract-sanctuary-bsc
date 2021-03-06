/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/math/SafeMath.sol

// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.6;

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

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)



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

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

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
        assembly {
            size := extcodesize(account)
        }
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

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

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
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)



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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)




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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)




/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)



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

// File: @openzeppelin/contracts/token/ERC721/ERC721.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/ERC721.sol)

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
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
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// File: @openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721URIStorage.sol)




/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)


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

// File: contracts/WWARTMarketPlace.sol

contract WWARTMarketPlace is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _auctionIdTracker;
    Counters.Counter private _bidTracker;
    string private _baseTokenURI;
    string private _baseContractURI;
    mapping(address => uint256) failedBids;
    mapping(uint256 => AuctionData) public wwartAuctions;
    mapping(uint256 => bool) public auctions;
    mapping(uint256 => uint256) public tokensUnderAuctions;
    mapping(string => bool) _artExists;
    mapping(uint256 => bool)  tokensForSale;
    mapping(uint256 => TokenData) public tokens;
    using SafeMath for uint256;
    uint256 public createCommission;
    uint256 public reSellCommission;
    uint256 public firstSellCommission;
    uint256 public auctionCommission;
    uint256 public royalty;
    // Data of each NFT
    struct TokenData {
        address payable creator; // creator of the NFT
        bool isSellEnabled;
        uint256 originalPrice;
        uint256 totalPrice;
    }

    //Each Auction is unique to each NFT (contract + id pairing).
    struct AuctionData {
        uint256 tokenId;
        uint256 auctionBidPeriod;
        uint256 auctionStartTime;
        uint256 auctionEndTime;
        uint256 minPriceInWei;
        uint256 cutPriceInWei;
        uint256 highestBid;
        address highestBidder;
        bool settled;
        bool bidStarted;
        uint extensions;
    }
    // default vaules
    uint256 public defaultBidIncreasePercentage = 300;
    uint256 public minimumBidIncreasePercentage = 500;
    uint256 public maximumMinPricePercentage = 100;
    uint256 public auctionPublishPeriod = 86400; // 24 hours
    uint256 commissionDenominator = 10000;
    uint256 public basePercent = 100;
    uint256 public timeBuffer = 600; //10 minutres
    uint256 public maximumExtensions = 144; //10 minutres
    uint256  defaultAuctionCommission = 1300;
    uint256  defaultFirstSellCommission = 1000;
    uint256  defaultReSellCommission = 250;
    uint256  defaultCreateCommission = 300;
    uint256  defaultRoyalty = 1000;

    /* ****
     *Events
     * ****/
    event SellEnabled(uint256 _tokenId, address sender, uint date); 
    event SellDisabled(uint256 _tokenId, uint date);
    event WWARTCreated(uint256 tokenId, address owner, uint256 totalPrice, uint now);
    event CommissionChanged(uint256 _oldCommission, uint256 _newCommission, address owner, uint stage, uint now);
    event PriceChanged(uint256 indexed tokenId, uint256 originalPrice, uint256 totalPrice, address owner, uint now);
    event Sale(uint256 indexed _tokenId, uint256 _price, uint now);
    event Payment(address from, address to, uint amount, uint32 recieverType, uint now);
    event SentMoney(address payable _payee, uint256 _amount, uint256 balance);
    event AuctionCreated(uint256 indexed auctionId, uint256 indexed tokenId, address tokenOwner, uint256 minPrice,
        uint256 _startTime, uint256 duration, uint256 _endTime, uint256 now);
    event AuctionEnded(uint256 indexed auctionId, uint256 indexed tokenId, address indexed tokenContract, address tokenOwner,
        address curator, address winner, uint256 amount, uint256 curatorFee, uint256 now);
    event AuctionCanceled(uint256 indexed auctionId, uint256 indexed tokenId, address indexed tokenContract, address tokenOwner);
    event PlaceBid(uint256 indexed auctionId, uint256 indexed tokenId, address bidder, uint256 amount);
    event AuctionSettleRequest(uint256 auctionId, uint256 tokenId, address auctionSettler, address winner, uint256 now);
    event AuctionSettled(uint256 auctionId, uint256 tokenId, address auctionSettler, address winner, uint256 now);

    constructor() ERC721("WWART NFT", "WWART") {
        firstSellCommission = defaultFirstSellCommission;
        createCommission = defaultCreateCommission;
        reSellCommission = defaultReSellCommission;
        auctionCommission = defaultAuctionCommission;
        royalty = defaultRoyalty;
    }

    /*
    */
    function baseTokenURI() public view returns (string memory) {
        return _baseTokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI();
    }

    // 1. mints the NFT and save the data in the "tokens" map.
    /**
    *  tokenURI - the url for the json file containing name, url of original art and description
    *  _price - price for the art excluding platform commission
    */
    function createNFT(string memory tokenURI, uint256 _price)
    public
    returns (uint256)
    {
        //require(_royalty <= 1000 && _royalty >= 500, "Royalty should be within 5-10%");
        require(_price > 0.0, "Price must be grater than 0.");
        uint256 tokenId = mintWWART(tokenURI);
        uint256 totalPrice = setupTokenData(tokenId, _price, msg.sender);
        enableSell(tokenId, 0.0);
        emit WWARTCreated(tokenId, msg.sender, totalPrice, block.timestamp);
        return tokenId;
    }

    function setupTokenData(uint256 _tokenId, uint256 _price, address sender) internal returns (uint256){
        _price = (_price.mul(1e18).div(commissionDenominator));
        uint256 commissionToPay = _price.mul(createCommission).div(commissionDenominator);
        uint256 totalPrice = _price.add(commissionToPay);
        tokens[_tokenId] = TokenData({
        creator : payable(sender),
        originalPrice : _price,
        totalPrice : totalPrice,
        isSellEnabled : true
        });
        return totalPrice;
    }


    function mintWWART(string memory tokenURI) internal returns (uint256){
        require(_artExists[tokenURI] != true, "Token Already Exists");
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        _artExists[tokenURI] = true;
        return newItemId;
    }


    function contractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function contractURI() public view returns (string memory) {
        return _baseContractURI;
    }


    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }

    /***
    * customer can change the price for the contract
    *  _tokenId = id of the token
    *  _price = price in 10000 ether for the token. For example, for 1 ether = send 10000
    */
    function changePrice(uint256 _tokenId, uint256 _price) external {
        require(msg.sender == ownerOf(_tokenId), "Only Token owner can change the price");
        _price = (_price.mul(1e18).div(commissionDenominator));
        // convert to wei
        updatePrice(_tokenId, _price, msg.sender);
    }

    function updatePrice(uint256 _tokenId, uint256 _price, address sender) internal {
        require(_exists(_tokenId), "This is not a valid TokenId");
        uint256 _oldPrice = tokens[_tokenId].originalPrice;
        require(_price != uint256(0) && _price != _oldPrice, "New price can not be same as old price.");
        address tokenOwner = ownerOf(_tokenId);
        address creator = tokens[_tokenId].creator;
        uint256 commission = 0;
        if (creator == tokenOwner) {
            commission = createCommission;
        } else {
            commission = reSellCommission;
        }
        tokens[_tokenId].originalPrice = _price;
        uint256 commissionToPay = _price.mul(commission).div(commissionDenominator);
        _price = _price.add(commissionToPay);
        if (creator != tokenOwner) {
            uint256 royaltyToPay = tokens[_tokenId].originalPrice.mul(royalty).div(commissionDenominator);
            // add royalty
            _price = _price.add(royaltyToPay);
        }
        tokens[_tokenId].totalPrice = _price;
        emit PriceChanged(_tokenId, tokens[_tokenId].originalPrice, tokens[_tokenId].totalPrice, sender, block.timestamp);
    }
    /**
     * stage = 1 , change createCommission
     * stage = 2 , change resell com
     */
    function changeCommission(uint256 _commission, uint stage) external onlyOwner {
        // Token must exist
        require(_commission != uint256(0), 'Platform Charge must be greater than 0');
        uint256 _oldCommission = 0;
        if (stage == 1) {
            _oldCommission = firstSellCommission;
            require(_commission != _oldCommission, "New Commission can not be same as old Commission.");
            firstSellCommission = _commission;
        } else if (stage == 2) {
            _oldCommission = reSellCommission;
            require(_commission != _oldCommission, "New Commission can not be same as old Commission.");
            reSellCommission = _commission;
        } else if (stage == 3) {
            _oldCommission = auctionCommission;
            require(_commission != _oldCommission, "New Commission can not be same as old Commission.");
            auctionCommission = _commission;
        } else if (stage == 4) {
            _oldCommission = createCommission;
            require(_commission != _oldCommission, "New Commission can not be same as old Commission.");
            createCommission = _commission;
        }
        emit CommissionChanged(_oldCommission, _commission, msg.sender, stage, block.timestamp);
    }
    
    function changeRoyalty (uint256 _newroyalty) external onlyOwner {
        require(_newroyalty != uint256(0), 'Royalty must be greater than 0');
        royalty =_newroyalty;     
    }

    /***
     * customer can enable resale for the wwart contract, if price is 0, old price will not change, otherwise price will change,
     */
    function enableSell(uint256 _tokenId, uint256 _price) public returns (bool) {
        // Token must exist
        require(_exists(_tokenId), "This is not a valid TokenId");
        require(ownerOf(_tokenId) == msg.sender, "Only owner can enable sale");
        if (_price > 0.0) {
            _price = (_price.mul(1e18).div(commissionDenominator));
            // convert to wei
            if (tokens[_tokenId].originalPrice != _price) {
                updatePrice(_tokenId, _price, msg.sender);
            }
        }
        tokens[_tokenId].isSellEnabled = true;
        return tokens[_tokenId].isSellEnabled;
    }

    /***
     * customer can enable resale for the wwart contract
     */
    function disableSell(uint256 _tokenId) public returns (bool) {
        require(_exists(_tokenId), "This is not a valid TokenId");
        require(ownerOf(_tokenId) == msg.sender, "Only owner can disable sale.");
        tokens[_tokenId].isSellEnabled = false;
        return tokens[_tokenId].isSellEnabled;
    }

    function isSellEnabled(uint256 _tokenId) public view returns (bool) {
        return tokens[_tokenId].isSellEnabled;
    }
    function resellWWART(uint256 _tokenId) public payable {
        address payable _platform = payable(owner());
        address payable tokenOwner = payable(ownerOf(_tokenId));
        verificationSell(_tokenId, msg.sender, tokenOwner, _platform, msg.value, tokens[_tokenId].originalPrice);
        uint256 platformCut = tokens[_tokenId].originalPrice.mul(reSellCommission).div(commissionDenominator);
        require(_platform.send(platformCut));
        emit Payment(msg.sender, _platform, platformCut, 1, block.timestamp);      
        require(tokenOwner.send(tokens[_tokenId].originalPrice));
        emit Payment(msg.sender, tokenOwner, tokens[_tokenId].originalPrice, 3, block.timestamp);
        uint256 royaltyInWei = tokens[_tokenId].totalPrice.sub(tokens[_tokenId].originalPrice.add(platformCut));
        tokens[_tokenId].creator.transfer(royaltyInWei);
        emit Payment(msg.sender, tokens[_tokenId].creator, royaltyInWei, 2, block.timestamp);
        tokenTransfer(tokenOwner, msg.sender,  _tokenId);
        disableSell(_tokenId);
    }


    function tokenTransfer (address from, address to, uint256 _tokenId) internal{
        _safeTransfer(from,to, _tokenId, "");
        require(to == ownerOf(_tokenId), "WWART transfer failed");
    }

    function verificationSell(uint256 _tokenId, address customer, address tokenOwner, address _platform, uint256 price, uint256 priceInWei)  internal {
        require(_exists(_tokenId), "This is not a valid TokenId");
        if(tokensUnderAuctions[_tokenId]!=0){
               if( _isAuctionOngoing(tokensUnderAuctions[_tokenId]) == false 
                    && isSellEnabled(_tokenId) == false) {
                   tokens[_tokenId].isSellEnabled = true;
                   delete tokensUnderAuctions[_tokenId];
               }
        }
        require(tokens[_tokenId].isSellEnabled, "Token is not enabled for sale.");
        require(tokenOwner != address(0) && customer != address(0) && _platform != address(0), "Invalid address.");
        require(tokenOwner != customer && customer != _platform, "Invalid customer address.");
        require(price >= priceInWei, "Invalid amount.");
        uint256 customerBalance = address(customer).balance;
        require(customerBalance >= priceInWei, "Insufficient Balance. Balance should be more than or equal to price.");
    }

    function sellWWART(uint256 _tokenId) payable external {
        address customer = msg.sender;
        uint256 price = msg.value;
        address payable _platform = payable(owner());
        address payable tokenOwner = payable(ownerOf(_tokenId));
        verificationSell(_tokenId, customer, tokenOwner, _platform, price, tokens[_tokenId].totalPrice);      
        uint256 commission = price - tokens[_tokenId].originalPrice;
        uint256 sellCommission = tokens[_tokenId].originalPrice.mul(firstSellCommission).div(commissionDenominator);
        commission = sellCommission + commission;
        require(_platform.send(commission));
        emit Payment(msg.sender, _platform, commission, 1, block.timestamp);
        uint256 ownerCut = price.sub(commission);
        require(tokenOwner.send(ownerCut));
        emit Payment(customer, tokenOwner, ownerCut, 2, block.timestamp);
        tokenTransfer (tokenOwner, customer, _tokenId);
        disableSell(_tokenId);

    }


    function sendTo(address payable _payee, uint256 _amount) public onlyOwner {
        require(_payee != address(0) && _payee != address(this));
        require(_amount > 0 && _amount <= address(this).balance);
        _payee.transfer(_amount);
        emit SentMoney(_payee, _amount, address(this).balance);
    }

    function createAuctionWithNewToken(string memory _tokenURI, uint128 startAfterDay, uint256 _auctionBidPeriod, uint256 _cutPrice,
        uint256 _minPrice, uint256 _price) public returns (uint256){
        uint256 _tokenId = mintWWART(_tokenURI);
        uint256 totalPrice = setupTokenData(_tokenId, _price, msg.sender);
        emit WWARTCreated(_tokenId, msg.sender, totalPrice, block.timestamp);
        return _createAuction(_tokenId, startAfterDay, _auctionBidPeriod, _cutPrice, _minPrice, msg.sender);
    }

    function createAuction(uint256 _tokenId, uint128 startAfterDay, uint256 _auctionBidPeriod, uint256 _cutPrice,
        uint256 _minPrice, uint256 _price) public returns (uint256){
        if (_price > 0.0) {
            require(msg.sender == ownerOf(_tokenId), "Sender doesn't own NFT");
            _price = (_price.mul(1e18).div(commissionDenominator));
            if (tokens[_tokenId].originalPrice != _price) {
                updatePrice(_tokenId, _price, msg.sender);
            }
        }    
        return _createAuction(_tokenId, startAfterDay, _auctionBidPeriod, _cutPrice, _minPrice, msg.sender);
    }

    function verifyAuctionData(uint256 _tokenId, uint256 _auctionBidPeriod, uint256 _cutPrice,
        uint256 _minPrice, address sender) internal view returns (uint256){
        require(auctions[_tokenId] != true, "Auction Already Exists");
        require(_minPrice > 0 && _cutPrice > 0, "Price cannot be 0");
        require(sender == ownerOf(_tokenId), "Sender doesn't own NFT");
        if (_auctionBidPeriod < 1) {
            _auctionBidPeriod = 1;
        }
        return _auctionBidPeriod;
    }

    function _createAuction(uint256 _tokenId, uint128 startAfterDay, uint256 _auctionBidPeriod, uint256 _cutPrice,
        uint256 _minPrice, address _sender) internal returns (uint256){
        _auctionBidPeriod = verifyAuctionData(_tokenId, _auctionBidPeriod, _cutPrice, _minPrice, _sender);
        _auctionIdTracker.increment();
        uint256 auctionId = _auctionIdTracker.current();
        uint256 startTime = block.timestamp;
        uint256 duration = auctionPublishPeriod.mul(_auctionBidPeriod);
        if (startAfterDay >= 0) {
            startTime = startTime.add(auctionPublishPeriod.mul(startAfterDay));
        }
        uint256 auctionEndTime = startTime.add(duration);
        _minPrice = _minPrice.mul(1e18).div(commissionDenominator);
        _cutPrice = _cutPrice.mul(1e18).div(commissionDenominator);

        wwartAuctions[auctionId] = AuctionData({
        tokenId : _tokenId,
        minPriceInWei : _minPrice,
        auctionBidPeriod : duration,
        auctionStartTime : startTime,
        auctionEndTime : auctionEndTime,
        highestBid : 0.0,
        highestBidder : address(0),
        settled : false,
        bidStarted: false,
        cutPriceInWei : _cutPrice,
        extensions : 0
        });
        auctions[_tokenId] = true;
        tokensUnderAuctions[_tokenId] = auctionId;
        disableSell(_tokenId);
        emit AuctionCreated(auctionId, _tokenId, msg.sender, _minPrice, startTime, _auctionBidPeriod, auctionEndTime, block.timestamp);
        return auctionId;
    }

    // 1. check if the auction exists
    modifier _isAuctionExists(uint256 _auctionId) {
        require(auctions[wwartAuctions[_auctionId].tokenId] = true, "Auction does not exist");
        _;
    }


    //5. if same auction already ongoing
    function _isAuctionOngoing(uint256 _auctionId) public view returns (bool){
        return (auctions[wwartAuctions[_auctionId].tokenId] && (wwartAuctions[_auctionId].auctionStartTime <= block.timestamp
        && block.timestamp < wwartAuctions[_auctionId].auctionEndTime));
    }

    function publishAuction(uint256 _auctionId)
    _isAuctionExists(_auctionId)
    public
    {
        require(msg.sender == ownerOf(wwartAuctions[_auctionId].tokenId), "Only Owner can publish an auction");
        wwartAuctions[_auctionId].auctionStartTime = block.timestamp;
        wwartAuctions[_auctionId].auctionEndTime = block.timestamp.add(wwartAuctions[_auctionId].auctionBidPeriod);

    }


    function cancelAuction(uint256 _auctionId)
    _isAuctionExists(_auctionId)
    public
    { require(msg.sender == ownerOf(wwartAuctions[_auctionId].tokenId), "Sender doesn't own NFT");
      require(_isAuctionOngoing(_auctionId) == false, "Auction is ongoing it can not be cancelled");
        _resetAuction(_auctionId);
    }

    function _resetAuction(uint256 _auctionId) internal
    {
        auctions[wwartAuctions[_auctionId].tokenId] = false;
        delete tokensUnderAuctions[wwartAuctions[_auctionId].tokenId];
    }

    function _validateBidAmount(uint256 _auctionId, uint256 _tokenAmount) internal view {
        uint256 cutPrice = wwartAuctions[_auctionId].cutPriceInWei;
        uint256 minPrice = wwartAuctions[_auctionId].minPriceInWei;
        uint256 _amount = wwartAuctions[_auctionId].highestBid;
        require(minPrice <= _tokenAmount, "Bid has to be equal or higher than the minimum price");

        if (_tokenAmount > 0 && _tokenAmount < cutPrice) {
            uint256 bidIncrement = _amount.add(_amount.mul(minimumBidIncreasePercentage).div(commissionDenominator));
            require(_tokenAmount >= bidIncrement, "Amount must be 5% higher than last bid");
        }

    }

    function _reverseLastBid(uint256 _auctionId) internal {
        _payout(wwartAuctions[_auctionId].highestBidder, wwartAuctions[_auctionId].highestBid);
    }

    function _payout(address _recipient, uint256 _amount) internal
    {
        payable(_recipient).transfer(_amount);
    }


    function _makeNewBid(uint256 _auctionId, address bidder, uint256 amount, uint256 diff) internal {
        wwartAuctions[_auctionId].highestBidder = bidder;
        wwartAuctions[_auctionId].highestBid = amount;
        address payable _platform = payable(owner());
        _payout(_platform, diff);
    }

    function bid(uint256 _auctionId, uint256 amount) public payable{
        uint256 _tokenId = wwartAuctions[_auctionId].tokenId;
        address tokenOwner = ownerOf(_tokenId);
        address bidder = address(msg.sender);
        address lastBidder = wwartAuctions[_auctionId].highestBidder;
        require(_isAuctionOngoing(_auctionId), "Bidding not allowed. Please check auction status.");
        require(lastBidder != bidder, "User is already the last bidder.");
        require(msg.sender != tokenOwner && msg.sender != address(this), "Sender should not own NFT");
        uint256 amountInWei = amount.mul(1e18).div(commissionDenominator);
        uint256 originalPrice = amountInWei;
        _validateBidAmount(_auctionId, amountInWei);
        require((bidder.balance > amountInWei && amountInWei > 0), "Insufficient amount");


        if (lastBidder != address(0) && lastBidder != address(this) && wwartAuctions[_auctionId].bidStarted) {
            _reverseLastBid(_auctionId);
            amountInWei = amountInWei.sub(wwartAuctions[_auctionId].highestBid);
        }

        _makeNewBid(_auctionId, bidder, originalPrice, amountInWei);
        emit PlaceBid(_auctionId, wwartAuctions[_auctionId].tokenId, msg.sender, msg.value);
        wwartAuctions[_auctionId].bidStarted= true;
        if (wwartAuctions[_auctionId].auctionStartTime.add(wwartAuctions[_auctionId].auctionBidPeriod).sub(
            block.timestamp) < timeBuffer && wwartAuctions[_auctionId].extensions < maximumExtensions) {
            _extendDuration(_auctionId);
        }

        if (originalPrice >= wwartAuctions[_auctionId].cutPriceInWei) {
            _resetAuction(_auctionId);
            emit AuctionSettleRequest(_auctionId, wwartAuctions[_auctionId].tokenId, tokenOwner, bidder, block.timestamp);
        }
    }

    function _extendDuration(uint256 _auctionId) internal {       
        wwartAuctions[_auctionId].auctionBidPeriod = wwartAuctions[_auctionId].auctionBidPeriod.add(timeBuffer);
        wwartAuctions[_auctionId].extensions = wwartAuctions[_auctionId].extensions.add(1);
        wwartAuctions[_auctionId].auctionEndTime = wwartAuctions[_auctionId].auctionEndTime.add(timeBuffer);
    }


    function _settleAuction(uint256 _auctionId, uint256 _tokenId, uint256 payment ) internal {
        address tokenOwner = payable(ownerOf(_tokenId));
        address winner = wwartAuctions[_auctionId].highestBidder;
        uint256 _amount = wwartAuctions[_auctionId].highestBid;
        uint256 commissionToPay = 0.0;
        address creator = tokens[_tokenId].creator;
        if (creator != tokenOwner) {// resell by auction
            uint256 royaltyToPay = _amount.mul(royalty).div(commissionDenominator);
            payable(creator).transfer(royaltyToPay);
            emit Payment(winner, creator, royaltyToPay, 2, block.timestamp);
            payment = payment.sub(royaltyToPay);
            commissionToPay = _amount.mul(reSellCommission).div(commissionDenominator);
            payment = payment.sub(commissionToPay);
            emit Payment(winner, owner(), commissionToPay, 1, block.timestamp);
        } else {
            commissionToPay = _amount.mul(auctionCommission).div(commissionDenominator);
            payment = payment.sub(commissionToPay);
            emit Payment(winner, owner(), commissionToPay, 1, block.timestamp);
        }
        payable(tokenOwner).transfer(payment);
        emit Payment(winner, tokenOwner, payment, 3, block.timestamp);
  
       tokenTransfer (tokenOwner, winner, _tokenId);
       emit AuctionSettled(_auctionId, wwartAuctions[_auctionId].tokenId, tokenOwner, winner, block.timestamp);
       delete wwartAuctions[_auctionId];
       tokens[_tokenId].isSellEnabled = true;
    }

    function settleAuction(uint256 _auctionId) public payable onlyOwner {
        require(msg.value >= wwartAuctions[_auctionId].highestBid, "Invalid ammount to settle Auction");
        _settleAuction(_auctionId, wwartAuctions[_auctionId].tokenId, msg.value);
    }

}