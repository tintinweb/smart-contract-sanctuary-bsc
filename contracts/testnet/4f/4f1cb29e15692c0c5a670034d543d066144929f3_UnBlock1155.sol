/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.2;

// import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(
            _initializing || !_initialized,
            "Initializable: contract is already initialized"
        );

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}

interface IERC165Upgradeable {
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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {}

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    uint256[50] private __gap;
}

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );
    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);

    /**
     * @dev xref:ROOT:ERC1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator)
        external
        view
        returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:ERC1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURIUpgradeable is IERC1155Upgradeable {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);
}

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
}

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165Upgradeable {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

contract ERC1155Upgradeable is
    Initializable,
    ContextUpgradeable,
    ERC165Upgradeable,
    IERC1155Upgradeable,
    IERC1155MetadataURIUpgradeable,
    IERC2981
{
    using AddressUpgradeable for address;
    string private _name;
    string private _symbol;
    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) public _balances;
    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => string) private _tokenURIs;
    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    function __ERC1155_init(
        string memory uri_,
        string memory name_,
        string memory symbol_
    ) internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC1155_init_unchained(uri_, name_, symbol_);
    }

    function __ERC1155_init_unchained(
        string memory uri_,
        string memory name_,
        string memory symbol_
    ) internal initializer {
        _setURI(uri_);
        _name = name_;
        _symbol = symbol_;
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
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165Upgradeable, IERC165Upgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC1155Upgradeable).interfaceId ||
            interfaceId == type(IERC1155MetadataURIUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return _tokenURIs[tokenId];
    }

    function _setTokenURI(uint256 tokenId, string memory tokenuri) internal {
        _tokenURIs[tokenId] = tokenuri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            account != address(0),
            "ERC1155: balance query for the zero address"
        );
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(
            accounts.length == ids.length,
            "ERC1155: accounts and ids length mismatch"
        );

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal {
        _operatorApprovals[owner][operator] = approved;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        require(
            _msgSender() != operator,
            "ERC1155: setting approval status for self"
        );

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, address(this)),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");
        address operator = _msgSender();
        _beforeTokenTransfer(
            operator,
            from,
            to,
            _asSingletonArray(id),
            _asSingletonArray(amount),
            data
        );
        uint256 fromBalance = _balances[id][from];
        require(
            fromBalance >= amount,
            "ERC1155: insufficient balance for transfer"
        );
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:ERC1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(
            ids.length == amounts.length,
            "ERC1155: ids and amounts length mismatch"
        );
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(
                fromBalance >= amount,
                "ERC1155: insufficient balance for transfer"
            );
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(
            operator,
            from,
            to,
            ids,
            amounts,
            data
        );
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `account`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - If `account` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            address(0),
            account,
            _asSingletonArray(id),
            _asSingletonArray(amount),
            data
        );

        _balances[id][address(this)] += amount;
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(
            operator,
            address(0),
            account,
            id,
            amount,
            data
        );
    }

    /**
     * @dev xref:ROOT:ERC1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(
            ids.length == amounts.length,
            "ERC1155: ids and amounts length mismatch"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }
        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(
            operator,
            address(0),
            to,
            ids,
            amounts,
            data
        );
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `account`
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have atleast `amount` tokens of token type `id`.
     */
    function _burn(
        address account,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            account,
            address(0),
            _asSingletonArray(id),
            _asSingletonArray(amount),
            ""
        );

        uint256 accountBalance = _balances[id][account];
        require(
            accountBalance >= amount,
            "ERC1155: burn amount exceeds balance"
        );
        unchecked {
            _balances[id][account] = accountBalance - amount;
        }

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try
                IERC1155ReceiverUpgradeable(to).onERC1155Received(
                    operator,
                    from,
                    id,
                    amount,
                    data
                )
            returns (bytes4 response) {
                if (
                    response !=
                    IERC1155ReceiverUpgradeable.onERC1155Received.selector
                ) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try
                IERC1155ReceiverUpgradeable(to).onERC1155BatchReceived(
                    operator,
                    from,
                    ids,
                    amounts,
                    data
                )
            returns (bytes4 response) {
                if (
                    response !=
                    IERC1155ReceiverUpgradeable.onERC1155BatchReceived.selector
                ) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element)
        private
        pure
        returns (uint256[] memory)
    {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }

    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    /**
     * @inheritdoc IERC2981
     */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        public
        view
        virtual
        override
        returns (address, uint256)
    {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[_tokenId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (_salePrice * royalty.royaltyFraction) /
            _feeDenominator();

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
    function _setDefaultRoyalty(address receiver, uint96 feeNumerator)
        internal
        virtual
    {
        require(
            feeNumerator <= _feeDenominator(),
            "ERC2981: royalty fee will exceed salePrice"
        );
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
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) internal virtual {
        require(
            feeNumerator <= _feeDenominator(),
            "ERC2981: royalty fee will exceed salePrice"
        );
        require(receiver != address(0), "ERC2981: Invalid parameters");

        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Resets royalty information for the token id back to the global default.
     */
    function _resetTokenRoyalty(uint256 tokenId) internal virtual {
        delete _tokenRoyaltyInfo[tokenId];
    }

    uint256[47] private __gap;
}

/**
 * @dev _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}

/**
 * @dev Extension of {ERC1155} that allows token holders to destroy both their
 * own tokens and those that they have been approved to use.
 *
 * _Available since v3.1._
 */
abstract contract ERC1155BurnableUpgradeable is
    Initializable,
    ERC1155Upgradeable,
    OwnableUpgradeable
{
    function __ERC1155Burnable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC1155Burnable_init_unchained();
        __Ownable_init();
    }

    function __ERC1155Burnable_init_unchained() internal initializer {}

    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public virtual {
        require(
            account == _msgSender() ||
                isApprovedForAll(account, address(this)) ||
                owner() == _msgSender(),
            "ERC1155: caller is not owner nor approved"
        );

        _burn(account, id, value);
    }

    uint256[50] private __gap;
}

library SafeMathUpgradeable {
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

interface IERC20Upgradeable {
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

    function decimals() external view returns (uint8);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract UnBlock1155 is
    Initializable,
    ERC1155Upgradeable,
    OwnableUpgradeable,
    ERC1155BurnableUpgradeable
{
    event CancelOrder(address indexed from, uint256 indexed tokenId);
    event Create(uint256 indexed tokenId);
    event ChangePrice(
        address indexed from,
        uint256 indexed tokenId,
        uint256 indexed value
    );
    event TokenId(address indexed from, uint256 indexed id);
    using SafeMathUpgradeable for uint256;

    struct Order {
        uint256 tokenId;
        uint256 price;
        address contractAddress;
    }
    struct SubscribeNFT {
        uint256 tokenId;
        uint256 subPrice;
        uint256 subPeriod;
    }
    struct userSubscrption {
        uint256 tokenId;
        uint256 subPrice;
        uint256 subStartPeriod;
        uint256 subEndPeriod;
    }

    mapping(uint256 => address) public _creator;
    mapping(uint256 => uint256) public _royal;
    mapping(uint256 => SubscribeNFT) public _subscribeNFT;
    mapping(address => userSubscrption) public _userSubscrption;
    uint256 public _tid;
    uint256 public totalmint;
    uint256 public unsubscripetionLimit;

    mapping(address => mapping(uint256 => Order)) public order_place;
    mapping(string => address) private tokentype;
    mapping(address => mapping(address => bool)) public approveStatus;
    mapping(uint256 => mapping(address => uint256)) public _unblockBalances;

    uint256 private serviceValue;
    uint256 private sellervalue;
    bool public publicMint;
    uint256 deci;
    mapping(address => mapping(uint256 => userSubscrption)) public userSubscrptiondata;
    function initialize() public initializer {
        ERC1155Upgradeable.__ERC1155_init("", "UnBlock1155", "UnBlock1155");
        __Ownable_init();
        _tid = 1;
        serviceValue = 2000000000000000000;
        sellervalue = 2000000000000000000;
        deci = 18;
        unsubscripetionLimit = 5;
    }

    function getServiceFee() public view returns (uint256, uint256) {
        return (serviceValue, sellervalue);
    }

    function setServiceValue(uint256 _serviceValue, uint256 sellerfee)
        public
        onlyOwner
    {
        serviceValue = _serviceValue;
        sellervalue = sellerfee;
    }

    function getTokenAddress(string memory _type)
        public
        view
        returns (address)
    {
        return tokentype[_type];
    }

    function addTokenType(string[] memory _type, address[] memory tokenAddress)
        public
        onlyOwner
    {
        require(
            _type.length == tokenAddress.length,
            "Not equal for Type and TokenAddress"
        );
        for (uint256 i = 0; i < _type.length; i++) {
            tokentype[_type[i]] = tokenAddress[i];
        }
    }

    function getTokenIds(uint256 supply) internal returns (uint256) {
        uint256 id = totalmint;
        totalmint = totalmint.add(supply);
        return id;
    }

    function orderPlace(
        uint256 tokenId,
        uint256 _price,
        address _conAddress,
        string memory _status
    ) public {
        if (
            keccak256(abi.encodePacked((_status))) ==
            keccak256(abi.encodePacked(("order")))
        ) {
            require(_unblockBalances[tokenId][msg.sender] > 0, "Not a Owner");
            require(
                userSubscrptiondata[msg.sender][tokenId].subEndPeriod.add(
                    unsubscripetionLimit.mul(1 days)
                ) < block.timestamp,
                "NFT Selling Period Completed"
            );
        }
        require(_price > 0, "Price Must be greater than zero");
        approveStatus[msg.sender][_conAddress] = true;
        Order memory order;
        order.tokenId = tokenId;
        order.price = _price;
        order.contractAddress = _conAddress;
        order_place[msg.sender][tokenId] = order;
    }

    function minting(
        string[] memory ipfsmetadata,
        uint256[] memory supply,
        uint256[] memory royal,
        uint256[] memory price,
        uint256[] memory _subPrice,
        uint256[] memory _subPeriod
    ) public returns (uint256 [] memory){
        require(
            msg.sender == owner(),
            "Public Mint Not Available"
        );
        uint256 id = getTokenIds(ipfsmetadata.length);
        uint256[] memory tokenId = new uint256[](ipfsmetadata.length);
        for (uint256 i = 0; i < ipfsmetadata.length; i++) {
            id = id.add(1);
            _creator[id] = owner();
            _mint(msg.sender, id, supply[i], "");
            _setTokenURI(id, ipfsmetadata[i]);
            _setTokenRoyalty(id, owner(), uint96(royal[i].div(1e16)));
            _royal[id] = royal[i];
            if (price[i] > 0) {
                orderPlace(id, price[i], msg.sender, "mint");
            }
            initialSubscriptionNFT(id, _subPrice[i],_subPeriod[i]);
            _unblockBalances[id][msg.sender] = supply[i];
            tokenId[i] = id;
            emit Create(tokenId[i]);
        }
        return tokenId;
    }
    
    // ids[0] - tokenId, ids[1] - amount, ids[2] -  nooftoken
    function saleWithToken(
        string memory bidtoken,
        address payable from,
        uint256[] memory ids
    ) public {
       require(
            userSubscrptiondata[from][ids[0]].subEndPeriod.add(
                unsubscripetionLimit.mul(1 days)
            ) <
                block.timestamp ||
                from == owner(),
            "NFT Selling Period Completed"
        );
        require(
            ids[2] == 1 &&
                (_unblockBalances[ids[0]][msg.sender] == 0 ||
                    userSubscrptiondata[msg.sender][ids[0]].subEndPeriod.add(
                        unsubscripetionLimit.mul(1 days)
                    ) <
                    block.timestamp),
            "Already You have this NFT or Only Purchase One NFT"
        );
        require(
            ids[1].sub(_subscribeNFT[ids[0]].subPrice) == order_place[from][ids[0]].price.mul(ids[2]),
            "Order is Mismatch"
        );
        _saleToken(from, ids, bidtoken);
        _userSubscrptiondata(ids[0]);
        if (_unblockBalances[ids[0]][from].sub(ids[2]) == 0) {
            if (order_place[from][ids[0]].price > 0) {
                delete order_place[from][ids[0]];
            }
        }
        if (_unblockBalances[ids[0]][msg.sender] == 0) {
            _unblockBalances[ids[0]][msg.sender] = _unblockBalances[ids[0]][
                msg.sender
            ].add(ids[2]);
            userSubscrption memory _subUser;
            _subUser.tokenId = ids[0];
            _subUser.subPrice = _subscribeNFT[ids[0]].subPrice;
            _subUser.subEndPeriod = block.timestamp;
            userSubscrptiondata[msg.sender][ids[0]] = _subUser;
        }
        else{
            userSubscrptiondata[msg.sender][ids[0]].subStartPeriod = block.timestamp;
            userSubscrptiondata[msg.sender][ids[0]].subEndPeriod = block.timestamp.add(_subscribeNFT[ids[0]].subPeriod.mul(1 days));
        }
        _unblockBalances[ids[0]][from] = _unblockBalances[ids[0]][from].sub(
            ids[2]
        );
        delete userSubscrptiondata[from][ids[0]];
    }

    // ids[0] - tokenId, ids[1] - amount, ids[2] -  nooftoken
    function saleToken(address payable from, uint256[] memory ids)
        public
        payable
    {
        require(
            userSubscrptiondata[from][ids[0]].subEndPeriod.add(
                unsubscripetionLimit.mul(1 days)
            ) <
                block.timestamp ||
                from == owner(),
            "NFT Selling Period Completed"
        );
        require(
            ids[2] == 1 &&
                (_unblockBalances[ids[0]][msg.sender] == 0 ||
                    userSubscrptiondata[msg.sender][ids[0]].subEndPeriod.add(
                        unsubscripetionLimit.mul(1 days)
                    ) <
                    block.timestamp),
            "Already You have this NFT or Only Purchase One NFT"
        );
        _saleToken(from, ids, "ETH");
        payable(owner()).transfer(msg.value.sub(order_place[from][ids[0]].price));
        _userSubscrptiondata(ids[0]);

        if (_unblockBalances[ids[0]][from].sub(ids[2]) == 0) {

            if (order_place[from][ids[0]].price > 0) {
                delete order_place[from][ids[0]];
            }
        }
        if (_unblockBalances[ids[0]][msg.sender] == 0) {
            _unblockBalances[ids[0]][msg.sender] = _unblockBalances[ids[0]][
                msg.sender
            ].add(ids[2]);
            userSubscrption memory _subUser;
            _subUser.tokenId = ids[0];
            _subUser.subPrice = _subscribeNFT[ids[0]].subPrice;
            _subUser.subEndPeriod = block.timestamp;
            userSubscrptiondata[msg.sender][ids[0]] = _subUser;
        }
        else{
            userSubscrptiondata[msg.sender][ids[0]].subStartPeriod = 0;
            userSubscrptiondata[msg.sender][ids[0]].subEndPeriod = block.timestamp;
        }
        _unblockBalances[ids[0]][from] = _unblockBalances[ids[0]][from].sub(
            ids[2]
        );
        if(from != owner()){
            delete userSubscrptiondata[from][ids[0]];
        }
    }

    // ids[0] - tokenId, ids[1] - amount, ids[2] -  nooftoken, ids[3] - nftType
    //ldatas[0] = _royal, ldatas[1] = Tokendecimals, ldatas[2] = approveValue, ldatas[3] = _adminfee,
    //ldatas[4] = roy, ldatas[5] = netamount, ldatas[6] = val
    function _saleToken(
        address payable from,
        uint256[] memory ids,
        string memory bidtoken
    ) internal {
        uint256[7] memory ldatas;
        ldatas[0] = _royal[ids[0]];
        ldatas[6] = pERCent(ids[1], serviceValue).add(ids[1]);
        if (
            keccak256(abi.encodePacked((bidtoken))) ==
            keccak256(abi.encodePacked(("ETH")))
        ) {
            require(msg.value == ldatas[6].add(_subscribeNFT[ids[0]].subPrice), "Mismatch the msg.value");
            (ldatas[3], ldatas[4], ldatas[5]) = calc(
                ids[1],
                ldatas[0],
                serviceValue,
                sellervalue
            );
            require(
                msg.value.sub(_subscribeNFT[ids[0]].subPrice) == ldatas[3].add(ldatas[4].add(ldatas[5])),
                "Missmatch the fees amount"
            );
            if (ldatas[3] != 0) {
                payable(owner()).transfer(ldatas[3]);
            }
            if (ldatas[4] != 0) {
                payable(_creator[ids[0]]).transfer(ldatas[4]);
            }
            if (ldatas[5] != 0) {
                from.transfer(ldatas[5]);
            }
        } else {
            IERC20Upgradeable t = IERC20Upgradeable(tokentype[bidtoken]);
            ldatas[1] = deci.sub(t.decimals());
            ldatas[2] = t.allowance(msg.sender, address(this));
            (ldatas[3], ldatas[4], ldatas[5]) = calc(
                ids[1],
                ldatas[0],
                serviceValue,
                sellervalue
            );
            if (ldatas[3] != 0) {
                t.transferFrom(
                    msg.sender,
                    owner(),
                    ldatas[3].div(10**ldatas[1])
                );
            }
            if (ldatas[4] != 0) {
                t.transferFrom(
                    msg.sender,
                    _creator[ids[0]],
                    ldatas[4].div(10**ldatas[1])
                );
            }
            if (ldatas[5] != 0) {
                t.transferFrom(msg.sender, from, ldatas[5].div(10**ldatas[1]));
            }
        }
    }

    function pERCent(uint256 value1, uint256 value2)
        internal
        pure
        returns (uint256)
    {
        uint256 result = value1.mul(value2).div(1e20);
        return (result);
    }

    function calc(
        uint256 amount,
        uint256 royal,
        uint256 _serviceValue,
        uint256 _sellervalue
    )
        internal
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 fee = pERCent(amount, _serviceValue);
        uint256 roy = pERCent(amount, royal);
        uint256 netamount = 0;
        if (_sellervalue != 0) {
            uint256 fee1 = pERCent(amount, _sellervalue);
            fee = fee.add(fee1);
            netamount = amount.sub(fee1.add(roy));
        } else {
            netamount = amount.sub(roy);
        }
        return (fee, roy, netamount);
    }

    // ids[0] - tokenId, ids[1] - amount, ids[2] -  nooftoken, ids[3] - nftType, isd[4] - collectionId
    function acceptBId(
        string memory bidtoken,
        address bidaddr,
        uint256[] memory ids
    ) public {
        require(
            userSubscrptiondata[msg.sender][ids[0]].subEndPeriod.add(
                unsubscripetionLimit.mul(1 days)
            ) < block.timestamp || msg.sender == owner(),
            "NFT Selling Period Completed"
        );
        require(
            ids[2] == 1 &&(_unblockBalances[ids[0]][bidaddr] == 0 ||
                    userSubscrptiondata[bidaddr][ids[0]].subEndPeriod.add(
                        unsubscripetionLimit.mul(1 days)
                    ) <
                    block.timestamp),
            "Already You have this NFT or Only Purchase One NFT"
        );
        _acceptBId(bidtoken, bidaddr, owner(), ids);

        if (_unblockBalances[ids[0]][msg.sender].sub(ids[2]) == 0) {
            if (order_place[msg.sender][ids[0]].price > 0) {
                delete order_place[msg.sender][ids[0]];
            }
        }
        if (_unblockBalances[ids[0]][bidaddr] == 0) {
            _unblockBalances[ids[0]][bidaddr] = _unblockBalances[ids[0]][
                bidaddr
            ].add(ids[2]);
            userSubscrption memory _subUser;
            _subUser.tokenId = ids[0];
            _subUser.subPrice = _subscribeNFT[ids[0]].subPrice;
            _subUser.subEndPeriod = block.timestamp;
            userSubscrptiondata[bidaddr][ids[0]] = _subUser;
        }
        else{
            userSubscrptiondata[bidaddr][ids[0]].subStartPeriod = 0;
            userSubscrptiondata[bidaddr][ids[0]].subEndPeriod = block.timestamp;
        }
        _unblockBalances[ids[0]][msg.sender] = _unblockBalances[ids[0]][msg.sender].sub(
            ids[2]
        );
        delete userSubscrptiondata[msg.sender][ids[0]];
    }

    // ids[0] - tokenId, ids[1] - amount, ids[2] -  nooftoken, ids[3] - nftType
    //ldatas[0] = _royal, ldatas[1] = Tokendecimals, ldatas[2] = approveValue, ldatas[3] = _adminfee,
    //ldatas[4] = roy, ldatas[5] = netamount, ldatas[6] = val
    function _acceptBId(
        string memory tokenAss,
        address from,
        address admin,
        uint256[] memory ids
    ) internal {
        uint256[7] memory ldatas;
        ldatas[0] = _royal[ids[0]];
        ldatas[6] = pERCent(ids[1], serviceValue).add(ids[1]);
        IERC20Upgradeable t = IERC20Upgradeable(tokentype[tokenAss]);
        ldatas[1] = deci.sub(t.decimals());
        ldatas[2] = t.allowance(from, address(this));
        (ldatas[3], ldatas[4], ldatas[5]) = calc(
            ids[1],
            ldatas[0],
            serviceValue,
            sellervalue
        );
        if (ldatas[3] != 0) {
            t.transferFrom(from, admin, ldatas[3].div(10**ldatas[1]));
        }
        if (ldatas[4] != 0) {
            t.transferFrom(
                from,
                _creator[ids[0]],
                ldatas[4].div(10**ldatas[1])
            );
        }
        if (ldatas[5] != 0) {
            t.transferFrom(from, msg.sender, ldatas[5].div(10**ldatas[1]));
        }
    }

    function cancelOrder(uint256 tokenId) public {
        delete order_place[msg.sender][tokenId];
        emit CancelOrder(msg.sender, tokenId);
    }

    function burnNFT(uint256 tokenId, uint256 amount) public onlyOwner {
        require(
            balanceOf(address(this), tokenId) >= amount &&
                _unblockBalances[tokenId][msg.sender] >= amount,
            "Not a Owner or balance Mismatch"
        );
        _unblockBalances[tokenId][msg.sender] = _unblockBalances[tokenId][
            msg.sender
        ].sub(amount);
        _burn(address(this), tokenId, amount);
    }

    function editSubscribeNFT(
        uint256 tokenId,
        uint256 amount,
        uint256 _days
    ) public onlyOwner {
        _subscribeNFT[tokenId].subPrice = amount;
        _subscribeNFT[tokenId].subPeriod = _days;
    }

    function initialSubscriptionNFT(uint256 tokenId, uint256 _subPrice, uint256 _subPeriod) internal {
        SubscribeNFT memory _SubscribeNFT;
        _SubscribeNFT.tokenId = tokenId;
        _SubscribeNFT.subPrice = _subPrice;
        _SubscribeNFT.subPeriod = _subPeriod;
        _subscribeNFT[tokenId] = _SubscribeNFT;
    }

    function nftSubscription(uint256 tokenId) public payable {
        require(
            msg.value == _subscribeNFT[tokenId].subPrice,
            "Subscription Price Mismatch"
        );
        _userSubscrptiondata(tokenId);
        payable(owner()).transfer(msg.value);
    }
    function _userSubscrptiondata(uint256 tokenId) internal {
        require(
            userSubscrptiondata[msg.sender][tokenId].subEndPeriod < block.timestamp &&
                _unblockBalances[tokenId][msg.sender] == 1,
            "Subscription Not Completed"
        );
        userSubscrptiondata[msg.sender][tokenId].tokenId = tokenId;
        userSubscrptiondata[msg.sender][tokenId].subStartPeriod = block.timestamp;
        userSubscrptiondata[msg.sender][tokenId].subEndPeriod = block.timestamp.add(
            _subscribeNFT[tokenId].subPeriod.mul(1 days)
        );
    }
    function nftReturn(uint256 tokenId, address from) public onlyOwner {
        require(
            userSubscrptiondata[from][tokenId].subEndPeriod.add(
                unsubscripetionLimit.mul(1 days)
            ) >= block.timestamp,
            "NFT Selling Period Not Completed"
        );
        if (_unblockBalances[tokenId][from].sub(1) == 0) {
            if (order_place[from][tokenId].price > 0) {
                delete order_place[from][tokenId];
            }
        }
        _unblockBalances[tokenId][msg.sender] = _unblockBalances[tokenId][msg.sender].add(1);
        _unblockBalances[tokenId][from] = _unblockBalances[tokenId][from].sub(
            1
        );
        delete userSubscrptiondata[from][tokenId];
    }
    function editUnsubscripetionLimit(uint _limit) public onlyOwner {
        unsubscripetionLimit = _limit;
    }
    
}