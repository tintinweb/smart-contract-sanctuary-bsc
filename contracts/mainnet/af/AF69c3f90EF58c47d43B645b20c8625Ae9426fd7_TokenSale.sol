// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721A is Context, ERC165, ERC2981, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;

    Counters.Counter private _tokenIdCounter;

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

    mapping(address => EnumerableSet.UintSet) private _holderTokens;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _tokenIdCounter.increment();
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165, ERC2981)
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function userTokens(address owner)
        external
        view
        virtual
        returns (uint256[] memory)
    {
        require(
            owner != address(0),
            "ERC721: balance query for the zero address"
        );
        uint256[] memory result = new uint256[](_holderTokens[owner].length());
        for (uint256 i; i < _holderTokens[owner].length(); i++) {
            result[i] = _holderTokens[owner].at(i);
        }
        return result;
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            owner != address(0),
            "ERC721: balance query for the zero address"
        );
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        address owner = _owners[tokenId];
        require(
            owner != address(0),
            "ERC721: owner query for nonexistent token"
        );
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
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
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
        address owner = ERC721A.ownerOf(tokenId);
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
    function getApproved(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        require(
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
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
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

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
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
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
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
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
    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        require(
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );
        address owner = ERC721A.ownerOf(tokenId);
        return (spender == owner ||
            isApprovedForAll(owner, spender) ||
            getApproved(tokenId) == spender);
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
        _holderTokens[to].add(tokenId);
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
        address owner = ERC721A.ownerOf(tokenId);

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
        require(
            ERC721A.ownerOf(tokenId) == from,
            "ERC721: transfer from incorrect owner"
        );
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);
        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);
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
        emit Approval(ERC721A.ownerOf(tokenId), to, tokenId);
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
            try
                IERC721Receiver(to).onERC721Received(
                    _msgSender(),
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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

// SPDX-License-Identifier: MIT
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/common/ERC2981.sol)

pragma solidity ^0.8.0;

import "../../interfaces/IERC2981.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the NFT Royalty Standard, a standardized way to retrieve royalty payment information.
 *
 * Royalty information can be specified globally for all token ids via {_setDefaultRoyalty}, and/or individually for
 * specific token ids via {_setTokenRoyalty}. The latter takes precedence over the first.
 *
 * Royalty is specified as a fraction of sale price. {_feeDenominator} is overridable but defaults to 10000, meaning the
 * fee is specified in basis points by default.
 *
 * IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. See
 * https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments[Rationale] in the EIP. Marketplaces are expected to
 * voluntarily pay royalties together with sales, but note that this standard is not yet widely supported.
 *
 * _Available since v4.5._
 */
abstract contract ERC2981 is IERC2981, ERC165 {
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IERC2981
     */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) public view virtual override returns (address, uint256) {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[_tokenId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (_salePrice * royalty.royaltyFraction) / _feeDenominator();

        return (royalty.receiver, royaltyAmount);
    }

    /**
     * @dev The denominator with which to interpret the fee set in {_setTokenRoyalty} and {_setDefaultRoyalty} as a
     * fraction of the sale price. Defaults to 10000 so fees are expressed in basis points, but may be customized by an
     * override.
     */
    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }

    /**
     * @dev Sets the royalty information that all ids in this contract will default to.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: invalid receiver");

        _defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Removes default royalty information.
     */
    function _deleteDefaultRoyalty() internal virtual {
        delete _defaultRoyaltyInfo;
    }

    /**
     * @dev Sets the royalty information for a specific token id, overriding the global default.
     *
     * Requirements:
     *
     * - `tokenId` must be already minted.
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: Invalid parameters");

        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Resets royalty information for the token id back to the global default.
     */
    function _resetTokenRoyalty(uint256 tokenId) internal virtual {
        delete _tokenRoyaltyInfo[tokenId];
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
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./interfaces/IUniswapRouterV2.sol";
import "./helpers/ERC721A.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title A PlanetexToken, symbol TPTX

contract NFTPlanetex is ERC721A, Ownable, ReentrancyGuard {
    struct TokenMetaData {
        string uri;
    }

    using Address for address;
    using Strings for uint256;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;

    IUniswapV2Router public swapRouter;

    string private baseUri; // nft token base Uri
    uint256 public totalSupplyNFT; // the maximum amount of mint
    uint256 public totalMinted; // how many tokens at the moment
    uint256 public purchasePrice; // nft token purchase price
    uint256 public saleStartTime; // nft sale start time
    address public usdt; // usdt or busd address
    address public proccedsRecipient; // procceds recipient wallet address
    address[] public path; // path for get price eth or bnb
    uint256[] public distributionCount; // distribution count NFT
    uint256[] public countAvailableNFT; // available count NFT

    mapping(uint256 => TokenMetaData) public tokenMetaDatas; // token metadata by id
    mapping(uint256 => TokenMetaData) public characters; // nft token types

    //// @dev - unequal length of arrays
    error InvalidArrayLengths(string err);
    /// @dev - address to the zero;
    error ZeroAddress(string err);
    /// @dev - amount to the zero;
    error ZeroNumber(string err);
    /// @dev - sold out
    error SoldOut(string err);
    /// @dev - Non exist token
    error NonExistToken(string err);
    /// @dev - Not enough purchase tokens
    error NotEnough(string err);
    /// @dev - failed to sent ether
    error FailedSentEther(string err);
    /// @dev - sale not started
    error SaleNotStarted(string err);

    event SetBaseURI(string indexed baseURI);
    event UpdatePurchasePrice(uint256 indexed newPurchasePrice);
    event BuyNFT(
        uint256 indexed tokenId,
        uint256 indexed tokenType,
        string uri
    );
    event UpdateURI(uint256 tokenId, string newUri);
    event UpdateSaleStart(uint256 newStartTime);

    constructor(
        uint256 totalSupply_, // nft tokens total supply
        uint96 fee_, // royalty fee percent
        uint256 purchasePrice_, // purchase price
        uint256 saleStartTime_, // sale start time
        address swapRouter_, // swap router address
        address usdt_, // usdt or busd token address
        address proccedsRecipient_, // procceds recipient wallet address
        string memory baseUri_, // base uri string
        uint256[] memory distributionCount_, // distribution count array
        uint256[] memory countAvailableNFT_, // count available for mint array
        string[] memory charactersUris_ // array of characters uris
    ) ERC721A("PlanetexNFT", "PLTEX") {
        if (
            distributionCount_.length != countAvailableNFT_.length ||
            distributionCount_.length != charactersUris_.length
        ) {
            revert InvalidArrayLengths("TPTX: Invalid array lengths");
        }

        if (
            usdt_ == address(0) ||
            swapRouter_ == address(0) ||
            proccedsRecipient_ == address(0)
        ) {
            revert ZeroAddress("TPTX: Zero Address");
        }
        if (purchasePrice_ == 0 || totalSupply_ == 0) {
            revert ZeroNumber("TPTX: Zero Number");
        }
        _setDefaultRoyalty(owner(), fee_);
        totalSupplyNFT = totalSupply_;
        baseUri = baseUri_;
        swapRouter = IUniswapV2Router(swapRouter_);
        usdt = usdt_;
        proccedsRecipient = proccedsRecipient_;
        purchasePrice = purchasePrice_;
        saleStartTime = saleStartTime_;
        distributionCount = distributionCount_;
        countAvailableNFT = countAvailableNFT_;
        for (uint256 i; i <= charactersUris_.length - 1; i++) {
            TokenMetaData storage charactersInfo = characters[i];
            charactersInfo.uri = charactersUris_[i];
        }

        address[] memory _path = new address[](2);
        _path[0] = IUniswapV2Router(swapRouter_).WETH();
        _path[1] = usdt_;
        path = _path;
    }

    receive() external payable {}

    //================================ External functions ========================================

    /**
    @dev The function performs the purchase of nft tokens for usdt or busd tokens
    */
    function buyForErc20() external {
        if (totalMinted == totalSupplyNFT) {
            revert SoldOut("TPTX: All sold out");
        }
        if (!isSaleStarted()) {
            revert SaleNotStarted("TPTX: Sale not started");
        }
        if (IERC20(usdt).balanceOf(msg.sender) < purchasePrice) {
            revert NotEnough("TPTX: Not enough tokens");
        }

        IERC20(usdt).safeTransferFrom(
            msg.sender,
            proccedsRecipient,
            purchasePrice
        );

        _mintAndSetMetaData(msg.sender);
    }

    /**
    @dev The function performs the purchase of nft tokens for eth or bnb tokens
    */
    function buyForEth() external payable nonReentrant {
        if (totalMinted == totalSupplyNFT) {
            revert SoldOut("TPTX: All sold out");
        }

        if (!isSaleStarted()) {
            revert SaleNotStarted("TPTX: Sale not started");
        }

        uint256 ethAmount = msg.value;

        uint256[] memory amounts = swapRouter.getAmountsIn(purchasePrice, path);
        if (ethAmount < amounts[0]) {
            revert NotEnough("TPTX: Not enough tokens");
        }
        (bool sent, ) = proccedsRecipient.call{value: amounts[0]}("");
        if (!sent) {
            revert FailedSentEther("Failed to send Ether");
        }
        if (ethAmount > amounts[0]) {
            uint256 turnBackValue = ethAmount - amounts[0];
            (bool sentBack, ) = msg.sender.call{value: turnBackValue}("");
            if (!sentBack) {
                revert FailedSentEther("Failed to send Ether");
            }
        }
        _mintAndSetMetaData(msg.sender);
    }

    /** 
    @dev The function mints the nft token and sets its metadata. Only owner can call it.
    @param to - recipient wallet address
     */
    function mint(address to) external onlyOwner {
        _mintAndSetMetaData(to);
    }

    /** 
    @dev The function updates the purchase price of the nft token. Only owner can call it.
    @param newPrice new purchase price
     */
    function updatePurchasePrice(uint256 newPrice) external onlyOwner {
        purchasePrice = newPrice;
        emit UpdatePurchasePrice(newPrice);
    }

    /** 
    @dev Sets the royalty information that all ids in this contract will default to. 
    Only owner can call it.
    @param receiver procceds fee recipient
    @param feeNumerator fee percent 
     */
    function updateDefaultRoyalty(address receiver, uint96 feeNumerator)
        external
        onlyOwner
    {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    /**
     * @dev Removes default royalty information.
     */
    function deleteDefaultRoyalty() external onlyOwner {
        _deleteDefaultRoyalty();
    }

    /**
     * @dev Sets the royalty information for a specific token id, overriding the global default.
     * Only owner can call it.
     *
     * Requirements:
     *
     * - `tokenId` must be already minted.
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) external onlyOwner {
        _setTokenRoyalty(tokenId, receiver, feeNumerator);
    }

    /**
     * @dev Removes royalty information for a specific token id.
     */
    function deleteTokenRoyalty(uint256 tokenId) external onlyOwner {
        _resetTokenRoyalty(tokenId);
    }

    /**
     * @dev function sets the base URI. Only owner can call it.
     * @param baseURI_ - new baseURI
     */
    function setBaseURI(string memory baseURI_) external virtual onlyOwner {
        baseUri = baseURI_;
        emit SetBaseURI(baseURI_);
    }

    /**
     * @dev This function updates the uri for a specific token.
     * Only owner can call it.
     * @param tokenId - token id
     * @param uri - new token uri
     */
    function updateURI(uint256 tokenId, string memory uri) public onlyOwner {
        TokenMetaData storage metaData = tokenMetaDatas[tokenId];
        metaData.uri = uri;
        emit UpdateURI(tokenId, uri);
    }

    /**
     * @dev This function performs a batch update of the token uri.
     * Only owner can call it.
     * @param tokenIds - array of token ids
     * @param urls - array of token uris
     */
    function updateUriBatch(uint256[] memory tokenIds, string[] memory urls)
        public
        onlyOwner
    {
        if (tokenIds.length != urls.length) {
            revert InvalidArrayLengths("TPTX: Invalid array lengths");
        }
        for (uint256 i; i < tokenIds.length; i++) {
            TokenMetaData storage metaData = tokenMetaDatas[tokenIds[i]];
            metaData.uri = urls[i];
            emit UpdateURI(tokenIds[i], urls[i]);
        }
    }

    /**
     * @dev The function updates the date of the start of the sale of nft tokens.
     * Only owner can call it.
     * @param newStartTime - new start time timestamp
     */
    function updateSaleStartTime(uint256 newStartTime) external onlyOwner {
        saleStartTime = newStartTime;
        emit UpdateSaleStart(newStartTime);
    }

    //=================== Public functions ================================

    /**
     * @dev The ETH amount equal purchase price.
     */

    function getEthPurchaseAmount() public view returns (uint256) {
        uint256[] memory amounts = swapRouter.getAmountsIn(purchasePrice, path);
        return amounts[0];
    }

    /**
     * @dev The function returns true if the token sale has started, false if not.
     */
    function isSaleStarted() public view returns (bool) {
        return block.timestamp >= saleStartTime;
    }

    /**
     * @dev The function returns the number of tokens created.
     */
    function totalSupply() public view virtual returns (uint256) {
        return totalMinted;
    }

    /**
     * @dev The getter function returns an array with a distribution of nft tokens and their types
     */
    function getDistributionCount() public view returns (uint256[] memory) {
        return distributionCount;
    }

    /**
     * @dev The getter function returns an array of free tokens with their types that can still be obtained
     */
    function getAvailableCount() public view returns (uint256[] memory) {
        return countAvailableNFT;
    }

    /**
     * @dev return base uri for nft tokens
     */
    function baseURI() public view virtual returns (string memory) {
        return baseUri;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (!_exists(tokenId)) {
            revert NonExistToken("TPTX: URI query for nonexistent token");
        }
        string memory _tokenURI = tokenMetaDatas[tokenId].uri;
        string memory base = baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }

        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return string(abi.encodePacked(base, tokenId.toString()));
    }

    //======================== Internal functions =====================================

    /**
     * @dev Mints `tokenId` and transfers it to `to` and set token metadata.
     */
    function _mintAndSetMetaData(address to) internal {
        uint256 nftType = _checkEmptyNFT();
        totalMinted++;
        TokenMetaData storage character = characters[nftType];
        TokenMetaData storage mintedNft = tokenMetaDatas[totalMinted];
        _mint(to, totalMinted);
        _saveDistributionCount(nftType);
        mintedNft.uri = character.uri;
        emit BuyNFT(totalMinted, nftType, mintedNft.uri);
    }

    /**
     * @dev This function performs semi-randomization in order to distribute
     * different types of nft between minters.
     * @param modul - maximum value for random
     */
    function _randomCount(uint256 modul) internal view returns (uint256) {
        if (modul == 0) {
            return 0;
        } else {
            uint256 random = uint256(
                keccak256(
                    abi.encodePacked(
                        msg.sender,
                        block.coinbase,
                        block.difficulty,
                        block.gaslimit,
                        block.timestamp
                    )
                )
            ) % modul;
            return random;
        }
    }

    /**
     * @dev This function checks for mint-free NFT types before the random is called.
     */
    function _checkEmptyNFT() internal view returns (uint256) {
        uint256[] memory availableArr = new uint256[](distributionCount.length);
        uint8 insertIndex;
        for (uint256 i = 0; i < distributionCount.length; i++) {
            if (distributionCount[i] < countAvailableNFT[i]) {
                availableArr[insertIndex] = i;
                ++insertIndex;
            }
        }
        uint256 freeCount = _randomCount(insertIndex);
        return availableArr[freeCount];
    }

    /**
     * @dev This function updates information about NFT tokens available to the Mint.
     */
    function _saveDistributionCount(uint256 number) internal {
        distributionCount[number] += 1;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IUniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./helpers/Whitelist.sol";
import "./interfaces/IUniswapRouterV2.sol";

pragma solidity 0.8.17;

contract TokenSale is Ownable, Whitelist {
    using SafeERC20 for IERC20;
    using Address for address;

    IUniswapV2Router public swapRouter; // swap router

    struct TokenSaleRound {
        uint256 startTime; // tokenSale round start time timestamp
        uint256 endTime; // tokenSale round end time timestamp
        uint256 duration; // tokenSale round duration
        uint256 minAmount; // min purchase amount
        uint256 purchasePrice; // purchase price
        uint256 tokensSold; // number of tokens sold
        uint256 totalPurchaseAmount; // number of tokens on sale
        uint256 tokenSaleType; // 0 - pre_sale; 1 - main_sale; 2 - private_sale
        bool isPublic; // if true then round is public, else is private
        bool isEnded; // active tokenSale if true, if false vesting is end
    }

    address public usdtToken; // usdt or busd token address
    address[] public path; // path for get price eth or bnb
    address public treasury; // treasury address
    uint256 public roundsCounter; // quantity of tokeSale rounds
    uint256 public immutable PRECISSION = 1000; // 10000; // precission for math operation

    mapping(uint256 => TokenSaleRound) public rounds; // 0 pre_sale; 1 main_sale; 2 private_sale;
    mapping(address => mapping(uint256 => uint256)) public userBalance; // return user balance of planetex token
    mapping(address => mapping(uint256 => uint256)) public userSpentFunds; // return user spent funds in token sale

    //// @errors

    //// @dev - unequal length of arrays
    error InvalidArrayLengths(string err);
    /// @dev - address to the zero;
    error ZeroAddress(string err);
    /// @dev - user not in the whitelist
    error NotInTheWhitelist(string err);
    /// @dev - round not started
    error RoundNotStarted(string err);
    /// @dev - round is started
    error RoundIsStarted(string err);
    /// @dev - amount more or less than min or max
    error MinMaxPurchase(string err);
    /// @dev - tokens not enough
    error TokensNotEnough(string err);
    /// @dev - msg.value cannot be zero
    error ZeroMsgValue(string err);
    /// @dev - round with rhis id not found
    error RoundNotFound(string err);
    /// @dev - round is ended
    error RoundNotEnd(string err);

    ////@notice emitted when the user purchase token
    event PurchasePlanetexToken(
        address user,
        uint256 spentAmount,
        uint256 receivedAmount
    );
    ////@notice emitted when the owner withdraw unsold tokens
    event WithdrawUnsoldTokens(
        uint256 roundId,
        address recipient,
        uint256 amount
    );
    ////@notice emitted when the owner update round start time
    event UpdateRoundStartTime(
        uint256 roundId,
        uint256 startTime,
        uint256 endTime
    );

    constructor(
        uint256[] memory _purchasePercents, // array of round purchase percents
        uint256[] memory _minAmounts, // array of round min purchase amounts
        uint256[] memory _durations, // array of round durations in seconds
        uint256[] memory _purchasePrices, // array of round purchase prices
        uint256[] memory _startTimes, // array of round start time timestamps
        bool[] memory _isPublic, // array of isPublic bool indicators
        uint256 _planetexTokenTotalSupply, // planetex token total supply
        address _usdtToken, // usdt token address
        address _treasury, // treasury address
        address _unirouter // swap router address
    ) {
        if (
            _purchasePercents.length != _minAmounts.length ||
            _purchasePercents.length != _durations.length ||
            _purchasePercents.length != _purchasePrices.length ||
            _purchasePercents.length != _isPublic.length ||
            _purchasePercents.length != _startTimes.length
        ) {
            revert InvalidArrayLengths("TokenSale: Invalid array lengths");
        }
        if (
            _usdtToken == address(0) ||
            _treasury == address(0) ||
            _unirouter == address(0)
        ) {
            revert ZeroAddress("TokenSale: Zero Address");
        }

        for (uint256 i; i <= _purchasePercents.length - 1; i++) {
            TokenSaleRound storage tokenSaleRound = rounds[i];
            tokenSaleRound.duration = _durations[i];
            tokenSaleRound.startTime = _startTimes[i];
            tokenSaleRound.endTime = _startTimes[i] + _durations[i];
            tokenSaleRound.minAmount = _minAmounts[i];
            tokenSaleRound.purchasePrice = _purchasePrices[i];
            tokenSaleRound.tokensSold = 0;
            tokenSaleRound.totalPurchaseAmount =
                (_planetexTokenTotalSupply * _purchasePercents[i]) /
                PRECISSION;
            tokenSaleRound.isPublic = _isPublic[i];
            tokenSaleRound.isEnded = false;
            tokenSaleRound.tokenSaleType = i;
        }
        roundsCounter = _purchasePercents.length - 1;
        usdtToken = _usdtToken;
        treasury = _treasury;
        swapRouter = IUniswapV2Router(_unirouter);
        address[] memory _path = new address[](2);
        _path[0] = IUniswapV2Router(_unirouter).WETH();
        _path[1] = _usdtToken;
        path = _path;
    }

    /**
    @dev The modifier checks whether the tokenSale round has not expired.
    @param roundId tokenSale round id.
    */
    modifier isEnded(uint256 roundId) {
        TokenSaleRound storage tokenSaleRound = rounds[roundId];
        if (roundId > roundsCounter) {
            revert RoundNotFound("TokenSale: Round not found");
        }
        require(
            tokenSaleRound.endTime > block.timestamp,
            "TokenSale: Round is ended"
        );
        _;
    }

    //// External functions

    receive() external payable {}

    /**
    @dev The function performs the purchase of tokens for usdt or busd tokens
    @param roundId tokeSale round id.
    @param amount usdt or busd amount.
    */
    function buyForErc20(uint256 roundId, uint256 amount)
        external
        isEnded(roundId)
    {
        TokenSaleRound storage tokenSaleRound = rounds[roundId];

        if (!tokenSaleRound.isPublic) {
            if (!whitelist[msg.sender]) {
                revert NotInTheWhitelist("TokenSale: Not in the whitelist");
            }
        }

        if (!isRoundStared(roundId)) {
            revert RoundNotStarted("TokenSale: Round is not started");
        }

        if (amount < tokenSaleRound.minAmount) {
            revert MinMaxPurchase("TokenSale: Amount not allowed");
        }

        uint256 tokenAmount = _calcPurchaseAmount(
            amount,
            tokenSaleRound.purchasePrice
        );

        if (
            tokenSaleRound.tokensSold + tokenAmount >
            tokenSaleRound.totalPurchaseAmount
        ) {
            revert TokensNotEnough("TokenSale: Tokens not enough");
        }

        tokenSaleRound.tokensSold += tokenAmount;
        userSpentFunds[msg.sender][roundId] += amount;

        IERC20(usdtToken).safeTransferFrom(msg.sender, treasury, amount);

        userBalance[msg.sender][roundId] += tokenAmount;

        _endSoldOutRound(roundId);
        emit PurchasePlanetexToken(msg.sender, amount, tokenAmount);
    }

    /**
    @dev The function performs the purchase of tokens for eth or bnb tokens
    @param roundId tokeSale round id.
    */
    function buyForEth(uint256 roundId) external payable isEnded(roundId) {
        if (msg.value == 0) {
            revert ZeroMsgValue("TokenSale: Zero msg.value");
        }

        TokenSaleRound storage tokenSaleRound = rounds[roundId];

        if (!tokenSaleRound.isPublic) {
            if (!whitelist[msg.sender]) {
                revert NotInTheWhitelist("TokenSale: Not in the whitelist");
            }
        }

        if (!isRoundStared(roundId)) {
            revert RoundNotStarted("TokenSale: Round is not started");
        }

        uint256[] memory amounts = swapRouter.getAmountsOut(msg.value, path);

        if (amounts[1] < tokenSaleRound.minAmount) {
            revert MinMaxPurchase("TokenSale: Amount not allowed");
        }

        uint256 tokenAmount = _calcPurchaseAmount(
            amounts[1],
            tokenSaleRound.purchasePrice
        );

        if (
            tokenSaleRound.tokensSold + tokenAmount >
            tokenSaleRound.totalPurchaseAmount
        ) {
            revert TokensNotEnough("TokenSale: Tokens not enough");
        }

        tokenSaleRound.tokensSold += tokenAmount;
        userSpentFunds[msg.sender][roundId] += amounts[1];

        userBalance[msg.sender][roundId] += tokenAmount;

        _endSoldOutRound(roundId);

        (bool sent, ) = treasury.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
        emit PurchasePlanetexToken(msg.sender, amounts[1], tokenAmount);
    }

    /**
    @dev The function withdraws tokens that were not sold and writes 
    them to the balance of the specified wallet.Only owner can call it. 
    Only if round is end.
    @param roundId tokeSale round id.
    @param recipient recipient wallet address
    */
    function withdrawUnsoldTokens(uint256 roundId, address recipient)
        external
        onlyOwner
    {
        if (roundId > roundsCounter) {
            revert RoundNotFound("TokenSale: Round not found");
        }
        TokenSaleRound storage tokenSaleRound = rounds[roundId];
        if (tokenSaleRound.endTime > block.timestamp) {
            revert RoundNotEnd("TokenSale: Round not end");
        }
        if (tokenSaleRound.totalPurchaseAmount > tokenSaleRound.tokensSold) {
            uint256 unsoldTokens = tokenSaleRound.totalPurchaseAmount -
                tokenSaleRound.tokensSold;
            tokenSaleRound.tokensSold = tokenSaleRound.totalPurchaseAmount;
            userBalance[recipient][roundId] += unsoldTokens;
            emit WithdrawUnsoldTokens(roundId, recipient, unsoldTokens);
        } else {
            revert TokensNotEnough("TokenSale: Sold out");
        }

        tokenSaleRound.isEnded = true;
    }

    /**
    @dev The function update token sale round start time.Only owner can call it. 
    Only if round is not started.
    @param roundId tokeSale round id.
    @param newStartTime new start time timestamp
    */
    function updateStartTime(uint256 roundId, uint256 newStartTime)
        external
        onlyOwner
    {
        if (roundId > roundsCounter) {
            revert RoundNotFound("TokenSale: Round not found");
        }
        TokenSaleRound storage tokenSaleRound = rounds[roundId];
        if (tokenSaleRound.startTime < block.timestamp) {
            revert RoundIsStarted("TokenSale: Round is started");
        }

        tokenSaleRound.startTime = newStartTime;
        tokenSaleRound.endTime = newStartTime + tokenSaleRound.duration;
        emit UpdateRoundStartTime(
            roundId,
            tokenSaleRound.startTime,
            tokenSaleRound.endTime
        );
    }

    //// Public Functions

    function convertToStable(uint256 amount, uint256 roundId)
        public
        view
        returns (
            uint256 ethAmount,
            uint256 usdtAmount,
            uint256 planetexAmount
        )
    {
        TokenSaleRound storage tokenSaleRound = rounds[roundId];
        if (amount > 0) {
            uint256[] memory amounts = swapRouter.getAmountsOut(amount, path);
            ethAmount = amounts[0];
            usdtAmount = amounts[1];
            planetexAmount = _calcPurchaseAmount(
                usdtAmount,
                tokenSaleRound.purchasePrice
            );
        } else {
            ethAmount = 0;
            usdtAmount = 0;
            planetexAmount = 0;
        }
    }

    function convertUsdtToPltx(uint256 roundId, uint256 amount)
        public
        view
        returns (uint256)
    {
        if (roundId > roundsCounter) {
            revert RoundNotFound("TokenSale: Round not found");
        }
        TokenSaleRound storage tokenSaleRound = rounds[roundId];
        uint256 tokenAmount = _calcPurchaseAmount(
            amount,
            tokenSaleRound.purchasePrice
        );
        return tokenAmount;
    }

    /**
    @dev The function shows whether the round has started. Returns true if yes, false if not
    @param roundId tokeSale round id.
    */
    function isRoundStared(uint256 roundId) public view returns (bool) {
        if (roundId > roundsCounter) {
            revert RoundNotFound("TokenSale: Round not found");
        }
        TokenSaleRound storage tokenSaleRound = rounds[roundId];
        return (block.timestamp >= tokenSaleRound.startTime &&
            block.timestamp <= tokenSaleRound.endTime);
    }

    /**
    @dev The function returns the timestamp of the end of the tokenSale round
    @param roundId tokeSale round id.
    */
    function getRoundEndTime(uint256 roundId) public view returns (uint256) {
        if (roundId > roundsCounter) {
            revert RoundNotFound("TokenSale: Round not found");
        }
        TokenSaleRound storage tokenSaleRound = rounds[roundId];
        return tokenSaleRound.endTime;
    }

    /**
    @dev The function returns the timestamp of the start of the tokenSale round
    @param roundId tokeSale round id.
    */
    function getRoundStartTime(uint256 roundId) public view returns (uint256) {
        if (roundId > roundsCounter) {
            revert RoundNotFound("TokenSale: Round not found");
        }
        TokenSaleRound storage tokenSaleRound = rounds[roundId];
        return tokenSaleRound.startTime;
    }

    //// Internal Functions

    /**
    @dev The function ends the round if all tokens are sold out
    @param roundId tokeSale round id.
    */
    function _endSoldOutRound(uint256 roundId) internal {
        TokenSaleRound storage tokenSaleRound = rounds[roundId];

        if (tokenSaleRound.tokensSold == tokenSaleRound.totalPurchaseAmount) {
            tokenSaleRound.isEnded = true;
        }
    }

    /**
    @dev The function calculates the number of tokens to be received by the user
    @param amount usdt or busd token amount.
    @param price purchase price
    */
    function _calcPurchaseAmount(uint256 amount, uint256 price)
        internal
        pure
        returns (uint256 tokenAmount)
    {
        tokenAmount = (amount / price) * 1e18;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * @dev This simplifies the implementation of "user permissions".
 */
contract Whitelist is Ownable {
    mapping(address => bool) public whitelist;

    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);

    /**
     * @dev add an address to the whitelist
     * @param addr address
     * @return success if the address was added to the whitelist, false if the address was already in the whitelist
     */
    function addAddressToWhitelist(address addr)
        public
        onlyOwner
        returns (bool success)
    {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }

    /**
     * @dev add addresses to the whitelist
     * @param addrs addresses
     * @return success if at least one address was added to the whitelist,
     * false if all addresses were already in the whitelist
     */
    function addAddressesToWhitelist(address[] memory addrs)
        public
        onlyOwner
        returns (bool success)
    {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

    /**
     * @dev remove an address from the whitelist
     * @param addr address
     * @return success if the address was removed from the whitelist,
     * false if the address wasn't in the whitelist in the first place
     */
    function removeAddressFromWhitelist(address addr)
        public
        onlyOwner
        returns (bool success)
    {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
    }

    /**
     * @dev remove addresses from the whitelist
     * @param addrs addresses
     * @return success if at least one address was removed from the whitelist,
     * false if all addresses weren't in the whitelist in the first place
     */
    function removeAddressesFromWhitelist(address[] memory addrs)
        public
        onlyOwner
        returns (bool success)
    {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
    }
}

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/ITokenSale.sol";

pragma solidity 0.8.17;

contract SaleVesting is Ownable {
    using SafeERC20 for IERC20;
    using Address for address;

    struct VestingProgram {
        uint256 startTime; // vesting start time timestamp
        uint256 endTime; // vesting end time timestamp
        uint256 cliffDuration; // cliff period duration in seconds
        uint256 duration; // vesting duration in seconds
        uint256 vestingAmount; // total vested amount
        uint256 unvestedAmount; // total unvested amount
        uint256 startUnlockPercentage; // start unlock percentage
        uint256 unlockPercentage; // period unlock percentage
        uint256 periodDuration; // unlock period duration in seconds
        uint256 vestingType; // 0 - presale, 1 - mainsale, 2 - private-sale
        bool isEnded; // active vesting if true, if false vesting is end
    }

    struct User {
        uint256 lastUnvesting; // last  unvest timestamp
        uint256 totalVested; // total user vested amount
        uint256 totalUnvested; // total user unvested amount
        bool isGetStartUnlockAmount; // received or not received the initial unlocked funds
    }

    address public tokenSale; // tokenSale contract address
    address public vestingToken; // planetex token address
    uint256 public vestingProgramsCounter; // quantity of vesting programs
    uint256 public immutable PRECISSION = 10000; // precission for math operation
    bool public isInitialized = false; // if true, the contract is initialized, if false, then not

    mapping(uint256 => VestingProgram) public vestingPrograms; // return VestingProgram info
    mapping(address => mapping(uint256 => User)) public userInfo; // return user info
    mapping(address => mapping(uint256 => bool)) public isVester; // bool if true then user is vesting member else not a member

    //// @errors

    //// @dev - cannot unvest 0;
    error ZeroAmountToUnvest(string err);
    //// @dev - unequal length of arrays
    error InvalidArrayLengths(string err);
    /// @dev - user is not a member of the vesting program
    error NotVester(string err);
    //// @dev - vesting program is ended
    error VestingIsEnd(string err);
    //// @dev - vesting program not started
    error VestingNotStarted(string err);
    //// @dev - there is no vesting program with this id
    error VestingProgramNotFound(string err);
    /// @dev - address to the zero;
    error ZeroAddress(string err);
    //// @dev - cannot rescue 0;
    error RescueZeroValue(string err);
    //// @dev - cannot initialized contract again
    error ContractIsInited(string err);
    //// @dev - cannot call methods if contract not inited
    error ContractIsNotInited(string err);

    ////@notice emitted when the user has joined the vesting program
    event Vest(address user, uint256 vestAmount, uint256 vestingProgramId);
    ////@notice emitted when the user gets ownership of the tokens
    event Unvest(
        address user,
        uint256 unvestedAmount,
        uint256 vestingProgramId
    );
    /// @notice Transferring funds from the wallet еther of the selected token contract to the specified wallet
    event RescueToken(
        address indexed to,
        address indexed token,
        uint256 amount
    );

    function initialize(
        address _tokenSale, // tokenSale contract address
        address _vestingToken, // planetex token contract address
        uint256[] memory _durations, // array of vesting durations in seconds
        uint256[] memory _cliffDurations, // array of cliff period durations in the seconds
        uint256[] memory _startUnlockPercentages, // array of start unlock percentages
        uint256[] memory _unlockPercentages, // array of unlock percentages every unlock period
        uint256[] memory _totalSupplyPercentages, // array of percentages of tokens from totalSupply
        uint256[] memory _vestingTypes, // array of vesting types. 0 - pre_sale; 1 - main_sale; 2 - private_sale
        uint256[] memory _periodDurations // array of unlock period durations in secconds
    ) external onlyOwner isInited {
        if (
            _durations.length != _cliffDurations.length ||
            _durations.length != _startUnlockPercentages.length ||
            _durations.length != _unlockPercentages.length ||
            _durations.length != _totalSupplyPercentages.length ||
            _durations.length != _vestingTypes.length ||
            _durations.length != _periodDurations.length
        ) {
            revert InvalidArrayLengths("Vesting: Invalid array lengths");
        }
        if (_tokenSale == address(0) || _vestingToken == address(0)) {
            revert ZeroAddress("Vesting: Zero address");
        }
        tokenSale = _tokenSale;
        vestingToken = _vestingToken;
        uint256 totalSupply = IERC20(_vestingToken).totalSupply();
        for (uint256 i; i <= _durations.length - 1; i++) {
            VestingProgram storage vestingProgram = vestingPrograms[i];
            vestingProgram.startTime =
                ITokenSale(_tokenSale).getRoundEndTime(i) + // set token sale round end time
                _cliffDurations[i];
            vestingProgram.endTime = vestingProgram.startTime + _durations[i];
            vestingProgram.duration = _durations[i];
            vestingProgram.cliffDuration = _cliffDurations[i];
            vestingProgram.vestingAmount =
                (_totalSupplyPercentages[i] * totalSupply) /
                PRECISSION;
            vestingProgram.startUnlockPercentage = _startUnlockPercentages[i];
            vestingProgram.unlockPercentage = _unlockPercentages[i];
            vestingProgram.periodDuration = _periodDurations[i];
            vestingProgram.vestingType = _vestingTypes[i];
            vestingProgram.unvestedAmount = 0;
            vestingProgram.isEnded = false;
        }
        isInitialized = true;
        vestingProgramsCounter = _durations.length - 1;
    }

    /**
    @dev The modifier checks whether the vesting program has not expired.
    @param vestingId vesting program id.
    */
    modifier isEnded(uint256 vestingId) {
        VestingProgram storage vestingProgram = vestingPrograms[vestingId];
        if (vestingId > vestingProgramsCounter) {
            revert VestingProgramNotFound("Vesting: Program not found");
        }
        if (vestingProgram.isEnded) {
            revert VestingIsEnd("Vesting: Vesting is end");
        }
        _;
    }

    /**
    @dev The modifier checks whether the contract has been initialized.
    Prevents reinitialization.
    */
    modifier isInited() {
        if (isInitialized) {
            revert ContractIsInited("Vesting: Already initialized");
        }
        _;
    }

    /**
    @dev The modifier checks if the contract has been initialized. 
    Prevents functions from being called before the contract is initialized.
    */
    modifier notInited() {
        if (!isInitialized) {
            revert ContractIsNotInited("Vesting: Not inited");
        }
        _;
    }

    //// External functions

    /**
    @dev The function withdraws unlocked funds for the specified user. 
    Anyone can call instead of the user.
    @param vestingId vesting program id.
    @param userAddress user wallet address.
    */
    function unvestFor(uint256 vestingId, address userAddress)
        external
        notInited
        isEnded(vestingId)
    {
        _unvest(vestingId, userAddress);
    }

    /**
    @dev The function performs the withdrawal of unlocked funds.
    @param vestingId vesting program id.
    */
    function unvest(uint256 vestingId) external notInited isEnded(vestingId) {
        _unvest(vestingId, msg.sender);
    }

    /// @notice Transferring funds from the wallet of the selected token contract to the specified wallet
    /// @dev Used for the owner to withdraw funds
    /// @param to Address owner (Example)
    /// @param tokenAddress Token address from which tokens will be transferred
    /// @param amount Amount of transferred tokens
    function rescue(
        address to,
        address tokenAddress,
        uint256 amount
    ) external onlyOwner {
        if (to == address(0) || tokenAddress == address(0)) {
            revert ZeroAddress("Vesting: Cannot rescue to the zero address");
        }
        if (amount == 0) {
            revert RescueZeroValue("Vesting: Cannot rescue 0");
        }
        IERC20(tokenAddress).safeTransfer(to, amount);
        emit RescueToken(to, address(tokenAddress), amount);
    }

    //// Public functions

    /**
    @dev The function calculates the available amount of funds 
    for unvest for a certain user.
    @param vestingId vesting program id.
    @param userAddress user wallet address.
    @return unvestedAmount available amount of funds for unvest for a certain user.
    @return lastUserUnvesting timestamp when user do last unvest.
    @return totalUserUnvested the sum of all funds received user after unvest.
    @return totalUnvested the entire amount of funds of the vesting program that was withdrawn from vesting
    @return payStartUnlock indicates whether the starting unlocked funds have been received
    */
    function getUserUnvestedAmount(uint256 vestingId, address userAddress)
        public
        view
        notInited
        returns (
            uint256 unvestedAmount,
            uint256 lastUserUnvesting,
            uint256 totalUserUnvested,
            uint256 totalUnvested,
            bool payStartUnlock
        )
    {
        if (isVester[userAddress][vestingId]) {
            (
                unvestedAmount,
                lastUserUnvesting,
                totalUserUnvested,
                totalUnvested,
                payStartUnlock
            ) = _getUnvestedAmountRegisterUser(vestingId, userAddress);
        } else {
            (
                unvestedAmount,
                lastUserUnvesting,
                totalUserUnvested,
                totalUnvested,
                payStartUnlock
            ) = _getUnvestedAmountNonRegisterUser(vestingId, userAddress);
        }
    }

    //// Internal functions

    /**
    @dev The function withdraws unlocked funds for the specified user. 
    Anyone can call instead of the user.
    @param vestingId vesting program id.
    @param userAddress user wallet address.
    */
    function _unvest(uint256 vestingId, address userAddress) internal {
        if (userAddress == address(0)) {
            revert ZeroAddress("Vesting: Zero address");
        }
        User storage user = userInfo[userAddress][vestingId];
        VestingProgram storage vestingProgram = vestingPrograms[vestingId];

        if (block.timestamp <= vestingProgram.startTime) {
            revert VestingNotStarted("Vesting: Not started");
        }

        if (!isVester[userAddress][vestingId]) {
            _vest(vestingId, userAddress, vestingProgram.startTime);
        }
        if (
            vestingProgram.unvestedAmount == vestingProgram.vestingAmount ||
            user.totalVested == user.totalUnvested
        ) {
            revert VestingIsEnd("Vesting: Vesting is end");
        }

        (
            uint256 unvestedAmount,
            uint256 lastUserUnvesting,
            uint256 totalUserUnvested,
            uint256 totalUnvested,
            bool payStartUnlock
        ) = getUserUnvestedAmount(vestingId, userAddress);

        if (!user.isGetStartUnlockAmount) {
            user.isGetStartUnlockAmount = payStartUnlock;
        }

        user.lastUnvesting = lastUserUnvesting;
        user.totalUnvested = totalUserUnvested;

        if (unvestedAmount == 0) {
            revert ZeroAmountToUnvest("Vesting: Zero unvest amount");
        } else {
            if (
                unvestedAmount + vestingProgram.unvestedAmount >=
                vestingProgram.vestingAmount
            ) {
                unvestedAmount =
                    vestingProgram.vestingAmount -
                    vestingProgram.unvestedAmount;
            }
            vestingProgram.unvestedAmount = totalUnvested;
            IERC20(vestingToken).safeTransfer(userAddress, unvestedAmount);
            emit Unvest(userAddress, unvestedAmount, vestingId);
        }

        if (vestingProgram.unvestedAmount == vestingProgram.vestingAmount) {
            vestingProgram.isEnded = true;
        }
    }

    /**
    @dev The function calculates the available amount of funds 
    for unvest for a certain user. Called if the user is already registered in the vesting program
    @param vestingId vesting program id.
    @param userAddress user wallet address.
    @return unvestedAmount available amount of funds for unvest for a certain user.
    @return lastUserUnvesting timestamp when user do last unvest.
    @return totalUserUnvested the sum of all funds received user after unvest.
    @return totalUnvested the entire amount of funds of the vesting program that was withdrawn from vesting
    @return payStartUnlock indicates whether the starting unlocked funds have been received
    */
    function _getUnvestedAmountRegisterUser(
        uint256 vestingId,
        address userAddress
    )
        internal
        view
        returns (
            uint256 unvestedAmount,
            uint256 lastUserUnvesting,
            uint256 totalUserUnvested,
            uint256 totalUnvested,
            bool payStartUnlock
        )
    {
        User storage user = userInfo[userAddress][vestingId];
        VestingProgram storage vestingProgram = vestingPrograms[vestingId];

        if (block.timestamp < vestingProgram.endTime) {
            uint256 userVestingTime = block.timestamp - user.lastUnvesting;
            uint256 payouts = userVestingTime / vestingProgram.periodDuration;
            unvestedAmount =
                ((user.totalVested * vestingProgram.unlockPercentage) /
                    PRECISSION) *
                payouts;
            if (vestingProgram.startUnlockPercentage > 0) {
                if (!user.isGetStartUnlockAmount) {
                    unvestedAmount += ((user.totalVested *
                        vestingProgram.startUnlockPercentage) / PRECISSION);
                    payStartUnlock = true;
                }
            }
            lastUserUnvesting =
                user.lastUnvesting +
                (vestingProgram.periodDuration * payouts);
            totalUserUnvested = user.totalUnvested + unvestedAmount;
            totalUnvested = vestingProgram.unvestedAmount + unvestedAmount;
        } else {
            unvestedAmount = user.totalVested - user.totalUnvested;
            if (unvestedAmount > 0) {
                lastUserUnvesting = vestingProgram.endTime;
                totalUserUnvested = user.totalVested;
                totalUnvested = vestingProgram.unvestedAmount + unvestedAmount;
            }
        }
    }

    /**
    @dev The function calculates the available amount of funds 
    for unvest for a certain user. Called if the user is not registered in the vesting program
    @param vestingId vesting program id.
    @param userAddress user wallet address.
    @return unvestedAmount available amount of funds for unvest for a certain user.
    @return lastUserUnvesting timestamp when user do last unvest.
    @return totalUserUnvested the sum of all funds received user after unvest.
    @return totalUnvested the entire amount of funds of the vesting program that was withdrawn from vesting
    @return payStartUnlock indicates whether the starting unlocked funds have been received
    */
    function _getUnvestedAmountNonRegisterUser(
        uint256 vestingId,
        address userAddress
    )
        internal
        view
        returns (
            uint256 unvestedAmount,
            uint256 lastUserUnvesting,
            uint256 totalUserUnvested,
            uint256 totalUnvested,
            bool payStartUnlock
        )
    {
        VestingProgram storage vestingProgram = vestingPrograms[vestingId];
        uint256 userTotalVested = ITokenSale(tokenSale).userBalance(
            userAddress,
            vestingId
        );
        if (block.timestamp < vestingProgram.startTime) {
            revert VestingNotStarted("Vesting: Not started");
        }
        if (userTotalVested == 0) {
            revert NotVester("Vesting: Not a vester");
        }

        if (block.timestamp < vestingProgram.endTime) {
            uint256 userVestingTime = block.timestamp -
                vestingProgram.startTime;
            uint256 payouts = userVestingTime / vestingProgram.periodDuration;
            unvestedAmount =
                ((userTotalVested * vestingProgram.unlockPercentage) /
                    PRECISSION) *
                payouts;
            if (vestingProgram.startUnlockPercentage > 0) {
                unvestedAmount += ((userTotalVested *
                    vestingProgram.startUnlockPercentage) / PRECISSION);
                payStartUnlock = true;
            }
            lastUserUnvesting =
                vestingProgram.startTime +
                (vestingProgram.periodDuration * payouts);
            totalUserUnvested = unvestedAmount;
            totalUnvested = vestingProgram.unvestedAmount + unvestedAmount;
        } else {
            unvestedAmount = userTotalVested;
            if (unvestedAmount > 0) {
                lastUserUnvesting = vestingProgram.endTime;
                totalUserUnvested = userTotalVested;
                totalUnvested = vestingProgram.unvestedAmount + unvestedAmount;
            }
        }
    }

    function _vest(
        uint256 vestingId,
        address userAddress,
        uint256 vestingProgramStartTime
    ) internal {
        User storage user = userInfo[userAddress][vestingId];
        uint256 vestedAmount = ITokenSale(tokenSale).userBalance(
            userAddress,
            vestingId
        );

        if (vestedAmount > 0) {
            isVester[userAddress][vestingId] = true;
            user.totalVested = vestedAmount;
            user.totalUnvested = 0;
            user.lastUnvesting = vestingProgramStartTime;
            user.isGetStartUnlockAmount = false;
            emit Vest(userAddress, vestedAmount, vestingId);
        } else {
            revert NotVester("Vesting: Zero balance");
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ITokenSale {
    function userBalance(address, uint256) external view returns (uint256);

    function getRoundEndTime(uint256 roundId) external view returns (uint256);

    function getRoundStartTime(uint256 roundId) external view returns (uint256);

    function rounds(uint256)
        external
        returns (
            uint256 startTime,
            uint256 endTime,
            uint256 duration,
            uint256 minAmount,
            uint256 maxAmount,
            uint256 purchasePrice,
            uint256 tokensSold,
            uint256 totalPurchaseAmount,
            uint256 tokenSaleType,
            uint256 paymentPercent,
            bool isPublic,
            bool isEnded
        );
}

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/ITokenSale.sol";

pragma solidity 0.8.17;

contract ProjectVesting is Ownable {
    using SafeERC20 for IERC20;
    using Address for address;

    struct VestingProgram {
        uint256 startTime; // vesting start time timestamp
        uint256 endTime; // vesting end time timestamp
        uint256 cliffDuration; // cliff period duration in seconds
        uint256 duration; // vesting duration in seconds
        uint256 vestingAmount; // total vested amount
        uint256 unvestedAmount; // total unvested amount
        uint256 unlockPercentage; // period unlock percentage
        uint256 periodDuration; // unlock period duration in seconds
        uint256 vestingType; //0 - team;  1 - treasury
        bool isEnded; // active vesting if true, if false vesting is end
    }

    struct User {
        uint256 lastUnvesting; // last  unvest timestamp
        uint256 totalVested; // total user vested amount
        uint256 totalUnvested; // total user unvested amount
    }

    address public vestingToken; // planetex token address
    address public tokenSale; // tokenSale contract address
    uint256 public vestingProgramsCounter; // quantity of vesting programs
    uint256 public immutable PRECISSION = 10000; // precission for math operation
    bool public isInitialized = false; // if true, the contract is initialized, if false, then not

    mapping(uint256 => VestingProgram) public vestingPrograms; // return VestingProgram info (0 - team, 1 - treasury)
    mapping(address => mapping(uint256 => User)) public userInfo; // return user info
    mapping(address => mapping(uint256 => bool)) public isVester; // bool if true then user is vesting member else not a member

    //// @errors

    //// @dev - cannot unvest 0;
    error ZeroAmountToUnvest(string err);
    //// @dev - unequal length of arrays
    error InvalidArrayLengths(string err);
    /// @dev - user is not a member of the vesting program
    error NotVester(string err);
    //// @dev - vesting program is ended
    error VestingIsEnd(string err);
    //// @dev - vesting program not started
    error VestingNotStarted(string err);
    //// @dev - there is no vesting program with this id
    error VestingProgramNotFound(string err);
    /// @dev - address to the zero;
    error ZeroAddress(string err);
    //// @dev - Cannot rescue 0;
    error RescueZeroValue(string err);
    //// @dev - cannot initialized contract again
    error ContractIsInited(string err);
    //// @dev - cannot call methods if contract not inited
    error ContractIsNotInited(string err);

    ////@notice emitted when the user has joined the vesting program
    event Vest(address user, uint256 vestAmount, uint256 vestingProgramId);
    ////@notice emitted when the user gets ownership of the tokens
    event Unvest(
        address user,
        uint256 unvestedAmount,
        uint256 vestingProgramId
    );
    /// @notice Transferring funds from the wallet еther of the selected token contract to the specified wallet
    event RescueToken(
        address indexed to,
        address indexed token,
        uint256 amount
    );

    function initialize(
        address _vestingToken, // planetex token contract address
        address _tokenSale, // tokenSale contract address
        uint256[] memory _durations, // array of vesting durations in seconds
        uint256[] memory _cliffDurations, // array of cliff period durations in the seconds
        uint256[] memory _unlockPercentages, // array of unlock percentages every unlock period
        uint256[] memory _totalSupplyPercentages, // array of percentages of tokens from totalSupply
        uint256[] memory _vestingTypes, // array of vesting types. 0 - team; 1 - treasury;
        uint256[] memory _periodDurations, // array of unlock period durations in secconds
        address[] memory _vesters // array of vesters adresses (0 - team address, 1 - treasury address)
    ) external onlyOwner isInited {
        if (
            _durations.length != _cliffDurations.length ||
            _durations.length != _unlockPercentages.length ||
            _durations.length != _totalSupplyPercentages.length ||
            _durations.length != _vestingTypes.length ||
            _durations.length != _periodDurations.length ||
            _durations.length != _vesters.length
        ) {
            revert InvalidArrayLengths("Vesting: Invalid array lengths");
        }
        if (_vestingToken == address(0) || _tokenSale == address(0)) {
            revert ZeroAddress("Vesting: Zero address");
        }

        vestingToken = _vestingToken;
        uint256 totalSupply = IERC20(_vestingToken).totalSupply();
        for (uint256 i; i <= _durations.length - 1; i++) {
            VestingProgram storage vestingProgram = vestingPrograms[i];
            vestingProgram.startTime =
                ITokenSale(_tokenSale).getRoundStartTime(0) +
                _cliffDurations[i];
            vestingProgram.endTime = vestingProgram.startTime + _durations[i];
            vestingProgram.duration = _durations[i];
            vestingProgram.cliffDuration = _cliffDurations[i];
            vestingProgram.vestingAmount =
                (_totalSupplyPercentages[i] * totalSupply) /
                PRECISSION;
            vestingProgram.unlockPercentage = _unlockPercentages[i];
            vestingProgram.periodDuration = _periodDurations[i];
            vestingProgram.vestingType = _vestingTypes[i];
            vestingProgram.unvestedAmount = 0;
            vestingProgram.isEnded = false;

            User storage userVestInfo = userInfo[_vesters[i]][i];
            userVestInfo.lastUnvesting = vestingProgram.startTime;
            userVestInfo.totalVested = vestingProgram.vestingAmount;
            userVestInfo.totalUnvested = vestingProgram.unvestedAmount;
            isVester[_vesters[i]][i] = true;
        }
        isInitialized = true;
        vestingProgramsCounter = _durations.length - 1;
    }

    /**
    @dev The modifier checks whether the vesting program has not expired.
    @param vestingId vesting program id.
    */
    modifier isEnded(uint256 vestingId) {
        VestingProgram storage vestingProgram = vestingPrograms[vestingId];
        if (vestingId > vestingProgramsCounter) {
            revert VestingProgramNotFound("Vesting: Program not found");
        }
        if (vestingProgram.isEnded) {
            revert VestingIsEnd("Vesting: Vesting is end");
        }
        _;
    }

    /**
    @dev The modifier checks whether the contract has been initialized.
    Prevents reinitialization.
    */
    modifier isInited() {
        if (isInitialized) {
            revert ContractIsInited("Vesting: Already initialized");
        }
        _;
    }

    /**
    @dev The modifier checks if the contract has been initialized. 
    Prevents functions from being called before the contract is initialized.
    */
    modifier notInited() {
        if (!isInitialized) {
            revert ContractIsNotInited("Vesting: Not inited");
        }
        _;
    }

    //// External functions

    /**
    @dev The function withdraws unlocked funds for the specified user. 
    Anyone can call instead of the user.
    @param vestingId vesting program id.
    @param userAddress user wallet address.
    */
    function unvestFor(uint256 vestingId, address userAddress)
        external
        notInited
        isEnded(vestingId)
    {
        _unvest(vestingId, userAddress);
    }

    /**
    @dev The function performs the withdrawal of unlocked funds.
    @param vestingId vesting program id.
    */
    function unvest(uint256 vestingId) external notInited isEnded(vestingId) {
        _unvest(vestingId, msg.sender);
    }

    /// @notice Transferring funds from the wallet of the selected token contract to the specified wallet
    /// @dev Used for the owner to withdraw funds
    /// @param to Address owner (Example)
    /// @param tokenAddress Token address from which tokens will be transferred
    /// @param amount Amount of transferred tokens
    function rescue(
        address to,
        address tokenAddress,
        uint256 amount
    ) external onlyOwner {
        if (to == address(0) || tokenAddress == address(0)) {
            revert ZeroAddress("Vesting: Cannot rescue to the zero address");
        }
        if (amount == 0) {
            revert RescueZeroValue("Vesting: Cannot rescue 0");
        }
        IERC20(tokenAddress).safeTransfer(to, amount);
        emit RescueToken(to, address(tokenAddress), amount);
    }

    //// Public functions

    /**
    @dev The function calculates the available amount of funds 
    for unvest for a certain user.
    @param vestingId vesting program id.
    @param userAddress user wallet address.
    @return unvestedAmount available amount of funds for unvest for a certain user.
    @return lastUserUnvesting timestamp when user do last unvest.
    @return totalUserUnvested the sum of all funds received user after unvest.
    @return totalUnvested the entire amount of funds of the vesting program that was withdrawn from vesting
    */
    function getUserUnvestedAmount(uint256 vestingId, address userAddress)
        public
        view
        notInited
        returns (
            uint256 unvestedAmount,
            uint256 lastUserUnvesting,
            uint256 totalUserUnvested,
            uint256 totalUnvested
        )
    {
        User storage user = userInfo[userAddress][vestingId];
        VestingProgram storage vestingProgram = vestingPrograms[vestingId];

        if (block.timestamp < vestingProgram.startTime) {
            revert VestingNotStarted("Vesting: Not started");
        }

        if (user.totalVested == 0) {
            revert NotVester("Vesting: Not a vester");
        }

        if (block.timestamp < vestingProgram.endTime) {
            uint256 userVestingTime = block.timestamp - user.lastUnvesting;
            uint256 payouts = userVestingTime / vestingProgram.periodDuration;
            unvestedAmount =
                ((user.totalVested * vestingProgram.unlockPercentage) /
                    PRECISSION) *
                payouts;
            lastUserUnvesting =
                user.lastUnvesting +
                (vestingProgram.periodDuration * payouts);
            totalUserUnvested = user.totalUnvested + unvestedAmount;
            totalUnvested = vestingProgram.unvestedAmount + unvestedAmount;
        } else {
            unvestedAmount = user.totalVested - user.totalUnvested;
            if (unvestedAmount > 0) {
                lastUserUnvesting = vestingProgram.endTime;
                totalUserUnvested = user.totalVested;
                totalUnvested = vestingProgram.unvestedAmount + unvestedAmount;
            }
        }
    }

    //// Internal functions

    /**
    @dev The function withdraws unlocked funds for the specified user. 
    Anyone can call instead of the user.
    @param vestingId vesting program id.
    @param userAddress user wallet address.
    */
    function _unvest(uint256 vestingId, address userAddress) internal {
        if (userAddress == address(0)) {
            revert ZeroAddress("Vesting: Zero address");
        }
        User storage user = userInfo[userAddress][vestingId];
        VestingProgram storage vestingProgram = vestingPrograms[vestingId];

        if (block.timestamp <= vestingProgram.startTime) {
            revert VestingNotStarted("Vesting: Not started");
        }

        if (!isVester[userAddress][vestingId]) {
            revert NotVester("Vesting: Zero balance");
        }

        (
            uint256 unvestedAmount,
            uint256 lastUserUnvesting,
            uint256 totalUserUnvested,
            uint256 totalUnvested
        ) = getUserUnvestedAmount(vestingId, userAddress);

        user.lastUnvesting = lastUserUnvesting;
        user.totalUnvested = totalUserUnvested;

        if (unvestedAmount == 0) {
            revert ZeroAmountToUnvest("Vesting: Zero unvest amount");
        } else {
            if (
                unvestedAmount + vestingProgram.unvestedAmount >=
                vestingProgram.vestingAmount
            ) {
                unvestedAmount =
                    vestingProgram.vestingAmount -
                    vestingProgram.unvestedAmount;
            }
            vestingProgram.unvestedAmount = totalUnvested;
            IERC20(vestingToken).safeTransfer(userAddress, unvestedAmount);
            emit Unvest(userAddress, unvestedAmount, vestingId);
        }

        if (vestingProgram.unvestedAmount == vestingProgram.vestingAmount) {
            vestingProgram.isEnded = true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

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

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title A PlanetexToken, symbol TPTX

// allocations
// Pre-sale - 7%
// Main Sale - 6%
// Private Sale - 3%
// IDO - 9%
// Team - 10%
// Advisors - 2,5%
// Launchpad - 0,5%
// Airdrop & Marketing - 15%
// Treasury - 20%
// Liquidity - 10%
// Ecosistem - 10%
// Platform Reward (Staking, etc.) - 7%

contract PlanetexToken is ERC20, Ownable {
    uint256 public immutable PRECISSION = 1000;

    error InvalidArrayLengths(string err);
    error ZeroAddress(string err);
    error ZeroPercent(string err);

    constructor(
        address[] memory recipients,
        uint256[] memory percents,
        uint256 totalSupply
    ) ERC20("PlanetexToken", "PLTEX") {
        if (recipients.length != percents.length) {
            revert InvalidArrayLengths("PlanetexToken: Invalid array lengths");
        }
        for (uint256 i; i <= recipients.length - 1; i++) {
            if (percents[i] == 0) {
                revert ZeroPercent("PlanetexToken: Zero percent");
            }
            if (recipients[i] == address(0)) {
                revert ZeroAddress("PlanetexToken: Zero address");
            }
            uint256 mintAmount = (totalSupply * percents[i]) / PRECISSION;
            _mint(recipients[i], mintAmount);
        }
    }
}

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/ITokenSale.sol";

pragma solidity 0.8.17;

contract MarketingAndAdvisorsVesting is Ownable {
    using SafeERC20 for IERC20;
    using Address for address;

    struct VestingProgram {
        uint256 startTime; // user vesting program start time timestamp
        uint256 endTime; // user vesting program end time timestamp
        uint256 cliffDuration; // cliff period duration in seconds
        uint256 duration; // vesting duration in seconds
        uint256 vestingAmount; // total vested amount
        uint256 totalActiveVested; // total active vested amount
        uint256 unvestedAmount; // total unvested amount
        uint256 startUnlockPercentage; // start unlock percentage
        uint256 unlockPercentage; // period unlock percentage
        uint256 periodDuration; // unlock period duration in seconds
        uint256 vestingType; // 0 - airdrop, 1 - advisors
        bool isEnded; // active vesting if true, if false vesting is end
    }

    struct User {
        uint256 lastUnvesting; // last  unvest timestamp
        uint256 totalVested; // total user vested amount
        uint256 totalUnvested; // total user unvested amount
        bool isGetStartUnlockAmount; // received or not received the initial unlocked funds
    }

    address public vestingToken; // planetex token address
    address public tokenSale; // tokenSale contract address
    uint256 public vestingProgramsCounter; // quantity of vesting programs
    uint256 public immutable PRECISSION = 10000; // precission for math operation
    bool public isInitialized = false; // if true, the contract is initialized, if false, then not

    mapping(uint256 => VestingProgram) public vestingPrograms; // return VestingProgram info (0 - airdrop, 1 - advisors)
    mapping(address => mapping(uint256 => User)) public userInfo; // return user info
    mapping(address => mapping(uint256 => bool)) public isVester; // bool if true then user is vesting member else not a member

    //// @errors

    //// @dev - cannot unvest 0;
    error ZeroAmountToUnvest(string err);
    //// @dev - cannot 0
    error ZeroAmount(string err);
    //// @dev - unequal length of arrays
    error InvalidArrayLengths(string err);
    /// @dev - user is not a member of the vesting program
    error NotVester(string err);
    //// @dev - vesting program is ended
    error VestingIsEnd(string err);
    //// @dev - vesting program not started
    error VestingNotStarted(string err);
    //// @dev - there is no vesting program with this id
    error VestingProgramNotFound(string err);
    //// @dev - address to the zero;
    error ZeroAddress(string err);
    //// @dev - not enough tokens in balance
    error TokensNotEnough(string err);
    //// @dev - user is not a vester
    error IsVester(string err);
    //// @dev - Cannot rescue 0;
    error RescueZeroValue(string err);
    //// @dev - cannot initialized contract again
    error ContractIsInited(string err);
    //// @dev - cannot call methods if contract not inited
    error ContractIsNotInited(string err);

    ////@notice emitted when the user has joined the vesting program
    event Vest(
        address indexed user,
        uint256 indexed vestAmount,
        uint256 indexed vestingProgramId
    );
    ////@notice emitted when the user gets ownership of the tokens
    event Unvest(
        address indexed user,
        uint256 indexed unvestedAmount,
        uint256 indexed vestingProgramId
    );
    /// @notice Transferring funds from the wallet еther of the selected token contract to the specified wallet
    event RescueToken(
        address indexed to,
        address indexed token,
        uint256 indexed amount
    );

    function initialize(
        address _vestingToken, // planetex token contract address
        address _tokenSale, // tokenSale contract address
        uint256[] memory _durations, // array of vesting durations in seconds
        uint256[] memory _cliffDurations, // array of cliff period durations in the seconds
        uint256[] memory _startUnlockPercentages, // array of start unlock percentages
        uint256[] memory _unlockPercentages, // array of unlock percentages every unlock period
        uint256[] memory _totalSupplyPercentages, // array of percentages of tokens from totalSupply
        uint256[] memory _vestingTypes, // array of vesting types. 0 - airdrop; 1 - advisors;
        uint256[] memory _periodDurations // array of unlock period durations in secconds
    ) external onlyOwner isInited {
        if (
            _durations.length != _cliffDurations.length ||
            _durations.length != _startUnlockPercentages.length ||
            _durations.length != _unlockPercentages.length ||
            _durations.length != _totalSupplyPercentages.length ||
            _durations.length != _vestingTypes.length ||
            _durations.length != _periodDurations.length
        ) {
            revert InvalidArrayLengths("Vesting: Invalid array lengths");
        }
        if (_vestingToken == address(0) || _tokenSale == address(0)) {
            revert ZeroAddress("Vesting: Zero address");
        }
        vestingToken = _vestingToken;
        uint256 totalSupply = IERC20(_vestingToken).totalSupply();
        for (uint256 i; i <= _durations.length - 1; i++) {
            VestingProgram storage vestingProgram = vestingPrograms[i];
            vestingProgram.duration = _durations[i];
            vestingProgram.startTime =
                ITokenSale(_tokenSale).getRoundStartTime(0) +
                _cliffDurations[i];
            vestingProgram.endTime = vestingProgram.startTime + _durations[i];
            vestingProgram.cliffDuration = _cliffDurations[i];
            vestingProgram.vestingAmount =
                (_totalSupplyPercentages[i] * totalSupply) /
                PRECISSION;
            vestingProgram.startUnlockPercentage = _startUnlockPercentages[i];
            vestingProgram.unlockPercentage = _unlockPercentages[i];
            vestingProgram.periodDuration = _periodDurations[i];
            vestingProgram.vestingType = _vestingTypes[i];
            vestingProgram.totalActiveVested = 0;
            vestingProgram.unvestedAmount = 0;
            vestingProgram.isEnded = false;
        }
        isInitialized = true;
        vestingProgramsCounter = _durations.length - 1;
    }

    /**
    @dev The modifier checks whether the vesting program has not expired.
    @param vestingId vesting program id.
    */
    modifier isEnded(uint256 vestingId) {
        VestingProgram storage vestingProgram = vestingPrograms[vestingId];
        if (vestingId > vestingProgramsCounter) {
            revert VestingProgramNotFound("Vesting: Program not found");
        }
        if (vestingProgram.isEnded) {
            revert VestingIsEnd("Vesting: Vesting is end");
        }
        _;
    }

    /**
    @dev The modifier checks whether the contract has been initialized.
    Prevents reinitialization.
    */
    modifier isInited() {
        if (isInitialized) {
            revert ContractIsInited("Vesting: Already initialized");
        }
        _;
    }

    /**
    @dev The modifier checks if the contract has been initialized. 
    Prevents functions from being called before the contract is initialized.
    */
    modifier notInited() {
        if (!isInitialized) {
            revert ContractIsNotInited("Vesting: Not inited");
        }
        _;
    }

    //// External functions

    /**
    @dev the function adds a new user to the vesting program.
    Only owner can call it.
    @param vestingId vesting program id.
    @param userAddress user wallet address.
    @param vestAmount user vest amount.
    */
    function vest(
        uint256 vestingId,
        address userAddress,
        uint256 vestAmount
    ) external notInited isEnded(vestingId) onlyOwner {
        _vest(vestingId, userAddress, vestAmount);
    }

    /**
    @dev the function adds a new user`s to the vesting program.
    Only owner can call it.
    @param vestingId vesting program id.
    @param userAddresses array of user wallet addresses.
    @param vestAmounts array of user vest amounts.
    */
    function vestUsers(
        uint256 vestingId,
        address[] memory userAddresses,
        uint256[] memory vestAmounts
    ) external notInited isEnded(vestingId) onlyOwner {
        if (userAddresses.length != vestAmounts.length) {
            revert InvalidArrayLengths("Vesting: Invalid array lengths");
        }
        for (uint256 i; i <= userAddresses.length - 1; i++) {
            _vest(vestingId, userAddresses[i], vestAmounts[i]);
        }
    }

    /**
    @dev The function withdraws unlocked funds for the specified user. 
    Anyone can call instead of the user.
    @param vestingId vesting program id.
    @param userAddress user wallet address.
    */
    function unvestFor(uint256 vestingId, address userAddress)
        external
        notInited
        isEnded(vestingId)
    {
        _unvest(vestingId, userAddress);
    }

    /**
    @dev The function performs the withdrawal of unlocked funds.
    @param vestingId vesting program id.
    */
    function unvest(uint256 vestingId) external notInited isEnded(vestingId) {
        _unvest(vestingId, msg.sender);
    }

    /// @notice Transferring funds from the wallet of the selected token contract to the specified wallet
    /// @dev Used for the owner to withdraw funds
    /// @param to Address owner (Example)
    /// @param tokenAddress Token address from which tokens will be transferred
    /// @param amount Amount of transferred tokens
    function rescue(
        address to,
        address tokenAddress,
        uint256 amount
    ) external onlyOwner {
        if (to == address(0) || tokenAddress == address(0)) {
            revert ZeroAddress("Vesting: Cannot rescue to the zero address");
        }
        if (amount == 0) {
            revert RescueZeroValue("Vesting: Cannot rescue 0");
        }
        IERC20(tokenAddress).safeTransfer(to, amount);
        emit RescueToken(to, address(tokenAddress), amount);
    }

    //// Public functions

    /**
    @dev The function calculates the available amount of funds 
    for unvest for a certain user.
    @param vestingId vesting program id.
    @param userAddress user wallet address.
    @return unvestedAmount available amount of funds for unvest for a certain user.
    @return lastUserUnvesting timestamp when user do last unvest.
    @return totalUserUnvested the sum of all funds received user after unvest.
    @return totalUnvested the entire amount of funds of the vesting program that was withdrawn from vesting
    @return payStartUnlock indicates whether the starting unlocked funds have been received
    */
    function getUserUnvestedAmount(uint256 vestingId, address userAddress)
        public
        view
        notInited
        returns (
            uint256 unvestedAmount,
            uint256 lastUserUnvesting,
            uint256 totalUserUnvested,
            uint256 totalUnvested,
            bool payStartUnlock
        )
    {
        User storage user = userInfo[userAddress][vestingId];
        VestingProgram storage vestingProgram = vestingPrograms[vestingId];

        if (!isVester[userAddress][vestingId]) {
            revert NotVester("SaleVesting: Not a vester");
        }

        if (block.timestamp < vestingProgram.startTime) {
            revert VestingNotStarted("Vesting: Not started");
        }

        if (block.timestamp < vestingProgram.endTime) {
            uint256 userVestingTime = block.timestamp - user.lastUnvesting;
            uint256 payouts = userVestingTime / vestingProgram.periodDuration;
            unvestedAmount =
                ((user.totalVested * vestingProgram.unlockPercentage) /
                    PRECISSION) *
                payouts;
            if (vestingProgram.startUnlockPercentage > 0) {
                if (!user.isGetStartUnlockAmount) {
                    unvestedAmount += ((user.totalVested *
                        vestingProgram.startUnlockPercentage) / PRECISSION);
                    payStartUnlock = true;
                }
            }
            lastUserUnvesting =
                user.lastUnvesting +
                (vestingProgram.periodDuration * payouts);
            totalUserUnvested = user.totalUnvested + unvestedAmount;
            totalUnvested = vestingProgram.unvestedAmount + unvestedAmount;
        } else {
            unvestedAmount = user.totalVested - user.totalUnvested;
            if (unvestedAmount > 0) {
                lastUserUnvesting = vestingProgram.endTime;
                totalUserUnvested = user.totalVested;
                totalUnvested = vestingProgram.unvestedAmount + unvestedAmount;
            }
        }
    }

    //// Internal functions

    /**
    @dev The function withdraws unlocked funds for the specified user. 
    Anyone can call instead of the user.
    @param vestingId vesting program id.
    @param userAddress user wallet address.
    */
    function _unvest(uint256 vestingId, address userAddress) internal {
        if (userAddress == address(0)) {
            revert ZeroAddress("Vesting: Zero address");
        }
        if (!isVester[userAddress][vestingId]) {
            revert NotVester("Vesting: Not a vester");
        }
        User storage user = userInfo[userAddress][vestingId];
        VestingProgram storage vestingProgram = vestingPrograms[vestingId];

        if (block.timestamp < vestingProgram.startTime) {
            revert VestingNotStarted("Vesting: Not started");
        }

        if (
            vestingProgram.unvestedAmount == vestingProgram.vestingAmount ||
            user.totalVested == user.totalUnvested
        ) {
            revert VestingIsEnd("Vesting: Vesting is end");
        }

        (
            uint256 unvestedAmount,
            uint256 lastUserUnvesting,
            uint256 totalUserUnvested,
            uint256 totalUnvested,
            bool payStartUnlock
        ) = getUserUnvestedAmount(vestingId, userAddress);

        if (!user.isGetStartUnlockAmount) {
            user.isGetStartUnlockAmount = payStartUnlock;
        }

        user.lastUnvesting = lastUserUnvesting;
        user.totalUnvested = totalUserUnvested;

        if (unvestedAmount == 0) {
            revert ZeroAmountToUnvest("Vesting: Zero unvest amount");
        } else {
            if (
                unvestedAmount + vestingProgram.unvestedAmount >=
                vestingProgram.vestingAmount
            ) {
                unvestedAmount =
                    vestingProgram.vestingAmount -
                    vestingProgram.unvestedAmount;
            }
            vestingProgram.unvestedAmount = totalUnvested;
            IERC20(vestingToken).safeTransfer(userAddress, unvestedAmount);
            emit Unvest(userAddress, unvestedAmount, vestingId);
        }

        if (vestingProgram.unvestedAmount == vestingProgram.vestingAmount) {
            vestingProgram.isEnded = true;
        }
    }

    /**
    @dev the function adds a new user to the vesting program.
    Only owner can call it.
    @param vestingId vesting program id.
    @param userAddress user wallet address.
    @param vestAmount user vest amount.
    */
    function _vest(
        uint256 vestingId,
        address userAddress,
        uint256 vestAmount
    ) internal {
        User storage user = userInfo[userAddress][vestingId];
        VestingProgram storage vestingProgram = vestingPrograms[vestingId];
        if (
            vestAmount >
            vestingProgram.vestingAmount - vestingProgram.totalActiveVested
        ) {
            revert TokensNotEnough("Vesting: Tokens not enough");
        }
        if (userAddress == address(0)) {
            revert ZeroAddress("Vesting: Zero address");
        }
        if (vestAmount == 0) {
            revert ZeroAmount("Vesting: Zero amount");
        }
        if (isVester[userAddress][vestingId]) {
            revert IsVester("Vesting: Already in vesting");
        }
        isVester[userAddress][vestingId] = true;
        vestingProgram.totalActiveVested += vestAmount;
        user.totalVested = vestAmount;
        user.totalUnvested = 0;
        user.lastUnvesting = vestingProgram.startTime;
        user.isGetStartUnlockAmount = false;
        emit Vest(userAddress, vestAmount, vestingId);
    }
}