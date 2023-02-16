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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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
pragma solidity 0.8.17;

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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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
pragma solidity 0.8.17;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "../token/IBEP20.sol";

contract Vesting is ReentrancyGuard, AccessControl {
    /**
     * The vesting time is given in terms of the selected vesting type.
     *     _vType
     *  --------------
     * | 0 = 1   days |
     * | 1 = 7   days |
     * | 2 = 30  days |
     * | 3 = 90  days |
     * | 4 = 180 days |
     * | 5 = 360 days |
     *  --------------
     */

    /*==================================================== Events =============================================================*/
    event InvestorAdded(
        address indexed investor,
        address caller,
        uint256 allocation,
        uint256 endTime,
        uint256 indexed softCapValue,
        bool indexed sofCapStatus
    );
    event Withdrawn(address indexed investor, uint256 value);
    event InvestorRemoved(address indexed investor);
    event RecoverToken(address indexed token, uint256 indexed amount);
    /*==================================================== Modifiers ==========================================================*/
    /*
     *Throws error when caller is not registered investor
     */
    modifier onlyInvestor(VestingCategory _vCat, uint256 _index) {
        require(
            investorsInfo[msg.sender][_vCat][_index].exists,
            "Only investors allowed"
        );
        _;
    }
    /*
     * Throws error when caller is not registered as an authorized contract.
     *Needed for withdrawFundsAutomatically for keeper mini vesting contracts.
     */
    modifier onlyVestingKeeper() {
        require(
            msg.sender == vestingKeeper,
            "Only authorized contracts allowed"
        );
        _;
    }

    /*==================================================== State Variables ====================================================*/
    //============================================================================

    //Vesting types
    enum VestingType {
        DAILY,
        WEEKLY,
        MONTHLY,
        QUARTERLY,
        HALFYEARLY,
        YEARLY
    }

    // Vesting categories
    enum VestingCategory {
        TA,
        MARKETING,
        ECOSYSTEM,
        STRATEGIC_SEED,
        STRATEGIC_PRIVATE,
        PUBLIC_UNLOCKED,
        PUBLIC_LOCKED,
        SPORTS
    }
    //============================================================================
    //Needed for Stack Too Deep eroor in the _addInvestor function. Its parameters were reduced into One using this Struct.
    struct AddInvestor {
        address investor;
        uint256 tokensAllotment;
        uint256 initialUnlockAmount;
        uint256 recurrence;
        uint256 afterCliffUnlockAmount;
        uint256 cliffDays;
        VestingCategory vCat;
        VestingType vType;
        string purchaseId;
    }

    struct AddInvestorBatch {
        address[] investors;
        uint256[] tokensAllotments;
        VestingCategory[] categories;
        string[] purchaseIds;
    }

    // Struct for Investor data
    struct Investor {
        bool exists;
        uint256 withdrawnTokens;
        uint256 tokensAllotment;
        uint256 startTimestamp;
        uint256 endTime;
        uint256 lastReceivedTime;
        Schedules schedules;
    }

    // Data of vesting categories
    struct Schedules {
        uint256 afterCliffUnlockAmount;
        uint256 initialUnlockAmount;
        uint256 recurrence;
        uint256 cliffDays;
        uint256 multiplier;
        uint256 maxAllotment;
        uint256 sold;
        VestingType vType;
    }

    //============================================================================
    //Total Allocated Token Amount To Investors
    uint256 public totalAllocatedAmount;
    //Investors vesting default start time
    uint256 public globalTime;
    // Holds Current value of the softcap pool
    uint256 public softCap;

    uint256 private constant SOFTCAP_LIMIT = 120 * 10 ** 11;
    uint256 private constant DIVIDING = 1000;
    uint256 private constant LOCKEDPRICE = 5 * 10 ** 6;
    uint256 private constant UNLOCKEDPRICE = 6 * 10 ** 6;
    uint256 private constant UNIT = 10 ** 18;

    address public vestingKeeper;
    //The Array of the investors addresses
    address[] public investors;
    //Address of the Soccer
    IBEP20 public SoCo;
    //Controller for SoCo set
    bool public isTokenSet;
    // Checks whether globalTime set before
    bool private isGlobalSetBefore;

    //============================================================================
    //Stores Investors Vesting Data
    mapping(address => mapping(VestingCategory => mapping(uint256 => Investor)))
        public investorsInfo;
    //Stores investors vesting indexes per vesting category
    mapping(address => mapping(VestingCategory => uint256[]))
        private investorIndexes;

    //Stores all investors addresses for the specific Vesting Category
    mapping(VestingCategory => address[]) private allInvestors;

    //To read investors easily from Mini Kepeer-Mini Vesting Type contracts
    mapping(uint256 => VestingCategory) public intToEnum;

    //Returns schedule data
    mapping(VestingCategory => Schedules) public scheduleInfo;
    //Returns period data
    mapping(VestingType => uint256) public periods;

    //Stores expired purchase Ids to prevent the same purchase happenning again
    mapping(string => bool) public expiredPurchaseIds;

    /*==================================================== Constructor ========================================================*/
    /*
     *@param _admin : address of the admin
     *@param _globaltime: default start time
     */
    constructor(address _admin, uint256 _globalTime) {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        globalTime = _globalTime;
        //============================================================================
        periods[VestingType.DAILY] = 1;
        periods[VestingType.WEEKLY] = 7;
        periods[VestingType.MONTHLY] = 30;
        periods[VestingType.QUARTERLY] = 90;
        periods[VestingType.HALFYEARLY] = 180;
        periods[VestingType.YEARLY] = 360;
        //============================================================================
        intToEnum[0] = VestingCategory.TA;
        intToEnum[1] = VestingCategory.MARKETING;
        intToEnum[2] = VestingCategory.ECOSYSTEM;
        intToEnum[3] = VestingCategory.STRATEGIC_SEED;
        intToEnum[4] = VestingCategory.STRATEGIC_PRIVATE;
        intToEnum[5] = VestingCategory.PUBLIC_UNLOCKED;
        intToEnum[6] = VestingCategory.PUBLIC_LOCKED;
        intToEnum[7] = VestingCategory.SPORTS;
        //============================================================================
        scheduleInfo[VestingCategory.TA].vType = VestingType.HALFYEARLY;
        scheduleInfo[VestingCategory.TA].afterCliffUnlockAmount = 0;
        scheduleInfo[VestingCategory.TA].recurrence = 6;
        scheduleInfo[VestingCategory.TA].cliffDays = 180;
        scheduleInfo[VestingCategory.TA].multiplier = 100;
        scheduleInfo[VestingCategory.TA].maxAllotment = 192 * 10 ** 24;
        //============================================================================
        scheduleInfo[VestingCategory.MARKETING].vType = VestingType.MONTHLY;
        scheduleInfo[VestingCategory.MARKETING].afterCliffUnlockAmount = 0;
        scheduleInfo[VestingCategory.MARKETING].multiplier = 200;
        scheduleInfo[VestingCategory.MARKETING].recurrence = 16;
        scheduleInfo[VestingCategory.MARKETING].cliffDays = 0;
        scheduleInfo[VestingCategory.MARKETING].maxAllotment = 160 * 10 ** 24;
        //============================================================================
        scheduleInfo[VestingCategory.ECOSYSTEM].vType = VestingType.QUARTERLY;
        scheduleInfo[VestingCategory.ECOSYSTEM].afterCliffUnlockAmount = 0;
        scheduleInfo[VestingCategory.ECOSYSTEM].multiplier = 200;
        scheduleInfo[VestingCategory.ECOSYSTEM].recurrence = 8;
        scheduleInfo[VestingCategory.ECOSYSTEM].cliffDays = 0;
        scheduleInfo[VestingCategory.ECOSYSTEM].maxAllotment = 432 * 10 ** 24;
        //============================================================================
        scheduleInfo[VestingCategory.STRATEGIC_SEED].vType = VestingType
            .QUARTERLY;
        scheduleInfo[VestingCategory.STRATEGIC_SEED].afterCliffUnlockAmount = 0;
        scheduleInfo[VestingCategory.STRATEGIC_SEED].multiplier = 300;
        scheduleInfo[VestingCategory.STRATEGIC_SEED].recurrence = 7;
        scheduleInfo[VestingCategory.STRATEGIC_SEED].cliffDays = 360;
        //============================================================================
        scheduleInfo[VestingCategory.STRATEGIC_PRIVATE].vType = VestingType
            .QUARTERLY;
        scheduleInfo[VestingCategory.STRATEGIC_PRIVATE]
            .afterCliffUnlockAmount = 0;
        scheduleInfo[VestingCategory.STRATEGIC_PRIVATE].multiplier = 75;
        scheduleInfo[VestingCategory.STRATEGIC_PRIVATE].recurrence = 6;
        scheduleInfo[VestingCategory.STRATEGIC_PRIVATE].cliffDays = 0;
        //============================================================================
        scheduleInfo[VestingCategory.PUBLIC_LOCKED].vType = VestingType.MONTHLY;
        scheduleInfo[VestingCategory.PUBLIC_LOCKED].afterCliffUnlockAmount = 0;
        scheduleInfo[VestingCategory.PUBLIC_LOCKED].multiplier = 100;
        scheduleInfo[VestingCategory.PUBLIC_LOCKED].recurrence = 9;
        scheduleInfo[VestingCategory.PUBLIC_LOCKED].cliffDays = 0;
        scheduleInfo[VestingCategory.PUBLIC_LOCKED].maxAllotment =
            48 *
            10 ** 24;
        //============================================================================
        scheduleInfo[VestingCategory.PUBLIC_UNLOCKED].vType = VestingType.DAILY;
        scheduleInfo[VestingCategory.PUBLIC_UNLOCKED]
            .afterCliffUnlockAmount = 0;
        scheduleInfo[VestingCategory.PUBLIC_UNLOCKED].multiplier = 1000;
        scheduleInfo[VestingCategory.PUBLIC_UNLOCKED].recurrence = 0;
        scheduleInfo[VestingCategory.PUBLIC_UNLOCKED].cliffDays = 0;
        scheduleInfo[VestingCategory.PUBLIC_UNLOCKED].maxAllotment =
            112 *
            10 ** 24;
        //============================================================================
        scheduleInfo[VestingCategory.SPORTS].vType = VestingType.DAILY;
        scheduleInfo[VestingCategory.SPORTS].afterCliffUnlockAmount = 0;
        scheduleInfo[VestingCategory.SPORTS].multiplier = 1000;
        scheduleInfo[VestingCategory.SPORTS].recurrence = 0;
        scheduleInfo[VestingCategory.SPORTS].cliffDays = 730;
        scheduleInfo[VestingCategory.SPORTS].maxAllotment = 320 * 10 ** 24;
        //============================================================================

        AddInvestor memory _taInvestor = AddInvestor(
            0xd1CeAEd88Ae316Ac6F8A22Fd2e27990817baC6D8, // investor
            192 * 10 ** 24, // tokens allotment
            0, // initial unlock
            6, // recurrence
            ((192 * 10 ** 24) * scheduleInfo[VestingCategory.TA].multiplier) /
                DIVIDING, // after cliff unlock
            180, // cliff days
            VestingCategory.TA, //vCAt
            VestingType.HALFYEARLY, // Vtype
            "0xd1CeAEd88Ae316Ac6F8A22Fd2e27990817baC6D8TA" // Purchase Id Address+VCat
        );
        _addInvestor(_taInvestor);

        //============================================================================

        AddInvestor memory _marketingInvestor = AddInvestor(
            0x8090B0AF0a604FA2C20684ACB63A446D5254e328, // investor
            160 * 10 ** 24, // tokens allotment
            (160 *
                10 ** 24 *
                scheduleInfo[VestingCategory.MARKETING].multiplier) / DIVIDING, // initial unlock amount
            16, // recurrence
            0, // after cliff
            0, // cliff days
            VestingCategory.MARKETING,
            VestingType.MONTHLY,
            "0x8090B0AF0a604FA2C20684ACB63A446D5254e328MARKETING"
        );
        _addInvestor(_marketingInvestor);

        //============================================================================

        AddInvestor memory _ecosystemInvestor = AddInvestor(
            0x824D0aa92001CAB20F51676d7dEB2fe0F38c81c2, // investor
            432 * 10 ** 24, // tokens allotment
            (432 *
                10 ** 24 *
                scheduleInfo[VestingCategory.ECOSYSTEM].multiplier) / DIVIDING, // initial unlock
            8, // recurrence
            0, // after cliff unlock
            0, // cliff days
            VestingCategory.ECOSYSTEM, //vCAt
            VestingType.QUARTERLY, // Vtype
            "0x824D0aa92001CAB20F51676d7dEB2fe0F38c81c2ECOSYSTEM" // Purchase Id Address+VCat
        );
        _addInvestor(_ecosystemInvestor);

        //============================================================================

        AddInvestor memory _sportsInvestor = AddInvestor(
            0x13e7eC99A6AEED4B3fec1919a750dbd2652dD50d, // investor
            320 * 10 ** 24, // tokens allotment
            0, // initial unlock
            0, // recurrence
            ((320 * 10 ** 24) * scheduleInfo[VestingCategory.TA].multiplier) /
                DIVIDING, // after cliff unlock
            730, // cliff days
            VestingCategory.SPORTS, //vCAt
            VestingType.DAILY, // Vtype
            "0x13e7eC99A6AEED4B3fec1919a750dbd2652dD50dSPORTS" // Purchase Id Address+VCat
        );
        _addInvestor(_sportsInvestor);

        //============================================================================
    }

    /*==================================================== FUNCTIONS ==========================================================*/
    /*==================================================== Read Functions ======================================================*/

    /** 
  ///@return _users : all investors addresses for the given category 
  ///@param _vCat: Between values 0-7, returns investors addresses for that vesting category
  */
    function getUsers(
        uint256 _vCat
    ) external view returns (address[] memory _users) {
        VestingCategory _vest = intToEnum[_vCat];
        return allInvestors[_vest];
    }

    /*
     *@returns Investor data as a struct
     *@param _investor : The address of the investor
     *@param _vCat : vesting category (e.g 0 for TA, 1 for Marketing)
     *@param _index : the index of the users purchase for the same category
     */
    function getInvestorInfo(
        address _investor,
        uint256 _vCat,
        uint256 _index
    ) external view returns (Investor memory) {
        VestingCategory _vest = intToEnum[_vCat];
        return investorsInfo[_investor][_vest][_index];
    }

    /**
    @return _indexes : the indexes of the given user for the given category
    @param _investor: The address of the Investor
    @param _vCat: Category parameter,integers between 0-7
  */
    function getInvestorIndexes(
        address _investor,
        uint256 _vCat
    ) external view returns (uint256[] memory _indexes) {
        VestingCategory _vest = intToEnum[_vCat];
        _indexes = investorIndexes[_investor][_vest];
    }

    /*
  ///@dev withdrawable tokens for an address
  *@returns Available tokens amount for the given user data  
  *@param _investor : The address of the investor
  *@param _vCat : vesting category (e.g 0 for TA, 1 for Marketing)
  *@param _index : the index of the users purchase for the same category 
  */
    function withdrawableTokens(
        address _investor,
        VestingCategory _vCat,
        uint256 _index
    ) public view returns (uint256 tokensAvailable) {
        Investor memory investor = investorsInfo[_investor][_vCat][_index];

        uint256 totalUnlockedTokens = calculateUnlockedTokens(
            _investor,
            _vCat,
            _index
        );
        uint256 tokensWithdrawable = totalUnlockedTokens -
            investor.withdrawnTokens;
        return tokensWithdrawable;
    }

    /*
     *@returns the end time of the vesting for the given user data
     *@param _investor : The address of the investor
     *@param _vCat : vesting category (e.g 0 for TA, 1 for Marketing)
     *@param _index : the index of the users purchase for the same category
     */
    function getInvestorEndTime(
        address _investor,
        VestingCategory _vCat,
        uint256 _index
    ) external view returns (uint256) {
        return investorsInfo[_investor][_vCat][_index].endTime;
    }

    /**
  @return availableTokens : Total unlocked amou t for the given investor data
  @param _investor: Address of the investor
  @param _vCat: Vesting Category 
  @param _index: the index of the users purchase for the same category 
   */
    function calculateUnlockedTokens(
        address _investor,
        VestingCategory _vCat,
        uint256 _index
    ) public view returns (uint256 availableTokens) {
        Investor memory investor = investorsInfo[_investor][_vCat][_index];
        uint256 period = periods[investor.schedules.vType];
        uint256 startTimeStamp = investor.startTimestamp;

        if (startTimeStamp == 0) startTimeStamp = globalTime;

        uint256 cliffTimestamp = startTimeStamp +
            (investor.schedules.cliffDays * 1 days);

        uint256 vestingTimestamp = cliffTimestamp +
            (investor.schedules.recurrence * period * 1 days);

        uint256 initialDistroAmount = investor.schedules.initialUnlockAmount;

        uint256 currentTimeStamp = block.timestamp;

        if (currentTimeStamp > startTimeStamp) {
            if (currentTimeStamp <= cliffTimestamp) {
                return initialDistroAmount;
            } else if (
                currentTimeStamp > cliffTimestamp &&
                currentTimeStamp < vestingTimestamp
            ) {
                uint256 vestingDistroAmount = investor.tokensAllotment -
                    (initialDistroAmount +
                        investor.schedules.afterCliffUnlockAmount);

                uint256 diffDays = ((currentTimeStamp - cliffTimestamp)) /
                    (period * 1 days);

                uint256 vestingUnlockedAmount = (diffDays *
                    vestingDistroAmount) / investor.schedules.recurrence;

                return
                    initialDistroAmount +
                    vestingUnlockedAmount +
                    investor.schedules.afterCliffUnlockAmount;
            } else {
                return investor.tokensAllotment;
            }
        } else {
            return 0;
        }
    }

    /*==================================================== External Functions ==================================================*/

    /**
  @param _investor: Investor address
  @param _tokensAllotment: Token Allotment of the User
  @param _category:  Vesting Category
  @param _purchaseId: Purchase Id
  */
    function addInvestor(
        address _investor,
        uint256 _tokensAllotment,
        string calldata _purchaseId,
        VestingCategory _category
    ) external onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
        Schedules memory _schedulesInfo = scheduleInfo[_category];
        if (
            _category == VestingCategory.TA ||
            _category == VestingCategory.STRATEGIC_SEED ||
            _category == VestingCategory.SPORTS
        ) {
            _schedulesInfo.afterCliffUnlockAmount =
                (_tokensAllotment * _schedulesInfo.multiplier) /
                DIVIDING;
        } else {
            _schedulesInfo.initialUnlockAmount =
                (_tokensAllotment * _schedulesInfo.multiplier) /
                DIVIDING;
        }
        AddInvestor memory investor = AddInvestor(
            _investor,
            _tokensAllotment,
            _schedulesInfo.initialUnlockAmount,
            _schedulesInfo.recurrence,
            _schedulesInfo.afterCliffUnlockAmount,
            _schedulesInfo.cliffDays,
            _category,
            _schedulesInfo.vType,
            _purchaseId
        );

        _addInvestor(investor);
    }

    /*
  This function can only be called by the Mini-Keeper Vesting Type Contracts that is registered.
  */
    function withdrawTokensAutomatically(
        address _user,
        VestingCategory _vCat,
        uint256 _index
    ) external onlyVestingKeeper nonReentrant {
        Investor memory investor = investorsInfo[_user][_vCat][_index];

        uint256 tokensAvailable = withdrawableTokens(_user, _vCat, _index);
        require(
            tokensAvailable > 0,
            "withdrawTokens: no tokens available for withdrawal"
        );

        require(
            investor.tokensAllotment >= tokensAvailable,
            "You can't take withdraw more than allocation"
        );

        investor.withdrawnTokens = investor.withdrawnTokens + tokensAvailable;
        investor.lastReceivedTime = block.timestamp;

        investorsInfo[_user][_vCat][_index] = investor;

        emit Withdrawn(_user, tokensAvailable);

        require(
            SoCo.transfer(_user, tokensAvailable),
            "withdrawTokensAutomatically: Soco transfer failed"
        );
    }

    /*

  * User can withdraw his/her unlocked tokens via this function
  *@param _vCat : Vesting category (e.g 0 for TA, 1 for Marketing)
  *@param _index : The index of the users purchase for the same category 
  */
    function withdrawTokens(
        VestingCategory _vCat,
        uint256 _index
    ) external nonReentrant onlyInvestor(_vCat, _index) {
        Investor memory investor = investorsInfo[msg.sender][_vCat][_index];

        uint256 tokensAvailable = withdrawableTokens(msg.sender, _vCat, _index);
        require(
            tokensAvailable > 0,
            "withdrawTokens: no tokens available for withdrawal"
        );

        require(
            investor.tokensAllotment >= tokensAvailable,
            "You can't take withdraw more than allocation"
        );

        investor.withdrawnTokens = investor.withdrawnTokens + tokensAvailable;
        investor.lastReceivedTime = block.timestamp;

        investorsInfo[msg.sender][_vCat][_index] = investor;
        emit Withdrawn(msg.sender, tokensAvailable);
        require(
            SoCo.transfer(msg.sender, tokensAvailable),
            "withdrawTokens: Soco transfer failed."
        );
    }

    /**
    Users who have Sports category tokens, can withdraw any amount they want after fully unlocked.
    *@param _vCat: Should be 7 (VestingCategory.SPORTS).
    *@param _index: The index of the users purchase for the same category.
    *@param _amount: The amount of the tokens that users want to withdraw. Can't be greater than withdrawable tokens amount.
   */
    function withdrawSportsTokens(
        VestingCategory _vCat,
        uint256 _index,
        uint256 _amount
    ) external onlyInvestor(_vCat, _index) {
        require(
            _vCat == VestingCategory.SPORTS,
            "This function enable to SPORTS category!"
        );
        Investor memory investor = investorsInfo[msg.sender][_vCat][_index];

        uint256 tokensAvailable = withdrawableTokens(msg.sender, _vCat, _index);
        require(
            tokensAvailable > 0,
            "withdrawTokens: no tokens available for withdrawal"
        );
        require(
            _amount <= tokensAvailable,
            "You can't take withdraw more than your available tokens"
        );

        investor.withdrawnTokens += _amount;
        investor.lastReceivedTime = block.timestamp;
        investorsInfo[msg.sender][_vCat][_index] = investor;

        emit Withdrawn(msg.sender, _amount);

        require(
            SoCo.transfer(msg.sender, _amount),
            "withdrawSportsTokens: Soco transfer failed"
        );
    }

    /*
     *The admin can remove investor with this function
     *@param _investor : The address of the investor
     *@param _vCat : Vesting category (e.g 0 for TA, 1 for Marketing)
     *@param _index : The index of the users purchase for the same category
     */
    function removeInvestor(
        address _investor,
        VestingCategory _vCat,
        uint256 _index
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        delete investorsInfo[_investor][_vCat][_index];
        emit InvestorRemoved(_investor);
    }

    /**
    Admin can recover tokens in the contract
  */
    function recoverToken(
        address _token,
        uint256 _amount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_token != address(SoCo), "token can't be SoCo");
        emit RecoverToken(_token, _amount);

        require(
            IBEP20(_token).transfer(msg.sender, _amount),
            "Recover token failed"
        );
    }

    /**
    After reaching Soft Cap, this function is called and set to a new start time for the investors.
  */
    function setGlobalTime(
        uint256 _globalTime
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        globalTime = _globalTime;
    }

    /**
    Sets Authorization status of the Keeper Vesting Contract.
   */
    function setVestingKeeper(
        address _vestingKeeper
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            _vestingKeeper != address(0),
            "Address can not be zero address"
        );
        vestingKeeper = _vestingKeeper;
    }

    /*
     * The admin can set a token which will be distributed
     *@param _token : The address of the token
     */
    function setToken(address _token) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!isTokenSet, "Token Already Set!");
        SoCo = IBEP20(_token);
        isTokenSet = true;
    }

    /*==================================================== Internal Functions ==================================================*/
    /**
    Adds investors data to contract
   */
    function _addInvestor(AddInvestor memory _investor) internal {
        require(
            !expiredPurchaseIds[_investor.purchaseId],
            "Purchase ID already used"
        );
        expiredPurchaseIds[_investor.purchaseId] = true;
        require(
            _investor.investor != address(0),
            "addInvestor: invalid address"
        );
        require(
            _investor.tokensAllotment > 0,
            "addInvestor: the investor allocation must be more than 0"
        );
        if (
            _investor.vCat != VestingCategory.STRATEGIC_PRIVATE &&
            _investor.vCat != VestingCategory.STRATEGIC_SEED
        ) {
            require(
                scheduleInfo[_investor.vCat].maxAllotment -
                    scheduleInfo[_investor.vCat].sold >=
                    _investor.tokensAllotment,
                "addInvestor: Not enough tokens available"
            );
        }

        uint256 _index = investorIndexes[_investor.investor][_investor.vCat]
            .length;

        if (_index == 0) allInvestors[_investor.vCat].push(_investor.investor);

        investorIndexes[_investor.investor][_investor.vCat].push(_index);

        Investor memory investor_ = investorsInfo[_investor.investor][
            _investor.vCat
        ][_index];

        scheduleInfo[_investor.vCat].sold += _investor.tokensAllotment;

        (bool _softCapStatus, uint256 _softCapValue) = _computeSoftCap(
            scheduleInfo[VestingCategory.PUBLIC_LOCKED].sold,
            scheduleInfo[VestingCategory.PUBLIC_UNLOCKED].sold
        );
        uint256 _startTime;

        _softCapStatus ? _startTime = block.timestamp : _startTime = 0;

        investor_.tokensAllotment = _investor.tokensAllotment;
        investor_.exists = true;
        investor_.schedules.initialUnlockAmount = _investor.initialUnlockAmount;
        investor_.schedules.vType = VestingType(_investor.vType);
        investor_.schedules.cliffDays = _investor.cliffDays;
        investor_.schedules.recurrence = _investor.recurrence;
        investor_.schedules.afterCliffUnlockAmount = _investor
            .afterCliffUnlockAmount;
        investor_.startTimestamp = _startTime;
        investor_.lastReceivedTime = _startTime;

        investor_.endTime =
            (_investor.recurrence * periods[VestingType(_investor.vType)]) +
            _investor.cliffDays;
        investorsInfo[_investor.investor][_investor.vCat][_index] = investor_;
        investors.push(_investor.investor);

        totalAllocatedAmount = totalAllocatedAmount + _investor.tokensAllotment;

        emit InvestorAdded(
            _investor.investor,
            msg.sender,
            _investor.tokensAllotment,
            investor_.endTime,
            _softCapValue,
            _softCapStatus
        );
    }

    /**
    Computes the soft cap amount for the vesting
   */
    function _computeSoftCap(
        uint256 _soldLocked,
        uint256 _soldUnlocked
    ) internal returns (bool _result, uint256 _value) {
        _value =
            ((_soldLocked * LOCKEDPRICE) / UNIT) +
            ((_soldUnlocked * UNLOCKEDPRICE) / UNIT);
        softCap = _value;
        _value > SOFTCAP_LIMIT ? _result = true : _result = false;
        if (!isGlobalSetBefore && _result) {
            globalTime = block.timestamp;
            isGlobalSetBefore = true;
        }
    }
}