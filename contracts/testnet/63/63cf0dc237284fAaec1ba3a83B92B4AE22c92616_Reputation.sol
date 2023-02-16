/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

// Sources flattened with hardhat v2.12.6 https://hardhat.org

// File @openzeppelin/contracts/utils/introspection/[email protected]

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


// File @openzeppelin/contracts/utils/introspection/[email protected]

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


// File @openzeppelin/contracts/utils/math/[email protected]

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


// File @openzeppelin/contracts/utils/[email protected]

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


// File contracts/interfaces/ISoulBound.sol

pragma solidity ^0.8.0;

interface ISoulBound is IERC165 {
    /**
     * @dev Emitted when `soulboundId` of a soulbound token is minted and linked to `owner`
     */
    event Issued(uint256 indexed soulboundId, address indexed owner);

    /**
     * @dev Emitted when `soulboundId` of a soulbound token is unlinked from `owner`
     */
    event Revoked(uint256 indexed soulboundId, address indexed owner);

    /**
     * @dev Emitted when `soulboundId` of a soulbound token is:
     * unlinked with `from` and linked to `to`
     */
    event Changed(
        uint256 indexed soulboundId,
        address indexed from,
        address indexed to
    );

    /**
     * @dev Emitted when `soulboundId` of a soulbound token is transferred from:
     * address(0) to `to` OR `to` to address(0)
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed soulboundId
    );

    /**
     * @dev Returns the total number of SoulBound tokens has been released
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the owner of the `soulboundId` token.
     * Requirements:
     * - `soulboundId` must exist.
     */
    function ownerOf(uint256 soulboundId) external view returns (address owner);

    /**
     * @dev Returns the soulboundId of the `owner`.
     * Requirements:
     * - `owner` must own a soulbound token.
     */
    function tokenOf(address owner) external view returns (uint256);

    /**
       	@notice Get total number of accounts that linked to `soulboundId`
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
    */
    function numOfLinkedAccounts(
        uint256 soulboundId
    ) external view returns (uint256);

    /**
       	@notice Get accounts that linked to `soulboundId`
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
        @param	fromIndex				Starting index of query range
        @param	toIndex				    Ending index of query range
    */
    function linkedAccounts(
        uint256 soulboundId,
        uint256 fromIndex,
        uint256 toIndex
    ) external view returns (address[] memory accounts);

    /**
       	@notice Checking if `soulboundId` is assigned, but revoked
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
    */
    function isRevoked(uint256 soulboundId) external view returns (bool);
}


// File contracts/interfaces/IERC721Metadata.sol

pragma solidity ^0.8.0;

interface IERC721Metadata is ISoulBound {
    /**
     * @dev Returns the SoulBound Token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the SoulBound Token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}


// File contracts/interfaces/IManagement.sol

pragma solidity ^0.8.0;

interface IManagement {
    /**
       	@notice Get address of Treasury
       	@dev  Caller can be ANY
    */
    function treasury() external view returns (address);

    /**
       	@notice Verify `role` of `account`
       	@dev  Caller can be ANY
        @param	role				    Bytes32 hash role
        @param	account				Address of `account` that needs to check `role`
    */
    function hasRole(
        bytes32 role,
        address account
    ) external view returns (bool);

    /**
       	@notice Get status of `paused`
       	@dev  Caller can be ANY
    */
    function paused() external view returns (bool);

    /**
       	@notice Checking whether `account` is blacklisted
       	@dev  Caller can be ANY
        @param	account				Address of `account` that needs to check
    */
    function blacklist(address account) external view returns (bool);

    /**
       	@notice Checking whether `account` is whitelisted
       	@dev  Caller can be ANY
        @param	account				Address of `account` that needs to check
    */
    function whitelist(address account) external view returns (bool);
}


// File @openzeppelin/contracts/utils/structs/[email protected]

// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

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
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
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
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
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
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
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

        /// @solidity memory-safe-assembly
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
     * @dev Returns the number of values in the set. O(1).
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

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}


// File contracts/interfaces/IAttribute.sol

pragma solidity ^0.8.0;

interface IAttribute {
    /**
     * @dev Emitted when `attributedId` is registered for one `soulbound`
     */
    event Set(address indexed soulbound, uint256 indexed attributeId);

    /**
     * @dev Emitted when `attributedId` is removed out of one `soulbound`
     */
    event Removed(address indexed soulbound, uint256 indexed attributeId);

    /**
       	@notice Check whether `_attributeId` exists
       	@dev  Caller can be ANY
        @param	attributeId				    Number ID of Attribute type
    */
    function isValidAttribute(
        uint256 attributeId
    ) external view returns (bool);

    /**
       	@notice Get size of Attributes currently available
       	@dev  Caller can be ANY
    */
    function numOfAttributes() external view returns (uint256);

    /**
       	@notice Get a list of available Attributes
       	@dev  Caller can be ANY
        @param	fromIdx				    Starting index in a list
        @param	toIdx				        Ending index in a list
    */
    function listOfAttributes(
        uint256 fromIdx,
        uint256 toIdx
    ) external view returns (uint256[] memory attributeIds);

    /**
       	@notice Retrieve Attribute's URI of `_soulboundId`
       	@dev  Caller can be ANY
        @param	soulboundId				    Soulbound Id
        @param	attributeId				    Number ID of Attribute type
    */
    function attributeURI(
        uint256 soulboundId,
        uint256 attributeId
    ) external view returns (string memory);
}


// File contracts/utils/Attribute.sol

pragma solidity ^0.8.0;



contract Attribute is IAttribute {
    using EnumerableSet for EnumerableSet.UintSet;
    using Strings for uint256;

    //  A set of available Attributes
    EnumerableSet.UintSet private attributes_;

    /**
       	@notice Check whether `_attributeId` exists
       	@dev  Caller can be ANY
        @param	attributeId				    Number ID of Attribute type
    */
    function isValidAttribute(
        uint256 attributeId
    ) public view virtual override returns (bool) {
        return _attribute().contains(attributeId);
    }

    /**
       	@notice Get size of Attributes currently available
       	@dev  Caller can be ANY
    */
    function numOfAttributes()
        external
        view
        virtual
        override
        returns (uint256)
    {
        return _attribute().length();
    }

    /**
       	@notice Get a list of available Attributes
       	@dev  Caller can be ANY
        @param	fromIdx				    Starting index in a list
        @param	toIdx				        Ending index in a list
    */
    function listOfAttributes(
        uint256 fromIdx,
        uint256 toIdx
    ) external view virtual override returns (uint256[] memory attributeIds) {
        EnumerableSet.UintSet storage list = _attribute();
        uint256 len = toIdx - fromIdx + 1;
        attributeIds = new uint256[](len);

        for (uint256 i; i < len; i++)
            attributeIds[i] = list.at(fromIdx + i);
    }

    /**
       	@notice Retrieve Attribute's URI of `_soulboundId`
       	@dev  Caller can be ANY
        @param	soulboundId				    Soulbound Id
        @param	attributeId				    Number ID of Attribute type
    */
    function attributeURI(
        uint256 soulboundId,
        uint256 attributeId
    ) external view virtual override returns (string memory) {
        require(isValidAttribute(attributeId), "Attribute not recorded");

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0 ?
                string(
                    abi.encodePacked(
                        _baseURI(),
                        soulboundId.toString(),
                        "/",
                        attributeId.toString()
                    )
                )
                : "";
    }

    function _setAttribute(uint256 attributeId) internal virtual {
        require(!isValidAttribute(attributeId), "Attribute already set");
        _attribute().add(attributeId);

        emit Set(address(this), attributeId);
    }

    function _removeAttribute(uint256 attributeId) internal virtual {
        require(isValidAttribute(attributeId), "Attribute not recorded");
        _attribute().remove(attributeId);

        emit Removed(address(this), attributeId);
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    function _attribute() private view returns (EnumerableSet.UintSet storage) {
        return attributes_;
    }
}


// File contracts/interfaces/ISoulBoundMintable.sol

pragma solidity ^0.8.0;

interface ISoulBoundMintable {
    /**
       	@notice Assign `soulboundId` to `owner`
       	@dev  Caller must have Minter role
		    @param	owner				        Address of soulbound's owner
        @param	soulboundId				Soulbound id

        Note: One `owner` is assigned ONLY one `soulboundId` that binds to off-chain profile
    */
    function issue(address owner, uint256 soulboundId) external;

    /**
       	@notice Unlink `soulboundId` to its `owner`
       	@dev  Caller must have Minter role
        @param	soulboundId				Soulbound id

        Note: After revoke, the update is:
        - `soulboundId` -> `owner` is unlinked, but
        - `owner` -> `soulboundId` is still linked
    */
    function revoke(uint256 soulboundId) external;

    /**
       	@notice Change `soulboundId` to new `owner`
       	@dev  Caller must have Minter role
        @param	soulboundId				Soulbound id
        @param	from				        Address of a current `owner`
        @param	to				            Address of a new `owner`

        Note: Change address from `from` to `to` does not mean ownership transfer
        Instead, it indicates which account is currently set as Primary
        Using `linkedAccounts()` can query all accounts that are linked to `soulboundId`
    */
    function change(uint256 soulboundId, address from, address to) external;
}


// File @openzeppelin/contracts/token/ERC721/[email protected]

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
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


// File @openzeppelin/contracts/utils/[email protected]

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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


// File @openzeppelin/contracts/utils/[email protected]

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


// File contracts/utils/SoulBound.sol

pragma solidity ^0.8.0;








contract SoulBound is Context, ERC165, ISoulBound, IERC721Metadata {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;
    using Strings for uint256;

    //  Total SoulBound tokens have been released
    uint256 private _totalSupply;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to last owner address and its status
    mapping(uint256 => address) private _owners;

    // Mapping from owner address to token ID
    mapping(address => uint256) private _tokens;

    // Mapping a list of revoked token ID
    mapping(uint256 => bool) private _revoked;

    // Archive list of token ID to owner addresses
    mapping(uint256 => EnumerableSet.AddressSet) private _archives;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(ISoulBound).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC721Receiver).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
       	@notice Get name of SoulBound Token
       	@dev  Caller can be ANY
    */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
       	@notice Get symbol of SoulBound Token
       	@dev  Caller can be ANY
    */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
       	@notice Get total minted SoulBound tokens
       	@dev  Caller can be ANY
    */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
       	@notice Get owner of `soulboundId`
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
    */
    function ownerOf(
        uint256 soulboundId
    ) public view virtual override returns (address) {
        address owner = _ownerOf(soulboundId);
        require(owner != address(0), "SoulBound: invalid soulbound ID");
        
        return owner;
    }

    /**
       	@notice Get current `soulboundId` that is assigned to `owner`
       	@dev  Caller can be ANY
        @param	owner				Address of querying account
    */
    function tokenOf(
        address owner
    ) external view virtual override returns (uint256) {
        require(owner != address(0), "SoulBound: address zero is not a valid owner");
        (uint256 soulboundId, bool assigned) = _isAssigned(owner);
        require(assigned, "SoulBound: account not yet assigned a soulbound");

        return soulboundId;
    }

    /**
       	@notice Get URI of `soulboundId`
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
    */
    function tokenURI(
        uint256 soulboundId
    ) public view virtual override returns (string memory) {
        _requireMinted(soulboundId);

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, soulboundId.toString()))
                : "";
    }

    /**
       	@notice Get total number of accounts that linked to `soulboundId`
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
    */
    function numOfLinkedAccounts(
        uint256 soulboundId
    ) external view virtual override returns (uint256) {
        return _numOfLinkedAccounts(soulboundId);
    }

    /**
       	@notice Get accounts that linked to `soulboundId`
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
        @param	fromIndex				Starting index of query range
        @param	toIndex				    Ending index of query range
    */
    function linkedAccounts(
        uint256 soulboundId,
        uint256 fromIndex,
        uint256 toIndex
    ) external view virtual override returns (address[] memory accounts) {
        uint256 len = toIndex - fromIndex + 1;
        accounts = new address[](len);

        for (uint256 i; i < len; i++)
            accounts[i] = _linkedAccountAt(soulboundId, fromIndex + i);
    }

    /**
       	@notice Checking if `soulboundId` is assigned, but revoked
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
    */
    function isRevoked(uint256 soulboundId) public view virtual override returns (bool) {
        return _revoked[soulboundId];
    }

    function _issue(address owner, uint256 soulboundId) internal virtual {
        _safeMint(owner, soulboundId);

        emit Issued(soulboundId, owner);
    }

    function _revoke(uint256 soulboundId) internal virtual {
        address owner = ownerOf(soulboundId);
        _revokeOwnership(owner, soulboundId);

        emit Revoked(soulboundId, owner);
    }
    /**
        Requirements to change `soulboundId` between two accounts - `from` and `to`
        - `soulboundId` is currently active (minted and not revoked)
        - `soulboundId` must be owned by `from`
        - `to`:
            - Should not yet assigne to any soulbound
            - If assigned, that assigned soulbound, that linked to `to`, must have Id that matches `soulboundId`
        Note: 
            - Contract cannot verify that `from` and `to` has relationship to soulbound's owner
            thus, this operation must be executed by Authorizer and it must go through a process of verification
    */
    function _change(
        uint256 soulboundId,
        address from,
        address to
    ) internal virtual {
        address owner = ownerOf(soulboundId);
        require(owner == from, "SoulBound: soulbound not owned by owner");
        (uint256 prevId, bool assigned) = _isAssigned(to);
        require(
            !assigned || (assigned && prevId == soulboundId),
            "SoulBound: account already assigned a different soulbound"
        );
        _revokeOwnership(owner, soulboundId);
        _reset(soulboundId);

        require(
            _checkOnERC721Received(address(0), to, soulboundId, ""),
            "SoulBound: transfer to non ERC721Receiver implementer"
        );
        _setOwnership(to, soulboundId);

        emit Changed(soulboundId, from, to);
    }

    /**
     * @dev Safely mints `soulboundId` and transfers it to `to`.
     * Requirements:
     * - `soulboundId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 soulboundId) internal virtual {
        _safeMint(to, soulboundId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 soulboundId,
        bytes memory data
    ) internal virtual {
        _mint(to, soulboundId);
        require(
            _checkOnERC721Received(address(0), to, soulboundId, data),
            "SoulBound: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `soulboundId` and transfers it to `to`.
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     * Requirements:
     * - `soulboundId` must not exist.
     * - `to` cannot be the zero address.
     * - `to` must not own any soulbound tokens or `soulboundId` must be the same as previous one
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 soulboundId) internal virtual {
        require(to != address(0), "SoulBound: mint to the zero address");

        //  Two possible cases makes `!_exists(soulboundId) = true`:
        //  - `soulboundId` not minted yet
        //  - `soulboundId` has been revoked
        //  if revoked, must check whether `_archives[soulboundId]` contains `to`
        //  else, must check `to` not yet linked to any soulbound
        require(!_exists(soulboundId), "SoulBound: token already minted");
        if (isRevoked(soulboundId)) {
            require(
                _contain(soulboundId, to), "SoulBound: revoked soulbound not contain the account"
            );
            _reset(soulboundId);
        }
        else {
            ( , bool assigned) = _isAssigned(to);
            require(!assigned, "SoulBound: account already assigned a soulbound");
        }
        _setOwnership(to, soulboundId);
    }

    /**
     * @dev Destroys `soulboundId`.
     * Requirements:
     * - `soulboundId` must exist.
     * Emits a {Transfer} event.
     */
    function _burn(uint256 soulboundId) internal virtual {
        address owner = ownerOf(soulboundId);
        _revokeOwnership(owner, soulboundId);
    }

    function _setOwnership(address to, uint256 soulboundId) internal virtual {
        _beforeTokenTransfer(address(0), to, soulboundId);

        // update current ownership of `soulboundId`
        // link `soulboundId` to `to`. Unable to unlink even soulbound token is revoked/burned
        // update `archives` list
        _owners[soulboundId] = to;
        _tokens[to] = soulboundId;
        _getArchive(soulboundId).add(to);
        _totalSupply++;

        emit Transfer(address(0), to, soulboundId);

        _afterTokenTransfer(address(0), to, soulboundId);
    }

    function _revokeOwnership(address owner, uint256 soulboundId) internal virtual {
        _beforeTokenTransfer(owner, address(0), soulboundId);

        //  when soulbound is revoked/burned, only remove connection between `soulboundId` and `owner` in the `_owners` mapping
        //  and mark `_revoked[soulboundId] = true`
        //  `_archives`, and `_tokens` mappings remain unchanged
        delete _owners[soulboundId];
        _totalSupply--;
        _revoked[soulboundId] = true;

        emit Transfer(owner, address(0), soulboundId);

        _afterTokenTransfer(owner, address(0), soulboundId);
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev Reverts if the `soulboundId` has not been minted yet.
     */
    function _requireMinted(uint256 soulboundId) internal view virtual {
        require(_exists(soulboundId), "SoulBound: invalid soulbound ID");
    }

    function _exists(uint256 soulboundId) internal view virtual returns (bool) {
        return _ownerOf(soulboundId) != address(0);
    }

    function _tokenOf(address owner) internal view virtual returns (uint256) {
        return _tokens[owner];
    }

    function _ownerOf(uint256 soulboundId) internal view virtual returns (address) {
        return _owners[soulboundId];
    }

    function _getArchive(uint256 soulboundId) internal view virtual returns (EnumerableSet.AddressSet storage) {
        return _archives[soulboundId];
    }

    function _contain(uint256 soulboundId, address account) internal view virtual returns (bool) {
        return _getArchive(soulboundId).contains(account);
    }

    function _reset(uint256 soulboundId) internal virtual {
        delete _revoked[soulboundId];
    }

    function _isAssigned(address account) internal view virtual returns (uint256 soulboundId, bool assigned) {
        //  Note: `account` must be non-zero address
        //  If tokenOf() returns:
        //  - non-zero -> `account` already assigned a soulbound
        //  - zero -> check whether `_archives[soulboundId = 0] contains `account`:
        //      - If yes -> return true
        //      - Otherwise -> return false
        soulboundId = _tokenOf(account);
        assigned = soulboundId == 0 ? _contain(soulboundId, account) : true;
    }

    function _numOfLinkedAccounts(
        uint256 soulboundId
    ) internal view virtual returns (uint256) {
        return _getArchive(soulboundId).length();
    }

    function _linkedAccountAt(
        uint256 soulboundId,
        uint256 index
    ) internal view virtual returns (address) {
        uint256 _totalLinkedAccounts = _numOfLinkedAccounts(soulboundId);
        require(
            _totalLinkedAccounts != 0,
            "SoulBound: id not linked to any accounts"
        );
        require(
            index <= _totalLinkedAccounts - 1,
            "SoulBound: index out of bounds"
        );

        return _getArchive(soulboundId).at(index);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 soulboundId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try
                IERC721Receiver(to).onERC721Received(
                    _msgSender(),
                    from,
                    soulboundId,
                    data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "SoulBound: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     * Calling conditions:
     * - When `from` and `to` are both non-zero, ``from``'s `soulboundId` will be
     * transferred to `to`.
     * - When `from` is zero, `soulboundId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `soulboundId` will be burned.
     * - `from` and `to` are never both zero.
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 soulboundId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     * Calling conditions:
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 soulboundId
    ) internal virtual {}
}


// File contracts/utils/SoulBoundMintable.sol

pragma solidity ^0.8.0;




contract SoulBoundMintable is SoulBound, Attribute, ISoulBoundMintable {
    bytes32 internal constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 internal constant MINTER_ROLE = keccak256("MINTER_ROLE");

    //  Address of Management contract
    IManagement public management;

    string private _uri;

    modifier hasRole(bytes32 role) {
        require(management.hasRole(role, _msgSender()), "Unauthorized");
        _;
    }

    modifier whenNotPause() {
        require(!management.paused(), "Paused");
        _;
    }

    constructor(
        IManagement management_,
        string memory name,
        string memory symbol,
        string memory uri
    ) SoulBound(name, symbol) Attribute() {
        management = management_;
        _uri = uri;
    }

    /**
       	@notice Update Address of Management contract
       	@dev  Caller must have MANAGER_ROLE
		    @param	management_				Address of new Management contract
    */
    function setManagement(
        address management_
    ) external virtual hasRole(MANAGER_ROLE) {
        require(Address.isContract(management_), "Must be a contract");
        management = IManagement(management_);
    }

    /**
       	@notice Update new string of `baseURI`
       	@dev  Caller must have MANAGER_ROLE
		    @param	uri				New string of `baseURI`
    */
    function setBaseURI(string calldata uri) external hasRole(MANAGER_ROLE) {
        _uri = uri;
    }

    /**
       	@notice Add/Remove the supporting Attributes in the SoulBound contract
       	@dev  Caller must have MANAGER_ROLE
		    @param	attributeId				  Number ID of Attribute type
        @param	isRemoved				    Boolean (Remove = true, Add = false)
    */
    function setAttribute(
        uint256 attributeId,
        bool isRemoved
    ) external hasRole(MANAGER_ROLE) {
        if (!isRemoved) _setAttribute(attributeId);
        else _removeAttribute(attributeId);
    }

    /**
       	@notice Assign `soulboundId` to `owner`
       	@dev  Caller must have MINTER_ROLE
		    @param	owner				        Address of soulbound's owner
        @param	soulboundId				  Soulbound id

        Note: One `owner` is assigned ONLY one `soulboundId` that binds to an off-chain profile
    */
    function issue(
        address owner,
        uint256 soulboundId
    ) external virtual override hasRole(MINTER_ROLE) {
        _issue(owner, soulboundId);
    }

    /**
       	@notice Unlink `soulboundId` to its `owner`
       	@dev  Caller must have MINTER_ROLE
        @param	soulboundId				Soulbound id

        Note: After revoke, the update is:
        - `soulboundId` -> `owner` is unlinked, but
        - `owner` -> `soulboundId` is still linked
    */
    function revoke(
        uint256 soulboundId
    ) external virtual override hasRole(MINTER_ROLE) {
        _revoke(soulboundId);
    }

    /**
       	@notice Change `soulboundId` to new `owner`
       	@dev  Caller must have MINTER_ROLE
        @param	soulboundId				Soulbound id
        @param	from				        Address of a current `owner`
        @param	to				          Address of a new `owner`

        Note: Change address from `from` to `to` does not mean ownership transfer
        Instead, it indicates which account is currently set as Primary
        Using `linkedAccounts()` can query all accounts that are linked to `soulboundId`
    */
    function change(
        uint256 soulboundId,
        address from,
        address to
    ) external virtual override hasRole(MINTER_ROLE) {
        _change(soulboundId, from, to);
    }

    function _baseURI()
        internal
        view
        override(SoulBound, Attribute)
        returns (string memory)
    {
        return _uri;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 soulboundId
    ) internal virtual override whenNotPause {
        super._beforeTokenTransfer(from, to, soulboundId);
    }
}


// File contracts/Reputation.sol

pragma solidity ^0.8.0;



contract Reputation is SoulBoundMintable {
    using EnumerableSet for EnumerableSet.UintSet;
    using Strings for uint256;

    struct Score {
        uint128 score;
        uint32 timestamp;
    }

    bytes32 private constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    uint256 private constant GENERAL_TYPE = 1;

    //  mapping of latest Reputation Scores (General + Category) per `soulboundId`
    mapping(uint256 => mapping(uint256 => Score)) private _latestAnswers;

    //  A list of Reputation Scores that `soulboundId` has (General Reputation Score by default)
    mapping(uint256 => EnumerableSet.UintSet) private _archives;

    /**
     * @dev Emitted when `operator` update latest Reputation Scores of `soulboundIds` by `attributeId`
     */
    event Respond(
        address indexed operator,
        uint256 indexed attributeId,
        uint256[] soulboundIds
    );

    /**
     * @dev Emitted when `operator` adds more Reputation Score in profile of `soulboundId`
     */
    event AttributeTo(
        address indexed operator,
        uint256 indexed soulboundId,
        uint256 indexed attributeId
    );

    modifier onlyWhitelist() {
        require(management.whitelist(_msgSender()), "Only whitelist");
        _;
    }

    modifier hasAttribute(uint256 soulboundId, uint256 attributeId) {
        require(
            isValidAttribute(attributeId) &&
                existAttributeOf(soulboundId, attributeId),
            "Attribute not exist in this soulbound"
        );
        _;
    }

    constructor(
        IManagement management_,
        string memory name,
        string memory symbol,
        string memory uri
    ) SoulBoundMintable(management_, name, symbol, uri) {
        _setAttribute(GENERAL_TYPE);
    }

    /**
       	@notice Assign `soulboundId` to `owner`
       	@dev  Caller must have MINTER_ROLE
		    @param	owner				        Address of soulbound's owner
        @param	soulboundId				  Soulbound id

        Note: 
        - One `owner` is assigned ONLY one `soulboundId` that binds to an off-chain profile
        - Override the method of `SoulBoundMintable` to add General Reputation Score as the default attribute to `soulboundId`
    */
    function issue(
        address owner,
        uint256 soulboundId
    ) external virtual override(SoulBoundMintable) hasRole(MINTER_ROLE) {
        _getArchiveOf(soulboundId).add(GENERAL_TYPE);
        super._issue(owner, soulboundId);
    }

    /**
       	@notice Add new `attributeId` as Reputation Score of `soulboundId`
       	@dev  Caller must have OPERATOR_ROLE
        @param	soulboundId				Soulbound Id
        @param	attributeId				Attribute ID of Reputation Score

        Note: 
        - This method is designed to be called by Service/Minter/Helper contract
            + In Service contract:
                - Owner of `soulboundId` requests to add Category Reputation Score in his/her profile.
                However, for easy extendability and flexibility, Service contract can be set as OPERATOR_ROLE
                so that authorized clients could also call this method
            + In Minter/Helper contract:
                - General Reputation Score will be added in the `soulboundId` profile (as default)
        - If method is called by Authorized Clients (EOA), make sure `soulboundId` is currently active
    */
    function addAttributeOf(
        uint256 soulboundId,
        uint256 attributeId
    ) external hasRole(OPERATOR_ROLE) {
        require(isValidAttribute(attributeId), "Attribute not supported");
        require(
            !existAttributeOf(soulboundId, attributeId),
            "Attribute added already to the Soulbound"
        );

        _getArchiveOf(soulboundId).add(attributeId);

        emit AttributeTo(_msgSender(), soulboundId, attributeId);
    }

    /**
       	@notice Update latest General/Category Reputation Scores of `soulboundIds`
       	@dev  Caller must have OPERATOR_ROLE
        @param	attributeId				  Attribute ID of Reputation Score
        @param	soulboundIds				A list of `soulboundId`
        @param	scores				      A list of latest scores that corresponding to each `soulboundId` respectively

        Note: 
        - Make sure OPERATOR_ROLE check that Reputation Score, `attributeId`, exists in each of the `soulboundId`
    */
    function fulfill(
        uint256 attributeId,
        uint256[] calldata soulboundIds,
        uint256[] calldata scores
    ) external hasRole(OPERATOR_ROLE) {
        uint256 len = soulboundIds.length;
        require(scores.length == len, "Length mismatch");
        require(isValidAttribute(attributeId), "Attribute not supported");

        uint32 timestamp = uint32(block.timestamp);
        uint256 soulboundId;
        for (uint256 i; i < len; i++) {
            soulboundId = soulboundIds[i];
            _requireMinted(soulboundId);
            _latestAnswers[soulboundId][attributeId] = Score({
                score: uint128(scores[i]),
                timestamp: timestamp
            });
        }

        emit Respond(_msgSender(), attributeId, soulboundIds);
    }

    /**
       	@notice Get size of Reputation Score list that `soulboundId` has
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
    */
    function sizeOf(uint256 soulboundId) external view returns (uint256) {
        return _getArchiveOf(soulboundId).length();
    }

    /**
       	@notice Get Reputation Score list that `soulboundId` has
       	@dev  Caller can be ANY
        @param	soulboundId				  Soulbound Id
        @param	fromIdx				      Starting index in a list
        @param	toIdx				        Ending index in a list
    */
    function listOf(
        uint256 soulboundId,
        uint256 fromIdx,
        uint256 toIdx
    ) external view returns (uint256[] memory attributeIds) {
        EnumerableSet.UintSet storage _list = _getArchiveOf(soulboundId);
        uint256 len = toIdx - fromIdx + 1;
        attributeIds = new uint256[](len);

        for (uint256 i; i < len; i++)
            attributeIds[i] = _list.at(fromIdx + i);
    }

    /**
       	@notice Query URL link to get Reputation Score metadata (General and Category)
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
        @param	attributeId				Attribute ID of Reputation Score
    */
    function attributeURI(
        uint256 soulboundId,
        uint256 attributeId
    )
        external
        view
        override(Attribute)
        hasAttribute(soulboundId, attributeId)
        returns (string memory)
    {
        //  If soulbound not yet minted -> hasAttribute throws error
        //  If soulbound minted, but not configured `attributeId` -> hasAttribute throws error
        //  If soulbound minted and configured `attributeId`, then revoked -> hasAttribute would not throw error
        //  thus, must check `_requireMinted()` to make sure `soulboundId` is currently available
        _requireMinted(soulboundId);

        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    soulboundId.toString(),
                    "/",
                    attributeId.toString()
                )
            );
    }

    /**
       	@notice Get latest Reputation Scores of `soulboundId`
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
        @param	attributeId				Attribute ID of Reputation Score
    */
    function latestAnswer(
        uint256 soulboundId,
        uint256 attributeId
    )
        external
        view
        hasAttribute(soulboundId, attributeId)
        returns (uint256 score, uint256 lastUpdate)
    {
        //  Similarly as attributeURI(), must check `_requireMinted()` to make sure `soulboundId` is currently available
        _requireMinted(soulboundId);

        score = _latestAnswers[soulboundId][attributeId].score;
        lastUpdate = _latestAnswers[soulboundId][attributeId].timestamp;
    }

    /**
       	@notice Check whether a list of `soulboundIds` exists
       	@dev  Caller can be ANY
        @param	soulboundIds				A list of `soulboundId`
    */
    function exist(
        uint256[] calldata soulboundIds
    ) external view returns (bool) {
        uint256 len = soulboundIds.length;
        for (uint256 i; i < len; i++) {
            if (!_exists(soulboundIds[i])) return false;
        }
        return true;
    }

    /**
       	@notice Check whether `soulboundId` contains `attributeId` as the Reputation Score
       	@dev  Caller can be ANY
        @param	soulboundId				Soulbound Id
        @param	attributeId				Attribute ID of Reputation Score
    */
    function existAttributeOf(
        uint256 soulboundId,
        uint256 attributeId
    ) public view returns (bool) {
        return _getArchiveOf(soulboundId).contains(attributeId);
    }

    function _getArchiveOf(
        uint256 soulboundId
    ) private view returns (EnumerableSet.UintSet storage) {
        return _archives[soulboundId];
    }
}