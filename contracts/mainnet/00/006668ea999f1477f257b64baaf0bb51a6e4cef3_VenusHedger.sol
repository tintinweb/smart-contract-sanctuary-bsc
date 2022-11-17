// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { Strings } from 'openzeppelin-contracts/utils/Strings.sol';
import { Ownable } from 'openzeppelin-contracts/access/Ownable.sol';
import { EnumerableSet } from 'openzeppelin-contracts/utils/structs/EnumerableSet.sol';
// import { console } from 'forge-std/console.sol';

// https://github.com/VenusProtocol/venus-protocol/blob/develop/contracts/VToken.sol
// https://github.com/VenusProtocol/venus-protocol/blob/develop/contracts/Comptroller.sol

// import { EasyMath } from './library/EasyMath.sol';
import { PriceOracle } from './interfaces/Venus/PriceOracle.sol';
import { VBep20Interface, VTokenInterface } from './interfaces/Venus/VTokenInterfaces.sol';
import { EIP20NonStandardInterface } from './interfaces/Venus/EIP20NonStandardInterface.sol';
import { ComptrollerInterface } from './interfaces/Venus/ComptrollerInterface.sol';
// import { IPancakeRouter01 } from './interfaces/Venus/PancakeStuff.sol';
import { IERC20Detailed } from './interfaces/tokens/IERC20Detailed.sol';
import { IParaSwapAugustus } from './external/paraswap/IParaSwapAugustus.sol';
import { Config } from './components/Config.sol';

contract VenusHedger is Ownable {
	using EnumerableSet for EnumerableSet.AddressSet;

	VBep20Interface constant internal vUSDC = VBep20Interface(0xecA88125a5ADbe82614ffC12D0DB554E2e2867C8);
	EIP20NonStandardInterface immutable internal USDC = EIP20NonStandardInterface(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d); // underlying of vUSDC

	IParaSwapAugustus public paraswap = IParaSwapAugustus(0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57); // proxy (don't need to approve this addr for tokens)

	address public paraswapTokenProxy; // token transfer proxy (need to approve this addr for tokens)

	ComptrollerInterface constant internal comptroller = ComptrollerInterface(0xfD36E2c2a6789Db23113685031d7F16329158384); // Unitroller proxy for comptroller

	PriceOracle constant internal oracle = PriceOracle(0xd8B6dA2bfEC71D684D3E2a2FC9492dDad5C3787F);

	Config public config;

	EnumerableSet.AddressSet private enabledVTokens;

	bool public initiated = false;

	modifier onlyEnabledVToken(address vToken) {
		require(isEnabledVToken(vToken), 'VToken not enabled for the contract.');
		_;
	}

	constructor(address _config, address _tokenTransferProxy) {
		config = Config(_config);
		paraswapTokenProxy = _tokenTransferProxy;

		// Manaully approve USDC in particular here
		USDC.approve(address(vUSDC), type(uint).max); // For minting vToken
		USDC.approve(address(paraswapTokenProxy), type(uint).max); // For swapping vToken
	}

	function setConfig(address _config) public onlyOwner {
		config = Config(_config);
	}

	function setParaSwap(address _augustus) public onlyOwner {
		paraswap = IParaSwapAugustus(_augustus);
		paraswapTokenProxy = paraswap.getTokenTransferProxy();
	}

	/// @dev Deposit USDC directly as the collateral
	function depositCollateral(uint256 amount) public onlyOwner {
		USDC.transferFrom(msg.sender, address(this), amount);
		vUSDC.mint(amount);
	}

	function initiate() public onlyOwner {
		require(!initiated, 'Already initiated');
		initiated = true;

		address[] memory vTokens = new address[](6);
		vTokens[0] = address(0xA07c5b74C9B40447a954e1466938b865b6BBea36); // vBNB
		vTokens[1] = address(0x882C173bC7Ff3b7786CA16dfeD3DFFfb9Ee7847B); // vBTC
		vTokens[2] = address(0xf508fCD89b8bd15579dc79A6827cB4686A3592c8); // vETH
		vTokens[3] = address(0xecA88125a5ADbe82614ffC12D0DB554E2e2867C8); // vUSDC
		vTokens[4] = address(0x5c9476FcD6a4F9a3654139721c949c2233bBbBc8); // vMATIC
		vTokens[5] = address(0x650b940a1033B8A1b1873f78730FcFC73ec11f1f); // vLINK
		// vTokens[0] = address(0x9A0AF7FDb2065Ce470D72664DE73cAE409dA28Ec); // vADA
		// vTokens[4] = address(0xfD5840Cd36d94D7229439859C0112a4185BC0255); // vUSDT
		// vTokens[7] = address(0x26DA28954763B92139ED49283625ceCAf52C6f94); // vAAVE
		// vTokens[8] = address(0x334b3eCB4DCa3593BCCC3c7EBD1A1C1d1780FBF1); // vDAI
		// vTokens[9] = address(0x1610bc33319e9398de5f57B33a5b184c806aD217); // vDOT
		// vTokens[10] = address(0x86aC3974e2BD0d60825230fa6F355fF11409df5c); // vCAKE
		// vTokens[12] = address(0x95c78222B3D6e262426483D42CfA53685A67Ab9D); // vBUSD
		// vTokens[13] = address(0x5F0388EBc2B94FA8E123F404b79cCF5f40b29176); // vBCH
		// vTokens[14] = address(0xec3422Ef92B2fb59e84c8B02Ba73F1fE84Ed8D71); // vDOGE
		// vTokens[15] = address(0xB248a295732e0225acd3337607cc01068e3b9c10); // vXRP
		// vTokens[16] = address(0xf91d58b5aE142DAcC749f58A49FCBac340Cb0343); // vFIL
		// vTokens[17] = address(0x57A5297F2cB2c0AaC9D554660acd6D385Ab50c6B); // vLTC

		enableVTokens(vTokens);
	}

	/// @dev Hedge and gives negative delta
	/// @dev Slippage is multiplied by 10^4, e.g. 0.01% => 100 // 0.05% => 500
	/// @dev From: https://github.com/aave/aave-v3-periphery/blob/master/contracts/adapters/paraswap/BaseParaSwapSellAdapter.sol#L42
	/// @dev ref: https://github.com/aave/aave-v3-periphery/blob/master/contracts/adapters/paraswap/BaseParaSwapBuyAdapter.sol#L40
	function hedge(
		address vToken,
		bytes memory swapCalldata,
		IParaSwapAugustus augustus,
    IERC20Detailed assetToSwapFrom, // example: ETH
    IERC20Detailed assetToSwapTo, // NOTE: Always should be USDC (collateral)
    uint256 amountToSwap,
    uint256 minAmountToReceive
	)
		public
		onlyEnabledVToken(vToken)
		onlyOwner
	{
		require(isEnabledVToken(vToken), 'VToken not supported, support it first.');

		// Collateral check, param: USDC price of vToken (e.g. vETH) // Oracle deicmals: 18
		uint amountInUSDC = amountToSwap * oracle.getUnderlyingPrice(VTokenInterface(vToken)) / (10 ** (18));
		_manageCollateral(amountInUSDC);

		// Borrow succeed => returns 0
		// console.log("This vToken bal b: ", VBep20Interface(VBep20Interface(vToken).underlying()).balanceOf(address(this)));
		uint err = VBep20Interface(vToken).borrow(amountToSwap);
		require(err == 0, string.concat('Borrow failed with ', Strings.toString(err)));
		// console.log("This vToken bal a: ", VBep20Interface(VBep20Interface(vToken).underlying()).balanceOf(address(this)));

		//
		// ParaSwap
		//
		uint256 balanceBeforeAssetFrom = assetToSwapFrom.balanceOf(address(this));
    uint256 balanceBeforeAssetTo = assetToSwapTo.balanceOf(address(this));
		// console.log('balanceBeforeAssetFrom:', balanceBeforeAssetFrom);
		// console.log('amountToSwap:', amountToSwap);
		// console.log('balanceBeforeAssetTo:', balanceBeforeAssetTo);
		// console.log('t:', IERC20Detailed(0x2170Ed0880ac9A755fd29B2688956BD959F933F8).balanceOf(address(this)));
		if (balanceBeforeAssetFrom < amountToSwap) {
			// balance short fall
			uint shortfall = amountToSwap - balanceBeforeAssetFrom;
			require(assetToSwapFrom.balanceOf(msg.sender) > shortfall, 'Not enough assetToSwapFrom allowance in caller to transfer');
			require(assetToSwapFrom.allowance(msg.sender, address(this)) > shortfall, 'Not enough assetToSwapFrom allowance in caller to transfer');
			require(assetToSwapFrom.transferFrom(msg.sender, address(this), shortfall), 'Failed assetToSwapFrom transfer to cover shortfall');
			balanceBeforeAssetFrom += shortfall;
    	// require(balanceBeforeAssetFrom >= amountToSwap, 'INSUFFICIENT_BALANCE_BEFORE_SWAP');
		}

		// address tokenTransferProxy = augustus.getTokenTransferProxy();

		// console.log('tokenTransferProxy assetToSwapFrom allowance: ', assetToSwapFrom.allowance(address(this), tokenTransferProxy));
		// console.log('tokenTransferProxy assetToSwapFrom balance: ', assetToSwapFrom.balanceOf(address(this)));
		// if (assetToSwapFrom.allowance(address(this), tokenTransferProxy) < amountToSwap) {
		// 	assetToSwapFrom.approve(tokenTransferProxy, type(uint).max); // give max
		// }

		// Swap via ParaSwap
		(bool success, ) = address(augustus).call(swapCalldata);
    if (!success) {
      // Copy revert reason from call
      assembly {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
    }

		// After Swap checks
		// require(
    //   assetToSwapFrom.balanceOf(address(this)) == balanceBeforeAssetFrom - amountToSwap,
    //   'WRONG_BALANCE_AFTER_SWAP'
    // );

		bool receivedWell = false;
		if (assetToSwapTo.balanceOf(address(this)) >= balanceBeforeAssetTo) {
			receivedWell = assetToSwapTo.balanceOf(address(this)) - balanceBeforeAssetTo >= minAmountToReceive;
		}
		require(receivedWell, 'INSUFFICIENT_AMOUNT_RECEIVED');


		// console.log(IERC20Detailed(VBep20Interface(vToken).underlying()).allowance(address(this), address(router)));
		// console.log(USDC.allowance(address(this), address(router)));
		// console.log(IERC20Detailed(VBep20Interface(vToken).underlying()).name());
		// console.log(amount);
		// console.log(amountInUSDC, EasyMath.amountLessSlippage(amountInUSDC, slippage));
		// console.log("This vToken bal a2: ", VBep20Interface(VBep20Interface(vToken).underlying()).balanceOf(address(this)));
	}

	/// @dev Pay back the hedge
	function payback(address vToken, uint256 amount)
		public
		onlyOwner
		onlyEnabledVToken(vToken)
	{
		// VBep20Interface vuToken = VBep20Interface(VBep20Interface(vToken).underlying());
		// require(
		// 	vuToken.balanceOf(address(this)) >= amount,
		// 	'Insufficient vToken amount for repayment'
		// );
		uint err = VBep20Interface(vToken).repayBorrow(amount);
		require(err == 0, string.concat('Repay borrow failed with ', Strings.toString(err)));
	}

	function swapAndPayback(
		address vToken,
		bytes memory paraswapData,
    IERC20Detailed assetToSwapFrom, // NOTE: Always should be USDC (collateral)
    IERC20Detailed assetToSwapTo,
    uint256 maxAmountToSwap,
    uint256 amountToReceive
	)
		public
		onlyOwner
		onlyEnabledVToken(vToken)
		returns (uint256 amountSold)
	{
		VBep20Interface vuToken = VBep20Interface(VBep20Interface(vToken).underlying()); // token underlying vToken

		if (address(vuToken) != address(USDC)) {
			// Swap USDC to vToken.underlying only if there's shortfall to repay `amount` of vToken.underlying
			if (maxAmountToSwap > vuToken.balanceOf(address(this))) {
				// uint price = oracle.getUnderlyingPrice(VTokenInterface(vToken));

				uint256 balanceBeforeAssetFrom = assetToSwapFrom.balanceOf(address(this));
				uint256 balanceBeforeAssetTo = assetToSwapTo.balanceOf(address(this));
				if (balanceBeforeAssetFrom < maxAmountToSwap) {
					// balance short fall for USDC
					uint shortfall = maxAmountToSwap - balanceBeforeAssetFrom;

					// Not enough USDC in wallet, so redeem just enough vUSDC (to USDC) to cover the difference
					uint err = vUSDC.redeemUnderlying(
						_amountMoreSlippage(maxAmountToSwap - USDC.balanceOf(address(this)), 1000) // 0.1% extra buffer
					);
					require(err == 0, string.concat('vUSDC redeem underlying failed with ', Strings.toString(err)));

					if (err != 0) {
						// vUSDC redeem underlying failed, try transferring from wallet
						require(assetToSwapFrom.balanceOf(msg.sender) > shortfall, 'Not enough USDC allowance in caller to transfer');
						require(assetToSwapFrom.allowance(msg.sender, address(this)) > shortfall, 'Not enough USDC allowance in caller to transfer');
						require(assetToSwapFrom.transferFrom(msg.sender, address(this), shortfall), 'Failed USDC transfer to cover shortfall');
					}

					balanceBeforeAssetFrom += assetToSwapFrom.balanceOf(address(this));
				}
				require(balanceBeforeAssetFrom >= maxAmountToSwap, 'INSUFFICIENT_BALANCE_BEFORE_SWAP');

				//
				// ParaSwap
				//
				(bytes memory buyCalldata, IParaSwapAugustus augustus) = abi.decode(
					paraswapData,
					(bytes, IParaSwapAugustus)
				);

				// address tokenTransferProxy = augustus.getTokenTransferProxy();

				// if (assetToSwapFrom.allowance(address(this), tokenTransferProxy) < maxAmountToSwap) {
				// 	assetToSwapFrom.approve(tokenTransferProxy, type(uint).max); // give max
				// }

				(bool success, ) = address(augustus).call(buyCalldata);
				if (!success) {
					// Copy revert reason from call
					assembly {
						returndatacopy(0, 0, returndatasize())
						revert(0, returndatasize())
					}
				}

				bool receivedWell = false;
				if (assetToSwapTo.balanceOf(address(this)) >= balanceBeforeAssetTo) {
					receivedWell = assetToSwapTo.balanceOf(address(this)) - balanceBeforeAssetTo >= amountToReceive;
				}
				require(receivedWell, 'INSUFFICIENT_AMOUNT_RECEIVED');

				// After Swap checks
				uint256 balanceAfterAssetFrom = assetToSwapFrom.balanceOf(address(this));
				amountSold = balanceBeforeAssetFrom - balanceAfterAssetFrom;
				// require(amountSold <= maxAmountToSwap, 'WRONG_BALANCE_AFTER_SWAP');

				// receivedWell = false;
				// if (assetToSwapTo.balanceOf(address(this)) >= balanceBeforeAssetTo) {
				// 	receivedWell = assetToSwapTo.balanceOf(address(this)) - balanceBeforeAssetTo >= amountToReceive;
				// }
				// require(receivedWell, 'INSUFFICIENT_AMOUNT_RECEIVED');
			}
		}

		payback(vToken, amountToReceive);
	}

	/// @param amountUSDC amount to borrow, in USDC
	function _manageCollateral(uint256 amountUSDC) internal {
		// 1. Get how much available collateral
		// uint256 collateral = getVTokenValue(vUSDC, vUSDC.balanceOf(msg.sender));
		(uint err,uint availableCollateral,) = comptroller.getAccountLiquidity(address(this));
		require(err == 0, 'Error in getting account liquidity!');
		
		uint requiredCollateral = amountUSDC * 1e4 / config.LTV();
		// console.log("Hedge amount USDC: ", amountUSDC);
		// console.log("Available Collateral: ", availableCollateral);
		// console.log("Required Collateral: ", requiredCollateral);
		// console.log("Current USDC bal: ", USDC.balanceOf(msg.sender));
		// console.log("Allowance for USDC: ", USDC.allowance(msg.sender, address(this)));

		// VTokenInterface[] memory tokens = comptroller.getAssetsIn(address(this));
		// for (uint i = 0; i < tokens.length; i++) {
		// 	VTokenInterface token = tokens[i];
		// 	(, uint vTokenBalance, uint borrowBalance,) = token.getAccountSnapshot(address(this));
		// 	console.log("vToken: ", address(token));
		// 	console.log("vTokenBalance: ", vTokenBalance);
		// 	console.log("borrowBalance: ", borrowBalance);
		// }

		// Not enough collateral, need to deposit collateral
		if (requiredCollateral > availableCollateral) {
			uint diff = requiredCollateral - availableCollateral;

			require(USDC.allowance(msg.sender, address(this)) >= diff, "Insufficient USDC allowance");
			require(USDC.balanceOf(msg.sender) >= diff, "Insufficient USDC to transfer");

			USDC.transferFrom(msg.sender, address(this), diff);
			require(vUSDC.mint(diff) == 0, 'Mint failed'); // @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
		}
	}

	/// @dev Close all hedges of all tokens and exit immediately
	// function exitAll() public onlyOwner {
	// 	VTokenInterface[] memory vtokens = comptroller.getAssetsIn(address(this));
	// 	for (uint i = 0; i < vtokens.length;) {
	// 		VTokenInterface vtoken = vtokens[i];
	// 		(,, uint borrowBalance,) = vtoken.getAccountSnapshot(address(this));
	// 		// console.log("vToken: ", address(vtoken));
	// 		// console.log("vTokenBalance: ", vTokenBalance);
	// 		// console.log("borrowBalance: ", borrowBalance);
	// 		if (borrowBalance > 0) {
	// 			swapAndPayback(address(vtoken), borrowBalance, config.defaultSlippage(), false);
	// 			VBep20Interface(address(vtoken)).redeemUnderlying(borrowBalance);
	// 			(,uint vTokenBalance,,) = vtoken.getAccountSnapshot(address(this)); // update vTken balance
	// 		}

	// 		if (vTokenBalance > 0) {
	// 			VBep20Interface(address(vtoken)).redeem(vTokenBalance);
	// 			(,vTokenBalance,,) = vtoken.getAccountSnapshot(address(this)); // update vTken balance
	// 			if (vTokenBalance > 0) VBep20Interface(address(vtoken)).redeemUnderlying(vTokenBalance);
	// 			withdrawERC(VBep20Interface(address(vtoken)).underlying());
	// 		}

	// 		unchecked { i++; }
	// 	}
	// }

	//
	// vToken management
	//

	function enableVTokens(address[] memory vTokens) public onlyOwner {
		for (uint i = 0; i < vTokens.length;) {
			enabledVTokens.add(vTokens[i]);

			EIP20NonStandardInterface vuToken = EIP20NonStandardInterface(
				vTokens[i] != address(0xA07c5b74C9B40447a954e1466938b865b6BBea36)
					? address(VBep20Interface(vTokens[i]).underlying()) // NOT vBNB, use underlying token
					: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c // is vBNB, use wrapped BNB
			);

			vuToken.approve(address(vTokens[i]), type(uint).max); // For minting vToken
			vuToken.approve(address(paraswapTokenProxy), type(uint).max); // For swapping vToken
			
			unchecked { i++; }
		}
		comptroller.enterMarkets(vTokens);
	}

	function disableVTokens(address[] memory vTokens) public onlyOwner {
		for (uint i = 0; i < vTokens.length;) {
			enabledVTokens.remove(vTokens[i]);
			uint err = comptroller.exitMarket(vTokens[i]);
			require(err == 0, string.concat('Disable vToken failed with ', Strings.toString(err)));
			unchecked { i++; }
		}
	}

	function getEnabledVTokens() public view returns (address[] memory) {
		return enabledVTokens.values();
	}

	function isEnabledVToken(address token) public view returns (bool) {
		return enabledVTokens.contains(token);
	}

	/// @dev Converts the input VToken amount to USDC value 
	function getVTokenValue(VTokenInterface token, uint256 amount) public view returns (uint256) {
		return token.exchangeRateStored() * amount / 1e18;
	}

	/// @dev Amount - amount * slippage
  /// @param a Amount of token
  /// @param s Desired slippage in 10^4 (e.g. 0.01% => 0.01e4 => 100)
	// function amountLessSlippage(uint256 a, uint256 s) internal pure returns (uint256) {
  //   return (a * (10 ** 6 - s)) / 10 ** 6;
  // }

  /// @dev Amount + amount * slippage
  /// @param a Amount of token
  /// @param s Desired slippage in 10^4 (e.g. 0.01% => 0.01e4 => 100)
  function _amountMoreSlippage(uint256 a, uint256 s) internal pure returns (uint256) {
    // slippage: 0.5e4 (0.5%)
    return (a * (10 ** 6 + s)) / 10 ** 6;
  }
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { Ownable } from 'openzeppelin-contracts/access/Ownable.sol';

contract Config is Ownable {
	uint256 public defaultSlippage = 5000; // 0.5%

	uint256 public LTV = 0.65e4; // 6500 => 65%

	constructor() {}

	function setDefaultSlippage(uint256 s) public onlyOwner {
		defaultSlippage = s;
	}

	function setLTV(uint256 l) public onlyOwner {
		LTV = l;
	}
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

interface IParaSwapAugustus {
  function getTokenTransferProxy() external view returns (address);
}

pragma solidity ^0.8.17;

import "./VTokenInterfaces.sol";
import "./PriceOracle.sol";

interface IComptrollerInterfaceG1 {
    /*** Assets You Are In ***/

    function enterMarkets(address[] calldata vTokens) external returns (uint[] memory);
    function exitMarket(address vToken) external returns (uint);

    /*** Policy Hooks ***/

    function mintAllowed(address vToken, address minter, uint mintAmount) external returns (uint);
    function mintVerify(address vToken, address minter, uint mintAmount, uint mintTokens) external;

    function redeemAllowed(address vToken, address redeemer, uint redeemTokens) external returns (uint);
    function redeemVerify(address vToken, address redeemer, uint redeemAmount, uint redeemTokens) external;

    function borrowAllowed(address vToken, address borrower, uint borrowAmount) external returns (uint);
    function borrowVerify(address vToken, address borrower, uint borrowAmount) external;

    function repayBorrowAllowed(
        address vToken,
        address payer,
        address borrower,
        uint repayAmount) external returns (uint);
    function repayBorrowVerify(
        address vToken,
        address payer,
        address borrower,
        uint repayAmount,
        uint borrowerIndex) external;

    function liquidateBorrowAllowed(
        address vTokenBorrowed,
        address vTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount) external returns (uint);
    function liquidateBorrowVerify(
        address vTokenBorrowed,
        address vTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount,
        uint seizeTokens) external;

    function seizeAllowed(
        address vTokenCollateral,
        address vTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external returns (uint);
    function seizeVerify(
        address vTokenCollateral,
        address vTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external;

    function transferAllowed(address vToken, address src, address dst, uint transferTokens) external returns (uint);
    function transferVerify(address vToken, address src, address dst, uint transferTokens) external;

    /*** Liquidity/Liquidation Calculations ***/

    function liquidateCalculateSeizeTokens(
        address vTokenBorrowed,
        address vTokenCollateral,
        uint repayAmount) external view returns (uint, uint);
    function setMintedVAIOf(address owner, uint amount) external returns (uint);
}

contract ComptrollerInterfaceG1 {
    /// @notice Indicator that this is a Comptroller contract (for inspection)
    bool public constant isComptroller = true;
}

interface ComptrollerInterfaceG2 is IComptrollerInterfaceG1 {
    function liquidateVAICalculateSeizeTokens(
        address vTokenCollateral,
        uint repayAmount) external view returns (uint, uint);
}

interface IComptrollerInterface is ComptrollerInterfaceG2 {
    function markets(address) external view returns (bool, uint);
    function oracle() external view returns (PriceOracle);
    function getAccountLiquidity(address) external view returns (uint, uint, uint);
    function getAssetsIn(address) external view returns (VTokenInterface[] memory);
    function claimVenus(address) external;
    function venusAccrued(address) external view returns (uint);
    function venusSpeeds(address) external view returns (uint);
    function getAllMarkets() external view returns (VTokenInterface[] memory);
    function venusSupplierIndex(address, address) external view returns (uint);
    function venusInitialIndex() external view returns (uint224);
    function venusBorrowerIndex(address, address) external view returns (uint);
    function venusBorrowState(address) external view returns (uint224, uint32);
    function venusSupplyState(address) external view returns (uint224, uint32);
}

abstract contract ComptrollerInterface is IComptrollerInterface {
    bool public constant isComptroller = true;
}

interface IVAIVault {
    function updatePendingRewards() external;
}

interface IComptroller {
    function liquidationIncentiveMantissa() external view returns (uint);
    /*** Treasury Data ***/
    function treasuryAddress() external view returns (address);
    function treasuryPercent() external view returns (uint);
}

pragma solidity ^0.8.17;

/**
 * @title EIP20NonStandardInterface
 * @dev Version of BEP20 with no return values for `transfer` and `transferFrom`
 *  See https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca
 */
interface EIP20NonStandardInterface {

    /**
     * @notice Get the total number of tokens in circulation
     * @return The supply of tokens
     */
    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256 balance);

    ///
    /// !!!!!!!!!!!!!!
    /// !!! NOTICE !!! `transfer` does not return a value, in violation of the BEP-20 specification
    /// !!!!!!!!!!!!!!
    ///

    /**
      * @notice Transfer `amount` tokens from `msg.sender` to `dst`
      * @param dst The address of the destination account
      * @param amount The number of tokens to transfer
      */
    function transfer(address dst, uint256 amount) external;

    ///
    /// !!!!!!!!!!!!!!
    /// !!! NOTICE !!! `transferFrom` does not return a value, in violation of the BEP-20 specification
    /// !!!!!!!!!!!!!!
    ///

    /**
      * @notice Transfer `amount` tokens from `src` to `dst`
      * @param src The address of the source account
      * @param dst The address of the destination account
      * @param amount The number of tokens to transfer
      */
    function transferFrom(address src, address dst, uint256 amount) external;

    function approve(address spender, uint256 amount) external returns (bool success);

    function allowance(address owner, address spender) external view returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}

pragma solidity ^0.8.17;

/**
  * @title Venus's InterestRateModel Interface
  * @author Venus
  */
interface InterestRateModel {
    /// @notice Indicator that this is an InterestRateModel contract (for inspection)
    function isInterestRateModel() external returns (bool);

    /**
      * @notice Calculates the current borrow interest rate per block
      * @param cash The total amount of cash the market has
      * @param borrows The total amount of borrows the market has outstanding
      * @param reserves The total amnount of reserves the market has
      * @return The borrow rate per block (as a percentage, and scaled by 1e18)
      */
    function getBorrowRate(uint cash, uint borrows, uint reserves) external view returns (uint);

    /**
      * @notice Calculates the current supply interest rate per block
      * @param cash The total amount of cash the market has
      * @param borrows The total amount of borrows the market has outstanding
      * @param reserves The total amnount of reserves the market has
      * @param reserveFactorMantissa The current reserve factor the market has
      * @return The supply rate per block (as a percentage, and scaled by 1e18)
      */
    function getSupplyRate(uint cash, uint borrows, uint reserves, uint reserveFactorMantissa) external view returns (uint);
}

pragma solidity ^0.8.17;

import "./VTokenInterfaces.sol";

interface PriceOracle {
    /// @notice Indicator that this is a PriceOracle contract (for inspection)
    // bool public constant isPriceOracle = true;

    /**
      * @notice Get the underlying price of a vToken asset
      * @param vToken The vToken to get the underlying price of
      * @return The underlying asset price mantissa (scaled by 1e18).
      *  Zero means the price is unavailable.
      */
    function getUnderlyingPrice(VTokenInterface vToken) external view returns (uint);
}

pragma solidity ^0.8.17;

import "./ComptrollerInterface.sol";
import "./InterestRateModel.sol";

interface VTokenInterface {
    /**
     * @notice Indicator that this is a VToken contract (for inspection)
     */
    // bool public constant isVToken = true;
    function isVToken() external returns (bool);

    function transfer(address dst, uint amount) external returns (bool);
    function transferFrom(address src, address dst, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function balanceOfUnderlying(address owner) external returns (uint);
    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);
    function borrowRatePerBlock() external view returns (uint);
    function supplyRatePerBlock() external view returns (uint);
    function totalBorrowsCurrent() external returns (uint);
    function borrowBalanceCurrent(address account) external returns (uint);
    function borrowBalanceStored(address account) external view returns (uint);
    function exchangeRateCurrent() external returns (uint);
    function exchangeRateStored() external view returns (uint);
    function getCash() external view returns (uint);
    function accrueInterest() external returns (uint);
    function seize(address liquidator, address borrower, uint seizeTokens) external returns (uint);


    /*** Admin Functions ***/

    function _setPendingAdmin(address payable newPendingAdmin) external returns (uint);
    function _acceptAdmin() external returns (uint);
    function _setComptroller(ComptrollerInterface newComptroller) external returns (uint);
    function _setReserveFactor(uint newReserveFactorMantissa) external returns (uint);
    function _reduceReserves(uint reduceAmount) external returns (uint);
    function _setInterestRateModel(InterestRateModel newInterestRateModel) external returns (uint);
}

interface VBep20Interface is VTokenInterface {
    /**
     * @notice Underlying asset for this VToken
     */
    function underlying() external returns (address);

        /*** User Interface ***/

    function mint(uint mintAmount) external returns (uint);
    function mintBehalf(address receiver, uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function borrow(uint borrowAmount) external returns (uint);
    function repayBorrow(uint repayAmount) external returns (uint);
    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);
    function liquidateBorrow(address borrower, uint repayAmount, VTokenInterface vTokenCollateral) external returns (uint);


    /*** Admin Functions ***/

    function _addReserves(uint addAmount) external returns (uint);
}

interface VDelegatorInterface {
    /**
     * @notice Implementation address for this contract
     */
    function implementation() external returns (address);

    /**
     * @notice Called by the admin to update the implementation of the delegator
     * @param implementation_ The address of the new implementation for delegation
     * @param allowResign Flag to indicate whether to call _resignImplementation on the old implementation
     * @param becomeImplementationData The encoded bytes data to be passed to _becomeImplementation
     */
    function _setImplementation(address implementation_, bool allowResign, bytes memory becomeImplementationData) external;

    /**
     * @notice Called by the delegator on a delegate to initialize it for duty
     * @dev Should revert if any issues arise which make it unfit for delegation
     * @param data The encoded bytes data for any initialization
     */
    function _becomeImplementation(bytes memory data) external;

    /**
     * @notice Called by the delegator on a delegate to forfeit its responsibility
     */
    function _resignImplementation() external;
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.17;

import { IERC20 } from 'openzeppelin-contracts/token/ERC20/IERC20.sol';

interface IERC20Detailed is IERC20 {
  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);
}