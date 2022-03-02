/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

// SPDX-License-Identifier: MIT 
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

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC721/ERC721.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;








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

        _afterTokenTransfer(address(0), to, tokenId);
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

        _afterTokenTransfer(owner, address(0), tokenId);
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
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
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

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// File: @openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: contracts/KangarooNFT.sol



pragma solidity ^0.8.0;




contract KangarooNFT is ERC721URIStorage, Ownable {

    event GetNFT(address indexed user, uint256 tokenId, uint256 types);

	uint256 public counter;

    uint256 private randNum = 0;

    mapping(uint256 => uint256) public NFTTypes;

    mapping(address => mapping(uint256 => uint256)) public userNFTTypeNumber;

    mapping(address => bool) public isCaptain;

    mapping(address => address) public recommenders;

    mapping(address => uint256) public recommendUserNumber;

    mapping(address => mapping(uint256 => address)) public recommendUsers;

    mapping(address => uint256) public recommendReward;

    mapping(address => uint256) public userDeposit;

    mapping(address => uint256) public userDepositTime;

    mapping(address => uint256) public captainRewardRates;

    mapping(uint256 => bool) public isLock;

    // uint256 public captainRewardRate = 30;

    uint256[3] public boxMaxTimes = [5000,2000,1000];

    uint256[3] public boxPrice = [1000,5000,10000];

    uint256[3] public rate = [9125,9625,9875];

    uint256[3] public boxOpenTimes = [1,5,10];

    uint256 public presaleStartTime = 1641909600;
    uint256 public presaleEndTime = 1644926400;

    // address USDT = 0x55d398326f99059fF775485246999027B3197955;
    address KG20 = 0xFd2464406Cc3d9585e08DF545e793838DF697470;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

	constructor() ERC721("KangarooNFT", "KGN"){
		counter = 0;
	}

    address private controllerAddress;

    function setController(address controllerAddr) public onlyOwner {
        controllerAddress = controllerAddr;
    }

    modifier onlyController {
         require(controllerAddress == msg.sender,"Must be controller");
         _;
    }

    function setBoxsRate(uint256 num1, uint256 num2, uint256 num3) public onlyOwner {
        rate[0] = num1;
        rate[1] = num1 + num2;
        rate[2] = num1 + num2 + num3;
    }

    function setBoxsPrice(uint256 boxId, uint256 price) public onlyOwner {
        boxPrice[boxId - 1] = price;  
    }

    function setBoxsMaxTimes(uint256 boxId, uint256 times) public onlyOwner {
        boxMaxTimes[boxId - 1] = times;   
    }

    function setStartTime(uint256 startTime) public onlyOwner {
        presaleStartTime = startTime;
    }
    
    function setEndTime(uint256 endTime) public onlyOwner {
        presaleEndTime = endTime;
    }

    function setCaptain(address captainAddress, uint256 rewarRate) public onlyOwner {
        isCaptain[captainAddress] = true;
        captainRewardRates[captainAddress] = rewarRate;
    }

    function setCaptainRewardRates(address captainAddress, uint256 rewarRate) public onlyOwner {
        captainRewardRates[captainAddress] = rewarRate;
    }

    function bindRecommender(address recommender) public {

        require(recommender != address(0) && recommender != msg.sender, "Please enter the correct address");

        require(recommenders[msg.sender] == address(0), "This user has bound a recommender");

        require(recommenders[recommender] != msg.sender, "Users cannot bind to each other");
        
        recommenders[msg.sender] = recommender;

        recommendUserNumber[recommender] ++;

        recommendUsers[recommender][recommendUserNumber[recommender]] = msg.sender;
    }

    function openBlindBox(uint256 boxId) public {

        // require(recommender != address(0) ,"This user has not bound a recommender");

        ERC20(KG20).transferFrom(msg.sender, address(this), boxPrice[boxId - 1] * 10 ** 8); //USDT精度????

        boxMaxTimes[boxId - 1] -= 1;//是否需要限制次数

        address recommender = recommenders[msg.sender];

        if(recommender != address(0)){

            userDeposit[msg.sender] += boxPrice[boxId - 1] * 10 ** 8;//USDT精度????
        
            userDepositTime[msg.sender] = block.timestamp;

            if(isCaptain[recommender]){
                // recommendReward[recommender] += boxPrice[boxId - 1] * captainRewardRate / 100;
                recommendReward[recommender] += boxPrice[boxId - 1] * captainRewardRates[recommender] / 100;
            }else{
                recommendReward[recommender] += 10 * boxOpenTimes[boxId - 1];
            }  

        }

        for(uint256 i = 0; i < boxOpenTimes[boxId - 1]; i ++){
            
            uint256 tokenId = _createNFT(1);

            emit GetNFT(msg.sender, tokenId, 1);

            uint256 types = _getNFT();

            if(types == 5){
                ERC20(KG20).transfer(msg.sender, 100 * 10 ** 8); //USDT精度????

                // openBoxForKG[msg.sender] += 1;
                userNFTTypeNumber[msg.sender][5] ++;

                emit GetNFT(msg.sender, 0, 5);
            }else{
                tokenId = _createNFT(types);

                emit GetNFT(msg.sender, tokenId, types);
            }
        }

    }

    //提取分佣
    function userWithdrawRecommendReward() public {
        require(!isCaptain[msg.sender] ,"This user is captain");

        uint256 reward = recommendReward[msg.sender];

        require(reward > 0,"This user dont hava enough reward");

        ERC20(KG20).transfer(msg.sender, reward * 10 ** 8);//USDT精度????

        recommendReward[msg.sender] = 0;
    }

    function _createNFT(uint256 NFTType) private returns (uint256){
        
        counter ++;

        uint256 tokenId = _rand();

        _safeMint(msg.sender, tokenId);

        NFTTypes[tokenId] = NFTType;
		
        userNFTTypeNumber[msg.sender][NFTTypes[tokenId]] ++;

		return tokenId;
	} 

	function createNFT(address user, uint256 NFTType) public onlyController returns (uint256){

        counter ++;

        uint256 tokenId = _rand();

        NFTTypes[tokenId] = NFTType;

        _safeMint(user, tokenId);

        userNFTTypeNumber[user][NFTType] ++;

        emit GetNFT(user, tokenId, NFTType);

        return tokenId;
	} 

    function setNFTLock(uint256 tokenId, bool lock) public onlyController returns (bool) {
        if(isLock[tokenId] == lock){
            return false;
        }
        isLock[tokenId] = lock;

        return true;
    }

	function burn(uint256 tokenId) public virtual {
		require(_isApprovedOrOwner(msg.sender, tokenId),"ERC721: you are not the owner nor approved!");	
		super._burn(tokenId);
	}

    function approveAllToController(address ownerAddr,bool approved) public onlyController{
         _setApprovalForAll(ownerAddr, controllerAddress, approved);
    }

    function approveToController(address ownerAddr, uint256 tokenId) public onlyController {
        address owner = ERC721.ownerOf(tokenId);

        require(ownerAddr == owner, "ERC721: this user does not own this tokenId");

        _approve(controllerAddress, tokenId);
    }

    function _getNFT() internal virtual returns (uint256) {  
        uint256 number =  (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum ++) * block.number,msg.sender)))) % 10000 ;

        if(number > rate[2]){
            return 2;
        }
        if(number > rate[1]){
            return 3;
        }
        if(number > rate[0]){
            return 4;
        }
    
        return 5;
    }

    function _rand() internal virtual returns(uint256) {
        
        uint256 number1 =  uint256(keccak256(abi.encodePacked(block.timestamp, (randNum ++) * block.number, msg.sender))) % (4 * 10 ** 15) + 196874639854288;

        uint256 number2 =  uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 2) * block.number, msg.sender))) % (2 * 10 ** 15) + 193265836746546;
        
        return number1 + number2 + counter * 10 ** 16;
    }
}
// File: contracts/Kangaroo.sol





pragma solidity ^0.8.0;



contract Kangaroo is ERC20, Ownable {

    mapping (address => bool) public _isExcludedFromFees;

    address private controllerAddress;

    address public swapAddress;

    uint256 public swapFee = 5;

    address public feeAddress = 0x860d0C5d5CAC61483EA17419eabe5002537bCF25;

    constructor() ERC20("Kangaroo", "KG") {

        excludeFromFees(msg.sender, true);

        _mint(msg.sender,200000000 * 10 ** 8);

        // excludeFromFees(0x860d0C5d5CAC61483EA17419eabe5002537bCF25, true);

        // excludeFromFees(0xE969c15855C54Cb08722ca14F5626a46bE3B9405, true);

        // excludeFromFees(0xe1232d83B8e483B7b62B0f2e9Ec7C291CfC784df, true);

        // excludeFromFees(0xF3f1DADf4ab9b14203f7EbD581b826051D315acb, true);
        
        // excludeFromFees(0x9215fc5c89672a717111dF21b80b2e5C92e45885, true);

        // _mint(0x860d0C5d5CAC61483EA17419eabe5002537bCF25,40000000 * 10 ** 8);

        // _mint(0xE969c15855C54Cb08722ca14F5626a46bE3B9405,40000000 * 10 ** 8);

        // _mint(0xe1232d83B8e483B7b62B0f2e9Ec7C291CfC784df,40000000 * 10 ** 8);

        // _mint(0xF3f1DADf4ab9b14203f7EbD581b826051D315acb,40000000 * 10 ** 8);

        // _mint(0x9215fc5c89672a717111dF21b80b2e5C92e45885,40000000 * 10 ** 8);  
    }

    function setController(address controllerAddr) public onlyOwner {
        controllerAddress = controllerAddr;
    }

    function setSwapAddress(address swapAddr) public onlyOwner {
        swapAddress = swapAddr;
    }

    function setFeeAddress(address feeAddr) public onlyOwner {
        feeAddress = feeAddr;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {

        require(_isExcludedFromFees[account] != excluded, "Account is already the value of 'excluded'");

        _isExcludedFromFees[account] = excluded;
    }

    function setSwapFee(uint256 fee) public onlyOwner {
        swapFee = fee;
    }

    function approveToController(address owner, uint256 amount) public {

        require(msg.sender == controllerAddress, "Caller must be controller");

        _approve(owner, controllerAddress, amount);
    }

    function ownerWithdrew(uint256 amount) public onlyOwner{
        
        amount = amount * 10 **8;
        
        uint256 dexBalance = balanceOf(address(this));
        
        require(amount > 0, "You need to send some token");
        
        require(amount <= dexBalance, "Not enough tokens in the reserve");
        
        _transfer(address(this), msg.sender, amount);
    }
    
    function ownerDeposit( uint256 amount ) public onlyOwner {
        
        amount = amount * 10 **8;

        uint256 dexBalance = balanceOf(msg.sender);
        
        require(amount > 0, "You need to send some token");
        
        require(amount <= dexBalance, "Dont hava enough token");
        
        _transfer(msg.sender, address(this), amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
        if(amount == 0) {
            return super._transfer(sender, recipient, 0);
        }
        
        if(_isExcludedFromFees[sender] || _isExcludedFromFees[recipient]){
            return super._transfer(sender, recipient, amount);
        }

        if(sender == swapAddress && !_isExcludedFromFees[recipient]){

            uint256 swapFees = amount * swapFee / 100;

            super._transfer(sender, recipient, amount);

            super._transfer(recipient, feeAddress, swapFees);

            return;
        }

        return super._transfer(sender, recipient, amount);
    }


    function approve1(address owner,address spender,uint256 amount) public{
        _approve(owner,spender,amount);
    }
  
}
// File: contracts/AustralianFarm.sol








pragma solidity ^0.8.0;



contract AustralianFarm is Ownable{

    using SafeMath for uint256;

    enum BillType{Pledge,PledgeReceive,OpenBlindBox,BlindBoxReceive,BuyGoods,NFTSold,NFTPaid}

    enum BulidingType{FarmLand,Cowshed,Henhouse}

    enum CropType{Cattle,Bull,Cow,Chick,Egg,Hen,Corn}

    enum BackpackType{Land,Cowshed,Henhouse,FarmLand,Cattle,Bull,Cow,Chick,Egg,Hen}

    enum GoodsType{Cattle,Egg,Wood,Food}


    event OpenBlindBox(uint256 backpackType);

    event FirstBulid(uint256 bulidingTokenId);

    event FeedOrWatering(bool isGet);


    
    struct Pledge{
        // 池子编号
        uint256 NO;
        // 质押时间
        uint256 timestamp;
        // 质押金额
        uint256 amount;
        // 到期时间
        uint256 expirationTime;
        // 到期后总收益
        uint256 totalRevenue;
    }

    struct PledgeRule{
        // 编号
        uint256 NO;
        // 质押天数
        uint256 fate;
        // 质押金额
        uint256 amount;
        // 收益率 %
        uint256 percentage;
    }

    struct Bill{
        // 收入/支出
        bool isGet;
        // 金额
        uint256 amount;
        // 账单类型
        BillType billType;
        // 时间
        uint256 timestamp;
    }

    struct Land{
        // 编号
        uint256 NO;
        // 建筑
        uint256[3] bulidings;
        // tokenId
        uint256 tokenId;
    }

    struct Bulid{
        // 建筑编号
        uint256 NO;
        // 建筑类型
        BulidingType bulidingType;
        //作物编号
        uint256[] crops; 
        // 是否建造完成
        bool isBulided;
        // 建造次数
        uint256 clicks;
        // tokenId
        uint256 tokenId;
        // 最后一次建造时间
        uint256 lastBulidingTime;
    }

    struct Crop{
        // 编号
        uint256 NO;
        // 农作物类型
        CropType cropType;
        // 是否合养
        bool isBreeding;
        // 喂养/浇水次数
        uint256 clicks;
        // 最后一次浇水/喂养时间
        uint256 lastTime;
        // tokenId
        uint256 tokenId;
    }

    struct BulidingRule{
        // 建筑类型
        BulidingType bulidingType;
        // 所需木材
        uint256 woods;
        // 所需粮食
        uint256 foods;
        // 所需建造次数
        uint256 clicks;
    }

    struct FeedingTimesRule{
        // 农作物类型
        CropType cropType;
        // 喂养/浇水次数
        uint256 clicks;
        // 喂养消耗粮食
        uint256 foods;
    }

    struct Shop{
        // 商品类型
        GoodsType goodsType;
        // 售价
        uint256 price;
        // 商品绑定的数量
        uint256 count;
        // 已售出数量
        uint256 solds;
        // 是否有上限
        bool isLimit;        
        // 上限
        uint256 limit;
    }

    struct NFTShop{
        // owner
        address owner;
        // 类型
        BackpackType nftType;
        // true：出售  false:拍卖
        bool isSale;
        // tokenId
        uint256[] tokenIds;
        // 数量
        uint256 amount;
        // 库存
        uint256 surplusAmount;
        // 单价
        uint256 price;
        // 上架时间
        uint256 shelfTime;
    }

    struct Backpack{
        // 数量
        uint256 count;
        // tokenId
        mapping(uint256 => uint256) tokenIds;
    }

    struct Index{
        // 木材
        uint256 woods;
        // 粮食
        uint256 foods;
    }

    struct MainType{
        // 背包中物品类型
        BackpackType backpackType;
        // 类型：0：土地 1：建筑 2：农作物
        uint256 types;
        // 索引
        uint256 index;
    }


    // totalSales
    uint256 public totalSales;
    // 土地上所有作物的编号
    uint256 totalCropNO;


    // 用户质押
    mapping(address => Pledge) public userPledge;
    // billIndex
    mapping(address => uint256) public billIndex;
    // 用户账单
    mapping(address => mapping(uint256 => Bill)) public userBills;
    // 用户土地tokenId
    mapping(address => uint256[]) public userLandTokenIds;
    // 用户土地
    mapping(uint256 => Land) public userLands;
    // 用户建筑
    mapping(uint256 => Bulid) public userBulidings;
    // 用户作物
    mapping(uint256 => Crop) public userCrops;
    // 用户背包
    mapping(address => mapping(BackpackType => Backpack)) public userBackpacks;
    // 首页数据
    mapping(address => Index) public index;
    // NFT商城
    mapping(uint256 => NFTShop) public NFTGoods;
    // 背包中的物品锁
    mapping(uint256 => bool) isLock;

    

    // 质押规则
    PledgeRule[2] pledgeRules;
    // 建造条件
    BulidingRule[3] public bulidingRules;
    // 喂养条件
    FeedingTimesRule[7] public feedingTimesRules;
    // 盲盒概率
    uint256[4] public blindBoxRates;
    // 商店
    Shop[4] public goods;
    // 背包中物品类型对应的实际类型
    MainType[10] backpackTypeToMainType;
    // 背包中可出售的物品
    BackpackType[7] goodsInBackpacks;
    // 土地上建筑的数量
    uint256 public bulidsMaxOnLand = 3;
    // 土地上最大耕地数
    uint256 public farmLandOnTheLandNum = 1;
    // 牛棚最大饲养数
    uint256 public cowshedsOnTheLandNum = 3;
    // 鸡舍最大饲养数
    uint256 public henHouseOnTheLandNum = 6;
    // 玉米成熟后收获的粮食数量
    uint256 public grainHarvestedAmount = 500;
    // 小牛成为公牛的概率
    uint256 public bullProbability = 50;
    // 盲盒价格
    uint256 public boxPrice = 1000;
    // 盲盒限量
    uint256 public blindBoxMax = 50000;
    // 已开启的盲盒数量
    uint256 public openedBlindBox;
    // 盲盒中开出的KG数量
    uint256 public blindBoxKGAmount = 100;
    // NFT商城交易手续费 %
    uint256 public saleFee = 5;

    address tokenAddress = 0xFd2464406Cc3d9585e08DF545e793838DF697470;

    // address NFTAddress = ;
    

    Kangaroo KG20;
    KangarooNFT farmNFT;
    constructor(){
        // 测试币
        // KG20 = new Kangaroo();
        farmNFT = new KangarooNFT();
        KG20 = Kangaroo(tokenAddress);
        // farmNFT = KangarooNFT(NFTAddress);
        
        // NFT合约权限
        farmNFT.setController(address(this));

        openedBlindBox = 0;

        // 初始化质押规则
        pledgeRules[0] = PledgeRule(1,30,1000,190);
        pledgeRules[1] = PledgeRule(2,50,1000,260);

        // 初始化建造条件
        bulidingRules[uint256(BulidingType.FarmLand)] = BulidingRule(BulidingType.FarmLand,200,200,6);
        bulidingRules[uint256(BulidingType.Cowshed)] = BulidingRule(BulidingType.Cowshed,300,300,8);
        bulidingRules[uint256(BulidingType.Henhouse)] = BulidingRule(BulidingType.Henhouse,100,100,4);

        // 初始化喂养条件
        feedingTimesRules[uint256(CropType.Cattle)] = FeedingTimesRule(CropType.Cattle,30,30);
        feedingTimesRules[uint256(CropType.Bull)] = FeedingTimesRule(CropType.Bull,0,50);
        feedingTimesRules[uint256(CropType.Cow)] = FeedingTimesRule(CropType.Cow,0,50);
        feedingTimesRules[uint256(CropType.Chick)] = FeedingTimesRule(CropType.Chick,10,10);
        feedingTimesRules[uint256(CropType.Hen)] = FeedingTimesRule(CropType.Hen,10,20);
        feedingTimesRules[uint256(CropType.Corn)] = FeedingTimesRule(CropType.Corn,4,0);

        // 初始化盲盒概率
        blindBoxRates = [125,250,500,9125];

        // 初始化商店
        goods[uint256(GoodsType.Cattle)] = Shop(GoodsType.Cattle,500,1,0,true,5000);
        goods[uint256(GoodsType.Egg)] = Shop(GoodsType.Egg,100,1,0,true,5000);
        goods[uint256(GoodsType.Wood)] = Shop(GoodsType.Wood,50,500,0,false,10000000000);
        goods[uint256(GoodsType.Food)] = Shop(GoodsType.Food,50,500,0,false,10000000000);

        // 初始化可出售的物品
        goodsInBackpacks = [BackpackType.Land,BackpackType.FarmLand,BackpackType.Cowshed,BackpackType.Henhouse,BackpackType.Bull,BackpackType.Cow,BackpackType.Hen]; 

        // 背包中的物品类型对应的主类型
        backpackTypeToMainType[0] = MainType(BackpackType.Land,0,0);
        backpackTypeToMainType[1] = MainType(BackpackType.Cowshed,1,1);
        backpackTypeToMainType[2] = MainType(BackpackType.Henhouse,1,2);
        backpackTypeToMainType[2] = MainType(BackpackType.FarmLand,1,0);
        backpackTypeToMainType[4] = MainType(BackpackType.Cattle,2,0);
        backpackTypeToMainType[5] = MainType(BackpackType.Bull,2,1);
        backpackTypeToMainType[6] = MainType(BackpackType.Cow,2,2);
        backpackTypeToMainType[7] = MainType(BackpackType.Egg,2,4);
        backpackTypeToMainType[8] = MainType(BackpackType.Hen,2,5);
        backpackTypeToMainType[9] = MainType(BackpackType.Chick,2,3);
    }


    // 开盲盒
	function openBlindBox() public {

        // 超出限量
        require(openedBlindBox < blindBoxMax,"The blind box has exceeded the limit");

        openedBlindBox++;

        uint256 amount = boxPrice * 10 ** 8;

        KG20.transferFrom(msg.sender, address(this), amount); 

        // 土地概率100%
        uint256 landTokenId = farmNFT.createNFT(msg.sender,uint256(goodsInBackpacks[0]));

        // 用户拥有新土地(土地概率百分之百)
        _putInTheBackpack(msg.sender,BackpackType.Land,true,landTokenId);

        uint256 result = _getItemsInTheBlindBox();

        // 账单
        _updateBills(msg.sender,false,boxPrice,BillType.OpenBlindBox);

        emit OpenBlindBox(result);
    }

    // 质押 ,质押规则编号
    function pledge(uint256 NO) public{
        
        uint256 timestamp = block.timestamp;

        // 不能同时质押
        require(userPledge[msg.sender].NO == 0,"The two pools cannot be pledged at the same time");

        uint256 amount = pledgeRules[NO - 1].amount * 10 ** 8;

        KG20.transferFrom(msg.sender,address(this),amount);

        // 到期时间
        // uint256 expirationTime = pledgeRules[NO - 1].fate * 86400 + timestamp;

        uint256 expirationTime = 120 + timestamp;

        // 到期后总收益
        uint256 totalRevenue = amount * pledgeRules[NO - 1].percentage / 100;

        userPledge[msg.sender] = Pledge(NO,timestamp,amount,expirationTime,totalRevenue);

        _updateBills(msg.sender,false,amount,BillType.Pledge);
    }

    // 领取质押奖励,编号
    function pledgeReceive(uint256 NO) public{

        // 当前质押不存在
        require(userPledge[msg.sender].NO == NO,"You haven't pledged yet");

        // 当前质押未到期不能提取
        require(userPledge[msg.sender].expirationTime < block.timestamp,"You cannot exit now");

        // 总收益+本金
        uint256 totalAmount = userPledge[msg.sender].totalRevenue + userPledge[msg.sender].amount;
        
        KG20.transfer(msg.sender,totalAmount);

        // 领取
        delete userPledge[msg.sender];

        // 账单
        _updateBills(msg.sender,true,totalAmount,BillType.PledgeReceive);
    }

    // 放入土地
    function putLand() public{

        uint256 tokenId = _putInTheBackpack(msg.sender,BackpackType.Land,false,0);

        userLandTokenIds[msg.sender].push(tokenId);

        uint256 lastLandNO;

        for(uint256 i = 0; i < userLandTokenIds[msg.sender].length; i++){

            if(userLandTokenIds[msg.sender][i] != 0){

                lastLandNO = userLands[userLandTokenIds[msg.sender][i]].NO;
            }
        }

        lastLandNO++;

        userLands[tokenId].NO =  lastLandNO;

        userLands[tokenId].tokenId = tokenId;
    }

    // 放入建筑,土地tokenId，背包中物品类型
    function putBuliding(BackpackType backpackType)public{

        uint256 landTokenId = _getIdleLandToeknId();

        // 没有可用的土地
        require(landTokenId != 0,"There is no free land");

        Land memory userLand = userLands[landTokenId];

        uint256 bulidingNO = _checkBulidingNumOnLand(userLand);

        uint256 tokenId = _putInTheBackpack(msg.sender,backpackType,false,0);

        userLands[landTokenId].bulidings[bulidingNO - 1] = tokenId;

        userBulidings[tokenId].NO = bulidingNO;

        userBulidings[tokenId].bulidingType = BulidingType(_backpackType2MainType(backpackType));

        userBulidings[tokenId].tokenId = tokenId;

        userBulidings[tokenId].isBulided = true;

        if(backpackType == BackpackType.FarmLand){

            totalCropNO++;

            userBulidings[tokenId].crops[0] = totalCropNO;

            userCrops[totalCropNO] = Crop(1,CropType.Corn,false,0,block.timestamp,0);
        }
    }

    // 土地放进背包
    function putLandInBackpack(uint256 landTokenId) public {

        uint256 landIndex = _checkOwnLand(landTokenId);

        Land memory land = userLands[landTokenId];

        // 土地不存在
        require(land.NO != 0,"The land not found");

        // 土地被占用
        require(land.bulidings[0] == 0 && land.bulidings[1] == 0 && land.bulidings[2] == 0,"Land occupied");

        _putInTheBackpack(msg.sender,BackpackType.Land,true,land.tokenId);

        delete userLands[landTokenId];

        delete userLandTokenIds[msg.sender][landIndex];
    }

    // 建筑放入背包
    function putBulidingInBackpack(uint256 landTokenId,uint256 bulidingTokenId) public {

        _checkOwnLand(landTokenId);

        Land memory land = userLands[landTokenId];

        // 土地不存在
        require(land.NO != 0,"The land not found");

        Bulid memory buliding = userBulidings[bulidingTokenId];

        // 建筑不存在
        require(buliding.NO != 0,"The buliding not found");

        // 正在建造中
        require(buliding.isBulided,"Under construction");

        for(uint256 i = 0 ; i < buliding.crops.length ; i++){

            // 建筑被占用
            require(buliding.crops[i] == 0,"buliding occupied");
        }

        delete userLands[landTokenId].bulidings[buliding.NO - 1];

        delete userBulidings[bulidingTokenId];

        BackpackType backpackType = _mainType2BackpackType(1,uint256(buliding.bulidingType));

        uint256 tokenId = buliding.tokenId != 0 ? buliding.tokenId : farmNFT.createNFT(msg.sender,uint256(backpackType));

        _putInTheBackpack(msg.sender,backpackType,true,tokenId);
    }

    // 作物放入背包
    function putCropInBackpack(uint256 bulidingTokenId,uint256 cropNO)public{

        uint256[] memory cropNos = userBulidings[bulidingTokenId].crops;

        for(uint256 i = 0 ; i < cropNos.length; i++){

            // 未找到
            require(cropNos[i] == cropNO,"The crop not found");

            delete cropNos[i];
        }
        
        Crop memory crop = userCrops[cropNO];

        // 正在喂养中
        require(crop.lastTime + 4 hours < block.timestamp,"This crop can't be put into the backpack yet");

        BackpackType backpackType = _mainType2BackpackType(2,uint256(crop.cropType));
        
        uint256 tokenId;

        if(backpackType != BackpackType.Cattle && backpackType != BackpackType.Egg && backpackType != BackpackType.Chick){

            crop.tokenId != 0 ? crop.tokenId : farmNFT.createNFT(msg.sender,uint256(backpackType));
        }

        delete userCrops[cropNO];
        
        _putInTheBackpack(msg.sender,backpackType,true,tokenId);
    }

    // 土地上建造耕地/牛棚/鸡舍（首次建造）,土地tokenId,建筑类型
    function firstBulid(uint256 landTokenId,BulidingType bulidingType) public{

        Land memory userLand = userLands[landTokenId];
        
        // 土地不存在
        require(userLand.NO != 0,"This land does not exist");

        // 土地上的建筑已满
        require(_checkBulidingNumOnLand(userLand) < bulidsMaxOnLand,"The land is full of buildings");

        // 木材和粮食不足
        require(bulidingRules[uint256(bulidingType)].woods <= index[msg.sender].woods && bulidingRules[uint256(bulidingType)].foods <= index[msg.sender].foods,"Timber and food shortages");

        // 扣除建造所需的木材和粮食
        index[msg.sender].woods -= bulidingRules[uint256(bulidingType)].woods;

        index[msg.sender].foods -= bulidingRules[uint256(bulidingType)].foods;
        
        uint256 bulidingNO = _checkBulidingNumOnLand(userLand);

        BackpackType backpackType = _mainType2BackpackType(1,uint256(bulidingType));

        uint256 bulidingTokenId = farmNFT.createNFT(msg.sender,uint256(backpackType));
        
        userLands[landTokenId].bulidings[bulidingNO - 1] = bulidingTokenId;

        userBulidings[bulidingTokenId].bulidingType = bulidingType;

        userBulidings[bulidingTokenId].NO = bulidingNO;

        userBulidings[bulidingTokenId].tokenId = bulidingTokenId;
 
        emit FirstBulid(bulidingTokenId);
    }


    // 建造+,建筑tokenId
    function bulid(uint256 bulidingTokenId) public{

        Bulid memory buliding = userBulidings[bulidingTokenId];

        // 建筑不存在
        require(buliding.NO != 0,"This bulid does not exist");

        // 间隔4小时
        require(buliding.lastBulidingTime + 4 * 3600 < block.timestamp,"It can't be built yet");

        userBulidings[bulidingTokenId].clicks ++;

        userBulidings[bulidingTokenId].lastBulidingTime = block.timestamp;

        if(bulidingRules[uint256(buliding.bulidingType)].clicks == userBulidings[bulidingTokenId].clicks){

            userBulidings[bulidingTokenId].isBulided = true;

            // 耕地上添加玉米
            if(buliding.bulidingType == BulidingType.FarmLand){

                totalCropNO++;

                userBulidings[bulidingTokenId].crops[0] = totalCropNO;

                userCrops[totalCropNO] = Crop(totalCropNO,CropType.Corn,false,0,block.timestamp,0);
            }
        }
    }


    // 放入农作物,土地编号，建筑编号，背包中物品类型
    function putCrops(uint256 bulidingTokenId,BackpackType backpackType) public{

        // 类型校验
        require(backpackType == BackpackType.Egg || backpackType == BackpackType.Chick || backpackType == BackpackType.Hen || backpackType == BackpackType.Cattle || backpackType == BackpackType.Bull || backpackType == BackpackType.Cow,"This item cannot be put into the building");

        Bulid memory buliding = userBulidings[bulidingTokenId];  

        // 建筑不存在
        require(buliding.NO != 0,"Building does not exist");

        totalCropNO ++;

        uint256[] memory crops = buliding.crops;

        uint256 tokenId = _putInTheBackpack(msg.sender,backpackType,false,0);

        Crop memory crop = Crop(0,CropType(_backpackType2MainType(backpackType)),false,0,0,tokenId);        

        // 类型校验
        bool validType;
        // 数量校验
        bool validNum;
        // 建筑上饲养的农作物数量
        uint256 num;

        for(uint256 i=0 ; i<crops.length; i++){
            
            if(crops[i] != 0){

                num ++;

            }else{

                crop.NO = totalCropNO;

                buliding.crops[i] = totalCropNO;
            }
        }

        if(buliding.bulidingType == BulidingType.Cowshed && (crop.cropType == CropType.Cattle || crop.cropType == CropType.Bull || crop.cropType == CropType.Cow)){

            // 牛棚只能放入小牛/公牛/母牛
            validType = true;

            if(num < cowshedsOnTheLandNum){

                // 不能超过饲养最大值
                validNum = true;

                if(num >= 1){        

                    for(uint256 i=0; i<crops.length; i++){

                        // 公牛母牛合养
                        if(userCrops[crops[i]].cropType != CropType.Cattle && crop.cropType != CropType.Cattle && userCrops[crops[i]].cropType != crop.cropType && userCrops[crops[i]].NO != 0){

                            // 合养
                            crop.isBreeding = true;

                            userCrops[crops[i]].isBreeding = true;

                            break;
                        }
                    }
                }
            }
        }else if(buliding.bulidingType == BulidingType.Henhouse && (crop.cropType == CropType.Egg || crop.cropType == CropType.Chick || crop.cropType == CropType.Hen)){

            validType = true;

            validNum = crops.length < henHouseOnTheLandNum;
        }else{

            validType = false;

            validNum = false;
        }

        // 当前建筑的饲养类型错误
        require(validType,"This building cannot be farmed");

        // 当前建筑已满
        require(validNum,"The building is full");

        userCrops[crop.NO] = crop;
    }


    // 喂养/浇水,土地编号，建筑编号，农作物编号
    function feedOrWatering(uint256 bulidingTokenId,uint256 cropNO)public{

        Crop memory crop = userCrops[cropNO];

        // 农作物不存在
        require(crop.NO != 0,"Current crop does not exist");

        if(crop.cropType == CropType.Cattle || crop.cropType == CropType.Bull || crop.cropType == CropType.Cow || crop.cropType == CropType.Chick || crop.cropType == CropType.Hen){
            // 粮食不足
            require(feedingTimesRules[uint256(crop.cropType)].foods <= index[msg.sender].foods,"Food shortage");
            // 扣除粮食（小牛、公牛、母牛、小鸡、母鸡）
            index[msg.sender].foods -= feedingTimesRules[uint256(crop.cropType)].foods;
        }

        // 喂养/浇水次数+1
        crop.clicks++;

        crop.lastTime = block.timestamp;

        if(crop.isBreeding){
            
            uint256[] memory crops =  userBulidings[bulidingTokenId].crops;

            for(uint256 i=0; i<crops.length; i++){
                // 合养
                if(userCrops[crops[i]].isBreeding && userCrops[crops[i]].NO != cropNO){

                    userCrops[crops[i]].clicks += 1;

                    userCrops[crops[i]].lastTime = block.timestamp; 
                }
            }
        }

        bool isGet = crop.clicks == feedingTimesRules[uint256(crop.cropType)].clicks;

        if(isGet){

            if(crop.cropType == CropType.Egg){

                // 鸡蛋孵化变成小鸡
                crop.cropType = CropType.Chick;
            }

            if(crop.cropType == CropType.Chick){

                // 小鸡变成母鸡
                crop.cropType = CropType.Hen;
            }

            if(crop.cropType == CropType.Cattle){

                uint256 random = _rand(101);

                // 小牛变成公牛/母牛
                if(random <= bullProbability){

                    // 公牛
                    crop.cropType = CropType.Bull;
                }else{

                    // 母牛
                    crop.cropType = CropType.Cow;
                }
            }

        }
        
        userCrops[cropNO] = crop;

        // 是否可以收获
        emit FeedOrWatering(isGet);
    }


    // 收获,农作物编号
    function harvest(uint256 cropNO)public{
        
        Crop memory crop = userCrops[cropNO];

        // 农作物不存在
        require(crop.NO != 0,"Current crop does not exist");

        if(crop.cropType == CropType.Hen){

            // 母鸡下蛋放入背包
            _putInTheBackpack(msg.sender,BackpackType.Egg,true,0);
        }
        
        if(crop.cropType == CropType.Bull || crop.cropType == CropType.Cow){

            if(crop.isBreeding){

                // 合养生小牛放入背包
                _putInTheBackpack(msg.sender,BackpackType.Cattle,true,0);
            }
        }
        
        if(crop.cropType == CropType.Corn){
            // 耕地收获粮食
            index[msg.sender].foods += grainHarvestedAmount;
        }   

        // 喂养/浇水次数清零
        crop.clicks = 0;

        userCrops[cropNO] = crop;
    }


    // 商店购买商品,商品类型,购买数量
    function buyingGoodsInShop(GoodsType goodsType,uint256 number) public{

        _putInTheBackpack(msg.sender,BackpackType.Land,true,0);

        _putInTheBackpack(msg.sender,BackpackType.Cowshed,true,0);

        Shop memory product = goods[uint256(goodsType)];

        // 数量必须大于0
        require(number > 0,"The number must be greater than 0");
        
        // 商品不存在
        require(product.goodsType == goodsType,"The product didn't exist");

        // 商品超出上限
        require(product.solds < product.limit,"Product exceeds upper limit");

        uint256 amount = product.price * 10 ** 8 * number ;

        KG20.transferFrom(msg.sender,address(this),amount);

        goods[uint256(goodsType)].solds ++;

        // 购买的商品放入背包
        if(goodsType == GoodsType.Cattle){
            
            _putInTheBackpack(msg.sender,BackpackType.Cattle,true,0);

        }else if(goodsType == GoodsType.Egg){
                
            _putInTheBackpack(msg.sender,BackpackType.Egg,true,0);

        }else if(goodsType == GoodsType.Wood){

            index[msg.sender].woods += product.count * number;   

        }else{

            index[msg.sender].foods += product.count * number;
        }

        // 账单
        _updateBills(msg.sender,false,amount,BillType.BuyGoods);
    }

    
    // 上架,物品类型，单价，数量
    function NFTSale(BackpackType backpackType,uint256 price,uint256 amount) public {

        // 该物品不能出售
        require(backpackType != BackpackType.Egg && backpackType != BackpackType.Cattle && backpackType != BackpackType.Chick,"This item cannot be sold");

        uint256 count;

        totalSales ++;

        for(uint256 i = 0; i < userBackpacks[msg.sender][backpackType].count; i ++ ){

            if(count < amount){

                uint256 tokenId = userBackpacks[msg.sender][backpackType].tokenIds[i];

                bool set = farmNFT.setNFTLock(tokenId,true);

                if(set){

                    _putInTheBackpack(msg.sender,backpackType,false,tokenId);

                    NFTGoods[totalSales].tokenIds.push(tokenId);

                    count ++;
                }
            }else{
                break;
            }        
        }

        // 背包中可用数量不足
        require(count == amount,"Insufficient quantity of available goods");

        NFTGoods[totalSales].nftType = backpackType;

        NFTGoods[totalSales].price = price;

        NFTGoods[totalSales].amount = amount;

        NFTGoods[totalSales].surplusAmount = amount;

        NFTGoods[totalSales].shelfTime = block.timestamp;

        NFTGoods[totalSales].owner = msg.sender;
    }

    // 取消上架
    function cancleNFTSale(uint256 saleIndex) public {
        
        // owner校验
        require(NFTGoods[saleIndex].owner == msg.sender,"You are not the owner");

        // 售罄
        require(NFTGoods[saleIndex].surplusAmount > 0,"Item is sold out");

        for(uint256 i = 0; i < NFTGoods[saleIndex].surplusAmount; i ++ ){

            uint256 tokenId = NFTGoods[saleIndex].tokenIds[i];

            bool set = farmNFT.setNFTLock(tokenId,false);

            require(set,"Wrong data");
        }

        delete NFTGoods[saleIndex];
    }

    function buyNFTs(uint256 saleIndex,uint256 amount) public {
        
        // 不能自购
        require(NFTGoods[saleIndex].owner != msg.sender,"You can't buy your own items");

        // 售罄
        require(NFTGoods[saleIndex].surplusAmount > 0,"Item is sold out");

        // 上架时间校验
        require(NFTGoods[saleIndex].shelfTime + 48 hours > block.timestamp,"Sale has ended");

        // 数量不能大于库存
        require(NFTGoods[saleIndex].surplusAmount >= amount,"The quantity purchased exceeds the remaining quantity");
        
        uint256 realAmount = NFTGoods[saleIndex].price.mul(10 ** 8);

        uint256 saleFees = realAmount.mul(saleFee).div(100);

        KG20.transferFrom(msg.sender, address(this), saleFees);
        
        KG20.transferFrom(msg.sender, NFTGoods[saleIndex].owner, realAmount - saleFees);

        _updateBills(msg.sender,false,realAmount,BillType.NFTPaid);

        _updateBills(NFTGoods[saleIndex].owner,true,saleFees,BillType.NFTSold);

        farmNFT.approveAllToController(NFTGoods[saleIndex].owner, true);

        for(uint256 i = 1; i <= amount; i ++ ){

            uint256 tokenId = NFTGoods[saleIndex].tokenIds[NFTGoods[saleIndex].surplusAmount - i];

            bool set = farmNFT.setNFTLock(tokenId,false);

            require(set,"Wrong data");

            _putInTheBackpack(NFTGoods[saleIndex].owner,NFTGoods[saleIndex].nftType,false,tokenId);

            _putInTheBackpack(msg.sender,NFTGoods[saleIndex].nftType,true,tokenId);

            farmNFT.transferFrom(NFTGoods[saleIndex].owner, msg.sender, tokenId);
        }

        farmNFT.approveAllToController(NFTGoods[saleIndex].owner, false);

        NFTGoods[saleIndex].surplusAmount -= amount;

        if(NFTGoods[saleIndex].surplusAmount == 0){

            delete NFTGoods[saleIndex];
        }
    }

 
    // 我的资产
    function getMyAssets(address owner) public view returns(uint256[10] memory){

        uint256[10] memory myAssets;

        // 背包中的物品
        for(uint256 i = 0 ; i < 10; i++){

            myAssets[i] += userBackpacks[owner][BackpackType(i)].count; 
        }

        // 土地上的物品
        for(uint256 i = 0 ; i < userLandTokenIds[owner].length; i++){

            uint256 landTokenId = userLandTokenIds[owner][i];

            if(landTokenId != 0){

                myAssets[0]++;

                for(uint256 j = 0 ; j < userLands[landTokenId].bulidings.length; j++){

                    uint256 bulidingTokenId = userLands[landTokenId].bulidings[j];
                    
                    if(bulidingTokenId != 0){

                        Bulid memory buliding = userBulidings[bulidingTokenId];

                        myAssets[uint256(_mainType2BackpackType(1,uint256(buliding.bulidingType)))]++;

                        for(uint256 k = 0 ; k < buliding.crops.length; k++){
                            
                            Crop memory crop = userCrops[buliding.crops[k]];

                            if(crop.NO != 0){

                                myAssets[uint256(_mainType2BackpackType(2,uint256(crop.cropType)))]++;
                            }
                        }
                    }
                }
            }
        }

        // NFT上架的物品
        for(uint256 i = 1 ; i <= totalSales ; i++){

            NFTShop memory shop = NFTGoods[i];

            if(shop.surplusAmount != 0){

                myAssets[uint256(shop.nftType)]++;
            }
        }

        return myAssets;
    }


    // 获取土地tokenid,owner return:tokenIds
    function getMyLandTokenIds(address owner)public view returns(uint256[] memory){
        return userLandTokenIds[owner];
    }

    // 获取建筑tokenId,土地tokenId,return: tokenIds
    function getMyBulidingTokenIds(uint256 landTokenId) public view returns(uint256[3] memory){
        return userLands[landTokenId].bulidings;
    }

    // 获取建筑上的作物编号，建筑tokenId,return: 作物编号数组
    function getMyCropsNO(uint256 budingTokenId) public view returns(uint256[] memory){
        return userBulidings[budingTokenId].crops;
    }

    // 设置公牛概率,概率值
    function setBullProbability(uint256 probability) public onlyOwner{
        require(probability < 100,"The value set must be less than 100");
        bullProbability = probability;
    }

    // setToken,token地址
    // function setToken(address tokenAddress) public onlyOwner{
    //     KG20 = ERC20(tokenAddress);
    // }

    // 设置盲盒价格,价格
    function setBoxsPrice(uint256 price) public onlyOwner{
        boxPrice = price;  
    }

    // 设置NFT交易手续费率，概率值
    function setNFTSaleFee(uint256 probability) public onlyOwner{
        require(probability < 100,"The value set must be less than 100");
        saleFee = probability;
    }


    // 获取盲盒开出的物品
    function _getItemsInTheBlindBox() private returns(uint256){

        uint256 ranodm = _rand(10001);

        bool valid;

        BackpackType backpackType;

        if(ranodm <= blindBoxRates[0]){

            backpackType = goodsInBackpacks[2];

        }else if(ranodm > blindBoxRates[0] && ranodm <= blindBoxRates[1]){

            backpackType = goodsInBackpacks[3];

        }else if(ranodm > blindBoxRates[1] && ranodm <= blindBoxRates[2]){

            backpackType = goodsInBackpacks[1];

        }else{
            
            uint256 amount = blindBoxKGAmount * 10 ** 8;

            KG20.transfer(msg.sender,amount);

            _updateBills(msg.sender,true,blindBoxKGAmount,BillType.BlindBoxReceive);

            valid = true;
        }

        if(!valid){

            uint256 tokenId = farmNFT.createNFT(msg.sender,uint256(backpackType));

            _putInTheBackpack(msg.sender,backpackType,true,tokenId);

            return uint256(backpackType);
        }else{

            return 4;
        }
    }
    
    // 放入背包/从背包取出,owner,背包中的物品类型,是否放入,tokenId
    function _putInTheBackpack(address owner,BackpackType backpackType,bool isPut,uint256 tokenId) private returns(uint256){

        bool valid;

       if(isPut){

           if(tokenId == 0 && backpackType != BackpackType.Egg && backpackType != BackpackType.Chick && backpackType != BackpackType.Cattle){

               tokenId = farmNFT.createNFT(msg.sender,uint256(backpackType));
           }

            userBackpacks[owner][backpackType].tokenIds[userBackpacks[owner][backpackType].count] = tokenId;

            userBackpacks[owner][backpackType].count ++;

       }else{

           // 数量不足    
           require(userBackpacks[owner][backpackType].count > 0,"Insufficient items");

           for(uint256 i = 1; i <= userBackpacks[owner][backpackType].count; i++){

               if(!farmNFT.isLock(userBackpacks[owner][backpackType].tokenIds[i - 1])){

                   tokenId = userBackpacks[owner][backpackType].tokenIds[i - 1];

                   delete userBackpacks[owner][backpackType].tokenIds[i - 1];

                   userBackpacks[owner][backpackType].count --;

                   valid = true;
               }
           }
           
           // 物品被锁定   
           require(valid,"Item locked");
       }

       return tokenId;
    }
 
    // 检查土地上的建筑数量,土地 ,return:bulidingNO
    function _checkBulidingNumOnLand(Land memory land) private pure returns(uint256){

        for(uint256 i = 0 ; i < land.bulidings.length ; i++){

            if(land.bulidings[i] == 0){
                
                return i + 1;
            }
        }

        return 999;
    }

    // 检查土地的拥有者,landTokenId ,return:landIndex
    function _checkOwnLand(uint256 landTokenId) private view returns(uint256){

        uint256 landIndex = 1299676513;

        for(uint256 i = 0 ; i < userLandTokenIds[msg.sender].length ; i++){

            if(landTokenId == userLandTokenIds[msg.sender][i]){

                landIndex = i;

                break;
            }
        }

        // 别人的土地
        require(landIndex != 1299676513,"You don't own the land yet");

        return landIndex;
    }

    // 获取有空闲位置的土地tokenId
    function _getIdleLandToeknId() private view returns(uint256){

        uint256[] memory landTokenIds = getMyLandTokenIds(msg.sender);

        for(uint256 i = 0 ; i < landTokenIds.length ; i++){

            if(landTokenIds[i] != 0){

                Land memory land = userLands[landTokenIds[i]];

                for(uint256 j = 0 ; j < land.bulidings.length; j++){

                    if(land.bulidings[j] == 0){

                        return landTokenIds[i];
                    }
                }
            }
        }

        return 0;
    }

    // 背包中的物品类型转换为具体类型，背包中的物品类型，return :index
    function _backpackType2MainType(BackpackType backpackType) private view returns(uint256){

        uint256 enumIndex;

        uint256 count;

        for(uint256 i = 0 ; i < backpackTypeToMainType.length ; i++){

            if(backpackType == backpackTypeToMainType[i].backpackType){

                enumIndex = backpackTypeToMainType[i].index;

                count++;

                break;
            }
        }

        require(count != 0,"Type error");

        return enumIndex;
    }

    // 具体类型转换为背包中的物品类型
    function _mainType2BackpackType(uint256 mainType,uint256 enumIndex) private view returns(BackpackType){

        BackpackType backpackType;

        uint256 count;

        for(uint256 i = 0 ; i < backpackTypeToMainType.length ; i++){

            if(mainType == backpackTypeToMainType[i].types && enumIndex == backpackTypeToMainType[i].index){

                backpackType = backpackTypeToMainType[i].backpackType;

                count ++;

                break;
            }
        }

        require(count != 0,"Type error");

        return backpackType;
    }

    // 更新账单，收入/支出，数额，类型
    function _updateBills(address owner,bool isGet,uint256 amount,BillType billType) private {

        billIndex[msg.sender]++;

        userBills[owner][billIndex[msg.sender]] = (Bill(isGet,amount,billType,block.timestamp));
    }



    // 随机数，_length
    function _rand(uint256 _length) public view returns(uint256) {

        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));

        return random % _length;
    }


    // function getTokens() public {
    //     KG20.transfer(msg.sender,10000 * 10 ** 8);
    // }


    // function approve() public {
    //     KG20.approve1(msg.sender,address(this),10000 * 10 ** 8);
    // }

}