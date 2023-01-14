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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
// Revision: 2023-1-13
// version 1.0.0

/// OpenZeppelin dependencies
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @dev dependencies
import "./IHorseStruct.sol";

/// @title HorseAncestry - Managing horse ancestry
/// @notice - DVCC Technology
contract HorseAncestry is AccessControl, HorseStruct {
  struct AncestryRate {
    uint32 appearType;
    uint32 qualityLimit;
    uint32 appearWeight;
  }

  struct AncestryConf {
    uint32 inheritChance;
    uint32 speedGear;
    uint32 enduranceGear;
    uint32 burstGear;
    uint32 stableGear;
    uint32 maintainCost;
  }

  struct BaseAttrTLevelRates {
    uint32[] speedGear;
    uint32[] enduranceGear;
    uint32[] burstGear;
    uint32[] stableGear;
  }

  struct ExtendAttrTLevelRates {
    uint32[] speedGear;
    uint32[] enduranceGear;
    uint32[] burstGear;
    uint32[] stableGear;
  }

  struct RandomBonus {
    uint32 min;
    uint32 max;
  }

  bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

  mapping(uint32 => AncestryRate) ancestryRateMapping;
  mapping(uint32 => AncestryConf) ancestryConfMapping;
  mapping(uint32 => BaseAttrTLevelRates) baseAttrRatesMapping;
  mapping(uint32 => ExtendAttrTLevelRates) extendAttrRatesMapping;
  mapping(uint32 => mapping(uint32 => mapping(uint32 => RandomBonus))) baseBonusMapping;
  mapping(uint32 => mapping(uint32 => mapping(uint32 => RandomBonus))) extendBonusMapping;
  mapping(uint32 => HorseAttribute) baseAttributes;
  uint32 totalAncestryLength;
  uint32 private constant RD = 0x2710;
  uint8 private tCoef = 2;

  /// @custom:log errors
  error InternalError();

  constructor() {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _grantRole(MANAGER_ROLE, _msgSender());
  }

  /// @custom:base - view horse data sources
  // get each ancestry's base/extend T level rates
  function getAncestryAttrByAncestryId(
    uint32 id
  ) external view returns (BaseAttrTLevelRates memory, ExtendAttrTLevelRates memory) {
    return (baseAttrRatesMapping[id], extendAttrRatesMapping[id]);
  }

  // get each ancestry's rate and T level upper limit
  function getAncestryByAncestryId(uint32 id) external view returns (AncestryRate memory, AncestryConf memory) {
    return (ancestryRateMapping[id], ancestryConfMapping[id]);
  }

  // get each quality's base attrs
  function getBaseAttributes(uint32 quality) external view returns (HorseAttribute memory) {
    return baseAttributes[quality];
  }

  // get each quality's specific gear's specific tLevel's min/max bonus
  function getBonusMinMax(
    uint32 id,
    uint32 attrType,
    uint8 tLevel
  ) external view returns (RandomBonus memory, RandomBonus memory) {
    return (baseBonusMapping[id][attrType][tLevel - 1], extendBonusMapping[id][attrType][tLevel - 1]);
  }

  /// @custom:note - GM functions
  function addAncestryBonus(
    uint32 id,
    uint32 attrType,
    uint32[] memory bMins,
    uint32[] memory bMaxs,
    uint32[] memory eMins,
    uint32[] memory eMaxs
  ) public onlyRole(MANAGER_ROLE) {
    for (uint32 i = 0; i < bMins.length; i++) {
      RandomBonus memory _bBonus = RandomBonus(bMins[i], bMaxs[i]);
      RandomBonus memory _eBonus = RandomBonus(eMins[i], eMaxs[i]);
      baseBonusMapping[id][attrType][i] = _bBonus;
      extendBonusMapping[id][attrType][i] = _eBonus;
    }
  }

  function addAncestryBonusBatch(
    uint32[] memory ids,
    uint32[] memory attrTypes,
    uint32[][][] memory bMinsMatrix,
    uint32[][][] memory bMaxsMatrix,
    uint32[][][] memory eMinsMatrix,
    uint32[][][] memory eMaxsMatrix
  ) external onlyRole(MANAGER_ROLE) {
    for (uint32 i = 0; i < ids.length; i++) {
      for (uint32 j = 0; j < 4; j++) {
        addAncestryBonus(
          ids[i],
          attrTypes[j],
          bMinsMatrix[i][j],
          bMaxsMatrix[i][j],
          eMinsMatrix[i][j],
          eMaxsMatrix[i][j]
        );
      }
    }
  }

  function addAncestryAttr(
    uint32 id,
    uint32[] memory speedGear,
    uint32[] memory enduranceGear,
    uint32[] memory burstGear,
    uint32[] memory stableGear,
    uint32[] memory eSpeedGear,
    uint32[] memory eEnduranceGear,
    uint32[] memory eBurstGear,
    uint32[] memory eStableGear
  ) public onlyRole(MANAGER_ROLE) {
    BaseAttrTLevelRates memory _bATRate = BaseAttrTLevelRates(speedGear, enduranceGear, burstGear, stableGear);
    ExtendAttrTLevelRates memory _eATRate = ExtendAttrTLevelRates(eSpeedGear, eEnduranceGear, eBurstGear, eStableGear);
    baseAttrRatesMapping[id] = _bATRate;
    extendAttrRatesMapping[id] = _eATRate;
  }

  function addAncestryAttrBatch(
    uint32[] memory ids,
    BaseAttrTLevelRates[] memory bATRates,
    ExtendAttrTLevelRates[] memory eATRates
  ) external onlyRole(MANAGER_ROLE) {
    for (uint i = 0; i < bATRates.length; i++) {
      BaseAttrTLevelRates memory bRate = bATRates[i];
      ExtendAttrTLevelRates memory eRate = eATRates[i];
      addAncestryAttr(
        ids[i],
        bRate.speedGear,
        bRate.enduranceGear,
        bRate.burstGear,
        bRate.stableGear,
        eRate.speedGear,
        eRate.enduranceGear,
        eRate.burstGear,
        eRate.stableGear
      );
    }
  }

  function addAncestry(
    uint32 id,
    uint32 appearType,
    uint32 appearWeight,
    uint32 inheritChance,
    uint32 speedGear,
    uint32 enduranceGear,
    uint32 burstGear,
    uint32 stableGear,
    uint32 maintainCost,
    uint32 qualityLimit
  ) public onlyRole(MANAGER_ROLE) {
    AncestryRate memory _ancestryRate = AncestryRate(appearType, qualityLimit, appearWeight);
    AncestryConf memory _ancestryConf = AncestryConf(
      inheritChance,
      speedGear,
      enduranceGear,
      burstGear,
      stableGear,
      maintainCost
    );
    if (ancestryRateMapping[id].appearWeight == 0 && ancestryConfMapping[id].speedGear == 0) {
      totalAncestryLength += 1;
    }
    ancestryRateMapping[id] = _ancestryRate;
    ancestryConfMapping[id] = _ancestryConf;
  }

  function addAncestryBatch(
    uint32[] memory ids,
    AncestryRate[] memory ancestryRates,
    AncestryConf[] memory ancestryConfs
  ) external onlyRole(MANAGER_ROLE) {
    for (uint i = 0; i < ancestryConfs.length; i++) {
      AncestryRate memory rate = ancestryRates[i];
      AncestryConf memory conf = ancestryConfs[i];
      addAncestry(
        ids[i],
        rate.appearType,
        rate.appearWeight,
        conf.inheritChance,
        conf.speedGear,
        conf.enduranceGear,
        conf.burstGear,
        conf.stableGear,
        conf.maintainCost,
        rate.qualityLimit
      );
    }
  }

  function addBaseAttributes(
    uint32 quality,
    uint32 speed,
    uint32 endurance,
    uint32 burst,
    uint32 stable
  ) external onlyRole(MANAGER_ROLE) {
    HorseAttribute memory _attr = HorseAttribute(speed, endurance, burst, stable);
    baseAttributes[quality] = _attr;
  }

  function setTCoef(uint8 tCoef_) external onlyRole(MANAGER_ROLE) {
    tCoef = tCoef_;
  }

  /// @custom:gameplay - random generating horse ancestry
  function randomAncestry(
    uint randomNumber,
    uint32 qualityLimit,
    uint8[] memory appearTypes
  ) public view returns (uint32) {
    uint totalWeight;
    uint32[] memory weights = new uint32[](totalAncestryLength);
    uint32 BASE = 400000;
    for (uint32 index = BASE + 1; index <= totalAncestryLength + BASE; index++) {
      AncestryRate memory _ancestryRate = ancestryRateMapping[index];
      if (qualityLimit > _ancestryRate.qualityLimit) {
        for (uint8 k = 0; k < appearTypes.length; k++) {
          if (appearTypes[k] == _ancestryRate.appearType) {
            totalWeight += _ancestryRate.appearWeight;
            weights[index - BASE - 1] = _ancestryRate.appearWeight;
            break;
          }
        }
      }
    }

    uint32 number = uint32(randomNumber % uint256(totalWeight));
    uint32 start = 0;
    uint32 ancestry;
    for (uint32 index = 0; index < weights.length; index++) {
      uint32 ancestryRate = weights[index];
      uint32 end = start + ancestryRate;
      if (number >= start && number < end) {
        ancestry = index + BASE + 1;
        return ancestry;
      }
      start = end;
    }
    return ancestry;
  }

  /// @custom:gameplay - generating ancestries through inheritance
  function inheritAncestry(
    uint randomNumber,
    uint32 quality,
    uint32 attrType,
    uint32[] memory ancestryList
  ) public view returns (uint32) {
    uint32[] memory inheritedAncestries = new uint32[](ancestryList.length);
    uint32[] memory weights = new uint32[](ancestryList.length);
    uint32 totalWeight;

    for (uint32 i = 0; i < ancestryList.length; i++) {
      uint32 _ancestry = ancestryList[i];
      AncestryConf memory _conf = ancestryConfMapping[_ancestry];
      uint32 inheritChance = _conf.inheritChance;
      randomNumber = nextRandom(i + 1, randomNumber);
      uint32 inheritNumber = uint32(randomNumber % RD);
      if (inheritNumber > inheritChance && quality > ancestryRateMapping[_ancestry].qualityLimit) {
        continue;
      }

      inheritedAncestries[i] = _ancestry;

      uint32 gearWeight;
      uint32 _gear;
      if (attrType == 1) {
        _gear = _conf.speedGear;
        gearWeight = RD / _gear ** tCoef;
      } else if (attrType == 2) {
        _gear = _conf.enduranceGear;
        gearWeight = RD / _gear ** tCoef;
      } else if (attrType == 3) {
        _gear = _conf.burstGear;
        gearWeight = RD / _gear ** tCoef;
      } else if (attrType == 4) {
        _gear = _conf.stableGear;
        gearWeight = RD / _gear ** tCoef;
      } else {
        revert InternalError();
      }
      totalWeight = totalWeight + gearWeight;
      weights[i] = gearWeight;
    }

    if (inheritedAncestries[0] == 0) {
      uint8[] memory appearTypes = new uint8[](2);
      appearTypes[0] = 2;
      appearTypes[1] = 3;
      return randomAncestry(nextRandom(uint32(ancestryList.length) + 1, randomNumber), quality, appearTypes);
    }

    uint32 number = uint32(randomNumber % uint256(totalWeight));
    uint32 start = 0;
    uint32 ancestry;
    for (uint32 index = 0; index < inheritedAncestries.length; index++) {
      uint32 ancestryRate = weights[index];
      uint32 end = start + ancestryRate;
      if (number >= start && number < end) {
        return inheritedAncestries[index];
      }
      start = end;
    }
    return ancestry;
  }

  /// @custom:gameplay - generating horse attributes cooresponding to ancestry
  function randomAncestryAttr(
    uint randomNumber,
    uint randomNonce,
    uint32 ancestry,
    uint32 quality
  ) public view returns (HorseAttribute memory, HorseAttribute memory, uint) {
    HorseAttribute memory _baseAttr = randomAncestryBaseAttr(randomNumber, randomNonce, ancestry, quality);
    HorseAttribute memory _extendAttr = randomAncestryExtendAttr(randomNumber, randomNonce, ancestry, quality);

    uint hashRate;
    hashRate += ((_baseAttr.speed + _extendAttr.speed) * 1000) / 1020;
    hashRate += ((_baseAttr.endurance + _extendAttr.endurance) * 1000) / 1100;
    hashRate += ((_baseAttr.burst + _extendAttr.burst) * 1000) / 1112;
    hashRate += ((_baseAttr.stable + _extendAttr.stable) * 1000) / 972;

    return (_baseAttr, _extendAttr, hashRate);
  }

  /// @custom:gameplay - generating horse attributes cooresponding to ancestry during breeding
  function inheritAncestryAttr(
    uint randomNumber,
    uint randomNonce,
    uint32[] memory ancestryList,
    uint32 quality
  ) external view returns (HorseAttribute memory, HorseAttribute memory, uint32[] memory, uint) {
    uint32[] memory ancestries = new uint32[](4);
    ancestries[0] = inheritAncestry(randomNumber, quality, 1, ancestryList);
    randomNumber = nextRandom(randomNonce + 1, randomNumber);
    ancestries[1] = inheritAncestry(randomNumber, quality, 2, ancestryList);
    randomNumber = nextRandom(randomNonce + 2, randomNumber);
    ancestries[2] = inheritAncestry(randomNumber, quality, 3, ancestryList);
    randomNumber = nextRandom(randomNonce + 3, randomNumber);
    ancestries[3] = inheritAncestry(randomNumber, quality, 4, ancestryList);
    randomNumber = nextRandom(randomNonce + 4, randomNumber);

    (HorseAttribute memory _baseAttr1, HorseAttribute memory _extendAttr1, uint hashRate1) = randomAncestryAttr(
      randomNumber,
      randomNonce + 5,
      ancestries[0],
      quality
    );
    randomNumber = nextRandom(randomNonce + 6, randomNumber);
    (HorseAttribute memory _baseAttr2, HorseAttribute memory _extendAttr2, uint hashRate2) = randomAncestryAttr(
      randomNumber,
      randomNonce + 7,
      ancestries[1],
      quality
    );
    randomNumber = nextRandom(randomNonce + 8, randomNumber);
    (HorseAttribute memory _baseAttr3, HorseAttribute memory _extendAttr3, uint hashRate3) = randomAncestryAttr(
      randomNumber,
      randomNonce + 9,
      ancestries[2],
      quality
    );
    randomNonce = nextRandom(randomNonce + 10, randomNumber);
    (HorseAttribute memory _baseAttr4, HorseAttribute memory _extendAttr4, uint hashRate4) = randomAncestryAttr(
      randomNonce,
      randomNonce + 11,
      ancestries[3],
      quality
    );

    HorseAttribute memory _baseAttr = HorseAttribute(
      (_baseAttr1.speed + _baseAttr2.speed + _baseAttr3.speed + _baseAttr4.speed) / 4,
      (_baseAttr1.endurance + _baseAttr2.endurance + _baseAttr3.endurance + _baseAttr4.endurance) / 4,
      (_baseAttr1.burst + _baseAttr2.burst + _baseAttr3.burst + _baseAttr4.burst) / 4,
      (_baseAttr1.stable + _baseAttr2.stable + _baseAttr3.stable + _baseAttr4.stable) / 4
    );
    HorseAttribute memory _extendAttr = HorseAttribute(
      (_extendAttr1.speed + _extendAttr2.speed + _extendAttr3.speed + _extendAttr4.speed) / 4,
      (_extendAttr1.endurance + _extendAttr2.endurance + _extendAttr3.endurance + _extendAttr4.endurance) / 4,
      (_extendAttr1.burst + _extendAttr2.burst + _extendAttr3.burst + _extendAttr4.burst) / 4,
      (_extendAttr1.stable + _extendAttr2.stable + _extendAttr3.stable + _extendAttr4.stable) / 4
    );
    uint hashRate = (hashRate1 + hashRate2 + hashRate3 + hashRate4) / 4;

    uint32 valid = 4;
    if (ancestries[0] == ancestries[1] || ancestries[0] == ancestries[2] || ancestries[0] == ancestries[3]) {
      ancestries[0] = 0;
      valid--;
    }
    if (ancestries[1] == ancestries[2] || ancestries[1] == ancestries[3]) {
      ancestries[1] = 0;
      valid--;
    }
    if (ancestries[2] == ancestries[3]) {
      ancestries[2] = 0;
      valid--;
    }
    uint32[] memory finalAncestries = new uint32[](valid);
    uint32 count = 0;
    for (uint i = 0; i < 4; i++) {
      if (ancestries[i] != 0) {
        finalAncestries[count] = ancestries[i];
        count++;
      }
    }

    return (_baseAttr, _extendAttr, finalAncestries, hashRate);
  }

  function randomAncestryExtendAttr(
    uint randomNumber,
    uint randomNonce,
    uint32 ancestry,
    uint32 quality
  ) internal view returns (HorseAttribute memory) {
    HorseAttribute memory _extendAttr = baseAttributes[quality];
    ExtendAttrTLevelRates memory _eATRate = extendAttrRatesMapping[ancestry];

    // extendSpeed
    uint32[] memory speedGearsubset = _eATRate.speedGear;
    RandomBonus memory _speedRange = extendBonusMapping[ancestry][1][randomTLevel(speedGearsubset, RD, randomNumber)];
    randomNumber = nextRandom(randomNonce + 5, randomNumber);
    _extendAttr.speed = (_extendAttr.speed * randBetween(_speedRange.min, _speedRange.max, randomNumber)) / RD;

    // extendEndurance
    uint32[] memory enduranceGearsubset = _eATRate.enduranceGear;
    randomNumber = nextRandom(_extendAttr.speed, randomNumber);
    RandomBonus memory _enduranceRange = extendBonusMapping[ancestry][2][
      randomTLevel(enduranceGearsubset, RD, randomNumber)
    ];
    randomNumber = nextRandom(randomNonce + 6, randomNumber);
    _extendAttr.endurance =
      (_extendAttr.endurance * randBetween(_enduranceRange.min, _enduranceRange.max, randomNumber)) /
      RD;

    // extendBurst
    uint32[] memory burstGearsubset = _eATRate.burstGear;
    randomNumber = nextRandom(_extendAttr.endurance, randomNumber);
    RandomBonus memory _burstRange = extendBonusMapping[ancestry][3][randomTLevel(burstGearsubset, RD, randomNumber)];
    randomNumber = nextRandom(randomNonce + 7, randomNumber);
    _extendAttr.burst = (_extendAttr.burst * randBetween(_burstRange.min, _burstRange.max, randomNumber)) / RD;

    // extendStable
    uint32[] memory stableGearsubset = _eATRate.stableGear;
    randomNumber = nextRandom(_extendAttr.burst, randomNumber);
    RandomBonus memory _stableRange = extendBonusMapping[ancestry][4][randomTLevel(stableGearsubset, RD, randomNumber)];
    randomNumber = nextRandom(randomNonce + 8, randomNumber);
    _extendAttr.stable = (_extendAttr.stable * randBetween(_stableRange.min, _stableRange.max, randomNumber)) / RD;

    return _extendAttr;
  }

  function randomAncestryBaseAttr(
    uint randomNumber,
    uint randomNonce,
    uint32 ancestry,
    uint32 quality
  ) internal view returns (HorseAttribute memory) {
    HorseAttribute memory _baseAttr = baseAttributes[quality];
    BaseAttrTLevelRates memory _bATRate = baseAttrRatesMapping[ancestry];

    // baseSpeed
    uint32[] memory speedGearsubset = _bATRate.speedGear;
    RandomBonus memory _speedRange = baseBonusMapping[ancestry][1][randomTLevel(speedGearsubset, RD, randomNumber)];
    randomNumber = nextRandom(randomNonce + 1, randomNumber);
    _baseAttr.speed =
      _baseAttr.speed +
      (_baseAttr.speed * randBetween(_speedRange.min, _speedRange.max, randomNumber)) /
      RD;

    // baseEndurance
    uint32[] memory enduranceGearsubset = _bATRate.enduranceGear;
    randomNumber = nextRandom(_baseAttr.speed, randomNumber);
    RandomBonus memory _enduranceRange = baseBonusMapping[ancestry][2][
      randomTLevel(enduranceGearsubset, RD, randomNumber)
    ];
    randomNumber = nextRandom(randomNonce + 2, randomNumber);
    _baseAttr.endurance =
      _baseAttr.endurance +
      (_baseAttr.endurance * randBetween(_enduranceRange.min, _enduranceRange.max, randomNumber)) /
      RD;

    // baseBurst
    uint32[] memory burstGearsubset = _bATRate.burstGear;
    randomNumber = nextRandom(_baseAttr.endurance, randomNumber);
    RandomBonus memory _burstRange = baseBonusMapping[ancestry][3][randomTLevel(burstGearsubset, RD, randomNumber)];
    randomNumber = nextRandom(randomNonce + 3, randomNumber);
    _baseAttr.burst =
      _baseAttr.burst +
      (_baseAttr.burst * randBetween(_burstRange.min, _burstRange.max, randomNumber)) /
      RD;

    uint32[] memory stableGearsubset = _bATRate.stableGear;
    randomNumber = nextRandom(_baseAttr.burst, randomNumber);
    RandomBonus memory _stableRange = baseBonusMapping[ancestry][4][randomTLevel(stableGearsubset, RD, randomNumber)];
    randomNumber = nextRandom(randomNonce + 4, randomNumber);
    _baseAttr.stable =
      _baseAttr.stable +
      (_baseAttr.stable * randBetween(_stableRange.min, _stableRange.max, randomNumber)) /
      RD;

    return _baseAttr;
  }

  function randomTLevel(uint32[] memory rates, uint totalWeight, uint randomNumber) internal pure returns (uint32) {
    uint32 number = uint32(randomNumber % uint256(totalWeight));
    uint32 tLevel;
    uint32 start = 0;
    for (uint32 index = 0; index < rates.length; index++) {
      uint32 tRate = rates[index];
      uint32 end = start + tRate;
      if (number >= start && number < end) {
        tLevel = index;
        return tLevel;
      }
      start = end;
    }
    return tLevel;
  }

  function randBetween(uint32 min, uint32 max, uint256 r) internal pure returns (uint32) {
    if (min >= max) {
      return min;
    }

    uint256 rang = (max + 1) - min;
    uint32 rand = uint32(min + (r % rang));
    return rand;
  }

  function nextRandom(uint256 index, uint256 number) internal view returns (uint256) {
    uint256 n1 = number % (block.number + block.timestamp + index);
    uint256 h1 = uint256(blockhash(n1));
    return uint256(keccak256(abi.encodePacked(n1, h1, index)));
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Revision: 2023-1-13
// version 1.0.0

interface HorseStruct {
  struct HorseData {
    uint32 name;
    uint32 numberPlate;
    uint8 sex;
    uint32 quality;
    bool appraisal;
    uint32 bornType;
    uint32 birthNumber;
    uint32 load;
    uint32 skillMax;
    uint32[] skillList;
    uint32 maintainCost;
    uint32[] ancestryList;
    HorseAttribute baseAttr;
    HorseAttribute extendAttr;
    HorseAppearances appearances;
    uint256 hashRate;
  }

  struct HorseAttribute {
    uint32 speed;
    uint32 endurance;
    uint32 burst;
    uint32 stable;
  }

  struct HorseAppearances {
    uint32[] partIds;
    uint32[] partsColors;
    uint32[] detailIds;
    uint32[] detailColors;
    bool unified;
  }
}