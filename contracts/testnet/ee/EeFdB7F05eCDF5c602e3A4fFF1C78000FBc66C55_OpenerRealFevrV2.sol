/**
 *Submitted for verification at BscScan.com on 2023-02-07
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


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

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
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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

// File: OpenerV2/interfaces/OpenerMintInterface.sol


pragma solidity ^0.8.0;

interface OpenerMintInterface is IERC721 {

    struct MarketplaceDistribution {
        uint256[] marketplaceDistributionAmounts;
        address[] marketplaceDistributionAddresses;
    }

    function mint(uint256 tokenId) external;
    function getLastNFTID() external returns(uint256);
    function setLastNFTID(uint256 newId) external;

    function setRegisteredID(address _account, uint256 _id) external;
    function pushRegisteredIDsArray(address _account, uint256 _id) external;
    function exists(uint256 _tokenId) external view returns (bool);
    function alreadyMinted(uint256 _tokenId) external view returns (bool);
    function mintedCounts(address _account) external view returns (uint256);
    function getRegisteredIDs(address _account) external view returns (uint256[] memory);
    
    function setMarketplaceDistribution(uint256[] memory amounts, address[] memory addresses, uint256 _id) external;
    function getMarketplaceDistributionForERC721(uint256 _tokenId) external view returns(uint256[] memory, address[] memory);

    function setAdmin(address admin_) external;
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


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/ERC721.sol)

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
        address owner = _ownerOf(tokenId);
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
            "ERC721: approve caller is not token owner or approved for all"
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
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

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
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
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
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
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
        return _ownerOf(tokenId) != address(0);
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

        _beforeTokenTransfer(address(0), to, tokenId, 1);

        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "ERC721: token already minted");

        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            _balances[to] += 1;
        }

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId, 1);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId, 1);

        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = ERC721.ownerOf(tokenId);

        // Clear approvals
        delete _tokenApprovals[tokenId];

        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            _balances[owner] -= 1;
        }
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId, 1);
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

        _beforeTokenTransfer(from, to, tokenId, 1);

        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];

        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId, 1);
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
     * @dev Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.
     * - When `from` is zero, the tokens will be minted for `to`.
     * - When `to` is zero, ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256, /* firstTokenId */
        uint256 batchSize
    ) internal virtual {
        if (batchSize > 1) {
            if (from != address(0)) {
                _balances[from] -= batchSize;
            }
            if (to != address(0)) {
                _balances[to] += batchSize;
            }
        }
    }

    /**
     * @dev Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.
     * - When `from` is zero, the tokens were minted for `to`.
     * - When `to` is zero, ``from``'s tokens were burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
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

// File: OpenerV2/collectionId.sol


pragma solidity ^0.8.0;




contract CollectionId is Ownable, ERC721URIStorage , OpenerMintInterface {

    address public _opener;
    address public _admin;
    uint256 private lastTokenId;

    string private _baseURIextended;
    
    // Mapping from address to bool, if egg was already claimed
    // The hash is about the userId and the nftIds array
    mapping(address => mapping(uint256 => bool)) public registeredIDs;
    mapping(address => uint256[]) public registeredIDsArray;
    mapping(uint256 => bool) public override alreadyMinted;
    mapping(address => uint256) public override mintedCounts;

    mapping(uint256 => MarketplaceDistribution) private marketplaceDistributions;

    event NftMinted(uint256 indexed tokenID);

    modifier onlyAdmin {
        require(_admin == _msgSender(), "Caller is not the admin");
        _;
    } 

    modifier onlyOpener {
        require(_opener == _msgSender(), "Caller is not the opener contract");
        _;
    }

    constructor(
        address _owner, 
        address opener,
        string memory name_, 
        string memory symbol_
    ) ERC721(name_, symbol_) {
        _opener = opener;
        lastTokenId = 1;
        _admin = _owner; 
    }

    function setAdmin(address admin_) external onlyOpener override {
        require (admin_ != address(0), "zero admin address");
        _admin = admin_;
    }

    function setBaseURI(string memory baseURI_) external onlyAdmin {
        _baseURIextended = baseURI_;
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) external onlyAdmin {
        _setTokenURI(tokenId, _tokenURI);
    }

    function baseURI() external view returns (string memory) {
        return _baseURI();
    }

    function getLastNFTID() public view override returns(uint256) {
        return lastTokenId;
    }

    function getMarketplaceDistributionForERC721(
        uint256 _tokenId
    ) external override view returns(
        uint256[] memory, 
        address[] memory
    ) {
        return (marketplaceDistributions[_tokenId].marketplaceDistributionAmounts, marketplaceDistributions[_tokenId].marketplaceDistributionAddresses);
    }

    // used when creating new pack and assigning nft index
    function setLastNFTID(uint256 newId) external override onlyOpener {
        require(newId > lastTokenId, "Wrong value");
        lastTokenId = newId;
    }

    function exists(uint256 tokenId) public view override returns (bool) {
        return _exists(tokenId);
    }

    function checkRegisteredID(
        address _address, 
        uint256 _tokenIdToMint
    ) external view returns(bool) {
        return registeredIDs[_address][_tokenIdToMint];
    }

    function setRegisteredID(
        address _address, 
        uint256 _id
    ) external override onlyOpener {
        registeredIDs[_address][_id] = true;
    }

    function pushRegisteredIDsArray(
        address _address, 
        uint256 _id
    ) external override onlyOpener {
        registeredIDsArray[_address].push(_id);
    }

    function getRegisteredIDs(
        address _address
    ) public view override returns(uint256[] memory) {
        return registeredIDsArray[_address];
    }

    function mint(uint256 tokenIdToMint) external override onlyOpener {
        address account = tx.origin;
        require(registeredIDs[account][tokenIdToMint], "Token was not registered or not the rightful owner");
        require(!alreadyMinted[tokenIdToMint], "Already minted");

        alreadyMinted[tokenIdToMint] = true;
        mintedCounts[account] ++;
        _safeMint(account, tokenIdToMint);
        emit NftMinted(tokenIdToMint);
    }

    // only set by opener when pack is created
    function setMarketplaceDistribution(
        uint256[] memory _amounts, 
        address[] memory _addresses, 
        uint256 _id
    ) external override onlyOpener {
        MarketplaceDistribution memory marketplaceDistribution = MarketplaceDistribution(_amounts, _addresses);
        marketplaceDistributions[_id] = marketplaceDistribution;
    }

    // only set by admin
    function setMarketplaceDistForNFT(
        uint256 _tokenId, 
        uint256[] memory _marketplaceDistributionAmounts, 
        address[] memory _marketplaceDistributionAddresses
    ) external {
        require(msg.sender == _admin, "Not authorized");
        require(_tokenId < getLastNFTID(), "NFT has not been created");
        require(_marketplaceDistributionAmounts.length == _marketplaceDistributionAddresses.length, "Length missmatch");
        marketplaceDistributions[_tokenId].marketplaceDistributionAmounts =_marketplaceDistributionAmounts;
        marketplaceDistributions[_tokenId].marketplaceDistributionAddresses = _marketplaceDistributionAddresses;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseURIextended;
    }
}

// File: OpenerV2/interfaces/ICollectionIdFactory.sol


pragma solidity ^0.8.0;


interface ICollectionIdFactory {
    function createNewCollectionId(
        address owner_,
        string memory name_,
        string memory symbol_
    ) external returns (address);
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


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
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
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
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
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

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
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
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
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
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

// File: OpenerV2/interfaces/IOpenerRealFevrV2.sol


pragma solidity ^0.8.0;




interface IOpenerRealFevrV2 {
    struct whitelist {
        bool whitelistEnabled;
        mapping(address => bool) isWhitelisted;
    }

    struct Pack {
        address buyToken;
        uint256 packPriceUSD; // price in USD (18 decimals)
        address NFTAddress;
        uint256 packId;
        uint256 nftAmount;
        uint256 initialNFTId;
        uint256 mintCount;
        uint256[] saleDistributionAmounts;
        address[] saleDistributionAddresses;
        // Marketplace
        // Catalog info
        string serie;
        string drop;
        string packType;
        bool opened;
        address buyer;
    }

    struct MultiPacksParam {
        address erc20;
        address NFTAddress;
        uint256 packsAmount;
        uint256 nftAmount;
        uint256 priceInUSD;
        string serie;
        string packType;
        string drop;
    }

    struct MintNFTCollectionParam {
        address collectionAddress;
        uint256[] collectionIds;
    }
    
    struct NFTTransferParam {
        address nftAddress;
        uint256[] ids;
        address[] recipients;
    }

    event PackCreated(uint256 packId, string indexed serie, string indexed packType, string indexed drop);
    event PackBought(address indexed by, uint256 indexed packId);
    event PackOffered(address indexed by, uint256 indexed packId);
    event PackOpened(address indexed by, uint256 indexed packId);
    event NftMinted(address indexed NFTAddress, uint256 indexed tokenId);
}
// File: OpenerV2/openerV2.sol


 
pragma solidity ^0.8.0;


contract OpenerRealFevrV2 is IOpenerRealFevrV2, Ownable {
    uint256 public packIncrementId;
    uint256 public _packsBought;
    bool public _closed;
    
    mapping(address => mapping(uint256 => bool)) public openedCollectionIds;
    mapping(uint256 => Pack) public packs;
    mapping(address => uint256) public collectionIdToSaleStart;
    mapping(address => bool) public isCollectionIdOpenPackLocked;
    mapping(address => bool) public isBuyPackLocked;
    mapping(address => whitelist) public collectionIdWhitelist; // collection id address to whitelist struct

    mapping(address => uint256) public ERC20Price; // all decimals = $1
    mapping(address => bool) public isERC20Accepted;
    mapping(address => bool) private isOpenerMintInterfaceAccepted;
    address[] public nfts;
    address private _factory;
    address public creator;
    address public offeror;
    address public admin;

    modifier onlyCreator() {
        address sender = msg.sender;
        require (sender == owner() || sender == creator, "only Creator can create packs");
        _;
    }

    modifier onlyOfferor() {
        address sender = msg.sender;
        require (sender == owner() || sender == offeror, "only Offeror can offer packs");
        _;
    }

    modifier onlyAdmin() {
        address sender = msg.sender;
        require (sender == owner() || sender == admin, "only Admin can configure pack and whitelist");
        _;
    }

    constructor (address factory) {
        _factory = factory;
        packIncrementId = 1;
    }

    function setCreator(address _account) external onlyOwner {
        require (_account != address(0), "zero creator address");
        creator = _account;
    }

    function setOfferor(address _offeror) external onlyOwner {
        require (_offeror != address(0), "zero offeror address");
        offeror = _offeror;
    }

    function setAdmin(address _admin) external onlyOwner {
        require (_admin != address(0), "zero admin address");
        admin = _admin;
    }

    // So In your case, if 1000 Fevr is $1 then you should set ERC20Price to 0.001 * 10**18  = 10**15.
    // And if pack price is $10 then you should set packPriceUSD to 10 * 10*18 = 10**19.
    function setERC20Price(
        address _erc20, 
        uint256 _price
    ) external onlyOwner {
        ERC20Price[_erc20] = _price;
    }

    function getPackPriceInERC20(
        uint256 packId
    ) public view returns(uint256) {
        return ERC20Price[packs[packId].buyToken] == 0 ? 0 : packs[packId].packPriceUSD * 1e18 / ERC20Price[packs[packId].buyToken];
    }

    function changeCollectionWhitelistFlag(
        address collectionIdAddress
    ) external onlyAdmin {
        collectionIdWhitelist[collectionIdAddress].whitelistEnabled = !collectionIdWhitelist[collectionIdAddress].whitelistEnabled;
    }
    
    function addWhiteListAddresses(
        address collectionIdAddress, 
        address[] memory _addresses
    ) external onlyAdmin {
        for(uint256 i = 0; i < _addresses.length; i++) {
           collectionIdWhitelist[collectionIdAddress].isWhitelisted[_addresses[i]] = true;
        }
    }
    function removeWhiteListAddresses(
        address collectionIdAddress, 
        address[] memory _addresses
    ) external onlyAdmin {
        for(uint256 i = 0; i < _addresses.length; i++) {
           collectionIdWhitelist[collectionIdAddress].isWhitelisted[_addresses[i]] = false;
        }
    }
 
    function buyPack(uint256 packId) public payable {
        require(!_closed, "Opener locked");
        require(block.timestamp >= collectionIdToSaleStart[packs[packId].NFTAddress], "Sale not started yet");
        require(packs[packId].buyer == address(0), "Pack is bought");
        require(packs[packId].packPriceUSD != 0, "Pack has to exist");
        require(!isBuyPackLocked[packs[packId].NFTAddress], "Buy pack locked");

        if(collectionIdWhitelist[packs[packId].NFTAddress].whitelistEnabled) {
            require(collectionIdWhitelist[packs[packId].NFTAddress].isWhitelisted[msg.sender], "Not whitelisted");
        }

        address from = msg.sender;

        uint256 price = getPackPriceInERC20(packId);
        require (price > 0, "price is not set yet");
        _distributePackShares(from, packId, getPackPriceInERC20(packId));

        _packsBought++;

        for(uint i = 0; i < packs[packId].nftAmount; i++){
            OpenerMintInterface(packs[packId].NFTAddress).setRegisteredID(msg.sender, packs[packId].initialNFTId+i);
            OpenerMintInterface(packs[packId].NFTAddress).pushRegisteredIDsArray(msg.sender, packs[packId].initialNFTId+i);
        }

        packs[packId].buyer = from;

        emit PackBought(from, packId);
    }

    function buyPacks(uint256[] memory packIds) external {
        for(uint i = 0; i < packIds.length; i++){
            buyPack(packIds[i]);
        } 
    }

    function getMintableCollectionIds(
        address account,
        address collectionAddress
    ) public view returns (uint256[] memory) {
        require (collectionAddress != address(0), "invalid collection address");
        OpenerMintInterface collection = OpenerMintInterface(collectionAddress);
        uint256[] memory registeredIds = collection.getRegisteredIDs(account);

        uint256 mintableCount = 0;
        for (uint256 i = 0; i < registeredIds.length; i ++) {
            uint256 id = registeredIds[i];
            if (!collection.alreadyMinted(id) && openedCollectionIds[collectionAddress][id]) {
                mintableCount ++;
            }
        }

        uint256[] memory mintableIds = new uint256[](mintableCount);
        uint256 index = 0;
        for (uint256 i = 0; i < registeredIds.length; i ++) {
            uint256 collectionId = registeredIds[i];
            if (!collection.alreadyMinted(collectionId) && openedCollectionIds[collectionAddress][collectionId]) {
                mintableIds[index ++] = collectionId;
            }
        }
        return mintableIds;
    }

    function mintArray(
        MintNFTCollectionParam[] memory mintNFTCollections
    ) public {
        uint256 length = mintNFTCollections.length;
        require(!_closed, "Opener is locked");
        require (length > 0, "empty collection array for minting");

        for (uint256 i = 0; i < length; i ++) {
            MintNFTCollectionParam memory mintNFTCollection = mintNFTCollections[i];
            address collectionAddress = mintNFTCollection.collectionAddress;
            uint256 collectionIdLength = mintNFTCollection.collectionIds.length;
            require (collectionAddress != address(0), "zero collection address");
            require (collectionIdLength > 0, "empty mint collection id array");
            for (uint256 j = 0; j < collectionIdLength; j ++) {
                uint256 collectionId = mintNFTCollection.collectionIds[j];
                require (openedCollectionIds[collectionAddress][collectionId], "Not opened collection id");
                OpenerMintInterface(collectionAddress).mint(collectionId);
                emit NftMinted(collectionAddress, collectionId);
            }
        }
    }

    function mintAll(address[] memory collectionAddrs) external {
        uint256 collectionLength = collectionAddrs.length;
        require (collectionLength > 0, "empty collection address array");
        MintNFTCollectionParam[] memory collectionParams = new MintNFTCollectionParam[](collectionLength);
        for (uint256 i = 0; i < collectionLength; i ++) {
            address collectionAddress = collectionAddrs[i];
            uint256[] memory collectionIds = getMintableCollectionIds(msg.sender, collectionAddress);
            uint256 collectionIdLength = collectionIds.length;
            if (collectionIdLength == 0) {
                revert(
                    string(
                        abi.encodePacked(
                            "no mintable collection ids for ",
                            Strings.toHexString(collectionAddress)
                        )
                    )
                );
            }
            collectionParams[i] = MintNFTCollectionParam(collectionAddress, collectionIds);
        }

        mintArray(collectionParams);
    }

    function openPackMintAll(uint256 packId) public {
        address collectionAddress = packs[packId].NFTAddress;
        require(!_closed, "Opener is locked");
        require(!packs[packId].opened, "Opened Already");
        require(packs[packId].buyer != address(0), "Pack not bought");
        require(packs[packId].buyer == msg.sender, "Not buyer");
        require(!isCollectionIdOpenPackLocked[collectionAddress], "Open locked");

        uint256 nftStartId = packs[packId].initialNFTId + packs[packId].mintCount;

        for(uint256 i = nftStartId; i < packs[packId].initialNFTId + packs[packId].nftAmount; i++) {
            openedCollectionIds[collectionAddress][i] = true;
            OpenerMintInterface(collectionAddress).mint(i);
            packs[packId].mintCount ++;
            emit NftMinted(collectionAddress, i);
        }

        packs[packId].opened = true;
    }

    function openPacksMintAll(uint256[] memory packIds) external {
        for(uint i = 0; i < packIds.length; i++){
            openPackMintAll(packIds[i]);
        } 
    }

    function openPack(uint256 packId) public {
        address collectionAddress = packs[packId].NFTAddress;
        require(!_closed, "Opener is locked");
        require(!packs[packId].opened, "Opened Already");
        require(packs[packId].buyer != address(0), "Pack not bought");
        require(packs[packId].buyer == msg.sender, "Not buyer");
        require(!isCollectionIdOpenPackLocked[collectionAddress], "Open locked");

        uint256 nftStartId = packs[packId].initialNFTId + packs[packId].mintCount;

        for(uint256 i = nftStartId; i < packs[packId].initialNFTId + packs[packId].nftAmount; i++) {
            openedCollectionIds[collectionAddress][i] = true;
        }

        packs[packId].opened = true;
        emit PackOpened(msg.sender, packId);
    }

    function openPacks(uint256[] memory packIds) external {
        for(uint i = 0; i < packIds.length; i++){
            openPack(packIds[i]);
        } 
    }

    function createMultiplePacks(
        MultiPacksParam memory param,
        address[] memory saleDistributionAddresses, 
        uint256[] memory saleDistributionAmounts,
        address[] memory marketplaceDistributionAddresses,  
        uint256[] memory marketplaceDistributionAmounts
      ) external onlyCreator {
        require(saleDistributionAddresses.length == saleDistributionAmounts.length , 
          "saleDistributionAddresses Lengths dont match with saleDistributionAmounts");
        require(marketplaceDistributionAddresses.length == marketplaceDistributionAmounts.length , 
          "marketplaceDistributionAddresses Lengths dont match with marketplaceDistributionAmounts");
        require(isOpenerMintInterfaceAccepted[param.NFTAddress], "NFT address not valid");
        require(isERC20Accepted[param.erc20], "ERC20 is not accepted as payment");

        for(uint i = 0; i < param.packsAmount; i++){
            uint256 _lastNFTid = OpenerMintInterface(param.NFTAddress).getLastNFTID();
            packs[packIncrementId].buyToken = param.erc20;
            packs[packIncrementId].NFTAddress = param.NFTAddress;
            packs[packIncrementId].packId = packIncrementId;
            packs[packIncrementId].nftAmount = param.nftAmount;
            packs[packIncrementId].initialNFTId = _lastNFTid;
            packs[packIncrementId].packPriceUSD = param.priceInUSD; 
            packs[packIncrementId].serie = param.serie;
            packs[packIncrementId].drop = param.drop;
            packs[packIncrementId].saleDistributionAddresses = saleDistributionAddresses;
            packs[packIncrementId].saleDistributionAmounts = saleDistributionAmounts;
            packs[packIncrementId].packType = param.packType;

            for(uint j = 0; j < param.nftAmount; j++){
            
                OpenerMintInterface(packs[packIncrementId].NFTAddress).setMarketplaceDistribution(
                    marketplaceDistributionAmounts, 
                    marketplaceDistributionAddresses, 
                    _lastNFTid+j
                );
            }

            emit PackCreated(packIncrementId, param.serie, param.packType, param.drop);
            OpenerMintInterface(param.NFTAddress).setLastNFTID(_lastNFTid + param.nftAmount);
            packIncrementId++;
        }
    }

    function offerPack(uint256 packId, address receivingAddress) public onlyOfferor {
        require(packs[packId].packId == packId, "Pack does not exist");
        require(packs[packId].buyer == address(0), "Pack is bought");

        packs[packId].buyer = receivingAddress;

        for(uint i = 0; i < packs[packId].nftAmount; i++){            
            OpenerMintInterface(packs[packId].NFTAddress).setRegisteredID(receivingAddress, packs[packId].initialNFTId+i);
            OpenerMintInterface(packs[packId].NFTAddress).pushRegisteredIDsArray(receivingAddress, packs[packId].initialNFTId+i);
        }
        emit PackOffered(receivingAddress, packId);
    }

    function offerPacks(uint256[] memory packIds, address[] memory receivingAddresses) external onlyOfferor {
        require(packIds.length == receivingAddresses.length , "packIds Lengths dont match with receivingAddresses");
        for(uint i = 0; i < packIds.length; i++){
            offerPack(packIds[i], receivingAddresses[i]);
        }
    }


    function setERC20Accepted(address _addr) external onlyOwner {
        isERC20Accepted[_addr] = !isERC20Accepted[_addr];
    }

    function editPackInfo(
        uint256 _packId, 
        string memory serie, 
        string memory packType, 
        string memory drop, 
        uint256 priceUSD
    ) external onlyAdmin {
        require(block.timestamp < collectionIdToSaleStart[packs[_packId].NFTAddress], "Sale already live");
        packs[_packId].serie = serie;
        packs[_packId].packType = packType;
        packs[_packId].drop = drop;
        packs[_packId].packPriceUSD = priceUSD;
    }

    function deletePackById(uint256 packId) external onlyOwner {
        require(block.timestamp < collectionIdToSaleStart[packs[packId].NFTAddress], "Sale already live");
        delete packs[packId];
    }

    function swapClosed() external onlyOwner {
        _closed = !_closed;
    }

    function multipleNftTransfer(
        NFTTransferParam[] memory nftTransferParams
    ) external {
        uint256 length = nftTransferParams.length;
        require (length > 0, "empty nft infors for transferring");
        for (uint256 i = 0; i < length; i ++) {
            NFTTransferParam memory nftTransferParam = nftTransferParams[i];
            address nft = nftTransferParam.nftAddress;
            uint256[] memory ids = nftTransferParam.ids;
            address[] memory recipients = nftTransferParam.recipients;
            require(isOpenerMintInterfaceAccepted[nft], "Address not valid");
            require(ids.length == recipients.length, "Length missmatch");
            for(uint256 j = 0; j < ids.length; j++)
                IERC721(nft).transferFrom(msg.sender, recipients[j], ids[j]);
        }
    }

    function createNewNFTContract(
        string memory name, 
        string memory symbol
    ) external onlyOwner {
        address newCollectionAddr = ICollectionIdFactory(_factory).createNewCollectionId(owner(), name, symbol);
        nfts.push(newCollectionAddr);
        isOpenerMintInterfaceAccepted[nfts[nfts.length-1]] = true;
    }

    function getNFTAddresses() external view returns (address[] memory) {
        uint256 length = nfts.length;
        address[] memory NFTAddresses = new address[](length);
        for (uint256 i = 0; i < length; i ++) {
            NFTAddresses[i] = nfts[i];
        }

        return NFTAddresses;
    }

    function setCollectionIdOpenPackLocked(
        address collectionIdAddress
    ) external onlyOwner {
        isCollectionIdOpenPackLocked[collectionIdAddress] = !isCollectionIdOpenPackLocked[collectionIdAddress];
    }

    function setCollectionIdBuyPackLocked(
        address collectionIdAddress
    ) external onlyOwner {
        isBuyPackLocked[collectionIdAddress] = !isBuyPackLocked[collectionIdAddress];
    }

    function setCollectionIdSaleStart(
        address collectionIdAddress, 
        uint256 saleStart
    ) external onlyOwner {
        collectionIdToSaleStart[collectionIdAddress] = saleStart;
    }

    // change rightholder fees and addresses for a specified nft
    function setMarketplaceDistributionForCollection(
        address collectionAddress, 
        uint256[] memory _amounts, 
        address[] memory _addresses, 
        uint256 _id
    ) external onlyOwner {
        require(_amounts.length == _addresses.length, "Lengths missmatch");
        OpenerMintInterface(collectionAddress).setMarketplaceDistribution(_amounts, _addresses, _id);
    }

    function transferOwnership(address newOwner) public virtual override onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);

        uint256 collectionIdLength = nfts.length;
        for (uint256 i = 0; i < collectionIdLength; i ++) {
            address collectionId = nfts[i];
            OpenerMintInterface(collectionId).setAdmin(newOwner);
        }
    }

    receive() external payable {}

    function _distributePackShares(
        address from, 
        uint256 packId, 
        uint256 amount
    ) internal {
        Pack memory pack = packs[packId];
        for(uint i = 0; i < pack.saleDistributionAddresses.length; i ++){
            //transfer of stake share
            address buyToken = pack.buyToken;
            uint256 transferAmount = (pack.saleDistributionAmounts[i] * amount) / 100;
            require (transferAmount > 0, "zero distribute amount");
            if (buyToken == address(0)) {   // native token case. ETH/BNB
                (bool sent, ) = payable(pack.saleDistributionAddresses[i]).call{value: transferAmount}("");
                require (sent, "Transfer failed");
            } else {
                IERC20(pack.buyToken).transferFrom(
                    from,
                    pack.saleDistributionAddresses[i],
                    transferAmount
                );
            }
        }
    }
}