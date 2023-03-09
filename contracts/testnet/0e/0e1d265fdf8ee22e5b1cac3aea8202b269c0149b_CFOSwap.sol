/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

// SPDX-License-Identifier: MIT
// File: contracts/ICFONFT.sol


pragma solidity ^0.8.0;
interface ICFONFT {
    function pledge(address myAddr,uint tokenId) external;
    function priceOf() external view returns(uint256);
    function conditionsOf() external view returns(uint256);
}
// File: contracts/ICFOSwap.sol


pragma solidity ^0.8.0;
interface ICFOSwap {
    function priceOf() external view returns(uint256);
    function getParentAddr(address myAddr) external view returns(address);
}
// File: contracts/IERC20.sol


pragma solidity ^0.8.0;
interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/IERC165.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/ERC165.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SignedMath.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/Math.sol


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
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
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
            require(denominator > prod1, "Math: mulDiv overflow");

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
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
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
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
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
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
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
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;



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
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));
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

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/IAccessControl.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol


// OpenZeppelin Contracts (last updated v4.8.0) (access/AccessControl.sol)

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
 * ```solidity
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```solidity
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

// File: contracts/CFOSwap.sol









pragma solidity ^0.8.0;

contract CFOSwap is AccessControl,ICFOSwap{
    uint256 public initialprice;//初始价格
    uint256 public price; //现价
    uint256 public unitmeasurement;//计量单位
    uint256 public swingprice;//幅动价格
    uint256 public amplitudeincreasedecrease;//幅动增减值
    uint256 public triggermultiple;//触发倍数
    uint256 public initialswingprice;//初始幅动价格
    uint256 public max;//最大
    uint256 public min;//最小
    address public cfoAddr;//cfo地址
    address public usdtAddr;//usdt地址
    uint public cfoDecimals = 18;//代币精度
    uint public usdtDecimals = 18;//法币精度
    bool public buyswitch;//买入开关
    bool public sellswitch;//卖出开关

    address public vault;//兑换池
    address public allocationPool;//分配池
    uint256 public allocationPoolRatio;//分配池比率
    uint256 public allocationPoolFenPeiRatio;//每次拿出分配池结余的?%作为卡牌⾦额加权分
    uint256 public allocationPoolBalance;//分配池余额
    address public communityPool;//社区建设
    uint256 public communityRatio;//社区建设比率
    address public urbanPool;//城市建设池
    uint256 public urbanRatio;//城市建设比率
    address public statePool;//⽣态
    uint256 public stateRatio;//⽣态比率
    uint256 public directPushRatio;//直推比率

    address public initialinvitationaddress;//初始邀请地址
    mapping(address => address) public invitation;//邀请关系：地址 => 上级地址
    mapping(address => mapping(uint256 => uint256[5])) public pledgeinfo;//质押，用户地址 => tokenId => [0:已质押 1:可赎回 2:已赎回,激活额度,质押收益,质押时间,赎回时间]
    mapping(address => uint256[5]) public userBenefits;//用户收益[总收益，今日收益，已领取收益，待领取收益，我的算力]
    uint256 public networkPower;//全网算力

    mapping(string => address) public cfonftinfo;//cfonft合约信息：X Card => 0x

    constructor(address cfoAddr_, address usdtAddr_, address initialinvitationaddress_,
        uint256[7] memory a) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        cfoAddr = cfoAddr_;
        usdtAddr = usdtAddr_;
        initialinvitationaddress = initialinvitationaddress_;
        initialprice = a[0];
        price = a[0];
        unitmeasurement = a[1];
        swingprice = a[2];
        amplitudeincreasedecrease = a[3];
        triggermultiple = a[4];
        initialswingprice = a[2];
        max = a[5];
        min = a[6];
        // cfoDecimals =  IERC20(cfoAddr).decimals();
        // usdtDecimals =  IERC20(usdtAddr).decimals();
        buyswitch = true;
        sellswitch = true;
    }

    struct Tokenconfiguration {
        uint256 initialprice;//初始价格
        uint256 price; //现价
        uint256 unitmeasurement;//计量单位
        uint256 swingprice;//幅动价格
        uint256 amplitudeincreasedecrease;//幅动增减值
        uint256 triggermultiple;//触发倍数
        uint256 initialswingprice;//初始幅动价格
        uint256 max;//最大
        uint256 min;//最小
    }

    //更新cfonft合约信息：X
    function updateCfonftInfo(string memory nftName_,address nftAddr_) public onlyRole(DEFAULT_ADMIN_ROLE){
        cfonftinfo[nftName_] = nftAddr_;
    }

    //更新配置地址及分配比率
    function updateVault(address vault_,address allocationPool_,address communityPool_,address urbanPool_,address statePool_,
            uint256 allocationPoolRatio_,uint256 allocationPoolFenPeiRatio_,uint256 communityRatio_,uint256 urbanRatio_,uint256 stateRatio_,
            uint256 directPushRatio_) public onlyRole(DEFAULT_ADMIN_ROLE){
        vault = vault_;
        allocationPool = allocationPool_;
        communityPool = communityPool_;
        urbanPool = urbanPool_;
        statePool = statePool_;
        allocationPoolRatio = allocationPoolRatio_;
        allocationPoolFenPeiRatio = allocationPoolFenPeiRatio_;
        communityRatio = communityRatio_;
        urbanRatio = urbanRatio_;
        stateRatio = stateRatio_;
        directPushRatio = directPushRatio_;
    }

    //设置买卖开关
    function setSwitch(bool _buyswitch_,bool _sellswitch_) public onlyRole(DEFAULT_ADMIN_ROLE){
        buyswitch = _buyswitch_;
        sellswitch = _sellswitch_;
    }

    //设置用户收益
    function setUserBenefits(address myAddr_, uint256 income_) public onlyRole(DEFAULT_ADMIN_ROLE){
        userBenefits[myAddr_][0] = userBenefits[myAddr_][0] + income_;
        userBenefits[myAddr_][1] = userBenefits[myAddr_][1] + income_;
        userBenefits[myAddr_][3] = userBenefits[myAddr_][3] + income_;
    }

    //重置用户今日收益
    function sresetTodayUserBenefits(address myAddr_) public onlyRole(DEFAULT_ADMIN_ROLE){
        userBenefits[myAddr_][1] = 0;
    }

    //设置tokenId质押收益
    function setPledgeIncome(address myAddr_,uint256 tokenId_,uint256 pledgeIncome_) public onlyRole(DEFAULT_ADMIN_ROLE){
        pledgeinfo[myAddr_][tokenId_][2] = pledgeinfo[myAddr_][tokenId_][2] + pledgeIncome_;
    }

    //设置tokenId质押状态
    function setPledgeIncome(address myAddr_,uint256 tokenId_) public onlyRole(DEFAULT_ADMIN_ROLE){
        pledgeinfo[myAddr_][tokenId_][0] = 1;
        userBenefits[msg.sender][4] = userBenefits[msg.sender][4] - pledgeinfo[msg.sender][tokenId_][1];
    }

    function priceOf() external override view returns(uint256){
        return price;
    }

    function getParentAddr(address myAddr) external override view returns(address){
        return invitation[myAddr];
    }


    //设置基础设置
    function setBasic(uint256 _price_,uint256 _unitmeasurement_,uint256 _swingprice_,uint256 _amplitudeincreasedecrease_,uint256 _triggermultiple_) public onlyRole(DEFAULT_ADMIN_ROLE){
        price = _price_;
        unitmeasurement = _unitmeasurement_;
        swingprice = _swingprice_;
        amplitudeincreasedecrease = _amplitudeincreasedecrease_;
        triggermultiple = _triggermultiple_;
    }

    //设置交易量
    function setVolume(uint256 _max_,uint256 _min_) public onlyRole(DEFAULT_ADMIN_ROLE){
        max = _max_;
        min = _min_;
    }


    //按枚数购买算法
    function algorithmBuyNumber(uint256 _amount) public view returns (uint256,uint256,uint256) {
        Tokenconfiguration memory t = Tokenconfiguration(initialprice,price,unitmeasurement,swingprice,amplitudeincreasedecrease,triggermultiple,initialswingprice,max,min);
        require(_amount <= t.max && _amount >= t.min,"1");
        uint256 equal = _amount / t.unitmeasurement;
        uint256 usdt_sum = equal * (2 * t.price + t.swingprice * equal - t.swingprice) / 2;
        t.price = t.price + equal * t.swingprice;
        t.swingprice = t.swingprice + (t.price / t.initialprice / t.triggermultiple * t.amplitudeincreasedecrease - (t.swingprice - t.initialswingprice));
        return (usdt_sum,t.swingprice,t.price);
    }

    //按枚数卖出算法
    function algorithmSellNumber(uint256 _amount) public view returns (uint256,uint256,uint256) {
        Tokenconfiguration memory t = Tokenconfiguration(initialprice,price,unitmeasurement,swingprice,amplitudeincreasedecrease,triggermultiple,initialswingprice,max,min);
        require(_amount <= t.max && _amount >= t.min,"1");
        uint256 usdt_sum = 0;
        uint256 equal = 0;
        if(t.price > t.initialprice){
            equal = (t.price - t.swingprice - t.initialprice) / t.swingprice;
        }
        uint256 a = equal * t.unitmeasurement;
        if(_amount <= a){
            equal = _amount / t.unitmeasurement;
            usdt_sum = equal * (2 * t.price + t.swingprice * equal - t.swingprice) / 2;
            t.price = t.price - equal * t.swingprice;
            t.swingprice = t.swingprice - (t.swingprice - t.initialswingprice - t.price / t.initialprice / t.triggermultiple * t.amplitudeincreasedecrease);
        }else {
            usdt_sum =equal * (2 * t.price + t.swingprice * equal - t.swingprice) / 2;
            equal = (_amount - a) / t.unitmeasurement;
            usdt_sum = usdt_sum +  equal * t.initialprice;
            t.price = t.initialprice;
            t.swingprice = t.initialswingprice;
        }
        return (usdt_sum,t.swingprice,t.price);
    }

    //按USDT购买算法
    function usdtBuyNumber(uint256 _amount) public view returns (uint256,uint256,uint256) {
        Tokenconfiguration memory t = Tokenconfiguration(initialprice,price,unitmeasurement,swingprice,amplitudeincreasedecrease,triggermultiple,initialswingprice,max,min);
        require(_amount <= t.max && _amount >= t.min,"1");
        uint256 a = t.price / t.swingprice - 1;
        uint256 equal = Math.sqrt(_amount * 2 / t.swingprice + a * a) - a;
        //计算枚数
        uint256 token_sum = equal * t.unitmeasurement;
        t.price = t.price + equal * t.swingprice;
        t.swingprice = t.initialswingprice + ((t.price / t.initialprice) / t.triggermultiple * t.amplitudeincreasedecrease);
        return (token_sum,t.swingprice,t.price);
    }

    //按USDT卖出算法
    function usdtSellNumber(uint256 _amount) public view returns (uint256,uint256,uint256) {
        Tokenconfiguration memory t = Tokenconfiguration(initialprice,price,unitmeasurement,swingprice,amplitudeincreasedecrease,triggermultiple,initialswingprice,max,min);
        require(_amount <= t.max && _amount >= t.min,"1");
        uint256 equal = 0;
        if(t.price > t.initialprice){
            equal = (t.price - t.swingprice - t.initialprice) / t.swingprice;
        }
        uint256 v =equal * (2 * t.price + t.swingprice * equal - t.swingprice) / 2;
        uint256 token_sum = 0;
        if(_amount <= v){
            uint256 a = t.price / t.swingprice - 1;
            equal = Math.sqrt(_amount * 2 / t.swingprice + a * a) - a;
            //计算枚数
            token_sum = equal * t.unitmeasurement;
            t.price = t.price - equal * t.swingprice;
            t.swingprice = t.initialswingprice - ((t.price / t.initialprice) / t.triggermultiple * t.amplitudeincreasedecrease);
        }else {
            t.price = t.initialprice;
            t.swingprice = t.initialswingprice;
            // //计算枚数
            token_sum = equal * t.unitmeasurement;
            token_sum = token_sum + (_amount - v) / t.initialprice * t.unitmeasurement;
        }
        return (token_sum,t.swingprice,t.price);
    }

    //交易,status_b[true：按枚，flase：按USDT],status_t[true：买入，flase：卖出]
    function swap(bool status_b, bool status_t,uint256 _amount) public returns (uint256[4] memory) {
        address from = msg.sender;
        uint256 tokenSum;
        uint256 usdtSum;
        uint256 m;
        uint256 n;
        uint256 z;
        address thisAddr = address(this);
        if(status_b){
            require(buyswitch,"0");
            require(_amount < max && _amount > min,"3");
            require(_amount % unitmeasurement == 0,"4");
            if(status_t){
                (m,n,z) = algorithmBuyNumber(_amount);
                require(IERC20(cfoAddr).balanceOf(thisAddr) >= _amount,"5");
                IERC20(usdtAddr).transferFrom(from, thisAddr, m * (10 ** usdtDecimals) / (10 ** cfoDecimals));
                IERC20(cfoAddr).transfer(from,_amount);
                tokenSum = _amount;
                usdtSum = m * (10 ** usdtDecimals) / (10 ** cfoDecimals);
            }else{
                (m,n,z) = algorithmSellNumber(_amount);
                require(IERC20(usdtAddr).balanceOf(thisAddr) >= m,"5");
                IERC20(cfoAddr).transferFrom(from, thisAddr, _amount);
                IERC20(usdtAddr).transfer(from,m * (10 ** usdtDecimals) / (10 ** cfoDecimals));
                tokenSum = _amount;
                usdtSum = m * (10 ** usdtDecimals) / (10 ** cfoDecimals);
            }
        }else{
            require(sellswitch,"7");
            require(_amount < max && _amount > min,"8");
            require(_amount % unitmeasurement == 0,"9");
            if(status_t){
                (m,n,z) = usdtBuyNumber(_amount);
                require(IERC20(cfoAddr).balanceOf(thisAddr) >= m,"10");
                IERC20(usdtAddr).transferFrom(from, thisAddr, _amount * (10 ** usdtDecimals) / (10 ** cfoDecimals));
                IERC20(cfoAddr).transfer(from,m);
                tokenSum = m;
                usdtSum = _amount * (10 ** usdtDecimals) / (10 ** cfoDecimals);
            }else{
                (m,n,z) = usdtSellNumber(_amount);
                require(IERC20(cfoAddr).balanceOf(thisAddr) >= _amount,"11");
                IERC20(cfoAddr).transferFrom(from, thisAddr, m);
                IERC20(usdtAddr).transfer(from, _amount * (10 ** usdtDecimals) / (10 ** cfoDecimals));
                tokenSum = m;
                usdtSum = _amount * (10 ** usdtDecimals) / (10 ** cfoDecimals);
            }
        }
        uint256 inprice = price;
        swingprice = n;
        price = z;
        return [tokenSum,usdtSum,z,inprice];
    }

    /*
     * @notice 赎回质押
     */
    function redeemPledge(address cardAddr,uint tokenId) public {
        require(pledgeinfo[msg.sender][tokenId][0] == 1, "1");
        pledgeinfo[msg.sender][tokenId][0] = 2;
        pledgeinfo[msg.sender][tokenId][4] = block.timestamp;
        IERC721(cardAddr).transferFrom(address(this),msg.sender, tokenId);
    }

    event Pledge(address cardAddr_,uint256 tokenId_,uint256 activateForce_,uint256 timestamp_);
    event PledgeSwap(address myAddr_,uint256 tokenSum,uint256 usdtSum,uint256 price,uint256 inprice);

    /*
     * @notice 质押
     */
    function pledge(address cardAddr,uint tokenId) public {
        ICFONFT(cardAddr).pledge(msg.sender,tokenId);
        pledgeinfo[msg.sender][tokenId][0] = 0;
        pledgeinfo[msg.sender][tokenId][1] = ICFONFT(cardAddr).priceOf() * ICFONFT(cardAddr).conditionsOf() / 100;
        pledgeinfo[msg.sender][tokenId][2] = 0;
        pledgeinfo[msg.sender][tokenId][3] = block.timestamp;
        pledgeinfo[msg.sender][tokenId][4] = 0;
        userBenefits[msg.sender][4] = userBenefits[msg.sender][4] + pledgeinfo[msg.sender][tokenId][1];
        uint256[4] memory a = pledgeSwap(ICFONFT(cardAddr).priceOf());
        emit Pledge(cardAddr,tokenId,pledgeinfo[msg.sender][tokenId][1],pledgeinfo[msg.sender][tokenId][3]);
        emit PledgeSwap(msg.sender,a[0],a[1],a[2],a[3]);
    }

    

    function pledgeSwap(uint256 _amount) internal returns (uint256[4] memory) {
        uint256 tokenSum;
        uint256 usdtSum;
        uint256 m;
        uint256 n;
        uint256 z;
        (m,n,z) = usdtBuyNumber(_amount);
        tokenSum = m;
        usdtSum = _amount * (10 ** usdtDecimals) / (10 ** cfoDecimals);
        uint256 inprice = price;
        swingprice = n;
        price = z;
        //资产分配
        if(allocationPool != address(0)){
            IERC20(cfoAddr).transferFrom(vault,allocationPool, usdtSum * allocationPoolRatio / 100);
        }
        if(communityPool != address(0)){
            IERC20(cfoAddr).transferFrom(vault,communityPool, usdtSum * communityRatio / 100);
        }
        if(urbanPool != address(0)){
            IERC20(cfoAddr).transferFrom(vault,urbanPool, usdtSum * urbanRatio / 100);
        }
        if(statePool != address(0)){
            IERC20(cfoAddr).transferFrom(vault,statePool, usdtSum * stateRatio / 100);
        }
        if(invitation[msg.sender] != address(0)){
            IERC20(cfoAddr).transferFrom(vault,invitation[msg.sender], usdtSum * directPushRatio / 100);
        }
        return [tokenSum,usdtSum,z,inprice];
    }

    //领取奖励
    function receiveAward(uint256 amount_) public{
        address from = msg.sender;
        require(amount_ > uint256(0),"1");
        require(userBenefits[from][3] > amount_,"2");
        userBenefits[from][2] = userBenefits[from][2] + amount_;
        userBenefits[from][3] = userBenefits[from][3] - amount_;
        IERC20(cfoAddr).transferFrom(allocationPool,from, amount_);
    }

    event Blind(address mySddr,address parentAddr);

    //绑定邀请
    function blind(address parentAddr) public{
        require(parentAddr != address(0), "1"); // 不允许上级地址为0地址
        require(parentAddr != msg.sender, "2");// 不允许自己的上级是自己
        // 验证要绑定的上级是否有上级，只有有上级的用户，才能被绑定为上级（firstAddress除外）。如果没有此验证，那么就可以随意拿一个地址绑定成上级了
        require(invitation[parentAddr] != address(0) || parentAddr == initialinvitationaddress, "3");
        require(invitation[msg.sender] == address(0), "4");
        invitation[msg.sender] = parentAddr;
        emit Blind(msg.sender,parentAddr);
    }
}