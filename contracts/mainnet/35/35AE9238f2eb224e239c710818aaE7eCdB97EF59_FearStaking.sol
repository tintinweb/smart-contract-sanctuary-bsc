// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;


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
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
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
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
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




/**
 * @dev Interface for contract which allows to pause and unpause the contract.
 */
interface IPausable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);
    
    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() external view returns (bool);

    /**
    * @dev Pauses the contract.
    */
    function pause() external;

    /**
    * @dev Unpauses the contract.
    */
    function unpause() external;
}




/**
 * @dev Interface of a contract containing identifier for Pauser role.
 */
interface IRoleContainerPauser {
    /**
    * @dev Returns Pauser role identifier.
    */
    function PAUSER_ROLE() external view returns (bytes32);
}




/**
 * @dev Interface of a contract containing identifier for Root role.
 */
interface IRoleContainerRoot {
    /**
    * @dev Returns Root role identifier.
    */
    function ROOT_ROLE() external view returns (bytes32);
}




/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
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




/**
 * @dev Interface of a contract containing identifier for Admin role.
 */
interface IRoleContainerAdmin {
    /**
    * @dev Returns Admin role identifier.
    */
    function ADMIN_ROLE() external view returns (bytes32);
}




/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via _msgSender() and msg.data, they should not be accessed in such a direct
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

    function toString(bytes32 value) internal pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && value[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && value[i] != 0; i++) {
            bytesArray[i] = value[i];
        }
        return string(bytesArray);
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
 * @dev Storage based implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
abstract contract ERC165Storage is ERC165 {
    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId] || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
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
 *     require(hasRole(MY_ROLE, _msgSender()));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 */
abstract contract AccessControl is Context, ERC165Storage, IAccessControl, IRoleContainerAdmin {
    /**
    * @dev Root Admin role identifier.
    */
    bytes32 public constant ROOT_ROLE = "Root";

    /**
    * @dev Admin role identifier.
    */
    bytes32 public constant ADMIN_ROLE = "Admin";

    /**
    * @dev Manager role identifier.
    */
    bytes32 public constant MANAGER_ROLE = "Manager";

    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    constructor() {
        _registerInterface(type(IAccessControl).interfaceId);

        _setupRole(ROOT_ROLE, _msgSender());
        _setRoleAdmin(ADMIN_ROLE, ROOT_ROLE);
        _setRoleAdmin(MANAGER_ROLE, ROOT_ROLE);
    }

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toString(role)
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
    function _setupRole(bytes32 role, address account) private {
        _grantRole(role, account);
        _setRoleAdmin(role, ROOT_ROLE);
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
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is AccessControl, IPausable, IRoleContainerPauser {
    /**
    * @dev Pauser role identifier.
    */
    bytes32 public constant PAUSER_ROLE = "Pauser";

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () {
        _registerInterface(type(IPausable).interfaceId);

        _setRoleAdmin(PAUSER_ROLE, ROOT_ROLE);

        _paused = true;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
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
        require(!_paused, "Pausable: paused");
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
        require(_paused, "Pausable: not paused");
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
   
    /**
    * @dev This function is called before pausing the contract.
    * Override to add custom pausing conditions or actions.
    */
    function _beforePause() internal virtual {
    }

    /**
    * @dev This function is called before unpausing the contract.
    * Override to add custom unpausing conditions or actions.
    */
    function _beforeUnpause() internal virtual {
    }

    /**
    * @dev Pauses the contract.
    * Requirements:
    * - Caller must have 'PAUSER_ROLE';
    * - Contract must be unpaused.
    */
    function pause() external onlyRole(PAUSER_ROLE) whenNotPaused {
        _beforePause();
        _pause();
    }

    /**
    * @dev Unpauses the contract.
    * Requirements:
    * - Caller must have 'PAUSER_ROLE';
    * - Contract must be unpaused;
    */
    function unpause() external onlyRole(PAUSER_ROLE) whenPaused {
        _beforeUnpause();
        _unpause();
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

        assembly {
            result := store
        }

        return result;
    }
}



/**
 * @dev Contract module which allows to perform basic checks on arguments.
 */
abstract contract RequirementsChecker {
    uint256 internal constant inf = type(uint256).max;

    function _requireNonZeroAddress(address _address, string memory paramName) internal pure {
        require(_address != address(0), string(abi.encodePacked(paramName, ": cannot use zero address")));
    }

    function _requireArrayData(address[] memory _array, string memory paramName) internal pure {
        require(_array.length != 0, string(abi.encodePacked(paramName, ": cannot be empty")));
    }

    function _requireArrayData(uint256[] memory _array, string memory paramName) internal pure {
        require(_array.length != 0, string(abi.encodePacked(paramName, ": cannot be empty")));
    }

    function _requireStringData(string memory _string, string memory paramName) internal pure {
        require(bytes(_string).length != 0, string(abi.encodePacked(paramName, ": cannot be empty")));
    }

    function _requireSameLengthArrays(address[] memory _array1, uint256[] memory _array2, string memory paramName1, string memory paramName2) internal pure {
        require(_array1.length == _array2.length, string(abi.encodePacked(paramName1, ", ", paramName2, ": lengths must be equal")));
    }

    function _requireInRange(uint256 value, uint256 minValue, uint256 maxValue, string memory paramName) internal pure {
        string memory maxValueString = maxValue == inf ? "inf" : Strings.toString(maxValue);
        require(minValue <= value && (maxValue == inf || value <= maxValue), string(abi.encodePacked(paramName, ": must be in [", Strings.toString(minValue), "..", maxValueString, "] range")));
    }
}




/**
 * @dev Interface of a contract module which allows to withdraw assets.
 */
interface IWithdrawable {
    /**
     * @dev Emitted when network main currency withdrawal occurs.
     */
    event Withdrawal(address to, string reason);
    /**
     * @dev Emitted when ERC20 asset withdrawal occurs.
     */
    event WithdrawalERC20(address asset, address to, string reason);
    /**
     * @dev Emitted when ERC721 asset withdrawal occurs.
     */
    event WithdrawalERC721(address asset, uint256[] ids, address to, string reason);
    /**
     * @dev Emitted when ERC1155 asset withdrawal occurs.
     */
    event WithdrawalERC1155(address asset, uint256[] ids, address to, string reason);

    /**
    * @dev Withdraws all balance of the network main currency.
    * Emits a {Withdrawal} event.
    */
    function withdraw(address payable to, string calldata reason) external;

    /**
    * @dev Withdraws all balance of specified ERC20 asset.
    * Emits a {WithdrawalERC20} event.
    */
    function withdrawERC20(address asset, address to, string calldata reason) external;

    /**
    * @dev Withdraws all of specified ERC721 asset with ids.
    * Emits a {WithdrawalERC721} event.
    */
    function withdrawERC721(address asset, uint256[] calldata ids, address to, string calldata reason) external;

    /**
    * @dev Withdraws all balances of specified ERC1155 asset with ids.
    * Emits a {WithdrawalERC1155} event.
    */
    function withdrawERC1155(address asset, uint256[] calldata ids, address to, string calldata reason) external;
}



/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers from ERC721 asset contracts.
 */
interface IERC721Receiver is IERC165 {
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



/**
 * @dev Implementation of the {IERC721Receiver} interface.
 */
abstract contract ERC721Holder is ERC165Storage, IERC721Receiver {

    constructor() {
        _registerInterface(type(IERC721Receiver).interfaceId);
    }

    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}




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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}



/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transfered from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}



/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}



/**
 * @dev Interface of extension of {IERC165} that allows to handle receipts on receiving {IERC1155} assets.
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. _msgSender())
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. _msgSender())
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}



/**
 * Simple implementation of `IERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be stuck.
 */
contract ERC1155Holder is ERC165Storage, IERC1155Receiver {

    constructor() {
        _registerInterface(type(IERC1155Receiver).interfaceId);
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}



/**
 * @dev Contract module which allows authorized account to withdraw assets in case of emergency.
 */
abstract contract Withdrawable is AccessControl, RequirementsChecker, ERC721Holder, ERC1155Holder, IWithdrawable {

    constructor () {
        _registerInterface(type(IWithdrawable).interfaceId);
    }

    /**
    * @dev Withdraws all balance of the network main currency.
    * Emits a {Withdrawal} event.
    */
    function withdraw(address payable to, string calldata reason) external onlyRole(ADMIN_ROLE) {
        _requireNonZeroAddress(to, "to");
        _requireStringData(reason, "reason");
        _beforeWithdrawal(to);

        (bool success,) = to.call{value: address(this).balance}("");
        require(success, "Withdraw failed");
        emit Withdrawal(to, reason);
    }

    /**
    * @dev Withdraws all balance of specified ERC20 asset.
    * Emits a {WithdrawalERC20} event.
    */
    function withdrawERC20(address asset, address to, string calldata reason) external onlyRole(ADMIN_ROLE) {
        _requireNonZeroAddress(asset, "asset");
        _requireNonZeroAddress(to, "to");
        _requireStringData(reason, "reason");
        _beforeWithdrawalERC20(asset, to);

        IERC20 token = IERC20(asset);        
        token.transfer(to, token.balanceOf(address(this)));
        emit WithdrawalERC20(asset, to, reason);
    }

    /**
    * @dev Withdraws all of specified ERC721 asset with ids.
    * Emits a {WithdrawalERC721} event.
    */
    function withdrawERC721(address asset, uint256[] calldata ids, address to, string calldata reason) external onlyRole(ADMIN_ROLE) {
        _requireNonZeroAddress(asset, "asset");
        _requireNonZeroAddress(to, "to");
        _requireArrayData(ids, "ids");
        _requireStringData(reason, "reason");
        _beforeWithdrawalERC721(asset, ids, to);

        IERC721 token = IERC721(asset);
        for(uint i = 0; i < ids.length; i++)
            token.safeTransferFrom(address(this), to, ids[i], "");
        emit WithdrawalERC721(asset, ids, to, reason);
    }

    /**
    * @dev Withdraws all balances of specified ERC1155 asset with ids.
    * Emits a {WithdrawalERC1155} event.
    */
    function withdrawERC1155(address asset, uint256[] calldata ids, address to, string calldata reason) external onlyRole(ADMIN_ROLE) {
        _requireNonZeroAddress(asset, "asset");
        _requireNonZeroAddress(to, "to");
        _requireArrayData(ids, "ids");
        _requireStringData(reason, "reason");
        _beforeWithdrawalERC1155(asset, ids, to);

        IERC1155 token = IERC1155(asset);

        address[] memory addresses = new address[](ids.length);
        for(uint i = 0; i < ids.length; i++)
            addresses[i] = address(this); // actually only this one, but multiple times to call balanceOfBatch

        uint256[] memory balances = token.balanceOfBatch(addresses, ids);
        token.safeBatchTransferFrom(address(this), to, ids, balances, "");
        emit WithdrawalERC1155(asset, ids, to, reason);
    }

    /**
    * @dev This function is called before withdrawal takes place.
    * Override to add custom conditions or actions.
    */
    function _beforeWithdrawal(address to) internal virtual {
    }

    /**
    * @dev This function is called before ERC20 withdrawal takes place.
    * Override to add custom conditions or actions.
    */
    function _beforeWithdrawalERC20(address asset, address to) internal virtual {
    }

    /**
    * @dev This function is called before ERC721 withdrawal takes place.
    * Override to add custom conditions or actions.
    */
    function _beforeWithdrawalERC721(address asset, uint256[] calldata ids, address to) internal virtual {
    }

    /**
    * @dev This function is called before ERC1155 withdrawal takes place.
    * Override to add custom conditions or actions.
    */
    function _beforeWithdrawalERC1155(address asset, uint256[] calldata ids, address to) internal virtual {
    }
}



/**
 * @dev Contract for staking FEAR in exchange of FEAR reward.
 * Multiple staking is possible.
 * Partial unstaking is possible.
 * Reward can be claimed any moment.
 * After unstaking deposit is splitted to several equal parts that become available for withdrawing back after equal periods of time.
 * Instant unstaking (without locking) is possible, but requires paying a fee.
 */
contract FearStaking is AccessControl, Pausable, Withdrawable, ReentrancyGuard {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
     * @dev Emitted when caller stakes FEAR.
     */
    event Staked(address indexed caller, uint256 amount, uint256 epochId);
    /**
     * @dev Emitted when caller unstakes FEAR.
     */
    event Unstaked(address indexed caller, uint256 amount, uint256 reward);
    /**
     * @dev Emitted when caller unstakes FEAR instantly.
     */
    event UnstakedInstantly(address indexed caller, uint256 amount, uint256 reward, uint256 fee);
    /**
     * @dev Emitted when caller claims the reward.
     */
    event RewardClaimed(address indexed caller, uint256 amount);
    /**
     * @dev Emitted when caller withdraws unlocked FEAR.
     */
    event Withdrawn(address indexed caller, uint256 amount);

    /**
     * @dev FEAR token contract interface (ERC20).
     */
    IERC20 public fearContract;

    /**
     * @dev Structure describing staking epoch.
     */
    struct StakingEpoch {
        uint256 id;             // id
        uint256 start;          // start timestamp
        uint256 end;            // end timestamp
        uint256 apr;            // APR (annual percentage rate) in 1/100 of percent, e.g. 1234 means 12.34%
        uint256 lockParts;      // number of parts the stake is splitted for locking on unstake
        uint256 lockPeriod;     // time interval between locked parts become available to withdraw
    }

    /**
     * @dev Structure describing stake.
     */
    struct Stake {
        uint256 epochId;        // id of epoch the staking was done
        uint256 amount;         // amount of FEAR that was staked
        uint256 stakingDate;    // date of staking
    }

    /**
     * @dev Structure describing locked tokens.
     */
    struct LockedTokens {
        uint256 amount;         // amount of FEAR locked
        uint256 unlockDate;     // date when withdrawal will be available
    }

    /**
     * @dev Fee percentage for instant unstaking (in 1/100 of percent, default is 20%)
     */
    uint256 public instantUnstakeFeePercentage = 2000;

    uint256 private percentageDivider = 10000;
    uint256 private nextEpochId = 1;
    address private instantUnstakeFeeReciever;


    uint256[] private epochIds; // array of timewise sorted epoch ids
    mapping (uint256 => StakingEpoch) private epochs;
    mapping (address => Stake[]) private stakes;
    mapping (address => LockedTokens[]) private locks;


    uint256 public totalSentToDaoAmount;
    uint256 private totalStakedAmount;
    uint256 private totalLockedAmount;
    EnumerableSet.AddressSet private fearStakers;
    EnumerableSet.AddressSet private fearLockers;


    constructor(address fearContractAddress) {
        fearContract = IERC20(fearContractAddress);
        instantUnstakeFeeReciever = _msgSender();
    }


    //// PRIVATE SERVICE FUNCITONS

    function _epochAt(uint i) private view returns (StakingEpoch memory) {
        return epochs[epochIds[i]];
    }

    function _getCurrentEpochId() private view returns (uint256) {
        if (epochIds.length == 0)
            return 0;

        for (uint i = epochIds.length - 1; i >= 0; i--) {
            if (_epochAt(i).start <= block.timestamp && block.timestamp <= _epochAt(i).end) // timestamp inside competition start/end
                return epochIds[i];
            if (_epochAt(i).end < block.timestamp) // sorted lookup cutoff - no need to iterate further (everything else will have earlier start/end)
                break;
        }

        return 0;
    }

    function _createEpoch(uint256 id, uint256 start, uint256 end, uint256 apr, uint256 lockParts, uint256 lockPeriod) private {
        epochs[id] = StakingEpoch(id, start, end, apr, lockParts, lockPeriod);

        // adding new index and rebuilding sorted indices (pushing new one down to its position)
        epochIds.push(id);
        for (uint i = epochIds.length - 1; i >= 1; i--) {
            if (_epochAt(i).start < _epochAt(i - 1).end)
                (epochIds[i], epochIds[i - 1]) = (epochIds[i - 1], epochIds[i]);
            else
                break;
        }
    }

    function _cleanStakes() private {
        address user = _msgSender();

        uint stakesLength = stakes[user].length;

        if (stakes[user][stakesLength - 1].amount == 0) {
            for (uint i = stakesLength - 1; i >= 0 ; i--) {
                delete stakes[user][i];
                stakes[user].pop();
                if (i == 0) break;
            }

            fearStakers.remove(user);
        }
    }

    function _cleanLocks() private {
        address user = _msgSender();

        uint locksLength = locks[user].length;
        bool canClean = true;

        for (uint i = 0; i < locksLength; i++) {
            if (locks[user][i].amount != 0) {
                canClean = false;
                break;
            }
        }

        if (canClean) {
            for (uint i = locksLength - 1; i >= 0 ; i--) {
                delete locks[user][i];
                locks[user].pop();
                if (i == 0) break;
            }

            fearLockers.remove(user);
        }
    }

    function _getUserStakeAmount(address user) private view returns (uint256) {
        Stake[] storage userStakes = stakes[user];

        uint256 totalAmount;
        
        for (uint i = 0; i < userStakes.length; i++)
            totalAmount = totalAmount.add(userStakes[i].amount);

        return totalAmount;
    }

    function _getUserRewardAmount(address user) private view returns (uint256) {
        Stake[] storage userStakes = stakes[user];

        uint256 curTimestamp = block.timestamp;
        uint256 totalAmount;

        for (uint i = 0; i < userStakes.length; i++)  {
            Stake memory iStake = userStakes[i];
            StakingEpoch memory epoch = epochs[iStake.epochId];
            uint256 stakingEnd = curTimestamp < epoch.end ? curTimestamp : epoch.end;
            totalAmount = totalAmount.add(iStake.amount.mul(stakingEnd - iStake.stakingDate).mul(epoch.apr).div(percentageDivider).div(365).div(1 days));
        }

        return totalAmount;
    }

    function _getUserLockedAmount(address user) private view returns (uint256) {
        LockedTokens[] storage userLocks = locks[user];

        uint256 totalAmount;

        for (uint i = 0; i < userLocks.length; i++)
            if (userLocks[i].unlockDate > block.timestamp)
                totalAmount = totalAmount.add(userLocks[i].amount);

        return totalAmount;
    }

    function _getUserWithdrawableAmount(address user) private view returns (uint256) {
        LockedTokens[] storage userLocks = locks[user];

        uint256 totalAmount;

        for (uint i = 0; i < userLocks.length; i++)
            if (userLocks[i].unlockDate <= block.timestamp)
                totalAmount = totalAmount.add(userLocks[i].amount);

        return totalAmount;
    }

    function _checkBalance(uint256 threshold) private view {
        uint256 balance = fearContract.balanceOf(address(this));
        require(balance >= threshold, "Contract balance is not enough");
    }

    function _getAllUserStakes(address user) private view returns (Stake[] memory) {
        uint256 counter;
        for (uint i = 0; i < stakes[user].length; i++)
            if (stakes[user][i].amount != 0)
                counter++;

        Stake[] memory result = new Stake[](counter);

        counter = 0;
        for (uint i = 0; i < stakes[user].length; i++)
            if (stakes[user][i].amount != 0) {
                result[counter] = stakes[user][i];
                counter++;
            }

        return result;
    }

    function _getAllUserLocks(address user) private view returns (LockedTokens[] memory) {
        uint256 counter;
        for (uint i = 0; i < locks[user].length; i++)
            if (locks[user][i].amount != 0)
                counter++;

        LockedTokens[] memory result = new LockedTokens[](counter);

        counter = 0;
        for (uint i = 0; i < locks[user].length; i++)
            if (locks[user][i].amount != 0) {
                result[counter] = locks[user][i];
                counter++;
            }

        return result;
    }



    //// PUBLIC FUNCITONS

    /** 
     * @dev Returns current staking epoch.
     */
    function getCurrentStakingEpoch() external view returns (StakingEpoch memory) {
        return epochs[_getCurrentEpochId()];
    }

    /** 
     * @dev Returns total count of stakers.
     */
    function getStakersCount() external view returns (uint256) {
        return fearStakers.length();
    }

    /** 
     * @dev Returns total amount of FEAR staked.
     */
    function getTotalStakedAmount() external view returns (uint256) {
        return totalStakedAmount;
    }

    /** 
     * @dev Returns caller's stake amount.
     */
    function getMyStakeAmount() public view returns (uint256) {
        return _getUserStakeAmount(_msgSender());
    }

    /** 
     * @dev Returns caller's reward amount for current moment.
     */
    function getMyRewardAmount() external view returns (uint256) {
        return _getUserRewardAmount(_msgSender());
    }

    /** 
     * @dev Returns caller's locked tokens amount.
     */
    function getMyLockedAmount() external view returns (uint256) {
        return _getUserLockedAmount(_msgSender());
    }

    /** 
     * @dev Returns caller's withdrawable (unlocked) tokens amount.
     */
    function getMyWithdrawableAmount() external view returns (uint256) {
        return _getUserWithdrawableAmount(_msgSender());
    }

    /** 
     * @dev Returns all caller's stakes.
     */
    function getAllMyStakes() external view returns (Stake[] memory) {
        return _getAllUserStakes(_msgSender());
    }

    /** 
     * @dev Returns all caller's locked tokens info.
     */
    function getAllMyLocks() external view returns (LockedTokens[] memory) {
        return _getAllUserLocks(_msgSender());
    }


    /** 
     * @dev Allows to stake FEAR.
     * @param amount Amount of FEAR to stake.
     * Requirements:
     * - Contract must be unpaused;
     * - There must be active staking epoch;
     * - Caller must have not less FEAR tokens than staking amount;
     * - Caller must allow the contract to operate their FEAR tokens (not less than staking amount).
     * Emits {Staked} event on success.
     */
    function stake(uint256 amount) external whenNotPaused nonReentrant {
        require(amount > 0, "Cannot stake zero");

        uint256 epochId = _getCurrentEpochId();
        require(epochId > 0, "No active epoch");

        address user = _msgSender();

        uint256 userBalance = fearContract.balanceOf(user);
        require(userBalance >= amount, "Insufficient balance");

        uint256 contractAllowance = fearContract.allowance(user, address(this));
        require(contractAllowance >= amount, "Insufficient allowance");

        Stake memory newStake = Stake(epochId, amount, block.timestamp);

        Stake[] storage userStakes = stakes[user];
        userStakes.push(newStake);

        fearStakers.add(user);
        totalStakedAmount = totalStakedAmount.add(amount);

        fearContract.transferFrom(user, address(this), amount);

        emit Staked(user, amount, epochId);
    }

    /** 
     * @dev Allows to stake back FEAR that has been unstaken but still stays at the contract.
     * Requirements:
     * - Contract must be unpaused;
     * - There must be active staking epoch;
     * - There must be some unstaken user's FEAR at the contract (locked or available to withdraw);
     * Emits {Staked} event on success.
     */
    function stakeBack() external whenNotPaused nonReentrant {
        uint256 epochId = _getCurrentEpochId();
        require(epochId > 0, "No active epoch");

        address user = _msgSender();

        LockedTokens[] storage userLocks = locks[user];
        require(userLocks.length > 0, "No user's FEAR at the contract");

        uint256 amount;
        for (uint i = 0; i < userLocks.length; i++) {
            amount = amount.add(userLocks[i].amount);
            userLocks[i].amount = 0;
        }

        Stake memory newStake = Stake(epochId, amount, block.timestamp);

        Stake[] storage userStakes = stakes[user];
        userStakes.push(newStake);

        fearStakers.add(user);
        totalStakedAmount = totalStakedAmount.add(amount);
        totalLockedAmount = totalLockedAmount.sub(amount);
        _cleanLocks();

        emit Staked(user, amount, epochId);
    }

    /** 
     * @dev Allows to unstake FEAR.
     * Reward is transferred to caller's address immediately.
     * Unstaked tokens are locked according to staking epoch settings.
     * @param amount Amount of FEAR to unstake.
     * Requirements:
     * - Contract must be unpaused;
     * - Amount to unstake must be less or qeual to caller's total staked amount.
     * Emits {RewardClaimed} and {Unstaked} events on success.
     */
    function unstake(uint256 amount) external whenNotPaused nonReentrant {
        require(amount > 0, "Cannot unstake zero");
        require(amount <= getMyStakeAmount(), "Amount exceeds total stake");

        address user = _msgSender();
        uint256 curTimestamp = block.timestamp;
        uint256 leftToUnstake = amount;
        uint256 totalReward;

        uint256 prevLockParts;
        uint256 prevLockPeriod;
        LockedTokens[] memory locksBuffer = new LockedTokens[](0);

        for (uint i = 0; i < stakes[user].length; i++) {
            Stake storage iStake = stakes[user][i];

            if (iStake.amount > 0) {
                StakingEpoch memory epoch = epochs[iStake.epochId];

                if (prevLockParts != epoch.lockParts || prevLockPeriod != epoch.lockPeriod) {

                    // flushing locks buffer
                    uint bufferLength = locksBuffer.length;

                    if (bufferLength > 0) {
                        for (uint k = 0; k < bufferLength; k++)
                            locks[user].push(locksBuffer[k]);

                        for (uint k = bufferLength - 1; k >= 0 ; k--)
                            delete locksBuffer[k];
                    }
                    
                    locksBuffer = new LockedTokens[](epoch.lockParts);

                    for (uint k = 0; k < epoch.lockParts; k++)
                        locksBuffer[k] = LockedTokens(0, curTimestamp + (k + 1) * epoch.lockPeriod);

                    prevLockParts = epoch.lockParts;
                    prevLockPeriod = epoch.lockPeriod;
                }

                uint256 unstakeAmount = leftToUnstake < iStake.amount ? leftToUnstake : iStake.amount;
                uint256 stakingEnd = curTimestamp < epoch.end ? curTimestamp : epoch.end;
                
                for (uint j = 0; j < epoch.lockParts; j++)
                    locksBuffer[j].amount = locksBuffer[j].amount.add(unstakeAmount / epoch.lockParts);

                iStake.amount = iStake.amount.sub(unstakeAmount);
                leftToUnstake = leftToUnstake.sub(unstakeAmount);
                totalReward = totalReward.add(unstakeAmount.mul(stakingEnd - iStake.stakingDate).mul(epoch.apr).div(percentageDivider).div(365).div(1 days));

                if (leftToUnstake == 0)
                    break;
            }
        }

        for (uint k = 0; k < locksBuffer.length; k++)
            locks[user].push(locksBuffer[k]);

        fearLockers.add(user);
        totalStakedAmount = totalStakedAmount.sub(amount);
        totalLockedAmount = totalLockedAmount.add(amount);
        _cleanStakes();
        _checkBalance(totalReward);

        if (totalReward > 0) {
            fearContract.transfer(user, totalReward);
            emit RewardClaimed(user, totalReward);
        }

        emit Unstaked(user, amount, totalReward);
    }

    /** 
     * @dev Allows to unstake FEAR without locking.
     * Reward is transferred to caller's address immediately.
     * Unstaked tokens minus instant unstake fee are transferred to caller's address immediately.
     * Instant unstaking fee is transferred to fee collector's address.
     * @param amount Amount of FEAR to unstake.
     * Requirements:
     * - Contract must be unpaused;
     * - Amount to unstake must be less or qeual to caller's total staked amount.
     * Emits {RewardClaimed} and {UnstakedInstantly} events on success.
     */
    function instantUnstake(uint256 amount) external whenNotPaused nonReentrant {
        require(amount > 0, "Cannot unstake zero");
        require(amount <= getMyStakeAmount(), "Amount exceeds total stake");

        address user = _msgSender();
        uint256 curTimestamp = block.timestamp;
        uint256 leftToUnstake = amount;
        uint256 totalReward;

        for (uint i = 0; i < stakes[user].length; i++) {
            Stake storage iStake = stakes[user][i];

            if (iStake.amount > 0) {
                StakingEpoch memory epoch = epochs[iStake.epochId];

                uint256 unstakeAmount = leftToUnstake < iStake.amount ? leftToUnstake : iStake.amount;
                uint256 stakingEnd = curTimestamp < epoch.end ? curTimestamp : epoch.end;
                
                iStake.amount = iStake.amount.sub(unstakeAmount);
                leftToUnstake = leftToUnstake.sub(unstakeAmount);
                totalReward = totalReward.add(unstakeAmount.mul(stakingEnd - iStake.stakingDate).mul(epoch.apr).div(percentageDivider).div(365).div(1 days));

                if (leftToUnstake == 0)
                    break;
            }
        }

        uint256 instantUnstakeFee = amount.mul(instantUnstakeFeePercentage).div(percentageDivider);
        uint256 amountMinusFee = amount.sub(instantUnstakeFee);

        totalStakedAmount = totalStakedAmount.sub(amount);
        totalSentToDaoAmount = totalSentToDaoAmount.add(instantUnstakeFee);
        _cleanStakes();
        _checkBalance(totalReward + amount);

        if (totalReward > 0) {
            fearContract.transfer(user, totalReward);
            emit RewardClaimed(user, totalReward);
        }

        fearContract.transfer(user, amountMinusFee);
        fearContract.transfer(instantUnstakeFeeReciever, instantUnstakeFee);

        emit UnstakedInstantly(user, amount, totalReward, instantUnstakeFee);
    }

    /** 
     * @dev Allows to claim the reward caller gets at the current moment.
     * Reward is transferred to caller's address immediately.
     * Requirements:
     * - Contract must be unpaused.
     * Emits {RewardClaimed} event on success.
     */
    function claimReward() external whenNotPaused nonReentrant {
        address user = _msgSender();
        uint256 curTimestamp = block.timestamp;
        uint256 totalReward;

        require(_getUserStakeAmount(user) > 0, "Nothing is staked");

        for (uint i = 0; i < stakes[user].length; i++) {
            Stake storage iStake = stakes[user][i];

            if (iStake.amount > 0) {
                StakingEpoch memory epoch = epochs[iStake.epochId];
                uint256 newStakingDate = curTimestamp < epoch.end ? curTimestamp : epoch.end;
                totalReward = totalReward.add(iStake.amount.mul(newStakingDate - iStake.stakingDate).mul(epoch.apr).div(percentageDivider).div(365).div(1 days));

                iStake.stakingDate = newStakingDate; // reward is claimed until the current date, new staking date = now
            }
        }

        _checkBalance(totalReward);

        if (totalReward > 0) {
            fearContract.transfer(user, totalReward);
            emit RewardClaimed(user, totalReward);
        }
    }

    /** 
     * @dev Allows to withdraw unlocked tokens.
     * Requirements:
     * - Contract must be unpaused.
     * Emits {Withdrawn} event on success.
     */
    function withdrawUnlocked() external whenNotPaused nonReentrant {
        address user = _msgSender();
        LockedTokens[] storage userLocks = locks[user];

        require(_getUserWithdrawableAmount(user) > 0, "Nothing to withdraw");

        uint256 totalAmount;

        for (uint i = 0; i < userLocks.length; i++)
            if (userLocks[i].unlockDate <= block.timestamp) {
                totalAmount = totalAmount.add(userLocks[i].amount);
                userLocks[i].amount = 0;
            }

        totalLockedAmount = totalLockedAmount.sub(totalAmount);
        _cleanLocks();
        _checkBalance(totalAmount);

        if (totalAmount > 0)
            fearContract.transfer(user, totalAmount);

        emit Withdrawn(user, totalAmount);
    }



    //// ADMIN FUNCTIONS
   
    function addStakingEpoch(uint256 start, uint256 end, uint256 apr, uint256 lockParts, uint256 lockPeriod) external onlyRole(ADMIN_ROLE) {
        require(start < end, "start must be less than end");
        require(end > block.timestamp, "cannot add passed epoch");
        require(apr > 0, "apr must be greater than zero");

        if (epochIds.length > 0) {
            for (uint i = epochIds.length - 1; i >= 0; i--) {
                if ((_epochAt(i).start <= start && start <= _epochAt(i).end)
                    || (_epochAt(i).start <= end && end <= _epochAt(i).end)
                    || (_epochAt(i).start >= start && _epochAt(i).end <= end)) // new competition covers existing one
                    revert("Intersecting start/end found");
                if (_epochAt(i).end < start) // sorted lookup cutoff
                    break;
            }
        }

        _createEpoch(nextEpochId, start, end, apr, lockParts, lockPeriod);
        nextEpochId++;
    }

    function removeStakingEpoch(uint256 id) external onlyRole(ADMIN_ROLE) {
        require(epochs[id].id > 0, "Epoch not found");
        require(epochs[id].start > block.timestamp, "Epoch is active or passed");

        uint epochIdIndex;
        for (uint i = epochIds.length - 1; i >= 1; i--) {
            if (epochIds[i] == id) {
                epochIdIndex = i;
                break;
            }
        }

        for (uint i = epochIdIndex; i < epochIds.length - 1; i++) {
            epochIds[i] = epochIds[i + 1];
        }

        epochIds.pop();
        delete epochs[id];
    }

    function getStakingEpochIds() external view onlyRole(ADMIN_ROLE) returns (uint256[] memory) {
        return epochIds;
    }

    function getStakingEpoch(uint256 id) external view onlyRole(ADMIN_ROLE) returns (StakingEpoch memory) {
        return epochs[id];
    }

    function setInstantUnstakeParams(uint256 feePercentage, address feeReciever) external onlyRole(ADMIN_ROLE) {
        require(feeReciever != address(0), "Cannot use zero address");

        instantUnstakeFeePercentage = feePercentage;
        instantUnstakeFeeReciever = feeReciever;
    }


    function getFearStakers() external view onlyRole(MANAGER_ROLE) returns (address[] memory) {
        address[] memory stakers = new address[](fearStakers.length());

        for (uint i = 0; i < stakers.length; i++)
            stakers[i] = fearStakers.at(i);

        return stakers;
    }

    function getFearLockers() external view onlyRole(MANAGER_ROLE) returns (address[] memory) {
        address[] memory lockers = new address[](fearLockers.length());

        for (uint i = 0; i < lockers.length; i++)
            lockers[i] = fearLockers.at(i);

        return lockers;
    }

    function getUserStakeAmount(address user) external view onlyRole(MANAGER_ROLE) returns (uint256) {
        return _getUserStakeAmount(user);
    }

    function getUserRewardAmount(address user) external view onlyRole(MANAGER_ROLE) returns (uint256) {
        return _getUserRewardAmount(user);
    }

    function getUserLockedAmount(address user) external view onlyRole(MANAGER_ROLE) returns (uint256) {
        return _getUserLockedAmount(user);
    }

    function getUserWithdrawableAmount(address user) external view onlyRole(MANAGER_ROLE) returns (uint256) {
        return _getUserWithdrawableAmount(user);
    }

    function getAllUserStakes(address user) external view onlyRole(MANAGER_ROLE) returns (Stake[] memory) {
        return _getAllUserStakes(user);
    }

    function getAllUserLocks(address user) external view onlyRole(MANAGER_ROLE) returns (LockedTokens[] memory) {
        return _getAllUserLocks(user);
    }

    function getTotalLockedAmount() external view onlyRole(MANAGER_ROLE) returns (uint256) {
        return totalLockedAmount;
    }

    function getTotalRewardAmount() external view onlyRole(MANAGER_ROLE) returns (uint256) {
        uint256 totalReward;
        for (uint i = 0; i < fearStakers.length(); i++)
            totalReward = totalReward.add(_getUserRewardAmount(fearStakers.at(i)));
        
        return totalReward;
    }
}