// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

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
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
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
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
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
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

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
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
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
        address owner = ERC721Upgradeable.ownerOf(tokenId);
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
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
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
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

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
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSetUpgradeable {
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

        /// @solidity memory-safe-assembly
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

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import {TokenInfo, MergeInfo} from "./NewDefinaCardStructs.sol";

library CommonUtils {
    function _randModulus(address user, uint mod, uint i) internal view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(
                block.timestamp,
                block.difficulty,
                mod,
                i,
                user, msg.sender)
            )) % mod;
        return rand;
    }

    function getHeroByRand(uint[] storage heroIds, address user, uint i) internal view returns (uint) {
        uint mod = heroIds.length;
        uint rand = uint(keccak256(abi.encodePacked(
                block.timestamp,
                block.difficulty,
                mod,
                i,
                user, msg.sender)
            )) % mod;

        return heroIds[rand];
    }

    function getHeroBySeed(uint[] memory heroIds, address user, bytes32 seed, bytes32 transactionHash,uint index) internal view returns (uint) {
        uint mod = heroIds.length;
        uint rand = uint(keccak256(abi.encodePacked(
                block.timestamp,
                block.difficulty,
                mod,
                user,
                seed,
                transactionHash,
                index,
                msg.sender)
            )) % mod;
        return heroIds[rand];
    }

    function getMintResult(uint256[][] memory rarityScale, address user, bytes32 seed, bytes32 transactionHash) internal view returns (uint) {
        uint mod = 100;
        uint rand = uint(keccak256(abi.encodePacked(
                block.timestamp,
                block.difficulty,
                mod,
                user,
                seed,
                transactionHash,
                msg.sender)
            )) % mod;

        uint256 prevScale = 0;
        for (uint256 i = 0; i < rarityScale.length; i++) {
            if (rand < prevScale + rarityScale[i][1]) return rarityScale[i][0];
            prevScale += rarityScale[i][1];
        }
        return 0;
    }

    function getMergeResult(uint scale, address user, bytes32 seed, bytes32 transactionHash) internal view returns (bool) {
        uint mod = 100;
        uint rand = uint(keccak256(abi.encodePacked(
                block.timestamp,
                block.difficulty,
                mod,
                user,
                seed,
                transactionHash,
                msg.sender)
            )) % mod;
        if (rand < scale) {
            return true;
        }
        return false;
    }

    function _randSeedModulus(address user, bytes32 seed, bytes32 transactionHash, uint mod) internal view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(
                block.timestamp,
                block.difficulty,
                mod,
                user,
                seed,
                transactionHash,
                msg.sender)
            )) % mod;
        return rand;
    }

    function stringToUint(string memory s) internal pure returns (uint) {
        bytes memory b = bytes(s);
        uint result = 0;
        for (uint i = 0; i < b.length; i++) {
            if (uint8(b[i]) >= 48 && uint8(b[i]) <= 57) {
                result = result * 10 + (uint8(b[i]) - 48);
            }
        }
        return result;
    }

    function getClaimableCards(uint256[] calldata tokenIds, mapping(uint256 => bool) storage claimed) internal view returns (uint256[] memory) {
        uint256[] memory claimableCards = new uint256[](tokenIds.length);
        uint256 n=0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint tokenId = tokenIds[i];
            if (claimed[tokenId] == false)
            {
                claimableCards[n]=tokenId;
                n++;
            }
        }
        return claimableCards;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

/**
 * @title NewDefinaCardEventsAndErrors
 * @notice NewDefinaCardEventsAndErrors contains all events and errors.
 */
interface NewDefinaCardEventsAndErrors {

    event MintMulti(address indexed owner, uint _amount);
    event Burn(uint indexed tokenId_);

    event AddMint(uint256 indexed tokenId, uint256 _amount, bool forWhitelist, address owner);
    event MintSuccess(uint256 indexed tokenId, uint256 _amount, bool forWhitelist, address owner, bytes32 randTransactionHash);

    event AddMerge(uint256 indexed tokenIdA, uint256 indexed tokenIdB, address indexed owner, uint256 blockNumber);
    event MergeSuccess(uint256 indexed tokenIdA, uint256 indexed tokenIdB, address indexed owner, uint _currentRarity, uint _currentHero, uint _currentPoint, bool success, bytes32 randTransactionHash);


    /**
     * @dev Contract address cannot be empty
     */
    error AddressIsNull();

    /**
     * @dev Array cannot be empty, length must be greater than 0
     */
    error ArrayIsNull();

    /**
     * @dev Incorrect array length
     */
    error ArrayLengthError();

    /**
     * @dev sale has already begun
     */
    error SaleHasAlreadyBegun();

    /**
     * @dev Price must be greater than 0
     */
    error PriceIsZero();

    /**
     * @dev wrong amount
     */
    error WrongAmount();

    /**
     * @dev Mint exceeds supply
     */
    error MintExceedsSupply();

    /**
     * @dev already claimed
     */
    error AlreadyClaimed();

    /**
     * @dev You must own the token to traverse
     */
    error NotTheOwner();

    /**
     * @dev NFT not allowed to claim
     */
    error NotAllowedClaim();


    /**
     * @dev Merge has already begun
     */
    error MergeHasAlreadyBegun();

    /**
     * @dev caller is not owner nor approved
     */
    error NotApprovedOrOwner();

    /**
     * @dev Two cards do not meet the merge rules
     */
    error NotMeetMergeRules();

    /**
     * @dev NFT already for merging
     */
    error AlreadyMerging();

    /**
     * @dev NFT merge object is error
     */
    error MergeInfoError();

    /**
     * @dev This chain is currently unavailable for travel
     */
    error ChainUnavailable();

    /**
     * @dev LZNFT: msg.value not enough to cover messageFee. Send gas for message fees
     */
    error NotEnoughMessageFee();
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2;
interface IDefinaCard {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function cardInfoes(uint cardId_) external returns (uint cardId, uint camp, uint rarity, string memory name, uint currentAmount, uint maxAmount, string memory cardURI);

    function cardIdMap(uint tokenId_) external view returns (uint);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2;

    struct TokenInfo {
        uint tokenId;
        uint heroId;
        uint rarity;
        uint genesisPoint;
    }

    struct MintInfo {
        uint tokenId;
        uint amount;
        address user;
        bool forWhitelist;
    }

    struct MergeInfo {
        uint tokenIdA;
        uint tokenIdB;
        address user;
        uint price;
        uint blockNumber;
    }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "./CommonUtils.sol";
import {TokenInfo, MintInfo, MergeInfo} from "./NewDefinaCardStructs.sol";
import {IDefinaCard} from "./NewDefinaCardInterface.sol";
import {NewDefinaCardEventsAndErrors} from "./NewDefinaCardEventsAndErrors.sol";


contract NewDefinaCard is ERC721EnumerableUpgradeable, OwnableUpgradeable, NewDefinaCardEventsAndErrors {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    address public mergerOperator;

    modifier whenClaimableActive() {
        require(claimableActive, "Claimable state is not active");
        _;
    }

    modifier onlyEOA() {
        require(msg.sender == tx.origin, "DefinaCard: not eoa");
        _;
    }
    modifier onlyOperator() {
        require(mergerOperator == msg.sender, "Only operator can call this method");
        _;
    }
    modifier whenPublicSaleActive() {
        require(publicSaleActive, "Public sale is not active");
        _;
    }
    modifier whenMergerActive() {
        require(mergeActive, "Merge is not active");
        _;
    }


    function setMergerOperator(address newMergerOperator_) external onlyOwner {
        if (newMergerOperator_ == address(0)) {
            revert AddressIsNull();
        }
        mergerOperator = newMergerOperator_;
    }
    // old rarity => new rarity
    mapping(uint => uint) private rarityRarityMap;
    // token => genesis point
    mapping(uint => uint) public genesisPointMap;
    // old rarity => genesis point
    mapping(uint => uint) private rarityPointMap;
    // Okex heroId => genesis point
    mapping(uint => uint) private okexPointMap;
    // Okex heroId => is Okex card
    mapping(uint => bool) private iSOkexMap;
    // token => heroId
    mapping(uint => uint) public heroIdMap;
    // token => rarity
    mapping(uint => uint) public rarityMap;
    // rarity => heroIds
//    mapping(uint => uint[]) public rarityHeroIdsMap;
    // rarity => no okex heroIds
    mapping(uint => uint[]) public rarityNoOkexHeroIdsMap;
    //[B,A,S,S+,SS,SS+,SSS,SSS+,X]
    uint private maxRarity;

    //MINT
    uint gasForDestinationLzReceive;
    uint256 public MAX_MINT;
    bool public publicSaleActive;
    address public currTokenAddress;
    uint public nftPrice;
    uint256 public mintIndexPublicSale;
    mapping(uint256 => bool) public forMint;
    mapping(uint256 => MintInfo) public mintMap;
    uint256 public maxFreeMintPerAddress;
    mapping(address => uint256) public freeMintMap;

    uint256[][] mintRarityScale;

    //CLAIM
    bool public claimableActive;
    IDefinaCard public nftA;
    mapping(uint256 => bool) public claimed;
    uint256 private maxClaimedAmount;

    //MERGE
//    uint256 public worldCupPrizePool;//TODO uncomment
//    address public worldCupAddress;//TODO uncomment
    bool public mergeActive;
    mapping(uint256 => bool) public forMerge;
    mapping(uint256 => MergeInfo) public mergeMap;
    //rarity=>scales
    mapping(uint => uint) private rarityScalesMap;
    //rarity=>base merge price
    mapping(uint => uint) public rarityMergePriceMap;
    //rarity=>directional merge price
    mapping(uint => uint) public rarityDirectionalPriceMap;
    address public mergeTokenAddress;
    // mergeIds
    EnumerableSetUpgradeable.UintSet private mintIds;
    EnumerableSetUpgradeable.UintSet private mergeIds;

    //whitelist
    mapping(address => uint256[3]) public whitelistInfos; // user => uint256[3]

    function initialize(IDefinaCard nftA_, uint nftAmount_, address _layerZeroEndpoint, uint[][] calldata _rarityHeroIds, uint[][] calldata _oldCardSetting) external initializer {
        __ERC721_init_unchained("Defina Card", "DEFINACARD");
        __ERC721Enumerable_init_unchained();
        __Ownable_init();

        mergerOperator = _msgSender();

        gasForDestinationLzReceive = 350000;
        MAX_MINT = 100000;
        maxFreeMintPerAddress = 4;
        mintRarityScale = [[2,60],[3,40]];

        require(nftAmount_ < MAX_MINT);
        nftA = nftA_;
        maxClaimedAmount = nftAmount_;
        mintIndexPublicSale = nftAmount_;
//        endpoint = ILayerZeroEndpoint(_layerZeroEndpoint);
        setOldCardSetting(_oldCardSetting);
        setRarityHeroIds(_rarityHeroIds);
    }

    function setRarityHeroIds(uint[][] calldata _rarityHeroIds) onlyOwner public {
        if (_rarityHeroIds.length == 0) {
            revert ArrayIsNull();
        }
        maxRarity = _rarityHeroIds.length;
        //remove
        for (uint i = 0; i < maxRarity; i++) {
            delete rarityNoOkexHeroIdsMap[i + 1];
            rarityNoOkexHeroIdsMap[i + 1] = _rarityHeroIds[i];


            // add rarityNoOkexHeroIdsMap
//            uint[] memory rarityHeroIds = _rarityHeroIds[i];
//            uint length = rarityHeroIds.length;
//            uint index = 0;
//            for (uint j = 0; j < length; j++) {
//                if(iSOkexMap[rarityHeroIds[j]] == true){
//                    index += 1;
//                }
//            }
//            if(index == 0){
//                rarityNoOkexHeroIdsMap[i + 1] = rarityHeroIds;
//            }else{
//                uint[] memory heroIds = new uint[](length-index);
//                uint ii=0;
//                for (uint j = 0; j < length; j++) {
//                    if(iSOkexMap[rarityHeroIds[j]] == false){
//                        heroIds[ii]=rarityHeroIds[j];
//                        ii += 1;
//                    }
//                }
//                rarityNoOkexHeroIdsMap[i + 1] = heroIds;
//            }
        }
    }

    function setOldCardSetting(uint[][] calldata _oldCardSetting) onlyOwner public {
        if (_oldCardSetting.length != 4) {
            revert ArrayLengthError();
        }
        uint[] calldata _rarityRarity = _oldCardSetting[0];
        uint[] calldata _rarityPoints = _oldCardSetting[1];
        uint[] calldata _okexHeroIds = _oldCardSetting[2];
        uint[] calldata _okexPoints = _oldCardSetting[3];
        if (_rarityRarity.length == 0 || _rarityPoints.length == 0) {
            revert ArrayIsNull();
        }
        if (_okexHeroIds.length != _okexPoints.length) {
            revert ArrayLengthError();
        }
        for (uint i = 0; i < _rarityRarity.length; i++) {
            uint oldRarity = i + 1;
            uint newRarity = _rarityRarity[i];
            rarityRarityMap[oldRarity] = newRarity;
        }
        for (uint i = 0; i < _rarityPoints.length; i++) {
            uint oldRarity = i + 1;
            uint point = _rarityPoints[i];
            rarityPointMap[oldRarity] = point;
        }
        for (uint i = 0; i < _okexHeroIds.length; i++) {
            okexPointMap[_okexHeroIds[i]] = _okexPoints[i];
            iSOkexMap[_okexHeroIds[i]] = true;
        }
    }

    // Public Sale Methods
    function startPublicSale(
        address _currTokenAddress,
        uint256 _nftPrice
    ) onlyOwner external {
//        if (publicSaleActive) {
//            revert SaleHasAlreadyBegun();
//        }
        if (_nftPrice == 0) {
            revert PriceIsZero();
        }
//        if (_currToken == IERC20Upgradeable(address(0))) {
//            revert AddressIsNull();
//        }

        currTokenAddress = _currTokenAddress;
        nftPrice = _nftPrice;
        publicSaleActive = true;
    }

    function stopPublicSale() onlyOwner whenPublicSaleActive external {
        publicSaleActive = false;
    }

//    function mintMulti(uint amount_) whenPublicSaleActive onlyEOA external payable {
//        if (amount_ == 0) {
//            revert WrongAmount();
//        }
//        if (mintIndexPublicSale + amount_ > MAX_MINT) {
//            revert MintExceedsSupply();
//        }
//        if (currTokenAddress == address(0)) {
//            require(msg.value >= nftPrice * amount_, 'Action underpriced');
//        }else{
//            IERC20Upgradeable currToken = IERC20Upgradeable(currTokenAddress);
//            currToken.safeTransferFrom(_msgSender(), address(this), nftPrice * amount_);
//        }
//        for (uint i = 0; i < amount_; ++i) {
//            uint rarity = 1;
//            uint tokenId = mintIndexPublicSale++;
//            uint heroId = CommonUtils.getHeroByRand(rarityHeroIdsMap[rarity], _msgSender(), i);
//            rarityMap[tokenId] = rarity;
//            heroIdMap[tokenId] = heroId;
//            _safeMint(_msgSender(), tokenId);
//        }
//        emit MintMulti(_msgSender(), amount_);
//    }

    function addMint(uint amount_, bool forWhitelist_) external whenPublicSaleActive onlyEOA payable {
        if (amount_ == 0 || amount_ > 10) {
            revert WrongAmount();
        }
        if (mintIndexPublicSale + amount_ > MAX_MINT) {
            revert MintExceedsSupply();
        }

        uint256 price = nftPrice;
        if (forWhitelist_) {
            uint256[3] storage whitelistInfo = whitelistInfos[_msgSender()];
            require(whitelistInfo[1] >= amount_, "Exceeds whitelist mint amount");
            price = whitelistInfo[2];
        }

        if (currTokenAddress == address(0)) {
            require(msg.value >= price * amount_, "Action underpriced");
        } else {
            IERC20Upgradeable currToken = IERC20Upgradeable(currTokenAddress);
            currToken.safeTransferFrom(_msgSender(), address(this), price * amount_);
        }

        forMint[mintIndexPublicSale] = true;
        mintMap[mintIndexPublicSale] = MintInfo({
            tokenId: mintIndexPublicSale,
            amount: amount_,
            user: _msgSender(),
            forWhitelist: forWhitelist_
        });
        mintIds.add(mintIndexPublicSale);
        emit AddMint(mintIndexPublicSale, amount_, forWhitelist_, _msgSender());
        mintIndexPublicSale += amount_;
    }

    function toMint(uint256 mintStartTokenId, uint256 amount_, bool forWhitelist_, bytes32 randomness_, bytes32 transactionHash) external onlyOperator {
        require(forMint[mintStartTokenId] == true, "This tokenId group has been minted");
        MintInfo storage mintInfo = mintMap[mintStartTokenId];
        uint256 startId = mintStartTokenId;

        if (forWhitelist_) {
            uint256[3] storage whitelistInfo = whitelistInfos[mintInfo.user];
            require(whitelistInfo[1] >= amount_, "Exceeds whitelist mint amount");
            whitelistInfo[1] -= amount_;
        }

        for (uint i = 0; i < amount_; ++i) {
            uint rarity;
            if(forWhitelist_){
                rarity = whitelistInfos[mintInfo.user][0];
            }else{
                rarity = CommonUtils.getMintResult(mintRarityScale, mintInfo.user, randomness_, transactionHash[i]);
            }
            uint tokenId = startId++;
            uint heroId = CommonUtils.getHeroBySeed(rarityNoOkexHeroIdsMap[rarity], mintInfo.user, randomness_, transactionHash, i);
            rarityMap[tokenId] = rarity;
            heroIdMap[tokenId] = heroId;
            _safeMint(mintInfo.user, tokenId);
        }

        delete forMint[mintStartTokenId];
        delete mintMap[mintStartTokenId];
        mintIds.remove(mintStartTokenId);
        emit MintSuccess(mintStartTokenId, amount_, forWhitelist_, mintInfo.user, transactionHash);
    }

    // TODO remove
    function freeMultiMintTest(uint amount_, uint heroId_, uint rarity_) whenPublicSaleActive onlyEOA external {
        if (amount_ == 0) {
            revert WrongAmount();
        }
        if (mintIndexPublicSale + amount_ > MAX_MINT) {
            revert MintExceedsSupply();
        }
        uint rarity = 1;
        uint heroId;
        rarity = rarity_;
        for (uint i = 0; i < amount_; ++i) {
            uint tokenId = mintIndexPublicSale++;
            heroId = CommonUtils.getHeroByRand(rarityNoOkexHeroIdsMap[rarity], _msgSender(), i);

            rarityMap[tokenId] = rarity;
            heroIdMap[tokenId] = heroId;
            _safeMint(_msgSender(), tokenId);
        }
        emit MintMulti(_msgSender(), amount_);
    }

    function freeMultiMint(uint amount_, uint heroId_, uint rarity_) whenPublicSaleActive onlyEOA external {
        if (amount_ == 0 || amount_ > 10) {
            revert WrongAmount();
        }
        if (mintIndexPublicSale + amount_ > MAX_MINT) {
            revert MintExceedsSupply();
        }
        uint rarity = 1;
        uint heroId;
        if(_msgSender() == mergerOperator){
            rarity = rarity_;
        }else{
            require(freeMintMap[_msgSender()] + amount_ <= maxFreeMintPerAddress, "Reached max free mint amount");
        }
        for (uint i = 0; i < amount_; ++i) {
            uint tokenId = mintIndexPublicSale++;
            if(_msgSender() == mergerOperator){
                heroId = heroId_;
            }else{
                heroId = CommonUtils.getHeroByRand(rarityNoOkexHeroIdsMap[rarity], _msgSender(), i);
            }

            rarityMap[tokenId] = rarity;
            heroIdMap[tokenId] = heroId;
            _safeMint(_msgSender(), tokenId);
        }
        freeMintMap[_msgSender()] += amount_;
        emit MintMulti(_msgSender(), amount_);
    }

    function setNftA(IDefinaCard nftA_) onlyOwner external {
        nftA = nftA_;
    }

    //Claim Methods
    function changeClaimableState() onlyOwner external {
        claimableActive = !claimableActive;
    }

    function nftOwnerClaimCards(uint256[] calldata tokenIds) whenClaimableActive onlyEOA external {
        for (uint256 i; i < tokenIds.length; ++i) {
            uint256 tokenId = tokenIds[i];
            if (claimed[tokenId] == true) {
                revert AlreadyClaimed();
            }
            if (nftA.ownerOf(tokenId) != _msgSender()) {
                revert NotTheOwner();
            }
            if (tokenId >= maxClaimedAmount) {
                revert NotAllowedClaim();
            }
            claimLandByTokenId(tokenId);
        }
    }

    function claimLandByTokenId(uint256 tokenId) private {
        claimed[tokenId] = true;
        _safeMint(_msgSender(), tokenId);
        uint cardId_ = nftA.cardIdMap(tokenId);
        (uint cardId, uint camp, uint rarity, string memory name, uint currentAmount, uint maxAmount, string memory cardURI) = nftA.cardInfoes(cardId_);
        rarityMap[tokenId] = rarityRarityMap[rarity];
        uint heroId = CommonUtils.stringToUint(cardURI);
        heroIdMap[tokenId] = heroId;
        if (iSOkexMap[heroId] == true) {
            genesisPointMap[tokenId] = okexPointMap[heroId];
        } else {
            genesisPointMap[tokenId] = rarityPointMap[rarity];
        }
    }

    function getClaimableCards(uint256[] calldata tokenIds) view external returns (uint256[] memory){
        return CommonUtils.getClaimableCards(tokenIds, claimed);
    }
    // Merge Methods
    function startMerge(address _mergeTokenAddress, address _worldCupAddress, uint[] calldata _mergePrices, uint[] calldata _directionalPrices, uint[] calldata rarityScales
    ) onlyOwner external {
        if (mergeActive) {
            revert MergeHasAlreadyBegun();
        }
        if (_mergePrices.length != (maxRarity - 1) || _directionalPrices.length != (maxRarity - 1) || rarityScales.length != (maxRarity - 1)) {
            revert ArrayLengthError();
        }
//        if (_mergeToken == IERC20Upgradeable(address(0))) {
//            revert AddressIsNull();
//        }

        mergeTokenAddress = _mergeTokenAddress;
//        worldCupAddress = _worldCupAddress;//TODO uncomment
        mergeActive = true;
        //remove previous quota first
        for (uint i = 0; i < _mergePrices.length; ++i) {
            rarityMergePriceMap[i + 1] = _mergePrices[i];
        }
        //remove previous quota first
        for (uint i = 0; i < _directionalPrices.length; ++i) {
            rarityDirectionalPriceMap[i + 1] = _directionalPrices[i];
        }
        //remove previous quota first
        for (uint i = 0; i < rarityScales.length; ++i) {
            rarityScalesMap[i + 1] = rarityScales[i];
        }
    }

    function stopMerge() onlyOwner whenMergerActive external {
        mergeActive = false;
    }


    function addMerge(uint tokenIdA, uint tokenIdB, uint price) payable onlyEOA whenMergerActive external {
        if (!_isApprovedOrOwner(_msgSender(), tokenIdA) || !_isApprovedOrOwner(_msgSender(), tokenIdB)) {
            revert NotApprovedOrOwner();
        }
        if (tokenIdA == tokenIdB || rarityMap[tokenIdA] != rarityMap[tokenIdB] || rarityMap[tokenIdA] >= maxRarity) {
            revert NotMeetMergeRules();
        }
        if (forMerge[tokenIdA] || forMerge[tokenIdB]) {
            revert AlreadyMerging();
        }

        uint basePrice = rarityMergePriceMap[rarityMap[tokenIdA]];
        if (price < basePrice) {
            revert WrongAmount();
        }

        if(mergeTokenAddress == address(0)){
            require(msg.value >= price, 'Action underpriced');
        }else{
            IERC20Upgradeable mergeToken = IERC20Upgradeable(mergeTokenAddress);
            mergeToken.safeTransferFrom(_msgSender(), address(this), price);//TODO remove
//            mergeToken.safeTransferFrom(_msgSender(), address(worldCupAddress), price);//TODO uncomment
        }
//        worldCupPrizePool += price;//TODO uncomment

        forMerge[tokenIdA] = true;
        forMerge[tokenIdB] = true;
        mergeMap[tokenIdA] = MergeInfo({
            tokenIdA : tokenIdA,
            tokenIdB : tokenIdB,
            user : _msgSender(),
            price : price,
            blockNumber : block.number
        });
        mergeIds.add(tokenIdA);

        if (address(mergerOperator) != _msgSender()) {
            approve(address(mergerOperator), tokenIdA);
            approve(address(mergerOperator), tokenIdB);
        }
        emit AddMerge(tokenIdA, tokenIdB, _msgSender(), block.number);
    }


    function toMerge(uint tokenIdA, bytes32 randomness_, bytes32 transactionHash) external onlyOperator{
        MergeInfo storage mergeInfo = mergeMap[tokenIdA];
        uint256 tokenIdB = mergeInfo.tokenIdB;
        address user = mergeInfo.user;
        if (mergeInfo.tokenIdA != tokenIdA) {
            revert MergeInfoError();
        }
        if (!_isApprovedOrOwner(_msgSender(), tokenIdA) || !_isApprovedOrOwner(_msgSender(), mergeInfo.tokenIdB)) {
            revert NotApprovedOrOwner();
        }
        bool mergeResult = CommonUtils.getMergeResult(rarityScalesMap[rarityMap[tokenIdA]], mergeInfo.user, randomness_, transactionHash);
        if (mergeResult) {
            uint directionalPrice = rarityDirectionalPriceMap[rarityMap[tokenIdA]];

            uint newRarity = rarityMap[tokenIdA] + 1;
            rarityMap[tokenIdA] = newRarity;
            genesisPointMap[tokenIdA] = genesisPointMap[tokenIdA] + genesisPointMap[mergeInfo.tokenIdB];

            if (mergeInfo.price < directionalPrice) {
                uint heroId = CommonUtils.getHeroBySeed(rarityNoOkexHeroIdsMap[newRarity], mergeInfo.user, randomness_, transactionHash, 0);
                heroIdMap[tokenIdA] = heroId;
            }
            burn(mergeInfo.tokenIdB);
        }
        //delete Merge record
        delete forMerge[tokenIdA];
        delete forMerge[mergeInfo.tokenIdB];
        delete mergeMap[tokenIdA];
        mergeIds.remove(tokenIdA);
        emit MergeSuccess(tokenIdA, tokenIdB, user, rarityMap[tokenIdA], heroIdMap[tokenIdA], genesisPointMap[tokenIdA], mergeResult, transactionHash);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);
        if (from != to) {
            if (forMerge[tokenId]) {
                uint length = mergeIds.length();
                uint tokenA;
                uint tokenB;
                for (uint i = 0; i < length; i++) {
                    if(tokenId == mergeIds.at(i)){
                        //tokenA
                        tokenA = tokenId;
                        tokenB = mergeMap[tokenId].tokenIdB;
                        break;
                    }
                    if(tokenId == mergeMap[mergeIds.at(i)].tokenIdB){
                        //tokenB
                        tokenB = tokenId;
                        tokenA = mergeIds.at(i);
                        break;
                    }
                }
                delete forMerge[tokenA];
                delete forMerge[tokenB];
                delete mergeMap[tokenA];
                mergeIds.remove(tokenA);
            }
        }
    }

    function burn(uint tokenId_) public returns (bool){
        if (!_isApprovedOrOwner(_msgSender(), tokenId_)) {
            revert NotApprovedOrOwner();
        }
        delete rarityMap[tokenId_];
        delete heroIdMap[tokenId_];
        delete genesisPointMap[tokenId_];
        _burn(tokenId_);
        emit Burn(tokenId_);
        return true;
    }

    function getTokenInfosByAddress(address who) view external returns (TokenInfo[] memory) {
        require(who != address(0));
        uint length = balanceOf(who);

        TokenInfo[] memory tmp = new TokenInfo[](length);
        for (uint i = 0; i < length; i++) {
            uint tokenId = tokenOfOwnerByIndex(who, length - i - 1);
            tmp[i] = TokenInfo({
            tokenId : tokenId,
            heroId : heroIdMap[tokenId],
            rarity : rarityMap[tokenId],
            genesisPoint : genesisPointMap[tokenId]
            });
        }
        return tmp;
    }

    function getMintInfos() view external returns (MintInfo[] memory) {
        uint length = mintIds.length();
        MintInfo[] memory tmp = new MintInfo[](length);
        for (uint i = 0; i < length; i++) {
            tmp[i] = mintMap[mintIds.at(i)];
        }
        return tmp;
    }

    function getMergeInfos() view external returns (MergeInfo[] memory) {
        uint length = mergeIds.length();
        MergeInfo[] memory tmp = new MergeInfo[](length);
        for (uint i = 0; i < length; i++) {
            tmp[i] = mergeMap[mergeIds.at(i)];
        }
        return tmp;
    }

    function getHeroIds(uint256[] calldata tokenIds) view external returns (uint256[] memory, uint256[] memory) {
        uint256[] memory heroIds = new uint256[](tokenIds.length);
        uint256[] memory rarities = new uint256[](tokenIds.length);
        for (uint i = 0; i < tokenIds.length; i++) {
            heroIds[i] = heroIdMap[tokenIds[i]];
            rarities[i] = rarityMap[tokenIds[i]];
        }
        return (heroIds, rarities);
    }

    function setWhitelistInfo(
        address[] calldata whitelistAddresses,
        uint256[] calldata rarity,
        uint256[] calldata remainingAmount,
        uint256[] calldata price
    ) external onlyOperator {
        if (
            whitelistAddresses.length != rarity.length ||
            rarity.length != remainingAmount.length ||
            remainingAmount.length != price.length
        ) {
            revert ArrayLengthError();
        }

        for (uint256 i = 0; i < whitelistAddresses.length; i++) {
            uint256[3] storage whitelist = whitelistInfos[
                whitelistAddresses[i]
            ];
            whitelist[0] = rarity[i];
            whitelist[1] = remainingAmount[i];
            whitelist[2] = price[i];
        }
    }

    // This function transfers the nft from your address on the
    // source chain to the same address on the destination chain
//    function traverseChains(uint16 _chainId, uint tokenId) public payable {
//        if (_msgSender() != ownerOf(tokenId)) {
//            revert NotTheOwner();
//        }
//        if (trustedRemoteLookup[_chainId].length == 0) {
//            revert ChainUnavailable();
//        }
//
//        _burn(tokenId);
//
//        // abi.encode() the payload with the values to send
//        bytes memory payload = abi.encode(_msgSender(), tokenId);
//
//        // encode adapterParams to specify more gas for the destination
//        uint16 version = 1;
//        bytes memory adapterParams = abi.encodePacked(version, gasForDestinationLzReceive);
//
//        // get the fees we need to pay to LayerZero + Relayer to cover message delivery
//        // you will be refunded for extra gas paid
//        (uint messageFee,) = endpoint.estimateFees(_chainId, address(this), payload, false, adapterParams);
//        if (msg.value < messageFee) {
//            revert NotEnoughMessageFee();
//        }
//        endpoint.send{value : msg.value}(
//            _chainId, // destination chainId
//            trustedRemoteLookup[_chainId], // destination address of nft contract
//            payload, // abi.encoded()'ed bytes
//            payable(msg.sender), // refund address
//            address(0x0), // 'zroPaymentAddress' unused for this
//            adapterParams                       // txParameters
//        );
//    }

    // just in case this fixed variable limits us from future integrations
//    function setGasForDestinationLzReceive(uint newVal) onlyOwner external {
//        gasForDestinationLzReceive = newVal;
//    }

//    function _LzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) override internal {
//        // decode
//        (address toAddr, uint tokenId) = abi.decode(_payload, (address, uint));
//
//        // mint the tokens back into existence on destination chain
//        _safeMint(toAddr, tokenId);
//    }

}