pragma solidity 0.8.14;
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
contract TreeMap {
    using SafeMath for uint256;
    // function decomposeTokenId(uint256[] memory tokenId) public view returns(uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory){
    //     // cau truc : // so dau tien la version, 2 so tiep theo la x, 2 so tiêp theo la y, 2 so tiep theo la w, 2 so cuoi la h
    //     uint256[] memory version;
    //     uint256[] memory x;
    //     uint256[] memory y;
    //     uint256[] memory w;
    //     uint256[] memory h;
    //     for(uint256 i = 0; i < tokenId.length; i++){
    //         uint256 ver = tokenId[i].mod(100000000); // chia lấy dư cho 9
    //         uint256 mulTokenId = tokenId[i].mul(100000000);
    //         uint256 xtokenId = mulTokenId.mod(1000000);
    //         uint256 mulxtokenid = mulTokenId.mul(1000000);
    //         uint256 ytokenid = mulxtokenid.mod(10000);
    //         uint256 mulytokenid = mulxtokenid.mul(10000);
    //         uint256 wtokenid = mulytokenid.mod(100);
    //         uint256 htokenid = mulytokenid.mul(100);
    //         // version.push(ver);
    //         // x.push(xtokenId);
    //         // y.push(ytokenid);
    //         // w.push(wtokenid);
    //         // h.push(htokenid);
    //         // Chia lấy phần nguyên => x, y, w, h
    //     }
    //     return x,y,w,h;
    // }
    function decomposeTokenIdx(uint256 tokenId) public view returns(uint256){
        // cau truc : // so dau tien la version, 2 so tiep theo la x, 2 so tiêp theo la y, 2 so tiep theo la w, 2 so cuoi la h
        uint256 x;
            uint256 ver = tokenId.mod(100000000); // chia lấy dư cho 9
            uint256 mulTokenId = tokenId.mul(100000000);
            uint256 xtokenId = mulTokenId.mod(1000000);
            uint256 mulxtokenid = mulTokenId.mul(1000000);
            uint256 ytokenid = mulxtokenid.mod(10000);
            uint256 mulytokenid = mulxtokenid.mul(10000);
            uint256 wtokenId = mulytokenid.mod(100);
            uint256 htokenId = mulytokenid.mul(100);
            // version.push(ver);
            // x.push(xtokenId);
            // y.push(ytokenid);
            // w.push(wtokenid);
            // h.push(htokenid);
            // Chia lấy phần nguyên => x, y, w, h
            x = xtokenId;
        return x;
    }
    function decomposeTokenIdy(uint256 tokenId) public view returns(uint256){
        // cau truc : // so dau tien la version, 2 so tiep theo la x, 2 so tiêp theo la y, 2 so tiep theo la w, 2 so cuoi la h
        uint256 x;
            uint256 ver = tokenId.mod(100000000); // chia lấy dư cho 9
            uint256 mulTokenId = tokenId.mul(100000000);
            uint256 xtokenId = mulTokenId.mod(1000000);
            uint256 mulxtokenid = mulTokenId.mul(1000000);
            uint256 ytokenId = mulxtokenid.mod(10000);
            uint256 mulytokenid = mulxtokenid.mul(10000);
            uint256 wtokenid = mulytokenid.mod(100);
            uint256 htokenid = mulytokenid.mul(100);
            // version.push(ver);
            // x.push(xtokenId);
            // y.push(ytokenid);
            // w.push(wtokenid);
            // h.push(htokenid);
            // Chia lấy phần nguyên => x, y, w, h
            x = ytokenId;
        return x;
    }
    function decomposeTokenIdw(uint256 tokenId) public view returns(uint256){
        // cau truc : // so dau tien la version, 2 so tiep theo la x, 2 so tiêp theo la y, 2 so tiep theo la w, 2 so cuoi la h
        uint256 x;
            uint256 ver = tokenId.mod(100000000); // chia lấy dư cho 9
            uint256 mulTokenId = tokenId.mul(100000000);
            uint256 xtokenId = mulTokenId.mod(1000000);
            uint256 mulxtokenid = mulTokenId.mul(1000000);
            uint256 ytokenId = mulxtokenid.mod(10000);
            uint256 mulytokenid = mulxtokenid.mul(10000);
            uint256 wtokenId = mulytokenid.mod(100);
            uint256 htokenId = mulytokenid.mul(100);
            // version.push(ver);
            // x.push(xtokenId);
            // y.push(ytokenid);
            // w.push(wtokenid);
            // h.push(htokenid);
            // Chia lấy phần nguyên => x, y, w, h
            x = wtokenId;
        return x;
    }
    function decomposeTokenIdh(uint256 tokenId) public view returns(uint256){
        // cau truc : // so dau tien la version, 2 so tiep theo la x, 2 so tiêp theo la y, 2 so tiep theo la w, 2 so cuoi la h
        uint256 x;
            uint256 ver = tokenId.mod(100000000); // chia lấy dư cho 9
            uint256 mulTokenId = tokenId.mul(100000000);
            uint256 xtokenId = mulTokenId.mod(1000000);
            uint256 mulxtokenid = mulTokenId.mul(1000000);
            uint256 ytokenId = mulxtokenid.mod(10000);
            uint256 mulytokenid = mulxtokenid.mul(10000);
            uint256 wtokenId = mulytokenid.mod(100);
            uint256 htokenId = mulytokenid.mul(100);
            // version.push(ver);
            // x.push(xtokenId);
            // y.push(ytokenid);
            // w.push(wtokenid);
            // h.push(htokenid);
            // Chia lấy phần nguyên => x, y, w, h
            x = htokenId;
        return x;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
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
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT
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