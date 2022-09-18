/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

pragma solidity ^ 0.8.7;
// SPDX-License-Identifier: Unlicensed

/**
 * @dev BEP20 Token interface
 */
interface IBEP20 {
function totalSupply() external view returns(uint256);
function decimals() external view returns(uint8);
function symbol() external view returns(string memory);
function name() external view returns(string memory);
function getOwner() external view returns(address);
function balanceOf(address account) external view returns(uint256);
function transfer(address recipient, uint256 amount) external returns(bool);
function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
function approve(address spender, uint256 amount) external returns(bool);
function allowance(address _owner, address spender) external view returns(uint256);
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
}

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^ 0.8.0;

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
    function supportsInterface(bytes4 interfaceId) external view returns(bool);
}

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^ 0.8.0;

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
) external returns(bytes4);
}

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^ 0.8.0;


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
    function balanceOf(address owner) external view returns(uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns(address owner);

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
    function getApproved(uint256 tokenId) external view returns(address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns(bool);
}

// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^ 0.8.0;
/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns(string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns(string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns(string memory);
}

pragma solidity ^ 0.8.0;

// import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor() {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(type(IERC165).interfaceId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns(bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^ 0.8.0;

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
    function _msgSender() internal view virtual returns(address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns(bytes calldata) {
        return msg.data;
    }
}

// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^ 0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns(string memory) {
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
    function toHexString(uint256 value) internal pure returns(string memory) {
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
    function toHexString(uint256 value, uint256 length) internal pure returns(string memory) {
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
    function toHexString(address addr) internal pure returns(string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

pragma solidity ^ 0.8.0;


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
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns(bool) {
        return
        interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns(uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns(address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns(string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns(string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns(string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns(string memory) {
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
    function getApproved(uint256 tokenId) public view virtual override returns(address) {
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
    function isApprovedForAll(address owner, address operator) public view virtual override returns(bool) {
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
    function _exists(uint256 tokenId) internal view virtual returns(bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns(bool) {
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
    ) private returns(bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns(bytes4 retval) {
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
    ) internal virtual { }

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
    ) internal virtual { }
}



/**
 * @dev Collection of functions related to the address type
 * 
 * from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol
 */
library Address {
    function isContract(address account) internal view returns(bool) { 
        uint256 size; 

        assembly { size:= extcodesize(account) }

        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount } ("");

        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns(bytes memory) { return functionCall(target, data, "Address: low-level call failed"); }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns(bytes memory) { return functionCallWithValue(target, data, 0, errorMessage); }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns(bytes memory) { return functionCallWithValue(target, data, value, "Address: low-level call with value failed"); }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns(bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value } (data);

        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns(bytes memory) { return functionStaticCall(target, data, "Address: low-level static call failed"); }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns(bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);

        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns(bytes memory) { return functionDelegateCall(target, data, "Address: low-level delegate call failed"); }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns(bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);

        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) { 
                assembly {
                    let returndata_size:= mload(returndata) revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 * 
 * from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol
 */
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns(bool, uint256) { 
        unchecked { 
            uint256 c = a + b;

            if (c < a) return (false, 0);

            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns(bool, uint256) { 
        unchecked {
            if (b > a) return (false, 0);

            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns(bool, uint256) { 
        unchecked {
            if (a == 0) return (true, 0); 

            uint256 c = a * b;

            if (c / a != b) return (false, 0);

            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns(bool, uint256) { 
        unchecked {
            if (b == 0) return (false, 0);

            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns(bool, uint256) { 
        unchecked {
            if (b == 0) return (false, 0);

            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) { return a + b; }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) { return a - b; }

    function mul(uint256 a, uint256 b) internal pure returns(uint256) { return a * b; }

    function div(uint256 a, uint256 b) internal pure returns(uint256) { return a / b; }

    function mod(uint256 a, uint256 b) internal pure returns(uint256) { return a % b; }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) { 
        unchecked {
            require(b <= a, errorMessage);

            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) { 
        unchecked {
            require(b > 0, errorMessage);

            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) { 
        unchecked {
            require(b > 0, errorMessage);

            return a % b;
        }
    }
}



/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol
 */
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() { _status = _NOT_ENTERED; }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 */
contract Ownable is Context {
    address private _owner;

    constructor() {
        _owner = _msgSender();

        emit OwnershipTransferred(address(0), _owner);
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns(address) { return _owner; }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;
    }

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}


// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^ 0.8.0;

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
    ) public virtual override returns(bytes4) {
        return this.onERC721Received.selector;
    }
}
contract saleteste is IBEP20, ReentrancyGuard, ERC721Holder, Context, Ownable {
	using Address for address;
    using SafeMath for uint256;

    IERC721 public nft;
 
    uint256 public emitStake = (10 * 10 ** _decimals) / 25 days; 
    uint256 public emitStake2 = (15 * 10 ** _decimals) / 35 days; 
    uint256 public emitStake3 = (25 * 10 ** _decimals) / 50 days; 
    uint256 public emitStake4 = (70 * 10 ** _decimals) / 30 days;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // NFT staking
    mapping(uint256 => address) public nftOwner; 
    mapping(uint256 => address) public nftOwner2;
    mapping(uint256 => address) public nftOwner3;
    mapping(uint256 => address) public nftOwner4;

    mapping(address => uint256) public tokenCheck1; 
    mapping(address => uint256) public tokenCheck2;
    mapping(address => uint256) public tokenCheck3;
    mapping(address => uint256) public tokenCheck4;

    mapping(address => bool) public claimedStake1; 
    mapping(address => bool) public claimedStake2;
    mapping(address => bool) public claimedStake3;
    mapping(address => bool) public claimedStake4;

    mapping(uint256 => uint256) public stakePool;
    mapping(uint256 => uint256) public stakePool2;
    mapping(uint256 => uint256) public stakePool3;
    mapping(uint256 => uint256) public stakePool4;

    mapping(address => uint256) public _tier;
   
    mapping(address => uint) public lockTime; // lock Pool 1 NFT stake rewards
    mapping(address => uint) public lockTime2; // lock Pool 2 NFT stake rewards
    mapping(address => uint) public lockTime3; // lock Pool 3 NFT stake rewards
    mapping(address => uint) public lockTime4; // lock Pool 4 NFT stake rewards

    mapping(address => uint) public lockTimeTks; // lock staked tokens and rewards

    // token staking
    IBEP20 public immutable stkToken;
    IBEP20 public immutable rewTks;

    mapping(address => bool) public claimed; // testnet tokens
   
   
    uint public duration;
    uint public finishAt;
    uint public updatedAt;
    uint public rewardRate;
    uint public rewardPerTokenStored;
    
    mapping(address => uint) public userRewardPerTokenPaid;
    mapping(address => uint) public rewards;

    uint public totalStaked;
    mapping(address => uint) public balanceOfstk;

    string private constant _name = "Name";
    string private constant _symbol = "SLG";
	uint8 private constant _decimals = 9;
	uint256 private constant _totalSupply = 10 * 10 ** 6 * 10 ** _decimals; // 10M

    constructor(address _nft) {
        // set totalSupply variable
        _balances[_msgSender()] = _totalSupply;
        nft = IERC721(_nft);

        stkToken = IBEP20(address(this));
        rewTks = IBEP20(address(this));

		emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    // to receive BNBs
    receive() external payable {
        revert();
    }


     modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        updatedAt = lastTimeRewardApplicable();

        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }

        _;
    }


    function getOwner() external view override returns(address) { return owner(); }

    function name() external pure override returns(string memory) { return _name; }

    function symbol() external pure override returns(string memory) { return _symbol; }

    function decimals() external pure override returns(uint8) { return _decimals; }

    function totalSupply() external pure override returns(uint256) { return _totalSupply; }

    function balanceOf(address account) public view override returns(uint256) { return _balances[account]; }

    function transfer(address recipient, uint256 amount) external override returns(bool) {
        _transfer(_msgSender(), recipient, amount);

        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns(bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));

        return true;
    }

    function approve(address spender, uint256 amount) external override returns(bool) {
        _approve(_msgSender(), spender, amount);

        return true;
    }


    function allowance(address owner, address spender) external view override returns(uint256) { return _allowances[owner][spender]; }

    function increaseAllowance(address spender, uint256 addedValue) external returns(bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));

        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns(bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));

        return true;
    }

    function stake(uint256 tokenId, uint256 pool) external {
        require(balanceOf(address(this)) >= 10000, "Insufficient tokens on contract for stake");

        if (pool == 1) {
            require(claimedStake1[msg.sender] != true, "Pool already in use");
            nft.safeTransferFrom(msg.sender, address(this), tokenId);
            nftOwner[tokenId] = msg.sender;
            tokenCheck1[msg.sender] = tokenId;
            stakePool[tokenId] = block.timestamp;
            claimedStake1[msg.sender] = true;
            _tier[msg.sender] += 1;

             //updates locktime 25 days from now
             lockTime[msg.sender] = block.timestamp + 25 days;
            

        } else if (pool == 2) {
            require(claimedStake2[msg.sender] != true, "Pool already in use");
            require(_tier[msg.sender] >= 1, "Need participating on 1 tier");
            nft.safeTransferFrom(msg.sender, address(this), tokenId);
            nftOwner2[tokenId] = msg.sender;
            tokenCheck2[msg.sender] = tokenId;
            stakePool2[tokenId] = block.timestamp;
            claimedStake2[msg.sender] = true;
            _tier[msg.sender] += 1;
            lockTime2[msg.sender] = block.timestamp + 35 days;

        } else if (pool == 3) {
            require(claimedStake3[msg.sender] != true, "Pool already in use");
            require(_tier[msg.sender] >= 2, "Need participating on 2 tiers");
            nft.safeTransferFrom(msg.sender, address(this), tokenId);
            tokenCheck3[msg.sender] = tokenId;
            nftOwner3[tokenId] = msg.sender;
            stakePool3[tokenId] = block.timestamp;
            claimedStake3[msg.sender] = true;
            _tier[msg.sender] += 1;
            lockTime3[msg.sender] = block.timestamp + 50 days;

        } else if (pool == 4) {
            require(claimedStake4[msg.sender] != true, "Pool already in use");
            require(_tier[msg.sender] >= 3, "Need participating on 3 tiers");
            nft.safeTransferFrom(msg.sender, address(this), tokenId);
            tokenCheck4[msg.sender] = tokenId;
            nftOwner4[tokenId] = msg.sender;
            stakePool4[tokenId] = block.timestamp;
            claimedStake4[msg.sender] = true;
            _tier[msg.sender] += 1;
            lockTime4[msg.sender] = block.timestamp + 30 days;
        } else {
            uint256 ful;
            ful++;
        }

    }



    function calculateRewards(uint256 tokenId) public view returns(uint256) {
        uint256 timeElapsed = block.timestamp - stakePool[tokenId];
        return timeElapsed * emitStake;
    }

    function calculateRewards2(uint256 tokenId) public view returns(uint256) {
        uint256 timeElapsed2 = block.timestamp - stakePool2[tokenId];
        return timeElapsed2 * emitStake2;
    }
    function calculateRewards3(uint256 tokenId) public view returns(uint256) {
        uint256 timeElapsed3 = block.timestamp - stakePool3[tokenId];
        return timeElapsed3 * emitStake3;
    }
    function calculateRewards4(uint256 tokenId) public view returns(uint256) {
        uint256 timeElapsed4 = block.timestamp - stakePool4[tokenId];
        return timeElapsed4 * emitStake4;
    }
    function unstake(uint256 tokenId, uint256 pool) external {

        if (pool == 1) {
            require(nftOwner[tokenId] == msg.sender, "You can't unstake");
            require(claimedStake1[msg.sender] != false, "Pool not in use");
            // check that the now time is > the time saved in the lock time mapping
             require(block.timestamp > lockTime[msg.sender], "lock time has not expired");

            _transfer(address(this), msg.sender, calculateRewards(tokenId));

            nft.transferFrom(address(this), msg.sender, tokenId);
            delete nftOwner[tokenId];
            delete tokenCheck1[msg.sender];
            delete stakePool[tokenId];
            claimedStake1[msg.sender] = false;
            _tier[msg.sender] -= 1;

        } else if (pool == 2) {
            require(nftOwner2[tokenId] == msg.sender, "You can't unstake");
            require(claimedStake2[msg.sender] != false, "Pool not in use");
            require(block.timestamp > lockTime2[msg.sender], "lock time has not expired");

            _transfer(address(this), msg.sender, calculateRewards2(tokenId));

            nft.transferFrom(address(this), msg.sender, tokenId);

            delete nftOwner2[tokenId];
            delete tokenCheck2[msg.sender];
            delete stakePool2[tokenId];
            claimedStake2[msg.sender] = false;
            _tier[msg.sender] -= 1;

        } else if (pool == 3) {
            require(nftOwner3[tokenId] == msg.sender, "You can't unstake");
            require(claimedStake3[msg.sender] != false, "Pool not in use");
            require(block.timestamp > lockTime3[msg.sender], "lock time has not expired");

            _transfer(address(this), msg.sender, calculateRewards3(tokenId));

            nft.transferFrom(address(this), msg.sender, tokenId);

            delete nftOwner3[tokenId];
            delete tokenCheck3[msg.sender];
            delete stakePool3[tokenId];
            claimedStake3[msg.sender] = false;
            _tier[msg.sender] -= 1;



        } else if (pool == 4) {
            require(nftOwner4[tokenId] == msg.sender, "You can't unstake");
            require(claimedStake4[msg.sender] != false, "Pool not in use");
            require(block.timestamp > lockTime4[msg.sender], "lock time has not expired");

            _transfer(address(this), msg.sender, calculateRewards4(tokenId));

            nft.transferFrom(address(this), msg.sender, tokenId);

            delete nftOwner4[tokenId];
            delete tokenCheck4[msg.sender];
            delete stakePool4[tokenId];
            claimedStake4[msg.sender] = false;
            _tier[msg.sender] -= 1;


        } else {
            uint256 ful;
            ful++;
        }

    }
    // set NFT rewards
    function nftRewards(uint256 tokenAmount) external onlyOwner { 
        require(tokenAmount > 0 && tokenAmount <= balanceOf(owner()).div(10 ** _decimals), "Token amount must be greater than zero and less than or equal to balance of owner.");
        _transfer(owner(), address(this), tokenAmount.mul(10 ** _decimals));

    }


    function _transfer(address from, address to, uint256 amount) private nonReentrant {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

    

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);

        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
 
        emit Approval(owner, spender, amount);
    }
     /* --------- TOKEN STAKE --------- */

    function lastTimeRewardApplicable() public view returns (uint) {
        return _min(finishAt, block.timestamp);
    }

    function rewardPerToken() public view returns (uint) {
        if (totalStaked == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored +
            (rewardRate * (lastTimeRewardApplicable() - updatedAt) * _decimals) /
            totalStaked;
    }

    function stakeTks(uint _amount) external updateReward(msg.sender) {
        require(_amount > 0, "Insufficient amount");

        //updates locktime 30 days from now
        lockTimeTks[msg.sender] = block.timestamp + 30 days;

        _transfer(msg.sender, address(this), _amount);
        balanceOfstk[msg.sender] += _amount;
        totalStaked += _amount;

        
    }

    function withdraw(uint _amount) external updateReward(msg.sender) {
        require(_amount > 0, "Insufficient amount");
        require(block.timestamp > lockTimeTks[msg.sender], "lock time has not expired");

        balanceOfstk[msg.sender] -= _amount;
        totalStaked -= _amount;
        _transfer(address(this), msg.sender, _amount);
    }

    function earned(address _account) public view returns (uint) {
        return
            ((balanceOfstk[_account] *
                (rewardPerToken() - userRewardPerTokenPaid[_account])) / _decimals) +
            rewards[_account];
    }

    function getReward() external updateReward(msg.sender) {
        uint reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            
             _transfer(address(this), msg.sender, reward);
            
        }
    }

    function setRewardsDuration(uint _duration) external onlyOwner {
        require(finishAt < block.timestamp, "reward duration not finished");
        duration = _duration;
    }

    function notifyRewardAmount(uint _amount)
        external
        onlyOwner
        updateReward(address(0))
    {
        if (block.timestamp >= finishAt) {
            rewardRate = _amount / duration;
        } else {
            uint remainingRewards = (finishAt - block.timestamp) * rewardRate;
            rewardRate = (_amount + remainingRewards) / duration;
        }

        require(rewardRate > 0, "reward rate = 0");
        require(
            rewardRate * duration <= rewTks.balanceOf(address(this)),
            "reward amount > balance"
        );

        finishAt = block.timestamp + duration;
        updatedAt = block.timestamp;
    }

    function _min(uint x, uint y) private pure returns (uint) {
        return x <= y ? x : y;
    }

    function withdrawTokens(uint256 amountPercent) external onlyOwner {
        require(amountPercent >= 0 && amountPercent <= 100, "values between 0 and 100");

		uint256 tokenAmount = balanceOf(address(this));

		if (tokenAmount > 0) {
		    _transfer(address(this), owner(), tokenAmount.mul(amountPercent).div(10**2));
		}
    }

    function testnet() public {
        require(claimed[msg.sender] != true, "already claimed");
            if(claimed[msg.sender] != true){
             uint256 tokenAmount = 2000_000000000;
            _transfer(address(this), _msgSender(), tokenAmount);
            claimed[msg.sender] = true;
        }

      }
   
}