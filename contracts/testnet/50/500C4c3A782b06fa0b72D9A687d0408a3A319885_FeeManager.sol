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

// SPDX-License-Identifier: GPL-3.0

/**
 * Developed By Snake M
 */
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/IEmergencyGuard.sol";

abstract contract EmergencyGuard is IEmergencyGuard {
    function _emergencyWithdraw(uint256 amount) internal virtual {
        address payable sender = payable(msg.sender);
        (bool sent,) = sender.call{value : amount}("");
        require(sent, "Lama: Failed to send BNB");

        emit EmergencyWithdraw(msg.sender, amount);
    }

    function _emergencyWithdrawToken(address token, uint256 amount)
    internal
    virtual
    {
        IERC20(token).transfer(msg.sender, amount);
        emit EmergencyWithdrawToken(msg.sender, token, amount);
    }
}

// SPDX-License-Identifier: GPL-3.0
/**
 * Developed By Snake M
 */
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./GenericFeeManager.sol";
import "./interfaces/ILamaToken.sol";

/**
 * @title Fee Manager for ERC20 token
 */
contract FeeManager is GenericFeeManager {
    constructor(address lamaToken) GenericFeeManager(lamaToken) {}

    receive() external payable {}

    function reflectFees(
        address from,
        address to,
        uint256 amount
    ) external override returns (uint256 tTotal, uint256 tFee) {
        require(
            hasRole(CALL_REFLECT_FEES, _msgSender()),
            "FeeManager: Caller is missing required role"
        );

        bool bypassFees = !feesEnabled() ||
        from == owner() ||
        hasRole(ADMIN, from) ||
        hasRole(FEE_WHITELIST, from) ||
        hasRole(RECEIVER_FEE_WHITELIST, to);

        if (bypassFees) {
            return (amount, 0);
        }


        if (from == pancakePairBnbAddress() || from == pancakePairBusdAddress()) {
            // Buy Fees
            tFee = _calculateFee(amount, getBuyFee());
        } else {
            // Sell Fees
            tFee = _calculateFee(amount, getSellFee());
        }

        _reflectFee(from, to, tFee);

        tTotal = amount - tFee;
        require(tTotal > 0, "FeeManager: invalid total amount");

        return (tTotal, tFee);
    }

    /**
     * Reflects a single fee
     *
     * @param from address - Sender address
     * @param to address - Receiver address
     * @param tFee uint256 - Fee amount
     */
    function _reflectFee(
        address from,
        address to,
        uint256 tFee
    ) private {

        // add to swap amount or transfer to fee destination
        require(
            ILamaToken(address(token())).transferFromNoFees(
                from,
                address(this),
                tFee
            ),
            "FeeManager: Fee transfer to manager failed"
        );

        // TODO BEK: Need to add a logic to validate it hit the threshold

        uint256 tokenSwapped = _getSwapAmount(
            percentageVolumeSwap(),
            pancakePairBnbAddress()
        );

        // Swap token for BNB
        _swapTokensForBnb(tokenSwapped, getFeesDestination());

        emit FeeReflected(from, to, tFee);
    }

    /**
     * Calculates a single fee
     *
     * @param amount uint256 - Transaction amount
     * @param percentage uint256 - Fee percentage
     *
     * @return tFee - Total Fee Amount
     */
    function _calculateFee(uint256 amount, uint256 percentage)
    private
    pure
    returns (uint256 tFee)
    {
        return (amount * percentage) / FEE_DIVIDER;
    }
}

// SPDX-License-Identifier: GPL-3.0
/**
 * Developed By Snake M
 */
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./EmergencyGuard.sol";
import "./interfaces/IFeeManager.sol";

/**
 * @title Generic Fee Manager
 */
abstract contract GenericFeeManager is
IFeeManager,
EmergencyGuard,
AccessControlEnumerable,
Ownable,
ReentrancyGuard
{
    // Role allowed to do admin operations like adding to fee whitelist, withdraw, etc.
    bytes32 public constant ADMIN = keccak256("ADMIN");

    // Role allowed to bypass fees
    bytes32 public constant FEE_WHITELIST = keccak256("FEE_WHITELIST");

    // Role allowed to token be sent to without fee
    bytes32 public constant RECEIVER_FEE_WHITELIST =
    keccak256("RECEIVER_FEE_WHITELIST");

    // Role allowed to bypass swap and liquify
    // bytes32 public constant BYPASS_SWAP_AND_LIQUIFY =
    // keccak256("BYPASS_SWAP_AND_LIQUIFY");

    // Role allowed to call reflectFees
    bytes32 public constant CALL_REFLECT_FEES = keccak256("CALL_REFLECT_FEES");

    // Transaction fee limit (Max LAMA Transaction limit for buy and sell at launch for the first minutes then no limit)
    // Can buy max 2000 LAMA Tokens and can sell max 2000 LAMA Tokens for the first minutes then no limit
    uint256 internal constant INITIAL_TRANSACTION_LIMIT = 2_000;

    // Fee divider
    uint256 internal constant FEE_DIVIDER = 100_000;

    // Fee percentage limit (Fees cannot exceed 20%)
    uint256 internal constant FEE_PERCENTAGE_LIMIT = 20_000;

    // Buy Fee - 10%
    uint256 private _buyFeePercentage = 10_000;

    // Sell Fee - 10%
    uint256 private _sellFeePercentage = 10_000;

    // Fees enabled state
    bool private _feesEnabled = true;

    // Transaction limit enabled at launch for the first minutes then it will be set
    // automatically by the smart contract to false and can never be set to true after that
    bool private _transactionLimitEnabled = true;

    address private _feesDestination = 0xABE7F3DbF0F46dbeBcc76050DD304d371Bd2028c;

    // Pancake Router address
    IPancakeRouter02 private _pancakeRouter;

    // BNB address
    address private _bnbAddress;

    // BUSD address
    address private _busdAddress;

    // Volume percentage for swap events
    uint256 private _percentageVolumeSwap = 1;

    // Volume percentage for liquify events
    uint256 private _percentageVolumeLiquify = 0;

    // Pancakeswap Pair (LAMA <-> BUSD) address
    address private _pancakePairBusdAddress;

    // Pancakeswap Pair (LAMA <-> BNB) address
    address private _pancakePairBnbAddress;

    // Lama token
    IERC20 private _token;


    constructor(address lamaToken) {
        // Add owner to admin role
        _setupRole(ADMIN, _msgSender());

        // Set role admin for roles
        _setRoleAdmin(ADMIN, ADMIN);
        _setRoleAdmin(FEE_WHITELIST, ADMIN);
        _setRoleAdmin(RECEIVER_FEE_WHITELIST, ADMIN);
        _setRoleAdmin(CALL_REFLECT_FEES, ADMIN);

        // Create Lama token instance
        _token = IERC20(lamaToken);
    }

    /**
     * Getter & Setter
     */

    function getFeesDestination()
    public
    view
    override
    returns (address destination)
    {
        return _feesDestination;
    }


    function getBuyFee()
    public
    view
    override
    returns (uint256 amount)
    {
        return _buyFeePercentage;
    }

    function getSellFee()
    public
    view
    override
    returns (uint256 amount)
    {
        return _sellFeePercentage;
    }

    function setFeesDestination(address destination) external override onlyRole(ADMIN) {
        _feesDestination = destination;
    }


    function setBuyFee(uint256 percentage) external override onlyRole(ADMIN) {
        require(
            percentage <= feePercentageLimit(),
            "FeeManager: Buy Fee percentage exceeds limit"
        );

        _buyFeePercentage = percentage;
    }

    function setSellFee(uint256 percentage) external override onlyRole(ADMIN) {
        require(
            percentage <= feePercentageLimit(),
            "FeeManager: Sell Fee percentage exceeds limit"
        );

        _sellFeePercentage = percentage;
    }

    function setFeesEnabled(bool value) external override onlyRole(ADMIN) {
        _feesEnabled = value;

        emit FeeEnabledUpdated(value);
    }

    function disableTransactionLimit() external override onlyRole(ADMIN) {
        _transactionLimitEnabled = false;

        emit TransactionLimitDisabled();
    }

    function setPancakeRouter(address value) external override onlyRole(ADMIN) {
        require(
            value != address(0),
            "FeeManager: Cannot set Pancake Router to zero address"
        );

        _pancakeRouter = IPancakeRouter02(value);
        emit PancakeRouterUpdated(value);
    }

    function setBnbAddress(address value) external override onlyRole(ADMIN) {
        require(
            value != address(0),
            "FeeManager: Cannot set BNB to zero address"
        );

        _bnbAddress = value;

        emit BnbAddressUpdated(value);
    }

    function setBusdAddress(address value) external override onlyRole(ADMIN) {
        require(
            value != address(0),
            "FeeManager: Cannot set BUSD to zero address"
        );

        _bnbAddress = value;
        emit BusdAddressUpdated(value);
    }

    function emergencyWithdraw(uint256 amount)
    external
    override
    onlyRole(ADMIN)
    {
        super._emergencyWithdraw(amount);
    }

    function emergencyWithdrawToken(address tokenToWithdraw, uint256 amount)
    external
    override
    onlyRole(ADMIN)
    {
        super._emergencyWithdrawToken(tokenToWithdraw, amount);
    }

    function setPercentageVolumeSwap(uint256 value)
    external
    override
    onlyRole(ADMIN)
    {
        require(
            value <= 100,
            "FeeManager: Invalid percentage volume swap value"
        );

        _percentageVolumeSwap = value;

        emit PercentageVolumeSwapUpdated(value);
    }

    function setPercentageVolumeLiquify(uint256 value)
    external
    override
    onlyRole(ADMIN)
    {
        require(
            value <= 100,
            "FeeManager: Invalid percentage volume liquify value"
        );

        _percentageVolumeLiquify = value;

        emit PercentageVolumeLiquifyUpdated(value);
    }

    function setPancakePairBnbAddress(address value)
    external
    override
    onlyRole(ADMIN)
    {
        require(
            value != address(0),
            "FeeManager: Cannot set BNB pair to zero address"
        );

        _pancakePairBnbAddress = value;

        emit PancakePairBnbUpdated(value);
    }

    function setPancakePairBusdAddress(address value)
    external
    override
    onlyRole(ADMIN)
    {
        require(
            value != address(0),
            "FeeManager: Cannot set BUSD pair to zero address"
        );

        _pancakePairBusdAddress = value;

        emit PancakePairBusdUpdated(value);
    }

    function feesEnabled() public view override returns (bool) {
        return _feesEnabled;
    }


    function transactionLimitEnabled() public view override returns (bool) {
        return _transactionLimitEnabled;
    }

    function pancakeRouter()
    public
    view
    override
    returns (IPancakeRouter02 value)
    {
        return _pancakeRouter;
    }

    function bnbAddress() public view override returns (address value) {
        return _bnbAddress;
    }

    function busdAddress() public view override returns (address value) {
        return _busdAddress;
    }

    function feePercentageLimit() public pure override returns (uint256 value) {
        return FEE_PERCENTAGE_LIMIT;
    }

    function percentageVolumeSwap()
    public
    view
    override
    returns (uint256 value)
    {
        return _percentageVolumeSwap;
    }

    function percentageVolumeLiquify()
    public
    view
    override
    returns (uint256 value)
    {
        return _percentageVolumeLiquify;
    }


    function pancakePairBnbAddress()
    public
    view
    override
    returns (address value)
    {
        return _pancakePairBnbAddress;
    }

    function pancakePairBusdAddress()
    public
    view
    override
    returns (address value)
    {
        return _pancakePairBusdAddress;
    }

    function token() public view override returns (IERC20 value) {
        return _token;
    }

    /**
     * Swaps tokens against BNB on Pancakeswap
     *
     * @param amount uint256 - Amount to use
     * @param destination address - Destination address for BNB
     */
    function _swapTokensForBnb(uint256 amount, address destination) internal {
        // generate the uniswap pair path of token -> wbnb
        address[] memory path = new address[](2);
        path[0] = address(token());
        path[1] = pancakeRouter().WETH();

        require(
            token().approve(address(pancakeRouter()), amount),
            "FeeManager: Failed to approve token for swap to BNB"
        );

        // make the swap
        pancakeRouter().swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of BNB
            path,
            destination,
            block.timestamp
        );
    }

    /**
     * Creates liquidity on Pancakeswap
     *
     * @param tokenAmount uint256 - Amount of token to use
     * @param bnbAmount uint256 - Amount of BNB to use
     * @param destination address - Destination address for the LP tokens
     *
     * @return tokenSwapped uint256 - Amount of token which have been swapped
     */
    function _addLiquidity(
        uint256 tokenAmount,
        uint256 bnbAmount,
        address destination
    ) internal returns (uint256 tokenSwapped) {
        // approve token transfer to cover all possible scenarios
        require(
            token().approve(address(pancakeRouter()), tokenAmount),
            "FeeManager: Failed to approve token for adding liquidity"
        );

        // add the liquidity
        (tokenSwapped,,) = pancakeRouter().addLiquidityETH{value : bnbAmount}(
            address(token()),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            destination,
            block.timestamp
        );

        return tokenSwapped;
    }

    /**
     * Returns the amount used for swap / liquify based on volume percentage for swap / liquify
     *
     * @param percentageVolume uint256 - Volume percentage for swap / liquify
     * @param pancakePairAddress address - Pancakeswap pair address to use for volume
     *
     * @return amount uint256 - Amount used for swap / liquify
     */
    function _getSwapAmount(
        uint256 percentageVolume,
        address pancakePairAddress
    ) internal view returns (uint256 amount) {

        uint256 pancakePairTokenBalance = token().balanceOf(pancakePairAddress);

        uint256 percentualAmount = (pancakePairTokenBalance * percentageVolume) / 100;
        //        if (pancakePairAddress == address(0) || percentageVolume == 0) {
        //            return swapOrLiquifyAmount;
        //        }
        //
        //        // Get pancakeswap pair token balance to identify, how many
        //        // token are currently on the market
        //        uint256 pancakePairTokenBalance = token().balanceOf(pancakePairAddress);
        //
        //        // Calculate percentual amount of volume
        //        uint256 percentualAmount = (pancakePairTokenBalance *
        //        percentageVolume) / 100;
        //
        //        // Do not exceed swap or liquify amount from fee entry
        //        if (percentualAmount >= swapOrLiquifyAmount) {
        //            return swapOrLiquifyAmount;
        //        }

        return percentualAmount;
    }
}

// SPDX-License-Identifier: GPL-3.0
/**
 * Developed By Snake M
 */
pragma solidity 0.8.17;

interface IEmergencyGuard {
    /**
     * Emitted on BNB withdrawal
     *
     * @param receiver address - Receiver of BNB
     * @param amount uint256 - BNB amount
     */
    event EmergencyWithdraw(address receiver, uint256 amount);

    /**
     * Emitted on token withdrawal
     *
     * @param receiver address - Receiver of token
     * @param token address - Token address
     * @param amount uint256 - token amount
     */
    event EmergencyWithdrawToken(
        address receiver,
        address token,
        uint256 amount
    );

    /**
     * Withdraws BNB stores at the contract
     *
     * @param amount uint256 - Amount of BNB to withdraw
     */
    function emergencyWithdraw(uint256 amount) external;

    /**
     * Withdraws token stores at the contract
     *
     * @param token address - Token to withdraw
     * @param amount uint256 - Amount of token to withdraw
     */
    function emergencyWithdrawToken(address token, uint256 amount) external;
}

// SPDX-License-Identifier: GPL-3.0
/**
 * Developed By Snake M
 */
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IPancakeRouter.sol";

interface IFeeManager {

    /**
     * Emitted on fee reflection / distribution
     *
     * @param from address - Sender address OR address(0) for wildcard
     * @param to address - Receiver address OR address(0) for wildcard
     * @param tFee uint256 - Fee used
     */
    event FeeReflected(
        address indexed from,
        address to,
        uint256 tFee
    );

    /**
     * Emitted on fee state update
     *
     * @param enabled bool - Indicates if fees are enabled now
     */
    event FeeEnabledUpdated(bool enabled);

    /**
     * Emitted on pancake router address update
     *
     * @param newAddress address - New pancake router address
     */
    event PancakeRouterUpdated(address newAddress);

    /**
     * Emitted on BUSD address update
     *
     * @param newAddress address - New BUSD address
     */
    event BusdAddressUpdated(address newAddress);


    /**
     * Emitted on BNB address update
     *
     * @param newAddress address - New BNB address
     */
    event BnbAddressUpdated(address newAddress);

    /**
     * Emitted on volume percentage for swap events updated
     *
     * @param newPercentage uint256 - New volume percentage for swap events
     */
    event PercentageVolumeSwapUpdated(uint256 newPercentage);

    /**
     * Emitted on volume percentage for liquify events updated
     *
     * @param newPercentage uint256 - New volume percentage for liquify events
     */
    event PercentageVolumeLiquifyUpdated(uint256 newPercentage);

    /**
     * Emitted on Pancakeswap pair (LAMA <-> BUSD) address updated
     *
     * @param newAddress address - New pair address
     */
    event PancakePairBusdUpdated(address newAddress);

    /**
     * Emitted on Pancakeswap pair (LAMA <-> BNB) address updated
     *
     * @param newAddress address - New pair address
     */
    event PancakePairBnbUpdated(address newAddress);


    /**
     * Emitted on Disable Transaction Limit
     *
     */
    event TransactionLimitDisabled();

    /**
     * Emitted on token swap to BUSD
     *
     * @param token address - Token used for swap
     * @param inputAmount uint256 - Amount used as input for swap
     * @param newBalance uint256 - Amount of received BUSD
     * @param destination address - Destination address for BUSD
     */
    event SwapTokenForBnb(
        address token,
        uint256 inputAmount,
        uint256 newBalance,
        address indexed destination
    );

    /**
     * Return the Fees Destination
     *
     *
     * @return destination address - Fees destination address
     */
    function getFeesDestination() external view returns (address destination);

    /**
     * Return the Buy Fee
     *
     *
     * @return amount uint256 - Fee amount
     */
    function getBuyFee() external view returns (uint256 amount);

    /**
     * Return the Sell Fee
     *
     *
     * @return amount uint256 - Fee amount
     */
    function getSellFee() external view returns (uint256 amount);


    /**
     * Sets Fees Destination
     *
     * @param destination address - Fees Destination Address
     */
    function setFeesDestination(address destination) external;

    /**
     * Sets the Buy Fee
     *
     * @param percentage uint256 - percentage of buy fees which does not excend the fee percentage limit of 20%
     */
    function setBuyFee(uint256 percentage) external;

    /**
     * Sets the Sell Fee
     *
     * @param percentage uint256 - percentage of buy fees which does not excend the fee percentage limit of 20%
     */
    function setSellFee(uint256 percentage) external;



    /**
     * Reflects the fee for a transaction
     *
     * @param from address - Sender address
     * @param to address - Receiver address
     * @param amount uint256 - Transaction amount
     *
     * @return tTotal uint256 - Total transaction amount after fees
     * @return tFees uint256 - Total fee amount
     */
    function reflectFees(
        address from,
        address to,
        uint256 amount
    ) external returns (uint256 tTotal, uint256 tFees);

    /**
     * Returns true if fees are enabled, false when disabled
     *
     * @param value bool - Indicates if fees are enabled
     */
    function feesEnabled() external view returns (bool value);

    /**
     * Sets the transaction fee state
     *
     * @param value bool - true to enable fees, false to disable
     */
    function setFeesEnabled(bool value) external;

    /**
     * Returns true if transactions limit are enabled, false when disabled
     *
     * @param value bool - Indicates if transactions limit are enabled
     */
    function transactionLimitEnabled() external view returns (bool value);


    /**
    * Disable Transaction Limit
    *
    */
    function disableTransactionLimit() external;

    /**
     * Returns the pancake router
     *
     * @return value IPancakeRouter02 - Pancake router
     */
    function pancakeRouter() external view returns (IPancakeRouter02 value);

    /**
     * Sets the pancake router
     *
     * @param value address - New pancake router address
     */
    function setPancakeRouter(address value) external;

    /**
     * Returns the BUSD address
     *
     * @return value address - BUSD address
     */
    function busdAddress() external view returns (address value);

    /**
     * Sets the BUSD address
     *
     * @param value address - BUSD address
     */
    function setBusdAddress(address value) external;


    /**
     * Returns the BNB address
     *
     * @return value address - BNB address
     */
    function bnbAddress() external view returns (address value);

    /**
     * Sets the BNB address
     *
     * @param value address - BNB address
     */
    function setBnbAddress(address value) external;

    /**
     * Returns the fee entry percentage limit
     *
     * @return value uint256 - Fee entry percentage limit
     */
    function feePercentageLimit() external view returns (uint256 value);

    /**
     * Returns the current volume percentage for swap events
     *
     * @return value uint256 - Volume percentage for swap events
     */
    function percentageVolumeSwap() external view returns (uint256 value);

    /**
     * Sets the volume percentage for swap events
     * If set to zero, swapping based on volume will be disabled and fee.swapOrLiquifyAmount is used.
     *
     * @param value uint256 - New volume percentage for swapping
     */
    function setPercentageVolumeSwap(uint256 value) external;

    /**
     * Returns the current volume percentage for liquify events
     *
     * @return value uint256 - Volume percentage for liquify events
     */
    function percentageVolumeLiquify() external view returns (uint256 value);

    /**
     * Sets the volume percentage for liquify events
     * If set to zero, adding liquidity based on volume will be disabled and fee.swapOrLiquifyAmount is used.
     *
     * @param value uint256 - New volume percentage for adding liquidity
     */
    function setPercentageVolumeLiquify(uint256 value) external;

    /**
     * Returns the Pancakeswap pair address (LAMA <-> BUSD)
     *
     * @return value address - Pair address
     */
    function pancakePairBusdAddress() external view returns (address value);

    /**
     * Sets the Pancakeswap pair address (LAMA <-> BUSD)
     *
     * @param value address - New pair address
     */
    function setPancakePairBusdAddress(address value) external;

    /**
     * Returns the Pancakeswap pair address (LAMA <-> BNB)
     *
     * @return value address - Pair address
     */
    function pancakePairBnbAddress() external view returns (address value);

    /**
     * Sets the Pancakeswap pair address (LAMA <-> BNB)
     *
     * @param value address - New pair address
     */
    function setPancakePairBnbAddress(address value) external;

    /**
     * Returns the WeSendit token instance
     *
     * @return value IERC20 - Lama Token instance
     */
    function token() external view returns (IERC20 value);
}

// SPDX-License-Identifier: GPL-3.0
/**
 * Developed By Snake M
 */
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IFeeManager.sol";

interface ILamaToken {
    /**
     * Emitted on dynamic fee manager update
     *
     * @param newAddress address - New dynamic fee manager address
     */
    event FeeManagerUpdated(address newAddress);

    /**
     * Unpause Trading
     */
    function unpause() external;

    /**
     * Pause Trading
     */
    function pause() external;

    /**
     * Returns the dynamic fee manager
     *
     * @return value IDynamicFeeManager - Dynamic Fee Manager
     */
    function feeManager()
    external
    view
    returns (IFeeManager value);

    /**
     * Sets the fee manager
     * Can be set to zero address to disable fee reflection.
     *
     * @param value address - New dynamic fee manager address
     */
    function setFeeManager(address value) external;

    /**
     * Transfers token from <from> to <to> without applying fees
     *
     * @param from address - Sender address
     * @param to address - Receiver address
     * @param amount uin256 - Transaction amount
     */
    function transferFromNoFees(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: GPL-3.0
/**
 * Developed By Snake M
 */
pragma solidity 0.8.17;

interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
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
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}