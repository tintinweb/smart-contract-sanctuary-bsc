// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

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
abstract contract AccessControl is Context, IAccessControl, ERC165 {
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
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
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
                        Strings.toHexString(account),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
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
// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/Address.sol";

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
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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
interface IERC20Permit {
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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

// SPDX-License-Identifier: Apache-2.0
// Copyright 2023 Enjinstarter
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IAdminPrivileges.sol";

/**
 * @title AdminPrivileges
 * @author Tim Loh
 * @notice Provides role definitions that are inherited by other contracts and grants the owner all the defined roles
 */
contract AdminPrivileges is AccessControl, IAdminPrivileges {
    bytes32 public constant BACKOFFICE_ROLE_ADMIN_ROLE =
        keccak256("BACKOFFICE_ROLE_ADMIN_ROLE");
    bytes32 public constant BACKOFFICE_GOVERNANCE_ROLE =
        keccak256("BACKOFFICE_GOVERNANCE_ROLE");
    bytes32 public constant BACKOFFICE_CONTRACT_ADMIN_ROLE =
        keccak256("BACKOFFICE_CONTRACT_ADMIN_ROLE");

    bytes32 public constant TENANT_ROLE_ADMIN_ROLE =
        keccak256("TENANT_ROLE_ADMIN_ROLE");
    bytes32 public constant TENANT_GOVERNANCE_ROLE =
        keccak256("TENANT_GOVERNANCE_ROLE");
    bytes32 public constant TENANT_CONTRACT_ADMIN_ROLE =
        keccak256("TENANT_CONTRACT_ADMIN_ROLE");
}

// SPDX-License-Identifier: Apache-2.0
// Copyright 2023 Enjinstarter
pragma solidity 0.8.17;

import "./interfaces/IAdminWallet.sol";

/**
 * @title AdminWallet
 * @author Tim Loh
 * @notice Provides an implementation of the admin wallet interface that is inherited by other contracts
 */
contract AdminWallet is IAdminWallet {
    address private _adminWallet;

    /**
     * @inheritdoc IAdminWallet
     */
    function adminWallet() public view virtual override returns (address) {
        return _adminWallet;
    }

    /**
     * @dev Change admin wallet to a new wallet address
     * @param newWallet The new admin wallet address
     */
    function _setAdminWallet(address newWallet) internal virtual {
        require(newWallet != address(0), "AdminWallet: new wallet");

        address oldWallet = _adminWallet;
        _adminWallet = newWallet;

        emit AdminWalletChanged(oldWallet, newWallet, msg.sender);
    }
}

// SPDX-License-Identifier: Apache-2.0
// Copyright 2023 Enjinstarter
pragma solidity 0.8.17;

/**
 * @title AdminPrivileges Interface
 * @author Tim Loh
 * @notice Interface for AdminPrivileges which provides role definitions
 */
interface IAdminPrivileges {
    // solhint-disable func-name-mixedcase

    // https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
    // slither-disable-next-line naming-convention
    function BACKOFFICE_ROLE_ADMIN_ROLE() external view returns (bytes32);

    // https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
    // slither-disable-next-line naming-convention
    function BACKOFFICE_GOVERNANCE_ROLE() external view returns (bytes32);

    // https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
    // slither-disable-next-line naming-convention
    function BACKOFFICE_CONTRACT_ADMIN_ROLE() external view returns (bytes32);

    // https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
    // slither-disable-next-line naming-convention
    function TENANT_ROLE_ADMIN_ROLE() external view returns (bytes32);

    // https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
    // slither-disable-next-line naming-convention
    function TENANT_GOVERNANCE_ROLE() external view returns (bytes32);

    // https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
    // slither-disable-next-line naming-convention
    function TENANT_CONTRACT_ADMIN_ROLE() external view returns (bytes32);

    // solhint-enable func-name-mixedcase
}

// SPDX-License-Identifier: Apache-2.0
// Copyright 2023 Enjinstarter
pragma solidity 0.8.17;

/**
 * @title AdminWallet Interface
 * @author Tim Loh
 * @notice Interface for AdminWallet where funds will be withdrawn to
 */
interface IAdminWallet {
    /**
     * @notice Emitted when admin wallet has been changed from `oldWallet` to `newWallet`
     * @param oldWallet The wallet before the wallet was changed
     * @param newWallet The wallet after the wallet was changed
     * @param sender The address that changes the admin wallet
     */
    event AdminWalletChanged(
        address indexed oldWallet,
        address indexed newWallet,
        address indexed sender
    );

    /**
     * @notice Returns the admin wallet address where funds will be withdrawn to
     * @return Admin wallet address
     */
    function adminWallet() external view returns (address);
}

// SPDX-License-Identifier: Apache-2.0
// Copyright 2023 Enjinstarter
pragma solidity 0.8.17;

/**
 * @title IFactoryImplementation
 * @author Tim Loh
 */
interface IFactoryImplementation {
    // https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
    // slither-disable-next-line naming-convention
    function FACTORY_IMPLEMENTATION_TYPE() external view returns (uint256);
    // solhint-disable-previous-line func-name-mixedcase
}

// SPDX-License-Identifier: Apache-2.0
// Copyright 2023 Enjinstarter
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/IAccessControl.sol";
import "./IAdminPrivileges.sol";
import "./IAdminWallet.sol";
import "./IFactoryImplementation.sol";

/**
 * @title IVestingCustomImplementation
 * @author Tim Loh
 */
interface IVestingCustomImplementation is
    IAccessControl,
    IAdminPrivileges,
    IAdminWallet,
    IFactoryImplementation
{
    event OptedForNonTgeRefund(
        address indexed account,
        uint256 refundAmount,
        uint256 refundStartTimestamp
    );

    event OptedForTgeRefund(
        address indexed account,
        bool indexed isTgeOnly,
        uint256 refundAmount,
        uint256 refundStartTimestamp
    );

    event NonTgeRefundCancelled(
        address indexed account,
        uint256 refundStartTimestamp,
        uint256 refundEndTimestamp
    );

    event NonTgeRefundIndicationPeriodExtended(
        address indexed sender,
        uint256 durationSeconds,
        uint256 oldEndTimestamp,
        uint256 newEndTimestamp
    );

    event NonTgeRefundTriggered(
        address indexed sender,
        uint256 startTimestamp,
        uint256 durationSeconds,
        uint256 endTimestamp
    );

    event ScheduleSet(
        address indexed account,
        uint256[] startTimestamps,
        uint256[] percentReleases,
        uint256[] durationsDays
    );

    event TgeRefundCancelled(
        address indexed account,
        bool isTgeOnly,
        uint256 refundStartTimestamp,
        uint256 refundEndTimestamp
    );

    event TgeRefundIndicationPeriodExtended(
        address indexed sender,
        uint256 durationSeconds,
        uint256 oldEndTimestamp,
        uint256 newEndTimestamp
    );

    event TgeRefundTriggered(
        address indexed sender,
        bool indexed isTgeOnly,
        uint256 startTimestamp,
        uint256 durationSeconds,
        uint256 endTimestamp
    );

    event TokensReleased(address indexed account, uint256 amount);

    event UnusedTokensTransferred(
        address indexed sender,
        uint256 unusedAmount,
        uint256 balanceInWei,
        uint256 totalReleasedAmount,
        uint256 totalRevokedAmount,
        uint256 totalRefundAmount,
        uint256 totalGrantAmount
    );

    event VestingGrantAdded(
        address indexed account,
        uint256 grantAmount,
        bool isRevocable
    );

    event VestingGrantRevoked(
        address indexed account,
        uint256 remainderAmount,
        uint256 grantAmount,
        uint256 refundedAmount,
        uint256 releasedAmount
    );

    function addVestingGrant(
        address account,
        uint256 grantAmount,
        bool isRevocable
    ) external;

    function addVestingGrantsBatch(
        address[] memory accounts,
        uint256[] memory grantAmounts,
        bool[] memory isRevocables
    ) external;

    function cancelNonTgeRefund() external;

    function cancelTgeRefund() external;

    function extendNonTgeRefundIndicationPeriod(
        uint256 newDurationSeconds
    ) external;

    function extendTgeRefundIndicationPeriod(
        uint256 newDurationSeconds
    ) external;

    function optForNonTgeRefund() external;

    function optForTgeRefund(bool isTgeOnly) external;

    function pauseContract() external;

    function release() external;

    function revokeVestingGrant(address account) external;

    function revokeVestingGrantsBatch(address[] memory accounts) external;

    function setAdminWallet(address newWallet) external;

    function setVestingSchedule(
        uint256[] calldata startTimestamps,
        uint256[] calldata percentReleases,
        uint256[] calldata durationsDays
    ) external;

    function transferUnusedTokens() external;

    function triggerNonTgeRefund(
        uint256 startTimestamp,
        uint256 durationSeconds
    ) external;

    function triggerTgeRefund(
        bool isTgeOnly,
        uint256 startTimestamp,
        uint256 durationSeconds
    ) external;

    function unpauseContract() external;

    function allowAccumulate() external view returns (bool);

    // https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
    // slither-disable-next-line naming-convention
    function BATCH_MAX_NUM() external view returns (uint256); // solhint-disable-line func-name-mixedcase

    // https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
    // slither-disable-next-line naming-convention
    function SCHEDULE_MAX_ENTRIES() external view returns (uint256); // solhint-disable-line func-name-mixedcase

    function getNonTgeRefundInfo()
        external
        view
        returns (uint256 startTimestamp, uint256 endTimestamp);

    function getTgeRefundInfo()
        external
        view
        returns (bool isTgeOnly, uint256 startTimestamp, uint256 endTimestamp);

    function getVestingSchedule()
        external
        view
        returns (
            uint256[] memory startTimestamps,
            uint256[] memory percentReleases,
            uint256[] memory durationsDays,
            uint256[] memory endTimestamps
        );

    function hasOptedForNonTgeRefund(
        address account
    ) external view returns (bool hasOpted);

    function hasOptedForTgeEntireRefund(
        address account
    ) external view returns (bool hasOpted);

    function hasOptedForTgeOnlyRefund(
        address account
    ) external view returns (bool hasOpted);

    function hasOptedForTgeRefund(
        address account
    ) external view returns (bool hasOpted);

    function isNonTgeRefundIndicationPeriodOpen()
        external
        view
        returns (bool isOpen);

    function isTgeRefundIndicationPeriodOpen()
        external
        view
        returns (bool isOpen);

    function numVestingScheduleEntries() external view returns (uint256);

    function refundedAmountFor(
        address account
    ) external view returns (uint256 refundedAmount);

    function releasableAmountFor(
        address account
    ) external view returns (uint256 unreleasedAmount);

    function releasedAmountFor(
        address account
    ) external view returns (uint256 releasedAmount);

    function revoked(address account) external view returns (bool isRevoked);

    function tokenAddress() external view returns (address);

    function tokenDecimals() external view returns (uint256);

    function totalGrantAmount() external view returns (uint256);

    function totalRefundAmount() external view returns (uint256);

    function totalReleasedAmount() external view returns (uint256);

    function totalRevokedAmount() external view returns (uint256);

    function unvestedAmountFor(
        address account
    ) external view returns (uint256 unvestedAmount);

    function vestedAmountFor(
        address account
    ) external view returns (uint256 vestedAmount);

    function vestingGrantFor(
        address account
    )
        external
        view
        returns (
            uint256 grantAmount,
            bool isRevocable,
            bool isRevoked,
            bool isActive
        );
}

// SPDX-License-Identifier: Apache-2.0
// Copyright 2023 Enjinstarter
pragma solidity 0.8.17;

/**
 * @title UnitConverter
 * @author Tim Loh
 * @notice Converts given amount between Wei and number of decimal places
 */
library UnitConverter {
    uint256 public constant TOKEN_MAX_DECIMALS = 18;

    /**
     * @notice Scale down given amount in Wei to given number of decimal places
     * @param weiAmount Amount in Wei
     * @param decimals Number of decimal places
     * @return decimalsAmount Amount in Wei scaled down to given number of decimal places
     */
    // https://github.com/crytic/slither/wiki/Detector-Documentation#dead-code
    // slither-disable-next-line dead-code
    function scaleWeiToDecimals(
        uint256 weiAmount,
        uint256 decimals
    ) internal pure returns (uint256 decimalsAmount) {
        require(decimals <= TOKEN_MAX_DECIMALS, "UnitConverter: decimals");

        if (decimals < TOKEN_MAX_DECIMALS && weiAmount > 0) {
            uint256 decimalsDiff = TOKEN_MAX_DECIMALS - decimals;
            decimalsAmount = weiAmount / 10 ** decimalsDiff;
        } else {
            decimalsAmount = weiAmount;
        }
    }

    /**
     * @notice Scale up given amount in given number of decimal places to Wei
     * @param decimalsAmount Amount in number of decimal places
     * @param decimals Number of decimal places
     * @return weiAmount Amount in given number of decimal places scaled up to Wei
     */
    // https://github.com/crytic/slither/wiki/Detector-Documentation#dead-code
    // slither-disable-next-line dead-code
    function scaleDecimalsToWei(
        uint256 decimalsAmount,
        uint256 decimals
    ) internal pure returns (uint256 weiAmount) {
        require(decimals <= TOKEN_MAX_DECIMALS, "UnitConverter: decimals");

        if (decimals < TOKEN_MAX_DECIMALS && decimalsAmount > 0) {
            uint256 decimalsDiff = TOKEN_MAX_DECIMALS - decimals;
            weiAmount = decimalsAmount * 10 ** decimalsDiff;
        } else {
            weiAmount = decimalsAmount;
        }
    }
}

// SPDX-License-Identifier: Apache-2.0
// Copyright 2023 Enjinstarter
pragma solidity 0.8.17;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./libraries/UnitConverter.sol";
import "./AdminPrivileges.sol";
import "./AdminWallet.sol";
import "./interfaces/IVestingCustomImplementation.sol";

/**
 * @title VestingCustomImplementation
 * @author Tim Loh
 */
contract VestingCustomImplementation is
    Initializable,
    Pausable,
    AdminPrivileges,
    AdminWallet,
    IVestingCustomImplementation
{
    using SafeERC20 for IERC20;
    using UnitConverter for uint256;

    struct CustomVestingScheduleEntry {
        uint256 percentRelease; // Percentage of grant amount to be released
        uint256 startTimestamp; // Start timestamp
        uint256 durationDays; // Duration in days
        uint256 endTimestamp; // End timestamp
    }

    struct NonTgeRefundInfo {
        uint256 startTimestamp;
        uint256 endTimestamp;
    }

    struct RefundOptIn {
        uint256 optForNonTgeRefundTimestamp; // Timestamp opted for non-TGE refund
        uint256 optForTgeRefundTimestamp; // Timestamp opted for TGE refund
        bool tgeRefundIsTgeOnly; // true if refund TGE trench only for TGE refund, false if refund entire vesting schedule for TGE refund
    }

    struct TgeRefundInfo {
        bool isTgeOnly;
        uint256 startTimestamp;
        uint256 endTimestamp;
    }

    struct VestingGrant {
        uint256 grantAmount; // Total number of tokens granted
        bool isRevocable; // true if vesting grant is revocable (a gift), false if irrevocable (purchased)
        bool isRevoked; // true if vesting grant has been revoked
        bool isActive; // true if vesting grant is active
    }

    uint256 public constant override FACTORY_IMPLEMENTATION_TYPE =
        0x616b2eb572eef33549870a0b95b358b8dbf353bf9649ebe3b797f228a633b563;

    uint256 public constant BATCH_MAX_NUM = 100;
    uint256 public constant SCHEDULE_MAX_ENTRIES = 100;

    uint256 public constant PERCENT_100_WEI = 100 ether;
    uint256 public constant SECONDS_IN_DAY = 86400;
    uint256 public constant TOKEN_MAX_DECIMALS = 18;

    bool public allowAccumulate;
    uint256 public numVestingScheduleEntries;
    address public tokenAddress;
    uint256 public tokenDecimals;
    uint256 public totalGrantAmount;
    uint256 public totalRefundAmount;
    uint256 public totalReleasedAmount;
    uint256 public totalRevokedAmount;

    mapping(address => uint256) private _refunded;
    mapping(address => RefundOptIn) private _refundOptIns;
    mapping(address => uint256) private _released;
    mapping(address => VestingGrant) private _vestingGrants;
    mapping(uint256 => CustomVestingScheduleEntry) private _vestingSchedule;

    NonTgeRefundInfo private _nonTgeRefundInfo;
    TgeRefundInfo private _tgeRefundInfo;

    function initialize(
        address tokenAddress_,
        uint256 tokenDecimals_,
        bool allowAccumulate_,
        address backofficeAdminAddress,
        address tenantAdminAddress
    ) public initializer {
        __VestingCustomImplementation_init(
            tokenAddress_,
            tokenDecimals_,
            allowAccumulate_,
            backofficeAdminAddress,
            tenantAdminAddress
        );
    }

    // https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
    // slither-disable-next-line naming-convention
    function __VestingCustomImplementation_init(
        // solhint-disable-previous-line func-name-mixedcase
        address tokenAddress_,
        uint256 tokenDecimals_,
        bool allowAccumulate_,
        address backofficeAdminAddress,
        address tenantAdminAddress
    ) internal onlyInitializing {
        __VestingCustomImplementation_init_unchained(
            tokenAddress_,
            tokenDecimals_,
            allowAccumulate_,
            backofficeAdminAddress,
            tenantAdminAddress
        );
    }

    // https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
    // slither-disable-next-line naming-convention
    function __VestingCustomImplementation_init_unchained(
        // solhint-disable-previous-line func-name-mixedcase
        address tokenAddress_,
        uint256 tokenDecimals_,
        bool allowAccumulate_,
        address backofficeAdminAddress,
        address tenantAdminAddress
    ) internal onlyInitializing {
        require(tokenAddress_ != address(0), "VCI: token address");
        require(tokenDecimals_ <= TOKEN_MAX_DECIMALS, "VCI: token decimals");
        require(backofficeAdminAddress != address(0), "VCI: backoffice admin");
        require(tenantAdminAddress != address(0), "VCI: tenant admin");

        _setRoleAdmin(BACKOFFICE_ROLE_ADMIN_ROLE, BACKOFFICE_ROLE_ADMIN_ROLE);
        _setRoleAdmin(
            BACKOFFICE_CONTRACT_ADMIN_ROLE,
            BACKOFFICE_ROLE_ADMIN_ROLE
        );
        _setRoleAdmin(TENANT_ROLE_ADMIN_ROLE, TENANT_ROLE_ADMIN_ROLE);
        _setRoleAdmin(TENANT_GOVERNANCE_ROLE, TENANT_ROLE_ADMIN_ROLE);
        _setRoleAdmin(TENANT_CONTRACT_ADMIN_ROLE, TENANT_ROLE_ADMIN_ROLE);

        _grantRole(BACKOFFICE_ROLE_ADMIN_ROLE, backofficeAdminAddress);
        _grantRole(BACKOFFICE_CONTRACT_ADMIN_ROLE, backofficeAdminAddress);

        _grantRole(TENANT_ROLE_ADMIN_ROLE, tenantAdminAddress);
        _grantRole(TENANT_GOVERNANCE_ROLE, tenantAdminAddress);
        _grantRole(TENANT_CONTRACT_ADMIN_ROLE, tenantAdminAddress);

        _setAdminWallet(tenantAdminAddress);

        tokenAddress = tokenAddress_;
        tokenDecimals = tokenDecimals_;

        allowAccumulate = allowAccumulate_;
    }

    /**
     * @dev isRevocable will be ignored if grant already added but amount allowed to accumulate.
     */
    function addVestingGrant(
        address account,
        uint256 grantAmount,
        bool isRevocable
    ) external virtual override onlyRole(TENANT_CONTRACT_ADMIN_ROLE) {
        _addVestingGrant(account, grantAmount, isRevocable);
    }

    function addVestingGrantsBatch(
        address[] memory accounts,
        uint256[] memory grantAmounts,
        bool[] memory isRevocables
    ) external virtual override onlyRole(TENANT_CONTRACT_ADMIN_ROLE) {
        require(accounts.length > 0, "VCI: empty");
        require(accounts.length <= BATCH_MAX_NUM, "VCI: exceed max");
        require(
            grantAmounts.length == accounts.length,
            "VCI: grant amounts length"
        );
        require(
            isRevocables.length == accounts.length,
            "VCI: is revocables length"
        );

        for (uint256 i = 0; i < accounts.length; i++) {
            _addVestingGrant(accounts[i], grantAmounts[i], isRevocables[i]);
        }
    }

    function cancelNonTgeRefund()
        external
        virtual
        override
        onlyRole(BACKOFFICE_CONTRACT_ADMIN_ROLE)
    {
        require(_nonTgeRefundInfo.startTimestamp > 0, "VCI: no refund");
        require(
            block.timestamp < _nonTgeRefundInfo.startTimestamp,
            "VCI: started"
        );

        uint256 oldStartTimestamp = _nonTgeRefundInfo.startTimestamp;
        uint256 oldEndTimestamp = _nonTgeRefundInfo.endTimestamp;

        _nonTgeRefundInfo.startTimestamp = 0;
        _nonTgeRefundInfo.endTimestamp = 0;

        emit NonTgeRefundCancelled(
            msg.sender,
            oldStartTimestamp,
            oldEndTimestamp
        );
    }

    function cancelTgeRefund()
        external
        virtual
        override
        onlyRole(BACKOFFICE_CONTRACT_ADMIN_ROLE)
    {
        require(_tgeRefundInfo.startTimestamp > 0, "VCI: no refund");
        require(
            block.timestamp < _tgeRefundInfo.startTimestamp,
            "VCI: started"
        );

        bool oldIsTgeOnly = _tgeRefundInfo.isTgeOnly;
        uint256 oldStartTimestamp = _tgeRefundInfo.startTimestamp;
        uint256 oldEndTimestamp = _tgeRefundInfo.endTimestamp;

        _tgeRefundInfo.isTgeOnly = false;
        _tgeRefundInfo.startTimestamp = 0;
        _tgeRefundInfo.endTimestamp = 0;

        emit TgeRefundCancelled(
            msg.sender,
            oldIsTgeOnly,
            oldStartTimestamp,
            oldEndTimestamp
        );
    }

    function extendNonTgeRefundIndicationPeriod(
        uint256 newDurationSeconds
    ) external virtual override onlyRole(BACKOFFICE_CONTRACT_ADMIN_ROLE) {
        require(newDurationSeconds > 0, "VCI: new duration");
        require(isNonTgeRefundIndicationPeriodOpen(), "VCI: not open");

        uint256 oldEndTimestamp = _nonTgeRefundInfo.endTimestamp;
        uint256 newEndTimestamp = _nonTgeRefundInfo.startTimestamp +
            newDurationSeconds;
        require(newEndTimestamp > oldEndTimestamp, "VCI: too short");

        _nonTgeRefundInfo.endTimestamp = newEndTimestamp;

        emit NonTgeRefundIndicationPeriodExtended(
            msg.sender,
            newDurationSeconds,
            oldEndTimestamp,
            newEndTimestamp
        );
    }

    function extendTgeRefundIndicationPeriod(
        uint256 newDurationSeconds
    ) external virtual override onlyRole(BACKOFFICE_CONTRACT_ADMIN_ROLE) {
        require(newDurationSeconds > 0, "VCI: new duration");
        require(isTgeRefundIndicationPeriodOpen(), "VCI: not open");

        uint256 oldEndTimestamp = _tgeRefundInfo.endTimestamp;
        uint256 newEndTimestamp = _tgeRefundInfo.startTimestamp +
            newDurationSeconds;
        require(newEndTimestamp > oldEndTimestamp, "VCI: too short");

        _tgeRefundInfo.endTimestamp = newEndTimestamp;

        emit TgeRefundIndicationPeriodExtended(
            msg.sender,
            newDurationSeconds,
            oldEndTimestamp,
            newEndTimestamp
        );
    }

    function optForNonTgeRefund() external virtual override whenNotPaused {
        require(isNonTgeRefundIndicationPeriodOpen(), "VCI: not open");
        require(!hasOptedForTgeEntireRefund(msg.sender), "VCI: refunded");
        require(!hasOptedForNonTgeRefund(msg.sender), "VCI: opted");

        VestingGrant memory vestingGrant = _vestingGrants[msg.sender];
        require(vestingGrant.isActive, "VCI: inactive");
        require(!revoked(msg.sender), "VCI: revoked");

        _refundOptIns[msg.sender].optForNonTgeRefundTimestamp = block.timestamp;

        uint256 refundAmount = _getNonTgeRefundAmount(
            msg.sender,
            vestingGrant.grantAmount
        );
        _refunded[msg.sender] += refundAmount;
        totalRefundAmount += refundAmount;

        emit OptedForNonTgeRefund(
            msg.sender,
            refundAmount,
            _nonTgeRefundInfo.startTimestamp
        );
    }

    function optForTgeRefund(
        bool isTgeOnly
    ) external virtual override whenNotPaused {
        require(isTgeRefundIndicationPeriodOpen(), "VCI: not open");
        require(!_tgeRefundInfo.isTgeOnly || isTgeOnly, "VCI: TGE only");
        require(
            !isTgeOnly || _vestingSchedule[0].durationDays == 0,
            "VCI: schedule"
        );
        require(!hasOptedForTgeRefund(msg.sender), "VCI: opted");

        VestingGrant memory vestingGrant = _vestingGrants[msg.sender];
        require(vestingGrant.isActive, "VCI: inactive");
        require(!revoked(msg.sender), "VCI: revoked");

        _refundOptIns[msg.sender].optForTgeRefundTimestamp = block.timestamp;
        _refundOptIns[msg.sender].tgeRefundIsTgeOnly = isTgeOnly;

        uint256 refundAmount = _getTgeRefundAmount(
            msg.sender,
            vestingGrant.grantAmount,
            isTgeOnly
        );
        _refunded[msg.sender] += refundAmount;
        totalRefundAmount += refundAmount;

        emit OptedForTgeRefund(
            msg.sender,
            isTgeOnly,
            refundAmount,
            _tgeRefundInfo.startTimestamp
        );
    }

    function pauseContract()
        external
        virtual
        override
        onlyRole(TENANT_CONTRACT_ADMIN_ROLE)
    {
        _pause();
    }

    function release() external virtual override whenNotPaused {
        uint256 releasableAmount = releasableAmountFor(msg.sender);

        _release(msg.sender, releasableAmount);
    }

    function revokeVestingGrant(
        address account
    ) external virtual override onlyRole(TENANT_CONTRACT_ADMIN_ROLE) {
        _revokeVestingGrant(account);
    }

    function revokeVestingGrantsBatch(
        address[] memory accounts
    ) external virtual override onlyRole(TENANT_CONTRACT_ADMIN_ROLE) {
        require(accounts.length > 0, "VCI: empty");
        require(accounts.length <= BATCH_MAX_NUM, "VCI: exceed max");

        for (uint256 i = 0; i < accounts.length; i++) {
            _revokeVestingGrant(accounts[i]);
        }
    }

    /**
     * @inheritdoc IVestingCustomImplementation
     */
    function setAdminWallet(
        address newWallet
    ) external virtual override onlyRole(TENANT_GOVERNANCE_ROLE) {
        _setAdminWallet(newWallet);
    }

    function setVestingSchedule(
        uint256[] calldata startTimestamps,
        uint256[] calldata percentReleases,
        uint256[] calldata durationsDays
    ) external virtual override onlyRole(TENANT_CONTRACT_ADMIN_ROLE) {
        require(startTimestamps.length > 0, "VCI: empty");
        require(
            startTimestamps.length <= SCHEDULE_MAX_ENTRIES,
            "VCI: exceed max"
        );
        require(
            percentReleases.length == startTimestamps.length,
            "VCI: percent length different"
        );
        require(
            durationsDays.length == startTimestamps.length,
            "VCI: duration length different"
        );
        require(
            numVestingScheduleEntries == 0 ||
                block.timestamp < _vestingSchedule[0].startTimestamp,
            "VCI: already started"
        );

        uint256 minTimestamp = block.timestamp;
        uint256 totalPercentRelease = 0;

        for (uint256 i = 0; i < startTimestamps.length; i++) {
            require(percentReleases[i] > 0, "VCI: zero percent");
            require(
                startTimestamps[i] >= minTimestamp,
                "VCI: invalid start timestamp"
            );

            totalPercentRelease = totalPercentRelease + percentReleases[i];
            require(totalPercentRelease <= PERCENT_100_WEI, "VCI: exceed 100%");

            if (durationsDays[i] > 0) {
                minTimestamp =
                    startTimestamps[i] +
                    durationsDays[i] *
                    SECONDS_IN_DAY;
            } else {
                minTimestamp = startTimestamps[i];
            }

            _vestingSchedule[i] = CustomVestingScheduleEntry({
                percentRelease: percentReleases[i],
                startTimestamp: startTimestamps[i],
                durationDays: durationsDays[i],
                endTimestamp: minTimestamp
            });
        }

        require(totalPercentRelease == PERCENT_100_WEI, "VCI: not 100%");

        numVestingScheduleEntries = startTimestamps.length;

        emit ScheduleSet(
            msg.sender,
            startTimestamps,
            percentReleases,
            durationsDays
        );
    }

    function transferUnusedTokens()
        external
        virtual
        override
        onlyRole(TENANT_CONTRACT_ADMIN_ROLE)
    {
        uint256 balanceInDecimals = IERC20(tokenAddress).balanceOf(
            address(this)
        );
        uint256 balanceInWei = balanceInDecimals.scaleDecimalsToWei(
            tokenDecimals
        );

        uint256 unusedAmount = balanceInWei +
            totalReleasedAmount +
            totalRevokedAmount +
            totalRefundAmount -
            totalGrantAmount;
        require(unusedAmount > 0, "VCI: nothing to transfer");

        uint256 transferAmount = unusedAmount.scaleWeiToDecimals(tokenDecimals);

        emit UnusedTokensTransferred(
            msg.sender,
            unusedAmount,
            balanceInWei,
            totalReleasedAmount,
            totalRevokedAmount,
            totalRefundAmount,
            totalGrantAmount
        );

        IERC20(tokenAddress).safeTransfer(adminWallet(), transferAmount);
    }

    function triggerNonTgeRefund(
        uint256 startTimestamp,
        uint256 durationSeconds
    ) external virtual override onlyRole(BACKOFFICE_CONTRACT_ADMIN_ROLE) {
        require(startTimestamp > block.timestamp, "VCI: start timestamp");
        require(durationSeconds > 0, "VCI: duration");
        require(
            numVestingScheduleEntries > 0 &&
                _vestingSchedule[0].startTimestamp > 0,
            "VCI: undefined schedule"
        );
        require(_tgeRefundInfo.startTimestamp > 0, "VCI: no TGE refund");
        require(
            startTimestamp >= _tgeRefundInfo.endTimestamp,
            "VCE: before TGE refund end"
        );
        require(
            _nonTgeRefundInfo.startTimestamp == 0 ||
                block.timestamp < _nonTgeRefundInfo.startTimestamp ||
                block.timestamp >= _nonTgeRefundInfo.endTimestamp,
            "VCI: triggered"
        );

        uint256 endTimestamp = startTimestamp + durationSeconds;

        _nonTgeRefundInfo.startTimestamp = startTimestamp;
        _nonTgeRefundInfo.endTimestamp = endTimestamp;

        emit NonTgeRefundTriggered(
            msg.sender,
            startTimestamp,
            durationSeconds,
            endTimestamp
        );
    }

    function triggerTgeRefund(
        bool isTgeOnly,
        uint256 startTimestamp,
        uint256 durationSeconds
    ) external virtual override onlyRole(BACKOFFICE_CONTRACT_ADMIN_ROLE) {
        require(startTimestamp > block.timestamp, "VCI: start timestamp");
        require(durationSeconds > 0, "VCI: duration");
        require(
            numVestingScheduleEntries > 0 &&
                _vestingSchedule[0].startTimestamp > 0,
            "VCI: undefined schedule"
        );
        require(
            !isTgeOnly || _vestingSchedule[0].durationDays == 0,
            "VCI: TGE only"
        );
        require(
            _tgeRefundInfo.startTimestamp == 0 ||
                block.timestamp < _tgeRefundInfo.startTimestamp,
            "VCI: triggered"
        );

        uint256 endTimestamp = startTimestamp + durationSeconds;

        _tgeRefundInfo.isTgeOnly = isTgeOnly;
        _tgeRefundInfo.startTimestamp = startTimestamp;
        _tgeRefundInfo.endTimestamp = endTimestamp;

        emit TgeRefundTriggered(
            msg.sender,
            isTgeOnly,
            startTimestamp,
            durationSeconds,
            endTimestamp
        );
    }

    function unpauseContract()
        external
        virtual
        override
        onlyRole(TENANT_CONTRACT_ADMIN_ROLE)
    {
        _unpause();
    }

    function getNonTgeRefundInfo()
        external
        view
        virtual
        override
        returns (uint256 startTimestamp, uint256 endTimestamp)
    {
        startTimestamp = _nonTgeRefundInfo.startTimestamp;
        endTimestamp = _nonTgeRefundInfo.endTimestamp;
    }

    function getTgeRefundInfo()
        external
        view
        virtual
        override
        returns (bool isTgeOnly, uint256 startTimestamp, uint256 endTimestamp)
    {
        isTgeOnly = _tgeRefundInfo.isTgeOnly;
        startTimestamp = _tgeRefundInfo.startTimestamp;
        endTimestamp = _tgeRefundInfo.endTimestamp;
    }

    function getVestingSchedule()
        external
        view
        virtual
        override
        returns (
            uint256[] memory startTimestamps,
            uint256[] memory percentReleases,
            uint256[] memory durationsDays,
            uint256[] memory endTimestamps
        )
    {
        startTimestamps = new uint256[](numVestingScheduleEntries);
        percentReleases = new uint256[](numVestingScheduleEntries);
        durationsDays = new uint256[](numVestingScheduleEntries);
        endTimestamps = new uint256[](numVestingScheduleEntries);

        if (numVestingScheduleEntries > 0) {
            for (uint256 i = 0; i < numVestingScheduleEntries; i++) {
                startTimestamps[i] = _vestingSchedule[i].startTimestamp;
                percentReleases[i] = _vestingSchedule[i].percentRelease;
                durationsDays[i] = _vestingSchedule[i].durationDays;
                endTimestamps[i] = _vestingSchedule[i].endTimestamp;
            }
        }
    }

    function unvestedAmountFor(
        address account
    ) external view virtual override returns (uint256 unvestedAmount) {
        require(account != address(0), "VCI: zero account");

        VestingGrant memory vestingGrant = _vestingGrants[account];
        require(vestingGrant.isActive, "VCI: inactive");

        if (revoked(account)) {
            unvestedAmount = 0;
            return unvestedAmount;
        }

        unvestedAmount = vestingGrant.grantAmount - vestedAmountFor(account);
    }

    function vestingGrantFor(
        address account
    )
        external
        view
        virtual
        override
        returns (
            uint256 grantAmount,
            bool isRevocable,
            bool isRevoked,
            bool isActive
        )
    {
        require(account != address(0), "VCI: zero account");

        VestingGrant memory vestingGrant = _vestingGrants[account];
        grantAmount = vestingGrant.grantAmount;
        isRevocable = vestingGrant.isRevocable;
        isRevoked = vestingGrant.isRevoked;
        isActive = vestingGrant.isActive;
    }

    function hasOptedForNonTgeRefund(
        address account
    ) public view virtual override returns (bool hasOpted) {
        require(account != address(0), "VCI: zero account");
        require(_vestingGrants[account].isActive, "VCI: inactive");

        hasOpted = _refundOptIns[account].optForNonTgeRefundTimestamp > 0;
    }

    function hasOptedForTgeEntireRefund(
        address account
    ) public view virtual override returns (bool hasOpted) {
        require(account != address(0), "VCI: zero account");
        require(_vestingGrants[account].isActive, "VCI: inactive");

        RefundOptIn memory refundOptIn = _refundOptIns[account];
        hasOpted =
            refundOptIn.optForTgeRefundTimestamp > 0 &&
            !refundOptIn.tgeRefundIsTgeOnly;
    }

    function hasOptedForTgeOnlyRefund(
        address account
    ) public view virtual override returns (bool hasOpted) {
        require(account != address(0), "VCI: zero account");
        require(_vestingGrants[account].isActive, "VCI: inactive");

        RefundOptIn memory refundOptIn = _refundOptIns[account];
        hasOpted =
            refundOptIn.optForTgeRefundTimestamp > 0 &&
            refundOptIn.tgeRefundIsTgeOnly;
    }

    function hasOptedForTgeRefund(
        address account
    ) public view virtual override returns (bool hasOpted) {
        require(account != address(0), "VCI: zero account");
        require(_vestingGrants[account].isActive, "VCI: inactive");

        hasOpted = _refundOptIns[account].optForTgeRefundTimestamp > 0;
    }

    function isNonTgeRefundIndicationPeriodOpen()
        public
        view
        virtual
        override
        returns (bool isOpen)
    {
        isOpen =
            _nonTgeRefundInfo.startTimestamp > 0 &&
            block.timestamp >= _nonTgeRefundInfo.startTimestamp &&
            block.timestamp < _nonTgeRefundInfo.endTimestamp;
    }

    function isTgeRefundIndicationPeriodOpen()
        public
        view
        virtual
        override
        returns (bool isOpen)
    {
        isOpen =
            _tgeRefundInfo.startTimestamp > 0 &&
            block.timestamp >= _tgeRefundInfo.startTimestamp &&
            block.timestamp < _tgeRefundInfo.endTimestamp;
    }

    function refundedAmountFor(
        address account
    ) public view virtual override returns (uint256 refundedAmount) {
        require(account != address(0), "VCI: zero account");

        refundedAmount = _refunded[account];
    }

    function releasableAmountFor(
        address account
    ) public view virtual override returns (uint256 releasableAmount) {
        require(account != address(0), "VCI: zero account");
        require(
            numVestingScheduleEntries > 0 &&
                _vestingSchedule[0].startTimestamp > 0,
            "VCI: undefined schedule"
        );
        require(
            block.timestamp >= _vestingSchedule[0].startTimestamp,
            "VCI: not started"
        );
        require(!revoked(account), "VCI: revoked");

        releasableAmount =
            vestedAmountFor(account) -
            refundedAmountFor(account) -
            releasedAmountFor(account);
    }

    function releasedAmountFor(
        address account
    ) public view virtual override returns (uint256 releasedAmount) {
        require(account != address(0), "VCI: zero account");

        releasedAmount = _released[account];
    }

    function revoked(
        address account
    ) public view virtual override returns (bool isRevoked) {
        require(account != address(0), "VCI: zero account");

        VestingGrant memory vestingGrant = _vestingGrants[account];
        require(vestingGrant.isActive, "VCI: inactive");

        isRevoked = vestingGrant.isRevoked;
    }

    function vestedAmountFor(
        address account
    ) public view virtual override returns (uint256 vestedAmount) {
        require(account != address(0), "VCI: zero account");

        VestingGrant memory vestingGrant = _vestingGrants[account];
        require(vestingGrant.isActive, "VCI: inactive");

        if (
            numVestingScheduleEntries == 0 ||
            _vestingSchedule[0].startTimestamp == 0
        ) {
            return 0;
        }

        if (block.timestamp < _vestingSchedule[0].startTimestamp) {
            return 0;
        }

        if (revoked(account)) {
            return releasedAmountFor(account);
        }

        if (
            hasOptedForTgeEntireRefund(account) ||
            hasOptedForNonTgeRefund(account)
        ) {
            vestedAmount = vestingGrant.grantAmount;
            return vestedAmount;
        }

        if (
            block.timestamp >=
            _vestingSchedule[numVestingScheduleEntries - 1].endTimestamp
        ) {
            return vestingGrant.grantAmount;
        }

        uint256 totalPercentRelease = _getTotalPercentRelease(block.timestamp);

        // https://github.com/crytic/slither/wiki/Detector-Documentation#divide-before-multiply
        // slither-disable-next-line divide-before-multiply
        uint256 totalReleaseAmount = (vestingGrant.grantAmount *
            totalPercentRelease) / PERCENT_100_WEI;
        vestedAmount = totalReleaseAmount
            .scaleWeiToDecimals(tokenDecimals)
            .scaleDecimalsToWei(tokenDecimals);
    }

    function _addVestingGrant(
        address account,
        uint256 grantAmount,
        bool isRevocable
    ) internal virtual {
        require(account != address(0), "VCI: zero account");
        require(grantAmount > 0, "VCI: zero grant amount");

        require(
            numVestingScheduleEntries == 0 ||
                block.timestamp < _vestingSchedule[0].startTimestamp,
            "VCI: already started"
        );

        VestingGrant memory vestingGrant = _vestingGrants[account];
        require(
            allowAccumulate || !vestingGrant.isActive,
            "VCI: already added"
        );
        require(
            !vestingGrant.isActive || !revoked(account),
            "VCI: already revoked"
        );

        uint256 truncatedGrantAmount = grantAmount
            .scaleWeiToDecimals(tokenDecimals)
            .scaleDecimalsToWei(tokenDecimals);
        require(truncatedGrantAmount > 0, "VCI: zero decimals grant amount");

        // https://github.com/crytic/slither/wiki/Detector-Documentation#costly-operations-inside-a-loop
        // slither-disable-next-line costly-loop
        totalGrantAmount += truncatedGrantAmount;
        // https://github.com/crytic/slither/wiki/Detector-Documentation/#calls-inside-a-loop
        // slither-disable-next-line calls-loop
        uint256 balanceInDecimals = IERC20(tokenAddress).balanceOf(
            address(this)
        );
        require(balanceInDecimals > 0, "VCI: zero balance");
        uint256 balanceInWei = balanceInDecimals.scaleDecimalsToWei(
            tokenDecimals
        );
        require(totalGrantAmount <= balanceInWei, "VCI: total grant > balance");

        if (vestingGrant.isActive) {
            _vestingGrants[account].grantAmount =
                vestingGrant.grantAmount +
                truncatedGrantAmount;
            // _vestingGrants[account].isRevocable = isRevocable;
        } else {
            _vestingGrants[account] = VestingGrant({
                grantAmount: truncatedGrantAmount,
                isRevocable: isRevocable,
                isRevoked: false,
                isActive: true
            });
        }

        emit VestingGrantAdded(account, truncatedGrantAmount, isRevocable);
    }

    function _release(address account, uint256 amount) internal virtual {
        require(account != address(0), "VCI: zero account");
        require(amount > 0, "VCI: zero amount");
        require(
            !isTgeRefundIndicationPeriodOpen() &&
                !isNonTgeRefundIndicationPeriodOpen(),
            "VCI: refund indication"
        );

        uint256 transferDecimalsAmount = amount.scaleWeiToDecimals(
            tokenDecimals
        );
        uint256 transferWeiAmount = transferDecimalsAmount.scaleDecimalsToWei(
            tokenDecimals
        );

        _released[account] += transferWeiAmount;
        totalReleasedAmount += transferWeiAmount;

        emit TokensReleased(account, transferWeiAmount);

        IERC20(tokenAddress).safeTransfer(account, transferDecimalsAmount);
    }

    function _revokeVestingGrant(address account) internal virtual {
        require(account != address(0), "VCI: zero account");

        VestingGrant memory vestingGrant = _vestingGrants[account];
        require(vestingGrant.isActive, "VCI: inactive");
        require(vestingGrant.isRevocable, "VCI: not revocable");
        require(!revoked(account), "VCI: already revoked");

        uint256 refundedAmount = refundedAmountFor(account);
        uint256 releasedAmount = releasedAmountFor(account);
        uint256 remainderAmount = vestingGrant.grantAmount -
            refundedAmount -
            releasedAmount;
        // https://github.com/crytic/slither/wiki/Detector-Documentation#costly-operations-inside-a-loop
        // slither-disable-next-line costly-loop
        totalRevokedAmount += remainderAmount;
        _vestingGrants[account].isRevoked = true;

        emit VestingGrantRevoked(
            account,
            remainderAmount,
            vestingGrant.grantAmount,
            refundedAmount,
            releasedAmount
        );
    }

    function _getNonTgeRefundAmount(
        address account,
        uint256 grantAmount
    ) internal view virtual returns (uint256 refundAmount) {
        uint256 releasedAmount = releasedAmountFor(account);
        uint256 tgeReleasableAmount = ((grantAmount *
            _vestingSchedule[0].percentRelease) / PERCENT_100_WEI)
            .scaleWeiToDecimals(tokenDecimals)
            .scaleDecimalsToWei(tokenDecimals);
        uint256 refundableAmount = releasedAmount > 0
            ? grantAmount - releasedAmount - refundedAmountFor(account)
            : grantAmount - tgeReleasableAmount;
        refundAmount = refundableAmount
            .scaleWeiToDecimals(tokenDecimals)
            .scaleDecimalsToWei(tokenDecimals);
    }

    function _getTgeRefundAmount(
        address account,
        uint256 grantAmount,
        bool isTgeOnly
    ) internal view virtual returns (uint256 refundAmount) {
        uint256 maxAmountRefundable = isTgeOnly
            ? ((grantAmount * _vestingSchedule[0].percentRelease) /
                PERCENT_100_WEI)
                .scaleWeiToDecimals(tokenDecimals)
                .scaleDecimalsToWei(tokenDecimals)
            : grantAmount;
        uint256 releasedAmount = releasedAmountFor(account);

        refundAmount = releasedAmount >= maxAmountRefundable
            ? 0
            : (maxAmountRefundable - releasedAmount)
                .scaleWeiToDecimals(tokenDecimals)
                .scaleDecimalsToWei(tokenDecimals);
    }

    function _getTotalPercentRelease(
        uint256 atTimestamp
    ) internal view virtual returns (uint256 totalPercentRelease) {
        totalPercentRelease = 0;

        for (uint256 i = 0; i < numVestingScheduleEntries; i++) {
            if (atTimestamp < _vestingSchedule[i].startTimestamp) {
                break;
            }

            if (atTimestamp >= _vestingSchedule[i].endTimestamp) {
                totalPercentRelease += _vestingSchedule[i].percentRelease;
            } else {
                uint256 durationSeconds = _vestingSchedule[i].durationDays *
                    SECONDS_IN_DAY;
                uint256 percentRelease = (atTimestamp -
                    _vestingSchedule[i].startTimestamp) *
                    _vestingSchedule[i].percentRelease;

                // https://github.com/crytic/slither/wiki/Detector-Documentation#divide-before-multiply
                // slither-disable-next-line divide-before-multiply
                totalPercentRelease =
                    (totalPercentRelease * durationSeconds + percentRelease) /
                    durationSeconds;
                break;
            }
        }
    }
}