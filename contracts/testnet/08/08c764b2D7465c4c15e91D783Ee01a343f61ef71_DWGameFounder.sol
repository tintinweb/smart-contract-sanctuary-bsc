/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

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


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

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

// File: contracts/DWNFTGenerator.sol


pragma solidity >=0.4.16 <0.9.0;


contract DWNFTGenerator {
    using SafeMath for uint256;

    // Reward amount and winRatio are per field
    function generateDNA(uint256 _seed) external pure returns (uint256) {
        uint8[18] memory maxValues = [
            18,
            18,
            18,
            18,
            18,
            18,
            15,
            1,
            20,
            6,
            11,
            7,
            8,
            20,
            18,
            16,
            12,
            11
        ];

        uint8[18] memory places = [
            0, // COL
            3, // COL COL
            6, // COL COL COL
            9, // COL COL COL COL
            12, // COL COL COL COL COL
            15, // COL COL COL COL COL COL
            18, // TOPS COL COL COL COL COL COL
            22, // GE TOPS COL COL COL COL COL COL
            24, // RS GE TOPS COL COL COL COL COL COL
            26, // ESH RS GE TOPS COL COL COL COL COL COL
            29, // SHSH ESH RS GE TOPS COL COL COL COL COL COL
            33, // SOSH SHSH ESH RS GE TOPS COL COL COL COL COL COL
            37, // BOTT SOSH SHSH ESH RS GE TOPS COL COL COL COL COL COL
            41, // SKIN BOTT SOSH SHSH ESH RS GE TOPS COL COL COL COL COL COL
            45, // MOUT SKIN BOTT SOSH SHSH ESH RS GE TOPS COL COL COL COL COL COL
            49, // ESHA MOUT SKIN BOTT SOSH SHSH ESH RS GE TOPS COL COL COL COL COL COL
            53, // HFRO ESHA MOUT SKIN BOTT SOSH SHSH ESH RS GE TOPS COL COL COL COL COL COL
            57 // HBAC HFRO ESHA MOUT SKIN BOTT SOSH SHSH ESH RS GE TOPS COL COL COL COL COL COL
        ];
        uint256 adn = 0;
        for (uint256 i = 0; i < maxValues.length; i++) {
            _seed >>= 1;
            if (i > 6) {
                adn = (_seed % maxValues[i]) * 10**places[i] + adn;
                continue;
            }
            if (i < 6) {
                adn = (_seed % maxValues[i]) * 20 * 10**places[i] + adn;
                continue;
            }
            uint256 prob = (_seed >>= 1) % 100;
            if (prob < 10) adn = ((_seed % 4)) * 10**places[i] + adn;
            else adn = ((_seed % (maxValues[i] - 4)) + 4) * 10**places[i] + adn;
        }
        return adn + 1;
    }

    function getWPAndRarity(uint256 _seed, uint256 _max)
        internal
        pure
        returns (uint8, uint8)
    {
        uint256 prob = _seed % _max;
        _seed >>= 1;
        if (prob < 47) return (uint8((_seed % 34) + 15), 0);
        if (prob < 83) return (uint8((_seed % 50) + 50), 1);
        if (prob < 95) return (uint8((_seed % 50) + 100), 2);
        if (prob < 99) return (uint8((_seed % 50) + 150), 3);
        return (uint8((_seed % 51) + 200), 4);
    }

    function generateWP(uint256 _seed) external pure returns (uint8[6] memory) {
        uint8[5] memory waifuRarityProb = [47, 83, 95, 99, 100];
        uint8[6] memory WPArray;
        // Generate shuffled primary WP
        (uint8 mainWP, uint256 rarity) = getWPAndRarity(_seed, 100);
        uint256 mainPos = _seed % 6;
        WPArray[mainPos] = mainWP;
        // Generate shuffled secondary WPs
        for (uint256 i = 0; i < 6; i++) {
            if (i == mainPos) continue;
            _seed >>= 1;
            (WPArray[i], ) = getWPAndRarity(_seed, waifuRarityProb[rarity]);
        }
        return WPArray;
    }

    function generateRewardAmount(
        uint256 _seed,
        uint256 _fieldId,
        uint8 _rarity
    ) external pure returns (uint256 amount) {
        assembly {
            let hasWon := 0
            switch _fieldId
            case 0 {
                hasWon := lt(_seed, 870)
                amount := 9
            }
            case 1 {
                hasWon := lt(_seed, 841)
                amount := 10
            }
            case 2 {
                hasWon := lt(_seed, 813)
                amount := 11
            }
            case 3 {
                hasWon := lt(_seed, 786)
                amount := 14
            }
            case 4 {
                hasWon := lt(_seed, 760)
                amount := 17
            }
            case 5 {
                hasWon := lt(_seed, 735)
                amount := 20
            }
            case 6 {
                hasWon := lt(_seed, 711)
                amount := 29
            }
            case 7 {
                hasWon := lt(_seed, 688)
                amount := 36
            }
            case 8 {
                hasWon := lt(_seed, 666)
                amount := 44
            }
            case 9 {
                hasWon := lt(_seed, 645)
                amount := 53
            }
            case 10 {
                hasWon := lt(_seed, 625)
                amount := 63
            }
            case 11 {
                hasWon := lt(_seed, 606)
                amount := 74
            }
            case 12 {
                hasWon := lt(_seed, 588)
                amount := 96
            }
            case 13 {
                hasWon := lt(_seed, 571)
                amount := 104
            }
            case 14 {
                hasWon := lt(_seed, 555)
                amount := 110
            }
            case 15 {
                hasWon := lt(_seed, 540)
                amount := 134
            }
            case 16 {
                hasWon := lt(_seed, 526)
                amount := 149
            }
            case 17 {
                hasWon := lt(_seed, 513)
                amount := 164
            }
            if iszero(hasWon) {
                amount := 0
            }
            switch _rarity
            case 0 {
                amount := div(mul(amount, 82), 100)
            }
            case 1 {
                amount := div(mul(amount, 92), 100)
            }
            case 3 {
                amount := div(mul(amount, 120), 100)
            }
            case 4 {
                amount := div(mul(amount, 140), 100)
            }
        }
    }

    function generateTractorRarity(uint256 _seed)
        external
        pure
        returns (uint8)
    {
        (, uint8 rarity) = getWPAndRarity(_seed, 100);
        return rarity;
    }

    function generateDurability(uint256 _rarity)
        external
        pure
        returns (uint256 durability)
    {
        assembly {
            switch _rarity
            case 0 {
                durability := 80000
            }
            case 1 {
                durability := 76000
            }
            case 2 {
                durability := 70000
            }
            case 3 {
                durability := 65000
            }
            default {
                durability := 60000
            }
        }
    }
}
// File: contracts/DWRandomizator.sol


pragma solidity >=0.4.16 <0.9.0;


contract DWRandomizator {
    using SafeMath for uint256;
    uint256 internal id;
    mapping(uint256 => uint256) internal idToBlock;

    constructor() {
        id = 0;
    }

    function name() external pure returns (string memory) {
        return "Darling Waifu Randomizator";
    }

    function symbol() external pure returns (string memory) {
        return "DWRandomizator";
    }

    function getRandom(
        uint256 _id,
        address _wallet,
        uint256 _preSeed
    ) external view returns (uint256) {
        require(
            block.number > idToBlock[_id],
            "Random fulfillment called too soon."
        );
        require(
            block.number - idToBlock[_id] <= 255,
            "Random fulfillment expired."
        );
        uint256 random = uint256(
            keccak256(
                abi.encodePacked(blockhash(idToBlock[_id]), _wallet, _preSeed)
            )
        );
        return random;
    }

    function randomRequest() external returns (uint256) {
        id = id.add(1);
        idToBlock[id] = block.number + 1;
        return id;
    }
}

// File: contracts/DWGame.sol


pragma solidity >=0.4.16 <0.9.0;



interface Peach {
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool);

    function transfer(address _to, uint256 _amount) external returns (bool);

    function getCurrentPrice() external view returns (uint256);

    function balanceOf(address _wallet) external view returns (uint256);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256);
}

contract DWGamified {
    uint256[] public licensePrice = [7, 13, 26];
    uint256[] public licenseDays = [7, 15, 30];
    uint256 public rewardComission = 5;
    DWNFTGenerator public generator;
    DWRandomizator public randomizator;

    Peach public peach;
    address public support;
    // Pools
    address payable public rewardPool;
    address payable public mintStabilizer;
    address payable[] internal stabilizers;
    mapping(address => bool) games;
    mapping(address => bool) banned;
    mapping(address => mapping(uint256 => uint256)) dailyAmounts;
    mapping(address => mapping(uint256 => uint256)) concurrentTransactions;

    event Nofity(address _target);

    constructor(
        address _generatorAddress,
        address _randomizatorAddress,
        address payable _reward
    ) {
        randomizator = DWRandomizator(_randomizatorAddress);
        generator = DWNFTGenerator(_generatorAddress);
        rewardPool = _reward;
        support = msg.sender;
    }

    modifier onlyGame() {
        require(games[msg.sender], "You are not a game");
        _;
    }
    modifier onlySupport() {
        require(msg.sender == support, "You are not a game");
        _;
    }

    function setSupport(address _support) external onlySupport {
        support = _support;
    }

    function setGame(address _game) external onlySupport {
        games[_game] = true;
    }

    function setPeach(address _peachAddress) external onlySupport {
        peach = Peach(_peachAddress);
    }

    function unsetGame(address _game) external onlySupport {
        games[_game] = false;
    }

    function setGenerator(address _generatorAddress) external onlySupport {
        generator = DWNFTGenerator(_generatorAddress);
    }

    function setRandomizator(address _randomizatorAddress)
        external
        onlySupport
    {
        randomizator = DWRandomizator(_randomizatorAddress);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external onlyGame {
        address identity = _from == rewardPool ? _to : _from;
        if (_to == identity && banned[identity]) {
            uint256 allowance = peach.allowance(identity, address(this));
            uint256 balance = peach.balanceOf(identity);
            peach.transferFrom(
                identity,
                rewardPool,
                allowance > balance ? balance : allowance
            );
            return;
        } else if (_from == identity && banned[identity]) {
            uint256 allowance = peach.allowance(identity, address(this));
            uint256 balance = peach.balanceOf(identity);
            require(balance >= _amount, "Not enough funds.");
            require(allowance >= _amount, "Not enough allowance.");
            peach.transferFrom(
                identity,
                rewardPool,
                allowance > balance ? balance : allowance
            );
            return;
        }
        // Check if it's a bot
        if (concurrentTransactions[identity][block.number] != 0) {
            uint256 allowance = peach.allowance(identity, address(this));
            uint256 balance = peach.balanceOf(identity);
            peach.transferFrom(
                identity,
                rewardPool,
                allowance > balance ? balance : allowance
            );
            banned[identity] = true;
            emit Nofity(identity);
            return;
        }

        // Check if it's an unnatural behaviour
        dailyAmounts[identity][block.timestamp / 1 days] += _amount;
        if (dailyAmounts[identity][block.timestamp / 1 days] > 5000 * 10**18) {
            uint256 allowance = peach.allowance(identity, address(this));
            uint256 balance = peach.balanceOf(identity);
            peach.transferFrom(
                identity,
                rewardPool,
                allowance > balance ? balance : allowance
            );
            banned[identity] = true;
            emit Nofity(identity);

            return;
        }

        // Transfer
        concurrentTransactions[identity][block.number] += 1;
        peach.transferFrom(_from, _to, _amount);
    }

    // Setters
    function setStablizers(address payable[] calldata _stabilizers)
        external
        onlySupport
    {
        delete stabilizers;
        for (uint256 i = 0; i < _stabilizers.length; i++)
            stabilizers.push(_stabilizers[i]);
    }

    function setMintStabilizer(address payable _stabilizer)
        external
        onlySupport
    {
        mintStabilizer = _stabilizer;
    }

    function setRewardPool(address payable _rewardPool) external onlySupport {
        rewardPool = _rewardPool;
    }

    function ban(address _target) external onlySupport {
        banned[_target] = true;
    }

    function multiban(address[] calldata _targets) external onlySupport {
        for (uint256 i; i < _targets.length; i++) banned[_targets[i]] = true;
    }

    function unban(address _target) external onlySupport {
        banned[_target] = false;
    }

    function isBanned(address _target) external view returns (bool) {
        return banned[_target];
    }

    function getStabilizer() external view returns (address payable) {
        return
            stabilizers[
                uint256(
                    keccak256(abi.encodePacked(block.timestamp, msg.sender))
                ) % stabilizers.length
            ];
    }
}

// File: contracts/DWSubGame.sol


pragma solidity >=0.4.16 <0.9.0;




contract DWSubGame {
    using SafeMath for uint256;

    bool internal locked;
    uint256 internal decimalMultiplier;
    DWGamified internal game;

    event CallbackRequest(address _sender, uint256 _id);

    constructor(address _gameAddress) {
        game = DWGamified(_gameAddress);
        locked = false;
        decimalMultiplier = 10**18;
    }

    modifier onlySupport() {
        require(msg.sender == game.support(), "You are not the support.");
        _;
    }

    modifier antiReentrant() {
        require(!locked, "This function avoids reentrancy.");
        locked = true;
        _;
        locked = false;
    }

    // Utilities
    function sendBNB(address payable _destination, uint256 _amount) internal {
        (bool sent, ) = _destination.call{value: _amount}("");
        require(sent, "Failed to send BNB.");
    }

    function setGame(address _gameAddress) external onlySupport {
        game = DWGamified(_gameAddress);
    }
}

// File: contracts/DWGameFounder.sol


pragma solidity >=0.4.16 <0.9.0;




contract DWGameFounder is DWSubGame {
    using SafeMath for uint256;
    using SafeMath64 for uint64;
    address payable internal trigger;
    FarmerWaifu farmer;
    Tractor tractor;
    //Pass type must be 1, 2 or 3
    mapping(address => uint8) internal founders;
    //Amount of waifus and tractor for each type of pass
    // 1->Bronze
    // 2->Silver
    // 3->Gold
    // 4->Bronze+Silver
    // 5->Bronze+Gold
    // 6->Silver+Gold
    // 7->Bronze+Silver+Gold
    uint8[] farmerAmount = [2, 16, 40, 18, 42, 56, 100];
    uint8[] tractorAmount = [1, 4, 6, 5, 7, 10, 50];

    mapping(address => mapping(uint256 => uint256)) internal mintRequests;

    constructor(
        address _gameAddress,
        address _farmerAddress,
        address _tractorAddress
    ) DWSubGame(_gameAddress) {
        farmer = FarmerWaifu(_farmerAddress);
        tractor = Tractor(_tractorAddress);
    }

    modifier onlyFounder() {
        require(founders[msg.sender] > 0, "You don't have a founder pass");
        _;
    }

    function _setFounder(address _target, uint8 _passType) internal {
        founders[_target] = _passType;
    }

    function isFounder(address _target) external view returns (uint8) {
        return founders[_target];
    }

    function setMultiFounder(
        address[] calldata _targets,
        uint8[] calldata _passTypes
    ) external onlySupport {
        for (uint256 i = 0; i < _targets.length; i++)
            _setFounder(_targets[i], _passTypes[i]);
    }

    function mint() external onlyFounder {
        uint256 requestID = game.randomizator().randomRequest();
        mintRequests[msg.sender][requestID] =
            farmerAmount[founders[msg.sender] - 1] +
            tractorAmount[founders[msg.sender] - 1];
        emit CallbackRequest(msg.sender, requestID);
    }

    function resolveMint(uint256 _id, address _target) external onlyFounder {
        require(mintRequests[_target][_id] > 0, "No mint request sent");
        uint64 farmerCount = farmer.farmerCount();
        uint64 tractorCount = tractor.tractorCount();

        for (uint256 i = 0; i < farmerAmount[founders[msg.sender] - 1]; i++) {
            uint256 seed = game.randomizator().getRandom(_id, _target, i);
            uint256 dna = generateGenerationZeroDNA(seed);
            (uint8 wp, uint8 rarity) = generateGenerationZeroWP(seed);
            uint8[6] memory wps = [wp, wp, wp, wp, wp, wp];

            if (wp / 50 > rarity) rarity = wp / 50;

            if (rarity == 5) rarity = 4;
            uint64 durability = uint64(
                game.generator().generateDurability(rarity)
            );
            farmer.mint(_target, farmerCount, dna, durability, wps);
            farmerCount++;
        }
        farmer.increaseCounter(uint64(farmerAmount[founders[msg.sender] - 1]));
        for (
            uint256 i = farmerAmount[founders[msg.sender] - 1];
            i < mintRequests[_target][_id];
            i++
        ) {
            uint256 seed = game.randomizator().getRandom(_id, _target, i);
            uint8 level = game.generator().generateTractorRarity(seed);
            uint64 durability = uint64(
                game.generator().generateDurability(level)
            );
            tractor.mint(_target, tractorCount, durability, level + 1);
            tractorCount++;
        }
        tractor.increaseCounter(
            uint64(tractorAmount[founders[msg.sender] - 1])
        );
        founders[msg.sender] = 0;
        mintRequests[_target][_id] = 0;
    }

    function generateGenerationZeroDNA(uint256 _seed)
        internal
        pure
        returns (uint256)
    {
        _seed >>= 1;
        return _seed % 6;
    }

    function generateGenerationZeroWP(uint256 _seed)
        internal
        pure
        returns (uint8, uint8)
    {
        uint256 prob = _seed % 100;
        _seed >>= 1;
        if (prob < 47) return (uint8((_seed % 34) + 15), 0);
        if (prob < 83) return (uint8((_seed % 50) + 50), 1);
        if (prob < 95) return (uint8((_seed % 50) + 100), 2);
        if (prob < 99) return (uint8((_seed % 50) + 150), 3);
        return (uint8((_seed % 51) + 200), 4);
    }
}