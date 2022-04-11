/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

// Sources flattened with hardhat v2.9.3 https://hardhat.org

// File @openzeppelin/contracts/utils/introspection/[email protected]

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


// File @openzeppelin/contracts/token/ERC721/[email protected]

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


// File @openzeppelin/contracts/token/ERC721/[email protected]

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


// File @openzeppelin/contracts/token/ERC721/extensions/[email protected]

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


// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/utils/introspection/[email protected]

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


// File @openzeppelin/contracts/token/ERC721/[email protected]

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


// File @openzeppelin/contracts/token/ERC721/extensions/[email protected]

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}


// File @openzeppelin/contracts/token/ERC721/extensions/[email protected]

// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;


/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
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
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}


// File @openzeppelin/contracts/access/[email protected]

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


// File contracts/LuckyMonsterStorage.sol

pragma solidity ^0.8.6;

abstract contract LuckyMonsterStorage is Ownable {
    address internal _logicAddr;

    string internal baseURI;

    // mapping from manager to exist
    mapping(address => bool) internal _manager;

    // whitelist mapping
    mapping(address => bool) public whitelist;

    // all whitelist
    // address[] internal _whitelists;

    // mapping from whitelist account to index of _allWhitelist
    // mapping(address => uint256) internal _whitelistIndex;

    // ordinary sale time (second)
    uint256 internal _saleTime;

    // whitelist sale time
    uint256 internal _whitelistSaleTime;

    // ordinary sale price (18wei)
    uint256 internal _mintPrice;

    // whitelist sale price
    uint256 internal _whitelistPrice;

    // max token count mint for one account (per season)
    uint256 internal _maxPersonalMint;

    // mapping from season to mint amount of owner
    mapping(uint256 => mapping(address => uint256)) public personalMint;

    // platform fee address
    address internal _feeAddr;

    // platform fee ratio (10000 mean 100%)
    uint256 internal _feeRatio;

    // game start time
    uint256 internal _startTime;

    // current season, start from 1
    uint256 internal _season;

    // current round, start from 1
    uint256 internal _round;

    // mapping from season to champion token
    mapping(uint256 => uint256) public champion;

    
    mapping(uint256 => bool) internal _joinedMonster;

    // owner of token before join game
    mapping(uint256 => address) internal _ownerOfMonster;

    // mapping from tokenId to inject reward
    mapping(uint256 => uint256) internal _injectReward;

    // total reward, related to number of token minted
    uint256 internal _totalReward;

    // reward for this season, related to monsters in the game
    uint256 internal _seasonReward;

    // max zone can choose
    uint256 internal _maxZone;

    // max monster in one zone
    uint256 internal _maxMonster;

    // mapping from monster id to zone
    mapping(uint256 => uint256) internal _zoneOfMonster;

    mapping(uint256 => uint256) internal _monsterIndex;

    // mapping from zone to token list
    mapping(uint256 => uint256[]) public monstersOfZone;

    // transfer dead monsters to
    address internal _deadAddr;

    // dead ratio every round, no more than 30
    uint256 internal _deadRatio;

    // stop announce when alive monster count greater than this number
    uint256 internal _announceStopCount;

    // bomb period from last bomb time
    uint256 internal _bombPeriod;

    // next bomb time
    uint256 internal _nextBombTime;

    // zones have alive monster
    uint256[] internal _aliveZones;

    mapping(uint256 => uint256) internal _aliveZoneIndex;

    uint256[] internal _nextBombZones;

    // secret
    uint256 internal _randomKey;

    struct MintInfo {
        uint256 saleTime;
        uint256 whitelistSaleTime;
        uint256 mintPrice;
        uint256 whitelistPrice;
        uint256 maxPersonalMint;
        address feeAddr;
        uint256 feeRatio;
    }

    struct GameInfo {
        uint256 season;
        uint256 round;
        uint256 totalReward;
        uint256 seasonReward;
        uint256 startTime;
        uint256 aliveMonsters;
        address deadAddr;
        uint256 deadRatio;
        uint256 announceStopCount;
        uint256 bombPeriod;
        uint256 nextBombTime;
        uint256[] nextBombZones;
        uint256[] aliveZones;
    }

    struct MonsterInfo {
        address owner;
        bool joined;
        uint256 zone;
        uint256 zoneIndex;
    }

    // event
    event JoinGame(
        uint256 indexed season,
        address indexed owner,
        uint256 indexed tokenId,
        uint256 zone
    );

    event ChangeZone(
        uint256 indexed season,
        address indexed owner,
        uint256 indexed tokenId,
        uint256 zone
    );

    event LeaveGame(
        uint256 indexed season,
        uint256 indexed zone,
        uint256 indexed tokenId,
        uint256 round,
        uint256 reward
    );

    event Eliminate(
        uint256 indexed season,
        uint256[] zones,
        uint256[] tokenIds,
        uint256 round
    );

    // error
    error NotOwnerOrManager();
    error NotSaleTime();
    error InvalideValue();
    error JoinTimeIsOver();
    error JoinTwice();
    error ZoneInvalid();
    error ExceedMaxAmount();
    error GameNotStart();
    error NotBombTime();
    error NotChangeRound();
    error OwnerNotMatch();
    error AddressCannotReceive();
    error GameIsOver();
    error GameNotOver();
    error SeasonInvalid();
}


// File contracts/LuckyMonsterLogic.sol

pragma solidity ^0.8.6;


contract LuckyMonsterLogic is ERC721Enumerable, LuckyMonsterStorage {

    constructor() ERC721("", "") {}

    fallback() external payable {}

    function setBaseURI(string memory baseURI_) external onlyManager {
        baseURI = baseURI_;
    }

    // ====================== manager ======================

    function isManager(address _addr) public view returns(bool) {
        return (owner() == _addr || _manager[_addr]);
    }

    modifier onlyManager() {
        if (!isManager(msg.sender)) {
            revert NotOwnerOrManager();
        }
        _;
    }

    function updateManager(address account, bool enable) external onlyOwner {
        if (enable) {
            _manager[account] = true;
        } else {
            delete _manager[account];
        }
    }

    // function addManager(address _account) external onlyOwner {
    //     if (!_manager[_account]) {
    //         _manager[_account] = true;
    //     }
    // }

    // function removeManager(address _account) external onlyOwner {
    //     delete _manager[_account];
    // }

    // ====================== whitelist ======================

    function updateWhitelist(address account, bool enable) external onlyOwner {
        if (enable) {
            whitelist[account] = true;
        } else {
            delete whitelist[account];
        }
    }
    
    // function isWhitelist(address _account) public view returns(bool) {
    //     return whitelist[_account];
    // }

    // function whitelists() public view returns(address[] memory) {
    //     return _whitelists;
    // }

    // function addWhitelist(address _account) external onlyManager {
        // if (!whitelist[_account]) {
            // _whitelistIndex[_account] = _whitelists.length;
            // _whitelists.push(_account);
        // }
    // }

    // function removeWhitelist(address _account) external onlyManager {
        // uint256 index = _whitelistIndex[_account];
        // address lastAccount = _whitelists[_whitelists.length - 1];

        // _whitelists[index] = lastAccount;
        // _whitelistIndex[lastAccount] = index;

        // delete _whitelistIndex[_account];
        // _whitelists.pop();
        // delete whitelists[_account];
    // }

    // ====================== mint ======================

    function setMintConfig(uint256 whitelistSaleTime, uint256 saleTime, uint256 whitelistPrice, uint256 mintPrice, 
        uint256 maxPersonalMint, address feeAddr, uint256 feeRatio) external onlyManager {
        _whitelistSaleTime = whitelistSaleTime;
        _saleTime = saleTime;
        _whitelistPrice = whitelistPrice;
        _mintPrice = mintPrice;
        _maxPersonalMint = maxPersonalMint;
        _feeAddr = feeAddr;
        _feeRatio = feeRatio;
    }

    // mint monster
    function mint() external payable {
        // check time and paid amount
        address sender = msg.sender;
        bool isWhitelist = whitelist[sender];
        if ((isWhitelist && (block.timestamp < _whitelistSaleTime || _whitelistSaleTime == 0)) 
            || (!isWhitelist && (block.timestamp < _saleTime || _saleTime == 0))) {
            revert NotSaleTime();
        }
        if ((isWhitelist && (msg.value != _whitelistPrice || _whitelistPrice == 0)) 
            || (!isWhitelist && (msg.value != _mintPrice || _mintPrice == 0))) {
            revert InvalideValue();
        }

        // check amount
        if (personalMint[_season][sender] >= _maxPersonalMint) {
            revert ExceedMaxAmount();
        }
        personalMint[_season][sender]++;
        // transfer fee
        uint256 fee = msg.value * _feeRatio / 10000;
        uint256 injectReward = msg.value - fee;
        payable(_feeAddr).transfer(fee);

        // mint
        uint256 tokenId = totalSupply();
        _mint(sender, tokenId);

        // reward
        _totalReward += injectReward;
        _injectReward[tokenId] = injectReward;
    }

    // ====================== join ======================

    function setGameConfig(uint256 season, uint256 startTime, uint256 maxZone, uint256 maxMonster, uint256 announceStopCount, uint256 bombPeriod, 
        address deadAddr, uint256 deadRatio) external onlyManager {
        if (season > _season) {
            if (season != _season + 1) {
                revert SeasonInvalid();
            }
            if (block.timestamp > _startTime && balanceOf(address(this)) == 0) {
                _season = season;
                _round = 0;
            } else {
                revert GameNotOver();
            }
        }
        _startTime = startTime;
        _maxZone = maxZone;
        _maxMonster = maxMonster;
        _announceStopCount = announceStopCount;
        _bombPeriod = bombPeriod;
        _deadAddr = deadAddr;
        _deadRatio = deadRatio;
    }

    // join game before started
    // function joinGame(uint256 _tokenId, uint256 _zone) external {
    //     _joinGame(_tokenId, _zone);
    // }

    // batch join game, no more than 20
    // function batchJoinGame(uint256[] memory _tokenIds, uint256[] memory _zones) external {
    //     for (uint256 i; i < _tokenIds.length; i++) {
    //         _joinGame(_tokenIds[i], _zones[i]);
    //     }
    // }

    function joinGame(uint256 tokenId, uint256 zone) external {
        // check time
        if (block.timestamp >= _startTime || _startTime == 0) {
            revert JoinTimeIsOver();
        }
        if (_joinedMonster[tokenId]) {
            revert JoinTwice();
        }
        if (zone == 0 || zone > _maxZone) {
            revert ZoneInvalid();
        }
        if (monstersOfZone[zone].length >= _maxMonster) {
            revert ExceedMaxAmount();
        }
        
        // transfer token
        super.transferFrom(msg.sender, address(this), tokenId);

        // set monster
        _joinedMonster[tokenId] = true;
        _ownerOfMonster[tokenId] = msg.sender;
        _addMonsterToZone(tokenId, zone);

        if (monstersOfZone[zone].length == 1) {
            _addAliveZone(zone);
        }

        // inject reward to pool
        _seasonReward += _injectReward[tokenId];
        emit JoinGame(_season, msg.sender, tokenId, zone);
    }

    // ====================== start ======================

    // function monsterInfo(uint256 tokenId) external view returns(address, bool, uint256, uint256) {
    //     return (_ownerOfMonster[tokenId], _joinedMonster[tokenId],_zoneOfMonster[tokenId], _monsterIndex[tokenId]);
    // }

    function nextDeadCount() public view returns(uint256) {
        uint256 _aliveMonsters = balanceOf(address(this));

        if (_aliveMonsters == 0) {
            return 0;
        }
        uint256 nextDead = _aliveMonsters * _deadRatio / 10000;
        if (nextDead > 30) {
            nextDead = 30;
        }
        if (nextDead == 0) {
            nextDead = 1;
        }
        if (nextDead >= _aliveMonsters) {
            nextDead = _aliveMonsters - 1;
        }
        return nextDead;
    }

    function randomBomb() external {
        // check time
        if (_round == 0) {
            // if (block.timestamp < _startTime) {
            //     revert NotBombTime();
            // }
            _randomZone();
            _round = 1;
            _nextBombTime = _startTime;
        }
        if (block.timestamp < _startTime || block.timestamp < _nextBombTime || _nextBombTime == 0) {
            revert NotBombTime();
        }
        uint256 _nextDeadCount = nextDeadCount();
        if (_nextDeadCount == 0) {
            revert GameIsOver();
        }

        // round after change zone
        if (_round % 10 == 0 || balanceOf(address(this)) <= _announceStopCount) {
            _randomZone();
        }

        // random kill monster
        // generate start index
        uint256[] memory startIndex = new uint256[](_nextBombZones.length);
        uint256 totalCount;
        for (uint256 i = 0; i < _nextBombZones.length; i++) {
            startIndex[i] = totalCount;
            totalCount += monstersOfZone[_nextBombZones[i]].length;
        }
        // random number
        uint256 tmpKey = _randomKey;
        uint256 blockHash = uint256(blockhash(block.number - 1));
        // for log
        uint256[] memory deadZone = new uint256[](_nextDeadCount);
        uint256[] memory deadMonsters = new uint256[](_nextDeadCount);
        for (uint256 i = 0; i < _nextDeadCount; i++) {
            tmpKey = uint256(keccak256(abi.encodePacked(blockHash + i, tmpKey)));
            // find index in which zone
            uint256 index = tmpKey % totalCount;
            bool removed;
            for (uint256 j = 0; j < startIndex.length; j++) {
                if (removed) {
                    // update start index
                    startIndex[j]--;
                } else if ((j < startIndex.length - 1 && index < startIndex[j + 1]) 
                    || (j == startIndex.length - 1 && index >= startIndex[j])) {
                    // remove from zone
                    uint256 zone = _nextBombZones[j];
                    uint256 length = monstersOfZone[zone].length;
                    uint256 tokenId = monstersOfZone[zone][(index - startIndex[j]) % length];
                    // _removeMonsterFromZone(tokenId, zone);
                    // _transfer(address(this), _deadAddr, tokenId);
                    // delete _ownerOfMonster[tokenId];
                    _transferMonster(_deadAddr, tokenId, zone);

                    deadMonsters[i] = tokenId;
                    deadZone[i] = zone;
                    totalCount--;
                    removed = true;

                    // remove from alive zone if empty
                    // if (monstersOfZone[zone].length == 0) {
                    //     _removeAliveZone(zone);
                    // }
                }
            }
        }
        _randomKey = tmpKey;
        emit Eliminate(_season, deadZone, deadMonsters, _round);
        // champion
        if (balanceOf(address(this)) == 1) {
            _championReward();
            return;
        }

        _round++;
        _nextBombTime += _bombPeriod;
        // generate next zone
        if (_round % 10 == 0 || balanceOf(address(this)) <= _announceStopCount) {
            // clear next zone
            _clearNextBombZone();
        } else {
            _randomZone();
        }
    }

    function _randomZone() internal {
        // choose all alive zone if count less than 3
        if (_aliveZones.length <= 3) {
            _nextBombZones = _aliveZones;
            return;
        }

        _clearNextBombZone();
        // random get zone
        uint256 totalCount;
        uint256 _nextDeadCount = nextDeadCount();
        uint256 tmpKey = _randomKey;

        uint256[] memory tmpAliveZone = _aliveZones;
        uint256 tmpAliveZoneLength = tmpAliveZone.length;
        
        while(_nextBombZones.length < 3 || totalCount < _nextDeadCount) {
            uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, tmpKey)));
            uint256 index = random % tmpAliveZoneLength;
            _nextBombZones.push(tmpAliveZone[index]);
            totalCount += monstersOfZone[tmpAliveZone[index]].length;
            // swap and logic delete
            tmpAliveZone[index] = tmpAliveZone[tmpAliveZoneLength - 1];
            tmpAliveZoneLength--;
            tmpKey = random;
        }
        _randomKey = tmpKey;
    }

    function _clearNextBombZone() internal {
        while(_nextBombZones.length > 0) {
            _nextBombZones.pop();
        }
    }

    // change to another zone every 10 round 
    function changeZone(uint256 tokenId, uint256 zone) external {
        // check round
        if (_round < 10 || _round % 10 != 0) {
            revert NotChangeRound();
        }

        uint256 fromZone = _zoneOfMonster[tokenId];
        // if (fromZone == zone) {
        //     revert ZoneNotChange();
        // }
        if (fromZone == zone || zone == 0 || zone > _maxZone) {
            revert ZoneInvalid();
        }

        _removeMonsterFromZone(tokenId, fromZone);
        _addMonsterToZone(tokenId, zone);

        // add to alive zone
        if (monstersOfZone[zone].length == 1) {
            _addAliveZone(zone);
        }
        // remove from alive zone
        if (monstersOfZone[fromZone].length == 0) {
            _removeAliveZone(zone);
        }
        emit ChangeZone(_season, msg.sender, tokenId, zone);
    }

    // leave game and take the reward
    function leaveGame(uint256 tokenId) external {
        // check token owner
        if (_ownerOfMonster[tokenId] != msg.sender) {
            revert OwnerNotMatch();
        }
        if (_round == 0) {
            revert GameNotStart();
        }
        // remove
        uint256 zone = _zoneOfMonster[tokenId];
        // _removeMonsterFromZone(tokenId, zone);
        // delete _ownerOfMonster[tokenId];
        _transferMonster(msg.sender, tokenId, zone);

        // transfer reward
        uint256 reward = _seasonReward / balanceOf(address(this));
        _seasonReward -= reward;
        _totalReward -= reward;
        // _transfer(address(this), msg.sender, tokenId);

        payable(msg.sender).transfer(reward);

        // champion
        if (balanceOf(address(this)) == 1) {
            _championReward();
        }
        emit LeaveGame(_season, zone, tokenId, _round, reward);
    }

    function _championReward() internal {
        uint256 championToken = tokenOfOwnerByIndex(address(this), 0);
        champion[_season] = championToken;
        // _transfer(address(this), _ownerOfMonster[championToken], championToken);
        // delete _ownerOfMonster[championToken];
        address championOwner = _ownerOfMonster[championToken];
        uint256 zone = _zoneOfMonster[championToken];
        _transferMonster(championOwner, championToken, zone);
        payable(championOwner).transfer(_seasonReward);
        _totalReward -= _seasonReward;
        _seasonReward = 0;
        emit LeaveGame(_season, zone, championToken, _round, _seasonReward);
    }

    // transfer monster from arena and remove data
    function _transferMonster(address to, uint256 tokenId, uint256 zone) internal {
        _transfer(address(this), to, tokenId);
        delete _ownerOfMonster[tokenId];
        _removeMonsterFromZone(tokenId, zone);
        if (monstersOfZone[zone].length == 0) {
            _removeAliveZone(zone);
        }
    }

    function _addMonsterToZone(uint256 tokenId, uint256 zone) internal {
        _zoneOfMonster[tokenId] = zone;
        _monsterIndex[tokenId] = monstersOfZone[zone].length;
        monstersOfZone[zone].push(tokenId);
    }

    function _removeMonsterFromZone(uint256 tokenId, uint256 zone) internal {
        uint256 index = _monsterIndex[tokenId];
        uint256 lastMonster = monstersOfZone[zone][monstersOfZone[zone].length - 1];

        monstersOfZone[zone][index] = lastMonster;
        _monsterIndex[lastMonster] = index;

        monstersOfZone[zone].pop();
        delete _monsterIndex[tokenId];
        delete _zoneOfMonster[tokenId];
    }

    function _addAliveZone(uint256 zone) internal {
        _aliveZoneIndex[zone] = _aliveZones.length;
        _aliveZones.push(zone);
    }

    function _removeAliveZone(uint256 zone) internal {
        uint256 index = _aliveZoneIndex[zone];
        uint256 lastZone = _aliveZones[_aliveZones.length - 1];

        _aliveZones[index] = lastZone;
        _aliveZoneIndex[lastZone] = index;

        _aliveZones.pop();
        delete _aliveZoneIndex[zone];
    }

    // contract cannot receive by transfer
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        if (to == address(this)) {
            revert AddressCannotReceive();
        }
        super.transferFrom(from, to, tokenId);
    }

    function emergencyWithdraw(address account) external onlyOwner {
        payable(account).transfer(address(this).balance);
    }

}