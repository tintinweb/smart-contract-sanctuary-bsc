// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

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
     * @dev See {ERC721-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);

        if (batchSize > 1) {
            // Will only trigger during construction. Batch transferring (minting) is not available afterwards.
            revert("ERC721Enumerable: consecutive transfers not supported");
        }

        uint256 tokenId = firstTokenId;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

interface IBiswapMintCallback {

    /// @notice Called to msg.sender in iBiswapPoolV3#mint call
    /// @param x Amount of tokenX need to pay from miner
    /// @param y Amount of tokenY need to pay from miner
    /// @param data Any data passed through by the msg.sender via the iBiswapPoolV3#mint call
    function mintDepositCallback(
        uint256 x,
        uint256 y,
        bytes calldata data
    ) external;

}

interface IBiswapCallback {

    /// @notice Called to msg.sender in iBiswapPoolV3#swapY2X(DesireX) call
    /// @param x Amount of tokenX trader will acquire
    /// @param y Amount of tokenY trader will pay
    /// @param data Any dadta passed though by the msg.sender via the iBiswapPoolV3#swapY2X(DesireX) call
    function swapY2XCallback(
        uint256 x,
        uint256 y,
        bytes calldata data
    ) external;

    /// @notice Called to msg.sender in iBiswapPoolV3#swapX2Y(DesireY) call
    /// @param x Amount of tokenX trader will pay
    /// @param y Amount of tokenY trader will require
    /// @param data Any dadta passed though by the msg.sender via the iBiswapPoolV3#swapX2Y(DesireY) call
    function swapX2YCallback(
        uint256 x,
        uint256 y,
        bytes calldata data
    ) external;

}

interface IBiswapAddLimOrderCallback {

    /// @notice Called to msg.sender in iBiswapPoolV3#addLimOrderWithX(Y) call
    /// @param x Amount of tokenX seller will pay
    /// @param y Amount of tokenY seller will pay
    /// @param data Any data passed though by the msg.sender via the iBiswapPoolV3#addLimOrderWithX(Y) call
    function payCallback(
        uint256 x,
        uint256 y,
        bytes calldata data
    ) external;

}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

interface IBiswapFactoryV3 {

    /// @notice emit when successfully create a new pool (calling iBiswapFactoryV3#newPool)
    /// @param tokenX address of erc-20 tokenX
    /// @param tokenY address of erc-20 tokenY
    /// @param fee fee amount of swap (3000 means 0.3%)
    /// @param pointDelta minimum number of distance between initialized or limitorder points
    /// @param pool address of swap pool
    event NewPool(
        address indexed tokenX,
        address indexed tokenY,
        uint16 indexed fee,
        uint24 pointDelta,
        address pool
    );

    /// @notice emit when owner change delta fee on pools
    /// @param oldDelta delta was before
    /// @param newDelta new delta
    event FeeDeltaChanged(uint16 oldDelta, uint16 newDelta);

    /// @notice emit when owner change discount setters address
    /// @param newDiscountSetter new discount setter address
    event NewDiscountSetter(address newDiscountSetter);

    struct Addresses {
        address swapX2YModule;
        address  swapY2XModule;
        address  liquidityModule;
        address  limitOrderModule;
        address  flashModule;
    }

    /// @notice Add struct to save gas
    /// @return swapX2YModule address of module to support swapX2Y(DesireY)
    /// @return swapY2XModule address of module to support swapY2X(DesireX)
    /// @return liquidityModule address of module to support liquidity
    /// @return limitOrderModule address of module for user to manage limit orders
    /// @return flashModule address of module to support flash loan
    function addresses() external returns(
        address swapX2YModule,
        address swapY2XModule,
        address liquidityModule,
        address limitOrderModule,
        address flashModule
    );


    /// @notice default fee rate from miner's fee gain
    /// @return defaultFeeChargePercent default fee rate * 100
    function defaultFeeChargePercent() external returns (uint24);

    /// @notice Enables a fee amount with the given pointDelta
    /// @dev Fee amounts may never be removed once enabled
    /// @param fee fee amount (3000 means 0.3%)
    /// @param pointDelta The spacing between points to be enforced for all pools created with the given fee amount
    function enableFeeAmount(uint16 fee, uint24 pointDelta) external;

    /// @notice Create a new pool which not exists.
    /// @param tokenX address of tokenX
    /// @param tokenY address of tokenY
    /// @param fee fee amount
    /// @param currentPoint initial point (log 1.0001 of price)
    /// @return address of newly created pool
    function newPool(
        address tokenX,
        address tokenY,
        uint16 fee,
        int24 currentPoint
    ) external returns (address);

    /// @notice Charge receiver of all pools.
    /// @return address of charge receiver
    function chargeReceiver() external view returns(address);

    /// @notice Get pool of (tokenX, tokenY, fee), address(0) for not exists.
    /// @param tokenX address of tokenX
    /// @param tokenY address of tokenY
    /// @param fee fee amount
    /// @return address of pool
    function pool(
        address tokenX,
        address tokenY,
        uint16 fee
    ) external view returns(address);

    /// @notice Get point delta of a given fee amount.
    /// @param fee fee amount
    /// @return pointDelta the point delta
    function fee2pointDelta(uint16 fee) external view returns (int24 pointDelta);

    /// @notice Get delta fee of a given fee amount.
    /// @param fee fee amount
    /// @return deltaFee fee delta [fee - %delta; fee + %delta] delta in percent base 10000
    function fee2DeltaFee(uint16 fee) external view returns (uint16 deltaFee);

    /// @notice Change charge receiver, only owner of factory can call.
    /// @param _chargeReceiver address of new receiver
    function modifyChargeReceiver(address _chargeReceiver) external;

    /// @notice Change defaultFeeChargePercent
    /// @param _defaultFeeChargePercent new charge percent
    function modifyDefaultFeeChargePercent(uint24 _defaultFeeChargePercent) external;

    /// @notice return range of fee change
    /// @param fee fee for get range
    /// @return lowFee low range border
    /// @return highFee high range border
    function getFeeRange(uint16 fee) external view returns(uint16 lowFee, uint16 highFee);

    /// @notice set fee delta to pools
    /// @param fee fee of pools on which the delta change
    /// @param delta new delta in base 10000
    function setFeeDelta(uint16 fee, uint16 delta) external;

    /// @notice change discount setters address
    /// @param newDiscountSetter new discount setter address
    function setDiscountSetterAddress(address newDiscountSetter) external;

    /// @notice get discount from user address and pool
    /// @param user user address
    /// @param _pool pool address
    /// @return discount value of the discount base 10000
    function feeDiscount(address user, address _pool) external returns(uint16 discount);

    function deployPoolParams() external view returns(
        address tokenX,
        address tokenY,
        uint16 fee,
        int24 currentPoint,
        int24 pointDelta,
        uint24 feeChargePercent
    );

    /// @notice check fee in range
    /// @param fee fee of pools on which the delta change
    /// @param initFee initialize fee when pool created
    function checkFeeInRange(uint16 fee, uint16 initFee) external view returns(bool);

}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

interface IBiswapPoolV3 {

    /// @notice Emitted when miner successfully add liquidity (mint).
    /// @param sender the address that minted the liquidity
    /// @param owner the owner who will benefit from this liquidity
    /// @param leftPoint left endpoint of the liquidity
    /// @param rightPoint right endpoint of the liquidity
    /// @param liquidity the amount of liquidity minted to the range [leftPoint, rightPoint)
    /// @param amountX amount of tokenX deposit
    /// @param amountY amount of tokenY deposit
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed leftPoint,
        int24 indexed rightPoint,
        uint128 liquidity,
        uint256 amountX,
        uint256 amountY
    );

    /// @notice Emitted when miner successfully decrease liquidity (withdraw).
    /// @param owner owner address of liquidity
    /// @param leftPoint left endpoint of liquidity
    /// @param rightPoint right endpoint of liquidity
    /// @param liquidity amount of liquidity decreased
    /// @param amountX amount of tokenX withdrawed
    /// @param amountY amount of tokenY withdrawed
    event Burn(
        address indexed owner,
        int24 indexed leftPoint,
        int24 indexed rightPoint,
        uint128 liquidity,
        uint256 amountX,
        uint256 amountY
    );

    /// @notice Emitted when fees and withdrawed liquidity are collected
    /// @param owner The owner of the Liquidity
    /// @param recipient recipient of those token
    /// @param leftPoint The left point of the liquidity
    /// @param rightPoint The right point of the liquidity
    /// @param amountX The amount of tokenX (fees and withdrawed tokenX from liquidity)
    /// @param amountY The amount of tokenY (fees and withdrawed tokenY from liquidity)
    event CollectLiquidity(
        address indexed owner,
        address recipient,
        int24 indexed leftPoint,
        int24 indexed rightPoint,
        uint256 amountX,
        uint256 amountY
    );

    /// @notice Emitted when change fee vote
    /// @param owner The owner of the Liquidity
    /// @param leftPoint The left point of the liquidity
    /// @param rightPoint The right point of the liquidity
    /// @param newFeeVote new vote for fee for existing liquidity
    event ChangeFeeVote(
        address indexed owner,
        int24 indexed leftPoint,
        int24 indexed rightPoint,
        uint16 newFeeVote
    );

    /// @notice Emitted when a trader successfully exchange.
    /// @param tokenX tokenX of pool
    /// @param tokenY tokenY of pool
    /// @param fee fee amount of pool
    /// @param sellXEarnY true for selling tokenX, false for buying tokenX
    /// @param amountX amount of tokenX in this exchange
    /// @param amountY amount of tokenY in this exchange
    event Swap(
        address indexed tokenX,
        address indexed tokenY,
        uint16 indexed fee,
        bool sellXEarnY,
        uint256 amountX,
        uint256 amountY
    );

    /// @notice Emitted by the pool for any flashes of tokenX/tokenY.
    /// @param sender the address that initiated the swap call, and that received the callback
    /// @param recipient the address that received the tokens from flash
    /// @param amountX the amount of tokenX that was flashed
    /// @param amountY the amount of tokenY that was flashed
    /// @param paidX the amount of tokenX paid for the flash, which can exceed the amountX plus the fee
    /// @param paidY the amount of tokenY paid for the flash, which can exceed the amountY plus the fee
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amountX,
        uint256 amountY,
        uint256 paidX,
        uint256 paidY
    );

    /// @notice Emitted when a seller successfully add a limit order.
    /// @param owner owner of limit order
    /// @param addAmount amount of token to sell the seller added
    /// @param acquireAmount amount of earn-token acquired, if there exists some opposite order before
    /// @param point point of limit order
    /// @param claimSold claimed sold sell-token, if this owner has order with same direction on this point before
    /// @param claimEarn claimed earned earn-token, if this owner has order with same direction on this point before
    /// @param sellXEarnY direction of limit order, etc. sell tokenX or sell tokenY
    event AddLimitOrder(
        address indexed owner,
        uint128 addAmount,
        uint128 acquireAmount,
        int24 indexed point,
        uint128 claimSold,
        uint128 claimEarn,
        bool sellXEarnY
    );

    /// @notice Emitted when a seller successfully decrease a limit order.
    /// @param owner owner of limit order
    /// @param decreaseAmount amount of token to sell the seller decreased
    /// @param point point of limit order
    /// @param claimSold claimed sold sell-token
    /// @param claimEarn claimed earned earn-token
    /// @param sellXEarnY direction of limit order, etc. sell tokenX or sell tokenY
    event DecLimitOrder(
        address indexed owner,
        uint128 decreaseAmount,
        int24 indexed point,
        uint128 claimSold,
        uint128 claimEarn,
        bool sellXEarnY
    );

    /// @notice Emitted when collect from a limit order
    /// @param owner The owner of the Liquidity
    /// @param recipient recipient of those token
    /// @param point The point of the limit order
    /// @param collectDec The amount of decreased sell token collected
    /// @param collectEarn The amount of earn token collected
    /// @param sellXEarnY direction of limit order, etc. sell tokenX or sell tokenY
    event CollectLimitOrder(
        address indexed owner,
        address recipient,
        int24 indexed point,
        uint128 collectDec,
        uint128 collectEarn,
        bool sellXEarnY
    );

    /// @notice Returns the information about a liquidity by the liquidity's key.
    /// @param key the liquidity's key is a hash of a preimage composed by the miner(owner), pointLeft and pointRight
    /// @return feeVote Vote for fee
    /// @return _liquidity the amount of liquidity,
    /// @return lastFeeScaleX_128 fee growth of tokenX inside the range as of the last mint/burn/collect,
    /// @return lastFeeScaleY_128 fee growth of tokenY inside the range as of the last mint/burn/collect,
    /// @return tokenOwedX the computed amount of tokenX miner can collect as of the last mint/burn/collect,
    /// @return tokenOwedY the computed amount of tokenY miner can collect as of the last mint/burn/collect
    function liquidity(bytes32 key)
        external
        view
        returns (
            uint16 feeVote,
            uint128 _liquidity,
            uint256 lastFeeScaleX_128,
            uint256 lastFeeScaleY_128,
            uint256 tokenOwedX,
            uint256 tokenOwedY
        );

    /// @notice Returns the information about a user's limit order (sell tokenY and earn tokenX).
    /// @param key the limit order's key is a hash of a preimage composed by the seller, point
    /// @return lastAccEarn total amount of tokenX earned by all users at this point as of the last add/dec/collect
    /// @return sellingRemain amount of tokenY not selled in this limit order
    /// @return sellingDec amount of tokenY decreased by seller from this limit order
    /// @return earn amount of unlegacy earned tokenX in this limit order not assigned
    /// @return legacyEarn amount of legacy earned tokenX in this limit order not assgined
    /// @return earnAssign assigned amount of tokenX earned (both legacy and unlegacy) in this limit order
    function userEarnX(bytes32 key)
        external
        view
        returns (
            uint256 lastAccEarn,
            uint128 sellingRemain,
            uint128 sellingDec,
            uint128 earn,
            uint128 legacyEarn,
            uint128 earnAssign
        );

    /// @notice Returns the information about a user's limit order (sell tokenX and earn tokenY).
    /// @param key the limit order's key is a hash of a preimage composed by the seller, point
    /// @return lastAccEarn total amount of tokenY earned by all users at this point as of the last add/dec/collect
    /// @return sellingRemain amount of tokenX not selled in this limit order
    /// @return sellingDec amount of tokenX decreased by seller from this limit order
    /// @return earn amount of unlegacy earned tokenY in this limit order not assigned
    /// @return legacyEarn amount of legacy earned tokenY in this limit order not assgined
    /// @return earnAssign assigned amount of tokenY earned (both legacy and unlegacy) in this limit order
    function userEarnY(bytes32 key)
        external
        view
        returns (
            uint256 lastAccEarn,
            uint128 sellingRemain,
            uint128 sellingDec,
            uint128 earn,
            uint128 legacyEarn,
            uint128 earnAssign
        );

    /// @notice Mark a given amount of tokenY in a limitorder(sellx and earn y) as assigned.
    /// @param point point (log Price) of seller's limit order,be sure to be times of pointDelta
    /// @param assignY max amount of tokenY to mark assigned
    /// @param fromLegacy true for assigning earned token from legacyEarnY
    /// @return actualAssignY actual amount of tokenY marked
    function assignLimOrderEarnY(
        int24 point,
        uint128 assignY,
        bool fromLegacy
    ) external returns(uint128 actualAssignY);

    /// @notice Mark a given amount of tokenX in a limitorder(selly and earn x) as assigned.
    /// @param point point (log Price) of seller's limit order,be sure to be times of pointDelta
    /// @param assignX max amount of tokenX to mark assigned
    /// @param fromLegacy true for assigning earned token from legacyEarnX
    /// @return actualAssignX actual amount of tokenX marked
    function assignLimOrderEarnX(
        int24 point,
        uint128 assignX,
        bool fromLegacy
    ) external returns(uint128 actualAssignX);

    /// @notice Decrease limitorder of selling X.
    /// @param point point of seller's limit order, be sure to be times of pointDelta
    /// @param deltaX max amount of tokenX seller wants to decrease
    /// @return actualDeltaX actual amount of tokenX decreased
    /// @return legacyAccEarn legacyAccEarnY of pointOrder at point when calling this interface
    function decLimOrderWithX(
        int24 point,
        uint128 deltaX
    ) external returns (uint128 actualDeltaX, uint256 legacyAccEarn);

    /// @notice Decrease limitorder of selling Y.
    /// @param point point of seller's limit order, be sure to be times of pointDelta
    /// @param deltaY max amount of tokenY seller wants to decrease
    /// @return actualDeltaY actual amount of tokenY decreased
    /// @return legacyAccEarn legacyAccEarnX of pointOrder at point when calling this interface
    function decLimOrderWithY(
        int24 point,
        uint128 deltaY
    ) external returns (uint128 actualDeltaY, uint256 legacyAccEarn);

    /// @notice Add a limit order (selling x) in the pool.
    /// @param recipient owner of the limit order
    /// @param point point of the order, be sure to be times of pointDelta
    /// @param amountX amount of tokenX to sell
    /// @param data any data that should be passed through to the callback
    /// @return orderX actual added amount of tokenX
    /// @return acquireY amount of tokenY acquired if there is a limit order to sell y before adding
    function addLimOrderWithX(
        address recipient,
        int24 point,
        uint128 amountX,
        bytes calldata data
    ) external returns (uint128 orderX, uint128 acquireY);

    /// @notice Add a limit order (selling y) in the pool.
    /// @param recipient owner of the limit order
    /// @param point point of the order, be sure to be times of pointDelta
    /// @param amountY amount of tokenY to sell
    /// @param data any data that should be passed through to the callback
    /// @return orderY actual added amount of tokenY
    /// @return acquireX amount of tokenX acquired if there exists a limit order to sell x before adding
    function addLimOrderWithY(
        address recipient,
        int24 point,
        uint128 amountY,
        bytes calldata data
    ) external returns (uint128 orderY, uint128 acquireX);

    /// @notice Collect earned or decreased token from limit order.
    /// @param recipient address to benefit
    /// @param point point of limit order, be sure to be times of pointDelta
    /// @param collectDec max amount of decreased selling token to collect
    /// @param collectEarn max amount of earned token to collect
    /// @param isEarnY direction of this limit order, true for sell y, false for sell x
    /// @return actualCollectDec actual amount of decresed selling token collected
    /// @return actualCollectEarn actual amount of earned token collected
    function collectLimOrder(
        address recipient, int24 point, uint128 collectDec, uint128 collectEarn, bool isEarnY
    ) external returns(uint128 actualCollectDec, uint128 actualCollectEarn);

    /// @notice Add liquidity to the pool.
    /// @param recipient newly created liquidity will belong to this address
    /// @param leftPt left endpoint of the liquidity, be sure to be times of pointDelta
    /// @param rightPt right endpoint of the liquidity, be sure to be times of pointDelta
    /// @param liquidDelta amount of liquidity to add
    /// @param data any data that should be passed through to the callback
    /// @return amountX The amount of tokenX that was paid for the liquidity. Matches the value in the callback
    /// @return amountY The amount of tokenY that was paid for the liquidity. Matches the value in the callback
    function mint(
        address recipient,
        int24 leftPt,
        int24 rightPt,
        uint128 liquidDelta,
        bytes calldata data
    ) external returns (uint256 amountX, uint256 amountY);

    /// @notice Add liquidity to the pool.
    /// @param recipient newly created liquidity will belong to this address
    /// @param leftPt left endpoint of the liquidity, be sure to be times of pointDelta
    /// @param rightPt right endpoint of the liquidity, be sure to be times of pointDelta
    /// @param liquidDelta amount of liquidity to add
    /// @param feeToVote vote for fee on current pool
    /// @param data any data that should be passed through to the callback
    /// @return amountX The amount of tokenX that was paid for the liquidity. Matches the value in the callback
    /// @return amountY The amount of tokenY that was paid for the liquidity. Matches the value in the callback
    function mint(
        address recipient,
        int24 leftPt,
        int24 rightPt,
        uint128 liquidDelta,
        uint16 feeToVote,
        bytes calldata data
    ) external returns (uint256 amountX, uint256 amountY);

    /// @notice Decrease a given amount of liquidity from msg.sender's liquidities.
    /// @param leftPt left endpoint of the liquidity
    /// @param rightPt right endpoint of the liquidity
    /// @param liquidDelta amount of liquidity to burn
    /// @return amountX The amount of tokenX should be refund after burn
    /// @return amountY The amount of tokenY should be refund after burn
    function burn(
        int24 leftPt,
        int24 rightPt,
        uint128 liquidDelta
    ) external returns (uint256 amountX, uint256 amountY);

    /// @notice Collect tokens (fee or refunded after burn) from a liquidity.
    /// @param recipient the address which should receive the collected tokens
    /// @param leftPt left endpoint of the liquidity
    /// @param rightPt right endpoint of the liquidity
    /// @param amountXLim max amount of tokenX the owner wants to collect
    /// @param amountYLim max amount of tokenY the owner wants to collect
    /// @return actualAmountX the amount tokenX collected
    /// @return actualAmountY the amount tokenY collected
    function collect(
        address recipient,
        int24 leftPt,
        int24 rightPt,
        uint256 amountXLim,
        uint256 amountYLim
    ) external returns (uint256 actualAmountX, uint256 actualAmountY);

    /// @notice Change fee vote for user existing liquidity.
    /// @param leftPt left endpoint of the liquidity
    /// @param rightPt right endpoint of the liquidity
    /// @param newFeeVote new vote for fee for existing liquidity
    function changeFeeVote(int24 leftPt, int24 rightPt, uint16 newFeeVote) external;

    /// @notice Swap tokenY for tokenX, given max amount of tokenY user willing to pay.
    /// @param recipient the address to receive tokenX
    /// @param amount the max amount of tokenY user willing to pay
    /// @param highPt the highest point(price) of x/y during swap
    /// @param data any data to be passed through to the callback
    /// @return amountX amount of tokenX payed
    /// @return amountY amount of tokenY acquired
    function swapY2X(
        address recipient,
        uint128 amount,
        int24 highPt,
        bytes calldata data
    ) external returns (uint256 amountX, uint256 amountY);

    /// @notice Swap tokenY for tokenX, given amount of tokenX user desires.
    /// @param recipient the address to receive tokenX
    /// @param desireX the amount of tokenX user desires
    /// @param highPt the highest point(price) of x/y during swap
    /// @param data any data to be passed through to the callback
    /// @return amountX amount of tokenX payed
    /// @return amountY amount of tokenY acquired
    function swapY2XDesireX(
        address recipient,
        uint128 desireX,
        int24 highPt,
        bytes calldata data
    ) external returns (uint256 amountX, uint256 amountY);

    /// @notice Swap tokenX for tokenY, given max amount of tokenX user willing to pay.
    /// @param recipient the address to receive tokenY
    /// @param amount the max amount of tokenX user willing to pay
    /// @param lowPt the lowest point(price) of x/y during swap
    /// @param data any data to be passed through to the callback
    /// @return amountX amount of tokenX acquired
    /// @return amountY amount of tokenY payed
    function swapX2Y(
        address recipient,
        uint128 amount,
        int24 lowPt,
        bytes calldata data
    ) external returns (uint256 amountX, uint256 amountY);

    /// @notice Swap tokenX for tokenY, given amount of tokenY user desires.
    /// @param recipient the address to receive tokenY
    /// @param desireY the amount of tokenY user desires
    /// @param lowPt the lowest point(price) of x/y during swap
    /// @param data any data to be passed through to the callback
    /// @return amountX amount of tokenX acquired
    /// @return amountY amount of tokenY payed
    function swapX2YDesireY(
        address recipient,
        uint128 desireY,
        int24 lowPt,
        bytes calldata data
    ) external returns (uint256 amountX, uint256 amountY);

    /// @notice Returns sqrt(1.0001), in 96 bit fixpoint number.
    function sqrtRate_96() external view returns(uint160);

    /// @notice State values of pool.
    /// @return sqrtPrice_96 a 96 fixpoing number describe the sqrt value of current price(tokenX/tokenY)
    /// @return currentPoint the current point of the pool, 1.0001 ^ currentPoint = price
    /// @return observationCurrentIndex the index of the last oracle observation that was written,
    /// @return observationQueueLen the current maximum number of observations stored in the pool,
    /// @return observationNextQueueLen the next maximum number of observations, to be updated when the observation.
    /// @return locked whether the pool is locked (only used for checking reentrance)
    /// @return feeTimesL sum Vote fee * Liquidity
    /// @return fee Current fee on pool
    /// @return _liquidity liquidity on the currentPoint (currX * sqrtPrice + currY / sqrtPrice)
    /// @return liquidityX liquidity of tokenX
    function state()
        external view
        returns(
            uint160 sqrtPrice_96,
            int24 currentPoint,
            uint16 observationCurrentIndex,
            uint16 observationQueueLen,
            uint16 observationNextQueueLen,
            bool locked,
            uint240 feeTimesL,
            uint16 fee,
            uint128 _liquidity,
            uint128 liquidityX
        );

    /// @notice LimitOrder info on a given point.
    /// @param point the given point
    /// @return sellingX total amount of tokenX selling on the point
    /// @return earnY total amount of unclaimed earned tokenY for unlegacy sellingX
    /// @return accEarnY total amount of earned tokenY(via selling tokenX) by all users at this point as of the last swap
    /// @return legacyAccEarnY latest recorded 'accEarnY' value when sellingX is clear (legacy)
    /// @return legacyEarnY total amount of unclaimed earned tokenY for legacy (cleared during swap) sellingX
    /// @return sellingY total amount of tokenYselling on the point
    /// @return earnX total amount of unclaimed earned tokenX for unlegacy sellingY
    /// @return legacyEarnX total amount of unclaimed earned tokenX for legacy (cleared during swap) sellingY
    /// @return accEarnX total amount of earned tokenX(via selling tokenY) by all users at this point as of the last swap
    /// @return legacyAccEarnX latest recorded 'accEarnX' value when sellingY is clear (legacy)
    function limitOrderData(int24 point)
        external view
        returns(
            uint128 sellingX,
            uint128 earnY,
            uint256 accEarnY,
            uint256 legacyAccEarnY,
            uint128 legacyEarnY,
            uint128 sellingY,
            uint128 earnX,
            uint128 legacyEarnX,
            uint256 accEarnX,
            uint256 legacyAccEarnX
        );

    /// @notice Query infomation about a point whether has limit order or is an liquidity's endpoint.
    /// @param point point to query
    /// @return val endpoint for val&1>0 and has limit order for val&2 > 0
    function orderOrEndpoint(int24 point) external returns(int24 val);

    /// @notice Returns observation data about a specific index.
    /// @param index the index of observation array
    /// @return timestamp the timestamp of the observation,
    /// @return accPoint the point multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
    /// @return init whether the observation has been initialized and the above values are safe to use
    function observations(uint256 index)
        external
        view
        returns (
            uint32 timestamp,
            int56 accPoint,
            bool init
        );

    /// @notice Point status in the pool.
    /// @param point the point
    /// @return liquidSum the total amount of liquidity that uses the point either as left endpoint or right endpoint
    /// @return liquidDelta how much liquidity changes when the pool price crosses the point from left to right
    /// @return accFeeXOut_128 the fee growth on the other side of the point from the current point in tokenX
    /// @return accFeeYOut_128 the fee growth on the other side of the point from the current point in tokenY
    /// @return isEndpt whether the point is an endpoint of a some miner's liquidity, true if liquidSum > 0
    /// @return feeTimesL how much fee vote changes when the pool price crosses the point
    function points(int24 point)
        external
        view
        returns (
            uint128 liquidSum,
            int128 liquidDelta,
            uint256 accFeeXOut_128,
            uint256 accFeeYOut_128,
            bool isEndpt,
            uint240 feeTimesL
        );

    /// @notice Returns 256 packed point (statusVal>0) boolean values. See PointBitmap for more information.
    function pointBitmap(int16 wordPosition) external view returns (uint256);

    /// @notice Returns the integral value of point(time) and integral value of 1/liquidity(time)
    ///     at some target timestamps (block.timestamp - secondsAgo[i])
    /// @dev Reverts if target timestamp is early than oldest observation in the queue
    /// @dev If you call this method with secondsAgos = [3600, 0]. the average point of this pool during recent hour is
    /// (accPoints[1] - accPoints[0]) / 3600
    /// @param secondsAgos describe the target timestamp , targetTimestimp[i] = block.timestamp - secondsAgo[i]
    /// @return accPoints integral value of point(time) from 0 to each target timestamp
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory accPoints);

    /// @notice Expand max-length of observation queue.
    /// @param newNextQueueLen new value of observationNextQueueLen, which should be greater than current observationNextQueueLen
    function expandObservationQueue(uint16 newNextQueueLen) external;

    /// @notice Borrow tokenX and/or tokenY and pay it back within a block.
    /// @dev The caller needs to implement a IBiswapPoolV3#flashCallback callback function
    /// @param recipient the address which will receive the tokenY and/or tokenX
    /// @param amountX the amount of tokenX to borrow
    /// @param amountY the amount of tokenY to borrow
    /// @param data Any data to be passed through to the callback
    function flash(
        address recipient,
        uint256 amountX,
        uint256 amountY,
        bytes calldata data
    ) external;

    /// @notice Returns a snapshot infomation of Liquidity in [leftPoint, rightPoint).
    /// @param leftPoint left endpoint of range, should be times of pointDelta
    /// @param rightPoint right endpoint of range, should be times of pointDelta
    /// @return deltaLiquidities an array of delta liquidity for points in the range
    ///    note 1. delta liquidity here is amount of liquidity changed when cross a point from left to right
    ///    note 2. deltaLiquidities only contains points which are times of pointDelta
    ///    note 3. this function may cost a ENORMOUS amount of gas, be careful to call
    function liquiditySnapshot(int24 leftPoint, int24 rightPoint) external view returns(int128[] memory deltaLiquidities);

    struct LimitOrderStruct {
        uint128 sellingX;
        uint128 earnY;
        uint256 accEarnY;
        uint128 sellingY;
        uint128 earnX;
        uint256 accEarnX;
    }

    /// @notice Returns a snapshot infomation of Limit Order in [leftPoint, rightPoint).
    /// @param leftPoint left endpoint of range, should be times of pointDelta
    /// @param rightPoint right endpoint of range, should be times of pointDelta
    /// @return limitOrders an array of Limit Orders for points in the range
    ///    note 1. this function may cost a HUGE amount of gas, be careful to call
    function limitOrderSnapshot(int24 leftPoint, int24 rightPoint) external view returns(LimitOrderStruct[] memory limitOrders);

    /// @notice Amount of charged fee on tokenX.
    function totalFeeXCharged() external view returns(uint256);

    /// @notice Amount of charged fee on tokenY.
    function totalFeeYCharged() external view returns(uint256);

    /// @notice Percent to charge from miner's fee.
    function feeChargePercent() external view returns(uint24);

    /// @notice Collect charged fee, only factory's chargeReceiver can call.
    function collectFeeCharged() external;

    /// @notice modify 'feeChargePercent', only owner has authority.
    /// @param newFeeChargePercent new value of feeChargePercent, a nature number range in [0, 100],
    function modifyFeeChargePercent(uint24 newFeeChargePercent) external;

    function getCurrentFee() external view returns(uint16 _fee);

}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

import "./MulDivMath.sol";
import "./TwoPower.sol";
import "./LogPowMath.sol";

library AmountMath {

    function getAmountY(
        uint128 liquidity,
        uint160 sqrtPriceL_96,
        uint160 sqrtPriceR_96,
        uint160 sqrtRate_96,
        bool upper
    ) internal pure returns (uint256 amount) {
        uint160 numerator = sqrtPriceR_96 - sqrtPriceL_96;
        uint160 denominator = sqrtRate_96 - uint160(TwoPower.Pow96);
        if (!upper) {
            amount = MulDivMath.mulDivFloor(liquidity, numerator, denominator);
        } else {
            amount = MulDivMath.mulDivCeil(liquidity, numerator, denominator);
        }
    }

    function getAmountX(
        uint128 liquidity,
        int24 leftPt,
        int24 rightPt,
        uint160 sqrtPriceR_96,
        uint160 sqrtRate_96,
        bool upper
    ) internal pure returns (uint256 amount) {
        // rightPt - (leftPt - 1), pc = leftPt - 1
        uint160 sqrtPricePrPl_96 = LogPowMath.getSqrtPrice(rightPt - leftPt);
        // 1. sqrtPriceR_96 * 2^96 < 2^256
        // 2. sqrtRate_96 > 2^96, so sqrtPricePrM1_96 < sqrtPriceR_96 < 2^160
        uint160 sqrtPricePrM1_96 = uint160(uint256(sqrtPriceR_96) * TwoPower.Pow96 / sqrtRate_96);

        uint160 numerator = sqrtPricePrPl_96 - uint160(TwoPower.Pow96);
        uint160 denominator = sqrtPriceR_96 - sqrtPricePrM1_96;
        if (!upper) {
            amount = MulDivMath.mulDivFloor(liquidity, numerator, denominator);
        } else {
            amount = MulDivMath.mulDivCeil(liquidity, numerator, denominator);
        }
    }

    function getAmountYUnitLiquidity_96(
        uint160 sqrtPriceL_96,
        uint160 sqrtPriceR_96,
        uint160 sqrtRate_96
    ) internal pure returns (uint256 amount_96) {
        uint160 numerator = sqrtPriceR_96 - sqrtPriceL_96;
        uint160 denominator = sqrtRate_96 - uint160(TwoPower.pow96);
        amount_96 = MulDivMath.mulDivCeil(TwoPower.pow96, numerator, denominator);
    }

    function getAmountXUnitLiquidity_96(
        int24 leftPt,
        int24 rightPt,
        uint160 sqrtPriceR_96,
        uint160 sqrtRate_96
    ) internal pure returns (uint256 amount_96) {
        // rightPt - (leftPt - 1), pc = leftPt - 1
        uint160 sqrtPricePrPc_96 = LogPowMath.getSqrtPrice(rightPt - leftPt + 1);
        uint160 sqrtPricePrPd_96 = LogPowMath.getSqrtPrice(rightPt + 1);

        uint160 numerator = sqrtPricePrPc_96 - sqrtRate_96;
        uint160 denominator = sqrtPricePrPd_96 - sqrtPriceR_96;
        amount_96 = MulDivMath.mulDivCeil(TwoPower.pow96, numerator, denominator);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


library LogPowMath {

    int24 internal constant MIN_POINT = -887272;

    int24 internal constant MAX_POINT = -MIN_POINT;

    uint160 internal constant MIN_SQRT_PRICE = 4295128739;

    uint160 internal constant MAX_SQRT_PRICE = 1461446703485210103287273052203988822378723970342;

    /// @notice sqrt(1.0001^point) in form oy 96-bit fix point num
    function getSqrtPrice(int24 point) internal pure returns (uint160 sqrtPrice_96) {
        uint256 absIdx = point < 0 ? uint256(-int256(point)) : uint256(int256(point));
        require(absIdx <= uint256(int256(MAX_POINT)), 'T');

        uint256 value = absIdx & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
        if (absIdx & 0x2 != 0) value = (value * 0xfff97272373d413259a46990580e213a) >> 128;
        if (absIdx & 0x4 != 0) value = (value * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absIdx & 0x8 != 0) value = (value * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absIdx & 0x10 != 0) value = (value * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absIdx & 0x20 != 0) value = (value * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absIdx & 0x40 != 0) value = (value * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absIdx & 0x80 != 0) value = (value * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absIdx & 0x100 != 0) value = (value * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absIdx & 0x200 != 0) value = (value * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absIdx & 0x400 != 0) value = (value * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absIdx & 0x800 != 0) value = (value * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absIdx & 0x1000 != 0) value = (value * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absIdx & 0x2000 != 0) value = (value * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absIdx & 0x4000 != 0) value = (value * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absIdx & 0x8000 != 0) value = (value * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absIdx & 0x10000 != 0) value = (value * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
        if (absIdx & 0x20000 != 0) value = (value * 0x5d6af8dedb81196699c329225ee604) >> 128;
        if (absIdx & 0x40000 != 0) value = (value * 0x2216e584f5fa1ea926041bedfe98) >> 128;
        if (absIdx & 0x80000 != 0) value = (value * 0x48a170391f7dc42444e8fa2) >> 128;

        if (point > 0) value = type(uint256).max / value;

        sqrtPrice_96 = uint160((value >> 32) + (value % (1 << 32) == 0 ? 0 : 1));
    }

    // floor(log1.0001(sqrtPrice_96))
    function getLogSqrtPriceFloor(uint160 sqrtPrice_96) internal pure returns (int24 logValue) {
        // second inequality must be < because the price can nevex reach the price at the max tick
        require(sqrtPrice_96 >= MIN_SQRT_PRICE && sqrtPrice_96 < MAX_SQRT_PRICE, 'R');
        uint256 sqrtPrice_128 = uint256(sqrtPrice_96) << 32;

        uint256 x = sqrtPrice_128;
        uint256 m = 0;

        assembly {
            let y := shl(7, gt(x, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(6, gt(x, 0xFFFFFFFFFFFFFFFF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(5, gt(x, 0xFFFFFFFF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(4, gt(x, 0xFFFF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(3, gt(x, 0xFF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(2, gt(x, 0xF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(1, gt(x, 0x3))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := gt(x, 0x1)
            m := or(m, y)
        }

        if (m >= 128) x = sqrtPrice_128 >> (m - 127);
        else x = sqrtPrice_128 << (127 - m);

        int256 l2 = (int256(m) - 128) << 64;

        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(63, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(62, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(61, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(60, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(59, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(58, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(57, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(56, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(55, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(54, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(53, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(52, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(51, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(50, y))
        }

        int256 ls10001 = l2 * 255738958999603826347141;

        int24 logFloor = int24((ls10001 - 3402992956809132418596140100660247210) >> 128);
        int24 logUpper = int24((ls10001 + 291339464771989622907027621153398088495) >> 128);

        logValue = logFloor == logUpper ? logFloor : getSqrtPrice(logUpper) <= sqrtPrice_96 ? logUpper : logFloor;
    }

    function getLogSqrtPriceFU(uint160 sqrtPrice_96) internal pure returns (int24 logFloor, int24 logUpper) {
        // second inequality must be < because the price can nevex reach the price at the max tick
        require(sqrtPrice_96 >= MIN_SQRT_PRICE && sqrtPrice_96 < MAX_SQRT_PRICE, 'R');
        uint256 sqrtPrice_128 = uint256(sqrtPrice_96) << 32;

        uint256 x = sqrtPrice_128;
        uint256 m = 0;

        assembly {
            let y := shl(7, gt(x, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(6, gt(x, 0xFFFFFFFFFFFFFFFF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(5, gt(x, 0xFFFFFFFF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(4, gt(x, 0xFFFF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(3, gt(x, 0xFF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(2, gt(x, 0xF))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := shl(1, gt(x, 0x3))
            m := or(m, y)
            x := shr(y, x)
        }
        assembly {
            let y := gt(x, 0x1)
            m := or(m, y)
        }

        if (m >= 128) x = sqrtPrice_128 >> (m - 127);
        else x = sqrtPrice_128 << (127 - m);

        int256 l2 = (int256(m) - 128) << 64;

        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(63, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(62, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(61, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(60, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(59, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(58, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(57, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(56, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(55, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(54, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(53, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(52, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(51, y))
            x := shr(y, x)
        }
        assembly {
            x := shr(127, mul(x, x))
            let y := shr(128, x)
            l2 := or(l2, shl(50, y))
        }

        int256 ls10001 = l2 * 255738958999603826347141;

        logFloor = int24((ls10001 - 3402992956809132418596140100660247210) >> 128);
        logUpper = int24((ls10001 + 291339464771989622907027621153398088495) >> 128);
    }
    
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

import "./TwoPower.sol";
import "./AmountMath.sol";

library MintMath {

    struct MintMathParam {
        int24 pl;
        int24 pr;
        uint128 xLim;
        uint128 yLim;
    }

    /// @dev [pl, pr)
    function _computeDepositXYPerUnit(
        int24 pl,
        int24 pr,
        int24 pc,
        uint160 sqrtPrice_96,
        uint160 sqrtRate_96
    ) private pure returns (uint256 x, uint256 y) {
        x = 0;
        y = 0;
        uint160 sqrtPriceR_96 = LogPowMath.getSqrtPrice(pr);
        if (pl < pc) {
            uint160 sqrtPriceL_96 = LogPowMath.getSqrtPrice(pl);
            if (pr < pc) {
                y += AmountMath.getAmountYUnitLiquidity_96(sqrtPriceL_96, sqrtPriceR_96, sqrtRate_96);
            } else {
                y += AmountMath.getAmountYUnitLiquidity_96(sqrtPriceL_96, sqrtPrice_96, sqrtRate_96);
            }
        }
        if (pr > pc) {
            // we need compute XR
            int24 xrLeft = (pl > pc) ? pl : pc + 1;
            x = AmountMath.getAmountXUnitLiquidity_96(
                xrLeft,
                pr,
                sqrtPriceR_96,
                sqrtRate_96
            );
        }
        if (pl <= pc && pr > pc) {
            // we nned compute yc at point of current price
            y += sqrtPrice_96;
        }
    }

    function computeLiquidity(
        MintMathParam memory mp, int24 currPt, uint160 sqrtPrice_96, uint160 sqrtRate_96
    ) internal pure returns(uint128 liquidity) {
        liquidity = type(uint128).max / 2;
        (uint256 x, uint256 y) = _computeDepositXYPerUnit(mp.pl, mp.pr, currPt, sqrtPrice_96, sqrtRate_96);
        if (x > 0) {
            uint256 xl = uint256(mp.xLim) * TwoPower.pow96 / x;
            if (liquidity > xl) {
                liquidity = uint128(xl);
            }
        }
        if (y > 0) {
            // we take yLim - 1, because in the core, the amountY to deposit is
            // calculated by range [left, pc) and point at pc respectively
            uint256 yl = uint256(mp.yLim - 1) * TwoPower.pow96 / y;
            if (liquidity > yl) {
                liquidity = uint128(yl);
            }
        }
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library MulDivMath {

    // compute res = floor(a * b / c), assuming res < 2^256
    function mulDivFloor(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal pure returns (uint256 res) {
        
        // let prodMod2_256 = a * b % 2^256
        uint256 prodMod2_256; 
        // let prodDiv2_256 = a * b / 2^256
        uint256 prodDiv2_256;
        assembly {
            let prodModM1 := mulmod(a, b, not(0))
            prodMod2_256 := mul(a, b)
            prodDiv2_256 := sub(sub(prodModM1, prodMod2_256), lt(prodModM1, prodMod2_256))
        }

        if (prodDiv2_256 == 0) {
            require(c > 0);
            assembly {
                res := div(prodMod2_256, c)
            }
            return res;
        }

        // we should ensure that a * b /c < 2^256 before calling
        require(c > prodDiv2_256);

        uint256 resMod;
        assembly {
            resMod := mulmod(a, b, c)
            // a * b - resMod
            prodDiv2_256 := sub(prodDiv2_256, gt(resMod, prodMod2_256))
            prodMod2_256 := sub(prodMod2_256, resMod)

            // compute lowbit of c
            let lowbit := not(c)
            lowbit := add(lowbit, 1)
            lowbit := and(lowbit, c)

            // c / lowbit
            c := div(c, lowbit)
            // a * b / lowbit
            prodMod2_256 := div(prodMod2_256, lowbit)
            lowbit := add(div(sub(0, lowbit), lowbit), 1)
            prodDiv2_256 := mul(prodDiv2_256, lowbit)
            prodMod2_256 := or(prodMod2_256, prodDiv2_256)

            // get inv of c
            // cInv * c = 1 (mod 2^4)
            let cInv := xor(mul(3, c), 2)
            cInv := mul(cInv, sub(2, mul(c, cInv))) // shift to 2^8
            cInv := mul(cInv, sub(2, mul(c, cInv))) // shift to 2^16
            cInv := mul(cInv, sub(2, mul(c, cInv))) // shift to 2^32
            cInv := mul(cInv, sub(2, mul(c, cInv))) // shift to 2^64
            cInv := mul(cInv, sub(2, mul(c, cInv))) // shift to 2^128
            cInv := mul(cInv, sub(2, mul(c, cInv))) // shift to 2^256

            // a * b / c = prodMod2_256 * cInv (mod 2^256)
            res := mul(prodMod2_256, cInv)
        }
    }

    // compute res = ceil(a * b / c), assuming res < 2^256
    function mulDivCeil(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal pure returns (uint256 res) {
        res = mulDivFloor(a, b, c);
        if (mulmod(a, b, c) > 0) {
            require(res < type(uint256).max);
            res++;
        }
    }
    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library TwoPower {
    uint256 internal constant Pow128 = 0x100000000000000000000000000000000;
    uint256 internal constant pow128 = 0x100000000000000000000000000000000;
    uint256 internal constant Pow96 = 0x1000000000000000000000000;
    uint256 internal constant pow96 = 0x1000000000000000000000000;
    uint8 internal constant RESOLUTION = 96;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../interfaces/IBiswapFactoryV3.sol";

/// @title Interface for WETH9
interface IWETH9 is IERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}

abstract contract Base {
    /// @notice address of BiswapFactoryV3
    address public immutable factory;

    /// @notice address of weth9 token
    address public immutable WETH9;

    modifier checkDeadline(uint256 deadline) {
        require(block.timestamp <= deadline, 'Out of time');
        _;
    }

    receive() external payable {}

    /// @notice Constructor of base.
    /// @param _factory address of BiswapFactoryV3
    /// @param _WETH9 address of weth9 token
    constructor(address _factory, address _WETH9) {
        factory = _factory;
        WETH9 = _WETH9;
    }

    /// @notice Make multiple function calls in this contract in a single transaction
    ///     and return the data for each function call, revert if any function call fails
    /// @param data The encoded function data for each function call
    /// @return results result of each function call
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            if (!success) {
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            results[i] = result;
        }
    }

    /// @notice Transfer tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    /// @notice Transfer tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    /// @notice Approve the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    /// @notice Transfer ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }

    /// @notice Withdraw all weth9 token of this contract and send the withdrawed eth to recipient
    ///    usually used in multicall when mint/swap/update limitorder with eth
    ///    normally this contract has no any erc20 token or eth after or before a transaction
    ///    we donot need to worry that some one can steal eth from this contract
    /// @param minAmount The minimum amount of WETH9 to withdraw
    /// @param recipient The address to receive all withdrawed eth from this contract
    function unwrapWETH9(uint256 minAmount, address recipient) external payable {
        uint256 all = IWETH9(WETH9).balanceOf(address(this));
        require(all >= minAmount, 'WETH9 Not Enough');

        if (all > 0) {
            IWETH9(WETH9).withdraw(all);
            safeTransferETH(recipient, all);
        }
    }

    /// @notice Send all balance of specified token in this contract to recipient
    ///    usually used in multicall when mint/swap/update limitorder with eth
    ///    normally this contract has no any erc20 token or eth after or before a transaction
    ///    we donot need to worry that some one can steal some token from this contract
    /// @param token address of the token
    /// @param minAmount balance should >= minAmount
    /// @param recipient the address to receive specified token from this contract
    function sweepToken(
        address token,
        uint256 minAmount,
        address recipient
    ) external payable {
        uint256 all = IERC20(token).balanceOf(address(this));
        require(all >= minAmount, 'WETH9 Not Enough');

        if (all > 0) {
            safeTransfer(token, recipient, all);
        }
    }

    /// @notice Send all balance of eth in this contract to msg.sender
    ///    usually used in multicall when mint/swap/update limitorder with eth
    ///    normally this contract has no any erc20 token or eth after or before a transaction
    ///    we donot need to worry that some one can steal some token from this contract
    function refundETH() external payable {
        if (address(this).balance > 0) safeTransferETH(msg.sender, address(this).balance);
    }

    /// @param token The token to pay
    /// @param payer The entity that must pay
    /// @param recipient The entity that will receive payment
    /// @param value The amount to pay
    function pay(
        address token,
        address payer,
        address recipient,
        uint256 value
    ) internal {
        if (token == WETH9 && address(this).balance >= value) {
            // pay with WETH9
            IWETH9(WETH9).deposit{value: value}(); // wrap only what is needed to pay
            IWETH9(WETH9).transfer(recipient, value);
        } else if (payer == address(this)) {
            // pay with tokens already in the contract (for the exact input multihop case)
            safeTransfer(token, recipient, value);
        } else {
            // pull payment
            safeTransferFrom(token, payer, recipient, value);
        }
    }

    /// @notice Query pool address from factory by (tokenX, tokenY, fee).
    /// @param tokenX tokenX of swap pool
    /// @param tokenY tokenY of swap pool
    /// @param fee fee amount of swap pool
    function pool(address tokenX, address tokenY, uint16 fee) public view returns(address) {
        (address token0, address token1) = tokenX < tokenY ? (tokenX, tokenY) : (tokenY, tokenX);
        return address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encode(token0, token1, fee)),
                hex'1ce2ccf1b7bdba79c33fb1280dec920e7ac26faee47e5ef92deda7b4f6378b2a'
            )))));
    }
    //
    function verify(address tokenX, address tokenY, uint16 fee) internal view {
        require (msg.sender == pool(tokenX, tokenY, fee), "sp");
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../interfaces/IBiswapCallback.sol";
import "../interfaces/IBiswapFactoryV3.sol";
import "../interfaces/IBiswapPoolV3.sol";

import "../libraries/MintMath.sol";
import "../libraries/TwoPower.sol";

import "./base/base.sol";

contract LiquidityManager is Ownable, Base, ERC721Enumerable, IBiswapMintCallback {

    /// @notice Emitted when miner successfully add liquidity on an existing liquidity-nft
    /// @param nftId id of minted liquidity nft
    /// @param pool address of swap pool
    /// @param liquidityDelta the amount of liquidity added
    /// @param amountX amount of tokenX deposit
    /// @param amountY amount of tokenY deposit
    event AddLiquidity(
        uint256 indexed nftId,
        address pool,
        uint128 liquidityDelta,
        uint256 amountX,
        uint256 amountY
    );
    /// @notice Emitted when miner successfully add decrease liquidity on an existing liquidity-nft
    /// @param nftId id of minted liquidity nft
    /// @param pool address of swap pool
    /// @param liquidityDelta the amount of liquidity decreased
    /// @param amountX amount of tokenX withdrawed
    /// @param amountY amount of tokenY withdrawed
    event DecLiquidity(
        uint256 indexed nftId,
        address pool,
        uint128 liquidityDelta,
        uint256 amountX,
        uint256 amountY
    );

    // callback data passed through BiswapPoolV3#mint to the callback
    struct MintCallbackData {
        // tokenX of swap
        address tokenX;
        // tokenY of swap
        address tokenY;
        // fee amount of swap
        uint16 fee;
        // address to pay tokenX and tokenY to BiswapPoolV3
        address payer;
    }

    // max-poolId in poolIds, poolId starts from 1
    uint128 private maxPoolId = 1;

    // infomation of liquidity provided by miner
    struct Liquidity {
        // left point of liquidity-token, the range is [leftPt, rightPt)
        int24 leftPt;
        // right point of liquidity-token, the range is [leftPt, rightPt)
        int24 rightPt;
        // amount of liquidity on each point in [leftPt, rightPt)
        uint128 liquidity;
        // a 128-fixpoint number, as integral of { fee(pt, t)/L(pt, t) }.
        // here fee(pt, t) denotes fee generated on point pt at time t
        // L(pt, t) denotes liquidity on point pt at time t
        // pt varies in [leftPt, rightPt)
        // t moves from pool created until miner last modify this liquidity-token (mint/addLiquidity/decreaseLiquidity/create)
        uint256 lastFeeScaleX_128;
        uint256 lastFeeScaleY_128;
        // remained tokenX miner can collect, including fee and withdrawed token
        uint256 remainTokenX;
        uint256 remainTokenY;
        // id of pool in which this liquidity is added
        uint128 poolId;
    }

    /// @notice mapping from nftId to Liquidity info
    mapping(uint256 =>Liquidity) public liquidities;

    /// @notice num of liquidity token
    uint256 public liquidityNum = 0;

    struct PoolMeta {
        // tokenX of pool
        address tokenX;
        // tokenY of pool
        address tokenY;
        // fee amount of pool
        uint16 fee;
    }

    /// @notice mapping from poolId to meta info of pool
    mapping(uint128 =>PoolMeta) public poolMetas;

    /// @notice mapping from address to poolId within this contract
    mapping(address =>uint128) public poolIds;

    modifier checkAuth(uint256 lid) {
        require(_isApprovedOrOwner(msg.sender, lid), 'Not approved');
        _;
    }

    string public baseURI;
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        baseURI = newBaseURI;
    }

    /// @notice Constructor to create this contract.
    /// @param factory address of BiswapFactoryV3
    /// @param weth address of WETH token
    constructor(
        address factory,
        address weth
    ) ERC721("Biswap Liquidity NFT", "BISWAP-LIQUIDITY-NFT") Base(factory, weth) {
    }

    /// @notice Callback for mining, in order to deposit tokens.
    /// @param x amount of tokenX pay from miner
    /// @param y amount of tokenY pay from miner
    /// @param data encoded MintCallbackData
    function mintDepositCallback(
        uint256 x, uint256 y, bytes calldata data
    ) external override {
        MintCallbackData memory dt = abi.decode(data, (MintCallbackData));
        verify(dt.tokenX, dt.tokenY, dt.fee);

        if (x > 0) {
            pay(dt.tokenX, dt.payer, msg.sender, x);
        }
        if (y > 0) {
            pay(dt.tokenY, dt.payer, msg.sender, y);
        }
    }

    /// @notice Get or create a pool for (tokenX/tokenY/fee) if not exists.
    /// @param tokenX tokenX of swap pool
    /// @param tokenY tokenY of swap pool
    /// @param fee fee amount of swap pool
    /// @param initialPoint initial point if need to create a new pool
    /// @return corresponding pool address
    function createPool(address tokenX, address tokenY, uint16 fee, int24 initialPoint) external returns (address) {
        require(tokenX < tokenY, "x<y");
        address pool = IBiswapFactoryV3(factory).pool(tokenX, tokenY, fee);
        if (pool == address(0)) {
            pool = IBiswapFactoryV3(factory).newPool(tokenX, tokenY, fee, initialPoint);
            return pool;
        }
        return pool;
    }

    function liquidityKey(address miner, int24 pl, int24 pr) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(miner, pl, pr));
    }

    function cachePoolKey(address pool, PoolMeta memory meta) private returns (uint128 poolId) {
        poolId = poolIds[pool];
        if (poolId == 0) {
            poolIds[pool] = (poolId = maxPoolId++);
            poolMetas[poolId] = meta;
        }
    }

    function getLastFeeScale(address pool, bytes32 key) private view returns(uint256, uint256) {

        (,, uint256 lastFeeScaleX_128, uint256 lastFeeScaleY_128, , ) = IBiswapPoolV3(pool).liquidity(
            key
        );
        return (lastFeeScaleX_128, lastFeeScaleY_128);
    }

    function getPoolPrice(address pool) private view returns (uint160, int24) {
        (
            uint160 sqrtPrice_96,
            int24 currPt,
            ,
            ,
            ,
            ,
            ,
            ,
            ,
        ) = IBiswapPoolV3(pool).state();
        return (sqrtPrice_96, currPt);
    }

    /// parameters when calling mint, grouped together to avoid stake too deep
    struct MintParam {
        // miner address
        address miner;
        // tokenX of swap pool
        address tokenX;
        // tokenY of swap pool
        address tokenY;
        // fee amount of swap pool
        uint16 fee;
        // left point of added liquidity
        int24 pl;
        // right point of added liquidity
        int24 pr;
        // amount limit of tokenX miner willing to deposit
        uint128 xLim;
        // amount limit tokenY miner willing to deposit
        uint128 yLim;
        // minimum amount of tokenX miner willing to deposit
        uint128 amountXMin;
        // minimum amount of tokenY miner willing to deposit
        uint128 amountYMin;

        uint256 deadline;
    }

    function _addLiquidity(MintParam memory mp) private returns(
        uint128 liquidity, uint256 amountX, uint256 amountY, address pool
    ) {
        int24 currPt;
        uint160 sqrtPrice_96;
        pool = IBiswapFactoryV3(factory).pool(mp.tokenX, mp.tokenY, mp.fee);
        uint160 sqrtRate_96 = IBiswapPoolV3(pool).sqrtRate_96();
        require(pool != address(0), "P0");
        (sqrtPrice_96, currPt) = getPoolPrice(pool);
        liquidity = MintMath.computeLiquidity(
            MintMath.MintMathParam({
                pl: mp.pl,
                pr: mp.pr,
                xLim: mp.xLim,
                yLim: mp.yLim
            }),
            currPt,
            sqrtPrice_96,
            sqrtRate_96
        );
        (amountX, amountY) = IBiswapPoolV3(pool).mint(address(this), mp.pl, mp.pr, liquidity,
            abi.encode(MintCallbackData({tokenX: mp.tokenX, tokenY: mp.tokenY, fee: mp.fee, payer: msg.sender})));
    }

    /// @notice Add a new liquidity and generate a nft.
    /// @param mintParam params, see MintParam for more
    /// @return lid id of nft
    /// @return liquidity amount of liquidity added
    /// @return amountX amount of tokenX deposited
    /// @return amountY amount of tokenY depsoited
    function mint(MintParam calldata mintParam) external payable checkDeadline(mintParam.deadline) returns(
        uint256 lid,
        uint128 liquidity,
        uint256 amountX,
        uint256 amountY
    ) {
        require(mintParam.tokenX < mintParam.tokenY, "x<y");
        address pool;
        (liquidity, amountX, amountY, pool) = _addLiquidity(mintParam);
        require(amountX >= mintParam.amountXMin, "XMIN");
        require(amountY >= mintParam.amountYMin, "YMIN");
        lid = liquidityNum ++;
        (uint256 lastFeeScaleX_128, uint256 lastFeeScaleY_128) = getLastFeeScale(
            pool, liquidityKey(address(this), mintParam.pl, mintParam.pr)
        );
        uint128 poolId = cachePoolKey(pool, PoolMeta({tokenX: mintParam.tokenX, tokenY: mintParam.tokenY, fee: mintParam.fee}));
        liquidities[lid] = Liquidity({
            leftPt: mintParam.pl,
            rightPt: mintParam.pr,
            liquidity: liquidity,
            lastFeeScaleX_128: lastFeeScaleX_128,
            lastFeeScaleY_128: lastFeeScaleY_128,
            remainTokenX: 0,
            remainTokenY: 0,
            poolId: poolId
        });
        _mint(mintParam.miner, lid);
        emit AddLiquidity(lid, pool, liquidity, amountX, amountY);
    }

    /// @notice Burn a generated nft.
    /// @param lid nft (liquidity) id
    /// @return success successfully burn or not
    function burn(uint256 lid) external checkAuth(lid) returns (bool success) {
        Liquidity storage liquid = liquidities[lid];
        require(liquid.liquidity == 0 && liquid.remainTokenX == 0 && liquid.remainTokenY == 0, 'NC');
        delete liquidities[lid];
        _burn(lid);
        return true;
    }

    /// parameters when calling addLiquidity, grouped together to avoid stake too deep
    struct AddLiquidityParam {
        // id of nft
        uint256 lid;
        // amount limit of tokenX user willing to deposit
        uint128 xLim;
        // amount limit of tokenY user willing to deposit
        uint128 yLim;
        // min amount of tokenX user willing to deposit
        uint128 amountXMin;
        // min amount of tokenY user willing to deposit
        uint128 amountYMin;

        uint256 deadline;
    }

    function updateLiquidity(
        Liquidity storage liquid,
        address pool,
        uint128 newLiquidity,
        uint256 amountX,
        uint256 amountY
    ) private {
        (uint256 lastFeeScaleX_128, uint256 lastFeeScaleY_128) = getLastFeeScale(
            pool, liquidityKey(address(this), liquid.leftPt, liquid.rightPt)
        );
        (uint256 deltaScaleX, uint256 deltaScaleY) = (liquid.lastFeeScaleX_128, liquid.lastFeeScaleY_128);
        assembly {
            deltaScaleX := sub(lastFeeScaleX_128, deltaScaleX)
            deltaScaleY := sub(lastFeeScaleY_128, deltaScaleY)
        }
        liquid.remainTokenX += amountX + MulDivMath.mulDivFloor(deltaScaleX, liquid.liquidity, TwoPower.pow128);
        liquid.remainTokenY += amountY + MulDivMath.mulDivFloor(deltaScaleY, liquid.liquidity, TwoPower.pow128);
        liquid.lastFeeScaleX_128 = lastFeeScaleX_128;
        liquid.lastFeeScaleY_128 = lastFeeScaleY_128;
        liquid.liquidity = newLiquidity;
    }

    /// @notice Add liquidity to a existing nft.
    /// @param addLiquidityParam see AddLiquidityParam for more
    /// @return liquidityDelta amount of added liquidity
    /// @return amountX amount of tokenX deposited
    /// @return amountY amonut of tokenY deposited
    function addLiquidity(
        AddLiquidityParam calldata addLiquidityParam
    ) external payable checkAuth(addLiquidityParam.lid) checkDeadline(addLiquidityParam.deadline) returns (
        uint128 liquidityDelta,
        uint256 amountX,
        uint256 amountY
    ) {
        require(addLiquidityParam.lid < liquidityNum, "LN");
        Liquidity storage liquid = liquidities[addLiquidityParam.lid];
        PoolMeta memory poolMeta = poolMetas[liquid.poolId];
        int24 currPt;
        uint160 sqrtPrice_96;
        address pool = IBiswapFactoryV3(factory).pool(poolMeta.tokenX, poolMeta.tokenY, poolMeta.fee);
        // uint160 sqrtRate_96 = IBiswapPoolV3(pool).sqrtRate_96();
        require(pool != address(0), "P0");
        (sqrtPrice_96, currPt) = getPoolPrice(pool);
        liquidityDelta = MintMath.computeLiquidity(
            MintMath.MintMathParam({
                pl: liquid.leftPt,
                pr: liquid.rightPt,
                xLim: addLiquidityParam.xLim,
                yLim: addLiquidityParam.yLim
            }),
            currPt,
            sqrtPrice_96,
            // sqrtRate_96
            IBiswapPoolV3(pool).sqrtRate_96()
        );
        require(int128(liquid.liquidity) == int256(uint256(liquid.liquidity)), "LO");
        uint128 newLiquidity = liquidityDelta + liquid.liquidity;
        (amountX, amountY) = IBiswapPoolV3(pool).mint(address(this), liquid.leftPt, liquid.rightPt, liquidityDelta,
            abi.encode(MintCallbackData({tokenX: poolMeta.tokenX, tokenY: poolMeta.tokenY, fee: poolMeta.fee, payer: msg.sender})));
        require(amountX >= addLiquidityParam.amountXMin, "XMIN");
        require(amountY >= addLiquidityParam.amountYMin, "YMIN");
        updateLiquidity(liquid, pool, newLiquidity, 0, 0);
        emit AddLiquidity(addLiquidityParam.lid, pool, liquidityDelta, amountX, amountY);
    }

    /// @notice Decrease liquidity from a nft.
    /// @param lid id of nft
    /// @param liquidDelta amount of liqudity to decrease
    /// @param amountXMin min amount of tokenX user want to withdraw
    /// @param amountYMin min amount of tokenY user want to withdraw
    /// @param deadline deadline timestamp of transaction
    /// @return amountX amount of tokenX refund to user
    /// @return amountY amount of tokenY refund to user
    function decLiquidity(
        uint256 lid,
        uint128 liquidDelta,
        uint256 amountXMin,
        uint256 amountYMin,
        uint256 deadline
    ) external checkAuth(lid) checkDeadline(deadline) returns (
        uint256 amountX,
        uint256 amountY
    ) {
        require(lid < liquidityNum, "LN");
        Liquidity storage liquidity = liquidities[lid];
        if (liquidity.liquidity == 0) {
            // no need to call core to update fee
            return (0, 0);
        }
        if (liquidDelta > liquidity.liquidity) {
            liquidDelta = liquidity.liquidity;
        }
        PoolMeta memory poolMeta = poolMetas[liquidity.poolId];
        address pool = IBiswapFactoryV3(factory).pool(poolMeta.tokenX, poolMeta.tokenY, poolMeta.fee);
        require(pool != address(0), "P0");

        uint128 newLiquidity = liquidity.liquidity - liquidDelta;
        (amountX, amountY) = IBiswapPoolV3(pool).burn(liquidity.leftPt, liquidity.rightPt, liquidDelta);
        require(amountX >= amountXMin, "XMIN");
        require(amountY >= amountYMin, "YMIN");
        updateLiquidity(liquidity, pool, newLiquidity, amountX, amountY);
        emit DecLiquidity(lid, pool, liquidDelta, amountX, amountY);
    }

    /// @notice Collect fee gained of token withdrawed from nft.
    /// @param recipient address to receive token
    /// @param lid id of nft
    /// @param amountXLim amount limit of tokenX to collect
    /// @param amountYLim amount limit of tokenY to collect
    /// @return amountX amount of tokenX actually collect
    /// @return amountY amount of tokenY actually collect
    function collect(
        address recipient,
        uint256 lid,
        uint128 amountXLim,
        uint128 amountYLim
    ) external payable checkAuth(lid) returns (
        uint256 amountX,
        uint256 amountY
    ) {
        if (recipient == address(0)) {
            recipient = address(this);
        }
        require(lid < liquidityNum, "LN");
        Liquidity storage liquidity = liquidities[lid];
        PoolMeta memory poolMeta = poolMetas[liquidity.poolId];
        address pool = IBiswapFactoryV3(factory).pool(poolMeta.tokenX, poolMeta.tokenY, poolMeta.fee);
        require(pool != address(0), "P0");
        if (liquidity.liquidity > 0) {
            IBiswapPoolV3(pool).burn(liquidity.leftPt, liquidity.rightPt, 0);
            updateLiquidity(liquidity, pool, liquidity.liquidity, 0, 0);
        }
        if (amountXLim > liquidity.remainTokenX) {
            amountXLim = uint128(liquidity.remainTokenX);
        }
        if (amountYLim > liquidity.remainTokenY) {
            amountYLim = uint128(liquidity.remainTokenY);
        }
        (amountX, amountY) = IBiswapPoolV3(pool).collect(recipient, liquidity.leftPt, liquidity.rightPt, amountXLim, amountYLim);
        // amountX(Y)Lim may be a little greater than actual value
        liquidity.remainTokenX -= amountXLim;
        liquidity.remainTokenY -= amountYLim;
    }

}