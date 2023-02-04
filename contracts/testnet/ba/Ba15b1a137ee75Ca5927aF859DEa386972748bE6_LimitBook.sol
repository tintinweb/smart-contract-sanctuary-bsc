// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";
import "../utils/ContextUpgradeable.sol";
import "../utils/StringsUpgradeable.sol";
import "../utils/introspection/ERC165Upgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(account),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

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
// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

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
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
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
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
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
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
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
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
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
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
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
     * @dev Moves `amount` of tokens from `from` to `to`.
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
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

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
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
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
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
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

import "./math/MathUpgradeable.sol";

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = MathUpgradeable.log10(value) + 1;
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
            return toHexString(value, MathUpgradeable.log256(value) + 1);
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

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
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
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
     * @dev Moves `amount` of tokens from `from` to `to`.
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
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

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
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
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
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

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

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.17;

import "../interfaces/ILimitBook.sol";
import "../interfaces/ISwapRouter.sol";
import "../interfaces/AbstractPool.sol";
import "../interfaces/OnlyDelegateCall.sol";
import "../libs/Errors.sol";
import "../libs/ERC20Fixed.sol";
import "../libs/math/FixedPoint.sol";
import "../TradingCore.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LimitBook is
  ILimitBook,
  OwnableUpgradeable,
  ReentrancyGuardUpgradeable,
  OnlyDelegateCall
{
  using FixedPoint for uint256;
  using ERC20Fixed for ERC20;

  TradingCore tradingCore;
  address baseToken;
  AbstractRegistry registry;
  AbstractOracleAggregator oracleAggregator;

  //TODO settable
  ISwapRouter swapRouter; //settable

  mapping(address => mapping(bytes32 => mapping(uint256 => bytes32)))
    public openLimitOrders;
  mapping(bytes32 => IRegistry.Trade) internal _openLimitOrderByOrderHash;
  mapping(address => mapping(bytes32 => uint256))
    public openLimitOrdersPerPriceIdCount;
  mapping(address => uint256) public openLimitOrdersPerUserCount;

  event SetSwapRouterEvent(ISwapRouter swapRouter);

  function initialize(
    address _owner,
    TradingCore _tradingCore,
    ISwapRouter _swapRouter
  ) public initializer {
    _transferOwnership(_owner);
    tradingCore = _tradingCore;
    baseToken = address(tradingCore.baseToken());
    registry = tradingCore.registry();
    oracleAggregator = tradingCore.oracleAggregator();
    swapRouter = _swapRouter;
  }

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  modifier onlyLiquidator() {
    _require(
      registry.hasRole(registry.LIQUIDATOR_ROLE(), msg.sender),
      Errors.LIQUIDATOR_ONLY
    );
    _;
  }

  modifier notPaused() {
    _require(!isPaused(), Errors.TRADING_PAUSED);
    _;
  }

  modifier onlyApprovedPriceId(bytes32 priceId) {
    _require(registry.approvedPriceId(priceId), Errors.APPROVED_PRICE_ID_ONLY);
    _;
  }

  // public functions

  function isPaused() public view returns (bool) {
    return tradingCore.isPaused();
  }

  function openLimitOrderByOrderHash(
    bytes32 orderHash
  ) public view returns (IRegistry.Trade memory t) {
    t = _openLimitOrderByOrderHash[orderHash];
    _require(t.user != address(0x0), Errors.ORDER_NOT_FOUND);
  }

  function openLimitOrder(
    OpenTradeInput calldata openData
  ) public notPaused onlyApprovedPriceId(openData.priceId) nonReentrant {
    IRegistry.Trade memory trade = tradingCore.createTrade(
      openData,
      openData.limitPrice,
      0
    );
    trade.user = msg.sender;
    bytes32 orderHash = _openLimitOrder(trade);
    ERC20(baseToken).transferFromFixed(
      msg.sender,
      address(this),
      openData.margin
    );
    emit OpenLimitOrderEvent(tx.origin, orderHash, trade);
  }

  function openLimitOrder(
    OpenTradeInput memory openData,
    ISwapRouter.SwapGivenOutInput memory input
  ) public notPaused onlyApprovedPriceId(openData.priceId) nonReentrant {
    _require(input.tokenOut == baseToken, Errors.TOKEN_MISMATCH);
    input.amountOut = openData.margin;

    ERC20(input.tokenIn).transferFromFixed(
      msg.sender,
      address(this),
      input.amountInMaximum
    );
    ERC20(input.tokenIn).approveFixed(
      address(swapRouter),
      input.amountInMaximum
    );
    uint256 amountIn = swapRouter.swapGivenOut(input);
    if (amountIn < input.amountInMaximum) {
      ERC20(input.tokenIn).transferFixed(
        msg.sender,
        input.amountInMaximum.sub(amountIn)
      );
    }

    IRegistry.Trade memory trade = tradingCore.createTrade(
      openData,
      openData.limitPrice,
      0
    );
    trade.user = msg.sender;
    bytes32 orderHash = _openLimitOrder(trade);
    emit OpenLimitOrderEvent(tx.origin, orderHash, trade);
  }

  function closeLimitOrder(
    bytes32 orderHash,
    uint256 closePercent
  ) public override notPaused nonReentrant {
    _require(
      closePercent > 0 && closePercent <= 1e18,
      Errors.INVALID_CLOSE_PERCENT
    );
    IRegistry.Trade memory trade = openLimitOrderByOrderHash(orderHash);
    _require(msg.sender == trade.user, Errors.USER_SENDER_MISMATCH);
    _closeLimitOrder(orderHash, closePercent);
    ERC20(baseToken).transferFixed(
      msg.sender,
      trade.margin.mulDown(closePercent)
    );
    if (closePercent == 1e18) {
      emit CloseLimitOrderEvent(
        tx.origin,
        orderHash,
        trade.user,
        trade.priceId
      );
    } else {
      emit PartialCloseLimitOrderEvent(
        tx.origin,
        orderHash,
        trade,
        closePercent
      );
    }
  }

  function tryExecuteLimitOrder(
    bytes32 orderHash,
    bytes[] calldata priceData
  ) public view notPaused returns (IRegistry.Trade memory trade) {
    (
      ,
      OpenTradeInput memory openData,
      uint256 executionPrice
    ) = _tryExecuteLimitOrder(orderHash, priceData);

    (, trade) = tradingCore.tryOpenMarketOrder(openData, executionPrice);
  }

  function _tryExecuteLimitOrder(
    bytes32 orderHash,
    bytes[] calldata priceData
  )
    private
    view
    returns (
      IRegistry.Trade memory t,
      OpenTradeInput memory openData,
      uint256 executionPrice
    )
  {
    t = openLimitOrderByOrderHash(orderHash);

    IOracleProvider.PricePackage memory pricePackage = oracleAggregator
      .parsePriceFeed(t.priceId, t.isBuy, priceData);
    _require(
      t.executionTime < pricePackage.publishTime,
      Errors.INVALID_TIMESTAMP
    );

    // actual execution is at worst at openPrice, and we don't deduct fee
    // so this is more conservative than actual slippage
    uint256 expectedSlippage = tradingCore.getSlippage(
      t.priceId,
      t.isBuy,
      t.openPrice,
      t.leverage.mulDown(t.margin)
    );
    uint256 expectedExecution = t.isBuy
      ? t.openPrice.sub(expectedSlippage)
      : t.openPrice.add(expectedSlippage);
    _require(
      t.isBuy
        ? pricePackage.price <= expectedExecution
        : pricePackage.price >= expectedExecution,
      Errors.CANNOT_EXECUTE_LIMIT
    );

    openData = OpenTradeInput(
      t.user,
      t.priceId,
      t.margin,
      t.leverage,
      t.isBuy,
      t.profitTarget,
      t.stopLoss,
      t.openPrice
    );
    executionPrice = pricePackage.price;
  }

  function executeLimitOrder(
    bytes32 orderHash,
    bytes[] calldata priceData
  ) public override notPaused nonReentrant {
    (
      IRegistry.Trade memory t,
      OpenTradeInput memory openData,
      uint256 executionPrice
    ) = _tryExecuteLimitOrder(orderHash, priceData);

    _closeLimitOrder(orderHash, 1e18);
    ERC20(baseToken).approveFixed(address(tradingCore), t.margin);
    tradingCore.openMarketOrder(openData, executionPrice);
    emit ExecuteLimitOrderEvent(tx.origin, orderHash, t.user, t.priceId);
  }

  /// @custom:oz-upgrades-unsafe-allow delegatecall
  function executeLimitOrderMany(
    bytes32[] calldata orderHashMany,
    bytes[] calldata priceData
  ) public onlyDelegateCall {
    for (uint256 i = 0; i < orderHashMany.length; i++) {
      (bool success, bytes memory data) = address(this).delegatecall(
        abi.encodeWithSignature(
          "executeLimitOrder(bytes32,bytes[])",
          orderHashMany[i],
          priceData
        )
      );
      if (!success) {
        emit FailedExecuteLimitOrderEvent(orderHashMany[i], data);
      }
    }
  }

  function updateLimitStop(
    bytes32 orderHash,
    uint256 _profitTarget,
    uint256 _stopLoss
  ) public notPaused {
    IRegistry.Trade memory t = openLimitOrderByOrderHash(orderHash);
    t = tradingCore._updateStop(t, _profitTarget, _stopLoss);
    _updateOpenLimitOrder(orderHash, t);
    emit UpdateOpenLimitOrderEvent(tx.origin, orderHash, t);
  }

  // private functions

  function _openLimitOrder(
    IRegistry.Trade memory trade
  ) private returns (bytes32) {
    openLimitOrdersPerPriceIdCount[trade.user][trade.priceId]++;
    trade.salt = openLimitOrdersPerPriceIdCount[trade.user][trade.priceId];

    bytes32 orderHash = keccak256(abi.encode(trade));

    openLimitOrdersPerUserCount[trade.user]++;
    openLimitOrders[trade.user][trade.priceId][trade.salt] = orderHash;
    _openLimitOrderByOrderHash[orderHash] = trade;
    return orderHash;
  }

  function _updateOpenLimitOrder(
    bytes32 orderHash,
    IRegistry.Trade memory trade
  ) private {
    IRegistry.Trade memory t = openLimitOrderByOrderHash(orderHash);
    _require(t.user == trade.user, Errors.TRADER_OWNER_MISMATCH);
    _openLimitOrderByOrderHash[orderHash] = trade;
  }

  function _closeLimitOrder(bytes32 orderHash, uint256 closePercent) private {
    IRegistry.Trade memory t = openLimitOrderByOrderHash(orderHash);
    uint256 closeMargin = t.margin.mulDown(closePercent);

    if (closePercent == 1e18) {
      openLimitOrdersPerPriceIdCount[t.user][t.priceId]--;
      openLimitOrdersPerUserCount[t.user]--;
      delete openLimitOrders[t.user][t.priceId][t.salt];
      delete _openLimitOrderByOrderHash[orderHash];
    } else {
      t.margin -= closeMargin;
      _openLimitOrderByOrderHash[orderHash] = t;
    }
  }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.17;

import "./IOracleProvider.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract AbstractOracleAggregator is Ownable, IOracleProvider {
  uint256 public checkThreshold;

  mapping(bytes32 => IOracleProvider[]) public oracleProvidersPerPriceId;

  // priceId => isBuy => cachedPrice
  mapping(bytes32 => mapping(bool => PricePackage))
    internal _cachedPricePerPriceId;

  event AddOracleProviderEvent(bytes32 priceId, address oracleProvider);
  event SetCheckThresholdEvent(uint256 checkThreshold);

  constructor(address owner) {
    _transferOwnership(owner);
    checkThreshold = type(uint256).max;
  }

  function cachedPricePerPriceId(
    bytes32 priceId,
    bool isBuy
  ) public view returns (PricePackage memory) {
    return _cachedPricePerPriceId[priceId][isBuy];
  }

  function setCheckThreshold(uint256 _checkThreshold) public onlyOwner {
    checkThreshold = _checkThreshold;
    emit SetCheckThresholdEvent(checkThreshold);
  }

  function addOracleProviderPerPriceId(
    bytes32 priceId,
    IOracleProvider oracleProvider
  ) public onlyOwner {
    oracleProvidersPerPriceId[priceId].push(oracleProvider);
    emit AddOracleProviderEvent(priceId, address(oracleProvider));
  }

  function getLatestPrice(
    bytes32 priceId,
    bool isBuy
  ) public view returns (PricePackage memory) {
    return _cachedPricePerPriceId[priceId][isBuy];
  }

  function parsePriceFeed(
    bytes32 priceId,
    bool isBuy,
    bytes[] memory updateData
  ) public view virtual returns (PricePackage memory);

  function getUpdateFee(
    uint256 updateDataSize
  ) public view virtual returns (uint256 feeAmount);

  function updatePriceFeeds(
    bytes[] memory priceData,
    bytes32[] memory priceIds,
    uint256 updateFee
  ) public payable virtual;

  function updateLatestPrice(
    bytes32 priceId,
    bool isBuy,
    bytes[] calldata priceData,
    uint256 updateFee
  ) public payable virtual returns (PricePackage memory);

  // TODO: check publishTime
  function _checkPrice(
    bytes32 priceId
  ) internal view returns (uint256 askPrice, uint256 bidPrice) {
    IOracleProvider[] storage providers = oracleProvidersPerPriceId[priceId];
    uint256 size = providers.length;
    if (size < checkThreshold) {
      askPrice = 0;
      bidPrice = 0;
    } else {
      uint256[] memory askPrices = new uint256[](size);
      uint256[] memory bidPrices = new uint256[](size);
      for (uint256 i = 0; i < size; i++) {
        askPrices[i] = providers[i].getLatestPrice(priceId, true).price;
        bidPrices[i] = providers[i].getLatestPrice(priceId, false).price;
      }

      uint256[] memory sortedAskPrices = sort(askPrices);
      askPrice = size % 2 == 1
        ? sortedAskPrices[(size - 1) / 2]
        : (sortedAskPrices[size / 2 - 1] + sortedAskPrices[size / 2]) / 2;

      uint256[] memory sortedBidPrices = sort(bidPrices);
      bidPrice = size % 2 == 1
        ? sortedBidPrices[(size - 1) / 2]
        : (sortedBidPrices[size / 2 - 1] + sortedBidPrices[size / 2]) / 2;
    }
  }

  function abs(int256 x) internal pure returns (uint256) {
    return x >= 0 ? uint256(x) : uint256(-x);
  }

  function sort(uint256[] memory arr) internal pure returns (uint256[] memory) {
    uint256 l = arr.length;
    for (uint256 i = 0; i < l; i++) {
      for (uint256 j = i + 1; j < l; j++) {
        if (arr[i] > arr[j]) {
          uint256 temp = arr[i];
          arr[i] = arr[j];
          arr[j] = temp;
        }
      }
    }
    return arr;
  }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.17;

import "./IPool.sol";
import "./AbstractRegistry.sol";
import "../libs/Errors.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract AbstractPool is IPool, OwnableUpgradeable {
  ERC20 baseToken;
  AbstractRegistry registry;
  uint256 baseDecimals;

  function _initialize(
    address _owner,
    ERC20 _baseToken,
    AbstractRegistry _registry
  ) internal onlyInitializing {
    _require(_baseToken.decimals() <= 18, Errors.INVALID_TOKEN_DECIMALS);
    _transferOwnership(_owner);
    baseToken = _baseToken;
    registry = _registry;
    baseDecimals = _baseToken.decimals();
  }

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  modifier onlyApproved() {
    _require(
      registry.hasRole(registry.APPROVED_ROLE(), msg.sender),
      Errors.APPROVED_ONLY
    );
    _;
  }

  function transferBase(address _to, uint256 _amount) public virtual override;

  function transferBaseFrom(
    address _from,
    address _to,
    uint256 _amount
  ) public virtual override;
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.17;

import "./IRegistry.sol";
import "../libs/Errors.sol";
import "../libs/math/FixedPoint.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract AbstractRegistry is
  IRegistry,
  AccessControlUpgradeable,
  OwnableUpgradeable
{
  using FixedPoint for uint256;
  using FixedPoint for int256;

  bytes32 public constant APPROVED_ROLE = keccak256("APPROVED_ROLE");
  bytes32 public constant LIQUIDATOR_ROLE = keccak256("LIQUIDATOR_ROLE");
  bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");

  // constant subject to governance update
  uint256 public salt;
  uint256 public maxOpenTradesPerPriceId;
  uint256 public maxOpenTradesPerUser;
  uint256 public maxMarginPerUser;
  uint256 public minPositionPerTrade;
  uint256 public liquidationPenalty;
  uint256 public maxPercentagePnLFactor;
  uint256 public fee;
  uint256 public stopFee;

  uint256 public feeFactor;

  // optional constant
  uint256 public maxPercentagePnLCap;
  uint256 public maxPercentagePnLFloor;

  // variable
  uint256 public minCollateral;

  event ApprovedPriceIdEvent(bytes32 priceId, bool approved);
  event SetMaxOpenTradesPerPriceIdEvent(uint256 maxOpenTradesPerPriceId);
  event SetMaxOpenTradesPerUserEvent(uint256 maxOpenTradesPerUser);
  event SetMaxMarginPerUserEvent(uint256 maxMarginPerUser);
  event SetMinPositionPerTradeEvent(uint256 minPositionPerTrade);
  event SetLiquidationThresholdEvent(
    bytes32 priceId,
    uint256 liquidationThreshold
  );
  event SetLiquidationPenaltyEvent(uint256 liquidationPenalty);
  event SetMaxLeverageEvent(bytes32 priceId, uint256 maxLeverage);
  event SetMinLeverageEvent(bytes32 priceId, uint256 minLeverage);
  event SetMaxPercentagePnLFactorEvent(uint256 maxPercentagePnLFactor);
  event SetMaxPercentagePnLCapEvent(uint256 maxPercentagePnLCap);
  event SetMaxPercentagePnLFloorEvent(uint256 maxPercentagePnLFloor);
  event SetFeeEvent(uint256 fee);
  event SetFeeFactorEvent(uint256 feeFactor);
  event SetFundingFeeEvent(bytes32 priceId, uint256 fundingFee);
  event SetImpactRefDepthLongEvent(bytes32 priceId, uint256 impactRefDepthLong);
  event SetImpactRefDepthShortEvent(
    bytes32 priceId,
    uint256 impactRefDepthShort
  );
  event SetStopFeeEvent(uint256 stopFee);

  function _initialize(
    address owner,
    uint256 _maxOpenTradesPerPriceId,
    uint256 _maxOpenTradesPerUser,
    uint256 _maxMarginPerUser,
    uint256 _minPositionPerTrade,
    uint256 _liquidationPenalty,
    uint256 _maxPercentagePnLFactor,
    uint256 _fee,
    uint256 _stopFee
  ) internal onlyInitializing {
    _transferOwnership(owner);
    _grantRole(DEFAULT_ADMIN_ROLE, owner);
    _grantRole(UPDATER_ROLE, owner);
    maxOpenTradesPerPriceId = _maxOpenTradesPerPriceId;
    maxOpenTradesPerUser = _maxOpenTradesPerUser;
    maxMarginPerUser = _maxMarginPerUser;
    minPositionPerTrade = _minPositionPerTrade;
    liquidationPenalty = _liquidationPenalty;
    maxPercentagePnLFactor = _maxPercentagePnLFactor;
    fee = _fee;
    stopFee = _stopFee;

    maxPercentagePnLCap = type(uint256).max;
  }

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  modifier onlyApprovedPriceId(bytes32 priceId) {
    _require(approvedPriceId[priceId], Errors.APPROVED_PRICE_ID_ONLY);
    _;
  }

  // constant subject to governance update
  mapping(bytes32 => bool) public approvedPriceId;
  mapping(bytes32 => uint256) public maxLeveragePerPriceId;
  mapping(bytes32 => uint256) public minLeveragePerPriceId;
  mapping(bytes32 => uint256) public liquidationThresholdPerPriceId;
  mapping(bytes32 => uint256) public impactRefDepthLongPerPriceId;
  mapping(bytes32 => uint256) public impactRefDepthShortPerPriceId;

  // dynamic variable
  mapping(address => mapping(bytes32 => mapping(uint256 => bytes32)))
    public openTrades;
  mapping(bytes32 => Trade) internal _openTradeByOrderHash;
  mapping(address => mapping(bytes32 => uint256))
    public openTradesPerPriceIdCount;
  mapping(address => uint256) public openTradesPerUserCount;
  mapping(address => uint256) public totalMarginPerUser;

  mapping(bytes32 => uint256) public totalLongPerPriceId;
  mapping(bytes32 => uint256) public totalShortPerPriceId;

  mapping(bytes32 => SignedUpdateable) internal _longImbalancePerPriceId;
  mapping(bytes32 => SignedUpdateable) internal _shortImbalancePerPriceId;

  mapping(bytes32 => Updateable) internal _fundingFeePerPriceId;

  function openTradeByOrderHash(
    bytes32 orderHash
  ) public view returns (Trade memory t) {
    t = _openTradeByOrderHash[orderHash];
    _require(t.user != address(0x0), Errors.ORDER_NOT_FOUND);
  }

  function fundingFeePerPriceId(
    bytes32 priceId
  ) public view returns (Updateable memory) {
    return _fundingFeePerPriceId[priceId];
  }

  function longImbalancePerPriceId(
    bytes32 priceId
  ) public view returns (SignedUpdateable memory) {
    return _longImbalancePerPriceId[priceId];
  }

  function shortImbalancePerPriceId(
    bytes32 priceId
  ) public view returns (SignedUpdateable memory) {
    return _shortImbalancePerPriceId[priceId];
  }

  function setMaxOpenTradesPerPriceId(
    uint256 _maxOpenTradesPerPriceId
  ) public onlyOwner {
    maxOpenTradesPerPriceId = _maxOpenTradesPerPriceId;
    emit SetMaxOpenTradesPerPriceIdEvent(maxOpenTradesPerPriceId);
  }

  function setMaxOpenTradesPerUser(
    uint256 _maxOpenTradesPerUser
  ) public onlyOwner {
    maxOpenTradesPerUser = _maxOpenTradesPerUser;
    emit SetMaxOpenTradesPerUserEvent(maxOpenTradesPerUser);
  }

  function setMaxMarginPerUser(uint256 _maxMarginPerUser) public onlyOwner {
    maxMarginPerUser = _maxMarginPerUser;
    emit SetMaxMarginPerUserEvent(maxMarginPerUser);
  }

  function setMinPositionPerTrade(
    uint256 _minPositionPerTrade
  ) public onlyOwner {
    minPositionPerTrade = _minPositionPerTrade;
    emit SetMinPositionPerTradeEvent(minPositionPerTrade);
  }

  function setApprovedPriceId(bytes32 priceId, bool approved) public onlyOwner {
    approvedPriceId[priceId] = approved;
    emit ApprovedPriceIdEvent(priceId, approved);
  }

  function setLiquidationThresholdPerPriceId(
    bytes32 priceId,
    uint256 liquidationThreshold
  ) public onlyOwner {
    liquidationThresholdPerPriceId[priceId] = liquidationThreshold;
    emit SetLiquidationThresholdEvent(priceId, liquidationThreshold);
  }

  function setLiquidationPenalty(uint256 _liquidationPenalty) public onlyOwner {
    liquidationPenalty = _liquidationPenalty;
    emit SetLiquidationPenaltyEvent(liquidationPenalty);
  }

  function setMaxLeveragePerPriceId(
    bytes32 priceId,
    uint256 maxLeverage
  ) public onlyOwner {
    _require(
      maxLeverage >= minLeveragePerPriceId[priceId],
      Errors.MAX_SMALLER_THAN_MIN
    );
    maxLeveragePerPriceId[priceId] = maxLeverage;
    emit SetMaxLeverageEvent(priceId, maxLeverage);
  }

  function setMinLeveragePerPriceId(
    bytes32 priceId,
    uint256 minLeverage
  ) public onlyOwner {
    _require(
      minLeverage <= maxLeveragePerPriceId[priceId],
      Errors.MIN_BIGGER_THAN_MAX
    );
    _require(
      minLeverage >= liquidationThresholdPerPriceId[priceId],
      Errors.MIN_SMALLER_THAN_THRESHOLD
    );
    minLeveragePerPriceId[priceId] = minLeverage;
    emit SetMinLeverageEvent(priceId, minLeverage);
  }

  function setMaxPercentagePnLFloor(
    uint256 _maxPercentagePnLFloor
  ) public onlyOwner {
    _require(
      _maxPercentagePnLFloor <= maxPercentagePnLCap,
      Errors.MIN_BIGGER_THAN_MAX
    );
    maxPercentagePnLFloor = _maxPercentagePnLFloor;
    emit SetMaxPercentagePnLFloorEvent(maxPercentagePnLFloor);
  }

  function setMaxPercentagePnLCap(
    uint256 _maxPercentagePnLCap
  ) public onlyOwner {
    _require(
      _maxPercentagePnLCap >= maxPercentagePnLFloor,
      Errors.MAX_SMALLER_THAN_MIN
    );
    maxPercentagePnLCap = _maxPercentagePnLCap;
    emit SetMaxPercentagePnLCapEvent(maxPercentagePnLCap);
  }

  function setMaxPercentagePnLFactor(
    uint256 _maxPercentagePnLFactor
  ) public onlyOwner {
    maxPercentagePnLFactor = _maxPercentagePnLFactor;
    emit SetMaxPercentagePnLFactorEvent(maxPercentagePnLFactor);
  }

  function setFee(uint256 _fee) public onlyOwner {
    fee = _fee;
    emit SetFeeEvent(fee);
  }

  function setFeeFactor(uint256 _feeFactor) public onlyOwner {
    feeFactor = _feeFactor;
    emit SetFeeFactorEvent(feeFactor);
  }

  function setStopFee(uint256 _stopFee) public onlyOwner {
    stopFee = _stopFee;
    emit SetStopFeeEvent(stopFee);
  }

  function setFundingFeePerPriceId(
    bytes32 priceId,
    uint256 _fundingFee
  ) public onlyOwner {
    Updateable storage fundingFee = _fundingFeePerPriceId[priceId];
    uint256 lastUpdate = fundingFee.lastUpdate;
    uint256 currentBlock = block.number;

    if (lastUpdate == 0) {
      fundingFee.initialUpdate = currentBlock;
      fundingFee.uptoLastUpdate = _fundingFee;
    } else {
      fundingFee.uptoLastUpdate =
        (fundingFee.current *
          (currentBlock - lastUpdate) +
          fundingFee.uptoLastUpdate *
          (lastUpdate - fundingFee.initialUpdate)) /
        (currentBlock - fundingFee.initialUpdate);
    }

    fundingFee.lastUpdate = currentBlock;
    fundingFee.current = _fundingFee;
    emit SetFundingFeeEvent(priceId, _fundingFee);
  }

  function setImpactRefDepthLongPerPriceId(
    bytes32 priceId,
    uint256 impactRefDepthLong
  ) public onlyRole(UPDATER_ROLE) {
    impactRefDepthLongPerPriceId[priceId] = impactRefDepthLong;
    emit SetImpactRefDepthLongEvent(priceId, impactRefDepthLong);
  }

  function setImpactRefDepthShortPerPriceId(
    bytes32 priceId,
    uint256 impactRefDepthShort
  ) public onlyRole(UPDATER_ROLE) {
    impactRefDepthShortPerPriceId[priceId] = impactRefDepthShort;
    emit SetImpactRefDepthShortEvent(priceId, impactRefDepthShort);
  }

  function _updateLongImbalancePerPriceId(bytes32 priceId) internal {
    SignedUpdateable memory longImbalance = _longImbalancePerPriceId[priceId];

    int256 currentImbalance = int256(totalLongPerPriceId[priceId].max(1e18))
      .sub(totalShortPerPriceId[priceId])
      .divDown(totalLongPerPriceId[priceId].max(1e18));

    _longImbalancePerPriceId[priceId] = _updateImbalancePerPriceId(
      longImbalance,
      currentImbalance
    );
  }

  function _updateShortImbalancePerPriceId(bytes32 priceId) internal {
    SignedUpdateable memory shortImbalance = _shortImbalancePerPriceId[priceId];
    int256 currentImbalance = int256(totalShortPerPriceId[priceId].max(1e18))
      .sub(totalLongPerPriceId[priceId])
      .divDown(totalShortPerPriceId[priceId].max(1e18));

    _shortImbalancePerPriceId[priceId] = _updateImbalancePerPriceId(
      shortImbalance,
      currentImbalance
    );
  }

  function _updateImbalancePerPriceId(
    SignedUpdateable memory imbalance,
    int256 currentImbalance
  ) internal view returns (SignedUpdateable memory) {
    uint256 lastUpdate = imbalance.lastUpdate;
    uint256 currentBlock = block.number;

    if (lastUpdate == 0) {
      imbalance.initialUpdate = currentBlock;
      imbalance.uptoLastUpdate = currentImbalance;
    } else {
      imbalance.uptoLastUpdate =
        (imbalance.current *
          int256(currentBlock - lastUpdate) +
          imbalance.uptoLastUpdate *
          int256(lastUpdate - imbalance.initialUpdate)) /
        int256(currentBlock - imbalance.initialUpdate);
    }

    imbalance.lastUpdate = currentBlock;
    imbalance.current = currentImbalance;

    return imbalance;
  }

  function openMarketOrder(Trade memory trade) public virtual returns (bytes32);

  function closeMarketOrder(
    bytes32 orderHash,
    uint256 closePercent
  ) public virtual;

  function updateOpenOrder(
    bytes32 orderHash,
    Trade memory trade
  ) public virtual;
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.17;

interface IBook {
  struct OpenTradeInput {
    address user;
    bytes32 priceId;
    uint256 margin;
    uint256 leverage;
    bool isBuy;
    uint256 profitTarget;
    uint256 stopLoss;
    uint256 limitPrice;
  }

  struct CloseTradeInput {
    bytes32 orderHash;
    uint256 closePercent;
    uint256 limitPrice;
  }

  event PausedEvent(bool paused);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.17;

import "./IRegistry.sol";
import "./IBook.sol";

interface ILimitBook is IBook {
  event OpenLimitOrderEvent(
    address indexed sender,
    bytes32 indexed orderHash,
    IRegistry.Trade trade
  );
  event UpdateOpenLimitOrderEvent(
    address indexed sender,
    bytes32 indexed orderHash,
    IRegistry.Trade trade
  );
  event ExecuteLimitOrderEvent(
    address indexed sender,
    bytes32 indexed orderHash,
    address trade_user,
    bytes32 trade_priceId
  );
  event CloseLimitOrderEvent(
    address indexed sender,
    bytes32 indexed orderHash,
    address trade_user,
    bytes32 trade_priceId
  );
  event PartialCloseLimitOrderEvent(
    address indexed sender,
    bytes32 indexed orderHash,
    IRegistry.Trade trade,
    uint256 closePercent
  );
  event FailedExecuteLimitOrderEvent(
    bytes32 indexed orderHash,
    bytes returnData
  );

  function openLimitOrder(OpenTradeInput calldata openData) external;

  function executeLimitOrder(
    bytes32 orderHash,
    bytes[] calldata priceData
  ) external;

  function closeLimitOrder(bytes32 orderHash, uint256 closePercent) external;
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.17;

interface IOracleProvider {
  struct PricePackage {
    uint256 price;
    uint256 publishTime;
  }

  function getLatestPrice(
    bytes32 priceId,
    bool isBuy
  ) external view returns (PricePackage memory package);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.17;

interface IPool {
  function transferBase(address _to, uint256 _amount) external;

  function transferBaseFrom(
    address _from,
    address _to,
    uint256 _amount
  ) external;
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.17;

interface IRegistry {
  struct Trade {
    address user;
    bytes32 priceId;
    uint256 margin;
    uint256 leverage;
    bool isBuy;
    uint256 openPrice;
    uint256 slippage;
    uint256 liquidationPrice;
    uint256 profitTarget;
    uint256 stopLoss;
    uint256 maxPercentagePnL;
    uint256 executionBlock;
    uint256 executionTime;
    uint256 salt;
  }

  struct Updateable {
    uint256 current;
    uint256 uptoLastUpdate;
    uint256 lastUpdate;
    uint256 initialUpdate;
  }

  struct SignedUpdateable {
    int256 current;
    int256 uptoLastUpdate;
    uint256 lastUpdate;
    uint256 initialUpdate;
  }

  function openMarketOrder(Trade memory trade) external returns (bytes32);

  function closeMarketOrder(bytes32 orderHash, uint256 closePercent) external;

  function updateOpenOrder(bytes32 orderHash, Trade memory trade) external;
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.17;

interface ISwapRouter {
  struct SwapGivenInInput {
    address tokenIn;
    address tokenOut;
    uint256 amountIn;
    uint256 amountOutMinimum;
    uint24 poolFee;
  }

  struct SwapGivenOutInput {
    address tokenIn;
    address tokenOut;
    uint256 amountOut;
    uint256 amountInMaximum;
    uint24 poolFee;
  }

  function swapGivenIn(
    SwapGivenInInput memory input
  ) external returns (uint256);

  function swapGivenOut(
    SwapGivenOutInput memory input
  ) external returns (uint256);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.17;

import "./IRegistry.sol";
import "./IBook.sol";

interface ITradingBook is IBook {
  struct OnCloseTrade {
    uint256 grossPnL;
    uint256 closeNet;
    uint256 slippage;
    int256 accumulatedFee;
    bool isStop;
    bool isLiquidated;
  }

  event OpenMarketOrderEvent(
    address indexed user,
    bytes32 indexed orderHash,
    IRegistry.Trade trade,
    uint256 fee
  );
  event UpdateOpenOrderEvent(
    address indexed user,
    bytes32 indexed orderHash,
    IRegistry.Trade trade,
    bool isAdding,
    uint256 marginDelta
  );
  event CloseMarketOrderEvent(
    address indexed user,
    bytes32 indexed orderHash,
    uint256 closePercent,
    IRegistry.Trade trade,
    uint256 closePrice,
    uint256 slippage,
    uint256 fee,
    int256 accumulatedFee,
    uint256 settled
  );
  event FailedCloseMarketOrderEvent(
    bytes32 indexed orderHash,
    uint256 closePercent,
    uint256 limitPrice,
    bytes returnData
  );

  function openMarketOrder(
    OpenTradeInput calldata openData,
    bytes[] calldata priceData
  ) external payable;

  function closeMarketOrder(
    CloseTradeInput calldata closeData,
    bytes[] calldata priceData
  ) external payable returns (uint256 settled);
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.17;

import "../libs/Errors.sol";

abstract contract OnlyDelegateCall {
  /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
  address private immutable self = address(this);

  modifier onlyDelegateCall() {
    _require(address(this) != self, Errors.DELEGATE_CALL_ONLY);
    _;
  }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

library ERC20Fixed {
  function transferFixed(ERC20 _token, address _to, uint256 _amount) internal {
    _token.transfer(_to, _amount / (10 ** (18 - _token.decimals())));
  }

  function transferFromFixed(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _amount
  ) internal {
    _token.transferFrom(_from, _to, _amount / (10 ** (18 - _token.decimals())));
  }

  function balanceOfFixed(
    ERC20 _token,
    address _owner
  ) internal view returns (uint256) {
    return _token.balanceOf(_owner) * (10 ** (18 - _token.decimals()));
  }

  function totalSupplyFixed(ERC20 _token) internal view returns (uint256) {
    return _token.totalSupply() * (10 ** (18 - _token.decimals()));
  }

  function allowanceFixed(
    ERC20 _token,
    address _owner,
    address _spender
  ) internal view returns (uint256) {
    return
      _token.allowance(_owner, _spender) * (10 ** (18 - _token.decimals()));
  }

  function approveFixed(
    ERC20 _token,
    address _spender,
    uint256 _amount
  ) internal returns (bool) {
    return _token.approve(_spender, _amount / (10 ** (18 - _token.decimals())));
  }

  function increaseAllowanceFixed(
    ERC20 _token,
    address _spender,
    uint256 _addedValue
  ) internal returns (bool) {
    return
      _token.increaseAllowance(
        _spender,
        _addedValue / (10 ** (18 - _token.decimals()))
      );
  }

  function decreaseAllowanceFixed(
    ERC20 _token,
    address _spender,
    uint256 _subtractedValue
  ) internal returns (bool) {
    return
      _token.decreaseAllowance(
        _spender,
        _subtractedValue / (10 ** (18 - _token.decimals()))
      );
  }
}

library ERC20UpgradeableFixed {
  function transferFixed(
    ERC20Upgradeable _token,
    address _to,
    uint256 _amount
  ) internal {
    _token.transfer(_to, _amount / (10 ** (18 - _token.decimals())));
  }

  function transferFromFixed(
    ERC20Upgradeable _token,
    address _from,
    address _to,
    uint256 _amount
  ) internal {
    _token.transferFrom(_from, _to, _amount / (10 ** (18 - _token.decimals())));
  }

  function balanceOfFixed(
    ERC20Upgradeable _token,
    address _owner
  ) internal view returns (uint256) {
    return _token.balanceOf(_owner) * (10 ** (18 - _token.decimals()));
  }

  function totalSupplyFixed(
    ERC20Upgradeable _token
  ) internal view returns (uint256) {
    return _token.totalSupply() * (10 ** (18 - _token.decimals()));
  }

  function allowanceFixed(
    ERC20Upgradeable _token,
    address _owner,
    address _spender
  ) internal view returns (uint256) {
    return
      _token.allowance(_owner, _spender) * (10 ** (18 - _token.decimals()));
  }

  function approveFixed(
    ERC20Upgradeable _token,
    address _spender,
    uint256 _amount
  ) internal returns (bool) {
    return _token.approve(_spender, _amount / (10 ** (18 - _token.decimals())));
  }

  function increaseAllowanceFixed(
    ERC20Upgradeable _token,
    address _spender,
    uint256 _addedValue
  ) internal returns (bool) {
    return
      _token.increaseAllowance(
        _spender,
        _addedValue / (10 ** (18 - _token.decimals()))
      );
  }

  function decreaseAllowanceFixed(
    ERC20Upgradeable _token,
    address _spender,
    uint256 _subtractedValue
  ) internal returns (bool) {
    return
      _token.decreaseAllowance(
        _spender,
        _subtractedValue / (10 ** (18 - _token.decimals()))
      );
  }
}

// SPDX-License-Identifier: GPL-3.0-or-later
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.8.17;

// solhint-disable

/**
 * @dev Reverts if `condition` is false, with a revert reason containing `errorCode`. Only codes up to 999 are
 * supported.
 * Uses the default 'UNW' prefix for the error code
 */
function _require(bool condition, uint256 errorCode) pure {
  if (!condition) _revert(errorCode);
}

/**
 * @dev Reverts if `condition` is false, with a revert reason containing `errorCode`. Only codes up to 999 are
 * supported.
 */
function _require(bool condition, uint256 errorCode, bytes3 prefix) pure {
  if (!condition) _revert(errorCode, prefix);
}

/**
 * @dev Reverts with a revert reason containing `errorCode`. Only codes up to 999 are supported.
 * Uses the default 'UNW' prefix for the error code
 */
function _revert(uint256 errorCode) pure {
  _revert(errorCode, 0x554e57); // This is the raw byte representation of "UNW"
}

/**
 * @dev Reverts with a revert reason containing `errorCode`. Only codes up to 999 are supported.
 */
function _revert(uint256 errorCode, bytes3 prefix) pure {
  uint256 prefixUint = uint256(uint24(prefix));
  // We're going to dynamically create a revert string based on the error code, with the following format:
  // 'UNW#{errorCode}'
  // where the code is left-padded with zeroes to three digits (so they range from 000 to 999).
  //
  // We don't have revert strings embedded in the contract to save bytecode size: it takes much less space to store a
  // number (8 to 16 bits) than the individual string characters.
  //
  // The dynamic string creation algorithm that follows could be implemented in Solidity, but assembly allows for a
  // much denser implementation, again saving bytecode size. Given this function unconditionally reverts, this is a
  // safe place to rely on it without worrying about how its usage might affect e.g. memory contents.
  assembly {
    // First, we need to compute the ASCII representation of the error code. We assume that it is in the 0-999
    // range, so we only need to convert three digits. To convert the digits to ASCII, we add 0x30, the value for
    // the '0' character.

    let units := add(mod(errorCode, 10), 0x30)

    errorCode := div(errorCode, 10)
    let tenths := add(mod(errorCode, 10), 0x30)

    errorCode := div(errorCode, 10)
    let hundreds := add(mod(errorCode, 10), 0x30)

    // With the individual characters, we can now construct the full string.
    // We first append the '#' character (0x23) to the prefix. In the case of 'UNW', it results in 0x554e57 ('UNW#')
    // Then, we shift this by 24 (to provide space for the 3 bytes of the error code), and add the
    // characters to it, each shifted by a multiple of 8.
    // The revert reason is then shifted left by 200 bits (256 minus the length of the string, 7 characters * 8 bits
    // per character = 56) to locate it in the most significant part of the 256 slot (the beginning of a byte
    // array).
    let formattedPrefix := shl(24, add(0x23, shl(8, prefixUint)))

    let revertReason := shl(
      200,
      add(formattedPrefix, add(add(units, shl(8, tenths)), shl(16, hundreds)))
    )

    // We can now encode the reason in memory, which can be safely overwritten as we're about to revert. The encoded
    // message will have the following layout:
    // [ revert reason identifier ] [ string location offset ] [ string length ] [ string contents ]

    // The Solidity revert reason identifier is 0x08c739a0, the function selector of the Error(string) function. We
    // also write zeroes to the next 28 bytes of memory, but those are about to be overwritten.
    mstore(
      0x0,
      0x08c379a000000000000000000000000000000000000000000000000000000000
    )
    // Next is the offset to the location of the string, which will be placed immediately after (20 bytes away).
    mstore(
      0x04,
      0x0000000000000000000000000000000000000000000000000000000000000020
    )
    // The string length is fixed: 7 characters.
    mstore(0x24, 7)
    // Finally, the string itself is stored.
    mstore(0x44, revertReason)

    // Even if the string is only 7 bytes long, we need to return a full 32 byte slot containing it. The length of
    // the encoded message is therefore 4 + 32 + 32 + 32 = 100.
    revert(0, 100)
  }
}

function _verifyCallResult(
  bool success,
  bytes memory returndata
) pure returns (bytes memory) {
  if (success) {
    return returndata;
  }
  if (returndata.length > 0) {
    // solhint-disable-next-line no-inline-assembly
    assembly {
      let returndata_size := mload(returndata)
      revert(add(32, returndata), returndata_size)
    }
  }
  _revert(Errors.SHOULD_NOT_HAPPEN);
}

library Errors {
  // Math
  uint256 internal constant ADD_OVERFLOW = 0;
  uint256 internal constant SUB_OVERFLOW = 1;
  uint256 internal constant SUB_UNDERFLOW = 2;
  uint256 internal constant MUL_OVERFLOW = 3;
  uint256 internal constant ZERO_DIVISION = 4;
  uint256 internal constant DIV_INTERNAL = 5;
  uint256 internal constant X_OUT_OF_BOUNDS = 6;
  uint256 internal constant Y_OUT_OF_BOUNDS = 7;
  uint256 internal constant PRODUCT_OUT_OF_BOUNDS = 8;
  uint256 internal constant INVALID_EXPONENT = 9;

  // Input
  uint256 internal constant OUT_OF_BOUNDS = 100;
  uint256 internal constant UNSORTED_ARRAY = 101;
  uint256 internal constant UNSORTED_TOKENS = 102;
  uint256 internal constant INPUT_LENGTH_MISMATCH = 103;
  uint256 internal constant ZERO_TOKEN = 104;
  uint256 internal constant TOKEN_MISMATCH = 105;
  uint256 internal constant INVALID_STOP_LOSS = 106;
  uint256 internal constant INVALID_PROFIT_TARGET = 107;
  uint256 internal constant FEE_TOO_HIGH = 108;
  uint256 internal constant NEGATIVE_LEVERAGE = 109;
  uint256 internal constant LEVERAGE_TOO_HIGH = 110;
  uint256 internal constant APPROVED_PRICE_ID_ONLY = 111;
  uint256 internal constant POSITION_TOO_SMALL = 112;
  uint256 internal constant SLIPPAGE_TOO_GREAT = 113;
  uint256 internal constant SLIPPAGE_EXCEEDS_LIMIT = 114;
  uint256 internal constant SWAP_MARGIN_MISMATCH = 115;
  uint256 internal constant INVALID_CLOSE_PERCENT = 116;
  uint256 internal constant INVALID_MARGIN = 117;
  uint256 internal constant ORDER_NOT_FOUND = 118;
  uint256 internal constant TRADER_OWNER_MISMATCH = 119;
  uint256 internal constant POSITIVE_EXPO = 120;
  uint256 internal constant NEGATIVE_PRICE = 121;
  uint256 internal constant INVALID_BURN_AMOUNT = 122;
  uint256 internal constant NOTHING_TO_BURN = 123;
  uint256 internal constant INVALID_TOKEN_DECIMALS = 124;
  uint256 internal constant MIN_BIGGER_THAN_MAX = 125;
  uint256 internal constant MAX_SMALLER_THAN_MIN = 126;
  uint256 internal constant MIN_SMALLER_THAN_THRESHOLD = 127;
  uint256 internal constant BURN_EXCEEDS_EXCESS = 128;
  uint256 internal constant PRICE_ID_MISMATCH = 129;
  uint256 internal constant TRADE_DIRECTION_MISMATCH = 130;
  uint256 internal constant CANNOT_LIQUIDATE = 131;
  uint256 internal constant INVALID_TIMESTAMP = 132;
  uint256 internal constant CANNOT_EXECUTE_LIMIT = 133;

  // Access
  uint256 internal constant APPROVED_ONLY = 200;
  uint256 internal constant TRADING_PAUSED = 201;
  uint256 internal constant USER_OR_LIQUIDATOR_ONLY = 202;
  uint256 internal constant USER_SENDER_MISMATCH = 203;
  uint256 internal constant LIQUIDATOR_ONLY = 204;
  uint256 internal constant DELEGATE_CALL_ONLY = 205;

  // Trading capacity
  uint256 internal constant MAX_OPEN_TRADES_PER_PRICE_ID = 300;
  uint256 internal constant MAX_OPEN_TRADES_PER_USER = 301;
  uint256 internal constant MAX_MARGIN_PER_USER = 302;
  uint256 internal constant MAX_LIQUIDITY_POOL = 303;

  // Pyth related
  uint256 internal constant INVALID_UPDATE_DATA_SOURCE = 400;
  uint256 internal constant INVALID_UPDATE_DATA = 401;
  uint256 internal constant INVALID_WORMHOLE_VAA = 402;
  uint256 internal constant PRICE_FEED_NOT_FOUND = 403;

  // Misc
  uint256 internal constant UNIMPLEMENTED = 998;
  uint256 internal constant SHOULD_NOT_HAPPEN = 999;
}

// SPDX-License-Identifier: GPL-3.0-or-later
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.8.17;

import "../Errors.sol";
import "./LogExpMath.sol";

/* solhint-disable private-vars-leading-underscore */

library FixedPoint {
  uint256 internal constant ONE = 1e18; // 18 decimal places
  uint256 internal constant TWO = 2 * ONE;
  uint256 internal constant FOUR = 4 * ONE;
  uint256 internal constant MAX_POW_RELATIVE_ERROR = 10000; // 10^(-14)

  // Minimum base for the power function when the exponent is 'free' (larger than ONE).
  uint256 internal constant MIN_POW_BASE_FREE_EXPONENT = 0.7e18;

  function abs(int256 a) internal pure returns (uint256 result) {
    // Equivalent to:
    // result = a > 0 ? uint256(a) : uint256(-a)
    assembly {
      let s := sar(255, a)
      result := sub(xor(a, s), s)
    }
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    // Fixed Point addition is the same as regular checked addition

    uint256 c = a + b;
    _require(c >= a, Errors.ADD_OVERFLOW);
    return c;
  }

  function add(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a + b;
    _require((b >= 0 && c >= a) || (b < 0 && c < a), Errors.ADD_OVERFLOW);
    return c;
  }

  function add(uint256 a, int256 b) internal pure returns (int256) {
    return add(int256(a), b);
  }

  function add(int256 a, uint256 b) internal pure returns (int256) {
    return add(a, int256(b));
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    // Fixed Point addition is the same as regular checked addition

    _require(b <= a, Errors.SUB_OVERFLOW);
    uint256 c = a - b;
    return c;
  }

  function sub(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a - b;
    _require((b >= 0 && c <= a) || (b < 0 && c > a), Errors.SUB_OVERFLOW);
    return c;
  }

  function sub(uint256 a, int256 b) internal pure returns (int256) {
    return sub(int256(a), b);
  }

  function sub(int256 a, uint256 b) internal pure returns (int256) {
    return sub(a, int256(b));
  }

  function mulDown(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 product = a * b;
    _require(a == 0 || product / a == b, Errors.MUL_OVERFLOW);

    return product / ONE;
  }

  function mulDown(int256 a, int256 b) internal pure returns (int256) {
    int256 product = a * b;
    _require(a == 0 || product / a == b, Errors.MUL_OVERFLOW);

    return product / int256(ONE);
  }

  function mulDown(uint256 a, int256 b) internal pure returns (int256) {
    return mulDown(int256(a), b);
  }

  function mulDown(int256 a, uint256 b) internal pure returns (int256) {
    return mulDown(a, int256(b));
  }

  function mulUp(uint256 a, uint256 b) internal pure returns (uint256 result) {
    uint256 product = a * b;
    _require(a == 0 || product / a == b, Errors.MUL_OVERFLOW);

    // The traditional divUp formula is:
    // divUp(x, y) := (x + y - 1) / y
    // To avoid intermediate overflow in the addition, we distribute the division and get:
    // divUp(x, y) := (x - 1) / y + 1
    // Note that this requires x != 0, if x == 0 then the result is zero
    //
    // Equivalent to:
    // result = product == 0 ? 0 : ((product - 1) / FixedPoint.ONE) + 1;
    assembly {
      result := mul(iszero(iszero(product)), add(div(sub(product, 1), ONE), 1))
    }
  }

  function divDown(uint256 a, uint256 b) internal pure returns (uint256) {
    _require(b != 0, Errors.ZERO_DIVISION);

    uint256 aInflated = a * ONE;
    _require(a == 0 || aInflated / a == ONE, Errors.DIV_INTERNAL); // mul overflow

    return aInflated / b;
  }

  function divDown(int256 a, int256 b) internal pure returns (int256) {
    _require(b != 0, Errors.ZERO_DIVISION);

    int256 aInflated = a * int256(ONE);
    _require(a == 0 || aInflated / a == int256(ONE), Errors.DIV_INTERNAL); // mul overflow

    return aInflated / b;
  }

  function divDown(uint256 a, int256 b) internal pure returns (int256) {
    return divDown(int256(a), b);
  }

  function divDown(int256 a, uint256 b) internal pure returns (int256) {
    return divDown(a, int256(b));
  }

  function divUp(uint256 a, uint256 b) internal pure returns (uint256 result) {
    _require(b != 0, Errors.ZERO_DIVISION);

    uint256 aInflated = a * ONE;
    _require(a == 0 || aInflated / a == ONE, Errors.DIV_INTERNAL); // mul overflow

    // The traditional divUp formula is:
    // divUp(x, y) := (x + y - 1) / y
    // To avoid intermediate overflow in the addition, we distribute the division and get:
    // divUp(x, y) := (x - 1) / y + 1
    // Note that this requires x != 0, if x == 0 then the result is zero
    //
    // Equivalent to:
    // result = a == 0 ? 0 : (a * FixedPoint.ONE - 1) / b + 1;
    assembly {
      result := mul(
        iszero(iszero(aInflated)),
        add(div(sub(aInflated, 1), b), 1)
      )
    }
  }

  /**
   * @dev Returns x^y, assuming both are fixed point numbers, rounding down. The result is guaranteed to not be above
   * the true value (that is, the error function expected - actual is always positive).
   */
  function powDown(uint256 x, uint256 y) internal pure returns (uint256) {
    // Optimize for when y equals 1.0, 2.0 or 4.0, as those are very simple to implement and occur often in 50/50
    // and 80/20 Weighted Pools
    if (y == ONE) {
      return x;
    } else if (y == TWO) {
      return mulDown(x, x);
    } else if (y == FOUR) {
      uint256 square = mulDown(x, x);
      return mulDown(square, square);
    } else {
      uint256 raw = LogExpMath.pow(x, y);
      uint256 maxError = add(mulUp(raw, MAX_POW_RELATIVE_ERROR), uint256(1));

      if (raw < maxError) {
        return 0;
      } else {
        return sub(raw, maxError);
      }
    }
  }

  /**
   * @dev Returns x^y, assuming both are fixed point numbers, rounding up. The result is guaranteed to not be below
   * the true value (that is, the error function expected - actual is always negative).
   */
  function powUp(uint256 x, uint256 y) internal pure returns (uint256) {
    // Optimize for when y equals 1.0, 2.0 or 4.0, as those are very simple to implement and occur often in 50/50
    // and 80/20 Weighted Pools
    if (y == ONE) {
      return x;
    } else if (y == TWO) {
      return mulUp(x, x);
    } else if (y == FOUR) {
      uint256 square = mulUp(x, x);
      return mulUp(square, square);
    } else {
      uint256 raw = LogExpMath.pow(x, y);
      uint256 maxError = add(mulUp(raw, MAX_POW_RELATIVE_ERROR), uint256(1));

      return add(raw, maxError);
    }
  }

  /**
   * @dev Returns the complement of a value (1 - x), capped to 0 if x is larger than 1.
   *
   * Useful when computing the complement for values with some level of relative error, as it strips this error and
   * prevents intermediate negative values.
   */
  function complement(uint256 x) internal pure returns (uint256 result) {
    // Equivalent to:
    // result = (x < ONE) ? (ONE - x) : 0;
    assembly {
      result := mul(lt(x, ONE), sub(ONE, x))
    }
  }

  /**
   * @dev Returns the largest of two numbers of 256 bits.
   */
  function max(uint256 a, uint256 b) internal pure returns (uint256 result) {
    // Equivalent to:
    // result = (a < b) ? b : a;
    assembly {
      result := sub(a, mul(sub(a, b), lt(a, b)))
    }
  }

  /**
   * @dev Returns the smallest of two numbers of 256 bits.
   */
  function min(uint256 a, uint256 b) internal pure returns (uint256 result) {
    // Equivalent to `result = (a < b) ? a : b`
    assembly {
      result := sub(a, mul(sub(a, b), gt(a, b)))
    }
  }
}

// SPDX-License-Identifier: MIT
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the “Software”), to deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.

// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

pragma solidity ^0.8.17;

import "../Errors.sol";

/* solhint-disable */

/**
 * @dev Exponentiation and logarithm functions for 18 decimal fixed point numbers (both base and exponent/argument).
 *
 * Exponentiation and logarithm with arbitrary bases (x^y and log_x(y)) are implemented by conversion to natural
 * exponentiation and logarithm (where the base is Euler's number).
 *
 * @author Fernando Martinelli - @fernandomartinelli
 * @author Sergio Yuhjtman - @sergioyuhjtman
 * @author Daniel Fernandez - @dmf7z
 */
library LogExpMath {
  // All fixed point multiplications and divisions are inlined. This means we need to divide by ONE when multiplying
  // two numbers, and multiply by ONE when dividing them.

  // All arguments and return values are 18 decimal fixed point numbers.
  int256 constant ONE_18 = 1e18;

  // Internally, intermediate values are computed with higher precision as 20 decimal fixed point numbers, and in the
  // case of ln36, 36 decimals.
  int256 constant ONE_20 = 1e20;
  int256 constant ONE_36 = 1e36;

  // The domain of natural exponentiation is bound by the word size and number of decimals used.
  //
  // Because internally the result will be stored using 20 decimals, the largest possible result is
  // (2^255 - 1) / 10^20, which makes the largest exponent ln((2^255 - 1) / 10^20) = 130.700829182905140221.
  // The smallest possible result is 10^(-18), which makes largest negative argument
  // ln(10^(-18)) = -41.446531673892822312.
  // We use 130.0 and -41.0 to have some safety margin.
  int256 constant MAX_NATURAL_EXPONENT = 130e18;
  int256 constant MIN_NATURAL_EXPONENT = -41e18;

  // Bounds for ln_36's argument. Both ln(0.9) and ln(1.1) can be represented with 36 decimal places in a fixed point
  // 256 bit integer.
  int256 constant LN_36_LOWER_BOUND = ONE_18 - 1e17;
  int256 constant LN_36_UPPER_BOUND = ONE_18 + 1e17;

  uint256 constant MILD_EXPONENT_BOUND = 2 ** 254 / uint256(ONE_20);

  // 18 decimal constants
  int256 constant x0 = 128000000000000000000; // 2ˆ7
  int256 constant a0 = 38877084059945950922200000000000000000000000000000000000; // eˆ(x0) (no decimals)
  int256 constant x1 = 64000000000000000000; // 2ˆ6
  int256 constant a1 = 6235149080811616882910000000; // eˆ(x1) (no decimals)

  // 20 decimal constants
  int256 constant x2 = 3200000000000000000000; // 2ˆ5
  int256 constant a2 = 7896296018268069516100000000000000; // eˆ(x2)
  int256 constant x3 = 1600000000000000000000; // 2ˆ4
  int256 constant a3 = 888611052050787263676000000; // eˆ(x3)
  int256 constant x4 = 800000000000000000000; // 2ˆ3
  int256 constant a4 = 298095798704172827474000; // eˆ(x4)
  int256 constant x5 = 400000000000000000000; // 2ˆ2
  int256 constant a5 = 5459815003314423907810; // eˆ(x5)
  int256 constant x6 = 200000000000000000000; // 2ˆ1
  int256 constant a6 = 738905609893065022723; // eˆ(x6)
  int256 constant x7 = 100000000000000000000; // 2ˆ0
  int256 constant a7 = 271828182845904523536; // eˆ(x7)
  int256 constant x8 = 50000000000000000000; // 2ˆ-1
  int256 constant a8 = 164872127070012814685; // eˆ(x8)
  int256 constant x9 = 25000000000000000000; // 2ˆ-2
  int256 constant a9 = 128402541668774148407; // eˆ(x9)
  int256 constant x10 = 12500000000000000000; // 2ˆ-3
  int256 constant a10 = 113314845306682631683; // eˆ(x10)
  int256 constant x11 = 6250000000000000000; // 2ˆ-4
  int256 constant a11 = 106449445891785942956; // eˆ(x11)

  /**
   * @dev Exponentiation (x^y) with unsigned 18 decimal fixed point base and exponent.
   *
   * Reverts if ln(x) * y is smaller than `MIN_NATURAL_EXPONENT`, or larger than `MAX_NATURAL_EXPONENT`.
   */
  function pow(uint256 x, uint256 y) internal pure returns (uint256) {
    if (y == 0) {
      // We solve the 0^0 indetermination by making it equal one.
      return uint256(ONE_18);
    }

    if (x == 0) {
      return 0;
    }

    // Instead of computing x^y directly, we instead rely on the properties of logarithms and exponentiation to
    // arrive at that result. In particular, exp(ln(x)) = x, and ln(x^y) = y * ln(x). This means
    // x^y = exp(y * ln(x)).

    // The ln function takes a signed value, so we need to make sure x fits in the signed 256 bit range.
    _require(x >> 255 == 0, Errors.X_OUT_OF_BOUNDS);
    int256 x_int256 = int256(x);

    // We will compute y * ln(x) in a single step. Depending on the value of x, we can either use ln or ln_36. In
    // both cases, we leave the division by ONE_18 (due to fixed point multiplication) to the end.

    // This prevents y * ln(x) from overflowing, and at the same time guarantees y fits in the signed 256 bit range.
    _require(y < MILD_EXPONENT_BOUND, Errors.Y_OUT_OF_BOUNDS);
    int256 y_int256 = int256(y);

    int256 logx_times_y;
    if (LN_36_LOWER_BOUND < x_int256 && x_int256 < LN_36_UPPER_BOUND) {
      int256 ln_36_x = _ln_36(x_int256);

      // ln_36_x has 36 decimal places, so multiplying by y_int256 isn't as straightforward, since we can't just
      // bring y_int256 to 36 decimal places, as it might overflow. Instead, we perform two 18 decimal
      // multiplications and add the results: one with the first 18 decimals of ln_36_x, and one with the
      // (downscaled) last 18 decimals.
      logx_times_y = ((ln_36_x / ONE_18) *
        y_int256 +
        ((ln_36_x % ONE_18) * y_int256) /
        ONE_18);
    } else {
      logx_times_y = _ln(x_int256) * y_int256;
    }
    logx_times_y /= ONE_18;

    // Finally, we compute exp(y * ln(x)) to arrive at x^y
    _require(
      MIN_NATURAL_EXPONENT <= logx_times_y &&
        logx_times_y <= MAX_NATURAL_EXPONENT,
      Errors.PRODUCT_OUT_OF_BOUNDS
    );

    return uint256(exp(logx_times_y));
  }

  /**
   * @dev Natural exponentiation (e^x) with signed 18 decimal fixed point exponent.
   *
   * Reverts if `x` is smaller than MIN_NATURAL_EXPONENT, or larger than `MAX_NATURAL_EXPONENT`.
   */
  function exp(int256 x) internal pure returns (int256) {
    _require(
      x >= MIN_NATURAL_EXPONENT && x <= MAX_NATURAL_EXPONENT,
      Errors.INVALID_EXPONENT
    );

    if (x < 0) {
      // We only handle positive exponents: e^(-x) is computed as 1 / e^x. We can safely make x positive since it
      // fits in the signed 256 bit range (as it is larger than MIN_NATURAL_EXPONENT).
      // Fixed point division requires multiplying by ONE_18.
      return ((ONE_18 * ONE_18) / exp(-x));
    }

    // First, we use the fact that e^(x+y) = e^x * e^y to decompose x into a sum of powers of two, which we call x_n,
    // where x_n == 2^(7 - n), and e^x_n = a_n has been precomputed. We choose the first x_n, x0, to equal 2^7
    // because all larger powers are larger than MAX_NATURAL_EXPONENT, and therefore not present in the
    // decomposition.
    // At the end of this process we will have the product of all e^x_n = a_n that apply, and the remainder of this
    // decomposition, which will be lower than the smallest x_n.
    // exp(x) = k_0 * a_0 * k_1 * a_1 * ... + k_n * a_n * exp(remainder), where each k_n equals either 0 or 1.
    // We mutate x by subtracting x_n, making it the remainder of the decomposition.

    // The first two a_n (e^(2^7) and e^(2^6)) are too large if stored as 18 decimal numbers, and could cause
    // intermediate overflows. Instead we store them as plain integers, with 0 decimals.
    // Additionally, x0 + x1 is larger than MAX_NATURAL_EXPONENT, which means they will not both be present in the
    // decomposition.

    // For each x_n, we test if that term is present in the decomposition (if x is larger than it), and if so deduct
    // it and compute the accumulated product.

    int256 firstAN;
    if (x >= x0) {
      x -= x0;
      firstAN = a0;
    } else if (x >= x1) {
      x -= x1;
      firstAN = a1;
    } else {
      firstAN = 1; // One with no decimal places
    }

    // We now transform x into a 20 decimal fixed point number, to have enhanced precision when computing the
    // smaller terms.
    x *= 100;

    // `product` is the accumulated product of all a_n (except a0 and a1), which starts at 20 decimal fixed point
    // one. Recall that fixed point multiplication requires dividing by ONE_20.
    int256 product = ONE_20;

    if (x >= x2) {
      x -= x2;
      product = (product * a2) / ONE_20;
    }
    if (x >= x3) {
      x -= x3;
      product = (product * a3) / ONE_20;
    }
    if (x >= x4) {
      x -= x4;
      product = (product * a4) / ONE_20;
    }
    if (x >= x5) {
      x -= x5;
      product = (product * a5) / ONE_20;
    }
    if (x >= x6) {
      x -= x6;
      product = (product * a6) / ONE_20;
    }
    if (x >= x7) {
      x -= x7;
      product = (product * a7) / ONE_20;
    }
    if (x >= x8) {
      x -= x8;
      product = (product * a8) / ONE_20;
    }
    if (x >= x9) {
      x -= x9;
      product = (product * a9) / ONE_20;
    }

    // x10 and x11 are unnecessary here since we have high enough precision already.

    // Now we need to compute e^x, where x is small (in particular, it is smaller than x9). We use the Taylor series
    // expansion for e^x: 1 + x + (x^2 / 2!) + (x^3 / 3!) + ... + (x^n / n!).

    int256 seriesSum = ONE_20; // The initial one in the sum, with 20 decimal places.
    int256 term; // Each term in the sum, where the nth term is (x^n / n!).

    // The first term is simply x.
    term = x;
    seriesSum += term;

    // Each term (x^n / n!) equals the previous one times x, divided by n. Since x is a fixed point number,
    // multiplying by it requires dividing by ONE_20, but dividing by the non-fixed point n values does not.

    term = ((term * x) / ONE_20) / 2;
    seriesSum += term;

    term = ((term * x) / ONE_20) / 3;
    seriesSum += term;

    term = ((term * x) / ONE_20) / 4;
    seriesSum += term;

    term = ((term * x) / ONE_20) / 5;
    seriesSum += term;

    term = ((term * x) / ONE_20) / 6;
    seriesSum += term;

    term = ((term * x) / ONE_20) / 7;
    seriesSum += term;

    term = ((term * x) / ONE_20) / 8;
    seriesSum += term;

    term = ((term * x) / ONE_20) / 9;
    seriesSum += term;

    term = ((term * x) / ONE_20) / 10;
    seriesSum += term;

    term = ((term * x) / ONE_20) / 11;
    seriesSum += term;

    term = ((term * x) / ONE_20) / 12;
    seriesSum += term;

    // 12 Taylor terms are sufficient for 18 decimal precision.

    // We now have the first a_n (with no decimals), and the product of all other a_n present, and the Taylor
    // approximation of the exponentiation of the remainder (both with 20 decimals). All that remains is to multiply
    // all three (one 20 decimal fixed point multiplication, dividing by ONE_20, and one integer multiplication),
    // and then drop two digits to return an 18 decimal value.

    return (((product * seriesSum) / ONE_20) * firstAN) / 100;
  }

  /**
   * @dev Logarithm (log(arg, base), with signed 18 decimal fixed point base and argument.
   */
  function log(int256 arg, int256 base) internal pure returns (int256) {
    // This performs a simple base change: log(arg, base) = ln(arg) / ln(base).

    // Both logBase and logArg are computed as 36 decimal fixed point numbers, either by using ln_36, or by
    // upscaling.

    int256 logBase;
    if (LN_36_LOWER_BOUND < base && base < LN_36_UPPER_BOUND) {
      logBase = _ln_36(base);
    } else {
      logBase = _ln(base) * ONE_18;
    }

    int256 logArg;
    if (LN_36_LOWER_BOUND < arg && arg < LN_36_UPPER_BOUND) {
      logArg = _ln_36(arg);
    } else {
      logArg = _ln(arg) * ONE_18;
    }

    // When dividing, we multiply by ONE_18 to arrive at a result with 18 decimal places
    return (logArg * ONE_18) / logBase;
  }

  /**
   * @dev Natural logarithm (ln(a)) with signed 18 decimal fixed point argument.
   */
  function ln(int256 a) internal pure returns (int256) {
    // The real natural logarithm is not defined for negative numbers or zero.
    _require(a > 0, Errors.OUT_OF_BOUNDS);
    if (LN_36_LOWER_BOUND < a && a < LN_36_UPPER_BOUND) {
      return _ln_36(a) / ONE_18;
    } else {
      return _ln(a);
    }
  }

  /**
   * @dev Internal natural logarithm (ln(a)) with signed 18 decimal fixed point argument.
   */
  function _ln(int256 a) private pure returns (int256) {
    if (a < ONE_18) {
      // Since ln(a^k) = k * ln(a), we can compute ln(a) as ln(a) = ln((1/a)^(-1)) = - ln((1/a)). If a is less
      // than one, 1/a will be greater than one, and this if statement will not be entered in the recursive call.
      // Fixed point division requires multiplying by ONE_18.
      return (-_ln((ONE_18 * ONE_18) / a));
    }

    // First, we use the fact that ln^(a * b) = ln(a) + ln(b) to decompose ln(a) into a sum of powers of two, which
    // we call x_n, where x_n == 2^(7 - n), which are the natural logarithm of precomputed quantities a_n (that is,
    // ln(a_n) = x_n). We choose the first x_n, x0, to equal 2^7 because the exponential of all larger powers cannot
    // be represented as 18 fixed point decimal numbers in 256 bits, and are therefore larger than a.
    // At the end of this process we will have the sum of all x_n = ln(a_n) that apply, and the remainder of this
    // decomposition, which will be lower than the smallest a_n.
    // ln(a) = k_0 * x_0 + k_1 * x_1 + ... + k_n * x_n + ln(remainder), where each k_n equals either 0 or 1.
    // We mutate a by subtracting a_n, making it the remainder of the decomposition.

    // For reasons related to how `exp` works, the first two a_n (e^(2^7) and e^(2^6)) are not stored as fixed point
    // numbers with 18 decimals, but instead as plain integers with 0 decimals, so we need to multiply them by
    // ONE_18 to convert them to fixed point.
    // For each a_n, we test if that term is present in the decomposition (if a is larger than it), and if so divide
    // by it and compute the accumulated sum.

    int256 sum = 0;
    if (a >= a0 * ONE_18) {
      a /= a0; // Integer, not fixed point division
      sum += x0;
    }

    if (a >= a1 * ONE_18) {
      a /= a1; // Integer, not fixed point division
      sum += x1;
    }

    // All other a_n and x_n are stored as 20 digit fixed point numbers, so we convert the sum and a to this format.
    sum *= 100;
    a *= 100;

    // Because further a_n are  20 digit fixed point numbers, we multiply by ONE_20 when dividing by them.

    if (a >= a2) {
      a = (a * ONE_20) / a2;
      sum += x2;
    }

    if (a >= a3) {
      a = (a * ONE_20) / a3;
      sum += x3;
    }

    if (a >= a4) {
      a = (a * ONE_20) / a4;
      sum += x4;
    }

    if (a >= a5) {
      a = (a * ONE_20) / a5;
      sum += x5;
    }

    if (a >= a6) {
      a = (a * ONE_20) / a6;
      sum += x6;
    }

    if (a >= a7) {
      a = (a * ONE_20) / a7;
      sum += x7;
    }

    if (a >= a8) {
      a = (a * ONE_20) / a8;
      sum += x8;
    }

    if (a >= a9) {
      a = (a * ONE_20) / a9;
      sum += x9;
    }

    if (a >= a10) {
      a = (a * ONE_20) / a10;
      sum += x10;
    }

    if (a >= a11) {
      a = (a * ONE_20) / a11;
      sum += x11;
    }

    // a is now a small number (smaller than a_11, which roughly equals 1.06). This means we can use a Taylor series
    // that converges rapidly for values of `a` close to one - the same one used in ln_36.
    // Let z = (a - 1) / (a + 1).
    // ln(a) = 2 * (z + z^3 / 3 + z^5 / 5 + z^7 / 7 + ... + z^(2 * n + 1) / (2 * n + 1))

    // Recall that 20 digit fixed point division requires multiplying by ONE_20, and multiplication requires
    // division by ONE_20.
    int256 z = ((a - ONE_20) * ONE_20) / (a + ONE_20);
    int256 z_squared = (z * z) / ONE_20;

    // num is the numerator of the series: the z^(2 * n + 1) term
    int256 num = z;

    // seriesSum holds the accumulated sum of each term in the series, starting with the initial z
    int256 seriesSum = num;

    // In each step, the numerator is multiplied by z^2
    num = (num * z_squared) / ONE_20;
    seriesSum += num / 3;

    num = (num * z_squared) / ONE_20;
    seriesSum += num / 5;

    num = (num * z_squared) / ONE_20;
    seriesSum += num / 7;

    num = (num * z_squared) / ONE_20;
    seriesSum += num / 9;

    num = (num * z_squared) / ONE_20;
    seriesSum += num / 11;

    // 6 Taylor terms are sufficient for 36 decimal precision.

    // Finally, we multiply by 2 (non fixed point) to compute ln(remainder)
    seriesSum *= 2;

    // We now have the sum of all x_n present, and the Taylor approximation of the logarithm of the remainder (both
    // with 20 decimals). All that remains is to sum these two, and then drop two digits to return a 18 decimal
    // value.

    return (sum + seriesSum) / 100;
  }

  /**
   * @dev Intrnal high precision (36 decimal places) natural logarithm (ln(x)) with signed 18 decimal fixed point argument,
   * for x close to one.
   *
   * Should only be used if x is between LN_36_LOWER_BOUND and LN_36_UPPER_BOUND.
   */
  function _ln_36(int256 x) private pure returns (int256) {
    // Since ln(1) = 0, a value of x close to one will yield a very small result, which makes using 36 digits
    // worthwhile.

    // First, we transform x to a 36 digit fixed point value.
    x *= ONE_18;

    // We will use the following Taylor expansion, which converges very rapidly. Let z = (x - 1) / (x + 1).
    // ln(x) = 2 * (z + z^3 / 3 + z^5 / 5 + z^7 / 7 + ... + z^(2 * n + 1) / (2 * n + 1))

    // Recall that 36 digit fixed point division requires multiplying by ONE_36, and multiplication requires
    // division by ONE_36.
    int256 z = ((x - ONE_36) * ONE_36) / (x + ONE_36);
    int256 z_squared = (z * z) / ONE_36;

    // num is the numerator of the series: the z^(2 * n + 1) term
    int256 num = z;

    // seriesSum holds the accumulated sum of each term in the series, starting with the initial z
    int256 seriesSum = num;

    // In each step, the numerator is multiplied by z^2
    num = (num * z_squared) / ONE_36;
    seriesSum += num / 3;

    num = (num * z_squared) / ONE_36;
    seriesSum += num / 5;

    num = (num * z_squared) / ONE_36;
    seriesSum += num / 7;

    num = (num * z_squared) / ONE_36;
    seriesSum += num / 9;

    num = (num * z_squared) / ONE_36;
    seriesSum += num / 11;

    num = (num * z_squared) / ONE_36;
    seriesSum += num / 13;

    num = (num * z_squared) / ONE_36;
    seriesSum += num / 15;

    // 8 Taylor terms are sufficient for 36 decimal precision.

    // All that remains is multiplying by 2 (non fixed point).
    return seriesSum * 2;
  }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.17;

import "../interfaces/AbstractRegistry.sol";
import "../interfaces/ITradingBook.sol";
import "./math/FixedPoint.sol";
import "./Errors.sol";

library TradingCoreLib {
  using FixedPoint for uint256;
  using FixedPoint for int256;

  function getSlippage(
    AbstractRegistry registry,
    bytes32 priceId,
    bool isBuy,
    uint256 price,
    uint256 position
  ) internal view returns (uint256) {
    uint256 impact = (
      (
        isBuy
          ? registry.totalLongPerPriceId(priceId)
          : registry.totalShortPerPriceId(priceId)
      ).add(position)
    ).divDown(
        isBuy
          ? registry.impactRefDepthLongPerPriceId(priceId)
          : registry.impactRefDepthShortPerPriceId(priceId)
      );
    return price.mulDown(impact).divDown(uint256(100e18));
  }

  function _closeTrade(
    AbstractRegistry registry,
    IRegistry.Trade memory trade,
    uint256 closeMargin,
    uint256 closePrice
  ) internal view returns (ITradingBook.OnCloseTrade memory onCloseTrade) {
    onCloseTrade = ITradingBook.OnCloseTrade(0, 0, 0, 0, false, false);

    onCloseTrade.grossPnL = 0;
    uint256 closePosition = trade.leverage.mulDown(closeMargin);

    (uint256 averageFundingFee, int256 averageImbalance) = _getFundingFeePct(
      registry,
      trade
    );
    onCloseTrade.accumulatedFee =
      averageFundingFee.mulDown(
        averageImbalance.mulDown(closePosition).add(closeMargin)
      ) *
      int256(block.number - trade.executionBlock);

    uint256 openNet = trade.isBuy
      ? trade.openPrice.add(trade.slippage)
      : trade.openPrice.sub(trade.slippage);

    onCloseTrade.closeNet = trade.isBuy
      ? uint256(
        closePrice.sub(
          onCloseTrade.accumulatedFee.mulDown(openNet).divDown(closePosition)
        )
      )
      : uint256(
        closePrice.add(
          onCloseTrade.accumulatedFee.mulDown(openNet).divDown(closePosition)
        )
      );

    // guaranteed execution (** before ** slippage)
    onCloseTrade.isStop = false;
    onCloseTrade.isLiquidated = false;
    if (
      trade.stopLoss > 0 &&
      ((trade.isBuy && onCloseTrade.closeNet <= trade.stopLoss) ||
        (!trade.isBuy && onCloseTrade.closeNet >= trade.stopLoss))
    ) {
      onCloseTrade.isStop = true;
      onCloseTrade.closeNet = trade.stopLoss;
    }
    if (
      trade.profitTarget > 0 &&
      ((trade.isBuy && onCloseTrade.closeNet >= trade.profitTarget) ||
        (!trade.isBuy && onCloseTrade.closeNet <= trade.profitTarget))
    ) {
      onCloseTrade.isStop = true;
      onCloseTrade.closeNet = trade.profitTarget;
    }
    if (
      !onCloseTrade.isStop &&
      ((trade.isBuy && onCloseTrade.closeNet <= trade.liquidationPrice) ||
        (!trade.isBuy && onCloseTrade.closeNet >= trade.liquidationPrice))
    ) {
      onCloseTrade.isLiquidated = true;
      onCloseTrade.closeNet = trade.liquidationPrice;
    }

    onCloseTrade.slippage = getSlippage(
      registry,
      trade.priceId,
      !trade.isBuy,
      onCloseTrade.closeNet,
      closePosition
    );
    onCloseTrade.closeNet = trade.isBuy
      ? onCloseTrade.closeNet.sub(onCloseTrade.slippage)
      : onCloseTrade.closeNet.add(onCloseTrade.slippage);

    uint256 absPositionPnL = (
      onCloseTrade.closeNet > openNet
        ? onCloseTrade.closeNet.sub(openNet)
        : openNet.sub(onCloseTrade.closeNet)
    ).mulDown(closePosition).divDown(openNet);

    bool isWinningMoney = (trade.isBuy && onCloseTrade.closeNet > openNet) ||
      (!trade.isBuy && openNet > onCloseTrade.closeNet);

    if (isWinningMoney) {
      onCloseTrade.grossPnL = closeMargin.add(absPositionPnL);
    } else {
      onCloseTrade.grossPnL = closeMargin < absPositionPnL
        ? 0
        : closeMargin.sub(absPositionPnL);
    }

    if (onCloseTrade.grossPnL > closeMargin.mulDown(trade.maxPercentagePnL)) {
      onCloseTrade.isStop = true;
      onCloseTrade.grossPnL = closeMargin.mulDown(trade.maxPercentagePnL);
    }
  }

  function _updateTrade(
    AbstractRegistry registry,
    bytes32 orderHash,
    uint256 closePrice,
    uint256 margin,
    bool isAdd
  ) internal view returns (IRegistry.Trade memory trade) {
    trade = registry.openTradeByOrderHash(orderHash);

    uint256 position = trade.leverage.mulDown(trade.margin);

    {
      if (isAdd) {
        uint256 maxMargin = position.divDown(
          registry.minLeveragePerPriceId(trade.priceId)
        );
        _require(trade.margin.add(margin) <= maxMargin, Errors.INVALID_MARGIN);

        trade.margin = trade.margin.add(margin);
      } else {
        uint256 minMargin = position.divDown(
          registry.maxLeveragePerPriceId(trade.priceId)
        );
        _require(trade.margin > margin, Errors.INVALID_MARGIN);
        _require(
          trade.margin.sub(margin) >= minMargin,
          Errors.LEVERAGE_TOO_HIGH
        );

        trade.margin = trade.margin.sub(margin);
      }
    }

    trade.leverage = position.divDown(trade.margin);

    {
      (uint256 averageFundingFee, int256 averageImbalance) = _getFundingFeePct(
        registry,
        trade
      );
      int256 accumulatedFee = averageFundingFee.mulDown(
        averageImbalance.mulDown(position).add(trade.margin)
      ) * int256(block.number - trade.executionBlock);

      if (trade.isBuy) {
        uint256 executionPrice = trade.openPrice.add(trade.slippage);
        int256 accumulatedFeePerPrice = executionPrice
          .mulDown(accumulatedFee)
          .divDown(position);
        trade.liquidationPrice = executionPrice.mulDown(
          trade
            .leverage
            .sub(registry.liquidationThresholdPerPriceId(trade.priceId))
            .divDown(trade.leverage)
        );
        _require(
          closePrice >
            uint256(trade.liquidationPrice.add(accumulatedFeePerPrice)),
          Errors.INVALID_MARGIN
        );
      } else {
        uint256 executionPrice = trade.openPrice.sub(trade.slippage);
        int256 accumulatedFeePerPrice = executionPrice
          .mulDown(accumulatedFee)
          .divDown(position);
        trade.liquidationPrice = executionPrice.mulDown(
          trade
            .leverage
            .add(registry.liquidationThresholdPerPriceId(trade.priceId))
            .divDown(trade.leverage)
        );
        _require(
          closePrice <
            uint256(trade.liquidationPrice.sub(accumulatedFeePerPrice)),
          Errors.INVALID_MARGIN
        );
      }
    }

    trade.maxPercentagePnL = position
      .divDown(registry.maxPercentagePnLFactor())
      .divDown(trade.margin)
      .min(registry.maxPercentagePnLCap())
      .max(registry.maxPercentagePnLFloor());
  }

  function _getFundingFeePct(
    AbstractRegistry registry,
    IRegistry.Trade memory trade
  ) internal view returns (uint256 averageFee, int256 averageImbalance) {
    IRegistry.SignedUpdateable memory imbalance = trade.isBuy
      ? registry.longImbalancePerPriceId(trade.priceId)
      : registry.shortImbalancePerPriceId(trade.priceId);

    averageImbalance = imbalance.current;
    if (trade.executionBlock < imbalance.lastUpdate) {
      averageImbalance =
        (imbalance.current *
          int256(block.number - imbalance.lastUpdate) +
          imbalance.uptoLastUpdate *
          int256(imbalance.lastUpdate - trade.executionBlock)) /
        int256(block.number - trade.executionBlock);
    }

    IRegistry.Updateable memory fundingFee = registry.fundingFeePerPriceId(
      trade.priceId
    );
    averageFee = fundingFee.current;
    if (trade.executionBlock < fundingFee.lastUpdate) {
      averageFee =
        (fundingFee.current *
          (block.number - fundingFee.lastUpdate) +
          fundingFee.uptoLastUpdate *
          (fundingFee.lastUpdate - trade.executionBlock)) /
        (block.number - trade.executionBlock);
    }
  }
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.17;

import "./libs/TradingCoreLib.sol";
import "./interfaces/AbstractPool.sol";
import "./interfaces/AbstractRegistry.sol";
import "./interfaces/ITradingBook.sol";
import "./interfaces/AbstractOracleAggregator.sol";
import "./libs/math/FixedPoint.sol";
import "./libs/ERC20Fixed.sol";
import "./libs/Errors.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TradingCore is
  ITradingBook,
  OwnableUpgradeable,
  AccessControlUpgradeable,
  ReentrancyGuardUpgradeable
{
  using FixedPoint for uint256;
  using FixedPoint for int256;
  using ERC20Fixed for ERC20;
  using TradingCoreLib for AbstractRegistry;

  bytes32 public constant APPROVED_ROLE = keccak256("APPROVED_ROLE");

  AbstractRegistry public registry;
  AbstractPool public liquidityPool;
  AbstractPool public marginPool;
  ERC20 public baseToken;

  AbstractOracleAggregator public oracleAggregator; //settable

  bool public isPaused;

  uint256 public liquidationStart;
  uint256 public liquidationEnd;

  event SetOracleAggregatorEvent(AbstractOracleAggregator oracleAggregator);

  function initialize(
    address _owner,
    AbstractOracleAggregator _oracleAggregator,
    ERC20 _baseToken,
    AbstractPool _liquidityPool,
    AbstractRegistry _registry,
    AbstractPool _marginPool
  ) public initializer {
    _transferOwnership(_owner);
    _grantRole(DEFAULT_ADMIN_ROLE, _owner);
    baseToken = _baseToken;
    liquidityPool = _liquidityPool;
    registry = _registry;
    marginPool = _marginPool;
    oracleAggregator = _oracleAggregator;
  }

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  // modifiers

  modifier onlyLiquidator() {
    _require(
      registry.hasRole(registry.LIQUIDATOR_ROLE(), msg.sender),
      Errors.LIQUIDATOR_ONLY
    );
    _;
  }

  modifier notPaused() {
    _require(!isPaused, Errors.TRADING_PAUSED);
    _;
  }

  // governance functions

  function pause() public onlyOwner {
    isPaused = !isPaused;
    emit PausedEvent(isPaused);
  }

  function setOracleAggregator(
    AbstractOracleAggregator _oracleAggregator
  ) public onlyOwner {
    oracleAggregator = _oracleAggregator;
    emit SetOracleAggregatorEvent(oracleAggregator);
  }

  // priviledged functions

  function createTrade(
    OpenTradeInput memory openData,
    uint256 openPrice,
    uint256 slippage
  ) public view onlyRole(APPROVED_ROLE) returns (IRegistry.Trade memory) {
    return _createTrade(openData, openPrice, slippage);
  }

  function openMarketOrder(
    OpenTradeInput calldata openData,
    uint256 openPrice
  ) public notPaused nonReentrant onlyRole(APPROVED_ROLE) {
    _openMarketOrder(openData, openPrice);
  }

  function liquidateMarketOrder(
    CloseTradeInput calldata closeData,
    bytes[] calldata priceData
  ) public notPaused nonReentrant onlyLiquidator returns (uint256) {
    IRegistry.Trade memory trade = registry.openTradeByOrderHash(
      closeData.orderHash
    );

    IOracleProvider.PricePackage memory pricePackage = oracleAggregator
      .parsePriceFeed(trade.priceId, !trade.isBuy, priceData);
    _require(
      trade.executionTime < pricePackage.publishTime,
      Errors.INVALID_TIMESTAMP
    );

    return _closeMarketOrder(closeData, pricePackage.price, trade, true);
  }

  // public functions

  function openMarketOrder(
    OpenTradeInput calldata openData,
    bytes[] calldata priceData
  ) public payable notPaused nonReentrant {
    _require(
      openData.user == msg.sender || hasRole(APPROVED_ROLE, msg.sender),
      Errors.USER_SENDER_MISMATCH
    );

    uint256 updateFee = oracleAggregator.getUpdateFee(priceData.length);
    IOracleProvider.PricePackage memory pricePackage = oracleAggregator
      .updateLatestPrice{value: updateFee}(
      openData.priceId,
      openData.isBuy,
      priceData,
      updateFee
    );

    _openMarketOrder(openData, pricePackage.price);
  }

  function closeMarketOrder(
    CloseTradeInput calldata closeData,
    bytes[] calldata priceData
  ) public payable notPaused nonReentrant returns (uint256 settled) {
    IRegistry.Trade memory trade = registry.openTradeByOrderHash(
      closeData.orderHash
    );

    _require(
      trade.user == msg.sender || hasRole(APPROVED_ROLE, msg.sender),
      Errors.USER_SENDER_MISMATCH
    );

    uint256 updateFee = oracleAggregator.getUpdateFee(priceData.length);
    IOracleProvider.PricePackage memory pricePackage = oracleAggregator
      .updateLatestPrice{value: updateFee}(
      trade.priceId,
      !trade.isBuy,
      priceData,
      updateFee
    );

    settled = _closeMarketOrder(closeData, pricePackage.price, trade, false);
  }

  function addMargin(
    bytes32 orderHash,
    bytes[] calldata priceData,
    uint256 margin
  ) public payable notPaused nonReentrant {
    IRegistry.Trade memory t = registry.openTradeByOrderHash(orderHash);

    _require(
      t.user == msg.sender || hasRole(APPROVED_ROLE, msg.sender),
      Errors.USER_SENDER_MISMATCH
    );

    uint256 updateFee = oracleAggregator.getUpdateFee(priceData.length);
    IOracleProvider.PricePackage memory pricePackage = oracleAggregator
      .updateLatestPrice{value: updateFee}(
      t.priceId,
      !t.isBuy,
      priceData,
      updateFee
    );

    IRegistry.Trade memory trade = registry._updateTrade(
      orderHash,
      pricePackage.price,
      margin,
      true
    );

    registry.updateOpenOrder(orderHash, trade);
    baseToken.transferFromFixed(msg.sender, address(marginPool), margin);
    emit UpdateOpenOrderEvent(t.user, orderHash, trade, true, margin);
  }

  function removeMargin(
    bytes32 orderHash,
    bytes[] calldata priceData,
    uint256 margin
  ) public payable notPaused nonReentrant {
    IRegistry.Trade memory t = registry.openTradeByOrderHash(orderHash);

    _require(
      t.user == msg.sender || hasRole(APPROVED_ROLE, msg.sender),
      Errors.USER_SENDER_MISMATCH
    );

    uint256 updateFee = oracleAggregator.getUpdateFee(priceData.length);
    IOracleProvider.PricePackage memory pricePackage = oracleAggregator
      .updateLatestPrice{value: updateFee}(
      t.priceId,
      !t.isBuy,
      priceData,
      updateFee
    );

    IRegistry.Trade memory trade = registry._updateTrade(
      orderHash,
      pricePackage.price,
      margin,
      false
    );

    registry.updateOpenOrder(orderHash, trade);
    marginPool.transferBase(msg.sender, margin);
    emit UpdateOpenOrderEvent(t.user, orderHash, trade, false, margin);
  }

  function updateStop(
    bytes32 orderHash,
    uint256 _profitTarget,
    uint256 _stopLoss
  ) public notPaused {
    IRegistry.Trade memory t = registry.openTradeByOrderHash(orderHash);
    _require(t.user == msg.sender, Errors.USER_SENDER_MISMATCH);

    IRegistry.Trade memory trade = _updateStop(t, _profitTarget, _stopLoss);
    registry.updateOpenOrder(orderHash, trade);
    emit UpdateOpenOrderEvent(msg.sender, orderHash, trade, true, 0);
  }

  function getSlippage(
    bytes32 priceId,
    bool isBuy,
    uint256 price,
    uint256 position
  ) public view returns (uint256) {
    return registry.getSlippage(priceId, isBuy, price, position);
  }

  function getFundingFeePct(
    bytes32 orderHash
  ) public view returns (uint256 averageFee, int256 averageImbalance) {
    return registry._getFundingFeePct(registry.openTradeByOrderHash(orderHash));
  }

  function _updateStop(
    IRegistry.Trade memory trade,
    uint256 _profitTarget,
    uint256 _stopLoss
  ) public pure returns (IRegistry.Trade memory) {
    _require(
      _stopLoss == 0 ||
        (
          trade.isBuy
            ? _stopLoss < trade.openPrice
            : _stopLoss > trade.openPrice
        ),
      Errors.INVALID_STOP_LOSS
    );
    _require(
      _profitTarget == 0 ||
        (
          trade.isBuy
            ? _profitTarget > trade.openPrice
            : _profitTarget < trade.openPrice
        ),
      Errors.INVALID_PROFIT_TARGET
    );

    trade.stopLoss = _stopLoss;
    trade.profitTarget = _profitTarget;

    return trade;
  }

  function tryOpenMarketOrder(
    OpenTradeInput memory openData,
    uint256 openPrice
  ) public view returns (uint256 fee, IRegistry.Trade memory trade) {
    fee = openData.leverage.mulDown(openData.margin).mulDown(registry.fee());
    _require(fee < openData.margin, Errors.FEE_TOO_HIGH);
    openData.margin -= fee;

    uint256 slippage = getSlippage(
      openData.priceId,
      openData.isBuy,
      openPrice,
      openData.leverage.mulDown(openData.margin)
    );
    trade = _createTrade(openData, openPrice, slippage);
  }

  // internal functions

  function _openMarketOrder(
    OpenTradeInput memory openData,
    uint256 openPrice
  ) internal {
    (uint256 fee, IRegistry.Trade memory trade) = tryOpenMarketOrder(
      openData,
      openPrice
    );

    bytes32 orderHash = registry.openMarketOrder(trade);

    baseToken.transferFromFixed(msg.sender, address(marginPool), trade.margin);
    baseToken.transferFromFixed(msg.sender, owner(), fee);

    emit OpenMarketOrderEvent(openData.user, orderHash, trade, fee);
  }

  function _closeMarketOrder(
    CloseTradeInput memory closeData,
    uint256 closePrice,
    IRegistry.Trade memory trade,
    bool isLiquidator
  ) internal returns (uint256 settled) {
    _require(
      isLiquidator
        ? closeData.closePercent == 1e18
        : (closeData.closePercent > 0 && closeData.closePercent <= 1e18),
      Errors.INVALID_CLOSE_PERCENT
    );

    uint256 closeMargin = trade.margin.mulDown(closeData.closePercent);

    OnCloseTrade memory onCloseTrade = registry._closeTrade(
      trade,
      closeMargin,
      closePrice
    );

    _require(
      trade.isBuy
        ? closeData.limitPrice <= onCloseTrade.closeNet
        : closeData.limitPrice >= onCloseTrade.closeNet,
      Errors.SLIPPAGE_EXCEEDS_LIMIT
    );

    registry.closeMarketOrder(closeData.orderHash, closeData.closePercent);

    marginPool.transferBase(address(liquidityPool), closeMargin);

    uint256 fee = trade.leverage.mulDown(closeMargin).mulDown(registry.fee());
    fee = fee.min(onCloseTrade.grossPnL);
    onCloseTrade.grossPnL -= fee;

    liquidityPool.transferBase(owner(), fee.mulDown(registry.feeFactor()));

    if (isLiquidator) {
      if (onCloseTrade.isLiquidated) {
        uint256 penalty = onCloseTrade.grossPnL.mulDown(
          registry.liquidationPenalty()
        );
        liquidityPool.transferBase(msg.sender, penalty);
        settled = onCloseTrade.grossPnL.sub(penalty);
        liquidityPool.transferBase(trade.user, settled);
      } else if (onCloseTrade.isStop) {
        uint256 stopFee = onCloseTrade.grossPnL.mulDown(registry.stopFee());
        liquidityPool.transferBase(msg.sender, stopFee);
        settled = onCloseTrade.grossPnL.sub(stopFee);
        liquidityPool.transferBase(trade.user, settled);
      } else {
        _revert(Errors.CANNOT_LIQUIDATE);
      }
    } else {
      settled = onCloseTrade.grossPnL;
      liquidityPool.transferBase(msg.sender, settled);
    }

    emit CloseMarketOrderEvent(
      tx.origin,
      closeData.orderHash,
      closeData.closePercent,
      trade,
      onCloseTrade.closeNet,
      onCloseTrade.slippage,
      fee,
      onCloseTrade.accumulatedFee,
      settled
    );
  }

  function _createTrade(
    OpenTradeInput memory openData,
    uint256 openPrice,
    uint256 slippage
  ) internal view returns (IRegistry.Trade memory trade) {
    uint256 position = openData.leverage.mulDown(openData.margin);
    uint256 executionPrice = openData.isBuy
      ? openPrice.add(slippage)
      : openPrice.sub(slippage);
    uint256 liquidationPrice = openData.isBuy
      ? executionPrice.mulDown(
        openData
          .leverage
          .sub(registry.liquidationThresholdPerPriceId(openData.priceId))
          .divDown(openData.leverage)
      )
      : executionPrice.mulDown(
        openData
          .leverage
          .add(registry.liquidationThresholdPerPriceId(openData.priceId))
          .divDown(openData.leverage)
      );
    uint256 maxPercentagePnL = openData
      .leverage
      .divDown(registry.maxPercentagePnLFactor())
      .min(registry.maxPercentagePnLCap())
      .max(registry.maxPercentagePnLFloor());

    _require(openData.leverage > 0, Errors.NEGATIVE_LEVERAGE);
    _require(
      openData.leverage <= registry.maxLeveragePerPriceId(openData.priceId),
      Errors.LEVERAGE_TOO_HIGH
    );
    _require(
      registry.approvedPriceId(openData.priceId),
      Errors.APPROVED_PRICE_ID_ONLY
    );
    _require(
      registry.openTradesPerPriceIdCount(openData.user, openData.priceId) <
        registry.maxOpenTradesPerPriceId(),
      Errors.MAX_OPEN_TRADES_PER_PRICE_ID
    );
    _require(
      registry.openTradesPerUserCount(openData.user) <
        registry.maxOpenTradesPerUser(),
      Errors.MAX_OPEN_TRADES_PER_USER
    );
    _require(
      openData.margin.add(registry.totalMarginPerUser(openData.user)) <
        registry.maxMarginPerUser(),
      Errors.MAX_MARGIN_PER_USER
    );
    _require(
      registry.minCollateral().add(openData.margin.mulDown(maxPercentagePnL)) <=
        baseToken.balanceOfFixed(address(liquidityPool)),
      Errors.MAX_LIQUIDITY_POOL
    );
    _require(
      position >= registry.minPositionPerTrade(),
      Errors.POSITION_TOO_SMALL
    );
    _require(
      openData.isBuy
        ? liquidationPrice < openPrice
        : liquidationPrice > openPrice,
      Errors.SLIPPAGE_TOO_GREAT
    );
    _require(
      openData.stopLoss == 0 ||
        (
          openData.isBuy
            ? openData.stopLoss < executionPrice
            : openData.stopLoss > executionPrice
        ),
      Errors.INVALID_STOP_LOSS
    );
    _require(
      openData.profitTarget == 0 ||
        (
          openData.isBuy
            ? openData.profitTarget > executionPrice
            : openData.profitTarget < executionPrice
        ),
      Errors.INVALID_PROFIT_TARGET
    );
    _require(
      openData.isBuy
        ? openData.limitPrice >= executionPrice
        : openData.limitPrice <= executionPrice,
      Errors.SLIPPAGE_EXCEEDS_LIMIT
    );

    trade = IRegistry.Trade(
      openData.user, //whose trade
      openData.priceId,
      openData.margin,
      openData.leverage, //user input
      openData.isBuy, //user input
      openPrice,
      slippage, //execution price,
      liquidationPrice,
      openData.profitTarget,
      openData.stopLoss,
      maxPercentagePnL,
      block.number,
      block.timestamp,
      0 //unique number - set by Registry
    );
  }
}