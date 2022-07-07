/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// File: contracts/support/safemath.sol

pragma solidity >=0.4.16 <0.9.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title SafeMath64
 * @dev SafeMath library implemented for uint64
 */
library SafeMath64 {
    function mul(uint64 a, uint64 b) internal pure returns (uint64) {
        if (a == 0) {
            return 0;
        }
        uint64 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint64 a, uint64 b) internal pure returns (uint64) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint64 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint64 a, uint64 b) internal pure returns (uint64) {
        assert(b <= a);
        return a - b;
    }

    function add(uint64 a, uint64 b) internal pure returns (uint64) {
        uint64 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title SafeMath32
 * @dev SafeMath library implemented for uint32
 */
library SafeMath32 {
    function mul(uint32 a, uint32 b) internal pure returns (uint32) {
        if (a == 0) {
            return 0;
        }
        uint32 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint32 a, uint32 b) internal pure returns (uint32) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint32 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32) {
        assert(b <= a);
        return a - b;
    }

    function add(uint32 a, uint32 b) internal pure returns (uint32) {
        uint32 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title SafeMath16
 * @dev SafeMath library implemented for uint16
 */
library SafeMath16 {
    function mul(uint16 a, uint16 b) internal pure returns (uint16) {
        if (a == 0) {
            return 0;
        }
        uint16 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint16 a, uint16 b) internal pure returns (uint16) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint16 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint16 a, uint16 b) internal pure returns (uint16) {
        assert(b <= a);
        return a - b;
    }

    function add(uint16 a, uint16 b) internal pure returns (uint16) {
        uint16 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title SafeMath8
 * @dev SafeMath library implemented for uint8
 */
library SafeMath8 {
    function mul(uint8 a, uint8 b) internal pure returns (uint8) {
        if (a == 0) {
            return 0;
        }
        uint8 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint8 a, uint8 b) internal pure returns (uint8) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint8 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint8 a, uint8 b) internal pure returns (uint8) {
        assert(b <= a);
        return a - b;
    }

    function add(uint8 a, uint8 b) internal pure returns (uint8) {
        uint8 c = a + b;
        assert(c >= a);
        return c;
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

// File: @openzeppelin/contracts/utils/Address.sol


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


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

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
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
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
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
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
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

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
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

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
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
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
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
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
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
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
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
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
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
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
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
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

// File: contracts/Farmer.sol


pragma solidity >=0.4.16 <0.9.0;




contract FarmerWaifu is ERC721 {
    using SafeMath for uint256;
    using SafeMath64 for uint64;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    struct Farmer {
        /**
    @dev
    - dna: almost unique combination of traits for the waifu
    - birthday: when the farmer was minted
    - immunityUntil: time when the waifu stops being immune to desease
    - sickUntil: time when the waifu stops being sick and can work again
    - durability: time when the waifu stops being able to farm and becomes art
    - level: the level of the waifu determines its WP (waifu power)
  */
        uint256 dna;
        uint256 sellPrice;
        uint64 id;
        uint64 immunityUntil;
        uint64 sickUntil;
        uint64 durability;
        uint64 availableFrom;
        uint64 licensedUntil;
        uint8[6] waifuPowers;
        bool forSale;
    }

    Farmer[] internal farmers;
    uint64[] internal forSale;

    address internal owner = msg.sender;
    address internal support;
    mapping(address => bool) internal games;
    mapping(address => uint64) internal ownerFarmerCount;
    mapping(address => uint64[]) internal ownerToFarmers;
    mapping(uint64 => address) internal farmerToOwner;
    mapping(uint64 => uint256) internal farmerAtOwnerIndex;
    mapping(uint64 => uint256) internal farmerToSaleIndex;
    uint64 public farmerCount = 0;

    constructor() ERC721("Darling Waifu farmer", "DWfarmer") {
        forSale.push(2**63);
    }

    modifier onlySupport() {
        require(msg.sender == support, "You are not the support address.");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner address.");
        _;
    }

    modifier onlyGame() {
        require(games[msg.sender], "You are not the game.");
        _;
    }

    function setSupport(address _support) external onlyOwner {
        support = _support;
    }

    function setGame(address _game) external onlySupport {
        games[_game] = true;
    }

    function unsetGame(address _game) external onlySupport {
        games[_game] = false;
    }

    function mint(
        address _newOwner,
        uint64 _id,
        uint256 _dna,
        uint64 _durability,
        uint8[6] calldata _waifuPowers
    ) external onlyGame {
        if (
            _id == 0 ||
            _id == 100 ||
            _id == 500 ||
            _id == 1000 ||
            _id % 5000 == 0
        ) {
            farmers.push(
                Farmer(
                    0,
                    0,
                    _id,
                    0,
                    0,
                    2**63,
                    0,
                    0,
                    [250, 250, 250, 250, 250, 250],
                    false
                )
            );
        } else {
            farmers.push(
                Farmer(
                    _dna,
                    0,
                    _id,
                    0,
                    0,
                    _durability,
                    0,
                    0,
                    _waifuPowers,
                    false
                )
            );
        }

        _transfer(address(0), _newOwner, _id);
    }

    function increaseCounter(uint64 _amount) external onlyGame {
        farmerCount = farmerCount.add(_amount);
    }

    function balanceOf(address _owner) public view override returns (uint256) {
        return ownerFarmerCount[_owner];
    }

    function ownerOf(uint256 _farmerId) public view override returns (address) {
        return farmerToOwner[uint64(_farmerId)];
    }

    function totalSupply() external view returns (uint256) {
        return farmerCount;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _farmerId
    ) internal override {
        uint64 _id = uint64(_farmerId);
        if (_from != address(0)) {
            require(farmerToOwner[_id] == _from);
            ownerFarmerCount[_from] = ownerFarmerCount[_from].sub(1);
            ownerToFarmers[_from][farmerAtOwnerIndex[_id]] = 10**18;
        }
        farmerToOwner[_id] = _to;
        ownerFarmerCount[_to] = ownerFarmerCount[_to].add(1);
        ownerToFarmers[_to].push(_id);
        farmerAtOwnerIndex[_id] = ownerToFarmers[_to].length.sub(1);
        emit Transfer(_from, _to, _id);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _farmerId
    ) public override {
        require(_from == msg.sender || games[msg.sender]);
        if (games[msg.sender]) {
            farmers[_farmerId].forSale = false;
        } else {
            require(
                farmers[_farmerId].durability < 1000,
                "This waifu is still alive. You need to wait for her to expire."
            );
        }
        _transfer(_from, _to, _farmerId);
    }

    function sell(uint64 _farmerId, uint256 _sellPrice) external {
        require(
            msg.sender == farmerToOwner[_farmerId],
            "You are not the owner of such farmer."
        );
        if (!farmers[_farmerId].forSale) {
            if (farmerToSaleIndex[_farmerId] == 0) {
                forSale.push(_farmerId);
                farmerToSaleIndex[_farmerId] = forSale.length - 1;
            }
            farmers[_farmerId].forSale = true;
        }
        farmers[_farmerId].sellPrice = _sellPrice;
    }

    function unsell(uint64 _farmerId) external {
        require(
            msg.sender == farmerToOwner[_farmerId],
            "You are not the owner of such farmer."
        );
        farmers[_farmerId].forSale = false;
    }

    function burn(uint64 _farmerId) external {
        require(
            msg.sender == farmerToOwner[_farmerId] || games[msg.sender],
            "You are not the owner of such farmer nor the game contract."
        );
        farmers[_farmerId].forSale = false;
        _transfer(farmerToOwner[_farmerId], address(0), _farmerId);
    }

    function sellPrice(uint256 _farmerId) external view returns (uint256) {
        require(farmers[_farmerId].forSale, "Farmer waifu not for sale.");
        return farmers[_farmerId].sellPrice;
    }

    function list(uint256 _offset) external view returns (uint256[13] memory) {
        // Max 12 items
        uint256[13] memory _forSale;
        uint256 _quantity = 0;
        uint256 i;
        for (i = _offset + 1; i < forSale.length && _quantity < 12; i++) {
            if (
                farmers[forSale[i]].forSale &&
                farmerToSaleIndex[forSale[i]] == i
            ) {
                _forSale[_quantity] = forSale[i];
                _quantity++;
            }
        }
        _forSale[12] = i - 1;
        return _forSale;
    }

    function getDNA(uint256 _farmerId) external view returns (uint256) {
        return farmers[_farmerId].dna;
    }

    function getTTL(uint256 _farmerId) external view returns (uint64) {
        return farmers[_farmerId].durability;
    }

    function getSickness(uint256 _farmerId) external view returns (uint64) {
        return farmers[_farmerId].sickUntil;
    }

    function getWP(uint256 _farmerId) external view returns (uint8[6] memory) {
        return farmers[_farmerId].waifuPowers;
    }

    function getLicense(uint256 _farmerId) external view returns (uint64) {
        return farmers[_farmerId].licensedUntil;
    }

    function getAvailability(uint256 _farmerId) external view returns (bool) {
        return uint64(block.timestamp) >= farmers[_farmerId].availableFrom;
    }

    function getFarmersOf(address _owner)
        external
        view
        returns (Farmer[] memory)
    {
        Farmer[] memory _farmers;
        for (uint256 i = 0; i < ownerFarmerCount[_owner]; i++) {
            _farmers[i] = farmers[ownerToFarmers[_owner][i]];
        }
        return _farmers;
    }

    function getFarmerIdsOf(address _owner)
        external
        view
        returns (uint64[] memory)
    {
        return ownerToFarmers[_owner];
    }

    function getFarmer(uint256 _farmerId)
        external
        view
        returns (Farmer memory)
    {
        return farmers[_farmerId];
    }

    function getRarity(uint256 _farmerId) external view returns (uint256) {
        uint256 maxWP = 0;
        for (uint256 i = 0; i < farmers[_farmerId].waifuPowers.length; i++) {
            if (farmers[_farmerId].waifuPowers[i] > maxWP)
                maxWP = farmers[_farmerId].waifuPowers[i];
        }
        if (maxWP == 250) return 4;
        return maxWP.div(50);
    }

    function setUsed(uint256 _farmerId, uint16 _age) external {
        require(games[msg.sender]);
        farmers[_farmerId].availableFrom = uint64(block.timestamp + 24 hours);
        farmers[_farmerId].durability = farmers[_farmerId].durability.sub(_age);
    }

    function infect(uint256 _farmerId) external onlyGame {
        farmers[_farmerId].sickUntil = uint64(block.timestamp + 48 hours);
    }

    function heal(uint256 _farmerId, uint256 _hours) external onlyGame {
        farmers[_farmerId].sickUntil = uint64(
            block.timestamp + _hours * 1 hours
        );
    }

    function extendLifespan(uint256 _farmerId, uint64 _points)
        external
        onlyGame
    {
        farmers[_farmerId].durability = farmers[_farmerId].durability + _points;
    }

    function setLicensed(uint256 _farmerId, uint256 _days) external onlyGame {
        if (farmers[_farmerId].licensedUntil > uint64(block.timestamp))
            farmers[_farmerId].licensedUntil = uint64(
                farmers[_farmerId].licensedUntil + _days * 1 days
            );
        else
            farmers[_farmerId].licensedUntil = uint64(
                block.timestamp + _days * 1 days
            );
    }
}

// File: contracts/MetaStore.sol


pragma solidity >=0.4.16 <0.9.0;


contract MetaStore {
    using SafeMath64 for uint64;
    mapping(uint256 => uint64) public licenses;
    mapping(address => uint256) public walletToDays;
    mapping(address => uint256) public walletToEvolution;
    address internal support;
    address internal harvester;
    address internal licenser;
    FarmerWaifu farmer;

    constructor(address _farmerAddress) {
        support = msg.sender;
        farmer = FarmerWaifu(_farmerAddress);
    }

    modifier onlySupport() {
        require(msg.sender == support, "Forbidden");
        _;
    }

    modifier onlyHarvester() {
        require(msg.sender == harvester, "Forbidden");
        _;
    }

    modifier onlyLicenser() {
        require(msg.sender == licenser, "Forbidden");
        _;
    }

    function import200Licenses(uint256 _offset) external onlySupport {
        for (
            uint256 i = _offset;
            i < farmer.farmerCount() && i < _offset + 200;
            i++
        ) {
            uint64 license = farmer.getLicense(i);
            if (
                license > uint64(block.timestamp) &&
                farmer.ownerOf(i) != address(0)
            ) {
                uint64 remaining = license - uint64(block.timestamp);
                uint64 temp = 30;
                if (remaining <= 8 days) temp = 7;
                else if (remaining <= 16 days) temp = 15;
                if (!farmer.getAvailability(i)) temp -= 1;
                licenses[i] = temp;
            }
        }
    }

    function setSupport(address _support) external onlySupport {
        support = _support;
    }

    function setHarvester(address _harvester) external onlySupport {
        harvester = _harvester;
    }

    function setLicenser(address _licenser) external onlySupport {
        licenser = _licenser;
    }

    function setUsed(uint256 _farmerId) external onlyHarvester {
        licenses[_farmerId] = licenses[_farmerId].sub(1);
    }

    function addLicense(uint256 _farmerId, uint64 _days) external onlyLicenser {
        licenses[_farmerId] = licenses[_farmerId].add(_days);
    }

    function evolve(address _target) external onlyHarvester {
        uint256 hour = block.timestamp / 1 days;
        if (walletToDays[_target] < hour) {
            walletToDays[_target] = hour;
            walletToEvolution[_target] = walletToEvolution[_target] + 1;
        }
    }

    function resetEvolution(address _target) external onlyHarvester {
        walletToEvolution[_target] = 0;
    }
}

// File: contracts/Tractor.sol


pragma solidity >=0.4.16 <0.9.0;




contract Tractor is ERC721 {
    using SafeMath for uint256;
    using SafeMath64 for uint64;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    struct TractorStruct {
        /**
      @title This struct holds the information of a tractor NFT
      @dev
      - builtAt: when the tractor was minted
      - brokenUntil: time when the tractor stops being broken and can function again
      - durability: time when the tractor stops being able to function properly and becomes art
      - level: the level of the tractor determines its capacity for carrying waifus
    */
        uint256 sellPrice;
        uint64 id;
        uint64 brokenUntil;
        uint64 durability;
        uint64 availableFrom;
        uint8 level;
        bool forSale;
    }

    TractorStruct[] internal tractors;
    uint64[] internal forSale;

    address internal owner = msg.sender;
    address internal support;
    mapping(address => bool) internal games;
    mapping(address => uint64) internal ownerTractorCount;
    mapping(address => uint64[]) internal ownerToTractors;
    mapping(uint64 => address) internal tractorToOwner;
    mapping(uint64 => uint256) internal tractorAtOwnerIndex;
    mapping(uint64 => uint256) internal tractorToSaleIndex;
    uint64 public tractorCount = 0;

    modifier onlySupport() {
        require(msg.sender == support, "You are not the support address.");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner address.");
        _;
    }

    modifier onlyGame() {
        require(games[msg.sender], "You are not the game.");
        _;
    }

    function setSupport(address _support) external onlyOwner {
        support = _support;
    }

    function setGame(address _game) external onlySupport {
        games[_game] = true;
    }

    function unsetGame(address _game) external onlySupport {
        games[_game] = false;
    }

    constructor() ERC721("Darling Waifu Tractor", "DWTractor") {
        forSale.push(2**63);
    }

    function totalSupply() external view returns (uint256) {
        return tractorCount;
    }

    function mint(
        address _newOwner,
        uint64 _id,
        uint64 _durability,
        uint8 _level
    ) external onlyGame {
        tractors.push(TractorStruct(0, _id, 0, _durability, 0, _level, false));
        _transfer(address(0), _newOwner, _id);
    }

    function increaseCounter(uint64 _amount) external onlyGame {
        tractorCount = tractorCount.add(_amount);
    }

    function balanceOf(address _owner) public view override returns (uint256) {
        return ownerTractorCount[_owner];
    }

    function ownerOf(uint256 _tractorId)
        public
        view
        override
        returns (address)
    {
        return tractorToOwner[uint64(_tractorId)];
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _tractorId
    ) internal override {
        uint64 _id = uint64(_tractorId);
        if (_from != address(0)) {
            require(tractorToOwner[_id] == _from);
            ownerTractorCount[_from] = ownerTractorCount[_from].sub(1);
            ownerToTractors[_from][tractorAtOwnerIndex[_id]] = 10**18;
        }
        tractorToOwner[_id] = _to;
        ownerTractorCount[_to] = ownerTractorCount[_to].add(1);
        ownerToTractors[_to].push(_id);
        tractorAtOwnerIndex[_id] = ownerToTractors[_to].length.sub(1);
        emit Transfer(_from, _to, _id);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tractorId
    ) public override {
        require(_from == msg.sender || games[msg.sender]);
        if (games[msg.sender]) {
            tractors[_tractorId].forSale = false;
        } else {
            require(
                tractors[_tractorId].durability < 1000,
                "This tractor is still working. You need to wait for it to expire."
            );
        }
        _transfer(_from, _to, _tractorId);
    }

    function sellPrice(uint256 _tractorId) external view returns (uint256) {
        return tractors[_tractorId].sellPrice;
    }

    function sell(uint64 _tractorId, uint256 _sellPrice) external {
        require(
            msg.sender == tractorToOwner[_tractorId],
            "You are not the owner of such tractor."
        );
        if (!tractors[_tractorId].forSale) {
            if (tractorToSaleIndex[_tractorId] == 0) {
                forSale.push(_tractorId);
                tractorToSaleIndex[_tractorId] = forSale.length - 1;
            }
            tractors[_tractorId].forSale = true;
        }
        tractors[_tractorId].sellPrice = _sellPrice;
    }

    function unsell(uint64 _tractorId) external {
        require(
            msg.sender == tractorToOwner[_tractorId],
            "You are not the owner of such tractor."
        );
        tractors[_tractorId].forSale = false;
    }

    function burn(uint64 _tractorId) external {
        require(
            msg.sender == tractorToOwner[_tractorId] || games[msg.sender],
            "You are not the owner of such tractor nor the game contract."
        );
        tractors[_tractorId].forSale = false;
        _transfer(tractorToOwner[_tractorId], address(0), _tractorId);
    }

    function list(uint256 _offset) external view returns (uint256[13] memory) {
        // Max 12 items
        uint256[13] memory _forSale;
        uint256 _quantity = 0;
        uint256 i;
        for (i = _offset + 1; i < forSale.length && _quantity < 12; i++) {
            if (
                tractors[forSale[i]].forSale &&
                tractorToSaleIndex[forSale[i]] == i
            ) {
                _forSale[_quantity] = forSale[i];
                _quantity++;
            }
        }
        _forSale[12] = i - 1;
        return _forSale;
    }

    function getSpace(uint256 _tractorId) external view returns (uint256) {
        return tractors[_tractorId].level;
    }

    function getTTL(uint256 _tractorId) external view returns (uint64) {
        return tractors[_tractorId].durability;
    }

    function getBrokenUntil(uint256 _tractorId) external view returns (uint64) {
        return tractors[_tractorId].brokenUntil;
    }

    function getAvailability(uint256 _tractorId) external view returns (bool) {
        return uint64(block.timestamp) >= tractors[_tractorId].availableFrom;
    }

    function getTractorsOf(address _owner)
        external
        view
        returns (TractorStruct[] memory)
    {
        TractorStruct[] memory _tractors;
        for (uint256 i = 0; i < ownerTractorCount[_owner]; i++) {
            _tractors[i] = tractors[ownerToTractors[_owner][i]];
        }
        return _tractors;
    }

    function getTractorIdsOf(address _owner)
        external
        view
        returns (uint64[] memory)
    {
        return ownerToTractors[_owner];
    }

    function getTractor(uint256 _tractorId)
        external
        view
        returns (TractorStruct memory)
    {
        return tractors[_tractorId];
    }

    function setUsed(uint256 _tractorId, uint16 _age) external onlyGame {
        tractors[_tractorId].availableFrom = uint64(block.timestamp + 24 hours);
        tractors[_tractorId].durability = tractors[_tractorId].durability.sub(
            _age
        );
    }

    function malfunction(uint256 _tractorId) external onlyGame {
        tractors[_tractorId].brokenUntil = uint64(block.timestamp + 3 days);
    }

    function repair(uint256 _tractorId, uint256 _hours) external onlyGame {
        tractors[_tractorId].brokenUntil = uint64(
            block.timestamp + _hours * 1 hours
        );
    }
}

// File: contracts/Crew.sol


pragma solidity >=0.4.16 <0.9.0;



contract Crew {
    using SafeMath for uint256;
    using SafeMath64 for uint64;
    using SafeMath32 for uint32;
    using SafeMath8 for uint8;
    struct Formation {
        string name;
        uint256[] farmers;
        uint256[] tractors;
        uint32[6] wp;
        uint64 durability;
        uint64 availability;
        uint64 licenses;
        uint8 space;
        uint8 rarity;
    }

    Formation[] public formations;
    FarmerWaifu farmer;
    Tractor tractor;
    MetaStore store;

    address support;

    mapping(address => bool) isGame;
    mapping(address => uint256[]) ownerToFormations;
    mapping(uint256 => address) public formationToOwner;
    mapping(uint256 => uint256) public farmerToFormation;
    mapping(uint256 => uint256) public tractorToFormation;

    bool public canGetDamaged;
    uint64 constant tractorDurabilityWeight = 3;
    uint64 constant farmerDurabilityWeight = 2;

    constructor(
        address _farmerAddress,
        address _tractorAddress,
        address _storeAddress
    ) {
        farmer = FarmerWaifu(_farmerAddress);
        tractor = Tractor(_tractorAddress);
        store = MetaStore(_storeAddress);
        support = msg.sender;
        uint256[] memory _temp;
        uint32[6] memory _wps;
        formations.push(
            Formation("Genesis formation", _temp, _temp, _wps, 0, 0, 0, 0, 0)
        );
    }

    modifier onlySupport() {
        require(msg.sender == support, "Permission denied.");
        _;
    }

    modifier onlyGame() {
        require(isGame[msg.sender], "Permission denied.");
        _;
    }

    modifier onlyOwner(uint256 _formationId) {
        require(
            formationToOwner[_formationId] == msg.sender,
            "Permission denied."
        );
        _;
    }

    // Contract parameters
    function setSupport(address _support) external onlySupport {
        support = _support;
    }

    function setGame(address _game, bool _isGame) external onlySupport {
        isGame[_game] = _isGame;
    }

    function setDamageStatus(bool _newDamage) external onlySupport {
        canGetDamaged = _newDamage;
    }

    // Write functions
    function createCrew(
        string calldata _name,
        uint256[] calldata _farmerIds,
        uint256[] calldata _tractorIds
    ) external returns (uint256) {
        uint256[] memory _temp;
        uint32[6] memory _wps = [
            uint32(0),
            uint32(0),
            uint32(0),
            uint32(0),
            uint32(0),
            uint32(0)
        ];
        formations.push(Formation(_name, _temp, _temp, _wps, 0, 0, 0, 0, 0));
        formationToOwner[formations.length - 1] = msg.sender;
        ownerToFormations[msg.sender].push(formations.length - 1);
        _addTractors(formations.length - 1, _tractorIds);
        _addWaifus(formations.length - 1, _farmerIds);
        return formations.length - 1;
    }

    function updateFormation(
        uint256 _formationId,
        uint256[] calldata _farmerIds,
        uint256[] calldata _tractorIds,
        bool _updateName,
        string calldata _newName
    ) external onlyOwner(_formationId) {
        _addTractors(_formationId, _tractorIds);
        _addWaifus(_formationId, _farmerIds);
        if (_updateName) formations[_formationId].name = _newName;
    }

    // Modify the state of a crew
    function _addWaifus(uint256 _formationId, uint256[] calldata _farmerIds)
        internal
    {
        if (_farmerIds.length == 0) return;
        // Verify available seats
        require(
            formations[_formationId].space >=
                _farmerIds.length + formations[_formationId].farmers.length,
            "Insufficient space."
        );
        uint64 ttl;
        uint64 licenses = 0;
        uint64 durability = formations[_formationId].durability *
            uint64(
                formations[_formationId].tractors.length *
                    tractorDurabilityWeight +
                    formations[_formationId].farmers.length *
                    farmerDurabilityWeight
            );
        uint32[6] memory wps = [
            uint32(0),
            uint32(0),
            uint32(0),
            uint32(0),
            uint32(0),
            uint32(0)
        ];
        uint8[6] memory _wps;
        for (uint8 i; i < _farmerIds.length; i++) {
            // The farmer shall not:
            // - Belong to a different person
            // - Be already in a formation
            // - Have less than 1000 of durability
            // - Be sick
            // - Be temporarily unusable
            require(
                farmer.ownerOf(_farmerIds[i]) ==
                    formationToOwner[_formationId] &&
                    farmerToFormation[_farmerIds[i]] == 0 &&
                    farmer.getTTL(_farmerIds[i]) >= 1000 &&
                    farmer.getSickness(_farmerIds[i]) <= block.timestamp &&
                    farmer.getAvailability(_farmerIds[i]),
                "The farmer does not belong to the crew owner."
            );
            formations[_formationId].farmers.push(_farmerIds[i]);
            farmerToFormation[_farmerIds[i]] = _formationId;
            _wps = farmer.getWP(_farmerIds[i]);
            ttl = farmer.getTTL(_farmerIds[i]);
            // Immortal waifus do not count for this
            durability +=
                (ttl > 100000 ? formations[_formationId].durability : ttl) *
                farmerDurabilityWeight;
            licenses += store.licenses(_farmerIds[i]);
            // Update total wps
            for (uint8 j; j < 6; j++) wps[j] += _wps[j];
        }
        // Update crew's licenses
        if (licenses > 0) formations[_formationId].licenses += licenses;

        // Update crew's durability
        formations[_formationId].durability =
            durability /
            uint64(
                formations[_formationId].tractors.length *
                    tractorDurabilityWeight +
                    formations[_formationId].farmers.length *
                    farmerDurabilityWeight
            );

        // Update crew's WPs
        for (uint8 i; i < 6; i++) {
            if (wps[i] > 0) formations[_formationId].wp[i] += wps[i];
        }
    }

    function _addTractors(uint256 _formationId, uint256[] calldata _tractorIds)
        internal
    {
        if (_tractorIds.length == 0) return;
        uint64 durability = formations[_formationId].durability *
            uint64(
                formations[_formationId].tractors.length *
                    tractorDurabilityWeight +
                    formations[_formationId].farmers.length *
                    farmerDurabilityWeight
            );
        uint8 space = 0;
        uint8 tractorSpace;
        uint8[5] memory rarities = [0, 0, 0, 0, 0];

        // Verify maximum amount of 10 tractors
        require(
            _tractorIds.length + formations[_formationId].tractors.length <= 10,
            "Maximum amount of tractors reached"
        );

        // Check current rarity
        for (uint8 i; i < formations[_formationId].tractors.length; i++) {
            tractorSpace = uint8(
                tractor.getSpace(formations[_formationId].tractors[i])
            );
            rarities[tractorSpace - 1]++;
        }

        // Add tractors
        for (uint8 i; i < _tractorIds.length; i++) {
            // The tractor shall not:
            // - Belong to a different person
            // - Be already in a formation
            // - Have less than 1000 of durability
            // - Be broken
            // - Be temporarily unusable
            require(
                tractor.ownerOf(_tractorIds[i]) ==
                    formationToOwner[_formationId] &&
                    tractorToFormation[_tractorIds[i]] == 0 &&
                    tractor.getTTL(_tractorIds[i]) > 1000 &&
                    tractor.getBrokenUntil(_tractorIds[i]) <= block.timestamp &&
                    tractor.getAvailability(_tractorIds[i]),
                "The tractor does not meet the requirements."
            );
            formations[_formationId].tractors.push(_tractorIds[i]);
            tractorToFormation[_tractorIds[i]] = _formationId;
            tractorSpace = uint8(tractor.getSpace(_tractorIds[i]));
            durability +=
                tractor.getTTL(_tractorIds[i]) *
                tractorDurabilityWeight;
            space += tractorSpace;
            rarities[tractorSpace - 1]++;
        }

        // Update the crew's spacing
        formations[_formationId].space += space;

        // Update crew's durability
        formations[_formationId].durability =
            durability /
            uint64(
                formations[_formationId].tractors.length *
                    tractorDurabilityWeight +
                    formations[_formationId].farmers.length *
                    farmerDurabilityWeight
            );

        // Update rarity
        uint8 max = rarities[0];
        uint8 mode = 0;
        for (uint8 i = 1; i < 5; i++) {
            if (rarities[i] > max) {
                max = rarities[i];
                mode = i;
            }
        }
        if (formations[_formationId].rarity != mode)
            formations[_formationId].rarity = mode;
    }

    function dissolve(uint256 _formationId) external onlyOwner(_formationId) {
        Formation memory formation = formations[_formationId];
        uint64 initialDurability = 0;
        //Calculate initial durability
        for (uint8 i; i < formation.farmers.length; i++) {
            uint64 ttl = farmer.getTTL(formation.farmers[i]);
            initialDurability +=
                (ttl > 100000 ? formations[_formationId].durability : ttl) *
                farmerDurabilityWeight;
        }
        for (uint8 i; i < formation.tractors.length; i++) {
            initialDurability +=
                tractor.getTTL(formation.tractors[i]) *
                tractorDurabilityWeight;
        }
        initialDurability = initialDurability.div(
            uint64(
                formation.farmers.length *
                    farmerDurabilityWeight +
                    formation.tractors.length *
                    tractorDurabilityWeight
            )
        );
        uint64 globalConsumption = initialDurability.sub(formation.durability);
        for (uint8 i; i < formation.farmers.length; i++) {
            // Delete farmer relationship
            farmerToFormation[formation.farmers[i]] = 0;
            // Clear licenses for farmer
            while (store.licenses(formation.farmers[i]) > 0)
                store.setUsed(formation.farmers[i]);
            // Proportionally reduce the mortal waifu's durability
            uint64 ttl = farmer.getTTL(formation.farmers[i]);
            if (ttl <= 100000) {
                uint64 consumption = ttl.mul(globalConsumption).div(
                    initialDurability
                );
                if (consumption > 40000) {
                    farmer.setUsed(formation.farmers[i], 40000);
                    consumption -= 40000;
                }
                farmer.setUsed(formation.farmers[i], uint16(consumption));
            } else {
                farmer.setUsed(formation.farmers[i], 0);
            }
        }
        for (uint8 i; i < formation.tractors.length; i++) {
            // Delete tractor relationship
            tractorToFormation[formation.tractors[i]] = 0;

            // Proportionally reduce the durability
            uint64 ttl = tractor.getTTL(formation.tractors[i]);
            uint64 consumption = ttl.mul(globalConsumption).div(
                initialDurability
            );
            if (consumption > 40000) {
                tractor.setUsed(formation.tractors[i], 40000);
                consumption -= 40000;
            }
            tractor.setUsed(formation.tractors[i], uint16(consumption));
        }
        // Delete from formation array for the owner
        uint256[] memory _formations = ownerToFormations[msg.sender];
        delete ownerToFormations[msg.sender];
        for (uint256 i; i < _formations.length; i++) {
            if (_formations[i] != _formationId)
                ownerToFormations[msg.sender].push(_formations[i]);
        }
        // Delete owner relationship
        formationToOwner[_formationId] = address(0);
    }

    function setUsed(
        uint256 _formationId,
        uint64 _age,
        uint64 _licenses
    ) external onlyGame {
        formations[_formationId].availability = uint64(
            block.timestamp + 24 hours
        );
        // Check durability
        require(
            formations[_formationId].durability >= _age,
            "Not enough durability."
        );
        formations[_formationId].durability = formations[_formationId]
            .durability
            .sub(_age);
        require(
            formations[_formationId].licenses >= _licenses,
            "Not enough valid licenses."
        );
        formations[_formationId].licenses -= _licenses;
    }

    function addLicenses(uint256 _formationId, uint64 _licenses)
        external
        onlyGame
    {
        formations[_formationId].licenses += _licenses;
    }

    // Legacy supporting functions
    // Either evolves or resets
    function setEvolution(bool _evolve, address _target) external onlyGame {
        if (_evolve) store.evolve(_target);
        else store.resetEvolution(_target);
    }

    function _getHealthyWaifusAndSickCount(uint256 _formationId)
        internal
        view
        returns (uint256[] memory, uint256)
    {
        if (!canGetDamaged) return (new uint256[](0), 0);
        uint256[] memory tempWaifus = new uint256[](
            formations[_formationId].farmers.length
        );
        uint256 healthyCount = 0;
        for (uint8 i; i < formations[_formationId].farmers.length; i++) {
            if (
                farmer.getSickness(formations[_formationId].farmers[i]) <=
                block.timestamp
            ) {
                tempWaifus[healthyCount++] = formations[_formationId].farmers[
                    i
                ];
            }
        }
        uint256[] memory healthyWaifus = new uint256[](healthyCount);
        for (uint8 i; i < healthyCount; i++) healthyWaifus[i] = tempWaifus[i];
        return (healthyWaifus, tempWaifus.length - healthyCount);
    }

    function _getHealthyTractorsAndBrokenCount(uint256 _formationId)
        internal
        view
        returns (uint256[] memory, uint256)
    {
        if (!canGetDamaged) return (new uint256[](0), 0);
        uint256[] memory tempTractors = new uint256[](
            formations[_formationId].tractors.length
        );
        uint256 healthyCount = 0;
        for (uint8 i; i < formations[_formationId].tractors.length; i++) {
            if (
                tractor.getBrokenUntil(formations[_formationId].tractors[i]) <=
                block.timestamp
            ) {
                tempTractors[healthyCount++] = formations[_formationId]
                    .tractors[i];
            }
        }
        uint256[] memory healthyTractors = new uint256[](healthyCount);
        for (uint8 i; i < healthyCount; i++)
            healthyTractors[i] = tempTractors[i];
        return (healthyTractors, tempTractors.length - healthyCount);
    }

    function getWPAndHealthParams(uint256 _formationId)
        external
        view
        returns (
            uint32[6] memory wp,
            uint256[] memory healthyTractors,
            uint256[] memory healthyWaifus,
            uint256 brokenCount,
            uint256 sickCount
        )
    {
        // Check amount of sick waifus
        (healthyWaifus, sickCount) = _getHealthyWaifusAndSickCount(
            _formationId
        );
        // Check amount of broken tractors
        (healthyTractors, brokenCount) = _getHealthyWaifusAndSickCount(
            _formationId
        );
        wp = formations[_formationId].wp;
        if (canGetDamaged) {
            uint32 multiplier = uint32(
                (healthyWaifus.length)
                    .mul(healthyTractors.length)
                    .mul(10000)
                    .div(formations[_formationId].farmers.length)
                    .div(formations[_formationId].tractors.length)
            );
            for (uint256 i; i < 6; i++)
                wp[i] = wp[i].mul(multiplier).div(10000);
        }
    }

    function getNFTIds(uint256 _formationId)
        external
        view
        returns (uint256[] memory, uint256[] memory)
    {
        return (
            formations[_formationId].tractors,
            formations[_formationId].farmers
        );
    }

    function getFormationIdsOf(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        return ownerToFormations[_owner];
    }

    function getTractorsAndWaifusNumber(uint256 _formationId)
        external
        view
        returns (uint256, uint256)
    {
        return (
            formations[_formationId].tractors.length,
            formations[_formationId].farmers.length
        );
    }
}