/**
 *Submitted for verification at BscScan.com on 2022-06-21
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

/*
  Copyright (c) 2022 SmartToken
*/

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

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}

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

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}

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
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

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
     * bearer except when using {_setupRole}.
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
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
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
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
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
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
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
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

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
        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

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
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
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
}

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable {
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping (bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId
            || super.supportsInterface(interfaceId);
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
    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {grantRole} to track enumerable memberships
     */
    function grantRole(bytes32 role, address account) public virtual override {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {revokeRole} to track enumerable memberships
     */
    function revokeRole(bytes32 role, address account) public virtual override {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    /**
     * @dev Overload {renounceRole} to track enumerable memberships
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    /**
     * @dev Overload {_setupRole} to track enumerable memberships
     */
    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
}

// 100 * 10 * 1000000000 / 100000000000000000
// 1 * 1 * 1 / 100000
// 1 / 100000

library Percentages {
  uint256 private constant PERCENTAGE_UNITS = 1e18;
  uint256 private constant PERCENTAGE_DIVISOR = (PERCENTAGE_UNITS * 100000);

  function getRate(uint256 a, uint256 b) internal pure returns(uint256) {
    if(b == 0) {
      return 0;
    }

    return (a * PERCENTAGE_UNITS) / b;
  }

  function fromRate(uint256 number, uint256 rate) internal pure returns(uint256) {
    return (number * rate) / PERCENTAGE_UNITS;
  }

  function fraction(uint256 number, uint256 perc) internal pure returns(uint256) {
    require(perc <= 100_000, 'INVALID_PERCENTAGE'); // we do not want fractions above 100%
    return (number * perc * PERCENTAGE_UNITS) / PERCENTAGE_DIVISOR;
  }
}

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
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
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

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

interface IERC20Base is IERC20Metadata {
  event LiquidityModuleToggled(bool enabled);
  event SetAutomatedMarketMakerPair(address pairAddress, bool isAMM);

  event AddLiquidity(uint256 amountInTokens, uint256 amountInWETH);

  function getTransactionFees(address sender, address recipient)
    external
    view
    returns(
      bytes32 feeType,
      uint256 totalFee,
      uint256 liquidityFee,
      uint256 marketingFee
    );

  function getCollectedFees()
    external
    view
    returns(
      uint256 totalFee,
      uint256 liquidityFee,
      uint256 marketingFee
    );

  /* -===== MUTATIVE FUNCTIONS ------ */

  function changeFees(
    bytes32 txType,
    uint256 liquidityFee,
    uint256 marketingFee
  ) external;

  function toggleLiquidityModule(bool _enabled)
    external;

  function setTokenReserveThreshold(uint256 _liquidityThresholdPercentage)
    external;
}

interface IPancakeRouter01 {
    function factory() external view returns (address);
    function WETH() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

library ERC20BaseStorage {
  bytes32 private constant MODULE_STORAGE_POSITION = keccak256('erc20.base.storage');

  struct User {
    uint256 balance;
    mapping(address => uint256) allowances;
  }

  struct Fee {
    uint256 totalFee;
    uint256 marketingFee;
    uint256 liquidityFee;
  }

  struct Storage {
    string name;
    string symbol;

    uint8 decimals;
    uint256 totalSupply;

    mapping(address => User) users;
    mapping(address => bool) automatedMarketMakerPairs;

    mapping(bytes32 => Fee) fees;
    Fee collectedFees;

    address marketingWallet;
    address liquidityWallet;

    IPancakeRouter02 pancakeswapV2Router;
    address pancakeswapV2Pair;

    IERC20 basePair;

    uint256 contractRedeemableETH;
    uint256 contractRedeemableBasePair;

    bool inSwapAndLiquify;
    bool liquidityModuleEnabled;
    uint256 tokenReserveThreshold;

    address escrower;
  }

  function initializeDefaults() internal {
    Storage storage st = getStorage();

    st.decimals = 9;
    st.liquidityModuleEnabled = true;
  }

  function getStorage() internal pure returns(Storage storage st) {
    bytes32 position = MODULE_STORAGE_POSITION;

    assembly {
      st.slot := position
    }
  }
}

library SmartTokenStorage {
  bytes32 private constant MODULE_STORAGE_POSITION = keccak256('smartToken.storage');

  struct Storage {
    bool initialized;
    bool tradingEnabled;
    bool initialLiquidityAdded;

    bool maxBalanceEnabled;
    uint256 maxBalanceAmount;
    uint256 maxTransactionAmount;

    bool sniperProtectionModuleEnabled;
    uint256 snipeBlockAmount;
    uint256 initialLiquidityBlockNumber;
  }

  function initializeDefaults() internal {
    Storage storage st = getStorage();

    st.initialized = true;
    st.tradingEnabled = false;
    st.initialLiquidityAdded = false;

    st.sniperProtectionModuleEnabled = true;
    st.snipeBlockAmount = 3;
    st.initialLiquidityBlockNumber = 0;
  }

  function getStorage() internal pure returns(Storage storage st) {
    bytes32 position = MODULE_STORAGE_POSITION;

    assembly {
      st.slot := position
    }
  }
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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Escrower is Ownable {
  function approve(IERC20 _token, uint256 _amount) external onlyOwner {
    _token.approve(msg.sender, _amount);
  }
}

library UserFeaturesStorage {
  bytes32 private constant MODULE_STORAGE_POSITION = keccak256('user.features.storage');

  struct Storage {
    mapping(address => mapping(bytes32 => bool)) userFeatures;
  }

  function getStorage() internal pure returns(Storage storage st) {
    bytes32 position = MODULE_STORAGE_POSITION;

    assembly {
      st.slot := position
    }
  }
}

interface IUserFeatures {
  function isExcludedFrom(bytes32 feature, address account)
    external
    view
    returns(bool);

  /* -===== MUTATIVE FUNCTIONS ------ */

  function setupUserInclusions(address account, bytes32[] calldata)
    external;

  function setupUserExclusions(address account, bytes32[] calldata)
    external;
}

abstract contract UserFeatures is
  /* -=== IMMUTABLE ===- */
  /* -=== DO NOT CHANGE ORDER ===- */
  /* -=== IT WILL BREAK STORAGE ===- */

  IUserFeatures,

  /* -=== IMMUTABLE ===- */
  /* -=== DO NOT CHANGE ORDER ===- */
  /* -=== IT WILL BREAK STORAGE ===- */

  AccessControlEnumerable
{
  bytes32 internal constant FEATURE_FEE = keccak256('FEATURE_FEE');
  bytes32 internal constant FEATURE_MAXTX = keccak256('FEATURE_MAXTX');
  bytes32 internal constant FEATURE_MAXBALANCE = keccak256('FEATURE_MAXBALANCE');
  bytes32 internal constant FEATURE_DIVIDENDS = keccak256('FEATURE_DIVIDENDS');

  function isExcludedFrom(bytes32 feature, address account)
    public
    view
    override
    returns(bool)
  {
    return UserFeaturesStorage.getStorage().userFeatures[account][feature];
  }

  /* -===== MUTATIVE FUNCTIONS ------ */

  function setupUserInclusions(address account, bytes32[] memory items)
    public
    override
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    _setupUserFeatures(account, items, false);
  }

  function setupUserExclusions(address account, bytes32[] memory items)
    public
    override
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    _setupUserFeatures(account, items, true);
  }

  function _setupUserFeatures(address account, bytes32[] memory items, bool excluded) private {
    for(uint256 i = 0; i < items.length; i += 1) {
      UserFeaturesStorage.getStorage().userFeatures[account][items[i]] = excluded;
    }
  }
}

abstract contract ERC20Base is
  /* -=== IMMUTABLE ===- */
  /* -=== DO NOT CHANGE ORDER ===- */
  /* -=== IT WILL BREAK STORAGE ===- */

  IERC20Base,

  /* -=== IMMUTABLE ===- */
  /* -=== DO NOT CHANGE ORDER ===- */
  /* -=== IT WILL BREAK STORAGE ===- */

  AccessControlEnumerable,
  UserFeatures
{
  using Percentages for uint256;
  using SafeERC20 for IERC20;

  struct FeeProcessingQueue {
    uint256 totalAmount;

    uint256 marketingRate;
    uint256 marketingSwapAmount;

    uint256 liquidityRate;
    uint256 liquiditySwapAmount;
    uint256 liquidityAddAmount;
  }

  bytes32 internal constant LIQUIFY_BYPASSER_ROLE = keccak256('LIQUIFY_BYPASSER_ROLE');

  bytes32 internal constant TX_BUY = keccak256('TX_BUY');
  bytes32 internal constant TX_SELL = keccak256('TX_SELL');
  bytes32 internal constant TX_TRANSFER = keccak256('TX_TRANSFER');
  bytes32 internal constant TX_FREE = keccak256('TX_FREE');

  constructor(
    string memory _name,
    string memory _symbol,

    uint256 _supply,
    uint256 _liquidityThresholdPercentage,
    address _v2RouterAddress,
    address _basePairAddress
  ) {
    ERC20BaseStorage.initializeDefaults();
    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();

    erc20.name = _name;
    erc20.symbol = _symbol;
    erc20.decimals = 18;
    erc20.totalSupply = _supply * (10**uint256(erc20.decimals));
    erc20.tokenReserveThreshold = erc20.totalSupply.fraction(_liquidityThresholdPercentage);

    _setupPancakeswap(_v2RouterAddress, _basePairAddress);

    erc20.escrower = address(new Escrower());

    erc20.users[msg.sender].balance = erc20.totalSupply;
    emit Transfer(address(0), msg.sender, erc20.totalSupply);
  }

  function _setupPancakeswap(address _routerAddress, address _basePairAddress) private {
    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();

    erc20.pancakeswapV2Router = IPancakeRouter02(_routerAddress);

    // create a pancakeswap pair for this new token
    erc20.pancakeswapV2Pair = IPancakeFactory(erc20.pancakeswapV2Router.factory())
      .createPair(address(this), _basePairAddress);

    erc20.basePair = IERC20(_basePairAddress);

    _setAutomatedMarketMakerPair(erc20.pancakeswapV2Pair, true);
  }

  function name() public view override returns(string memory) {
    return ERC20BaseStorage.getStorage().name;
  }

  function symbol() public view override returns(string memory) {
    return ERC20BaseStorage.getStorage().symbol;
  }

  function decimals() public view override returns(uint8) {
    return ERC20BaseStorage.getStorage().decimals;
  }

  function totalSupply() public view override returns(uint256) {
    return ERC20BaseStorage.getStorage().totalSupply;
  }

  function balanceOf(address account) public view override returns(uint256) {
    return ERC20BaseStorage.getStorage().users[account].balance;
  }

  function allowance(address owner, address spender) public view override returns(uint256) {
    return ERC20BaseStorage.getStorage().users[owner].allowances[spender];
  }

  function getTransactionFees(address sender, address recipient)
    public
    view
    override
    returns(
      bytes32 feeType,
      uint256 totalFee,
      uint256 liquidityFee,
      uint256 marketingFee
    )
  {
    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();

    feeType = TX_FREE;

    if(
      !isExcludedFrom(UserFeatures.FEATURE_FEE, sender)
        && !isExcludedFrom(UserFeatures.FEATURE_FEE, recipient)
    ) {
      if(erc20.automatedMarketMakerPairs[sender]) {
        feeType = TX_BUY;
      } else if(erc20.automatedMarketMakerPairs[recipient]) {
        feeType = TX_SELL;
      } else {
        feeType = TX_TRANSFER;
      }
    }

    return (
      feeType,
      erc20.fees[feeType].totalFee,
      erc20.fees[feeType].liquidityFee,
      erc20.fees[feeType].marketingFee
    );
  }

  function getCollectedFees() external view override returns(
    uint256 totalFee,
    uint256 liquidityFee,
    uint256 marketingFee
  ) {
    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();
    ERC20BaseStorage.Fee storage collectedFees = erc20.collectedFees;

    return (
      collectedFees.totalFee,
      collectedFees.liquidityFee,
      collectedFees.marketingFee
    );
  }

  /* -===== MUTATIVE FUNCTIONS ------ */

  function approve(address spender, uint256 amount) public override returns(bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function transfer(address recipient, uint256 amount) public override returns(bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount)
    public
    override
    returns(bool)
  {
    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();

    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, erc20.users[sender].allowances[msg.sender] - amount);

    return true;
  }

  function changeFees(
    bytes32 txType,
    uint256 liquidityFee,
    uint256 marketingFee
  )
    public
    override
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    if(txType == TX_BUY) {
      require(liquidityFee <= 5000);
      require(marketingFee <= 5000);
    }

    if(txType == TX_SELL) {
      require(liquidityFee <= 10000);
      require(marketingFee <= 10000);
    }

    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();

    erc20.fees[txType].liquidityFee = liquidityFee;
    erc20.fees[txType].marketingFee = marketingFee;

    erc20.fees[txType].totalFee = (liquidityFee + marketingFee);
  }

  function toggleLiquidityModule(bool _enabled)
    external
    override
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();

    erc20.liquidityModuleEnabled = _enabled;
    emit LiquidityModuleToggled(_enabled);
  }

  function setTokenReserveThreshold(uint256 _liquidityThresholdPercentage)
    external
    override
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();
    erc20.tokenReserveThreshold = erc20.totalSupply.fraction(_liquidityThresholdPercentage);
  }

  function _setAutomatedMarketMakerPair(address pairAddress, bool isAMM) internal {
    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();

    if(!isAMM) {
      require(pairAddress != erc20.pancakeswapV2Pair, 'PANCAKESWAP_PAIR');
    }

    erc20.automatedMarketMakerPairs[pairAddress] = isAMM;
    emit SetAutomatedMarketMakerPair(pairAddress, isAMM);
  }

  function _approve(address owner, address spender, uint256 amount) private {
    require(owner != address(0), 'FROM_ZERO_ADDRESS');
    require(spender != address(0), 'TO_ZERO_ADDRESS');

    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();
    erc20.users[owner].allowances[spender] = amount;

    emit Approval(owner, spender, amount);
  }

  function _transfer(address sender, address recipient, uint256 amount) private {
    require(sender != address(0), 'FROM_ZERO_ADDRESS');
    require(recipient != address(0), 'TO_ZERO_ADDRESS');
    require(amount > 0, 'ZERO_AMOUNT');

    _processFees(sender);
    _beforeTokenTransfer(sender, recipient, amount);

    (,
      uint256 totalFee,
      uint256 marketingFee,
      uint256 liquidityFee
    ) = getTransactionFees(sender, recipient);

    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();
    ERC20BaseStorage.Fee storage collectedFees = erc20.collectedFees;
    ERC20BaseStorage.User storage ownContract = erc20.users[address(this)];

    uint256 txnCollectedFees;

    if(totalFee > 0) {
      if(marketingFee > 0) {
        uint256 txnMarketingFee = amount.fraction(marketingFee);

        collectedFees.marketingFee += txnMarketingFee;
        collectedFees.totalFee += txnMarketingFee;
        txnCollectedFees += txnMarketingFee;
      }

      if(liquidityFee > 0) {
        uint256 txnLiquidityFee = amount.fraction(liquidityFee);

        collectedFees.liquidityFee += txnLiquidityFee;
        collectedFees.totalFee += txnLiquidityFee;
        txnCollectedFees += txnLiquidityFee;
      }

      ownContract.balance += txnCollectedFees;
      emit Transfer(sender, address(this), txnCollectedFees);
    }

    uint256 taxedAmount = amount - txnCollectedFees;

    erc20.users[sender].balance -= amount;
    erc20.users[recipient].balance += taxedAmount;

    emit Transfer(sender, recipient, taxedAmount);

    _afterTokenTransfer(sender, recipient, amount, taxedAmount);
  }

  function _processLiquidity(uint256 amountInTokens, uint256 amountInBasePair) private {
    if(amountInTokens == 0 || amountInBasePair == 0) {
      return;
    }

    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();

    // approve token transfer
    _approve(address(this), address(erc20.pancakeswapV2Router), amountInTokens);
    erc20.basePair.approve(address(erc20.pancakeswapV2Router), amountInBasePair);

    // add the liquidity
    erc20.pancakeswapV2Router.addLiquidity(
      address(this),
      address(erc20.basePair),
      amountInTokens,
      amountInBasePair,
      0, // slippage is unavoidable
      0, // slippage is unavoidable
      erc20.liquidityWallet,
      block.timestamp
    );

    emit AddLiquidity(amountInTokens, amountInBasePair);
  }

  function _processMarketingFee(uint256 amountInBasePair) private {
    if(amountInBasePair == 0) {
      return;
    }

    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();
    erc20.basePair.safeTransfer(erc20.marketingWallet, amountInBasePair);
  }

  function _processFees(address sender) private {
    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();
    SmartTokenStorage.Storage storage smartToken = SmartTokenStorage.getStorage();

    uint256 pendingFees = Math.min(
      erc20.collectedFees.totalFee,
      smartToken.maxTransactionAmount
    );

    if(
      (pendingFees >= erc20.tokenReserveThreshold)
        && !erc20.inSwapAndLiquify
        && sender != erc20.pancakeswapV2Pair
        && erc20.liquidityModuleEnabled
        && !hasRole(LIQUIFY_BYPASSER_ROLE, sender)
    ) {
      erc20.inSwapAndLiquify = true;

      FeeProcessingQueue memory allSwaps;

      {
        allSwaps.marketingRate = erc20
          .collectedFees
          .marketingFee
          .getRate(erc20.collectedFees.totalFee);

        allSwaps.marketingSwapAmount = pendingFees
          .fromRate(allSwaps.marketingRate);

        erc20.collectedFees.marketingFee -= allSwaps.marketingSwapAmount;
      }

      {
        allSwaps.liquidityRate = erc20
          .collectedFees
          .liquidityFee
          .getRate(erc20.collectedFees.totalFee);

        allSwaps.liquiditySwapAmount = pendingFees
          .fromRate(allSwaps.liquidityRate);

        allSwaps.liquidityAddAmount = allSwaps.liquiditySwapAmount / 2;
        allSwaps.liquiditySwapAmount -= allSwaps.liquidityAddAmount;

        erc20.collectedFees.liquidityFee -= (allSwaps.liquidityAddAmount + allSwaps.liquiditySwapAmount);
      }

      uint256 amountToSwap = allSwaps.marketingSwapAmount
        + allSwaps.liquiditySwapAmount;

      erc20.collectedFees.totalFee -= allSwaps.liquidityAddAmount
        + allSwaps.liquiditySwapAmount
        + allSwaps.marketingSwapAmount;

      if(amountToSwap > 0) {
        uint256 deltaBasePair = _swapTokensReturningDelta(
          address(this),
          address(erc20.basePair),
          amountToSwap
        );

        _processLiquidity(
          allSwaps.liquidityAddAmount,
          deltaBasePair - deltaBasePair.fromRate(allSwaps.marketingRate)
        );

        _processMarketingFee(deltaBasePair.fromRate(allSwaps.marketingRate));
      }

      // dust after executing all swaps
      erc20.contractRedeemableETH = address(this).balance;
      erc20.inSwapAndLiquify = false;
    }
  }

  function _swapTokensReturningDelta(
    address inputTokenAddress,
    address outputTokenAddress,
    uint256 amountInTokens
  ) private returns(uint256) {
    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();

    address[] memory path = new address[](2);
    path[0] = inputTokenAddress;
    path[1] = outputTokenAddress;

    IERC20(inputTokenAddress)
      .approve(address(erc20.pancakeswapV2Router), amountInTokens);

    IERC20 outputToken = IERC20(outputTokenAddress);

    uint256 initialBalance = outputToken.balanceOf(address(this));

    // make the swap
    erc20.pancakeswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
      amountInTokens,
      0, // slippage 100%
      path,
      erc20.escrower,
      block.timestamp
    );

    uint256 tradedAmount = outputToken.balanceOf(erc20.escrower);

    Escrower(erc20.escrower).approve(outputToken, tradedAmount);

    outputToken.safeTransferFrom(
      erc20.escrower,
      address(this),
      tradedAmount
    );

    return outputToken.balanceOf(address(this)) - initialBalance;
  }

  function _beforeTokenTransfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual {}

  function _afterTokenTransfer(
    address sender,
    address recipient,
    uint256 sentAmount,
    uint256 receivedAmount
  ) internal virtual {}
}

interface ISmartToken {
  event SwapAndLiquifyModuleToggle(bool enabled);

  function isSniper(address account) external view returns(bool);

  /* -===== MUTATIVE FUNCTIONS ------ */

  function removeSniper(address account)
    external;

  function toggleSniperProtectionModule(bool enabled)
    external;

  function enableTrading()
    external;

  function setMaxTransactionPercentage(uint256 maxTransactionPercentage)
    external;

  function setMaxBalancePercentage(uint256 maxBalancePercentage)
    external;

  function toggleSwapAndLiquifyModule(bool enabled)
    external;

  function setAutomatedMarketMakerPair(address pairAddress, bool isAMM)
    external;

  function setMarketingWallet(address newWallet)
    external;

  function setLiquidityWallet(address newWallet)
    external;

  function redeemLockedETH(address recipient)
    external;

  // withdraw any tokens that are not supposed to be inside this contract.
  function redeemLockedTokens(address _recipient, address _token)
    external;
}

contract SmartToken is
  ISmartToken,
  AccessControlEnumerable,
  ReentrancyGuard,
  UserFeatures,
  ERC20Base
{
  using Percentages for uint256;
  using SafeERC20 for IERC20;

  bytes32 internal constant SNIPER_ROLE = keccak256('SNIPER_ROLE');
  bytes32 internal constant LIQUIDITY_MANAGER_ROLE = keccak256('LIQUIDITY_MANAGER_ROLE');

  constructor(
    string memory _name,
    string memory _symbol,

    uint256 _supply,
    uint256 _maxTxnPercentage,
    uint256 _maxBalancePercentage,
    uint256 _liquidityThresholdPercentage,

    uint256[2] memory _buyFees,
    uint256[2] memory _sellFees,

    address[3] memory _addresses,

    address _v2Router
  ) ERC20Base(
    _name,
    _symbol,
    _supply,
    _liquidityThresholdPercentage,
    _v2Router,
    _addresses[0]
  ) {
    SmartTokenStorage.initializeDefaults();
    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();

    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(LIQUIDITY_MANAGER_ROLE, msg.sender);

    erc20.marketingWallet = _addresses[1];
    erc20.liquidityWallet = _addresses[2];

    _setupExclusions();

    changeFees(ERC20Base.TX_BUY, _buyFees[0], _buyFees[1]);
    changeFees(ERC20Base.TX_SELL, _sellFees[0], _sellFees[1]);

    setMaxTransactionPercentage(_maxTxnPercentage);
    setMaxBalancePercentage(_maxBalancePercentage);
  }

  function isSniper(address account) public view override returns(bool) {
    return hasRole(SNIPER_ROLE, account);
  }

  /* -===== MUTATIVE FUNCTIONS ------ */

  function removeSniper(address account)
    external
    override
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    revokeRole(SNIPER_ROLE, account);
  }

  function toggleSniperProtectionModule(bool enabled)
    external
    override
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    SmartTokenStorage.getStorage().sniperProtectionModuleEnabled = enabled;
  }

  function enableTrading()
    external
    override
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    SmartTokenStorage.getStorage().tradingEnabled = true;
  }

  function setMaxTransactionPercentage(uint256 maxTransactionPercentage)
    public
    override
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    require(maxTransactionPercentage >= 50); // minimum 0.05%

    SmartTokenStorage.Storage storage smartToken = SmartTokenStorage.getStorage();
    smartToken.maxTransactionAmount = totalSupply().fraction(maxTransactionPercentage);
  }

  function setMaxBalancePercentage(uint256 maxBalancePercentage)
    public
    override
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    require(maxBalancePercentage >= 50); // minimum 0.05%

    SmartTokenStorage.Storage storage smartToken = SmartTokenStorage.getStorage();
    smartToken.maxBalanceAmount = totalSupply().fraction(maxBalancePercentage);
  }

  function setSwapAndLiquifyEnabled(bool _enabled) external {
    toggleSwapAndLiquifyModule(_enabled);
  }

  function toggleSwapAndLiquifyModule(bool enabled)
    public
    override
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    ERC20BaseStorage.getStorage().liquidityModuleEnabled = enabled;
    emit SwapAndLiquifyModuleToggle(enabled);
  }

  function setAutomatedMarketMakerPair(address pairAddress, bool isAMM)
    external
    override
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    _setAutomatedMarketMakerPair(pairAddress, isAMM);
  }

  function setMarketingWallet(address newWallet)
    external
    override
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();
    erc20.marketingWallet = newWallet;
  }

  function setLiquidityWallet(address newWallet)
    external
    override
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();
    erc20.liquidityWallet = newWallet;
  }

  function redeemLockedETH(address recipient)
    external
    override
    nonReentrant
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();

    require(recipient != address(0), 'ZERO_ADDRESS');
    require(erc20.contractRedeemableETH > 0 || erc20.contractRedeemableBasePair > 0, 'ZERO_BALANCE');

    uint256 amountInETH = erc20.contractRedeemableETH;
    uint256 amountInBasePair = erc20.contractRedeemableBasePair;

    erc20.contractRedeemableETH = 0;
    erc20.contractRedeemableBasePair = 0;

    if(amountInETH > 0) {
      (bool success,) = payable(recipient).call{value: amountInETH}('');

      if(!success) {
        revert();
      }
    }

    if(amountInBasePair > 0) {
      erc20.basePair.safeTransfer(recipient, amountInBasePair);
    }
  }

  // withdraw any tokens that are not supposed to be inside this contract.
  function redeemLockedTokens(address _recipient, address _token)
    external
    override
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    require(_token != address(this), 'REDEEM_OWN_TOKEN');

    IERC20 token = IERC20(_token);
    token.transfer(_recipient, token.balanceOf(address(this)));
  }

  function _setupExclusions() private {
    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();

    bytes32[] memory excludeAll = new bytes32[](4);

    excludeAll[0] = FEATURE_FEE;
    excludeAll[1] = FEATURE_MAXTX;
    excludeAll[2] = FEATURE_MAXBALANCE;

    setupUserExclusions(msg.sender, excludeAll);
    setupUserExclusions(address(this), excludeAll);
    setupUserExclusions(erc20.marketingWallet, excludeAll);
    setupUserExclusions(erc20.liquidityWallet, excludeAll);
    setupUserExclusions(erc20.escrower, excludeAll);

    bytes32[] memory excludeAMM = new bytes32[](2);

    excludeAMM[1] = FEATURE_MAXBALANCE;

    setupUserExclusions(erc20.pancakeswapV2Pair, excludeAMM);
  }

  function _ensureWalletLimit(address recipient, uint256 amount) private view {
    SmartTokenStorage.Storage storage smartToken = SmartTokenStorage.getStorage();

    if(smartToken.maxBalanceEnabled) {
      require(
        ((balanceOf(recipient) + amount) <= smartToken.maxBalanceAmount) || isExcludedFrom(FEATURE_MAXBALANCE, recipient),
        'MAX_WALLET_EXCEEDED'
      );
    }
  }

  function _ensureTransactionLimit(address sender, address recipient, uint256 amount) private view {
    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();
    SmartTokenStorage.Storage storage smartToken = SmartTokenStorage.getStorage();

    if(erc20.automatedMarketMakerPairs[sender]) {
      require(amount <= smartToken.maxTransactionAmount || isExcludedFrom(FEATURE_MAXTX, recipient), 'TX_LIMIT_EXCEEDED');
    } else {
      require(amount <= smartToken.maxTransactionAmount || isExcludedFrom(FEATURE_MAXTX, sender), 'TX_LIMIT_EXCEEDED');
    }
  }

  function _ensureSniperProtection(address sender, address recipient) private {
    if(isSniper(sender)) {
      revert('REJECTED_SNIPER');
    }

    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();
    SmartTokenStorage.Storage storage smartToken = SmartTokenStorage.getStorage();

    // are we adding initial liquidity?
    if(!smartToken.initialLiquidityAdded) {
      _checkTransactionForInitialLiquidity(sender, recipient);
    } else {
      if(
        smartToken.initialLiquidityBlockNumber > 0
          && sender == erc20.pancakeswapV2Pair
          && !hasRole(LIQUIDITY_MANAGER_ROLE, sender)
          && !hasRole(LIQUIDITY_MANAGER_ROLE, recipient)
      ) {
        if((block.number - smartToken.initialLiquidityBlockNumber) < smartToken.snipeBlockAmount) {
          _setupRole(SNIPER_ROLE, recipient);
        }
      }
    }
  }

  function _checkTransactionForInitialLiquidity(address sender, address recipient) private {
    ERC20BaseStorage.Storage storage erc20 = ERC20BaseStorage.getStorage();
    SmartTokenStorage.Storage storage smartToken = SmartTokenStorage.getStorage();

    require(!smartToken.initialLiquidityAdded, 'INITIAL_LIQUIDITY_ALREADY_ADDED');

    if((recipient == erc20.pancakeswapV2Pair) && hasRole(LIQUIDITY_MANAGER_ROLE, sender)) {
      smartToken.initialLiquidityAdded = true;
      smartToken.initialLiquidityBlockNumber = block.number;
      smartToken.tradingEnabled = true;
    }
  }

  function _beforeTokenTransfer(address sender, address recipient, uint256 amount)
    internal
    virtual
    override(ERC20Base)
  {
    super._beforeTokenTransfer(sender, recipient, amount);

    SmartTokenStorage.Storage storage smartToken = SmartTokenStorage.getStorage();

    if(!isExcludedFrom(FEATURE_FEE, sender) && !isExcludedFrom(FEATURE_FEE, recipient)) {
      require(smartToken.tradingEnabled, 'TRADING_DISABLED');
    }

    _ensureWalletLimit(recipient, amount);
    _ensureTransactionLimit(sender, recipient, amount);

    if(smartToken.sniperProtectionModuleEnabled) {
      _ensureSniperProtection(sender, recipient);
    }
  }

  function _afterTokenTransfer(address sender, address recipient, uint256 sentAmount, uint256 receivedAmount)
    internal
    virtual
    override(ERC20Base)
  {
    super._afterTokenTransfer(sender, recipient, sentAmount, receivedAmount);
  }

  receive() external payable {}
}