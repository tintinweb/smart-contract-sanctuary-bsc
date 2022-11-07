/**
 *Submitted for verification at BscScan.com on 2022-11-06
*/

// Sources flattened with hardhat v2.4.3 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/[email protected]

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File @openzeppelin/contracts/utils/[email protected]


pragma solidity ^0.8.0;

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
        return msg.data;
    }
}


// File @openzeppelin/contracts/utils/[email protected]


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


// File @openzeppelin/contracts/utils/introspection/[email protected]


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


// File @openzeppelin/contracts/utils/introspection/[email protected]


pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/access/[email protected]


pragma solidity ^0.8.0;



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
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

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
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
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


// File @openzeppelin/contracts/utils/structs/[email protected]


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
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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


// File @openzeppelin/contracts/utils/math/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}


// File contracts/interfaces/IMediaEyeSubscriptionMediator.sol

pragma solidity ^0.8.0;

interface IMediaEyeSubscriptionMediator {
    function subscribeByMediator(address account, uint256 startTimestamp, uint256 endTimestamp, bool tier) external;
    function subscribeLevelOne(address account, uint256 startTimestamp, uint256 endTimestamp) external;
}


// File contracts/interfaces/IChainlinkPriceFeeds.sol

pragma solidity ^0.8.0;

interface IChainlinkPriceFeeds {

    function convertPrice(
        uint256 _baseAmount,
        uint256 _baseDecimals,
        uint256 _queryDecimals,
        bool _invertedAggregator,
        bool _convertToNative
    ) external view returns (uint256);
}


// File contracts/libraries/MediaEyeOrders.sol

pragma solidity ^0.8.0;

library MediaEyeOrders {
    enum NftTokenType {
        ERC1155,
        ERC721
    }

    enum SubscriptionTier {
        Unsubscribed,
        LevelOne,
        LevelTwo
    }

    struct SubscriptionSignature {
        bool isValid;
        UserSubscription userSubscription;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct UserSubscription {
        address userAddress;
        MediaEyeOrders.SubscriptionTier subscriptionTier;
        uint256 startTime;
        uint256 endTime;
    }

    struct Listing {
        uint256 listingId;
        Nft[] nfts;
        address payable seller;
        uint256 timestamp;
        Split split;
    }

    struct Chainlink {
        address tokenAddress;
        uint256 tokenDecimals;
        address nativeAddress;
        uint256 nativeDecimals;
        IChainlinkPriceFeeds priceFeed;
        bool invertedAggregator;
    }

    struct AuctionConstructor {
        address _owner;
        address[] _admins;
        address payable _treasuryWallet;
        uint256 _basisPointFee;
        address _feeContract;
        address _mediaEyeMarketplaceInfo;
        address _mediaEyeCharities;
        Chainlink _chainlink;
    }

    struct OfferConstructor {
        address _owner;
        address[] _admins;
        address payable _treasuryWallet;
        uint256 _basisPointFee;
        address _feeContract;
        address _mediaEyeMarketplaceInfo;
    }

    struct AuctionAdmin {
        address payable _newTreasuryWallet;
        address _newFeeContract;
        address _newCharityContract;
        MediaEyeOrders.Chainlink _chainlink;
        uint256 _basisPointFee;
        bool _check;
        address _newInfoContract;
    }

    struct OfferAdmin {
        address payable _newTreasuryWallet;
        address _newFeeContract;
        uint256 _basisPointFee;
        address _newInfoContract;
    }

    struct AuctionInput {
        MediaEyeOrders.Nft[] nfts;
        MediaEyeOrders.AuctionPayment[] auctionPayments;
        MediaEyeOrders.PaymentChainlink chainlinkPayment;
        uint8 setRoyalty;
        uint256 royalty;
        MediaEyeOrders.Split split;
        AuctionTime auctionTime;
        MediaEyeOrders.SubscriptionSignature subscriptionSignature;
        MediaEyeOrders.Feature feature;
        string data;
    }

    struct AuctionTime {
        uint256 startTime;
        uint256 endTime;
    }

    struct Auction {
        uint256 auctionId;
        Nft[] nfts;
        address seller;
        uint256 startTime;
        uint256 endTime;
        Split split;
    }

    struct Royalty {
        address payable artist;
        uint256 royaltyBasisPoint;
    }

    struct Split {
        address payable recipient;
        uint256 splitBasisPoint;
        address payable charity;
        uint256 charityBasisPoint;
    }

    struct ListingPayment {
        address paymentMethod;
        uint256 price;
    }

    struct PaymentChainlink {
        bool isValid;
        address quoteAddress;
    }

    struct Feature {
        bool feature;
        address paymentMethod;
        uint256 numDays;
        uint256 id;
        address[] tokenAddresses;
        uint256[] tokenIds;
        uint256 price;
    }

    struct AuctionPayment {
        address paymentMethod;
        uint256 initialPrice;
        uint256 buyItNowPrice;
    }

    struct AuctionSignature {
        uint256 auctionId;
        uint256 price;
        address bidder;
        address paymentMethod;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct OfferSignature {
        Nft nft;
        uint256 price;
        address offerer;
        address paymentMethod;
        uint256 expiry;
        address charityAddress;
        uint256 charityBasisPoint;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct Nft {
        NftTokenType nftTokenType;
        address nftTokenAddress;
        uint256 nftTokenId;
        uint256 nftNumTokens;
    }
}


// File @chainlink/contracts/src/v0.8/interfaces/[email protected]

pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}


// File contracts/MediaEyeFee.sol

pragma solidity ^0.8.0;







contract MediaEyeFee is AccessControl {
    using SafeCast for int256;
    using EnumerableSet for EnumerableSet.AddressSet;
    using MediaEyeOrders for MediaEyeOrders.SubscriptionTier;
    using MediaEyeOrders for MediaEyeOrders.UserSubscription;

    bytes32 internal immutable _DOMAIN_SEPARATOR;
    bytes32 internal SUBSCRIPTION_SIGNATURE_TYPEHASH =
        0x8f46388099841dd51e9fe2125176aa86d3a6c9d0a3a9a4988781ba98423514dd;
    // keccak256(
    //     "UserSubscription(address userAddress,uint8 subscriptionTier,uint256 startTime,uint256 endTime)"
    // );
    address public operator;
    AggregatorV3Interface internal priceFeed;

    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");
    bytes32 public constant ROLE_CALLER = keccak256("ROLE_CALLER");

    address public mediator;
    address payable public feeWallet;
    bool public ambCheck;

    struct Featured {
        uint256 startTime;
        uint256 numDays;
        uint256 featureType;
        address contractAddress;
        uint256 listingId;
        uint256 auctionId;
        uint256 id;
        address featuredBy;
        uint256 price;
    }

    TokenAmounts public baseUSDTokenAmounts;
    bool public invertedAggregator;

    struct TokenAmounts {
        uint256 uploadOneAmount;
        uint256 uploadTwoAmount;
        uint256 uploadThreeAmount;
        uint256 uploadFourAmount;
        uint256 featureAmountPerDay;
        uint256 subscribeOneAmount;
        uint256 subscribeTwoAmount;
        uint256 subscribeOne90Amount;
        uint256 subscribeTwo90Amount;
        bool chainlinkFeed;
        bool stableCoin;
        uint256 tokenDecimals;
    }

    EnumerableSet.AddressSet private paymentMethods;

    enum UploadTier {
        LevelOne,
        LevelTwo,
        LevelThree,
        LevelFour
    }

    enum SubscriptionDuration {
        Duration1,
        Duration2
    }

    // amount required for fees
    mapping(address => TokenAmounts) public paymentMethodAmounts;

    mapping(address => MediaEyeOrders.UserSubscription) public subscriptions;

    event UploadPaid(
        uint256 uploadId,
        UploadTier uploadTier,
        address userAddress,
        uint256 price
    );

    event FeaturePaid(
        address[] tokenAddresses,
        uint256[] tokenIds,
        Featured featured,
        uint256 startTime,
        uint256 endTime,
        address purchaser
    );

    event SubscriptionPaid(MediaEyeOrders.UserSubscription userSubscription);

    event SubscriptionByBridge(
        MediaEyeOrders.UserSubscription userSubscription
    );

    event SubscriptionByAdmin(MediaEyeOrders.UserSubscription userSubscription);

    event TokenAmountsChanged(address paymentMethod, TokenAmounts tokenAmounts);

    event PaymentAdded(address paymentMethod, TokenAmounts tokenAmounts);

    event PaymentRemoved(address paymentMethod);

    event FeeWalletChanged(address newFeeWallet);

    /********************** MODIFIERS ********************************/

    // only admin or owner
    modifier onlyAdmin() {
        require(
            (hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender)),
            "MediaEyeFee: Sender is not an admin."
        );
        _;
    }

    // only owner
    modifier onlyOwner() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "MediaEyeFee: Sender is not an owner."
        );
        _;
    }

    // only from mediator
    modifier onlyMediator() {
        require(
            msg.sender == mediator,
            "MediaEyeFee: GovernanceReceiverMediator::executeTransaction: Call must come from bridge."
        );
        _;
    }

    /**
     * @dev Stores and sets up the owners and admins, setting up feewallet, payment methods and payments. Stores initial feature details.
     *
     * Params:
     * _owner: the address of the owner
     * _admins: addresses of the admins
     * _operator: address of the subscription admin to verify signature
     * _feeWallet: address to withdraw fees to
     * _paymentMethods: initial payment methods to accept
     * _initialTokenAmounts: amounts for each fee for each payment method
     * _baseUSDTokenAmounts: price in usd for each category
     * _priceFeedAggregator: the address of the price feed aggregator
     * _invertedAggregator: whether the aggregator is inverted
     */
    constructor(
        bool _ambCheck,
        address _owner,
        address[] memory _admins,
        address _operator,
        address payable _feeWallet,
        address[] memory _paymentMethods,
        TokenAmounts[] memory _initialTokenAmounts,
        TokenAmounts memory _baseUSDTokenAmounts,
        address _priceFeedAggregator,
        bool _invertedAggregator
    ) {
        require(
            _initialTokenAmounts.length == _paymentMethods.length,
            "MediaEyeFee: There must be amounts for each payment method."
        );

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        _DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256("MediaEyeFee"),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );

        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        _setRoleAdmin(ROLE_CALLER, ROLE_ADMIN);

        for (uint256 i = 0; i < _admins.length; i++) {
            _setupRole(ROLE_ADMIN, _admins[i]);
        }

        feeWallet = _feeWallet;

        for (uint256 i = 0; i < _paymentMethods.length; i++) {
            paymentMethods.add(_paymentMethods[i]);
            paymentMethodAmounts[_paymentMethods[i]] = _initialTokenAmounts[i];
        }

        ambCheck = _ambCheck;

        baseUSDTokenAmounts = _baseUSDTokenAmounts;
        priceFeed = AggregatorV3Interface(_priceFeedAggregator);
        invertedAggregator = _invertedAggregator;
        operator = _operator;
    }

    /********************** Price Feed ********************************/

    function getRoundData() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();

        return price.toUint256();
    }

    function convertPrice(
        uint256 _baseAmount,
        uint256 _baseDecimals,
        uint256 _queryDecimals,
        bool _invertedAggregator,
        bool _convertToNative
    ) public view returns (uint256) {
        require(_baseDecimals > 0 && _baseDecimals <= 18, "Invalid _decimals");
        require(
            _queryDecimals > 0 && _queryDecimals <= 18,
            "Invalid _decimals"
        );

        uint256 roundData = getRoundData();
        uint256 roundDataDecimals = priceFeed.decimals();
        uint256 query = 0;

        if (_convertToNative) {
            if (_invertedAggregator) {
                query = (_baseAmount * roundData) / (10**roundDataDecimals);
            } else {
                query = (_baseAmount * (10**roundDataDecimals)) / roundData;
            }
        } else {
            if (_invertedAggregator) {
                query = (_baseAmount * (10**roundDataDecimals)) / roundData;
            } else {
                query = (_baseAmount * roundData) / (10**roundDataDecimals);
            }
        }

        if (_baseDecimals > _queryDecimals) {
            uint256 decimals = _baseDecimals - _queryDecimals;
            query = query / (10**decimals);
        } else if (_baseDecimals < _queryDecimals) {
            uint256 decimals = _queryDecimals - _baseDecimals;
            query = query * (10**decimals);
        }
        return query;
    }

    /********************** Get methods ********************************/

    // Get number of payment methods accepted
    function getNumPaymentMethods() external view returns (uint256) {
        return paymentMethods.length();
    }

    // Get user subscription
    function getUserSubscription(address _account)
        external
        view
        returns (MediaEyeOrders.UserSubscription memory)
    {
        return subscriptions[_account];
    }

    // Returns true if is accepted payment method
    function isPaymentMethod(address _paymentMethod)
        external
        view
        returns (bool)
    {
        return paymentMethods.contains(_paymentMethod);
    }

    /********************** Owner update methods ********************************/

    /**
     * @dev Update fee wallet
     *
     * Params:
     * _newFeeWallet: new fee wallet
     */
    function updateFeeWallet(address payable _newFeeWallet) external onlyOwner {
        feeWallet = _newFeeWallet;
        emit FeeWalletChanged(_newFeeWallet);
    }

    /********************** Admin update methods ********************************/

    /**
     * @dev Update mediator address
     *
     * Params:
     * _mediator: new mediator address
     */
    function setMediator(address _mediator) external onlyAdmin {
        mediator = _mediator;
    }

    /**
     * @dev Update subscription typehash
     *
     * Params:
     * _typeHash: new typehash
     */
    function setSubscriptionHash(bytes32 _typeHash) external onlyAdmin {
        SUBSCRIPTION_SIGNATURE_TYPEHASH = _typeHash;
    }

    /**
     * @dev Update price feed aggregator address
     *
     * Params:
     * _aggregator: new aggregator address
     * _inverted: whether the aggregator is inverted
     */
    function setPriceFeedAggregator(address _aggregator, bool _inverted)
        external
        onlyAdmin
    {
        priceFeed = AggregatorV3Interface(_aggregator);
        invertedAggregator = _inverted;
    }

    /**
     * @dev Update mediator address
     *
     * Params:
     * _baseUSDTokenAmounts: price in usd for each category
     */
    function setBaseUSDTokenAmounts(TokenAmounts memory _baseUSDTokenAmounts)
        external
        onlyAdmin
    {
        baseUSDTokenAmounts = _baseUSDTokenAmounts;
    }

    /**
     * @dev Update subscriptionadmin address
     *
     * Params:
     * _address: new subscriptionadmin address
     */
    function setOperatorAddress(address _address) external onlyAdmin {
        operator = _address;
    }

    /**
     * @dev Add single payment method
     *
     * Params:
     * _newTokenAmount: new token amounts for single payment method
     * _paymentMethod: the payment method to add
     */
    function addPaymentMethod(
        TokenAmounts memory _newTokenAmount,
        address _paymentMethod
    ) external onlyAdmin {
        require(
            !paymentMethods.contains(_paymentMethod),
            "MediaEyeFee: Payment method is already accepted."
        );
        paymentMethods.add(_paymentMethod);
        paymentMethodAmounts[_paymentMethod] = _newTokenAmount;
        emit PaymentAdded(_paymentMethod, _newTokenAmount);
    }

    /**
     * @dev Removes single payment method
     *
     * Params:
     * _paymentMethod: the payment method to remove
     */
    function removePaymentMethod(address _paymentMethod) external onlyAdmin {
        require(
            paymentMethods.contains(_paymentMethod),
            "MediaEyeFee: Payment method does not exist."
        );
        paymentMethods.remove(_paymentMethod);
        delete paymentMethodAmounts[_paymentMethod];
        emit PaymentRemoved(_paymentMethod);
    }

    /**
     * @dev Update Price Amounts for single payment method
     *
     * Params:
     * _newTokenAmount: new token amounts for single payment method
     * _paymentMethod: the payment method to change amountf or
     */
    function updateSingleTokenAmount(
        TokenAmounts memory _newTokenAmount,
        address _paymentMethod
    ) external onlyAdmin {
        require(
            paymentMethods.contains(_paymentMethod),
            "MediaEyeFee: Payment method does not exist."
        );
        paymentMethodAmounts[_paymentMethod] = _newTokenAmount;
        emit TokenAmountsChanged(_paymentMethod, _newTokenAmount);
    }

    /**
     * @dev Update Price Amounts for multiple payment method
     *
     * Params:
     * _newTokenAmounts: new token amounts for multiple payment method
     * _paymentMethods: order of the tokenAmounts to set
     */
    function updateMultipleTokenAmounts(
        TokenAmounts[] memory _newTokenAmounts,
        address[] memory _paymentMethods
    ) external onlyAdmin {
        require(
            _newTokenAmounts.length == _paymentMethods.length,
            "MediaEyeFee: There must be amounts for each payment method"
        );
        for (uint256 i = 0; i < _paymentMethods.length; i++) {
            require(
                paymentMethods.contains(_paymentMethods[i]),
                "MediaEyeFee: One of the payment method does not exist."
            );
            paymentMethodAmounts[_paymentMethods[i]] = _newTokenAmounts[i];
            emit TokenAmountsChanged(_paymentMethods[i], _newTokenAmounts[i]);
        }
    }

    function subscribeByAdmin(
        address account,
        uint256 startTimestamp,
        uint256 endTimestamp,
        uint256 tier
    ) external onlyAdmin {
        MediaEyeOrders.UserSubscription
            storage newUserSubscription = subscriptions[account];
        newUserSubscription.userAddress = account;
        if (tier == 0) {
            newUserSubscription.subscriptionTier = MediaEyeOrders
                .SubscriptionTier
                .LevelOne;
        } else {
            newUserSubscription.subscriptionTier = MediaEyeOrders
                .SubscriptionTier
                .LevelTwo;
        }
        newUserSubscription.startTime = startTimestamp;
        newUserSubscription.endTime = endTimestamp;

        emit SubscriptionByAdmin(newUserSubscription);
    }

    /**
     * @dev Update amb bool
     *
     * Params:
     * _ambBool: boolean to set amb
     */
    function setAmb(bool _ambBool) external onlyAdmin {
        ambCheck = _ambBool;
    }

    /********************** Check Subscription ********************************/
    function checkUserSubscription(address _user)
        external
        view
        returns (uint256)
    {
        MediaEyeOrders.UserSubscription memory userSubscription = subscriptions[
            _user
        ];
        if (
            userSubscription.subscriptionTier ==
            MediaEyeOrders.SubscriptionTier.LevelOne &&
            userSubscription.endTime > block.timestamp &&
            userSubscription.startTime < block.timestamp
        ) {
            return 1;
        } else if (
            userSubscription.subscriptionTier ==
            MediaEyeOrders.SubscriptionTier.LevelTwo &&
            userSubscription.endTime > block.timestamp &&
            userSubscription.startTime < block.timestamp
        ) {
            return 2;
        } else {
            return 0;
        }
    }

    function checkUserSubscriptionBySig(
        MediaEyeOrders.UserSubscription memory _userSubscription,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (uint256) {
        // verify signature
        bytes32 structHash = keccak256(
            abi.encode(
                SUBSCRIPTION_SIGNATURE_TYPEHASH,
                _userSubscription.userAddress,
                _userSubscription.subscriptionTier,
                _userSubscription.startTime,
                _userSubscription.endTime
            )
        );
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), structHash)
        );
        if (ecrecover(digest, v, r, s) != operator) {
            return 0;
        }
        if (
            _userSubscription.subscriptionTier ==
            MediaEyeOrders.SubscriptionTier.LevelOne &&
            _userSubscription.endTime > block.timestamp &&
            _userSubscription.startTime < block.timestamp
        ) {
            return 1;
        } else if (
            _userSubscription.subscriptionTier ==
            MediaEyeOrders.SubscriptionTier.LevelTwo &&
            _userSubscription.endTime > block.timestamp &&
            _userSubscription.startTime < block.timestamp
        ) {
            return 2;
        } else {
            return 0;
        }
    }

    /********************** PAY ********************************/

    /**
     * @dev user pays upload fees
     *
     * Params:
     * _paymentMethod: type of payment Method
     * _uploadTier: tier of the uploaded content, based on size, 20/50/100/200 mb
     * _uploadId: id of upload
     */
    function payUploadFee(
        address _paymentMethod,
        UploadTier _uploadTier,
        uint256 _uploadId
    ) external payable {
        require(
            paymentMethods.contains(_paymentMethod),
            "MediaEyeFee: Payment method does not exist."
        );
        uint256 price = 0;
        TokenAmounts memory tokenAmount = paymentMethodAmounts[_paymentMethod];
        if (tokenAmount.chainlinkFeed && _paymentMethod == address(0)) {
            if (_uploadTier == UploadTier.LevelOne) {
                price = baseUSDTokenAmounts.uploadOneAmount;
            } else if (_uploadTier == UploadTier.LevelTwo) {
                price = baseUSDTokenAmounts.uploadTwoAmount;
            } else if (_uploadTier == UploadTier.LevelThree) {
                price = baseUSDTokenAmounts.uploadThreeAmount;
            } else if (_uploadTier == UploadTier.LevelFour) {
                price = baseUSDTokenAmounts.uploadFourAmount;
            }
            // get price from chainlink feed
            price = convertPrice(
                price,
                baseUSDTokenAmounts.tokenDecimals,
                18,
                invertedAggregator,
                true
            );
            require(
                msg.value >= price,
                "MediaEyeFee: Not enough native tokens to pay fee."
            );
            (bool priceSent, ) = feeWallet.call{value: price}("");
            require(priceSent, "transfer fail.");
            if (msg.value > price) {
                (bool diffSent, ) = msg.sender.call{value: msg.value - price}(
                    ""
                );
                require(diffSent, "return transfer fail.");
            }
        } else if (tokenAmount.stableCoin) {
            if (_uploadTier == UploadTier.LevelOne) {
                price = baseUSDTokenAmounts.uploadOneAmount;
            } else if (_uploadTier == UploadTier.LevelTwo) {
                price = baseUSDTokenAmounts.uploadTwoAmount;
            } else if (_uploadTier == UploadTier.LevelThree) {
                price = baseUSDTokenAmounts.uploadThreeAmount;
            } else if (_uploadTier == UploadTier.LevelFour) {
                price = baseUSDTokenAmounts.uploadFourAmount;
            }
            IERC20(_paymentMethod).transferFrom(msg.sender, feeWallet, price);
        } else {
            if (_uploadTier == UploadTier.LevelOne) {
                price = tokenAmount.uploadOneAmount;
            } else if (_uploadTier == UploadTier.LevelTwo) {
                price = tokenAmount.uploadTwoAmount;
            } else if (_uploadTier == UploadTier.LevelThree) {
                price = tokenAmount.uploadThreeAmount;
            } else if (_uploadTier == UploadTier.LevelFour) {
                price = tokenAmount.uploadFourAmount;
            }
            if (_paymentMethod == address(0)) {
                require(
                    msg.value == price,
                    "MediaEyeFee: Incorrect transaction value."
                );
                (bool priceSent, ) = feeWallet.call{value: price}("");
                require(priceSent, "transfer fail.");
            } else {
                IERC20(_paymentMethod).transferFrom(
                    msg.sender,
                    feeWallet,
                    price
                );
            }
        }
        emit UploadPaid(_uploadId, _uploadTier, msg.sender, price);
    }

    /**
     * @dev user pays feature fees
     * user must be trying to feature within a certain time before the feature start time
     * there can only be a set number of features for each category
     * the same nft can only be featured once every 30 day period by a user
     *
     * Params:
     * _paymentMethod: type of payment Method
     * _category: the category to feature into
     * _tokenAddress: address of the token to feature
     * _tokenId: id of the token to feature
     * _startTime: proposed start time, must be a multiple of the base Start blocktime
     */
    function payFeatureFee(
        address _paymentMethod,
        address[] memory _tokenAddresses,
        uint256[] memory _tokenIds,
        Featured memory _featured
    ) external payable {
        require(
            paymentMethods.contains(_paymentMethod),
            "MediaEyeFee: Payment method does not exist."
        );

        require(
            _featured.startTime == 0 || _featured.startTime >= block.timestamp,
            "MediaEyeFee: Can only feature within possible time frame."
        );

        require(
            _featured.numDays > 0,
            "MediaEyeFee: Can only feature for a positive number of days."
        );

        uint256 price = 0;
        TokenAmounts memory tokenAmount = paymentMethodAmounts[_paymentMethod];
        if (tokenAmount.chainlinkFeed && _paymentMethod == address(0)) {
            // get price from chainlink feed
            price = convertPrice(
                baseUSDTokenAmounts.featureAmountPerDay * _featured.numDays,
                baseUSDTokenAmounts.tokenDecimals,
                18,
                invertedAggregator,
                true
            );
            require(
                msg.value >= price,
                "MediaEyeFee: Not enough native tokens to pay fee."
            );
            (bool priceSent, ) = feeWallet.call{value: price}("");
            require(priceSent, "transfer fail.");
            if (msg.value > price) {
                (bool diffSent, ) = _featured.featuredBy.call{
                    value: msg.value - price
                }("");
                require(diffSent, "return transfer fail.");
            }
        } else if (tokenAmount.stableCoin) {
            price = baseUSDTokenAmounts.featureAmountPerDay * _featured.numDays;
            require(
                price == _featured.price,
                "MediaEyeFee: Incorrect transaction value."
            );
            if (hasRole(ROLE_CALLER, msg.sender)) {
                IERC20(_paymentMethod).transfer(feeWallet, price);
            } else {
                IERC20(_paymentMethod).transferFrom(
                    msg.sender,
                    feeWallet,
                    price
                );
            }
        } else {
            price = tokenAmount.featureAmountPerDay * _featured.numDays;
            if (_paymentMethod == address(0)) {
                require(
                    msg.value == price,
                    "MediaEyeFee: Incorrect transaction value."
                );
                (bool priceSent, ) = feeWallet.call{value: price}("");
                require(priceSent, "transfer fail.");
            } else {
                require(
                    price == _featured.price,
                    "MediaEyeFee: Incorrect transaction value."
                );
                if (hasRole(ROLE_CALLER, msg.sender)) {
                    IERC20(_paymentMethod).transfer(feeWallet, price);
                } else {
                    IERC20(_paymentMethod).transferFrom(
                        msg.sender,
                        feeWallet,
                        price
                    );
                }
            }
        }

        uint256 startTime = _featured.startTime;
        if (startTime == 0) {
            startTime = block.timestamp;
        }
        uint256 endTime = startTime + (_featured.numDays * 1 days);

        emit FeaturePaid(
            _tokenAddresses,
            _tokenIds,
            _featured,
            startTime,
            endTime,
            _featured.featuredBy
        );
    }

    /**
     * @dev user pays subscription fees for tier one
     *
     * Params:
     * _paymentMethod: type of payment Method
     * _duration: 30 days or 90 days
     */
    function paySubscriptionLevelOneFee(
        address _paymentMethod,
        SubscriptionDuration _duration
    ) external payable {
        require(
            paymentMethods.contains(_paymentMethod),
            "MediaEyeFee: Payment method does not exist."
        );

        require(
            _duration == SubscriptionDuration.Duration1 ||
                _duration == SubscriptionDuration.Duration2,
            "MediaEyeFee: Duration must match."
        );

        uint256 startTimestamp = block.timestamp;
        uint256 endTimestamp = 0;
        uint256 price = 0;

        if (_duration == SubscriptionDuration.Duration1) {
            endTimestamp = block.timestamp + 30 days;
        } else if (_duration == SubscriptionDuration.Duration2) {
            endTimestamp = block.timestamp + 90 days;
        }
        if (subscriptions[msg.sender].endTime > block.timestamp) {
            require(
                subscriptions[msg.sender].subscriptionTier ==
                    MediaEyeOrders.SubscriptionTier.LevelOne,
                "MediaEyeFee: User is subscribed already to a higher tier."
            );
            startTimestamp = subscriptions[msg.sender].startTime;
            if (_duration == SubscriptionDuration.Duration1) {
                endTimestamp =
                    subscriptions[msg.sender].endTime +
                    43800 minutes;
            } else if (_duration == SubscriptionDuration.Duration2) {
                endTimestamp =
                    subscriptions[msg.sender].endTime +
                    131400 minutes;
            }
        }

        TokenAmounts memory tokenAmount = paymentMethodAmounts[_paymentMethod];
        if (tokenAmount.chainlinkFeed && _paymentMethod == address(0)) {
            if (_duration == SubscriptionDuration.Duration1) {
                price = baseUSDTokenAmounts.subscribeOneAmount;
            } else if (_duration == SubscriptionDuration.Duration2) {
                price = baseUSDTokenAmounts.subscribeOne90Amount;
            }
            // get price from chainlink feed
            price = convertPrice(
                price,
                baseUSDTokenAmounts.tokenDecimals,
                18,
                invertedAggregator,
                true
            );
            require(
                msg.value >= price,
                "MediaEyeFee: Not enough native tokens to pay fee."
            );
            (bool priceSent, ) = feeWallet.call{value: price}("");
            require(priceSent, "transfer fail.");
            if (msg.value > price) {
                (bool diffSent, ) = msg.sender.call{value: msg.value - price}(
                    ""
                );
                require(diffSent, "return transfer fail.");
            }
        } else if (tokenAmount.stableCoin) {
            if (_duration == SubscriptionDuration.Duration1) {
                price = baseUSDTokenAmounts.subscribeOneAmount;
            } else if (_duration == SubscriptionDuration.Duration2) {
                price = baseUSDTokenAmounts.subscribeOne90Amount;
            }
            IERC20(_paymentMethod).transferFrom(msg.sender, feeWallet, price);
        } else {
            if (_duration == SubscriptionDuration.Duration1) {
                price = tokenAmount.subscribeOneAmount;
            } else if (_duration == SubscriptionDuration.Duration2) {
                price = tokenAmount.subscribeOne90Amount;
            }
            if (_paymentMethod == address(0)) {
                require(
                    msg.value == price,
                    "MediaEyeFee: Incorrect transaction value."
                );
                (bool priceSent, ) = feeWallet.call{value: price}("");
                require(priceSent, "transfer fail.");
            } else {
                IERC20(_paymentMethod).transferFrom(
                    msg.sender,
                    feeWallet,
                    price
                );
            }
        }

        MediaEyeOrders.UserSubscription
            storage newUserSubscription = subscriptions[msg.sender];
        newUserSubscription.userAddress = msg.sender;
        newUserSubscription.subscriptionTier = MediaEyeOrders
            .SubscriptionTier
            .LevelOne;
        newUserSubscription.startTime = startTimestamp;
        newUserSubscription.endTime = endTimestamp;

        if (ambCheck) {
            IMediaEyeSubscriptionMediator(mediator).subscribeByMediator(
                msg.sender,
                startTimestamp,
                endTimestamp,
                false
            );
        }

        emit SubscriptionPaid(newUserSubscription);
    }

    //call to subscribe via mediator
    function subscribeByBridge(
        address account,
        uint256 startTimestamp,
        uint256 endTimestamp,
        bool tier
    ) external onlyMediator {
        MediaEyeOrders.UserSubscription
            storage newUserSubscription = subscriptions[account];
        newUserSubscription.userAddress = account;
        if (tier == false) {
            newUserSubscription.subscriptionTier = MediaEyeOrders
                .SubscriptionTier
                .LevelOne;
        } else {
            newUserSubscription.subscriptionTier = MediaEyeOrders
                .SubscriptionTier
                .LevelTwo;
        }
        newUserSubscription.startTime = startTimestamp;
        newUserSubscription.endTime = endTimestamp;

        emit SubscriptionByBridge(newUserSubscription);
    }

    /**
     * @dev user pays subscription fees for tier two
     *
     * Params:
     * _paymentMethod: type of payment Method
     * _duration: 30 days or 90 days
     */
    function paySubscriptionLevelTwoFee(
        address _paymentMethod,
        SubscriptionDuration _duration
    ) external payable {
        require(
            paymentMethods.contains(_paymentMethod),
            "MediaEyeFee: Payment method does not exist."
        );

        require(
            _duration == SubscriptionDuration.Duration1 ||
                _duration == SubscriptionDuration.Duration2,
            "MediaEyeFee: Duration must match."
        );

        uint256 startTimestamp = block.timestamp;
        uint256 endTimestamp = 0;
        uint256 price = 0;

        if (_duration == SubscriptionDuration.Duration1) {
            endTimestamp = block.timestamp + 43800 minutes;
        } else if (_duration == SubscriptionDuration.Duration2) {
            endTimestamp = block.timestamp + 131400 minutes;
        }

        if (subscriptions[msg.sender].endTime > block.timestamp) {
            if (
                subscriptions[msg.sender].subscriptionTier ==
                MediaEyeOrders.SubscriptionTier.LevelTwo
            ) {
                startTimestamp = subscriptions[msg.sender].startTime;
                if (_duration == SubscriptionDuration.Duration1) {
                    endTimestamp =
                        subscriptions[msg.sender].endTime +
                        43800 minutes;
                } else if (_duration == SubscriptionDuration.Duration2) {
                    endTimestamp =
                        subscriptions[msg.sender].endTime +
                        131400 minutes;
                }
            }
        }
        TokenAmounts memory tokenAmount = paymentMethodAmounts[_paymentMethod];

        if (tokenAmount.chainlinkFeed && _paymentMethod == address(0)) {
            if (_duration == SubscriptionDuration.Duration1) {
                price = baseUSDTokenAmounts.subscribeTwoAmount;
            } else if (_duration == SubscriptionDuration.Duration2) {
                price = baseUSDTokenAmounts.subscribeTwo90Amount;
            }
            // get price from chainlink feed
            price = convertPrice(
                price,
                baseUSDTokenAmounts.tokenDecimals,
                18,
                invertedAggregator,
                true
            );
            require(
                msg.value >= price,
                "MediaEyeFee: Not enough native tokens to pay fee."
            );
            (bool priceSent, ) = feeWallet.call{value: price}("");
            require(priceSent, "transfer fail.");
            if (msg.value > price) {
                (bool diffSent, ) = msg.sender.call{value: msg.value - price}(
                    ""
                );
                require(diffSent, "return transfer fail.");
            }
        } else if (tokenAmount.stableCoin) {
            if (_duration == SubscriptionDuration.Duration1) {
                price = baseUSDTokenAmounts.subscribeTwoAmount;
            } else if (_duration == SubscriptionDuration.Duration2) {
                price = baseUSDTokenAmounts.subscribeTwo90Amount;
            }
            IERC20(_paymentMethod).transferFrom(msg.sender, feeWallet, price);
        } else {
            if (_duration == SubscriptionDuration.Duration1) {
                price = tokenAmount.subscribeTwoAmount;
            } else if (_duration == SubscriptionDuration.Duration2) {
                price = tokenAmount.subscribeTwo90Amount;
            }
            if (_paymentMethod == address(0)) {
                require(
                    msg.value == price,
                    "MediaEyeFee: Incorrect transaction value."
                );
                (bool priceSent, ) = feeWallet.call{value: price}("");
                require(priceSent, "transfer fail.");
            } else {
                IERC20(_paymentMethod).transferFrom(
                    msg.sender,
                    feeWallet,
                    price
                );
            }
        }

        MediaEyeOrders.UserSubscription
            storage newUserSubscription = subscriptions[msg.sender];
        newUserSubscription.userAddress = msg.sender;
        newUserSubscription.subscriptionTier = MediaEyeOrders
            .SubscriptionTier
            .LevelTwo;
        newUserSubscription.startTime = startTimestamp;
        newUserSubscription.endTime = endTimestamp;

        if (ambCheck) {
            IMediaEyeSubscriptionMediator(mediator).subscribeByMediator(
                msg.sender,
                startTimestamp,
                endTimestamp,
                true
            );
        }

        emit SubscriptionPaid(newUserSubscription);
    }

    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        return _DOMAIN_SEPARATOR;
    }
}