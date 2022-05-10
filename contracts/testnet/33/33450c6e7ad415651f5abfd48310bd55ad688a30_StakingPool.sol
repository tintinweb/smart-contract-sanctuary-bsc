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


// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/token/ERC721/ERC721.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/ERC721.sol)

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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

// File: contracts/pool/Upgradable.sol


pragma solidity ^0.8.0;





contract Upgradable is Ownable {
    
    address public feeRecipientAddress; // Address receive tax fee
    uint256 public taxFee; // Tax fee when stake, restake, unstake, claim
    uint256 public totalPoolCreated; // Total pool created by admin
    uint256 public totalUserStaked; // Total user staked to pools
    // uint256 constant ONE_DAY_IN_SECONDS = 86400;
    uint256 public ONE_DAY_IN_SECONDS = 86400;
    uint256 constant ONE_YEAR_IN_SECONDS = 31536000;
    mapping(address => bool) adminList; // Admin list
    mapping(address => bool) blackList; // Blocked users
    mapping(string => PoolInfo) public poolInfo; // Pools info
    mapping(address => uint256) public totalAmountStaked; //  tokenAddress => totalAmountStaked: balance of token staked to the pools
    mapping(address => uint256) public totalRewardClaimed; // tokenAddress => totalRewardClaimed: total reward user has claimed
    mapping(address => uint256) public totalRewardFund; // tokenAddress => rewardFund: total pools reward fund
    mapping(address => uint256) public totalStakedBalancePerUser; // total value users staked to the pool
    mapping(address => mapping(address => uint256)) public totalStakedBalanceByToken; // tokenAddress => userAddress => amount: total balance user staked
    mapping(address => mapping(address => uint256)) public totalRewardClaimedPerUser; // tokenAddress => userAddress => amount: total reward users claimed
    mapping(string => mapping(address => StakingData)) public tokenStakingData; // poolId => userAddress => data: users' staking data
    mapping(string => mapping(address => uint256)) public stakedBalancePerUser; // poolId => userAddress => balance: total value each user staked to the pool
    mapping(string => mapping(address => uint256)) public rewardClaimedPerUser; // poolId => userAddress => balance: reward each user has claimed
    address public controller;
    mapping(address => bool) superAdminList; //Super Admin list
    // uint256 totalSuperAdmin; // total Super Admin
    uint256 public totalUserStakeNFT721;
    mapping(address => uint256) public totalStakedNFT721BalancePerUser;
    mapping(address => mapping(address => uint256)) public totalStakedNFT721BalanceByNFT;
    mapping(string => mapping(uint256 => address)) public stakeNFT721ByUser; // poolId => tokenId => userAddress
    mapping(address => mapping(uint256 => bool)) public nftStake;
    mapping(address => uint256) public totalAmountNFT721Staked; //  tokenAddress => totalAmountStaked: balance of token staked to the pools
    
    /*================================ MODIFIERS ================================*/
    
    modifier onlyAdmins() {
        require(adminList[msg.sender] || superAdminList[msg.sender] || msg.sender == controller, "Only admins or super admins or controller");
        _;
    }
    
    modifier poolExist(string memory poolId) {
        require(poolInfo[poolId].initialFund != 0, "Pool is not exist");
        require(poolInfo[poolId].active == 1, "Pool has been disabled");
        _;
    }
    
    modifier notBlocked() {
        require(!blackList[msg.sender], "Caller has been blocked");
        _;
    }

    modifier onlyController() {
        require(msg.sender == controller, "Only controller");
        _;
    }

    modifier onlySuperAdmin() {
        require(superAdminList[msg.sender] || msg.sender == controller, "Only super admins or controller");
        _;
    }
    
    /*================================ EVENTS ================================*/
    
    event StakingEvent( 
        uint256 amount,
        address indexed account,
        string poolId,
        string internalTxID
    );
    
    event PoolUpdated(
        uint256 rewardFund,
        address indexed creator,
        string poolId,
        string internalTxID
    );

    event AdminSet(
        address indexed admin,
        bool isSet,
        string typeAdmin
    );

    event FeeRecipientSet(
        address indexed setter,
        address indexed recipient
    );

    event TaxFeeSet(
        address indexed setter,
        uint256 fee
    );

    event BlacklistSet(
        address indexed user,
        bool isSet
    );

    event PoolActivationSet(
        address indexed admin,
        string poolId,
        uint256 isActive
    );

    event ControllerTransferred(
        address indexed previousController, 
        address indexed newController
    );

    event StakeNFT(
        address tokenAddress,
        address from,
        address to,
        uint256 tokenId,
        uint256 amount,
        string poolId
    );
    
    /*================================ STRUCTS ================================*/
     
    struct StakingData {
        uint256 balance; // staked value
        uint256 stakedTime; // staked time
        uint256 lastUpdateTime; // last update time
        uint256 reward; // the total reward
        uint256 rewardPerTokenPaid; // reward per token paid
    }

    struct PoolInfo {
        address stakingToken; // staking token of the pool
        address rewardToken; // reward token of the pool
        uint256 stakedBalance; // total balance staked the pool
        uint256 totalRewardClaimed; // total reward user has claimed
        uint256 rewardFund; // reward token available
        uint256 initialFund; // initial reward fund
        uint256 apr; // annual percentage rate
        uint256 totalUserStaked; // total user staked
        uint256 rewardRatio; // ratio of reward amount user can claim, 0 < fixedTimeRate < 100
        uint256 stakingLimit; // maximum amount of token users can stake to the pool
        uint256 active; // pool activation status, 0: disable, 1: active
        uint256 poolType; // flexible: 0, fixedTime: 1, monthly: 2, 3: monthly with unstake period
        uint256[] flexData; // lastUpdateTime(0), rewardPerTokenPaid(1)
        uint256[] configs; // startDate(0), endDate(1), duration(2), endStakeDate(3), exchangeRateRewardToStaking(4), poolNFT(5)
        // uint256 poolNFT; // 1: pool Token, 2: pool 721, 3: pool 1155
    }
}

// File: contracts/pool/StakingPool.sol


pragma solidity ^0.8.0;


contract StakingPool is Upgradable {
    using SafeERC20 for IERC20;

    constructor() {
        _transferController(msg.sender);
    }

    /*================================ MAIN FUNCTIONS ================================*/
    
    /**
     * @dev Stake token to a pool  
     * @param strs: poolId(0), internalTxID(1)
     * @param amount: amount of token user want to stake to the pool
    */
    function stakeToken(string[] memory strs, uint256 amount) external poolExist(strs[0]) notBlocked payable {
        string memory poolId = strs[0];
        PoolInfo storage pool = poolInfo[poolId];
        StakingData storage data = tokenStakingData[poolId][msg.sender];
        require(pool.configs[5] == 1,"This pool cant stake Token");
        require(block.timestamp >= pool.configs[0], "Staking time has not been started");
        require(block.timestamp <= pool.configs[3], "Staking time has ended"); 
        require(amount > 0, "Staking amount must be greater than 0");
        require(msg.value == taxFee, "Tax fee amount is invalid");
        require(amount <= pool.stakingLimit, "Pool staking limit is exceeded");

        updateDataPool(poolId, data, 0);
        
        // Update staking amount
        data.balance += amount;
        
        if (totalStakedBalancePerUser[msg.sender] == 0) {
            totalUserStaked += 1;
        }
        // Update user staked balance
        totalStakedBalancePerUser[msg.sender] += amount;
        
        // Update user staked balance by token address
        totalStakedBalanceByToken[pool.stakingToken][msg.sender] += amount; 
        
        if (stakedBalancePerUser[poolId][msg.sender] == 0) {
            pool.totalUserStaked += 1;
        }
        // Update user staked balance by pool
        stakedBalancePerUser[poolId][msg.sender] += amount;
        
        // Update pool staked balance
        pool.stakedBalance += amount;

        // Update staking limit
        pool.stakingLimit -= amount;
        
        // Update total staked balance by token address
        totalAmountStaked[pool.stakingToken] += amount;
        
        // Transfer user's token to the pool
        IERC20(pool.stakingToken).safeTransferFrom(msg.sender, address(this), amount);
        
        // Transfer tax fee
        _transferTaxFee();
        
        emit StakingEvent(amount, msg.sender, poolId, strs[1]);
    }

     /**
     * @dev Stake NFT721 to a pool  
     * @param strs: poolId(0), internalTxID(1)
     * @param tokenId: id of token 
    */
    function stakeNFT721(string[] memory strs, uint256 tokenId) external poolExist(strs[0]) notBlocked payable{
        string memory poolId = strs[0];
        PoolInfo storage pool = poolInfo[poolId];
        StakingData storage data = tokenStakingData[poolId][msg.sender];
        require(pool.configs[5] == 2,"This pool cant stake NFT721");
        require(block.timestamp >= pool.configs[0], "Staking time has not been started");
        require(block.timestamp <= pool.configs[3], "Staking time has ended"); 
        require(msg.value == taxFee, "Tax fee amount is invalid");
        require(pool.stakingLimit > 0, "Pool staking limit is exceeded");

        updateDataPool(poolId, data, 0);
        
        // Update staking amount
        data.balance += 1e18;
        
        if (totalStakedNFT721BalancePerUser[msg.sender] == 0) {
            totalUserStakeNFT721 += 1;
        }

        stakeNFT721ByUser[poolId][tokenId] = msg.sender;
        // Update user staked balance
        totalStakedNFT721BalancePerUser[msg.sender] += 1;
        
        // Update user staked balance by token address
        totalStakedNFT721BalanceByNFT[pool.stakingToken][msg.sender] += 1; 
        
        if (stakedBalancePerUser[poolId][msg.sender] == 0) {
            pool.totalUserStaked += 1;
        }
        // Update user staked balance by pool
        stakedBalancePerUser[poolId][msg.sender] += 1;
        
        // Update pool staked balance
        pool.stakedBalance += 1e18;

        // Update staking limit
        pool.stakingLimit -= 1e18;
        
        // Update total staked balance by token address
        totalAmountNFT721Staked[pool.stakingToken] += 1e18;

        nftStake[pool.stakingToken][tokenId] = true;
        
        // Transfer user's token to the pool
        ERC721(pool.stakingToken).safeTransferFrom(msg.sender, address(this), tokenId);
        
        // Transfer tax fee
        _transferTaxFee();
        
        emit StakeNFT(pool.stakingToken, msg.sender, address(this), tokenId, 1, poolId);
    }

    /** 
     * @dev Take total amount of staked token and reward and stake to the pool
     * @param strs: poolId(0), internalTxID(1)
    */
    function restakeToken(string[] memory strs) external poolExist(strs[0]) notBlocked payable {
        string memory poolId = strs[0];
        PoolInfo storage pool = poolInfo[poolId];
        StakingData storage data = tokenStakingData[poolId][msg.sender];
        
        require(block.timestamp <= pool.configs[3], "Staking time has ended"); 
        require(pool.stakingToken == pool.rewardToken, "Staking token and reward token must be the same");
        require(msg.value == taxFee, "Tax fee amount is invalid");
        
        // If not flexible pool
        if (pool.poolType != 0) {
            require(data.stakedTime + pool.configs[2] * ONE_DAY_IN_SECONDS <= block.timestamp, "Need to wait until staking period ended");
        }

        updateDataPool(poolId, data, 0);
        
        // Users can restaked only if reward > 0
        uint256 addingAmount = data.reward;
        require(data.reward > 0, "Reward must be greater than 0");
        require(addingAmount <= pool.stakingLimit, "Pool staking limit is exceeded");
        
        // Update staked balance and reset reward
        data.balance += addingAmount;
        data.reward = 0;

        // Update balance user has staked to the pool
        totalStakedBalancePerUser[msg.sender] += addingAmount;
        
        // Update balance user has staked by token address
        totalStakedBalanceByToken[pool.stakingToken][msg.sender] += addingAmount;
        
        // Update user staked balance to the pool
        stakedBalancePerUser[poolId][msg.sender] += addingAmount; 
        
        // Update pool staked balance
        pool.stakedBalance += addingAmount;
        
        // Update pool staking limit
        pool.stakingLimit -= addingAmount;
        
        // Update amount token user has staked by token address
        totalAmountStaked[pool.stakingToken] += addingAmount;
         
        // Transfer tax fee 
        _transferTaxFee();
         
        emit StakingEvent(data.balance, msg.sender, poolId, strs[1]); 
    }
    
    /**
     * @dev Unstake token of a pool  
     * @param strs: poolId(0), internalTxID(1)
     * @param amount: amount of token user want to unstake
    */
    function unstakeToken(string[] memory strs, uint256 amount) external poolExist(strs[0]) notBlocked payable {
        string memory poolId = strs[0];
        PoolInfo storage pool = poolInfo[poolId];
        StakingData storage data = tokenStakingData[poolId][msg.sender];
        
        // If monthly with unstake period pool
        if (pool.poolType == 3) {
            require(data.stakedTime + pool.configs[2] * ONE_DAY_IN_SECONDS <= block.timestamp, "Need to wait until staking period ended");
        }
        
        require(msg.value == taxFee, "Tax fee amount is invalid");
        require(amount > 0, "Unstake amount must be greater than 0");
        require(data.balance >= amount, "Not enough staking balance");
        
        updateDataPool(poolId, data, 1);
        
        // Update user stake balance
        totalStakedBalancePerUser[msg.sender] -= amount;
        
        // Update user stake balance by token address 
        totalStakedBalanceByToken[pool.stakingToken][msg.sender] -= amount;
        if (totalStakedBalancePerUser[msg.sender] == 0) {
            totalUserStaked -= 1;
        }
        
        // Update user stake balance by pool
        stakedBalancePerUser[poolId][msg.sender] -= amount;
        if (stakedBalancePerUser[poolId][msg.sender] == 0) {
            pool.totalUserStaked -= 1;
        }
        
        // Update staked balance
        data.balance -= amount;
        
        // Update pool staked balance
        pool.stakedBalance -= amount; 

        // Update Staking Limit
        pool.stakingLimit += amount;
        
        // Update total staked balance by token address 
        totalAmountStaked[pool.stakingToken] -= amount;
        
        uint256 reward = 0;
        
        // If user unstake all token and has reward
         if ((canGetReward(poolId) && data.reward > 0 && data.balance == 0) 
            || (data.reward > 0 && pool.rewardRatio > 0 && data.balance == 0)) {
            reward = data.reward; 
            
            // If fixed time pool can only get partial amount ratio which was set by admin
            if (pool.poolType == 1 && data.stakedTime + pool.configs[2] * ONE_DAY_IN_SECONDS > block.timestamp) { 
                reward = reward * pool.rewardRatio / 100;
            }
            
            // Update pool total reward claimed and reward fund
            pool.totalRewardClaimed += reward;
            pool.rewardFund -= reward;
            
            // Update total reward user has claimed by token address
            totalRewardClaimed[pool.rewardToken] += reward;
            
            // Update pool reward claimed by user
            rewardClaimedPerUser[poolId][msg.sender] += reward;
            
            // Update pool reward claimed by user and token address
            totalRewardClaimedPerUser[pool.rewardToken][msg.sender] += reward;
            
            // Reset reward
            data.reward = 0;
            
            // Transfer reward
            IERC20(pool.rewardToken).safeTransfer(msg.sender, reward);
        }  
        
        // Transfer staking token back to user
        IERC20(pool.stakingToken).safeTransfer(msg.sender, amount);
        
        // Transfer tax fee
        _transferTaxFee();
        
        emit StakingEvent(reward, msg.sender, poolId, strs[1]);
    } 

    /**
     * @dev Unstake NFT721 of a pool  
     * @param strs: poolId(0), internalTxID(1)
     * @param tokenId: token ID
    */
    function unstakeNFT721(string[] memory strs, uint256 tokenId) external poolExist(strs[0]) notBlocked payable {
        string memory poolId = strs[0];
        uint256 amount = 1e18;
        PoolInfo storage pool = poolInfo[poolId];
        StakingData storage data = tokenStakingData[poolId][msg.sender];
        
        require(pool.configs[5] == 2,"This pool cant unstake NFT721");
        // If monthly with unstake period pool
        if (pool.poolType == 3) {
            require(data.stakedTime + pool.configs[2] * ONE_DAY_IN_SECONDS <= block.timestamp, "Need to wait until staking period ended");
        }
    
        require(msg.value == taxFee, "Tax fee amount is invalid");
        require(stakeNFT721ByUser[poolId][tokenId] == msg.sender,"You didn't stake this token to this pool");
        
        updateDataPool(poolId, data, 1);
        
        // Update user stake balance
        totalStakedNFT721BalancePerUser[msg.sender] -= amount;
        
        // Update user stake balance by token address 
        totalStakedNFT721BalanceByNFT[pool.stakingToken][msg.sender] -= amount;
        if (totalStakedNFT721BalancePerUser[msg.sender] == 0) {
            totalUserStakeNFT721 -= 1;
        }
        
        // Update user stake balance by pool
        stakedBalancePerUser[poolId][msg.sender] -= amount;
        if (stakedBalancePerUser[poolId][msg.sender] == 0) {
            pool.totalUserStaked -= 1;
        }
        
        // Update staked balance
        data.balance -= amount;
        
        // Update pool staked balance
        pool.stakedBalance -= amount; 

        // Update Staking Limit
        pool.stakingLimit += amount;
        
        // Update total staked balance by token address 
        totalAmountNFT721Staked[pool.stakingToken] -= amount;
        
        nftStake[pool.stakingToken][tokenId] = false;

        uint256 reward = 0;
        
        // If user unstake all token and has reward
         if ((canGetReward(poolId) && data.reward > 0 && data.balance == 0) 
            || (data.reward > 0 && pool.rewardRatio > 0 && data.balance == 0)) {
            reward = data.reward; 
            
            // If fixed time pool can only get partial amount ratio which was set by admin
            if (pool.poolType == 1 && data.stakedTime + pool.configs[2] * ONE_DAY_IN_SECONDS > block.timestamp) { 
                reward = reward * pool.rewardRatio / 100;
            }
            
            // Update pool total reward claimed and reward fund
            pool.totalRewardClaimed += reward;
            pool.rewardFund -= reward;
            
            // Update total reward user has claimed by token address
            totalRewardClaimed[pool.rewardToken] += reward;
            
            // Update pool reward claimed by user
            rewardClaimedPerUser[poolId][msg.sender] += reward;
            
            // Update pool reward claimed by user and token address
            totalRewardClaimedPerUser[pool.rewardToken][msg.sender] += reward;
            
            // Reset reward
            data.reward = 0;
            
            // Transfer reward
            IERC20(pool.rewardToken).safeTransfer(msg.sender, reward);
        }  
        
        // Transfer staking token back to user
        ERC721(pool.stakingToken).safeTransferFrom(address(this), msg.sender, tokenId);
        // Transfer tax fee
        _transferTaxFee();
        
        emit StakeNFT(pool.stakingToken,address(this), msg.sender, tokenId, 1, poolId);
    }

    /**
     * @dev Claim reward when user has staked to the pool for a period of time 
     * @param strs: poolId(0), internalTxID(1)
    */
    function claimReward(string[] memory strs) external poolExist(strs[0]) notBlocked payable { 
        string memory poolId = strs[0];
        PoolInfo storage pool = poolInfo[poolId];
        StakingData storage data = tokenStakingData[poolId][msg.sender]; 
        
        require(msg.value == taxFee, "Tax fee amount is invalid");
        
        updateDataPool(poolId, data, 1);
        
        uint256 availableAmount = data.reward;
        
        // Fixed time get partial reward
        if (pool.poolType == 1 && data.stakedTime + pool.configs[2] * ONE_DAY_IN_SECONDS > block.timestamp) { 
            availableAmount = availableAmount * pool.rewardRatio / 100;
        }
        
        require(availableAmount > 0, "Reward is 0");
        require(IERC20(pool.rewardToken).balanceOf(address(this)) >= availableAmount, "Pool balance is not enough");
        require(canGetReward(poolId), "Not enough staking time"); 

        // Reset reward
        data.reward = 0;
        
        // Update pool claimed amount
        pool.totalRewardClaimed += availableAmount;
        
        // Update pool reward fund
        pool.rewardFund -= availableAmount; 
        
        // Update reward claimed by token address
        totalRewardClaimed[pool.rewardToken] += availableAmount;
        
        // Update pool reward claimed by user
        rewardClaimedPerUser[poolId][msg.sender] += availableAmount;
        
        // Update pool reward claimed by user and token address
        totalRewardClaimedPerUser[pool.rewardToken][msg.sender] += availableAmount;
        
        // Transfer reward
        IERC20(pool.rewardToken).safeTransfer(msg.sender, availableAmount);

        // Transfer tax fee
        _transferTaxFee();
    
        emit StakingEvent(availableAmount, msg.sender, poolId, strs[1]); 
    }

    /**
     * @dev Check if enough time to claim reward
     * @param poolId: the pool id user has staked
    */
    function canGetReward(string memory poolId) public view returns (bool) {
        PoolInfo memory pool = poolInfo[poolId];
        StakingData memory data = tokenStakingData[poolId][msg.sender];
        
        // Flexible & fixed time pool
        if (pool.poolType == 0) return true;
        
        // Pool with staking period
        return data.stakedTime + pool.configs[2] * ONE_DAY_IN_SECONDS <= block.timestamp;
    }

    /**
     * @dev Return amount of reward user can claim
     * @param poolId: the pool id user has staked
     * @param account: wallet address of user
    */
    function earned(string memory poolId, address account) 
        public
        view
        returns (uint256)
    {
        StakingData memory data = tokenStakingData[poolId][account]; 
        if (data.balance == 0) return 0;
        
        PoolInfo memory pool = poolInfo[poolId];
        uint256 amount = 0;
        
        // Flexible pool
        if (pool.poolType == 0) {
            amount = data.balance * (rewardPerToken(poolId) - data.rewardPerTokenPaid) / 1e20 + data.reward;
        } else { 
            // Get current timestamp, if currentTimestamp > poolEndDate then poolEndDate will be currentTimestamp
            uint256 currentTimestamp = block.timestamp < pool.configs[1] ? block.timestamp : pool.configs[1];
            
            if(pool.configs[5] == 1) {
                amount = (currentTimestamp - data.lastUpdateTime) * data.balance * pool.apr * pool.configs[4] / ONE_YEAR_IN_SECONDS / 1e4 + data.reward;
            } else {
                amount = (currentTimestamp - data.lastUpdateTime) * data.balance * pool.configs[4] / ONE_YEAR_IN_SECONDS + data.reward;
            }
        }
         
        return pool.rewardFund > amount ? amount : pool.rewardFund;
    }

    /**
     * @dev Return MaxTVL
     * @param poolDuration: endDate - startDate
     * @param totalReward: pool.initialFund
    */
    function getMaxTVL(uint256 poolDuration, uint256 totalReward) internal pure returns(uint256){
        return (totalReward* 1e20)/poolDuration;
    }

    function updateDataPool(string memory poolId, StakingData storage data, uint256 typeFunction) internal {
        PoolInfo storage pool = poolInfo[poolId];
        // Flexible pool update 
        if (pool.poolType == 0) {
            pool.flexData[1] = rewardPerToken(poolId);
            pool.flexData[0] = block.timestamp;
        }   

        // Update reward
        data.reward = earned(poolId, msg.sender);
        
        // Flexible pool update
        if (pool.poolType == 0) {
            data.rewardPerTokenPaid = pool.flexData[1];
        } else {
            if (typeFunction == 0) {
                data.lastUpdateTime = block.timestamp;
                data.stakedTime = block.timestamp;
            }else if (typeFunction == 1) {
                data.lastUpdateTime = block.timestamp < pool.configs[1] ? block.timestamp : pool.configs[1];
            }
        }
    }


    /*================================ ADMINISTRATOR FUNCTIONS ================================*/
    
    /**
     * @dev Create pool
     * @param strs: poolId(0), internalTxID(1)
     * @param addr: stakingToken(0), rewardToken(1)
     * @param data: rewardFund(0), apr(1), rewardRatio(2), stakingLimit(3), poolType(4), poolNFT(5)
     * @param configs: startDate(0), endDate(1), duration(2), endStakedTime(3)
    */
    function createPool(string[] memory strs, address[] memory addr, uint256[] memory data, uint256[] memory configs) external onlyAdmins {
        require(poolInfo[strs[0]].initialFund == 0, "Pool already exists");
        require(data[0] > 0, "Reward fund must be greater than 0");
        require(configs[0] < configs[1], "End date must be greater than start date");
        require(configs[0] < configs[3], "End staking date must be greater than start date");
        
        uint256[] memory flexData = new uint256[](2);
        PoolInfo memory pool;
        if(data[4]!=0){
            pool = PoolInfo(addr[0], addr[1], 0, 0, data[0], data[0], data[1], 0, data[2], data[3], 1, data[4], flexData, configs);
        } else {
            uint256 poolDuration = configs[1] - configs[0];
            uint256 MaxTVL = getMaxTVL(poolDuration,data[0]);
            pool = PoolInfo(addr[0], addr[1], 0, 0, data[0], data[0], data[1], 0, data[2], MaxTVL, 1, data[4], flexData, configs);
        }
        
        if (isAdmin(msg.sender)) {
            IERC20(pool.rewardToken).safeTransferFrom(msg.sender, address(this), data[0]);
        }
        poolInfo[strs[0]] = pool;
        totalPoolCreated += 1;
        totalRewardFund[pool.rewardToken] += data[0];
        
        emit PoolUpdated(data[0], msg.sender, strs[0], strs[1]); 
        
        emit PoolUpdated(data[0], msg.sender, strs[0], strs[1]); 
    }

    // /**
    //  * @dev Return configs of a pool
    //  * @param poolId: Pool id
    // */
    // function showConfigs(string memory poolId) external view returns(uint256[] memory) {
    //     PoolInfo memory pool = poolInfo[poolId];
    //     return pool.configs;
    // }

    /**
     * @dev Return annual percentage rate of a pool
     * @param poolId: Pool id
    */
    function apr(string memory poolId) public view returns (uint256) {
        PoolInfo memory pool = poolInfo[poolId];
        
        // If not flexible pool
        if (pool.poolType != 0) return pool.apr; 
        
        // Flexible pool
        uint256 poolDuration = pool.configs[1] - pool.configs[0];
        if (pool.stakedBalance == 0 || poolDuration == 0) return 0;
        
        return (ONE_YEAR_IN_SECONDS * pool.rewardFund / poolDuration) * 100 / pool.stakedBalance; 
    }
    
    /**
     * @dev Return amount of reward token distibuted per second
     * @param poolId: Pool id
    */
    function rewardPerToken(string memory poolId) public view returns (uint256) {
        PoolInfo memory pool = poolInfo[poolId];
        
        require(pool.poolType == 0, "Only flexible pool");
        
        // poolDuration = poolEndDate - poolStartDate
        uint256 poolDuration = pool.configs[1] - pool.configs[0]; 
        
        // Get current timestamp, if currentTimestamp > poolEndDate then poolEndDate will be currentTimestamp
        uint256 currentTimestamp = block.timestamp < pool.configs[1] ? block.timestamp : pool.configs[1];
        
        // If stakeBalance = 0 or poolDuration = 0
        if (pool.stakedBalance == 0 || poolDuration == 0) return 0;
        
        // If the pool has ended then stop calculate reward per token
        if (currentTimestamp <= pool.flexData[0]) return pool.flexData[1];
        
        // result = result * 1e8 for zero prevention
        uint256 rewardPool = pool.rewardFund * (currentTimestamp - pool.flexData[0]) * 1e20;
        
        // newRewardPerToken = rewardPerToken(newPeriod) + lastRewardPertoken          
        return rewardPool / (poolDuration * pool.stakedBalance) + pool.flexData[1];
    }

    function checkERC(address contractAddress) public view returns(bool) {
        return ERC721(contractAddress).supportsInterface(0x80ac58cd);
    }
    
    /** 
     * @dev Emercency withdraw token for users
     * @param _poolId: the pool id user has staked
     * @param _account: wallet address of user
    */
    function emercencyWithdrawToken(string memory _poolId, address _account) external onlyController {
        PoolInfo memory pool = poolInfo[_poolId];
        StakingData memory data = tokenStakingData[_poolId][_account];
        require(data.balance > 0, "Staked balance is 0");
        
        // Transfer staking token back to user
        IERC20(pool.stakingToken).safeTransfer(_account, data.balance);
        
        uint256 amount = data.balance;

        // Flexible pool update
        if (pool.poolType == 0) {
            pool.flexData[1] = rewardPerToken(_poolId);
            pool.flexData[0] = block.timestamp;
        }
        
        // Update user stake balance
        totalStakedBalancePerUser[msg.sender] -= amount;
        
        // Update user stake balance by token address 
        totalStakedBalanceByToken[pool.stakingToken][msg.sender] -= amount;
        if (totalStakedBalancePerUser[msg.sender] == 0) {
            totalUserStaked -= 1;
        }
        
        // Update user stake balance by pool
        stakedBalancePerUser[_poolId][msg.sender] -= amount;
        if (stakedBalancePerUser[_poolId][msg.sender] == 0) {
            pool.totalUserStaked -= 1;
        }
        
        // Update pool staked balance
        pool.stakedBalance -= amount; 
        
        // Update total staked balance by token address 
        totalAmountStaked[pool.stakingToken] -= amount;

        // Delete data
        delete tokenStakingData[_poolId][_account];
    }
    
    /**
     * @dev Withdraw fund admin has sent to the pool
     * @param _tokenAddress: the token contract owner want to withdraw fund
     * @param _account: the account which is used to receive fund
     * @param _amount: the amount contract owner want to withdraw
    */
    function withdrawFund(address _tokenAddress, address _account, uint256 _amount) external onlyController {
        require(IERC20(_tokenAddress).balanceOf(address(this)) >= _amount, "Pool not has enough balance");
        
        // Transfer fund back to account
        IERC20(_tokenAddress).safeTransfer(_account, _amount);
    }
    
    /**
     * @dev Set tax fee paid by native token when users stake, unstake, restake and claim
     * @param _taxFee: amount users have to pay when call any of these functions 
    */
    function setTaxFee(uint256 _taxFee) external onlyController {
        taxFee = _taxFee;

        emit TaxFeeSet(msg.sender, _taxFee);
    }
    
    /**
     * @dev Set recipient address which is used to receive tax fee
    */
    function setFeeRecipientAddress(address _feeRecipientAddress) external onlyController {
        feeRecipientAddress = _feeRecipientAddress;

        emit FeeRecipientSet(msg.sender, _feeRecipientAddress);
    }
    
    /**
     * @dev Transfer tax fee 
    */
    function _transferTaxFee() internal {
        // If recipientAddress and taxFee are set
        if (feeRecipientAddress != address(0) && taxFee > 0) {
            payable(feeRecipientAddress).transfer(taxFee);
        }
    }
    
     /**
     * @dev Contract owner set admin for execute administrator functions
     * @param _address: wallet address of admin
     * @param _value: true/false
    */
    function setAdminNew(address _address, bool _value) external onlySuperAdmin { 
        adminList[_address] = _value;

        emit AdminSet(_address, _value, "Admin");
    } 

    /**
     * @dev Check if a wallet address is admin or not
     * @param _address: wallet address of the user
    */
    function isAdmin(address _address) public view returns (bool) {
        return adminList[_address];
    }

    /**
     * @dev Update admin
     * @param oldAddress: old address
     * @param newAddress: new address
    */
    function editAdmin(address oldAddress, address newAddress) external onlySuperAdmin {
        adminList[oldAddress] = false;

        adminList[newAddress] = true;

        emit AdminSet(oldAddress, false, "Admin");
        emit AdminSet(oldAddress, true, "Admin");
    }

    /**
     * @dev Contract owner set admin for execute administrator functions
     * @param _address: wallet address of admin
     * @param _value: true/false
    */
    function setSuperAdmin(address _address, bool _value) external onlyController { 
        superAdminList[_address] = _value;
        emit AdminSet(_address, _value, "SuperAdmin");
    } 

    /**
     * @dev Check if a wallet address is super admin or not
     * @param _address: wallet address of the user
    */
    function isSuperAdmin(address _address) external view returns (bool) {
        return superAdminList[_address];
    }

    /**
     * @dev Update superAdmin
     * @param oldAddress: old address
     * @param newAddress: new address
    */
    function editSuperAdmin(address oldAddress, address newAddress) external onlyController {
        superAdminList[oldAddress] = false;

        superAdminList[newAddress] = true;

        emit AdminSet(oldAddress, false, "SuperAdmin");
        emit AdminSet(oldAddress, true, "SuperAdmin");
    }

    /**
     * @dev Block users
     * @param _address: wallet address of user
     * @param _value: true/false
    */
    function setBlacklist(address _address, bool _value) external onlyAdmins {
        blackList[_address] = _value;

        emit BlacklistSet(_address, _value);
    }
    
    /**
     * @dev Check if a user has been blocked
     * @param _address: user wallet 
    */
    function isBlackList(address _address) external view returns (bool) {
        return blackList[_address];
    }
    
    /**
     * @dev Set pool active/deactive
     * @param _poolId: the pool id
     * @param _value: true/false
    */
    function setPoolActive(string memory _poolId, uint256 _value) external onlyAdmins {
        poolInfo[_poolId].active = _value;
        
        emit PoolActivationSet(msg.sender, _poolId, _value);
    }

    /**
     * @dev Transfers controller of the contract to a new account (`newController`).
     * Can only be called by the current controller.
    */
    function transferController(address _newController) external {
        // Check if controller has been initialized in proxy contract
        // Caution: If set controller != proxyOwnerAddress then all functions require controller permission cannot be called from proxy contract
        if (controller != address(0)) {
            require(msg.sender == controller, "Only controller");
        }
        require(_newController != address(0), "New controller is the zero address");
        _transferController(_newController);
    }

    /**
     * @dev Transfers controller of the contract to a new account (`newController`).
     * Internal function without access restriction.
    */
    function _transferController(address _newController) internal {
        address oldController = controller;
        controller = _newController;
        emit ControllerTransferred(oldController, controller);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }
}