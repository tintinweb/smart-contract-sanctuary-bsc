/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// SPDX-License-Identifier: MIT
/*
 * ABDK Math 64.64 Smart Contract Library.  Copyright © 2019 by ABDK Consulting.
 * Author: Mikhail Vladimirov <[email protected]>
 */
pragma solidity >=0.6.2 <0.8.0;

/**
 * Smart contract library of mathematical functions operating with signed
 * 64.64-bit fixed point numbers.  Signed 64.64-bit fixed point number is
 * basically a simple fraction whose numerator is signed 128-bit integer and
 * denominator is 2^64.  As long as denominator is always the same, there is no
 * need to store it, thus in Solidity signed 64.64-bit fixed point numbers are
 * represented by int128 type holding only the numerator.
 */
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
                require(
                    absoluteResult <=
                        0x8000000000000000000000000000000000000000000000000000000000000000
                );
                return -int256(absoluteResult); // We rely on overflow behavior here
            } else {
                require(
                    absoluteResult <=
                        0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                );
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

        uint256 lo = (uint256(x) * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) >>
            64;
        uint256 hi = uint256(x) * (y >> 128);

        require(hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        hi <<= 64;

        require(
            hi <=
                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF -
                    lo
        );
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
        require(
            m <
                0x4000000000000000000000000000000000000000000000000000000000000000
        );
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
        uint256 absoluteResult;
        bool negativeResult = false;
        if (x >= 0) {
            absoluteResult = powu(uint256(x) << 63, y);
        } else {
            // We rely on overflow behavior here
            absoluteResult = powu(uint256(uint128(-x)) << 63, y);
            negativeResult = y & 1 > 0;
        }

        absoluteResult >>= 63;

        if (negativeResult) {
            require(absoluteResult <= 0x80000000000000000000000000000000);
            return -int128(absoluteResult); // We rely on overflow behavior here
        } else {
            require(absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            return int128(absoluteResult); // We rely on overflow behavior here
        }
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

        return
            int128(
                (uint256(log_2(x)) * 0xB17217F7D1CF79ABC9E3B39803F2F6AF) >> 128
            );
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

        if (x & 0x8000000000000000 > 0)
            result = (result * 0x16A09E667F3BCC908B2FB1366EA957D3E) >> 128;
        if (x & 0x4000000000000000 > 0)
            result = (result * 0x1306FE0A31B7152DE8D5A46305C85EDEC) >> 128;
        if (x & 0x2000000000000000 > 0)
            result = (result * 0x1172B83C7D517ADCDF7C8C50EB14A791F) >> 128;
        if (x & 0x1000000000000000 > 0)
            result = (result * 0x10B5586CF9890F6298B92B71842A98363) >> 128;
        if (x & 0x800000000000000 > 0)
            result = (result * 0x1059B0D31585743AE7C548EB68CA417FD) >> 128;
        if (x & 0x400000000000000 > 0)
            result = (result * 0x102C9A3E778060EE6F7CACA4F7A29BDE8) >> 128;
        if (x & 0x200000000000000 > 0)
            result = (result * 0x10163DA9FB33356D84A66AE336DCDFA3F) >> 128;
        if (x & 0x100000000000000 > 0)
            result = (result * 0x100B1AFA5ABCBED6129AB13EC11DC9543) >> 128;
        if (x & 0x80000000000000 > 0)
            result = (result * 0x10058C86DA1C09EA1FF19D294CF2F679B) >> 128;
        if (x & 0x40000000000000 > 0)
            result = (result * 0x1002C605E2E8CEC506D21BFC89A23A00F) >> 128;
        if (x & 0x20000000000000 > 0)
            result = (result * 0x100162F3904051FA128BCA9C55C31E5DF) >> 128;
        if (x & 0x10000000000000 > 0)
            result = (result * 0x1000B175EFFDC76BA38E31671CA939725) >> 128;
        if (x & 0x8000000000000 > 0)
            result = (result * 0x100058BA01FB9F96D6CACD4B180917C3D) >> 128;
        if (x & 0x4000000000000 > 0)
            result = (result * 0x10002C5CC37DA9491D0985C348C68E7B3) >> 128;
        if (x & 0x2000000000000 > 0)
            result = (result * 0x1000162E525EE054754457D5995292026) >> 128;
        if (x & 0x1000000000000 > 0)
            result = (result * 0x10000B17255775C040618BF4A4ADE83FC) >> 128;
        if (x & 0x800000000000 > 0)
            result = (result * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB) >> 128;
        if (x & 0x400000000000 > 0)
            result = (result * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9) >> 128;
        if (x & 0x200000000000 > 0)
            result = (result * 0x10000162E43F4F831060E02D839A9D16D) >> 128;
        if (x & 0x100000000000 > 0)
            result = (result * 0x100000B1721BCFC99D9F890EA06911763) >> 128;
        if (x & 0x80000000000 > 0)
            result = (result * 0x10000058B90CF1E6D97F9CA14DBCC1628) >> 128;
        if (x & 0x40000000000 > 0)
            result = (result * 0x1000002C5C863B73F016468F6BAC5CA2B) >> 128;
        if (x & 0x20000000000 > 0)
            result = (result * 0x100000162E430E5A18F6119E3C02282A5) >> 128;
        if (x & 0x10000000000 > 0)
            result = (result * 0x1000000B1721835514B86E6D96EFD1BFE) >> 128;
        if (x & 0x8000000000 > 0)
            result = (result * 0x100000058B90C0B48C6BE5DF846C5B2EF) >> 128;
        if (x & 0x4000000000 > 0)
            result = (result * 0x10000002C5C8601CC6B9E94213C72737A) >> 128;
        if (x & 0x2000000000 > 0)
            result = (result * 0x1000000162E42FFF037DF38AA2B219F06) >> 128;
        if (x & 0x1000000000 > 0)
            result = (result * 0x10000000B17217FBA9C739AA5819F44F9) >> 128;
        if (x & 0x800000000 > 0)
            result = (result * 0x1000000058B90BFCDEE5ACD3C1CEDC823) >> 128;
        if (x & 0x400000000 > 0)
            result = (result * 0x100000002C5C85FE31F35A6A30DA1BE50) >> 128;
        if (x & 0x200000000 > 0)
            result = (result * 0x10000000162E42FF0999CE3541B9FFFCF) >> 128;
        if (x & 0x100000000 > 0)
            result = (result * 0x100000000B17217F80F4EF5AADDA45554) >> 128;
        if (x & 0x80000000 > 0)
            result = (result * 0x10000000058B90BFBF8479BD5A81B51AD) >> 128;
        if (x & 0x40000000 > 0)
            result = (result * 0x1000000002C5C85FDF84BD62AE30A74CC) >> 128;
        if (x & 0x20000000 > 0)
            result = (result * 0x100000000162E42FEFB2FED257559BDAA) >> 128;
        if (x & 0x10000000 > 0)
            result = (result * 0x1000000000B17217F7D5A7716BBA4A9AE) >> 128;
        if (x & 0x8000000 > 0)
            result = (result * 0x100000000058B90BFBE9DDBAC5E109CCE) >> 128;
        if (x & 0x4000000 > 0)
            result = (result * 0x10000000002C5C85FDF4B15DE6F17EB0D) >> 128;
        if (x & 0x2000000 > 0)
            result = (result * 0x1000000000162E42FEFA494F1478FDE05) >> 128;
        if (x & 0x1000000 > 0)
            result = (result * 0x10000000000B17217F7D20CF927C8E94C) >> 128;
        if (x & 0x800000 > 0)
            result = (result * 0x1000000000058B90BFBE8F71CB4E4B33D) >> 128;
        if (x & 0x400000 > 0)
            result = (result * 0x100000000002C5C85FDF477B662B26945) >> 128;
        if (x & 0x200000 > 0)
            result = (result * 0x10000000000162E42FEFA3AE53369388C) >> 128;
        if (x & 0x100000 > 0)
            result = (result * 0x100000000000B17217F7D1D351A389D40) >> 128;
        if (x & 0x80000 > 0)
            result = (result * 0x10000000000058B90BFBE8E8B2D3D4EDE) >> 128;
        if (x & 0x40000 > 0)
            result = (result * 0x1000000000002C5C85FDF4741BEA6E77E) >> 128;
        if (x & 0x20000 > 0)
            result = (result * 0x100000000000162E42FEFA39FE95583C2) >> 128;
        if (x & 0x10000 > 0)
            result = (result * 0x1000000000000B17217F7D1CFB72B45E1) >> 128;
        if (x & 0x8000 > 0)
            result = (result * 0x100000000000058B90BFBE8E7CC35C3F0) >> 128;
        if (x & 0x4000 > 0)
            result = (result * 0x10000000000002C5C85FDF473E242EA38) >> 128;
        if (x & 0x2000 > 0)
            result = (result * 0x1000000000000162E42FEFA39F02B772C) >> 128;
        if (x & 0x1000 > 0)
            result = (result * 0x10000000000000B17217F7D1CF7D83C1A) >> 128;
        if (x & 0x800 > 0)
            result = (result * 0x1000000000000058B90BFBE8E7BDCBE2E) >> 128;
        if (x & 0x400 > 0)
            result = (result * 0x100000000000002C5C85FDF473DEA871F) >> 128;
        if (x & 0x200 > 0)
            result = (result * 0x10000000000000162E42FEFA39EF44D91) >> 128;
        if (x & 0x100 > 0)
            result = (result * 0x100000000000000B17217F7D1CF79E949) >> 128;
        if (x & 0x80 > 0)
            result = (result * 0x10000000000000058B90BFBE8E7BCE544) >> 128;
        if (x & 0x40 > 0)
            result = (result * 0x1000000000000002C5C85FDF473DE6ECA) >> 128;
        if (x & 0x20 > 0)
            result = (result * 0x100000000000000162E42FEFA39EF366F) >> 128;
        if (x & 0x10 > 0)
            result = (result * 0x1000000000000000B17217F7D1CF79AFA) >> 128;
        if (x & 0x8 > 0)
            result = (result * 0x100000000000000058B90BFBE8E7BCD6D) >> 128;
        if (x & 0x4 > 0)
            result = (result * 0x10000000000000002C5C85FDF473DE6B2) >> 128;
        if (x & 0x2 > 0)
            result = (result * 0x1000000000000000162E42FEFA39EF358) >> 128;
        if (x & 0x1 > 0)
            result = (result * 0x10000000000000000B17217F7D1CF79AB) >> 128;

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

        return
            exp_2(
                int128((int256(x) * 0x171547652B82FE1777D0FFDA0D23A7D12) >> 128)
            );
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

        if (x <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            result = (x << 64) / y;
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
     * Calculate x^y assuming 0^0 is 1, where x is unsigned 129.127 fixed point
     * number and y is unsigned 256-bit integer number.  Revert on overflow.
     *
     * @param x unsigned 129.127-bit fixed point number
     * @param y uint256 value
     * @return unsigned 129.127-bit fixed point number
     */
    function powu(uint256 x, uint256 y) private pure returns (uint256) {
        if (y == 0) return 0x80000000000000000000000000000000;
        else if (x == 0) return 0;
        else {
            int256 msb = 0;
            uint256 xc = x;
            if (xc >= 0x100000000000000000000000000000000) {
                xc >>= 128;
                msb += 128;
            }
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

            int256 xe = msb - 127;
            if (xe > 0) x >>= uint256(xe);
            else x <<= uint256(-xe);

            uint256 result = 0x80000000000000000000000000000000;
            int256 re = 0;

            while (y > 0) {
                if (y & 1 > 0) {
                    result = result * x;
                    y -= 1;
                    re += xe;
                    if (
                        result >=
                        0x8000000000000000000000000000000000000000000000000000000000000000
                    ) {
                        result >>= 128;
                        re += 1;
                    } else result >>= 127;
                    if (re < -127) return 0; // Underflow
                    require(re < 128); // Overflow
                } else {
                    x = x * x;
                    y >>= 1;
                    xe <<= 1;
                    if (
                        x >=
                        0x8000000000000000000000000000000000000000000000000000000000000000
                    ) {
                        x >>= 128;
                        xe += 1;
                    } else x >>= 127;
                    if (xe < -127) return 0; // Underflow
                    require(xe < 128); // Overflow
                }
            }

            if (re > 0) result <<= uint256(re);
            else if (re < 0) result >>= uint256(-re);

            return result;
        }
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



pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity >=0.6.0 <0.8.0;

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}



pragma solidity >=0.5.0;

interface IUniswapV2ERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}


pragma solidity >=0.6.0 <0.8.0;


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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity >=0.6.0 <0.8.0;


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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
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
        require(_paused, "Pausable: not paused");
        _;
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



pragma solidity >=0.7.0 <0.8.0;


/**
 * @dev Contract module which is essentially like Pausable but only owner is allowed to change the state.
 */
abstract contract PausableByOwner is Pausable, Ownable {
    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function pause() external virtual onlyOwner {
        _pause();
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function unpause() external virtual onlyOwner {
        _unpause();
    }
}



pragma solidity >=0.7.0 <0.8.0;

/**
 @dev The contract is intendent to help recovering arbitrary ERC20 tokens and ETH accidentally transferred to the contract address
 */
abstract contract RecoverableByOwner is Ownable {
    function getRecoverableAmount(address tokenAddress)
        internal
        view
        virtual
        returns (uint256)
    {
        if (tokenAddress == address(0)) return address(this).balance;
        else return IERC20(tokenAddress).balanceOf(address(this));
    }

    /**
     @param tokenAddress ERC20 token's address to recover or address(0) to recover ETH
     @param amount to recover from contract's address
     @param to address to receive tokens from the contract
     */
    function recoverFunds(
        address tokenAddress,
        uint256 amount,
        address to
    ) external onlyOwner {
        uint256 recoverableAmount = getRecoverableAmount(tokenAddress);
        require(
            amount <= recoverableAmount,
            "RecoverableByOwner: RECOVERABLE_AMOUNT_NOT_ENOUGH"
        );
        if (tokenAddress == address(0)) recoverEth(amount, to);
        else recoverErc20(tokenAddress, amount, to);
    }

    function recoverEth(uint256 amount, address to) private {
        address payable toPayable = payable(to);
        toPayable.transfer(amount);
    }

    function recoverErc20(
        address tokenAddress,
        uint256 amount,
        address to
    ) private {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = tokenAddress.call(
            abi.encodeWithSelector(0xa9059cbb, to, amount)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "RecoverableByOwner: TRANSFER_FAILED"
        );
    }
}

pragma solidity >=0.7.0 <0.8.0;
pragma abicoder v2;

contract StakingService is PausableByOwner, RecoverableByOwner {
    /**
     * @param totalStaked amount of LP currently staked in the service
     * @param historicalRewardRate how many Token minted per one LP (<< 40). Never decreases.
	 * @param totalTokenSupply how many tokens CVR minted.
	 * @param previousTokenSupply how many CVR tokens minted before.
     */
    struct State {
        uint128 totalStaked;
        uint128 historicalRewardRate;
		uint256 totalTokenSupply;
		uint256 previousTokenSupply;
		uint40 time;
    }

    /**
	 * @param time when was staked
     * @param amount of LP currently staked by the staker
     * @param initialRewardRate value of historicalRewardRate before last update of the staker's data
     * @param reward total amount of Token accrued to the staker
     * @param claimedReward total amount of Token the staker transferred from the service already
     */
    struct Staker {
		uint40 time;
        uint256 amount;
        uint128 initialRewardRate;
        uint128 reward;
        uint256 claimedReward;
    }
	
	struct TokenSupplyScheduleState {
		uint40 time;
		uint16 sDay;
		uint256 tokensForDay;
	}
	
	using ABDKMath64x64 for int128;
	uint40 private constant DISTRIBUTION_START_TIME = 1667957881;
	
	/* uint256 firstTokenSupply = 1251 * 10**18; */
	int128 supplyPercent_01 = ABDKMath64x64.divu(1, 1);
	int128 supplyPercent_02_04 = ABDKMath64x64.divu(12, 10);
	int128 supplyPercent_05_50 = ABDKMath64x64.divu(103, 100);
	int128 supplyPercent_51_134 = ABDKMath64x64.divu(9999, 10000);
	int128 supplyPercent_135_200 = ABDKMath64x64.divu(998, 1000);
	int128 supplyPercent_201_429 = ABDKMath64x64.divu(996, 1000);
	int128 supplyPercent_430_755 = ABDKMath64x64.divu(99978, 100000);
	int128 supplyPercent_756_1557 = ABDKMath64x64.divu(9996, 10000);
	int128 supplyPercent_1558_2200 = ABDKMath64x64.divu(9994, 10000);
	int128 supplyPercent_2201_3274 = ABDKMath64x64.divu(99943, 100000);
	int128 supplyPercent_3275_3728 = ABDKMath64x64.divu(999429, 1000000);
	
	
	uint40 constant DAY = 86400;	
	

    bytes32 public immutable DOMAIN_SEPARATOR;

    string private constant CLAIM_TYPE =
        "Claim(address owner,address spender,uint128 value,uint256 nonce,uint256 deadline)";
    bytes32 public constant CLAIM_TYPEHASH =
        keccak256(abi.encodePacked(CLAIM_TYPE));

    string private constant UNSTAKE_TYPE =
        "Unstake(address owner,address spender,uint128 value,uint256 nonce,uint256 deadline)";
    bytes32 public constant UNSTAKE_TYPEHASH =
        keccak256(abi.encodePacked(UNSTAKE_TYPE));

    mapping(address => uint256) public nonces;

    address public immutable token; /// @dev Token contract
    address public immutable stakingToken; /// @dev LP contract of uniswap
    address public tokenKeeper;
    State public state; /// @dev internal service state
	TokenSupplyScheduleState public supplyState; /// @dev internal supply state
    mapping(address => Staker) public stakers; /// @dev mapping of staker's address to its state

    event Staked(address indexed owner, uint128 amount); /// @dev someone is staked LP
    event Unstaked(address indexed from, address indexed to, uint128 amount); /// @dev someone unstaked LP
    event Rewarded(address indexed from, address indexed to, uint128 amount); /// @dev someone transferred Token from the service
    event StakingBonusAccrued(address indexed staker, uint128 amount); /// @dev Token accrued to the staker

    constructor(
        address _token,
        address _stakingToken,
        address _tokenKeeper
    ) {
        token = _token;
        stakingToken = _stakingToken;
        tokenKeeper = _tokenKeeper;
		supplyState.tokensForDay = 12 * 10**18;

        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("StakingService")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    /**
     @dev function to stake permitted amount of LP tokens from uniswap contract
     @param amount of LP to be staked in the service
     */
    function stake(uint128 amount) external {
        _stakeFrom(_msgSender(), amount);
    }

    function stakeWithPermit(
        uint128 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        IUniswapV2ERC20(stakingToken).permit(
            _msgSender(),
            address(this),
            amount,
            deadline,
            v,
            r,
            s
        );
        _stakeFrom(_msgSender(), amount);
    }

    function stakeFrom(address owner, uint128 amount) external {
        _stakeFrom(owner, amount);
    }

    function _stakeFrom(address owner, uint128 amount) private whenNotPaused {
        bool transferred = IERC20(stakingToken).transferFrom(
            owner,
            address(this),
            uint256(amount)
        );
        require(transferred, "StakingService: LP_FAILED_TRANSFER");

        Staker storage staker = updateStateAndStaker(owner);

        emit Staked(owner, amount);
        state.totalStaked += amount;
        staker.amount += amount;
    }

    /**
     @dev function to unstake LP tokens from the service and transfer to uniswap contract
     @param amount of LP to be unstaked from the service
     */
    function unstake(uint128 amount) external {
        _unstake(_msgSender(), _msgSender(), amount);
    }

    function unstakeTo(address to, uint128 amount) external {
        _unstake(_msgSender(), to, amount);
    }

    function unstakeWithAuthorization(
        address owner,
        uint128 amount,
        uint128 signedAmount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(amount <= signedAmount, "StakingService: INVALID_AMOUNT");
        verifySignature(
            UNSTAKE_TYPEHASH,
            owner,
            _msgSender(),
            signedAmount,
            deadline,
            v,
            r,
            s
        );
        _unstake(owner, _msgSender(), amount);
    }

    function _unstake(
        address from,
        address to,
        uint128 amount
    ) private {
        Staker storage staker = updateStateAndStaker(from);
        require(staker.amount >= amount, "StakingService: NOT_ENOUGH_STAKED");

        emit Unstaked(from, to, amount);
        state.totalStaked -= amount;
        staker.amount -= amount;

        bool transferred = IERC20(stakingToken).transfer(to, amount);
        require(transferred, "StakingService: LP_FAILED_TRANSFER");
    }
	
	function transfer(
		address to,
		uint256 amount
	) external {
		require(_msgSender() == tokenKeeper || _msgSender() == owner(), "TOKEN: no access");
		bool transferred = IERC20(token).transfer(to, amount);
        require(transferred, "StakingService: CVR_FAILED_TRANSFER");	
	}

    /**
     * @dev updates current reward and transfers it to the caller's address
     */
    function claimReward() external returns (uint256) {
        Staker storage staker = updateStateAndStaker(_msgSender());
        assert(staker.reward >= staker.claimedReward);
        uint128 unclaimedReward = staker.reward - uint128(staker.claimedReward);
        _claimReward(staker, _msgSender(), _msgSender(), unclaimedReward);
        return unclaimedReward;
    }

    function claimRewardTo(address to) external returns (uint256) {
        Staker storage staker = updateStateAndStaker(_msgSender());
        assert(staker.reward >= staker.claimedReward);
        uint128 unclaimedReward = staker.reward - uint128(staker.claimedReward);
        _claimReward(staker, _msgSender(), to, unclaimedReward);
        return unclaimedReward;
    }

    function claimRewardToWithoutUpdate(address to) external returns (uint256) {
        Staker storage staker = stakers[_msgSender()];
        assert(staker.reward >= staker.claimedReward);
        uint128 unclaimedReward = staker.reward - uint128(staker.claimedReward);
        _claimReward(staker, _msgSender(), to, unclaimedReward);
        return unclaimedReward;
    }

    function claimWithAuthorization(
        address owner,
        uint128 tokenAmount,
        uint128 signedAmount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(
            tokenAmount <= signedAmount,
            "StakingService: INVALID_TOKEN_AMOUNT"
        );
        verifySignature(
            CLAIM_TYPEHASH,
            owner,
            _msgSender(),
            signedAmount,
            deadline,
            v,
            r,
            s
        );

        Staker storage staker = updateStateAndStaker(owner);
        _claimReward(staker, owner, _msgSender(), tokenAmount);
    }

    function updateStateAndStaker(address stakerAddress)
        private
        returns (Staker storage staker)
    {
        updateHistoricalRewardRate();
        staker = stakers[stakerAddress];

        uint128 unrewarded = uint128(
            ((state.historicalRewardRate - staker.initialRewardRate) *
                staker.amount) >> 40
        );
        emit StakingBonusAccrued(stakerAddress, unrewarded);

        staker.initialRewardRate = state.historicalRewardRate;
        staker.reward += unrewarded;
		staker.time = uint40(block.timestamp);
    }

    function _claimReward(
        Staker storage staker,
        address from,
        address to,
        uint128 amount
    ) private {
        assert(staker.reward >= staker.claimedReward);
        uint128 unclaimedReward = staker.reward - uint128(staker.claimedReward);
        require(
            amount <= unclaimedReward,
            "StakingService: NOT_ENOUGH_BALANCE"
        );
        emit Rewarded(from, to, amount);
        staker.claimedReward += amount;
        bool transferred = IERC20(token).transfer(to, amount);
        require(transferred, "StakingService: TOKEN_FAILED_TRANSFER");
    }

    function verifySignature(
        bytes32 typehash,
        address owner,
        address spender,
        uint128 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private {
        require(deadline >= block.timestamp, "StakingService: EXPIRED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        typehash,
                        owner,
                        spender,
                        value,
                        nonces[owner]++,
                        deadline
                    )
                )
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(
            recoveredAddress != address(0) && recoveredAddress == owner,
            "StakingService: INVALID_SIGNATURE"
        );
    }

    /**
     * @dev updates state and returns unclaimed reward amount. Is supposed to be invoked as call from metamask to display current amount of Token available
     */
    function getReward() external returns (uint256 unclaimedReward) {
        Staker memory staker = updateStateAndStaker(_msgSender());
        assert(staker.reward >= staker.claimedReward);
        unclaimedReward = staker.reward - staker.claimedReward;
    }
	
	function tokenSupplyAmount(uint256 _totalSupplyAmount) public {
        require(_msgSender() == tokenKeeper || _msgSender() == owner(), "TOKEN: no access");
		if (_totalSupplyAmount == state.totalTokenSupply) return;
		state.totalTokenSupply = _totalSupplyAmount;		
	}
	
	function _makeProgress(
        uint40 maxTime
    ) private returns (uint256 tokenSupply) {
        if (maxTime <= supplyState.time) return 0;		
		uint256 nextTick;
		uint16 theDay = uint16(1 + (maxTime - DISTRIBUTION_START_TIME) / DAY);
		if (theDay == supplyState.sDay) {
			nextTick = (maxTime - supplyState.time) * (supplyState.tokensForDay / DAY);
			supplyState.time = maxTime;
			return nextTick;
		}
		
		uint40 restOfLastDay = DISTRIBUTION_START_TIME + (supplyState.sDay * DAY) - supplyState.time;
		nextTick += restOfLastDay * supplyState.tokensForDay / DAY;
		uint256 tokSup = supplyState.tokensForDay;
		uint16 tDay = supplyState.sDay + 1;
		while (tDay < theDay) {
			tokSup = _percentState(tDay).mulu(tokSup);
			nextTick += tokSup;
			tDay++;
		}
		uint40 restOfNewDay = maxTime - (theDay - 1) * DAY - DISTRIBUTION_START_TIME;
		tokSup = _percentState(theDay - 1).mulu(supplyState.tokensForDay);
		nextTick += tokSup * restOfNewDay / DAY;
		supplyState.sDay = theDay;
		supplyState.time = maxTime;
		supplyState.tokensForDay = tokSup;
		
        
        return nextTick;
    }
	
	function _percentState(uint16 sday) private view returns (int128 percent) {
		uint16 week = (sday / 7) + 1;
		if (week == 1) {
			return supplyPercent_01;
		} else if (week >= 2 && week <= 4) {
			return supplyPercent_02_04;
		} else if (week >= 5 && week <= 50) {
			return supplyPercent_05_50;
		} else if (week >= 51 && week <= 134) {
			return supplyPercent_51_134;
		} else if (week >= 135 && week <= 200) {
			return supplyPercent_135_200;
		} else if (week >= 201 && week <= 429) {
			return supplyPercent_201_429;
		} else if (week >= 430 && week <= 755) {
			return supplyPercent_430_755;
		} else if (week >= 756 && week <= 1557) {
			return supplyPercent_756_1557;
		} else if (week >= 1558 && week <= 2200) {
			return supplyPercent_1558_2200;
		} else if (week >= 2201 && week <= 3274) {
			return supplyPercent_2201_3274;
		} else if (week >= 3275 && week <= 3728) {
			return supplyPercent_3275_3728;
		} else {
			return ABDKMath64x64.divu(0, 1);
		}		

	}

    function updateHistoricalRewardRate() public {
        uint256 currentTokenSupply = _makeProgress(uint40(block.timestamp)) - state.totalTokenSupply;
        if (currentTokenSupply == 0) return;
		state.totalTokenSupply += currentTokenSupply;
        if (state.totalStaked != 0) {
            uint128 additionalRewardRate = uint128(
                (currentTokenSupply << 40) / state.totalStaked
            );
            state.historicalRewardRate += additionalRewardRate;
        } else {
            bool transferred = IERC20(token).transfer(
                owner(),
                currentTokenSupply
            );
            require(transferred, "StakingService: TOKEN_FAILED_TRANSFER");
        }
    }

    function changeTokenKeeper(address newTokenKeeper) external onlyOwner {
        tokenKeeper = newTokenKeeper;
    }

    function totalStaked() external view returns (uint128) {
        return state.totalStaked;
    }

    function getRecoverableAmount(address tokenAddress)
        internal
        view
        override
        returns (uint256)
    {
        // there is no way to know exact amount of Token service owns to the stakers
        require(
            tokenAddress != token,
            "StakingService: INVALID_RECOVERABLE_TOKEN"
        );
        if (tokenAddress == stakingToken) {
            uint256 _totalStaked = state.totalStaked;
            uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
            assert(balance >= _totalStaked);
            return balance - _totalStaked;
        }
        return RecoverableByOwner.getRecoverableAmount(tokenAddress);
    }
}