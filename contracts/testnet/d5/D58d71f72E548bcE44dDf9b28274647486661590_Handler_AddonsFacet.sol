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

import {OwnersAware} from "./OwnersFacet.sol";
import {LibAppStorage} from "./AppStorage.sol";

struct Waterpack {
    /// @dev How much lifetime is added to the node, expressed relative to the
    /// node's GRP time.
    uint256 ratioOfGRP;
}

struct WaterpackFacetStorage {
    Waterpack[] items;
    string[] names;
    /// @dev Name to index + 1, 0 means the waterpack doesn't exists.
    mapping(string => uint256) indexOfPlusOne;
    mapping(string => mapping(string => uint256)) itemToNodeTypeToPrice;
}

library LibWaterpack {
    bytes32 constant STORAGE_POSITION =
        keccak256("diamond.handler.waterpack.storage");

    function facetStorage()
        internal
        pure
        returns (WaterpackFacetStorage storage fs)
    {
        bytes32 position = STORAGE_POSITION;
        assembly {
            fs.slot := position
        }
    }

    function hasWaterpackType(string memory name) internal view returns (bool) {
        WaterpackFacetStorage storage fs = facetStorage();
        return fs.indexOfPlusOne[name] != 0;
    }

    function getWaterpackType(string memory name)
        internal
        view
        returns (Waterpack storage)
    {
        WaterpackFacetStorage storage fs = facetStorage();
        uint256 idx = fs.indexOfPlusOne[name];
        require(idx != 0, "Waterpacks: nonexistant key");
        return fs.items[idx - 1];
    }

    function setWaterpackType(
        string memory name,
        uint256 ratioOfGRP,
        uint256[] memory prices
    ) internal {
        WaterpackFacetStorage storage fs = facetStorage();
        string[] memory nodeTypes = LibAppStorage.appStorage().mapNt.keys;
        require(
            nodeTypes.length == prices.length,
            "Waterpacks: length mismatch"
        );

        uint256 indexPlusOne = fs.indexOfPlusOne[name];
        if (indexPlusOne == 0) {
            fs.names.push(name);
            fs.items.push(Waterpack({ratioOfGRP: ratioOfGRP}));
            fs.indexOfPlusOne[name] = fs.names.length;
        } else {
            Waterpack storage waterpack = fs.items[indexPlusOne - 1];
            waterpack.ratioOfGRP = ratioOfGRP;
        }

        for (uint256 i = 0; i < nodeTypes.length; i++) {
            fs.itemToNodeTypeToPrice[name][nodeTypes[i]] = prices[i];
        }
    }

    function getWaterpackPriceByNameAndNodeType(
        string memory name,
        string memory nodeType
    ) internal view returns (uint256) {
        require(hasWaterpackType(name), "Waterpack type does not exist");
        WaterpackFacetStorage storage fs = facetStorage();
        return fs.itemToNodeTypeToPrice[name][nodeType];
    }
}

struct Fertilizer {
    /// @dev Duration of the effect of the fertilizer, expressed in seconds.
    uint256 durationEffect;
    /// @dev Percentage of additional boost provided during the effect of the
    /// fertilizer.
    uint256 rewardBoost;
    /// @dev Global limit on the number of fertilizers of that type that can be
    /// applied.
    uint256 globalLimit;
    /// @dev Not used anymore
    uint256 userLimit;
    /// @dev Limit on the number of fertilizers of that type that can be applied
    /// per node type, per user.
    uint256 userNodeTypeLimit;
    /// @dev Limit on the number of fertilizers of that type that can be applied
    /// on a single node.
    uint256 nodeLimit;
}

struct FertilizerFacetStorage {
    Fertilizer[] items;
    string[] names;
    /// @dev Name to index + 1, 0 means the fertilizer doesn't exists.
    mapping(string => uint256) indexOfPlusOne;
    mapping(string => mapping(string => uint256)) itemToNodeTypeToPrice;
    mapping(string => uint256) totalCreatedPerType;
    mapping(address => mapping(string => uint256)) totalCreatedPerUserPerType;
    mapping(uint256 => uint256) totalCreatedPerNodeTokenId;
}

library LibFertilizer {
    bytes32 constant STORAGE_POSITION =
        keccak256("diamond.handler.fertilizer.storage");

    function facetStorage()
        internal
        pure
        returns (FertilizerFacetStorage storage fs)
    {
        bytes32 position = STORAGE_POSITION;
        assembly {
            fs.slot := position
        }
    }

    function hasFertilizerType(string memory name)
        internal
        view
        returns (bool)
    {
        FertilizerFacetStorage storage fs = facetStorage();
        return fs.indexOfPlusOne[name] != 0;
    }

    function getFertilizerType(string memory name)
        internal
        view
        returns (Fertilizer storage)
    {
        FertilizerFacetStorage storage fs = facetStorage();
        uint256 idx = fs.indexOfPlusOne[name];
        require(idx != 0, "Fertilizers: nonexistant key");
        return fs.items[idx - 1];
    }

    function setFertilizerType(
        string memory name,
        uint256 durationEffect,
        uint256 rewardBoost,
        uint256[] memory limits,
        uint256[] memory prices
    ) internal {
        FertilizerFacetStorage storage fs = facetStorage();
        require(limits.length == 3, "Fertilizers: invalid arguments");
        string[] memory nodeTypes = LibAppStorage.appStorage().mapNt.keys;
        require(
            prices.length == nodeTypes.length,
            "Fertilizers: length mismatch"
        );
        uint256 indexPlusOne = fs.indexOfPlusOne[name];
        if (indexPlusOne == 0) {
            fs.names.push(name);
            fs.items.push(
                Fertilizer({
                    durationEffect: durationEffect,
                    rewardBoost: rewardBoost,
                    globalLimit: limits[0],
                    userLimit: 0, // Unused
                    userNodeTypeLimit: limits[1],
                    nodeLimit: limits[2]
                })
            );
            fs.indexOfPlusOne[name] = fs.names.length;
        } else {
            Fertilizer storage fertilizer = fs.items[indexPlusOne - 1];
            fertilizer.durationEffect = durationEffect;
            fertilizer.rewardBoost = rewardBoost;
            fertilizer.globalLimit = limits[0];
            fertilizer.userNodeTypeLimit = limits[1];
            fertilizer.nodeLimit = limits[2];
        }

        for (uint256 i = 0; i < nodeTypes.length; i++) {
            fs.itemToNodeTypeToPrice[name][nodeTypes[i]] = prices[i];
        }
    }

    function applyFertilizer(
        string memory name,
        uint256 nodeTokenId,
        uint256 amount
    ) internal {
        FertilizerFacetStorage storage fs = facetStorage();

        Fertilizer memory fertilizerType = getFertilizerType(name);
        string memory nodeType = LibAppStorage.getTokenIdNodeTypeName(
            nodeTokenId
        );
        address user = LibAppStorage.nft().ownerOf(nodeTokenId);

        fs.totalCreatedPerType[name] += amount;
        require(
            fs.totalCreatedPerType[name] <= fertilizerType.globalLimit,
            "Fertilizers: Global limit exceeded"
        );

        fs.totalCreatedPerUserPerType[user][nodeType] += amount;
        require(
            fs.totalCreatedPerUserPerType[user][nodeType] <=
                fertilizerType.userNodeTypeLimit,
            "Fertilizers: User node type limit exceeded"
        );

        fs.totalCreatedPerNodeTokenId[nodeTokenId] += amount;
        require(
            fs.totalCreatedPerNodeTokenId[nodeTokenId] <=
                fertilizerType.nodeLimit,
            "Fertilizers: Node limit exceeded"
        );
    }

    function getFertilizerPriceByNameAndNodeType(
        string memory name,
        string memory nodeType
    ) internal view returns (uint256) {
        require(
            LibFertilizer.hasFertilizerType(name),
            "Fertilizer type does not exist"
        );
        FertilizerFacetStorage storage fs = LibFertilizer.facetStorage();
        return fs.itemToNodeTypeToPrice[name][nodeType];
    }
}

struct NodeAddonLog {
    uint256[] creationTime;
    string[] addonKind;
    string[] addonTypeName;
}

struct AddonsFacetStorage {
    mapping(uint256 => NodeAddonLog) nodeAddonLogs;
}

library LibAddons {
    bytes32 constant STORAGE_POSITION =
        keccak256("diamond.handler.addons.storage");

    function facetStorage()
        internal
        pure
        returns (AddonsFacetStorage storage fs)
    {
        bytes32 position = STORAGE_POSITION;
        assembly {
            fs.slot := position
        }
    }

    function logAddon(
        uint256 nodeTokenId,
        string memory addonKind,
        string memory addonTypeName,
        uint256 creationTime
    ) internal {
        AddonsFacetStorage storage fs = facetStorage();
        fs.nodeAddonLogs[nodeTokenId].creationTime.push(creationTime);
        fs.nodeAddonLogs[nodeTokenId].addonKind.push(addonKind);
        fs.nodeAddonLogs[nodeTokenId].addonTypeName.push(addonTypeName);

        assert(
            fs.nodeAddonLogs[nodeTokenId].creationTime.length ==
                fs.nodeAddonLogs[nodeTokenId].addonKind.length
        );

        assert(
            fs.nodeAddonLogs[nodeTokenId].creationTime.length ==
                fs.nodeAddonLogs[nodeTokenId].addonTypeName.length
        );
    }

    function logWaterpacks(
        uint256[] memory nodeTokenIds,
        string memory waterpackType,
        uint256 creationTime,
        uint256[] memory amounts
    ) internal {
        require(
            nodeTokenIds.length == amounts.length,
            "Addons: Length mismatch"
        );
        for (uint256 i = 0; i < nodeTokenIds.length; i++) {
            for (uint256 j = 0; j < amounts[i]; j++) {
                logAddon(
                    nodeTokenIds[i],
                    "Waterpack",
                    waterpackType,
                    creationTime
                );
            }
        }
    }

    function logFertilizers(
        uint256[] memory nodeTokenIds,
        string memory fertilizerType,
        uint256 creationTime,
        uint256[] memory amounts
    ) internal {
        require(
            nodeTokenIds.length == amounts.length,
            "Addons: Length mismatch"
        );

        for (uint256 i = 0; i < nodeTokenIds.length; i++) {
            LibFertilizer.applyFertilizer(
                fertilizerType,
                nodeTokenIds[i],
                amounts[i]
            );

            for (uint256 j = 0; j < amounts[i]; j++) {
                logAddon(
                    nodeTokenIds[i],
                    "Fertilizer",
                    fertilizerType,
                    creationTime
                );
            }
        }
    }
}

contract Handler_AddonsFacet is OwnersAware {
    function hasWaterpackType(string memory name) external view returns (bool) {
        return LibWaterpack.hasWaterpackType(name);
    }

    function getWaterpackType(string memory name)
        external
        view
        returns (Waterpack memory)
    {
        return LibWaterpack.getWaterpackType(name);
    }

    function getWaterpackPriceByNameAndNodeType(
        string memory name,
        string memory nodeType
    ) external view returns (uint256) {
        return LibWaterpack.getWaterpackPriceByNameAndNodeType(name, nodeType);
    }

    struct WaterpackView {
        string name;
        uint256 ratioOfGRP;
        uint256[] prices;
    }

    function getWaterpackTypes() public view returns (WaterpackView[] memory) {
        WaterpackFacetStorage storage fs = LibWaterpack.facetStorage();

        string[] memory nodeTypes = LibAppStorage.appStorage().mapNt.keys;
        WaterpackView[] memory output = new WaterpackView[](fs.items.length);

        for (uint256 i = 0; i < fs.items.length; i++) {
            uint256[] memory prices = new uint256[](nodeTypes.length);
            for (uint256 j = 0; j < nodeTypes.length; j++) {
                prices[j] = fs.itemToNodeTypeToPrice[fs.names[i]][nodeTypes[j]];
            }
            output[i] = WaterpackView({
                name: fs.names[i],
                ratioOfGRP: fs.items[i].ratioOfGRP,
                prices: prices
            });
        }

        return output;
    }

    function hasFertilizerType(string memory name)
        external
        view
        returns (bool)
    {
        return LibFertilizer.hasFertilizerType(name);
    }

    function getFertilizerType(string memory name)
        external
        view
        returns (Fertilizer memory)
    {
        return LibFertilizer.getFertilizerType(name);
    }

    function getFertilizerPriceByNameAndNodeType(
        string memory name,
        string memory nodeType
    ) external view returns (uint256) {
        return
            LibFertilizer.getFertilizerPriceByNameAndNodeType(name, nodeType);
    }

    struct FertilizerView {
        string name;
        uint256 durationEffect;
        uint256 rewardBoost;
        uint256[] prices;
        uint256 globalLimit;
        uint256 userNodeTypeLimit;
        uint256 nodeLimit;
    }

    function getFertilizerTypes()
        public
        view
        returns (FertilizerView[] memory)
    {
        FertilizerFacetStorage storage fs = LibFertilizer.facetStorage();
        string[] memory nodeTypes = LibAppStorage.appStorage().mapNt.keys;
        FertilizerView[] memory output = new FertilizerView[](fs.items.length);

        for (uint256 i = 0; i < fs.items.length; i++) {
            string storage fertilizerName = fs.names[i];
            uint256[] memory prices = new uint256[](nodeTypes.length);
            for (uint256 j = 0; j < nodeTypes.length; j++) {
                prices[j] = fs.itemToNodeTypeToPrice[fertilizerName][
                    nodeTypes[j]
                ];
            }

            output[i] = FertilizerView({
                name: fertilizerName,
                durationEffect: fs.items[i].durationEffect,
                rewardBoost: fs.items[i].rewardBoost,
                prices: prices,
                globalLimit: fs.items[i].globalLimit,
                userNodeTypeLimit: fs.items[i].userNodeTypeLimit,
                nodeLimit: fs.items[i].nodeLimit
            });
        }

        return output;
    }

    struct NodeAddonLogItemView {
        uint256 creationTime;
        string addonKind;
        string addonTypeName;
    }

    function getItemLogForNode(uint256 nodeId)
        public
        view
        returns (NodeAddonLogItemView[] memory)
    {
        AddonsFacetStorage storage fs = LibAddons.facetStorage();
        NodeAddonLog memory log = fs.nodeAddonLogs[nodeId];
        uint256 logLength = log.creationTime.length;
        NodeAddonLogItemView[] memory logItems = new NodeAddonLogItemView[](
            logLength
        );

        for (uint256 i = 0; i < logLength; i++) {
            logItems[i].creationTime = log.creationTime[i];
            logItems[i].addonKind = log.addonKind[i];
            logItems[i].addonTypeName = log.addonTypeName[i];
        }

        return logItems;
    }

    function totalFertilizerCreatedPerType(string calldata typeName)
        public
        view
        returns (uint256)
    {
        FertilizerFacetStorage storage fs = LibFertilizer.facetStorage();
        return fs.totalCreatedPerType[typeName];
    }

    function totalFertilizerCreatedPerUserPerType(
        address user,
        string calldata nodeType
    ) public view returns (uint256) {
        FertilizerFacetStorage storage fs = LibFertilizer.facetStorage();
        return fs.totalCreatedPerUserPerType[user][nodeType];
    }

    function totalFertilizerCreatedPerNodeTokenId(uint256 nodeTokenId)
        public
        view
        returns (uint256)
    {
        FertilizerFacetStorage storage fs = LibFertilizer.facetStorage();
        return fs.totalCreatedPerNodeTokenId[nodeTokenId];
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