// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "./Permissions.sol";

contract Core is Permissions {

    constructor() public {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract Permissions is AccessControl {
    bytes32 public constant GOVERN_ROLE = keccak256("GOVERN_ROLE");
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
    bytes32 public constant MASTER_ROLE = keccak256("MASTER_ROLE");
    bytes32 public constant TIMELOCK_ROLE = keccak256("TIMELOCK_ROLE");
    bytes32 public constant MULTISTRATEGY_ROLE = keccak256("MULTISTRATEGY_ROLE");

    constructor() public {
        _setupGovernor(address(this));
        _setupGovernor(msg.sender);
        _setupRole(TIMELOCK_ROLE, msg.sender);
        _setRoleAdmin(GOVERN_ROLE, GOVERN_ROLE);
        _setRoleAdmin(GUARDIAN_ROLE, GOVERN_ROLE);
        _setRoleAdmin(PROPOSER_ROLE, GOVERN_ROLE);
        _setRoleAdmin(EXECUTOR_ROLE, GOVERN_ROLE);
        _setRoleAdmin(MASTER_ROLE, GOVERN_ROLE);
        _setRoleAdmin(TIMELOCK_ROLE, GOVERN_ROLE);
        _setRoleAdmin(MULTISTRATEGY_ROLE, GOVERN_ROLE);
    }

    modifier onlyGovernor() {
        require(isGovernor(msg.sender), "Permissions::onlyGovernor: Caller is not a governor");
        _;
    }

    modifier onlyTimelock() {
        require(hasRole(TIMELOCK_ROLE, msg.sender), "Permissions::onlyTimelock: Caller is not a timelock");
        _;
    }

    function createRole(bytes32 role, bytes32 adminRole) external onlyTimelock {
        _setRoleAdmin(role, adminRole);
    }

    function grantGovernor(address governor) external onlyTimelock {
        grantRole(GOVERN_ROLE, governor);
    }

    function grantGuardian(address guardian) external onlyTimelock {
        grantRole(GUARDIAN_ROLE, guardian);
    }

    function grantMultistrategy(address multistrategy) external onlyTimelock {
        grantRole(MULTISTRATEGY_ROLE, multistrategy);
    }

    function grantRole(bytes32 role, address account) public override onlyTimelock {
        super.grantRole(role, account);
    }

    function revokeGovernor(address governor) external onlyGovernor {
        revokeRole(GOVERN_ROLE, governor);
    }

    function revokeGuardian(address guardian) external onlyGovernor {
        revokeRole(GUARDIAN_ROLE, guardian);
    }

    function revokeMultistrategy(address multistrategy) external onlyGovernor {
        revokeRole(MULTISTRATEGY_ROLE, multistrategy);
    }

    function isGovernor(address _address) public view virtual returns (bool) {
        return hasRole(GOVERN_ROLE, _address);
    }

    function isMultistrategy(address _address) public view virtual returns (bool) {
        return hasRole(MULTISTRATEGY_ROLE, _address);
    }

    function isGuardian(address _address) public view returns (bool) {
        return hasRole(GUARDIAN_ROLE, _address);
    }

    function _setupGovernor(address governor) internal {
        _setupRole(GOVERN_ROLE, governor);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/EnumerableSet.sol";
import "../utils/Address.sol";
import "../utils/Context.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
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
abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
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
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
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
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
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
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

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
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

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
    function renounceRole(bytes32 role, address account) public virtual {
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
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../utils/Context.sol";
import "./IERC20.sol";
import "../../math/SafeMath.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
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
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
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

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "../interfaces/IVenus.sol";
import "../interfaces/IStrategy.sol";
import "../interfaces/IPancakeRouter02.sol";
import "../interfaces/IOracle.sol";
import "../refs/CoreRef.sol";
import "../interfaces/IWBNB.sol";
// import "hardhat/console.sol";

contract StrategyVenus is IStrategyVenus, ReentrancyGuard, Ownable, CoreRef {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 public override lastEarnBlock;

    address public override wantAddress;
    address public override vTokenAddress;
    address[] public override markets;
    address public override uniRouterAddress;

    address public constant wbnbAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public override earnedAddress;
    address public override distributionAddress;

    address[] public override earnedToWantPath;

    uint256 public override borrowRate;

    bool public override isComp;

    address public oracle;
    uint256 internal swapSlippage;

    constructor(
        address _core,
        address _wantAddress,
        address _vTokenAddress,
        address _uniRouterAddress,
        address _earnedAddress,
        address _distributionAddress,
        address[] memory _earnedToWantPath,
        bool _isComp,
        address _oracle,
        uint256 _swapSlippage
    ) public CoreRef(_core) {
        borrowRate = 585;
        wantAddress = _wantAddress;

        earnedToWantPath = _earnedToWantPath;

        earnedAddress = _earnedAddress;
        distributionAddress = _distributionAddress;
        vTokenAddress = _vTokenAddress;
        markets = [vTokenAddress];
        uniRouterAddress = _uniRouterAddress;

        isComp = _isComp;

        oracle = _oracle;
        swapSlippage = _swapSlippage;

        IERC20(earnedAddress).safeApprove(uniRouterAddress, uint256(-1));
        IERC20(wantAddress).safeApprove(uniRouterAddress, uint256(-1));
        IERC20(wantAddress).safeApprove(vTokenAddress, uint256(-1));

        IVenusDistribution(distributionAddress).enterMarkets(markets);
    }

    function _supply(uint256 _amount) internal {
        _safeUnwrap(_amount);
        if (wantAddress == wbnbAddress) {
            IVBNB(vTokenAddress).mint{ value: _amount }();
        } else {
            require(IVToken(vTokenAddress).mint(_amount) == 0, "mint Err");
        }
    }

    function _removeSupply(uint256 _amount) internal {
        require(IVToken(vTokenAddress).redeemUnderlying(_amount) == 0, "redeemUnderlying Err");
        _safeWrap();
    }

    function _safeWrap() internal {
        if (wantAddress == wbnbAddress) {
            IWBNB(wbnbAddress).deposit{ value: address(this).balance }();
        }
    }

    function _safeUnwrap(uint256 _amount) internal {
        if (wantAddress == wbnbAddress) {
            IWBNB(wbnbAddress).withdraw(_amount);
        }
    }

    function _borrow(uint256 _amount) internal {
        require(IVToken(vTokenAddress).borrow(_amount) == 0, "borrow Err");
    }

    function _repayBorrow(uint256 _amount) internal {
        require(IVToken(vTokenAddress).repayBorrow(_amount) == 0, "repayBorrow Err");
    }

    function deposit(uint256 _wantAmt) public override nonReentrant whenNotPaused {
        (uint256 sup, uint256 brw, ) = updateBalance();

        IERC20(wantAddress).safeTransferFrom(address(msg.sender), address(this), _wantAmt);

        _supply(wantLockedInHere());
    }

    function leverage(uint256 _amount) public override onlyTimelock {
        _leverage(_amount);
    }

    function _leverage(uint256 _amount) internal {
        updateStrategy();
        (uint256 sup, uint256 brw, ) = updateBalance();

        require(brw.add(_amount).mul(1000).div(borrowRate) <= sup, "ltv too high");
        _borrow(_amount);
        _supply(wantLockedInHere());
    }

    function deleverage(uint256 _amount) public override onlyTimelock {
        _deleverage(_amount);
    }

    function deleverageAll(uint256 redeemFeeAmt) public override onlyTimelock {
        updateStrategy();
        (uint256 sup, uint256 brw, uint256 supMin) = updateBalance();
        require(brw.add(redeemFeeAmt) <= sup.sub(supMin), "amount too big");
        _removeSupply(brw.add(redeemFeeAmt));
        _repayBorrow(brw);
        _supply(wantLockedInHere());
    }

    function _deleverage(uint256 _amount) internal {
        updateStrategy();
        (uint256 sup, uint256 brw, uint256 supMin) = updateBalance();

        require(_amount <= sup.sub(supMin), "amount too big");
        require(_amount <= brw, "amount too big");

        _removeSupply(_amount);
        _repayBorrow(wantLockedInHere());
    }

    function setBorrowRate(uint256 _borrowRate) public override onlyTimelock {
        updateStrategy();
        borrowRate = _borrowRate;
        (uint256 sup, , uint256 supMin) = updateBalance();
        require(sup >= supMin, "supply should be greater than supply min");
    }

    function earn() public override whenNotPaused onlyTimelock {
        if (isComp) {
            IVenusDistribution(distributionAddress).claimComp(address(this));
        } else {
            IVenusDistribution(distributionAddress).claimVenus(address(this));
        }
        uint256 minReturnWant;

        uint256 earnedAmt = IERC20(earnedAddress).balanceOf(address(this));

        if (earnedAddress != wantAddress && earnedAmt != 0) {
            uint256 minReturnWant = _calculateMinReturn(earnedAmt, earnedAddress);
            IPancakeRouter02(uniRouterAddress).swapExactTokensForTokens(
                earnedAmt,
                minReturnWant,
                earnedToWantPath,
                address(this),
                now.add(600)
            );
        }

        earnedAmt = wantLockedInHere();
        if (earnedAmt != 0) {
            _supply(earnedAmt);
        }

        lastEarnBlock = block.number;
    }

    function withdraw() public override onlyMultistrategy nonReentrant {
        _withdraw();

        if (isComp) {
            IVenusDistribution(distributionAddress).claimComp(address(this));
        } else {
            IVenusDistribution(distributionAddress).claimVenus(address(this));
        }

        uint256 earnedAmt = IERC20(earnedAddress).balanceOf(address(this));
        if (earnedAddress != wantAddress && earnedAmt != 0) {
            uint256 minReturnWant = _calculateMinReturn(earnedAmt, earnedAddress);
            IPancakeRouter02(uniRouterAddress).swapExactTokensForTokens(
                earnedAmt,
                minReturnWant,
                earnedToWantPath,
                address(this),
                now.add(600)
            );
        }

        uint256 wantBal = wantLockedInHere();
        IERC20(wantAddress).safeTransfer(msg.sender, wantBal);
    }

    function _withdraw() internal {
        (uint256 sup, uint256 brw, uint256 supMin) = updateBalance();
        uint256 _wantAmt = sup.sub(brw);
        uint256 delevAmtAvail = sup.sub(supMin);
        while (_wantAmt > delevAmtAvail) {
            if (delevAmtAvail > brw) {
                _deleverage(brw);
                (sup, brw, supMin) = updateBalance();
                delevAmtAvail = sup.sub(supMin);
                break;
            } else {
                _deleverage(delevAmtAvail);
            }
            (sup, brw, supMin) = updateBalance();
            delevAmtAvail = sup.sub(supMin);
        }

        if (_wantAmt > delevAmtAvail) {
            _wantAmt = delevAmtAvail;
        }

        _removeSupply(_wantAmt);
    }

    function _pause() internal override {
        super._pause();
        IERC20(earnedAddress).safeApprove(uniRouterAddress, 0);
        IERC20(wantAddress).safeApprove(uniRouterAddress, 0);
        IERC20(wantAddress).safeApprove(vTokenAddress, 0);
    }

    function _unpause() internal override {
        super._unpause();
        IERC20(earnedAddress).safeApprove(uniRouterAddress, uint256(-1));
        IERC20(wantAddress).safeApprove(uniRouterAddress, uint256(-1));
        IERC20(wantAddress).safeApprove(vTokenAddress, uint256(-1));
    }

    function calculateMinReturn(uint256 _amount) external view returns (uint256 minReturn) {
        minReturn = _calculateMinReturn(_amount, earnedAddress);
    }

    // below allow deposit of different inputTokens with different decimals
    struct CalculateMinReturnVal {
        uint256 oraclePriceUsdPerRewardToken;
        uint256 oraclePriceUsdPerInputToken;
        uint8 baseDecimalsRewardToken;
        uint8 baseDecimalsInputToken;
        uint256 exponent;
    }
    function _calculateMinReturn(uint256 _amount, address _rewardTokenAddress) internal view returns (uint256 minReturn) {
        CalculateMinReturnVal memory c;
        c.oraclePriceUsdPerRewardToken = IOracle(oracle).getLatestPrice(_rewardTokenAddress);
        c.oraclePriceUsdPerInputToken = IOracle(oracle).getLatestPrice(wantAddress);
        (,c.baseDecimalsRewardToken) = IOracle(oracle).feeds(_rewardTokenAddress);
        (,c.baseDecimalsInputToken) = IOracle(oracle).feeds(wantAddress);

        if (c.baseDecimalsRewardToken == c.baseDecimalsInputToken) {
            minReturn =  _amount.mul(c.oraclePriceUsdPerRewardToken).mul(100 - swapSlippage).div(100).div(c.oraclePriceUsdPerInputToken);
        } else if (c.baseDecimalsRewardToken > c.baseDecimalsInputToken) {
            c.exponent = (uint256(c.baseDecimalsRewardToken).sub(uint256(c.baseDecimalsInputToken))).mul(2);
            minReturn =  _amount.mul(c.oraclePriceUsdPerRewardToken)
                        .mul(100 - swapSlippage).div(100)
                        .div( 10**c.exponent ).div(c.oraclePriceUsdPerInputToken);
        } else if (c.baseDecimalsRewardToken < c.baseDecimalsInputToken) {
            c.exponent = (uint256(c.baseDecimalsInputToken).sub(uint256(c.baseDecimalsRewardToken))).mul(2);
            minReturn =  _amount.mul(c.oraclePriceUsdPerRewardToken).mul( 10**c.exponent )
                        .mul(100 - swapSlippage).div(100)
                        .div(c.oraclePriceUsdPerInputToken);
        }
    }

    function setSlippage(uint256 _swapSlippage) public onlyGovernor {
        require(_swapSlippage < 10, "Slippage value is too big");
        swapSlippage = _swapSlippage;
    }

    function setOracle(address _oracle) public onlyGovernor {
        oracle = _oracle;
    }

    function updateBalance()
        public
        view
        override
        returns (
            uint256 sup,
            uint256 brw,
            uint256 supMin
        )
    {
        (uint256 errCode, uint256 _sup, uint256 _brw, uint256 exchangeRate) = IVToken(vTokenAddress).getAccountSnapshot(
            address(this)
        );
        require(errCode == 0, "Venus ErrCode");
        sup = _sup.mul(exchangeRate).div(1e18);
        brw = _brw;
        supMin = brw.mul(1000).div(borrowRate);
    }

    function wantLockedTotal() public view returns (uint256) {
        (uint256 sup, uint256 brw, ) = updateBalance();
        return wantLockedInHere().add(sup).sub(brw);
    }

    function wantLockedInHere() public view override returns (uint256) {
        return IERC20(wantAddress).balanceOf(address(this));
    }

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) public override onlyTimelock {
        require(_token != earnedAddress, "!safe");
        require(_token != wantAddress, "!safe");
        require(_token != vTokenAddress, "!safe");

        IERC20(_token).safeTransfer(_to, _amount);
    }

    function updateStrategy() public override {
        require(IVToken(vTokenAddress).accrueInterest() == 0);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

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
    using SafeMath for uint256;
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
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

    constructor () internal {
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
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

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVenusDistribution {
    function claimVenus(address holder) external;

    function claimComp(address holder) external;

    function enterMarkets(address[] memory _vtokens) external;

    function exitMarket(address _vtoken) external;

    function getAssetsIn(address account)
        external
        view
        returns (address[] memory);

    function getAccountLiquidity(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );
}

interface IVToken is IERC20 {

    function mint(uint256 mintAmount) external returns (uint256);

    function redeem(uint256 redeemTokens) external returns (uint256);

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function borrow(uint256 borrowAmount) external returns (uint256);

    function repayBorrow(uint256 repayAmount) external returns (uint256);

    function balanceOfUnderlying(address owner) external returns (uint256);

    function borrowBalanceStored(address account) external view returns (uint);

    function borrowBalanceCurrent(address account) external returns (uint256);
    
    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);

    function accrueInterest() external returns (uint);
}

interface IVBNB is IVToken {
    function mint() external payable;

    function repayBorrow() external payable;
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface IStrategy {
    function wantLockedInHere() external view returns (uint256);

    function lastEarnBlock() external view returns (uint256);

    function deposit(uint256 _wantAmt) external;

    function withdraw() external;

    function updateStrategy() external;

    function uniRouterAddress() external view returns (address);

    function wantAddress() external view returns (address);

    function earnedToWantPath(uint256 idx) external view returns (address);

    function earn() external;

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) external;
}

interface ILeverageStrategy is IStrategy {
    function leverage(uint256 _amount) external;

    function deleverage(uint256 _amount) external;

    function deleverageAll(uint256 redeemFeeAmount) external;

    function updateBalance()
        external
        view
        returns (
            uint256 sup,
            uint256 brw,
            uint256 supMin
        );

    function borrowRate() external view returns (uint256);

    function setBorrowRate(uint256 _borrowRate) external;
}

interface IStrategyAlpaca is IStrategy {
    function vaultAddress() external view returns (address);

    function poolId() external view returns (uint256);
}

interface IStrategyVenus is ILeverageStrategy {
    function vTokenAddress() external view returns (address);

    function markets(uint256 idx) external view returns (address);

    function earnedAddress() external view returns (address);

    function distributionAddress() external view returns (address);

    function isComp() external view returns (bool);
}

interface IStrategyAvax {
    function setOracle(address _oracle) external;

    function setDexRouter(address _dexRouterAddress) external;

    function setInputTokenToBaseTokenPath(address[] calldata _inputTokenToBaseTokenPath) external;

    function setBaseTokenToInputTokenPath(address[] calldata _baseTokenToInputTokenPath) external;

    function setAvaxToInputTokenPath(address[] calldata _avaxToInputTokenPath) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

import './IPancakeRouter01.sol';

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

//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

interface IOracle {
    function oracle() external view returns (address);

    function getLatestPrice(address token) external view returns (uint256 price);

    function setFeeds(
        address[] memory _tokens,
        address[] memory _baseDecimals,
        address[] memory _aggregators
    ) external;

    function feeds(address) external view returns (address aggregator, uint8 baseDecimals);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "../interfaces/ICore.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

abstract contract CoreRef is Pausable {
    event CoreUpdate(address indexed _core);

    ICore private _core;

    bytes32 public constant TIMELOCK_ROLE = keccak256("TIMELOCK_ROLE");

    constructor(address core_) public {
        _core = ICore(core_);
    }

    modifier onlyGovernor() {
        require(_core.isGovernor(msg.sender), "CoreRef::onlyGovernor: Caller is not a governor");
        _;
    }

    modifier onlyGuardian() {
        require(_core.isGuardian(msg.sender), "CoreRef::onlyGuardian: Caller is not a guardian");
        _;
    }

    modifier onlyGuardianOrGovernor() {
        require(
            _core.isGovernor(msg.sender) || _core.isGuardian(msg.sender),
            "CoreRef::onlyGuardianOrGovernor: Caller is not a guardian or governor"
        );
        _;
    }

    modifier onlyMultistrategy() {
        require(_core.isMultistrategy(msg.sender), "CoreRef::onlyMultistrategy: Caller is not a multistrategy");
        _;
    }

    modifier onlyTimelock() {
        require(_core.hasRole(TIMELOCK_ROLE, msg.sender), "CoreRef::onlyTimelock: Caller is not a timelock");
        _;
    }

    modifier onlyRole(bytes32 role) {
        require(_core.hasRole(role, msg.sender), "CoreRef::onlyRole: Not permit");
        _;
    }

    modifier onlyRoleOrOpenRole(bytes32 role) {
        require(
            _core.hasRole(role, address(0)) || _core.hasRole(role, msg.sender),
            "CoreRef::onlyRoleOrOpenRole: Not permit"
        );
        _;
    }

    modifier onlyNonZeroAddress(address targetAddress) {
        require(targetAddress != address(0), "address cannot be set to 0x0");
        _;
    }

    modifier onlyNonZeroAddressArray(address[] calldata targetAddresses) {
        for (uint256 i = 0; i < targetAddresses.length; i++) {
            require(targetAddresses[i] != address(0), "address cannot be set to 0x0");
        }
        _;
    }

    function setCore(address core_) external onlyGovernor {
        _core = ICore(core_);
        emit CoreUpdate(core_);
    }

    function pause() public onlyGuardianOrGovernor {
        _pause();
    }

    function unpause() public onlyGuardianOrGovernor {
        _unpause();
    }

    function core() public view returns (ICore) {
        return _core;
    }
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.4.18 <=0.6.12;

interface IWBNB {
    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function totalSupply() external view returns (uint256);

    function approve(address guy, uint256 wad) external returns (bool);

    function transfer(address dst, uint256 wad) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);
}

//WBNB contract address:0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c

// abstract contract WBNBCaller {
//     WBNB public wbnb;
//     constructor (address _contractAddress)  {
//         wbnb = WBNB( _contractAddress );
//     }

//     function getTotalSupply() public view returns(uint) {
//         return wbnb.totalSupply();
//     }
//     function deposit() public  {
//         wbnb.deposit();
//     }

// }

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface ICore {
    function isGovernor(address _address) external view returns (bool);

    function isGuardian(address _address) external view returns (bool);

    function isMultistrategy(address _address) external view returns (bool);

    function hasRole(bytes32 role, address account) external view returns (bool);

    function createRole(bytes32 role, bytes32 adminRole) external;

    function grantGovernor(address governor) external;

    function grantGuardian(address guardian) external;

    function grantMultistrategy(address multistrategy) external;

    function grantRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./Context.sol";

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
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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

//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "../refs/CoreRefUpgradeable.sol";
import "../interfaces/IAlpaca.sol";
import "../interfaces/IWBNB.sol";
import "../interfaces/AlpacaPancakeFarm/IStrategyManagerAlpacaFarm.sol";

contract StrategyManagerAlpacaFarm is
    Initializable,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable,
    CoreRefUpgradeable,
    IStrategyManagerAlpacaFarm
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public alpacaAddress;

    function init(address _core, address _alpacaAddress) public initializer {
        CoreRefUpgradeable.initialize(_core);
        OwnableUpgradeable.__Ownable_init();
        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
        alpacaAddress = _alpacaAddress;
    }

    function deposit(
        address vaultAddress,
        uint256 vaultPositionId,
        address worker,
        address wantAddr,
        uint256 wantAmt,
        bytes memory data
    ) external override nonReentrant returns (uint256) {
        require(wantAmt > 0, "StrategyManagerAlpacaFarm::Invalid amount");
        IERC20Upgradeable(wantAddr).safeTransferFrom(msg.sender, address(this), wantAmt);
        IERC20Upgradeable(wantAddr).safeApprove(vaultAddress, wantAmt);
        if (vaultPositionId != 0) {
            Vault(vaultAddress).work(vaultPositionId, worker, wantAmt, 0, 0, data);
        } else {
            vaultPositionId = Vault(vaultAddress).nextPositionID();
            Vault(vaultAddress).work(0, worker, wantAmt, 0, 0, data);
        }
        return vaultPositionId;
    }

    function withdraw(
        address wantAddress,
        address vaultAddress,
        uint256 vaultPositionId,
        address worker,
        bytes memory data
    ) external payable override onlyMultistrategy nonReentrant {
        address wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        Vault(vaultAddress).work(vaultPositionId, worker, 0, 0, uint256(-1), data);
        if (wantAddress == wbnb) {
            IWBNB(wbnb).deposit{value: address(this).balance}();
        }
        uint256 earnedAlpaca = IERC20Upgradeable(alpacaAddress).balanceOf(address(this));
        uint256 wantBalance = IERC20Upgradeable(wantAddress).balanceOf(address(this));

        IERC20Upgradeable(alpacaAddress).safeTransfer(msg.sender, earnedAlpaca);
        IERC20Upgradeable(wantAddress).safeTransfer(msg.sender, wantBalance);
    }

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) public onlyTimelock {
        IERC20Upgradeable(_token).safeTransfer(_to, _amount);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
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
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20Upgradeable.sol";
import "../../math/SafeMathUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";

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
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/Initializable.sol";
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
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

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

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "../interfaces/ICore.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

abstract contract CoreRefUpgradeable is PausableUpgradeable {
    event CoreUpdate(address indexed _core);

    ICore private _core;

    bytes32 public constant TIMELOCK_ROLE = keccak256("TIMELOCK_ROLE");

    function initialize(address core_) public initializer {
        _core = ICore(core_);
        PausableUpgradeable.__Pausable_init_unchained();
    }

    constructor() public {}

    modifier onlyGovernor() {
        require(_core.isGovernor(msg.sender), "CoreRef::onlyGovernor: Caller is not a governor");
        _;
    }

    modifier onlyGuardian() {
        require(_core.isGuardian(msg.sender), "CoreRef::onlyGuardian: Caller is not a guardian");
        _;
    }

    modifier onlyGuardianOrGovernor() {
        require(
            _core.isGovernor(msg.sender) || _core.isGuardian(msg.sender),
            "CoreRef::onlyGuardianOrGovernor: Caller is not a guardian or governor"
        );
        _;
    }

    modifier onlyMultistrategy() {
        require(_core.isMultistrategy(msg.sender), "CoreRef::onlyMultistrategy: Caller is not a multistrategy");
        _;
    }

    modifier onlyTimelock() {
        require(_core.hasRole(TIMELOCK_ROLE, msg.sender), "CoreRef::onlyTimelock: Caller is not a timelock");
        _;
    }

    modifier onlyRole(bytes32 role) {
        require(_core.hasRole(role, msg.sender), "CoreRef::onlyRole: Not permit");
        _;
    }

    modifier onlyRoleOrOpenRole(bytes32 role) {
        require(
            _core.hasRole(role, address(0)) || _core.hasRole(role, msg.sender),
            "CoreRef::onlyRoleOrOpenRole: Not permit"
        );
        _;
    }

    function setCore(address core_) external onlyGovernor {
        _core = ICore(core_);
        emit CoreUpdate(core_);
    }

    function pause() public onlyGuardianOrGovernor {
        _pause();
    }

    function unpause() public onlyGuardianOrGovernor {
        _unpause();
    }

    function core() public view returns (ICore) {
        return _core;
    }
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface Vault {
    function balanceOf(address account) external view returns (uint256);

    function nextPositionID() external view returns (uint256);

    function totalToken() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function deposit(uint256 amountToken) external payable;

    function withdraw(uint256 share) external;

    function work(
        uint256 id,
        address worker,
        uint256 principalAmount,
        uint256 loan,
        uint256 maxReturn,
        bytes memory data
    ) external payable;
}

interface FairLaunch {
    function deposit(
        address _for,
        uint256 _pid,
        uint256 _amount
    ) external; // staking

    function withdraw(
        address _for,
        uint256 _pid,
        uint256 _amount
    ) external; // unstaking

    function harvest(uint256 _pid) external;

    function pendingAlpaca(uint256 _pid, address _user) external returns (uint256);

    function userInfo(uint256, address)
        external
        view
        returns (
            uint256 amount,
            uint256 rewardDebt,
            uint256 bonusDebt,
            uint256 fundedBy
        );
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface IStrategyManagerAlpacaFarm {
    function deposit(
        address vaultAddress,
        uint256 vaultPositionId,
        address worker,
        address wantAddr,
        uint256 wantAmt,
        bytes memory data
    ) external returns (uint256);

    function withdraw(
        address wantAddress,
        address vaultAddress,
        uint256 vaultPositionId,
        address worker,
        bytes memory data
    ) external payable;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./ContextUpgradeable.sol";
import "../proxy/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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
    uint256[49] private __gap;
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/math/MathUpgradeable.sol";
import "../refs/CoreRefUpgradeable.sol";
import "../interfaces/IAlpaca.sol";
import "../interfaces/AlpacaPancakeFarm/IStrategyAlpacaFarm.sol";
import "../interfaces/AlpacaPancakeFarm/IStrategyManagerAlpacaFarm.sol";
import "../interfaces/IPancakeRouter02.sol";
import "../interfaces/IPancakeFactory.sol";
import "../interfaces/IPancakePair.sol";
import "../interfaces/IPancakeswapV2Worker02.sol";
import "../interfaces/IOracle.sol";

import "../library/Math.sol";

contract StrategyAlpacaFarmUpgradeable is
    Initializable,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable,
    CoreRefUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;
    using WTFMath for uint256;

    address public wantAddress;
    address public farmTokenAddress;
    address public strategyManager;
    address public alpacaAddress;
    address public uniRouterAddress;
    address public vaultAddress;
    address public worker;
    address public strategyAddAllBaseToken;
    address public strategyLiquidate;
    address[] public earnedToWantPath;
    address public oracle;
    uint256 public swapSlippage;
    uint256 public vaultPositionId;

    function init(
        address _core,
        address _wantAddress,
        address _farmTokenAddress,
        address _strategyManager,
        address _alpacaAddress,
        address _uniRouterAddress,
        address _vaultAddress,
        address _worker,
        address _strategyAddAllBaseToken,
        address _strategyLiquidate,
        address[] memory _earnedToWantPath,
        address _oracle,
        uint256 _swapSlippage
    ) public initializer {
        // Init
        CoreRefUpgradeable.initialize(_core);
        OwnableUpgradeable.__Ownable_init();
        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();

        wantAddress = _wantAddress;
        farmTokenAddress = _farmTokenAddress;
        strategyManager = _strategyManager;
        alpacaAddress = _alpacaAddress;

        uniRouterAddress = _uniRouterAddress;
        vaultAddress = _vaultAddress;
        worker = _worker;
        strategyAddAllBaseToken = _strategyAddAllBaseToken;
        strategyLiquidate = _strategyLiquidate;
        earnedToWantPath = _earnedToWantPath;
        oracle = _oracle;
        swapSlippage = _swapSlippage;
        IERC20Upgradeable(alpacaAddress).safeApprove(uniRouterAddress, uint256(-1));
        IERC20Upgradeable(wantAddress).safeApprove(strategyManager, uint256(-1));
    }

    function calculateMinLP(uint256 _amountWant) external view returns (uint256 minLP) {
        address[] memory path = new address[](2);
        path[0] = wantAddress; // want
        path[1] = farmTokenAddress; // farming token
        (uint256 rWant, uint256 rFarm) = _getPairReserves(path[0], path[1]);
        /* 
           find how many baseToken need to be converted to farmingToken
           Constants come from
           2-f = 2-0.0025 = 19975
           4(1-f) = 4*9975*10000 = 399000000, where f = 0.0025 and 10,000 is a way to avoid floating point
           19975^2 = 399000625
           9975*2 = 19950
        */
        uint256 amountIn = WTFMath.sqrt(rWant.mul(_amountWant.mul(399000000).add(rWant.mul(399000625)))).sub(
            rWant.mul(19975)
        ) / 19950;

        require(amountIn <= _amountWant, "StrategyAlpacaFarmUpgradeable:: Not enough tokens");
        uint256 amountOut = IPancakeRouter02(uniRouterAddress).getAmountsOut(amountIn, path)[1];
        uint256 amountWantInvest = _amountWant.sub(amountIn);
        uint256 totalSupply = _getLPTotalSupply(path[0], path[1]);
        minLP = MathUpgradeable.min(amountWantInvest.mul(totalSupply) / rWant, amountOut.mul(totalSupply) / rFarm);
    }

    function _getPairReserves(address token0, address token1) internal view returns (uint256 rWant, uint256 rFarm) {
        address factory = IPancakeRouter02(uniRouterAddress).factory();
        IPancakePair lptoken = IPancakePair(IPancakeV2Factory(factory).getPair(token0, token1));
        (uint256 r0, uint256 r1, ) = lptoken.getReserves();
        rWant = lptoken.token0() == wantAddress ? r0 : r1;
        rFarm = lptoken.token1() == farmTokenAddress ? r1 : r0;
    }

    function _getLPTotalSupply(address token0, address token1) internal view returns (uint256 totalSupply) {
        address factory = IPancakeRouter02(uniRouterAddress).factory();
        totalSupply = IPancakePair(IPancakeV2Factory(factory).getPair(token0, token1)).totalSupply();
    }

    function deposit(uint256 _wantAmt, uint256 _minLPAmount) external nonReentrant whenNotPaused {
        require(_wantAmt > 0, "StrategyAlpacaFarmUpgradeable:: Invalid amount");
        IERC20Upgradeable(wantAddress).safeTransferFrom(msg.sender, address(this), _wantAmt);
        _deposit(_wantAmt, _minLPAmount);
    }

    function _deposit(uint256 _wantAmt, uint256 _minLPAmount) internal {
        bytes memory ext = abi.encode(uint256(_minLPAmount));
        bytes memory data = abi.encode(strategyAddAllBaseToken, ext);
        vaultPositionId = IStrategyManagerAlpacaFarm(strategyManager).deposit(
            vaultAddress,
            vaultPositionId,
            worker,
            wantAddress,
            _wantAmt,
            data
        );
    }

    function calculateMinBaseToken() external view returns (uint256 minBaseToken) {
        minBaseToken = IWorker(worker).health(vaultPositionId);
    }

    function _liquidate(uint256 minBaseToken) internal {
        bytes memory ext = abi.encode(uint256(minBaseToken));
        bytes memory data = abi.encode(strategyLiquidate, ext);
        IStrategyManagerAlpacaFarm(strategyManager).withdraw(wantAddress, vaultAddress, vaultPositionId, worker, data);
    }

    function withdraw(uint256 minBaseToken) public onlyMultistrategy nonReentrant {
        _liquidate(minBaseToken);
        uint256 earnedAmt = IERC20Upgradeable(alpacaAddress).balanceOf(address(this));
        if (earnedAmt != 0) {
            uint256 minReturn = _calculateMinReturn(earnedAmt);
            IPancakeRouter02(uniRouterAddress).swapExactTokensForTokens(
                earnedAmt,
                minReturn,
                earnedToWantPath,
                address(this),
                now.add(600)
            );
        }
        uint256 balanceWant = IERC20Upgradeable(wantAddress).balanceOf(address(this));
        IERC20Upgradeable(wantAddress).transfer(msg.sender, balanceWant);
    }

    function _calculateMinReturn(uint256 amount) internal view returns (uint256 minReturn) {
        uint256 oraclePrice = IOracle(oracle).getLatestPrice(alpacaAddress);
        uint256 total = amount.mul(oraclePrice).div(1e18);
        minReturn = total.mul(100 - swapSlippage).div(100);
    }

    function _pause() internal override {
        super._pause();
        IERC20Upgradeable(alpacaAddress).safeApprove(uniRouterAddress, 0);
        IERC20Upgradeable(wantAddress).safeApprove(strategyManager, 0);
    }

    function _unpause() internal override {
        super._unpause();
        IERC20Upgradeable(alpacaAddress).safeApprove(uniRouterAddress, uint256(-1));
        IERC20Upgradeable(wantAddress).safeApprove(strategyManager, uint256(-1));
    }

    function setSlippage(uint256 _swapSlippage) public onlyGovernor {
        require(_swapSlippage < 10, "Slippage value is too big");
        swapSlippage = _swapSlippage;
    }

    function setOracle(address _oracle) public onlyGovernor {
        oracle = _oracle;
    }

    function wantLockedInHere() public view returns (uint256) {
        return IERC20Upgradeable(wantAddress).balanceOf(address(this));
    }

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) public onlyTimelock {
        IERC20Upgradeable(_token).safeTransfer(_to, _amount);
    }

    receive() external payable {}

    function updateStrategy() public {}
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
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

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface IStrategyAlpacaFarm {
    function wantLockedInHere() external view returns (uint256);

    function deposit(uint256 wantAmt, uint256 minLPAmount) external;

    function withdraw(uint256 minBaseAmount) external;

    function updateStrategy() external;

    function uniRouterAddress() external view returns (address);

    function wantAddress() external view returns (address);

    function earnedToWantPath(uint256 idx) external view returns (address);

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) external;
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

interface IPancakeV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface IWorker {
    /// @dev Work on a (potentially new) position. Optionally send token back to Vault.
    function work(
        uint256 id,
        address user,
        uint256 debt,
        bytes calldata data
    ) external;

    /// @dev Re-invest whatever the worker is working on.
    function reinvest() external;

    /// @dev Return the amount of wei to get back if we are to liquidate the position.
    function health(uint256 id) external view returns (uint256);

    /// @dev Liquidate the given position to token. Send all token back to its Vault.
    function liquidate(uint256 id) external;

    /// @dev SetStretegy that be able to executed by the worker.
    function setStrategyOk(address[] calldata strats, bool isOk) external;

    /// @dev Set address that can be reinvest
    function setReinvestorOk(address[] calldata reinvestor, bool isOk) external;

    /// @dev Base Token that worker is working on
    function baseToken() external view returns (address);

    /// @dev Farming Token that worker is working on
    function farmingToken() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

library WTFMath {
    // implementation from https://github.com/Uniswap/uniswap-lib/commit/99f3f28770640ba1bb1ff460ac7c5292fb8291a0
    // original implementation: https://github.com/abdk-consulting/abdk-libraries-solidity/blob/master/ABDKMath64x64.sol#L687
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 xx = x;
        uint256 r = 1;

        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }

        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }

        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import "../interfaces/IOracle.sol";
import "../interfaces/ITraderJoe.sol";
import "../interfaces/IOracle.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract TestTraderJoe is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public traderJoeRouterAddress;
    address public constant jCollateralCapErc20DelegateAddress = 0xcE095A9657A02025081E0607c8D8b081c76A75ea;
    address public constant joetrollerAddress = 0xdc13687554205E5b89Ac783db14bb5bba4A1eDaC;
    address public constant joeBarAddress = 0x57319d41F71E81F3c65F2a47CA4e001EbAFd4F33;
    address public constant joeAddress = 0x6e84a6216eA6dACC71eE8E6b0a5B7322EEbC0fDd;

    address public wantAddress;
    address public jMiMAddress;
    uint256 public poolId;

    address[] public earnedToWantPath;
    // address public oracle;

    // uint256 public swapSlippage;


    constructor(
        address _wantAddress,
        address _jMiMAddress,
        address _traderJoeRouterAddress,
        // address _oracle,
        // uint256 _poolId,
        address[] memory _earnedToWantPath
        // uint256 _swapSlippage
    ) public {
        wantAddress = _wantAddress;
        jMiMAddress = _jMiMAddress;
        // poolId = _poolId;
        earnedToWantPath = _earnedToWantPath;
        // oracle = _oracle;
        // swapSlippage = _swapSlippage;
        traderJoeRouterAddress = _traderJoeRouterAddress;
    }

    function stakeJoe() public  {
        IJoetroller(joetrollerAddress).claimReward(0, address(this));
        uint256 stakeAmt = IERC20(joeAddress).balanceOf(address(this));

        IERC20(joeAddress).safeApprove(joeBarAddress, stakeAmt);
        IXJoe(joeBarAddress).enter(stakeAmt);
    }

    function deposit(uint256 _wantAmt) public  {
        IERC20(wantAddress).safeTransferFrom(address(msg.sender), address(this), _wantAmt);

        _deposit(_wantAmt);
    }

    function _deposit(uint256 _wantAmt) internal {
        // Approve LendingPool contract to move your coin
        IERC20(wantAddress).safeApprove(jCollateralCapErc20DelegateAddress, _wantAmt);
        IJToken(jCollateralCapErc20DelegateAddress).mint(_wantAmt);
    }
    
    function withdraw(uint256 _minReturnWant) public onlyOwner {
        uint256 unstakeAmt = IERC20(joeBarAddress).balanceOf(address(this));
        IXJoe(joeBarAddress).leave(unstakeAmt);

        uint256 withdrawAmt = IERC20(jMiMAddress).balanceOf(address(this));
        IJToken(jCollateralCapErc20DelegateAddress).redeem(withdrawAmt);

        uint256 swapAmt = IERC20(joeAddress).balanceOf(address(this));
        IERC20(joeAddress).safeApprove(traderJoeRouterAddress, swapAmt);
        IJoeRouter(traderJoeRouterAddress).swapExactTokensForTokens(
            swapAmt,
            _minReturnWant,
            earnedToWantPath,
            address(this),
            block.timestamp.add(600)
        );

        uint256 balance = wantLockedInHere();
        IERC20(wantAddress).safeTransfer(msg.sender, balance);
    }

    function wantLockedInHere() public view returns (uint256) {
        return IERC20(wantAddress).balanceOf(address(this));
    }

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IJoeRouter {

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint[] memory amounts);

    function swapExactAVAXForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
    
}

interface IJToken {
    function mint(uint256 mintAmount) external returns (uint256);

    function mintNative() external payable returns (uint256);

    function redeem(uint256 redeemTokens) external returns (uint256);

    function redeemNative(uint256 redeemTokens) external returns (uint256);

    function balanceOf(address account) external view returns (uint256);
}

interface IJoetroller {

    function claimReward(uint8 rewardType, address holder) external;

}

interface IXJoe {
    function enter(uint256 _amount) external;

    function leave(uint256 _share) external;

    function balanceOf(address account) external view returns (uint256);
}

interface IJoePair {
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import "../interfaces/IOracle.sol";
import "../interfaces/IWonderland.sol";
import "../interfaces/ITraderJoe.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract TestWonderland is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public traderJoeRouterAddress;
    address public constant timeBondDepositoryAddress = 0x694738E0A438d90487b4a549b201142c1a97B556;
    address public constant timeStakingAddress = 0x4456B87Af11e87E329AB7d7C7A246ed1aC2168B9;
    address public constant timeAddress = 0xb54f16fB19478766A268F172C9480f8da1a7c9C3;

    address public wantAddress;
    address public memoAddress;
    uint256 public poolId;

    address[] public earnedToWantPath;
    // address public oracle;

    // uint256 public swapSlippage;


    constructor(
        address _wantAddress,
        address _memoAddress,
        address _traderJoeRouterAddress,
        // address _oracle,
        // uint256 _poolId,
        address[] memory _earnedToWantPath
        // uint256 _swapSlippage
    ) public {
        wantAddress = _wantAddress;
        memoAddress = _memoAddress;
        // poolId = _poolId;
        earnedToWantPath = _earnedToWantPath;
        // oracle = _oracle;
        // swapSlippage = _swapSlippage;
        traderJoeRouterAddress = _traderJoeRouterAddress;
    }

    function stake() public  {
        IBondDepository(timeBondDepositoryAddress).redeem(address(this), true);
    }

    function deposit(uint256 _wantAmt, uint256 _maxPrice) public  {
        IERC20(wantAddress).safeTransferFrom(address(msg.sender), address(this), _wantAmt); // min amount: 0.01 TIME

        _deposit(_wantAmt, _maxPrice);
    }

    function _deposit(uint256 _wantAmt, uint256 _maxPrice) internal {
        // Approve LendingPool contract to move your coin
        IERC20(wantAddress).safeApprove(timeBondDepositoryAddress, _wantAmt);
        IBondDepository(timeBondDepositoryAddress).deposit(_wantAmt, _maxPrice, address(this));

    }
    
    function withdraw(uint256 _minReturnWant, bool _trigger) public onlyOwner {

        uint256 withdrawAmt = IERC20(memoAddress).balanceOf(address(this));
        IERC20(memoAddress).safeApprove(timeStakingAddress, withdrawAmt);
        IStaking(timeStakingAddress).unstake(withdrawAmt, _trigger);

        IERC20(timeAddress).safeApprove(traderJoeRouterAddress, withdrawAmt);
        IJoeRouter(traderJoeRouterAddress).swapExactTokensForTokens(
            withdrawAmt,
            _minReturnWant,
            earnedToWantPath,
            address(this),
            block.timestamp.add(600)
        );

        uint256 balance = wantLockedInHere();
        IERC20(wantAddress).safeTransfer(msg.sender, balance);
    }

    function wantLockedInHere() public view returns (uint256) {
        return IERC20(wantAddress).balanceOf(address(this));
    }

}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;


interface IStakingHelper {
    
    function stake( uint _amount, address recipient ) external;

}

interface IStaking {

    /**
        @notice redeem sOHM for OHM
        @param _amount uint
        @param _trigger bool
     */
    function unstake( uint _amount, bool _trigger ) external;

    function claim( address _recipient ) external;

    function epoch() external view returns (uint256 number, uint256 distribute, uint32 length, uint32 endTime);

    function contractBalance() external view returns (uint256 balance);

}

interface IBondDepository {

    /**
     *  @notice initializes bond parameters
     *  @param _controlVariable uint
     *  @param _vestingTerm uint32
     *  @param _minimumPrice uint
     *  @param _maxPayout uint
     *  @param _fee uint
     *  @param _maxDebt uint
     *  @param _initialDebt uint
     */
    function initializeBondTerms( 
        uint _controlVariable, 
        uint _minimumPrice,
        uint _maxPayout,
        uint _fee,
        uint _maxDebt,
        uint _initialDebt,
        uint32 _vestingTerm
    ) external;


    /* ======== POLICY FUNCTIONS ======== */

    enum PARAMETER { VESTING, PAYOUT, FEE, DEBT, MINPRICE }
    /**
     *  @notice set parameters for new bonds
     *  @param _parameter PARAMETER
     *  @param _input uint
     */
    function setBondTerms ( PARAMETER _parameter, uint _input ) external;

    /**
     *  @notice set control variable adjustment
     *  @param _addition bool
     *  @param _increment uint
     *  @param _target uint
     *  @param _buffer uint
     */
    function setAdjustment ( 
        bool _addition,
        uint _increment, 
        uint _target,
        uint32 _buffer 
    ) external;

    /**
     *  @notice set contract for auto stake
     *  @param _staking address
     *  @param _helper bool
     */
    function setStaking( address _staking, bool _helper ) external;


    /**
     *  @notice deposit bond
     *  @param _amount uint
     *  @param _maxPrice uint
     *  @param _depositor address
     *  @return uint
     */
    function deposit( 
        uint _amount, 
        uint _maxPrice,
        address _depositor
    ) external returns ( uint );

    /** 
     *  @notice redeem bond for user
     *  @param _recipient address
     *  @param _stake bool
     *  @return uint
     */ 
    function redeem( address _recipient, bool _stake ) external returns ( uint );

    function maxPayout() external view returns ( uint );

    function payoutFor( uint _value ) external view returns ( uint );

    function bondPrice() external view returns ( uint price_ );

    function bondPriceInUSD() external view returns ( uint price_ );

    function bondInfo( address _holder) external view returns ( uint256 payout, uint256 pricePaid, uint32 lastTime, uint32 vesting );

    function debtRatio() external view returns ( uint debtRatio_ );

    function standardizedDebtRatio() external view returns ( uint );

    function currentDebt() external view returns ( uint );

    function debtDecay() external view returns ( uint decay_ );

    function percentVestedFor( address _depositor ) external view returns ( uint percentVested_ );

    function pendingPayoutFor( address _depositor ) external view returns ( uint pendingPayout_ );

    function recoverLostToken( address _token ) external returns ( bool );
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// import "../refs/CoreRef.sol";
import "../interfaces/ITraderJoe.sol";
import "../interfaces/IStargate.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";
// import "@nomiclabs/buidler/console.sol";

contract TempStrategyStargate is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address stgAddress = 0x2F6F07CDcf3588944Bf4C42aC74ff24bF56e7590;
    //////////////////////////////////////////////
    /////////////////// config ///////////////////
    //////////////////////////////////////////////
    address public inputTokenAddress = 0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7;
    address stargateLpTokenAddress = 0x29e38769f23701A2e4A8Ef0492e19dA4604Be62c;
    address[] public baseTokenToInputTokenPath = [
        stgAddress, 
        0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7, 
        0x130966628846BFd36ff31a822705796e8cb8C18D, 
        inputTokenAddress
    ];
    uint256 liquidityPoolId = 2;
    uint256 stakingPoolId = 1;
    uint256 public baseTokenSellingPrice = 120;
    bool public isInstantRedeemLp = false;



    // address public wavaxAddress;
    // address public qiTokenAddress;
    // address public qiAddress;
    // address public qiComptrollerAddress;
    address public dexRouterAddress = 0x60aE616a2155Ee3d9A68541Ba4544862310933d4;
    uint256 public swapSlippage = 1;
    bool public isSTGReward = true;
    bool public isLpRedeemed = false;

    // event SetDexRouter(address value);
    // event SetBaseTokenToInputTokenPath(address[] value);
    // event SetAvaxToInputTokenPath(address[] value);
    // event SetSlippage(uint256 value);
    // event SetOracle(address value);
    // event SetIsQiReward(bool value);
    // event SetIsAvaxReward(bool value);

    // constructor(
    //     address _core,
    //     address _inputTokenAddress,
    //     address _wavaxAddress,
    //     address _qiTokenAddress,
    //     address _qiAddress,
    //     address _qiComptrollerAddress,
    //     address _dexRouterAddress,
    //     address[] memory _baseTokenToInputTokenPath,
    //     address[] memory _avaxToInputTokenPath,
    //     uint256 _swapSlippage,
    //     address _oracle
    // ) public CoreRef(_core) {
    //     inputTokenAddress = _inputTokenAddress;
    //     wavaxAddress = _wavaxAddress;
    //     qiTokenAddress = _qiTokenAddress;
    //     qiAddress = _qiAddress;
    //     qiComptrollerAddress = _qiComptrollerAddress;
    //     dexRouterAddress = _dexRouterAddress;
    //     baseTokenToInputTokenPath = _baseTokenToInputTokenPath;
    //     avaxToInputTokenPath = _avaxToInputTokenPath;
    //     swapSlippage = _swapSlippage;
    //     oracle = _oracle;
    // }

    address stargateRouterAddress = 0x45A01E4e04F14f7A4a6702c74187c5F6222033cd;
    address stargateLpStakingAddress = 0x8731d54E9D02c286767d56ac03e8037C07e01e98;
    uint256 gasForTriggerStop = 2e16;


    function deposit(uint256 _depositAmt) public nonReentrant {
        IERC20(inputTokenAddress).safeTransferFrom(address(msg.sender), address(this), _depositAmt);
        _deposit(_depositAmt);
    }

    function _deposit(uint256 _depositAmt) internal {
        IERC20(inputTokenAddress).safeApprove(stargateRouterAddress, _depositAmt);
        IStargateRouter(stargateRouterAddress).addLiquidity(liquidityPoolId, _depositAmt, address(this));
        uint256 lpTokenBalance = IERC20(stargateLpTokenAddress).balanceOf(address(this));
        IERC20(stargateLpTokenAddress).safeApprove(stargateLpStakingAddress, lpTokenBalance);
        IStargateLpStaking(stargateLpStakingAddress).deposit(stakingPoolId, lpTokenBalance);
        isLpRedeemed = false;
    }


    function redeemLp() public nonReentrant {
        _redeemLp();
    }

    function _redeemLp() internal {
        (uint256 stakedLpBalance,) = IStargateLpStaking(stargateLpStakingAddress).userInfo(stakingPoolId, address(this));
        IStargateLpStaking(stargateLpStakingAddress).withdraw(stakingPoolId, stakedLpBalance);
        if (isInstantRedeemLp == true) {
            IStargateRouter(stargateRouterAddress).instantRedeemLocal(uint16(liquidityPoolId), stakedLpBalance, address(this));
        } else {
            require(address(this).balance > gasForTriggerStop, "not enough gas!");
            // IStargateRouter(stargateRouterAddress).redeemLocal{ value: gasForTriggerStop }(9, 1, 1, payable(address(this)), stakedLpBalance, abi.encodePacked(address(this)), lzTxParams);
            (bool success, ) = address(stargateRouterAddress).call{ value: gasForTriggerStop }(abi.encodeWithSelector(
                bytes4(keccak256("redeemLocal(uint16,uint256,uint256,address,uint256,bytes,(uint256,uint256,bytes))")), 9, liquidityPoolId, liquidityPoolId, payable(address(this)), stakedLpBalance, abi.encodePacked(address(this)), abi.encode(0, 0, abi.encodePacked(address(this)))
            ));
            require(success == true, "redeemLocal failed!");
        }
        isLpRedeemed = true;
    }

    function withdraw() public nonReentrant {
        if (isInstantRedeemLp == true) {
            _redeemLp();
        }
        require(isLpRedeemed == true, "LP not yet redeemed!");
        if (isSTGReward == true) {
            uint256 swapAmt = IERC20(stgAddress).balanceOf(address(this));
            IERC20(stgAddress).safeApprove(dexRouterAddress, swapAmt);
            uint256 minReturnWant = _calculateMinInputTokenReturn(swapAmt);
            IJoeRouter(dexRouterAddress).swapExactTokensForTokens(
                swapAmt,
                minReturnWant,
                baseTokenToInputTokenPath,
                address(this),
                block.timestamp
            );
        }

        IERC20(inputTokenAddress).safeTransfer(msg.sender, IERC20(inputTokenAddress).balanceOf(address(this)));
    }

    function _calculateMinInputTokenReturn(uint256 amount) internal view returns (uint256 minReturn) {
        uint256 total = amount.mul(baseTokenSellingPrice).div(100).div(1e12);
        minReturn = total.mul(100 - swapSlippage).div(100);
    }

    function setBaseTokenSellingPrice(uint256 _baseTokenSellingPrice) public {
        // 2 decimal number
        baseTokenSellingPrice = _baseTokenSellingPrice;
    }

    function setGasForTriggerStop(uint256 _gasForTriggerStop) public {
        gasForTriggerStop = _gasForTriggerStop;
    }

    function setIsInstantRedeemLp(bool _isInstantRedeemLp) public {
        isInstantRedeemLp = _isInstantRedeemLp;
    }

    fallback() external payable {}

    receive() external payable {}
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface IStargateRouter {
    function addLiquidity(uint256 poolId, uint256 amountLD, address to) external;
    function instantRedeemLocal(uint16 _srcPoolId, uint256 _amountLP, address _to) external returns (uint256 amountSD);
}

interface IStargateLpStaking {
    function deposit(uint256 pid, uint256 amount) external;
    function withdraw(uint256 pid, uint256 amount) external;
    function userInfo(uint256 pid, address userAddress) external view returns (uint256 amount, uint256 rewardDebt);
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../refs/CoreRef.sol";
import "../interfaces/IOracle.sol";
import "../interfaces/ITraderJoe.sol";
import "../interfaces/IStargate.sol";
import "../interfaces/ITrancheMasterAuto.sol";
// import "hardhat/console.sol";

contract StrategyStargate is ReentrancyGuard, Ownable, CoreRef {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    
    address public inputTokenAddress;
    address public stargateLpStakingAddress;
    address public stargateLpTokenAddress;
    address public stgAddress;
    address public stargateRouterAddress;
    address public dexRouterAddress;
    address public trancheMasterAddress;
    address[] public baseTokenToInputTokenPath;
    uint256 public swapSlippage;
    uint256 public liquidityPoolId;
    uint256 public stakingPoolId;
    uint256 public baseTokenSellingPrice;
    uint256 public gasForTriggerStop = 2e16;
    address public oracle;
    bool public isSTGReward = true;
    bool public isInstantRedeemLp = true;
    bool public isLpRedeemed = false;

    event SetBaseTokenSellingPrice(uint256 value);
    event SetGasForTriggerStop(uint256 value);
    event SetDexRouter(address value);
    event SetBaseTokenToInputTokenPath(address[] value);
    event SetSlippage(uint256 value);
    event SetOracle(address value);
    event SetIsSTGReward(bool value);
    event SetIsInstantRedeemLp(bool value);
    event SetTrancheMaster(address value);

    constructor(
        address _core,
        address _inputTokenAddress,
        address _stargateLpStakingAddress,
        address _stargateLpTokenAddress,
        address _stgAddress,
        address _stargateRouterAddress,
        address _dexRouterAddress,
        address[] memory _baseTokenToInputTokenPath,
        uint256 _swapSlippage,
        uint256 _liquidityPoolId,
        uint256 _stakingPoolId,
        address _oracle
    ) public CoreRef(_core) {
        inputTokenAddress = _inputTokenAddress;
        stargateLpStakingAddress = _stargateLpStakingAddress;
        stargateLpTokenAddress = _stargateLpTokenAddress;
        stgAddress = _stgAddress;
        stargateRouterAddress = _stargateRouterAddress;
        dexRouterAddress = _dexRouterAddress;
        baseTokenToInputTokenPath = _baseTokenToInputTokenPath;
        swapSlippage = _swapSlippage;
        liquidityPoolId = _liquidityPoolId;
        stakingPoolId = _stakingPoolId;
        oracle = _oracle;
    }

    function deposit(uint256 _depositAmt) public onlyMultistrategy nonReentrant whenNotPaused {
        IERC20(inputTokenAddress).safeTransferFrom(address(msg.sender), address(this), _depositAmt);
        _deposit(_depositAmt);
    }

    function _deposit(uint256 _depositAmt) internal {
        IERC20(inputTokenAddress).safeApprove(stargateRouterAddress, _depositAmt);
        IStargateRouter(stargateRouterAddress).addLiquidity(liquidityPoolId, _depositAmt, address(this));
        uint256 lpTokenBalance = IERC20(stargateLpTokenAddress).balanceOf(address(this));
        IERC20(stargateLpTokenAddress).safeApprove(stargateLpStakingAddress, lpTokenBalance);
        IStargateLpStaking(stargateLpStakingAddress).deposit(stakingPoolId, lpTokenBalance);
        isLpRedeemed = false;
    }


    function redeemLp() public onlyGovernor nonReentrant {
        require(block.timestamp >= ITrancheMasterAuto(trancheMasterAddress).actualStartAt() + ITrancheMasterAuto(trancheMasterAddress).duration(), "cycle not expired");
        _redeemLp();
    }

    function _redeemLp() internal {
        (uint256 stakedLpBalance,) = IStargateLpStaking(stargateLpStakingAddress).userInfo(stakingPoolId, address(this));
        IStargateLpStaking(stargateLpStakingAddress).withdraw(stakingPoolId, stakedLpBalance);
        if (isInstantRedeemLp == true) {
            IStargateRouter(stargateRouterAddress).instantRedeemLocal(uint16(liquidityPoolId), stakedLpBalance, address(this));
        } else {
            require(address(this).balance > gasForTriggerStop, "not enough gas!");
            // IStargateRouter(stargateRouterAddress).redeemLocal{ value: gasForTriggerStop }(9, liquidityPoolId, liquidityPoolId, payable(address(this)), stakedLpBalance, abi.encodePacked(address(this)), lzTxParams);
            (bool success, ) = address(stargateRouterAddress).call{ value: gasForTriggerStop }(abi.encodeWithSelector(
                bytes4(keccak256("redeemLocal(uint16,uint256,uint256,address,uint256,bytes,(uint256,uint256,bytes))")), 9, liquidityPoolId, liquidityPoolId, payable(address(this)), stakedLpBalance, abi.encodePacked(address(this)), abi.encode(0, 0, abi.encodePacked(address(this)))
            ));
            require(success == true, "redeemLocal failed!");
        }
        isLpRedeemed = true;
    }

    function withdraw() public onlyMultistrategy nonReentrant {
        if (isInstantRedeemLp == true) {
            _redeemLp();
        }
        require(isLpRedeemed == true, "LP not yet redeemed!");
        require(IERC20(inputTokenAddress).balanceOf(address(this)) > 0, "inputToken not yet received!");
        uint256 swapAmt = IERC20(stgAddress).balanceOf(address(this));
        uint256 minReturnWant = _calculateMinReturn(swapAmt);
        if (isSTGReward == true && minReturnWant > 0) {
            IERC20(stgAddress).safeApprove(dexRouterAddress, swapAmt);
            IJoeRouter(dexRouterAddress).swapExactTokensForTokens(
                swapAmt,
                minReturnWant,
                baseTokenToInputTokenPath,
                address(this),
                block.timestamp
            );
        }

        IERC20(inputTokenAddress).safeTransfer(msg.sender, IERC20(inputTokenAddress).balanceOf(address(this)));
    }

    // function _calculateMinReturn(uint256 amount) internal view returns (uint256 minReturn) {
    //     uint256 total = amount.mul(baseTokenSellingPrice).div(100);
    //     minReturn = total.mul(100 - swapSlippage).div(100);
    // }

    // below allow deposit of different inputTokens with different decimals
    struct CalculateMinReturnVal {
        uint256 oraclePriceUsdPerRewardToken;
        uint256 oraclePriceUsdPerInputToken;
        uint8 baseDecimalsRewardToken;
        uint8 baseDecimalsInputToken;
        uint256 exponent;
    }
    function _calculateMinReturn(uint256 _amount) internal view returns (uint256 minReturn) {
        CalculateMinReturnVal memory c;
        c.oraclePriceUsdPerRewardToken = baseTokenSellingPrice;
        c.oraclePriceUsdPerInputToken = IOracle(oracle).getLatestPrice(inputTokenAddress);
        c.baseDecimalsRewardToken = 18;
        (,c.baseDecimalsInputToken) = IOracle(oracle).feeds(inputTokenAddress);

        if (c.baseDecimalsRewardToken == c.baseDecimalsInputToken) {
            minReturn =  _amount.mul(c.oraclePriceUsdPerRewardToken).mul(100 - swapSlippage).div(100).div(c.oraclePriceUsdPerInputToken);
        } else if (c.baseDecimalsRewardToken > c.baseDecimalsInputToken) {
            c.exponent = (uint256(c.baseDecimalsRewardToken).sub(uint256(c.baseDecimalsInputToken))).mul(2);
            minReturn =  _amount.mul(c.oraclePriceUsdPerRewardToken)
                        .mul(100 - swapSlippage).div(100)
                        .div( 10**c.exponent ).div(c.oraclePriceUsdPerInputToken);
        } else if (c.baseDecimalsRewardToken < c.baseDecimalsInputToken) {
            c.exponent = (uint256(c.baseDecimalsInputToken).sub(uint256(c.baseDecimalsRewardToken))).mul(2);
            minReturn =  _amount.mul(c.oraclePriceUsdPerRewardToken).mul( 10**c.exponent )
                        .mul(100 - swapSlippage).div(100)
                        .div(c.oraclePriceUsdPerInputToken);
        }
    }

    function setBaseTokenSellingPrice(uint256 _baseTokenSellingPrice) public onlyGovernor {
        // 2 decimal number
        baseTokenSellingPrice = _baseTokenSellingPrice.mul(1e16);
        emit SetBaseTokenSellingPrice(_baseTokenSellingPrice);
    }

    function setGasForTriggerStop(uint256 _gasForTriggerStop) public onlyGovernor {
        gasForTriggerStop = _gasForTriggerStop;
        emit SetGasForTriggerStop(_gasForTriggerStop);
    }

    function setDexRouter(address _dexRouterAddress) public onlyTimelock onlyNonZeroAddress(_dexRouterAddress) {
        dexRouterAddress = _dexRouterAddress;
        emit SetDexRouter(_dexRouterAddress);
    }

    function setBaseTokenToInputTokenPath(address[] calldata _baseTokenToInputTokenPath) public onlyTimelock onlyNonZeroAddressArray(_baseTokenToInputTokenPath) {
        baseTokenToInputTokenPath = _baseTokenToInputTokenPath;
        emit SetBaseTokenToInputTokenPath(_baseTokenToInputTokenPath);
    }

    function setTrancheMaster(address _trancheMasterAddress) public onlyGovernor onlyNonZeroAddress(_trancheMasterAddress) {
        trancheMasterAddress = _trancheMasterAddress;
        emit SetTrancheMaster(_trancheMasterAddress);
    }

    function setSlippage(uint256 _swapSlippage) public onlyGovernor {
        require(_swapSlippage < 10, "Slippage value is too big");
        swapSlippage = _swapSlippage;
        emit SetSlippage(_swapSlippage);
    }

    function setOracle(address _oracle) public onlyTimelock onlyNonZeroAddress(_oracle) {
        oracle = _oracle;
        emit SetOracle(_oracle);
    }

    function setIsSTGReward(bool _isSTGReward) public onlyGovernor {
        isSTGReward = _isSTGReward;
        emit SetIsSTGReward(_isSTGReward);
    }

    function setIsInstantRedeemLp(bool _isInstantRedeemLp) public onlyGovernor {
        isInstantRedeemLp = _isInstantRedeemLp;
        emit SetIsInstantRedeemLp(_isInstantRedeemLp);
    }

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) public onlyTimelock {
        require(_token != inputTokenAddress, "!safe");
        require(_token != stargateLpTokenAddress, "!safe");
        require(_token != stgAddress, "!safe");
        IERC20(_token).safeTransfer(_to, _amount);
    }

    fallback() external payable {}

    receive() external payable {}
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface ITrancheMasterAuto {
    function setDuration(uint256 _duration) external;

    function setDevAddress(address _devAddress) external;

    function add(
        uint256 target,
        uint256 apy,
        uint256 fee,
        bool principalFee
    ) external;

    function set(
        uint256 tid,
        uint256 target,
        uint256 apy,
        uint256 fee,
        bool principalFee
    ) external;

    function balanceOf(address account) external view returns (uint256 balance, uint256 invested);

    function switchAuto(bool _auto) external;

    function investDirect(
        uint256 amountIn,
        uint256 tid,
        uint256 amountInvest
    ) external payable;

    function deposit(uint256 amount) external payable;

    function invest(
        uint256 tid,
        uint256 amount,
        bool returnLeft
    ) external;

    function redeem(uint256 tid) external;

    function redeemDirect(uint256 tid) external;

    function withdraw(uint256 amount) external;

    function stop() external;

    function setStaker(address _staker) external;

    function setStrategy(address _strategy) external;

    function withdrawFee(uint256 amount) external;

    function transferFeeToStaking(uint256 _amount, address _pool) external;

    function producedFee() external view returns (uint256);

    function duration() external view returns (uint256);

    function cycle() external view returns (uint256);

    function actualStartAt() external view returns (uint256);

    function active() external view returns (bool);

    function tranches(uint256 id)
        external
        view
        returns (
            uint256 target,
            uint256 principal,
            uint256 autoPrincipal,
            uint256 validPercent,
            uint256 apy,
            uint256 fee,
            uint256 autoValid,
            bool principalFee
        );

    function currency() external view returns (address);

    function staker() external view returns (address);

    function strategy() external view returns (address);

    function devAddress() external view returns (address);

    function userInfo(address account) external view returns (uint256, bool);

    function userInvest(address account, uint256 tid)
        external
        view
        returns (
            uint256 cycle,
            uint256 principal,
            bool rebalanced
        );

    function trancheSnapshots(uint256 cycle, uint256 tid)
        external
        view
        returns (
            uint256 target,
            uint256 principal,
            uint256 capital,
            uint256 validPercent,
            uint256 rate,
            uint256 apy,
            uint256 fee,
            uint256 startAt,
            uint256 stopAt
        );
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../refs/CoreRef.sol";
import "../interfaces/IWonderland.sol";
import "../interfaces/ITraderJoe.sol";
import "../interfaces/ITrancheMasterAuto.sol";
// import "hardhat/console.sol";

contract StrategyWonderland is ReentrancyGuard, Ownable, CoreRef {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public inputTokenAddress;
    address public baseTokenAddress;
    address public stakedTokenAddress;
    address public bondDepositoryAddress;
    address public stakingAddress;
    address public stakingHelperAddress;
    address public dexRouterAddress;
    address public trancheMasterAddress;
    address public jlpAddress;
    address[] public inputTokenToBaseTokenPath;
    address[] public baseTokenToInputTokenPath;
    uint256 public swapSlippage;
    uint256 public baseTokenBuyingPrice;
    uint256 public baseTokenSellingPrice;
    bool public isMint = true;

    event SetIsMint(bool value);
    event SetBaseTokenBuyingPrice(uint256 value);
    event SetBaseTokenSellingPrice(uint256 value);
    event SetDexRouter(address value);
    event SetTrancheMaster(address value);
    event SetJlp(address value);
    event SetInputTokenToBaseTokenPath(address[] value);
    event SetBaseTokenToInputTokenPath(address[] value);
    event SetSlippage(uint256 value);

    constructor(
        address _core,
        address _inputTokenAddress,
        address _baseTokenAddress,
        address _stakedTokenAddress,
        address _bondDepositoryAddress,
        address _stakingAddress,
        address _stakingHelperAddress,
        address _dexRouterAddress,
        address _jlpAddress,
        address[] memory _inputTokenToBaseTokenPath,
        address[] memory _baseTokenToInputTokenPath,
        uint256 _swapSlippage
    ) public CoreRef(_core) {
        inputTokenAddress = _inputTokenAddress;
        baseTokenAddress = _baseTokenAddress;
        stakedTokenAddress = _stakedTokenAddress;
        bondDepositoryAddress = _bondDepositoryAddress;
        stakingAddress = _stakingAddress;
        stakingHelperAddress = _stakingHelperAddress;
        dexRouterAddress = _dexRouterAddress;
        jlpAddress = _jlpAddress;
        inputTokenToBaseTokenPath = _inputTokenToBaseTokenPath;
        baseTokenToInputTokenPath = _baseTokenToInputTokenPath;
        swapSlippage = _swapSlippage;
    }

    function stake() public nonReentrant whenNotPaused {
        IBondDepository(bondDepositoryAddress).redeem(address(this), true);
    }

    function deposit(uint256 _depositAmt) public onlyMultistrategy nonReentrant whenNotPaused {
        IERC20(inputTokenAddress).safeTransferFrom(address(msg.sender), address(this), _depositAmt);
        if(isMint == true && _calculateExpectedReturn(0, _depositAmt) > _calculateExpectedReturn(1, _depositAmt)) {
            _mint(_depositAmt);
        } else {
            _buyAndStake(_depositAmt);
        }
    }

    /**
     * @param _type  0: mint, 1: swap
     */
    function _calculateExpectedReturn(uint256 _type, uint256 _depositAmt) internal view returns(uint256) {
        uint output;
        if (_type == 0) {
            output = _expectedStakingReturn(_type, _depositAmt, 1).add(
            _expectedStakingReturn(_type, _depositAmt, 2)).add(
            _expectedStakingReturn(_type, _depositAmt, 3)).add(
            _expectedStakingReturn(_type, _depositAmt, 4)).add(
            _expectedStakingReturn(_type, _depositAmt, 5));
        } else if (_type == 1) {
            output = _expectedStakingReturn(_type, _depositAmt, 0);
        }
        return output;
    }

    struct ReturnVal {
        uint256 totalStakingReward;
        uint256 stakingContractBalance;
        uint112 baseTokenDexReserve;
        uint112 inputTokenDexReserve;
        uint112 temp;
        uint256 buyingPrice;
        uint256 epochPerDay;
        uint256 trancheDuration;
        uint256 totalStakingEpoch;
    }
    function _expectedStakingReturn(uint256 _type, uint256 _depositAmt, uint256 _day) internal view returns(uint256) {
        ReturnVal memory r;
        (,r.totalStakingReward,,) = IStaking(stakingAddress).epoch();
        r.stakingContractBalance = IStaking(stakingAddress).contractBalance();
        (r.baseTokenDexReserve, r.inputTokenDexReserve,) = IJoePair(jlpAddress).getReserves();
        if(r.baseTokenDexReserve > r.inputTokenDexReserve) {
            r.temp = r.baseTokenDexReserve;
            r.baseTokenDexReserve = r.inputTokenDexReserve;
            r.inputTokenDexReserve = r.temp;
        }
        r.epochPerDay = 3;
        r.trancheDuration = ITrancheMasterAuto(trancheMasterAddress).duration();
        if (_type == 0) {
            r.buyingPrice = IBondDepository(bondDepositoryAddress).bondPrice();
            // r.trancheDuration must be > 6*3600*24, otherwise results in error
            r.totalStakingEpoch = r.epochPerDay.mul(r.trancheDuration.div(86400).sub(_day));
        } else if (_type == 1) {
            // if r.baseTokenDexReserve > r.inputTokenDexReserve, r.buyingPrice will be < 0 which is = 0 after truncating decimals
            // 1003 / 1000 refer to 0.3% fee for dex trade
            r.buyingPrice = _depositAmt.mul(1003).div(1000).div(uint256(r.baseTokenDexReserve).sub( uint256(r.baseTokenDexReserve).mul(uint256(r.inputTokenDexReserve)).div(r.inputTokenDexReserve + _depositAmt) )).div(1e7);
            r.totalStakingEpoch = r.epochPerDay.mul(r.trancheDuration).div(86400);
        }

        uint256 output = _depositAmt.mul( r.stakingContractBalance.add(r.totalStakingReward) ).div(r.stakingContractBalance);
        // overflow if put all multiplication before division
        for (uint256 i = 0; i < r.totalStakingEpoch - 1; i++) {
            output = output.mul( r.stakingContractBalance.add(r.totalStakingReward) ).div(r.stakingContractBalance);
        }
        output = output.div( r.buyingPrice ).div(1e7);

        if (_type == 0) {
            return output.div(5);
        } else if (_type == 1) {
            return output;
        }
    }

    function _mint(uint256 _depositAmt) internal {
        IERC20(inputTokenAddress).safeApprove(bondDepositoryAddress, _depositAmt);
        IBondDepository(bondDepositoryAddress).deposit(_depositAmt, baseTokenBuyingPrice, address(this));
    }

    function _buyAndStake(uint256 _depositAmt) internal {
        uint256 minReturnWant = _calculateMinBaseTokenReturn(_depositAmt);
        IERC20(inputTokenAddress).safeApprove(dexRouterAddress, _depositAmt);
        IJoeRouter(dexRouterAddress).swapExactTokensForTokens(
            _depositAmt,
            minReturnWant,
            inputTokenToBaseTokenPath,
            address(this),
            block.timestamp
        );
        uint256 baseTokenBalance = IERC20(baseTokenAddress).balanceOf(address(this));
        IERC20(baseTokenAddress).safeApprove(stakingHelperAddress, baseTokenBalance);
        IStakingHelper(stakingHelperAddress).stake(baseTokenBalance, address(this));
    }
    
    function withdraw() public onlyMultistrategy nonReentrant {
        (uint256 payout,,,) = IBondDepository(bondDepositoryAddress).bondInfo(address(this));
        if (payout > 0) {
            IBondDepository(bondDepositoryAddress).redeem(address(this), false);
        }
        IStaking(stakingAddress).claim(address(this));
        uint256 withdrawAmt = IERC20(stakedTokenAddress).balanceOf(address(this));
        IERC20(stakedTokenAddress).safeApprove(stakingAddress, withdrawAmt);
        IStaking(stakingAddress).unstake(withdrawAmt, true); // set true to trigger rebase to update staked token balance but user can only withdraw updated amount after the call
        
        withdrawAmt = IERC20(baseTokenAddress).balanceOf(address(this));
        IERC20(baseTokenAddress).safeApprove(dexRouterAddress, withdrawAmt);
        uint256 minReturnWant = _calculateMinInputTokenReturn(withdrawAmt);
        IJoeRouter(dexRouterAddress).swapExactTokensForTokens(
            withdrawAmt,
            minReturnWant,
            baseTokenToInputTokenPath,
            address(this),
            block.timestamp
        );

        IERC20(inputTokenAddress).safeTransfer(msg.sender, IERC20(inputTokenAddress).balanceOf(address(this)));
    }

    function _calculateMinInputTokenReturn(uint256 amount) internal view returns (uint256 minReturn) {
        // uint256 total = amount.mul(baseTokenSellingPrice).div(1e5); // for usdc
        uint256 total = amount.mul(baseTokenSellingPrice).mul(1e7); // amount * 10^9 * baseTokenSellingPrice * 10^16 / 10^18
        minReturn = total.mul(100 - swapSlippage).div(100);
    }

    function _calculateMinBaseTokenReturn(uint256 amount) internal view returns (uint256 minReturn) {
        // uint256 total = amount.mul(1e5).div(baseTokenBuyingPrice); // for usdc
        minReturn = amount.mul(100 - swapSlippage).div(100).div(baseTokenBuyingPrice.mul(1e7));
    }
    
    function setIsMint(bool _isMint) public onlyGovernor {
        isMint = _isMint;
        emit SetIsMint(_isMint);
    }

    function setBaseTokenBuyingPrice(uint256 _baseTokenBuyingPrice) public onlyGovernor {
        // 2 decimal number
        baseTokenBuyingPrice = _baseTokenBuyingPrice;
        emit SetBaseTokenBuyingPrice(_baseTokenBuyingPrice);
    }

    function setBaseTokenSellingPrice(uint256 _baseTokenSellingPrice) public onlyGovernor {
        // 2 decimal number
        baseTokenSellingPrice = _baseTokenSellingPrice;
        emit SetBaseTokenSellingPrice(_baseTokenSellingPrice);
    }

    function setDexRouter(address _dexRouterAddress) public onlyTimelock onlyNonZeroAddress(_dexRouterAddress) {
        dexRouterAddress = _dexRouterAddress;
        emit SetDexRouter(_dexRouterAddress);
    }

    function setTrancheMaster(address _trancheMasterAddress) public onlyGovernor onlyNonZeroAddress(_trancheMasterAddress) {
        trancheMasterAddress = _trancheMasterAddress;
        emit SetTrancheMaster(_trancheMasterAddress);
    }

    function setJlp(address _jlpAddress) public onlyGovernor onlyNonZeroAddress(_jlpAddress) {
        jlpAddress = _jlpAddress;
        emit SetJlp(_jlpAddress);
    }

    function setInputTokenToBaseTokenPath(address[] calldata _inputTokenToBaseTokenPath) public onlyTimelock onlyNonZeroAddressArray(_inputTokenToBaseTokenPath) {
        inputTokenToBaseTokenPath = _inputTokenToBaseTokenPath;
        emit SetInputTokenToBaseTokenPath(_inputTokenToBaseTokenPath);
    }

    function setBaseTokenToInputTokenPath(address[] calldata _baseTokenToInputTokenPath) public onlyTimelock onlyNonZeroAddressArray(_baseTokenToInputTokenPath) {
        baseTokenToInputTokenPath = _baseTokenToInputTokenPath;
        emit SetBaseTokenToInputTokenPath(_baseTokenToInputTokenPath);
    }

    function setSlippage(uint256 _swapSlippage) public onlyGovernor {
        require(_swapSlippage < 10, "Slippage value is too big");
        swapSlippage = _swapSlippage;
        emit SetSlippage(_swapSlippage);
    }

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) public onlyTimelock {
        require(_token != inputTokenAddress, "!safe");
        require(_token != baseTokenAddress, "!safe");
        require(_token != stakedTokenAddress, "!safe");
        IERC20(_token).safeTransfer(_to, _amount);
    }

}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../interfaces/IStrategy.sol";
import "../interfaces/IPancakeRouter02.sol";
import "../refs/CoreRef.sol";
import "../interfaces/ILendingPoolAddressesProvider.sol";
import "../interfaces/ILendingPool.sol";

abstract contract LendingPoolAddressesProvider is ILendingPoolAddressesProvider {}

abstract contract LendingPool is ILendingPool {}

contract StrategyAave is IStrategyAlpaca, ReentrancyGuard, Ownable, CoreRef {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 public override lastEarnBlock;

    address public override uniRouterAddress;

    // address public constant lendingPoolAddressesProviderAddress = 0x88757f2f99175387aB4C6a4b3067c77A695b0349; // eth_kovan
    address public constant lendingPoolAddressesProviderAddress = 0x7fdC1FdF79BE3309bf82f4abdAD9f111A6590C0f; // avax_fuji

    // address public constant alpacaAddress = 0x8F0528cE5eF7B51152A59745bEfDD91D97091d2F;

    // address public constant fairLaunchAddress = 0xA625AB01B08ce023B2a342Dbb12a16f2C8489A8F;

    address public alpacaAddress;
    address public fairLaunchAddress;

    // address public override vaultAddress;
    address public override wantAddress;
    address public aTokenAddress;
    uint256 public override poolId;

    // address[] public override earnedToWantPath;


    constructor(
        address _core,
        // address _vaultAddress,
        address _wantAddress,
        address _aTokenAddress,
        // address _uniRouterAddress,
        // address _alpacaAddress,
        // address _fairLaunchAddress,
        uint256 _poolId
        // address[] memory _earnedToWantPath
    ) public CoreRef(_core) {
        // vaultAddress = _vaultAddress;
        wantAddress = _wantAddress;
        aTokenAddress = _aTokenAddress;
        poolId = _poolId;
        // earnedToWantPath = _earnedToWantPath;
        // uniRouterAddress = _uniRouterAddress;
        // alpacaAddress = _alpacaAddress;
        // fairLaunchAddress = _fairLaunchAddress;

        // IERC20(alpacaAddress).safeApprove(uniRouterAddress, uint256(-1));
        // IERC20(_wantAddress).safeApprove(uniRouterAddress, uint256(-1));
        // IERC20(_wantAddress).safeApprove(vaultAddress, uint256(-1));
        // IERC20(vaultAddress).safeApprove(fairLaunchAddress, uint256(-1));
    }

    function deposit(uint256 _wantAmt) public override nonReentrant whenNotPaused {
        IERC20(wantAddress).safeTransferFrom(address(msg.sender), address(this), _wantAmt);

        _deposit(wantLockedInHere());
    }

    function _deposit(uint256 _wantAmt) internal {
        LendingPoolAddressesProvider provider = LendingPoolAddressesProvider(lendingPoolAddressesProviderAddress);
        LendingPool lendingPool = LendingPool(provider.getLendingPool());

        // Approve LendingPool contract to move your coin
        IERC20(wantAddress).safeApprove(provider.getLendingPool(), _wantAmt);
        lendingPool.deposit(wantAddress, _wantAmt, address(this), 0);

        // can we stake aToken?
    }

    function earn() public override whenNotPaused onlyTimelock {
        // FairLaunch(fairLaunchAddress).harvest(poolId);

        uint256 earnedAmt = IERC20(alpacaAddress).balanceOf(address(this));
        // if (alpacaAddress != wantAddress && earnedAmt != 0) {
        //     IPancakeRouter02(uniRouterAddress).swapExactTokensForTokens(
        //         earnedAmt,
        //         minReturnWant,
        //         earnedToWantPath,
        //         address(this),
        //         now.add(600)
        //     );
        // }

        earnedAmt = wantLockedInHere();
        if (earnedAmt != 0) {
            _deposit(earnedAmt);
        }

        lastEarnBlock = block.number;
    }

    
    function withdraw() public override onlyMultistrategy nonReentrant {
        LendingPoolAddressesProvider provider = LendingPoolAddressesProvider(lendingPoolAddressesProviderAddress);
        LendingPool lendingPool = LendingPool(provider.getLendingPool());

        lendingPool.withdraw(wantAddress, IERC20(aTokenAddress).balanceOf(address(this)) , address(this));

        uint256 balance = wantLockedInHere();
        IERC20(wantAddress).safeTransfer(msg.sender, balance);
    }

    function _pause() internal override {
        super._pause();
        IERC20(alpacaAddress).safeApprove(uniRouterAddress, 0);
        IERC20(wantAddress).safeApprove(uniRouterAddress, 0);
        // IERC20(wantAddress).safeApprove(vaultAddress, 0);
    }

    function _unpause() internal override {
        super._unpause();
        IERC20(alpacaAddress).safeApprove(uniRouterAddress, uint256(-1));
        IERC20(wantAddress).safeApprove(uniRouterAddress, uint256(-1));
        // IERC20(wantAddress).safeApprove(vaultAddress, uint256(-1));
    }

    function wantLockedInHere() public view override returns (uint256) {
        return IERC20(wantAddress).balanceOf(address(this));
    }

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) public override onlyTimelock {
        require(_token != alpacaAddress, "!safe");
        require(_token != wantAddress, "!safe");
        // require(_token != vaultAddress, "!safe");
        IERC20(_token).safeTransfer(_to, _amount);
    }

    function updateStrategy() public override {}

    function vaultAddress() public view override returns (address) {}
    function earnedToWantPath(uint256 idx) public view override returns (address) {}
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity >=0.6.0 <0.8.0;

/**
 * @title LendingPoolAddressesProvider contract
 * @dev Main registry of addresses part of or connected to the protocol, including permissioned roles
 * - Acting also as factory of proxies and admin of those, so with right to change its implementations
 * - Owned by the Aave Governance
 * @author Aave
 **/
interface ILendingPoolAddressesProvider {
  event MarketIdSet(string newMarketId);
  event LendingPoolUpdated(address indexed newAddress);
  event ConfigurationAdminUpdated(address indexed newAddress);
  event EmergencyAdminUpdated(address indexed newAddress);
  event LendingPoolConfiguratorUpdated(address indexed newAddress);
  event LendingPoolCollateralManagerUpdated(address indexed newAddress);
  event PriceOracleUpdated(address indexed newAddress);
  event LendingRateOracleUpdated(address indexed newAddress);
  event ProxyCreated(bytes32 id, address indexed newAddress);
  event AddressSet(bytes32 id, address indexed newAddress, bool hasProxy);

  function getMarketId() external view returns (string memory);

  function setMarketId(string calldata marketId) external;

  function setAddress(bytes32 id, address newAddress) external;

  function setAddressAsProxy(bytes32 id, address impl) external;

  function getAddress(bytes32 id) external view returns (address);

  function getLendingPool() external view returns (address);

  function setLendingPoolImpl(address pool) external;

  function getLendingPoolConfigurator() external view returns (address);

  function setLendingPoolConfiguratorImpl(address configurator) external;

  function getLendingPoolCollateralManager() external view returns (address);

  function setLendingPoolCollateralManager(address manager) external;

  function getPoolAdmin() external view returns (address);

  function setPoolAdmin(address admin) external;

  function getEmergencyAdmin() external view returns (address);

  function setEmergencyAdmin(address admin) external;

  function getPriceOracle() external view returns (address);

  function setPriceOracle(address priceOracle) external;

  function getLendingRateOracle() external view returns (address);

  function setLendingRateOracle(address lendingRateOracle) external;
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import {ILendingPoolAddressesProvider} from "./ILendingPoolAddressesProvider.sol";

library DataTypes {
  // refer to the whitepaper, section 1.1 basic concepts for a formal description of these properties.
  struct ReserveData {
    //stores the reserve configuration
    ReserveConfigurationMap configuration;
    //the liquidity index. Expressed in ray
    uint128 liquidityIndex;
    //variable borrow index. Expressed in ray
    uint128 variableBorrowIndex;
    //the current supply rate. Expressed in ray
    uint128 currentLiquidityRate;
    //the current variable borrow rate. Expressed in ray
    uint128 currentVariableBorrowRate;
    //the current stable borrow rate. Expressed in ray
    uint128 currentStableBorrowRate;
    uint40 lastUpdateTimestamp;
    //tokens addresses
    address aTokenAddress;
    address stableDebtTokenAddress;
    address variableDebtTokenAddress;
    //address of the interest rate strategy
    address interestRateStrategyAddress;
    //the id of the reserve. Represents the position in the list of the active reserves
    uint8 id;
  }

  struct ReserveConfigurationMap {
    //bit 0-15: LTV
    //bit 16-31: Liq. threshold
    //bit 32-47: Liq. bonus
    //bit 48-55: Decimals
    //bit 56: Reserve is active
    //bit 57: reserve is frozen
    //bit 58: borrowing is enabled
    //bit 59: stable rate borrowing enabled
    //bit 60-63: reserved
    //bit 64-79: reserve factor
    uint256 data;
  }

  struct UserConfigurationMap {
    uint256[2] data; // size is _maxReserves / 128 + ((_maxReserves % 128 > 0) ? 1 : 0), but need to be literal
  }

  enum InterestRateMode {NONE, STABLE, VARIABLE}
}

interface ILendingPool {
  /**
   * @dev Emitted on deposit()
   * @param reserve The address of the underlying asset of the reserve
   * @param user The address initiating the deposit
   * @param onBehalfOf The beneficiary of the deposit, receiving the aTokens
   * @param amount The amount deposited
   * @param referral The referral code used
   **/
  event Deposit(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint16 indexed referral
  );

  /**
   * @dev Emitted on withdraw()
   * @param reserve The address of the underlyng asset being withdrawn
   * @param user The address initiating the withdrawal, owner of aTokens
   * @param to Address that will receive the underlying
   * @param amount The amount to be withdrawn
   **/
  event Withdraw(address indexed reserve, address indexed user, address indexed to, uint256 amount);

  /**
   * @dev Emitted on borrow() and flashLoan() when debt needs to be opened
   * @param reserve The address of the underlying asset being borrowed
   * @param user The address of the user initiating the borrow(), receiving the funds on borrow() or just
   * initiator of the transaction on flashLoan()
   * @param onBehalfOf The address that will be getting the debt
   * @param amount The amount borrowed out
   * @param borrowRateMode The rate mode: 1 for Stable, 2 for Variable
   * @param borrowRate The numeric rate at which the user has borrowed
   * @param referral The referral code used
   **/
  event Borrow(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint256 borrowRateMode,
    uint256 borrowRate,
    uint16 indexed referral
  );

  /**
   * @dev Emitted on repay()
   * @param reserve The address of the underlying asset of the reserve
   * @param user The beneficiary of the repayment, getting his debt reduced
   * @param repayer The address of the user initiating the repay(), providing the funds
   * @param amount The amount repaid
   **/
  event Repay(
    address indexed reserve,
    address indexed user,
    address indexed repayer,
    uint256 amount
  );

  /**
   * @dev Emitted on swapBorrowRateMode()
   * @param reserve The address of the underlying asset of the reserve
   * @param user The address of the user swapping his rate mode
   * @param rateMode The rate mode that the user wants to swap to
   **/
  event Swap(address indexed reserve, address indexed user, uint256 rateMode);

  /**
   * @dev Emitted on setUserUseReserveAsCollateral()
   * @param reserve The address of the underlying asset of the reserve
   * @param user The address of the user enabling the usage as collateral
   **/
  event ReserveUsedAsCollateralEnabled(address indexed reserve, address indexed user);

  /**
   * @dev Emitted on setUserUseReserveAsCollateral()
   * @param reserve The address of the underlying asset of the reserve
   * @param user The address of the user enabling the usage as collateral
   **/
  event ReserveUsedAsCollateralDisabled(address indexed reserve, address indexed user);

  /**
   * @dev Emitted on rebalanceStableBorrowRate()
   * @param reserve The address of the underlying asset of the reserve
   * @param user The address of the user for which the rebalance has been executed
   **/
  event RebalanceStableBorrowRate(address indexed reserve, address indexed user);

  /**
   * @dev Emitted on flashLoan()
   * @param target The address of the flash loan receiver contract
   * @param initiator The address initiating the flash loan
   * @param asset The address of the asset being flash borrowed
   * @param amount The amount flash borrowed
   * @param premium The fee flash borrowed
   * @param referralCode The referral code used
   **/
  event FlashLoan(
    address indexed target,
    address indexed initiator,
    address indexed asset,
    uint256 amount,
    uint256 premium,
    uint16 referralCode
  );

  /**
   * @dev Emitted when the pause is triggered.
   */
  event Paused();

  /**
   * @dev Emitted when the pause is lifted.
   */
  event Unpaused();

  /**
   * @dev Emitted when a borrower is liquidated. This event is emitted by the LendingPool via
   * LendingPoolCollateral manager using a DELEGATECALL
   * This allows to have the events in the generated ABI for LendingPool.
   * @param collateralAsset The address of the underlying asset used as collateral, to receive as result of the liquidation
   * @param debtAsset The address of the underlying borrowed asset to be repaid with the liquidation
   * @param user The address of the borrower getting liquidated
   * @param debtToCover The debt amount of borrowed `asset` the liquidator wants to cover
   * @param liquidatedCollateralAmount The amount of collateral received by the liiquidator
   * @param liquidator The address of the liquidator
   * @param receiveAToken `true` if the liquidators wants to receive the collateral aTokens, `false` if he wants
   * to receive the underlying collateral asset directly
   **/
  event LiquidationCall(
    address indexed collateralAsset,
    address indexed debtAsset,
    address indexed user,
    uint256 debtToCover,
    uint256 liquidatedCollateralAmount,
    address liquidator,
    bool receiveAToken
  );

  /**
   * @dev Emitted when the state of a reserve is updated. NOTE: This event is actually declared
   * in the ReserveLogic library and emitted in the updateInterestRates() function. Since the function is internal,
   * the event will actually be fired by the LendingPool contract. The event is therefore replicated here so it
   * gets added to the LendingPool ABI
   * @param reserve The address of the underlying asset of the reserve
   * @param liquidityRate The new liquidity rate
   * @param stableBorrowRate The new stable borrow rate
   * @param variableBorrowRate The new variable borrow rate
   * @param liquidityIndex The new liquidity index
   * @param variableBorrowIndex The new variable borrow index
   **/
  event ReserveDataUpdated(
    address indexed reserve,
    uint256 liquidityRate,
    uint256 stableBorrowRate,
    uint256 variableBorrowRate,
    uint256 liquidityIndex,
    uint256 variableBorrowIndex
  );

  /**
   * @dev Deposits an `amount` of underlying asset into the reserve, receiving in return overlying aTokens.
   * - E.g. User deposits 100 USDC and gets in return 100 aUSDC
   * @param asset The address of the underlying asset to deposit
   * @param amount The amount to be deposited
   * @param onBehalfOf The address that will receive the aTokens, same as msg.sender if the user
   *   wants to receive them on his own wallet, or a different address if the beneficiary of aTokens
   *   is a different wallet
   * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
   *   0 if the action is executed directly by the user, without any middle-man
   **/
  function deposit(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external;

  /**
   * @dev Withdraws an `amount` of underlying asset from the reserve, burning the equivalent aTokens owned
   * E.g. User has 100 aUSDC, calls withdraw() and receives 100 USDC, burning the 100 aUSDC
   * @param asset The address of the underlying asset to withdraw
   * @param amount The underlying amount to be withdrawn
   *   - Send the value type(uint256).max in order to withdraw the whole aToken balance
   * @param to Address that will receive the underlying, same as msg.sender if the user
   *   wants to receive it on his own wallet, or a different address if the beneficiary is a
   *   different wallet
   * @return The final amount withdrawn
   **/
  function withdraw(
    address asset,
    uint256 amount,
    address to
  ) external returns (uint256);

  /**
   * @dev Allows users to borrow a specific `amount` of the reserve underlying asset, provided that the borrower
   * already deposited enough collateral, or he was given enough allowance by a credit delegator on the
   * corresponding debt token (StableDebtToken or VariableDebtToken)
   * - E.g. User borrows 100 USDC passing as `onBehalfOf` his own address, receiving the 100 USDC in his wallet
   *   and 100 stable/variable debt tokens, depending on the `interestRateMode`
   * @param asset The address of the underlying asset to borrow
   * @param amount The amount to be borrowed
   * @param interestRateMode The interest rate mode at which the user wants to borrow: 1 for Stable, 2 for Variable
   * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
   *   0 if the action is executed directly by the user, without any middle-man
   * @param onBehalfOf Address of the user who will receive the debt. Should be the address of the borrower itself
   * calling the function if he wants to borrow against his own collateral, or the address of the credit delegator
   * if he has been given credit delegation allowance
   **/
  function borrow(
    address asset,
    uint256 amount,
    uint256 interestRateMode,
    uint16 referralCode,
    address onBehalfOf
  ) external;

  /**
   * @notice Repays a borrowed `amount` on a specific reserve, burning the equivalent debt tokens owned
   * - E.g. User repays 100 USDC, burning 100 variable/stable debt tokens of the `onBehalfOf` address
   * @param asset The address of the borrowed underlying asset previously borrowed
   * @param amount The amount to repay
   * - Send the value type(uint256).max in order to repay the whole debt for `asset` on the specific `debtMode`
   * @param rateMode The interest rate mode at of the debt the user wants to repay: 1 for Stable, 2 for Variable
   * @param onBehalfOf Address of the user who will get his debt reduced/removed. Should be the address of the
   * user calling the function if he wants to reduce/remove his own debt, or the address of any other
   * other borrower whose debt should be removed
   * @return The final amount repaid
   **/
  function repay(
    address asset,
    uint256 amount,
    uint256 rateMode,
    address onBehalfOf
  ) external returns (uint256);

  /**
   * @dev Allows a borrower to swap his debt between stable and variable mode, or viceversa
   * @param asset The address of the underlying asset borrowed
   * @param rateMode The rate mode that the user wants to swap to
   **/
  function swapBorrowRateMode(address asset, uint256 rateMode) external;

  /**
   * @dev Rebalances the stable interest rate of a user to the current stable rate defined on the reserve.
   * - Users can be rebalanced if the following conditions are satisfied:
   *     1. Usage ratio is above 95%
   *     2. the current deposit APY is below REBALANCE_UP_THRESHOLD * maxVariableBorrowRate, which means that too much has been
   *        borrowed at a stable rate and depositors are not earning enough
   * @param asset The address of the underlying asset borrowed
   * @param user The address of the user to be rebalanced
   **/
  function rebalanceStableBorrowRate(address asset, address user) external;

  /**
   * @dev Allows depositors to enable/disable a specific deposited asset as collateral
   * @param asset The address of the underlying asset deposited
   * @param useAsCollateral `true` if the user wants to use the deposit as collateral, `false` otherwise
   **/
  function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external;

  /**
   * @dev Function to liquidate a non-healthy position collateral-wise, with Health Factor below 1
   * - The caller (liquidator) covers `debtToCover` amount of debt of the user getting liquidated, and receives
   *   a proportionally amount of the `collateralAsset` plus a bonus to cover market risk
   * @param collateralAsset The address of the underlying asset used as collateral, to receive as result of the liquidation
   * @param debtAsset The address of the underlying borrowed asset to be repaid with the liquidation
   * @param user The address of the borrower getting liquidated
   * @param debtToCover The debt amount of borrowed `asset` the liquidator wants to cover
   * @param receiveAToken `true` if the liquidators wants to receive the collateral aTokens, `false` if he wants
   * to receive the underlying collateral asset directly
   **/
  function liquidationCall(
    address collateralAsset,
    address debtAsset,
    address user,
    uint256 debtToCover,
    bool receiveAToken
  ) external;

  /**
   * @dev Allows smartcontracts to access the liquidity of the pool within one transaction,
   * as long as the amount taken plus a fee is returned.
   * IMPORTANT There are security concerns for developers of flashloan receiver contracts that must be kept into consideration.
   * For further details please visit https://developers.aave.com
   * @param receiverAddress The address of the contract receiving the funds, implementing the IFlashLoanReceiver interface
   * @param assets The addresses of the assets being flash-borrowed
   * @param amounts The amounts amounts being flash-borrowed
   * @param modes Types of the debt to open if the flash loan is not returned:
   *   0 -> Don't open any debt, just revert if funds can't be transferred from the receiver
   *   1 -> Open debt at stable rate for the value of the amount flash-borrowed to the `onBehalfOf` address
   *   2 -> Open debt at variable rate for the value of the amount flash-borrowed to the `onBehalfOf` address
   * @param onBehalfOf The address  that will receive the debt in the case of using on `modes` 1 or 2
   * @param params Variadic packed params to pass to the receiver as extra information
   * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
   *   0 if the action is executed directly by the user, without any middle-man
   **/
  function flashLoan(
    address receiverAddress,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint16 referralCode
  ) external;

  /**
   * @dev Returns the user account data across all the reserves
   * @param user The address of the user
   * @return totalCollateralETH the total collateral in ETH of the user
   * @return totalDebtETH the total debt in ETH of the user
   * @return availableBorrowsETH the borrowing power left of the user
   * @return currentLiquidationThreshold the liquidation threshold of the user
   * @return ltv the loan to value of the user
   * @return healthFactor the current health factor of the user
   **/
  function getUserAccountData(address user)
    external
    view
    returns (
      uint256 totalCollateralETH,
      uint256 totalDebtETH,
      uint256 availableBorrowsETH,
      uint256 currentLiquidationThreshold,
      uint256 ltv,
      uint256 healthFactor
    );

  function initReserve(
    address reserve,
    address aTokenAddress,
    address stableDebtAddress,
    address variableDebtAddress,
    address interestRateStrategyAddress
  ) external;

  function setReserveInterestRateStrategyAddress(address reserve, address rateStrategyAddress)
    external;

  function setConfiguration(address reserve, uint256 configuration) external;

  /**
   * @dev Returns the configuration of the reserve
   * @param asset The address of the underlying asset of the reserve
   * @return The configuration of the reserve
   **/
//   function getConfiguration(address asset)
//     external
//     view
//     returns (DataTypes.ReserveConfigurationMap memory);

//   /**
//    * @dev Returns the configuration of the user across all the reserves
//    * @param user The user address
//    * @return The configuration of the user
//    **/
//   function getUserConfiguration(address user)
//     external
//     view
//     returns (DataTypes.UserConfigurationMap memory);

  /**
   * @dev Returns the normalized income normalized income of the reserve
   * @param asset The address of the underlying asset of the reserve
   * @return The reserve's normalized income
   */
  function getReserveNormalizedIncome(address asset) external view returns (uint256);

  /**
   * @dev Returns the normalized variable debt per unit of asset
   * @param asset The address of the underlying asset of the reserve
   * @return The reserve normalized variable debt
   */
  function getReserveNormalizedVariableDebt(address asset) external view returns (uint256);

  /**
   * @dev Returns the state and configuration of the reserve
   * @param asset The address of the underlying asset of the reserve
   * @return The state of the reserve
   **/
  function getReserveData(address asset) external view returns (DataTypes.ReserveData memory);

  function finalizeTransfer(
    address asset,
    address from,
    address to,
    uint256 amount,
    uint256 balanceFromAfter,
    uint256 balanceToBefore
  ) external;

  function getReservesList() external view returns (address[] memory);

  function getAddressesProvider() external view returns (ILendingPoolAddressesProvider);

  function setPause(bool val) external;

  function paused() external view returns (bool);
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "../interfaces/ILendingPoolAddressesProvider.sol";
import "../interfaces/ILendingPool.sol";

abstract contract LendingPoolAddressesProvider is ILendingPoolAddressesProvider {}

abstract contract LendingPool is ILendingPool {}

contract TestAave {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public lendingPoolAddressesProviderAddress;
    address public wantAddress;
    address public aTokenAddress;

    constructor(address _wantAddress, address _aTokenAddress, address _lendingPoolAddressesProviderAddress) public {
        lendingPoolAddressesProviderAddress = _lendingPoolAddressesProviderAddress;
        wantAddress = _wantAddress;
        aTokenAddress = _aTokenAddress;
    }

    function deposit(uint256 _wantAmt) public {
        LendingPoolAddressesProvider provider = LendingPoolAddressesProvider(lendingPoolAddressesProviderAddress);
        LendingPool lendingPool = LendingPool(provider.getLendingPool());

        IERC20(wantAddress).safeTransferFrom(msg.sender, address(this), _wantAmt);

        // Approve LendingPool contract to move your DAI
        IERC20(wantAddress).safeApprove(provider.getLendingPool(), _wantAmt);
        lendingPool.deposit(wantAddress, _wantAmt, address(this), 0);

        // can we stake aToken?
    }

    function withdraw() public {
        LendingPoolAddressesProvider provider = LendingPoolAddressesProvider(lendingPoolAddressesProviderAddress);
        LendingPool lendingPool = LendingPool(provider.getLendingPool());

        // DataTypes.ReserveData memory reserveData = lendingPool.getReserveData(wantAddress);
        lendingPool.withdraw(wantAddress, IERC20(aTokenAddress).balanceOf(address(this)) , address(this));

        uint256 balance = wantLockedInHere();
        IERC20(wantAddress).safeTransfer(msg.sender, balance);
    }

    function wantLockedInHere() public view returns (uint256) {
        return IERC20(wantAddress).balanceOf(address(this));
    }

}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../refs/CoreRef.sol";
import "../interfaces/IOracle.sol";
import "../interfaces/ITraderJoe.sol";
import "../interfaces/IWAVAX.sol";
// import "hardhat/console.sol";

contract StrategyTraderJoe is ReentrancyGuard, Ownable, CoreRef {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    
    address public inputTokenAddress;
    address public wavaxAddress;
    address public jTokenAddress;
    address public joeAddress;
    address public xJoeAddress;
    address public joetrollerAddress;
    address public dexRouterAddress;
    address[] public baseTokenToInputTokenPath;
    address[] public avaxToInputTokenPath;
    uint256 public swapSlippage;
    address public oracle;
    bool public isJoeReward = false;
    bool public isAvaxReward = false;

    event SetDexRouter(address value);
    event SetBaseTokenToInputTokenPath(address[] value);
    event SetAvaxToInputTokenPath(address[] value);
    event SetSlippage(uint256 value);
    event SetOracle(address value);
    event SetIsJoeReward(bool value);
    event SetIsAvaxReward(bool value);
    event Deposit(uint256 value);

    constructor(
        address _core,
        address _inputTokenAddress,
        address _wavaxAddress,
        address _jTokenAddress,
        address _joeAddress,
        address _xJoeAddress,
        address _joetrollerAddress,
        address _dexRouterAddress,
        address[] memory _baseTokenToInputTokenPath,
        address[] memory _avaxToInputTokenPath,
        uint256 _swapSlippage,
        address _oracle
    ) public CoreRef(_core) {
        inputTokenAddress = _inputTokenAddress;
        wavaxAddress = _wavaxAddress;
        jTokenAddress = _jTokenAddress;
        joeAddress = _joeAddress;
        xJoeAddress = _xJoeAddress;
        joetrollerAddress = _joetrollerAddress;
        dexRouterAddress = _dexRouterAddress;
        baseTokenToInputTokenPath = _baseTokenToInputTokenPath;
        avaxToInputTokenPath = _avaxToInputTokenPath;
        swapSlippage = _swapSlippage;
        oracle = _oracle;
    }

    function stakeJoe() public nonReentrant whenNotPaused {
        IJoetroller(joetrollerAddress).claimReward(0, address(this));
        uint256 stakeAmt = IERC20(joeAddress).balanceOf(address(this));

        IERC20(joeAddress).safeApprove(xJoeAddress, stakeAmt);
        IXJoe(xJoeAddress).enter(stakeAmt);
    }

    function deposit(uint256 _depositAmt) public onlyMultistrategy nonReentrant whenNotPaused {
        IERC20(inputTokenAddress).safeTransferFrom(address(msg.sender), address(this), _depositAmt);
        _deposit(_depositAmt);
    }

    function _deposit(uint256 _depositAmt) internal {
        if (inputTokenAddress == wavaxAddress) {
            IWAVAX(wavaxAddress).withdraw(_depositAmt);
            IJToken(jTokenAddress).mintNative{ value: _depositAmt }();
        } else {
            IERC20(inputTokenAddress).safeApprove(jTokenAddress, _depositAmt);
            uint256 successCode = IJToken(jTokenAddress).mint(_depositAmt);
            require(successCode == 0, "jToken minting is failed!");
        }
        emit Deposit(_depositAmt);
    }

    
    function withdraw() public onlyMultistrategy nonReentrant {
        uint256 successCode;
        if (inputTokenAddress == wavaxAddress) {
            successCode = IJToken(jTokenAddress).redeemNative(IJToken(jTokenAddress).balanceOf(address(this)));
        } else {
            successCode = IJToken(jTokenAddress).redeem(IJToken(jTokenAddress).balanceOf(address(this)));
        }
        require(successCode == 0, "jToken redemption is failed!");
        if (isJoeReward == true) {
            IXJoe(xJoeAddress).leave(IXJoe(xJoeAddress).balanceOf(address(this)));
            uint256 swapAmt = IERC20(joeAddress).balanceOf(address(this));
            IERC20(joeAddress).safeApprove(dexRouterAddress, swapAmt);
            uint256 minReturnWant = _calculateMinReturn(swapAmt, joeAddress);
            IJoeRouter(dexRouterAddress).swapExactTokensForTokens(
                swapAmt,
                minReturnWant,
                baseTokenToInputTokenPath,
                address(this),
                block.timestamp
            );
        }
        if (isAvaxReward == true && inputTokenAddress == wavaxAddress) {
            IJoetroller(joetrollerAddress).claimReward(1, address(this));
        } else if (isAvaxReward == true) {
            IJoetroller(joetrollerAddress).claimReward(1, address(this));
            uint256 swapAmt = address(this).balance; // it may include other AVAX that is accidentally sent in
            uint256 minReturnWant = _calculateMinReturn(swapAmt, wavaxAddress);
            IJoeRouter(dexRouterAddress).swapExactAVAXForTokens{ value: swapAmt }(
                minReturnWant,
                avaxToInputTokenPath,
                address(this),
                block.timestamp
            );
        }
        if (inputTokenAddress == wavaxAddress) {
            IWAVAX(wavaxAddress).deposit{ value: address(this).balance }();
        }

        IERC20(inputTokenAddress).safeTransfer(msg.sender, IERC20(inputTokenAddress).balanceOf(address(this)));
    }

    // function _calculateMinReturn(uint256 _amount, address _rewardTokenAddress) internal view returns (uint256 minReturn) {
    //     uint256 oraclePriceUsdPerRewardToken = IOracle(oracle).getLatestPrice(_rewardTokenAddress);
    //     uint256 oraclePriceUsdPerInputToken = IOracle(oracle).getLatestPrice(inputTokenAddress);
    //     // uint256 total = _amount.mul(oraclePriceUsdPerRewardToken).div(oraclePriceUsdPerInputToken);
    //     // minReturn = total.mul(100 - swapSlippage).div(100);
    //     minReturn =  _amount.mul(oraclePriceUsdPerRewardToken).mul(100 - swapSlippage).div(100).div(oraclePriceUsdPerInputToken);
    // }

    // below allow deposit of different inputTokens with different decimals
    struct CalculateMinReturnVal {
        uint256 oraclePriceUsdPerRewardToken;
        uint256 oraclePriceUsdPerInputToken;
        uint8 baseDecimalsRewardToken;
        uint8 baseDecimalsInputToken;
        uint256 exponent;
    }
    function _calculateMinReturn(uint256 _amount, address _rewardTokenAddress) internal view returns (uint256 minReturn) {
        CalculateMinReturnVal memory c;
        c.oraclePriceUsdPerRewardToken = IOracle(oracle).getLatestPrice(_rewardTokenAddress);
        c.oraclePriceUsdPerInputToken = IOracle(oracle).getLatestPrice(inputTokenAddress);
        (,c.baseDecimalsRewardToken) = IOracle(oracle).feeds(_rewardTokenAddress);
        (,c.baseDecimalsInputToken) = IOracle(oracle).feeds(inputTokenAddress);

        if (c.baseDecimalsRewardToken == c.baseDecimalsInputToken) {
            minReturn =  _amount.mul(c.oraclePriceUsdPerRewardToken).mul(100 - swapSlippage).div(100).div(c.oraclePriceUsdPerInputToken);
        } else if (c.baseDecimalsRewardToken > c.baseDecimalsInputToken) {
            c.exponent = (uint256(c.baseDecimalsRewardToken).sub(uint256(c.baseDecimalsInputToken))).mul(2);
            minReturn =  _amount.mul(c.oraclePriceUsdPerRewardToken)
                        .mul(100 - swapSlippage).div(100)
                        .div( 10**c.exponent ).div(c.oraclePriceUsdPerInputToken);
        } else if (c.baseDecimalsRewardToken < c.baseDecimalsInputToken) {
            c.exponent = (uint256(c.baseDecimalsInputToken).sub(uint256(c.baseDecimalsRewardToken))).mul(2);
            minReturn =  _amount.mul(c.oraclePriceUsdPerRewardToken).mul( 10**c.exponent )
                        .mul(100 - swapSlippage).div(100)
                        .div(c.oraclePriceUsdPerInputToken);
        }
    }

    function setDexRouter(address _dexRouterAddress) public onlyTimelock onlyNonZeroAddress(_dexRouterAddress) {
        dexRouterAddress = _dexRouterAddress;
        emit SetDexRouter(_dexRouterAddress);
    }

    function setBaseTokenToInputTokenPath(address[] calldata _baseTokenToInputTokenPath) public onlyTimelock onlyNonZeroAddressArray(_baseTokenToInputTokenPath) {
        baseTokenToInputTokenPath = _baseTokenToInputTokenPath;
        emit SetBaseTokenToInputTokenPath(_baseTokenToInputTokenPath);
    }

    function setAvaxToInputTokenPath(address[] calldata _avaxToInputTokenPath) public onlyTimelock onlyNonZeroAddressArray(_avaxToInputTokenPath) {
        avaxToInputTokenPath = _avaxToInputTokenPath;
        emit SetAvaxToInputTokenPath(_avaxToInputTokenPath);
    }

    function setSlippage(uint256 _swapSlippage) public onlyGovernor {
        require(_swapSlippage < 10, "Slippage value is too big");
        swapSlippage = _swapSlippage;
        emit SetSlippage(_swapSlippage);
    }

    function setOracle(address _oracle) public onlyTimelock onlyNonZeroAddress(_oracle) {
        oracle = _oracle;
        emit SetOracle(_oracle);
    }

    function setIsJoeReward(bool _isJoeReward) public onlyGovernor {
        isJoeReward = _isJoeReward;
        emit SetIsJoeReward(_isJoeReward);
    }

    function setIsAvaxReward(bool _isAvaxReward) public onlyGovernor {
        isAvaxReward = _isAvaxReward;
        emit SetIsAvaxReward(_isAvaxReward);
    }

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) public onlyTimelock {
        require(_token != inputTokenAddress, "!safe");
        require(_token != jTokenAddress, "!safe");
        require(_token != joeAddress, "!safe");
        require(_token != xJoeAddress, "!safe");
        IERC20(_token).safeTransfer(_to, _amount);
    }

    fallback() external payable {}

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IWAVAX {

    function withdraw(uint256 wad) external;

    function deposit() external payable;
    
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../refs/CoreRef.sol";
import "../interfaces/ITraderJoe.sol";
import "../interfaces/IPlatypus.sol";
import "../interfaces/IWAVAX.sol";
// import "hardhat/console.sol";

contract StrategyPlatypus is ReentrancyGuard, Ownable, CoreRef {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public inputTokenAddress;
    address public wavaxAddress;
    address public ptpLpTokenAddress;
    address public ptpLendingPoolAddress;
    address public ptpAddress;
    address public masterPtpAddress;
    address public ptpStakerAddress;
    address public dexRouterAddress;
    address[] public baseTokenToInputTokenPath;
    uint256 public swapSlippage;
    uint256 public poolId;
    uint256 public baseTokenSellingPrice;
    bool public isPtpReward = false;

    uint256 public depositedLiquidity = 0;

    event SetDexRouter(address value);
    event SetBaseTokenToInputTokenPath(address[] value);
    event SetBaseTokenSellingPrice(uint256 value);
    event SetSlippage(uint256 value);
    event SetIsPtpReward(bool value);
    event SetMasterPtpAddress(address value);
    event Deposit(uint256 value);

    constructor(
        address _core,
        address _inputTokenAddress,
        address _wavaxAddress,
        address _ptpLpTokenAddress,
        address _ptpLendingPoolAddress,                          
        address _ptpAddress,
        address _masterPtpAddress,
        address _ptpStakerAddress,
        address _dexRouterAddress,
        address[] memory _baseTokenToInputTokenPath,
        uint256 _swapSlippage,
        uint256 _poolId
    ) public CoreRef(_core) {
        inputTokenAddress = _inputTokenAddress;
        wavaxAddress = _wavaxAddress;
        ptpLpTokenAddress = _ptpLpTokenAddress;
        ptpLendingPoolAddress = _ptpLendingPoolAddress;
        ptpAddress = _ptpAddress;
        masterPtpAddress = _masterPtpAddress;
        ptpStakerAddress = _ptpStakerAddress;
        dexRouterAddress = _dexRouterAddress;
        baseTokenToInputTokenPath = _baseTokenToInputTokenPath;
        swapSlippage = _swapSlippage;
        poolId = _poolId;
    }

    function stake(uint256 _stakeAmt) public payable onlyGovernor {
        IERC20(ptpAddress).safeTransferFrom(address(msg.sender), address(this), _stakeAmt);
        IERC20(ptpAddress).safeApprove(ptpStakerAddress, _stakeAmt);
        IPtpStaker(ptpStakerAddress).deposit(_stakeAmt);
    }

    function unstake() public payable onlyGovernor {
        IPtpStaker(ptpStakerAddress).withdraw(IPtpStaker(ptpStakerAddress).getStakedPtp(address(this)));
        IERC20(ptpAddress).safeTransfer(msg.sender, IPtpStaker(ptpStakerAddress).getStakedPtp(address(this)));
    }

    function deposit(uint256 _depositAmt) public onlyMultistrategy nonReentrant whenNotPaused {
        IERC20(inputTokenAddress).safeTransferFrom(address(msg.sender), address(this), _depositAmt);
        _deposit(_depositAmt);
    }

    function _deposit(uint256 _depositAmt) internal {
        IERC20(inputTokenAddress).safeApprove(ptpLendingPoolAddress, _depositAmt);
        uint256 mintedLiquidity = IPtpLendingPool(ptpLendingPoolAddress).deposit(
            inputTokenAddress,
            _depositAmt,
            address(this),
            block.timestamp.add(600)
        );
        require(mintedLiquidity > 0, "ptpToken deposit is failed!");

        // stake to the pool
        IERC20(ptpLpTokenAddress).safeApprove(masterPtpAddress, mintedLiquidity);
        IMasterPtp(masterPtpAddress).deposit(poolId, mintedLiquidity);
        depositedLiquidity += mintedLiquidity;
        emit Deposit(_depositAmt);
    }

    function withdraw() public onlyMultistrategy nonReentrant {
        // Unstake
        IMasterPtp(masterPtpAddress).withdraw(poolId, depositedLiquidity);
        // Reset deposited LP
        depositedLiquidity = 0;

        uint256 withdrawAmountToBe = IERC20(ptpLpTokenAddress).balanceOf(address(this));
        // Approve LP token
        IERC20(ptpLpTokenAddress).safeApprove(ptpLendingPoolAddress, withdrawAmountToBe);
        uint256 withdrawnAmount = IPtpLendingPool(ptpLendingPoolAddress).withdraw(
            inputTokenAddress,
            withdrawAmountToBe,
            withdrawAmountToBe.mul(100 - swapSlippage).div(100),
            address(this),
            block.timestamp.add(600)
        );


        require(withdrawnAmount > 0, "ptpToken redemption is failed!");
        if (isPtpReward == true) {
            uint256[] memory claimInputs = new uint256[](1);
            claimInputs[0] = uint256(poolId);
            IMasterPtp(masterPtpAddress).multiClaim(claimInputs);
            uint256 swapAmt = IERC20(ptpAddress).balanceOf(address(this));
            IERC20(ptpAddress).safeApprove(dexRouterAddress, swapAmt);
            uint256 minReturnWant = _calculateMinInputTokenReturn(swapAmt);
            IJoeRouter(dexRouterAddress).swapExactTokensForTokens(
                swapAmt,
                minReturnWant,
                baseTokenToInputTokenPath,
                address(this),
                block.timestamp
            );
        }

        IERC20(inputTokenAddress).safeTransfer(msg.sender, IERC20(inputTokenAddress).balanceOf(address(this)));
    }

    function _calculateMinInputTokenReturn(uint256 amount) internal view returns (uint256 minReturn) {
        uint256 total = amount.mul(baseTokenSellingPrice).div(100).div(1e12);
        minReturn = total.mul(100 - swapSlippage).div(100);
    }

    function setBaseTokenSellingPrice(uint256 _baseTokenSellingPrice) public onlyGovernor {
        // 2 decimal number
        baseTokenSellingPrice = _baseTokenSellingPrice;
        emit SetBaseTokenSellingPrice(_baseTokenSellingPrice);
    }

    function setDexRouter(address _dexRouterAddress) public onlyTimelock onlyNonZeroAddress(_dexRouterAddress) {
        dexRouterAddress = _dexRouterAddress;
        emit SetDexRouter(_dexRouterAddress);
    }

    function setBaseTokenToInputTokenPath(address[] calldata _baseTokenToInputTokenPath)
        public
        onlyGovernor
        onlyNonZeroAddressArray(_baseTokenToInputTokenPath)
    {
        baseTokenToInputTokenPath = _baseTokenToInputTokenPath;
        emit SetBaseTokenToInputTokenPath(_baseTokenToInputTokenPath);
    }

    function setSlippage(uint256 _swapSlippage) public onlyGovernor {
        require(_swapSlippage < 10, "Slippage value is too big");
        swapSlippage = _swapSlippage;
        emit SetSlippage(_swapSlippage);
    }

    function setIsPtpReward(bool _isPtpReward) public onlyGovernor {
        isPtpReward = _isPtpReward;
        emit SetIsPtpReward(_isPtpReward);
    }

    function setMasterPtpAddress(address _masterPtpAddress) public onlyGovernor {
        masterPtpAddress = _masterPtpAddress;
        emit SetMasterPtpAddress(_masterPtpAddress);
    }

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) public onlyTimelock {
        require(_token != inputTokenAddress, "!safe");
        require(_token != ptpLpTokenAddress, "!safe");
        require(_token != ptpAddress, "!safe");
        IERC20(_token).safeTransfer(_to, _amount);
    }

    fallback() external payable {}

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IPtpLendingPool {
    function deposit(
        address token,
        uint256 amount,
        address to,
        uint256 deadline
    ) external returns (uint256 liquidity);

    function withdraw(
        address token,
        uint256 liquidity,
        uint256 minimumAmount,
        address to,
        uint256 deadline
    ) external returns (uint256 amount);
}

interface IMasterPtp {

    // return (pending, additionalRewards)
    function deposit(uint256 _pid, uint256 _amount) external returns (uint256, uint256);

    // return (transfered, amounts, additionalRewards)
    function multiClaim(uint256[] memory _pids)
        external
        returns (
            uint256,
            uint256[] memory,
            uint256[] memory
        );

    // return (pending, additionalRewards)
    function withdraw(uint256 _pid, uint256 _amount) external returns (uint256, uint256);


    function balanceOf(address account) external view returns (uint256);
}

interface IPtpStaker {
    function deposit(uint256 _amount) external;

    function withdraw(uint256 _amount) external;

    function getStakedPtp(address _user) external view returns (uint256);
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../refs/CoreRef.sol";
import "../interfaces/IGMX.sol";
// import "hardhat/console.sol";

contract StrategyGLP is ReentrancyGuard, Ownable, CoreRef {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    
    IGMXRewardRouter public gmxRewardRouter;
    IERC20 public inputToken;
    IERC20 public glpToken;
    IERC20 public fsGlpToken;
    IGlpManager public glpManager;
    IGMXVault public gmxVault;
    IGMXVaultUtils public gmxVaultUtils;
    address public usdgAddress;

    event Deposit(uint256 value);

    constructor(
        address _core,
        address _inputTokenAddress,
        address _glpTokenAddress,
        address _fsGlpTokenAddress,
        address _usdgAddress,
        address _gmxRewardRouterAddress,
        address _glpManagerAddress,
        address _gmxVaultAddress,
        address _gmxVaultUtilsAddress
    ) public CoreRef(_core) {
        inputToken = IERC20(_inputTokenAddress);
        glpToken = IERC20(_glpTokenAddress);
        fsGlpToken = IERC20(_fsGlpTokenAddress);
        gmxRewardRouter = IGMXRewardRouter(_gmxRewardRouterAddress);
        glpManager = IGlpManager(_glpManagerAddress);
        gmxVault = IGMXVault(_gmxVaultAddress);
        gmxVaultUtils = IGMXVaultUtils(_gmxVaultUtilsAddress);
        usdgAddress = _usdgAddress;
    }

    function deposit(uint256 _depositAmt) public onlyMultistrategy nonReentrant whenNotPaused {
        inputToken.safeTransferFrom(address(msg.sender), address(this), _depositAmt);
        _deposit(_depositAmt);
    }

    function _deposit(uint256 _depositAmt) internal {
        inputToken.safeApprove(address(glpManager), _depositAmt);
        uint256 feeBasisPoints = getGlpMintFeeBasisPoints(_depositAmt);
        uint256 minGlpAmount = _depositAmt.mul(glpToken.totalSupply()).mul(gmxVault.BASIS_POINTS_DIVISOR().sub(feeBasisPoints)).div(glpManager.getAumInUsdg(true)).div(gmxVault.BASIS_POINTS_DIVISOR());
        gmxRewardRouter.mintAndStakeGlp(
            address(inputToken),
            _depositAmt,
            0,
            minGlpAmount
        );
        emit Deposit(_depositAmt);
    }

    
    function withdraw() public onlyMultistrategy nonReentrant {
        uint256 glpAmount = fsGlpToken.balanceOf(address(this));
        uint256 usdgAmount = glpManager.getAumInUsdg(false).mul(glpAmount).div(glpToken.totalSupply());
        uint256 feeBasisPoints = getGlpRedeemFeeBasisPoints(usdgAmount);
        uint256 minOut = gmxVault.getRedemptionAmount(address(inputToken), usdgAmount).mul(gmxVault.BASIS_POINTS_DIVISOR().sub(feeBasisPoints)).div(gmxVault.BASIS_POINTS_DIVISOR());
        gmxRewardRouter.unstakeAndRedeemGlp(
            address(inputToken),
            glpAmount,
            minOut,
            address(this)
        );
        inputToken.safeTransfer(msg.sender, inputToken.balanceOf(address(this)));
    }

    function getGlpMintFeeBasisPoints(uint256 _inputTokenAmount) public view returns (uint256) {
        uint256 usdgAmount = gmxVault.adjustForDecimals(
            _inputTokenAmount.mul( gmxVault.getMinPrice(address(inputToken)) ).div(gmxVault.PRICE_PRECISION()),
            address(inputToken),
            usdgAddress
        );
        return gmxVaultUtils.getBuyUsdgFeeBasisPoints(address(inputToken), usdgAmount);
    }

    function getGlpRedeemFeeBasisPoints(uint256 _usdgAmount) public view returns (uint256) {
        return gmxVaultUtils.getSellUsdgFeeBasisPoints(address(inputToken), _usdgAmount);
    }

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) public onlyTimelock {
        require(_token != address(inputToken), "!safe");
        require(_token != address(fsGlpToken), "!safe");
        IERC20(_token).safeTransfer(_to, _amount);
    }

    fallback() external payable {}

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IGMXRewardRouter {
    function mintAndStakeGlp(address _token, uint256 _amount, uint256 _minUsdg, uint256 _minGlp) external returns (uint256);
    function unstakeAndRedeemGlp(address _tokenOut, uint256 _glpAmount, uint256 _minOut, address _receiver) external returns (uint256);
}

interface IGlpManager {
    function getAumInUsdg(bool maximise) external view returns (uint256);
}

interface IGMXVault {
    function adjustForDecimals(uint256 _amount, address _tokenDiv, address _tokenMul) external view returns (uint256);
    function getMinPrice(address _token) external view returns (uint256);
    function PRICE_PRECISION() external view returns (uint256);
    function BASIS_POINTS_DIVISOR() external view returns(uint256);
    function getRedemptionAmount(address _token, uint256 _usdgAmount) external view returns (uint256);
}
interface IGMXVaultUtils {
    function getBuyUsdgFeeBasisPoints(address _token, uint256 _usdgAmount) external view returns (uint256);
    function getSellUsdgFeeBasisPoints(address _token, uint256 _usdgAmount) external view returns (uint256);
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../refs/CoreRef.sol";
import "../interfaces/IOracle.sol";
import "../interfaces/ITraderJoe.sol";
import "../interfaces/IEchidna.sol";
import "../interfaces/IWAVAX.sol";
// import "hardhat/console.sol";

contract StrategyEchidna is ReentrancyGuard, Ownable, CoreRef {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    
    address public inputTokenAddress;
    address public boosterAddress;
    address public ptpAddress;
    address public joetrollerAddress;
    address public dexRouterAddress;
    address[] public baseTokenToInputTokenPath;
    uint256 public baseTokenSellingPrice;
    uint256 public swapSlippage;
    uint256 public pid;
    address public oracle;

    event SetBaseTokenSellingPrice(uint256 value);
    event SetDexRouter(address value);
    event SetBaseTokenToInputTokenPath(address[] value);
    event SetAvaxToInputTokenPath(address[] value);
    event SetSlippage(uint256 value);
    event SetOracle(address value);
    event Deposit(uint256 value);

    constructor(
        address _core,
        address _inputTokenAddress,
        address _boosterAddress,
        address _ptpAddress,
        address _dexRouterAddress,
        address[] memory _baseTokenToInputTokenPath,
        uint256 _swapSlippage,
        uint256 _pid,
        address _oracle
    ) public CoreRef(_core) {
        inputTokenAddress = _inputTokenAddress;
        boosterAddress = _boosterAddress;
        ptpAddress = _ptpAddress;
        dexRouterAddress = _dexRouterAddress;
        baseTokenToInputTokenPath = _baseTokenToInputTokenPath;
        swapSlippage = _swapSlippage;
        pid = _pid;
        oracle = _oracle;
    }

    function deposit(uint256 _depositAmt) public onlyMultistrategy nonReentrant whenNotPaused {
        IERC20(inputTokenAddress).safeTransferFrom(address(msg.sender), address(this), _depositAmt);
        _deposit(_depositAmt);
    }

    function _deposit(uint256 _depositAmt) internal {
        IERC20(inputTokenAddress).safeApprove(boosterAddress, _depositAmt);
        IEchidna(boosterAddress).deposit(pid, _depositAmt, true, block.timestamp);
        emit Deposit(_depositAmt);
    }

    
    function withdraw() public onlyMultistrategy nonReentrant {
        IEchidna(boosterAddress).withdrawAll(pid, true, true, (100 - swapSlippage) * 1000 );
        uint256 swapAmt = IERC20(ptpAddress).balanceOf(address(this));
        IERC20(ptpAddress).safeApprove(dexRouterAddress, swapAmt);
        uint256 minReturnWant = _calculateMinReturn(swapAmt, ptpAddress);
        IJoeRouter(dexRouterAddress).swapExactTokensForTokens(
            swapAmt,
            minReturnWant,
            baseTokenToInputTokenPath,
            address(this),
            block.timestamp
        );
        
        IERC20(inputTokenAddress).safeTransfer(msg.sender, IERC20(inputTokenAddress).balanceOf(address(this)));
    }

    // below allow deposit of different inputTokens with different decimals
    struct CalculateMinReturnVal {
        uint256 oraclePriceUsdPerRewardToken;
        uint256 oraclePriceUsdPerInputToken;
        uint8 baseDecimalsRewardToken;
        uint8 baseDecimalsInputToken;
        uint256 exponent;
    }
    function _calculateMinReturn(uint256 _amount, address _rewardTokenAddress) internal view returns (uint256 minReturn) {
        CalculateMinReturnVal memory c;
        c.oraclePriceUsdPerRewardToken = baseTokenSellingPrice;
        c.oraclePriceUsdPerInputToken = IOracle(oracle).getLatestPrice(inputTokenAddress);
        c.baseDecimalsRewardToken = 18;
        (,c.baseDecimalsInputToken) = IOracle(oracle).feeds(inputTokenAddress);

        if (c.baseDecimalsRewardToken == c.baseDecimalsInputToken) {
            minReturn =  _amount.mul(c.oraclePriceUsdPerRewardToken).mul(100 - swapSlippage).div(100).div(c.oraclePriceUsdPerInputToken);
        } else if (c.baseDecimalsRewardToken > c.baseDecimalsInputToken) {
            c.exponent = (uint256(c.baseDecimalsRewardToken).sub(uint256(c.baseDecimalsInputToken))).mul(2);
            minReturn =  _amount.mul(c.oraclePriceUsdPerRewardToken)
                        .mul(100 - swapSlippage).div(100)
                        .div( 10**c.exponent ).div(c.oraclePriceUsdPerInputToken);
        } else if (c.baseDecimalsRewardToken < c.baseDecimalsInputToken) {
            c.exponent = (uint256(c.baseDecimalsInputToken).sub(uint256(c.baseDecimalsRewardToken))).mul(2);
            minReturn =  _amount.mul(c.oraclePriceUsdPerRewardToken).mul( 10**c.exponent )
                        .mul(100 - swapSlippage).div(100)
                        .div(c.oraclePriceUsdPerInputToken);
        }
    }

    function setBaseTokenSellingPrice(uint256 _baseTokenSellingPrice) public onlyGovernor {
        // 2 decimal number
        baseTokenSellingPrice = _baseTokenSellingPrice.mul(1e16);
        emit SetBaseTokenSellingPrice(_baseTokenSellingPrice);
    }

    function setDexRouter(address _dexRouterAddress) public onlyTimelock onlyNonZeroAddress(_dexRouterAddress) {
        dexRouterAddress = _dexRouterAddress;
        emit SetDexRouter(_dexRouterAddress);
    }

    function setBaseTokenToInputTokenPath(address[] calldata _baseTokenToInputTokenPath) public onlyTimelock onlyNonZeroAddressArray(_baseTokenToInputTokenPath) {
        baseTokenToInputTokenPath = _baseTokenToInputTokenPath;
        emit SetBaseTokenToInputTokenPath(_baseTokenToInputTokenPath);
    }

    function setSlippage(uint256 _swapSlippage) public onlyGovernor {
        require(_swapSlippage < 10, "Slippage value is too big");
        swapSlippage = _swapSlippage;
        emit SetSlippage(_swapSlippage);
    }

    function setOracle(address _oracle) public onlyTimelock onlyNonZeroAddress(_oracle) {
        oracle = _oracle;
        emit SetOracle(_oracle);
    }

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) public onlyTimelock {
        require(_token != inputTokenAddress, "!safe");
        require(_token != ptpAddress, "!safe");
        IERC20(_token).safeTransfer(_to, _amount);
    }

    fallback() external payable {}

    receive() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface IEchidna {
    function withdrawAll(
        uint256 _pid,
        bool _claim,
        bool unwrap,
        uint256 slippage
    ) external;

    function deposit(
        uint256 _pid,
        uint256 _amount,
        bool depositToPlatypus,
        uint256 deadline
    ) external;
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../refs/CoreRef.sol";
import "../interfaces/IOracle.sol";
import "../interfaces/ITraderJoe.sol";
import "../interfaces/IBenqi.sol";
import "../interfaces/IWAVAX.sol";
// import "hardhat/console.sol";

contract StrategyBenqi is ReentrancyGuard, Ownable, CoreRef {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    
    address public inputTokenAddress;
    address public wavaxAddress;
    address public qiTokenAddress;
    address public qiAddress;
    address public qiComptrollerAddress;
    address public dexRouterAddress;
    address[] public baseTokenToInputTokenPath;
    address[] public avaxToInputTokenPath;
    uint256 public swapSlippage;
    address public oracle;
    bool public isQiReward = true;
    bool public isAvaxReward = true;

    event SetDexRouter(address value);
    event SetBaseTokenToInputTokenPath(address[] value);
    event SetAvaxToInputTokenPath(address[] value);
    event SetSlippage(uint256 value);
    event SetOracle(address value);
    event SetIsQiReward(bool value);
    event SetIsAvaxReward(bool value);
    event Deposit(uint256 value);

    constructor(
        address _core,
        address _inputTokenAddress,
        address _wavaxAddress,
        address _qiTokenAddress,
        address _qiAddress,
        address _qiComptrollerAddress,
        address _dexRouterAddress,
        address[] memory _baseTokenToInputTokenPath,
        address[] memory _avaxToInputTokenPath,
        uint256 _swapSlippage,
        address _oracle
    ) public CoreRef(_core) {
        inputTokenAddress = _inputTokenAddress;
        wavaxAddress = _wavaxAddress;
        qiTokenAddress = _qiTokenAddress;
        qiAddress = _qiAddress;
        qiComptrollerAddress = _qiComptrollerAddress;
        dexRouterAddress = _dexRouterAddress;
        baseTokenToInputTokenPath = _baseTokenToInputTokenPath;
        avaxToInputTokenPath = _avaxToInputTokenPath;
        swapSlippage = _swapSlippage;
        oracle = _oracle;
    }

    function deposit(uint256 _depositAmt) public onlyMultistrategy nonReentrant whenNotPaused {
        IERC20(inputTokenAddress).safeTransferFrom(address(msg.sender), address(this), _depositAmt);
        _deposit(_depositAmt);
    }

    function _deposit(uint256 _depositAmt) internal {
        if (inputTokenAddress == wavaxAddress) {
            IWAVAX(wavaxAddress).withdraw(_depositAmt);
            IQiToken(qiTokenAddress).mint{ value: _depositAmt }();
        } else {
            IERC20(inputTokenAddress).safeApprove(qiTokenAddress, _depositAmt);
            uint256 successCode = IQiToken(qiTokenAddress).mint(_depositAmt);
            require(successCode == 0, "qiToken minting is failed!");
        }
        emit Deposit(_depositAmt);
    }


    function withdraw() public onlyMultistrategy nonReentrant {
        address[] memory qiTokenPath = new address[](1);
        qiTokenPath[0] = qiTokenAddress;
        uint256 successCode = IQiToken(qiTokenAddress).redeemUnderlying(uint256(-1)); // put IQiToken(qiTokenAddress).balanceOf(address(this)) not working?
        require(successCode == 0, "qiToken redemption is failed!");
        if (isQiReward == true) {
            IQiComptroller(qiComptrollerAddress).claimReward(0, payable(address(this)), qiTokenPath);
            uint256 swapAmt = IERC20(qiAddress).balanceOf(address(this));
            IERC20(qiAddress).safeApprove(dexRouterAddress, swapAmt);
            uint256 minReturnWant = _calculateMinReturn(swapAmt, qiAddress);
            IJoeRouter(dexRouterAddress).swapExactTokensForTokens(
                swapAmt,
                minReturnWant,
                baseTokenToInputTokenPath,
                address(this),
                block.timestamp
            );
        }
        if (isAvaxReward == true && inputTokenAddress == wavaxAddress) {
            IQiComptroller(qiComptrollerAddress).claimReward(1, payable(address(this)), qiTokenPath);
        } else if (isAvaxReward == true) {
            IQiComptroller(qiComptrollerAddress).claimReward(1, payable(address(this)), qiTokenPath);
            uint256 swapAmt = address(this).balance; // it may include other AVAX that is accidentally sent in
            uint256 minReturnWant = _calculateMinReturn(swapAmt, wavaxAddress);
            IJoeRouter(dexRouterAddress).swapExactAVAXForTokens{ value: swapAmt }(
                minReturnWant,
                avaxToInputTokenPath,
                address(this),
                block.timestamp
            );
        }
        if (inputTokenAddress == wavaxAddress) {
            IWAVAX(wavaxAddress).deposit{ value: address(this).balance }();
        }

        IERC20(inputTokenAddress).safeTransfer(msg.sender, IERC20(inputTokenAddress).balanceOf(address(this)));
    }

    // function _calculateMinReturn(uint256 _amount, address _rewardTokenAddress) internal view returns (uint256 minReturn) {
    //     uint256 oraclePriceUsdPerRewardToken = IOracle(oracle).getLatestPrice(_rewardTokenAddress);
    //     uint256 oraclePriceUsdPerInputToken = IOracle(oracle).getLatestPrice(inputTokenAddress);
    //     uint256 total = _amount.mul(oraclePriceUsdPerRewardToken).div(oraclePriceUsdPerInputToken);
    //     minReturn = total.mul(100 - swapSlippage).div(100);
    // }

    // below allow deposit of different inputTokens with different decimals
    struct CalculateMinReturnVal {
        uint256 oraclePriceUsdPerRewardToken;
        uint256 oraclePriceUsdPerInputToken;
        uint8 baseDecimalsRewardToken;
        uint8 baseDecimalsInputToken;
        uint256 exponent;
    }
    function _calculateMinReturn(uint256 _amount, address _rewardTokenAddress) internal view returns (uint256 minReturn) {
        CalculateMinReturnVal memory c;
        c.oraclePriceUsdPerRewardToken = IOracle(oracle).getLatestPrice(_rewardTokenAddress);
        c.oraclePriceUsdPerInputToken = IOracle(oracle).getLatestPrice(inputTokenAddress);
        (,c.baseDecimalsRewardToken) = IOracle(oracle).feeds(_rewardTokenAddress);
        (,c.baseDecimalsInputToken) = IOracle(oracle).feeds(inputTokenAddress);

        if (c.baseDecimalsRewardToken == c.baseDecimalsInputToken) {
            minReturn =  _amount.mul(c.oraclePriceUsdPerRewardToken).mul(100 - swapSlippage).div(100).div(c.oraclePriceUsdPerInputToken);
        } else if (c.baseDecimalsRewardToken > c.baseDecimalsInputToken) {
            c.exponent = (uint256(c.baseDecimalsRewardToken).sub(uint256(c.baseDecimalsInputToken))).mul(2);
            minReturn =  _amount.mul(c.oraclePriceUsdPerRewardToken)
                        .mul(100 - swapSlippage).div(100)
                        .div( 10**c.exponent ).div(c.oraclePriceUsdPerInputToken);
        } else if (c.baseDecimalsRewardToken < c.baseDecimalsInputToken) {
            c.exponent = (uint256(c.baseDecimalsInputToken).sub(uint256(c.baseDecimalsRewardToken))).mul(2);
            minReturn =  _amount.mul(c.oraclePriceUsdPerRewardToken).mul( 10**c.exponent )
                        .mul(100 - swapSlippage).div(100)
                        .div(c.oraclePriceUsdPerInputToken);
        }
    }

    function setDexRouter(address _dexRouterAddress) public onlyTimelock onlyNonZeroAddress(_dexRouterAddress) {
        dexRouterAddress = _dexRouterAddress;
        emit SetDexRouter(_dexRouterAddress);
    }

    function setBaseTokenToInputTokenPath(address[] calldata _baseTokenToInputTokenPath) public onlyTimelock onlyNonZeroAddressArray(_baseTokenToInputTokenPath) {
        baseTokenToInputTokenPath = _baseTokenToInputTokenPath;
        emit SetBaseTokenToInputTokenPath(_baseTokenToInputTokenPath);
    }

    function setAvaxToInputTokenPath(address[] calldata _avaxToInputTokenPath) public onlyTimelock onlyNonZeroAddressArray(_avaxToInputTokenPath) {
        avaxToInputTokenPath = _avaxToInputTokenPath;
        emit SetAvaxToInputTokenPath(_avaxToInputTokenPath);
    }

    function setSlippage(uint256 _swapSlippage) public onlyGovernor {
        require(_swapSlippage < 10, "Slippage value is too big");
        swapSlippage = _swapSlippage;
        emit SetSlippage(_swapSlippage);
    }

    function setOracle(address _oracle) public onlyTimelock onlyNonZeroAddress(_oracle) {
        oracle = _oracle;
        emit SetOracle(_oracle);
    }

    function setIsQiReward(bool _isQiReward) public onlyGovernor {
        isQiReward = _isQiReward;
        emit SetIsQiReward(_isQiReward);
    }

    function setIsAvaxReward(bool _isAvaxReward) public onlyGovernor {
        isAvaxReward = _isAvaxReward;
        emit SetIsAvaxReward(_isAvaxReward);
    }

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) public onlyTimelock {
        require(_token != inputTokenAddress, "!safe");
        require(_token != qiTokenAddress, "!safe");
        require(_token != qiAddress, "!safe");
        IERC20(_token).safeTransfer(_to, _amount);
    }

    fallback() external payable {}

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IQiToken {
    
    function mint(uint256 mintAmount) external returns (uint256);

    function mint() external payable;

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function balanceOf(address account) external view returns (uint256);
}

interface IQiComptroller {

    function claimReward(uint8 rewardType, address payable holder, address[] calldata qiTokens) external;

}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../interfaces/IAlpaca.sol";
import "../interfaces/IStrategy.sol";
import "../interfaces/IPancakeRouter02.sol";
import "../interfaces/IOracle.sol";
import "../refs/CoreRef.sol";
import "../interfaces/IWBNB.sol";
// import "hardhat/console.sol";

contract StrategyAlpaca is IStrategyAlpaca, ReentrancyGuard, Ownable, CoreRef {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 public override lastEarnBlock;

    address public override uniRouterAddress;

    address public constant wbnbAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    address public constant alpacaAddress = 0x8F0528cE5eF7B51152A59745bEfDD91D97091d2F;

    address public constant fairLaunchAddress = 0xA625AB01B08ce023B2a342Dbb12a16f2C8489A8F;

    address public override vaultAddress;
    address public override wantAddress;
    uint256 public override poolId;

    address[] public override earnedToWantPath;
    address public oracle;
    uint256 internal swapSlippage;

    constructor(
        address _core,
        address _vaultAddress,
        address _wantAddress,
        address _uniRouterAddress,
        uint256 _poolId,
        address[] memory _earnedToWantPath,
        address _oracle,
        uint256 _swapSlippage
    ) public CoreRef(_core) {
        vaultAddress = _vaultAddress;
        wantAddress = _wantAddress;
        poolId = _poolId;
        earnedToWantPath = _earnedToWantPath;
        uniRouterAddress = _uniRouterAddress;
        oracle = _oracle;
        swapSlippage = _swapSlippage;

        IERC20(alpacaAddress).safeApprove(uniRouterAddress, uint256(-1));
        IERC20(_wantAddress).safeApprove(uniRouterAddress, uint256(-1));
        IERC20(_wantAddress).safeApprove(vaultAddress, uint256(-1));
        IERC20(vaultAddress).safeApprove(fairLaunchAddress, uint256(-1));
    }

    function deposit(uint256 _wantAmt) public override nonReentrant whenNotPaused {
        IERC20(wantAddress).safeTransferFrom(address(msg.sender), address(this), _wantAmt);

        _deposit(wantLockedInHere());
    }

    function _deposit(uint256 _wantAmt) internal {
        Vault(vaultAddress).deposit(_wantAmt);
        FairLaunch(fairLaunchAddress).deposit(address(this), poolId, Vault(vaultAddress).balanceOf(address(this)));
    }

    function earn() public override whenNotPaused onlyTimelock {
        FairLaunch(fairLaunchAddress).harvest(poolId);
        uint256 earnedAmt = IERC20(alpacaAddress).balanceOf(address(this));
        if (alpacaAddress != wantAddress && earnedAmt != 0) {
            uint256 minReturnWant = _calculateMinReturn(earnedAmt, alpacaAddress);
            IPancakeRouter02(uniRouterAddress).swapExactTokensForTokens(
                earnedAmt,
                minReturnWant,
                earnedToWantPath,
                address(this),
                now.add(600)
            );
        }

        earnedAmt = wantLockedInHere();
        if (earnedAmt != 0) {
            _deposit(earnedAmt);
        }

        lastEarnBlock = block.number;
    }

    function withdraw() public override onlyMultistrategy nonReentrant {
        (uint256 _amount, , , ) = FairLaunch(fairLaunchAddress).userInfo(poolId, address(this));
        FairLaunch(fairLaunchAddress).withdraw(address(this), poolId, _amount);
        Vault(vaultAddress).withdraw(Vault(vaultAddress).balanceOf(address(this)));
        _safeWrap();

        uint256 earnedAmt = IERC20(alpacaAddress).balanceOf(address(this));
        if (alpacaAddress != wantAddress && earnedAmt != 0) {
            uint256 minReturnWant = _calculateMinReturn(earnedAmt, alpacaAddress);
            IPancakeRouter02(uniRouterAddress).swapExactTokensForTokens(
                earnedAmt,
                minReturnWant,
                earnedToWantPath,
                address(this),
                now.add(600)
            );
        }

        uint256 balance = wantLockedInHere();
        IERC20(wantAddress).safeTransfer(msg.sender, balance);
    }

    function _safeWrap() internal {
        if (wantAddress == wbnbAddress) {
            IWBNB(wbnbAddress).deposit{ value: address(this).balance }();
        }
    }

    function _pause() internal override {
        super._pause();
        IERC20(alpacaAddress).safeApprove(uniRouterAddress, 0);
        IERC20(wantAddress).safeApprove(uniRouterAddress, 0);
        IERC20(wantAddress).safeApprove(vaultAddress, 0);
    }

    function _unpause() internal override {
        super._unpause();
        IERC20(alpacaAddress).safeApprove(uniRouterAddress, uint256(-1));
        IERC20(wantAddress).safeApprove(uniRouterAddress, uint256(-1));
        IERC20(wantAddress).safeApprove(vaultAddress, uint256(-1));
    }

    function wantLockedInHere() public view override returns (uint256) {
        return IERC20(wantAddress).balanceOf(address(this));
    }

    function calculateMinReturn(uint256 _amount) external view returns (uint256 minReturn) {
        minReturn = _calculateMinReturn(_amount, alpacaAddress);
    }

    // below allow deposit of different inputTokens with different decimals
    struct CalculateMinReturnVal {
        uint256 oraclePriceUsdPerRewardToken;
        uint256 oraclePriceUsdPerInputToken;
        uint8 baseDecimalsRewardToken;
        uint8 baseDecimalsInputToken;
        uint256 exponent;
    }
    function _calculateMinReturn(uint256 _amount, address _rewardTokenAddress) internal view returns (uint256 minReturn) {
        CalculateMinReturnVal memory c;
        c.oraclePriceUsdPerRewardToken = IOracle(oracle).getLatestPrice(_rewardTokenAddress);
        c.oraclePriceUsdPerInputToken = IOracle(oracle).getLatestPrice(wantAddress);
        (,c.baseDecimalsRewardToken) = IOracle(oracle).feeds(_rewardTokenAddress);
        (,c.baseDecimalsInputToken) = IOracle(oracle).feeds(wantAddress);

        if (c.baseDecimalsRewardToken == c.baseDecimalsInputToken) {
            minReturn =  _amount.mul(c.oraclePriceUsdPerRewardToken).mul(100 - swapSlippage).div(100).div(c.oraclePriceUsdPerInputToken);
        } else if (c.baseDecimalsRewardToken > c.baseDecimalsInputToken) {
            c.exponent = (uint256(c.baseDecimalsRewardToken).sub(uint256(c.baseDecimalsInputToken))).mul(2);
            minReturn =  _amount.mul(c.oraclePriceUsdPerRewardToken)
                        .mul(100 - swapSlippage).div(100)
                        .div( 10**c.exponent ).div(c.oraclePriceUsdPerInputToken);
        } else if (c.baseDecimalsRewardToken < c.baseDecimalsInputToken) {
            c.exponent = (uint256(c.baseDecimalsInputToken).sub(uint256(c.baseDecimalsRewardToken))).mul(2);
            minReturn =  _amount.mul(c.oraclePriceUsdPerRewardToken).mul( 10**c.exponent )
                        .mul(100 - swapSlippage).div(100)
                        .div(c.oraclePriceUsdPerInputToken);
        }
    }

    function setSlippage(uint256 _swapSlippage) public onlyGovernor {
        require(_swapSlippage < 10, "Slippage value is too big");
        swapSlippage = _swapSlippage;
    }

    function setOracle(address _oracle) public onlyGovernor {
        oracle = _oracle;
    }

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) public override onlyTimelock {
        require(_token != alpacaAddress, "!safe");
        require(_token != wantAddress, "!safe");
        require(_token != vaultAddress, "!safe");
        IERC20(_token).safeTransfer(_to, _amount);
    }

    function updateStrategy() public override {}

    receive() external payable {}
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../interfaces/IStrategy.sol";
import "../interfaces/IStrategyToken.sol";
import "../refs/CoreRef.sol";

contract MultiStrategyToken is IMultiStrategyToken, ReentrancyGuard, CoreRef {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    bytes32 public constant MASTER_ROLE = keccak256("MASTER_ROLE");

    address public override token;

    address[] public override strategies;

    mapping(address => uint256) public override ratios;

    uint256 public override ratioTotal;

    event StrategiesAndRatiosChanged(bool value);
    event RatioChanged(address strategyAddress, uint256 ratioBefore, uint256 ratioAfter);

    constructor(
        address _core,
        address _token,
        address[] memory _strategies,
        uint256[] memory _ratios
    ) public CoreRef(_core) {
        require(_strategies.length == _ratios.length, "array not match");

        token = _token;
        strategies = _strategies;

        for (uint256 i = 0; i < strategies.length; i++) {
            ratios[strategies[i]] = _ratios[i];
            ratioTotal = ratioTotal.add(_ratios[i]);
        }

        approveToken();
    }

    function approveToken() public override {
        for (uint256 i = 0; i < strategies.length; i++) {
            IERC20(token).safeApprove(strategies[i], uint256(-1));
        }
    }

    function deposit(uint256 _amount) public override onlyRole(MASTER_ROLE) {
        require(_amount != 0, "deposit must be greater than 0");
        IERC20(token).safeTransferFrom(msg.sender, address(this), _amount);
        _deposit(_amount);
    }

    function _deposit(uint256 _amount) internal nonReentrant {
        for (uint256 i = 0; i < strategies.length; i++) {
            uint256 amt = _amount.mul(ratios[strategies[i]]).div(ratioTotal);
            IStrategy(strategies[i]).deposit(amt);
        }
    }

    function withdraw(address[] memory _strategyAddresses) public override onlyRole(MASTER_ROLE) nonReentrant {
        if (_strategyAddresses[0] == address(0)) {
            for (uint256 i = 0; i < strategies.length; i++) {
                IStrategy(strategies[i]).withdraw();
            }
        } else {
            for (uint256 i = 0; i < _strategyAddresses.length; i++) {
                IStrategy(_strategyAddresses[i]).withdraw();
            }
        }

        uint256 amt = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(msg.sender, amt);
    }

    function updateStrategiesAndRatios(address[] calldata _strategies, uint256[] calldata _ratios) public override onlyTimelock {
        strategies = _strategies;
        ratioTotal = 0;
        for (uint256 i = 0; i < _strategies.length; i++) {
            ratios[_strategies[i]] = _ratios[i];
            ratioTotal = ratioTotal.add(_ratios[i]);
            IERC20(token).approve(_strategies[i], uint256(-1));
        }
        emit StrategiesAndRatiosChanged(true);
    }

    function changeRatio(uint256 index, uint256 value) public override onlyTimelock {
        require(strategies.length > index, "invalid index");
        uint256 valueBefore = ratios[strategies[index]];
        ratios[strategies[index]] = value;
        ratioTotal = ratioTotal.sub(valueBefore).add(value);

        emit RatioChanged(strategies[index], valueBefore, value);
    }

    function strategyCount() public view override returns (uint256) {
        return strategies.length;
    }

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) public override onlyTimelock {
        require(_token != token, "!safe");
        IERC20(_token).safeTransfer(_to, _amount);
    }

}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface IStrategyToken {
    function token() external view returns (address);

    function deposit(uint256 _amount) external;

    function withdraw(address[] memory _strategyAddresses) external;

    function approveToken() external;
}

interface IMultiStrategyToken is IStrategyToken {
    function strategies(uint256 idx) external view returns (address);

    function strategyCount() external view returns (uint256);

    function ratios(address _strategy) external view returns (uint256);

    function ratioTotal() external view returns (uint256);

    function updateStrategiesAndRatios(address[] calldata _strategies, uint256[] calldata _ratios) external;

    function changeRatio(uint256 _index, uint256 _value) external;

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) external;

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../refs/CoreRef.sol";
import "../interfaces/ITrancheMaster.sol";
import "../interfaces/IMasterWTF.sol";
import "../interfaces/IStrategy.sol";
import "../interfaces/IStrategyToken.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";
// import "@nomiclabs/buidler/console.sol";

contract TimelockController_with_2_delays is CoreRef, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 internal constant _DONE_TIMESTAMP = uint256(1);
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    mapping(bytes32 => uint256) private _timestamps;
    uint256 public minDelayNormal;
    uint256 public minDelayCritical;

    event CallScheduled(
        bytes32 indexed id,
        uint256 indexed index,
        address target,
        uint256 value,
        bytes data,
        bytes32 predecessor,
        uint256 delay
    );

    event CallScheduledBatch(
        bytes32 indexed id,
        uint256 indexed index,
        bytes[] datas
    );

    event CallExecuted(bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data);

    event Cancelled(bytes32 indexed id);

    event MinDelayChange(string delayType, uint256 oldDuration, uint256 newDuration);

    modifier onlySelf() {
        require(msg.sender == address(this), "TimelockController::onlySelf: caller is not itself");
        _;
    }

    constructor(address _core, uint256 _minDelayNormal,  uint256 _minDelayCritical) public CoreRef(_core) {
        minDelayNormal = _minDelayNormal;
        minDelayCritical = _minDelayCritical;
        emit MinDelayChange("normal", 0, _minDelayNormal);
        emit MinDelayChange("critical", 0, _minDelayCritical);
    }

    receive() external payable {}

    function isOperation(bytes32 id) public view virtual returns (bool pending) {
        return getTimestamp(id) > 0;
    }

    function isOperationPending(bytes32 id) public view virtual returns (bool pending) {
        return getTimestamp(id) > _DONE_TIMESTAMP;
    }

    function isOperationReady(bytes32 id) public view virtual returns (bool ready) {
        uint256 timestamp = getTimestamp(id);
        return timestamp > _DONE_TIMESTAMP && timestamp <= block.timestamp;
    }

    function isOperationDone(bytes32 id) public view virtual returns (bool done) {
        return getTimestamp(id) == _DONE_TIMESTAMP;
    }

    function getTimestamp(bytes32 id) public view virtual returns (uint256 timestamp) {
        return _timestamps[id];
    }

    function hashOperation(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt
    ) public pure virtual returns (bytes32 hash) {
        return keccak256(abi.encode(target, value, data, predecessor, salt));
    }

    function hashOperationBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas,
        bytes32 predecessor,
        bytes32 salt
    ) public pure virtual returns (bytes32 hash) {
        return keccak256(abi.encode(targets, values, datas, predecessor, salt));
    }

    function bytesToBytes32(bytes memory b, uint offset) private pure returns (bytes32) {
        bytes32 out;

        for (uint i = 0; i < 32; i++) {
            out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    function checkMinDelay(bytes calldata data, uint256 delay) private view {
        if (
            bytes4(keccak256("setTrancheMaster(address,uint256,uint256,uint256,uint256)")) == bytes4(bytesToBytes32(data, 0)) || 
            bytes4(keccak256("setMasterWTF(address,uint256,uint256,bool)")) == bytes4(bytesToBytes32(data, 0)) ||
            bytes4(keccak256("updateRewardPerBlock(address,uint256)")) == bytes4(bytesToBytes32(data, 0)) ||
            bytes4(keccak256("changeRatio(address,uint256,uint256)")) == bytes4(bytesToBytes32(data, 0))
        ) {
            require(delay >= minDelayNormal, "TimelockController: insufficient delay for normal operation");
        } else {
            require(delay >= minDelayCritical, "TimelockController: insufficient delay for critical operation");
        }
    }

    modifier onlyPassMinDelay(bytes calldata data, uint256 delay) {
        checkMinDelay(data, delay);
        _;
    }

    modifier onlyPassMinDelayForBatch(bytes[] calldata datas, uint256 delay) {
        for (uint256 i = 0; i < datas.length; ++i) {
            checkMinDelay(datas[i], delay);
        }
        _;
    }

    function schedule(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt,
        uint256 delay
    ) public virtual onlyRole(PROPOSER_ROLE) onlyPassMinDelay(data, delay) {
        bytes32 id = hashOperation(target, value, data, predecessor, salt);
        _schedule(id, delay);
        emit CallScheduled(id, 0, target, value, data, predecessor, delay);
    }

    function scheduleBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas,
        bytes32 predecessor,
        bytes32 salt,
        uint256 delay
    ) public virtual onlyRole(PROPOSER_ROLE) onlyPassMinDelayForBatch(datas, delay) {
        require(targets.length == values.length, "TimelockController: length mismatch");
        require(targets.length == datas.length, "TimelockController: length mismatch");

        bytes32 id = hashOperationBatch(targets, values, datas, predecessor, salt);
        _schedule(id, delay);
        emit CallScheduledBatch(id, targets.length, datas);
    }

    function _schedule(bytes32 id, uint256 delay) private {
        require(!isOperation(id), "TimelockController: operation already scheduled");
        _timestamps[id] = block.timestamp + delay;
    }

    function cancel(bytes32 id) public virtual onlyRole(PROPOSER_ROLE) {
        require(isOperationPending(id), "TimelockController: operation cannot be cancelled");
        delete _timestamps[id];

        emit Cancelled(id);
    }

    function execute(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt
    ) public payable virtual onlyRoleOrOpenRole(EXECUTOR_ROLE) {
        bytes32 id = hashOperation(target, value, data, predecessor, salt);
        _beforeCall(id, predecessor);
        _call(id, 0, target, value, data);
        _afterCall(id);
    }

    function executeBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas,
        bytes32 predecessor,
        bytes32 salt
    ) public payable virtual onlyRoleOrOpenRole(EXECUTOR_ROLE) {
        require(targets.length == values.length, "TimelockController: length mismatch");
        require(targets.length == datas.length, "TimelockController: length mismatch");

        bytes32 id = hashOperationBatch(targets, values, datas, predecessor, salt);
        _beforeCall(id, predecessor);
        for (uint256 i = 0; i < targets.length; ++i) {
            _call(id, i, targets[i], values[i], datas[i]);
        }
        _afterCall(id);
    }

    function _beforeCall(bytes32 id, bytes32 predecessor) private view {
        require(isOperationReady(id), "TimelockController: operation is not ready");
        require(predecessor == bytes32(0) || isOperationDone(predecessor), "TimelockController: missing dependency");
    }

    function _afterCall(bytes32 id) private {
        require(isOperationReady(id), "TimelockController: operation is not ready");
        _timestamps[id] = _DONE_TIMESTAMP;
    }

    function _call(
        bytes32 id,
        uint256 index,
        address target,
        uint256 value,
        bytes calldata data
    ) private {
        (bool success, ) = target.call{value: value}(data);
        require(success, "TimelockController: underlying transaction reverted");

        emit CallExecuted(id, index, target, value, data);
    }

    function updateDelay(uint256 delayTypeId, uint256 newDelay) public virtual onlySelf {
        if (delayTypeId == 0) {
            emit MinDelayChange("normal", minDelayNormal, newDelay);
            minDelayNormal = newDelay;
        } else if (delayTypeId == 1) {
            emit MinDelayChange("critical", minDelayCritical, newDelay);
            minDelayCritical = newDelay;
        }
    }

    // IMasterWTF

    function setMasterWTF(
        address _master,
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlySelf {
        IMasterWTF(_master).set(_pid, _allocPoint, _withUpdate);
    }

    function updateRewardPerBlock(address _master, uint256 _rewardPerBlock) public onlySelf {
        IMasterWTF(_master).updateRewardPerBlock(_rewardPerBlock);
    }

    // ITrancheMaster

    function setTrancheMaster(
        address _trancheMaster,
        uint256 _tid,
        uint256 _target,
        uint256 _apy,
        uint256 _fee
    ) public onlySelf {
        ITrancheMaster(_trancheMaster).set(_tid, _target, _apy, _fee);
    }

    // IStrategyToken

    function changeRatio(
        address _token,
        uint256 _index,
        uint256 _value
    ) public onlySelf {
        IMultiStrategyToken(_token).changeRatio(_index, _value);
    }

    // IStrategy

    function setOracle(address _strategy, address _oracle) public onlySelf {
        IStrategyAvax(_strategy).setOracle(_oracle);
    }

    function setDexRouter(address _strategy, address _dexRouterAddress) public onlySelf {
        IStrategyAvax(_strategy).setDexRouter(_dexRouterAddress);
    }

    function setInputTokenToBaseTokenPath(address _strategy, address[] calldata _inputTokenToBaseTokenPath) public onlySelf {
        IStrategyAvax(_strategy).setInputTokenToBaseTokenPath(_inputTokenToBaseTokenPath);
    }

    function setBaseTokenToInputTokenPath(address _strategy, address[] calldata _baseTokenToInputTokenPath) public onlySelf {
        IStrategyAvax(_strategy).setBaseTokenToInputTokenPath(_baseTokenToInputTokenPath);
    }

    function setAvaxToInputTokenPath(address _strategy, address[] calldata _avaxToInputTokenPath) public onlySelf {
        IStrategyAvax(_strategy).setAvaxToInputTokenPath(_avaxToInputTokenPath);
    }

    function createRole(bytes32 role, bytes32 adminRole) external onlySelf {
        core().createRole(role, adminRole);
    }

    function grantGovernor(address governor) external onlySelf {
        core().grantGovernor(governor);
    }

    function grantGuardian(address guardian) external onlySelf {
        core().grantGuardian(guardian);
    }

    function grantMultistrategy(address multistrategy) external onlySelf {
        core().grantMultistrategy(multistrategy);
    }

    function grantRole(bytes32 role, address account) public onlySelf {
        core().grantRole(role, account);
    }

    function earn(address _strategy) public onlyRole(EXECUTOR_ROLE) {
        IStrategy(_strategy).earn();
    }

    function inCaseTokensGetStuck(
        address _strategy,
        address _token,
        uint256 _amount,
        address _to
    ) public onlySelf {
        IStrategy(_strategy).inCaseTokensGetStuck(_token, _amount, _to);
    }

    function leverage(address _strategy, uint256 _amount) public onlySelf {
        ILeverageStrategy(_strategy).leverage(_amount);
    }

    function deleverage(address _strategy, uint256 _amount) public onlySelf {
        ILeverageStrategy(_strategy).deleverage(_amount);
    }

    function deleverageAll(address _strategy, uint256 _amount) public onlySelf {
        ILeverageStrategy(_strategy).deleverageAll(_amount);
    }

    function setBorrowRate(address _strategy, uint256 _borrowRate) public onlySelf {
        ILeverageStrategy(_strategy).setBorrowRate(_borrowRate);
    }
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface ITrancheMaster {
    function setDuration(uint256 _duration) external;

    function setDevAddress(address _devAddress) external;

    function add(
        uint256 target,
        uint256 apy,
        uint256 fee
    ) external;

    function set(
        uint256 tid,
        uint256 target,
        uint256 apy,
        uint256 fee
    ) external;

    function balanceOf(address account) external view returns (uint256 balance, uint256 invested);

    function getInvest(uint256 tid) external view returns (uint256);

    function investDirect(
        uint256 amountIn,
        uint256 tid,
        uint256 amountInvest
    ) external;

    function deposit(uint256 amount) external;

    function invest(
        uint256 tid,
        uint256 amount,
        bool returnLeft
    ) external;

    function redeem(uint256 tid) external;

    function redeemDirect(uint256 tid) external;

    function withdraw(uint256 amount) external;

    function stop() external;

    function setStaker(address _staker) external;

    function setStrategy(address _strategy) external;

    function withdrawFee(uint256 amount) external;

    function transferFeeToStaking(uint256 _amount, address _pool) external;

    function producedFee() external view returns (uint256);

    function duration() external view returns (uint256);

    function cycle() external view returns (uint256);

    function actualStartAt() external view returns (uint256);

    function active() external view returns (bool);

    function tranches(uint256 id)
        external
        view
        returns (
            uint256 target,
            uint256 principal,
            uint256 apy,
            uint256 fee
        );

    function currency() external view returns (address);

    function staker() external view returns (address);

    function strategy() external view returns (address);

    function devAddress() external view returns (address);

    function userInfo(address account) external view returns (uint256);

    function userInvest(address account, uint256 tid) external view returns (uint256 cycle, uint256 principal);

    function trancheSnapshots(uint256 cycle, uint256 tid)
        external
        view
        returns (
            uint256 target,
            uint256 principal,
            uint256 capital,
            uint256 rate,
            uint256 apy,
            uint256 fee,
            uint256 startAt,
            uint256 stopAt
        );
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface IMasterWTF {
    function rewardToken() external view returns (address);

    function rewardPerBlock() external view returns (uint256);

    function totalAllocPoint() external view returns (uint256);

    function startBlock() external view returns (uint256);

    function endBlock() external view returns (uint256);

    function cycleId() external view returns (uint256);

    function rewarding() external view returns (bool);

    function votingEscrow() external view returns (address);

    function poolInfo(uint256 pid) external view returns (uint256);

    function userInfo(uint256 pid, address account)
        external
        view
        returns (
            uint256 amount,
            uint256 rewardDebt,
            uint256 cid,
            uint256 earned
        );

    function poolSnapshot(uint256 cid, uint256 pid)
        external
        view
        returns (
            uint256 totalSupply,
            uint256 lastRewardBlock,
            uint256 accRewardPerShare
        );

    function poolLength() external view returns (uint256);

    function add(uint256 _allocPoint) external;

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) external;

    function setVotingEscrow(address _votingEscrow) external;

    function getMultiplier(uint256 _from, uint256 _to) external view returns (uint256);

    function pendingReward(address _user, uint256 _pid) external view returns (uint256);

    function massUpdatePools() external;

    function updatePool(uint256 _pid) external;

    function updateStake(
        uint256 _pid,
        address _account,
        uint256 _amount
    ) external;

    function start(uint256 _endBlock) external;

    function next(uint256 _cid) external;

    function claim(
        uint256 _pid,
        uint256 _lockDurationIfNoLock,
        uint256 _newLockExpiryTsIfLockExists
    ) external;

    function claimAll(uint256 _lockDurationIfNoLock, uint256 _newLockExpiryTsIfLockExists) external;

    function updateRewardPerBlock(uint256 _rewardPerBlock) external;
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../refs/CoreRef.sol";
import "../interfaces/ITrancheMasterAutoMultiToken.sol";
import "../interfaces/IMasterWTF.sol";
import "../interfaces/IStrategyTokenOld.sol";
import "../interfaces/IFeeRewards.sol";
// import "@nomiclabs/buidler/console.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";

contract TrancheMasterAutoMultiToken is ITrancheMasterAutoMultiToken, CoreRef, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct TrancheParams {
        uint256 apy;
        uint256 fee;
        uint256 target;
    }

    struct Tranche {
        uint256 target;
        uint256 principal;
        uint256 autoPrincipal;
        uint256 apy;
        uint256 fee;
    }

    struct Token {
        address addr;
        address strategy;
        uint256 percent;
    }

    struct TrancheSnapshot {
        uint256 target;
        uint256 principal;
        uint256 rate;
        uint256 apy;
        uint256 fee;
        uint256 startAt;
        uint256 stopAt;
    }

    struct TokenSettle {
        uint256 capital;
        uint256 reward;
        uint256 profit;
        uint256 left;
        bool gain;
    }

    uint256 public constant PercentageParamScale = 1e5;
    uint256 public constant PercentageScale = 1e18;
    uint256 private constant MaxAPY = 100000;
    uint256 private constant MaxFee = 10000;

    mapping(address => uint256) public override producedFee;
    uint256 public override duration = 7 days;
    uint256 public override cycle;
    uint256 public override actualStartAt;
    bool public override active;
    Tranche[] public override tranches;
    address public override staker;

    address public override devAddress;
    Token[] public tokens;
    uint256 public tokenCount;

    // user => token => balance
    mapping(address => mapping(address => uint256)) public userBalances;

    // user => isAuto
    mapping(address => bool) public userIsAuto;

    // user => cycle
    mapping(address => uint256) public userCycle;

    // user => trancheID => token => amount
    mapping(address => mapping(uint256 => mapping(address => uint256))) public override userInvest;

    // cycle => trancheID => token => amount
    mapping(uint256 => mapping(uint256 => mapping(address => uint256))) public override trancheInvest;

    // cycle => trancheID => snapshot
    mapping(uint256 => mapping(uint256 => TrancheSnapshot)) public override trancheSnapshots;

    // cycle => token => TokenSettle
    mapping(uint256 => mapping(address => TokenSettle)) public tokenSettles;

    event Deposit(address account, address token, uint256 amount);

    event Invest(address account, uint256 tid, uint256 cycle, address token, uint256 amount);

    event Redeem(address account, uint256 tid, uint256 cycle, address token, uint256 amount);

    event Withdraw(address account, address token, uint256 amount);

    event WithdrawFee(address account, address token, uint256 amount);

    event Harvest(address account, uint256 tid, uint256 cycle, uint256 principal, uint256 capital);

    event TrancheAdd(uint256 tid, uint256 target, uint256 apy, uint256 fee);

    event TrancheUpdated(uint256 tid, uint256 target, uint256 apy, uint256 fee);

    event TrancheStart(uint256 tid, uint256 cycle, uint256 principal);

    event TrancheSettle(uint256 tid, uint256 cycle, uint256 principal, uint256 capital, uint256 rate);

    event SetDevAddress(address dev);

    modifier checkTranches() {
        require(tranches.length > 1, "tranches is incomplete");
        require(tranches[tranches.length - 1].apy == 0, "the last tranche must carry zero apy");
        _;
    }

    modifier checkTrancheID(uint256 tid) {
        require(tid < tranches.length, "invalid tranche id");
        _;
    }

    modifier checkActive() {
        require(active, "not active");
        _;
    }

    modifier checkNotActive() {
        require(!active, "already active");
        _;
    }

    modifier checkNotAuto() {
        require(!userIsAuto[msg.sender], "user autorolling");
        _;
    }

    modifier updateInvest() {
        _updateInvest(_msgSender());
        _;
    }

    constructor(
        address _core,
        address _staker,
        address _devAddress,
        uint256 _duration,
        TrancheParams[] memory _params,
        Token[] memory _tokens
    ) public CoreRef(_core) {
        staker = _staker;
        devAddress = _devAddress;
        duration = _duration;

        for (uint256 i = 0; i < _params.length; i++) {
            _add(_params[i].target, _params[i].apy, _params[i].fee);
        }

        tokenCount = _tokens.length;
        uint256 total = 0;
        for (uint256 i = 0; i < tokenCount; i++) {
            total = total.add(_tokens[i].percent);
            tokens.push(Token({addr: _tokens[i].addr, strategy: _tokens[i].strategy, percent: _tokens[i].percent}));
        }
        require(total == PercentageParamScale, "invalid token percent");

        approveToken();
    }

    function approveToken() public {
        for (uint256 i = 0; i < tokenCount; i++) {
            IERC20(tokens[i].addr).safeApprove(tokens[i].strategy, uint256(-1));
        }
    }

    function setDuration(uint256 _duration) public override onlyGovernor {
        duration = _duration;
    }

    function setDevAddress(address _devAddress) public override onlyGovernor {
        devAddress = _devAddress;
        emit SetDevAddress(_devAddress);
    }

    function _add(
        uint256 target,
        uint256 apy,
        uint256 fee
    ) internal {
        require(target > 0, "invalid target");
        require(apy <= MaxAPY, "invalid APY");
        require(fee <= MaxFee, "invalid fee");
        tranches.push(
            Tranche({
                target: target,
                apy: apy.mul(PercentageScale).div(PercentageParamScale),
                fee: fee,
                principal: 0,
                autoPrincipal: 0
            })
        );
        emit TrancheAdd(tranches.length - 1, target, apy, fee);
    }

    function add(
        uint256 target,
        uint256 apy,
        uint256 fee
    ) public override onlyGovernor {
        _add(target, apy, fee);
    }

    function set(
        uint256 tid,
        uint256 target,
        uint256 apy,
        uint256 fee
    ) public override onlyTimelock checkTrancheID(tid) {
        require(target >= tranches[tid].principal, "invalid target");
        require(apy <= MaxAPY, "invalid APY");
        require(fee <= MaxFee, "invalid fee");
        tranches[tid].target = target;
        tranches[tid].apy = apy.mul(PercentageScale).div(PercentageParamScale);
        tranches[tid].fee = fee;
        emit TrancheUpdated(tid, target, apy, fee);
    }

    struct UpdateInvestVals {
        uint256 sum;
        uint256 capital;
        uint256 principal;
        uint256 total;
        uint256 left;
        uint256 amt;
        uint256 aj;
        uint256[] amounts;
        TokenSettle settle1;
        TokenSettle settle2;
        TrancheSnapshot snapshot;
    }

    function _updateInvest(address account) internal {
        uint256 _cycle = userCycle[account];
        if (_cycle == cycle) {
            return;
        }

        UpdateInvestVals memory v;
        v.sum = 0;
        v.amounts = new uint256[](tokenCount);

        for (uint256 i = 0; i < tokenCount; i++) {
            v.settle1 = tokenSettles[_cycle][tokens[i].addr];
            if (v.settle1.gain) {
                v.sum = v.sum.add(v.settle1.profit);
            }
        }

        for (uint256 i = 0; i < tranches.length; i++) {
            v.snapshot = trancheSnapshots[_cycle][i];
            v.capital = 0;
            v.principal = 0;

            if (userIsAuto[account]) {
                for (uint256 j = 0; j < tokenCount; j++) {
                    v.amt = userInvest[account][i][tokens[j].addr];
                    if (v.amt == 0) {
                        continue;
                    }

                    for (uint k = _cycle; k < cycle; k++) {
                        v.amt = v.amt.mul(trancheSnapshots[k][i].rate).div(PercentageScale);
                        emit Harvest(account, i, k, v.amt, v.amt);
                    }
                    userInvest[account][i][tokens[j].addr] = v.amt;
                    v.principal = v.principal.add(v.amt);
                }
                IMasterWTF(staker).updateStake(i, account, v.principal);
            } else {
                for (uint256 j = 0; j < tokenCount; j++) {
                    v.amt = userInvest[account][i][tokens[j].addr];
                    if (v.amt == 0) {
                        continue;
                    }

                    v.principal = v.principal.add(v.amt);

                    v.settle1 = tokenSettles[_cycle][tokens[j].addr];
                    v.total = v.amt.mul(v.snapshot.rate).div(PercentageScale);
                    v.left = v.total >= v.amt ? v.total.sub(v.amt) : 0;

                    v.capital = v.capital.add(v.total);
                    if (v.settle1.gain || 0 == v.left) {
                        v.amounts[j] = v.amounts[j].add(v.total);
                    } else {
                        v.amounts[j] = v.amounts[j].add(v.amt);

                        v.aj = v.left.mul(v.settle1.reward).div(v.settle1.reward.add(v.settle1.profit));
                        v.amounts[j] = v.amounts[j].add(v.aj);
                        v.aj = v.left.mul(v.settle1.profit).div(v.settle1.reward.add(v.settle1.profit));
                        for (uint256 k = 0; k < tokenCount; k++) {
                            if (j == k) {
                                continue;
                            }
                            v.settle2 = tokenSettles[_cycle][tokens[k].addr];
                            if (v.settle2.gain) {
                                v.amounts[k] = v.amounts[k].add(v.aj.mul(v.settle2.profit).div(v.sum));
                            }
                        }
                    }

                    userInvest[account][i][tokens[j].addr] = 0;
                }

                if (v.principal > 0) {
                    IMasterWTF(staker).updateStake(i, account, 0);
                    emit Harvest(account, i, _cycle, v.principal, v.capital);
                }
            }
        }

        for (uint256 i = 0; i < tokenCount; i++) {
            if (v.amounts[i] > 0) {
                userBalances[account][tokens[i].addr] = v.amounts[i].add(userBalances[account][tokens[i].addr]);
            }
        }

        userCycle[account] = cycle;
    }

    function balanceOf(address account) public view override returns (uint256[] memory, uint256[] memory) {
        uint256[] memory balances = new uint256[](tokenCount);
        uint256[] memory invests = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            balances[i] = balances[i].add(userBalances[account][tokens[i].addr]);
        }

        UpdateInvestVals memory v;
        uint256 _cycle = userCycle[account];

        if (userIsAuto[account]) {
            for (uint256 i = 0; i < tokenCount; i++) {
                v.principal = 0;
                for (uint256 j = 0; j < tranches.length; j++) {
                    uint256 amt = userInvest[account][j][tokens[i].addr];
                    if (_cycle == cycle) {
                        v.principal = v.principal.add(amt);
                    } else {
                        for (uint k = _cycle; k < cycle; k++) {
                            if (amt > 0) {
                                amt = amt.mul(trancheSnapshots[k][j].rate).div(PercentageScale);
                                v.principal = v.principal.add(amt);
                            }
                        }
                    }
                }
                if (v.principal > 0) {
                    invests[i] = invests[i].add(v.principal);
                }
            }
            return (balances, invests);
        }

        if (_cycle == cycle) {
            for (uint256 i = 0; i < tokenCount; i++) {
                v.principal = 0;
                for (uint256 j = 0; j < tranches.length; j++) {
                    uint256 amt = userInvest[account][j][tokens[i].addr];
                    if (amt > 0) {
                        v.principal = v.principal.add(amt);
                    }
                }
                if (v.principal > 0) {
                    invests[i] = invests[i].add(v.principal);
                }
            }
            return (balances, invests);
        }

        v.sum = 0;
        v.amounts = new uint256[](tokenCount);

        for (uint256 i = 0; i < tokenCount; i++) {
            v.settle1 = tokenSettles[_cycle][tokens[i].addr];
            if (v.settle1.gain) {
                v.sum = v.sum.add(v.settle1.profit);
            }
        }

        for (uint256 i = 0; i < tranches.length; i++) {
            v.snapshot = trancheSnapshots[_cycle][i];
            v.capital = 0;
            v.principal = 0;
            for (uint256 j = 0; j < tokenCount; j++) {
                v.amt = userInvest[account][i][tokens[j].addr];
                if (v.amt == 0) {
                    continue;
                }

                v.principal = v.principal.add(v.amt);

                v.settle1 = tokenSettles[_cycle][tokens[j].addr];
                v.total = v.amt.mul(v.snapshot.rate).div(PercentageScale);
                v.left = v.total >= v.amt ? v.total.sub(v.amt) : 0;

                v.capital = v.capital.add(v.total);
                if (v.settle1.gain || 0 == v.left) {
                    v.amounts[j] = v.amounts[j].add(v.total);
                } else {
                    v.amounts[j] = v.amounts[j].add(v.amt);

                    v.aj = v.left.mul(v.settle1.reward).div(v.settle1.reward.add(v.settle1.profit));
                    v.amounts[j] = v.amounts[j].add(v.aj);
                    v.aj = v.left.mul(v.settle1.profit).div(v.settle1.reward.add(v.settle1.profit));
                    for (uint256 k = 0; k < tokenCount; k++) {
                        if (j == k) {
                            continue;
                        }
                        v.settle2 = tokenSettles[_cycle][tokens[k].addr];
                        if (v.settle2.gain) {
                            v.amounts[k] = v.amounts[k].add(v.aj.mul(v.settle2.profit).div(v.sum));
                        }
                    }
                }
            }
        }

        for (uint256 i = 0; i < tokenCount; i++) {
            if (v.amounts[i] > 0) {
                balances[i] = v.amounts[i].add(balances[i]);
            }
        }

        return (balances, invests);
    }

    function switchAuto(bool _auto) public override updateInvest nonReentrant {

        if (userIsAuto[msg.sender] == _auto) {
            return;
        }

        for (uint i = 0; i < tranches.length; i++) {
            uint256 principal = 0;
            for (uint256 j = 0; j < tokenCount; j++) {
                principal = principal + userInvest[msg.sender][i][tokens[j].addr];
            }

            if (principal == 0) {
                continue;
            }

            Tranche storage t = tranches[i];
            if (_auto) {
                t.principal = t.principal.sub(principal);
                t.autoPrincipal = t.autoPrincipal.add(principal);
            } else {
                t.principal = t.principal.add(principal);
                t.autoPrincipal = t.autoPrincipal.sub(principal);
            }
        }

        userIsAuto[msg.sender] = _auto;
    }

    function _tryStart() internal returns (bool) {
        for (uint256 i = 0; i < tranches.length; i++) {
            Tranche memory t = tranches[i];
            if (t.principal.add(t.autoPrincipal) < t.target) {
                return false;
            }
        }

        _startCycle();

        return true;
    }

    // no other function call _sumBalance, what is the purpose?
    function _sumBalance(address account) private returns (uint256 ret) {
        for (uint256 i = 0; i < tokenCount; i++) {
            ret = ret.add(userBalances[account][tokens[i].addr]);
        }
    }

    function investDirect(
        uint256 tid,
        uint256[] calldata amountsIn,
        uint256[] calldata amountsInvest
    ) external override checkTrancheID(tid) checkNotActive updateInvest nonReentrant {
        require(amountsIn.length == tokenCount, "invalid amountsIn");
        require(amountsInvest.length == tokenCount, "invalid amountsInvest");

        for (uint256 i = 0; i < tokenCount; i++) {
            IERC20(tokens[i].addr).safeTransferFrom(msg.sender, address(this), amountsIn[i]);
            userBalances[msg.sender][tokens[i].addr] = amountsIn[i].add(userBalances[msg.sender][tokens[i].addr]);
            emit Deposit(msg.sender, tokens[i].addr, amountsIn[i]);
        }

        _invest(tid, amountsInvest, false);
    }

    function deposit(uint256[] calldata amountsIn) external override updateInvest nonReentrant {
        require(amountsIn.length == tokenCount, "invalid amountsIn");
        for (uint256 i = 0; i < tokenCount; i++) {
            IERC20(tokens[i].addr).safeTransferFrom(msg.sender, address(this), amountsIn[i]);
            userBalances[msg.sender][tokens[i].addr] = amountsIn[i].add(userBalances[msg.sender][tokens[i].addr]);
            emit Deposit(msg.sender, tokens[i].addr, amountsIn[i]);
        }
    }

    function invest(
        uint256 tid,
        uint256[] calldata amountsIn,
        bool returnLeft
    ) external override checkTrancheID(tid) checkNotActive updateInvest nonReentrant {
        require(amountsIn.length == tokenCount, "invalid amountsIn");
        _invest(tid, amountsIn, returnLeft);
    }

    function _invest(
        uint256 tid,
        uint256[] calldata amountsIn,
        bool returnLeft
    ) internal {
        Tranche storage t = tranches[tid];

        uint256 total = 0;
        for (uint256 i = 0; i < tokenCount; i++) {
            total = amountsIn[i].add(total);
        }

        require(t.target >= t.principal.add(t.autoPrincipal).add(total), "not enough quota");

        uint256 totalTarget = 0;
        for (uint256 i = 0; i < tranches.length; i++) {
            totalTarget = totalTarget.add(tranches[i].target);
        }

        for (uint256 i = 0; i < tokenCount; i++) {
            uint256 target = totalTarget.mul(tokens[i].percent).div(PercentageParamScale);
            uint256 amt = amountsIn[i];
            if (amt == 0) {
                continue;
            }
            uint256 already = 0;
            for (uint256 j = 0; j < tranches.length; j++) {
                already = already.add(trancheInvest[cycle][j][tokens[i].addr]);
            }
            require(amt.add(already) <= target);
            userBalances[msg.sender][tokens[i].addr] = userBalances[msg.sender][tokens[i].addr].sub(amt);
            trancheInvest[cycle][tid][tokens[i].addr] = trancheInvest[cycle][tid][tokens[i].addr].add(amt);
            userInvest[msg.sender][tid][tokens[i].addr] = userInvest[msg.sender][tid][tokens[i].addr].add(amt);

            emit Invest(msg.sender, tid, cycle, tokens[i].addr, amt);
        }

        if (userIsAuto[msg.sender]) {
            t.autoPrincipal = t.autoPrincipal.add(total);
        } else {
            t.principal = t.principal.add(total);
        }

        uint256 principal = 0;
        for (uint256 i = 0; i < tokenCount; i++) {
            principal = principal.add(userInvest[msg.sender][tid][tokens[i].addr]);
        }
        IMasterWTF(staker).updateStake(tid, msg.sender, principal);

        if (returnLeft) {
            for (uint256 i = 0; i < tokenCount; i++) {
                uint256 b = userBalances[msg.sender][tokens[i].addr];
                if (b > 0) {
                    IERC20(tokens[i].addr).safeTransfer(msg.sender, b);
                    userBalances[msg.sender][tokens[i].addr] = 0;
                    emit Withdraw(msg.sender, tokens[i].addr, b);
                }
            }
        }

        _tryStart();
    }

    function redeem(uint256 tid)
        public
        override
        checkTrancheID(tid)
        checkNotActive
        checkNotAuto
        updateInvest
        nonReentrant 
    {
        _redeem(tid);
    }

    function _redeem(uint256 tid) private returns (uint256[] memory) {
        uint256 total = 0;
        uint256[] memory amountOuts = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            uint256 amt = userInvest[msg.sender][tid][tokens[i].addr];
            if (amt == 0) {
                continue;
            }

            userBalances[msg.sender][tokens[i].addr] = userBalances[msg.sender][tokens[i].addr].add(amt);
            trancheInvest[cycle][tid][tokens[i].addr] = trancheInvest[cycle][tid][tokens[i].addr].sub(amt);
            userInvest[msg.sender][tid][tokens[i].addr] = 0;

            total = total.add(amt);
            amountOuts[i] = amt;
            emit Redeem(msg.sender, tid, cycle, tokens[i].addr, amt);
        }

        Tranche storage t = tranches[tid];
        t.principal = t.principal.sub(total);

        IMasterWTF(staker).updateStake(tid, msg.sender, 0);

        return amountOuts;
    }

    function redeemDirect(uint256 tid)
        external 
        override 
        checkTrancheID(tid) 
        checkNotActive
        checkNotAuto 
        updateInvest 
        nonReentrant 
    {
        uint256[] memory amountOuts = _redeem(tid);
        _withdraw(amountOuts);
    }

    function _withdraw(uint256[] memory amountOuts) internal {
        for (uint256 i = 0; i < tokenCount; i++) {
            uint256 amt = amountOuts[i];
            if (amt > 0) {
                userBalances[msg.sender][tokens[i].addr] = userBalances[msg.sender][tokens[i].addr].sub(amt);
                IERC20(tokens[i].addr).safeTransfer(msg.sender, amt);
                emit Withdraw(msg.sender, tokens[i].addr, amt);
            }
        }
    }

    function withdraw(uint256[] memory amountOuts) public override updateInvest nonReentrant {
        _withdraw(amountOuts);
    }

    function _startCycle() internal checkNotActive {
        uint256 total = 0;
        for (uint256 i = 0; i < tranches.length; i++) {
            Tranche memory t = tranches[i];
            total = total.add(t.principal).add(t.autoPrincipal);
        }

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 amt = total.mul(tokens[i].percent).div(PercentageParamScale);
            IStrategyToken(tokens[i].strategy).deposit(amt);
        }

        actualStartAt = block.timestamp;
        active = true;
        for (uint256 i = 0; i < tranches.length; i++) {
            emit TrancheStart(i, cycle, tranches[i].principal.add(tranches[i].autoPrincipal));
        }
        IMasterWTF(staker).start(block.number.add(duration.div(3)));
    }

    function _stopCycle() internal {
        require(block.timestamp >= actualStartAt + duration, "cycle not expired");
        _processExit();
        active = false;
        cycle++;
        IMasterWTF(staker).next(cycle);
    }

    function _calculateExchangeRate(uint256 current, uint256 base) internal pure returns (uint256) {
        if (current == base) {
            return PercentageScale;
        } else if (current > base) {
            return PercentageScale.add((current - base).mul(PercentageScale).div(base));
        } else {
            return PercentageScale.sub((base - current).mul(PercentageScale).div(base));
        }
    }

    function _getTotalTarget() internal returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < tranches.length; i++) {
            total = total.add(tranches[i].target);
        }
        return total;
    }

    function _redeemAll() internal returns (uint256[] memory, uint256) {
        uint256 total = 0;
        uint256 before;
        uint256[] memory capitals = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            Token memory token = tokens[i];
            before = IERC20(token.addr).balanceOf(address(this));
            IStrategyToken(token.strategy).withdraw();
            capitals[i] = IERC20(token.addr).balanceOf(address(this)).sub(before);
            total = total.add(capitals[i]);
        }
        return (capitals, total);
    }

    struct ExitVals {
        uint256 totalTarget;
        uint256[] capitals;
        uint256 restCapital;
        uint256 interest;
        uint256 rate;
        uint256 capital;
        uint256 principal;
        uint256 now;
        uint256 totalFee;
        uint256 all;
        bool satisfied;
        Token token;
    }

    function _processExit() internal {
        ExitVals memory v;

        v.now = block.timestamp;
        v.totalTarget = _getTotalTarget();
        (v.capitals, v.restCapital) = _redeemAll();

        for (uint256 i = 0; i < tranches.length - 1; i++) {
            Tranche storage senior = tranches[i];
            v.principal = senior.principal.add(senior.autoPrincipal);
            v.capital = 0;
            v.interest = senior.principal
                .mul(senior.apy)
                .mul(v.now - actualStartAt)
                .div(365)
                .div(86400)
                .div(PercentageScale);

            v.all = v.principal.add(v.interest);
            v.satisfied = v.restCapital >= v.all;
            if (!v.satisfied) {
                v.capital = v.restCapital;
                v.restCapital = 0;
            } else {
                v.capital = v.all;
                v.restCapital = v.restCapital.sub(v.all);
            }

            if (v.satisfied) {
                uint256 fee = v.capital.mul(senior.fee).div(PercentageParamScale);
                v.totalFee = v.totalFee.add(fee);
                v.capital = v.capital.sub(fee);
            }

            v.rate = _calculateExchangeRate(v.capital, v.principal);
            trancheSnapshots[cycle][i] = TrancheSnapshot({
                target: senior.target,
                principal: v.principal,
                rate: v.rate,
                apy: senior.apy,
                fee: senior.fee,
                startAt: actualStartAt,
                stopAt: v.now
            });

            senior.principal = 0;
            senior.autoPrincipal = senior.autoPrincipal.mul(v.rate).div(PercentageScale);

            emit TrancheSettle(i, cycle, v.principal, v.capital, v.rate);
        }

        {
            uint256 juniorIndex = tranches.length - 1;
            Tranche storage junior = tranches[juniorIndex];
            v.principal = junior.principal.add(junior.autoPrincipal);
            v.capital = v.restCapital;
            uint256 fee = v.capital.mul(junior.fee).div(PercentageParamScale);
            v.totalFee = v.totalFee.add(fee);
            v.capital = v.capital.sub(fee);
            v.rate = _calculateExchangeRate(v.capital, v.principal);
            trancheSnapshots[cycle][juniorIndex] = TrancheSnapshot({
                target: junior.target,
                principal: v.principal,
                rate: v.rate,
                apy: junior.apy,
                fee: junior.fee,
                startAt: actualStartAt,
                stopAt: v.now
            });

            junior.principal = 0;
            junior.autoPrincipal = junior.autoPrincipal.mul(v.rate).div(PercentageScale);

            emit TrancheSettle(juniorIndex, cycle, v.principal, v.capital, v.rate);
        }

        for (uint256 i = 0; i < tokenCount; i++) {
            v.token = tokens[i];
            uint256 target = v.totalTarget.mul(v.token.percent).div(PercentageParamScale);
            uint256 fee = v.totalFee.mul(v.token.percent).div(PercentageParamScale);
            v.capital = v.capitals[i];
            if (v.capital >= fee) {
                v.capital = v.capital.sub(fee);
                producedFee[v.token.addr] = producedFee[v.token.addr].add(fee);
            }

            uint256 reward = v.capital > target ? v.capital.sub(target) : 0;
            uint256 pay = 0;
            v.principal = 0;
            for (uint256 j = 0; j < tranches.length; j++) {
                uint256 p = trancheInvest[cycle][j][v.token.addr];
                pay = pay.add(p.mul(trancheSnapshots[cycle][j].rate).div(PercentageScale));
            }

            tokenSettles[cycle][v.token.addr] = TokenSettle({
                capital: v.capital,
                reward: reward,
                profit: v.capital >= pay ? v.capital.sub(pay) : pay.sub(v.capital),
                left: v.capital,
                gain: v.capital >= pay
            });
        }
    }

    function stop() public override checkActive nonReentrant onlyGovernor {
        _stopCycle();
        _tryStart();
    }

    function withdrawFee() public override {
        require(devAddress != address(0), "devAddress not set");
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 amount = producedFee[tokens[i].addr];
            IERC20(tokens[i].addr).safeTransfer(devAddress, amount);
            producedFee[tokens[i].addr] = 0;
            emit WithdrawFee(devAddress, tokens[i].addr, amount);
        }
    }
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface ITrancheMasterAutoMultiToken {
    function setDuration(uint256 _duration) external;

    function setDevAddress(address _devAddress) external;

    function add(
        uint256 target,
        uint256 apy,
        uint256 fee
    ) external;

    function set(
        uint256 tid,
        uint256 target,
        uint256 apy,
        uint256 fee
    ) external;

    function balanceOf(address account) external view returns (uint256[] memory, uint256[] memory);

    function switchAuto(bool _auto) external;

    function investDirect(
        uint256 tid,
        uint256[] calldata amountsIn,
        uint256[] calldata amountsInvest
    ) external;

    function deposit(uint256[] calldata amountsIn) external;

    function invest(
        uint256 tid,
        uint256[] calldata amountsIn,
        bool returnLeft
    ) external;

    function redeem(uint256 tid) external;

    function redeemDirect(uint256 tid) external;

    function withdraw(uint256[] calldata amountOuts) external;

    function stop() external;

    function withdrawFee() external;

    function producedFee(address token) external view returns (uint256);

    function duration() external view returns (uint256);

    function cycle() external view returns (uint256);

    function actualStartAt() external view returns (uint256);

    function active() external view returns (bool);

    function tranches(uint256 id)
        external
        view
        returns (
            uint256 target,
            uint256 principal,
            uint256 autoPrincipal,
            uint256 apy,
            uint256 fee
        );

    function staker() external view returns (address);

    function devAddress() external view returns (address);

    function userInvest(
        address account,
        uint256 tid,
        address token
    ) external view returns (uint256);

    function trancheInvest(
        uint256 cycle,
        uint256 tid,
        address token
    ) external view returns (uint256);

    function trancheSnapshots(uint256 cycle, uint256 tid)
        external
        view
        returns (
            uint256 target,
            uint256 principal,
            uint256 rate,
            uint256 apy,
            uint256 fee,
            uint256 startAt,
            uint256 stopAt
        );
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface IStrategyToken {
    function token() external view returns (address);

    function deposit(uint256 _amount) external;

    function withdraw() external;

    function approveToken() external;
}

interface IMultiStrategyToken is IStrategyToken {
    function strategies(uint256 idx) external view returns (address);

    function strategyCount() external view returns (uint256);

    function ratios(address _strategy) external view returns (uint256);

    function ratioTotal() external view returns (uint256);

    function changeRatio(uint256 _index, uint256 _value) external;

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) external;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IFeeRewards {
    function sendRewards(uint256 _amount) external;
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../refs/CoreRef.sol";
import "../interfaces/ITrancheMasterMultiToken.sol";
import "../interfaces/IMasterWTF.sol";
import "../interfaces/IStrategyTokenOld.sol";
import "../interfaces/IFeeRewards.sol";

contract TrancheMasterMultiToken is ITrancheMasterMultiToken, CoreRef, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct TrancheParams {
        uint256 apy;
        uint256 fee;
        uint256 target;
    }

    struct Tranche {
        uint256 target;
        uint256 principal;
        uint256 apy;
        uint256 fee;
    }

    struct Token {
        address addr;
        address strategy;
        uint256 percent;
    }

    struct TrancheSnapshot {
        uint256 target;
        uint256 principal;
        uint256 rate;
        uint256 apy;
        uint256 fee;
        uint256 startAt;
        uint256 stopAt;
    }

    struct TokenSettle {
        uint256 capital;
        uint256 reward;
        uint256 profit;
        uint256 left;
        bool gain;
    }

    uint256 public constant PercentageParamScale = 1e5;
    uint256 public constant PercentageScale = 1e18;
    uint256 private constant MaxAPY = 100000;
    uint256 private constant MaxFee = 10000;

    mapping(address => uint256) public override producedFee;
    uint256 public override duration = 7 days;
    uint256 public override cycle;
    uint256 public override actualStartAt;
    bool public override active;
    Tranche[] public override tranches;
    address public override staker;

    address public override devAddress;
    Token[] public tokens;
    uint256 public tokenCount;

    // user => token => balance
    mapping(address => mapping(address => uint256)) public userBalances;

    // user => cycle
    mapping(address => uint256) public userCycle;

    // user => trancheID => token => amount
    mapping(address => mapping(uint256 => mapping(address => uint256))) public override userInvest;

    // cycle => trancheID => token => amount
    mapping(uint256 => mapping(uint256 => mapping(address => uint256))) public override trancheInvest;

    // cycle => trancheID => snapshot
    mapping(uint256 => mapping(uint256 => TrancheSnapshot)) public override trancheSnapshots;

    // cycle => token => TokenSettle
    mapping(uint256 => mapping(address => TokenSettle)) public tokenSettles;

    event Deposit(address account, address token, uint256 amount);

    event Invest(address account, uint256 tid, uint256 cycle, uint256 tokenId, uint256 amount);

    event Redeem(address account, uint256 tid, uint256 cycle, uint256 tokenId, uint256 amount);

    event Withdraw(address account, address token, uint256 amount);

    event WithdrawFee(address account, address token, uint256 amount);

    event Harvest(address account, uint256 tid, uint256 cycle, uint256 tokenId, uint256 amount);

    event TrancheAdd(uint256 tid, uint256 target, uint256 apy, uint256 fee);

    event TrancheUpdated(uint256 tid, uint256 target, uint256 apy, uint256 fee);

    event TrancheStart(uint256 tid, uint256 cycle, uint256 principal);

    event TrancheSettle(uint256 tid, uint256 cycle, uint256 principal, uint256 capital, uint256 rate);

    event SetDevAddress(address dev);

    modifier checkTranches() {
        require(tranches.length > 1, "tranches is incomplete");
        require(tranches[tranches.length - 1].apy == 0, "the last tranche must carry zero apy");
        _;
    }

    modifier checkTrancheID(uint256 tid) {
        require(tid < tranches.length, "invalid tranche id");
        _;
    }

    modifier checkActive() {
        require(active, "not active");
        _;
    }

    modifier checkNotActive() {
        require(!active, "already active");
        _;
    }

    modifier updateInvest() {
        _updateInvest(_msgSender());
        _;
    }

    constructor(
        address _core,
        address _staker,
        address _devAddress,
        uint256 _duration,
        TrancheParams[] memory _params,
        Token[] memory _tokens
    ) public CoreRef(_core) {
        staker = _staker;
        devAddress = _devAddress;
        duration = _duration;

        for (uint256 i = 0; i < _params.length; i++) {
            _add(_params[i].target, _params[i].apy, _params[i].fee);
        }

        tokenCount = _tokens.length;
        uint256 total = 0;
        for (uint256 i = 0; i < tokenCount; i++) {
            total = total.add(_tokens[i].percent);
            tokens.push(Token({addr: _tokens[i].addr, strategy: _tokens[i].strategy, percent: _tokens[i].percent}));
        }
        require(total == PercentageParamScale, "invalid token percent");

        approveToken();
    }

    function approveToken() public {
        for (uint256 i = 0; i < tokenCount; i++) {
            IERC20(tokens[i].addr).safeApprove(tokens[i].strategy, uint256(-1));
        }
    }

    function setDuration(uint256 _duration) public override onlyGovernor {
        duration = _duration;
    }

    function setDevAddress(address _devAddress) public override onlyGovernor {
        devAddress = _devAddress;
        emit SetDevAddress(_devAddress);
    }

    function _add(
        uint256 target,
        uint256 apy,
        uint256 fee
    ) internal {
        require(target > 0, "invalid target");
        require(apy <= MaxAPY, "invalid APY");
        require(fee <= MaxFee, "invalid fee");
        tranches.push(
            Tranche({target: target, apy: apy.mul(PercentageScale).div(PercentageParamScale), fee: fee, principal: 0})
        );
        emit TrancheAdd(tranches.length - 1, target, apy, fee);
    }

    function add(
        uint256 target,
        uint256 apy,
        uint256 fee
    ) public override onlyGovernor {
        _add(target, apy, fee);
    }

    function set(
        uint256 tid,
        uint256 target,
        uint256 apy,
        uint256 fee
    ) public override onlyTimelock checkTrancheID(tid) {
        require(target >= tranches[tid].principal, "invalid target");
        require(apy <= MaxAPY, "invalid APY");
        require(fee <= MaxFee, "invalid fee");
        tranches[tid].target = target;
        tranches[tid].apy = apy.mul(PercentageScale).div(PercentageParamScale);
        tranches[tid].fee = fee;
        emit TrancheUpdated(tid, target, apy, fee);
    }

    struct UpdateInvestVals {
        uint256 sum;
        uint256 capital;
        uint256 principal;
        uint256 total;
        uint256 left;
        uint256 amt;
        uint256 aj;
        uint256[] amounts;
        TokenSettle settle1;
        TokenSettle settle2;
        TrancheSnapshot snapshot;
    }

    function _updateInvest(address account) internal {
        uint256 _cycle = userCycle[account];
        if (_cycle == cycle) {
            return;
        }

        UpdateInvestVals memory v;
        v.sum = 0;
        v.amounts = new uint256[](tokenCount);

        for (uint256 i = 0; i < tokenCount; i++) {
            v.settle1 = tokenSettles[_cycle][tokens[i].addr];
            if (v.settle1.gain) {
                v.sum = v.sum.add(v.settle1.profit);
            }
        }

        for (uint256 i = 0; i < tranches.length; i++) {
            v.snapshot = trancheSnapshots[_cycle][i];
            v.capital = 0;
            v.principal = 0;
            for (uint256 j = 0; j < tokenCount; j++) {
                v.amt = userInvest[account][i][tokens[j].addr];
                if (v.amt == 0) {
                    continue;
                }

                v.principal = v.principal.add(v.amt);

                v.settle1 = tokenSettles[_cycle][tokens[j].addr];
                v.total = v.amt.mul(v.snapshot.rate).div(PercentageScale);
                v.left = v.total >= v.amt ? v.total.sub(v.amt) : 0;

                v.capital = v.capital.add(v.total);
                if (v.settle1.gain || 0 == v.left) {
                    v.amounts[j] = v.amounts[j].add(v.total);
                } else {
                    v.amounts[j] = v.amounts[j].add(v.amt);

                    v.aj = v.left.mul(v.settle1.reward).div(v.settle1.reward.add(v.settle1.profit));
                    v.amounts[j] = v.amounts[j].add(v.aj);
                    v.aj = v.left.mul(v.settle1.profit).div(v.settle1.reward.add(v.settle1.profit));
                    for (uint256 k = 0; k < tokenCount; k++) {
                        if (j == k) {
                            continue;
                        }
                        v.settle2 = tokenSettles[_cycle][tokens[k].addr];
                        if (v.settle2.gain) {
                            v.amounts[k] = v.amounts[k].add(v.aj.mul(v.settle2.profit).div(v.sum));
                        }
                    }
                }

                userInvest[account][i][tokens[j].addr] = 0;
                emit Harvest(account, i, _cycle, j, v.amounts[j]);
            }

            if (v.principal > 0) {
                IMasterWTF(staker).updateStake(i, account, 0);
                // emit Harvest(account, i, _cycle, v.principal, v.capital);
            }
        }

        for (uint256 i = 0; i < tokenCount; i++) {
            if (v.amounts[i] > 0) {
                userBalances[account][tokens[i].addr] = v.amounts[i].add(userBalances[account][tokens[i].addr]);
            }
        }

        userCycle[account] = cycle;
    }

    function balanceOf(address account) public view override returns (uint256[] memory, uint256[] memory) {
        uint256[] memory balances = new uint256[](tokenCount);
        uint256[] memory invests = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            balances[i] = balances[i].add(userBalances[account][tokens[i].addr]);
        }

        UpdateInvestVals memory v;
        uint256 _cycle = userCycle[account];
        if (_cycle == cycle) {
            for (uint256 i = 0; i < tokenCount; i++) {
                v.principal = 0;
                for (uint256 j = 0; j < tranches.length; j++) {
                    uint256 amt = userInvest[account][j][tokens[i].addr];
                    if (amt > 0) {
                        v.principal = v.principal.add(amt);
                    }
                }
                if (v.principal > 0) {
                    invests[i] = invests[i].add(v.principal);
                }
            }
            return (balances, invests);
        }

        v.sum = 0;
        v.amounts = new uint256[](tokenCount);

        for (uint256 i = 0; i < tokenCount; i++) {
            v.settle1 = tokenSettles[_cycle][tokens[i].addr];
            if (v.settle1.gain) {
                v.sum = v.sum.add(v.settle1.profit);
            }
        }

        for (uint256 i = 0; i < tranches.length; i++) {
            v.snapshot = trancheSnapshots[_cycle][i];
            v.capital = 0;
            v.principal = 0;
            for (uint256 j = 0; j < tokenCount; j++) {
                v.amt = userInvest[account][i][tokens[j].addr];
                if (v.amt == 0) {
                    continue;
                }

                v.principal = v.principal.add(v.amt);

                v.settle1 = tokenSettles[_cycle][tokens[j].addr];
                v.total = v.amt.mul(v.snapshot.rate).div(PercentageScale);
                v.left = v.total >= v.amt ? v.total.sub(v.amt) : 0;

                v.capital = v.capital.add(v.total);
                if (v.settle1.gain || 0 == v.left) {
                    v.amounts[j] = v.amounts[j].add(v.total);
                } else {
                    v.amounts[j] = v.amounts[j].add(v.amt);

                    v.aj = v.left.mul(v.settle1.reward).div(v.settle1.reward.add(v.settle1.profit));
                    v.amounts[j] = v.amounts[j].add(v.aj);
                    v.aj = v.left.mul(v.settle1.profit).div(v.settle1.reward.add(v.settle1.profit));
                    for (uint256 k = 0; k < tokenCount; k++) {
                        if (j == k) {
                            continue;
                        }
                        v.settle2 = tokenSettles[_cycle][tokens[k].addr];
                        if (v.settle2.gain) {
                            v.amounts[k] = v.amounts[k].add(v.aj.mul(v.settle2.profit).div(v.sum));
                        }
                    }
                }
            }
        }

        for (uint256 i = 0; i < tokenCount; i++) {
            if (v.amounts[i] > 0) {
                balances[i] = v.amounts[i].add(balances[i]);
            }
        }

        return (balances, invests);
    }

    function _tryStart() internal returns (bool) {
        for (uint256 i = 0; i < tranches.length; i++) {
            Tranche memory t = tranches[i];
            if (t.principal < t.target) {
                return false;
            }
        }

        _startCycle();

        return true;
    }

    function _sumBalance(address account) private returns (uint256 ret) {
        for (uint256 i = 0; i < tokenCount; i++) {
            ret = ret.add(userBalances[account][tokens[i].addr]);
        }
    }

    function investDirect(
        uint256 tid,
        uint256[] calldata amountsIn,
        uint256[] calldata amountsInvest
    ) external override checkTrancheID(tid) checkNotActive updateInvest nonReentrant {
        require(amountsIn.length == tokenCount, "invalid amountsIn");
        require(amountsInvest.length == tokenCount, "invalid amountsInvest");

        for (uint256 i = 0; i < tokenCount; i++) {
            IERC20(tokens[i].addr).safeTransferFrom(msg.sender, address(this), amountsIn[i]);
            userBalances[msg.sender][tokens[i].addr] = amountsIn[i].add(userBalances[msg.sender][tokens[i].addr]);
            emit Deposit(msg.sender, tokens[i].addr, amountsIn[i]);
        }

        _invest(tid, amountsInvest, false);
    }

    function deposit(uint256[] calldata amountsIn) external override updateInvest nonReentrant {
        require(amountsIn.length == tokenCount, "invalid amountsIn");
        for (uint256 i = 0; i < tokenCount; i++) {
            IERC20(tokens[i].addr).safeTransferFrom(msg.sender, address(this), amountsIn[i]);
            userBalances[msg.sender][tokens[i].addr] = amountsIn[i].add(userBalances[msg.sender][tokens[i].addr]);
            emit Deposit(msg.sender, tokens[i].addr, amountsIn[i]);
        }
    }

    function invest(
        uint256 tid,
        uint256[] calldata amountsIn,
        bool returnLeft
    ) external override checkTrancheID(tid) checkNotActive updateInvest nonReentrant {
        require(amountsIn.length == tokenCount, "invalid amountsIn");
        _invest(tid, amountsIn, returnLeft);
    }

    function _invest(
        uint256 tid,
        uint256[] calldata amountsIn,
        bool returnLeft
    ) internal {
        Tranche storage t = tranches[tid];

        uint256 total = 0;
        for (uint256 i = 0; i < tokenCount; i++) {
            total = amountsIn[i].add(total);
        }

        require(t.target >= t.principal.add(total), "not enough quota");

        uint256 totalTarget = 0;
        for (uint256 i = 0; i < tranches.length; i++) {
            totalTarget = totalTarget.add(tranches[i].target);
        }

        for (uint256 i = 0; i < tokenCount; i++) {
            uint256 target = totalTarget.mul(tokens[i].percent).div(PercentageParamScale);
            uint256 amt = amountsIn[i];
            emit Invest(msg.sender, tid, cycle, i, amt);
            if (amt == 0) {
                continue;
            }
            uint256 already = 0;
            for (uint256 j = 0; j < tranches.length; j++) {
                already = already.add(trancheInvest[cycle][j][tokens[i].addr]);
            }
            require(amt.add(already) <= target);
            userBalances[msg.sender][tokens[i].addr] = userBalances[msg.sender][tokens[i].addr].sub(amt);
            trancheInvest[cycle][tid][tokens[i].addr] = trancheInvest[cycle][tid][tokens[i].addr].add(amt);
            userInvest[msg.sender][tid][tokens[i].addr] = userInvest[msg.sender][tid][tokens[i].addr].add(amt);

        }

        t.principal = t.principal.add(total);

        uint256 principal = 0;
        for (uint256 i = 0; i < tokenCount; i++) {
            principal = principal.add(userInvest[msg.sender][tid][tokens[i].addr]);
        }
        IMasterWTF(staker).updateStake(tid, msg.sender, principal);

        if (returnLeft) {
            for (uint256 i = 0; i < tokenCount; i++) {
                uint256 b = userBalances[msg.sender][tokens[i].addr];
                if (b > 0) {
                    IERC20(tokens[i].addr).safeTransfer(msg.sender, b);
                    userBalances[msg.sender][tokens[i].addr] = 0;
                    emit Withdraw(msg.sender, tokens[i].addr, b);
                }
            }
        }

        _tryStart();
    }

    function redeem(uint256 tid) public override checkTrancheID(tid) checkNotActive updateInvest nonReentrant {
        _redeem(tid);
    }

    function _redeem(uint256 tid) private returns (uint256[] memory) {
        uint256 total = 0;
        uint256[] memory amountOuts = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            uint256 amt = userInvest[msg.sender][tid][tokens[i].addr];
            if (amt == 0) {
                continue;
            }

            userBalances[msg.sender][tokens[i].addr] = userBalances[msg.sender][tokens[i].addr].add(amt);
            trancheInvest[cycle][tid][tokens[i].addr] = trancheInvest[cycle][tid][tokens[i].addr].sub(amt);
            userInvest[msg.sender][tid][tokens[i].addr] = 0;

            total = total.add(amt);
            amountOuts[i] = amt;
            emit Redeem(msg.sender, tid, cycle, i, amt);
        }

        Tranche storage t = tranches[tid];
        t.principal = t.principal.sub(total);

        IMasterWTF(staker).updateStake(tid, msg.sender, 0);

        return amountOuts;
    }

    function redeemDirect(uint256 tid) external override checkTrancheID(tid) checkNotActive updateInvest nonReentrant {
        uint256[] memory amountOuts = _redeem(tid);
        _withdraw(amountOuts);
    }

    function _withdraw(uint256[] memory amountOuts) internal {
        for (uint256 i = 0; i < tokenCount; i++) {
            uint256 amt = amountOuts[i];
            if (amt > 0) {
                userBalances[msg.sender][tokens[i].addr] = userBalances[msg.sender][tokens[i].addr].sub(amt);
                IERC20(tokens[i].addr).safeTransfer(msg.sender, amt);
                emit Withdraw(msg.sender, tokens[i].addr, amt);
            }
        }
    }

    function withdraw(uint256[] memory amountOuts) public override updateInvest nonReentrant {
        _withdraw(amountOuts);
    }

    function _startCycle() internal checkNotActive {
        uint256 total = 0;
        for (uint256 i = 0; i < tranches.length; i++) {
            Tranche memory t = tranches[i];
            total = total.add(t.principal);
        }

        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 amt = total.mul(tokens[i].percent).div(PercentageParamScale);
            IStrategyToken(tokens[i].strategy).deposit(amt);
        }

        actualStartAt = block.timestamp;
        active = true;
        for (uint256 i = 0; i < tranches.length; i++) {
            emit TrancheStart(i, cycle, tranches[i].principal);
        }
        IMasterWTF(staker).start(block.number.add(duration.div(3)));
    }

    function _stopCycle() internal {
        require(block.timestamp >= actualStartAt + duration, "cycle not expired");
        _processExit();
        active = false;
        cycle++;
        IMasterWTF(staker).next(cycle);
    }

    function _calculateExchangeRate(uint256 current, uint256 base) internal pure returns (uint256) {
        if (current == base) {
            return PercentageScale;
        } else if (current > base) {
            return PercentageScale.add((current - base).mul(PercentageScale).div(base));
        } else {
            return PercentageScale.sub((base - current).mul(PercentageScale).div(base));
        }
    }

    function _getTotalTarget() internal returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < tranches.length; i++) {
            total = total.add(tranches[i].target);
        }
        return total;
    }

    function _redeemAll() internal returns (uint256[] memory, uint256) {
        uint256 total = 0;
        uint256 before;
        uint256[] memory capitals = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            Token memory token = tokens[i];
            before = IERC20(token.addr).balanceOf(address(this));
            IStrategyToken(token.strategy).withdraw();
            capitals[i] = IERC20(token.addr).balanceOf(address(this)).sub(before);
            total = total.add(capitals[i]);
        }
        return (capitals, total);
    }

    struct ExitVals {
        uint256 totalTarget;
        uint256[] capitals;
        uint256 restCapital;
        uint256 interest;
        uint256 rate;
        uint256 capital;
        uint256 principal;
        uint256 now;
        uint256 totalFee;
        uint256 all;
        bool satisfied;
        Token token;
    }

    function _processExit() internal {
        ExitVals memory v;

        v.now = block.timestamp;
        v.totalTarget = _getTotalTarget();
        (v.capitals, v.restCapital) = _redeemAll();

        for (uint256 i = 0; i < tranches.length - 1; i++) {
            Tranche storage senior = tranches[i];
            v.principal = senior.principal;
            v.capital = 0;
            v.interest = senior.principal.mul(senior.apy).mul(v.now - actualStartAt).div(365).div(86400).div(
                PercentageScale
            );

            v.all = v.principal.add(v.interest);
            v.satisfied = v.restCapital >= v.all;
            if (!v.satisfied) {
                v.capital = v.restCapital;
                v.restCapital = 0;
            } else {
                v.capital = v.all;
                v.restCapital = v.restCapital.sub(v.all);
            }

            if (v.satisfied) {
                uint256 fee = v.capital.mul(senior.fee).div(PercentageParamScale);
                v.totalFee = v.totalFee.add(fee);
                v.capital = v.capital.sub(fee);
            }

            v.rate = _calculateExchangeRate(v.capital, v.principal);
            trancheSnapshots[cycle][i] = TrancheSnapshot({
                target: senior.target,
                principal: v.principal,
                rate: v.rate,
                apy: senior.apy,
                fee: senior.fee,
                startAt: actualStartAt,
                stopAt: v.now
            });

            senior.principal = 0;

            emit TrancheSettle(i, cycle, v.principal, v.capital, v.rate);
        }

        {
            uint256 juniorIndex = tranches.length - 1;
            Tranche storage junior = tranches[juniorIndex];
            v.principal = junior.principal;
            v.capital = v.restCapital;
            uint256 fee = v.capital.mul(junior.fee).div(PercentageParamScale);
            v.totalFee = v.totalFee.add(fee);
            v.capital = v.capital.sub(fee);
            v.rate = _calculateExchangeRate(v.capital, v.principal);
            trancheSnapshots[cycle][juniorIndex] = TrancheSnapshot({
                target: junior.target,
                principal: v.principal,
                rate: v.rate,
                apy: junior.apy,
                fee: junior.fee,
                startAt: actualStartAt,
                stopAt: v.now
            });

            junior.principal = 0;

            emit TrancheSettle(juniorIndex, cycle, v.principal, v.capital, v.rate);
        }

        for (uint256 i = 0; i < tokenCount; i++) {
            v.token = tokens[i];
            uint256 target = v.totalTarget.mul(v.token.percent).div(PercentageParamScale);
            uint256 fee = v.totalFee.mul(v.token.percent).div(PercentageParamScale);
            v.capital = v.capitals[i];
            if (v.capital >= fee) {
                v.capital = v.capital.sub(fee);
                producedFee[v.token.addr] = producedFee[v.token.addr].add(fee);
            }

            uint256 reward = v.capital > target ? v.capital.sub(target) : 0;
            uint256 pay = 0;
            v.principal = 0;
            for (uint256 j = 0; j < tranches.length; j++) {
                uint256 p = trancheInvest[cycle][j][v.token.addr];
                pay = pay.add(p.mul(trancheSnapshots[cycle][j].rate).div(PercentageScale));
            }

            tokenSettles[cycle][v.token.addr] = TokenSettle({
                capital: v.capital,
                reward: reward,
                profit: v.capital >= pay ? v.capital.sub(pay) : pay.sub(v.capital),
                left: v.capital,
                gain: v.capital >= pay
            });
        }
    }

    function stop() public override checkActive nonReentrant onlyGovernor {
        _stopCycle();
    }

    function withdrawFee() public override {
        require(devAddress != address(0), "devAddress not set");
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 amount = producedFee[tokens[i].addr];
            IERC20(tokens[i].addr).safeTransfer(devAddress, amount);
            producedFee[tokens[i].addr] = 0;
            emit WithdrawFee(devAddress, tokens[i].addr, amount);
        }
    }
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface ITrancheMasterMultiToken {
    function setDuration(uint256 _duration) external;

    function setDevAddress(address _devAddress) external;

    function add(
        uint256 target,
        uint256 apy,
        uint256 fee
    ) external;

    function set(
        uint256 tid,
        uint256 target,
        uint256 apy,
        uint256 fee
    ) external;

    function balanceOf(address account) external view returns (uint256[] memory, uint256[] memory);

    function investDirect(
        uint256 tid,
        uint256[] calldata amountsIn,
        uint256[] calldata amountsInvest
    ) external;

    function deposit(uint256[] calldata amountsIn) external;

    function invest(
        uint256 tid,
        uint256[] calldata amountsIn,
        bool returnLeft
    ) external;

    function redeem(uint256 tid) external;

    function redeemDirect(uint256 tid) external;

    function withdraw(uint256[] calldata amountOuts) external;

    function stop() external;

    function withdrawFee() external;

    function producedFee(address token) external view returns (uint256);

    function duration() external view returns (uint256);

    function cycle() external view returns (uint256);

    function actualStartAt() external view returns (uint256);

    function active() external view returns (bool);

    function tranches(uint256 id)
        external
        view
        returns (
            uint256 target,
            uint256 principal,
            uint256 apy,
            uint256 fee
        );

    function staker() external view returns (address);

    function devAddress() external view returns (address);

    function userInvest(
        address account,
        uint256 tid,
        address token
    ) external view returns (uint256);

    function trancheInvest(
        uint256 cycle,
        uint256 tid,
        address token
    ) external view returns (uint256);

    function trancheSnapshots(uint256 cycle, uint256 tid)
        external
        view
        returns (
            uint256 target,
            uint256 principal,
            uint256 rate,
            uint256 apy,
            uint256 fee,
            uint256 startAt,
            uint256 stopAt
        );
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../refs/CoreRef.sol";
import "../interfaces/ITrancheMaster.sol";
import "../interfaces/IMasterWTF.sol";
import "../interfaces/IStrategyTokenOld.sol";
import "../interfaces/IFeeRewards.sol";

contract TrancheMaster is ITrancheMaster, CoreRef, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct TrancheParams {
        uint256 apy;
        uint256 fee;
        uint256 target;
    }

    struct Tranche {
        uint256 target;
        uint256 principal;
        uint256 apy;
        uint256 fee;
    }

    struct TrancheSnapshot {
        uint256 target;
        uint256 principal;
        uint256 capital;
        uint256 rate;
        uint256 apy;
        uint256 fee;
        uint256 startAt;
        uint256 stopAt;
    }

    struct Investment {
        uint256 cycle;
        uint256 principal;
    }

    struct UserInfo {
        uint256 balance;
    }

    uint256 public constant PercentageParamScale = 1e5;
    uint256 public constant PercentageScale = 1e18;
    uint256 private constant MaxAPY = 100000;
    uint256 private constant MaxFee = 10000;

    uint256 public override producedFee;
    uint256 public override duration = 7 days;
    uint256 public override cycle;
    uint256 public override actualStartAt;
    bool public override active;
    Tranche[] public override tranches;
    address public override currency;
    address public override staker;
    address public override strategy;

    address public override devAddress;

    mapping(address => UserInfo) public override userInfo;
    mapping(address => mapping(uint256 => Investment)) public override userInvest;

    // cycle => trancheID => snapshot
    mapping(uint256 => mapping(uint256 => TrancheSnapshot)) public override trancheSnapshots;

    event Deposit(address account, uint256 amount);

    event Invest(address account, uint256 tid, uint256 cycle, uint256 amount);

    event Redeem(address account, uint256 tid, uint256 cycle, uint256 amount);

    event Withdraw(address account, uint256 amount);

    event WithdrawFee(address account, uint256 amount);

    event Harvest(address account, uint256 tid, uint256 cycle, uint256 principal, uint256 capital);

    event TrancheAdd(uint256 tid, uint256 target, uint256 apy, uint256 fee);

    event TrancheUpdated(uint256 tid, uint256 target, uint256 apy, uint256 fee);

    event TrancheStart(uint256 tid, uint256 cycle, uint256 principal);

    event TrancheSettle(uint256 tid, uint256 cycle, uint256 principal, uint256 capital, uint256 rate);

    event SetDevAddress(address dev);

    modifier checkTranches() {
        require(tranches.length > 1, "tranches is incomplete");
        require(tranches[tranches.length - 1].apy == 0, "the last tranche must carry zero apy");
        _;
    }

    modifier checkTrancheID(uint256 tid) {
        require(tid < tranches.length, "invalid tranche id");
        _;
    }

    modifier checkActive() {
        require(active, "not active");
        _;
    }

    modifier checkNotActive() {
        require(!active, "already active");
        _;
    }

    modifier updateInvest() {
        _updateInvest(_msgSender());
        _;
    }

    constructor(
        address _core,
        address _currency,
        address _strategy,
        address _staker,
        address _devAddress,
        uint256 _duration,
        TrancheParams[] memory _params
    ) public CoreRef(_core) {
        currency = _currency;
        strategy = _strategy;
        staker = _staker;
        devAddress = _devAddress;
        duration = _duration;

        approveToken();

        for (uint256 i = 0; i < _params.length; i++) {
            _add(_params[i].target, _params[i].apy, _params[i].fee);
        }
    }

    function approveToken() public {
        IERC20(currency).safeApprove(strategy, uint256(-1));
    }

    function setDuration(uint256 _duration) public override onlyGovernor {
        duration = _duration;
    }

    function setDevAddress(address _devAddress) public override onlyGovernor {
        devAddress = _devAddress;
        emit SetDevAddress(_devAddress);
    }

    function _add(
        uint256 target,
        uint256 apy,
        uint256 fee
    ) internal {
        require(target > 0, "invalid target");
        require(apy <= MaxAPY, "invalid APY");
        require(fee <= MaxFee, "invalid fee");
        tranches.push(
            Tranche({target: target, apy: apy.mul(PercentageScale).div(PercentageParamScale), fee: fee, principal: 0})
        );
        emit TrancheAdd(tranches.length - 1, target, apy, fee);
    }

    function add(
        uint256 target,
        uint256 apy,
        uint256 fee
    ) public override onlyGovernor {
        _add(target, apy, fee);
    }

    function set(
        uint256 tid,
        uint256 target,
        uint256 apy,
        uint256 fee
    ) public override onlyTimelock checkTrancheID(tid) {
        require(target >= tranches[tid].principal, "invalid target");
        require(apy <= MaxAPY, "invalid APY");
        require(fee <= MaxFee, "invalid fee");
        tranches[tid].target = target;
        tranches[tid].apy = apy.mul(PercentageScale).div(PercentageParamScale);
        tranches[tid].fee = fee;
        emit TrancheUpdated(tid, target, apy, fee);
    }

    function _updateInvest(address account) internal {
        UserInfo storage u = userInfo[account];
        for (uint256 i = 0; i < tranches.length; i++) {
            Investment storage inv = userInvest[account][i];
            if (inv.cycle < cycle) {
                uint256 principal = inv.principal;
                if (principal > 0) {
                    TrancheSnapshot memory snapshot = trancheSnapshots[inv.cycle][i];
                    uint256 capital = principal.mul(snapshot.rate).div(PercentageScale);
                    u.balance = u.balance.add(capital);
                    inv.principal = 0;
                    IMasterWTF(staker).updateStake(i, account, 0);
                    emit Harvest(account, i, inv.cycle, principal, capital);
                }
                inv.cycle = cycle;
            }
        }
    }

    function balanceOf(address account) public view override returns (uint256 balance, uint256 invested) {
        UserInfo storage u = userInfo[account];
        balance = u.balance;
        for (uint256 i = 0; i < tranches.length; i++) {
            Investment storage inv = userInvest[account][i];
            if (inv.principal > 0) {
                if (inv.cycle < cycle) {
                    TrancheSnapshot memory snapshot = trancheSnapshots[inv.cycle][i];
                    uint256 capital = inv.principal.mul(snapshot.rate).div(PercentageScale);
                    balance = balance.add(capital);
                } else {
                    invested = invested.add(inv.principal);
                }
            }
        }
    }

    function getInvest(uint256 tid) public view override checkTrancheID(tid) returns (uint256) {
        Investment storage inv = userInvest[msg.sender][tid];
        if (inv.cycle < cycle) {
            return 0;
        } else {
            return inv.principal;
        }
    }

    function _tryStart() internal returns (bool) {
        for (uint256 i = 0; i < tranches.length; i++) {
            Tranche memory t = tranches[i];
            if (t.principal < t.target) {
                return false;
            }
        }

        _startCycle();

        return true;
    }

    function investDirect(
        uint256 amountIn,
        uint256 tid,
        uint256 amountInvest
    ) public override checkTrancheID(tid) checkNotActive updateInvest nonReentrant {
        require(amountIn > 0, "invalid amountIn");
        require(amountInvest > 0, "invalid amountInvest");

        UserInfo storage u = userInfo[msg.sender];
        require(u.balance.add(amountIn) >= amountInvest, "balance not enough");

        IERC20(currency).safeTransferFrom(msg.sender, address(this), amountIn);
        u.balance = u.balance.add(amountIn);
        emit Deposit(msg.sender, amountIn);

        _invest(tid, amountInvest, false);
    }

    function deposit(uint256 amount) public override updateInvest nonReentrant {
        require(amount > 0, "invalid amount");
        UserInfo storage u = userInfo[msg.sender];
        IERC20(currency).safeTransferFrom(msg.sender, address(this), amount);
        u.balance = u.balance.add(amount);
        emit Deposit(msg.sender, amount);
    }

    function invest(
        uint256 tid,
        uint256 amount,
        bool returnLeft
    ) public override checkTrancheID(tid) checkNotActive updateInvest nonReentrant {
        require(amount > 0, "invalid amount");
        _invest(tid, amount, returnLeft);
    }

    function _invest(
        uint256 tid,
        uint256 amount,
        bool returnLeft
    ) private {
        UserInfo storage u = userInfo[msg.sender];
        require(amount <= u.balance, "balance not enough");

        Tranche storage t = tranches[tid];
        require(t.target >= t.principal.add(amount), "not enough quota");
        Investment storage inv = userInvest[msg.sender][tid];
        inv.principal = inv.principal.add(amount);
        u.balance = u.balance.sub(amount);
        t.principal = t.principal.add(amount);

        IMasterWTF(staker).updateStake(tid, msg.sender, inv.principal);

        emit Invest(msg.sender, tid, cycle, amount);

        if (returnLeft && u.balance > 0) {
            IERC20(currency).safeTransferFrom(address(this), msg.sender, u.balance);
            emit Withdraw(msg.sender, u.balance);
            u.balance = 0;
        }

        _tryStart();
    }

    function redeem(uint256 tid) public override checkTrancheID(tid) checkNotActive updateInvest nonReentrant {
        _redeem(tid);
    }

    function _redeem(uint256 tid) private returns (uint256) {
        UserInfo storage u = userInfo[msg.sender];
        Investment storage inv = userInvest[msg.sender][tid];
        uint256 principal = inv.principal;
        require(principal > 0, "not enough principal");

        Tranche storage t = tranches[tid];
        u.balance = u.balance.add(principal);
        t.principal = t.principal.sub(principal);
        IMasterWTF(staker).updateStake(tid, msg.sender, 0);
        inv.principal = 0;
        emit Redeem(msg.sender, tid, cycle, principal);
        return principal;
    }

    function redeemDirect(uint256 tid) public override checkTrancheID(tid) checkNotActive updateInvest nonReentrant {
        uint256 amount = _redeem(tid);
        UserInfo storage u = userInfo[msg.sender];
        u.balance = u.balance.sub(amount);
        IERC20(currency).safeTransfer(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }

    function withdraw(uint256 amount) public override updateInvest nonReentrant {
        require(amount > 0, "invalid amount");
        UserInfo storage u = userInfo[msg.sender];
        require(amount <= u.balance, "balance not enough");
        u.balance = u.balance.sub(amount);
        IERC20(currency).safeTransfer(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }

    function _startCycle() internal checkNotActive {
        uint256 total = 0;
        for (uint256 i = 0; i < tranches.length; i++) {
            Tranche memory t = tranches[i];
            total = total.add(t.principal);
        }

        IStrategyToken(strategy).deposit(total);
        actualStartAt = block.timestamp;
        active = true;
        for (uint256 i = 0; i < tranches.length; i++) {
            emit TrancheStart(i, cycle, tranches[i].principal);
        }
        IMasterWTF(staker).start(block.number.add(duration.div(3)));
    }

    function _stopCycle() internal {
        require(block.timestamp >= actualStartAt + duration, "cycle not expired");
        _processExit();
        active = false;
        cycle++;
        IMasterWTF(staker).next(cycle);
    }

    function _calculateExchangeRate(uint256 current, uint256 base) internal pure returns (uint256) {
        if (current == base) {
            return PercentageScale;
        } else if (current > base) {
            return PercentageScale.add((current - base).mul(PercentageScale).div(base));
        } else {
            return PercentageScale.sub((base - current).mul(PercentageScale).div(base));
        }
    }

    function _processExit() internal {
        uint256 before = IERC20(currency).balanceOf(address(this));
        IStrategyToken(strategy).withdraw();

        uint256 total = IERC20(currency).balanceOf(address(this)).sub(before);
        uint256 restCapital = total;
        uint256 interestShouldBe;
        uint256 cycleExchangeRate;
        uint256 capital;
        uint256 principal;
        uint256 _now = block.timestamp;

        for (uint256 i = 0; i < tranches.length - 1; i++) {
            Tranche storage senior = tranches[i];
            principal = senior.principal;
            capital = 0;
            interestShouldBe = senior.principal.mul(senior.apy).mul(_now - actualStartAt).div(365).div(86400).div(
                PercentageScale
            );

            uint256 all = principal.add(interestShouldBe);
            bool satisfied = restCapital >= all;
            if (!satisfied) {
                capital = restCapital;
                restCapital = 0;
            } else {
                capital = all;
                restCapital = restCapital.sub(all);
            }

            if (satisfied) {
                uint256 fee = capital.mul(senior.fee).div(PercentageParamScale);
                producedFee = producedFee.add(fee);
                capital = capital.sub(fee);
            }

            cycleExchangeRate = _calculateExchangeRate(capital, principal);
            trancheSnapshots[cycle][i] = TrancheSnapshot({
                target: senior.target,
                principal: principal,
                capital: capital,
                rate: cycleExchangeRate,
                apy: senior.apy,
                fee: senior.fee,
                startAt: actualStartAt,
                stopAt: _now
            });

            senior.principal = 0;

            emit TrancheSettle(i, cycle, principal, capital, cycleExchangeRate);
        }

        uint256 juniorIndex = tranches.length - 1;
        Tranche storage junior = tranches[juniorIndex];
        principal = junior.principal;
        capital = restCapital;
        uint256 fee = capital.mul(junior.fee).div(PercentageParamScale);
        producedFee = producedFee.add(fee);
        capital = capital.sub(fee);
        cycleExchangeRate = _calculateExchangeRate(capital, principal);
        trancheSnapshots[cycle][juniorIndex] = TrancheSnapshot({
            target: junior.target,
            principal: principal,
            capital: capital,
            rate: cycleExchangeRate,
            apy: junior.apy,
            fee: junior.fee,
            startAt: actualStartAt,
            stopAt: now
        });

        junior.principal = 0;

        emit TrancheSettle(juniorIndex, cycle, principal, capital, cycleExchangeRate);
    }

    function stop() public override checkActive nonReentrant {
        _stopCycle();
    }

    function setStaker(address _staker) public override onlyGovernor {
        staker = _staker;
    }

    function setStrategy(address _strategy) public override onlyGovernor {
        strategy = _strategy;
    }

    function withdrawFee(uint256 amount) public override {
        require(amount <= producedFee, "not enough balance for fee");
        producedFee = producedFee.sub(amount);
        if (devAddress != address(0)) {
            IERC20(currency).safeTransfer(devAddress, amount);
            emit WithdrawFee(devAddress, amount);
        }
    }

    function transferFeeToStaking(uint256 _amount, address _pool) public override onlyGovernor {
        require(_amount > 0, "Zero amount");
        IERC20(currency).safeApprove(_pool, _amount);
        IFeeRewards(_pool).sendRewards(_amount);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../refs/CoreRef.sol";
import "../interfaces/ITrancheMasterManual.sol";
import "../interfaces/IMasterWTF.sol";
import "../interfaces/AlpacaPancakeFarm/IStrategyToken.sol";
import "../interfaces/IFeeRewards.sol";

contract TrancheMasterManual is ITrancheMasterManual, CoreRef, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct TrancheParams {
        uint256 apy;
        uint256 fee;
        uint256 target;
    }

    struct Tranche {
        uint256 target;
        uint256 principal;
        uint256 apy;
        uint256 fee;
    }

    struct TrancheSnapshot {
        uint256 target;
        uint256 principal;
        uint256 capital;
        uint256 rate;
        uint256 apy;
        uint256 fee;
        uint256 startAt;
        uint256 stopAt;
    }

    struct Investment {
        uint256 cycle;
        uint256 principal;
    }

    struct UserInfo {
        uint256 balance;
    }

    uint256 public constant PercentageParamScale = 1e5;
    uint256 public constant PercentageScale = 1e18;
    uint256 private constant MaxAPY = 100000;
    uint256 private constant MaxFee = 10000;

    uint256 public override producedFee;
    uint256 public override duration = 7 days;
    uint256 public override cycle;
    uint256 public override actualStartAt;
    bool public override active;
    Tranche[] public override tranches;
    address public override currency;
    address public override staker;
    address public override strategy;

    address payable public devAddress;

    mapping(address => UserInfo) public override userInfo;
    mapping(address => mapping(uint256 => Investment)) public override userInvest;

    // cycle => trancheID => snapshot
    mapping(uint256 => mapping(uint256 => TrancheSnapshot)) public override trancheSnapshots;

    event Deposit(address account, uint256 amount);

    event Invest(address account, uint256 tid, uint256 cycle, uint256 amount);

    event Redeem(address account, uint256 tid, uint256 cycle, uint256 amount);

    event Withdraw(address account, uint256 amount);

    event WithdrawFee(address account, uint256 amount);

    event Harvest(address account, uint256 tid, uint256 cycle, uint256 principal, uint256 capital);

    event TrancheAdd(uint256 tid, uint256 target, uint256 apy, uint256 fee);

    event TrancheUpdated(uint256 tid, uint256 target, uint256 apy, uint256 fee);

    event TrancheStart(uint256 tid, uint256 cycle, uint256 principal);

    event TrancheSettle(uint256 tid, uint256 cycle, uint256 principal, uint256 capital, uint256 rate);

    event SetDevAddress(address dev);

    modifier checkTranches() {
        require(tranches.length > 1, "tranches is incomplete");
        require(tranches[tranches.length - 1].apy == 0, "the last tranche must carry zero apy");
        _;
    }

    modifier checkTrancheID(uint256 tid) {
        require(tid < tranches.length, "invalid tranche id");
        _;
    }

    modifier checkActive() {
        require(active, "not active");
        _;
    }

    modifier checkNotActive() {
        require(!active, "already active");
        _;
    }

    modifier updateInvest() {
        _updateInvest(_msgSender());
        _;
    }

    constructor(
        address _core,
        address _currency,
        address _strategy,
        address _staker,
        address payable _devAddress,
        uint256 _duration,
        TrancheParams[] memory _params
    ) public CoreRef(_core) {
        currency = _currency;
        strategy = _strategy;
        staker = _staker;
        devAddress = _devAddress;
        duration = _duration;

        approveToken();

        for (uint256 i = 0; i < _params.length; i++) {
            _add(_params[i].target, _params[i].apy, _params[i].fee);
        }
    }

    function approveToken() public {
        IERC20(currency).safeApprove(strategy, uint256(-1));
    }

    function setDuration(uint256 _duration) public override onlyGovernor {
        duration = _duration;
    }

    function setDevAddress(address payable _devAddress) public override onlyGovernor {
        devAddress = _devAddress;
        emit SetDevAddress(_devAddress);
    }

    function _add(
        uint256 target,
        uint256 apy,
        uint256 fee
    ) internal {
        require(target > 0, "invalid target");
        require(apy <= MaxAPY, "invalid APY");
        require(fee <= MaxFee, "invalid fee");
        tranches.push(
            Tranche({target: target, apy: apy.mul(PercentageScale).div(PercentageParamScale), fee: fee, principal: 0})
        );
        emit TrancheAdd(tranches.length - 1, target, apy, fee);
    }

    function add(
        uint256 target,
        uint256 apy,
        uint256 fee
    ) public override onlyGovernor {
        _add(target, apy, fee);
    }

    function set(
        uint256 tid,
        uint256 target,
        uint256 apy,
        uint256 fee
    ) public override onlyTimelock checkTrancheID(tid) {
        require(target >= tranches[tid].principal, "invalid target");
        require(apy <= MaxAPY, "invalid APY");
        require(fee <= MaxFee, "invalid fee");
        tranches[tid].target = target;
        tranches[tid].apy = apy.mul(PercentageScale).div(PercentageParamScale);
        tranches[tid].fee = fee;
        emit TrancheUpdated(tid, target, apy, fee);
    }

    function _updateInvest(address account) internal {
        UserInfo storage u = userInfo[account];
        for (uint256 i = 0; i < tranches.length; i++) {
            Investment storage inv = userInvest[account][i];
            if (inv.cycle < cycle) {
                uint256 principal = inv.principal;
                if (principal > 0) {
                    TrancheSnapshot memory snapshot = trancheSnapshots[inv.cycle][i];
                    uint256 capital = principal.mul(snapshot.rate).div(PercentageScale);
                    u.balance = u.balance.add(capital);
                    inv.principal = 0;
                    IMasterWTF(staker).updateStake(i, account, 0);
                    emit Harvest(account, i, inv.cycle, principal, capital);
                }
                inv.cycle = cycle;
            }
        }
    }

    function balanceOf(address account) public view override returns (uint256 balance, uint256 invested) {
        UserInfo storage u = userInfo[account];
        balance = u.balance;
        for (uint256 i = 0; i < tranches.length; i++) {
            Investment storage inv = userInvest[account][i];
            if (inv.principal > 0) {
                if (inv.cycle < cycle) {
                    TrancheSnapshot memory snapshot = trancheSnapshots[inv.cycle][i];
                    uint256 capital = inv.principal.mul(snapshot.rate).div(PercentageScale);
                    balance = balance.add(capital);
                } else {
                    invested = invested.add(inv.principal);
                }
            }
        }
    }

    function getInvest(uint256 tid) public view override checkTrancheID(tid) returns (uint256) {
        Investment storage inv = userInvest[msg.sender][tid];
        if (inv.cycle < cycle) {
            return 0;
        } else {
            return inv.principal;
        }
    }

    function start(uint256[] memory minLPAmounts) external override onlyGovernor {
        for (uint256 i = 0; i < tranches.length; i++) {
            Tranche memory t = tranches[i];
            require(t.target == t.principal, "TrancheMaster:: TVL not reached");
        }

        _startCycle(minLPAmounts);
    }

    function investDirect(
        uint256 amountIn,
        uint256 tid,
        uint256 amountInvest
    ) public override checkTrancheID(tid) checkNotActive updateInvest nonReentrant {
        require(amountIn > 0, "invalid amountIn");
        require(amountInvest > 0, "invalid amountInvest");

        UserInfo storage u = userInfo[msg.sender];
        require(u.balance.add(amountIn) >= amountInvest, "balance not enough");

        IERC20(currency).safeTransferFrom(msg.sender, address(this), amountIn);
        u.balance = u.balance.add(amountIn);
        emit Deposit(msg.sender, amountIn);

        _invest(tid, amountInvest, false);
    }

    function deposit(uint256 amount) public override updateInvest nonReentrant {
        require(amount > 0, "invalid amount");
        UserInfo storage u = userInfo[msg.sender];
        IERC20(currency).safeTransferFrom(msg.sender, address(this), amount);
        u.balance = u.balance.add(amount);
        emit Deposit(msg.sender, amount);
    }

    function invest(
        uint256 tid,
        uint256 amount,
        bool returnLeft
    ) public override checkTrancheID(tid) checkNotActive updateInvest nonReentrant {
        require(amount > 0, "invalid amount");
        _invest(tid, amount, returnLeft);
    }

    function _invest(
        uint256 tid,
        uint256 amount,
        bool returnLeft
    ) private {
        UserInfo storage u = userInfo[msg.sender];
        require(amount <= u.balance, "balance not enough");
        Tranche storage t = tranches[tid];
        require(t.target >= t.principal.add(amount), "not enough quota");
        Investment storage inv = userInvest[msg.sender][tid];
        inv.principal = inv.principal.add(amount);
        u.balance = u.balance.sub(amount);
        t.principal = t.principal.add(amount);
        IMasterWTF(staker).updateStake(tid, msg.sender, inv.principal);
        emit Invest(msg.sender, tid, cycle, amount);
        if (returnLeft && u.balance > 0) {
            IERC20(currency).safeTransferFrom(address(this), msg.sender, u.balance);
            emit Withdraw(msg.sender, u.balance);
            u.balance = 0;
        }
    }

    function redeem(uint256 tid) public override checkTrancheID(tid) checkNotActive updateInvest nonReentrant {
        _redeem(tid);
    }

    function _redeem(uint256 tid) private returns (uint256) {
        UserInfo storage u = userInfo[msg.sender];
        Investment storage inv = userInvest[msg.sender][tid];
        uint256 principal = inv.principal;
        require(principal > 0, "not enough principal");

        Tranche storage t = tranches[tid];
        u.balance = u.balance.add(principal);
        t.principal = t.principal.sub(principal);
        IMasterWTF(staker).updateStake(tid, msg.sender, 0);
        inv.principal = 0;
        emit Redeem(msg.sender, tid, cycle, principal);
        return principal;
    }

    function redeemDirect(uint256 tid) public override checkTrancheID(tid) checkNotActive updateInvest nonReentrant {
        uint256 amount = _redeem(tid);
        UserInfo storage u = userInfo[msg.sender];
        u.balance = u.balance.sub(amount);
        IERC20(currency).safeTransfer(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }

    function withdraw(uint256 amount) public override updateInvest nonReentrant {
        require(amount > 0, "invalid amount");
        UserInfo storage u = userInfo[msg.sender];
        require(amount <= u.balance, "balance not enough");
        u.balance = u.balance.sub(amount);
        IERC20(currency).safeTransfer(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }

    function _startCycle(uint256[] memory minLPAmounts) internal checkNotActive {
        uint256 total = 0;
        for (uint256 i = 0; i < tranches.length; i++) {
            Tranche memory t = tranches[i];
            total = total.add(t.principal);
        }

        IStrategyToken(strategy).deposit(total, minLPAmounts);
        actualStartAt = block.timestamp;
        active = true;
        for (uint256 i = 0; i < tranches.length; i++) {
            emit TrancheStart(i, cycle, tranches[i].principal);
        }
        IMasterWTF(staker).start(block.number.add(duration.div(3)));
    }

    function _stopCycle(uint256[] memory minBaseAmounts) internal {
        require(block.timestamp >= actualStartAt + duration, "cycle not expired");
        _processExit(minBaseAmounts);
        active = false;
        cycle++;
        IMasterWTF(staker).next(cycle);
    }

    function _calculateExchangeRate(uint256 current, uint256 base) internal pure returns (uint256) {
        if (current == base) {
            return PercentageScale;
        } else if (current > base) {
            return PercentageScale.add((current - base).mul(PercentageScale).div(base));
        } else {
            return PercentageScale.sub((base - current).mul(PercentageScale).div(base));
        }
    }

    function _processExit(uint256[] memory minBaseAmounts) internal {
        uint256 before = IERC20(currency).balanceOf(address(this));
        IStrategyToken(strategy).withdraw(minBaseAmounts);
        uint256 total = IERC20(currency).balanceOf(address(this)).sub(before);
        uint256 restCapital = total;
        uint256 interestShouldBe;
        uint256 cycleExchangeRate;
        uint256 capital;
        uint256 principal;
        uint256 _now = block.timestamp;

        for (uint256 i = 0; i < tranches.length - 1; i++) {
            Tranche storage senior = tranches[i];
            principal = senior.principal;
            capital = 0;
            interestShouldBe = senior.principal.mul(senior.apy).mul(_now - actualStartAt).div(365).div(86400).div(
                PercentageScale
            );

            uint256 all = principal.add(interestShouldBe);
            bool satisfied = restCapital >= all;
            if (!satisfied) {
                capital = restCapital;
                restCapital = 0;
            } else {
                capital = all;
                restCapital = restCapital.sub(all);
            }

            if (satisfied) {
                uint256 fee = capital.mul(senior.fee).div(PercentageParamScale);
                producedFee = producedFee.add(fee);
                capital = capital.sub(fee);
            }

            cycleExchangeRate = _calculateExchangeRate(capital, principal);
            trancheSnapshots[cycle][i] = TrancheSnapshot({
                target: senior.target,
                principal: principal,
                capital: capital,
                rate: cycleExchangeRate,
                apy: senior.apy,
                fee: senior.fee,
                startAt: actualStartAt,
                stopAt: _now
            });

            senior.principal = 0;

            emit TrancheSettle(i, cycle, principal, capital, cycleExchangeRate);
        }

        uint256 juniorIndex = tranches.length - 1;
        Tranche storage junior = tranches[juniorIndex];
        principal = junior.principal;
        capital = restCapital;
        uint256 fee = capital.mul(junior.fee).div(PercentageParamScale);
        producedFee = producedFee.add(fee);
        capital = capital.sub(fee);
        cycleExchangeRate = _calculateExchangeRate(capital, principal);
        trancheSnapshots[cycle][juniorIndex] = TrancheSnapshot({
            target: junior.target,
            principal: principal,
            capital: capital,
            rate: cycleExchangeRate,
            apy: junior.apy,
            fee: junior.fee,
            startAt: actualStartAt,
            stopAt: now
        });

        junior.principal = 0;

        emit TrancheSettle(juniorIndex, cycle, principal, capital, cycleExchangeRate);
    }

    function stop(uint256[] memory minBaseAmounts) public override onlyGovernor checkActive nonReentrant {
        _stopCycle(minBaseAmounts);
    }

    function setStaker(address _staker) public override onlyGovernor {
        staker = _staker;
    }

    function setStrategy(address _strategy) public override onlyGovernor {
        strategy = _strategy;
    }

    function withdrawFee(uint256 amount) public override {
        require(amount <= producedFee, "not enough balance for fee");
        producedFee = producedFee.sub(amount);
        if (devAddress != address(0)) {
            IERC20(currency).safeTransfer(devAddress, amount);
            emit WithdrawFee(devAddress, amount);
        }
    }
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface ITrancheMasterManual {
    function setDuration(uint256 _duration) external;

    function setDevAddress(address payable _devAddress) external;

    function add(
        uint256 target,
        uint256 apy,
        uint256 fee
    ) external;

    function set(
        uint256 tid,
        uint256 target,
        uint256 apy,
        uint256 fee
    ) external;

    function balanceOf(address account) external view returns (uint256 balance, uint256 invested);

    function getInvest(uint256 tid) external view returns (uint256);

    function investDirect(
        uint256 amountIn,
        uint256 tid,
        uint256 amountInvest
    ) external;

    function deposit(uint256 amount) external;

    function invest(
        uint256 tid,
        uint256 amount,
        bool returnLeft
    ) external;

    function redeem(uint256 tid) external;

    function redeemDirect(uint256 tid) external;

    function withdraw(uint256 amount) external;

    function stop(uint256[] memory minBaseAmounts) external;

    function start(uint256[] memory minLPAmounts) external;

    function setStaker(address _staker) external;

    function setStrategy(address _strategy) external;

    function withdrawFee(uint256 amount) external;

    function producedFee() external view returns (uint256);

    function duration() external view returns (uint256);

    function cycle() external view returns (uint256);

    function actualStartAt() external view returns (uint256);

    function active() external view returns (bool);

    function tranches(uint256 id)
        external
        view
        returns (
            uint256 target,
            uint256 principal,
            uint256 apy,
            uint256 fee
        );

    function currency() external view returns (address);

    function staker() external view returns (address);

    function strategy() external view returns (address);

    function userInfo(address account) external view returns (uint256);

    function userInvest(address account, uint256 tid) external view returns (uint256 cycle, uint256 principal);

    function trancheSnapshots(uint256 cycle, uint256 tid)
        external
        view
        returns (
            uint256 target,
            uint256 principal,
            uint256 capital,
            uint256 rate,
            uint256 apy,
            uint256 fee,
            uint256 startAt,
            uint256 stopAt
        );
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface IStrategyToken {
    function deposit(uint256 amt, uint256[] memory minLPAmounts) external;

    function withdraw(uint256[] memory minBaseAmounts) external;
}

interface IMultiStrategyToken is IStrategyToken {
    function approveToken() external;

    function strategies(uint256 idx) external view returns (address);

    function strategyCount() external view returns (uint256);

    function ratios(address _strategy) external view returns (uint256);

    function ratioTotal() external view returns (uint256);

    function changeRatio(uint256 _index, uint256 _value) external;

    function inCaseTokensGetStuck(
        address token,
        uint256 _amount,
        address _to
    ) external;

    function updateAllStrategies() external;
}

//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../interfaces/AlpacaPancakeFarm/IStrategyAlpacaFarm.sol";
import "../interfaces/AlpacaPancakeFarm/IStrategyToken.sol";
import "../refs/CoreRef.sol";

contract MultiStrategyTokenAlpacaFarm is IMultiStrategyToken, ReentrancyGuard, CoreRef {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    bytes32 public constant MASTER_ROLE = keccak256("MASTER_ROLE");

    address public token;
    address[] public override strategies;

    mapping(address => uint256) public override ratios;

    uint256 public override ratioTotal;

    event RatioChanged(address strategyAddress, uint256 ratioBefore, uint256 ratioAfter);

    constructor(
        address _core,
        address _token,
        address[] memory _strategies,
        uint256[] memory _ratios
    ) public CoreRef(_core) {
        require(_strategies.length == _ratios.length, "array not match");
        token = _token;
        strategies = _strategies;
        for (uint256 i = 0; i < strategies.length; i++) {
            ratios[strategies[i]] = _ratios[i];
            ratioTotal = ratioTotal.add(_ratios[i]);
        }
        approveToken();
    }

    function approveToken() public override {
        for (uint256 i = 0; i < strategies.length; i++) {
            IERC20(token).safeApprove(strategies[i], uint256(-1));
        }
    }

    function deposit(uint256 _amount, uint256[] memory minLPAmounts) public override {
        require(_amount != 0, "deposit must be greater than 0");
        IERC20(token).safeTransferFrom(msg.sender, address(this), _amount);
        _deposit(_amount, minLPAmounts);
    }

    function _deposit(uint256 _amount, uint256[] memory minLPAmounts) internal nonReentrant {
        updateAllStrategies();
        for (uint256 i = 0; i < strategies.length; i++) {
            uint256 amt = _amount.mul(ratios[strategies[i]]).div(ratioTotal);
            IStrategyAlpacaFarm(strategies[i]).deposit(amt, minLPAmounts[i]);
        }
    }

    function withdraw(uint256[] memory minBaseAmounts) public override onlyRole(MASTER_ROLE) nonReentrant {
        updateAllStrategies();
        for (uint256 i = 0; i < strategies.length; i++) {
            IStrategyAlpacaFarm(strategies[i]).withdraw(minBaseAmounts[i]);
        }

        uint256 balanceWant = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(msg.sender, balanceWant);
    }

    function changeRatio(uint256 index, uint256 value) public override onlyTimelock {
        require(strategies.length > index, "invalid index");
        uint256 valueBefore = ratios[strategies[index]];
        ratios[strategies[index]] = value;
        ratioTotal = ratioTotal.sub(valueBefore).add(value);

        emit RatioChanged(strategies[index], valueBefore, value);
    }

    function strategyCount() public view override returns (uint256) {
        return strategies.length;
    }

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) public override onlyTimelock {
        IERC20(_token).safeTransfer(_to, _amount);
    }

    function updateAllStrategies() public override {
        for (uint256 i = 0; i < strategies.length; i++) {
            IStrategyAlpacaFarm(strategies[i]).updateStrategy();
        }
    }

    receive() external payable {}
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../refs/CoreRef.sol";
import "../interfaces/ITrancheMasterAuto.sol";
import "../interfaces/IMasterWTF.sol";
import "../interfaces/IStrategyToken.sol";
import "../interfaces/IFeeRewards.sol";
import "../interfaces/IWETH.sol";

contract TrancheMasterAuto is ITrancheMasterAuto, CoreRef, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct TrancheParams {
        uint256 apy;
        uint256 fee;
        uint256 target;
        bool principalFee;
    }

    struct Tranche {
        uint256 target;
        uint256 principal;
        uint256 autoPrincipal;
        uint256 validPercent;
        uint256 apy;
        uint256 fee;
        uint256 autoValid;
        bool principalFee;
    }

    struct TrancheSnapshot {
        uint256 target;
        uint256 principal;
        uint256 capital;
        uint256 validPercent;
        uint256 rate;
        uint256 apy;
        uint256 fee;
        uint256 startAt;
        uint256 stopAt;
    }

    struct Investment {
        uint256 cycle;
        uint256 principal;
        bool rebalanced;
    }

    struct UserInfo {
        uint256 balance;
        bool isAuto;
    }

    uint256 public constant PercentageParamScale = 1e5;
    uint256 public constant PercentageScale = 1e18;
    uint256 private constant MaxAPY = 100000;
    uint256 private constant MaxFee = 50000;
    uint256 public pendingStrategyWithdrawal = 0;

    uint256 public override producedFee;
    uint256 public override duration = 7 days;
    uint256 public override cycle;
    uint256 public override actualStartAt;
    bool public override active;
    Tranche[] public override tranches;
    address public immutable wNative;
    address public override currency;
    address public override staker;
    address public override strategy;

    address public override devAddress;
    address[] public zeroAddressArr;

    mapping(address => UserInfo) public override userInfo;
    mapping(address => mapping(uint256 => Investment)) public override userInvest;

    // cycle => trancheID => snapshot
    mapping(uint256 => mapping(uint256 => TrancheSnapshot)) public override trancheSnapshots;

    event Deposit(address account, uint256 amount);

    event Invest(address account, uint256 tid, uint256 cycle, uint256 amount);

    event Redeem(address account, uint256 tid, uint256 cycle, uint256 amount);

    event Withdraw(address account, uint256 amount);

    event WithdrawFee(address account, uint256 amount);

    event Harvest(address account, uint256 tid, uint256 cycle, uint256 principal, uint256 capital);

    event TrancheAdd(uint256 tid, uint256 target, uint256 apy, uint256 fee, bool principalFee);

    event TrancheUpdated(uint256 tid, uint256 target, uint256 apy, uint256 fee, bool principalFee);

    event TrancheStart(uint256 tid, uint256 cycle, uint256 principal);

    event TrancheSettle(uint256 tid, uint256 cycle, uint256 principal, uint256 capital, uint256 rate);

    event SetDevAddress(address dev);

    modifier checkTranches() {
        require(tranches.length > 1, "tranches is incomplete");
        require(tranches[tranches.length - 1].apy == 0, "the last tranche must carry zero apy");
        _;
    }

    modifier checkTrancheID(uint256 tid) {
        require(tid < tranches.length, "invalid tranche id");
        _;
    }

    modifier checkActive() {
        require(active, "not active");
        _;
    }

    modifier checkNotActive() {
        require(!active, "already active");
        _;
    }

    modifier checkNotAuto() {
        require(!userInfo[msg.sender].isAuto, "user autorolling");
        _;
    }

    modifier checkNoPendingStrategyWithdrawal() {
        require(pendingStrategyWithdrawal == 0, "at least 1 strategy is pending for withdrawal");
        _;
    }

    modifier updateInvest() {
        _updateInvest(_msgSender());
        _;
    }

    modifier transferTokenToVault(uint256 value) {
        if (msg.value != 0) {
            require(currency == wNative, "currency is not wNative");
            require(value == msg.value, "value != msg.value");
            IWETH(currency).deposit{ value: msg.value }();
        } else {
            IERC20(currency).safeTransferFrom(msg.sender, address(this), value);
        }
        _;
    }

    constructor(
        address _core,
        address _wNative,
        address _currency,
        address _strategy,
        address _staker,
        address _devAddress,
        uint256 _duration,
        TrancheParams[] memory _params
    ) public CoreRef(_core) {
        wNative = _wNative;
        currency = _currency;
        strategy = _strategy;
        staker = _staker;
        devAddress = _devAddress;
        duration = _duration;

        approveToken();

        for (uint256 i = 0; i < _params.length; i++) {
            _add(_params[i].target, _params[i].apy, _params[i].fee, _params[i].principalFee);
        }
        zeroAddressArr.push( address(0) );
    }

    function approveToken() public {
        IERC20(currency).safeApprove(strategy, uint256(-1));
    }

    function setDuration(uint256 _duration) public override onlyGovernor {
        duration = _duration;
    }

    function setDevAddress(address _devAddress) public override onlyGovernor {
        devAddress = _devAddress;
        emit SetDevAddress(_devAddress);
    }

    function _add(
        uint256 target,
        uint256 apy,
        uint256 fee,
        bool principalFee
    ) internal {
        require(target > 0, "invalid target");
        require(apy <= MaxAPY, "invalid APY");
        require(fee <= MaxFee, "invalid fee");
        tranches.push(
            Tranche({
                target: target,
                apy: apy.mul(PercentageScale).div(PercentageParamScale),
                fee: fee,
                principal: 0,
                autoPrincipal: 0,
                validPercent: 0,
                autoValid: 0,
                principalFee: principalFee
            })
        );
        emit TrancheAdd(tranches.length - 1, target, apy, fee, principalFee);
    }

    function add(
        uint256 target,
        uint256 apy,
        uint256 fee,
        bool principalFee
    ) public override onlyGovernor {
        _add(target, apy, fee, principalFee);
    }

    function set(
        uint256 tid,
        uint256 target,
        uint256 apy,
        uint256 fee,
        bool principalFee
    ) public override onlyTimelock checkTrancheID(tid) {
        require(target >= tranches[tid].principal, "invalid target");
        require(apy <= MaxAPY, "invalid APY");
        require(fee <= MaxFee, "invalid fee");
        tranches[tid].target = target;
        tranches[tid].apy = apy.mul(PercentageScale).div(PercentageParamScale);
        tranches[tid].fee = fee;
        tranches[tid].principalFee = principalFee;
        emit TrancheUpdated(tid, target, apy, fee, principalFee);
    }

    function _updateInvest(address account) internal {
        UserInfo storage u = userInfo[account];
        uint256 valid;
        uint256 principal;
        uint256 total;
        uint256 capital;
        uint256 left;
        for (uint i = 0; i < tranches.length; i++) {
            Investment storage inv = userInvest[account][i];
            principal = inv.principal;
            if (principal == 0) {
                inv.cycle = cycle;
                continue;
            }
            if (u.isAuto) {
                for (uint j = inv.cycle; j < cycle; j++) {
                    TrancheSnapshot memory snapshot = trancheSnapshots[j][i];
                    if (inv.rebalanced) {
                        valid = principal;
                        inv.rebalanced = false;
                        left = 0;
                    } else {
                        valid = principal.mul(snapshot.validPercent).div(PercentageScale);
                        left = principal
                            .mul(PercentageScale.sub(snapshot.validPercent))
                            .div(PercentageScale);
                        if (left > 0) {
                            left -= 1;
                        }
                    }
                    capital = valid.mul(snapshot.rate).div(PercentageScale);
                    total = left.add(capital);
                    emit Harvest(account, i, j, valid, capital);
                    principal = total;
                }
                if (active && !inv.rebalanced) {
                    valid = principal.mul(tranches[i].validPercent).div(PercentageScale);
                    left = principal
                        .mul(PercentageScale.sub(tranches[i].validPercent))
                        .div(PercentageScale);
                    if (left > 0) {
                        left -= 1;
                    }
                    inv.rebalanced = true;
                    inv.principal = valid;
                    u.balance = u.balance.add(left);
                    tranches[i].autoPrincipal = tranches[i].autoPrincipal.sub(left);
                } else {
                    inv.principal = principal;
                }
                IMasterWTF(staker).updateStake(i, account, inv.principal);
            } else {
                if (inv.cycle < cycle) {
                    TrancheSnapshot memory snapshot = trancheSnapshots[inv.cycle][i];
                    if (inv.rebalanced) {
                        valid = principal;
                        left = 0;
                        inv.rebalanced = false;
                    } else {
                        valid = principal.mul(snapshot.validPercent).div(PercentageScale);
                        left = principal
                            .mul(PercentageScale.sub(snapshot.validPercent))
                            .div(PercentageScale);
                        if (left > 0) {
                            left -= 1;
                        }
                    }
                    capital = valid.mul(snapshot.rate).div(PercentageScale);
                    total = left.add(capital);
                    u.balance = u.balance.add(total);
                    inv.principal = 0;
                    IMasterWTF(staker).updateStake(i, account, 0);
                    emit Harvest(account, i, inv.cycle, valid, capital);
                } else if (active && !inv.rebalanced) {
                    valid = principal.mul(tranches[i].validPercent).div(PercentageScale);
                    left = principal
                        .mul(PercentageScale.sub(tranches[i].validPercent))
                        .div(PercentageScale);
                    if (left > 0) {
                        left -= 1;
                    }
                    inv.rebalanced = true;
                    inv.principal = valid;
                    u.balance = u.balance.add(left);
                    tranches[i].principal = tranches[i].principal.sub(left);
                    IMasterWTF(staker).updateStake(i, account, inv.principal);
                }
            }
            inv.cycle = cycle;
        }
    }

    function balanceOf(address account) public view override returns (uint256 balance, uint256 invested) {
        UserInfo memory u = userInfo[account];
        uint256 principal;
        uint256 valid;
        uint256 total;
        uint256 capital;
        uint256 left;
        bool rebalanced;

        balance = u.balance;
        for (uint i = 0; i < tranches.length; i++) {
            Investment memory inv = userInvest[account][i];
            rebalanced = inv.rebalanced;
            principal = inv.principal;
            if (principal == 0) {
                continue;
            }
            if (u.isAuto) {
                for (uint j = inv.cycle; j < cycle; j++) {
                    TrancheSnapshot memory snapshot = trancheSnapshots[j][i];
                    if (rebalanced) {
                        valid = principal;
                        rebalanced = false;
                        left = 0;
                    } else {
                        valid = principal.mul(snapshot.validPercent).div(PercentageScale);
                        left = principal
                            .mul(PercentageScale.sub(snapshot.validPercent))
                            .div(PercentageScale);
                        if (left > 0) {
                            left -= 1;
                        }
                    }
                    capital = valid.mul(snapshot.rate).div(PercentageScale);
                    principal = left.add(capital);
                }
                if (active && !rebalanced) {
                    valid = principal.mul(tranches[i].validPercent).div(PercentageScale);
                    left = principal
                        .mul(PercentageScale.sub(tranches[i].validPercent))
                        .div(PercentageScale);
                    if (left > 0) {
                        left -= 1;
                    }
                    invested = invested.add(valid);
                    balance = balance.add(left);
                } else {
                    invested = invested.add(principal);
                }
            } else {
                if (inv.cycle < cycle) {
                    TrancheSnapshot memory snapshot = trancheSnapshots[inv.cycle][i];
                    if (inv.rebalanced) {
                        valid = principal;
                        rebalanced = false;
                        left = 0;
                    } else {
                        valid = principal.mul(snapshot.validPercent).div(PercentageScale);
                        left = principal
                            .mul(PercentageScale.sub(snapshot.validPercent))
                            .div(PercentageScale);
                        if (left > 0) {
                            left -= 1;
                        }
                    }
                    capital = valid.mul(snapshot.rate).div(PercentageScale);
                    total = left.add(capital);
                    balance = balance.add(total);
                } else {
                    if (active && !rebalanced) {
                        valid = principal.mul(tranches[i].validPercent).div(PercentageScale);
                        left = principal
                            .mul(PercentageScale.sub(tranches[i].validPercent))
                            .div(PercentageScale);
                        if (left > 0) {
                            left -= 1;
                        }
                        invested = invested.add(valid);
                        balance = balance.add(left);
                    } else {
                        invested = invested.add(principal);
                    }
                }
            }
        }
    }

    function switchAuto(bool _auto) public override updateInvest nonReentrant {
        if (_auto) {
            require(active == false, "cannot switch ON autoroll while the fall is active");
        }
        UserInfo storage u = userInfo[msg.sender];
        if (u.isAuto == _auto) {
            return;
        }

        for (uint i = 0; i < tranches.length; i++) {
            Investment memory inv = userInvest[msg.sender][i];
            if (inv.principal == 0) {
                continue;
            }

            Tranche storage t = tranches[i];
            if (_auto) {
                t.principal = t.principal.sub(inv.principal);
                t.autoPrincipal = t.autoPrincipal.add(inv.principal);
            } else {
                t.principal = t.principal.add(inv.principal);
                t.autoPrincipal = t.autoPrincipal.sub(inv.principal);
                if (active) {
                    t.autoValid = t.autoValid > inv.principal ? t.autoValid.sub(inv.principal) : 0;
                }
            }
        }

        u.isAuto = _auto;
    }

    function _tryStart() internal returns (bool) {
        for (uint256 i = 0; i < tranches.length; i++) {
            Tranche memory t = tranches[i];
            if (t.principal.add(t.autoPrincipal) < t.target) {
                return false;
            }
        }

        _startCycle();

        return true;
    }

    function investDirect(
        uint256 amountIn,
        uint256 tid,
        uint256 amountInvest
    )
        public
        override
        payable
        checkTrancheID(tid)
        checkNotActive
        checkNoPendingStrategyWithdrawal
        updateInvest
        nonReentrant
        transferTokenToVault(amountIn)
    {
        require(amountIn > 0, "invalid amountIn");
        require(amountInvest > 0, "invalid amountInvest");

        UserInfo storage u = userInfo[msg.sender];
        require(u.balance.add(amountIn) >= amountInvest, "balance not enough");

        u.balance = u.balance.add(amountIn);
        emit Deposit(msg.sender, amountIn);

        _invest(tid, amountInvest, false);
    }

    function deposit(uint256 amount)
        public
        override
        payable
        updateInvest
        nonReentrant
        transferTokenToVault(amount)
    {
        require(amount > 0, "invalid amount");
        UserInfo storage u = userInfo[msg.sender];
        u.balance = u.balance.add(amount);
        emit Deposit(msg.sender, amount);
    }

    function invest(
        uint256 tid,
        uint256 amount,
        bool returnLeft
    ) public override checkTrancheID(tid) checkNotActive checkNoPendingStrategyWithdrawal updateInvest nonReentrant {
        require(amount > 0, "invalid amount");
        _invest(tid, amount, returnLeft);
    }

    function _invest(
        uint256 tid,
        uint256 amount,
        bool returnLeft
    ) private {
        UserInfo storage u = userInfo[msg.sender];
        require(amount <= u.balance, "balance not enough");

        Tranche storage t = tranches[tid];
        require(t.target >= t.principal.add(t.autoPrincipal).add(amount), "not enough quota");
        Investment storage inv = userInvest[msg.sender][tid];
        inv.principal = inv.principal.add(amount);
        u.balance = u.balance.sub(amount);
        if (u.isAuto) {
            t.autoPrincipal = t.autoPrincipal.add(amount);
        } else {
            t.principal = t.principal.add(amount);
        }

        IMasterWTF(staker).updateStake(tid, msg.sender, inv.principal);

        emit Invest(msg.sender, tid, cycle, amount);

        if (returnLeft && u.balance > 0) {
            _safeUnwrap(msg.sender, u.balance);
            emit Withdraw(msg.sender, u.balance);
            u.balance = 0;
        }

        _tryStart();
    }

    function redeem(uint256 tid)
        public
        override
        checkTrancheID(tid)
        checkNotActive
        checkNotAuto
        updateInvest
        nonReentrant
    {
        _redeem(tid);
    }

    function _redeem(uint256 tid) private returns (uint256) {
        UserInfo storage u = userInfo[msg.sender];
        Investment storage inv = userInvest[msg.sender][tid];
        uint256 principal = inv.principal;
        require(principal > 0, "not enough principal");

        Tranche storage t = tranches[tid];
        u.balance = u.balance.add(principal);
        t.principal = t.principal.sub(principal);

        IMasterWTF(staker).updateStake(tid, msg.sender, 0);
        inv.principal = 0;
        emit Redeem(msg.sender, tid, cycle, principal);
        return principal;
    }

    function redeemDirect(uint256 tid)
        public
        override
        checkTrancheID(tid)
        checkNotActive
        checkNotAuto
        updateInvest
        nonReentrant
    {
        uint256 amount = _redeem(tid);
        UserInfo storage u = userInfo[msg.sender];
        u.balance = u.balance.sub(amount);
        _safeUnwrap(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }

    function withdraw(uint256 amount) public override updateInvest nonReentrant {
        require(amount > 0, "invalid amount");
        UserInfo storage u = userInfo[msg.sender];
        require(amount <= u.balance, "balance not enough");
        u.balance = u.balance.sub(amount);
        _safeUnwrap(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }

    function _startCycle() internal checkNotActive {
        uint256 total = 0;
        for (uint256 i = 0; i < tranches.length; i++) {
            Tranche memory t = tranches[i];
            total = total.add(t.target);
        }

        IStrategyToken(strategy).deposit(total);
        actualStartAt = block.timestamp;
        active = true;
        for (uint256 i = 0; i < tranches.length; i++) {
            Tranche storage t = tranches[i];
            t.validPercent = t.target.mul(PercentageScale).div(t.principal.add(t.autoPrincipal));
            t.autoValid = t.principal == 0 ? t.target : t.autoPrincipal.mul(t.validPercent).div(PercentageScale);
            emit TrancheStart(i, cycle, t.target);
        }
        IMasterWTF(staker).start(block.number.add(duration.div(3)));
    }

    function _stopCycle(address[] memory _strategyAddresses) internal {
        _processExit(_strategyAddresses);
        active = false;
        cycle++;
        IMasterWTF(staker).next(cycle);
    }

    function _calculateExchangeRate(uint256 current, uint256 base) internal pure returns (uint256) {
        if (current == base) {
            return PercentageScale;
        } else if (current > base) {
            return PercentageScale.add((current - base).mul(PercentageScale).div(base));
        } else {
            return PercentageScale.sub((base - current).mul(PercentageScale).div(base));
        }
    }

    function _processExit(address[] memory _strategyAddresses) internal {
        uint256 before = IERC20(currency).balanceOf(address(this));
        IStrategyToken(strategy).withdraw(_strategyAddresses);

        uint256 total = IERC20(currency).balanceOf(address(this)).sub(before);
        uint256 restCapital = total;
        uint256 interestShouldBe;
        uint256 cycleExchangeRate;
        uint256 capital;
        uint256 principal;
        uint256 _now = block.timestamp;

        for (uint256 i = 0; i < tranches.length - 1; i++) {
            Tranche storage senior = tranches[i];
            principal = senior.target;
            capital = 0;
            interestShouldBe = principal
                .mul(senior.apy)
                .mul(_now - actualStartAt)
                .div(365)
                .div(86400)
                .div(PercentageScale);

            uint256 all = principal.add(interestShouldBe);
            bool satisfied = restCapital >= all;
            if (!satisfied) {
                capital = restCapital;
                restCapital = 0;
            } else {
                capital = all;
                restCapital = restCapital.sub(all);
            }

            uint256 fee;
            if (senior.principalFee) {
                fee = satisfied ? capital.mul(senior.fee).div(PercentageParamScale) : 0;
            } else if (capital > principal) {
                fee = capital.sub(principal).mul(senior.fee).div(PercentageParamScale);
            }
            if (fee > 0) {
                producedFee = producedFee.add(fee);
                capital = capital.sub(fee);
            }

            cycleExchangeRate = _calculateExchangeRate(capital, principal);
            trancheSnapshots[cycle][i] = TrancheSnapshot({
                target: senior.target,
                principal: principal,
                capital: capital,
                validPercent: senior.validPercent,
                rate: cycleExchangeRate,
                apy: senior.apy,
                fee: senior.fee,
                startAt: actualStartAt,
                stopAt: _now
            });

            senior.principal = 0;

            senior.autoPrincipal = senior.autoValid
                .mul(cycleExchangeRate)
                .div(PercentageScale)
                .add(senior.autoPrincipal > senior.autoValid ? senior.autoPrincipal.sub(senior.autoValid) : 0);

            emit TrancheSettle(i, cycle, principal, capital, cycleExchangeRate);
        }

        {
            uint256 juniorIndex = tranches.length - 1;
            Tranche storage junior = tranches[juniorIndex];
            principal = junior.target;
            capital = restCapital;
            uint256 fee;
            if (junior.principalFee) {
                fee = capital.mul(junior.fee).div(PercentageParamScale);
            } else if (capital > principal) {
                fee = capital.sub(principal).mul(junior.fee).div(PercentageParamScale);
            }
            if (fee > 0) {
                producedFee = producedFee.add(fee);
                capital = capital.sub(fee);
            }
            cycleExchangeRate = _calculateExchangeRate(capital, principal);
            trancheSnapshots[cycle][juniorIndex] = TrancheSnapshot({
                target: junior.target,
                principal: principal,
                capital: capital,
                validPercent: junior.validPercent,
                rate: cycleExchangeRate,
                apy: junior.apy,
                fee: junior.fee,
                startAt: actualStartAt,
                stopAt: now
            });

            junior.principal = 0;
            junior.autoPrincipal = junior.autoValid
                .mul(cycleExchangeRate)
                .div(PercentageScale)
                .add(junior.autoPrincipal > junior.autoValid ? junior.autoPrincipal.sub(junior.autoValid) : 0);

            emit TrancheSettle(juniorIndex, cycle, principal, capital, cycleExchangeRate);
        }
    }

    function stop() public override checkActive nonReentrant {        
        require(block.timestamp >= actualStartAt + duration, "cycle not expired");
        _stopCycle(zeroAddressArr);
        _tryStart();
    }

    function emergencyStop(address[] memory _strategyAddresses) public checkActive nonReentrant onlyGovernor {
        pendingStrategyWithdrawal = IMultiStrategyToken(strategy).strategyCount() - _strategyAddresses.length;
        _stopCycle(_strategyAddresses);
    }

    function recoverFund(address[] memory _strategyAddresses) public checkNotActive nonReentrant onlyGovernor {
        require(pendingStrategyWithdrawal > 0, "no strategy is pending for withdrawal");
        pendingStrategyWithdrawal -= _strategyAddresses.length;
        uint256 before = IERC20(currency).balanceOf(address(this));
        IStrategyToken(strategy).withdraw(_strategyAddresses);
        uint256 total = IERC20(currency).balanceOf(address(this)).sub(before);
        _safeUnwrap(devAddress, total);
    }

    function setStaker(address _staker) public override onlyGovernor {
        staker = _staker;
    }

    function setStrategy(address _strategy) public override onlyGovernor {
        strategy = _strategy;
    }

    function withdrawFee(uint256 amount) public override {
        require(amount <= producedFee, "not enough balance for fee");
        producedFee = producedFee.sub(amount);
        if (devAddress != address(0)) {
            _safeUnwrap(devAddress, amount);
            emit WithdrawFee(devAddress, amount);
        }
    }

    function transferFeeToStaking(uint256 _amount, address _pool) public override onlyGovernor {
        require(_amount > 0, "Zero amount");
        IERC20(currency).safeApprove(_pool, _amount);
        IFeeRewards(_pool).sendRewards(_amount);
    }

    function _safeUnwrap(address to, uint256 amount) internal {
        if (currency == wNative) {
            IWETH(currency).withdraw(amount);
            Address.sendValue(payable(to), amount);
        } else {
            IERC20(currency).safeTransfer(to, amount);
        }
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../refs/CoreRef.sol";
import "../interfaces/ITrancheMasterAuto.sol";
import "../interfaces/IMasterWTF.sol";
import "../interfaces/IStrategy.sol";
import "../interfaces/IStrategyToken.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";
// import "@nomiclabs/buidler/console.sol";

contract TimelockController is CoreRef, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 internal constant _DONE_TIMESTAMP = uint256(1);
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    mapping(bytes32 => uint256) private _timestamps;
    uint256 public minDelay;

    event CallScheduled(
        bytes32 indexed id,
        uint256 indexed index,
        address target,
        uint256 value,
        bytes data,
        bytes32 predecessor,
        uint256 delay
    );

    event CallExecuted(bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data);

    event Cancelled(bytes32 indexed id);

    event MinDelayChange(uint256 oldDuration, uint256 newDuration);

    modifier onlySelf() {
        require(msg.sender == address(this), "TimelockController::onlySelf: caller is not itself");
        _;
    }

    constructor(address _core, uint256 _minDelay) public CoreRef(_core) {
        minDelay = _minDelay;
        emit MinDelayChange(0, _minDelay);
    }

    receive() external payable {}

    function isOperation(bytes32 id) public view virtual returns (bool pending) {
        return getTimestamp(id) > 0;
    }

    function isOperationPending(bytes32 id) public view virtual returns (bool pending) {
        return getTimestamp(id) > _DONE_TIMESTAMP;
    }

    function isOperationReady(bytes32 id) public view virtual returns (bool ready) {
        uint256 timestamp = getTimestamp(id);
        return timestamp > _DONE_TIMESTAMP && timestamp <= block.timestamp;
    }

    function isOperationDone(bytes32 id) public view virtual returns (bool done) {
        return getTimestamp(id) == _DONE_TIMESTAMP;
    }

    function getTimestamp(bytes32 id) public view virtual returns (uint256 timestamp) {
        return _timestamps[id];
    }

    function hashOperation(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt
    ) public pure virtual returns (bytes32 hash) {
        return keccak256(abi.encode(target, value, data, predecessor, salt));
    }

    function hashOperationBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas,
        bytes32 predecessor,
        bytes32 salt
    ) public pure virtual returns (bytes32 hash) {
        return keccak256(abi.encode(targets, values, datas, predecessor, salt));
    }

    function schedule(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt,
        uint256 delay
    ) public virtual onlyRole(PROPOSER_ROLE) {
        bytes32 id = hashOperation(target, value, data, predecessor, salt);
        _schedule(id, delay);
        emit CallScheduled(id, 0, target, value, data, predecessor, delay);
    }

    function scheduleBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas,
        bytes32 predecessor,
        bytes32 salt,
        uint256 delay
    ) public virtual onlyRole(PROPOSER_ROLE) {
        require(targets.length == values.length, "TimelockController: length mismatch");
        require(targets.length == datas.length, "TimelockController: length mismatch");

        bytes32 id = hashOperationBatch(targets, values, datas, predecessor, salt);
        _schedule(id, delay);
        for (uint256 i = 0; i < targets.length; ++i) {
            emit CallScheduled(id, i, targets[i], values[i], datas[i], predecessor, delay);
        }
    }

    function _schedule(bytes32 id, uint256 delay) private {
        require(!isOperation(id), "TimelockController: operation already scheduled");
        require(delay >= minDelay, "TimelockController: insufficient delay");
        _timestamps[id] = block.timestamp + delay;
    }

    function cancel(bytes32 id) public virtual onlyRole(PROPOSER_ROLE) {
        require(isOperationPending(id), "TimelockController: operation cannot be cancelled");
        delete _timestamps[id];

        emit Cancelled(id);
    }

    function execute(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt
    ) public payable virtual onlyRoleOrOpenRole(EXECUTOR_ROLE) {
        bytes32 id = hashOperation(target, value, data, predecessor, salt);
        _beforeCall(id, predecessor);
        _call(id, 0, target, value, data);
        _afterCall(id);
    }

    function executeBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas,
        bytes32 predecessor,
        bytes32 salt
    ) public payable virtual onlyRoleOrOpenRole(EXECUTOR_ROLE) {
        require(targets.length == values.length, "TimelockController: length mismatch");
        require(targets.length == datas.length, "TimelockController: length mismatch");

        bytes32 id = hashOperationBatch(targets, values, datas, predecessor, salt);
        _beforeCall(id, predecessor);
        for (uint256 i = 0; i < targets.length; ++i) {
            _call(id, i, targets[i], values[i], datas[i]);
        }
        _afterCall(id);
    }

    function _beforeCall(bytes32 id, bytes32 predecessor) private view {
        require(isOperationReady(id), "TimelockController: operation is not ready");
        require(predecessor == bytes32(0) || isOperationDone(predecessor), "TimelockController: missing dependency");
    }

    function _afterCall(bytes32 id) private {
        require(isOperationReady(id), "TimelockController: operation is not ready");
        _timestamps[id] = _DONE_TIMESTAMP;
    }

    function _call(
        bytes32 id,
        uint256 index,
        address target,
        uint256 value,
        bytes calldata data
    ) private {
        (bool success, ) = target.call{value: value}(data);
        require(success, "TimelockController: underlying transaction reverted");

        emit CallExecuted(id, index, target, value, data);
    }

    function updateDelay(uint256 newDelay) public virtual onlySelf {
        emit MinDelayChange(minDelay, newDelay);
        minDelay = newDelay;
    }

    // IMasterWTF

    function setMasterWTF(
        address _master,
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlySelf {
        IMasterWTF(_master).set(_pid, _allocPoint, _withUpdate);
    }

    function updateRewardPerBlock(address _master, uint256 _rewardPerBlock) public onlySelf {
        IMasterWTF(_master).updateRewardPerBlock(_rewardPerBlock);
    }

    // ITrancheMaster

    function setTrancheMaster(
        address _trancheMaster,
        uint256 _tid,
        uint256 _target,
        uint256 _apy,
        uint256 _fee,
        bool _principalFee
    ) public onlySelf {
        ITrancheMasterAuto(_trancheMaster).set(_tid, _target, _apy, _fee, _principalFee);
    }

    // IStrategyToken

    function updateStrategiesAndRatios(
        address _token,
        address[] calldata _strategies,
        uint256[] calldata _ratios
    ) public onlySelf {
        IMultiStrategyToken(_token).updateStrategiesAndRatios(_strategies, _ratios);
    }

    function changeRatio(
        address _token,
        uint256 _index,
        uint256 _value
    ) public onlySelf {
        IMultiStrategyToken(_token).changeRatio(_index, _value);
    }

    // IStrategy

    function setOracle(address _strategy, address _oracle) public onlySelf {
        IStrategyAvax(_strategy).setOracle(_oracle);
    }

    function setDexRouter(address _strategy, address _dexRouterAddress) public onlySelf {
        IStrategyAvax(_strategy).setDexRouter(_dexRouterAddress);
    }

    function setInputTokenToBaseTokenPath(address _strategy, address[] calldata _inputTokenToBaseTokenPath) public onlySelf {
        IStrategyAvax(_strategy).setInputTokenToBaseTokenPath(_inputTokenToBaseTokenPath);
    }

    function setBaseTokenToInputTokenPath(address _strategy, address[] calldata _baseTokenToInputTokenPath) public onlySelf {
        IStrategyAvax(_strategy).setBaseTokenToInputTokenPath(_baseTokenToInputTokenPath);
    }

    function setAvaxToInputTokenPath(address _strategy, address[] calldata _avaxToInputTokenPath) public onlySelf {
        IStrategyAvax(_strategy).setAvaxToInputTokenPath(_avaxToInputTokenPath);
    }

    function createRole(bytes32 role, bytes32 adminRole) external onlySelf {
        core().createRole(role, adminRole);
    }

    function grantGovernor(address governor) external onlySelf {
        core().grantGovernor(governor);
    }

    function grantGuardian(address guardian) external onlySelf {
        core().grantGuardian(guardian);
    }

    function grantMultistrategy(address multistrategy) external onlySelf {
        core().grantMultistrategy(multistrategy);
    }

    function grantRole(bytes32 role, address account) public onlySelf {
        core().grantRole(role, account);
    }

    function earn(address _strategy) public onlyRole(EXECUTOR_ROLE) {
        IStrategy(_strategy).earn();
    }

    function inCaseTokensGetStuck(
        address _strategy,
        address _token,
        uint256 _amount,
        address _to
    ) public onlySelf {
        IStrategy(_strategy).inCaseTokensGetStuck(_token, _amount, _to);
    }

    function leverage(address _strategy, uint256 _amount) public onlySelf {
        ILeverageStrategy(_strategy).leverage(_amount);
    }

    function deleverage(address _strategy, uint256 _amount) public onlySelf {
        ILeverageStrategy(_strategy).deleverage(_amount);
    }

    function deleverageAll(address _strategy, uint256 _amount) public onlySelf {
        ILeverageStrategy(_strategy).deleverageAll(_amount);
    }

    function setBorrowRate(address _strategy, uint256 _borrowRate) public onlySelf {
        ILeverageStrategy(_strategy).setBorrowRate(_borrowRate);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../refs/CoreRef.sol";
import "../interfaces/IMasterWTF.sol";
import "../interfaces/IVotingEscrow.sol";

contract MasterWTF is IMasterWTF, CoreRef, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 cid;
        uint256 earned;
    }

    struct PoolInfo {
        uint256 allocPoint;
    }

    struct PoolStatus {
        uint256 totalSupply;
        uint256 lastRewardBlock;
        uint256 accRewardPerShare;
    }

    bytes32 public constant MASTER_ROLE = keccak256("MASTER_ROLE");
    address public override votingEscrow;
    address public override rewardToken;
    uint256 public override rewardPerBlock;
    uint256 public override totalAllocPoint = 0;
    uint256 public override startBlock;
    uint256 public override endBlock;
    uint256 public override cycleId = 0;
    bool public override rewarding = false;

    PoolInfo[] public override poolInfo;
    // pid => address => UserInfo
    mapping(uint256 => mapping(address => UserInfo)) public override userInfo;
    // cid => pid => PoolStatus
    mapping(uint256 => mapping(uint256 => PoolStatus)) public override poolSnapshot;

    modifier validatePid(uint256 _pid) {
        require(_pid < poolInfo.length, "validatePid: Not exist");
        _;
    }

    event UpdateEmissionRate(uint256 rewardPerBlock);
    event Claim(address indexed user, uint256 pid, uint256 amount);
    event ClaimAll(address indexed user, uint256 amount);

    constructor(
        address _core,
        address _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _endBlock,
        uint256[] memory _pools,
        address _votingEscrow
    ) public CoreRef(_core) {
        rewardToken = _rewardToken;
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
        endBlock = _endBlock;
        votingEscrow = _votingEscrow;
        IERC20(_rewardToken).safeApprove(votingEscrow, uint256(-1));
        uint256 total = 0;
        for (uint256 i = 0; i < _pools.length; i++) {
            total = total.add(_pools[i]);
            poolInfo.push(PoolInfo({allocPoint: _pools[i]}));
        }
        totalAllocPoint = total;
    }

    function poolLength() public view override returns (uint256) {
        return poolInfo.length;
    }

    function add(uint256 _allocPoint) public override onlyGovernor {
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({allocPoint: _allocPoint}));
    }

    function setVotingEscrow(address _votingEscrow) public override onlyTimelock {
        require(_votingEscrow != address(0), "Zero address");
        IERC20(rewardToken).safeApprove(votingEscrow, 0);
        votingEscrow = _votingEscrow;
        IERC20(rewardToken).safeApprove(votingEscrow, uint256(-1));
    }

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public override onlyTimelock validatePid(_pid) {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = totalAllocPoint.sub(prevAllocPoint).add(_allocPoint);
        }
    }

    function getMultiplier(uint256 _from, uint256 _to) public view override returns (uint256) {
        return _to.sub(_from);
    }

    function pendingReward(address _user, uint256 _pid) public view override validatePid(_pid) returns (uint256) {
        PoolInfo storage info = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        PoolStatus storage pool = poolSnapshot[user.cid][_pid];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        if (cycleId == user.cid && rewarding && block.number > pool.lastRewardBlock && pool.totalSupply != 0) {
            uint256 multiplier = getMultiplier(
                pool.lastRewardBlock,
                block.number >= endBlock ? endBlock : block.number
            );
            uint256 reward = multiplier.mul(rewardPerBlock).mul(info.allocPoint).div(totalAllocPoint);
            accRewardPerShare = accRewardPerShare.add(reward.mul(1e12).div(pool.totalSupply));
        }
        return user.amount.mul(accRewardPerShare).div(1e12).sub(user.rewardDebt).add(user.earned);
    }

    function massUpdatePools() public override {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public override validatePid(_pid) {
        if (!rewarding) {
            return;
        }
        PoolInfo storage info = poolInfo[_pid];
        PoolStatus storage pool = poolSnapshot[cycleId][_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        if (pool.lastRewardBlock >= endBlock) {
            return;
        }
        uint256 lastRewardBlock = block.number >= endBlock ? endBlock : block.number;
        if (pool.totalSupply == 0 || info.allocPoint == 0) {
            pool.lastRewardBlock = lastRewardBlock;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, lastRewardBlock);
        uint256 reward = multiplier.mul(rewardPerBlock).mul(info.allocPoint).div(totalAllocPoint);
        pool.accRewardPerShare = pool.accRewardPerShare.add(reward.mul(1e12).div(pool.totalSupply));
        pool.lastRewardBlock = lastRewardBlock;
    }

    function updateStake(
        uint256 _pid,
        address _account,
        uint256 _amount
    ) public override onlyRole(MASTER_ROLE) validatePid(_pid) nonReentrant {
        UserInfo storage user = userInfo[_pid][_account];
        PoolStatus storage pool = poolSnapshot[user.cid][_pid];

        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accRewardPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            user.earned = user.earned.add(pending);
        }

        if (cycleId == user.cid) {
            pool.totalSupply = pool.totalSupply.sub(user.amount).add(_amount);
            user.amount = _amount;
            user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        } else {
            pool = poolSnapshot[cycleId][_pid];
            pool.totalSupply = pool.totalSupply.add(_amount);
            user.amount = _amount;
            user.cid = cycleId;
            user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        }
    }

    function start(uint256 _endBlock) public override onlyRole(MASTER_ROLE) nonReentrant {
        require(!rewarding, "cycle already active");
        require(_endBlock > block.number, "endBlock less");
        rewarding = true;
        endBlock = _endBlock;
        for (uint256 i = 0; i < poolInfo.length; i++) {
            PoolStatus storage pool = poolSnapshot[cycleId][i];
            pool.lastRewardBlock = block.number;
            pool.accRewardPerShare = 0;
        }
    }

    function next(uint256 _cid) public override onlyRole(MASTER_ROLE) nonReentrant {
        require(rewarding, "cycle not active");
        massUpdatePools();
        endBlock = block.number + 1;
        rewarding = false;
        cycleId = _cid;
        for (uint256 i = 0; i < poolInfo.length; i++) {
            poolSnapshot[cycleId][i] = PoolStatus({totalSupply: 0, lastRewardBlock: 0, accRewardPerShare: 0});
        }
    }

    function _lockRewards(
        address _rewardBeneficiary,
        uint256 _rewardAmount,
        uint256 _lockDurationIfLockNotExists,
        uint256 _lockDurationIfLockExists
    ) internal {
        require(_rewardAmount > 0, "WTF Reward is zero");
        uint256 lockedAmountWTF = IVotingEscrow(votingEscrow).getLockedAmount(_rewardBeneficiary);

        // if no lock exists
        if (lockedAmountWTF == 0) {
            require(_lockDurationIfLockNotExists > 0, "Lock duration can't be zero");
            IVotingEscrow(votingEscrow).createLockFor(_rewardBeneficiary, _rewardAmount, _lockDurationIfLockNotExists);
        } else {
            // check if expired
            bool lockExpired = IVotingEscrow(votingEscrow).isLockExpired(_rewardBeneficiary);
            if (lockExpired) {
                require(_lockDurationIfLockExists > 0, "New lock expiry timestamp can't be zero");
            }
            IVotingEscrow(votingEscrow).increaseTimeAndAmountFor(
                _rewardBeneficiary,
                _rewardAmount,
                _lockDurationIfLockExists
            );
        }
    }

    function claim(
        uint256 _pid,
        uint256 _lockDurationIfLockNotExists,
        uint256 _lockDurationIfLockExists
    ) public override nonReentrant {
        uint256 pending;
        UserInfo storage user = userInfo[_pid][msg.sender];
        PoolStatus storage pool = poolSnapshot[user.cid][_pid];

        if (cycleId == user.cid) {
            updatePool(_pid);
        }

        pending = user.amount.mul(pool.accRewardPerShare).div(1e12).sub(user.rewardDebt);
        if (user.earned > 0) {
            pending = pending.add(user.earned);
            user.earned = 0;
        }
        if (pending > 0) {
            _lockRewards(msg.sender, pending, _lockDurationIfLockNotExists, _lockDurationIfLockExists);
            emit Claim(msg.sender, _pid, pending);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
    }

    function claimAll(uint256 _lockDurationIfLockNotExists, uint256 _lockDurationIfLockExists)
        public
        override
        nonReentrant
    {
        uint256 pending = 0;
        for (uint256 i = 0; i < poolInfo.length; i++) {
            UserInfo storage user = userInfo[i][msg.sender];
            PoolStatus storage pool = poolSnapshot[user.cid][i];
            if (cycleId == user.cid) {
                updatePool(i);
            }
            if (user.earned > 0) {
                pending = pending.add(user.earned);
                user.earned = 0;
            }
            pending = user.amount.mul(pool.accRewardPerShare).div(1e12).sub(user.rewardDebt).add(pending);
            user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        }

        if (pending > 0) {
            _lockRewards(msg.sender, pending, _lockDurationIfLockNotExists, _lockDurationIfLockExists);
            emit ClaimAll(msg.sender, pending);
        }
    }

    function safeRewardTransfer(address _to, uint256 _amount) internal returns (uint256) {
        uint256 balance = IERC20(rewardToken).balanceOf(address(this));
        uint256 amount;
        if (_amount > balance) {
            amount = balance;
        } else {
            amount = _amount;
        }

        require(IERC20(rewardToken).transfer(_to, amount), "safeRewardTransfer: Transfer failed");
        return amount;
    }

    function updateRewardPerBlock(uint256 _rewardPerBlock) public override onlyTimelock {
        massUpdatePools();
        rewardPerBlock = _rewardPerBlock;
        emit UpdateEmissionRate(_rewardPerBlock);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

interface IVotingEscrow {
    function createLock(uint256 _amount, uint256 duration) external;

    function createLockFor(
        address _account,
        uint256 _amount,
        uint256 _duration
    ) external;

    function getLockedAmount(address account) external view returns (uint256);

    function increaseLockDuration(uint256 _newExpiryTimestamp) external;

    function increaseLockDurationFor(address account, uint256 _newExpiryTimestamp) external;

    function increaseTimeAndAmount(uint256 _amount, uint256 _newExpiryTimestamp) external;

    function increaseTimeAndAmountFor(
        address _account,
        uint256 _amount,
        uint256 _newExpiryTimestamp
    ) external;

    function increaseAmount(uint256 _amount) external;

    function increaseAmountFor(address _account, uint256 _amount) external;

    function isLockExpired(address account) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

contract Token is ERC20, Ownable {
    using SafeERC20 for ERC20;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) public ERC20(_name, _symbol) {
        _setupDecimals(_decimals);
    }

}

//SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "../refs/CoreRef.sol";
import "@openzeppelin/contracts/math/SignedSafeMath.sol";

contract Oracle is CoreRef {
    using SignedSafeMath for int256;

    struct Feed {
        address aggregator;
        uint8 baseDecimals;
    }
    // token address => Feed
    mapping(address => Feed) public feeds;

    constructor(
        address _core,
        address[] memory _tokens,
        uint8[] memory _baseDecimals,
        address[] memory _aggregators
    ) public CoreRef(_core) {
        _setFeeds(_tokens, _baseDecimals, _aggregators);
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice(address token) public view returns (int256 price) {
        Feed storage feed = feeds[token];
        require(feed.aggregator != address(0), "Oracle:: price feed does not exist");
        (, int256 price, , , ) = AggregatorV3Interface(feed.aggregator).latestRoundData();
        uint8 quoteDecimals = AggregatorV3Interface(feed.aggregator).decimals();
        uint8 baseDecimals = feed.baseDecimals;
        price = scalePrice(price, quoteDecimals, baseDecimals);
        return price;
    }

    function scalePrice(
        int256 _price,
        uint8 _quoteDecimals,
        uint8 _baseDecimals
    ) internal pure returns (int256) {
        if (_quoteDecimals < _baseDecimals) {
            return _price.mul(int256(10**uint256(_baseDecimals - _quoteDecimals)));
        } else if (_quoteDecimals > _baseDecimals) {
            return _price.div(int256(10**uint256(_quoteDecimals - _baseDecimals)));
        }
        return _price;
    }

    function setFeeds(
        address[] memory _tokens,
        uint8[] memory _baseDecimals,
        address[] memory _aggregators
    ) public onlyGovernor {
        _setFeeds(_tokens, _baseDecimals, _aggregators);
    }

    function _setFeeds(
        address[] memory _tokens,
        uint8[] memory _baseDecimals,
        address[] memory _aggregators
    ) internal {
        for (uint256 i = 0; i < _tokens.length; i++) {
            feeds[_tokens[i]] = Feed(_aggregators[i], _baseDecimals[i]);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @title SignedSafeMath
 * @dev Signed math operations with safety checks that revert on error.
 */
library SignedSafeMath {
    int256 constant private _INT256_MIN = -2**255;

    /**
     * @dev Returns the multiplication of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two signed integers. Reverts on
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
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    /**
     * @dev Returns the subtraction of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    /**
     * @dev Returns the addition of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}