/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


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

// File: @openzeppelin/contracts/token/ERC1155/IERC1155.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

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
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

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
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

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
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


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
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/utils/Strings.sol


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

// File: @openzeppelin/contracts/access/IAccessControl.sol


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/AccessControl.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

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

// File: contracts/Helperv3.sol


pragma solidity ^0.8.4;







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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
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
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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

library Helperv3 {

    enum CONTRACT_TYPE {
        ERC20,
        ERC1155
    }


    using SafeMath for uint256;
    struct RATE {
        uint256 ori;
        uint256 dest;
        CONTRACT_TYPE ctype;
        bool isEnable;
    }



    function calcQTY(uint256 amount_ori,uint256 qty_ori,uint256 qty_dest) internal pure returns(uint256 qty,uint256 remainder){
        
        if(qty_ori==0 || qty_dest==0 || amount_ori==0){
            return (0,0);
        }

        qty = amount_ori.mul(qty_dest).div(qty_ori);

        remainder = amount_ori.sub( qty.mul(qty_ori).div(qty_dest));


    }



    function calcConvert(mapping(address => RATE) storage cntrRatesInfo,address token,uint256 amount ) internal view returns(uint256 qty,uint256 rem_token){

        if(token==address(0) || !Address.isContract(token)) return (0,0);

        RATE storage rate = cntrRatesInfo[token];

        if(rate.ori==0 || rate.dest==0) return (0,0);

        (qty,rem_token) = calcQTY(amount,rate.ori,rate.dest);

    }


    function calcConvertBatch(mapping(address => RATE) storage cntrRatesInfo,address[] memory scontracts,  uint256[] memory amounts) 
        internal 
        view 
        returns(uint256 )
        {

        require(scontracts.length == amounts.length, "C3S: scontracts and amounts length mismatch");


        uint256 amAcum=0;
        RATE memory rateAc;

        for (uint256 i = 0; i < scontracts.length; ++i) {

            require(scontracts[i] != address(0), "C3S: batch calcConvertBatch query for the zero address");
            require(Address.isContract(scontracts[i])  , "C3S: batch calcConvertBatch query for not contract address");
            require(amounts[i] != 0, "C3S: batch calcConvertBatch has 0 amount");

            RATE storage rate = cntrRatesInfo[scontracts[i]];

            require(rate.ori!=0 && rate.dest!=0, "C3S: batch calcConvertBatch query not found contract address");
         
            if(i==0){
                rateAc=rate;
            }else{
                require(rate.ori==rateAc.ori && rate.dest==rateAc.dest, "C3S: batch calcConvertBatch query not equal rates contract address");
            }

            amAcum=amAcum.add(amounts[i]);

        }

        (uint256 qty,uint256 rem_token) = calcQTY(amAcum,rateAc.ori,rateAc.dest);

        require(qty!=0 && rem_token==0, "C3S: batch calcConvertBatch query not exact match total sum amount with rate ");
        
        return qty;

    }


    function calcConvertTWO(
        mapping(address => RATE) storage cntrRatesInfo,
        address tokenPrin,
        uint256 amountPrin,
        uint256 amountSec,
        uint256 conv_ori,
        uint256 conv_dest
         ) internal view returns(uint256 qty,uint256 rem_tokenPrim,uint256 rem_tokenSec){

        //conv Sec a Prin
       uint256 qty_cPrin=0;
       rem_tokenPrim=0;

       (qty_cPrin,rem_tokenSec) = calcQTY(amountSec,conv_ori,conv_dest);

        uint256 qtyPrin =amountPrin.add(qty_cPrin);

        uint256 remain =0;

       ( qty,remain) =calcConvert(cntrRatesInfo,tokenPrin,qtyPrin );


    // conv vuelto to sec
        uint256 qty_sec=0;
        uint256 rem_tokenSec2=0;
       (qty_sec,rem_tokenSec2) = calcQTY(remain,conv_dest,conv_ori);

       rem_tokenSec = rem_tokenSec.add(qty_sec).add(rem_tokenSec2);

       if(rem_tokenSec > amountSec){

            uint256 diffToConvPrin=rem_tokenSec.sub(amountSec);
            //conv vuelto to prin
            (rem_tokenPrim,rem_tokenSec2) = calcQTY(diffToConvPrin,conv_ori,conv_dest);

            rem_tokenSec = amountSec;


       }

    }




}

// File: contracts/Crowdsale3Stagesv3.sol


pragma solidity ^0.8.4;








/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC_20 {
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
    function allowance(address owner, address spender)
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

    function mint(address to, uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;
}



interface IERC1155SP is  IERC1155{
    
    function allowedProxies(address account) external view returns(bool);
    function maxSupply()external view returns(uint);
    function totalMinted()external view returns(uint);
    function owner() external view returns(address);
    function mint(address account, uint256 id, uint256 amount, bytes memory data) external;
    function tokenTypes(uint _tokenId) external view returns(
            string memory,
            bool ,
            uint256 ,
            uint256 );
}




// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}






contract Crowdsale3stagesv3 is Pausable, AccessControl {
    using SafeMath for uint256;

    

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    mapping(address => Helperv3.RATE) public cntrRatesInfo;

    Helperv3.RATE public cntrEthRateInfo;

    mapping(address => mapping(uint256 => bool)) public isIdEnabled;
    mapping(uint256 => bool) public isIdEthEnabled;

    IERC1155SP public WMP;
    IERC_20 public WOOP;
    IERC_20 public WST;

    address public fundraiser;


    event Saled(uint sp_id,address indexed account,uint256 wmpQty,uint256 toDebitWST,uint256 toDebitWOOP);
    event TkSaled(address indexed account,uint sp_id,uint tk_id,uint256 qty,uint256 amountF1 );
    event ETHSaled(address indexed account,uint sp_id,uint256 qty,uint256 amountdeb );
    event TkSaledBatch(address indexed account,uint sp_id,uint256 qty,uint256 amountdeb);

    constructor(
        IERC_20 _woop,
        IERC_20 _wst,
        IERC1155SP _wmp,
        address _fundraiser


    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        fundraiser=_fundraiser;
        WMP = _wmp;
        WOOP= _woop;
        WST= _wst;


        //WST + WOOP  -> Mythical id 2
        //5mil woop o 5 WST combinados=1 WMP Mythical id 2
        //1WST =1000 woop
        setRate(Helperv3.CONTRACT_TYPE.ERC20, address(_woop),  5000 ether, 1,true,2);
        setRate(Helperv3.CONTRACT_TYPE.ERC20, address(_wst),  5 ether, 1,true,2);
        //BNB o ETH x WMP: disabled
        setETHRate(  1 ether ,1,false,2);



        //F1 Dorado ->  Mythical id 2
        //1 F1 serie dorado te da 3 WMP
        // http://mainnet.woonkly.com/collections/5e450addcb464325fc4e33e754fbc934
        //0x13a86461126a33C544CdEDa5976192999da1d124
        setRate(Helperv3.CONTRACT_TYPE.ERC1155, 0x13a86461126a33C544CdEDa5976192999da1d124,  1, 3,true,2);


        //F1 combinaciones -> Mythical id2 
        //10 coches F1 (de cualquier color) = te da 1 WMP
        //0x3f7a5b9D37Bce9699dd138880eb6b81AB857C120
        setRate(Helperv3.CONTRACT_TYPE.ERC1155, 0x3f7a5b9D37Bce9699dd138880eb6b81AB857C120,  10, 1,true,2);
        //0x494286bf39eabbf3c92f05df114182fdc68a73c5
        setRate(Helperv3.CONTRACT_TYPE.ERC1155, 0x494286bf39eaBBF3C92f05df114182FdC68A73c5,  10, 1,true,2);
        //0xc1f89d6216020af9750cf1811a334728207d6a0b
        setRate(Helperv3.CONTRACT_TYPE.ERC1155, 0xc1f89d6216020af9750Cf1811A334728207D6A0b,  10, 1,true,2);
        //0x57E1AAB317204531EE5Cf995a502d23DFC7DD932
        setRate(Helperv3.CONTRACT_TYPE.ERC1155, 0x57E1AAB317204531EE5Cf995a502d23DFC7DD932,  10, 1,true,2);
        //0xcf8016C695DF8789A1D148b3418aFE4Eca24E70a
        setRate(Helperv3.CONTRACT_TYPE.ERC1155, 0xcf8016C695DF8789A1D148b3418aFE4Eca24E70a,  10, 1,true,2);
        //0xe0d88573999ff7141092eCCDe50C6D808657F51b
        setRate(Helperv3.CONTRACT_TYPE.ERC1155, 0xe0d88573999ff7141092eCCDe50C6D808657F51b,  10, 1,true,2);
        //0x776B4e641700edEFcC4D8f7d127A51ea7DA5FA54
        setRate(Helperv3.CONTRACT_TYPE.ERC1155, 0x776B4e641700edEFcC4D8f7d127A51ea7DA5FA54,  10, 1,true,2);
        //0xC706d169eFd96581988Ffa6CB217E9430388DB93
        setRate(Helperv3.CONTRACT_TYPE.ERC1155, 0xC706d169eFd96581988Ffa6CB217E9430388DB93,  10, 1,true,2);







    }



    function changeFundraiser(address newfundraiser)
        external
        onlyRole(ADMIN_ROLE)
    {
        require(fundraiser != address(0), "C3S: Invalid address");

        fundraiser = newfundraiser;
        
    }



    function setRate(Helperv3.CONTRACT_TYPE ctype, address scontract,  uint256 origin,uint256 destination,bool enable,uint256 id_nft)
        public
        onlyRole(ADMIN_ROLE)
    {
        require(origin != 0, "C3S: Invalid origin");
        require(destination != 0, "C3S: Invalid destination");
        require(scontract != address(0), "C3S: Invalid address");
        require(Address.isContract(scontract), "C3S: Invalid contract address");

        Helperv3.RATE storage rate = cntrRatesInfo[scontract];
        rate.ori=origin;
        rate.dest=destination;
        rate.ctype = ctype;
        rate.isEnable=enable;

        isIdEnabled[scontract][id_nft]=true;

    }




    function setETHRate(  uint256 origin,uint256 destination,bool enable,uint256 id_nft)
        public
        onlyRole(ADMIN_ROLE)
    {
        require(origin != 0, "C3S: Invalid origin");
        require(destination != 0, "C3S: Invalid destination");

        
        cntrEthRateInfo.ori=origin;
        cntrEthRateInfo.dest=destination;
        cntrEthRateInfo.isEnable=enable;

        isIdEthEnabled[id_nft]=true;


    }




    function setSCActive( address scontract,bool enable)
        public
        onlyRole(ADMIN_ROLE)
    {
        require(scontract != address(0), "C3S: Invalid address");
        require(Address.isContract(scontract), "C3S: Invalid contract address");

        Helperv3.RATE storage rate = cntrRatesInfo[scontract];

        require(rate.ori != 0, "C3S: contract not found!");
        rate.isEnable=enable;


    }


    function setETHActive(bool enable)
        public
        onlyRole(ADMIN_ROLE)
    {
        cntrEthRateInfo.isEnable=enable;
    }




    function setNFTActive( address scontract,uint256 id_nft,bool enable)
        public
        onlyRole(ADMIN_ROLE)
    {
        require(scontract != address(0), "C3S: Invalid address");
        require(Address.isContract(scontract), "C3S: Invalid contract address");
        require(cntrRatesInfo[scontract].isEnable==true, "C3S: Contract is disabled!");

        isIdEnabled[scontract][id_nft]=enable;

    }


    function setNFTETHActive( uint256 id_nft,bool enable)
        public
        onlyRole(ADMIN_ROLE)
    {
        require(cntrEthRateInfo.isEnable==true, "C3S: ETH is disabled!");

        isIdEthEnabled[id_nft]=enable;

    }


    function getRateInfo(address scontract) external view returns(Helperv3.RATE memory rate){
        rate=cntrRatesInfo[scontract];
    } 

    function getETHRateInfo() external view returns(Helperv3.RATE memory rate){
        rate=cntrEthRateInfo;
    } 



    function isSCEnable(address scontract) public view returns(bool){
        return cntrRatesInfo[scontract].isEnable ;
    } 

    function isETHEnable() public view returns(bool){
        return cntrEthRateInfo.isEnable ;
    } 


    function isNFTEnable(address scontract,uint256 id_nft) public view returns(bool){
        return (cntrRatesInfo[scontract].isEnable && isIdEnabled[scontract][id_nft]  );
    } 

    function isNFTETHEnable(uint256 id_nft) public view returns(bool){
        return (cntrEthRateInfo.isEnable && isIdEthEnabled[id_nft]  );
    } 





    function calcConvertBatch(address[] memory scontracts,  uint256[] memory amounts) 
        public 
        view 
        returns(uint256 )
        {

        return Helperv3.calcConvertBatch(cntrRatesInfo, scontracts,  amounts) ;   

    }


    function crowdsale1stage(uint256 amountWST,uint256 amountWOOP,uint256 sp_id,bytes memory data) 
            external whenNotPaused
            returns(uint256 qty,uint256 rem_tokenPrim,uint256 rem_tokenSec){

        require( WMP.allowedProxies(address(this)) || WMP.owner()==address(this)  ,"C3S: not allowed to mint!");

        require(isNFTEnable(address(WOOP),sp_id),"C3S: Crowdsale WOOP is disabled!" );    

        require( isNFTEnable(address(WST),sp_id),"C3S: Crowdsale WST is disabled!" );    

        (,bool isenable,,)=WMP.tokenTypes(sp_id);
        require(isenable == true, "C3S:minting is not allowed for this token id");

        require(amountWST>0 || amountWOOP>0,"C3S: invalid amounts" );    


        (qty, rem_tokenPrim, rem_tokenSec)=Helperv3.calcConvertTWO(
                    cntrRatesInfo,
                    address(WST),
                    amountWST,
                    amountWOOP,
                    1000 ether,
                    1 ether
                    ) ;

         require(qty>0 ,"C3S: insufficient funds!");
         uint newMinted = WMP.totalMinted() + qty;
         require(newMinted <= WMP.maxSupply(), "C3S:supply has run out");


         uint256 toDebitWST = rem_tokenPrim>0 ? amountWST.sub(rem_tokenPrim)  :  amountWST;
         uint256 toDebitWOOP = rem_tokenSec>0 ? amountWOOP.sub(rem_tokenSec)  :  amountWOOP;

        if( toDebitWST > 0 ){
            require(
                WST.balanceOf(_msgSender()) >= toDebitWST,
                "C3S: insufficient WST funds! "
            );

            require(
                WST.allowance(_msgSender(), address(this)) >= toDebitWST,
                "C3S: insufficient WST allowance! "
            );
        }    


        if( toDebitWOOP > 0 ){
            require(
                WOOP.balanceOf(_msgSender()) >= toDebitWOOP,
                "C3S: insufficient WOOP funds! "
            );

            require(
                WOOP.allowance(_msgSender(), address(this)) >= toDebitWOOP,
                "C3S: insufficient WOOP allowance! "
            );
        }    

        if( toDebitWST > 0 ){
            TransferHelper.safeTransferFrom(
                address(WST),
                _msgSender(),
                address(fundraiser),
                toDebitWST
            );
        }


        if( toDebitWOOP > 0 ){
            TransferHelper.safeTransferFrom(
                address(WOOP),
                _msgSender(),
                address(fundraiser),
                toDebitWOOP
            );
        }

        WMP.mint(_msgSender(), sp_id, qty,  data);
       

        emit Saled(sp_id,_msgSender(),qty,toDebitWST,toDebitWOOP );

    }


    function crowdsale2stage(address scontract,uint256 amountF1,uint256 tk_id,uint256 sp_id,bytes memory data) 
            public whenNotPaused
            returns(uint256 qty,uint256 rem_token){

        require( WMP.allowedProxies(address(this)) || WMP.owner()==address(this)  ,"C3S: not allowed to mint!");

        (,bool isenable,,)=WMP.tokenTypes(sp_id);
        require(isenable == true, "C3S:minting is not allowed for this token id");

        require(amountF1>0,"C3S: invalid amount" );    

        require(Address.isContract(scontract),"C3S: invalid scontract" );    

        Helperv3.RATE storage rate = cntrRatesInfo[scontract];

        require (rate.ori!=0 && rate.dest!=0,"C3S: invalid scontract (1)" );    

        require(isNFTEnable(scontract,sp_id) ,"C3S: Crowdsale is disabled! for this contract" );    


        (qty, rem_token)=Helperv3.calcConvert(cntrRatesInfo,scontract,amountF1 ) ;

         require(qty>0 ,"C3S: insufficient funds!");
         uint newMinted = WMP.totalMinted() + qty;
         require(newMinted <= WMP.maxSupply(), "C3S:supply has run out");


        IERC1155 f1=(IERC1155)(scontract);

        require(f1.balanceOf(_msgSender(),tk_id) >= amountF1 ,"C3S: insufficient scontract funds!");
        require(f1.isApprovedForAll(_msgSender(), address(this)), "C3S: caller is not owner nor approved"  );

        uint256 amountdeb = rem_token>0 ? amountF1.sub(rem_token) : amountF1;

        f1.safeTransferFrom(
             _msgSender(),
             address(fundraiser),
             tk_id,
             amountdeb,
            data
        );



        WMP.mint(_msgSender(), sp_id, qty,  data);


        emit TkSaled(_msgSender(),sp_id,tk_id,qty,amountdeb );

    }



    function crowdsaleETHstage(uint256 sp_id,bytes memory data) 
            payable
            external whenNotPaused
            returns(uint256 qty,uint256 rem_token){

        require( WMP.allowedProxies(address(this)) || WMP.owner()==address(this)  ,"C3S: not allowed to mint!");

        (,bool isenable,,)=WMP.tokenTypes(sp_id);
        require(isenable == true, "C3S:minting is not allowed for this token id");

        require(isNFTETHEnable(sp_id) ,"C3S: Crowdsale is disabled! NFT Id for this ETH" );    

        (qty,rem_token) = Helperv3.calcQTY(msg.value ,cntrEthRateInfo.ori,cntrEthRateInfo.dest);

         require(qty>0 ,"C3S: insufficient funds!");
         uint newMinted = WMP.totalMinted() + qty;
         require(newMinted <= WMP.maxSupply(), "C3S:supply has run out");

        uint256 amountdeb = rem_token>0 ? msg.value.sub(rem_token) : msg.value;

        WMP.mint(_msgSender(), sp_id, qty,  data);

        if(rem_token>0){

            payable(msg.sender).transfer(rem_token);
        }


        emit ETHSaled(_msgSender(),sp_id,qty,amountdeb );

    }




    function crowdsaleStageBatch(address[] memory scontracts,  uint256[] memory amounts, uint256[] memory tk_ids, uint256 sp_id,bytes memory data) 
        external whenNotPaused        {

        require( WMP.allowedProxies(address(this)) || WMP.owner()==address(this)  ,"C3S: not allowed to mint!");
        require(scontracts.length == tk_ids.length, "C3S: scontracts and tk_ids length mismatch");    

        uint256 qty=calcConvertBatch( scontracts,  amounts);
        require(qty!=0,"C3S:invalid conversion!");     

       for (uint256 i = 0; i < scontracts.length; ++i) {

            (,bool isenable,,)=WMP.tokenTypes(sp_id);
            require(isenable == true, "C3S:minting is not allowed for this token id");
            require(isNFTEnable(scontracts[i],sp_id) ,"C3S: Crowdsale is disabled! for this contract" );               
           
            IERC1155 f1=(IERC1155)(scontracts[i]);

            require(f1.balanceOf(_msgSender(),tk_ids[i]) >= amounts[i] ,"C3S: insufficient scontract funds!");
            require(f1.isApprovedForAll(_msgSender(), address(this)), "C3S: caller is not owner nor approved"  );

       }

        uint256 amountdeb=0;

        for (uint256 i = 0; i < scontracts.length; ++i) {

            IERC1155 f1=(IERC1155)(scontracts[i]);

            amountdeb=amountdeb.add(amounts[i]);

            f1.safeTransferFrom(
                _msgSender(),
                address(fundraiser),
                tk_ids[i],
                amounts[i],
                data
            );
        }

        WMP.mint(_msgSender(), sp_id, qty,  data);


        emit TkSaledBatch(_msgSender(),sp_id,qty,amountdeb );


    }



    function pause() public onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(ADMIN_ROLE) {
        _unpause();
    }


    function calcQTY(uint256 amount_ori,uint256 qty_ori,uint256 qty_dest) public pure returns(uint256 qty,uint256 remainder){
        
            (qty,remainder) = Helperv3.calcQTY(amount_ori,qty_ori,qty_dest);

    }


    function calcConvert(address token,uint256 amount ) external view returns(uint256 qty,uint256 rem_token){

        return Helperv3.calcConvert( cntrRatesInfo, token, amount );

    }


    function calcConvertTWO(
        address tokenPrin,
        uint256 amountPrin,
        uint256 amountSec,
        uint256 conv_ori,
        uint256 conv_dest
         ) external view returns(uint256 qty,uint256 rem_tokenPrim,uint256 rem_tokenSec){

          return Helperv3.calcConvertTWO(cntrRatesInfo, tokenPrin, amountPrin, amountSec, conv_ori, conv_dest);

     }




}