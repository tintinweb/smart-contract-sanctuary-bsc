/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

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

// File: @openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/extensions/ERC721URIStorage.sol)

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
        _requireMinted(tokenId);

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
     * @dev See {ERC721-_burn}. This override additionally checks to see if a
     * token-specific URI was set for the token, and if so, it deletes the token URI from
     * the storage mapping.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

// File: FOFPlayerNFT.sol



pragma solidity ^0.8.0;


// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract FOFPlayerNFT is ERC721URIStorage, Ownable {

	uint256 public counter;

    uint256 private randNum = 0;

    mapping(uint256 => uint256) public NFTIDs;

    mapping(uint256 => uint256) public NFTTypes;

    mapping(address => uint256[]) public userNFTIDs;

    mapping(uint256 => uint256) public NFTIDToIndex;

    mapping(address => mapping(uint256 => uint256)) public userNFTTypeNumber;

    mapping(uint256 => uint256) public NFTTypeNumber;

    mapping(uint256 => uint256) public IDToWhtidrawTime;

    mapping(uint256 => bool) private islock;
    

    mapping(address => bool) public isController;


	constructor() ERC721("FOFPlayer", "FOFNFT"){
		counter = 0;
	}

    function addController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = true;
    }

    function removeController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = false;
    }

    modifier onlyController {
         require(isController[msg.sender],"Must be controller");
         _;
    }
    
    function setNFTLock(uint256 tokenId, bool unlock) public onlyController returns (bool) {
        if(islock[tokenId] == unlock){
            return false;
        }
        islock[tokenId] = unlock;

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        require(!islock[tokenId], "ERC721: the NFT is locked");

        uint256 index = NFTIDToIndex[tokenId];

        userNFTIDs[from][index] = 0;

        NFTIDToIndex[tokenId] = userNFTIDs[to].length;

        userNFTIDs[to].push(tokenId);

        userNFTTypeNumber[from][NFTTypes[tokenId]] -= 1;

        userNFTTypeNumber[to][NFTTypes[tokenId]] += 1;
        
        return super._transfer(from, to, tokenId);
    }

    function createNFT(address user, uint256 NFTType) public onlyController returns (uint256){
        counter ++;

        uint256 tokenId = _rand();

        _safeMint(user, tokenId);

        NFTIDs[counter] = tokenId;

        NFTTypes[tokenId] = NFTType;

        NFTIDToIndex[tokenId] = userNFTIDs[user].length;

        userNFTIDs[user].push(tokenId);

        userNFTTypeNumber[user][NFTType] ++;

        NFTTypeNumber[NFTType] ++;

        IDToWhtidrawTime[tokenId] = block.timestamp;
		
        return tokenId;
	} 

    function createNFTs(address[] memory users, uint256 NFTType) public onlyController {

        for(uint256 i = 0; i < users.length; i++){
            createNFT(users[i],NFTType);
        }
        
	}

	function burn(uint256 tokenId) public virtual {
		require(_isApprovedOrOwner(msg.sender, tokenId),"ERC721: you are not the owner nor approved!");

		super._burn(tokenId);

        uint256 index = NFTIDToIndex[tokenId];

        userNFTIDs[msg.sender][index] = 0;

        userNFTTypeNumber[msg.sender][NFTTypes[tokenId]] -= 1;

        NFTTypeNumber[NFTTypes[tokenId]] -= 1;
	}

    function approveToController(address ownerAddr, uint256 tokenId) public onlyController {
        address owner = ownerOf(tokenId);

        require(ownerAddr == owner, "ERC721: this user does not own this tokenId");

        _approve(msg.sender, tokenId);
    }

    function setIDToWhtidrawTime(uint256 tokenId, uint256 time) public onlyController returns(bool){
        IDToWhtidrawTime[tokenId] = time;
        return true;
    }

    function setIDToWhtidrawTimes(uint256[] memory tokenIds, uint256 time) public onlyController returns(bool){

        for(uint256 i = 0; i < tokenIds.length; i++){
            IDToWhtidrawTime[tokenIds[i]] = time;
        }
        
        return true;
    }

    function _rand() internal virtual returns(uint256) {
        
        uint256 number1 =  uint256(keccak256(abi.encodePacked(block.timestamp, (randNum ++) * block.number, msg.sender))) % (4 * 10 ** 8) + 19689868;

        uint256 number2 =  uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 2) * block.number, msg.sender))) % (2 * 10 ** 8) + 19586796;
        
        return number1 + number2 + counter * 10 ** 9;
    }

    function getUserNFTIDs(address user) public view returns(uint256[] memory) {
		return userNFTIDs[user];
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

// File: FOFPlayerController1.sol



pragma solidity ^0.8.0;




contract FOFPlayerController1 is Ownable {

    using SafeMath for uint256;

    event PaymentReceived(address from, uint256 amount);

    event OpenBlindBox(address from, uint256 cost, uint256 awardTypes, Component com);

    event WhtidrawDividends(address from, uint256 profit);


    struct Component {
        uint256 id;

        address holder;

        uint256 types;

        uint256 rarity;

        uint256 speed;

        uint256 stability;

        uint256 controllability;

        uint256 explosive;
    }

    struct Commission {

        uint256 rewardTime;

        uint256 rewardType;

        uint256 reward;
    }

    uint256 public cId;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    uint256 private randNum;

    address public kickbackAddress = 0xc83D33C262B6AaBB559922dd0f2aE5458acD4689;
    address public vipAddress = address(this);
    address public leagueAddress = 0x5da88e4aeA67Be3Fa8D75BB32dCE23F3c50B04b9;
    address public marketingAddress = 0x85c1c55AbDB5bd78D10ce285ef1c1647F7FFADfa;


    mapping(uint256 => Component) public components;

    mapping(address => uint256[]) public myComponentCids;

    mapping(uint256 => uint256) public cIdToIndexs;

    mapping(address => Commission[]) public myCommissions;

    uint256[6] public rareValue = [10,11,12,13,14,15];

    uint256[5] public epicValue = [16,17,18,19,20];

    uint256[10] public storyValue = [21,22,23,24,25,26,27,28,29,30];

    uint256 public blindBoxPrice = 1 * 10 ** 16;


    uint256 public todayDividends;

    uint256 public topDividends = 10 ** 17;

    mapping(uint256 => mapping(uint256 => uint256)) public settlementTimesToDividends;

    uint256[] public settlementTimesToTime;


    mapping(address => bool) public isController;
    
 
    FOFPlayerNFT FPN;

    constructor() {
        // FPN = FOFPlayerNFT(0x8918337F9aF8BC5a70EE804dc284B1d017665B27);
        FPN = FOFPlayerNFT(0x25894eA4eE6576623Fd8383d6D023dc5219E0553);
    }

    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    function addController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = true;
    }

    function removeController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = false;
    }

    modifier onlyController {
        require(isController[msg.sender],"Must be controller");
        _;
    }

    function setFOFPlayerNFT(address _FOFPlayerNFT) public onlyController {
        FPN = FOFPlayerNFT(_FOFPlayerNFT);
    }

    function setKickbackAddress(address _kickbackAddress) public onlyController {
        kickbackAddress = _kickbackAddress;
    }

    function setVipAddress(address _vipAddress) public onlyController {
        vipAddress = _vipAddress;
    }

    function setLeagueAddress(address _leagueAddress) public onlyController {
        leagueAddress = _leagueAddress;
    }

    function setMarketingAddress(address _marketingAddress) public onlyController {
        marketingAddress = _marketingAddress;
    }

    function setTopDividends(uint256 _topDividends) public onlyController {
        topDividends = _topDividends;
    }

    function setBoxsPrices(uint256 price) public onlyController {
        blindBoxPrice = price;
    }

    function setCId(uint256 _cId) public onlyController {
        cId = _cId;
    }

    function whtidraw(uint256 amount) public onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    function openBlindBox(uint256 types) public payable{

        require(types > 0 && types < 6, "The blind box type does not exist");
       
        require(msg.value == blindBoxPrice, "The price of the blind box is wrong");

        cId++;

        (uint256 rarity,uint256 speed,uint256 stability, uint256 controllability, uint256 explosive) = _getBlindBoxAwardType();

        components[cId] = Component(cId, msg.sender, types, rarity, speed, stability, controllability, explosive);

        cIdToIndexs[cId] = myComponentCids[msg.sender].length;

        myComponentCids[msg.sender].push(cId);

        uint256 price1 = msg.value.mul(44).div(100);
        uint256 price2 = msg.value.mul(30).div(100);
        uint256 price3 = msg.value.mul(16).div(100);
        uint256 price4 = msg.value - price1 - price2 - price3;

        payable(kickbackAddress).transfer(price1);
        payable(vipAddress).transfer(price2);
        payable(leagueAddress).transfer(price3);
        payable(marketingAddress).transfer(price4);

        todayDividends = todayDividends.add(price2);

        if(todayDividends > topDividends){
            _settlement();
        }

        emit OpenBlindBox(msg.sender, msg.value, types, components[cId]);
    }

    function _getBlindBoxAwardType() internal virtual returns (uint256 rarity,uint256 speed,uint256 stability, uint256 controllability, uint256 explosive) {  
        uint256 rarityRandom =  (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum ++) * block.number, msg.sender)))) % 100;

        uint256 number;

        if(rarityRandom >= 95){
            rarity = 3;
            speed = storyValue[getRarityValue(10, number)];
            number = (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 1) * block.number, msg.sender))));
            stability = storyValue[getRarityValue(10, number)];
            number = (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 2) * block.number, msg.sender))));
            controllability = storyValue[getRarityValue(10, number)];
            number = (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 3) * block.number, msg.sender))));
            explosive = storyValue[getRarityValue(10, number)];
        }else if (rarityRandom >= 70){
            rarity = 2;
            speed = epicValue[getRarityValue(5, number)];
            number = (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 1) * block.number, msg.sender))));
            stability = epicValue[getRarityValue(5, number)];
            number = (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 2) * block.number, msg.sender))));
            controllability = epicValue[getRarityValue(5, number)];
            number = (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 3) * block.number, msg.sender))));
            explosive = epicValue[getRarityValue(5, number)];
        }else{
            rarity = 1;
            speed = rareValue[getRarityValue(6, number)];
            number = (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 1) * block.number, msg.sender))));
            stability = rareValue[getRarityValue(6, number)];
            number = (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 2) * block.number, msg.sender))));
            controllability = rareValue[getRarityValue(6, number)];
            number = (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 3) * block.number, msg.sender))));
            explosive = rareValue[getRarityValue(6, number)];
        }
        return(rarity, speed, stability, controllability, explosive);
    }

    function getRarityValue(uint256 _length, uint256 number) public pure returns (uint256){
        return number % _length;
    }

    function settlement() public onlyController {
        _settlement();
    }

    function _settlement() internal virtual {
        require(todayDividends > 0, "No dividends to settle");

        settlementTimesToTime.push(block.timestamp);

        uint256 nft1Num = FPN.NFTTypeNumber(1);

        uint256 nft2Num = FPN.NFTTypeNumber(2);

        uint256 nft3Num = FPN.NFTTypeNumber(3);

        if(nft1Num > 0){
            settlementTimesToDividends[settlementTimesToTime.length][1] = todayDividends.mul(50).div(100 * nft1Num);
        }

        if(nft2Num > 0){
            settlementTimesToDividends[settlementTimesToTime.length][2] = todayDividends.mul(30).div(100 * nft2Num);
        }

        if(nft3Num > 0){
            settlementTimesToDividends[settlementTimesToTime.length][3] = todayDividends.mul(20).div(100 * nft3Num);
        }

        todayDividends = 0;
    }

    function whtidrawDividends() public {

        uint256[] memory ids = FPN.getUserNFTIDs(msg.sender);

        uint256 time = block.timestamp;

        uint256 profit;

        uint256 i;

        uint256 j;

        for(i = 0; i < ids.length; i++){
            if(ids[i] != 0){
                for(j = settlementTimesToTime.length; j > 0; j--){
                    if(settlementTimesToTime[j - 1] > FPN.IDToWhtidrawTime(ids[i])){
                        profit = profit.add(settlementTimesToDividends[j][FPN.NFTTypes(ids[i])]);
                    }else{
                        break;
                    }
                }

                FPN.setIDToWhtidrawTime(ids[i], time);
            }
        }

        if(profit > 0){
            payable(msg.sender).transfer(profit);

            myCommissions[msg.sender].push(Commission(time, 1, profit));
        }

        emit WhtidrawDividends(msg.sender, profit);
    }

    function deleteMyComponent(address user, uint256 cid) public onlyController returns(bool) {
        
        require(user == components[cid].holder, "This user is not the owner of the component");

        delete myComponentCids[user][cIdToIndexs[cid]];

        delete components[cid];

        delete cIdToIndexs[cid];

        return true;
    }

    function deleteMyComponents(address user, uint256[] memory cids) public onlyController returns(bool) {

        for(uint256 i = 0; i < cids.length; i++){

            uint256 cid = cids[i];

            require(user == components[cid].holder, "This user is not the owner of the component");

            delete myComponentCids[user][cIdToIndexs[cid]];

            delete components[cid];

            delete cIdToIndexs[cid];
        }

        return true;
    }

    function addMyComponent(uint256 id, address holder, uint256 types, uint256 rarity, uint256 speed, 
    uint256 stability, uint256 controllability, uint256 explosive) public onlyController returns(bool){

        require(components[id].id != id, "The component data has been imported");

        components[id] = Component(id, holder, types, rarity, speed, stability, controllability, explosive);

        cIdToIndexs[id] = myComponentCids[holder].length;

        myComponentCids[holder].push(id);

        return true;
    }

    function addMyCommissions(address user, uint256 rewardTime, uint256 rewardType, uint256 reward) public onlyController returns(bool){
        myCommissions[user].push(Commission(rewardTime, rewardType, reward));
        return true;
    }

    function setSettlementTimesToTime(uint256 time) public onlyController returns(bool){
        settlementTimesToTime.push(time);
        return true;
    }

    function setSettlementTimesToDividends(uint256 index1, uint256 index2, uint256 dividend) public onlyController returns(bool){
        settlementTimesToDividends[index1][index2] = dividend;
        return true;
    }

    function addTodayDividends(uint256 reward) public onlyController returns(bool){
        todayDividends = todayDividends.add(reward);

        if(todayDividends > topDividends){
            _settlement();
        }

        return true;
    }

    function getUserDividends(address user) public view returns(uint256) {

        uint256[] memory ids = FPN.getUserNFTIDs(user);

        uint256 profit;

        uint256 i;

        uint256 j;

        for(i = 0; i < ids.length; i++){
            if(ids[i] != 0){
                for(j = settlementTimesToTime.length; j > 0; j--){
                    if(settlementTimesToTime[j - 1] > FPN.IDToWhtidrawTime(ids[i])){
                        profit = profit.add(settlementTimesToDividends[j][FPN.NFTTypes(ids[i])]);
                    }else{
                        break;
                    }
                }
            }
        }

        return profit;
    }

    function queryMyCommissions(address user) public view returns(Commission[] memory){
        return myCommissions[user];
    }

    function queryMyComponentIds(address user) public view returns(uint256[] memory){
        return myComponentCids[user];
    }

    function queryMyComponent(address user) public view returns(Component[] memory myComponents){
        uint256 count;

        uint256[] memory cids = myComponentCids[user];

        Component[] memory myComponents0 = new Component[](uint256(cids.length));

        for(uint256 i = 0; i < cids.length; i++){
            if(cids[i] != 0){
                myComponents0[count] = components[cids[i]];
                count++;
            }
        }

        myComponents = new Component[](uint256(count));

        for(uint256 i = 0; i < count; i++){
            myComponents[i] = myComponents0[i];
        }

        return myComponents;
    }

    function queryMyComponentByType(address user, uint256 types) public view returns(Component[] memory myComponents){

        uint256 count;

        uint256[] memory cids = myComponentCids[user];

        Component[] memory myComponents0 = new Component[](uint256(cids.length));

        for(uint256 i = 0; i < cids.length; i++){
            if(components[cids[i]].types == types){
                myComponents0[count] = components[cids[i]];
                count++;
            }
        }

        myComponents = new Component[](uint256(count));

        for(uint256 i = 0; i < count; i++){
            myComponents[i] = myComponents0[i];
        }

        return myComponents;
    }
    
}
// File: FOFPlayerController2.sol



pragma solidity ^0.8.0;





contract FOFPlayerController2 is Ownable {

    using SafeMath for uint256;

    event PaymentReceived(address from, uint256 amount);

    event MergeVehicle(address from, uint256[] burnIds, Vehicle vehicle);

    
    struct Vehicle {
        uint256 tokenId;

        uint256 types;

        uint256 speed;

        uint256 stability;

        uint256 controllability;

        uint256 explosive;

        uint256 attribute;
    }

    
    mapping(uint256 => Vehicle) public vehicles;

    mapping(uint256 => uint256) public tokenIdToStatus;

    mapping(uint256 => bool) public openVehicleMerge;


    mapping(address => bool) public isController;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    
 
    FOFPlayerNFT FPN;

    FOFPlayerController1 FPC;

    constructor() {
        // FPN = FOFPlayerNFT(0x8918337F9aF8BC5a70EE804dc284B1d017665B27);
        // FPC = FOFPlayerController1(payable(0x74b58b15da0F0073069EB7e585ADb17Dc2330EF4));
        FPN = FOFPlayerNFT(0x25894eA4eE6576623Fd8383d6D023dc5219E0553);
        FPC = FOFPlayerController1(payable(0x50E79435Bb54564E8F6d0BBa2B841027C77B8824));

        openVehicleMerge[101] = true;
        openVehicleMerge[102] = true;
        openVehicleMerge[103] = true;
    }

    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    function addController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = true;
    }

    function removeController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = false;
    }

    modifier onlyController {
        require(isController[msg.sender],"Must be controller");
        _;
    }

    function setFOFPlayerNFT(address _FOFPlayerNFT) public onlyController {
        FPN = FOFPlayerNFT(_FOFPlayerNFT);
    }

    function setFOFPlayerController1(address _FOFPlayerController1) public onlyController {
        FPC = FOFPlayerController1(payable(_FOFPlayerController1));
    }

    function openopenVehicleMerge(uint256 VehicleType, bool open) public onlyController {
        openVehicleMerge[VehicleType] = open;
    }

    function mergeVehicle(uint256[] memory cIds) public returns (uint256) {

        require(checkCids(cIds), "The selected parts cannot be synthesized into vehicles");

        require(openVehicleMerge[101], "Vehicle synthesis of this type is not available");

        (uint256 speed,uint256 stability, uint256 controllability,uint256 explosive) = countVehicleAttribute(cIds);

        uint256 attribute = speed.add(stability).add(controllability).add(explosive);

        FPC.deleteMyComponents(msg.sender, cIds);

        uint256 tokenId = FPN.createNFT(msg.sender, 101);

        vehicles[tokenId] = Vehicle(tokenId, 101, speed, stability, controllability, explosive, attribute);

        emit MergeVehicle(msg.sender, cIds, vehicles[tokenId]);

        return tokenId;
    }

    function mergeAdvancedVehicle(uint256[] memory tokenIds) public returns (uint256) {

        require(tokenIds[0] != tokenIds[1], "The vehicle types don't match");

        require(FPN.ownerOf(tokenIds[0]) == msg.sender && FPN.ownerOf(tokenIds[1]) == msg.sender , "You are not the owner of the vehicle");

        require(FPN.NFTTypes(tokenIds[0]) == FPN.NFTTypes(tokenIds[1]) && FPN.NFTTypes(tokenIds[0]) > 100, "The vehicle types don't match");

        require(tokenIdToStatus[tokenIds[0]] == 0 && tokenIdToStatus[tokenIds[1]] == 0, "Vehicles are unavailable");

        uint256 types = FPN.NFTTypes(tokenIds[0]) + 1;

        require(openVehicleMerge[types], "Vehicle synthesis of this type is not available");

        uint256 tokenId = FPN.createNFT(msg.sender, types);

        (uint256 speed,uint256 stability, uint256 controllability,uint256 explosive) = countVehicleAttribute2(tokenIds);

        uint256 attribute = speed.add(stability).add(controllability).add(explosive);

        vehicles[tokenId] = Vehicle(tokenId, types, speed, stability, controllability, explosive, attribute);

        delete vehicles[tokenIds[0]];

        delete vehicles[tokenIds[1]];

        FPN.approveToController(msg.sender, tokenIds[0]);

        FPN.approveToController(msg.sender, tokenIds[1]);

        FPN.transferFrom(msg.sender, deadWallet, tokenIds[0]);

        FPN.transferFrom(msg.sender, deadWallet, tokenIds[1]);

        emit MergeVehicle(msg.sender, tokenIds, vehicles[tokenId]);

        return tokenId;
    }

    function setNFTStatus(uint256 tokenId, uint256 status) public onlyController returns (bool) {
        tokenIdToStatus[tokenId] = status;
        return true;
    }

    function countVehicleAttribute(uint256[] memory cIds) public view returns(uint256,uint256,uint256,uint256) {

        uint256 speed;
        uint256 stability;
        uint256 controllability;
        uint256 explosive;

        for(uint256 i = 0; i < 5; i++){

            (,,,,uint256 speed0,uint256 stability0,uint256 controllability0,uint256 explosive0) = FPC.components(cIds[i]);

            speed = speed.add(speed0);
            stability = stability.add(stability0);
            controllability = controllability.add(controllability0);
            explosive = explosive.add(explosive0);
        }

        return (speed,stability,controllability,explosive);
    }

    function countVehicleAttribute2(uint256[] memory tokenIds) public view returns(uint256,uint256,uint256,uint256) {

        Vehicle memory vehicle0 = vehicles[tokenIds[0]];
        Vehicle memory vehicle1 = vehicles[tokenIds[1]];

        uint256 speed = vehicle0.speed.add(vehicle1.speed).mul(3).div(2);
        uint256 stability = vehicle0.stability.add(vehicle1.stability).mul(3).div(2);
        uint256 controllability = vehicle0.controllability.add(vehicle1.controllability).mul(3).div(2);
        uint256 explosive = vehicle0.explosive.add(vehicle1.explosive).mul(3).div(2);

        return (speed,stability,controllability,explosive);
    }

    function checkCids(uint256[] memory cIds) public view returns(bool) {

        uint256 i;

        uint256 j;

        uint256 counter;

        for(i = 0; i < 5; i++){

            (,,uint256 types,,,,,) = FPC.components(cIds[i]);

            for(j = 1; j < 6; j++){
                if(types == j){
                    counter  = counter.add(j);
                }
            }
        }

        if(counter == 15){
            return true;
        }

        return false; 
    }

    function getUserNFTIDs(address user) public view returns(uint256[] memory NFTIDs) {

		uint256[] memory NFTIDs0 = FPN.getUserNFTIDs(user);

        uint256[] memory NFTIDs1 = new uint256[](uint256(NFTIDs0.length));

        uint256 counter;

        uint256 i;

        for(i = 0; i < NFTIDs0.length; i++){
            if(NFTIDs0[i] != 0){

                NFTIDs1[counter] = NFTIDs0[i];

                counter++;
            }
        }

        NFTIDs = new uint256[](uint256(counter));

        for(i = 0; i < counter; i++){
            NFTIDs[i] = NFTIDs1[i];
        }

        return (NFTIDs);
	}

    function getUserNFTIDsAndTypes(address user) public view returns(uint256[] memory NFTIDs, uint256[] memory types) {

		uint256[] memory NFTIDs0 = FPN.getUserNFTIDs(user);

        uint256[] memory NFTIDs1 = new uint256[](uint256(NFTIDs0.length));

        uint256 counter;

        uint256 i;

        for(i = 0; i < NFTIDs0.length; i++){
            if(NFTIDs0[i] != 0){

                NFTIDs1[counter] = NFTIDs0[i];

                counter++;
            }
        }

        NFTIDs = new uint256[](uint256(counter));

        types = new uint256[](uint256(counter));

        for(i = 0; i < counter; i++){
            NFTIDs[i] = NFTIDs1[i];

            types[i] = FPN.NFTTypes(NFTIDs[i]);
        }

        return (NFTIDs,types);
	}

    function getUserNFTIDsByType(address user, uint256 NFTType) public view returns(uint256[] memory NFTIDs) {

		uint256[] memory NFTIDs0 = FPN.getUserNFTIDs(user);

        uint256[] memory NFTIDs1 = new uint256[](uint256(NFTIDs0.length));

        uint256 counter;

        uint256 i;

        for(i = 0; i < NFTIDs0.length; i++){
            if(NFTIDs0[i] != 0 && FPN.NFTTypes(NFTIDs0[i]) == NFTType){

                NFTIDs1[counter] = NFTIDs0[i];

                counter++;
            }
        }

        NFTIDs = new uint256[](uint256(counter));

        for(i = 0; i < counter; i++){
            NFTIDs[i] = NFTIDs1[i];
        }

        return NFTIDs;
	}

    function getUserVehicles(address user) public view returns(Vehicle[] memory myVehicles) {

		uint256[] memory NFTIDs = getUserNFTIDs(user);

        uint256[] memory NFTIDs1 = new uint256[](uint256(NFTIDs.length));

        uint256 counter;

        uint256 i;

        for(i = 0; i < NFTIDs.length; i++){
            if(FPN.NFTTypes(NFTIDs[i]) > 100){

                NFTIDs1[counter] = NFTIDs[i];

                counter++;
            }
        }

        myVehicles = new Vehicle[](uint256(counter));

        for(i = 0; i < counter; i++){
            myVehicles[i] = vehicles[NFTIDs1[i]];
        }

        return myVehicles;
	}

    function getUserVehiclesByType(address user, uint256 NFTType) public view returns(Vehicle[] memory myVehicles) {

		uint256[] memory NFTIDs = getUserNFTIDsByType(user, NFTType);

        uint256[] memory NFTIDs1 = new uint256[](uint256(NFTIDs.length));

        uint256 counter;

        uint256 i;

        for(i = 0; i < NFTIDs.length; i++){
            if(FPN.NFTTypes(NFTIDs[i]) == NFTType){

                NFTIDs1[counter] = NFTIDs[i];

                counter++;
            }
        }

        myVehicles = new Vehicle[](uint256(counter));

        for(i = 0; i < counter; i++){
            myVehicles[i] = vehicles[NFTIDs1[i]];
        }

        return myVehicles;
	}

    function getUserNFTs(address user) public view returns(uint256[] memory NFTIDs, uint256[] memory types, uint256[] memory NFTStatus) {

		uint256[] memory NFTIDs0 = FPN.getUserNFTIDs(user);

        uint256[] memory NFTIDs1 = new uint256[](uint256(NFTIDs0.length));

        uint256 counter;

        uint256 i;

        for(i = 0; i < NFTIDs0.length; i++){
            if(NFTIDs0[i] != 0){

                NFTIDs1[counter] = NFTIDs0[i];

                counter++;
            }
        }

        NFTIDs = new uint256[](uint256(counter));

        types = new uint256[](uint256(counter));

        NFTStatus = new uint256[](uint256(counter));

        for(i = 0; i < counter; i++){
            NFTIDs[i] = NFTIDs1[i];

            types[i] = FPN.NFTTypes(NFTIDs[i]);

            NFTStatus[i] = tokenIdToStatus[NFTIDs1[i]];
        }

        return (NFTIDs,types,NFTStatus);
	}

    function getUserNFTsByType(address user, uint256 NFTType) public view returns(uint256[] memory NFTIDs, uint256[] memory types, uint256[] memory NFTStatus) {

		uint256[] memory NFTIDs0 = FPN.getUserNFTIDs(user);

        uint256[] memory NFTIDs1 = new uint256[](uint256(NFTIDs0.length));

        uint256 counter;

        uint256 i;

        for(i = 0; i < NFTIDs0.length; i++){
            if(NFTIDs0[i] != 0 && FPN.NFTTypes(NFTIDs0[i]) == NFTType){

                NFTIDs1[counter] = NFTIDs0[i];

                counter++;
            }
        }

        NFTIDs = new uint256[](uint256(counter));

        types = new uint256[](uint256(counter));

        NFTStatus = new uint256[](uint256(counter));

        for(i = 0; i < counter; i++){

            NFTIDs[i] = NFTIDs1[i];

            types[i] = FPN.NFTTypes(NFTIDs[i]);

            NFTStatus[i] = tokenIdToStatus[NFTIDs1[i]];
        }

        return (NFTIDs,types,NFTStatus);
	}

}
// File: FOFPlayerController3.sol

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;




contract FOFPlayerController3 is Ownable {

    using SafeMath for uint256;

    event PaymentReceived(address from, uint256 amount);

    event SellMyNFT(address indexed user, uint256 tokenId, uint256 price);

    event BuyNFT(address indexed seller, address indexed buyer, uint256 tokenId, uint256 price);

    event CancelSellNFT(address indexed user, uint256 tokenId);

    
    mapping(address => bool) public isController;

    mapping(uint256 => uint256) public tokenIdToPrice;

    uint256[] public sellTokenIds;

    mapping(uint256 => uint256) public tokenIdToSellIndexs;

    address public receiveAddress;

    uint256 public sellFee = 3;
    
 
    FOFPlayerNFT FPN;

    FOFPlayerController2 FPC2;

    constructor() {
        // FPN = FOFPlayerNFT(0x8918337F9aF8BC5a70EE804dc284B1d017665B27);
        // FPC2 = FOFPlayerController2(payable(0xE3547B03613503261C7649ad36Fd159C9A2651b2));
        FPN = FOFPlayerNFT(0x25894eA4eE6576623Fd8383d6D023dc5219E0553);
        FPC2 = FOFPlayerController2(payable(0x3c9ffD06fa3adE6bCBb7B409d66741a2A52f094d));

        receiveAddress = address(0xBdDeeC848161d71851Bcb3ff8A4Bf590eF782E71);
    }

    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    function addController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = true;
    }

    function removeController(address controllerAddr) public onlyOwner {
        isController[controllerAddr] = false;
    }

    modifier onlyController {
        require(isController[msg.sender],"Must be controller");
        _;
    }

    function setFOFPlayerNFT(address _FOFPlayerNFT) public onlyController {
        FPN = FOFPlayerNFT(_FOFPlayerNFT);
    }

    function setFOFPlayerController2(address _FOFPlayerController2) public onlyController {
        FPC2 = FOFPlayerController2(payable(_FOFPlayerController2));
    }

    function setReceiveAddress(address _receiveAddress) public onlyController {
        receiveAddress = address(_receiveAddress);
    }

    function setSellFee(uint256 _sellFee) public onlyController {
        sellFee = _sellFee;
    }

    function sellMyNFT(uint256 tokenId, uint256 price) public {

        require(FPN.ownerOf(tokenId) == msg.sender, "You are not the owner");
        
        require(FPC2.tokenIdToStatus(tokenId) == 0,"The vehicle you selected is unavailable");

        require(price > 0,"The price has to be greater than 0");

        FPN.setNFTLock(tokenId, true);

        tokenIdToPrice[tokenId] = price.mul(10 ** 14);

        FPC2.setNFTStatus(tokenId, 1);

        if(tokenIdToSellIndexs[tokenId] > 0){
            sellTokenIds[tokenIdToSellIndexs[tokenId]] = tokenId;
        }else{

            tokenIdToSellIndexs[tokenId] = sellTokenIds.length;

            sellTokenIds.push(tokenId);
        }

        emit SellMyNFT(msg.sender, tokenId, price);
    }

    function cancelSellNFT(uint256 tokenId) public {

        require(FPN.ownerOf(tokenId) == msg.sender, "You are not the owner");
        
        require(FPC2.tokenIdToStatus(tokenId) == 1 && tokenIdToPrice[tokenId] > 0,"The vehicle you selected is not available");

        FPN.setNFTLock(tokenId, false);

        tokenIdToPrice[tokenId] = 0;

        FPC2.setNFTStatus(tokenId, 0);

        delete sellTokenIds[tokenIdToSellIndexs[tokenId]];

        emit CancelSellNFT(msg.sender, tokenId);
    }

    function buyNFT(uint256 tokenId) public payable {

        address ownerAddress = FPN.ownerOf(tokenId);

        require(ownerAddress != msg.sender,"This buyer is owner");

        require(FPC2.tokenIdToStatus(tokenId) == 1 && tokenIdToPrice[tokenId] > 0,"The vehicle you selected is not available");

        uint256 price = tokenIdToPrice[tokenId];

        require(msg.value == price,"The price entered is wrong");

        uint256 fee = price.mul(sellFee).div(100);

        payable(receiveAddress).transfer(fee);

        payable(ownerAddress).transfer(price - fee);

        FPN.setNFTLock(tokenId, false);

        FPN.approveToController(ownerAddress, tokenId);

        FPN.transferFrom(ownerAddress, msg.sender, tokenId);

        tokenIdToPrice[tokenId] = 0;

        FPC2.setNFTStatus(tokenId, 0);

        delete sellTokenIds[tokenIdToSellIndexs[tokenId]];

        emit BuyNFT(ownerAddress, msg.sender, tokenId, price);
    }

    function getSells(address user, uint256 NFTType) public view returns(uint256[] memory sellNFTIDs, uint256[] memory indexs, uint256[] memory prices, uint256[] memory types, uint256[] memory attributes, address[] memory owners) {

        uint256[] memory sellNFTIDs0 = new uint256[](uint256(sellTokenIds.length));

        uint256 counter;

        uint256 i;

        if(user == address(0)){
            for(i = 0; i < sellTokenIds.length; i++){
                if(sellTokenIds[i] != 0){

                    if(NFTType == 0 && sellTokenIds[i] != 0){
                        sellNFTIDs0[counter] = sellTokenIds[i];

                        counter++;
                    }else{
                        if(NFTType == 1 && FPN.NFTTypes(sellTokenIds[i]) > 0 && FPN.NFTTypes(sellTokenIds[i]) < 4){
                            sellNFTIDs0[counter] = sellTokenIds[i];

                            counter++;
                        }else if(NFTType == 101 && FPN.NFTTypes(sellTokenIds[i]) > 100){
                            sellNFTIDs0[counter] = sellTokenIds[i];

                            counter++;
                        }else if(FPN.NFTTypes(sellTokenIds[i]) == NFTType){
                            sellNFTIDs0[counter] = sellTokenIds[i];

                            counter++;
                        }
                    }
                }
            }
        }else{
            for(i = 0; i < sellTokenIds.length; i++){
                if(sellTokenIds[i] != 0 && FPN.ownerOf(sellTokenIds[i]) == user){

                    if(NFTType == 0){
                        sellNFTIDs0[counter] = sellTokenIds[i];

                        counter++;
                    }else{
                        if(NFTType == 1 && FPN.NFTTypes(sellTokenIds[i]) > 0 && FPN.NFTTypes(sellTokenIds[i]) < 4){
                            sellNFTIDs0[counter] = sellTokenIds[i];

                            counter++;
                        }else if(NFTType == 101 && FPN.NFTTypes(sellTokenIds[i]) > 100){
                            sellNFTIDs0[counter] = sellTokenIds[i];

                            counter++;
                        }else if(FPN.NFTTypes(sellTokenIds[i]) == NFTType){
                            sellNFTIDs0[counter] = sellTokenIds[i];

                            counter++;
                        }
                    }
                }
            }
        }

        sellNFTIDs = new uint256[](uint256(counter));

        indexs = new uint256[](uint256(counter));

        prices = new uint256[](uint256(counter));

        types = new uint256[](uint256(counter));

        attributes = new uint256[](uint256(counter));

        owners = new address[](uint256(counter));

        for(i = 0; i < counter; i++){
            sellNFTIDs[i] = sellNFTIDs0[i];

            indexs[i] = tokenIdToSellIndexs[sellNFTIDs0[i]] + 1;

            prices[i] = tokenIdToPrice[sellNFTIDs0[i]].div(10 ** 14);

            owners[i] = FPN.ownerOf(sellNFTIDs0[i]);

            types[i] = FPN.NFTTypes(sellNFTIDs0[i]);

            if(NFTType == 101){
                (,,,,,,uint256 attribute) = FPC2.vehicles(sellNFTIDs0[i]);

                attributes[i] = attribute;
            }
        }

        return (sellNFTIDs,indexs,prices,types,attributes,owners);
	}

}