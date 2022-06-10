/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;


library ABDKMath64x64 {
    /*
     * Minimum value signed 64.64-bit fixed point number may have.
     */
    int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;

    /*
     * Maximum value signed 64.64-bit fixed point number may have.
     */
    int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    /**
     * Convert signed 256-bit integer number into signed 64.64-bit fixed point
     * number.  Revert on overflow.
     *
     * @param x signed 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function fromInt(int256 x) internal pure returns (int128) {
        require(x >= -0x8000000000000000 && x <= 0x7FFFFFFFFFFFFFFF);
        return int128(x << 64);
    }

    /**
     * Convert signed 64.64 fixed point number into signed 64-bit integer number
     * rounding down.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64-bit integer number
     */
    function toInt(int128 x) internal pure returns (int64) {
        return int64(x >> 64);
    }

    /**
     * Convert unsigned 256-bit integer number into signed 64.64-bit fixed point
     * number.  Revert on overflow.
     *
     * @param x unsigned 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function fromUInt(uint256 x) internal pure returns (int128) {
        require(x <= 0x7FFFFFFFFFFFFFFF);
        return int128(x << 64);
    }

    /**
     * Convert signed 64.64 fixed point number into unsigned 64-bit integer
     * number rounding down.  Revert on underflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return unsigned 64-bit integer number
     */
    function toUInt(int128 x) internal pure returns (uint64) {
        require(x >= 0);
        return uint64(x >> 64);
    }

    /**
     * Convert signed 128.128 fixed point number into signed 64.64-bit fixed point
     * number rounding down.  Revert on overflow.
     *
     * @param x signed 128.128-bin fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function from128x128(int256 x) internal pure returns (int128) {
        int256 result = x >> 64;
        require(result >= MIN_64x64 && result <= MAX_64x64);
        return int128(result);
    }

    /**
     * Convert signed 64.64 fixed point number into signed 128.128 fixed point
     * number.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 128.128 fixed point number
     */
    function to128x128(int128 x) internal pure returns (int256) {
        return int256(x) << 64;
    }

    /**
     * Calculate x + y.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function add(int128 x, int128 y) internal pure returns (int128) {
        int256 result = int256(x) + y;
        require(result >= MIN_64x64 && result <= MAX_64x64);
        return int128(result);
    }

    /**
     * Calculate x - y.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function sub(int128 x, int128 y) internal pure returns (int128) {
        int256 result = int256(x) - y;
        require(result >= MIN_64x64 && result <= MAX_64x64);
        return int128(result);
    }

    /**
     * Calculate x * y rounding down.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function mul(int128 x, int128 y) internal pure returns (int128) {
        int256 result = (int256(x) * y) >> 64;
        require(result >= MIN_64x64 && result <= MAX_64x64);
        return int128(result);
    }

    /**
     * Calculate x * y rounding towards zero, where x is signed 64.64 fixed point
     * number and y is signed 256-bit integer number.  Revert on overflow.
     *
     * @param x signed 64.64 fixed point number
     * @param y signed 256-bit integer number
     * @return signed 256-bit integer number
     */
    function muli(int128 x, int256 y) internal pure returns (int256) {
        if (x == MIN_64x64) {
            require(
                y >= -0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF &&
                    y <= 0x1000000000000000000000000000000000000000000000000
            );
            return -y << 63;
        } else {
            bool negativeResult = false;
            if (x < 0) {
                x = -x;
                negativeResult = true;
            }
            if (y < 0) {
                y = -y; // We rely on overflow behavior here
                negativeResult = !negativeResult;
            }
            uint256 absoluteResult = mulu(x, uint256(y));
            if (negativeResult) {
                require(absoluteResult <= 0x8000000000000000000000000000000000000000000000000000000000000000);
                return -int256(absoluteResult); // We rely on overflow behavior here
            } else {
                require(absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
                return int256(absoluteResult);
            }
        }
    }

    /**
     * Calculate x * y rounding down, where x is signed 64.64 fixed point number
     * and y is unsigned 256-bit integer number.  Revert on overflow.
     *
     * @param x signed 64.64 fixed point number
     * @param y unsigned 256-bit integer number
     * @return unsigned 256-bit integer number
     */
    function mulu(int128 x, uint256 y) internal pure returns (uint256) {
        if (y == 0) return 0;

        require(x >= 0);

        uint256 lo = (uint256(x) * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) >> 64;
        uint256 hi = uint256(x) * (y >> 128);

        require(hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        hi <<= 64;

        require(hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - lo);
        return hi + lo;
    }

    /**
     * Calculate x / y rounding towards zero.  Revert on overflow or when y is
     * zero.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function div(int128 x, int128 y) internal pure returns (int128) {
        require(y != 0);
        int256 result = (int256(x) << 64) / y;
        require(result >= MIN_64x64 && result <= MAX_64x64);
        return int128(result);
    }

    /**
     * Calculate x / y rounding towards zero, where x and y are signed 256-bit
     * integer numbers.  Revert on overflow or when y is zero.
     *
     * @param x signed 256-bit integer number
     * @param y signed 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function divi(int256 x, int256 y) internal pure returns (int128) {
        require(y != 0);

        bool negativeResult = false;
        if (x < 0) {
            x = -x; // We rely on overflow behavior here
            negativeResult = true;
        }
        if (y < 0) {
            y = -y; // We rely on overflow behavior here
            negativeResult = !negativeResult;
        }
        uint128 absoluteResult = divuu(uint256(x), uint256(y));
        if (negativeResult) {
            require(absoluteResult <= 0x80000000000000000000000000000000);
            return -int128(absoluteResult); // We rely on overflow behavior here
        } else {
            require(absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            return int128(absoluteResult); // We rely on overflow behavior here
        }
    }

    /**
     * Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
     * integer numbers.  Revert on overflow or when y is zero.
     *
     * @param x unsigned 256-bit integer number
     * @param y unsigned 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function divu(uint256 x, uint256 y) internal pure returns (int128) {
        require(y != 0);
        uint128 result = divuu(x, y);
        require(result <= uint128(MAX_64x64));
        return int128(result);
    }

    /**
     * Calculate -x.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function neg(int128 x) internal pure returns (int128) {
        require(x != MIN_64x64);
        return -x;
    }

    /**
     * Calculate |x|.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function abs(int128 x) internal pure returns (int128) {
        require(x != MIN_64x64);
        return x < 0 ? -x : x;
    }

    /**
     * Calculate 1 / x rounding towards zero.  Revert on overflow or when x is
     * zero.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function inv(int128 x) internal pure returns (int128) {
        require(x != 0);
        int256 result = int256(0x100000000000000000000000000000000) / x;
        require(result >= MIN_64x64 && result <= MAX_64x64);
        return int128(result);
    }

    /**
     * Calculate arithmetics average of x and y, i.e. (x + y) / 2 rounding down.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function avg(int128 x, int128 y) internal pure returns (int128) {
        return int128((int256(x) + int256(y)) >> 1);
    }

    /**
     * Calculate geometric average of x and y, i.e. sqrt (x * y) rounding down.
     * Revert on overflow or in case x * y is negative.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function gavg(int128 x, int128 y) internal pure returns (int128) {
        int256 m = int256(x) * int256(y);
        require(m >= 0);
        require(m < 0x4000000000000000000000000000000000000000000000000000000000000000);
        return int128(sqrtu(uint256(m)));
    }

    /**
     * Calculate x^y assuming 0^0 is 1, where x is signed 64.64 fixed point number
     * and y is unsigned 256-bit integer number.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y uint256 value
     * @return signed 64.64-bit fixed point number
     */
    function pow(int128 x, uint256 y) internal pure returns (int128) {
        bool negative = x < 0 && y & 1 == 1;

        uint256 absX = uint128(x < 0 ? -x : x);
        uint256 absResult;
        absResult = 0x100000000000000000000000000000000;

        if (absX <= 0x10000000000000000) {
            absX <<= 63;
            while (y != 0) {
                if (y & 0x1 != 0) {
                    absResult = (absResult * absX) >> 127;
                }
                absX = (absX * absX) >> 127;

                if (y & 0x2 != 0) {
                    absResult = (absResult * absX) >> 127;
                }
                absX = (absX * absX) >> 127;

                if (y & 0x4 != 0) {
                    absResult = (absResult * absX) >> 127;
                }
                absX = (absX * absX) >> 127;

                if (y & 0x8 != 0) {
                    absResult = (absResult * absX) >> 127;
                }
                absX = (absX * absX) >> 127;

                y >>= 4;
            }

            absResult >>= 64;
        } else {
            uint256 absXShift = 63;
            if (absX < 0x1000000000000000000000000) {
                absX <<= 32;
                absXShift -= 32;
            }
            if (absX < 0x10000000000000000000000000000) {
                absX <<= 16;
                absXShift -= 16;
            }
            if (absX < 0x1000000000000000000000000000000) {
                absX <<= 8;
                absXShift -= 8;
            }
            if (absX < 0x10000000000000000000000000000000) {
                absX <<= 4;
                absXShift -= 4;
            }
            if (absX < 0x40000000000000000000000000000000) {
                absX <<= 2;
                absXShift -= 2;
            }
            if (absX < 0x80000000000000000000000000000000) {
                absX <<= 1;
                absXShift -= 1;
            }

            uint256 resultShift = 0;
            while (y != 0) {
                require(absXShift < 64);

                if (y & 0x1 != 0) {
                    absResult = (absResult * absX) >> 127;
                    resultShift += absXShift;
                    if (absResult > 0x100000000000000000000000000000000) {
                        absResult >>= 1;
                        resultShift += 1;
                    }
                }
                absX = (absX * absX) >> 127;
                absXShift <<= 1;
                if (absX >= 0x100000000000000000000000000000000) {
                    absX >>= 1;
                    absXShift += 1;
                }

                y >>= 1;
            }

            require(resultShift < 64);
            absResult >>= 64 - resultShift;
        }
        int256 result = negative ? -int256(absResult) : int256(absResult);
        require(result >= MIN_64x64 && result <= MAX_64x64);
        return int128(result);
    }

    /**
     * Calculate sqrt (x) rounding down.  Revert if x < 0.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function sqrt(int128 x) internal pure returns (int128) {
        require(x >= 0);
        return int128(sqrtu(uint256(x) << 64));
    }

    /**
     * Calculate binary logarithm of x.  Revert if x <= 0.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function log_2(int128 x) internal pure returns (int128) {
        require(x > 0);

        int256 msb = 0;
        int256 xc = x;
        if (xc >= 0x10000000000000000) {
            xc >>= 64;
            msb += 64;
        }
        if (xc >= 0x100000000) {
            xc >>= 32;
            msb += 32;
        }
        if (xc >= 0x10000) {
            xc >>= 16;
            msb += 16;
        }
        if (xc >= 0x100) {
            xc >>= 8;
            msb += 8;
        }
        if (xc >= 0x10) {
            xc >>= 4;
            msb += 4;
        }
        if (xc >= 0x4) {
            xc >>= 2;
            msb += 2;
        }
        if (xc >= 0x2) msb += 1; // No need to shift xc anymore

        int256 result = (msb - 64) << 64;
        uint256 ux = uint256(x) << uint256(127 - msb);
        for (int256 bit = 0x8000000000000000; bit > 0; bit >>= 1) {
            ux *= ux;
            uint256 b = ux >> 255;
            ux >>= 127 + b;
            result += bit * int256(b);
        }

        return int128(result);
    }

    /**
     * Calculate natural logarithm of x.  Revert if x <= 0.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function ln(int128 x) internal pure returns (int128) {
        require(x > 0);

        return int128((uint256(log_2(x)) * 0xB17217F7D1CF79ABC9E3B39803F2F6AF) >> 128);
    }

    /**
     * Calculate binary exponent of x.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function exp_2(int128 x) internal pure returns (int128) {
        require(x < 0x400000000000000000); // Overflow

        if (x < -0x400000000000000000) return 0; // Underflow

        uint256 result = 0x80000000000000000000000000000000;

        if (x & 0x8000000000000000 > 0) result = (result * 0x16A09E667F3BCC908B2FB1366EA957D3E) >> 128;
        if (x & 0x4000000000000000 > 0) result = (result * 0x1306FE0A31B7152DE8D5A46305C85EDEC) >> 128;
        if (x & 0x2000000000000000 > 0) result = (result * 0x1172B83C7D517ADCDF7C8C50EB14A791F) >> 128;
        if (x & 0x1000000000000000 > 0) result = (result * 0x10B5586CF9890F6298B92B71842A98363) >> 128;
        if (x & 0x800000000000000 > 0) result = (result * 0x1059B0D31585743AE7C548EB68CA417FD) >> 128;
        if (x & 0x400000000000000 > 0) result = (result * 0x102C9A3E778060EE6F7CACA4F7A29BDE8) >> 128;
        if (x & 0x200000000000000 > 0) result = (result * 0x10163DA9FB33356D84A66AE336DCDFA3F) >> 128;
        if (x & 0x100000000000000 > 0) result = (result * 0x100B1AFA5ABCBED6129AB13EC11DC9543) >> 128;
        if (x & 0x80000000000000 > 0) result = (result * 0x10058C86DA1C09EA1FF19D294CF2F679B) >> 128;
        if (x & 0x40000000000000 > 0) result = (result * 0x1002C605E2E8CEC506D21BFC89A23A00F) >> 128;
        if (x & 0x20000000000000 > 0) result = (result * 0x100162F3904051FA128BCA9C55C31E5DF) >> 128;
        if (x & 0x10000000000000 > 0) result = (result * 0x1000B175EFFDC76BA38E31671CA939725) >> 128;
        if (x & 0x8000000000000 > 0) result = (result * 0x100058BA01FB9F96D6CACD4B180917C3D) >> 128;
        if (x & 0x4000000000000 > 0) result = (result * 0x10002C5CC37DA9491D0985C348C68E7B3) >> 128;
        if (x & 0x2000000000000 > 0) result = (result * 0x1000162E525EE054754457D5995292026) >> 128;
        if (x & 0x1000000000000 > 0) result = (result * 0x10000B17255775C040618BF4A4ADE83FC) >> 128;
        if (x & 0x800000000000 > 0) result = (result * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB) >> 128;
        if (x & 0x400000000000 > 0) result = (result * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9) >> 128;
        if (x & 0x200000000000 > 0) result = (result * 0x10000162E43F4F831060E02D839A9D16D) >> 128;
        if (x & 0x100000000000 > 0) result = (result * 0x100000B1721BCFC99D9F890EA06911763) >> 128;
        if (x & 0x80000000000 > 0) result = (result * 0x10000058B90CF1E6D97F9CA14DBCC1628) >> 128;
        if (x & 0x40000000000 > 0) result = (result * 0x1000002C5C863B73F016468F6BAC5CA2B) >> 128;
        if (x & 0x20000000000 > 0) result = (result * 0x100000162E430E5A18F6119E3C02282A5) >> 128;
        if (x & 0x10000000000 > 0) result = (result * 0x1000000B1721835514B86E6D96EFD1BFE) >> 128;
        if (x & 0x8000000000 > 0) result = (result * 0x100000058B90C0B48C6BE5DF846C5B2EF) >> 128;
        if (x & 0x4000000000 > 0) result = (result * 0x10000002C5C8601CC6B9E94213C72737A) >> 128;
        if (x & 0x2000000000 > 0) result = (result * 0x1000000162E42FFF037DF38AA2B219F06) >> 128;
        if (x & 0x1000000000 > 0) result = (result * 0x10000000B17217FBA9C739AA5819F44F9) >> 128;
        if (x & 0x800000000 > 0) result = (result * 0x1000000058B90BFCDEE5ACD3C1CEDC823) >> 128;
        if (x & 0x400000000 > 0) result = (result * 0x100000002C5C85FE31F35A6A30DA1BE50) >> 128;
        if (x & 0x200000000 > 0) result = (result * 0x10000000162E42FF0999CE3541B9FFFCF) >> 128;
        if (x & 0x100000000 > 0) result = (result * 0x100000000B17217F80F4EF5AADDA45554) >> 128;
        if (x & 0x80000000 > 0) result = (result * 0x10000000058B90BFBF8479BD5A81B51AD) >> 128;
        if (x & 0x40000000 > 0) result = (result * 0x1000000002C5C85FDF84BD62AE30A74CC) >> 128;
        if (x & 0x20000000 > 0) result = (result * 0x100000000162E42FEFB2FED257559BDAA) >> 128;
        if (x & 0x10000000 > 0) result = (result * 0x1000000000B17217F7D5A7716BBA4A9AE) >> 128;
        if (x & 0x8000000 > 0) result = (result * 0x100000000058B90BFBE9DDBAC5E109CCE) >> 128;
        if (x & 0x4000000 > 0) result = (result * 0x10000000002C5C85FDF4B15DE6F17EB0D) >> 128;
        if (x & 0x2000000 > 0) result = (result * 0x1000000000162E42FEFA494F1478FDE05) >> 128;
        if (x & 0x1000000 > 0) result = (result * 0x10000000000B17217F7D20CF927C8E94C) >> 128;
        if (x & 0x800000 > 0) result = (result * 0x1000000000058B90BFBE8F71CB4E4B33D) >> 128;
        if (x & 0x400000 > 0) result = (result * 0x100000000002C5C85FDF477B662B26945) >> 128;
        if (x & 0x200000 > 0) result = (result * 0x10000000000162E42FEFA3AE53369388C) >> 128;
        if (x & 0x100000 > 0) result = (result * 0x100000000000B17217F7D1D351A389D40) >> 128;
        if (x & 0x80000 > 0) result = (result * 0x10000000000058B90BFBE8E8B2D3D4EDE) >> 128;
        if (x & 0x40000 > 0) result = (result * 0x1000000000002C5C85FDF4741BEA6E77E) >> 128;
        if (x & 0x20000 > 0) result = (result * 0x100000000000162E42FEFA39FE95583C2) >> 128;
        if (x & 0x10000 > 0) result = (result * 0x1000000000000B17217F7D1CFB72B45E1) >> 128;
        if (x & 0x8000 > 0) result = (result * 0x100000000000058B90BFBE8E7CC35C3F0) >> 128;
        if (x & 0x4000 > 0) result = (result * 0x10000000000002C5C85FDF473E242EA38) >> 128;
        if (x & 0x2000 > 0) result = (result * 0x1000000000000162E42FEFA39F02B772C) >> 128;
        if (x & 0x1000 > 0) result = (result * 0x10000000000000B17217F7D1CF7D83C1A) >> 128;
        if (x & 0x800 > 0) result = (result * 0x1000000000000058B90BFBE8E7BDCBE2E) >> 128;
        if (x & 0x400 > 0) result = (result * 0x100000000000002C5C85FDF473DEA871F) >> 128;
        if (x & 0x200 > 0) result = (result * 0x10000000000000162E42FEFA39EF44D91) >> 128;
        if (x & 0x100 > 0) result = (result * 0x100000000000000B17217F7D1CF79E949) >> 128;
        if (x & 0x80 > 0) result = (result * 0x10000000000000058B90BFBE8E7BCE544) >> 128;
        if (x & 0x40 > 0) result = (result * 0x1000000000000002C5C85FDF473DE6ECA) >> 128;
        if (x & 0x20 > 0) result = (result * 0x100000000000000162E42FEFA39EF366F) >> 128;
        if (x & 0x10 > 0) result = (result * 0x1000000000000000B17217F7D1CF79AFA) >> 128;
        if (x & 0x8 > 0) result = (result * 0x100000000000000058B90BFBE8E7BCD6D) >> 128;
        if (x & 0x4 > 0) result = (result * 0x10000000000000002C5C85FDF473DE6B2) >> 128;
        if (x & 0x2 > 0) result = (result * 0x1000000000000000162E42FEFA39EF358) >> 128;
        if (x & 0x1 > 0) result = (result * 0x10000000000000000B17217F7D1CF79AB) >> 128;

        result >>= uint256(63 - (x >> 64));
        require(result <= uint256(MAX_64x64));

        return int128(result);
    }

    /**
     * Calculate natural exponent of x.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function exp(int128 x) internal pure returns (int128) {
        require(x < 0x400000000000000000); // Overflow

        if (x < -0x400000000000000000) return 0; // Underflow

        return exp_2(int128((int256(x) * 0x171547652B82FE1777D0FFDA0D23A7D12) >> 128));
    }

    /**
     * Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
     * integer numbers.  Revert on overflow or when y is zero.
     *
     * @param x unsigned 256-bit integer number
     * @param y unsigned 256-bit integer number
     * @return unsigned 64.64-bit fixed point number
     */
    function divuu(uint256 x, uint256 y) private pure returns (uint128) {
        require(y != 0);

        uint256 result;

        if (x <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) result = (x << 64) / y;
        else {
            uint256 msb = 192;
            uint256 xc = x >> 192;
            if (xc >= 0x100000000) {
                xc >>= 32;
                msb += 32;
            }
            if (xc >= 0x10000) {
                xc >>= 16;
                msb += 16;
            }
            if (xc >= 0x100) {
                xc >>= 8;
                msb += 8;
            }
            if (xc >= 0x10) {
                xc >>= 4;
                msb += 4;
            }
            if (xc >= 0x4) {
                xc >>= 2;
                msb += 2;
            }
            if (xc >= 0x2) msb += 1; // No need to shift xc anymore

            result = (x << (255 - msb)) / (((y - 1) >> (msb - 191)) + 1);
            require(result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

            uint256 hi = result * (y >> 128);
            uint256 lo = result * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

            uint256 xh = x >> 192;
            uint256 xl = x << 64;

            if (xl < lo) xh -= 1;
            xl -= lo; // We rely on overflow behavior here
            lo = hi << 128;
            if (xl < lo) xh -= 1;
            xl -= lo; // We rely on overflow behavior here

            assert(xh == hi >> 128);

            result += xl / y;
        }

        require(result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        return uint128(result);
    }

    /**
     * Calculate sqrt (x) rounding down, where x is unsigned 256-bit integer
     * number.
     *
     * @param x unsigned 256-bit integer number
     * @return unsigned 128-bit integer number
     */
    function sqrtu(uint256 x) private pure returns (uint128) {
        if (x == 0) return 0;
        else {
            uint256 xx = x;
            uint256 r = 1;
            if (xx >= 0x100000000000000000000000000000000) {
                xx >>= 128;
                r <<= 64;
            }
            if (xx >= 0x10000000000000000) {
                xx >>= 64;
                r <<= 32;
            }
            if (xx >= 0x100000000) {
                xx >>= 32;
                r <<= 16;
            }
            if (xx >= 0x10000) {
                xx >>= 16;
                r <<= 8;
            }
            if (xx >= 0x100) {
                xx >>= 8;
                r <<= 4;
            }
            if (xx >= 0x10) {
                xx >>= 4;
                r <<= 2;
            }
            if (xx >= 0x8) {
                r <<= 1;
            }
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1; // Seven iterations should be enough
            uint256 r1 = x / r;
            return uint128(r < r1 ? r : r1);
        }
    }
}

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
    function fromInt(int256 x) internal pure returns (bytes16) {
        if (x == 0) return bytes16(0);
        else {
            // We rely on overflow behavior here
            uint256 result = uint256(x > 0 ? x : -x);

            uint256 msb = msb(result);
            if (msb < 112) result <<= 112 - msb;
            else if (msb > 112) result >>= msb - 112;

            result = (result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF) | ((16383 + msb) << 112);
            if (x < 0) result |= 0x80000000000000000000000000000000;

            return bytes16(uint128(result));
        }
    }

    /**
     * Convert quadruple precision number into signed 256-bit integer number
     * rounding towards zero.  Revert on overflow.
     *
     * @param x quadruple precision number
     * @return signed 256-bit integer number
     */
    function toInt(bytes16 x) internal pure returns (int256) {
        uint256 exponent = (uint128(x) >> 112) & 0x7FFF;

        require(exponent <= 16638); // Overflow
        if (exponent < 16383) return 0; // Underflow

        uint256 result = (uint256(uint128(x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF) | 0x10000000000000000000000000000;

        if (exponent < 16495) result >>= 16495 - exponent;
        else if (exponent > 16495) result <<= exponent - 16495;

        if (uint128(x) >= 0x80000000000000000000000000000000) {
            // Negative
            require(result <= 0x8000000000000000000000000000000000000000000000000000000000000000);
            return -int256(result); // We rely on overflow behavior here
        } else {
            require(result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            return int256(result);
        }
    }

    /**
     * Convert unsigned 256-bit integer number into quadruple precision number.
     *
     * @param x unsigned 256-bit integer number
     * @return quadruple precision number
     */
    function fromUInt(uint256 x) internal pure returns (bytes16) {
        if (x == 0) return bytes16(0);
        else {
            uint256 result = x;

            uint256 msb = msb(result);
            if (msb < 112) result <<= 112 - msb;
            else if (msb > 112) result >>= msb - 112;

            result = (result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF) | ((16383 + msb) << 112);

            return bytes16(uint128(result));
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
    function toUInt(bytes16 x) internal pure returns (uint256) {
        uint256 exponent = (uint128(x) >> 112) & 0x7FFF;

        if (exponent < 16383) return 0; // Underflow

        require(uint128(x) < 0x80000000000000000000000000000000); // Negative

        require(exponent <= 16638); // Overflow
        uint256 result = (uint256(uint128(x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF) | 0x10000000000000000000000000000;

        if (exponent < 16495) result >>= 16495 - exponent;
        else if (exponent > 16495) result <<= exponent - 16495;

        return result;
    }

    /**
     * Convert signed 128.128 bit fixed point number into quadruple precision
     * number.
     *
     * @param x signed 128.128 bit fixed point number
     * @return quadruple precision number
     */
    function from128x128(int256 x) internal pure returns (bytes16) {
        if (x == 0) return bytes16(0);
        else {
            // We rely on overflow behavior here
            uint256 result = uint256(x > 0 ? x : -x);

            uint256 msb = msb(result);
            if (msb < 112) result <<= 112 - msb;
            else if (msb > 112) result >>= msb - 112;

            result = (result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF) | ((16255 + msb) << 112);
            if (x < 0) result |= 0x80000000000000000000000000000000;

            return bytes16(uint128(result));
        }
    }

    /**
     * Convert quadruple precision number into signed 128.128 bit fixed point
     * number.  Revert on overflow.
     *
     * @param x quadruple precision number
     * @return signed 128.128 bit fixed point number
     */
    function to128x128(bytes16 x) internal pure returns (int256) {
        uint256 exponent = (uint128(x) >> 112) & 0x7FFF;

        require(exponent <= 16510); // Overflow
        if (exponent < 16255) return 0; // Underflow

        uint256 result = (uint256(uint128(x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF) | 0x10000000000000000000000000000;

        if (exponent < 16367) result >>= 16367 - exponent;
        else if (exponent > 16367) result <<= exponent - 16367;

        if (uint128(x) >= 0x80000000000000000000000000000000) {
            // Negative
            require(result <= 0x8000000000000000000000000000000000000000000000000000000000000000);
            return -int256(result); // We rely on overflow behavior here
        } else {
            require(result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            return int256(result);
        }
    }

    /**
     * Convert signed 64.64 bit fixed point number into quadruple precision
     * number.
     *
     * @param x signed 64.64 bit fixed point number
     * @return quadruple precision number
     */
    function from64x64(int128 x) internal pure returns (bytes16) {
        if (x == 0) return bytes16(0);
        else {
            // We rely on overflow behavior here
            uint256 result = uint128(x > 0 ? x : -x);

            uint256 msb = msb(result);
            if (msb < 112) result <<= 112 - msb;
            else if (msb > 112) result >>= msb - 112;

            result = (result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF) | ((16319 + msb) << 112);
            if (x < 0) result |= 0x80000000000000000000000000000000;

            return bytes16(uint128(result));
        }
    }

    /**
     * Convert quadruple precision number into signed 64.64 bit fixed point
     * number.  Revert on overflow.
     *
     * @param x quadruple precision number
     * @return signed 64.64 bit fixed point number
     */
    function to64x64(bytes16 x) internal pure returns (int128) {
        uint256 exponent = (uint128(x) >> 112) & 0x7FFF;

        require(exponent <= 16446); // Overflow
        if (exponent < 16319) return 0; // Underflow

        uint256 result = (uint256(uint128(x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF) | 0x10000000000000000000000000000;

        if (exponent < 16431) result >>= 16431 - exponent;
        else if (exponent > 16431) result <<= exponent - 16431;

        if (uint128(x) >= 0x80000000000000000000000000000000) {
            // Negative
            require(result <= 0x80000000000000000000000000000000);
            return -int128(result); // We rely on overflow behavior here
        } else {
            require(result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            return int128(result);
        }
    }

    /**
     * Convert octuple precision number into quadruple precision number.
     *
     * @param x octuple precision number
     * @return quadruple precision number
     */
    function fromOctuple(bytes32 x) internal pure returns (bytes16) {
        bool negative = x & 0x8000000000000000000000000000000000000000000000000000000000000000 > 0;

        uint256 exponent = (uint256(x) >> 236) & 0x7FFFF;
        uint256 significand = uint256(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        if (exponent == 0x7FFFF) {
            if (significand > 0) return NaN;
            else return negative ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
        }

        if (exponent > 278526) return negative ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
        else if (exponent < 245649) return negative ? NEGATIVE_ZERO : POSITIVE_ZERO;
        else if (exponent < 245761) {
            significand =
                (significand | 0x100000000000000000000000000000000000000000000000000000000000) >>
                (245885 - exponent);
            exponent = 0;
        } else {
            significand >>= 124;
            exponent -= 245760;
        }

        uint128 result = uint128(significand | (exponent << 112));
        if (negative) result |= 0x80000000000000000000000000000000;

        return bytes16(result);
    }

    /**
     * Convert quadruple precision number into octuple precision number.
     *
     * @param x quadruple precision number
     * @return octuple precision number
     */
    function toOctuple(bytes16 x) internal pure returns (bytes32) {
        uint256 exponent = (uint128(x) >> 112) & 0x7FFF;

        uint256 result = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        if (exponent == 0x7FFF)
            exponent = 0x7FFFF; // Infinity or NaN
        else if (exponent == 0) {
            if (result > 0) {
                uint256 msb = msb(result);
                result = (result << (236 - msb)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                exponent = 245649 + msb;
            }
        } else {
            result <<= 124;
            exponent += 245760;
        }

        result |= exponent << 236;
        if (uint128(x) >= 0x80000000000000000000000000000000)
            result |= 0x8000000000000000000000000000000000000000000000000000000000000000;

        return bytes32(result);
    }

    /**
     * Convert double precision number into quadruple precision number.
     *
     * @param x double precision number
     * @return quadruple precision number
     */
    function fromDouble(bytes8 x) internal pure returns (bytes16) {
        uint256 exponent = (uint64(x) >> 52) & 0x7FF;

        uint256 result = uint64(x) & 0xFFFFFFFFFFFFF;

        if (exponent == 0x7FF)
            exponent = 0x7FFF; // Infinity or NaN
        else if (exponent == 0) {
            if (result > 0) {
                uint256 msb = msb(result);
                result = (result << (112 - msb)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                exponent = 15309 + msb;
            }
        } else {
            result <<= 60;
            exponent += 15360;
        }

        result |= exponent << 112;
        if (x & 0x8000000000000000 > 0) result |= 0x80000000000000000000000000000000;

        return bytes16(uint128(result));
    }

    /**
     * Convert quadruple precision number into double precision number.
     *
     * @param x quadruple precision number
     * @return double precision number
     */
    function toDouble(bytes16 x) internal pure returns (bytes8) {
        bool negative = uint128(x) >= 0x80000000000000000000000000000000;

        uint256 exponent = (uint128(x) >> 112) & 0x7FFF;
        uint256 significand = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        if (exponent == 0x7FFF) {
            if (significand > 0) return 0x7FF8000000000000;
            // NaN
            else
                return
                    negative
                        ? bytes8(0xFFF0000000000000) // -Infinity
                        : bytes8(0x7FF0000000000000); // Infinity
        }

        if (exponent > 17406)
            return
                negative
                    ? bytes8(0xFFF0000000000000) // -Infinity
                    : bytes8(0x7FF0000000000000);
        // Infinity
        else if (exponent < 15309)
            return
                negative
                    ? bytes8(0x8000000000000000) // -0
                    : bytes8(0x0000000000000000);
        // 0
        else if (exponent < 15361) {
            significand = (significand | 0x10000000000000000000000000000) >> (15421 - exponent);
            exponent = 0;
        } else {
            significand >>= 60;
            exponent -= 15360;
        }

        uint64 result = uint64(significand | (exponent << 52));
        if (negative) result |= 0x8000000000000000;

        return bytes8(result);
    }

    /**
     * Test whether given quadruple precision number is NaN.
     *
     * @param x quadruple precision number
     * @return true if x is NaN, false otherwise
     */
    function isNaN(bytes16 x) internal pure returns (bool) {
        return uint128(x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF > 0x7FFF0000000000000000000000000000;
    }

    /**
     * Test whether given quadruple precision number is positive or negative
     * infinity.
     *
     * @param x quadruple precision number
     * @return true if x is positive or negative infinity, false otherwise
     */
    function isInfinity(bytes16 x) internal pure returns (bool) {
        return uint128(x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0x7FFF0000000000000000000000000000;
    }

    /**
     * Calculate sign of x, i.e. -1 if x is negative, 0 if x if zero, and 1 if x
     * is positive.  Note that sign (-0) is zero.  Revert if x is NaN.
     *
     * @param x quadruple precision number
     * @return sign of x
     */
    function sign(bytes16 x) internal pure returns (int8) {
        uint128 absoluteX = uint128(x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        require(absoluteX <= 0x7FFF0000000000000000000000000000); // Not NaN

        if (absoluteX == 0) return 0;
        else if (uint128(x) >= 0x80000000000000000000000000000000) return -1;
        else return 1;
    }

    /**
     * Calculate sign (x - y).  Revert if either argument is NaN, or both
     * arguments are infinities of the same sign.
     *
     * @param x quadruple precision number
     * @param y quadruple precision number
     * @return sign (x - y)
     */
    function cmp(bytes16 x, bytes16 y) internal pure returns (int8) {
        uint128 absoluteX = uint128(x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        require(absoluteX <= 0x7FFF0000000000000000000000000000); // Not NaN

        uint128 absoluteY = uint128(y) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        require(absoluteY <= 0x7FFF0000000000000000000000000000); // Not NaN

        // Not infinities of the same sign
        require(x != y || absoluteX < 0x7FFF0000000000000000000000000000);

        if (x == y) return 0;
        else {
            bool negativeX = uint128(x) >= 0x80000000000000000000000000000000;
            bool negativeY = uint128(y) >= 0x80000000000000000000000000000000;

            if (negativeX) {
                if (negativeY) return absoluteX > absoluteY ? -1 : int8(1);
                else return -1;
            } else {
                if (negativeY) return 1;
                else return absoluteX > absoluteY ? int8(1) : -1;
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
    function eq(bytes16 x, bytes16 y) internal pure returns (bool) {
        if (x == y) {
            return uint128(x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF < 0x7FFF0000000000000000000000000000;
        } else return false;
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
    function add(bytes16 x, bytes16 y) internal pure returns (bytes16) {
        uint256 xExponent = (uint128(x) >> 112) & 0x7FFF;
        uint256 yExponent = (uint128(y) >> 112) & 0x7FFF;

        if (xExponent == 0x7FFF) {
            if (yExponent == 0x7FFF) {
                if (x == y) return x;
                else return NaN;
            } else return x;
        } else if (yExponent == 0x7FFF) return y;
        else {
            bool xSign = uint128(x) >= 0x80000000000000000000000000000000;
            uint256 xSignifier = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            if (xExponent == 0) xExponent = 1;
            else xSignifier |= 0x10000000000000000000000000000;

            bool ySign = uint128(y) >= 0x80000000000000000000000000000000;
            uint256 ySignifier = uint128(y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            if (yExponent == 0) yExponent = 1;
            else ySignifier |= 0x10000000000000000000000000000;

            if (xSignifier == 0) return y == NEGATIVE_ZERO ? POSITIVE_ZERO : y;
            else if (ySignifier == 0) return x == NEGATIVE_ZERO ? POSITIVE_ZERO : x;
            else {
                int256 delta = int256(xExponent) - int256(yExponent);

                if (xSign == ySign) {
                    if (delta > 112) return x;
                    else if (delta > 0) ySignifier >>= uint256(delta);
                    else if (delta < -112) return y;
                    else if (delta < 0) {
                        xSignifier >>= uint256(-delta);
                        xExponent = yExponent;
                    }

                    xSignifier += ySignifier;

                    if (xSignifier >= 0x20000000000000000000000000000) {
                        xSignifier >>= 1;
                        xExponent += 1;
                    }

                    if (xExponent == 0x7FFF) return xSign ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
                    else {
                        if (xSignifier < 0x10000000000000000000000000000) xExponent = 0;
                        else xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

                        return
                            bytes16(
                                uint128(
                                    (xSign ? 0x80000000000000000000000000000000 : 0) | (xExponent << 112) | xSignifier
                                )
                            );
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
                    else if (delta > 1) ySignifier = ((ySignifier - 1) >> uint256(delta - 1)) + 1;
                    else if (delta < -112) xSignifier = 1;
                    else if (delta < -1) xSignifier = ((xSignifier - 1) >> uint256(-delta - 1)) + 1;

                    if (xSignifier >= ySignifier) xSignifier -= ySignifier;
                    else {
                        xSignifier = ySignifier - xSignifier;
                        xSign = ySign;
                    }

                    if (xSignifier == 0) return POSITIVE_ZERO;

                    uint256 msb = msb(xSignifier);

                    if (msb == 113) {
                        xSignifier = (xSignifier >> 1) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                        xExponent += 1;
                    } else if (msb < 112) {
                        uint256 shift = 112 - msb;
                        if (xExponent > shift) {
                            xSignifier = (xSignifier << shift) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                            xExponent -= shift;
                        } else {
                            xSignifier <<= xExponent - 1;
                            xExponent = 0;
                        }
                    } else xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

                    if (xExponent == 0x7FFF) return xSign ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
                    else
                        return
                            bytes16(
                                uint128(
                                    (xSign ? 0x80000000000000000000000000000000 : 0) | (xExponent << 112) | xSignifier
                                )
                            );
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
    function sub(bytes16 x, bytes16 y) internal pure returns (bytes16) {
        return add(x, y ^ 0x80000000000000000000000000000000);
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
    function mul(bytes16 x, bytes16 y) internal pure returns (bytes16) {
        uint256 xExponent = (uint128(x) >> 112) & 0x7FFF;
        uint256 yExponent = (uint128(y) >> 112) & 0x7FFF;

        if (xExponent == 0x7FFF) {
            if (yExponent == 0x7FFF) {
                if (x == y) return x ^ (y & 0x80000000000000000000000000000000);
                else if (x ^ y == 0x80000000000000000000000000000000) return x | y;
                else return NaN;
            } else {
                if (y & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
                else return x ^ (y & 0x80000000000000000000000000000000);
            }
        } else if (yExponent == 0x7FFF) {
            if (x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
            else return y ^ (x & 0x80000000000000000000000000000000);
        } else {
            uint256 xSignifier = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            if (xExponent == 0) xExponent = 1;
            else xSignifier |= 0x10000000000000000000000000000;

            uint256 ySignifier = uint128(y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            if (yExponent == 0) yExponent = 1;
            else ySignifier |= 0x10000000000000000000000000000;

            xSignifier *= ySignifier;
            if (xSignifier == 0)
                return (x ^ y) & 0x80000000000000000000000000000000 > 0 ? NEGATIVE_ZERO : POSITIVE_ZERO;

            xExponent += yExponent;

            uint256 msb = xSignifier >= 0x200000000000000000000000000000000000000000000000000000000
                ? 225
                : xSignifier >= 0x100000000000000000000000000000000000000000000000000000000
                ? 224
                : msb(xSignifier);

            if (xExponent + msb < 16496) {
                // Underflow
                xExponent = 0;
                xSignifier = 0;
            } else if (xExponent + msb < 16608) {
                // Subnormal
                if (xExponent < 16496) xSignifier >>= 16496 - xExponent;
                else if (xExponent > 16496) xSignifier <<= xExponent - 16496;
                xExponent = 0;
            } else if (xExponent + msb > 49373) {
                xExponent = 0x7FFF;
                xSignifier = 0;
            } else {
                if (msb > 112) xSignifier >>= msb - 112;
                else if (msb < 112) xSignifier <<= 112 - msb;

                xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

                xExponent = xExponent + msb - 16607;
            }

            return
                bytes16(
                    uint128(uint128((x ^ y) & 0x80000000000000000000000000000000) | (xExponent << 112) | xSignifier)
                );
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
    function div(bytes16 x, bytes16 y) internal pure returns (bytes16) {
        uint256 xExponent = (uint128(x) >> 112) & 0x7FFF;
        uint256 yExponent = (uint128(y) >> 112) & 0x7FFF;

        if (xExponent == 0x7FFF) {
            if (yExponent == 0x7FFF) return NaN;
            else return x ^ (y & 0x80000000000000000000000000000000);
        } else if (yExponent == 0x7FFF) {
            if (y & 0x0000FFFFFFFFFFFFFFFFFFFFFFFFFFFF != 0) return NaN;
            else return POSITIVE_ZERO | ((x ^ y) & 0x80000000000000000000000000000000);
        } else if (y & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) {
            if (x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
            else return POSITIVE_INFINITY | ((x ^ y) & 0x80000000000000000000000000000000);
        } else {
            uint256 ySignifier = uint128(y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            if (yExponent == 0) yExponent = 1;
            else ySignifier |= 0x10000000000000000000000000000;

            uint256 xSignifier = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            if (xExponent == 0) {
                if (xSignifier != 0) {
                    uint256 shift = 226 - msb(xSignifier);

                    xSignifier <<= shift;

                    xExponent = 1;
                    yExponent += shift - 114;
                }
            } else {
                xSignifier = (xSignifier | 0x10000000000000000000000000000) << 114;
            }

            xSignifier = xSignifier / ySignifier;
            if (xSignifier == 0)
                return (x ^ y) & 0x80000000000000000000000000000000 > 0 ? NEGATIVE_ZERO : POSITIVE_ZERO;

            assert(xSignifier >= 0x1000000000000000000000000000);

            uint256 msb = xSignifier >= 0x80000000000000000000000000000
                ? msb(xSignifier)
                : xSignifier >= 0x40000000000000000000000000000
                ? 114
                : xSignifier >= 0x20000000000000000000000000000
                ? 113
                : 112;

            if (xExponent + msb > yExponent + 16497) {
                // Overflow
                xExponent = 0x7FFF;
                xSignifier = 0;
            } else if (xExponent + msb + 16380 < yExponent) {
                // Underflow
                xExponent = 0;
                xSignifier = 0;
            } else if (xExponent + msb + 16268 < yExponent) {
                // Subnormal
                if (xExponent + 16380 > yExponent) xSignifier <<= xExponent + 16380 - yExponent;
                else if (xExponent + 16380 < yExponent) xSignifier >>= yExponent - xExponent - 16380;

                xExponent = 0;
            } else {
                // Normal
                if (msb > 112) xSignifier >>= msb - 112;

                xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

                xExponent = xExponent + msb + 16269 - yExponent;
            }

            return
                bytes16(
                    uint128(uint128((x ^ y) & 0x80000000000000000000000000000000) | (xExponent << 112) | xSignifier)
                );
        }
    }

    /**
     * Calculate -x.
     *
     * @param x quadruple precision number
     * @return quadruple precision number
     */
    function neg(bytes16 x) internal pure returns (bytes16) {
        return x ^ 0x80000000000000000000000000000000;
    }

    /**
     * Calculate |x|.
     *
     * @param x quadruple precision number
     * @return quadruple precision number
     */
    function abs(bytes16 x) internal pure returns (bytes16) {
        return x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    }

    /**
     * Calculate square root of x.  Return NaN on negative x excluding -0.
     *
     * @param x quadruple precision number
     * @return quadruple precision number
     */
    function sqrt(bytes16 x) internal pure returns (bytes16) {
        if (uint128(x) > 0x80000000000000000000000000000000) return NaN;
        else {
            uint256 xExponent = (uint128(x) >> 112) & 0x7FFF;
            if (xExponent == 0x7FFF) return x;
            else {
                uint256 xSignifier = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                if (xExponent == 0) xExponent = 1;
                else xSignifier |= 0x10000000000000000000000000000;

                if (xSignifier == 0) return POSITIVE_ZERO;

                bool oddExponent = xExponent & 0x1 == 0;
                xExponent = (xExponent + 16383) >> 1;

                if (oddExponent) {
                    if (xSignifier >= 0x10000000000000000000000000000) xSignifier <<= 113;
                    else {
                        uint256 msb = msb(xSignifier);
                        uint256 shift = (226 - msb) & 0xFE;
                        xSignifier <<= shift;
                        xExponent -= (shift - 112) >> 1;
                    }
                } else {
                    if (xSignifier >= 0x10000000000000000000000000000) xSignifier <<= 112;
                    else {
                        uint256 msb = msb(xSignifier);
                        uint256 shift = (225 - msb) & 0xFE;
                        xSignifier <<= shift;
                        xExponent -= (shift - 112) >> 1;
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

                return bytes16(uint128((xExponent << 112) | (r & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF)));
            }
        }
    }

    /**
     * Calculate binary logarithm of x.  Return NaN on negative x excluding -0.
     *
     * @param x quadruple precision number
     * @return quadruple precision number
     */
    function log_2(bytes16 x) internal pure returns (bytes16) {
        if (uint128(x) > 0x80000000000000000000000000000000) return NaN;
        else if (x == 0x3FFF0000000000000000000000000000) return POSITIVE_ZERO;
        else {
            uint256 xExponent = (uint128(x) >> 112) & 0x7FFF;
            if (xExponent == 0x7FFF) return x;
            else {
                uint256 xSignifier = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
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
                        uint256 msb = msb(xSignifier);
                        resultSignifier = 16493 - msb;
                        xSignifier <<= 127 - msb;
                    }
                }

                if (xSignifier == 0x80000000000000000000000000000000) {
                    if (resultNegative) resultSignifier += 1;
                    uint256 shift = 112 - msb(resultSignifier);
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

                return
                    bytes16(
                        uint128(
                            (resultNegative ? 0x80000000000000000000000000000000 : 0) |
                                (resultExponent << 112) |
                                (resultSignifier & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
                        )
                    );
            }
        }
    }

    /**
     * Calculate natural logarithm of x.  Return NaN on negative x excluding -0.
     *
     * @param x quadruple precision number
     * @return quadruple precision number
     */
    function ln(bytes16 x) internal pure returns (bytes16) {
        return mul(log_2(x), 0x3FFE62E42FEFA39EF35793C7673007E5);
    }

    /**
     * Calculate 2^x.
     *
     * @param x quadruple precision number
     * @return quadruple precision number
     */
    function pow_2(bytes16 x) internal pure returns (bytes16) {
        bool xNegative = uint128(x) > 0x80000000000000000000000000000000;
        uint256 xExponent = (uint128(x) >> 112) & 0x7FFF;
        uint256 xSignifier = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        if (xExponent == 0x7FFF && xSignifier != 0) return NaN;
        else if (xExponent > 16397) return xNegative ? POSITIVE_ZERO : POSITIVE_INFINITY;
        else if (xExponent < 16255) return 0x3FFF0000000000000000000000000000;
        else {
            if (xExponent == 0) xExponent = 1;
            else xSignifier |= 0x10000000000000000000000000000;

            if (xExponent > 16367) xSignifier <<= xExponent - 16367;
            else if (xExponent < 16367) xSignifier >>= 16367 - xExponent;

            if (xNegative && xSignifier > 0x406E00000000000000000000000000000000) return POSITIVE_ZERO;

            if (!xNegative && xSignifier > 0x3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) return POSITIVE_INFINITY;

            uint256 resultExponent = xSignifier >> 128;
            xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            if (xNegative && xSignifier != 0) {
                xSignifier = ~xSignifier;
                resultExponent += 1;
            }

            uint256 resultSignifier = 0x80000000000000000000000000000000;
            if (xSignifier & 0x80000000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x16A09E667F3BCC908B2FB1366EA957D3E) >> 128;
            if (xSignifier & 0x40000000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1306FE0A31B7152DE8D5A46305C85EDEC) >> 128;
            if (xSignifier & 0x20000000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1172B83C7D517ADCDF7C8C50EB14A791F) >> 128;
            if (xSignifier & 0x10000000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10B5586CF9890F6298B92B71842A98363) >> 128;
            if (xSignifier & 0x8000000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1059B0D31585743AE7C548EB68CA417FD) >> 128;
            if (xSignifier & 0x4000000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x102C9A3E778060EE6F7CACA4F7A29BDE8) >> 128;
            if (xSignifier & 0x2000000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10163DA9FB33356D84A66AE336DCDFA3F) >> 128;
            if (xSignifier & 0x1000000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100B1AFA5ABCBED6129AB13EC11DC9543) >> 128;
            if (xSignifier & 0x800000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10058C86DA1C09EA1FF19D294CF2F679B) >> 128;
            if (xSignifier & 0x400000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1002C605E2E8CEC506D21BFC89A23A00F) >> 128;
            if (xSignifier & 0x200000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100162F3904051FA128BCA9C55C31E5DF) >> 128;
            if (xSignifier & 0x100000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000B175EFFDC76BA38E31671CA939725) >> 128;
            if (xSignifier & 0x80000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100058BA01FB9F96D6CACD4B180917C3D) >> 128;
            if (xSignifier & 0x40000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10002C5CC37DA9491D0985C348C68E7B3) >> 128;
            if (xSignifier & 0x20000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000162E525EE054754457D5995292026) >> 128;
            if (xSignifier & 0x10000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000B17255775C040618BF4A4ADE83FC) >> 128;
            if (xSignifier & 0x8000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB) >> 128;
            if (xSignifier & 0x4000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9) >> 128;
            if (xSignifier & 0x2000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000162E43F4F831060E02D839A9D16D) >> 128;
            if (xSignifier & 0x1000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000B1721BCFC99D9F890EA06911763) >> 128;
            if (xSignifier & 0x800000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000058B90CF1E6D97F9CA14DBCC1628) >> 128;
            if (xSignifier & 0x400000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000002C5C863B73F016468F6BAC5CA2B) >> 128;
            if (xSignifier & 0x200000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000162E430E5A18F6119E3C02282A5) >> 128;
            if (xSignifier & 0x100000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000B1721835514B86E6D96EFD1BFE) >> 128;
            if (xSignifier & 0x80000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000058B90C0B48C6BE5DF846C5B2EF) >> 128;
            if (xSignifier & 0x40000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000002C5C8601CC6B9E94213C72737A) >> 128;
            if (xSignifier & 0x20000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000162E42FFF037DF38AA2B219F06) >> 128;
            if (xSignifier & 0x10000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000B17217FBA9C739AA5819F44F9) >> 128;
            if (xSignifier & 0x8000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000058B90BFCDEE5ACD3C1CEDC823) >> 128;
            if (xSignifier & 0x4000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000002C5C85FE31F35A6A30DA1BE50) >> 128;
            if (xSignifier & 0x2000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000162E42FF0999CE3541B9FFFCF) >> 128;
            if (xSignifier & 0x1000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000B17217F80F4EF5AADDA45554) >> 128;
            if (xSignifier & 0x800000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000058B90BFBF8479BD5A81B51AD) >> 128;
            if (xSignifier & 0x400000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000002C5C85FDF84BD62AE30A74CC) >> 128;
            if (xSignifier & 0x200000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000162E42FEFB2FED257559BDAA) >> 128;
            if (xSignifier & 0x100000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000B17217F7D5A7716BBA4A9AE) >> 128;
            if (xSignifier & 0x80000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000058B90BFBE9DDBAC5E109CCE) >> 128;
            if (xSignifier & 0x40000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000002C5C85FDF4B15DE6F17EB0D) >> 128;
            if (xSignifier & 0x20000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000162E42FEFA494F1478FDE05) >> 128;
            if (xSignifier & 0x10000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000B17217F7D20CF927C8E94C) >> 128;
            if (xSignifier & 0x8000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000058B90BFBE8F71CB4E4B33D) >> 128;
            if (xSignifier & 0x4000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000002C5C85FDF477B662B26945) >> 128;
            if (xSignifier & 0x2000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000162E42FEFA3AE53369388C) >> 128;
            if (xSignifier & 0x1000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000B17217F7D1D351A389D40) >> 128;
            if (xSignifier & 0x800000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000058B90BFBE8E8B2D3D4EDE) >> 128;
            if (xSignifier & 0x400000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000002C5C85FDF4741BEA6E77E) >> 128;
            if (xSignifier & 0x200000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000162E42FEFA39FE95583C2) >> 128;
            if (xSignifier & 0x100000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000B17217F7D1CFB72B45E1) >> 128;
            if (xSignifier & 0x80000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000058B90BFBE8E7CC35C3F0) >> 128;
            if (xSignifier & 0x40000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000002C5C85FDF473E242EA38) >> 128;
            if (xSignifier & 0x20000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000162E42FEFA39F02B772C) >> 128;
            if (xSignifier & 0x10000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000B17217F7D1CF7D83C1A) >> 128;
            if (xSignifier & 0x8000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000058B90BFBE8E7BDCBE2E) >> 128;
            if (xSignifier & 0x4000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000002C5C85FDF473DEA871F) >> 128;
            if (xSignifier & 0x2000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000162E42FEFA39EF44D91) >> 128;
            if (xSignifier & 0x1000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000B17217F7D1CF79E949) >> 128;
            if (xSignifier & 0x800000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000058B90BFBE8E7BCE544) >> 128;
            if (xSignifier & 0x400000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000002C5C85FDF473DE6ECA) >> 128;
            if (xSignifier & 0x200000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000162E42FEFA39EF366F) >> 128;
            if (xSignifier & 0x100000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000B17217F7D1CF79AFA) >> 128;
            if (xSignifier & 0x80000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000058B90BFBE8E7BCD6D) >> 128;
            if (xSignifier & 0x40000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000002C5C85FDF473DE6B2) >> 128;
            if (xSignifier & 0x20000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000162E42FEFA39EF358) >> 128;
            if (xSignifier & 0x10000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000B17217F7D1CF79AB) >> 128;
            if (xSignifier & 0x8000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000058B90BFBE8E7BCD5) >> 128;
            if (xSignifier & 0x4000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000002C5C85FDF473DE6A) >> 128;
            if (xSignifier & 0x2000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000162E42FEFA39EF34) >> 128;
            if (xSignifier & 0x1000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000B17217F7D1CF799) >> 128;
            if (xSignifier & 0x800000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000058B90BFBE8E7BCC) >> 128;
            if (xSignifier & 0x400000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000002C5C85FDF473DE5) >> 128;
            if (xSignifier & 0x200000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000162E42FEFA39EF2) >> 128;
            if (xSignifier & 0x100000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000B17217F7D1CF78) >> 128;
            if (xSignifier & 0x80000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000058B90BFBE8E7BB) >> 128;
            if (xSignifier & 0x40000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000002C5C85FDF473DD) >> 128;
            if (xSignifier & 0x20000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000162E42FEFA39EE) >> 128;
            if (xSignifier & 0x10000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000B17217F7D1CF6) >> 128;
            if (xSignifier & 0x8000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000058B90BFBE8E7A) >> 128;
            if (xSignifier & 0x4000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000002C5C85FDF473C) >> 128;
            if (xSignifier & 0x2000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000162E42FEFA39D) >> 128;
            if (xSignifier & 0x1000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000B17217F7D1CE) >> 128;
            if (xSignifier & 0x800000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000058B90BFBE8E6) >> 128;
            if (xSignifier & 0x400000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000002C5C85FDF472) >> 128;
            if (xSignifier & 0x200000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000162E42FEFA38) >> 128;
            if (xSignifier & 0x100000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000B17217F7D1B) >> 128;
            if (xSignifier & 0x80000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000058B90BFBE8D) >> 128;
            if (xSignifier & 0x40000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000002C5C85FDF46) >> 128;
            if (xSignifier & 0x20000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000162E42FEFA2) >> 128;
            if (xSignifier & 0x10000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000000B17217F7D0) >> 128;
            if (xSignifier & 0x8000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000058B90BFBE7) >> 128;
            if (xSignifier & 0x4000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000002C5C85FDF3) >> 128;
            if (xSignifier & 0x2000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000000162E42FEF9) >> 128;
            if (xSignifier & 0x1000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000000B17217F7C) >> 128;
            if (xSignifier & 0x800000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000000058B90BFBD) >> 128;
            if (xSignifier & 0x400000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000002C5C85FDE) >> 128;
            if (xSignifier & 0x200000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000000162E42FEE) >> 128;
            if (xSignifier & 0x100000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000000B17217F6) >> 128;
            if (xSignifier & 0x80000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000000058B90BFA) >> 128;
            if (xSignifier & 0x40000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000000002C5C85FC) >> 128;
            if (xSignifier & 0x20000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000000162E42FD) >> 128;
            if (xSignifier & 0x10000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000000000B17217E) >> 128;
            if (xSignifier & 0x8000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000000058B90BE) >> 128;
            if (xSignifier & 0x4000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000000002C5C85E) >> 128;
            if (xSignifier & 0x2000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000000000162E42E) >> 128;
            if (xSignifier & 0x1000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000000000B17216) >> 128;
            if (xSignifier & 0x800000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000000000058B90A) >> 128;
            if (xSignifier & 0x400000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000000002C5C84) >> 128;
            if (xSignifier & 0x200000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000000000162E41) >> 128;
            if (xSignifier & 0x100000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000000000B1720) >> 128;
            if (xSignifier & 0x80000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000000000058B8F) >> 128;
            if (xSignifier & 0x40000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000000000002C5C7) >> 128;
            if (xSignifier & 0x20000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000000000162E3) >> 128;
            if (xSignifier & 0x10000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000000000000B171) >> 128;
            if (xSignifier & 0x8000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000000000058B8) >> 128;
            if (xSignifier & 0x4000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000000000002C5B) >> 128;
            if (xSignifier & 0x2000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000000000000162D) >> 128;
            if (xSignifier & 0x1000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000000000000B16) >> 128;
            if (xSignifier & 0x800 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000000000000058A) >> 128;
            if (xSignifier & 0x400 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000000000002C4) >> 128;
            if (xSignifier & 0x200 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000000000000161) >> 128;
            if (xSignifier & 0x100 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000000000000B0) >> 128;
            if (xSignifier & 0x80 > 0) resultSignifier = (resultSignifier * 0x100000000000000000000000000000057) >> 128;
            if (xSignifier & 0x40 > 0) resultSignifier = (resultSignifier * 0x10000000000000000000000000000002B) >> 128;
            if (xSignifier & 0x20 > 0) resultSignifier = (resultSignifier * 0x100000000000000000000000000000015) >> 128;
            if (xSignifier & 0x10 > 0) resultSignifier = (resultSignifier * 0x10000000000000000000000000000000A) >> 128;
            if (xSignifier & 0x8 > 0) resultSignifier = (resultSignifier * 0x100000000000000000000000000000004) >> 128;
            if (xSignifier & 0x4 > 0) resultSignifier = (resultSignifier * 0x100000000000000000000000000000001) >> 128;

            if (!xNegative) {
                resultSignifier = (resultSignifier >> 15) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                resultExponent += 0x3FFF;
            } else if (resultExponent <= 0x3FFE) {
                resultSignifier = (resultSignifier >> 15) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                resultExponent = 0x3FFF - resultExponent;
            } else {
                resultSignifier = resultSignifier >> (resultExponent - 16367);
                resultExponent = 0;
            }

            return bytes16(uint128((resultExponent << 112) | resultSignifier));
        }
    }

    /**
     * Calculate e^x.
     *
     * @param x quadruple precision number
     * @return quadruple precision number
     */
    function exp(bytes16 x) internal pure returns (bytes16) {
        return pow_2(mul(x, 0x3FFF71547652B82FE1777D0FFDA0D23A));
    }

    /**
     * Get index of the most significant non-zero bit in binary representation of
     * x.  Reverts if x is zero.
     *
     * @return index of the most significant non-zero bit in binary representation
     *         of x
     */
    function msb(uint256 x) private pure returns (uint256) {
        require(x > 0);

        uint256 result = 0;

        if (x >= 0x100000000000000000000000000000000) {
            x >>= 128;
            result += 128;
        }
        if (x >= 0x10000000000000000) {
            x >>= 64;
            result += 64;
        }
        if (x >= 0x100000000) {
            x >>= 32;
            result += 32;
        }
        if (x >= 0x10000) {
            x >>= 16;
            result += 16;
        }
        if (x >= 0x100) {
            x >>= 8;
            result += 8;
        }
        if (x >= 0x10) {
            x >>= 4;
            result += 4;
        }
        if (x >= 0x4) {
            x >>= 2;
            result += 2;
        }
        if (x >= 0x2) result += 1; // No need to shift x anymore

        return result;
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
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
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract BlockstarLockupStaking is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    struct UserInfo {
        uint256 amount;
        uint256 lockupDuration;
        uint returnPer;
        uint256 starttime;
        uint256 endtime;
    }

    struct UserHistory {
        uint256 amount;
        uint256 lockupDuration;
        uint returnPer;
        uint256 starttime;
        uint256 endtime;
    }

    struct PoolInfo {
        uint256 lockupDuration;
        uint returnPer;
    }


    IERC20 public token;
    bool public started = true;
    uint256 public emergencyWithdrawFess = 2500;
     

    mapping(address =>  UserInfo[]) private _userinfo;
    mapping(address =>  UserHistory[]) private _userhistory;
    mapping(uint256 => PoolInfo) public pooldata;
    mapping(address => uint) public rewardEarned;

    uint public totalStake = 0;
    uint public totalWithdrawal = 0;
    uint public totalRewardsDistribution = 0;
    
    constructor(
       address _token,
       bool _started
    ) public {
        token = IERC20(_token);
        started = _started;
    }

    event Deposit(address indexed user, uint256 indexed lockupDuration, uint256 amount , uint returnPer);
    event Withdraw(address indexed user, uint256 amount , uint256 reward , uint256 total );
    event WithdrawAll(address indexed user, uint256 amount);
    
    
    function addPool(uint256 _lockupDuration , uint _returnPer ) external onlyOwner {
        PoolInfo storage pool = pooldata[_lockupDuration];
        pool.lockupDuration = _lockupDuration;
        pool.returnPer = _returnPer;

    }

    function setToken(IERC20 _token) external onlyOwner {
        token = _token;
    }

    function toggleStaking(bool _start) external onlyOwner {
        started = _start;
    }

    function getUserDeposite(address _userAddress) public view returns (UserInfo[] memory)
    {
        return _userinfo[_userAddress];
    }

    function getUserDepositeHistory(address _userAddress) public view returns (UserHistory[] memory)
    {
        return _userhistory[_userAddress];
    }

    function getUserTotalDepositeAmount(address _userAddress) public view returns (uint)
    {
        UserInfo[] storage userdata = _userinfo[_userAddress];
        uint len = userdata.length;
        uint total = 0;
        for (uint256 i = 0; i < len; i++) {
            total += userdata[i].amount;
        }
        return total;
    }

    
    function pendingRewards(address _user) external view returns (uint256) {
        UserInfo[] storage userdata = _userinfo[_user];
        uint len = userdata.length;
        uint256 total = 0;
        for (uint256 i = 0; i < len; i++) {
            if( block.timestamp > userdata[i].endtime && userdata[i].amount > 0 ){
                total += getCompoundedInterest(userdata[i].amount , userdata[i].returnPer * 10**20 , userdata[i].lockupDuration) -  userdata[i].amount;
            }
        }
        return total;
    }

    function pendingWithdraw(address _user) external view returns (uint256) {
        UserInfo[] storage userdata = _userinfo[_user];
        uint len = userdata.length;
        uint256 total = 0;
        for (uint256 i = 0; i < len; i++) {
            if( block.timestamp > userdata[i].endtime &&  userdata[i].amount > 0){
                total += userdata[i].amount ;
            }
        }
        return total;
    }

    
    function deposit(uint256 _amount , uint256 _lockupDuration) external {
        require(address(token) != address(0), "Token Not Set Yet");
        require(address(msg.sender) != address(0), "please Enter Valid Adderss");
        require(started == true, "Not Stared yet!");
        require(_amount > 0, "Amount must be greater than Zero!");
        PoolInfo storage pool = pooldata[_lockupDuration];
        
        require(pool.lockupDuration > 0 && pool.returnPer > 0 , "No Pool exist With Locktime !");
        
        token.safeTransferFrom(address(msg.sender), address(this), _amount);
       
        _userinfo[msg.sender].push(
            UserInfo
            (
            _amount,
            _lockupDuration,
            pool.returnPer,
            block.timestamp,
            block.timestamp + _lockupDuration
         ));

         _userhistory[msg.sender].push(
            UserHistory
            (
            _amount,
            _lockupDuration,
            pool.returnPer,
            block.timestamp,
            block.timestamp + _lockupDuration
         ));

         totalStake += _amount;
        emit Deposit(msg.sender , _lockupDuration , _amount ,pool.returnPer );
    }

   

    function checkAvaliblereward() internal
        view
        returns (bool){
        UserInfo[] storage userdata = _userinfo[msg.sender];
        uint len = userdata.length;
        bool check = false;
        for (uint256 i = 0; i < len; i++) {
            if( block.timestamp > userdata[i].endtime && userdata[i].amount > 0){
                check = true;
            }
        }
        if(check){
            return true;
        }
        else{
            return false;
        }
    }

    function withdraw() external {
        require(address(token) != address(0), "Token Not Set Yet");
        require(address(msg.sender) != address(0), "please Enter Valid Adderss");
        //Need Avlible Balance
        uint256 avalible = totalStake - totalWithdrawal;
        require(token.balanceOf(address(this)) > avalible, "Currently Withdraw not Avalible");
        //Check Is Reward Avalible For Withdraw
        bool avalibleReward = checkAvaliblereward();
        require(avalibleReward, "No Reward Avalible For Withdraw !");
        UserInfo[] storage userdata = _userinfo[msg.sender];
        uint len = userdata.length;
        uint256 withdraw_total = 0;
        uint256 total_reward = 0;
        uint256 total_amount = 0;
        for (uint256 i = 0; i < len; i++) {
            if( block.timestamp > userdata[i].endtime && userdata[i].amount > 0){
                uint256 totalAmount =  getCompoundedInterest(userdata[i].amount , userdata[i].returnPer * 10**20 , userdata[i].lockupDuration);
                uint256 amount =  userdata[i].amount;
                uint256 reward = totalAmount - amount;
                uint256 total = amount  +  reward  ;
                
                token.transfer(address(msg.sender) , total);
                delete _userinfo[msg.sender][i];
                total_reward += reward;
                withdraw_total += total;
                total_amount += amount; 
                totalWithdrawal += userdata[i].amount;
                totalRewardsDistribution += reward;
                
            }
        }
        rewardEarned[msg.sender] += total_reward;
      emit Withdraw(msg.sender , total_amount , total_reward , withdraw_total);
    }

    function getNextRewardTime(address _user) external view returns (uint) {

        UserInfo[] storage userdata = _userinfo[_user];
        uint len = userdata.length;
        uint next = 0;

        if(len > 0){
            next = userdata[0].endtime;
        }
        
        for (uint256 i = 0; i < len; i++) {
            if (userdata[i].starttime < block.timestamp && userdata[i].amount > 0 && userdata[i].endtime >=  block.timestamp && userdata[i].endtime < next ) {
                next = userdata[i].endtime;
            }
        }

        return next;
    }


    function emergencyWithdraw() external {
        require(address(token) != address(0), "Token Not Set Yet");
        require(address(msg.sender) != address(0), "please Enter Valid Adderss");
        //Need Avlible Balance
        uint256 avalible = totalStake - totalWithdrawal;
        require(token.balanceOf(address(this)) > avalible, "Currently Withdraw not Avalible");
        //Check Is Reward Avalible For Withdraw
        
        UserInfo[] storage userdata = _userinfo[msg.sender];
        uint len = userdata.length;
        uint256 withdraw_total = 0;
        uint256 total_amount = 0;
        for (uint256 i = 0; i < len; i++) {
            if( userdata[i].amount > 0){
                uint256 fees = (userdata[i].amount * emergencyWithdrawFess) / 10000;
                uint256 amount =  userdata[i].amount;
                uint256 total = amount - fees  ;
                
                token.transfer(address(msg.sender) , total);
                delete _userinfo[msg.sender][i];
                withdraw_total += total;
                total_amount += amount; 
                totalWithdrawal += amount;
                
            }
        }
      emit WithdrawAll(msg.sender , total_amount);
    } 

    function bnbLiquidity(address payable _reciever, uint256 _amount) public onlyOwner {
        _reciever.transfer(_amount); 
    }

    function transferAnyERC20Token( address payaddress ,address tokenAddress, uint256 tokens ) public onlyOwner 
    {
       IERC20(tokenAddress).transfer(payaddress, tokens);
    }

    function pow(int128 _x, uint256 _n) internal pure returns (int128 r) {
        r = ABDKMath64x64.fromUInt(1);
        while (_n > 0) {
            if (_n % 2 == 1) {
                r = ABDKMath64x64.mul(r, _x);
                _n -= 1;
            } else {
                _x = ABDKMath64x64.mul(_x, _x);
                _n /= 2;
            }
        }
    }


    function getCompoundedInterest(
        uint256 _principal,
        uint256 _ratio,
        uint256 _n
    ) public pure returns (uint256) {
        uint256 DAY = 1 days;
        uint256 daysCount = _n.div(DAY);
        return
            ABDKMath64x64.mulu(
                pow(ABDKMath64x64.add(ABDKMath64x64.fromUInt(1), ABDKMath64x64.divu(_ratio, 10**18)), daysCount),
                _principal
            );
    }

}