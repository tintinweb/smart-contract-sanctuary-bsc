/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/access/[email protected]


// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity 0.8.13;

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


// File @openzeppelin/contracts/utils/[email protected]


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)


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


// File @openzeppelin/contracts/utils/[email protected]


// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)


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


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

//pragma solidity 0.8.13;

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


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

//pragma solidity 0.8.13;

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


// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

//pragma solidity 0.8.13;


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
}


// File contracts/access/Guarded.sol


/// @title Guard contract extending Access Control
/// @author Osman Kuzucu
/// @notice Current implementation differs from the original
/// guard contract for the use case. Be cautious using
/// this contract for different purposes
/// @dev More roles could be added as needed
contract Guarded is AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant BLACKLISTER_ROLE = keccak256("BLACKLISTER_ROLE");
    bytes32 public constant WHITELISTER_ROLE = keccak256("WHITELISTER_ROLE");
    bytes32 public constant EXPIRER_ROLE = keccak256("EXPIRER_ROLE");
    bytes32 public constant COLLECTOR_ROLE = keccak256("COLLECTOR_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    /**
     * @notice state variables for checking whether a MBEP20 contract
     * is paused or any address is blacklisted or a contract is expired
     */
    mapping(address => bool) internal _paused;
    mapping(address => bool) internal _blacklist;
    mapping(address => bool) internal _whitelist;
    mapping(address => bool) internal _expired;

    /**
     * @notice state variables that would be effecting all the contracts
     */
    bool internal _allPaused;
    bool internal _blacklistEnabled;
    bool internal _whitelistEnabled;
    bool internal _allExpired;

    /**
     * @notice initially we should be setting up all the roles
     * necessary for our operation
     */
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(BLACKLISTER_ROLE, _msgSender());
        _setupRole(EXPIRER_ROLE, _msgSender());
        _setupRole(COLLECTOR_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(OWNER_ROLE, _msgSender());
    }

    /** PAUSE RELATED FUNCTIONS */

    /**
     * @dev public view function that returns whether all contracts are
     * paused or not
     *
     * @param tokenAddress address of the token to query
     *
     * @return bool
     */
    function isPaused(address tokenAddress) public view returns (bool) {
        return _paused[tokenAddress];
    }

    /**
     * @dev public view function that returns the status
     * of `_allPaused` variable
     *
     * @return bool
     */
    function isAllPaused() public view returns (bool) {
        return _allPaused;
    }

    /**
     * @dev pauses a specific token by address
     * @notice requires caller to have `PAUSER_ROLE`
     *
     * @param tokenAddress address of the token to pause
     *
     * @return bool
     */
    function pause(address tokenAddress)
        public
        onlyRole(PAUSER_ROLE)
        returns (bool)
    {
        _paused[tokenAddress] = true;
        return true;
    }

    /**
     * @dev unpauses a specific token by address
     * @notice this function requires caller to have `PAUSER_ROLE`
     *
     * @param tokenAddress address of the token to unpause
     *
     * @return bool
     */
    function unpause(address tokenAddress)
        public
        onlyRole(PAUSER_ROLE)
        returns (bool)
    {
        _paused[tokenAddress] = false;
        return true;
    }

    /**
     * @dev pauses all of the contracts
     * @notice requires caller to have `OWNER_ROLE`
     *
     * @return bool
     */
    function pauseAll() public onlyRole(OWNER_ROLE) returns (bool) {
        _allPaused = true;
        return true;
    }

    /**
     * @dev unpause all of the contracts
     * @notice requires caller to have `OWNER_ROLE`
     *
     * @return bool
     */
    function unpauseAll() public onlyRole(OWNER_ROLE) returns (bool) {
        _allPaused = false;
        return true;
    }

    /** BLACKLIST RELATED FUNCTIONS */

    /**
     * @dev check if blacklisting module is enabled
     *
     * @return bool
     */
    function isBlacklistEnabled() public view returns (bool) {
        return _blacklistEnabled;
    }

    /**
     * @dev enables black list module
     * @notice requires caller to have `OWNER_ROLE`
     *
     * @return bool
     */
    function enableBlacklist() public onlyRole(OWNER_ROLE) returns (bool) {
        _blacklistEnabled = true;
        return true;
    }

    /**
     * @dev disables blacklist module
     * @notice requires caller to have `OWNER_ROLE`
     *
     * @return bool
     */
    function disableBlacklist() public onlyRole(OWNER_ROLE) returns (bool) {
        _blacklistEnabled = false;
        return true;
    }

    /**
     * @dev checks if an address is blacklisted
     *
     * @param user address of the user
     *
     * @return bool
     */
    function isBlacklisted(address user) public view returns (bool) {
        return _blacklist[user];
    }

    /**
     * @dev blacklists an address
     * @notice requires caller to have `BLACKLISTER_ROLE`
     *
     * @param user address of the user
     *
     * @return bool
     */
    function blacklist(address user)
        public
        onlyRole(BLACKLISTER_ROLE)
        returns (bool)
    {
        _blacklist[user] = true;
        return true;
    }

    /**
     * @dev removes an address from the blacklist
     * @notice requires caller to have `BLACKLISTER_ROLE`
     *
     * @param user address of the user
     *
     * @return bool
     */
    function removeFromBlacklist(address user)
        public
        onlyRole(BLACKLISTER_ROLE)
        returns (bool)
    {
        _blacklist[user] = false;
        return true;
    }

    /** WHITELIST RELATED FUNCTIONS */

    /**
     * @dev checks if whitelist enabled
     *
     * @return bool
     */
    function isWhitelistEnabled() public view returns (bool) {
        return _whitelistEnabled;
    }

    /**
     * @dev enables whitelist
     * @notice requires caller to have `OWNER_ROLE`
     *
     * @return bool
     */
    function enableWhitelist() public onlyRole(OWNER_ROLE) returns (bool) {
        _whitelistEnabled = true;
        return true;
    }

    /**
     * @dev disables whitelist
     * @notice requires caller to have `OWNER_ROLE`
     *
     * @return bool
     */
    function disableWhitelist() public onlyRole(OWNER_ROLE) returns (bool) {
        _whitelistEnabled = false;
        return true;
    }

    /**
     * @dev checks if an address is whitelisted
     *
     * @param user address of the user
     *
     * @return bool
     */
    function isWhitelisted(address user) public view returns (bool) {
        return _whitelist[user];
    }

    /**
     * @dev whitelists an address
     * @notice requires caller to have `WHITELISTER_ROLE`
     *
     * @param user address of the user
     *
     * @return bool
     */
    function whitelist(address user)
        public
        onlyRole(WHITELISTER_ROLE)
        returns (bool)
    {
        _whitelist[user] = true;
        return true;
    }

    /**
     * @dev removes an address from whitelist
     * @notice requires caller to have `WHITELISTER_ROLE`
     *
     * @param user address of the user
     *
     * @return bool
     */
    function removeFromWhitelist(address user)
        public
        onlyRole(WHITELISTER_ROLE)
        returns (bool)
    {
        _whitelist[user] = false;
        return true;
    }

    /** EXPIRATION RELATED FUNCTIONS */

    /**
     * @dev checks if all tokens are expired
     *
     * @return bool
     */
    function isAllExpired() public view returns (bool) {
        return _allExpired;
    }

    /**
     * @dev expires all contracts
     * @notice requires caller to have `OWNER_ROLE`
     *
     * @return bool
     */
    function expireAll() public onlyRole(OWNER_ROLE) returns (bool) {
        _allExpired = true;
        return true;
    }

    /**
     * @dev unexpires all contracts
     * @notice requires caller to have `OWNER_ROLE`
     *
     * @return bool
     */
    function unexpireAll() public onlyRole(OWNER_ROLE) returns (bool) {
        _allExpired = false;
        return true;
    }

    /**
     * @dev checks if a token contract is expired
     *
     * @param tokenAddress address of the token to query
     *
     * @return bool
     */
    function isExpired(address tokenAddress) public view returns (bool) {
        return _expired[tokenAddress];
    }

    /**
     * @dev expires a contract
     * @notice requires caller to have `EXPIRER_ROLE`
     *
     * @param tokenAddress address of the token
     *
     * @return bool
     */
    function expire(address tokenAddress)
        public
        onlyRole(EXPIRER_ROLE)
        returns (bool)
    {
        _expired[tokenAddress] = true;
        return true;
    }

    /**
     * @dev unexpires a contract
     * @notice requires caller to have `EXPIRER_ROLE`
     *
     * @param tokenAddress address of the token
     *
     * @return bool
     */
    function unexpire(address tokenAddress)
        public
        onlyRole(EXPIRER_ROLE)
        returns (bool)
    {
        _expired[tokenAddress] = false;
        return true;
    }
}


// File @openzeppelin/contracts/token/ERC20/[email protected]


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

//pragma solidity 0.8.13;

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


// File @openzeppelin/contracts/utils/[email protected]


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

//pragma solidity 0.8.13;

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


// File @openzeppelin/contracts/token/ERC20/utils/[email protected]


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

//pragma solidity 0.8.13;


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


// File contracts/interfaces/IBEP20.sol


//pragma solidity 0.8.13;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


// File contracts/interfaces/IMBEP20.sol


//pragma solidity 0.8.13;
interface IMBEP20 is IBEP20 {
    /** 
     * @dev Mints `amount` tokens to `recipient`
     *
     * Emits a {Mint} event.
     */
    function mint(address recipient, uint256 amount) external returns (bool);
    
    /**
     * @dev Burns `amount` tokens `from` 
     *
     * Emits a {Burn} event.
     */
    function burn(address from, uint256 amount) external returns (bool);

    /** 
     * @dev Emitted when `amount` of tokens are minted to the `recipient`
     */
    event Mint(address indexed recipient, uint256 amount);
    
    /**
     * @dev Emitted when `amount` of tokens are burned `from`
     */
    event Burn(address indexed from, uint256 amount);
}


// File contracts/interfaces/IGuarded.sol


//pragma solidity 0.8.13;

/// @title Interface for the {Guard} contract
/// @author Osman Kuzucu
/// @notice only the view functions are implemented on the interface
/// as they are enough for functionality we require
interface IGuarded {
    /**
     * @dev Returns whether all contracts are paused or not
     */
    function isAllPaused() external view returns (bool);

    /**
     * @dev Returns whether contract at address `tokenAddress` is paused or not
     */
    function isPaused(address tokenAddress) external view returns (bool);

    /**
     * @dev Returns whether blacklist module is enabled or not
     */
    function isBlacklistEnabled() external view returns (bool);

    /**
     * @dev Returns whether an `user` is blacklisted or not
     */
    function isBlacklisted(address user) external view returns (bool);

    /**
     * @dev Returns whether whitelist is enabled or not
     */
    function isWhitelistEnabled() external view returns (bool);

    /**
     * @dev Returns whether an `user` is whitelisted or not
     */
    function isWhitelisted(address user) external view returns (bool);

    /**
     * @dev Returns whether all contracts are expired or not
     */
    function isAllExpired() external view returns (bool);

    /**
     * @dev Returns whether contract at address `tokenAddress` is expired or not
     */
    function isExpired(address tokenAddress) external view returns (bool);
}


// File contracts/interfaces/IMonoviFactory.sol


//pragma solidity 0.8.13;
interface IMonoviFactory is IGuarded {
    /** 
     * @dev returns the `_garbage`
     */
    function getGarbageAddress() external view returns (address);
}


// File contracts/token/MBEP20.sol


//pragma solidity 0.8.13;

/// @title MBEP20 contract
/// @author Osman Kuzucu
/// @notice MBEP20 standart is dependent on a factory
/// @notice the Context was inherited based on the client's request for msg.sender
contract MBEP20 is Context, IMBEP20 {
    // @dev interface object that forwards calls to the {MonoviFactory} contract
    IMonoviFactory private _factory;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;

    string private _name;
    string private _symbol;

    /**
     * @dev modifier that checks if the `_msgSender()` is the factory contract
     *
     * Whenever a smart contract calls another smart contract, the `_msgSender()`
     * value becomes the address of the caller smart contract. This way
     * if a user calls a function from the factory contract that calls
     * a function from MBEP20 contract, _msgSender() becomes the factory contract
     *
     * Our design allows regular calls from users, or factory only calls
     * and access is managed at the factory contract.
     */
    modifier onlyFactory() {
        require(
            _isFactory(_msgSender()),
            "MBEP20: you must call this from factory"
        );
        _;
    }

    constructor(
        address factory,
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 supply_
    ) {
        _factory = IMonoviFactory(factory);
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        mint(_msgSender(), supply_);
    }

    /**
     * @dev returns factory address
     *
     * @return address
     */
    function getFactory() public view returns (address) {
        return address(_factory);
    }

    /**
     * @dev returns `_totalSupply`
     *
     * @return uint256
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev returns `_decimals`
     *
     * @return uint8
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev returns `_symbol`
     *
     * @return string memory
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev returns `_name`
     *
     * @return string memory
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev returns the owner of the contract
     *
     * Unlike BEP20, MBEP20 contract doesnt have a owner variable
     * instead it is designed to return the factory address as its
     * owner
     *
     * @return address
     */
    function getOwner() public view returns (address) {
        return address(_factory);
    }

    /**
     * @dev queries balance of the `account`
     *
     * This function first checks whether all contracts are expired or not
     * and later checks if this contract is expired or not from the
     * `_factory` contract. If the contract is expired, it returns
     * zero balance for all the accounts except garbage account.
     *
     * If the contracts are not expired, then it returns the usual balance
     * from the internal {_balance} function.
     *
     * @param account the account to query
     *
     * @return uint256
     *  */
    function balanceOf(address account) public view returns (uint256) {
        if (_factory.isAllExpired() || _factory.isExpired(address(this))) {
            return _factory.getGarbageAddress() == account ? _totalSupply : 0;
        }
        return _balanceOf(account);
    }

    /**
     * @dev returns the amount of tokens `spender` can spend on behalf of `owner`
     *
     * This function first checks if the spender is the factory address
     * if it is the factory address, it returns the `_totalSupply` as allowance
     * so that factory can call {transferFrom} function on behalf of any
     * token holder.
     *
     * If the caller is not the factory contract, it calls {_allowance} function
     * that returns the real allowance `spender` has for `owner`
     *
     * @param owner address of the owner whose tokens will be spent
     * @param spender address of the spender
     *
     * @return uint256 amount of tokens that could be spent
     */
    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return
            spender == address(_factory)
                ? _totalSupply
                : _allowance(owner, spender);
    }

    /**
     * @dev transfers `amount` to `recipient` from `_msgSender()`
     *
     * This function first calls {_beforeTokenTransfer} and later
     * calls {_transfer} function.
     *
     * @param recipient the receiver of the tokens
     * @param amount the amount of tokens to be transferred
     *
     * @return bool
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _beforeTokenTransfer(_msgSender(), recipient, amount);
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev mints `amount` of tokens to `recipient`
     *
     * Emits {Mint} and {Transfer} events. The transfer event is emitted
     * as if the transfer happened from zero address
     *
     * @notice requires `_msgSender()` to be the factory address
     *
     * @param recipient the address of the receiver
     * @param amount the amount of tokens to be minted
     *
     * @return bool
     */
    function mint(address recipient, uint256 amount)
        public
        onlyFactory
        returns (bool)
    {
        _totalSupply += amount;
        _balances[recipient] += amount;
        emit Mint(recipient, amount);
        emit Transfer(address(0), recipient, amount);
        return true;
    }

    /**
     * @dev burn `amount` of tokens `from`
     *
     * Emits {Burn} and {Transfer} events. The transfer event is emitted
     * as if tokens are transferred to zero address
     *
     * If balance of the `from` is less than the `amount` the
     * _balances[from] -= amount operation will cause a revert
     * reason
     *
     * @notice requires `_msgSender()` to be the factory address
     *
     * @param from the address tokens will be burned from
     * @param amount the amount of tokens to be burned
     *
     * @return bool
     */
    function burn(address from, uint256 amount)
        public
        onlyFactory
        returns (bool)
    {
        _totalSupply -= amount;
        _balances[from] -= amount;
        emit Burn(from, amount);
        emit Transfer(from, address(0), amount);
        return true;
    }

    /**
     * @dev approves `amount` to be spent on behalf of the `_msgSender()`
     * by the `spender`
     *
     * Emits {Approval} event
     *
     * @param spender address of the spender who is authorized to spend `amount`
     * @param amount tokens that could be spent by the `spender`
     *
     * @return bool
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _allowances[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev transfers `amount` to `recipient `on behalf of `sender` by `_msgSender()`
     *
     * Be aware that this function first calls {_beforeTokenTransfer}
     * then {_decreaseAllowance} and {_transfer} functions and returns boolean
     *
     * @param sender `amount` to be deduced from `sender`
     * @param recipient receiver of the `amount`
     * @param amount to be transferred
     *
     * @return bool
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _beforeTokenTransfer(sender, recipient, amount);
        _decreaseAllowance(sender, _msgSender(), amount);
        _transfer(sender, recipient, amount);
        return true;
    }

    /**
     * @dev checks if `user` is factory address
     *
     * This is used for checking whether calls are originated
     * from the factory contract
     *
     * @param user address to be queried
     *
     * @return boolean - true if it is factory, false if not
     */
    function _isFactory(address user) internal view returns (bool) {
        return user == address(_factory) ? true : false;
    }

    /**
     * @dev internal balance query function returning balance
     * of the `account` from `_balances` mapping
     *
     * @param account address to be queried
     *
     * @return balance in uint256
     */
    function _balanceOf(address account) internal view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev internal allowance function that returns the amount of
     * tokens that could be spent by `spender` on behalf of `owner`
     *
     * @param owner whose tokens will be spent
     * @param spender address who will be spending
     *
     * @return amount allowed to spend
     */
    function _allowance(address owner, address spender)
        internal
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev function that is called before the token transfer
     * for required checks on the contract for `sender` and `recipient`
     *
     * It first checks if the `_msgSender()` is the factory contract, if it is,
     * it passes all the checks and execution continues
     *
     * If it is not, then it requires the contract(s) to be unpaused
     *
     * It then checks if the blacklist module is enabled, if it is enabled
     * it checks both the `sender` and `recipient` are not blacklisted
     *
     * It then checks if the whitelist module is enabled, if it is enabled
     * it requires at least one of the `sender` and `recipient` to be whitelisted
     *
     * All the checks are redirected to the factory contract to
     * make sure everything could be operated from the factory contract
     *
     * These checks are there in case if MBEP20 contracts will be opened to
     * be publicly traded / transferred
     *
     * @param sender address of the sender
     * @param recipient address of the receiver
     */
    function _beforeTokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {
        if (!_isFactory(_msgSender())) {
            require(balanceOf(sender) >= amount, "MBEP20: not enough balance");
            require(
                !(_factory.isAllPaused() || _factory.isPaused(address(this))),
                "MBEP20: contract paused"
            );
            if (_factory.isBlacklistEnabled()) {
                require(
                    !(_factory.isBlacklisted(sender) ||
                        _factory.isBlacklisted(recipient)),
                    "MBEP20: receiver or sender is blacklisted"
                );
            }
            if (_factory.isWhitelistEnabled()) {
                require(
                    _factory.isWhitelisted(sender) ||
                        _factory.isWhitelisted(recipient),
                    "MBEP20: you are not whitelisted"
                );
            }
        }
    }

    /**
     * @dev internal transfer function that checks `from` or `to`
     * is not the zero address and the `from` has enough balance
     * to transfer tokens.
     *
     * This is also called by `transferFrom` function
     *
     * Emits {Transfer} event
     *
     * @param from the sender
     * @param to the receiver
     * @param amount to be transferred
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "MBEP20: Transfer from zero address");
        require(to != address(0), "MBEP20: Transfer to zero address");
        require(_balances[from] >= amount, "MBEP20: not enough balance");

        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    /**
     * @dev function that decreases allowance of the `spender`
     * for the `sender`
     *
     * It makes a call to the {allowance} function, if this is queried
     * for the factory contract, allowance returns total supply
     * which is then queried by an if call and effectively doesn't change
     * any value
     *
     * If this function is called for any other contract than factory,
     * it checks allowance as usual, and decreases the `amount` from the
     * `spender`'s allowance
     *
     * @param sender the sending party
     * @param spender the address who is spending on behalf of sender
     * @param amount tokens to be transferred
     */
    function _decreaseAllowance(
        address sender,
        address spender,
        uint256 amount
    ) internal {
        require(
            allowance(sender, spender) >= amount,
            "MBEP20: not enough allowance"
        );
        if (spender != address(_factory)) {
            _allowances[sender][spender] -= amount;
        }
    }
}


// File contracts/MonoviFactory.sol


//pragma solidity 0.8.13;

/// @title Monovi Factory contract
/// @author Osman Kuzucu
//TODO: implement token recover on MBEP20 tokens too
//TODO: add events to all calls
//TODO: add role admin update function

contract MonoviFactory is Guarded {
    /// @dev used in case of token recovery as some BEP20 tokens are not fully ERC20/BEP20 compliant
    using SafeERC20 for IERC20;

    /// @dev array of the Monovi Tokens registered in the contract
    /// @notice mapping is used for checking whether an address is a factory produced contract or not
    address[] private _tokens;
    mapping(address => bool) private _isMonoviToken;

    /// @dev garbage address
    address private _garbage;

    event DeployNewToken(
        address indexed tokenAddress,
        string name,
        string symbol,
        uint8 decimals,
        uint256 supply
    );
    event TransferContract(
        address indexed tokenAddress,
        address indexed sender,
        address indexed receiver,
        uint256 amount
    );
    event TokenBurnedContract(
        address indexed tokenAddress,
        address indexed from,
        uint256 amount
    );
    event TokenMintedContract(
        address indexed tokenAddress,
        address indexed recipient,
        uint256 amount
    );

    modifier onlyMonoviToken(address tokenAddress) {
        require(isMonoviToken(tokenAddress), "Not a Monovi Token");
        _;
    }

    constructor() Guarded() {
        enableBlacklist();
        enableWhitelist();
    }

    /**
     * @dev deploys a new monovi token and pushes the
     * address to the `_tokens` array and updates `_isMonoviToken` mapping
     * for the address to be true
     *
     * Emits {DeployNewToken} event
     *
     * @notice requires `msg.sender` to have `OWNER_ROLE`
     *
     * @param name_ name of the new token to be deployed
     * @param symbol_ symbol of the new token to be deployed
     * @param decimals_ decimals of the new token to be deployed in uint8
     * @param supply_ the initial supply of the token
     *
     * @return bool
     */
    function deployNewToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 supply_
    ) public onlyRole(OWNER_ROLE) returns (bool) {
        MBEP20 newToken = new MBEP20(
            address(this),
            name_,
            symbol_,
            decimals_,
            supply_
        );
        _tokens.push(address(newToken));
        _isMonoviToken[address(newToken)] = true;
        emit DeployNewToken(
            address(newToken),
            name_,
            symbol_,
            decimals_,
            supply_
        );
        return true;
    }

    /** GARBAGE ADDRESS FUNCTIONS */

    /**
     * @dev sets the garbage address as `garbage`
     *
     * @notice requires `msg.sender` to have the `ONLY_OWNER` role
     *
     * @param garbage new garbage address
     *
     * @return bool
     */
    function setGarbageAddress(address garbage)
        public
        onlyRole(OWNER_ROLE)
        returns (bool)
    {
        _garbage = garbage;
        return true;
    }

    /**
     * @dev returs the garbage address
     *
     * This is used at the MBEP20 contracts for querying balance if
     * the MBEP20 token is expired
     *
     * @return garbage address
     */
    function getGarbageAddress() public view returns (address) {
        return _garbage;
    }

    /** VIEW FUNCTIONS FOR MBEP FACTORY PATTERN */

    /**
     * @dev checks if `tokenAddress` is a factory issued token
     *
     * @param tokenAddress address to be queried
     *
     * @return true if it is a factory issued token, false if not
     */
    function isMonoviToken(address tokenAddress) public view returns (bool) {
        return _isMonoviToken[tokenAddress];
    }

    /**
     * @dev returns the balance of a user given a contract address
     *
     * @param tokenAddress address of the token
     * @param user address of the user
     *
     * @return balance of the user uint256
     */
    function balanceOf(address tokenAddress, address user)
        public
        view
        returns (uint256)
    {
        return MBEP20(tokenAddress).balanceOf(user);
    }

    /**
     * @dev mints `amount` to the `recipient` at the `tokenAddress`
     *
     * @notice this function requires `msg.sender` to have `MINTER_ROLE`
     *
     * emits {TokenMintedContract}
     *
     * @param tokenAddress address of the token
     * @param recipient address of the receiver
     * @param amount tokens to be minted
     *
     * @return true if mint successful else it fails
     */
    function mint(
        address tokenAddress,
        address recipient,
        uint256 amount
    )
        public
        onlyRole(MINTER_ROLE)
        onlyMonoviToken(tokenAddress)
        returns (bool)
    {
        emit TokenMintedContract(tokenAddress, recipient, amount);
        return MBEP20(tokenAddress).mint(recipient, amount);
    }

    /**
     * @dev burns `amount` from the `from` at the `tokenAddress`
     *
     * @notice this function requires `msg.sender` to have `MINTER_ROLE`
     *
     * emits {TokenBurnedContract}
     *
     * @param tokenAddress address of the token
     * @param from address `amount` will be burned from
     * @param amount tokens to be burned
     *
     * @return true if burn is successful else it fails
     */
    function burn(
        address tokenAddress,
        address from,
        uint256 amount
    )
        public
        onlyRole(MINTER_ROLE)
        onlyMonoviToken(tokenAddress)
        returns (bool)
    {
        emit TokenBurnedContract(tokenAddress, from, amount);
        return MBEP20(tokenAddress).burn(from, amount);
    }

    /**
     * @dev transfers `amount` to the `recipient` at the `tokenAddress`
     *
     * Since when a new token is deployed, all the supply is minted
     * and credited to the factory contract, in order to distribute
     * tokens to the user, this function should be called
     *
     * Emits {TransferContract} event
     *
     *
     * @notice requires `msg.sender` to have the `COLLECTOR_ROLE`
     *
     * New role could be added if we want tokens to be distributed
     * by the distributor role
     *
     * @param tokenAddress address of the token transfer will be made at
     * @param recipient address of the recipient
     * @param amount tokens to be transferred
     *
     * @return true if transfer succeeds, else transaction fails
     */
    function transfer(
        address tokenAddress,
        address recipient,
        uint256 amount
    )
        public
        onlyRole(COLLECTOR_ROLE)
        onlyMonoviToken(tokenAddress)
        returns (bool)
    {
        emit TransferContract(tokenAddress, msg.sender, recipient, amount);
        return MBEP20(tokenAddress).transfer(recipient, amount);
    }

    /**
     * @dev transfers `amount` to the `recipient` at the `tokenAddress` on
     * behalf of the `sender`
     *
     * Due to the design of the MBEP20 contract, factory contract can
     * call {transferFrom} function at any Monovi Token contract. This function
     * is used for force transfer between accounts
     *
     * emits {TransferContract}
     *
     * Also checks call is only made to a Monovi Token
     *
     * @notice requires `msg.sender` to have the `COLLECTOR_ROLE`
     *
     * New role could be added if we want tokens to be distributed
     * by the distributor role.
     *
     * @param tokenAddress address of the token transfer will be made at
     * @param sender `amount` to be deduced from
     * @param recipient address of the recipient
     * @param amount tokens to be transferred
     *
     * @return true if transfer succeeds, else transaction fails
     */
    function transferFrom(
        address tokenAddress,
        address sender,
        address recipient,
        uint256 amount
    )
        public
        onlyRole(COLLECTOR_ROLE)
        onlyMonoviToken(tokenAddress)
        returns (bool)
    {
        emit TransferContract(tokenAddress, sender, recipient, amount);
        return MBEP20(tokenAddress).transferFrom(sender, recipient, amount);
    }

    /** TOKEN RECOVER */
    function recoverERC20(
        address contractAddress,
        address receiver,
        uint256 amount
    ) public onlyRole(OWNER_ROLE) returns (bool) {
        IERC20 tokenInstance_ = IERC20(contractAddress);
        tokenInstance_.transfer(receiver, amount);
        return true;
    }

    function recoverNative(address receiver, uint256 amount)
        public
        onlyRole(OWNER_ROLE)
        returns (bool)
    {
        address payable receiver_ = payable(receiver);
        receiver_.transfer(amount);
        return true;
    }
}