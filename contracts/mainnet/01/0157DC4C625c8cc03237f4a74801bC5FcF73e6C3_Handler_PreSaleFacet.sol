// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721Upgradeable.sol";
import "./IERC721ReceiverUpgradeable.sol";
import "./extensions/IERC721MetadataUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../utils/StringsUpgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

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
    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
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
        address owner = ERC721Upgradeable.ownerOf(tokenId);
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
        address owner = ERC721Upgradeable.ownerOf(tokenId);
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
        address owner = ERC721Upgradeable.ownerOf(tokenId);

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
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
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
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
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
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[44] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721Upgradeable.sol";
import "./IERC721EnumerableUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721EnumerableUpgradeable is Initializable, ERC721Upgradeable, IERC721EnumerableUpgradeable {
    function __ERC721Enumerable_init() internal onlyInitializing {
    }

    function __ERC721Enumerable_init_unchained() internal onlyInitializing {
    }
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
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC721Upgradeable) returns (bool) {
        return interfaceId == type(IERC721EnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Upgradeable.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
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
        require(index < ERC721EnumerableUpgradeable.totalSupply(), "ERC721Enumerable: global index out of bounds");
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
        uint256 length = ERC721Upgradeable.balanceOf(to);
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

        uint256 lastTokenIndex = ERC721Upgradeable.balanceOf(from) - 1;
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[46] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721EnumerableUpgradeable is IERC721Upgradeable {
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

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
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

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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

// SPDX-License-Identifier: BSD-3-Clause

pragma solidity ^0.8.0;

import "./Owners.sol";

contract EmergencyMode is Owners {
    bool public isEmergencyMode = false;

    modifier onlySafeMode() {
        require(!isEmergencyMode, "Emergency mode is activated");
        _;
    }

    modifier onlyEmergencyMode() {
        require(isEmergencyMode, "Emergency mode is not activated");
        _;
    }

    function setEmergencyMode(bool _emergency) external onlyOwners {
        isEmergencyMode = _emergency;
    }
}

// SPDX-License-Identifier: BSD-3-Clause

pragma solidity ^0.8.0;

interface INodeType {
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function burnFrom(address from, uint256[] memory tokenIds)
        external
        returns (uint256);

    function createNodeWithLuckyBox(
        address user,
        uint256[] memory tokenIds,
        string memory feature
    ) external;

    function createNodeCustom(
        address user,
        uint256[] memory tokenIds,
        string memory feature
    ) external;

    function getTotalNodesNumberOf(address user)
        external
        view
        returns (uint256);

    function getAttribute(uint256 tokenId)
        external
        view
        returns (string memory);

    function claimRewardsAll(address user) external returns (uint256, uint256);

    function claimRewardsBatch(address user, uint256[] memory tokenIds)
        external
        returns (uint256, uint256);

    function calculateUserRewards(address user)
        external
        view
        returns (uint256, uint256);

    function applyWaterpackBatch(
        address user,
        uint256[] memory tokenIds,
        uint256 ratioOfGRPExtended,
        uint256[] memory amounts
    ) external;

    function applyFertilizerBatch(
        address user,
        uint256[] memory tokenIds,
        uint256 durationEffect,
        uint256 boostAmount,
        uint256[] memory amounts
    ) external;

    function setPlotAdditionalLifetime(
        address user,
        uint256 tokenId,
        uint256 amountOfGRP
    ) external;

    function addPlotAdditionalLifetime(
        address user,
        uint256 tokenId,
        uint256 amountOfGRP,
        uint256 amount
    ) external;

    function name() external view returns (string memory);

    function totalCreatedNodes() external view returns (uint256);
}

// SPDX-License-Identifier: BSD-3-Clause

pragma solidity ^0.8.0;

interface ISpringLuckyBox {
	function createLuckyBoxesWithTokens(
		string memory name,
		uint count,
		address user
	) external returns(uint);
	
	function createLuckyBoxesAirDrop(
		string memory name,
		uint count,
		address user
	) external;
	
	function createNodesWithLuckyBoxes(
		address user,
		uint[] memory tokenIds
	)
		external
		returns(
			string[] memory,
			string[] memory
		);
}

// SPDX-License-Identifier: BSD-3-Clause

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface ISpringNode is IERC721Enumerable {
	function generateNfts(
		string memory name,
		address user,
		uint count
	)
		external
		returns(uint[] memory);
	
	function burnBatch(address user, uint[] memory tokenIds) external;

	function setTokenIdToNodeType(uint tokenId, string memory nodeType) external;

	function tokenIdsToType(uint256 tokenId) external view returns (string memory nodeType);
}

// SPDX-License-Identifier: BSD-3-Clause

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

struct PlotTypeView {
    string name;
    uint256 maxNodes;
    uint256 price;
    string[] allowedNodeTypes;
    uint256 additionalGRPTime;
    uint256 waterpackGRPBoost;
}

struct PlotInstanceView {
    string plotType;
    address owner;
    uint256[] nodeTokenIds;
}

/// @notice A plot houses trees (nodes) and adds additional lifetime to the
/// nodes it owns.
/// @dev Token IDs should start at `1`, so we can use `0` as a null value.
interface ISpringPlot is IERC721EnumerableUpgradeable {
    function createNewPlot(address user, string memory plotTypeName)
        external
        returns (uint256 price, uint256 tokenId);

    function moveNodeToPlot(
        address user,
        uint256 nodeTokenId,
        uint256 plotTokenId
    ) external;

    function moveNodesToPlots(
        address user,
        uint256[][] memory nodeTokenId,
        uint256[] memory plotTokenId
    ) external;

    function setPlotType(
        string memory name,
        uint256 price,
        uint256 maxNodes,
        string[] memory allowedNodeTypes,
        uint256 additionalGRPTime,
        uint256 waterpackGRPBoost
    ) external;

    /// @dev Returns the plot type of an instanciated plot, given its `tokenId`.
    /// Reverts if the plot doesn't exist.
    function getPlotTypeByTokenId(uint256 tokenId)
        external
        view
        returns (PlotTypeView memory);

    function findOrCreateDefaultPlot(address user)
        external
        returns (uint256 tokenId);

    function getPlotTypeByNodeTokenId(uint256 tokenId)
        external
        view
        returns (PlotTypeView memory);

    // /// @dev Returns the total amount of plot types.
    // function getPlotTypeSize() external view returns (uint256 plotTypeAmount);

    // /// @dev Returns the plot type at a given `index`. Use along with
    // /// {getPlotTypeSize} to enumerate all plot types, or {getPlotTypes}.
    // function getPlotTypeByIndex(uint256 index) external view
    //     returns (PlotTypeView memory);

    // /// @dev Returns the plot type with a given `name`. Reverts if the plot type
    // /// doesn't exist.
    // function getPlotTypeByName(string memory name) external view
    //     returns (PlotTypeView memory);

    // /// @dev Returns the list of all enumerable plot types.
    // function getPlotTypes() external view returns (PlotTypeView[] memory);

    // /// @dev Returns the number of plots detained by a given user.
    // function getPlotsOfUserSize(address user) external view
    //     returns (uint256 plotAmount);

    /// @dev Returns the plot instance of a given token id. Reverts if the plot
    /// doesn't exist.
    function getPlotByTokenId(uint256 tokenId)
        external
        view
        returns (PlotInstanceView memory);

    // /// @dev Returns the plot instance of a given user at a given `index`. Use
    // /// along with {getPlotsOfUserSize} to enumerate all plots of a user, or
    // /// {getPlotsOfUser}.
    // function getPlotsOfUserByIndex(address user, uint256 index) external view
    //     returns (PlotTypeInstance memory);

    // /// @dev Returns the list of all plots of a given user.
    // function getPlotsOfUser(address user) external view
    //     returns (PlotTypeInstance[] memory);

    // /// @dev Returns the token ID of the next available plot of a given type for
    // /// a given user, or `0` if no plot is available.
    // function getPlotTokenIdOfNextEmptyOfType(address user, string memory plotType) external view
    //     returns (uint256 plotTokenIdOrZero);

    // /// @dev Returns the token ID of the plot housing the given node. Reverts if
    // /// the node token ID is not attributed.
    // function getPlotTokenIdOfNodeTokenId(uint256 nodeTokenId) external view
    //     returns (uint256 plotTokenId);
}

// SPDX-License-Identifier: BSD-3-Clause

pragma solidity ^0.8.0;

interface ISwapper {
	function swapCreateNodesWithTokens(
		address tokenIn, 
		address user, 
		uint price,
		string memory sponso
	) external;
	
	function swapCreateNodesWithPending(
		address tokenOut, 
		address user, 
		uint rewardsTotal, 
		uint feesTotal
	) external;
	
	function swapCreateLuckyBoxesWithTokens(
		address tokenIn, 
		address user, 
		uint price,
		string memory sponso
	) external;

	function swapClaimRewardsAll(
		address tokenOut, 
		address user, 
		uint rewardsTotal, 
		uint feesTotal
	) external;

	function swapClaimRewardsBatch(
		address tokenOut, 
		address user, 
		uint rewardsTotal, 
		uint feesTotal
	) external;
	
	function swapClaimRewardsNodeType(
		address tokenOut, 
		address user, 
		uint rewardsTotal, 
		uint feesTotal
	) external;

	function swapApplyWaterpack(
		address tokenIn,
		address user,
		uint amount,
		string memory sponso
	) external;

	function swapApplyFertilizer(
		address tokenIn,
		address user,
		uint amount,
		string memory sponso
	) external;

	function swapNewPlot(
		address tokenIn,
		address user,
		uint amount,
		string memory sponso
	) external;
}

// SPDX-License-Identifier: BSD-3-Clause

pragma solidity ^0.8.0;

contract Owners {
	
	address[] public owners;
	mapping(address => bool) public isOwner;

	constructor() {
		owners.push(msg.sender);
		isOwner[msg.sender] = true;
	}

	modifier onlySuperOwner() {
		require(owners[0] == msg.sender, "Owners: Only Super Owner");
		_;
	}
	
	modifier onlyOwners() {
		require(isOwner[msg.sender], "Owners: Only Owner");
		_;
	}

	function addOwner(address _new, bool _change) external onlySuperOwner {
		require(!isOwner[_new], "Owners: Already owner");
		isOwner[_new] = true;
		if (_change) {
			owners.push(owners[0]);
			owners[0] = _new;
		} else {
			owners.push(_new);
		}
	}

	function removeOwner(address _new) external onlySuperOwner {
		require(isOwner[_new], "Owners: Not owner");
		require(_new != owners[0], "Owners: Cannot remove super owner");
		for (uint i = 1; i < owners.length; i++) {
			if (owners[i] == _new) {
				owners[i] = owners[owners.length - 1];
				owners.pop();
				break;
			}
		}
		isOwner[_new] = false;
	}

	function getOwnersSize() external view returns(uint) {
		return owners.length;
	}
}

// SPDX-License-Identifier: BSD-3-Clause

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Owners.sol";
import "./EmergencyMode.sol";

/**
 * @dev An item available to pre-order.
 */
struct Item {
    string name;
    uint256 priceRegular;
    uint256 priceWhitelisted;
}

/**
 * @dev Used by burner contracts, this is the interface that will be used to
 * consume pre-ordered items.
 */
interface IPreSaleBurnable {
    function burnItemTypeFrom(address user, uint256 itemType)
        external
        returns (
            uint256 tokenAmount,
            uint256 itemAmount,
            string memory itemName
        );
}

struct PreOrderCountItem {
    uint256 regular;
    uint256 whitelisted;
}

library PreOrderCountItemLib {
    function total(PreOrderCountItem storage item)
        internal
        view
        returns (uint256)
    {
        return item.regular + item.whitelisted;
    }

    function add(
        PreOrderCountItem storage item,
        bool isWhitelisted,
        uint256 val
    ) internal {
        if (isWhitelisted) {
            item.whitelisted += val;
        } else {
            item.regular += val;
        }
    }

    function sub(
        PreOrderCountItem storage item,
        bool isWhitelisted,
        uint256 val
    ) internal {
        if (isWhitelisted) {
            item.whitelisted -= val;
        } else {
            item.regular -= val;
        }
    }
}

struct PlacedOrder {
    uint256 amountAsRegular;
    uint256 amountAsWhitelisted;
    uint256 totalPaidAsRegular;
    uint256 totalPaidAsWhitelisted;
}

library PlacedOrderLib {
    function totalAmount(PlacedOrder storage order)
        internal
        view
        returns (uint256)
    {
        return order.amountAsRegular + order.amountAsWhitelisted;
    }

    function addAmount(
        PlacedOrder storage order,
        bool isWhitelisted,
        uint256 amount
    ) internal {
        if (isWhitelisted) {
            order.amountAsWhitelisted += amount;
        } else {
            order.amountAsRegular += amount;
        }
    }

    function subAmount(
        PlacedOrder storage order,
        bool isWhitelisted,
        uint256 amount
    ) internal {
        if (isWhitelisted) {
            order.amountAsWhitelisted -= amount;
        } else {
            order.amountAsRegular -= amount;
        }
    }

    function addTotalPaid(
        PlacedOrder storage order,
        bool isWhitelisted,
        uint256 amount
    ) internal {
        if (isWhitelisted) {
            order.totalPaidAsWhitelisted += amount;
        } else {
            order.totalPaidAsRegular += amount;
        }
    }

    function totalPaid(PlacedOrder storage order)
        internal
        view
        returns (uint256)
    {
        return order.totalPaidAsRegular + order.totalPaidAsWhitelisted;
    }

    function subTotalPaid(
        PlacedOrder storage order,
        bool isWhitelisted,
        uint256 amount
    ) internal {
        if (isWhitelisted) {
            order.totalPaidAsWhitelisted -= amount;
        } else {
            order.totalPaidAsRegular -= amount;
        }
    }

    function reset(PlacedOrder storage order)
        internal
        returns (uint256 amount, uint256 paid)
    {
        amount = order.amountAsRegular + order.amountAsWhitelisted;
        paid = order.totalPaidAsRegular + order.totalPaidAsWhitelisted;

        order.amountAsRegular = 0;
        order.amountAsWhitelisted = 0;
        order.totalPaidAsRegular = 0;
        order.totalPaidAsWhitelisted = 0;
    }
}

/**
 * @notice Locks an ERC20 token in exchange of the future right to buy an item.
 * @dev The actual item can be anything and is therefore only identified by a
 * `string`. The `burner` contract will be responsible to bind the registered
 * item name to the type of asset issued.
 */
contract PreSale is Owners, EmergencyMode, IPreSaleBurnable {
    event PreOrder(
        address user,
        uint256 itemType,
        uint256 itemAmount,
        uint256 tokenAmount
    );

    event OrderBurned(
        address user,
        uint256 itemType,
        uint256 itemAmount,
        uint256 tokenAmount
    );

    using SafeERC20 for IERC20;
    using PreOrderCountItemLib for PreOrderCountItem;
    using PlacedOrderLib for PlacedOrder;

    IERC20 public immutable paymentToken;
    Item[] public items;
    PreOrderCountItem[] public amountByItemIdx;
    PreOrderCountItem[] public tvlByItemIdx;

    mapping(address => bool) public whitelist;
    mapping(address => mapping(uint256 => PlacedOrder))
        internal userToItemIdxToAmount;

    address internal burner;
    bool public openPreOrderToRegular = false;
    bool public openPreOrderToWhitelist = false;
    bool public openToBurn = false;

    address public immutable multisig;

    uint256 public maxTVLPerRegularUser;
    uint256 public maxTVLPerWhitelistedUser;

    /**
     * @param _paymentToken Address to the token on which the orders will be
     * accepted.
     * @param itemNames Names of the items to pre-order.
     * @param itemRegularPrices Prices of the items for regular users.
     * @param itemWLPrices Prices of the items for whitelisted users.
     * @param _multisig Address of the multisig wallet allowed to access funds
     * locked in the contract.
     * @param _maxTVLs Tuple of the max TVL by user, index 0 for regular users
     * and index 1 for whitelisted users.
     */
    constructor(
        IERC20 _paymentToken,
        string[] memory itemNames,
        uint256[] memory itemRegularPrices,
        uint256[] memory itemWLPrices,
        address _multisig,
        uint256[] memory _maxTVLs
    ) {
        require(
            itemNames.length == itemRegularPrices.length &&
                itemRegularPrices.length == itemWLPrices.length,
            "Arrays must have the same length"
        );

        require(_maxTVLs.length == 2, "Invalid argument length");

        require(_multisig != address(0), "Multisig can't be the zero address");

        for (uint256 i = 0; i < itemNames.length; i++) {
            items.push(
                Item({
                    name: itemNames[i],
                    priceRegular: itemRegularPrices[i],
                    priceWhitelisted: itemWLPrices[i]
                })
            );
        }

        paymentToken = _paymentToken;
        multisig = _multisig;

        for (uint256 i = 0; i < items.length; i++) {
            amountByItemIdx.push(
                PreOrderCountItem({regular: 0, whitelisted: 0})
            );
            tvlByItemIdx.push(PreOrderCountItem({regular: 0, whitelisted: 0}));
        }

        paymentToken.safeApprove(multisig, type(uint256).max);

        maxTVLPerRegularUser = _maxTVLs[0];
        maxTVLPerWhitelistedUser = _maxTVLs[1];
    }

    //========== User-facing interface

    /**
     * @notice Places a pre-order on a given item.
     *
     * @param itemIdx The index of the pre-ordered item.
     * @param amount How many items to pre-order.
     */
    function preOrder(uint256 itemIdx, uint256 amount)
        external
        onlySafeMode
    {
        bool isWhitelisted = _isWhitelisted(msg.sender);
        require(
            (isWhitelisted && openPreOrderToWhitelist) ||
            (!isWhitelisted && openPreOrderToRegular),
            "PreSale: Pre-order is closed"
        );
        require(itemIdx < items.length, "PreSale: index out of bounds");
        require(amount > 0, "PreSale: amount can't be zero");

        Item memory item = items[itemIdx];
        uint256 maxTVL;
        uint256 tokenAmountToTransfer = amount;

        if (isWhitelisted) {
            maxTVL = maxTVLPerWhitelistedUser;
            tokenAmountToTransfer *= item.priceWhitelisted;
        } else {
            maxTVL = maxTVLPerRegularUser;
            tokenAmountToTransfer *= item.priceRegular;
        }

        require(
            tokenAmountToTransfer + getTotalValueLockedByUser(msg.sender) <=
                maxTVL,
            "PreSale: Maximum TVL reached"
        );

        _createPreOrder(msg.sender, itemIdx, amount, tokenAmountToTransfer);

        paymentToken.safeTransferFrom(
            msg.sender,
            address(this),
            tokenAmountToTransfer
        );

        emit PreOrder(msg.sender, itemIdx, amount, tokenAmountToTransfer);
    }

    /**
     * @notice Used in case of emergency, will allow users to get back their
     * all of their locked funds.
     */
    function emergencyRedeem() external onlyEmergencyMode {
        uint256 deposited = _burnAllPreOrdersForUser(msg.sender);
        require(deposited > 0, "PreSale Emergency: no deposits");
        paymentToken.safeTransfer(msg.sender, deposited);
    }

    /**
     * @notice Used in case of emergency, will allow users to get back their
     * locked funds, by item type.
     * @dev To be used if the item list is too long to be iterated on a single
     * transaction by `emergencyRedeem`. Use `getItemsSize` to iterate over all
     * the items.
     *
     * @param itemIdx The item index to redeem.
     */
    function emergencyRedeemByItem(uint256 itemIdx) public onlyEmergencyMode {
        require(itemIdx < items.length, "PreSale Emergency: out of bounds");
        (, uint256 deposited) = _burnPreOrderForUser(msg.sender, itemIdx);
        require(deposited > 0, "PreSale Emergency: no deposits");

        paymentToken.safeTransfer(msg.sender, deposited);
    }

    //========== Burner-only interface =======================================//

    /**
     * @notice Burns orders of a given user for a given item type.
     * @dev Caller must iterate manually on the item types in order to avoid
     * gas fees explosion if there is too many item types.
     *
     * @param user The user whose orders must be burned.
     * @param itemIdx The item type index of the orders to be burned.
     *
     * @return tokenAmount Amount of token that is transferred to the burner.
     * @return itemAmount How many items were ordered by the user.
     */
    function burnItemTypeFrom(address user, uint256 itemIdx)
        external
        onlySafeMode
        returns (
            uint256 tokenAmount,
            uint256 itemAmount,
            string memory itemName
        )
    {
        require(openToBurn, "PreSale: not open to burn");
        require(msg.sender == burner, "PreSale: only by Burner");
        require(user != address(0), "PreSale: null address");
        require(itemIdx < items.length, "PreSale: itemIdx out of bounds");

        itemName = items[itemIdx].name;
        (itemAmount, tokenAmount) = _burnPreOrderForUser(user, itemIdx);

        emit OrderBurned(user, itemIdx, itemAmount, tokenAmount);
    }

    //========== Multisig-only interface =====================================//

    function resetAllowance() external {
        require(msg.sender == multisig, "PreSale: only multisig");
        _resetAllowance();
    }

    function whithdraw() external {
        require(msg.sender == multisig, "PreSale: only multisig");
        paymentToken.safeTransfer(multisig, paymentToken.balanceOf(address(this)));
    }

    function refill() external {
        require(msg.sender == multisig, "PreSale: only multisig");
        uint256 thisBalance = paymentToken.balanceOf(address(this));
        uint256 neededBalance = getTotalValueLocked();

        if (thisBalance < neededBalance) {
            paymentToken.safeTransferFrom(
                multisig,
                address(this),
                neededBalance - thisBalance
            );
        }
    }

    //========== Owners-only interface =======================================//

    function setWhitelist(address[] calldata users, bool isWhitelisted)
        external
        onlyOwners
    {
        for (uint256 i = 0; i < users.length; i++) {
            whitelist[users[i]] = isWhitelisted;
        }
    }

    function setOpenPreOrderForAll(bool isOpen) external onlyOwners {
        openPreOrderToRegular = isOpen;
        openPreOrderToWhitelist = isOpen;
    }

    function setOpenPreOrderForRegular(bool isOpen) external onlyOwners {
        openPreOrderToRegular = isOpen;
    }

    function setOpenPreOrderForWhitelist(bool isOpen) external onlyOwners {
        openPreOrderToWhitelist = isOpen;
    }

    function setOpenToBurn(bool isOpen) external onlyOwners {
        openToBurn = isOpen;
    }

    function setBurner(address _burner) external onlyOwners {
        burner = _burner;
    }

    function setMaxTVLByRegularUser(uint256 maxTVL) external onlyOwners {
        maxTVLPerRegularUser = maxTVL;
    }

    function setMaxTVLByWhitelistedUser(uint256 maxTVL) external onlyOwners {
        maxTVLPerWhitelistedUser = maxTVL;
    }

    //========= Getters =======================================================/

    function getItemsSize() public view returns (uint256) {
        return items.length;
    }

    struct ItemView {
        string name;
        uint256 priceRegular;
        uint256 priceWhitelisted;
        uint256 amountCreated;
        uint256 tvl;
    }

    function getItems() public view returns (ItemView[] memory) {
        ItemView[] memory viewItems = new ItemView[](items.length);
        for (uint256 i = 0; i < items.length; i++) {
            viewItems[i] = ItemView({
                name: items[i].name,
                priceRegular: items[i].priceRegular,
                priceWhitelisted: items[i].priceWhitelisted,
                amountCreated: amountByItemIdx[i].total(),
                tvl: tvlByItemIdx[i].total()
            });
        }

        return viewItems;
    }

    struct PreOrderView {
        string itemName;
        uint256 amount;
        uint256 lockedValue;
    }

    function getPreOrdersByUser(address user)
        public
        view
        returns (PreOrderView[] memory)
    {
        PreOrderView[] memory orders = new PreOrderView[](items.length);
        for (uint256 i = 0; i < items.length; i++) {
            orders[i].itemName = items[i].name;
            orders[i].amount = userToItemIdxToAmount[user][i].totalAmount();
            orders[i].lockedValue = userToItemIdxToAmount[user][i].totalPaid();
        }

        return orders;
    }

    function getTotalValueLocked() public view returns (uint256 total) {
        for (uint256 i = 0; i < tvlByItemIdx.length; i++) {
            total += tvlByItemIdx[i].total();
        }
    }

    function getTotalValueLockedByUser(address user)
        public
        view
        returns (uint256 amount)
    {
        for (uint256 i = 0; i < items.length; i++) {
            amount += userToItemIdxToAmount[user][i].totalPaidAsRegular;
            amount += userToItemIdxToAmount[user][i].totalPaidAsWhitelisted;
        }
    }

    function getTotalValueLockedForRegularUsers()
        public
        view
        returns (uint256 total)
    {
        for (uint256 i = 0; i < tvlByItemIdx.length; i++) {
            total += tvlByItemIdx[i].regular;
        }
    }

    function getTotalValueLockedForWhitelistedUsers()
        public
        view
        returns (uint256 total)
    {
        for (uint256 i = 0; i < tvlByItemIdx.length; i++) {
            total += tvlByItemIdx[i].whitelisted;
        }
    }

    function getTotalPreOrderedItems() public view returns (uint256 total) {
        for (uint256 i = 0; i < amountByItemIdx.length; i++) {
            total += amountByItemIdx[i].total();
        }
    }

    function getTotalPreOrdersByItem(uint256 itemIdx)
        public
        view
        returns (uint256 total)
    {
        require(itemIdx < items.length, "PreSale: out of bounds");
        total = amountByItemIdx[itemIdx].total();
    }

    function getTotalPreOrderedItemsByUser(address user)
        public
        view
        returns (uint256 amount)
    {
        for (uint256 i = 0; i < items.length; i++) {
            amount += userToItemIdxToAmount[user][i].amountAsRegular;
            amount += userToItemIdxToAmount[user][i].amountAsWhitelisted;
        }
    }

    function getTotalPreOrderedItemsForRegularUsers()
        public
        view
        returns (uint256 total)
    {
        for (uint256 i = 0; i < amountByItemIdx.length; i++) {
            total += amountByItemIdx[i].regular;
        }
    }

    function getTotalPreOrderedItemsForWhitelistedUsers()
        public
        view
        returns (uint256 total)
    {
        for (uint256 i = 0; i < amountByItemIdx.length; i++) {
            total += amountByItemIdx[i].whitelisted;
        }
    }

    //========== Internal API ================================================//

    function _isWhitelisted(address user) internal view returns (bool) {
        return whitelist[user];
    }

    function _createPreOrder(
        address user,
        uint256 itemIdx,
        uint256 amount,
        uint256 totalPrice
    ) internal {
        bool isWhitelisted = _isWhitelisted(user);

        userToItemIdxToAmount[user][itemIdx].addAmount(isWhitelisted, amount);
        userToItemIdxToAmount[user][itemIdx].addTotalPaid(
            isWhitelisted,
            totalPrice
        );

        amountByItemIdx[itemIdx].add(isWhitelisted, amount);
        tvlByItemIdx[itemIdx].add(isWhitelisted, totalPrice);
    }

    function _burnPreOrderForUser(address user, uint256 itemIdx)
        internal
        returns (uint256 amount, uint256 totalPaid)
    {
        PlacedOrder storage order = userToItemIdxToAmount[user][itemIdx];

        amountByItemIdx[itemIdx].sub(true, order.amountAsWhitelisted);
        amountByItemIdx[itemIdx].sub(false, order.amountAsRegular);
        tvlByItemIdx[itemIdx].sub(true, order.totalPaidAsWhitelisted);
        tvlByItemIdx[itemIdx].sub(false, order.totalPaidAsRegular);

        (amount, totalPaid) = userToItemIdxToAmount[user][itemIdx].reset();
    }

    function _burnAllPreOrdersForUser(address user)
        internal
        returns (uint256 deposited)
    {
        deposited = 0;
        for (uint256 i = 0; i < items.length; i++) {
            PlacedOrder storage order = userToItemIdxToAmount[user][i];

            amountByItemIdx[i].sub(true, order.amountAsWhitelisted);
            amountByItemIdx[i].sub(false, order.amountAsRegular);
            tvlByItemIdx[i].sub(true, order.totalPaidAsWhitelisted);
            tvlByItemIdx[i].sub(false, order.totalPaidAsRegular);

            (, uint256 totalPaid) = order.reset();
            deposited += totalPaid;
        }
    }

    function _resetAllowance() internal {
        paymentToken.safeIncreaseAllowance(
            multisig,
            type(uint256).max -
                paymentToken.allowance(address(this), msg.sender)
        );
    }
}

// SPDX-License-Identifier: BSD-3-Clause

pragma solidity ^0.8.0;

import "../INodeType.sol";
import "../ISpringNode.sol";
import "../ISpringLuckyBox.sol";
import "../ISwapper.sol";
import "../ISpringPlot.sol";

struct NodeType {
    string[] keys; // nodeTypeName to address
    mapping(string => address) values;
    mapping(string => uint256) indexOf;
    mapping(string => bool) inserted;
}

struct Token {
    uint256[] keys; // token ids to nodeTypeName
    mapping(uint256 => string) values;
    mapping(uint256 => uint256) indexOf;
    mapping(uint256 => bool) inserted;
}

struct AppStorage {
    NodeType mapNt;
    Token mapToken;
    address nft;
    ISpringLuckyBox lucky;
    ISwapper swapper;
    ISpringPlot plot;
}

library LibAppStorage {
    function appStorage() internal pure returns (AppStorage storage s) {
        assembly {
            s.slot := 0
        }
    }

    function getTokenIdNodeTypeName(uint256 tokenId)
        internal
        view
        returns (string memory)
    {
        AppStorage storage s = LibAppStorage.appStorage();
        require(s.mapToken.inserted[tokenId], "TokenId doesnt exist");
        return s.mapToken.values[tokenId];
    }

    function nft() internal view returns (IERC721) {
        AppStorage storage s = LibAppStorage.appStorage();
        return IERC721(s.nft);
    }
}

// SPDX-License-Identifier: BSD-3-Clause

pragma solidity ^0.8.0;

struct OwnersStorage {
    bool initialized;
    address[] owners;
    mapping(address => bool) isOwner;
}

library LibOwners {
    bytes32 constant STORAGE_POSITION = keccak256("diamond.owners.storage");

    function facetStorage() internal pure returns (OwnersStorage storage s) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    function initialize() internal {
        OwnersStorage storage s = facetStorage();
        require(!s.initialized, "Owners: already initialized");

        s.owners.push(msg.sender);
        s.isOwner[msg.sender] = true;
        s.initialized = true;
    }

    function enforceOnlySuperOwner() internal view {
        OwnersStorage storage s = facetStorage();
        require(s.owners[0] == msg.sender, "Owners: Only Super Owner");
    }

    function enforceOnlyOwners() internal view {
        OwnersStorage storage s = facetStorage();
        require(s.isOwner[msg.sender], "Owners: Only Owner");
    }

    function isOwner(address user) internal view returns (bool) {
        OwnersStorage storage s = facetStorage();
        return s.isOwner[user];
    }
}

abstract contract OwnersAware {
    modifier onlyOwners {
        LibOwners.enforceOnlyOwners();
        _;
    }
}

contract Handler_OwnersFacet {
    function addOwner(address _new, bool _change) external {
        LibOwners.enforceOnlySuperOwner();

        OwnersStorage storage s = LibOwners.facetStorage();

        s.isOwner[_new] = true;
        if (_change) {
            s.owners.push(s.owners[0]);
            s.owners[0] = _new;
        } else {
            s.owners.push(_new);
        }
    }

    function removeOwner(address _new) external {
        LibOwners.enforceOnlySuperOwner();

        OwnersStorage storage s = LibOwners.facetStorage();

        require(s.isOwner[_new], "Owners: Not owner");
        require(_new != s.owners[0], "Owners: Cannot remove super owner");
        for (uint256 i = 1; i < s.owners.length; i++) {
            if (s.owners[i] == _new) {
                s.owners[i] = s.owners[s.owners.length - 1];
                s.owners.pop();
                break;
            }
        }

        s.isOwner[_new] = false;
    }
}

// SPDX-License-Identifier: BSD-3-Clause

pragma solidity ^0.8.0;

import "./OwnersFacet.sol";
import "./AppStorage.sol";
import "../PreSale.sol";

struct PreSaleFacetStorage {
    mapping(string => string) preSaleItemToLuckyBoxName;
    IPreSaleBurnable preSaleContract;
}

library LibPreSale {
    bytes32 constant STORAGE_POSITION =
        keccak256("diamond.handler.presale.storage");

    function facetStorage()
        internal
        pure
        returns (PreSaleFacetStorage storage s)
    {
        bytes32 position = STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    function updateMap(string memory preSaleName, string memory luckyBoxName)
        internal
    {
        PreSaleFacetStorage storage s = facetStorage();
        s.preSaleItemToLuckyBoxName[preSaleName] = luckyBoxName;
    }

    function getLuckyBoxNameFromPreSaleItem(string memory _preSaleItem)
        internal
        view
        returns (string memory)
    {
        PreSaleFacetStorage storage s = facetStorage();
        return s.preSaleItemToLuckyBoxName[_preSaleItem];
    }
}

contract Handler_PreSaleFacet is OwnersAware {
    function preSale() public view returns (IPreSaleBurnable) {
        return LibPreSale.facetStorage().preSaleContract;
    }

    function setPreSale(IPreSaleBurnable _preSale) external onlyOwners {
        PreSaleFacetStorage storage s = LibPreSale.facetStorage();
        s.preSaleContract = _preSale;
    }

    function preSaleMapping(string calldata preSaleName)
        public
        view
        returns (string memory)
    {
        return LibPreSale.getLuckyBoxNameFromPreSaleItem(preSaleName);
    }

    function setPreSaleMapping(
        string[] memory preSaleNames,
        string[] memory luckyBoxesNames
    ) external onlyOwners {
        require(
            preSaleNames.length == luckyBoxesNames.length,
            "Handler: Length mismatch"
        );

        for (uint256 i = 0; i < preSaleNames.length; i++) {
            LibPreSale.updateMap({
                preSaleName: preSaleNames[i],
                luckyBoxName: luckyBoxesNames[i]
            });
        }
    }

    function createLuckyBoxFromPreSale(address user, uint256 preSaleItemIdx)
        external
    {
        require(
            msg.sender == user || LibOwners.isOwner(msg.sender),
            "Handler: Don't mess with others claims"
        );

        PreSaleFacetStorage storage s = LibPreSale.facetStorage();
        IPreSaleBurnable _preSale = s.preSaleContract;

        (, uint256 amount, string memory itemName) = _preSale.burnItemTypeFrom(
            user,
            preSaleItemIdx
        );

        require(amount >= 0, "Handler: No items bought of this type");

        LibAppStorage.appStorage().lucky.createLuckyBoxesAirDrop(
            LibPreSale.getLuckyBoxNameFromPreSaleItem(itemName),
            amount,
            user
        );
    }
}