/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

// Sources flattened with hardhat v2.7.0 https://hardhat.org

// File @openzeppelin/contracts-upgradeable/utils/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
    assembly {
      size := extcodesize(account)
    }
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
  function functionStaticCall(address target, bytes memory data)
    internal
    view
    returns (bytes memory)
  {
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

// File @openzeppelin/contracts-upgradeable/proxy/utils/[email protected]

// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
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
    // If the contract is initializing we ignore whether _initialized is set in order to support multiple
    // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
    // contract may have been reentered.
    require(
      _initializing ? _isConstructor() : !_initialized,
      "Initializable: contract is already initialized"
    );

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

  /**
   * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
   * {initializer} modifier, directly or indirectly.
   */
  modifier onlyInitializing() {
    require(_initializing, "Initializable: contract is not initializing");
    _;
  }

  function _isConstructor() private view returns (bool) {
    return !AddressUpgradeable.isContract(address(this));
  }
}

// File @openzeppelin/contracts-upgradeable/utils/[email protected]

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
abstract contract ContextUpgradeable is Initializable {
  function __Context_init() internal onlyInitializing {
    __Context_init_unchained();
  }

  function __Context_init_unchained() internal onlyInitializing {}

  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }

  uint256[50] private __gap;
}

// File @openzeppelin/contracts-upgradeable/security/[email protected]

// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

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
  function __Pausable_init() internal onlyInitializing {
    __Context_init_unchained();
    __Pausable_init_unchained();
  }

  function __Pausable_init_unchained() internal onlyInitializing {
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

// File @openzeppelin/contracts-upgradeable/access/[email protected]

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
  event RoleAdminChanged(
    bytes32 indexed role,
    bytes32 indexed previousAdminRole,
    bytes32 indexed newAdminRole
  );

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

// File @openzeppelin/contracts-upgradeable/utils/[email protected]

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

// File @openzeppelin/contracts-upgradeable/utils/introspection/[email protected]

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

// File @openzeppelin/contracts-upgradeable/utils/introspection/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
  function __ERC165_init() internal onlyInitializing {
    __ERC165_init_unchained();
  }

  function __ERC165_init_unchained() internal onlyInitializing {}

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IERC165Upgradeable).interfaceId;
  }

  uint256[50] private __gap;
}

// File @openzeppelin/contracts-upgradeable/access/[email protected]

// OpenZeppelin Contracts v4.4.1 (access/AccessControl.sol)

pragma solidity ^0.8.0;

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
abstract contract AccessControlUpgradeable is
  Initializable,
  ContextUpgradeable,
  IAccessControlUpgradeable,
  ERC165Upgradeable
{
  function __AccessControl_init() internal onlyInitializing {
    __Context_init_unchained();
    __ERC165_init_unchained();
    __AccessControl_init_unchained();
  }

  function __AccessControl_init_unchained() internal onlyInitializing {}

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
    _checkRole(role, _msgSender());
    _;
  }

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return
      interfaceId == type(IAccessControlUpgradeable).interfaceId ||
      super.supportsInterface(interfaceId);
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
   *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
   */
  function _checkRole(bytes32 role, address account) internal view {
    if (!hasRole(role, account)) {
      revert(
        string(
          abi.encodePacked(
            "AccessControl: account ",
            StringsUpgradeable.toHexString(uint160(account), 20),
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
  function grantRole(bytes32 role, address account)
    public
    virtual
    override
    onlyRole(getRoleAdmin(role))
  {
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
  function revokeRole(bytes32 role, address account)
    public
    virtual
    override
    onlyRole(getRoleAdmin(role))
  {
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
   */
  function _revokeRole(bytes32 role, address account) internal virtual {
    if (hasRole(role, account)) {
      _roles[role].members[account] = false;
      emit RoleRevoked(role, account, _msgSender());
    }
  }

  uint256[49] private __gap;
}

// File @openzeppelin/contracts/utils/[email protected]

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
  struct Counter {
    // This variable should never be directly accessed by users of the library: interactions must be restricted to
    // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
    // this feature: see https://github.com/ethereum/solidity/issues/4637
    uint256 _value; // default: 0
  }

  function current(Counter storage counter) internal view returns (uint256) {
    return counter._value;
  }

  function increment(Counter storage counter) internal {
    unchecked {
      counter._value += 1;
    }
  }

  function decrement(Counter storage counter) internal {
    uint256 value = counter._value;
    require(value > 0, "Counter: decrement overflow");
    unchecked {
      counter._value = value - 1;
    }
  }

  function reset(Counter storage counter) internal {
    counter._value = 0;
  }
}

// File contracts/game/stasher/interfaces/IERC20Dec.sol

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
   * @dev Returns the amount of decimals
   */
  function decimals() external view returns (uint8);

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

  function burnFrom(address sender, uint256 amount) external;

  function burn(uint256 amount) external;

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

// File contracts/game/stasher/Stasher.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/**
 *@title Mouse Haunt Stashing Contract
 *@notice This contract is used to stash Mouse Haunt Token.
 */
contract MouseHauntStashing is Initializable, PausableUpgradeable, AccessControlUpgradeable {
  using Counters for Counters.Counter;
  Counters.Counter internal _stashIdCounter;

  bytes32 internal constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
  uint32 internal constant SECONDS_IN_DAY = 86400; //1 day

  //Governance
  IERC20 public paymentToken;
  address public vault;

  //Individual stashes
  mapping(address => uint256) public playerBalance;
  mapping(address => StashInfo) internal playerStashes;
  mapping(address => mapping(uint256 => uint256)) public playerToPeriodToBalance;

  //Global stashes
  Stash[] public stashes;
  mapping(uint256 => uint256) public stashIdToStashIndex;
  uint256 public totalStashed;

  //Tiers vars
  mapping(uint256 => bool) public allowedPeriods;
  uint256[] public periods;

  mapping(uint256 => bool) public allowedRanges;
  uint256[] public ranges;

  mapping(uint256 => mapping(uint256 => Tier)) public periodToRangeToTier;

  //ENUM
  enum Tier {
    NIL,
    F,
    E,
    D,
    C,
    B,
    A,
    S,
    SS
  }

  //Structs
  struct Stash {
    uint256 id;
    address ownerAddress;
    uint256 amount;
    uint256 timestamp;
    uint256 period;
  }
  struct StashInfo {
    uint256[] ids;
    mapping(uint256 => uint256) idToIndex;
  }
  struct TierSet {
    uint256 period;
    uint256 range;
    Tier tier;
  }
  struct PeriodSet {
    uint256 period;
    bool isActive;
  }
  struct RangeSet {
    uint256 range;
    bool isActive;
  }

  // EVENTS
  event Stashed(
    uint256 indexed stashId,
    address indexed playerAddress,
    uint256 amount,
    uint256 indexed period
  );
  event Unstashed(
    uint256 indexed stashId,
    address indexed playerAddress,
    uint256 amount,
    uint256 cycles
  );
  event FeeBurned(uint256 indexed stashId, address indexed playerAddress, uint256 amount);

  /**
   @dev initialize the Mouse Haunt Stashing
   @param _operator for Access Control and Pausable functions
   @param _paymentToken for the token used to pay for the stashes
   */
  function initialize(address _operator, address _paymentToken) public initializer {
    require(_operator != address(0), "INV_ADDRESS");
    require(_paymentToken != address(0), "INV_ADDRESS");

    __AccessControl_init();
    __Pausable_init();

    paymentToken = IERC20(_paymentToken);

    Stash memory dummyStash = Stash(0, address(0), 0, 0, 0);
    _addStash(dummyStash);
    _stashIdCounter.increment();

    _setupRole(DEFAULT_ADMIN_ROLE, _operator);
    _setupRole(OPERATOR_ROLE, _operator);
  }

  /**
   * @dev stash token in the Mouse Haunt Stashing
   * @param _amount of tokens to deposit.
   * @param _period of the stash.
   */
  function stash(uint256 _amount, uint256 _period) external whenNotPaused {
    require(_amount > 0, "INV_AMOUNT");
    require(_period > 0, "INV_DURATION");
    require(allowedPeriods[_period], "INV_DURATION");

    uint256 balance = paymentToken.balanceOf(msg.sender);
    require(balance >= _amount, "NO_BALANCE");

    require(paymentToken.allowance(msg.sender, address(this)) >= _amount, "NOT_ENOUGH_ALLOWANCE");

    uint256 stashId = _stashIdCounter.current();

    Stash memory _stash = Stash(stashId, msg.sender, _amount, block.timestamp, _period);

    _addStash(_stash);

    uint256 playerBalanceBefore = playerBalance[msg.sender];
    playerBalance[msg.sender] = playerBalanceBefore + _amount;
    totalStashed = totalStashed + _amount;

    require(playerBalance[msg.sender] - playerBalanceBefore == _amount, "INV_BALANCE");

    playerToPeriodToBalance[msg.sender][_period] =
      playerToPeriodToBalance[msg.sender][_period] +
      _amount;

    _stashIdCounter.increment();

    emit Stashed(stashId, msg.sender, _amount, _period);

    paymentToken.transferFrom(msg.sender, address(this), _amount);
  }

  /**
   * @dev Unstash tokens from the Mouse Haunt Stashing.
   * @param _stashId of the stash to withdraw.
   */

  function unstash(uint256 _stashId) external whenNotPaused {
    uint256 stashIndex = stashIdToStashIndex[_stashId];
    require(stashIndex < stashes.length && stashIndex != 0, "INV_ID");

    Stash memory _stash = stashes[stashIndex];

    uint256 cycles = cyclesOfStash(_stash.id);

    require(isUnstashable(_stash.id), "STASHED");

    require(msg.sender == _stash.ownerAddress, "INV_OWNER");
    uint256 amount = _stash.amount;

    require(playerBalance[msg.sender] >= amount, "NO_BALANCE");
    playerBalance[msg.sender] = playerBalance[msg.sender] - amount;

    require(playerToPeriodToBalance[msg.sender][_stash.period] >= amount, "NO_BALANCE");
    playerToPeriodToBalance[msg.sender][_stash.period] =
      playerToPeriodToBalance[msg.sender][_stash.period] -
      amount;

    require(totalStashed >= amount, "INV_BALANCE");
    totalStashed = totalStashed - amount;

    _deleteStash(_stashId);

    emit Unstashed(_stashId, msg.sender, amount, cycles);

    uint256 totalStashedBefore = paymentToken.balanceOf(address(this));
    paymentToken.transfer(msg.sender, amount);
    uint256 totalStashedAfter = paymentToken.balanceOf(address(this));
    require(totalStashedBefore - totalStashedAfter == amount, "INV_BALANCE");
  }

  /**
   * @dev Getters
   */

  function isUnstashable(uint256 _stashId) public view returns (bool) {
    uint256 stashIndex = stashIdToStashIndex[_stashId];
    require(stashIndex < stashes.length && stashIndex != 0, "INV_ID");

    Stash memory _stash = stashes[stashIndex];

    uint256 timeDifferenceInSeconds = block.timestamp - _stash.timestamp;
    uint256 timeDifferenceInDays = timeDifferenceInSeconds / SECONDS_IN_DAY;
    uint256 cycles = timeDifferenceInDays / _stash.period;
    uint256 cycleDaysInSeconds = (_stash.period * cycles * SECONDS_IN_DAY);
    uint256 daysPassedInSeconds = timeDifferenceInSeconds - cycleDaysInSeconds;

    uint256 minimumDaysToUnstash = _stash.timestamp + (_stash.period * SECONDS_IN_DAY);

    return daysPassedInSeconds <= SECONDS_IN_DAY && block.timestamp >= minimumDaysToUnstash;
  }

  function cyclesOfStash(uint256 _stashId) public view returns (uint256) {
    uint256 stashIndex = stashIdToStashIndex[_stashId];
    require(stashIndex < stashes.length && stashIndex != 0, "INV_ID");

    Stash memory _stash = stashes[stashIndex];

    uint256 timeDifferenceInSeconds = block.timestamp - _stash.timestamp;
    uint256 timeDifferenceInDays = timeDifferenceInSeconds / SECONDS_IN_DAY;
    uint256 cycles = timeDifferenceInDays / _stash.period;

    return cycles;
  }

  function tierOf(address _playerAddress) public view returns (Tier) {
    uint256 balanceStashedAtPeriod = playerBalance[_playerAddress];

    Tier highestTier = Tier.NIL;
    uint256 previousBalance = 0;

    for (uint256 i = 0; i < periods.length; i++) {
      uint256 period = periods[i];

      balanceStashedAtPeriod = balanceStashedAtPeriod - previousBalance;
      Tier actualTier = getTier(balanceStashedAtPeriod, period);

      if (actualTier > highestTier) {
        highestTier = actualTier;
      }
      previousBalance = playerToPeriodToBalance[_playerAddress][period];
    }

    return highestTier;
  }

  function previewTierOf(
    address _playerAddress,
    uint256 _amount,
    uint256 _period
  ) public view returns (Tier) {
    uint256 balanceStashedAtPeriod = playerBalance[_playerAddress];

    Tier highestTier = Tier.NIL;
    uint256 previousBalance = 0;

    for (uint256 i = 0; i < periods.length; i++) {
      uint256 periodStashed = periods[i];

      if (periodStashed == _period) {
        balanceStashedAtPeriod = balanceStashedAtPeriod + _amount;
      }

      balanceStashedAtPeriod = balanceStashedAtPeriod - previousBalance;
      Tier actualTier = getTier(balanceStashedAtPeriod, periodStashed);

      if (actualTier > highestTier) {
        highestTier = actualTier;
      }

      previousBalance = playerToPeriodToBalance[_playerAddress][periodStashed];

      if (periodStashed == _period) {
        previousBalance = previousBalance + _amount;
      }
    }

    return highestTier;
  }

  function getPeriods() external view returns (uint256[] memory) {
    return periods;
  }

  function getRanges() external view returns (uint256[] memory) {
    return ranges;
  }

  function getTier(uint256 _amount, uint256 _period) public view returns (Tier) {
    Tier tier = Tier.NIL;

    for (uint256 i = ranges.length - 1; i >= 0; i--) {
      if (_amount >= ranges[i]) {
        tier = periodToRangeToTier[_period][ranges[i]];
        break;
      }

      if (i == 0) break;
    }

    return tier;
  }

  function stashesOf(address _playerAddress) external view returns (Stash[] memory) {
    uint256[] memory ids = playerStashes[_playerAddress].ids;
    Stash[] memory _stashes = new Stash[](ids.length);

    for (uint256 i = 0; i < ids.length; i++) {
      uint256 index = stashIdToStashIndex[ids[i]];
      _stashes[i] = stashes[index];
    }
    return _stashes;
  }

  function getStashes() external view returns (Stash[] memory) {
    return stashes;
  }

  function balanceOf(address _playerAddress) external view returns (uint256) {
    return playerBalance[_playerAddress];
  }

  /**
   * @dev Setters
   */
  function pause() public onlyRole(OPERATOR_ROLE) {
    _pause();
  }

  function unpause() public onlyRole(OPERATOR_ROLE) {
    _unpause();
  }

  /**
   * @dev set payment token. Needs to be an operator.
   * @param _paymentToken ERC20 token
   */
  function setPaymentToken(address _paymentToken) public onlyRole(OPERATOR_ROLE) {
    require(_paymentToken != address(0), "INV_ADDR");
    paymentToken = IERC20(_paymentToken);
  }

  /**
   * @dev must set this for the Tier matrix. Needs to be an operator.
   * @param _data array of allowed periods in days
   */
  function setPeriods(PeriodSet[] calldata _data) external onlyRole(OPERATOR_ROLE) {
    delete periods;

    for (uint256 i = 0; i < _data.length; i++) {
      allowedPeriods[_data[i].period] = _data[i].isActive;
      periods.push(_data[i].period);
    }
  }

  /**
   * @dev must set this for the Tier matrix. Needs to be an operator.
   * @param _data array of allowed ranges in wei
   */
  function setRanges(RangeSet[] calldata _data) external onlyRole(OPERATOR_ROLE) {
    delete ranges;

    for (uint256 i = 0; i < _data.length; i++) {
      allowedRanges[_data[i].range] = _data[i].isActive;
      ranges.push(_data[i].range);
    }
  }

  /**
   * @notice needs to set the ranges and periods first.
   * @dev must set this for the Tier matrix. Needs to be an operator.
   * @param _tierSet array of allowed tiers
   */

  function setTiers(TierSet[] calldata _tierSet) external onlyRole(OPERATOR_ROLE) {
    for (uint256 i = 0; i < _tierSet.length; i++) {
      require(allowedRanges[_tierSet[i].range], "INV_RANGE");
      require(allowedPeriods[_tierSet[i].period], "INV_DURATION");

      periodToRangeToTier[_tierSet[i].period][_tierSet[i].range] = _tierSet[i].tier;
    }
  }

  /**
   *@notice in case of address(0) the fee will be burned.
   *@dev must set this for godMode fees. Needs to be an operator.
   *@param _vault the vault address
   */
  function setVault(address _vault) public onlyRole(OPERATOR_ROLE) {
    vault = _vault;
  }

  function _addStash(Stash memory _stash) internal {
    uint256 stashId = _stash.id;

    stashes.push(_stash);
    stashIdToStashIndex[stashId] = stashes.length - 1;

    _addStashInfo(stashId, _stash.ownerAddress);
  }

  function _addStashInfo(uint256 _stashId, address ownerAddress) internal {
    uint256[] storage ids = playerStashes[ownerAddress].ids;

    if (ids.length == 0) {
      ids.push(0);
    }

    ids.push(_stashId);
    playerStashes[ownerAddress].idToIndex[_stashId] = ids.length - 1;
  }

  function _deleteStash(uint256 _stashId) internal {
    uint256 stashIndex = stashIdToStashIndex[_stashId];
    require(stashIndex < stashes.length && stashIndex != 0, "INV_ID");

    Stash memory _stash = stashes[stashIndex];
    Stash memory lastStash = stashes[stashes.length - 1];

    if (lastStash.id != _stashId) {
      stashes[stashIndex] = lastStash;
      stashIdToStashIndex[lastStash.id] = stashIndex;
    }

    stashes.pop();
    delete stashIdToStashIndex[_stashId];
    _deleteStashInfo(_stashId, _stash.ownerAddress);
  }

  function _deleteStashInfo(uint256 _stashId, address _ownerAddress) internal {
    uint256[] storage ids = playerStashes[_ownerAddress].ids;
    uint256 index = playerStashes[_ownerAddress].idToIndex[_stashId];
    require(index < ids.length && index != 0, "Invalid stash index");

    uint256 lastId = ids[ids.length - 1];

    if (lastId != _stashId) {
      ids[index] = lastId;
      playerStashes[_ownerAddress].idToIndex[lastId] = index;
    }

    ids.pop();
    delete playerStashes[_ownerAddress].idToIndex[_stashId];
  }

  /**
   * @notice Function to be used by Governance in exceptional cases. The stashes goes directly to the player.
   * @dev unstash the stashes of a player. Needs to be an operator.
   * @param _stashId the id of the stash to unstash
   * @param _fee the fee to be paid
   */
  function __godMode__unstash(uint256 _stashId, uint256 _fee) external onlyRole(OPERATOR_ROLE) {
    uint256 stashIndex = stashIdToStashIndex[_stashId];
    require(stashIndex < stashes.length && stashIndex != 0, "INV_ID");

    Stash memory _stash = stashes[stashIndex];
    address owner = _stash.ownerAddress;
    uint256 amount = _stash.amount;

    require(playerBalance[owner] >= amount, "NO_BALANCE");
    playerBalance[owner] = playerBalance[owner] - amount;

    require(playerToPeriodToBalance[owner][_stash.period] >= amount, "NO_BALANCE");
    playerToPeriodToBalance[owner][_stash.period] =
      playerToPeriodToBalance[owner][_stash.period] -
      amount;

    require(totalStashed >= amount, "INV_BALANCE");
    totalStashed = totalStashed - amount;

    uint256 cycles = cyclesOfStash(_stash.id);

    _deleteStash(_stashId);

    emit Unstashed(_stashId, owner, amount, cycles);

    if (_fee > 0) {
      require(_fee <= amount, "INV_FEE");
      uint256 liquidAmount = amount - _fee;

      paymentToken.transfer(owner, liquidAmount);

      if (vault != address(0)) {
        paymentToken.transfer(vault, _fee);
      } else {
        paymentToken.burn(_fee);
        emit FeeBurned(_stashId, owner, _fee);
      }
    } else {
      paymentToken.transfer(owner, amount);
    }
  }

  /**
   * @dev recover any ERC20 deposit by mistake.
   * @param _tokenAddress the address of the token
   * @param _amount the amount of the token
   * @param _recipient the address of the recepient
   */
  function recoverERC20(
    address _tokenAddress,
    uint256 _amount,
    address _recipient
  ) external onlyRole(OPERATOR_ROLE) {
    IERC20(_tokenAddress).transfer(_recipient, _amount);
  }
}