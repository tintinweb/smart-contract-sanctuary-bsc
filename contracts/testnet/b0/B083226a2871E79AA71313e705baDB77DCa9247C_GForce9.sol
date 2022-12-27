/**
 *Submitted for verification at BscScan.com on 2022-12-27
*/

// SPDX-License-Identifier: No License

pragma solidity ^ 0.8 .0;


// 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)
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

// 
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)
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

// 
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

// 
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)
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

/*
 * @title String & slice utility library for Solidity contracts.
 * @author Nick Johnson <[email protected]>
 *
 * @dev Functionality in this library is largely implemented using an
 *      abstraction called a 'slice'. A slice represents a part of a string -
 *      anything from the entire string to a single character, or even no
 *      characters at all (a 0-length slice). Since a slice only has to specify
 *      an offset and a length, copying and manipulating slices is a lot less
 *      expensive than copying and manipulating the strings they reference.
 *
 *      To further reduce gas costs, most functions on slice that need to return
 *      a slice modify the original one instead of allocating a new one; for
 *      instance, `s.split(".")` will return the text up to the first '.',
 *      modifying s to only contain the remainder of the string after the '.'.
 *      In situations where you do not want to modify the original slice, you
 *      can make a copy first with `.copy()`, for example:
 *      `s.copy().split(".")`. Try and avoid using this idiom in loops; since
 *      Solidity has no memory management, it will result in allocating many
 *      short-lived slices that are later discarded.
 *
 *      Functions that return two slices come in two versions: a non-allocating
 *      version that takes the second slice as an argument, modifying it in
 *      place, and an allocating version that allocates and returns the second
 *      slice; see `nextRune` for example.
 *
 *      Functions that have to copy string data will return strings rather than
 *      slices; these can be cast back to slices for further processing if
 *      required.
 *
 *      For convenience, some functions are provided with non-modifying
 *      variants that create a new slice and return both; for instance,
 *      `s.splitNew('.')` leaves s unmodified, and returns two values
 *      corresponding to the left and right parts of the string.
 */
library stringa {
    struct slice {
        uint _len;
        uint _ptr;
    }

    function memcpy(uint dest, uint src, uint len) private pure {
        // Copy word-length chunks while possible
        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = type(uint).max;
        if (len > 0) {
            mask = 256 ** (32 - len) - 1;
        }
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    /*
     * @dev Returns a slice containing the entire string.
     * @param self The string to make a slice from.
     * @return A newly allocated slice containing the entire string.
     */
    function toSlice(string memory self) internal pure returns (slice memory) {
        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

    /*
     * @dev Returns the length of a null-terminated bytes32 string.
     * @param self The value to find the length of.
     * @return The length of the string, from 0 to 32.
     */
    function len(bytes32 self) internal pure returns (uint) {
        uint ret;
        if (self == 0)
            return 0;
        if (uint(self) & type(uint128).max == 0) {
            ret += 16;
            self = bytes32(uint(self) / 0x100000000000000000000000000000000);
        }
        if (uint(self) & type(uint64).max == 0) {
            ret += 8;
            self = bytes32(uint(self) / 0x10000000000000000);
        }
        if (uint(self) & type(uint32).max == 0) {
            ret += 4;
            self = bytes32(uint(self) / 0x100000000);
        }
        if (uint(self) & type(uint16).max == 0) {
            ret += 2;
            self = bytes32(uint(self) / 0x10000);
        }
        if (uint(self) & type(uint8).max == 0) {
            ret += 1;
        }
        return 32 - ret;
    }

    /*
     * @dev Returns a slice containing the entire bytes32, interpreted as a
     *      null-terminated utf-8 string.
     * @param self The bytes32 value to convert to a slice.
     * @return A new slice containing the value of the input argument up to the
     *         first null.
     */
    function toSliceB32(bytes32 self) internal pure returns (slice memory ret) {
        // Allocate space for `self` in memory, copy it there, and point ret at it
        assembly {
            let ptr := mload(0x40)
            mstore(0x40, add(ptr, 0x20))
            mstore(ptr, self)
            mstore(add(ret, 0x20), ptr)
        }
        ret._len = len(self);
    }

    /*
     * @dev Returns a new slice containing the same data as the current slice.
     * @param self The slice to copy.
     * @return A new slice containing the same data as `self`.
     */
    function copy(slice memory self) internal pure returns (slice memory) {
        return slice(self._len, self._ptr);
    }

    /*
     * @dev Copies a slice to a new string.
     * @param self The slice to copy.
     * @return A newly allocated string containing the slice's text.
     */
    function toString(slice memory self) internal pure returns (string memory) {
        string memory ret = new string(self._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        memcpy(retptr, self._ptr, self._len);
        return ret;
    }

    /*
     * @dev Returns the length in runes of the slice. Note that this operation
     *      takes time proportional to the length of the slice; avoid using it
     *      in loops, and call `slice.empty()` if you only need to know whether
     *      the slice is empty or not.
     * @param self The slice to operate on.
     * @return The length of the slice in runes.
     */
    function len(slice memory self) internal pure returns (uint l) {
        // Starting at ptr-31 means the LSB will be the byte we care about
        uint ptr = self._ptr - 31;
        uint end = ptr + self._len;
        for (l = 0; ptr < end; l++) {
            uint8 b;
            assembly { b := and(mload(ptr), 0xFF) }
            if (b < 0x80) {
                ptr += 1;
            } else if(b < 0xE0) {
                ptr += 2;
            } else if(b < 0xF0) {
                ptr += 3;
            } else if(b < 0xF8) {
                ptr += 4;
            } else if(b < 0xFC) {
                ptr += 5;
            } else {
                ptr += 6;
            }
        }
    }

    /*
     * @dev Returns true if the slice is empty (has a length of 0).
     * @param self The slice to operate on.
     * @return True if the slice is empty, False otherwise.
     */
    function empty(slice memory self) internal pure returns (bool) {
        return self._len == 0;
    }

    /*
     * @dev Returns a positive number if `other` comes lexicographically after
     *      `self`, a negative number if it comes before, or zero if the
     *      contents of the two slices are equal. Comparison is done per-rune,
     *      on unicode codepoints.
     * @param self The first slice to compare.
     * @param other The second slice to compare.
     * @return The result of the comparison.
     */
    function compare(slice memory self, slice memory other) internal pure returns (int) {
        uint shortest = self._len;
        if (other._len < self._len)
            shortest = other._len;

        uint selfptr = self._ptr;
        uint otherptr = other._ptr;
        for (uint idx = 0; idx < shortest; idx += 32) {
            uint a;
            uint b;
            assembly {
                a := mload(selfptr)
                b := mload(otherptr)
            }
            if (a != b) {
                // Mask out irrelevant bytes and check again
                uint mask = type(uint).max; // 0xffff...
                if(shortest < 32) {
                  mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);
                }
                unchecked {
                    uint diff = (a & mask) - (b & mask);
                    if (diff != 0)
                        return int(diff);
                }
            }
            selfptr += 32;
            otherptr += 32;
        }
        return int(self._len) - int(other._len);
    }

    /*
     * @dev Returns true if the two slices contain the same text.
     * @param self The first slice to compare.
     * @param self The second slice to compare.
     * @return True if the slices are equal, false otherwise.
     */
    function equals(slice memory self, slice memory other) internal pure returns (bool) {
        return compare(self, other) == 0;
    }

    /*
     * @dev Extracts the first rune in the slice into `rune`, advancing the
     *      slice to point to the next rune and returning `self`.
     * @param self The slice to operate on.
     * @param rune The slice that will contain the first rune.
     * @return `rune`.
     */
    function nextRune(slice memory self, slice memory rune) internal pure returns (slice memory) {
        rune._ptr = self._ptr;

        if (self._len == 0) {
            rune._len = 0;
            return rune;
        }

        uint l;
        uint b;
        // Load the first byte of the rune into the LSBs of b
        assembly { b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF) }
        if (b < 0x80) {
            l = 1;
        } else if(b < 0xE0) {
            l = 2;
        } else if(b < 0xF0) {
            l = 3;
        } else {
            l = 4;
        }

        // Check for truncated codepoints
        if (l > self._len) {
            rune._len = self._len;
            self._ptr += self._len;
            self._len = 0;
            return rune;
        }

        self._ptr += l;
        self._len -= l;
        rune._len = l;
        return rune;
    }

    /*
     * @dev Returns the first rune in the slice, advancing the slice to point
     *      to the next rune.
     * @param self The slice to operate on.
     * @return A slice containing only the first rune from `self`.
     */
    function nextRune(slice memory self) internal pure returns (slice memory ret) {
        nextRune(self, ret);
    }

    /*
     * @dev Returns the number of the first codepoint in the slice.
     * @param self The slice to operate on.
     * @return The number of the first codepoint in the slice.
     */
    function ord(slice memory self) internal pure returns (uint ret) {
        if (self._len == 0) {
            return 0;
        }

        uint word;
        uint length;
        uint divisor = 2 ** 248;

        // Load the rune into the MSBs of b
        assembly { word:= mload(mload(add(self, 32))) }
        uint b = word / divisor;
        if (b < 0x80) {
            ret = b;
            length = 1;
        } else if(b < 0xE0) {
            ret = b & 0x1F;
            length = 2;
        } else if(b < 0xF0) {
            ret = b & 0x0F;
            length = 3;
        } else {
            ret = b & 0x07;
            length = 4;
        }

        // Check for truncated codepoints
        if (length > self._len) {
            return 0;
        }

        for (uint i = 1; i < length; i++) {
            divisor = divisor / 256;
            b = (word / divisor) & 0xFF;
            if (b & 0xC0 != 0x80) {
                // Invalid UTF-8 sequence
                return 0;
            }
            ret = (ret * 64) | (b & 0x3F);
        }

        return ret;
    }

    /*
     * @dev Returns the keccak-256 hash of the slice.
     * @param self The slice to hash.
     * @return The hash of the slice.
     */
    function keccak(slice memory self) internal pure returns (bytes32 ret) {
        assembly {
            ret := keccak256(mload(add(self, 32)), mload(self))
        }
    }

    /*
     * @dev Returns true if `self` starts with `needle`.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return True if the slice starts with the provided text, false otherwise.
     */
    function startsWith(slice memory self, slice memory needle) internal pure returns (bool) {
        if (self._len < needle._len) {
            return false;
        }

        if (self._ptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let length := mload(needle)
            let selfptr := mload(add(self, 0x20))
            let needleptr := mload(add(needle, 0x20))
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
        }
        return equal;
    }

    /*
     * @dev If `self` starts with `needle`, `needle` is removed from the
     *      beginning of `self`. Otherwise, `self` is unmodified.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return `self`
     */
    function beyond(slice memory self, slice memory needle) internal pure returns (slice memory) {
        if (self._len < needle._len) {
            return self;
        }

        bool equal = true;
        if (self._ptr != needle._ptr) {
            assembly {
                let length := mload(needle)
                let selfptr := mload(add(self, 0x20))
                let needleptr := mload(add(needle, 0x20))
                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
            }
        }

        if (equal) {
            self._len -= needle._len;
            self._ptr += needle._len;
        }

        return self;
    }

    /*
     * @dev Returns true if the slice ends with `needle`.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return True if the slice starts with the provided text, false otherwise.
     */
    function endsWith(slice memory self, slice memory needle) internal pure returns (bool) {
        if (self._len < needle._len) {
            return false;
        }

        uint selfptr = self._ptr + self._len - needle._len;

        if (selfptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let length := mload(needle)
            let needleptr := mload(add(needle, 0x20))
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
        }

        return equal;
    }

    /*
     * @dev If `self` ends with `needle`, `needle` is removed from the
     *      end of `self`. Otherwise, `self` is unmodified.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return `self`
     */
    function until(slice memory self, slice memory needle) internal pure returns (slice memory) {
        if (self._len < needle._len) {
            return self;
        }

        uint selfptr = self._ptr + self._len - needle._len;
        bool equal = true;
        if (selfptr != needle._ptr) {
            assembly {
                let length := mload(needle)
                let needleptr := mload(add(needle, 0x20))
                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
            }
        }

        if (equal) {
            self._len -= needle._len;
        }

        return self;
    }

    // Returns the memory address of the first byte of the first occurrence of
    // `needle` in `self`, or the first byte after `self` if not found.
    function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {
        uint ptr = selfptr;
        uint idx;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask;
                if (needlelen > 0) {
                    mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));
                }

                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }

                uint end = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }

                while (ptrdata != needledata) {
                    if (ptr >= end)
                        return selfptr + selflen;
                    ptr++;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr;
            } else {
                // For long needles, use hashing
                bytes32 hash;
                assembly { hash := keccak256(needleptr, needlelen) }

                for (idx = 0; idx <= selflen - needlelen; idx++) {
                    bytes32 testHash;
                    assembly { testHash := keccak256(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr;
                    ptr += 1;
                }
            }
        }
        return selfptr + selflen;
    }

    // Returns the memory address of the first byte after the last occurrence of
    // `needle` in `self`, or the address of `self` if not found.
    function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {
        uint ptr;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask;
                if (needlelen > 0) {
                    mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));
                }

                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }

                ptr = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }

                while (ptrdata != needledata) {
                    if (ptr <= selfptr)
                        return selfptr;
                    ptr--;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr + needlelen;
            } else {
                // For long needles, use hashing
                bytes32 hash;
                assembly { hash := keccak256(needleptr, needlelen) }
                ptr = selfptr + (selflen - needlelen);
                while (ptr >= selfptr) {
                    bytes32 testHash;
                    assembly { testHash := keccak256(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr + needlelen;
                    ptr -= 1;
                }
            }
        }
        return selfptr;
    }

    /*
     * @dev Modifies `self` to contain everything from the first occurrence of
     *      `needle` to the end of the slice. `self` is set to the empty slice
     *      if `needle` is not found.
     * @param self The slice to search and modify.
     * @param needle The text to search for.
     * @return `self`.
     */
    function find(slice memory self, slice memory needle) internal pure returns (slice memory) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len -= ptr - self._ptr;
        self._ptr = ptr;
        return self;
    }

    /*
     * @dev Modifies `self` to contain the part of the string from the start of
     *      `self` to the end of the first occurrence of `needle`. If `needle`
     *      is not found, `self` is set to the empty slice.
     * @param self The slice to search and modify.
     * @param needle The text to search for.
     * @return `self`.
     */
    function rfind(slice memory self, slice memory needle) internal pure returns (slice memory) {
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len = ptr - self._ptr;
        return self;
    }

    /*
     * @dev Splits the slice, setting `self` to everything after the first
     *      occurrence of `needle`, and `token` to everything before it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and `token` is set to the entirety of `self`.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @param token An output parameter to which the first token is written.
     * @return `token`.
     */
    function split(slice memory self, slice memory needle, slice memory token) internal pure returns (slice memory) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = self._ptr;
        token._len = ptr - self._ptr;
        if (ptr == self._ptr + self._len) {
            // Not found
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
            self._ptr = ptr + needle._len;
        }
        return token;
    }

    /*
     * @dev Splits the slice, setting `self` to everything after the first
     *      occurrence of `needle`, and returning everything before it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and the entirety of `self` is returned.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @return The part of `self` up to the first occurrence of `delim`.
     */
    function split(slice memory self, slice memory needle) internal pure returns (slice memory token) {
        split(self, needle, token);
    }

    /*
     * @dev Splits the slice, setting `self` to everything before the last
     *      occurrence of `needle`, and `token` to everything after it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and `token` is set to the entirety of `self`.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @param token An output parameter to which the first token is written.
     * @return `token`.
     */
    function rsplit(slice memory self, slice memory needle, slice memory token) internal pure returns (slice memory) {
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = ptr;
        token._len = self._len - (ptr - self._ptr);
        if (ptr == self._ptr) {
            // Not found
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
        }
        return token;
    }

    /*
     * @dev Splits the slice, setting `self` to everything before the last
     *      occurrence of `needle`, and returning everything after it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and the entirety of `self` is returned.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @return The part of `self` after the last occurrence of `delim`.
     */
    function rsplit(slice memory self, slice memory needle) internal pure returns (slice memory token) {
        rsplit(self, needle, token);
    }

    /*
     * @dev Counts the number of nonoverlapping occurrences of `needle` in `self`.
     * @param self The slice to search.
     * @param needle The text to search for in `self`.
     * @return The number of occurrences of `needle` found in `self`.
     */
    function count(slice memory self, slice memory needle) internal pure returns (uint cnt) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;
        while (ptr <= self._ptr + self._len) {
            cnt++;
            ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;
        }
    }

    /*
     * @dev Returns True if `self` contains `needle`.
     * @param self The slice to search.
     * @param needle The text to search for in `self`.
     * @return True if `needle` is found in `self`, false otherwise.
     */
    function contains(slice memory self, slice memory needle) internal pure returns (bool) {
        return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;
    }

    /*
     * @dev Returns a newly allocated string containing the concatenation of
     *      `self` and `other`.
     * @param self The first slice to concatenate.
     * @param other The second slice to concatenate.
     * @return The concatenation of the two strings.
     */
    function concat(slice memory self, slice memory other) internal pure returns (string memory) {
        string memory ret = new string(self._len + other._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }

    /*
     * @dev Joins an array of slices, using `self` as a delimiter, returning a
     *      newly allocated string.
     * @param self The delimiter to use.
     * @param parts A list of slices to join.
     * @return A newly allocated string containing all the slices in `parts`,
     *         joined with `self`.
     */
    function join(slice memory self, slice[] memory parts) internal pure returns (string memory) {
        if (parts.length == 0)
            return "";

        uint length = self._len * (parts.length - 1);
        for(uint i = 0; i < parts.length; i++)
            length += parts[i]._len;

        string memory ret = new string(length);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        for(uint i = 0; i < parts.length; i++) {
            memcpy(retptr, parts[i]._ptr, parts[i]._len);
            retptr += parts[i]._len;
            if (i < parts.length - 1) {
                memcpy(retptr, self._ptr, self._len);
                retptr += self._len;
            }
        }

        return ret;
    }
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)
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

// 
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

   
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

// pragma solidity >=0.6.2;
interface IUniswapV2Router02 is IUniswapV2Router01 {
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

contract GForce9 is Ownable {
    using SafeMath
    for uint256;

    using stringa
    for * ;

    event Log(string _myString);
    event NewUserJoined(address userId, address uplineId, uint256 level, bool useGForce);
    event NewDividendPayment(address receiverId, address originatedFrom, uint256 level, uint256 amount, IERC20 currency);
    event NewUserJoinedPayment(address userId, IERC20 currency, uint256 amount);
    event NewCycle(uint256 level, address userId, address newProxyAddress);

    struct User {
        uint256 index;
        address Id;
        address UplineId;

        address[] UserList;
        string[] PositionList;
        mapping(string => bool) UserExists;
        mapping(string => address) UserAt;
        mapping(address => string) UserAtInverse;
    }

    mapping (uint256 => mapping(uint256 => address)) public IndexToUserMapping;
    mapping(uint256 => mapping(address => address)) public ProxyMapping;
    mapping(uint256 => mapping(address => address)) public ProxyMappingInverse;

    mapping(uint256 => mapping(address => bool)) public AllowedToJoinLevel;
    mapping(uint256 => mapping(address => bool)) public GlobalUserExists;
    mapping(uint256 => mapping(address => User)) public GlobalUsers;
    mapping(uint256 => uint256) public userIndex;

    mapping(address => address) public firstLevelUplineTable;
    mapping(address => address) public secondLevelUplineTable;
    mapping(address => address) public thirdLevelUplineTable;

    IUniswapV2Router02 public uniswapV2Router;

    bool public id1CanJoin = true;
    uint256 public refreshIndex;
    uint256 public unclaimed;
    uint256 public kept;
    uint256 allowanceLimit = 1000000000000000000000000000000;
    IERC20 public currency;
    IERC20 public wBnb;
    mapping(uint256 => uint256) public pricePerDraw;
    mapping(uint256 => uint256) public upgradePriceTable;

    address public id1;
    address public id2;
   
    constructor() {
        refreshIndex = 9000000000;
          id1 = 0x6Ba9d6F42F628f343D285363acce757B9D069e69;

        createNewUserInternal(1, id1, "1", 0x0000000000000000000000000000000000000000);
        createNewUserInternal(2, id1, "1", 0x0000000000000000000000000000000000000000);
        createNewUserInternal(3, id1, "1", 0x0000000000000000000000000000000000000000);
        createNewUserInternal(4, id1, "1", 0x0000000000000000000000000000000000000000);

        createNewUserInternal(5, id1, "1", 0x0000000000000000000000000000000000000000);
        createNewUserInternal(6, id1, "1", 0x0000000000000000000000000000000000000000);
        createNewUserInternal(7, id1, "1", 0x0000000000000000000000000000000000000000);
        createNewUserInternal(8, id1, "1", 0x0000000000000000000000000000000000000000);

        createNewUserInternal(9, id1, "1", 0x0000000000000000000000000000000000000000);
        createNewUserInternal(10, id1, "1", 0x0000000000000000000000000000000000000000);
        createNewUserInternal(11, id1, "1", 0x0000000000000000000000000000000000000000);
        createNewUserInternal(12, id1, "1", 0x0000000000000000000000000000000000000000);

      
        updateUniswapV2Router(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        setWBnb(IERC20(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd));
        setCurrency(IERC20(0x66C35E07521D9eD2935D309b4f3CD9cBc5a6Cd99));

        setPricePerDraw(1,5000);
        setPricePerDraw(2,10000);
        setPricePerDraw(3,20000);
        setPricePerDraw(4,40000);
        setPricePerDraw(5,80000);
        setPricePerDraw(6,160000);
        setPricePerDraw(7,320000);
        setPricePerDraw(8,640000);
        setPricePerDraw(9,1280000);
        setPricePerDraw(10,2560000);
        setPricePerDraw(11,5120000);
        setPricePerDraw(12,10240000);

        setId2(0x7B999805CC1a10121581eB0470C3ceBc52644C19);
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "The router already has that address.");
   
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function multiJoin(address[] memory uplines, address[] memory downlines) public payable {
        for (uint256 i = 0; i < downlines.length; i++) {
            join(1, downlines[i], uplines[i], true, false);
        }
    }

    function setId2(address _id2) public onlyOwner {
        id2 = _id2;
    }

    function generateAddressFromSeed(uint256 seed) public view returns(address) {
        return address(uint160(seed));
    }

    function toAsciiString(address x) internal pure returns(string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2 ** (8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns(bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

  function printUser(uint256 level, address id) public view returns(string memory) {
     
        User storage user = GlobalUsers[level][id];
        stringa.slice memory output;

        for (uint256 i = 0; i < user.PositionList.length; i++) {
            output = output.concat("[".toSlice()).toSlice();
            output = output.concat(user.PositionList[i].toSlice()).toSlice();
            output = output.concat("]0x".toSlice()).toSlice();
            output = output.concat(toAsciiString(user.UserAt[user.PositionList[i]]).toSlice()).toSlice();
            output = output.concat(" ".toSlice()).toSlice();
        }

        return output.toString();
    }
    
    function printUser2(uint256 level, address id) public view returns(string memory) {
        if (ProxyMappingInverse[level][id] != 0x0000000000000000000000000000000000000000) {
            do {
                id = ProxyMappingInverse[level][id];
            } while (ProxyMappingInverse[level][id] != 0x0000000000000000000000000000000000000000);
        }

        User storage user = GlobalUsers[level][id];
        stringa.slice memory output;

        for (uint256 i = 0; i < user.PositionList.length; i++) {
            output = output.concat("[".toSlice()).toSlice();
            output = output.concat(user.PositionList[i].toSlice()).toSlice();
            output = output.concat("]0x".toSlice()).toSlice();
            output = output.concat(toAsciiString(user.UserAt[user.PositionList[i]]).toSlice()).toSlice();
            output = output.concat(" ".toSlice()).toSlice();
        }

        return output.toString();
    }

    function createNewUserInternal(uint256 level, address id, string memory position, address uplineId) internal returns(User storage) {
        require(!GlobalUserExists[level][id], "User already exist");

        User storage user = GlobalUsers[level][id];
        user.Id = id;
        user.UserExists[position] = true;
        user.UserAt[position] = id;
        user.UserAtInverse[id] = position;
        user.UserList.push(id);
        user.PositionList.push(position);
        user.index = userIndex[level];
        IndexToUserMapping[level][user.index] = id;

        // emit Log("aaa33");
        if (uplineId != address(0)) {
            user.UplineId = uplineId;
        }

        GlobalUserExists[level][id] = true;
        // emit Log("aaa44");
        userIndex[level] = userIndex[level] + 1;
     
        return user;
    }

    function power(uint256 A, uint256 B) internal returns(uint256) {
        return A ** B;
    }

    function findBestSlot(mapping(string => bool) storage usersTable) private returns(string memory) {
        stringa.slice memory downline = "1".toSlice();
        bool foundDownline = false;

        // string memory logs = string(abi.encodePacked("aaa1"));
        // emit Log(logs);

        do {
            downline = stringa.concat(downline, "1".toSlice()).toSlice();
            string memory target = downline.toString();
            string[14] memory options = ["11", "12", "111", "112", "121", "122", "1111", "1112", "1121", "1122", "1211", "1212", "1221", "1222"];

            for (uint256 i = 0; i <= options.length; i++) {
                target = options[i];
                foundDownline = usersTable[target];

                if (!foundDownline) {
                    // string memory logs = string(abi.encodePacked("Best slot FOUND ", target));

                    // emit Log(logs);
                    return target;
                }

            }

        } while (foundDownline);

        return "";
    }

    function findBestSlotUpline(
        uint256 level,
        string memory immediateBestSlot,
        address immediateUplineId,
        mapping(address => string) storage immediateUplineTableInverse,
        address superUplineId,
        mapping(address => string) storage superUplineTableInverse)
    private returns(string memory) {

        bool immediateUplineIsBigger = findUser(level, immediateUplineId).index < findUser(level, superUplineId).index;
        if (!immediateUplineIsBigger) {
            stringa.slice memory id1 = superUplineTableInverse[immediateUplineId].toSlice();
            stringa.slice memory id2 = substring(immediateBestSlot, 1, immediateBestSlot.toSlice().len()).toSlice();

            string memory returnVal = id1.concat(id2);

            // string memory logs = string(abi.encodePacked("wow1e", returnVal, ",", id1.toString(), ",", id2.toString(), ",", toAsciiString(immediateUplineId), ",", immediateBestSlot, ",", toAsciiString(superUplineId)));

            // emit Log(logs);
            return returnVal;
        } else {
            stringa.slice memory superUplinePosition = immediateUplineTableInverse[superUplineId].toSlice();

            string memory returnVal2 = stringa.concat("1".toSlice(), immediateBestSlot.toSlice().beyond(superUplinePosition));

            // string memory logs = string(abi.encodePacked("wow2e", returnVal2));

            // emit Log(logs);

            return returnVal2;
        }
    }

    function _stringReplace(string memory _string, uint256 _pos, string memory _letter) internal pure returns(string memory) {
        bytes memory _stringBytes = bytes(_string);
        bytes memory result = new bytes(_stringBytes.length);

        for (uint i = 0; i < _stringBytes.length; i++) {
            result[i] = _stringBytes[i];
            if (i == _pos)
                result[i] = bytes(_letter)[0];
        }
        return string(result);
    }

    function pay(address originatedFrom, uint256 level, address id, uint256 percentage, address[] memory usersArr, string memory slot) private {

        if (percentage == 0) {
            firstLevelUplineTable[originatedFrom] = id;
        } else if (percentage == 30) {
            secondLevelUplineTable[originatedFrom] = id;
        } else if (percentage == 70) {
            thirdLevelUplineTable[originatedFrom] = id;
        }

        if (percentage == 0) return;


        uint256 totalPayable = pricePerDraw[level].mul(percentage).div(100);
        uint256 bnbPayable = totalPayable.mul(50).div(100);
        uint256 gForcePayable = totalPayable.mul(50).div(100);

        if (usersArr.length == 15 || slot.toSlice().equals("122".toSlice())) {
            // string memory logs = string(abi.encodePacked("KEEP ", toAsciiString(id), Strings.toString(totalPayable), ",", Strings.toString(usersArr.length)));
            // emit Log(Strings.toString(usersArr.length));
            // emit Log(logs);
            kept += totalPayable;
        } else {
            // string memory logs = string(abi.encodePacked("PAY ", toAsciiString(id), Strings.toString(totalPayable), ",", Strings.toString(usersArr.length)));
            // emit Log(Strings.toString(usersArr.length));
            // emit Log(logs);

            if (ProxyMapping[level][id] != address(0)) {

                payable(ProxyMapping[level][id]).transfer(bnbPayable);
                swapWBnbForGforce(originatedFrom, ProxyMapping[level][id], gForcePayable, level);

                emit NewDividendPayment(ProxyMapping[level][id], originatedFrom, level, bnbPayable, wBnb);
             
                // currency.transfer(ProxyMapping[level][id], totalPayable);
            } else if (id != address(0)) {
                payable(id).transfer(bnbPayable);
                swapWBnbForGforce(originatedFrom, id, gForcePayable, level);

                 emit NewDividendPayment(id, originatedFrom, level, bnbPayable, wBnb);
              
                //  currency.transfer(id, totalPayable);
            } else {
                unclaimed += totalPayable;
            }
        }
    }

    function clearUserExistAndUserAt(User storage user) private {
        for (uint256 i = 0; i < user.UserList.length; i++) {
            delete user.UserAtInverse[user.UserList[i]];

        }
        for (uint256 i = 0; i < user.PositionList.length; i++) {
            delete user.UserAt[user.PositionList[i]];
            delete user.UserExists[user.PositionList[i]];

        }

        delete user.UserList;
        delete user.PositionList;

    }


    function doLevel1(uint256 level, address userId, address uplineId, string memory slot) internal {
        User storage findImmediateUpline = GlobalUsers[level][uplineId];

        User storage upline1 = findUpline(level, userId, findImmediateUpline, slot, 1, 0);

        if (GlobalUserExists[level][upline1.UplineId]) {
            User storage upline2UserFound = GlobalUsers[level][upline1.UplineId];

            string storage mySlot = upline2UserFound.UserAtInverse[upline1.Id];

            //   // emit Log("aa");
            //   // emit Log(mySlot);
            if (mySlot.toSlice().len() > 1) {
                string memory mySlotNew = substring(mySlot, 0, mySlot.toSlice().len() - 1);
                address mySlotUpline = upline2UserFound.UserAt[mySlotNew];

                User storage mySlotUplineFound = GlobalUsers[level][mySlotUpline];
                string memory bestSlot2 = findBestSlotUpline(level, slot, findImmediateUpline.Id, findImmediateUpline.UserAtInverse, mySlotUplineFound.Id, mySlotUplineFound.UserAtInverse);

                if (bestSlot2.toSlice().len() <= 4 && mySlotUplineFound.UserList.length < 15) {
                    mySlotUplineFound.UserExists[bestSlot2] = true;
                    mySlotUplineFound.UserAt[bestSlot2] = userId;

                    mySlotUplineFound.UserAtInverse[userId] = bestSlot2;
                    mySlotUplineFound.PositionList.push(bestSlot2);
                    mySlotUplineFound.UserList.push(userId);

                    // emit Log("cc");

                    pay(userId, level, mySlotUplineFound.Id, 30, findImmediateUpline.UserList, bestSlot2);
                }
                checkAndRefresh(level, mySlotUplineFound.Id, mySlotUplineFound.UserList, mySlotUplineFound.UserExists);

                if (GlobalUserExists[level][mySlotUplineFound.UplineId]) {
                    doFurtherLevel1Again(userId, uplineId, level, slot);
                }
            }
        }

        checkAndRefresh(level, upline1.Id, upline1.UserList, upline1.UserExists);
    }

    function doLevel3(uint256 level, address userId, address uplineId, string memory slot) internal {
        User storage findImmediateUpline = GlobalUsers[level][uplineId];

        User storage upline1 = findUpline(level, userId, findImmediateUpline, slot, 1, 0);
        User storage upline2 = findUpline(level, userId, findImmediateUpline, slot, 2, 30);
        User storage upline3 = findUpline(level, userId, findImmediateUpline, slot, 3, 70);

        checkAndRefresh(level, upline1.Id, upline1.UserList, upline1.UserExists);
        checkAndRefresh(level, upline2.Id, upline2.UserList, upline2.UserExists);
        checkAndRefresh(level, upline3.Id, upline3.UserList, upline3.UserExists);

    }

    function getUserAtInverse(uint256 level, address user, address uplineId) public view returns(string memory) {
        User storage upline2BonusFound = GlobalUsers[level][user];
        return upline2BonusFound.UserAtInverse[uplineId];
    }


    function doFurtherLevel1Again(address userId, address uplineId, uint256 level, string memory slot) internal {
        address immediateUplineOfUpline2 = secondLevelUplineTable[uplineId];
        User storage upline2BonusFound = GlobalUsers[level][immediateUplineOfUpline2];


        string memory myBonusSlot = upline2BonusFound.UserAtInverse[uplineId];
        // 1211
        // emit Log("bonus slot found");
        // emit Log(toAsciiString(userId));
        // emit Log(toAsciiString(uplineId));
        // emit Log(myBonusSlot);
        // emit Log(slot);
        string memory myBonusSlotUplineSlot = (myBonusSlot.toSlice().concat(substring(slot, 1, slot.toSlice().len()).toSlice()));
        //  string memory bestBonusSlot3 = "1".toSlice().concat(slot.toSlice());
        // emit Log("bonus slot found2");
        // emit Log(myBonusSlotUplineSlot);

        if (upline2BonusFound.UserList.length < 15 && myBonusSlotUplineSlot.toSlice().len() <= 4) {
            upline2BonusFound.UserExists[myBonusSlotUplineSlot] = true;
            upline2BonusFound.UserAt[myBonusSlotUplineSlot] = userId;
            upline2BonusFound.UserAtInverse[userId] = myBonusSlotUplineSlot;
            upline2BonusFound.PositionList.push(myBonusSlotUplineSlot);
            upline2BonusFound.UserList.push(userId);

            pay(userId, level, upline2BonusFound.Id, 70, upline2BonusFound.UserList, myBonusSlotUplineSlot);
            checkAndRefresh(level, upline2BonusFound.Id, upline2BonusFound.UserList, upline2BonusFound.UserExists);
        }

      
    }



    function doLevel2(uint256 level, address userId, address uplineId, string memory slot) internal {
        User storage findImmediateUpline = GlobalUsers[level][uplineId];

        User storage upline1 = findUpline(level, userId, findImmediateUpline, slot, 1, 0);
        User storage upline2 = findUpline(level, userId, findImmediateUpline, slot, 2, 30);

        User storage upline2UserFound = GlobalUsers[level][upline2.Id];

        string storage mySlot = upline2UserFound.UserAtInverse[upline2.Id];

        // emit Log("2mySlot found");
        // emit Log(toAsciiString(upline2.Id));
        // emit Log(mySlot);

        if (mySlot.toSlice().len() >= 1) {
            // string memory logs = string(abi.encodePacked("BEST SLOT3-1 ", slot, ",", mySlot, ",", userId, ",", uplineId));
            // emit Log(logs);
            //  1, 0x53EbE28FA6469701F8750e28b14BB7E087d11E1f, 0xC58F5F6dB49DF39f144586042bb408A1C99b0d84, 0xC58F5F6dB49DF39f144586042bb408A1C99b0d84, 1, 122
            User storage mySlotUplineFound = findUplineInverse2(level, userId,
                findImmediateUpline, upline2UserFound, mySlot, slot,
                1, 70);

            // emit Log("2myslotupline found");
            // emit Log(toAsciiString(mySlotUplineFound.Id));

            checkAndRefresh(level, mySlotUplineFound.Id, mySlotUplineFound.UserList, mySlotUplineFound.UserExists);
            if (mySlot.toSlice().len() > 1 && GlobalUserExists[level][mySlotUplineFound.UplineId]) {
                User storage bonus = GlobalUsers[level][mySlotUplineFound.UplineId];
                string memory myBonusSlot = bonus.UserAtInverse[mySlotUplineFound.Id];

                User storage myBonusSlotUplineFound = findUplineInverse(level, userId, findImmediateUpline, myBonusSlot, slot, 1, 0);

                checkAndRefresh(level, myBonusSlotUplineFound.Id, myBonusSlotUplineFound.UserList, myBonusSlotUplineFound.UserExists);
            }
        } else {
            //  doFurtherLevel2(userId, uplineId, level, slot);
        }

        checkAndRefresh(level, upline1.Id, upline1.UserList, upline1.UserExists);
        checkAndRefresh(level, upline2.Id, upline2.UserList, upline2.UserExists);
    }

    function upgradeWithBnb(uint256 level, address userId) public payable {
        return upgrade(level, userId, false);
    }

    function upgrade(uint256 level, address userId, bool useGForce) public {
        require(!AllowedToJoinLevel[level][userId], "You have already upgraded");
        require(level > 1 && level <= 12, "Invalid level");
        require(GlobalUserExists[1][userId], "User does not exist");

        // uint256 totalPayable = upgradePriceTable[level];
        // currency.transferFrom(msg.sender, address(this), totalPayable);
        if (!AllowedToJoinLevel[1][userId]) {
            AllowedToJoinLevel[1][userId] = true;
        }

        AllowedToJoinLevel[level][userId] = true;

        address level1Upline = GlobalUsers[1][userId].UplineId;

        // Resolve the upline original address.
        if (ProxyMappingInverse[level][level1Upline] != 0x0000000000000000000000000000000000000000) {
            do {
                level1Upline = ProxyMappingInverse[level][level1Upline];
            } while (ProxyMappingInverse[level][level1Upline] != 0x0000000000000000000000000000000000000000);
        }

        // If upline haven't join. Then we join under company.
        if (!GlobalUserExists[level][level1Upline]) {
            require(id2 != 0x0000000000000000000000000000000000000000, "Must set id2");
            level1Upline = id2;
        }

        join(level, userId, level1Upline, true, useGForce);

    }

    function setCanJoin(bool canJoin) public onlyOwner {
        id1CanJoin = canJoin;
    }

    function joinWithBnb(address userId, address uplineId) public payable {
        require(id1CanJoin || (!id1CanJoin && uplineId != id1), "Upline cannot be id1");

        join(1, userId, uplineId, true, false);
    }

    function join(address userId, address uplineId) public {
         require(id1CanJoin || (!id1CanJoin && uplineId != id1), "Upline cannot be id1");

        join(1, userId, uplineId, true, true);
    }

    receive() external payable {}

    function swapWBnbForGforce(address originatedFrom, address to, uint256 total, uint256 level) private returns(uint256) {
        address[] memory path = new address[](2);
        path[1] = address(currency);
        path[0] = address(wBnb);

        currency.approve(address(uniswapV2Router), allowanceLimit);

        // Make the swap
        uint[] memory amounts = uniswapV2Router.swapExactETHForTokens {
            value: total
        }(
            0,
            path,
            to,
            block.timestamp
        );

        emit NewDividendPayment(to, originatedFrom, level, amounts[1], currency);
                
        return amounts[1];
    }

    function getPayableInGForce(uint256 level) public view returns(uint256) {
         uint256 totalPayable = pricePerDraw[level];

         address[] memory path = new address[](2);
        path[0] = address(currency);
        path[1] = address(wBnb);

        uint256[] memory amount = uniswapV2Router.getAmountsIn(totalPayable, path);
        return amount[0];
    }

    function swapGForceForWBnb(uint256 total) private returns(uint256) {

        address[] memory path = new address[](2);
        path[0] = address(currency);
        path[1] = address(wBnb);

        uint256[] memory amount = uniswapV2Router.getAmountsIn(total, path);

        currency.transferFrom(msg.sender, address(this), amount[0]);
        // wBnb.approve(address(uniswapV2Router), allowanceLimit);
        currency.approve(address(uniswapV2Router), allowanceLimit);

        // Make the swap
        uint[] memory amounts = uniswapV2Router.swapTokensForExactETH(
            total,
            allowanceLimit,
            path,
            address(this),
            block.timestamp
        );

        return amounts[1];
    }

    function UserIsLevel(address userId) public view returns(uint256) {
         uint256 level = 0;

        do {
            level = level +1;
        } while (AllowedToJoinLevel[level][userId]);

        return level;
    }
     
    function join(uint256 level, address userId, address uplineId, bool needPay, bool useGForce) private {
        // JoinParam memory param = JoinParam();
        // JoinParam storage param = JoinParams[userId];


         address originalUserId = userId;
                if (ProxyMapping[level][originalUserId] != 0x0000000000000000000000000000000000000000) {
                    do {
                        originalUserId = ProxyMapping[level][originalUserId];
                    } while (ProxyMapping[level][originalUserId] != 0x0000000000000000000000000000000000000000);
                }

        require(level == 1 || AllowedToJoinLevel[level - 1][originalUserId], "You need to open previous level first");

        if (ProxyMappingInverse[level][uplineId] != 0x0000000000000000000000000000000000000000) {
            do {
                uplineId = ProxyMappingInverse[level][uplineId];
            } while (ProxyMappingInverse[level][uplineId] != 0x0000000000000000000000000000000000000000);
        }

        // string memory logs1 = string(abi.encodePacked("join with upline: ", toAsciiString(uplineId)));
        // emit Log(logs1);

        User storage newUser = createNewUserInternal(level, userId, "1", uplineId);

        bool hasUpline = GlobalUserExists[level][uplineId];

        // string memory logs2 = string(abi.encodePacked("level: ", level, " upline: ", toAsciiString(uplineId), "hasUpline: ", hasUpline));
        // emit Log(logs2);

        if (uplineId == 0x0000000000000000000000000000000000000000) {
            // emit Log("uplineId is address(0)");
            return;

        }

        require(hasUpline, "must have upline");
        uint256 totalPayable = pricePerDraw[level];

        if (needPay && useGForce) {
            uint256 swapped = swapGForceForWBnb(totalPayable);
            emit NewUserJoinedPayment(userId, currency, swapped);
            //  currency.transferFrom(msg.sender, address(this), totalPayable);
        } else {
            require(msg.value == totalPayable, "Wrong BNB amount");
            emit NewUserJoinedPayment(userId, wBnb, totalPayable);
        }

        User storage findImmediateUpline = GlobalUsers[level][uplineId];
        // string memory logs = string(abi.encodePacked("IMMEDIATE UPLINE slot for ", toAsciiString(findImmediateUpline.Id)));
        // emit Log(logs);

        string memory slot = findBestSlot(findImmediateUpline.UserExists);


        if (slot.toSlice().len() > 3) {
            doLevel3(level, userId, uplineId, slot);

        } else if (slot.toSlice().len() > 2) {
            doLevel2(level, userId, uplineId, slot);
            //   checkAndRefresh(upline1.Id, upline1.UserList, upline1.UserExists);
            //   checkAndRefresh(upline2.Id, upline2.UserList, upline2.UserExists);
        } else if (slot.toSlice().len() > 1) {
            doLevel1(level, userId, uplineId, slot);
            //  checkAndRefresh(upline1.Id, upline1.UserList, upline1.UserExists);
        }

        emit NewUserJoined(userId, uplineId, level, useGForce);
    }

    function create(uint256 level, address myId) private {
        refreshIndex = refreshIndex + 1;
        address newRandomAddress = generateAddressFromSeed(refreshIndex);

        refreshIndex = refreshIndex + 1;
        address newRandomAddress2 = generateAddressFromSeed(refreshIndex);

        ProxyMapping[level][newRandomAddress] = myId;
        ProxyMappingInverse[level][myId] = newRandomAddress;

        // Reset company address as well
        ProxyMapping[level][newRandomAddress2] = id1;
        ProxyMappingInverse[level][id1] = newRandomAddress2;

        // string memory logs = string(abi.encodePacked("create - myId: ", myId, " new pxy: ", toAsciiString(newRandomAddress), " new pxy2: ", toAsciiString(newRandomAddress2)));
        // emit Log(logs);

        createNewUserInternal(level, newRandomAddress2, "1", 0x0000000000000000000000000000000000000000);
        emit NewCycle(level, myId, newRandomAddress2);
        join(level, newRandomAddress, newRandomAddress2, false, false);
    }

    function checkAndRefresh(
        uint256 level,
        address myId,
        address[] memory currentUserDownlines,
        mapping(string => bool) storage userExists)
    private {
        User storage user = GlobalUsers[level][myId];
        User storage upline = GlobalUsers[level][user.UplineId];


        // string memory logs = string(abi.encodePacked("checkRefresh - ", Strings.toString(currentUserDownlines.length), ",", toAsciiString(user.UplineId), ",", toAsciiString(myId)));
        // emit Log(logs);

        if (currentUserDownlines.length == 15) {

            if (GlobalUserExists[level][user.UplineId]) {
                // JOIN REFRESH
                refreshIndex = refreshIndex + 1;
                address newRandomAddress = generateAddressFromSeed(refreshIndex);

                address originalUplineId = user.UplineId;
                if (ProxyMapping[level][originalUplineId] != 0x0000000000000000000000000000000000000000) {
                    do {
                        originalUplineId = ProxyMapping[level][originalUplineId];
                    } while (ProxyMapping[level][originalUplineId] != 0x0000000000000000000000000000000000000000);
                }

                if (originalUplineId == id1 || originalUplineId == 0x0000000000000000000000000000000000000000) {

                    create(level, myId);
                } else {

                    ProxyMapping[level][newRandomAddress] = myId;
                    ProxyMappingInverse[level][myId] = newRandomAddress;
                    emit NewCycle(level, myId, newRandomAddress);
                    // string memory logs = string(abi.encodePacked("join - myId: ", myId, " new pxy: ", toAsciiString(newRandomAddress)));
                    // emit Log(logs);
                    join(level, newRandomAddress, user.UplineId, false, false);
                }

            }
        }
    }

    function cycleCount(uint256 level, address id) public view returns(uint256) {
        uint256 cycle = 0;

        if (ProxyMappingInverse[level][id] != 0x0000000000000000000000000000000000000000) {
            cycle = 1;
            do {
                id = ProxyMappingInverse[level][id];
                cycle++;
            } while (ProxyMappingInverse[level][id] != 0x0000000000000000000000000000000000000000);
        }

        return cycle;
    }

    function intParse(string memory numString) public pure returns(uint) {
        uint val = 0;
        bytes memory stringBytes = bytes(numString);
        for (uint i = 0; i < stringBytes.length; i++) {
            uint exp = stringBytes.length - i;
            bytes1 ival = stringBytes[i];
            uint8 uval = uint8(ival);
            uint jval = uval - uint(0x30);

            val += (uint(jval) * (10 ** (exp - 1)));
        }
        return val;
    }

    function findUser(uint256 level, address id) private view returns(User storage) {
        return GlobalUsers[level][id];
    }



    function findUplineInverse2(
        uint256 level,
        address userId,
        User storage findImmediateUpline,
        User storage upline2UserFound,
        string memory slot,
        string memory slotForTop,
        uint256 index,
        uint256 payPercentage) private returns(User storage) {
        string memory newSlot = substring(slot, 0, slot.toSlice().len() - index);
        address mySlotUpline = upline2UserFound.UserAt[newSlot];

        if (mySlotUpline == address(0x0) && slotForTop.toSlice().len() == 3) {
            mySlotUpline = firstLevelUplineTable[findImmediateUpline.Id];

            // emit Log("findUplineInverse2");
            // emit Log(Strings.toString(index));
            // emit Log(slotForTop);
            // emit Log(slot);
        } else {
            // emit Log(toAsciiString(mySlotUpline));
        }

        User storage mySlotUplineFound = GlobalUsers[level][mySlotUpline];
        string memory bestSlot3 = findBestSlotUpline(level, slotForTop, findImmediateUpline.Id, findImmediateUpline.UserAtInverse, mySlotUplineFound.Id, mySlotUplineFound.UserAtInverse);

        if (bestSlot3.toSlice().len() <= 4 && mySlotUplineFound.UserList.length < 15) {
            mySlotUplineFound.UserExists[bestSlot3] = true;
            mySlotUplineFound.UserAt[bestSlot3] = userId;
            mySlotUplineFound.UserAtInverse[userId] = bestSlot3;
            mySlotUplineFound.PositionList.push(bestSlot3);
            mySlotUplineFound.UserList.push(userId);

            pay(userId, level, mySlotUplineFound.Id, payPercentage, mySlotUplineFound.UserList, bestSlot3);
        }
        return mySlotUplineFound;
    }


    function setCurrency(IERC20 _currency) public onlyOwner {
        currency = _currency;
    }

    function setWBnb(IERC20 _wbnb) public onlyOwner {
        wBnb = _wbnb;
    }


    function setUpgradePriceTable(uint256 level, uint upgradePrice) external onlyOwner {
        upgradePriceTable[level] = upgradePrice;
    }

    function setPricePerDraw(uint256 level, uint _pricePerDraw) public onlyOwner {
        pricePerDraw[level] = _pricePerDraw;
    }

    function findUpline(
        uint256 level,
        address userId,
        User storage findImmediateUpline,
        string memory slot,
        uint256 index,
        uint256 payPercentage) private returns(User storage) {
        string memory newSlot = substring(slot, 0, slot.toSlice().len() - index);
        address upline2User = findImmediateUpline.UserAt[newSlot];
        User storage upline2 = GlobalUsers[level][upline2User];

        string memory bestSlot2 = findBestSlotUpline(level, slot, findImmediateUpline.Id, findImmediateUpline.UserAtInverse,
            upline2.Id, upline2.UserAtInverse);

        // string memory logs = string(abi.encodePacked("2 Best slot for ", toAsciiString(userId), " under ", toAsciiString(upline2.Id), " is ", bestSlot2));

        // emit Log(logs);

        if (bestSlot2.toSlice().len() <= 4 && upline2.UserList.length < 15) {
            upline2.UserExists[bestSlot2] = true;
            upline2.UserAt[bestSlot2] = userId;
            upline2.UserAtInverse[userId] = bestSlot2;
            upline2.PositionList.push(bestSlot2);
            upline2.UserList.push(userId);

            // if (payPercentage > 0) {
            pay(userId, level, upline2.Id, payPercentage, findImmediateUpline.UserList, bestSlot2);
            //  }
        }
        return upline2;
    }

    function findUplineInverse(
        uint256 level,
        address userId,
        User storage findImmediateUpline,
        string memory slot,
        string memory slotForTop,
        uint256 index,
        uint256 payPercentage) private returns(User storage) {
        string memory newSlot = substring(slot, 0, slot.toSlice().len() - index);
        address upline2User = findImmediateUpline.UserAt[newSlot];
        User storage upline2 = GlobalUsers[level][upline2User];

        string memory bestSlot2 = findBestSlotUpline(level, slotForTop, findImmediateUpline.Id, findImmediateUpline.UserAtInverse,
            upline2.Id, upline2.UserAtInverse);

        // string memory logs = string(abi.encodePacked("3 Best slot for ", toAsciiString(userId), " under ", toAsciiString(upline2.Id), " is ", bestSlot2, " SFT ", slotForTop, " index ", index, " IMME ", (findImmediateUpline.Id)));

        // emit Log(logs);

        if (bestSlot2.toSlice().len() <= 4 && upline2.UserList.length < 15) {
            upline2.UserExists[bestSlot2] = true;
            upline2.UserAt[bestSlot2] = userId;
            upline2.UserAtInverse[userId] = bestSlot2;
            upline2.PositionList.push(bestSlot2);
            upline2.UserList.push(userId);

            if (payPercentage > 0) {
                pay(userId, level, upline2.Id, payPercentage, findImmediateUpline.UserList, bestSlot2);
            }
        }
        return upline2;
    }

    function substring(string memory str, uint startIndex, uint endIndex) private returns(string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    function claim1(uint256 amount) public payable onlyOwner {
        payable(address(msg.sender)).transfer(amount);
    }

    function claim2(address tokenAddress, uint256 amount) public onlyOwner {     
        IERC20(tokenAddress).transfer(msg.sender, amount);
    }
}