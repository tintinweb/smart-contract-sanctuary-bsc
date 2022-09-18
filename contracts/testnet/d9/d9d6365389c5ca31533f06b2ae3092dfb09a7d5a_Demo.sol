// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/ERC721.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/IERC721.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/IERC721Receiver.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/extensions/ERC721Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "../../../utils/Context.sol";

/**
 * @title ERC721 Burnable Token
 * @dev ERC721 Token that can be irreversibly burned (destroyed).
 */
abstract contract ERC721Burnable is Context, ERC721 {
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/extensions/IERC721Metadata.sol)

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
// OpenZeppelin Contracts v4.4.0 (utils/Address.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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
// OpenZeppelin Contracts v4.4.0 (utils/Strings.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/introspection/ERC165.sol)

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
// OpenZeppelin Contracts v4.4.0 (utils/introspection/IERC165.sol)

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

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#* 
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=: 
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%* 
 *
 * @title: IDeveloper.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Interface for onlyDev() role
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IDeveloper is IERC165 {


  // @dev: Classic "EIP-173" but for onlyDev()
  // @return: Developer of contract
  function developer()
    external
    view
    returns (address);

  // @dev: This renounces your role as onlyDev()
  function renounceDeveloper()
    external;

  // @dev: Classic "EIP-173" but for onlyDev()
  // @param newDeveloper: addres of new pending Developer role
  function transferDeveloper(
    address newDeveloper
  ) external;
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: IDeveloperV2.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Interface V2 for onlyDev() role, suggested by Auditors...
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./IDeveloper.sol";

interface IDeveloperV2 is IDeveloper {

  // @dev: This accepts the push-pull method of onlyDev()
  function acceptDeveloper()
    external;

  // @dev: This declines the push-pull method of onlyDev()
  function declineDeveloper()
    external;

  // @dev: This starts the push-pull method of onlyDev()
  // @param newDeveloper: addres of new pending developer role
  function pushDeveloper(
    address newDeveloper
  ) external;
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#* 
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=: 
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%* 
 *
 * @title: IOwner.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Interface for onlyOwner() role
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IOwner is IERC165 {

  // @dev: Classic "EIP-173" getter for owner()
  // @return: owner of contract
  function owner()
    external
    view
    returns (address);

  // @dev: This is the classic "EIP-173" method of setting onlyOwner()  
  function renounceOwnership()
    external;


  // @dev: This is the classic "EIP-173" method of setting onlyOwner()
  // @param newOwner: addres of new pending owner role
  function transferOwnership(
    address newOwner
  ) external;
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: IOwnerV2.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Interface V2 for onlyOwner() role, suggested by Auditors...
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./IOwner.sol";

interface IOwnerV2 is IOwner {

  // @dev: This accepts the push-pull method of onlyOwner()
  function acceptOwnership()
    external;

  // @dev: This declines the push-pull method of onlyOwner()
  function declineOwnership()
    external;

  // @dev: This starts the push-pull method of onlyOwner()
  // @param newOwner: addres of new pending owner role
  function pushOwnership(
    address newOwner
  ) external;
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: IRole.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Interface for MaxAccess version of roles
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IRole is IERC165 {

  // @dev: Returns `true` if `account` has been granted `role`.
  // @param role: Bytes4 of a role
  // @param account: Address to check
  // @return: bool true/false if account has role
  function hasRole(
    bytes4 role
  , address account
  ) external
    view
    returns (bool);

  // @dev: Returns the admin role that controls a role
  // @param role: Role to check
  // @return: admin role
  function getRoleAdmin(
    bytes4 role
  ) external
    view 
    returns (bytes4);

  // @dev: Grants `role` to `account`
  // @param role: Bytes4 of a role
  // @param account: account to give role to
  function grantRole(
    bytes4 role
  , address account
  ) external;

  // @dev: Revokes `role` from `account`
  // @param role: Bytes4 of a role
  // @param account: account to revoke role from
  function revokeRole(
    bytes4 role
  , address account
  ) external;

  // @dev: Renounces `role` from `account`
  // @param role: Bytes4 of a role
  // @param account: account to renounce role from
  function renounceRole(
    bytes4 role
  ) external;
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: MaxAccess.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Access control based off EIP 173/roles from OZ
 * @custom:error-code MA:E1 you are not admin or role
 * @custom:error-code MA:E2 pending developers can not use
 * @custom:error-code MA:E3 pending owners can not use
 * @custom:error-code MA:E4 you are not onlyDev()
 * @custom:error-code MA:E5 you are not onlyOwner()
 * @custom:change-log added custom errors above
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./IOwnerV2.sol";
import "./IDeveloperV2.sol";
import "./IRole.sol";
import "../lib/Roles.sol";
import "../errors/MaxErrors.sol";

abstract contract MaxAccess is MaxErrors
                             , IRole
                             , IOwnerV2
                             , IDeveloperV2 {

  using Roles for Roles.Role;

  Roles.Role private contractRoles;

  // bytes4 caluclated as follows
  // bytes4(keccak256(bytes(signature)))
  // developer() => 0xca4b208b
  // owner() => 0x8da5cb5b
  // admin() => 0xf851a440
  // was using trailing () for caluclations

  bytes4 constant private DEVS = 0xca4b208b;
  bytes4 constant private PENDING_DEVS = 0xca4b208a; // DEVS - 1
  bytes4 constant private OWNERS = 0x8da5cb5b;
  bytes4 constant private PENDING_OWNERS = 0x8da5cb5a; // OWNERS - 1
  bytes4 constant private ADMIN = 0xf851a440;

  // @dev you can sub your own address here... this is MaxFlowO2.eth
  // these are for displays anyways, and init().
  address private TheDev = address(0x4CE69fd760AD0c07490178f9a47863Dc0358cCCD);
  address private TheOwner = address(0x5ccf599B7d43Bc3F576EA01EC0aA307ecbc94102);

  constructor() {
    // supercedes all the logic below
    contractRoles.add(ADMIN, address(this));
    _grantRole(ADMIN, TheDev);
    _grantRole(OWNERS, TheOwner);
    _grantRole(DEVS, TheDev);
  }

  // modifiers
  modifier onlyRole(bytes4 role) {
    if (_checkRole(role, msg.sender) || _checkRole(ADMIN, msg.sender)) {
      _;
    } else {
      revert MaxSplaining({
        reason: "MA:E1"
      });
    }
  }

  modifier onlyDev() {
    if (!_checkRole(DEVS, msg.sender)) {
      revert MaxSplaining({
        reason: "MA:E4"
      });
    }
    _;
  }

  modifier onlyOwner() {
    if (!_checkRole(OWNERS, msg.sender)) {
      revert MaxSplaining({
        reason: "MA:E5"
      });
    }
    _;
  }

  // internal logic first 
  // (sets the tone later, and for later contracts)

  // @dev: this is the bool for checking if the account has a role via lib roles.sol
  // @param role: bytes4 of the role to check for
  // @param account: address of account to check
  // @return: bool true/false
  function _checkRole(
    bytes4 role
  , address account
  ) internal
    view
    virtual
    returns (bool) {
    return contractRoles.has(role, account);
  }

  // @dev: this is the internal to grant roles
  // @param role: bytes4 of the role
  // @param account: address of account to add
  function _grantRole(
    bytes4 role
  , address account
  ) internal
    virtual {
    contractRoles.add(role, account);
  }

  // @dev: this is the internal to revoke roles
  // @param role: bytes4 of the role
  // @param account: address of account to remove
  function _revokeRole(
    bytes4 role
  , address account
  ) internal
    virtual {
    contractRoles.remove(role, account);
  }

  // @dev: Returns `true` if `account` has been granted `role`.
  // @param role: Bytes4 of a role
  // @param account: Address to check
  // @return: bool true/false if account has role
  function hasRole(
    bytes4 role
  , address account
  ) external
    view
    virtual
    override
    returns (bool) {
    return _checkRole(role, account);
  }

  // @dev: Returns the admin role that controls a role
  // @param role: Role to check
  // @return: admin role
  function getRoleAdmin(
    bytes4 role
  ) external
    view
    virtual
    override
    returns (bytes4) {
    return ADMIN;
  }

  // @dev: Grants `role` to `account`
  // @param role: Bytes4 of a role
  // @param account: account to give role to
  function grantRole(
    bytes4 role
  , address account
  ) external
    virtual
    override 
    onlyRole(role) {

    if (role == PENDING_DEVS) {
      // locks out pending devs from mass swapping roles
      if (_checkRole(PENDING_DEVS, msg.sender)) {
        revert MaxSplaining({
          reason: "MA:E2"
        });
      }
    }

    if (role == PENDING_OWNERS) {
      // locks out pending owners from mass swapping roles
      if (_checkRole(PENDING_OWNERS, msg.sender)) {
        revert MaxSplaining({
          reason: "MA:E3"
        });
      }
    }

    _grantRole(role, account);
  }

  // @dev: Revokes `role` from `account`
  // @param role: Bytes4 of a role
  // @param account: account to revoke role from
  function revokeRole(
    bytes4 role
  , address account
  ) external
    virtual
    override
    onlyRole(role) {

    if (role == PENDING_DEVS) {
      // locks out pending devs from mass swapping roles
      if (account != msg.sender) {
        revert MaxSplaining({
          reason: "MA:E2"
        });
      }
    }

    if (role == PENDING_OWNERS) {
      // locks out pending owners from mass swapping roles
      if (account != msg.sender) {
        revert MaxSplaining({
          reason: "MA:E3"
        });
      }
    }
    _revokeRole(role, account);
  }

  // @dev: Renounces `role` from `account`
  // @param role: Bytes4 of a role
  // @param account: account to renounce role from
  function renounceRole(
    bytes4 role
  ) external
    virtual
    override 
    onlyRole(role) {
    address user = msg.sender;
    _revokeRole(role, user);
  }

  // Now the classic onlyDev() + "V2" suggested by auditors

  // @dev: Classic "EIP-173" but for onlyDev()
  // @return: Developer of contract
  function developer()
    external
    view
    virtual
    override
    returns (address) {
    return TheDev;
  }

  // @dev: This renounces your role as onlyDev()
  function renounceDeveloper()
    external
    virtual
    override 
    onlyRole(DEVS) {
    address user = msg.sender;
    _revokeRole(DEVS, user);
  }

  // @dev: Classic "EIP-173" but for onlyDev()
  // @param newDeveloper: addres of new pending Developer role
  function transferDeveloper(
    address newDeveloper
  ) external
    virtual
    override 
    onlyRole(DEVS) {
    address user = msg.sender;
    _grantRole(DEVS, newDeveloper);
    _revokeRole(DEVS, user);
  }

  // @dev: This accepts the push-pull method of onlyDev()
  function acceptDeveloper()
    external
    virtual
    override 
    onlyRole(PENDING_DEVS) {
    address user = msg.sender;
    _revokeRole(PENDING_DEVS, user);
    _grantRole(DEVS, user);
  }

  // @dev: This declines the push-pull method of onlyDev()
  function declineDeveloper()
    external
    virtual
    override 
    onlyRole(PENDING_DEVS) {
    address user = msg.sender;
    _revokeRole(PENDING_DEVS, user);
  }

  // @dev: This starts the push-pull method of onlyDev()
  // @param newDeveloper: addres of new pending developer role
  function pushDeveloper(
    address newDeveloper
  ) external
    virtual
    override
    onlyRole(DEVS) {
    _grantRole(PENDING_DEVS, newDeveloper);
  }

  // @dev: This changes the display of developer()
  // @param newDisplay: new display addrss for developer()
  function setDeveloper(
    address newDisplay
  ) external
    onlyDev() {
    if (!_checkRole(DEVS, newDisplay)) {
        revert MaxSplaining({
          reason: "MA:E4"
        });
    }
    TheDev = newDisplay;
  }

  // Now the classic onlyOwner() + "V2" suggested by auditors

  // @dev: Classic "EIP-173" getter for owner()
  // @return: owner of contract
  function owner()
    external
    view
    virtual
    override
    returns (address) {
    return TheOwner;
  }

   // @dev: This renounces your role as onlyOwner()
  function renounceOwnership()
    external
    virtual
    override
    onlyRole(OWNERS) {
    address user = msg.sender;
    _revokeRole(OWNERS, user);
  }

  // @dev: Classic "EIP-173" but for onlyOwner()
  // @param newOwner: addres of new pending Developer role
  function transferOwnership(
    address newOwner
  ) external
    virtual
    override
    onlyRole(OWNERS) {
    address user = msg.sender;
    _grantRole(OWNERS, newOwner);
    _revokeRole(OWNERS, user);
  }

  // @dev: This accepts the push-pull method of onlyOwner()
  function acceptOwnership()
    external
    virtual
    override
    onlyRole(PENDING_OWNERS) {
    address user = msg.sender;
    _revokeRole(PENDING_OWNERS, user);
    _grantRole(OWNERS, user);
  }

  // @dev: This declines the push-pull method of onlyOwner()
  function declineOwnership()
    external
    virtual
    override
    onlyRole(PENDING_OWNERS) {
    address user = msg.sender;
    _revokeRole(PENDING_OWNERS, user);
  }

  // @dev: This starts the push-pull method of onlyOwner()
  // @param newOwner: addres of new pending developer role
  function pushOwnership(
    address newOwner
  ) external
    virtual
    override
    onlyRole(OWNERS) {
    _grantRole(PENDING_OWNERS, newOwner);
  }

  // @dev: This changes the display of Ownership()
  // @param newDisplay: new display addrss for Ownership()
  function setOwner(
    address newDisplay
  ) external
    onlyOwner() {
    if (!_checkRole(OWNERS, newDisplay)) {
        revert MaxSplaining({
          reason: "MA:E5"
        });
    }
    TheOwner = newDisplay;
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: Batch Transfers For Non-Fungible Tokens
 * @author: Nick Mudge [email protected]
 * @notice: Adds batch transfer functions for ERC721 non-fungible tokens.
 * @custom: Change log added ERC165 into this, added event TransferBatch and changed to Apache2.0
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

///  Note: the ERC-165 identifier for this interface is 0x2b89bcaa

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface EIP1412 is IERC165 {

  // @notice this is the event emitted for batch transfer
  // @param operator - msg.sender
  // @param from - address from
  // @param to - addres sent to
  // @param ids - list/array of token id's that transferred
  event TransferBatch(
    address indexed operator,
    address indexed from,
    address indexed to,
    uint256[] ids
  );

  // @notice Transfers the ownership of multiple NFTs from one address to another address
  // @param _from The current owner of the NFT
  // @param _to The new owner
  // @param _tokenIds The NFTs to transfer
  // @param _data Additional data with no specified format, sent in call to `_to`  
  function safeBatchTransferFrom(
    address _from
  , address _to
  , uint256[] memory _tokenIds
  , bytes memory _data
  ) external;
  
  // @notice Transfers the ownership of multiple NFTs from one address to another address
  // @param _from The current owner of the NFT
  // @param _to The new owner
  // @param _tokenIds The NFTs to transfer  
  function safeBatchTransferFrom(
    address _from
  , address _to
  , uint256[] memory _tokenIds
  ) external;

}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: ERC721BatchTransfer.sol
 * @author: @MaxFlowO2 on bird app/GitHub
 * @notice: Provides a batch transfer capability that can be added to ERC 721 via EIP 1412 (V2).
 * @custom:error-code ERC721BT:E1 to.length tokenId.length mismatch
 * @custom:change-log added custom errors above
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./EIP1412.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

abstract contract ERC1412 is EIP1412
                           , ERC721
                           , ERC721Burnable {

  constructor(
    string memory _name
  , string memory _ticker
  ) ERC721(_name, _ticker) {}

  function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory tokenIds
  ) public
    virtual
    override {
    safeBatchTransferFrom(from, to, tokenIds, "");
  }

  function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory tokenIds,
    bytes memory _data
  ) public
    virtual
    override {
    uint len = tokenIds.length;
    for(uint x = 0; x < len;) {
      _safeTransfer(from, to, tokenIds[x], _data);
      unchecked { ++x; }
    }
    emit TransferBatch(msg.sender, from, to, tokenIds);
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: ERC2981Collection.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Use case for EIP 2981, steered more towards NFT Collections as a whole
 * @custom:error-code ERC2981:E1 permille out of bounds
 * @custom:change-log added custom error code
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./IMAX2981.sol";
import "../../access/MaxAccess.sol";

abstract contract ERC2981 is MaxAccess
                           , IMAX2981 {

  address internal royaltyAddress;
  uint16 internal royaltyPermille;

  event royalatiesSet(
          uint16 value
        , address recipient
        );

  // the internals to do logic flows later

  // @dev to set roaylties on contract via EIP 2981
  // @param _receiver, address of recipient
  // @param _permille, permille xx.x -> xxx value
  function _setRoyalties(
    address _receiver
  , uint16 _permille
  ) internal {
  if (_permille >= 1000 || _permille == 0) {
    revert MaxSplaining({
      reason: "ERC2981:E1"
    });
  }
    royaltyAddress = _receiver;
    royaltyPermille = _permille;
    emit royalatiesSet(royaltyPermille, royaltyAddress);
  }

  // @dev to remove royalties from contract
  function _removeRoyalties()
    internal {
    delete royaltyAddress;
    delete royaltyPermille;
    emit royalatiesSet(royaltyPermille, royaltyAddress);
  }

  // Logic for this contract (abstract)

  // @notice: This sets the contract as royalty reciever (useful with abstract PaymentSplitter)
  // @param permille: Percentage you want so 3.5% -> 35
  function setRoyaltiesThis(
    uint16 permille
  ) external
    virtual
    override
    onlyOwner() {
    _setRoyalties(address(this), permille);
  }

  // @notice: This sets royalties per EIP-2981
  // @param newAddress: Sets the address for royalties
  // @param permille: Percentage you want so 3.5% -> 35
  function setRoyalties(
    address newAddress
  , uint16 permille
  ) external
    virtual
    override
    onlyOwner() {
    _setRoyalties(newAddress, permille);
  }

  // @notice: Clears EIP2981 royalties
  function clearRoyalties()
    external
    virtual
    override
    onlyOwner() {
    _removeRoyalties();
  }

  // @dev Override for royaltyInfo(uint256, uint256)
  // @param _tokenId, uint of token ID to be checked
  // @param _salePrice, uint of amount of sale
  // @return receiver, address of recipient
  // @return royaltyAmount, amount royalties recieved
  function royaltyInfo(
    uint256 _tokenId
  , uint256 _salePrice
  ) external
    view
    virtual
    override
    returns (
    address receiver
  , uint256 royaltyAmount
  ) {
    receiver = royaltyAddress;
    royaltyAmount = _salePrice * royaltyPermille / 1000;
  }
}

/***
 *    ███████╗██╗██████╗       ██████╗  █████╗  █████╗  ██╗
 *    ██╔════╝██║██╔══██╗      ╚════██╗██╔══██╗██╔══██╗███║
 *    █████╗  ██║██████╔╝█████╗ █████╔╝╚██████║╚█████╔╝╚██║
 *    ██╔══╝  ██║██╔═══╝ ╚════╝██╔═══╝  ╚═══██║██╔══██╗ ██║
 *    ███████╗██║██║           ███████╗ █████╔╝╚█████╔╝ ██║
 *    ╚══════╝╚═╝╚═╝           ╚══════╝ ╚════╝  ╚════╝  ╚═╝                                                        
 * Zach Burks, James Morgan, Blaine Malone, James Seibel,
 * "EIP-2981: NFT Royalty Standard,"
 * Ethereum Improvement Proposals, no. 2981, September 2020. [Online serial].
 * Available: https://eips.ethereum.org/EIPS/eip-2981.
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

///
/// @dev Interface for the NFT Royalty Standard
///

interface IERC2981 is IERC165 {

  // @notice Called with the sale price to determine how much royalty
  //  is owed and to whom.
  // @param _tokenId - the NFT asset queried for royalty information
  // @param _salePrice - the sale price of the NFT asset specified by _tokenId
  // @return receiver - address of who should be sent the royalty payment
  // @return royaltyAmount - the royalty payment amount for _salePrice
  function royaltyInfo(
    uint256 _tokenId
  , uint256 _salePrice
  ) external
    view
    returns (
    address receiver
  , uint256 royaltyAmount
  );
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: IMAX2981.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: IERC2981 Extension
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/


pragma solidity >=0.8.0 <0.9.0;

import "./IERC2981.sol";

interface IMAX2981 is IERC2981 {

  // @notice: This sets the contract as royalty reciever (useful with abstract PaymentSplitter)
  // @param permille: Percentage you want so 3.5% -> 35
  function setRoyaltiesThis(
    uint16 permille
  ) external;

  // @notice: This sets royalties per EIP-2981
  // @param newAddress: Sets the address for royalties
  // @param permille: Percentage you want so 3.5% -> 35
  function setRoyalties(
    address newAddress
  , uint16 permille
  ) external;

  // @notice: This clears all EIP-2981 royalties (address(0) and 0%)
  function clearRoyalties()
    external;

}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: Redacted
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: ERC-721/1412/2981 compliant contract set with burn()
 * @custom:change-log addred quant limit of 5 to logic
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./eip/1412/ERC1412.sol";
import "./eip/2981/ERC2981Collection.sol";
import "./modules/timecop/TimeCop.sol";
import "./modules/splitter/PaymentSplitterV2.sol";
import "./modules/llamas/Llamas.sol";
import "./modules/whitelist/WhitelistV3.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Demo is TimeCop
               , ERC2981
               , PaymentSplitterV2
               , Llamas
               , ERC1412
               , WhitelistV3
               , ReentrancyGuard {

  using Strings for uint256;

  string base;

  event UpdatedBaseURI(string _old, string _new);
  event ThankYou(address user, uint amount);

  constructor() ERC1412("NFT Demo", "ERC721") {}



  function presaleMint(
    uint quant
  ) external
    notPaused()
    onlyPresale()
    nonReentrant() {
    for (uint x = 0; x < quant;) {
      _safeMint(msg.sender, _nextUp());
      _oneRegularMint();
      _oneWLMint(msg.sender);
      unchecked { ++x; }
    }
  }

  function publicMint(
    uint quant
  ) external
    payable
    notPaused()
    onlySale()
    paidMint(quant)
    nonReentrant() {
    if (quant > 5) {
      revert MaxSplaining ({
        reason: "Main:E1"
      });
    }
    for (uint x = 0; x < quant;) {
      _safeMint(msg.sender, _nextUp());
      _oneRegularMint();
      unchecked { ++x; }
    }
  }

/*
  function teamMint()
    external
    onlyDev() {
    uint quant = this.minterTeamMintsRemaining();
    for (uint x = 0; x < quant;) {
      // mint it
      _safeMint(this.owner(), _nextUp());
      _oneTeamMint();
      unchecked { ++x; }
    }
  }
*/
  function donate()
    external
    payable {
    // thank you
    emit ThankYou(msg.sender, msg.value);
  }

  // @notice: Function to receive ether, msg.data must be empty
  receive()
    external
    payable {
    // From PaymentSplitter.sol
    emit PaymentReceived(msg.sender, msg.value);
  }

  // @notice: Function to receive ether, msg.data is not empty
  fallback()
    external
    payable {
    // From PaymentSplitter.sol
    emit PaymentReceived(msg.sender, msg.value);
  }

  // @notice this is a public getter for ETH blance on contract
  function getBalance()
    external
    view
    returns (uint) {
    return address(this).balance;
  }

  // @notice will update _baseURI() by onlyDeveloper() role
  // @param _base: Base for NFT's
  function setBaseURI(
    string memory _base
    )
    public
    onlyDev() {
    string memory old = base;
    base = _base;
    emit UpdatedBaseURI(old, base);
  }

  // @notice: This override sets _base as the string for tokenURI(tokenId)
  function _baseURI()
    internal
    view
    override
    returns (string memory) {
    return base;
  }

  // @notice: This override is for making string/number now string/number.json
  // @param tokenId: tokenId to pull URI for
  function tokenURI(
    uint256 tokenId
  ) public
    view
    virtual
    override (ERC721)
    returns (string memory) {
    if (!_exists(tokenId)) {
      revert MaxSplaining({
        reason: string(
                  abi.encodePacked(
                    "ERC721Metadata: URI query for ",
                    Strings.toString(tokenId),
                    " returns nonexistent token"
                  )
                )
      });
    }
    string memory baseURI = _baseURI();
    string memory json = ".json";
    return bytes(baseURI).length > 0 ? string(
                                         abi.encodePacked(
                                           baseURI
                                         , tokenId.toString()
                                         , json)
                                       ) : "";
  }

  // @notice: This override is to correct totalSupply()
  // @param tokenId: tokenId to burn
  function burn(
    uint256 tokenId
  ) public
    virtual
    override(ERC721Burnable) {
    //solhint-disable-next-line max-line-length
    if (!_isApprovedOrOwner(_msgSender(), tokenId)) {
      revert MaxSplaining({
        reason: string(
                  abi.encodePacked(
                    "ERC721Burnable: ",
                    Strings.toHexString(uint160(msg.sender), 20),
                    " is not owner nor approved"
                  )
                )
      });
    }
    _burn(tokenId);
    // fixes totalSupply()
    _subOne();
  }

  // @notice: Standard override for ERC165
  // @param interfaceId: interfaceId to check for compliance
  // @return: bool if interfaceId is supported
  function supportsInterface(
    bytes4 interfaceId
  ) public
    view
    virtual
    override (
      ERC721
    , IERC165
    ) returns (bool) {
    return (
      interfaceId == type(IERC2981).interfaceId  ||
      interfaceId == type(EIP1412).interfaceId  ||
      super.supportsInterface(interfaceId)
    );
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: MaxErrors.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Custom errors for all contracts, minus libraries
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;


import "@openzeppelin/contracts/utils/Strings.sol";

abstract contract MaxErrors {

  // @dev: this is Unauthorized(), basically a catch all, zero description
  // @notice: 0x82b42900 bytes4 of this
  error Unauthorized();

  // @dev: this is MaxSplaining(), giving you a reason, aka require(param, "reason")
  // @param reason: Use the "Contract name: error"
  // @notice: 0x0661b792 bytes4 of this
  error MaxSplaining(
    string reason
  );

  // @dev: this is TooSoonJunior(), using times
  // @param yourTime: should almost always be block.timestamp
  // @param hitTime: the time you should have started
  // @notice: 0xf3f82ac5 bytes4 of this
  error TooSoonJunior(
    uint yourTime
  , uint hitTime
  );

  // @dev: this is TooLateBoomer(), using times
  // @param yourTime: should almost always be block.timestamp
  // @param hitTime: the time you should have ended
  // @notice: 0x43c540ef bytes4 of this
  error TooLateBoomer(
    uint yourTime
  , uint hitTime
  );

}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: CountersV2.sol
 * @author Matt Condon (@shrugs)
           rewritten by Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Provides counters that can only be incremented, decremented, reset or set. 
 * This can be used e.g. to track the number of elements in a mapping, issuing ERC721 ids
 * or counting request ids.
 *
 * Edited by @MaxFlowO2 for more NFT functionality on 13 Jan 2022
 * added .set(uint) so if projects need to start at say 1 or some random number they can
 * and an event log for numbers being reset or set.
 *
 * Include with `using CountersV2 for CountersV2.Counter;`
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

library CountersV2 {

  // @dev: this is MaxSplaining(), giving you a reason, aka require(param, "reason")
  // @param reason: Use the "Contract name: error"
  // @notice: 0x0661b792 bytes4 of this
  error MaxSplaining(
    string reason
  );

  event CounterNumberChangedTo(uint _number);

  struct Counter {
    // This variable should never be directly accessed by users of the library: interactions must be restricted to
    // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
    // this feature: see https://github.com/ethereum/solidity/issues/4637
    uint256 _value; // default: 0
  }

  function current(
    Counter storage counter
  ) internal
    view
    returns (uint256) {
    return counter._value;
  }

  function increment(
    Counter storage counter
  ) internal {
    unchecked {
      ++counter._value;
    }
  }

  function decrement(
    Counter storage counter
  ) internal {
    uint256 value = counter._value;
    if (value == 0) {
      revert MaxSplaining({
        reason : "CountersV2: No negatives in uints"
      });
    }
    unchecked {
      --counter._value;
    }
  }

  function reset(
    Counter storage counter
  ) internal {
    counter._value = 0;
    emit CounterNumberChangedTo(counter._value);
  }

  function set(
    Counter storage counter
  , uint number
  ) internal {
    counter._value = number;
    emit CounterNumberChangedTo(counter._value);
  }  
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: PsuedoRand.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Library for Llama/BAYC Mint engine...
 *  basically a random start point and a bookends mint to start
 *  i.e. 0-2999 start at 500 -> 2999, then 0 -> 499.
 *
 *  Covers IMAX721.sol and Illamas.sol
 *
 * Include with 'using PsuedoRand for PsuedoRand.Engine;'
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./CountersV2.sol";

library PsuedoRand {
  using CountersV2 for CountersV2.Counter;

  event SetProvenanceIMG(string _new, string _old);
  event SetProvenanceJSON(string _new, string _old);
  event SetStartNumber(uint _new);
  event SetMaxCapacity(uint _new, uint _old);
  event SetMaxTeamMint(uint _new, uint _old);
  event SetMintFees(uint _new, uint _old);
  event SetStatus(bool _new);
  event ProvenanceLocked(bool _status);

  // @dev: this is MaxSplaining(), giving you a reason, aka require(param, "reason")
  // @param reason: Use the "Contract name: error"
  // @notice: 0x0661b792 bytes4 of this
  error MaxSplaining(
    string reason
  );

  struct Engine {
    uint256 mintFee;
    uint256 startNumber;
    uint256 maxCapacity;
    uint256 maxTeamMints;
    string ProvenanceIMG;
    string ProvenanceJSON;
    CountersV2.Counter currentMinted;
    CountersV2.Counter currentTeam;
    bool status;
    bool provSet;
  }

  function setProvJSON(
    Engine storage engine
  , string memory provJSON
  ) internal {
    string memory old = engine.ProvenanceJSON;
    engine.ProvenanceJSON = provJSON;
    emit SetProvenanceJSON(provJSON, old);
  }
 
  function setProvIMG(
    Engine storage engine
  , string memory provIMG
  ) internal {
    string memory old = engine.ProvenanceIMG;
    engine.ProvenanceIMG = provIMG;
    emit SetProvenanceIMG(provIMG, old);
  }

  function provLock(
    Engine storage engine
  ) internal {
    engine.provSet = true;
    emit ProvenanceLocked(engine.provSet);
  }

  function setStartNumber(
    Engine storage engine
  ) internal {
    if (engine.maxCapacity == 0) {
      revert MaxSplaining({
        reason : "Lib-Llamas:E1"
      });
    }
    engine.startNumber = uint(
                           keccak256(
                             abi.encodePacked(
                               block.timestamp
                             , msg.sender
                             , engine.ProvenanceIMG
                             , engine.ProvenanceJSON
                             , block.difficulty))) 
                         % engine.maxCapacity;
    emit SetStartNumber(engine.startNumber);
  }

  function setMaxCap(
    Engine storage engine
  , uint256 max
  ) internal {
    uint old = engine.maxCapacity;
    engine.maxCapacity = max;
    emit SetMaxCapacity(max, old);
  }

  function setMaxTeam(
    Engine storage engine
  , uint256 max
  ) internal {
    uint old = engine.maxTeamMints;
    engine.maxTeamMints = max;
    emit SetMaxTeamMint(max, old);
  }

  function setFees(
    Engine storage engine
  , uint256 max
  ) internal {
    uint old = engine.mintFee;
    engine.mintFee = max;
    emit SetMintFees(max, old);
  }

  function setStatus(
    Engine storage engine
  , bool change
  ) internal {
    engine.status = change;
    emit SetStatus(change);
  }

  function mintID(
    Engine storage engine
  ) internal
    view
    returns (uint256) {
    return (engine.startNumber + engine.currentMinted.current()) % engine.maxCapacity;
  }

  function showTeam(
    Engine storage engine
  ) internal 
    view
    returns (uint256) {
    return engine.currentTeam.current();
  }

  function showMinted(
    Engine storage engine
  ) internal
    view
    returns (uint256) {
    return engine.currentMinted.current();
  }

  function battersUpTeam(
    Engine storage engine
  ) internal {
    engine.currentTeam.increment();
  }

  function battersUp(
    Engine storage engine
  ) internal {
    engine.currentMinted.increment();
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: Roles.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Library for MaxAcess.sol
 * @custom:error-code Lib-Roles:E1 User has role already
 * @custom:error-code Lib-Roles:E2 User does not have role to revoke
 * @custom:change-log Custom errors added above
 *
 * Include with 'using Roles for Roles.Role;'
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

library Roles {

  // @dev: this is Unauthorized(), basically a catch all, zero description
  // @notice: 0x82b42900 bytes4 of this
  error Unauthorized();

  // @dev: this is MaxSplaining(), giving you a reason, aka require(param, "reason")
  // @param reason: Use the "Contract name: error"
  // @notice: 0x0661b792 bytes4 of this
  error MaxSplaining(
    string reason
  );

  event RoleChanged(bytes4 _type, address _user, bool _status); // 0x0baaa7ab

  struct Role {
    mapping(address => mapping(bytes4 => bool)) bearer;
  }

  function add(Role storage role, bytes4 _type, address account) internal {
    if (account == address(0)) {
      revert Unauthorized();
    } else if (has(role, _type, account)) {
      revert MaxSplaining({
        reason: "Lib-Roles:E1"
      });
    }
    role.bearer[account][_type] = true;
    emit RoleChanged(_type, account, true);
  }

  function remove(Role storage role, bytes4 _type, address account) internal {
    if (account == address(0)) {
      revert Unauthorized();
    } else if (!has(role, _type, account)) {
      revert MaxSplaining({
        reason: "Lib-Roles:E2"
      });
    }
    role.bearer[account][_type] = false;
    emit RoleChanged(_type, account, false);
  }

  function has(Role storage role, bytes4 _type, address account)
    internal
    view
    returns (bool)
  {
    if (account == address(0)) {
      revert Unauthorized();
    }
    return role.bearer[account][_type];
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: Whitelist.sol
 * @author: @MaxFlowO2 on bird app/GitHub
 * @notice: Provides a whitelist capability that can be added to and removed easily.
 * @custom:error-code Lib-WL:E1 Whitelist already enabled
 * @custom:error-code Lib-WL:E2 Whitelist already disabled
 * @custom:error-code Lib-WL:E3 User already Whitelisted
 * @custom:error-code Lib-WL:E4 User not Whitelisted
 * @custom:change-log Custom errors added above
 *
 * Include with 'using WhitelistV2 for WhitelistV2.List;'
 *
 * This edition is address => uint so you can have a quant per wl address
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./CountersV2.sol";

library WhitelistV2 {
  using CountersV2 for CountersV2.Counter;

  event WhiteListEndChanged(uint _old, uint _new);
  event WhiteListChanged(bool _current, uint _quant, address _address);
  event WhiteListStatus(bool _old, bool _new);

  // @dev: this is MaxSplaining(), giving you a reason, aka require(param, "reason")
  // @param reason: Use the "Contract name: error"
  // @notice: 0x0661b792 bytes4 of this
  error MaxSplaining(
    string reason
  );

  struct List {
    // These variables should never be directly accessed by users of the library: interactions must be restr>
    // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to>
    // this feature: see https://github.com/ethereum/solidity/issues/4637
    bool enabled; //default is false,
    mapping(address => uint) _quant; // all values default to zero
  }

  function wlMint(
    List storage list
  , address _address
  ) internal {
    // Using this a bit
    uint check = list._quant[_address];
    // If zero revert
    if (check == 0) {
      revert  MaxSplaining({
        reason : "Lib-WL:E4"
      });
    }
    // has to be positive, can unckeck the decrement
    unchecked { --check; }
    // now the new wl value
    list._quant[_address] = check;
    // emit event
    emit WhiteListChanged(true, list._quant[_address], _address);
  }

  function add(
    List storage list
  , address _address
  , uint _amount
  ) internal {
    if (list._quant[_address] > 0) {
      revert  MaxSplaining({
        reason : "Lib-WL:E3"
      });
    }
    // since now all previous values are false no need for another variable
    // and add them to the list!
    list._quant[_address] = _amount;
    // emit event
    emit WhiteListChanged(true, list._quant[_address], _address);
  }

  function remove(
    List storage list
  , address _address
  ) internal {
    if (list._quant[_address] == 0) {
      revert  MaxSplaining({
        reason : "Lib-WL:E4"
      });
    }
    // since now all previous values are true no need for another variable
    // and remove them from the list!
    list._quant[_address] = 0;
    // emit event
    emit WhiteListChanged(false, list._quant[_address], _address);
  }

  function enable(
    List storage list
  ) internal {
    if (list.enabled) {
      revert  MaxSplaining({
        reason : "Lib-WL:E1"
      });
    }
    list.enabled = true;
    emit WhiteListStatus(false, list.enabled);
  }

  function disable(
    List storage list
  ) internal {
    if (!list.enabled) {
      revert  MaxSplaining({
        reason : "Lib-WL:E2"
      });
    }
    list.enabled = false;
    emit WhiteListStatus(true, list.enabled);
  }

  function status(
    List storage list
  ) internal
    view
    returns (bool) {
    return list.enabled;
  }

  function onList(
    List storage list
  , address _address
  ) internal
    view
    returns (bool) {
    return list._quant[_address] > 0;
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: ILlamas.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Interface for Llama/BAYC Mint engine, does Provenance for Metadata/Images
 * Source: https://etherscan.io/address/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d#code
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./IMAX721.sol";

interface ILlamas is IMAX721{

  // @dev: will return Provenance hash of images
  // @return: string memory of the Images Hash (sha256)
  function RevealProvenanceImages()
    external
    view
    returns (string memory);

  // @dev: will return Provenance hash of metadata
  // @return: string memory of the Metadata Hash (sha256)
  function RevealProvenanceJSON()
    external
    view
    returns (string memory);

  // @dev: will return starting number for mint
  // @return: uint of the start number
  function RevealStartID()
    external
    view
    returns (uint256);

  // @dev this will set the boolean for minter status
  // @param toggle: bool for enabled or not
  function setStatus(
    bool toggle
  ) external;

  // @dev this will set the minter fees
  // @param number: uint for fees in wei.
  function setMintFees(
    uint number
  ) external;

  // @dev this will set the Provenance Hashes
  // @param string memory img - Provenance Hash of images in sequence
  // @param string memory json - Provenance Hash of metadata in sequence
  // @notice: This will set the start number as well, make sure to set MaxCap
  //  also can be a hyperlink... sha3... ipfs.. whatever.
  function setProvenance(
    string memory img
  , string memory json
  ) external;

  // @dev this will set the mint engine
  // @param mintingCap: uint for publicMint() capacity of this chain
  // @param teamMints: uint for maximum teamMints() capacity on this chain
  function setLlamasEngine(
    uint mintingCap
  , uint teamMints
  ) external;
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: IMAX721.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Interface for UX/UI
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IMAX721 is IERC165 {

  // @dev will return status of Minter
  // @return - bool of active or not
  function minterStatus() 
    external
    view
    returns (bool);

  // @dev will return minting fees
  // @return - uint of mint costs in wei
  function minterFees()
    external
    view
    returns (uint);

  // @dev will return maximum mint capacity
  // @return - uint of maximum mints allowed
  function minterCapacity()
    external
    view
    returns (uint);

  // @dev will return maximum mint capacity
  // @return - uint of maximum mints allowed
  function minterMinted()
    external
    view
    returns (uint);

  // @dev will return maximum "team minting" capacity
  // @return - uint of maximum airdrops or team mints allowed
  function minterTeamMintsCapacity()
    external
    view
    returns (uint);


  // @dev will return "team mints" count
  // @return - uint of airdrops or team mints done
  function minterTeamMintsMinted()
    external
    view
    returns (uint);

  // @dev: will return total supply for mint
  // @return: uint for this mint
  function totalSupply()
    external
    view
    returns (uint256);
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: Llamas.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Solidity from the BAYC Mint engine, does Provenance for Images
 * @custom:OG-Source: https://etherscan.io/address/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d#code
 * @custom:error-code Llamas:E1 msg.value is under quant * fees
 * @custom:error-code Llamas:E2 minter is paused
 * @custom:error-code Llamas:E3 states not loaded
 * @custom:error-code Llamas:E4 provenance is locked
 * @custom:error-code Llamas:E5 can not change provenance while minting
 * @custom:change-log added provenance to metadata
 * @custom:change-log used the modulo division to wrap from start -> last ID -> first ID -> start
 * @custom:change-log bug found, line 61 corrected >= to <
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./ILlamas.sol";
import "../../lib/PsuedoRand.sol";
import "../../lib/CountersV2.sol";
import "../../access/MaxAccess.sol";

abstract contract Llamas is MaxAccess
                          , ILlamas {

  using PsuedoRand for PsuedoRand.Engine;
  using CountersV2 for CountersV2.Counter;

  PsuedoRand.Engine private llamas;
  CountersV2.Counter private tokensBurned;

  event SetStartNumbers(uint numberToMint, uint teamMints);

  modifier paidMint(uint quant) {
    if (msg.value < quant * llamas.mintFee) {
      revert MaxSplaining({
        reason: "Llamas:E1"
      });
    }
    _;
  }

  modifier notPaused() {
    if (!llamas.status) {
      revert MaxSplaining({
        reason: "Llamas:E2"
      });
    }
    _;
  }

  modifier numbersSet() {
    if (llamas.maxCapacity == 0) {
      revert MaxSplaining({
        reason: "Llamas:E3"
      });
    }
    _;
  }

  modifier provenanceLocked() {
    if (llamas.provSet) {
      revert MaxSplaining({
        reason: "Llamas:E4:"
      });
    }
    if (llamas.showMinted() > 0) {
      revert MaxSplaining({
        reason: "Llamas:E5"
      });
    }
    _;
  }

  // @dev this is to substract one to on chain minted
  function _subOne()
    internal {
    tokensBurned.increment();
  }

  // @dev this is for any team mint that happens, must be included in mint...
  function _oneTeamMint()
    internal {
    llamas.battersUp();
    llamas.battersUpTeam();
  }

  // @dev this is for any mint outside of a team mint, must be included in mint...
  function _oneRegularMint()
    internal {
    llamas.battersUp();
  }

  // @dev this will set the boolean for minter status
  // @param toggle: bool for enabled or not
  function _setStatus(
    bool toggle
  ) internal {
    llamas.setStatus(toggle);
  }

  // @dev this will set the minter fees
  // @param number: uint for fees in wei.
  function _setMintFees(
    uint number
  ) internal {
    llamas.setFees(number);
  }

  // @dev this will set the mint engine
  // @param _mintingCap: uint for publicMint() capacity of this chain
  // @param _teamMints: uint for maximum teamMints() capacity on this chain
  function _setLlamasEngine(
    uint _mintingCap
  , uint _teamMints
  ) internal {
    llamas.setMaxCap(_mintingCap);
    llamas.setMaxTeam(_teamMints);

    emit SetStartNumbers(
      _mintingCap
    , _teamMints
    );
  }

  // @dev this will set the Provenance Hashes
  // @param string memory img - Provenance Hash of images in sequence
  // @param string memory json - Provenance Hash of metadata in sequence
  // @notice: This will set the start number as well, make sure to set MaxCap
  //  also can be a hyperlink... sha3... ipfs.. whatever.
  function _setProvenance(
    string memory img
  , string memory json
  ) internal {
    llamas.setProvJSON(json);
    llamas.setProvIMG(img);
    llamas.setStartNumber();
    llamas.provLock();
  }

  // @dev this will be valuable on the mint engine logic contract
  function _nextUp()
    internal
    view
    returns (uint) {
    return llamas.mintID();
  }

  // @dev this will set the boolean for minter status
  // @param toggle: bool for enabled or not
  function setStatus(
    bool toggle
  ) external
    virtual
    override
    onlyDev() {
    _setStatus(toggle);
  }

  // @dev this will set the minter fees
  // @param number: uint for fees in wei.
  function setMintFees(
    uint number
  ) external
    virtual
    override
    onlyDev() {
    _setMintFees(number);
  }

  // @dev this will set the mint engine
  // @param mintingCap: uint for publicMint() capacity of this chain
  // @param teamMints: uint for maximum teamMints() capacity on this chain
  function setLlamasEngine(
    uint mintingCap
  , uint teamMints
  ) external
    virtual
    override
    onlyDev() {
    _setLlamasEngine(
      mintingCap
    , teamMints
    );
  }

  // @dev this will set the Provenance Hashes
  // @param string memory img - Provenance Hash of images in sequence
  // @param string memory json - Provenance Hash of metadata in sequence
  // @notice: This will set the start number as well, make sure to set MaxCap
  //  also can be a hyperlink... sha3... ipfs.. whatever.
  function setProvenance(
    string memory img
  , string memory json
  ) external
    virtual
    override
    numbersSet()
    provenanceLocked()
    onlyDev() {
    _setProvenance(
      img
    , json
    );
  }

  // @dev will return status of Minter
  // @return - bool of active or not
  function minterStatus()
    external
    view
    virtual
    override
    returns (bool) {
    return llamas.status;
  }

  // @dev will return minting fees
  // @return - uint of mint costs in wei
  function minterFees()
    external
    view
    virtual
    override
    returns (uint) {
    return llamas.mintFee;
  }

  // @dev will return maximum mint capacity
  // @return - uint of maximum mints allowed
  function minterCapacity()
    external
    view
    virtual
    override
    returns (uint) {
    return llamas.maxCapacity;
  }

  // @dev will return maximum mint capacity
  // @return - uint of maximum mints allowed
  function minterMinted()
    external
    view
    virtual
    override
    returns (uint) {
    return llamas.showMinted();
  }

  // @dev will return maximum "team minting" capacity
  // @return - uint of maximum airdrops or team mints allowed
  function minterTeamMintsCapacity()
    external
    view
    virtual
    override
    returns (uint) {
    return llamas.maxTeamMints;
  }

  // @dev will return "team mints" count
  // @return - uint of airdrops or team mints done
  function minterTeamMintsMinted()
    external
    view
    virtual
    override
    returns (uint) {
    return llamas.showTeam();
  }

  // @dev: will return total supply for mint
  // @return: uint for this mint
  function totalSupply()
    external
    view
    virtual
    override
    returns (uint256) {
    return llamas.showMinted() - tokensBurned.current();
  }

  // @dev: will return Provenance hash of images
  // @return: string memory of the Images Hash (sha256)
  function RevealProvenanceImages() 
    external 
    view 
    virtual
    override 
    returns (string memory) {
    return llamas.ProvenanceIMG;
  }

  // @dev: will return Provenance hash of metadata
  // @return: string memory of the Metadata Hash (sha256)
  function RevealProvenanceJSON()
    external
    view
    virtual
    override
    returns (string memory) {
    return llamas.ProvenanceJSON;
  }

  // @dev: will return starting number for mint
  // @return: uint of the start number
  function RevealStartID()
    external
    view
    virtual
    override
    returns (uint256) {
    return llamas.startNumber;
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: IPaymentSplitter.sol
 * @author: OG was OZ, rewritten by Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Interface for PaymentSplitter.sol
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IPaymentSplitterV2 is IERC165 {

  // @dev: this claims all "eth" on contract for msg.sender
  function claim()
    external;

  // @dev: This adds a payment split to PaymentSplitterV3.sol
  // @param newSplit: Address of payee
  // @param newShares: Shares to send user
  function addSplit (
    address newSplit
  , uint256 newShares
  ) external;

  // @dev: This pays all payment splits on PaymentSplitterV3.sol
  function paySplits()
    external;

  // @dev: This removes a payment split on PaymentSplitterV3.sol
  // @param remove: Address of payee to remove
  // @notice: use paySplits() prior to use if anything is on the contract
  function removeSplit (
    address remove
  ) external;

  // @dev: This removes all payment splits on PaymentSplitterV3.sol
  // @notice: use paySplits() prior to use if anything is on the contract
  function clearSplits()
    external;

  // @dev: returns total shares
  // @return: uint256 of all shares on contract
  function totalShares()
    external
    view
    returns (uint256);

  // @dev: returns total releases in "eth"
  // @return: uint256 of all "eth" released in wei
  function totalReleased()
    external
    view
    returns (uint256);

  // @dev: returns shares of an address
  // @param account: address of account to return
  // @return: mapping(address => uint) of _shares
  function shares(
    address account
  ) external
    view
    returns (uint256);

  // @dev: returns released "eth" of an account
  // @param account: address of account to look up
  // @return: mapping(address => uint) of _released
  function released(
    address account
  ) external
    view
    returns (uint256);

  // @dev: returns index number of payee
  // @param index: number of index
  // @return: address at _payees[index]
  function payee(
    uint256 index
  ) external
    view
    returns (address);

  // @dev: returns amount of "eth" that can be released to account
  // @param account: address of account to look up
  // @return: uint in wei of "eth" to release
  function releasable(
    address account
  ) external
    view
    returns (uint256);

}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: PaymentSplitterV2.sol
 * @author: rewritten by Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: was once an OZ payment splitter now, a maxflow payment splitter
 * @custom:OG-Source github.com/OpenZeppelin/openzeppelin-contracts/blob/0a87a4e75b02b95ca019d4894dc6e02e69e586f1/contracts/finance/PaymentSplitter.sol
 * @custom:error-code PSV2:E1 No Shares for address
 * @custom:error-code PSV2:E2 No payment due for address
 * @custom:error-code PSV2:E3 Can not use address(0)
 * @custom:error-code PSV2:E4 Shares can not be 0
 * @custom:error-code PSV2:E5 User has shares already
 * @custom:change-log added claim (msg.sender) for payment
 * @custom:change-log removed constructor, release, and ERC20 support
 * @custom:change-log added addPayee(address, uint)
 * @custom:change-log added removePayee(address, uint)
 * @custom:change-log added ERC165 with Interfaces IPaymentSplitter & IPaymentSplitterV2
 * @custom:change-log added custom error-codes above
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./IPaymentSplitterV2.sol";
import "../../access/MaxAccess.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @dev This contract allows to split Ether payments among a group of accounts. The sender does not need to be aware
 * that the Ether will be split in this way, since it is handled transparently by the contract.
 *
 * The split can be in equal parts or in any other arbitrary proportion. The way this is specified is by assigning each
 * account to a number of shares. Of all the Ether that this contract receives, each account will then be able to claim
 * an amount proportional to the percentage of total shares they were assigned. The distribution of shares is set at the
 * time of contract deployment and can't be updated thereafter.
 *
 * `PaymentSplitter` follows a _pull payment_ model. This means that payments are not automatically forwarded to the
 * accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the {release}
 * function.
 */

abstract contract PaymentSplitterV2 is MaxAccess
                                     , IPaymentSplitterV2 {
  uint256 private _totalShares;
  uint256 private _totalReleased;
  mapping(address => uint256) private _shares;
  mapping(address => uint256) private _released;
  address[] private _payees;

  event PayeeAdded(address account, uint256 shares);
  event PayeeRemoved(address account, uint256 shares);
  event PayeesReset();
  event PaymentReleased(address to, uint256 amount);
  event PaymentReceived(address from, uint256 amount);

  /**
   * @dev The Ether received will be logged with {PaymentReceived} events. Note that these events are not fully
   * reliable: it's possible for a contract to receive Ether without triggering this function. This only affects the
   * reliability of the events, and not the actual splitting of Ether.
   *
   * To learn more about this see the Solidity documentation for
   * https://solidity.readthedocs.io/en/latest/contracts.html#fallback-function[fallback
   * functions].
   *
   *  receive() external payable virtual {
   *    emit PaymentReceived(msg.sender, msg.value);
   *  }
   *
   *  // Fallback function is called when msg.data is not empty
   *  // Added to PaymentSplitter.sol
   *  fallback() external payable {
   *    emit PaymentReceived(msg.sender, msg.value);
   *  }
   *
   * receive() and fallback() to be handled at final contract
   */

  // Internals of this contract

  // @dev: returns uint of payment for account in wei
  // @param account: account to lookup
  // @return: eth in wei
  function _pendingPayment(
    address account
  ) internal
    view
    returns (uint256) {
    uint totalReceived = address(this).balance + _totalReleased;
    return (totalReceived * _shares[account]) / _totalShares - _totalReleased;
  }

  // @dev: claims "eth" for user
  // @param user: address of user
  function _claimETH(
    address user
  ) internal {
    if (_shares[user] == 0) {
      revert MaxSplaining({
        reason: "PSV2:E1"
      });
    }

    uint256 payment = _pendingPayment(user);

    if (payment == 0) {
      revert MaxSplaining({
        reason: "PSV2:E2"
      });
    }

    // _totalReleased is the sum of all values in _released.
    // If "_totalReleased += payment" does not overflow,
    // then "_released[account] += payment" cannot overflow.
    _totalReleased += payment;
    unchecked {
      _released[user] += payment;
    }
    Address.sendValue(payable(user), payment);
    emit PaymentReleased(user, payment);
  }


  // @dev: this claims "eth" and ERC20 for all _payees[]
  function _payAll()
    internal {
    uint len = _payees.length;
    for (uint x = 0; x < len;) {
      _claimETH(_payees[x]);
      unchecked {
        ++x;
      }
    }
  }

  // @dev: this will add a payee to PaymentSplitterV3
  // @param account: address of account to add
  // @param shares: uint256 of shares to add to account
  function _addPayee(
    address account
  , uint256 addShares
  ) internal {
    if (account == address(0)) {
      revert MaxSplaining({
        reason: "PSV2:E3"
      });
    } else if (addShares == 0) {
      revert MaxSplaining({
        reason: "PSV2:E4"
      });
    } else if (_shares[account] > 0) {
      revert MaxSplaining({
        reason: "PSV2:E5"
      });
    }

    _payees.push(account);
    _shares[account] = addShares;
    _totalShares = _totalShares + addShares;

    emit PayeeAdded(account, addShares);
  }

  // @dev: finds index of an account in _payees
  // @param account: address of account to find
  // @return index: position of account in address[] _payees
  function _findIndex(
    address account
  ) internal
    view
    returns (uint index) {
    uint len = _payees.length;
    for (uint x = 0; x < len;) {
      if (_payees[x] == account) {
        index = x;
      }
      unchecked {
        ++x;
      }
    }
  }

  // @dev: removes an account in _payees
  // @param account: address of account to remove
  // @notice: will keep payment data in there
  function _removePayee(
    address account
  ) internal {
    if (account == address(0)) {
      revert MaxSplaining({
        reason: "PSV2:E3"
      });
    }

    // This finds the payee in the array _payees and removes it
    uint remove = _findIndex(account);
    address last = _payees[_payees.length - 1];
    _payees[remove] = last;
    _payees.pop();

    uint removeTwo = _shares[account];
    _shares[account] = 0;
    _totalShares = _totalShares - removeTwo;

    emit PayeeRemoved(account, removeTwo);
  }

  // @dev: this clears all shares/users from PaymentSplitterV3
  //       this WILL leave the payments already claimed on contract
  function _clearPayees()
    internal {
    uint len = _payees.length;
    for (uint x = 0; x < len;) {
      address account = _payees[x];
      _shares[account] = 0;
      unchecked {
         ++x;
      }
    }
    delete _totalShares;
    delete _payees;
    emit PayeesReset();
  }

  // Now the externals, listed by use

  // @dev: this claims all "eth" on contract for msg.sender
  function claim()
    external
    virtual
    override {
    _claimETH(msg.sender);
  }

  // @dev: This adds a payment split to PaymentSplitterV3.sol
  // @param newSplit: Address of payee
  // @param newShares: Shares to send user
  function addSplit (
    address newSplit
  , uint256 newShares
  ) external
    virtual
    override
    onlyDev() {
    _addPayee(newSplit, newShares);
  }

  // @dev: This pays all payment splits on PaymentSplitterV3.sol
  function paySplits()
    external
    virtual
    override
    onlyDev() {
    _payAll();
  }

  // @dev: This removes a payment split on PaymentSplitterV3.sol
  // @param remove: Address of payee to remove
  // @notice: use paySplits() prior to use if anything is on the contract
  function removeSplit (
    address remove
  ) external
    virtual
    override
    onlyDev() {
    _removePayee(remove);
  }

  // @dev: This removes all payment splits on PaymentSplitterV3.sol
  // @notice: use paySplits() prior to use if anything is on the contract
  function clearSplits()
    external
    virtual
    override
    onlyDev() {
    _clearPayees();
  }

  // @dev: returns total shares
  // @return: uint256 of all shares on contract
  function totalShares()
    external
    view
    virtual
    override
    returns (uint256) {
    return _totalShares;
  }

  // @dev: returns total releases in "eth"
  // @return: uint256 of all "eth" released in wei
  function totalReleased()
    external
    view
    virtual
    override
    returns (uint256) {
    return _totalReleased;
  }

  // @dev: returns shares of an address
  // @param account: address of account to return
  // @return: mapping(address => uint) of _shares
  function shares(
    address account
  ) external
    view
    virtual
    override
    returns (uint256) {
    return _shares[account];
  }

  // @dev: returns released "eth" of an account
  // @param account: address of account to look up
  // @return: mapping(address => uint) of _released
  function released(
    address account
  ) external
    view
    virtual
    override
    returns (uint256) {
    return _released[account];
  }

  // @dev: returns index number of payee
  // @param index: number of index
  // @return: address at _payees[index]
  function payee(
    uint256 index
  ) external
    view
    virtual
    override
    returns (address) {
    return _payees[index];
  }

  // @dev: returns amount of "eth" that can be released to account
  // @param account: address of account to look up
  // @return: uint in wei of "eth" to release
  function releasable(
    address account
  ) external
    view
    virtual
    override
    returns (uint256) {
    return _pendingPayment(account);
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: ITimeCop.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Time based interface for Solidity
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface ITimeCop is IERC165 {

  function setPresale(
    uint time
  , uint duration
  ) external;

  function showPresaleStart()
    external
    view
    returns (uint);

  function showStart()
    external
    view
    returns (uint);
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: TimeCop.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Time based mechanism for Solidity
 * @custom:error-code TC:E1 State not set
 * @custom:change-log added custom error code
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./ITimeCop.sol";
import "../../access/MaxAccess.sol";

abstract contract TimeCop is MaxAccess
                           , ITimeCop {

  uint internal startPresale;
  uint internal presaleDuration;

  event PresaleSet(uint start, uint length);

  function setPresale(
    uint time
  , uint duration
  ) external
    onlyDev() {
    startPresale = time;
    presaleDuration = duration;
    emit PresaleSet(time, duration);
  }

  function showPresaleStart()
    external
    view
    virtual
    override (ITimeCop)
    returns (uint) {
    return startPresale;
  }

  function showStart()
    external
    view
    virtual
    override (ITimeCop)
    returns (uint) {
    return startPresale + presaleDuration;
  }

  modifier onlyPresale() {
    if (block.timestamp < startPresale) {
      revert TooSoonJunior({
        yourTime: block.timestamp
      , hitTime: startPresale
      });
    }
    if (block.timestamp >= startPresale + presaleDuration) {
      revert TooLateBoomer({
        yourTime: block.timestamp
      , hitTime: startPresale + presaleDuration
      });
    }
    _;
  }

  modifier onlySale() {
    if (block.timestamp < startPresale + presaleDuration) {
      revert TooSoonJunior({
        yourTime: block.timestamp
      , hitTime: startPresale + presaleDuration
      });
    }
    if (startPresale == 0) {
      revert MaxSplaining({
        reason: "TC:E1"
      });
    }
    _;
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: IWhitelist.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Interface for Whitelist
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IWhitelist is IERC165 {

  // @notice enables the bool
  function enableWhitelist()
    external;

  // @notice disables the bool
  function disableWhitelist()
    external;

  // @dev will return user status on whitelist
  // @return - bool if whitelist is enabled or not
  // @param myAddress - any user account address, EOA or contract
  function myWhitelistStatus(
    address myAddress
  ) external
    view
    returns (bool);

  // @dev will return status of whitelist
  // @return - bool if whitelist is enabled or not
  function whitelistStatus()
    external
    view
    returns (bool);
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: IWhitelistV3.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Interface for WhitelistV2.sol add on for ERC20/721/777/1155 tokens
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./IWhitelist.sol";

interface IWhitelistV3 is IWhitelist {

  // @notice adding functions to whitelist
  // @param newAddresses - array of addresses to add
  // @param newQuants - arrray of quantites allowed
  function addBatchWhitelist(
    address[] memory newAddresses
  , uint[] memory newQuants
  ) external;

  // @notice adding functions to whitelist
  // @param newAddress - address to add
  // @param newQuant - quantity allowed
  function addWhitelist(
    address newAddress
  , uint newQuant
  ) external;

  // @notice removing functions to whitelist
  // @param newAddresses - array of addresses to remove
  function removeBatchWhitelist(
    address[] memory newAddresses
  ) external;

  // @notice removing functions to whitelist
  // @param newAddress - address to remove
  function removeWhitelist(
    address newAddress
  ) external;

}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: WhitelistV3.sol
 * @author: @MaxFlowO2 on bird app/GitHub
 * @notice: Provides a whitelist capability that can be added to and removed easily.
 * @custom:error-code WLV3:E1 address.length and quant.length mismatch
 * @custom:change-log Custom errors added above
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "../../access/MaxAccess.sol";
import "../../lib/WhitelistV2.sol";
import "./IWhitelistV3.sol";

abstract contract WhitelistV3 is MaxAccess
                               , IWhitelistV3 {

  using WhitelistV2 for WhitelistV2.List;
  
  WhitelistV2.List internal whitelist;

  // internals of contract

  function _oneWLMint(
    address user
  ) internal {
    whitelist.wlMint(user);
  }

  function _addWhitelist(
    address newAddress
  , uint newQuant
  ) internal {
    whitelist.add(newAddress, newQuant);
  }

  function _addBatchWhitelist(
    address[] memory newAddresses
  , uint[] memory newQuants
  ) internal {
    uint check = newQuants.length;
    uint length = newAddresses.length;
    if (check != length) {
      revert MaxSplaining ({
        reason: "WLV3:E1"
      });
    }
    for(uint x = 0; x < length;) {
      whitelist.add(newAddresses[x], newQuants[x]);
      unchecked { ++x; }
    }
  }

  function _removeWhitelist(
    address newAddress
  ) internal {
    whitelist.remove(newAddress);
  }

  function _removeBatchWhitelist(
    address[] memory newAddresses
  ) internal {
    uint length = newAddresses.length;
    for(uint x = 0; x < length;) {
      whitelist.remove(newAddresses[x]);
      unchecked { ++x; }
    }
  }

  function _enableWhitelist()
    internal {
    whitelist.enable();
  }

  function _disableWhitelist()
    internal {
    whitelist.disable();
  }

  // @dev will return user status on whitelist
  // @return - bool if whitelist is enabled or not
  // @param myAddress - any user account address, EOA or contract
  function _myWhitelistStatus(
    address myAddress
  ) internal
    view
    returns (bool) {
    return whitelist.onList(myAddress);
  }

  // Externals of contract

  function addWhitelist(
    address newAddress
  , uint newQuant
  ) external
    virtual
    override
    onlyDev() {
    _addWhitelist(newAddress, newQuant);
  }

  function addBatchWhitelist(
    address[] memory newAddresses
  , uint[] memory newQuants
  ) external
    virtual
    override
    onlyDev() {
    _addBatchWhitelist(newAddresses, newQuants);
  }

  function removeWhitelist(
    address newAddress
  ) external
    virtual
    override
    onlyDev() {
    _removeWhitelist(newAddress);
  }

  function removeBatchWhitelist(
    address[] memory newAddresses
  ) external
    virtual
    override
    onlyDev() {
    _removeBatchWhitelist(newAddresses);
  }

  function enableWhitelist()
    external
    virtual
    override
    onlyDev() {
    _enableWhitelist();
  }

  function disableWhitelist()
    external
    virtual
    override
    onlyDev() {
    _disableWhitelist();
  }

  // @dev will return user status on whitelist
  // @return - bool if whitelist is enabled or not
  // @param myAddress - any user account address, EOA or contract
  function myWhitelistStatus(
    address myAddress
  ) external
    view
    virtual
    override
    returns (bool) {
    return whitelist.onList(myAddress);
  }

  // @dev will return status of whitelist
  // @return - bool if whitelist is enabled or not
  function whitelistStatus()
    external
    view
    virtual
    override
    returns (bool) {
    return whitelist.status();
  }

}