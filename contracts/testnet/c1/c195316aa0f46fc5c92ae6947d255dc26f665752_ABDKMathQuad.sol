/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

// SPDX-License-Identifier: MIT AND BSD-4-Clause
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

pragma solidity >=0.6.2;

interface DexRouter {
    function WETH() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}


/*
 * ABDK Math Quad Smart Contract Library.  Copyright © 2019 by ABDK Consulting.
 * Author: Mikhail Vladimirov <[email protected]>
 */
pragma solidity ^0.8.0;

/**
 * Smart contract library of mathematical functions operating with IEEE 754
 * quadruple-precision binary floating-point numbers (quadruple precision
 * numbers).  As long as quadruple precision numbers are 16-bytes long, they are
 * represented by bytes16 type.
 */
library ABDKMathQuad {
  /*
   * 0.
   */
  bytes16 private constant POSITIVE_ZERO = 0x00000000000000000000000000000000;

  /*
   * -0.
   */
  bytes16 private constant NEGATIVE_ZERO = 0x80000000000000000000000000000000;

  /*
   * +Infinity.
   */
  bytes16 private constant POSITIVE_INFINITY = 0x7FFF0000000000000000000000000000;

  /*
   * -Infinity.
   */
  bytes16 private constant NEGATIVE_INFINITY = 0xFFFF0000000000000000000000000000;

  /*
   * Canonical NaN value.
   */
  bytes16 private constant NaN = 0x7FFF8000000000000000000000000000;

  /**
   * Convert signed 256-bit integer number into quadruple precision number.
   *
   * @param x signed 256-bit integer number
   * @return quadruple precision number
   */
  function fromInt (int256 x) internal pure returns (bytes16) {
    unchecked {
      if (x == 0) return bytes16 (0);
      else {
        // We rely on overflow behavior here
        uint256 result = uint256 (x > 0 ? x : -x);

        uint256 msb = mostSignificantBit (result);
        if (msb < 112) result <<= 112 - msb;
        else if (msb > 112) result >>= msb - 112;

        result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16383 + msb << 112;
        if (x < 0) result |= 0x80000000000000000000000000000000;

        return bytes16 (uint128 (result));
      }
    }
  }

  /**
   * Convert quadruple precision number into signed 256-bit integer number
   * rounding towards zero.  Revert on overflow.
   *
   * @param x quadruple precision number
   * @return signed 256-bit integer number
   */
  function toInt (bytes16 x) internal pure returns (int256) {
    unchecked {
      uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

      require (exponent <= 16638); // Overflow
      if (exponent < 16383) return 0; // Underflow

      uint256 result = uint256 (uint128 (x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF |
        0x10000000000000000000000000000;

      if (exponent < 16495) result >>= 16495 - exponent;
      else if (exponent > 16495) result <<= exponent - 16495;

      if (uint128 (x) >= 0x80000000000000000000000000000000) { // Negative
        require (result <= 0x8000000000000000000000000000000000000000000000000000000000000000);
        return -int256 (result); // We rely on overflow behavior here
      } else {
        require (result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        return int256 (result);
      }
    }
  }

  /**
   * Convert unsigned 256-bit integer number into quadruple precision number.
   *
   * @param x unsigned 256-bit integer number
   * @return quadruple precision number
   */
  function fromUInt (uint256 x) internal pure returns (bytes16) {
    unchecked {
      if (x == 0) return bytes16 (0);
      else {
        uint256 result = x;

        uint256 msb = mostSignificantBit (result);
        if (msb < 112) result <<= 112 - msb;
        else if (msb > 112) result >>= msb - 112;

        result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16383 + msb << 112;

        return bytes16 (uint128 (result));
      }
    }
  }

  /**
   * Convert quadruple precision number into unsigned 256-bit integer number
   * rounding towards zero.  Revert on underflow.  Note, that negative floating
   * point numbers in range (-1.0 .. 0.0) may be converted to unsigned integer
   * without error, because they are rounded to zero.
   *
   * @param x quadruple precision number
   * @return unsigned 256-bit integer number
   */
  function toUInt (bytes16 x) internal pure returns (uint256) {
    unchecked {
      uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

      if (exponent < 16383) return 0; // Underflow

      require (uint128 (x) < 0x80000000000000000000000000000000); // Negative

      require (exponent <= 16638); // Overflow
      uint256 result = uint256 (uint128 (x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF |
        0x10000000000000000000000000000;

      if (exponent < 16495) result >>= 16495 - exponent;
      else if (exponent > 16495) result <<= exponent - 16495;

      return result;
    }
  }

  /**
   * Convert signed 128.128 bit fixed point number into quadruple precision
   * number.
   *
   * @param x signed 128.128 bit fixed point number
   * @return quadruple precision number
   */
  function from128x128 (int256 x) internal pure returns (bytes16) {
    unchecked {
      if (x == 0) return bytes16 (0);
      else {
        // We rely on overflow behavior here
        uint256 result = uint256 (x > 0 ? x : -x);

        uint256 msb = mostSignificantBit (result);
        if (msb < 112) result <<= 112 - msb;
        else if (msb > 112) result >>= msb - 112;

        result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16255 + msb << 112;
        if (x < 0) result |= 0x80000000000000000000000000000000;

        return bytes16 (uint128 (result));
      }
    }
  }

  /**
   * Convert quadruple precision number into signed 128.128 bit fixed point
   * number.  Revert on overflow.
   *
   * @param x quadruple precision number
   * @return signed 128.128 bit fixed point number
   */
  function to128x128 (bytes16 x) internal pure returns (int256) {
    unchecked {
      uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

      require (exponent <= 16510); // Overflow
      if (exponent < 16255) return 0; // Underflow

      uint256 result = uint256 (uint128 (x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF |
        0x10000000000000000000000000000;

      if (exponent < 16367) result >>= 16367 - exponent;
      else if (exponent > 16367) result <<= exponent - 16367;

      if (uint128 (x) >= 0x80000000000000000000000000000000) { // Negative
        require (result <= 0x8000000000000000000000000000000000000000000000000000000000000000);
        return -int256 (result); // We rely on overflow behavior here
      } else {
        require (result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        return int256 (result);
      }
    }
  }

  /**
   * Convert signed 64.64 bit fixed point number into quadruple precision
   * number.
   *
   * @param x signed 64.64 bit fixed point number
   * @return quadruple precision number
   */
  function from64x64 (int128 x) internal pure returns (bytes16) {
    unchecked {
      if (x == 0) return bytes16 (0);
      else {
        // We rely on overflow behavior here
        uint256 result = uint128 (x > 0 ? x : -x);

        uint256 msb = mostSignificantBit (result);
        if (msb < 112) result <<= 112 - msb;
        else if (msb > 112) result >>= msb - 112;

        result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16319 + msb << 112;
        if (x < 0) result |= 0x80000000000000000000000000000000;

        return bytes16 (uint128 (result));
      }
    }
  }

  /**
   * Convert quadruple precision number into signed 64.64 bit fixed point
   * number.  Revert on overflow.
   *
   * @param x quadruple precision number
   * @return signed 64.64 bit fixed point number
   */
  function to64x64 (bytes16 x) internal pure returns (int128) {
    unchecked {
      uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

      require (exponent <= 16446); // Overflow
      if (exponent < 16319) return 0; // Underflow

      uint256 result = uint256 (uint128 (x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF |
        0x10000000000000000000000000000;

      if (exponent < 16431) result >>= 16431 - exponent;
      else if (exponent > 16431) result <<= exponent - 16431;

      if (uint128 (x) >= 0x80000000000000000000000000000000) { // Negative
        require (result <= 0x80000000000000000000000000000000);
        return -int128 (int256 (result)); // We rely on overflow behavior here
      } else {
        require (result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        return int128 (int256 (result));
      }
    }
  }

  /**
   * Convert octuple precision number into quadruple precision number.
   *
   * @param x octuple precision number
   * @return quadruple precision number
   */
  function fromOctuple (bytes32 x) internal pure returns (bytes16) {
    unchecked {
      bool negative = x & 0x8000000000000000000000000000000000000000000000000000000000000000 > 0;

      uint256 exponent = uint256 (x) >> 236 & 0x7FFFF;
      uint256 significand = uint256 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

      if (exponent == 0x7FFFF) {
        if (significand > 0) return NaN;
        else return negative ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
      }

      if (exponent > 278526)
        return negative ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
      else if (exponent < 245649)
        return negative ? NEGATIVE_ZERO : POSITIVE_ZERO;
      else if (exponent < 245761) {
        significand = (significand | 0x100000000000000000000000000000000000000000000000000000000000) >> 245885 - exponent;
        exponent = 0;
      } else {
        significand >>= 124;
        exponent -= 245760;
      }

      uint128 result = uint128 (significand | exponent << 112);
      if (negative) result |= 0x80000000000000000000000000000000;

      return bytes16 (result);
    }
  }

  /**
   * Convert quadruple precision number into octuple precision number.
   *
   * @param x quadruple precision number
   * @return octuple precision number
   */
  function toOctuple (bytes16 x) internal pure returns (bytes32) {
    unchecked {
      uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

      uint256 result = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

      if (exponent == 0x7FFF) exponent = 0x7FFFF; // Infinity or NaN
      else if (exponent == 0) {
        if (result > 0) {
          uint256 msb = mostSignificantBit (result);
          result = result << 236 - msb & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
          exponent = 245649 + msb;
        }
      } else {
        result <<= 124;
        exponent += 245760;
      }

      result |= exponent << 236;
      if (uint128 (x) >= 0x80000000000000000000000000000000)
        result |= 0x8000000000000000000000000000000000000000000000000000000000000000;

      return bytes32 (result);
    }
  }

  /**
   * Convert double precision number into quadruple precision number.
   *
   * @param x double precision number
   * @return quadruple precision number
   */
  function fromDouble (bytes8 x) internal pure returns (bytes16) {
    unchecked {
      uint256 exponent = uint64 (x) >> 52 & 0x7FF;

      uint256 result = uint64 (x) & 0xFFFFFFFFFFFFF;

      if (exponent == 0x7FF) exponent = 0x7FFF; // Infinity or NaN
      else if (exponent == 0) {
        if (result > 0) {
          uint256 msb = mostSignificantBit (result);
          result = result << 112 - msb & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
          exponent = 15309 + msb;
        }
      } else {
        result <<= 60;
        exponent += 15360;
      }

      result |= exponent << 112;
      if (x & 0x8000000000000000 > 0)
        result |= 0x80000000000000000000000000000000;

      return bytes16 (uint128 (result));
    }
  }

  /**
   * Convert quadruple precision number into double precision number.
   *
   * @param x quadruple precision number
   * @return double precision number
   */
  function toDouble (bytes16 x) internal pure returns (bytes8) {
    unchecked {
      bool negative = uint128 (x) >= 0x80000000000000000000000000000000;

      uint256 exponent = uint128 (x) >> 112 & 0x7FFF;
      uint256 significand = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

      if (exponent == 0x7FFF) {
        if (significand > 0) return 0x7FF8000000000000; // NaN
        else return negative ?
            bytes8 (0xFFF0000000000000) : // -Infinity
            bytes8 (0x7FF0000000000000); // Infinity
      }

      if (exponent > 17406)
        return negative ?
            bytes8 (0xFFF0000000000000) : // -Infinity
            bytes8 (0x7FF0000000000000); // Infinity
      else if (exponent < 15309)
        return negative ?
            bytes8 (0x8000000000000000) : // -0
            bytes8 (0x0000000000000000); // 0
      else if (exponent < 15361) {
        significand = (significand | 0x10000000000000000000000000000) >> 15421 - exponent;
        exponent = 0;
      } else {
        significand >>= 60;
        exponent -= 15360;
      }

      uint64 result = uint64 (significand | exponent << 52);
      if (negative) result |= 0x8000000000000000;

      return bytes8 (result);
    }
  }

  /**
   * Test whether given quadruple precision number is NaN.
   *
   * @param x quadruple precision number
   * @return true if x is NaN, false otherwise
   */
  function isNaN (bytes16 x) internal pure returns (bool) {
    unchecked {
      return uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF >
        0x7FFF0000000000000000000000000000;
    }
  }

  /**
   * Test whether given quadruple precision number is positive or negative
   * infinity.
   *
   * @param x quadruple precision number
   * @return true if x is positive or negative infinity, false otherwise
   */
  function isInfinity (bytes16 x) internal pure returns (bool) {
    unchecked {
      return uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ==
        0x7FFF0000000000000000000000000000;
    }
  }

  /**
   * Calculate sign of x, i.e. -1 if x is negative, 0 if x if zero, and 1 if x
   * is positive.  Note that sign (-0) is zero.  Revert if x is NaN. 
   *
   * @param x quadruple precision number
   * @return sign of x
   */
  function sign (bytes16 x) internal pure returns (int8) {
    unchecked {
      uint128 absoluteX = uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

      require (absoluteX <= 0x7FFF0000000000000000000000000000); // Not NaN

      if (absoluteX == 0) return 0;
      else if (uint128 (x) >= 0x80000000000000000000000000000000) return -1;
      else return 1;
    }
  }

  /**
   * Calculate sign (x - y).  Revert if either argument is NaN, or both
   * arguments are infinities of the same sign. 
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return sign (x - y)
   */
  function cmp (bytes16 x, bytes16 y) internal pure returns (int8) {
    unchecked {
      uint128 absoluteX = uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

      require (absoluteX <= 0x7FFF0000000000000000000000000000); // Not NaN

      uint128 absoluteY = uint128 (y) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

      require (absoluteY <= 0x7FFF0000000000000000000000000000); // Not NaN

      // Not infinities of the same sign
      require (x != y || absoluteX < 0x7FFF0000000000000000000000000000);

      if (x == y) return 0;
      else {
        bool negativeX = uint128 (x) >= 0x80000000000000000000000000000000;
        bool negativeY = uint128 (y) >= 0x80000000000000000000000000000000;

        if (negativeX) {
          if (negativeY) return absoluteX > absoluteY ? -1 : int8 (1);
          else return -1; 
        } else {
          if (negativeY) return 1;
          else return absoluteX > absoluteY ? int8 (1) : -1;
        }
      }
    }
  }

  /**
   * Test whether x equals y.  NaN, infinity, and -infinity are not equal to
   * anything. 
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return true if x equals to y, false otherwise
   */
  function eq (bytes16 x, bytes16 y) internal pure returns (bool) {
    unchecked {
      if (x == y) {
        return uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF <
          0x7FFF0000000000000000000000000000;
      } else return false;
    }
  }

  /**
   * Calculate x + y.  Special values behave in the following way:
   *
   * NaN + x = NaN for any x.
   * Infinity + x = Infinity for any finite x.
   * -Infinity + x = -Infinity for any finite x.
   * Infinity + Infinity = Infinity.
   * -Infinity + -Infinity = -Infinity.
   * Infinity + -Infinity = -Infinity + Infinity = NaN.
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return quadruple precision number
   */
  function add (bytes16 x, bytes16 y) internal pure returns (bytes16) {
    unchecked {
      uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
      uint256 yExponent = uint128 (y) >> 112 & 0x7FFF;

      if (xExponent == 0x7FFF) {
        if (yExponent == 0x7FFF) { 
          if (x == y) return x;
          else return NaN;
        } else return x; 
      } else if (yExponent == 0x7FFF) return y;
      else {
        bool xSign = uint128 (x) >= 0x80000000000000000000000000000000;
        uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        if (xExponent == 0) xExponent = 1;
        else xSignifier |= 0x10000000000000000000000000000;

        bool ySign = uint128 (y) >= 0x80000000000000000000000000000000;
        uint256 ySignifier = uint128 (y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        if (yExponent == 0) yExponent = 1;
        else ySignifier |= 0x10000000000000000000000000000;

        if (xSignifier == 0) return y == NEGATIVE_ZERO ? POSITIVE_ZERO : y;
        else if (ySignifier == 0) return x == NEGATIVE_ZERO ? POSITIVE_ZERO : x;
        else {
          int256 delta = int256 (xExponent) - int256 (yExponent);
  
          if (xSign == ySign) {
            if (delta > 112) return x;
            else if (delta > 0) ySignifier >>= uint256 (delta);
            else if (delta < -112) return y;
            else if (delta < 0) {
              xSignifier >>= uint256 (-delta);
              xExponent = yExponent;
            }
  
            xSignifier += ySignifier;
  
            if (xSignifier >= 0x20000000000000000000000000000) {
              xSignifier >>= 1;
              xExponent += 1;
            }
  
            if (xExponent == 0x7FFF)
              return xSign ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
            else {
              if (xSignifier < 0x10000000000000000000000000000) xExponent = 0;
              else xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
  
              return bytes16 (uint128 (
                  (xSign ? 0x80000000000000000000000000000000 : 0) |
                  (xExponent << 112) |
                  xSignifier)); 
            }
          } else {
            if (delta > 0) {
              xSignifier <<= 1;
              xExponent -= 1;
            } else if (delta < 0) {
              ySignifier <<= 1;
              xExponent = yExponent - 1;
            }

            if (delta > 112) ySignifier = 1;
            else if (delta > 1) ySignifier = (ySignifier - 1 >> uint256 (delta - 1)) + 1;
            else if (delta < -112) xSignifier = 1;
            else if (delta < -1) xSignifier = (xSignifier - 1 >> uint256 (-delta - 1)) + 1;

            if (xSignifier >= ySignifier) xSignifier -= ySignifier;
            else {
              xSignifier = ySignifier - xSignifier;
              xSign = ySign;
            }

            if (xSignifier == 0)
              return POSITIVE_ZERO;

            uint256 msb = mostSignificantBit (xSignifier);

            if (msb == 113) {
              xSignifier = xSignifier >> 1 & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
              xExponent += 1;
            } else if (msb < 112) {
              uint256 shift = 112 - msb;
              if (xExponent > shift) {
                xSignifier = xSignifier << shift & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                xExponent -= shift;
              } else {
                xSignifier <<= xExponent - 1;
                xExponent = 0;
              }
            } else xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

            if (xExponent == 0x7FFF)
              return xSign ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
            else return bytes16 (uint128 (
                (xSign ? 0x80000000000000000000000000000000 : 0) |
                (xExponent << 112) |
                xSignifier));
          }
        }
      }
    }
  }

  /**
   * Calculate x - y.  Special values behave in the following way:
   *
   * NaN - x = NaN for any x.
   * Infinity - x = Infinity for any finite x.
   * -Infinity - x = -Infinity for any finite x.
   * Infinity - -Infinity = Infinity.
   * -Infinity - Infinity = -Infinity.
   * Infinity - Infinity = -Infinity - -Infinity = NaN.
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return quadruple precision number
   */
  function sub (bytes16 x, bytes16 y) internal pure returns (bytes16) {
    unchecked {
      return add (x, y ^ 0x80000000000000000000000000000000);
    }
  }

  /**
   * Calculate x * y.  Special values behave in the following way:
   *
   * NaN * x = NaN for any x.
   * Infinity * x = Infinity for any finite positive x.
   * Infinity * x = -Infinity for any finite negative x.
   * -Infinity * x = -Infinity for any finite positive x.
   * -Infinity * x = Infinity for any finite negative x.
   * Infinity * 0 = NaN.
   * -Infinity * 0 = NaN.
   * Infinity * Infinity = Infinity.
   * Infinity * -Infinity = -Infinity.
   * -Infinity * Infinity = -Infinity.
   * -Infinity * -Infinity = Infinity.
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return quadruple precision number
   */
  function mul (bytes16 x, bytes16 y) internal pure returns (bytes16) {
    unchecked {
      uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
      uint256 yExponent = uint128 (y) >> 112 & 0x7FFF;

      if (xExponent == 0x7FFF) {
        if (yExponent == 0x7FFF) {
          if (x == y) return x ^ y & 0x80000000000000000000000000000000;
          else if (x ^ y == 0x80000000000000000000000000000000) return x | y;
          else return NaN;
        } else {
          if (y & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
          else return x ^ y & 0x80000000000000000000000000000000;
        }
      } else if (yExponent == 0x7FFF) {
          if (x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
          else return y ^ x & 0x80000000000000000000000000000000;
      } else {
        uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        if (xExponent == 0) xExponent = 1;
        else xSignifier |= 0x10000000000000000000000000000;

        uint256 ySignifier = uint128 (y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        if (yExponent == 0) yExponent = 1;
        else ySignifier |= 0x10000000000000000000000000000;

        xSignifier *= ySignifier;
        if (xSignifier == 0)
          return (x ^ y) & 0x80000000000000000000000000000000 > 0 ?
              NEGATIVE_ZERO : POSITIVE_ZERO;

        xExponent += yExponent;

        uint256 msb =
          xSignifier >= 0x200000000000000000000000000000000000000000000000000000000 ? 225 :
          xSignifier >= 0x100000000000000000000000000000000000000000000000000000000 ? 224 :
          mostSignificantBit (xSignifier);

        if (xExponent + msb < 16496) { // Underflow
          xExponent = 0;
          xSignifier = 0;
        } else if (xExponent + msb < 16608) { // Subnormal
          if (xExponent < 16496)
            xSignifier >>= 16496 - xExponent;
          else if (xExponent > 16496)
            xSignifier <<= xExponent - 16496;
          xExponent = 0;
        } else if (xExponent + msb > 49373) {
          xExponent = 0x7FFF;
          xSignifier = 0;
        } else {
          if (msb > 112)
            xSignifier >>= msb - 112;
          else if (msb < 112)
            xSignifier <<= 112 - msb;

          xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

          xExponent = xExponent + msb - 16607;
        }

        return bytes16 (uint128 (uint128 ((x ^ y) & 0x80000000000000000000000000000000) |
            xExponent << 112 | xSignifier));
      }
    }
  }

  /**
   * Calculate x / y.  Special values behave in the following way:
   *
   * NaN / x = NaN for any x.
   * x / NaN = NaN for any x.
   * Infinity / x = Infinity for any finite non-negative x.
   * Infinity / x = -Infinity for any finite negative x including -0.
   * -Infinity / x = -Infinity for any finite non-negative x.
   * -Infinity / x = Infinity for any finite negative x including -0.
   * x / Infinity = 0 for any finite non-negative x.
   * x / -Infinity = -0 for any finite non-negative x.
   * x / Infinity = -0 for any finite non-negative x including -0.
   * x / -Infinity = 0 for any finite non-negative x including -0.
   * 
   * Infinity / Infinity = NaN.
   * Infinity / -Infinity = -NaN.
   * -Infinity / Infinity = -NaN.
   * -Infinity / -Infinity = NaN.
   *
   * Division by zero behaves in the following way:
   *
   * x / 0 = Infinity for any finite positive x.
   * x / -0 = -Infinity for any finite positive x.
   * x / 0 = -Infinity for any finite negative x.
   * x / -0 = Infinity for any finite negative x.
   * 0 / 0 = NaN.
   * 0 / -0 = NaN.
   * -0 / 0 = NaN.
   * -0 / -0 = NaN.
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return quadruple precision number
   */
  function div (bytes16 x, bytes16 y) internal pure returns (bytes16) {
    unchecked {
      uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
      uint256 yExponent = uint128 (y) >> 112 & 0x7FFF;

      if (xExponent == 0x7FFF) {
        if (yExponent == 0x7FFF) return NaN;
        else return x ^ y & 0x80000000000000000000000000000000;
      } else if (yExponent == 0x7FFF) {
        if (y & 0x0000FFFFFFFFFFFFFFFFFFFFFFFFFFFF != 0) return NaN;
        else return POSITIVE_ZERO | (x ^ y) & 0x80000000000000000000000000000000;
      } else if (y & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) {
        if (x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
        else return POSITIVE_INFINITY | (x ^ y) & 0x80000000000000000000000000000000;
      } else {
        uint256 ySignifier = uint128 (y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        if (yExponent == 0) yExponent = 1;
        else ySignifier |= 0x10000000000000000000000000000;

        uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        if (xExponent == 0) {
          if (xSignifier != 0) {
            uint shift = 226 - mostSignificantBit (xSignifier);

            xSignifier <<= shift;

            xExponent = 1;
            yExponent += shift - 114;
          }
        }
        else {
          xSignifier = (xSignifier | 0x10000000000000000000000000000) << 114;
        }

        xSignifier = xSignifier / ySignifier;
        if (xSignifier == 0)
          return (x ^ y) & 0x80000000000000000000000000000000 > 0 ?
              NEGATIVE_ZERO : POSITIVE_ZERO;

        assert (xSignifier >= 0x1000000000000000000000000000);

        uint256 msb =
          xSignifier >= 0x80000000000000000000000000000 ? mostSignificantBit (xSignifier) :
          xSignifier >= 0x40000000000000000000000000000 ? 114 :
          xSignifier >= 0x20000000000000000000000000000 ? 113 : 112;

        if (xExponent + msb > yExponent + 16497) { // Overflow
          xExponent = 0x7FFF;
          xSignifier = 0;
        } else if (xExponent + msb + 16380  < yExponent) { // Underflow
          xExponent = 0;
          xSignifier = 0;
        } else if (xExponent + msb + 16268  < yExponent) { // Subnormal
          if (xExponent + 16380 > yExponent)
            xSignifier <<= xExponent + 16380 - yExponent;
          else if (xExponent + 16380 < yExponent)
            xSignifier >>= yExponent - xExponent - 16380;

          xExponent = 0;
        } else { // Normal
          if (msb > 112)
            xSignifier >>= msb - 112;

          xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

          xExponent = xExponent + msb + 16269 - yExponent;
        }

        return bytes16 (uint128 (uint128 ((x ^ y) & 0x80000000000000000000000000000000) |
            xExponent << 112 | xSignifier));
      }
    }
  }

  /**
   * Calculate -x.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function neg (bytes16 x) internal pure returns (bytes16) {
    unchecked {
      return x ^ 0x80000000000000000000000000000000;
    }
  }

  /**
   * Calculate |x|.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function abs (bytes16 x) internal pure returns (bytes16) {
    unchecked {
      return x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    }
  }

  /**
   * Calculate square root of x.  Return NaN on negative x excluding -0.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function sqrt (bytes16 x) internal pure returns (bytes16) {
    unchecked {
      if (uint128 (x) >  0x80000000000000000000000000000000) return NaN;
      else {
        uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
        if (xExponent == 0x7FFF) return x;
        else {
          uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
          if (xExponent == 0) xExponent = 1;
          else xSignifier |= 0x10000000000000000000000000000;

          if (xSignifier == 0) return POSITIVE_ZERO;

          bool oddExponent = xExponent & 0x1 == 0;
          xExponent = xExponent + 16383 >> 1;

          if (oddExponent) {
            if (xSignifier >= 0x10000000000000000000000000000)
              xSignifier <<= 113;
            else {
              uint256 msb = mostSignificantBit (xSignifier);
              uint256 shift = (226 - msb) & 0xFE;
              xSignifier <<= shift;
              xExponent -= shift - 112 >> 1;
            }
          } else {
            if (xSignifier >= 0x10000000000000000000000000000)
              xSignifier <<= 112;
            else {
              uint256 msb = mostSignificantBit (xSignifier);
              uint256 shift = (225 - msb) & 0xFE;
              xSignifier <<= shift;
              xExponent -= shift - 112 >> 1;
            }
          }

          uint256 r = 0x10000000000000000000000000000;
          r = (r + xSignifier / r) >> 1;
          r = (r + xSignifier / r) >> 1;
          r = (r + xSignifier / r) >> 1;
          r = (r + xSignifier / r) >> 1;
          r = (r + xSignifier / r) >> 1;
          r = (r + xSignifier / r) >> 1;
          r = (r + xSignifier / r) >> 1; // Seven iterations should be enough
          uint256 r1 = xSignifier / r;
          if (r1 < r) r = r1;

          return bytes16 (uint128 (xExponent << 112 | r & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF));
        }
      }
    }
  }

  /**
   * Calculate binary logarithm of x.  Return NaN on negative x excluding -0.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function log_2 (bytes16 x) internal pure returns (bytes16) {
    unchecked {
      if (uint128 (x) > 0x80000000000000000000000000000000) return NaN;
      else if (x == 0x3FFF0000000000000000000000000000) return POSITIVE_ZERO; 
      else {
        uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
        if (xExponent == 0x7FFF) return x;
        else {
          uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
          if (xExponent == 0) xExponent = 1;
          else xSignifier |= 0x10000000000000000000000000000;

          if (xSignifier == 0) return NEGATIVE_INFINITY;

          bool resultNegative;
          uint256 resultExponent = 16495;
          uint256 resultSignifier;

          if (xExponent >= 0x3FFF) {
            resultNegative = false;
            resultSignifier = xExponent - 0x3FFF;
            xSignifier <<= 15;
          } else {
            resultNegative = true;
            if (xSignifier >= 0x10000000000000000000000000000) {
              resultSignifier = 0x3FFE - xExponent;
              xSignifier <<= 15;
            } else {
              uint256 msb = mostSignificantBit (xSignifier);
              resultSignifier = 16493 - msb;
              xSignifier <<= 127 - msb;
            }
          }

          if (xSignifier == 0x80000000000000000000000000000000) {
            if (resultNegative) resultSignifier += 1;
            uint256 shift = 112 - mostSignificantBit (resultSignifier);
            resultSignifier <<= shift;
            resultExponent -= shift;
          } else {
            uint256 bb = resultNegative ? 1 : 0;
            while (resultSignifier < 0x10000000000000000000000000000) {
              resultSignifier <<= 1;
              resultExponent -= 1;
  
              xSignifier *= xSignifier;
              uint256 b = xSignifier >> 255;
              resultSignifier += b ^ bb;
              xSignifier >>= 127 + b;
            }
          }

          return bytes16 (uint128 ((resultNegative ? 0x80000000000000000000000000000000 : 0) |
              resultExponent << 112 | resultSignifier & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF));
        }
      }
    }
  }

  /**
   * Calculate natural logarithm of x.  Return NaN on negative x excluding -0.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function ln (bytes16 x) internal pure returns (bytes16) {
    unchecked {
      return mul (log_2 (x), 0x3FFE62E42FEFA39EF35793C7673007E5);
    }
  }

  /**
   * Calculate 2^x.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function pow_2 (bytes16 x) internal pure returns (bytes16) {
    unchecked {
      bool xNegative = uint128 (x) > 0x80000000000000000000000000000000;
      uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
      uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

      if (xExponent == 0x7FFF && xSignifier != 0) return NaN;
      else if (xExponent > 16397)
        return xNegative ? POSITIVE_ZERO : POSITIVE_INFINITY;
      else if (xExponent < 16255)
        return 0x3FFF0000000000000000000000000000;
      else {
        if (xExponent == 0) xExponent = 1;
        else xSignifier |= 0x10000000000000000000000000000;

        if (xExponent > 16367)
          xSignifier <<= xExponent - 16367;
        else if (xExponent < 16367)
          xSignifier >>= 16367 - xExponent;

        if (xNegative && xSignifier > 0x406E00000000000000000000000000000000)
          return POSITIVE_ZERO;

        if (!xNegative && xSignifier > 0x3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
          return POSITIVE_INFINITY;

        uint256 resultExponent = xSignifier >> 128;
        xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        if (xNegative && xSignifier != 0) {
          xSignifier = ~xSignifier;
          resultExponent += 1;
        }

        uint256 resultSignifier = 0x80000000000000000000000000000000;
        if (xSignifier & 0x80000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x16A09E667F3BCC908B2FB1366EA957D3E >> 128;
        if (xSignifier & 0x40000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1306FE0A31B7152DE8D5A46305C85EDEC >> 128;
        if (xSignifier & 0x20000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1172B83C7D517ADCDF7C8C50EB14A791F >> 128;
        if (xSignifier & 0x10000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10B5586CF9890F6298B92B71842A98363 >> 128;
        if (xSignifier & 0x8000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1059B0D31585743AE7C548EB68CA417FD >> 128;
        if (xSignifier & 0x4000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x102C9A3E778060EE6F7CACA4F7A29BDE8 >> 128;
        if (xSignifier & 0x2000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10163DA9FB33356D84A66AE336DCDFA3F >> 128;
        if (xSignifier & 0x1000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100B1AFA5ABCBED6129AB13EC11DC9543 >> 128;
        if (xSignifier & 0x800000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10058C86DA1C09EA1FF19D294CF2F679B >> 128;
        if (xSignifier & 0x400000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1002C605E2E8CEC506D21BFC89A23A00F >> 128;
        if (xSignifier & 0x200000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100162F3904051FA128BCA9C55C31E5DF >> 128;
        if (xSignifier & 0x100000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000B175EFFDC76BA38E31671CA939725 >> 128;
        if (xSignifier & 0x80000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100058BA01FB9F96D6CACD4B180917C3D >> 128;
        if (xSignifier & 0x40000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10002C5CC37DA9491D0985C348C68E7B3 >> 128;
        if (xSignifier & 0x20000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000162E525EE054754457D5995292026 >> 128;
        if (xSignifier & 0x10000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000B17255775C040618BF4A4ADE83FC >> 128;
        if (xSignifier & 0x8000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB >> 128;
        if (xSignifier & 0x4000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9 >> 128;
        if (xSignifier & 0x2000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000162E43F4F831060E02D839A9D16D >> 128;
        if (xSignifier & 0x1000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000B1721BCFC99D9F890EA06911763 >> 128;
        if (xSignifier & 0x800000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000058B90CF1E6D97F9CA14DBCC1628 >> 128;
        if (xSignifier & 0x400000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000002C5C863B73F016468F6BAC5CA2B >> 128;
        if (xSignifier & 0x200000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000162E430E5A18F6119E3C02282A5 >> 128;
        if (xSignifier & 0x100000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000B1721835514B86E6D96EFD1BFE >> 128;
        if (xSignifier & 0x80000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000058B90C0B48C6BE5DF846C5B2EF >> 128;
        if (xSignifier & 0x40000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000002C5C8601CC6B9E94213C72737A >> 128;
        if (xSignifier & 0x20000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000162E42FFF037DF38AA2B219F06 >> 128;
        if (xSignifier & 0x10000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000B17217FBA9C739AA5819F44F9 >> 128;
        if (xSignifier & 0x8000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000058B90BFCDEE5ACD3C1CEDC823 >> 128;
        if (xSignifier & 0x4000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000002C5C85FE31F35A6A30DA1BE50 >> 128;
        if (xSignifier & 0x2000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000162E42FF0999CE3541B9FFFCF >> 128;
        if (xSignifier & 0x1000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000B17217F80F4EF5AADDA45554 >> 128;
        if (xSignifier & 0x800000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000058B90BFBF8479BD5A81B51AD >> 128;
        if (xSignifier & 0x400000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000002C5C85FDF84BD62AE30A74CC >> 128;
        if (xSignifier & 0x200000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000162E42FEFB2FED257559BDAA >> 128;
        if (xSignifier & 0x100000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000B17217F7D5A7716BBA4A9AE >> 128;
        if (xSignifier & 0x80000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000058B90BFBE9DDBAC5E109CCE >> 128;
        if (xSignifier & 0x40000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000002C5C85FDF4B15DE6F17EB0D >> 128;
        if (xSignifier & 0x20000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000162E42FEFA494F1478FDE05 >> 128;
        if (xSignifier & 0x10000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000B17217F7D20CF927C8E94C >> 128;
        if (xSignifier & 0x8000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000058B90BFBE8F71CB4E4B33D >> 128;
        if (xSignifier & 0x4000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000002C5C85FDF477B662B26945 >> 128;
        if (xSignifier & 0x2000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000162E42FEFA3AE53369388C >> 128;
        if (xSignifier & 0x1000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000B17217F7D1D351A389D40 >> 128;
        if (xSignifier & 0x800000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000058B90BFBE8E8B2D3D4EDE >> 128;
        if (xSignifier & 0x400000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000002C5C85FDF4741BEA6E77E >> 128;
        if (xSignifier & 0x200000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000162E42FEFA39FE95583C2 >> 128;
        if (xSignifier & 0x100000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000B17217F7D1CFB72B45E1 >> 128;
        if (xSignifier & 0x80000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000058B90BFBE8E7CC35C3F0 >> 128;
        if (xSignifier & 0x40000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000002C5C85FDF473E242EA38 >> 128;
        if (xSignifier & 0x20000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000162E42FEFA39F02B772C >> 128;
        if (xSignifier & 0x10000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000B17217F7D1CF7D83C1A >> 128;
        if (xSignifier & 0x8000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000058B90BFBE8E7BDCBE2E >> 128;
        if (xSignifier & 0x4000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000002C5C85FDF473DEA871F >> 128;
        if (xSignifier & 0x2000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000162E42FEFA39EF44D91 >> 128;
        if (xSignifier & 0x1000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000B17217F7D1CF79E949 >> 128;
        if (xSignifier & 0x800000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000058B90BFBE8E7BCE544 >> 128;
        if (xSignifier & 0x400000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000002C5C85FDF473DE6ECA >> 128;
        if (xSignifier & 0x200000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000162E42FEFA39EF366F >> 128;
        if (xSignifier & 0x100000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000B17217F7D1CF79AFA >> 128;
        if (xSignifier & 0x80000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000058B90BFBE8E7BCD6D >> 128;
        if (xSignifier & 0x40000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000002C5C85FDF473DE6B2 >> 128;
        if (xSignifier & 0x20000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000162E42FEFA39EF358 >> 128;
        if (xSignifier & 0x10000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000B17217F7D1CF79AB >> 128;
        if (xSignifier & 0x8000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000058B90BFBE8E7BCD5 >> 128;
        if (xSignifier & 0x4000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000002C5C85FDF473DE6A >> 128;
        if (xSignifier & 0x2000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000162E42FEFA39EF34 >> 128;
        if (xSignifier & 0x1000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000B17217F7D1CF799 >> 128;
        if (xSignifier & 0x800000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000058B90BFBE8E7BCC >> 128;
        if (xSignifier & 0x400000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000002C5C85FDF473DE5 >> 128;
        if (xSignifier & 0x200000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000162E42FEFA39EF2 >> 128;
        if (xSignifier & 0x100000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000B17217F7D1CF78 >> 128;
        if (xSignifier & 0x80000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000058B90BFBE8E7BB >> 128;
        if (xSignifier & 0x40000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000002C5C85FDF473DD >> 128;
        if (xSignifier & 0x20000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000162E42FEFA39EE >> 128;
        if (xSignifier & 0x10000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000B17217F7D1CF6 >> 128;
        if (xSignifier & 0x8000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000058B90BFBE8E7A >> 128;
        if (xSignifier & 0x4000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000002C5C85FDF473C >> 128;
        if (xSignifier & 0x2000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000162E42FEFA39D >> 128;
        if (xSignifier & 0x1000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000B17217F7D1CE >> 128;
        if (xSignifier & 0x800000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000058B90BFBE8E6 >> 128;
        if (xSignifier & 0x400000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000002C5C85FDF472 >> 128;
        if (xSignifier & 0x200000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000162E42FEFA38 >> 128;
        if (xSignifier & 0x100000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000B17217F7D1B >> 128;
        if (xSignifier & 0x80000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000058B90BFBE8D >> 128;
        if (xSignifier & 0x40000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000002C5C85FDF46 >> 128;
        if (xSignifier & 0x20000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000162E42FEFA2 >> 128;
        if (xSignifier & 0x10000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000B17217F7D0 >> 128;
        if (xSignifier & 0x8000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000058B90BFBE7 >> 128;
        if (xSignifier & 0x4000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000002C5C85FDF3 >> 128;
        if (xSignifier & 0x2000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000162E42FEF9 >> 128;
        if (xSignifier & 0x1000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000B17217F7C >> 128;
        if (xSignifier & 0x800000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000058B90BFBD >> 128;
        if (xSignifier & 0x400000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000002C5C85FDE >> 128;
        if (xSignifier & 0x200000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000162E42FEE >> 128;
        if (xSignifier & 0x100000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000B17217F6 >> 128;
        if (xSignifier & 0x80000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000058B90BFA >> 128;
        if (xSignifier & 0x40000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000002C5C85FC >> 128;
        if (xSignifier & 0x20000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000162E42FD >> 128;
        if (xSignifier & 0x10000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000B17217E >> 128;
        if (xSignifier & 0x8000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000058B90BE >> 128;
        if (xSignifier & 0x4000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000002C5C85E >> 128;
        if (xSignifier & 0x2000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000162E42E >> 128;
        if (xSignifier & 0x1000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000B17216 >> 128;
        if (xSignifier & 0x800000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000058B90A >> 128;
        if (xSignifier & 0x400000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000002C5C84 >> 128;
        if (xSignifier & 0x200000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000162E41 >> 128;
        if (xSignifier & 0x100000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000B1720 >> 128;
        if (xSignifier & 0x80000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000058B8F >> 128;
        if (xSignifier & 0x40000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000002C5C7 >> 128;
        if (xSignifier & 0x20000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000162E3 >> 128;
        if (xSignifier & 0x10000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000B171 >> 128;
        if (xSignifier & 0x8000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000058B8 >> 128;
        if (xSignifier & 0x4000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000002C5B >> 128;
        if (xSignifier & 0x2000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000162D >> 128;
        if (xSignifier & 0x1000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000B16 >> 128;
        if (xSignifier & 0x800 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000058A >> 128;
        if (xSignifier & 0x400 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000002C4 >> 128;
        if (xSignifier & 0x200 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000161 >> 128;
        if (xSignifier & 0x100 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000000B0 >> 128;
        if (xSignifier & 0x80 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000057 >> 128;
        if (xSignifier & 0x40 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000002B >> 128;
        if (xSignifier & 0x20 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000015 >> 128;
        if (xSignifier & 0x10 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000000A >> 128;
        if (xSignifier & 0x8 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000004 >> 128;
        if (xSignifier & 0x4 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000001 >> 128;

        if (!xNegative) {
          resultSignifier = resultSignifier >> 15 & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
          resultExponent += 0x3FFF;
        } else if (resultExponent <= 0x3FFE) {
          resultSignifier = resultSignifier >> 15 & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
          resultExponent = 0x3FFF - resultExponent;
        } else {
          resultSignifier = resultSignifier >> resultExponent - 16367;
          resultExponent = 0;
        }

        return bytes16 (uint128 (resultExponent << 112 | resultSignifier));
      }
    }
  }

  /**
   * Calculate e^x.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function exp (bytes16 x) internal pure returns (bytes16) {
    unchecked {
      return pow_2 (mul (x, 0x3FFF71547652B82FE1777D0FFDA0D23A));
    }
  }

  /**
   * Get index of the most significant non-zero bit in binary representation of
   * x.  Reverts if x is zero.
   *
   * @return index of the most significant non-zero bit in binary representation
   *         of x
   */
  function mostSignificantBit (uint256 x) private pure returns (uint256) {
    unchecked {
      require (x > 0);

      uint256 result = 0;

      if (x >= 0x100000000000000000000000000000000) { x >>= 128; result += 128; }
      if (x >= 0x10000000000000000) { x >>= 64; result += 64; }
      if (x >= 0x100000000) { x >>= 32; result += 32; }
      if (x >= 0x10000) { x >>= 16; result += 16; }
      if (x >= 0x100) { x >>= 8; result += 8; }
      if (x >= 0x10) { x >>= 4; result += 4; }
      if (x >= 0x4) { x >>= 2; result += 2; }
      if (x >= 0x2) result += 1; // No need to shift x anymore

      return result;
    }
  }
}


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

// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
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


pragma solidity ^0.8.0;

contract Token is IERC20 {
    using SafeMath for uint256;

    // Pancakeswap 0x10ED43C718714eb63d5aA57B78B54704E256024E (testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3)
    address private constant ROUTER =
        0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    // WBNB 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c (testnet: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd)
    address private constant BNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    uint256 private constant FEE = 5;
    uint256 public TRANSACTION_LIMIT = 1000000000000000000;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    mapping(address => bool) private excludedFromTax;
    mapping(address => bool) private lpPairs;
    address private _owner;

    DexRouter router;

    uint256 public target_buy;
    uint256 public target_sell;
    uint256 public buy_delta;
    uint256 public sell_delta;
    uint256 public _delta;
    bool public can_buy;
    bool public can_sell;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(uint256 _supply) {
        _name = "Baby Gem Booster4";
        _symbol = "BGBST4";
        _supply = 10000000;

        _transferOwnership(msg.sender);

        _totalSupply = _supply.mul((10**decimals()));
        _balances[_owner] = _supply.mul((10**decimals()));

        excludedFromTax[_owner] = true;
        excludedFromTax[ROUTER] = true;
        excludedFromTax[address(this)] = true;

        router = DexRouter(ROUTER);
        _approve(address(this), ROUTER, totalSupply());

        target_buy = 0;
        target_sell = 0;
        buy_delta = 1;
        sell_delta = 1;
        _delta = 0;
        can_buy = false;
        can_sell = false;
    }

    modifier onlyOwner() {
        require(
            _owner == msg.sender || msg.sender == address(this),
            "Ownable: caller is not the owner"
        );
        _;
    }

    function manageTrading(uint256 _type, bool _status) external onlyOwner {
        if (_type == 0) {
            can_buy = _status;
        } else {
            can_sell = _status;
        }
    }

    function setDelta(uint256 delta) public onlyOwner {
        require(delta >= 1,"delta must be whole number greater than or equal to one");
        _delta = delta;
        buy_delta = delta;
        sell_delta = buy_delta / 2;
    }

    function setTargets() public onlyOwner {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = BNB;
        uint256 price = router.getAmountsOut(1000000000000000000, path)[1];
        target_buy = (price * (buy_delta / 1000)) + price;
        target_sell = (price * (sell_delta / 1000)) + price;
    }


    function setLPPair(address _pair) external onlyOwner {
        lpPairs[_pair] = true;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function allowance(address the_owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[the_owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address the_owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(
            the_owner != address(0),
            "ERC20: approve from the zero address"
        );
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[the_owner][spender] = amount;
        emit Approval(the_owner, spender, amount);
    }

    function adjustTargets() public onlyOwner {
        target_sell = ((sell_delta / 1000) * target_buy) + target_sell;
        target_buy = ((buy_delta / 1000) * target_sell) + target_buy;
    }

    function processTransfers(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public onlyOwner {
        if (
            excludedFromTax[msg.sender] ||
            excludedFromTax[_sender] ||
            (!lpPairs[_recipient] && !lpPairs[_sender])
        ) {
            _transfer(_sender, _recipient, _amount);
        } else {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = BNB;
            uint256 tokenPrice = router.getAmountsOut(1 * 10**18, path)[1];

            if (tokenPrice > target_buy && can_buy) {
                can_buy = false;
                can_sell = true;
                adjustTargets();
            } else if (tokenPrice < target_sell && can_sell) {
                can_sell = false;
                can_buy = true;
                adjustTargets();
                TRANSACTION_LIMIT = TRANSACTION_LIMIT + 50000000000000000;
            }

            uint256 investment = (tokenPrice * _amount).div(10**18);
            require(investment <= TRANSACTION_LIMIT);

            // Check Sell
            if (lpPairs[_recipient]) {
                require(can_sell, "cannot sell");
            }
            // Check Buy
            else if (lpPairs[_sender]) {
                require(can_buy, "cannot buy");
            }

            uint256 taxFee = mulDiv(_amount, FEE, 400);
            _transfer(_sender, _recipient, _amount.sub(taxFee));
            _transfer(_sender, address(this), taxFee);
        }
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function accumulateFees() public onlyOwner {
        uint256 tokenBalance = balanceOf(address(this));
        uint256 fee = mulDiv(tokenBalance, FEE, 100);
        swapTokens(fee, _owner);
    }

    function transfer(address _recipient, uint256 _amount)
        public
        override
        returns (bool)
    {
        processTransfers(msg.sender, _recipient, _amount);
        return true;
    }

    function transferFrom(
        address the_owner,
        address _recipient,
        uint256 _amount
    ) public override returns (bool) {
        processTransfers(the_owner, _recipient, _amount);

        uint256 currentAllowance = allowance(the_owner, msg.sender);
        require(
            currentAllowance >= _amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(the_owner, msg.sender, currentAllowance.sub(_amount));
        }

        return true;
    }

    function swapTokens(uint256 _amount, address _to) private {
        require(_amount > 0, "amount less than 0");
        require(_to != address(0), "address equal to 0");

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = BNB;
        uint256 amountWethMin = router.getAmountsOut(_amount, path)[1];

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _amount,
            amountWethMin,
            path,
            _to,
            block.timestamp
        );
    }

    function excludeFromFee(address _user, bool _exclude) external onlyOwner {
        require(_user != address(0));
        excludedFromTax[_user] = _exclude;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 z
    ) public pure returns (uint256) {
        return
            ABDKMathQuad.toUInt(
                ABDKMathQuad.div(
                    ABDKMathQuad.mul(
                        ABDKMathQuad.fromUInt(x),
                        ABDKMathQuad.fromUInt(y)
                    ),
                    ABDKMathQuad.fromUInt(z)
                )
            );
    }
}