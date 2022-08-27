// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract KeeperBase {
  error OnlySimulatedBackend();

  /**
   * @notice method that allows it to be simulated via eth_call by checking that
   * the sender is the zero address.
   */
  function preventExecution() internal view {
    if (tx.origin != address(0)) {
      revert OnlySimulatedBackend();
    }
  }

  /**
   * @notice modifier that allows it to be simulated via eth_call by checking
   * that the sender is the zero address.
   */
  modifier cannotExecute() {
    preventExecution();
    _;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KeeperBase.sol";
import "./interfaces/KeeperCompatibleInterface.sol";

abstract contract KeeperCompatible is KeeperBase, KeeperCompatibleInterface {}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface KeeperCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easily be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

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
                        Strings.toHexString(uint160(account), 20),
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
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlEnumerable.sol";
import "./AccessControl.sol";
import "../utils/structs/EnumerableSet.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
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
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Multicall.sol)

pragma solidity ^0.8.0;

import "./Address.sol";

/**
 * @dev Provides a function to batch together multiple calls in a single external call.
 *
 * _Available since v4.1._
 */
abstract contract Multicall {
    /**
     * @dev Receives and executes a batch of function calls on this contract.
     */
    function multicall(bytes[] calldata data) external virtual returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = Address.functionDelegateCall(address(this), data[i]);
        }
        return results;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
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

pragma solidity 0.8.16;

import {AccessControlEnumerable} from "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import {IERC20Metadata, IERC20} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Multicall} from "@openzeppelin/contracts/utils/Multicall.sol";

import {KeeperCompatibleInterface} from "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

interface IGame {
    function hasPendingBets(address token) external view returns (bool);

    function withdrawTokensVRFFees(address token) external;
}

// import "hardhat/console.sol";

/// @title BetSwirl's Bank
/// @author Romuald Hog
/// @notice The Bank contract holds the casino's funds,
/// whitelist the games betting tokens,
/// define the max bet amount based on a risk,
/// payout the bet profit to user and collect the loss bet amount from the game's contract,
/// split and allocate the house edge taken from each bet (won or loss).
/// The admin role is transfered to a Timelock that execute administrative tasks,
/// only the Games could payout the bet profit from the bank, and send the loss bet amount to the bank.
/// @dev All rates are in basis point.
contract Bank is AccessControlEnumerable, KeeperCompatibleInterface, Multicall {
    using SafeERC20 for IERC20;

    /// @notice Enum to identify the Chainlink Upkeep registration.
    enum UpkeepActions {
        DistributePartnerHouseEdge
    }

    /// @notice Token's house edge allocations struct.
    /// The games house edge is split into several allocations.
    /// The allocated amounts stays in the bank until authorized parties withdraw. They are subtracted from the balance.
    /// @param bank Rate to be allocated to the bank, on bet payout.
    /// @param dividend Rate to be allocated as staking rewards, on bet payout.
    /// @param partner Rate to be allocated to the partner, on bet payout.
    /// @param treasury Rate to be allocated to the treasury, on bet payout.
    /// @param team Rate to be allocated to the team, on bet payout.
    /// @param dividendAmount The number of tokens to be sent as staking rewards.
    /// @param partnerAmount The number of tokens to be sent to the partner.
    /// @param treasuryAmount The number of tokens to be sent to the treasury.
    /// @param teamAmount The number of tokens to be sent to the team.
    struct HouseEdgeSplit {
        uint16 bank;
        uint16 dividend;
        uint16 partner;
        uint16 treasury;
        uint16 team;
        uint256 dividendAmount;
        uint256 partnerAmount;
        uint256 treasuryAmount;
        uint256 teamAmount;
    }

    /// @notice Token struct.
    /// List of tokens to bet on games.
    /// @param allowed Whether the token is allowed for bets.
    /// @param paused Whether the token is paused for bets.
    /// @param balanceRisk Defines the maximum bank payout, used to calculate the max bet amount.
    /// @param VRFSubId Chainlink VRF v2 subscription ID.
    /// @param partner Address of the partner to manage the token and receive the house edge.
    /// @param minBetAmount Minimum bet amount.
    /// @param minPartnerTransferAmount The minimum amount of token to distribute the partner house edge.
    /// @param houseEdgeSplit House edge allocations.
    struct Token {
        bool allowed;
        bool paused;
        uint16 balanceRisk;
        uint64 VRFSubId;
        address partner;
        uint256 minBetAmount;
        uint256 minPartnerTransferAmount;
        HouseEdgeSplit houseEdgeSplit;
    }

    /// @notice Token's metadata struct. It contains additional information from the ERC20 token.
    /// @dev Only used on the `getTokens` getter for the front-end.
    /// @param decimals Number of token's decimals.
    /// @param tokenAddress Contract address of the token.
    /// @param name Name of the token.
    /// @param symbol Symbol of the token.
    /// @param token Token data.
    struct TokenMetadata {
        uint8 decimals;
        address tokenAddress;
        string name;
        string symbol;
        Token token;
    }

    /// @notice Number of tokens added.
    uint8 private _tokensCount;

    /// @notice Treasury multi-sig wallet.
    address public immutable treasury;

    /// @notice Team wallet.
    address public teamWallet;

    /// @notice Role associated to Games smart contracts.
    bytes32 public constant GAME_ROLE = keccak256("GAME_ROLE");

    /// @notice Role associated to SwirlMaster smart contract.
    bytes32 public constant SWIRLMASTER_ROLE = keccak256("SWIRLMASTER_ROLE");

    /// @notice Maps tokens addresses to token configuration.
    mapping(address => Token) public tokens;

    /// @notice Maps tokens indexes to token address.
    mapping(uint8 => address) private _tokensList;

    /// @notice Emitted after the team wallet is set.
    /// @param teamWallet The team wallet address.
    event SetTeamWallet(address teamWallet);

    /// @notice Emitted after a token is added.
    /// @param token Address of the token.
    event AddToken(address token);

    /// @notice Emitted after the balance risk is set.
    /// @param balanceRisk Rate defining the balance risk.
    event SetBalanceRisk(address indexed token, uint16 balanceRisk);

    /// @notice Emitted after a token is allowed.
    /// @param token Address of the token.
    /// @param allowed Whether the token is allowed for betting.
    event SetAllowedToken(address indexed token, bool allowed);

    /// @notice Emitted after the minimum bet amount is set for a token.
    /// @param token Address of the token.
    /// @param minBetAmount Minimum bet amount.
    event SetTokenMinBetAmount(address indexed token, uint256 minBetAmount);

    /// @notice Emitted after the token's VRF subscription ID is set.
    /// @param token Address of the token.
    /// @param subId Subscription ID.
    event SetTokenVRFSubId(address indexed token, uint64 subId);

    /// @notice Emitted after a token is paused.
    /// @param token Address of the token.
    /// @param paused Whether the token is paused for betting.
    event SetPausedToken(address indexed token, bool paused);

    /// @notice Emitted after the Upkeep minimum transfer amount is set.
    /// @param token Address of the token.
    /// @param minPartnerTransferAmount Minimum amount of token to allow transfer.
    event SetMinPartnerTransferAmount(
        address indexed token,
        uint256 minPartnerTransferAmount
    );

    /// @notice Emitted after a token partner is set.
    /// @param token Address of the token.
    /// @param partner Address of the partner.
    event SetTokenPartner(address indexed token, address partner);

    /// @notice Emitted after a token deposit.
    /// @param token Address of the token.
    /// @param amount The number of token deposited.
    event Deposit(address indexed token, uint256 amount);

    /// @notice Emitted after a token withdrawal.
    /// @param token Address of the token.
    /// @param amount The number of token withdrawn.
    event Withdraw(address indexed token, uint256 amount);

    /// @notice Emitted after the token's house edge allocations for bet payout is set.
    /// @param token Address of the token.
    /// @param bank Rate to be allocated to the bank, on bet payout.
    /// @param dividend Rate to be allocated as staking rewards, on bet payout.
    /// @param partner Rate to be allocated to the partner, on bet payout.
    /// @param treasury Rate to be allocated to the treasury, on bet payout.
    /// @param team Rate to be allocated to the team, on bet payout.
    event SetTokenHouseEdgeSplit(
        address indexed token,
        uint16 bank,
        uint16 dividend,
        uint16 partner,
        uint16 treasury,
        uint16 team
    );

    /// @notice Emitted after the token's treasury and team allocations are distributed.
    /// @param token Address of the token.
    /// @param treasuryAmount The number of tokens sent to the treasury.
    /// @param teamAmount The number of tokens sent to the team.
    event HouseEdgeDistribution(
        address indexed token,
        uint256 treasuryAmount,
        uint256 teamAmount
    );
    /// @notice Emitted after the token's partner allocation is distributed.
    /// @param token Address of the token.
    /// @param partnerAmount The number of tokens sent to the partner.
    event HouseEdgePartnerDistribution(
        address indexed token,
        uint256 partnerAmount
    );

    /// @notice Emitted after the token's dividend allocation is distributed.
    /// @param token Address of the token.
    /// @param amount The number of tokens sent to the SwirlMaster.
    event HarvestDividend(address indexed token, uint256 amount);

    /// @notice Emitted after the token's house edge is allocated.
    /// @param token Address of the token.
    /// @param bank The number of tokens allocated to bank.
    /// @param dividend The number of tokens allocated as staking rewards.
    /// @param partner The number of tokens allocated to the partner.
    /// @param treasury The number of tokens allocated to the treasury.
    /// @param team The number of tokens allocated to the team.
    event AllocateHouseEdgeAmount(
        address indexed token,
        uint256 bank,
        uint256 dividend,
        uint256 partner,
        uint256 treasury,
        uint256 team
    );

    /// @notice Emitted after the bet profit amount is sent to the user.
    /// @param token Address of the token.
    /// @param newBalance New token balance.
    /// @param profit Bet profit amount sent.
    event Payout(address indexed token, uint256 newBalance, uint256 profit);

    /// @notice Emitted after the bet amount is collected from the game smart contract.
    /// @param token Address of the token.
    /// @param newBalance New token balance.
    /// @param amount Bet amount collected.
    event CashIn(address indexed token, uint256 newBalance, uint256 amount);

    /// @notice Reverting error when trying to add an existing token.
    error TokenExists();
    /// @notice Reverting error when setting the house edge allocations, but the sum isn't 100%.
    /// @param splitSum Sum of the house edge allocations rates.
    error WrongHouseEdgeSplit(uint16 splitSum);
    /// @notice Reverting error when sender isn't allowed.
    error AccessDenied();
    /// @notice Reverting error when team wallet or treasury is the zero address.
    error WrongAddress();
    /// @notice Reverting error when withdrawing a non paused token.
    error TokenNotPaused();
    /// @notice Reverting error when token has pending bets on a game.
    error TokenHasPendingBets();

    /// @notice Modifier that checks that an account is allowed to interact with a token.
    /// @param role The required role.
    /// @param token The token address.
    modifier onlyTokenOwner(bytes32 role, address token) {
        address partner = tokens[token].partner;
        if (partner == address(0)) {
            _checkRole(role, msg.sender);
        } else if (msg.sender != partner) {
            revert AccessDenied();
        }
        _;
    }

    /// @notice Initialize the contract's admin role to the deployer, and state variables.
    /// @param treasuryAddress Treasury multi-sig wallet.
    /// @param teamWalletAddress Team wallet.
    constructor(address treasuryAddress, address teamWalletAddress) {
        if (treasuryAddress == address(0)) {
            revert WrongAddress();
        }

        treasury = treasuryAddress;

        // The ownership should then be transfered to a multi-sig.
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        setTeamWallet(teamWalletAddress);
    }

    /// @notice Transfers a specific amount of token to an address.
    /// Uses native transfer or ERC20 transfer depending on the token.
    /// @dev The 0x address is considered the gas token.
    /// @param user Address of destination.
    /// @param token Address of the token.
    /// @param amount Number of tokens.
    function _safeTransfer(
        address user,
        address token,
        uint256 amount
    ) private {
        if (_isGasToken(token)) {
            payable(user).transfer(amount);
        } else {
            IERC20(token).safeTransfer(user, amount);
        }
    }

    /// @notice Check if the token has the 0x address.
    /// @param token Address of the token.
    /// @return Whether the token's address is the 0x address.
    function _isGasToken(address token) private pure returns (bool) {
        return token == address(0);
    }

    /// @notice Deposit funds in the bank to allow gamers to win more.
    /// ERC20 token allowance should be given prior to deposit.
    /// @param token Address of the token.
    /// @param amount Number of tokens.
    function deposit(address token, uint256 amount)
        external
        payable
        onlyTokenOwner(DEFAULT_ADMIN_ROLE, token)
    {
        if (_isGasToken(token)) {
            amount = msg.value;
        } else {
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        }
        emit Deposit(token, amount);
    }

    /// @notice Withdraw funds from the bank. Token has to be paused and no pending bet resolution on games.
    /// @param token Address of the token.
    /// @param amount Number of tokens.
    function withdraw(address token, uint256 amount)
        public
        onlyTokenOwner(DEFAULT_ADMIN_ROLE, token)
    {
        uint256 balance = getBalance(token);
        if (balance != 0) {
            if (!tokens[token].paused) {
                revert TokenNotPaused();
            }

            uint256 roleMemberCount = getRoleMemberCount(GAME_ROLE);
            for (uint256 i; i < roleMemberCount; i++) {
                if (IGame(getRoleMember(GAME_ROLE, i)).hasPendingBets(token)) {
                    revert TokenHasPendingBets();
                }
            }
        }

        if (amount > balance) {
            amount = balance;
        }
        _safeTransfer(msg.sender, token, amount);
        emit Withdraw(token, amount);
    }

    /// @notice Sets the new token balance risk.
    /// @param token Address of the token.
    /// @param balanceRisk Risk rate.
    function setBalanceRisk(address token, uint16 balanceRisk)
        external
        onlyTokenOwner(DEFAULT_ADMIN_ROLE, token)
    {
        tokens[token].balanceRisk = balanceRisk;
        emit SetBalanceRisk(token, balanceRisk);
    }

    /// @notice Adds a new token that'll be enabled for the games' betting.
    /// Token shouldn't exist yet.
    /// @param token Address of the token.
    function addToken(address token) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_tokensCount != 0) {
            for (uint8 i; i < _tokensCount; i++) {
                if (_tokensList[i] == token) {
                    revert TokenExists();
                }
            }
        }
        _tokensList[_tokensCount] = token;
        _tokensCount += 1;
        emit AddToken(token);
    }

    /// @notice Changes the token's bet permission.
    /// @param token Address of the token.
    /// @param allowed Whether the token is enabled for bets.
    function setAllowedToken(address token, bool allowed)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        tokens[token].allowed = allowed;
        emit SetAllowedToken(token, allowed);
    }

    /// @notice Changes the token's paused status.
    /// @param token Address of the token.
    /// @param paused Whether the token is paused.
    function setPausedToken(address token, bool paused)
        external
        onlyTokenOwner(DEFAULT_ADMIN_ROLE, token)
    {
        tokens[token].paused = paused;
        emit SetPausedToken(token, paused);
    }

    /// @notice Changes the token's Upkeep min transfer amount.
    /// @param token Address of the token.
    /// @param minPartnerTransferAmount Minimum amount of token to allow transfer.
    function setMinPartnerTransferAmount(
        address token,
        uint256 minPartnerTransferAmount
    ) external onlyTokenOwner(DEFAULT_ADMIN_ROLE, token) {
        tokens[token].minPartnerTransferAmount = minPartnerTransferAmount;
        emit SetMinPartnerTransferAmount(token, minPartnerTransferAmount);
    }

    /// @notice Changes the token's partner address.
    /// It withdraw the available balance, the partner allocation, and the games' VRF fees.
    /// @param token Address of the token.
    /// @param partner Address of the partner.
    function setTokenPartner(address token, address partner)
        external
        onlyTokenOwner(DEFAULT_ADMIN_ROLE, token)
    {
        uint256 roleMemberCount = getRoleMemberCount(GAME_ROLE);
        for (uint256 i; i < roleMemberCount; i++) {
            IGame(getRoleMember(GAME_ROLE, i)).withdrawTokensVRFFees(token);
        }
        withdrawPartnerAmount(token);
        withdraw(token, getBalance(token));
        tokens[token].partner = partner;
        emit SetTokenPartner(token, partner);
    }

    /// @notice Sets the token's house edge allocations for bet payout.
    /// @param token Address of the token.
    /// @param bank Rate to be allocated to the bank, on bet payout.
    /// @param dividend Rate to be allocated as staking rewards, on bet payout.
    /// @param partner Rate to be allocated to the partner, on bet payout.
    /// @param _treasury Rate to be allocated to the treasury, on bet payout.
    /// @param team Rate to be allocated to the team, on bet payout.
    /// @dev `bank`, `dividend`, `_treasury` and `team` rates sum must equals 10000.
    function setHouseEdgeSplit(
        address token,
        uint16 bank,
        uint16 dividend,
        uint16 partner,
        uint16 _treasury,
        uint16 team
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint16 splitSum = bank + dividend + team + partner + _treasury;
        if (splitSum != 10000) {
            revert WrongHouseEdgeSplit(splitSum);
        }

        HouseEdgeSplit storage tokenHouseEdge = tokens[token].houseEdgeSplit;
        tokenHouseEdge.bank = bank;
        tokenHouseEdge.dividend = dividend;
        tokenHouseEdge.partner = partner;
        tokenHouseEdge.treasury = _treasury;
        tokenHouseEdge.team = team;

        emit SetTokenHouseEdgeSplit(
            token,
            bank,
            dividend,
            partner,
            _treasury,
            team
        );
    }

    /// @notice Sets the minimum bet amount for a specific token.
    /// @param token Address of the token.
    /// @param tokenMinBetAmount Minimum bet amount.
    function setTokenMinBetAmount(address token, uint256 tokenMinBetAmount)
        external
        onlyTokenOwner(DEFAULT_ADMIN_ROLE, token)
    {
        tokens[token].minBetAmount = tokenMinBetAmount;
        emit SetTokenMinBetAmount(token, tokenMinBetAmount);
    }

    /// @notice Sets the Chainlink VRF subscription ID for a specific token.
    /// @param token Address of the token.
    /// @param subId Subscription ID.
    function setTokenVRFSubId(address token, uint64 subId)
        external
        onlyTokenOwner(DEFAULT_ADMIN_ROLE, token)
    {
        tokens[token].VRFSubId = subId;
        emit SetTokenVRFSubId(token, subId);
    }

    /// @notice Harvests tokens dividends.
    /// @return The list of tokens addresses.
    /// @return The list of tokens' amounts harvested.
    function harvestDividends()
        external
        onlyRole(SWIRLMASTER_ROLE)
        returns (address[] memory, uint256[] memory)
    {
        address[] memory _tokens = new address[](_tokensCount);
        uint256[] memory _amounts = new uint256[](_tokensCount);

        for (uint8 i; i < _tokensCount; i++) {
            address tokenAddress = _tokensList[i];
            Token storage token = tokens[tokenAddress];
            uint256 dividendAmount = token.houseEdgeSplit.dividendAmount;
            if (dividendAmount != 0) {
                delete token.houseEdgeSplit.dividendAmount;
                _safeTransfer(msg.sender, tokenAddress, dividendAmount);
                emit HarvestDividend(tokenAddress, dividendAmount);
                _tokens[i] = tokenAddress;
                _amounts[i] = dividendAmount;
            }
        }

        return (_tokens, _amounts);
    }

    /// @notice Get the available tokens dividends amounts.
    /// @return The list of tokens addresses.
    /// @return The list of tokens' amounts harvested.
    function getDividends()
        external
        view
        returns (address[] memory, uint256[] memory)
    {
        address[] memory _tokens = new address[](_tokensCount);
        uint256[] memory _amounts = new uint256[](_tokensCount);

        for (uint8 i; i < _tokensCount; i++) {
            address tokenAddress = _tokensList[i];
            Token storage token = tokens[tokenAddress];
            uint256 dividendAmount = token.houseEdgeSplit.dividendAmount;
            if (dividendAmount != 0) {
                _tokens[i] = tokenAddress;
                _amounts[i] = dividendAmount;
            }
        }

        return (_tokens, _amounts);
    }

    /// @notice Payouts a winning bet, and allocate the house edge fee.
    /// @param user Address of the gamer.
    /// @param token Address of the token.
    /// @param profit Number of tokens to be sent to the gamer.
    /// @param fees Bet amount and bet profit fees amount.
    function payout(
        address payable user,
        address token,
        uint256 profit,
        uint256 fees
    ) external payable onlyRole(GAME_ROLE) {
        // Splits the house edge fees and allocates them as dividends, to the partner, the bank, the treasury, and team.
        {
            HouseEdgeSplit storage tokenHouseEdge = tokens[token]
                .houseEdgeSplit;

            uint256 partnerAmount;
            if (tokenHouseEdge.partner != 0) {
                partnerAmount = ((fees * tokenHouseEdge.partner) / 10000);
                tokenHouseEdge.partnerAmount += partnerAmount;
            }

            uint256 dividendAmount = (fees * tokenHouseEdge.dividend) / 10000;
            tokenHouseEdge.dividendAmount += dividendAmount;

            // The bank also get allocated a share of the house edge.
            uint256 bankAmount = (fees * tokenHouseEdge.bank) / 10000;

            uint256 treasuryAmount = (fees * tokenHouseEdge.treasury) / 10000;
            tokenHouseEdge.treasuryAmount += treasuryAmount;

            uint256 teamAmount = (fees * tokenHouseEdge.team) / 10000;
            tokenHouseEdge.teamAmount += teamAmount;

            emit AllocateHouseEdgeAmount(
                token,
                bankAmount,
                dividendAmount,
                partnerAmount,
                treasuryAmount,
                teamAmount
            );
        }

        // Pay the user
        _safeTransfer(user, token, profit);
        emit Payout(token, getBalance(token), profit);
    }

    /// @notice Accounts a loss bet.
    /// @dev In case of an ERC20, the bet amount should be transfered prior to this tx.
    /// @dev In case of the gas token, the bet amount is sent along with this tx.
    /// @param tokenAddress Address of the token.
    /// @param amount Loss bet amount.
    function cashIn(address tokenAddress, uint256 amount)
        external
        payable
        onlyRole(GAME_ROLE)
    {
        emit CashIn(
            tokenAddress,
            getBalance(tokenAddress),
            _isGasToken(tokenAddress) ? msg.value : amount
        );
    }

    /// @notice Executed by Chainlink Keepers when `upkeepNeeded` is true.
    /// @param performData Data which was passed back from `checkUpkeep`.
    function performUpkeep(bytes calldata performData) external override {
        (UpkeepActions upkeepAction, address tokenAddress) = abi.decode(
            performData,
            (UpkeepActions, address)
        );
        Token memory token = tokens[tokenAddress];

        if (
            upkeepAction == UpkeepActions.DistributePartnerHouseEdge &&
            token.houseEdgeSplit.partnerAmount > token.minPartnerTransferAmount
        ) {
            withdrawPartnerAmount(tokenAddress);
        }
    }

    /// @dev For the front-end
    function getTokens() external view returns (TokenMetadata[] memory) {
        TokenMetadata[] memory _tokens = new TokenMetadata[](_tokensCount);
        for (uint8 i; i < _tokensCount; i++) {
            address tokenAddress = _tokensList[i];
            Token memory token = tokens[tokenAddress];
            if (_isGasToken(tokenAddress)) {
                _tokens[i] = TokenMetadata({
                    decimals: 18,
                    tokenAddress: tokenAddress,
                    name: "ETH",
                    symbol: "ETH",
                    token: token
                });
            } else {
                IERC20Metadata erc20Metadata = IERC20Metadata(tokenAddress);
                _tokens[i] = TokenMetadata({
                    decimals: erc20Metadata.decimals(),
                    tokenAddress: tokenAddress,
                    name: erc20Metadata.name(),
                    symbol: erc20Metadata.symbol(),
                    token: token
                });
            }
        }
        return _tokens;
    }

    /// @notice Gets the token's min bet amount.
    /// @param token Address of the token.
    /// @return minBetAmount Min bet amount.
    /// @dev The min bet amount should be at least 10000 cause of the `getMaxBetAmount` calculation.
    function getMinBetAmount(address token)
        external
        view
        returns (uint256 minBetAmount)
    {
        minBetAmount = tokens[token].minBetAmount;
        if (minBetAmount == 0) {
            minBetAmount = 10000;
        }
    }

    /// @notice Calculates the max bet amount based on the token balance, the balance risk, and the game multiplier.
    /// @param token Address of the token.
    /// @param multiplier The bet amount leverage determines the user's profit amount. 10000 = 100% = no profit.
    /// @return Maximum bet amount for the token.
    /// @dev The multiplier should be at least 10000.
    function getMaxBetAmount(address token, uint256 multiplier)
        external
        view
        returns (uint256)
    {
        return (getBalance(token) * tokens[token].balanceRisk) / multiplier;
    }

    /// @notice Gets the token's allow status used on the games smart contracts.
    /// @param tokenAddress Address of the token.
    /// @return Whether the token is enabled for bets.
    function isAllowedToken(address tokenAddress) external view returns (bool) {
        Token memory token = tokens[tokenAddress];
        return token.allowed && !token.paused;
    }

    /// @notice Runs by Chainlink Keepers at every block to determine if `performUpkeep` should be called.
    /// @param checkData Fixed and specified at Upkeep registration.
    /// @return upkeepNeeded Boolean that when True will trigger the on-chain performUpkeep call.
    /// @return performData Bytes that will be used as input parameter when calling performUpkeep.
    /// @dev `checkData` and `performData` are encoded with types (uint8, address).
    function checkUpkeep(bytes calldata checkData)
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        (UpkeepActions upkeepAction, address tokenAddressData) = abi.decode(
            checkData,
            (UpkeepActions, address)
        );
        if (upkeepAction == UpkeepActions.DistributePartnerHouseEdge) {
            Token memory token = tokens[tokenAddressData];
            if (
                token.houseEdgeSplit.partnerAmount >
                token.minPartnerTransferAmount
            ) {
                upkeepNeeded = true;
                performData = abi.encode(upkeepAction, tokenAddressData);
            }
        }
    }

    /// @notice Gets the token's Chainlink VRF v2 Subscription ID.
    /// @param token Address of the token.
    /// @return Chainlink VRF v2 Subscription ID.
    function getVRFSubId(address token) external view returns (uint64) {
        return tokens[token].VRFSubId;
    }

    /// @notice Gets the token's owner.
    /// @param token Address of the token.
    /// @return Address of the owner.
    function getTokenOwner(address token) external view returns (address) {
        address partner = tokens[token].partner;
        if (partner == address(0)) {
            return getRoleMember(DEFAULT_ADMIN_ROLE, 0);
        } else {
            return partner;
        }
    }

    /// @notice Sets the new team wallet.
    /// @param _teamWallet The team wallet address.
    function setTeamWallet(address _teamWallet)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        if (_teamWallet == address(0)) {
            revert WrongAddress();
        }
        teamWallet = _teamWallet;
        emit SetTeamWallet(teamWallet);
    }

    /// @notice Distributes the token's treasury and team allocations amounts.
    /// @param tokenAddress Address of the token.
    function withdrawHouseEdgeAmount(address tokenAddress) public {
        HouseEdgeSplit storage tokenHouseEdge = tokens[tokenAddress]
            .houseEdgeSplit;
        uint256 treasuryAmount = tokenHouseEdge.treasuryAmount;
        uint256 teamAmount = tokenHouseEdge.teamAmount;
        if (treasuryAmount != 0) {
            delete tokenHouseEdge.treasuryAmount;
            _safeTransfer(treasury, tokenAddress, treasuryAmount);
        }
        if (teamAmount != 0) {
            delete tokenHouseEdge.teamAmount;
            _safeTransfer(teamWallet, tokenAddress, teamAmount);
        }
        if (treasuryAmount != 0 || teamAmount != 0) {
            emit HouseEdgeDistribution(
                tokenAddress,
                treasuryAmount,
                teamAmount
            );
        }
    }

    /// @notice Distributes the token's partner amount.
    /// @param tokenAddress Address of the token.
    function withdrawPartnerAmount(address tokenAddress) public {
        Token storage token = tokens[tokenAddress];
        uint256 partnerAmount = token.houseEdgeSplit.partnerAmount;
        if (partnerAmount != 0 && token.partner != address(0)) {
            delete token.houseEdgeSplit.partnerAmount;
            _safeTransfer(token.partner, tokenAddress, partnerAmount);
            emit HouseEdgePartnerDistribution(tokenAddress, partnerAmount);
        }
    }

    /// @notice Gets the token's balance.
    /// The token's house edge allocation amounts are subtracted from the balance.
    /// @param token Address of the token.
    /// @return The amount of token available for profits.
    function getBalance(address token) public view returns (uint256) {
        uint256 balance;
        if (_isGasToken(token)) {
            balance = address(this).balance;
        } else {
            balance = IERC20(token).balanceOf(address(this));
        }
        HouseEdgeSplit memory tokenHouseEdgeSplit = tokens[token]
            .houseEdgeSplit;
        return
            balance -
            tokenHouseEdgeSplit.dividendAmount -
            tokenHouseEdgeSplit.partnerAmount -
            tokenHouseEdgeSplit.treasuryAmount -
            tokenHouseEdgeSplit.teamAmount;
    }
}