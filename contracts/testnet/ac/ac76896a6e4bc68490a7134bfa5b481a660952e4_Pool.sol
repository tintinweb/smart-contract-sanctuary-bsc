/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;



/**
 * @dev Reverts if `condition` is false, with a revert reason containing `errorCode`. Only codes up to 999 are
 * supported.
 */
function _require(bool condition, uint256 errorCode) pure {
    if (!condition) _revert(errorCode);
}

/**
 * @dev Reverts with a revert reason containing `errorCode`. Only codes up to 999 are supported.
 */
function _revert(uint256 errorCode) pure {
    // We're going to dynamically create a revert string based on the error code, with the following format:
    // 'ZYG#{errorCode}'
    // where the code is left-padded with zeroes to three digits (so they range from 000 to 999).
    //
    // We don't have revert strings embedded in the contract to save bytecode size: it takes much less space to store a
    // number (8 to 16 bits) than the individual string characters.
    //
    // The dynamic string creation algorithm that follows could be implemented in Solidity, but assembly allows for a
    // much denser implementation, again saving bytecode size. Given this function unconditionally reverts, this is a
    // safe place to rely on it without worrying about how its usage might affect e.g. memory contents.
    assembly {
        // First, we need to compute the ASCII representation of the error code. We assume that it is in the 0-999
        // range, so we only need to convert three digits. To convert the digits to ASCII, we add 0x30, the value for
        // the '0' character.

        let units := add(mod(errorCode, 10), 0x30)

        errorCode := div(errorCode, 10)
        let tenths := add(mod(errorCode, 10), 0x30)

        errorCode := div(errorCode, 10)
        let hundreds := add(mod(errorCode, 10), 0x30)

        // With the individual characters, we can now construct the full string. The "ZYG#" part is a known constant
        // (0x42414c23): we simply shift this by 24 (to provide space for the 3 bytes of the error code), and add the
        // characters to it, each shifted by a multiple of 8.
        // The revert reason is then shifted left by 200 bits (256 minus the length of the string, 7 characters * 8 bits
        // per character = 56) to locate it in the most significant part of the 256 slot (the beginning of a byte
        // array).

        let revertReason := shl(
            200,
            add(
                0x5a594723000000,
                add(add(units, shl(8, tenths)), shl(16, hundreds))
            )
        )

        // We can now encode the reason in memory, which can be safely overwritten as we're about to revert. The encoded
        // message will have the following layout:
        // [ revert reason identifier ] [ string location offset ] [ string length ] [ string contents ]

        // The Solidity revert reason identifier is 0x08c739a0, the function selector of the Error(string) function. We
        // also write zeroes to the next 28 bytes of memory, but those are about to be overwritten.
        mstore(
            0x0,
            0x08c379a000000000000000000000000000000000000000000000000000000000
        )
        // Next is the offset to the location of the string, which will be placed immediately after (20 bytes away).
        mstore(
            0x04,
            0x0000000000000000000000000000000000000000000000000000000000000020
        )
        // The string length is fixed: 7 characters.
        mstore(0x24, 7)
        // Finally, the string itself is stored.
        mstore(0x44, revertReason)

        // Even if the string is only 7 bytes long, we need to return a full 32 byte slot containing it. The length of
        // the encoded message is therefore 4 + 32 + 32 + 32 = 100.
        revert(0, 100)
    }
}

library Errors {
    // Math
    uint256 internal constant MUL_OVERFLOW = 0;
    uint256 internal constant ZERO_DIVISION = 1;
    uint256 internal constant DIV_INTERNAL = 2;
    uint256 internal constant X_OUT_OF_BOUNDS = 3;
    uint256 internal constant Y_OUT_OF_BOUNDS = 4;
    uint256 internal constant PRODUCT_OUT_OF_BOUNDS = 5;
    uint256 internal constant INVALID_EXPONENT = 6;

    // Input
    uint256 internal constant OUT_OF_BOUNDS = 100;
    uint256 internal constant INPUT_LENGTH_MISMATCH = 101;
    uint256 internal constant ZERO_TOKEN = 102;
    uint256 internal constant ZERO_AMOUNT_IN = 103;
    uint256 internal constant ZERO_ADDRESS = 104;

    // Pools
    uint256 internal constant CALLER_NOT_POOL_OWNER = 200;
    uint256 internal constant CANNOT_MODIFY_SWAP_FEE = 201;
    uint256 internal constant MAX_SWAP_FEE_PERCENTAGE = 202;
    uint256 internal constant MIN_SWAP_FEE_PERCENTAGE = 203;
    uint256 internal constant MINIMUM_HPT = 204;
    uint256 internal constant CALLER_NOT_ROUTER = 205;
    uint256 internal constant UNINITIALIZED = 206;
    uint256 internal constant HPT_OUT_MIN_AMOUNT = 207;

    uint256 internal constant MIN_WEIGHT = 300;
    uint256 internal constant EMPTY_POOL_BALANCES = 301;
    uint256 internal constant INSUFFICIENT_POOL_BALANCES = 302;
    uint256 internal constant NORMALIZED_WEIGHT_INVARIANT = 303;
    uint256 internal constant UNHANDLED_JOIN_KIND = 304;
    uint256 internal constant ZERO_INVARIANT = 305;

    // Lib
    uint256 internal constant REENTRANCY = 400;
    uint256 internal constant SAFE_ERC20_CALL_FAILED = 401;
    uint256 internal constant SAFE_CAST_VALUE_CANT_FIT_INT256 = 402;

    // Router
    uint256 internal constant FACTORY_ALREADY_SET = 500;
    uint256 internal constant EXIT_BELOW_MIN = 501;
    uint256 internal constant JOIN_ABOVE_MAX = 502;
    uint256 internal constant SWAP_LIMIT = 503;
    uint256 internal constant SWAP_DEADLINE = 504;
    uint256 internal constant CANNOT_SWAP_SAME_TOKEN = 505;
    uint256 internal constant UNKNOWN_AMOUNT_IN_FIRST_SWAP = 506;
    uint256 internal constant MALCONSTRUCTED_MULTIHOP_SWAP = 507;
    uint256 internal constant INSUFFICIENT_ETH = 508;
    uint256 internal constant ETH_TRANSFER = 509;
    uint256 internal constant TOKENS_MISMATCH = 510;

    // Fees
    uint256 internal constant SWAP_FEE_PERCENTAGE_TOO_HIGH = 600;

    // Factory
    uint256 internal constant IDENTICAL_ADDRESSES = 700;
    uint256 internal constant POOL_EXISTS = 701;
}




 
library SafeCast {
    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        _require(value < 2**255, Errors.SAFE_CAST_VALUE_CANT_FIT_INT256);
        return int256(value);
    }
}



library LogExpMath {
    // All fixed point multiplications and divisions are inlined. This means we need to divide by ONE when multiplying
    // two numbers, and multiply by ONE when dividing them.

    // All arguments and return values are 18 decimal fixed point numbers.
    int256 constant ONE_18 = 1e18;

    // Internally, intermediate values are computed with higher precision as 20 decimal fixed point numbers, and in the
    // case of ln36, 36 decimals.
    int256 constant ONE_20 = 1e20;
    int256 constant ONE_36 = 1e36;

    // The domain of natural exponentiation is bound by the word size and number of decimals used.
    //
    // Because internally the result will be stored using 20 decimals, the largest possible result is
    // (2^255 - 1) / 10^20, which makes the largest exponent ln((2^255 - 1) / 10^20) = 130.700829182905140221.
    // The smallest possible result is 10^(-18), which makes largest negative argument
    // ln(10^(-18)) = -41.446531673892822312.
    // We use 130.0 and -41.0 to have some safety margin.
    int256 constant MAX_NATURAL_EXPONENT = 130e18;
    int256 constant MIN_NATURAL_EXPONENT = -41e18;

    // Bounds for ln_36's argument. Both ln(0.9) and ln(1.1) can be represented with 36 decimal places in a fixed point
    // 256 bit integer.
    int256 constant LN_36_LOWER_BOUND = ONE_18 - 1e17;
    int256 constant LN_36_UPPER_BOUND = ONE_18 + 1e17;

    uint256 constant MILD_EXPONENT_BOUND = 2**254 / uint256(ONE_20);

    // 18 decimal constants
    int256 constant x0 = 128000000000000000000; // 2ˆ7
    int256 constant a0 =
        38877084059945950922200000000000000000000000000000000000; // eˆ(x0) (no decimals)
    int256 constant x1 = 64000000000000000000; // 2ˆ6
    int256 constant a1 = 6235149080811616882910000000; // eˆ(x1) (no decimals)

    // 20 decimal constants
    int256 constant x2 = 3200000000000000000000; // 2ˆ5
    int256 constant a2 = 7896296018268069516100000000000000; // eˆ(x2)
    int256 constant x3 = 1600000000000000000000; // 2ˆ4
    int256 constant a3 = 888611052050787263676000000; // eˆ(x3)
    int256 constant x4 = 800000000000000000000; // 2ˆ3
    int256 constant a4 = 298095798704172827474000; // eˆ(x4)
    int256 constant x5 = 400000000000000000000; // 2ˆ2
    int256 constant a5 = 5459815003314423907810; // eˆ(x5)
    int256 constant x6 = 200000000000000000000; // 2ˆ1
    int256 constant a6 = 738905609893065022723; // eˆ(x6)
    int256 constant x7 = 100000000000000000000; // 2ˆ0
    int256 constant a7 = 271828182845904523536; // eˆ(x7)
    int256 constant x8 = 50000000000000000000; // 2ˆ-1
    int256 constant a8 = 164872127070012814685; // eˆ(x8)
    int256 constant x9 = 25000000000000000000; // 2ˆ-2
    int256 constant a9 = 128402541668774148407; // eˆ(x9)
    int256 constant x10 = 12500000000000000000; // 2ˆ-3
    int256 constant a10 = 113314845306682631683; // eˆ(x10)
    int256 constant x11 = 6250000000000000000; // 2ˆ-4
    int256 constant a11 = 106449445891785942956; // eˆ(x11)

    /**
     * @dev Exponentiation (x^y) with unsigned 18 decimal fixed point base and exponent.
     *
     * Reverts if ln(x) * y is smaller than `MIN_NATURAL_EXPONENT`, or larger than `MAX_NATURAL_EXPONENT`.
     */
    function pow(uint256 x, uint256 y) internal pure returns (uint256) {
        if (y == 0) {
            // We solve the 0^0 indetermination by making it equal one.
            return uint256(ONE_18);
        }

        if (x == 0) {
            return 0;
        }

        // Instead of computing x^y directly, we instead rely on the properties of logarithms and exponentiation to
        // arrive at that result. In particular, exp(ln(x)) = x, and ln(x^y) = y * ln(x). This means
        // x^y = exp(y * ln(x)).

        // The ln function takes a signed value, so we need to make sure x fits in the signed 256 bit range.
        _require(x < 2**255, Errors.X_OUT_OF_BOUNDS);
        int256 x_int256 = int256(x);

        // We will compute y * ln(x) in a single step. Depending on the value of x, we can either use ln or ln_36. In
        // both cases, we leave the division by ONE_18 (due to fixed point multiplication) to the end.

        // This prevents y * ln(x) from overflowing, and at the same time guarantees y fits in the signed 256 bit range.
        _require(y < MILD_EXPONENT_BOUND, Errors.Y_OUT_OF_BOUNDS);
        int256 y_int256 = int256(y);

        int256 logx_times_y;
        if (LN_36_LOWER_BOUND < x_int256 && x_int256 < LN_36_UPPER_BOUND) {
            int256 ln_36_x = _ln_36(x_int256);

            // ln_36_x has 36 decimal places, so multiplying by y_int256 isn't as straightforward, since we can't just
            // bring y_int256 to 36 decimal places, as it might overflow. Instead, we perform two 18 decimal
            // multiplications and add the results: one with the first 18 decimals of ln_36_x, and one with the
            // (downscaled) last 18 decimals.
            logx_times_y = ((ln_36_x / ONE_18) *
                y_int256 +
                ((ln_36_x % ONE_18) * y_int256) /
                ONE_18);
        } else {
            logx_times_y = _ln(x_int256) * y_int256;
        }
        logx_times_y /= ONE_18;

        // Finally, we compute exp(y * ln(x)) to arrive at x^y
        _require(
            MIN_NATURAL_EXPONENT <= logx_times_y &&
                logx_times_y <= MAX_NATURAL_EXPONENT,
            Errors.PRODUCT_OUT_OF_BOUNDS
        );

        return uint256(exp(logx_times_y));
    }

    /**
     * @dev Natural exponentiation (e^x) with signed 18 decimal fixed point exponent.
     *
     * Reverts if `x` is smaller than MIN_NATURAL_EXPONENT, or larger than `MAX_NATURAL_EXPONENT`.
     */
    function exp(int256 x) internal pure returns (int256) {
        _require(
            x >= MIN_NATURAL_EXPONENT && x <= MAX_NATURAL_EXPONENT,
            Errors.INVALID_EXPONENT
        );

        if (x < 0) {
            // We only handle positive exponents: e^(-x) is computed as 1 / e^x. We can safely make x positive since it
            // fits in the signed 256 bit range (as it is larger than MIN_NATURAL_EXPONENT).
            // Fixed point division requires multiplying by ONE_18.
            return ((ONE_18 * ONE_18) / exp(-x));
        }

        // First, we use the fact that e^(x+y) = e^x * e^y to decompose x into a sum of powers of two, which we call x_n,
        // where x_n == 2^(7 - n), and e^x_n = a_n has been precomputed. We choose the first x_n, x0, to equal 2^7
        // because all larger powers are larger than MAX_NATURAL_EXPONENT, and therefore not present in the
        // decomposition.
        // At the end of this process we will have the product of all e^x_n = a_n that apply, and the remainder of this
        // decomposition, which will be lower than the smallest x_n.
        // exp(x) = k_0 * a_0 * k_1 * a_1 * ... + k_n * a_n * exp(remainder), where each k_n equals either 0 or 1.
        // We mutate x by subtracting x_n, making it the remainder of the decomposition.

        // The first two a_n (e^(2^7) and e^(2^6)) are too large if stored as 18 decimal numbers, and could cause
        // intermediate overflows. Instead we store them as plain integers, with 0 decimals.
        // Additionally, x0 + x1 is larger than MAX_NATURAL_EXPONENT, which means they will not both be present in the
        // decomposition.

        // For each x_n, we test if that term is present in the decomposition (if x is larger than it), and if so deduct
        // it and compute the accumulated product.

        int256 firstAN;
        if (x >= x0) {
            x -= x0;
            firstAN = a0;
        } else if (x >= x1) {
            x -= x1;
            firstAN = a1;
        } else {
            firstAN = 1; // One with no decimal places
        }

        // We now transform x into a 20 decimal fixed point number, to have enhanced precision when computing the
        // smaller terms.
        x *= 100;

        // `product` is the accumulated product of all a_n (except a0 and a1), which starts at 20 decimal fixed point
        // one. Recall that fixed point multiplication requires dividing by ONE_20.
        int256 product = ONE_20;

        if (x >= x2) {
            x -= x2;
            product = (product * a2) / ONE_20;
        }
        if (x >= x3) {
            x -= x3;
            product = (product * a3) / ONE_20;
        }
        if (x >= x4) {
            x -= x4;
            product = (product * a4) / ONE_20;
        }
        if (x >= x5) {
            x -= x5;
            product = (product * a5) / ONE_20;
        }
        if (x >= x6) {
            x -= x6;
            product = (product * a6) / ONE_20;
        }
        if (x >= x7) {
            x -= x7;
            product = (product * a7) / ONE_20;
        }
        if (x >= x8) {
            x -= x8;
            product = (product * a8) / ONE_20;
        }
        if (x >= x9) {
            x -= x9;
            product = (product * a9) / ONE_20;
        }

        // x10 and x11 are unnecessary here since we have high enough precision already.

        // Now we need to compute e^x, where x is small (in particular, it is smaller than x9). We use the Taylor series
        // expansion for e^x: 1 + x + (x^2 / 2!) + (x^3 / 3!) + ... + (x^n / n!).

        int256 seriesSum = ONE_20; // The initial one in the sum, with 20 decimal places.
        int256 term; // Each term in the sum, where the nth term is (x^n / n!).

        // The first term is simply x.
        term = x;
        seriesSum += term;

        // Each term (x^n / n!) equals the previous one times x, divided by n. Since x is a fixed point number,
        // multiplying by it requires dividing by ONE_20, but dividing by the non-fixed point n values does not.

        term = ((term * x) / ONE_20) / 2;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 3;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 4;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 5;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 6;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 7;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 8;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 9;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 10;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 11;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 12;
        seriesSum += term;

        // 12 Taylor terms are sufficient for 18 decimal precision.

        // We now have the first a_n (with no decimals), and the product of all other a_n present, and the Taylor
        // approximation of the exponentiation of the remainder (both with 20 decimals). All that remains is to multiply
        // all three (one 20 decimal fixed point multiplication, dividing by ONE_20, and one integer multiplication),
        // and then drop two digits to return an 18 decimal value.

        return (((product * seriesSum) / ONE_20) * firstAN) / 100;
    }

    /**
     * @dev Logarithm (log(arg, base), with signed 18 decimal fixed point base and argument.
     */
    function log(int256 arg, int256 base) internal pure returns (int256) {
        // This performs a simple base change: log(arg, base) = ln(arg) / ln(base).

        // Both logBase and logArg are computed as 36 decimal fixed point numbers, either by using ln_36, or by
        // upscaling.

        int256 logBase;
        if (LN_36_LOWER_BOUND < base && base < LN_36_UPPER_BOUND) {
            logBase = _ln_36(base);
        } else {
            logBase = _ln(base) * ONE_18;
        }

        int256 logArg;
        if (LN_36_LOWER_BOUND < arg && arg < LN_36_UPPER_BOUND) {
            logArg = _ln_36(arg);
        } else {
            logArg = _ln(arg) * ONE_18;
        }

        // When dividing, we multiply by ONE_18 to arrive at a result with 18 decimal places
        return (logArg * ONE_18) / logBase;
    }

    /**
     * @dev Natural logarithm (ln(a)) with signed 18 decimal fixed point argument.
     */
    function ln(int256 a) internal pure returns (int256) {
        // The real natural logarithm is not defined for negative numbers or zero.
        _require(a > 0, Errors.OUT_OF_BOUNDS);
        if (LN_36_LOWER_BOUND < a && a < LN_36_UPPER_BOUND) {
            return _ln_36(a) / ONE_18;
        } else {
            return _ln(a);
        }
    }

    /**
     * @dev Internal natural logarithm (ln(a)) with signed 18 decimal fixed point argument.
     */
    function _ln(int256 a) private pure returns (int256) {
        if (a < ONE_18) {
            // Since ln(a^k) = k * ln(a), we can compute ln(a) as ln(a) = ln((1/a)^(-1)) = - ln((1/a)). If a is less
            // than one, 1/a will be greater than one, and this if statement will not be entered in the recursive call.
            // Fixed point division requires multiplying by ONE_18.
            return (-_ln((ONE_18 * ONE_18) / a));
        }

        // First, we use the fact that ln^(a * b) = ln(a) + ln(b) to decompose ln(a) into a sum of powers of two, which
        // we call x_n, where x_n == 2^(7 - n), which are the natural logarithm of precomputed quantities a_n (that is,
        // ln(a_n) = x_n). We choose the first x_n, x0, to equal 2^7 because the exponential of all larger powers cannot
        // be represented as 18 fixed point decimal numbers in 256 bits, and are therefore larger than a.
        // At the end of this process we will have the sum of all x_n = ln(a_n) that apply, and the remainder of this
        // decomposition, which will be lower than the smallest a_n.
        // ln(a) = k_0 * x_0 + k_1 * x_1 + ... + k_n * x_n + ln(remainder), where each k_n equals either 0 or 1.
        // We mutate a by subtracting a_n, making it the remainder of the decomposition.

        // For reasons related to how `exp` works, the first two a_n (e^(2^7) and e^(2^6)) are not stored as fixed point
        // numbers with 18 decimals, but instead as plain integers with 0 decimals, so we need to multiply them by
        // ONE_18 to convert them to fixed point.
        // For each a_n, we test if that term is present in the decomposition (if a is larger than it), and if so divide
        // by it and compute the accumulated sum.

        int256 sum = 0;
        if (a >= a0 * ONE_18) {
            a /= a0; // Integer, not fixed point division
            sum += x0;
        }

        if (a >= a1 * ONE_18) {
            a /= a1; // Integer, not fixed point division
            sum += x1;
        }

        // All other a_n and x_n are stored as 20 digit fixed point numbers, so we convert the sum and a to this format.
        sum *= 100;
        a *= 100;

        // Because further a_n are  20 digit fixed point numbers, we multiply by ONE_20 when dividing by them.

        if (a >= a2) {
            a = (a * ONE_20) / a2;
            sum += x2;
        }

        if (a >= a3) {
            a = (a * ONE_20) / a3;
            sum += x3;
        }

        if (a >= a4) {
            a = (a * ONE_20) / a4;
            sum += x4;
        }

        if (a >= a5) {
            a = (a * ONE_20) / a5;
            sum += x5;
        }

        if (a >= a6) {
            a = (a * ONE_20) / a6;
            sum += x6;
        }

        if (a >= a7) {
            a = (a * ONE_20) / a7;
            sum += x7;
        }

        if (a >= a8) {
            a = (a * ONE_20) / a8;
            sum += x8;
        }

        if (a >= a9) {
            a = (a * ONE_20) / a9;
            sum += x9;
        }

        if (a >= a10) {
            a = (a * ONE_20) / a10;
            sum += x10;
        }

        if (a >= a11) {
            a = (a * ONE_20) / a11;
            sum += x11;
        }

        // a is now a small number (smaller than a_11, which roughly equals 1.06). This means we can use a Taylor series
        // that converges rapidly for values of `a` close to one - the same one used in ln_36.
        // Let z = (a - 1) / (a + 1).
        // ln(a) = 2 * (z + z^3 / 3 + z^5 / 5 + z^7 / 7 + ... + z^(2 * n + 1) / (2 * n + 1))

        // Recall that 20 digit fixed point division requires multiplying by ONE_20, and multiplication requires
        // division by ONE_20.
        int256 z = ((a - ONE_20) * ONE_20) / (a + ONE_20);
        int256 z_squared = (z * z) / ONE_20;

        // num is the numerator of the series: the z^(2 * n + 1) term
        int256 num = z;

        // seriesSum holds the accumulated sum of each term in the series, starting with the initial z
        int256 seriesSum = num;

        // In each step, the numerator is multiplied by z^2
        num = (num * z_squared) / ONE_20;
        seriesSum += num / 3;

        num = (num * z_squared) / ONE_20;
        seriesSum += num / 5;

        num = (num * z_squared) / ONE_20;
        seriesSum += num / 7;

        num = (num * z_squared) / ONE_20;
        seriesSum += num / 9;

        num = (num * z_squared) / ONE_20;
        seriesSum += num / 11;

        // 6 Taylor terms are sufficient for 36 decimal precision.

        // Finally, we multiply by 2 (non fixed point) to compute ln(remainder)
        seriesSum *= 2;

        // We now have the sum of all x_n present, and the Taylor approximation of the logarithm of the remainder (both
        // with 20 decimals). All that remains is to sum these two, and then drop two digits to return a 18 decimal
        // value.

        return (sum + seriesSum) / 100;
    }

    /**
     * @dev Intrnal high precision (36 decimal places) natural logarithm (ln(x)) with signed 18 decimal fixed point argument,
     * for x close to one.
     *
     * Should only be used if x is between LN_36_LOWER_BOUND and LN_36_UPPER_BOUND.
     */
    function _ln_36(int256 x) private pure returns (int256) {
        // Since ln(1) = 0, a value of x close to one will yield a very small result, which makes using 36 digits
        // worthwhile.

        // First, we transform x to a 36 digit fixed point value.
        x *= ONE_18;

        // We will use the following Taylor expansion, which converges very rapidly. Let z = (x - 1) / (x + 1).
        // ln(x) = 2 * (z + z^3 / 3 + z^5 / 5 + z^7 / 7 + ... + z^(2 * n + 1) / (2 * n + 1))

        // Recall that 36 digit fixed point division requires multiplying by ONE_36, and multiplication requires
        // division by ONE_36.
        int256 z = ((x - ONE_36) * ONE_36) / (x + ONE_36);
        int256 z_squared = (z * z) / ONE_36;

        // num is the numerator of the series: the z^(2 * n + 1) term
        int256 num = z;

        // seriesSum holds the accumulated sum of each term in the series, starting with the initial z
        int256 seriesSum = num;

        // In each step, the numerator is multiplied by z^2
        num = (num * z_squared) / ONE_36;
        seriesSum += num / 3;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 5;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 7;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 9;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 11;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 13;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 15;

        // 8 Taylor terms are sufficient for 36 decimal precision.

        // All that remains is multiplying by 2 (non fixed point).
        return seriesSum * 2;
    }
}



library FixedPoint {
    uint256 internal constant ONE = 1e18; // 18 decimal places
    uint256 internal constant MAX_POW_RELATIVE_ERROR = 10000; // 10^(-14)

    // Minimum base for the power function when the exponent is 'free' (larger than ONE).
    uint256 internal constant MIN_POW_BASE_FREE_EXPONENT = 0.7e18;

    function mulDown(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 product = a * b;
        _require(a == 0 || product / a == b, Errors.MUL_OVERFLOW);

        return product / ONE;
    }

    function mulUp(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 product = a * b;
        _require(a == 0 || product / a == b, Errors.MUL_OVERFLOW);

        if (product == 0) {
            return 0;
        } else {
            // The traditional divUp formula is:
            // divUp(x, y) := (x + y - 1) / y
            // To avoid intermediate overflow in the addition, we distribute the division and get:
            // divUp(x, y) := (x - 1) / y + 1
            // Note that this requires x != 0, which we already tested for.

            return ((product - 1) / ONE) + 1;
        }
    }

    function divDown(uint256 a, uint256 b) internal pure returns (uint256) {
        _require(b != 0, Errors.ZERO_DIVISION);

        if (a == 0) {
            return 0;
        } else {
            uint256 aInflated = a * ONE;
            _require(aInflated / a == ONE, Errors.DIV_INTERNAL); // mul overflow

            return aInflated / b;
        }
    }

    function divUp(uint256 a, uint256 b) internal pure returns (uint256) {
        _require(b != 0, Errors.ZERO_DIVISION);

        if (a == 0) {
            return 0;
        } else {
            uint256 aInflated = a * ONE;
            _require(aInflated / a == ONE, Errors.DIV_INTERNAL); // mul overflow

            // The traditional divUp formula is:
            // divUp(x, y) := (x + y - 1) / y
            // To avoid intermediate overflow in the addition, we distribute the division and get:
            // divUp(x, y) := (x - 1) / y + 1
            // Note that this requires x != 0, which we already tested for.

            return ((aInflated - 1) / b) + 1;
        }
    }

    /**
     * @dev Returns x^y, assuming both are fixed point numbers, rounding down. The result is guaranteed to not be above
     * the true value (that is, the error function expected - actual is always positive).
     */
    function powDown(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 raw = LogExpMath.pow(x, y);
        uint256 maxError = mulUp(raw, MAX_POW_RELATIVE_ERROR) + 1;

        if (raw < maxError) {
            return 0;
        } else {
            return raw - maxError;
        }
    }

    /**
     * @dev Returns x^y, assuming both are fixed point numbers, rounding up. The result is guaranteed to not be below
     * the true value (that is, the error function expected - actual is always negative).
     */
    function powUp(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 raw = LogExpMath.pow(x, y);
        uint256 maxError = mulUp(raw, MAX_POW_RELATIVE_ERROR) + 1;

        return raw + maxError;
    }

    /**
     * @dev Returns the complement of a value (1 - x), capped to 0 if x is larger than 1.
     *
     * Useful when computing the complement for values with some level of relative error, as it strips this error and
     * prevents intermediate negative values.
     */
    function complement(uint256 x) internal pure returns (uint256) {
        return (x < ONE) ? (ONE - x) : 0;
    }
}


library Math {
    /**
     * @dev Returns the largest of two numbers of 256 bits.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function divDown(uint256 a, uint256 b) internal pure returns (uint256) {
        _require(b != 0, Errors.ZERO_DIVISION);
        return a / b;
    }

    function divUp(uint256 a, uint256 b) internal pure returns (uint256) {
        _require(b != 0, Errors.ZERO_DIVISION);

        if (a == 0) {
            return 0;
        } else {
            return 1 + (a - 1) / b;
        }
    }
}


/* solhint-disable private-vars-leading-underscore */

contract WeightedMath {
    using FixedPoint for uint256;
    using SafeCast for uint256;

    uint256 internal constant ONE = 1e18; // 18 decimal places

    // Invariant is used to initiate the HPT amount and,
    // because there is a minimum HPT, we round down the invariant.
    function _calculateInvariant(
        uint256[] memory normalizedWeights,
        uint256[] memory balances
    ) internal pure returns (uint256 invariant) {
        /**********************************************************************************************
        // invariant               _____                                                             //
        // wi = weight index i      | |      wi                                                      //
        // bi = balance index i     | |  bi ^   = i                                                  //
        // i = invariant                                                                             //
        **********************************************************************************************/

        invariant = FixedPoint.ONE;
        for (uint256 i = 0; i < normalizedWeights.length; i++) {
            invariant = invariant.mulDown(
                balances[i].powDown(normalizedWeights[i])
            );
        }

        _require(invariant > 0, Errors.ZERO_INVARIANT);
    }

    // Computes how many tokens can be taken out of a pool if `amountIn` are sent, given the
    // current balances and weights.
    function _calcOutGivenIn(
        uint256 balanceIn,
        uint256 weightIn,
        uint256 balanceOut,
        uint256 weightOut,
        uint256 amountIn
    ) internal pure returns (uint256) {
        _require(amountIn > 0, Errors.ZERO_AMOUNT_IN);
        _require(balanceIn > 0 && balanceOut > 0, Errors.EMPTY_POOL_BALANCES);
        uint256 exponentFracFraction = balanceIn.divDown(balanceIn + amountIn);
        uint256 exponentFraction = (ONE - exponentFracFraction).divDown(
            ONE + exponentFracFraction
        );

        uint256 exponentNumerator = weightIn -
            (weightIn.mulDown(exponentFraction));
        uint256 exponentDenominator = weightOut +
            (weightIn.mulDown(exponentFraction));

        uint256 exponent = exponentNumerator.divDown(exponentDenominator);

        uint256 amountOut = ONE - exponentFracFraction.powUp(exponent);
        amountOut = balanceOut.mulDown(amountOut);
        _require(amountOut < balanceOut, Errors.INSUFFICIENT_POOL_BALANCES);
        return amountOut;
    }

    function _calculateNewWeights(
        uint256 weightInOld,
        uint256 weightOutOld,
        uint256 balanceOutOld,
        uint256 balanceOutNew
    ) internal pure returns (uint256 weightInNew, uint256 weightOutNew) {
        uint256 denominator = weightInOld.divDown(weightOutOld) + ONE;
        uint256 baseWeightInNew;
        uint256 baseWeightOutNew;
        uint256 numerator;
        if (weightInOld < weightOutOld) {
            numerator =
                (balanceOutOld.divDown(balanceOutNew) - ONE) *
                (ONE - weightOutOld);
        } else {
            numerator =
                (balanceOutOld.divDown(balanceOutNew) - ONE) *
                (weightOutOld);
        }

        baseWeightOutNew = numerator / denominator;
        baseWeightInNew = numerator / denominator;
        weightOutNew = weightOutOld + baseWeightOutNew;
        weightInNew = weightInOld - baseWeightInNew;
    }

    // Join hook

    function _calcHptOutGivenExactTokensIn(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        uint256[] memory amountsIn,
        uint256 hptTotalSupply,
        uint256 swapFee
    ) internal pure returns (uint256) {
        // HPT out, so we round down overall.

        uint256[] memory balanceRatiosWithFee = new uint256[](amountsIn.length);

        uint256 invariantRatioWithFees = 0;
        for (uint256 i = 0; i < balances.length; i++) {
            balanceRatiosWithFee[i] = (balances[i] + amountsIn[i]).divDown(
                balances[i]
            );
            invariantRatioWithFees =
                invariantRatioWithFees +
                (balanceRatiosWithFee[i].mulDown(normalizedWeights[i]));
        }

        uint256 invariantRatio = FixedPoint.ONE;
        for (uint256 i = 0; i < balances.length; i++) {
            uint256 amountInWithoutFee;

            if (balanceRatiosWithFee[i] > invariantRatioWithFees) {
                uint256 nonTaxableAmount = balances[i].mulDown(
                    invariantRatioWithFees - FixedPoint.ONE
                );
                uint256 taxableAmount = amountsIn[i] - nonTaxableAmount;
                amountInWithoutFee =
                    nonTaxableAmount +
                    (taxableAmount.mulDown(FixedPoint.ONE - swapFee));
            } else {
                amountInWithoutFee = amountsIn[i];
            }

            uint256 balanceRatio = (balances[i] + amountInWithoutFee).divDown(
                balances[i]
            );

            invariantRatio = invariantRatio.mulDown(
                balanceRatio.powDown(normalizedWeights[i])
            );
        }

        if (invariantRatio >= FixedPoint.ONE) {
            return hptTotalSupply.mulDown(invariantRatio - FixedPoint.ONE);
        } else {
            return 0;
        }
    }

    function _calculateVirtualSwapAmountIn(
        uint256 balanceIn,
        uint256 balanceOut,
        uint256 amountIn,
        uint256 amountOut,
        uint256 weightIn,
        uint256 weightOut
    ) internal pure returns (uint256 amountsInForVirtualSwap) {
        uint256 priceToken1OverToken0 = (
            (amountIn + balanceIn).divDown(weightIn)
        ).divDown((amountOut + balanceOut).divDown(weightOut));

        // Multiplying 'amountIn' by 0.5
        uint256 x = (amountIn * 500000000000000000).divDown(
            (amountOut * priceToken1OverToken0)
        );

        // Adding 'x' with 0.5
        uint256 weightToken0Input = ONE.divDown(x + 500000000000000000).mulDown(
            x
        );
        uint256 v = weightToken0Input - weightIn;

        amountsInForVirtualSwap = (
            (((amountIn * ONE) / weightToken0Input).mulDown(v))
        );
    }

    function _calculateNextIterationAmountIn(
        uint256 amountIn,
        uint256 amountOutIn,
        uint256 amountInForVirtualSwap,
        uint256 weightIn,
        uint256 amountOut,
        uint256 tokenTotalIn,
        uint256 tokenTotalOut
    ) internal pure returns (uint256) {
        uint256 tempTokenInBalance = tokenTotalIn + amountInForVirtualSwap;
        uint256 tempTokenOutBalance = tokenTotalOut - amountOut;

        uint256 tempVirtualBalancesRatio = tempTokenOutBalance.divDown(
            tempTokenInBalance
        );

        // Here 'amountOut' is the amount we got from '_calcSwapOut', and 'amountOutIn' is the amount of the 'amountOut'
        // token type provided by user
        // @Note 'amountOutIn' would be 0 in single join
        uint256 tempAmountInOutRatio = (amountOut + amountOutIn).divDown(
            amountIn - amountInForVirtualSwap
        );

        uint256 ratioDifferenceInPercentage = tempVirtualBalancesRatio.divDown(
            tempAmountInOutRatio
        );
        uint256 finalPercentage = uint256(
            ONE.toInt256() +
                ((ratioDifferenceInPercentage.toInt256() - ONE.toInt256()) *
                    weightIn.toInt256()) /
                ONE.toInt256()
        );
        amountInForVirtualSwap = amountInForVirtualSwap.mulDown(
            finalPercentage
        );
        return amountInForVirtualSwap;
    }

    // Exit hook

    function _calcTokensOutGivenExactHptIn(
        uint256[] memory balances,
        uint256 hptAmountIn,
        uint256 totalHPT
    ) internal pure returns (uint256[] memory) {
        /**********************************************************************************************
        // exactHPTInForTokensOut                                                                    //
        // (per token)                                                                               //
        // aO = amountOut                  /        hptIn         \                                  //
        // b = balance           a0 = b * | ---------------------  |                                 //
        // hptIn = hptAmountIn             \       totalHPT       /                                  //
        // hpt = totalHPT                                                                            //
        **********************************************************************************************/

        // Since we're computing an amount out, we round down overall. This means rounding down on both the
        // multiplication and division.

        uint256 hptRatio = hptAmountIn.divDown(totalHPT);
        uint256[] memory amountsOut = new uint256[](balances.length);
        for (uint256 i = 0; i < balances.length; i++) {
            amountsOut[i] = balances[i].mulDown(hptRatio);
        }

        return amountsOut;
    }
}




abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


interface IERC20 {

    //----------- Start GDO 7-Oct-2022 --------------
    /**
     * @dev Returns the name of tokens in existence.
     */
    function name() external view  returns (string memory);

    function symbol() external view returns (string memory);
    //----------- End GDO 7-Oct-2022 --------------

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


interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override (IERC20, IERC20Metadata) returns (string memory ) {
        return _name;
    }
     //----------- Start GDO 7-Oct-2022 --------------

    function setName(string memory tName) internal  {
        _name = tName;
    }

    function setSymbol(string memory tSymbol) internal  {
        _symbol = tSymbol;
    }

     //----------- End GDO 7-Oct-2022 --------------

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override(IERC20, IERC20Metadata) returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
 

contract HedgePoolToken is ERC20 {
    constructor() ERC20("Hedge Pool Token", "HT") {}
}


library InputHelpers {
    function ensureInputLengthMatch(uint256 a, uint256 b) internal pure {
        _require(a == b, Errors.INPUT_LENGTH_MISMATCH);
    }

    function ensureInputLengthMatch(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal pure {
        _require(a == b && b == c, Errors.INPUT_LENGTH_MISMATCH);
    }
}


library Decoder {
    function joinKind(bytes memory self) internal pure returns (Pool.JoinKind) {
        return abi.decode(self, (Pool.JoinKind));
    }

    // Joins

    function initialAmountsIn(bytes memory self)
        internal
        pure
        returns (uint256[] memory amountsIn)
    {
        (, amountsIn) = abi.decode(self, (Pool.JoinKind, uint256[]));
    }

    function exactTokensInForHptOut(bytes memory self)
        internal
        pure
        returns (uint256[] memory amountsIn, uint256 minHPTAmountOut)
    {
        (, amountsIn, minHPTAmountOut) = abi.decode(
            self,
            (Pool.JoinKind, uint256[], uint256)
        );
    }

    function exactTokenInForHptOut(bytes memory self)
        internal
        pure
        returns (
            uint256 amountIn,
            uint256 tokenIndex,
            uint256 minHPTAmountOut
        )
    {
        (, amountIn, tokenIndex, minHPTAmountOut) = abi.decode(
            self,
            (Pool.JoinKind, uint256, uint256, uint256)
        );
    }

    // Exit

    function exactHptInForTokensOut(bytes memory self)
        internal
        pure
        returns (uint256 hptAmountIn, uint256 weightInputToken0)
    {
        (hptAmountIn, weightInputToken0) = abi.decode(self, (uint256, uint256));
    }
}



contract Pool is WeightedMath, HedgePoolToken {
    using Decoder for bytes;
    using FixedPoint for uint256;
    using SafeCast for uint256;

    IERC20 internal immutable _token0;
    IERC20 internal immutable _token1;

    enum JoinKind {
        INIT,
        EXACT_TOKENS_IN_FOR_HPT_OUT,
        EXACT_TOKEN_IN_FOR_HPT_OUT
    }

    bool public immutable canChangeSwapFee;
    address private immutable _router;
    address public immutable _owner;

    uint256 private constant _MINIMUM_HPT = 1e6;

    // 1e18 corresponds to 1.0, or a 100% fee
    uint256 private constant _MIN_SWAP_FEE_PERCENTAGE = 1e12; // 0.0001%
    uint256 private constant _MAX_SWAP_FEE_PERCENTAGE = 1e17; // 10%

    uint256 private constant _MIN_WEIGHT = 2e17; // 20%

    uint256 private _swapFeePercentage;

    uint256 private _weight0;
    uint256 private _weight1;

    // All token balances are normalized to behave as if the token had 18 decimals. We assume a token's decimals will
    // not change throughout its lifetime, and store the corresponding scaling factor for each at construction time.
    // These factors are always greater than or equal to one: tokens with more than 18 decimals are not supported.
    uint256 internal immutable _scalingFactor0;
    uint256 internal immutable _scalingFactor1;

    // Balance management
    uint112 private _balance0;
    uint112 private _balance1;

    // lastChangeBlock stores the last block in which either of the pool token changed its total balance.
    uint32 private _lastChangeBlock;
    event SwapFeePercentageChanged(uint256 swapFeePercentage);

    modifier onlyRouter() {
        _require(msg.sender == _router, Errors.CALLER_NOT_ROUTER);
        _;
    }

    
    struct NewPoolParams {
        address router;
        IERC20 token0;
        IERC20 token1;
        uint256 weight0;
        uint256 weight1;
        uint256 swapFeePercentage;
        bool changeSwapFeeEnabled;
        address owner;
    }

    constructor(NewPoolParams memory params) {
        _setSwapFeePercentage(params.swapFeePercentage);

        _router = params.router;
        _owner = params.owner;

        canChangeSwapFee = params.changeSwapFeeEnabled;

        _token0 = params.token0;
        _token1 = params.token1;

        _scalingFactor0 = _computeScalingFactor(params.token0);
        _scalingFactor1 = _computeScalingFactor(params.token1);

        // Ensure each normalized weight is above them minimum and find the token index of the maximum weight
        _require(params.weight0 >= _MIN_WEIGHT, Errors.MIN_WEIGHT);
        _require(params.weight1 >= _MIN_WEIGHT, Errors.MIN_WEIGHT);

        // Ensure that the sum of weights is ONE
        uint256 weightSum = params.weight0 + params.weight1;
        _require(
            weightSum == FixedPoint.ONE,
            Errors.NORMALIZED_WEIGHT_INVARIANT
        );

        _weight0 = params.weight0;
        _weight1 = params.weight1;

        //----------- Start GDO 7-Oct-2022 --------------

         string memory strToken0 = string(abi.encodePacked(_token0.symbol(), "/"));
         string memory strToken1 = string(abi.encodePacked(strToken0,_token1.symbol()));
         string memory strGToken = string(abi.encodePacked("Gamut ", strToken1));
         string memory strPoolName = string(abi.encodePacked(strGToken, " Pool"));
       
        ERC20.setName(strPoolName);

        ERC20.setSymbol("Gamut-LP");
        //----------- End GDO 7-Oct-2022 -----------------
    }

    // Getters / Setters

    function getRouter() public view returns (address) {
        return _router;
    }

    function getSwapFeePercentage() public view returns (uint256) {
        return _swapFeePercentage;
    }

    function getWeights() external view returns (uint256[] memory) {
        return _weights();
    }

    function _weights() private view returns (uint256[] memory) {
        uint256[] memory weights = new uint256[](2);
        weights[0] = _weights(true);
        weights[1] = _weights(false);
        return weights;
    }

    function _weights(bool token0) private view returns (uint256) {
        return token0 ? _weight0 : _weight1;
    }

    /**
     * @dev Determines whether tokenIn is _token0 or _token1 in the pool,
     * based on the result, returns weight of Input and Output token as well as their scaling factor.
     *
     * true when tokenIn is _token0, false otherwise.
     */
    function getWeightsAndScalingFactors(IERC20 tokenIn)
        private
        view
        returns (
            bool tokenInIsToken0,
            uint256 weightIn,
            uint256 weightOut,
            uint256 scalingFactorTokenIn,
            uint256 scalingFactorTokenOut
        )
    {
        tokenInIsToken0 = tokenIn == _token0;
        weightIn = _weights(tokenInIsToken0);
        weightOut = _weights(!tokenInIsToken0);
        scalingFactorTokenIn = _scalingFactor(tokenInIsToken0);
        scalingFactorTokenOut = _scalingFactor(!tokenInIsToken0);
    }

    /**
     * @dev Returns an ordered/sorted array with all the tokens and balances in a Pool
     */
    function getPoolTokensAndBalances()
        external
        view
        returns (IERC20[] memory tokens, uint256[] memory balances)
    {
        (
            uint112 balance0,
            uint112 balance1,

        ) = getPoolBalancesAndChangeBlock();

        tokens = new IERC20[](2);
        tokens[0] = _token0;
        tokens[1] = _token1;

        balances = new uint256[](2);
        balances[0] = uint256(balance0);
        balances[1] = uint256(balance1);
    }

    function getPoolBalancesAndChangeBlock()
        public
        view
        returns (
            uint112 balance0,
            uint112 balance1,
            uint32 lastChangeBlock
        )
    {
        balance0 = _balance0;
        balance1 = _balance1;
        lastChangeBlock = _lastChangeBlock;
    }

    // Caller must be the Pool owner
    function setSwapFeePercentage(uint256 swapFeePercentage) external {
        _require(msg.sender == _owner, Errors.CALLER_NOT_POOL_OWNER);
        _require(canChangeSwapFee, Errors.CANNOT_MODIFY_SWAP_FEE);
        _setSwapFeePercentage(swapFeePercentage);
    }

    function _setSwapFeePercentage(uint256 swapFeePercentage) private {
        _require(
            swapFeePercentage >= _MIN_SWAP_FEE_PERCENTAGE,
            Errors.MIN_SWAP_FEE_PERCENTAGE
        );
        _require(
            swapFeePercentage <= _MAX_SWAP_FEE_PERCENTAGE,
            Errors.MAX_SWAP_FEE_PERCENTAGE
        );

        _swapFeePercentage = swapFeePercentage;
        emit SwapFeePercentageChanged(swapFeePercentage);
    }

    /**
     * @dev Sets the balances of Pool's tokens and updates the lastChangeBlock.
     */
    function setPoolBalancesAndLastChangeBlock(
        uint256 balance0,
        uint256 balance1
    ) external onlyRouter {
        _balance0 = uint112(balance0);
        _balance1 = uint112(balance1);
        _lastChangeBlock = uint32(block.number);
    }

    // Swap Hooks

    function onSwap(
        IERC20 tokenIn,
        uint256 amountIn,
        uint256 balanceTokenIn,
        uint256 balanceTokenOut,
        uint256 protocolSwapFeePercentage
    ) public onlyRouter returns (uint256, uint256) {
        (
            ,
            ,
            ,
            uint256 scalingFactorTokenIn,
            uint256 scalingFactorTokenOut
        ) = getWeightsAndScalingFactors(tokenIn);

        // All token amounts are upscaled.
        balanceTokenIn = _upscale(balanceTokenIn, scalingFactorTokenIn);
        balanceTokenOut = _upscale(balanceTokenOut, scalingFactorTokenOut);

        uint256 protocolFeeAmount;

        (amountIn, protocolFeeAmount) = _calcPoolAndProtocolSwapFee(
            amountIn,
            protocolSwapFeePercentage,
            scalingFactorTokenIn
        );

        uint256 amountOut = _calcSwapOut(
            tokenIn,
            amountIn,
            balanceTokenIn,
            balanceTokenOut
        );
        _updateWeights(tokenIn, balanceTokenOut, balanceTokenOut - amountOut);

        // amountOut tokens are exiting the Pool, so we round down.
        return (
            _downscaleDown(amountOut, scalingFactorTokenOut),
            protocolFeeAmount
        );
    }

    /**
     * @dev Same as `onSwap`, except it doesn't upscale 'balances' as it already receives upscaled 'balances' and,
     * it downScales 'amountIn' as fee calculation requires 'amountIn' without any type of scaling
     */
    function _onVirtualSwap(
        IERC20 tokenIn,
        uint256 amountIn,
        uint256 balanceTokenIn,
        uint256 balanceTokenOut,
        uint256 protocolSwapFeePercentage
    ) private returns (uint256 amountOut, uint256 protocolFeeAmount) {
        (, , , uint256 scalingFactorTokenIn, ) = getWeightsAndScalingFactors(
            tokenIn
        );

        amountIn = _downscaleDown(amountIn, scalingFactorTokenIn);

        (amountIn, protocolFeeAmount) = _calcPoolAndProtocolSwapFee(
            amountIn,
            protocolSwapFeePercentage,
            scalingFactorTokenIn
        );

        amountOut = _calcSwapOut(
            tokenIn,
            amountIn,
            balanceTokenIn,
            balanceTokenOut
        );

        _updateWeights(tokenIn, balanceTokenOut, balanceTokenOut - amountOut);
    }

    function _calcPoolAndProtocolSwapFee(
        uint256 amountIn,
        uint256 protocolSwapFeePercentage,
        uint256 scalingFactorTokenIn
    ) private view returns (uint256, uint256) {
        amountIn = _upscale(amountIn, scalingFactorTokenIn);
        uint256 feeAmount = amountIn.mulUp(getSwapFeePercentage());
        uint256 protocolFeeAmount = feeAmount.mulUp(protocolSwapFeePercentage);
        amountIn = amountIn - feeAmount;

        return (amountIn, protocolFeeAmount);
    }

    function _calcSwapOut(
        IERC20 tokenIn,
        uint256 amountIn,
        uint256 balanceTokenIn,
        uint256 balanceTokenOut
    ) private view returns (uint256 amountOut) {
        (
            ,
            uint256 weightIn,
            uint256 weightOut,
            ,

        ) = getWeightsAndScalingFactors(tokenIn);

        amountOut = WeightedMath._calcOutGivenIn(
            balanceTokenIn, // Current balance of token In
            weightIn,
            balanceTokenOut, //Current balance of token Out
            weightOut,
            amountIn
        );
    }

    function _updateWeights(
        IERC20 tokenIn,
        uint256 balanceOutOld,
        uint256 balanceOutNew
    ) private {
        (
            bool tokenInIsToken0,
            uint256 weightIn,
            uint256 weightOut,
            ,

        ) = getWeightsAndScalingFactors(tokenIn);

        (uint256 weightInNew, uint256 weightOutNew) = _calculateNewWeights(
            weightIn,
            weightOut,
            balanceOutOld,
            balanceOutNew
        );

        _weight0 = tokenInIsToken0 ? weightInNew : weightOutNew;
        _weight1 = !tokenInIsToken0 ? weightInNew : weightOutNew;
    }

    // Join Hook

    function onJoinPool(
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    )
        external
        onlyRouter
        returns (
            uint256[] memory amountsIn,
            uint256[] memory protocolSwapFeeAmount
        )
    {
        uint256 hptAmountOut;
        if (totalSupply() == 0) {
            (hptAmountOut, amountsIn) = _onInitializePool(userData);

            // On initialization, we lock _MINIMUM_HPT by minting it for the zero address. This HPT acts as a minimum
            // as it will never be burned, which reduces potential issues with rounding, and also prevents the Pool from
            // ever being fully drained.
            _require(hptAmountOut >= _MINIMUM_HPT, Errors.MINIMUM_HPT);
            _mint(address(0), _MINIMUM_HPT);
            _mint(recipient, hptAmountOut - _MINIMUM_HPT);

            // amountsIn are amounts entering the Pool, so we round up.
            _downscaleUpArray(amountsIn);

            // There are no protocol swap fee amounts during initialization
            protocolSwapFeeAmount = new uint256[](2);
        } else {
            _upscaleArray(balances);

            uint256 minHPTAmountOut;

            (
                hptAmountOut,
                amountsIn,
                protocolSwapFeeAmount,
                minHPTAmountOut
            ) = _onJoinPool(
                sender,
                recipient,
                balances,
                protocolSwapFeePercentage,
                userData
            );

            _require(
                hptAmountOut >= minHPTAmountOut,
                Errors.HPT_OUT_MIN_AMOUNT
            );

            _mint(recipient, hptAmountOut);

            // amountsIn are amounts entering the Pool, so we round up.
            _downscaleUpArray(amountsIn);
        }
    }

    /**
     * @dev Called when the Pool is joined for the first time; that is, when the HPT total supply is zero.
     *
     * Returns the amount of HPT to mint, and the token amounts the Pool will receive in return.
     *
     * Minted HPT will be sent to `recipient`, except for _MINIMUM_HPT, which will be deducted from this amount and sent
     * to the zero address instead. This will cause that HPT to remain forever locked there, preventing total BTP from
     * ever dropping below that value, and ensuring `_onInitializePool` can only be called once in the entire Pool's
     * lifetime.
     *
     * The tokens granted to the Pool will be transferred from `sender`. These amounts are considered upscaled and will
     * be downscaled (rounding up) before being returned to the Vault.
     */
    function _onInitializePool(bytes memory userData)
        private
        view
        returns (uint256, uint256[] memory)
    {
        Pool.JoinKind kind = userData.joinKind();
        _require(kind == Pool.JoinKind.INIT, Errors.UNINITIALIZED);

        uint256[] memory amountsIn = userData.initialAmountsIn();
        InputHelpers.ensureInputLengthMatch(amountsIn.length, 2);

        _upscaleArray(amountsIn);

        uint256[] memory weights = _weights();

        uint256 invariant = WeightedMath._calculateInvariant(
            weights,
            amountsIn
        );

        // Set the initial HPT to the value of the invariant times the number of tokens. This makes HPT supply more
        // consistent in Pools with similar compositions but different number of tokens.
        uint256 hptAmountOut = invariant * 2;

        return (hptAmountOut, amountsIn);
    }

    /**
     * @dev Called whenever the Pool is joined after the first initialization join (see `_onInitializePool`).
     *
     * Returns the amount of HPT to mint, the token amounts that the Pool will receive in return, and the number of
     * tokens to pay in protocol swap fees.
     *
     * Minted HPT will be sent to `recipient`.
     *
     * The tokens granted to the Pool will be transferred from `sender`. These amounts are considered upscaled and will
     * be downscaled (rounding up) before being returned to the Vault.
     */
    function _onJoinPool(
        address,
        address,
        uint256[] memory balances,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    )
        private
        returns (
            uint256,
            uint256[] memory,
            uint256[] memory,
            uint256
        )
    {
        uint256[] memory weights = _weights();

        Pool.JoinKind kind = userData.joinKind();

        if (kind == Pool.JoinKind.EXACT_TOKENS_IN_FOR_HPT_OUT) {
            return
                _joinExactTokensInForHPTOut(
                    balances,
                    protocolSwapFeePercentage,
                    userData
                );
        } else if (kind == Pool.JoinKind.EXACT_TOKEN_IN_FOR_HPT_OUT) {
            return
                _joinTokenInForHPTOut(
                    balances,
                    weights,
                    protocolSwapFeePercentage,
                    userData
                );
        } else {
            _revert(Errors.UNHANDLED_JOIN_KIND);
        }
    }

    function _joinExactTokensInForHPTOut(
        uint256[] memory balances,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    )
        private
        returns (
            uint256 hptAmountOut,
            uint256[] memory amountsIn,
            uint256[] memory protocolSwapFeeAmount,
            uint256 minHPTAmountOut
        )
    {
        (amountsIn, minHPTAmountOut) = userData.exactTokensInForHptOut();

        InputHelpers.ensureInputLengthMatch(amountsIn.length, 2);

        _upscaleArray(amountsIn);

        /**
        * To store amountIn with which, we are actually joining the pool, 'amountsIn' provided by the user 
        * might be different than the amount which we are using to calculate LP tokens.
      
        * amountsIn and actualJoinAmountsIn will be different only when user is joining the pool 
        * with different weights than the pool currently has.
        */
        uint256[] memory actualJoinAmountsIn = new uint256[](2);
        actualJoinAmountsIn[0] = amountsIn[0];
        actualJoinAmountsIn[1] = amountsIn[1];

        protocolSwapFeeAmount = new uint256[](2);

        uint256 amountsInRatio = amountsIn[0].divDown(amountsIn[1]);
        uint256 poolBalancesRatio = balances[0].divDown(balances[1]);

        if (amountsInRatio != poolBalancesRatio) {
            (actualJoinAmountsIn, protocolSwapFeeAmount) = _unEqualJoin(
                balances,
                amountsIn,
                actualJoinAmountsIn,
                protocolSwapFeeAmount,
                protocolSwapFeePercentage,
                amountsInRatio,
                poolBalancesRatio
            );
        }

        hptAmountOut = _calculateHptOut(balances, actualJoinAmountsIn);
    }

    function _unEqualJoin(
        uint256[] memory balances,
        uint256[] memory amountsIn,
        uint256[] memory actualJoinAmountsIn,
        uint256[] memory protocolSwapFeeAmount,
        uint256 protocolSwapFeePercentage,
        uint256 amountsInRatio,
        uint256 poolBalancesRatio
    ) private returns (uint256[] memory, uint256[] memory) {
        uint256 amountOut;

        // When ratio of amounts In provided by the user is greater than the pool balances ratio
        if (amountsInRatio > poolBalancesRatio) {
            // Local copies to avoid stack too deep
            uint256 balancesIn = balances[0];
            uint256 balancesOut = balances[1];
            uint256 amountTokenIn = amountsIn[0];
            uint256 amountTokenOut = amountsIn[1];

            uint256 amountsInForVirtualSwap = _calculateVirtualSwapAmountIn(
                balancesIn,
                balancesOut,
                amountTokenIn,
                amountTokenOut,
                _weight0,
                _weight1
            );

            // 'amountOut' is the result of 'onVirtualSwap'
            // 'amountsInForVirtualSwap' is the input amount used when calling 'onVirtualSwap'
            (
                amountOut,
                amountsInForVirtualSwap,
                protocolSwapFeeAmount
            ) = _doVirtualSwap(
                amountTokenIn,
                amountTokenOut,
                amountsInForVirtualSwap,
                _token0,
                protocolSwapFeePercentage,
                balancesIn,
                balancesOut
            );
            actualJoinAmountsIn[0] = amountTokenIn - amountsInForVirtualSwap;
            actualJoinAmountsIn[1] = amountTokenOut + amountOut;
        } else {
            uint256 balancesIn = balances[1];
            uint256 balancesOut = balances[0];
            uint256 amountTokenIn = amountsIn[1];
            uint256 amountTokenOut = amountsIn[0];

            uint256 amountsInForVirtualSwap = _calculateVirtualSwapAmountIn(
                balancesIn,
                balancesOut,
                amountTokenIn,
                amountTokenOut,
                _weight1,
                _weight0
            );

            // 'amountOut' is the result of 'onVirtualSwap'
            // 'amountsInForVirtualSwap' is the input amount used when calling 'onVirtualSwap'
            (
                amountOut,
                amountsInForVirtualSwap,
                protocolSwapFeeAmount
            ) = _doVirtualSwap(
                amountTokenIn,
                amountTokenOut,
                amountsInForVirtualSwap,
                _token1,
                protocolSwapFeePercentage,
                balancesIn,
                balancesOut
            );

            actualJoinAmountsIn[0] = amountTokenOut + amountOut;
            actualJoinAmountsIn[1] = amountTokenIn - amountsInForVirtualSwap;
        }
        return (actualJoinAmountsIn, protocolSwapFeeAmount);
    }

    function _joinTokenInForHPTOut(
        uint256[] memory balances,
        uint256[] memory weights,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    )
        private
        returns (
            uint256 hptAmountOut,
            uint256[] memory amountsIn,
            uint256[] memory protocolSwapFeeAmount,
            uint256 minHPTAmountOut
        )
    {
        uint256 amountIn;
        uint256 tokenIndex;
        (amountIn, tokenIndex, minHPTAmountOut) = userData
            .exactTokenInForHptOut();
        _require(tokenIndex < 2, Errors.OUT_OF_BOUNDS);

        // Storing in local variables to avoid stack too deep
        uint256[] memory _balances = balances;
        uint256 _protocolSwapFeePercentage = protocolSwapFeePercentage;

        amountsIn = new uint256[](2);
        amountsIn[tokenIndex] = amountIn;

        _upscaleArray(amountsIn);

        uint256 amountInForVirtualSwap;

        // Block scope to avoid stack too deep
        {
            // Calculating "actual" amountIn (of the token which user is providing) according to the
            // weight of that token in the pool
            uint256 actualAmountIn = weights[tokenIndex].mulDown(
                amountsIn[tokenIndex]
            );

            // 'amountInForVirtualSwap' contains the extra amount of tokens user is providing to join the pool,
            // we will swap this amount for the other token
            amountInForVirtualSwap = amountsIn[tokenIndex] - actualAmountIn;
        }

        // Determing which is tokenIn and which is tokenOut
        (
            IERC20 tokenInForVirtualSwap,
            IERC20 tokenOutForVirtualSwap
        ) = tokenIndex == 0 ? (_token0, _token1) : (_token1, _token0);

        // We have the Pool balances, but we don't know which one is 'token in' or 'token out'
        uint256 balanceIn;
        uint256 balanceOut;

        // Because token 0 has a smaller address than token 1
        if (tokenInForVirtualSwap < tokenOutForVirtualSwap) {
            // in is _token0, out is _token1
            balanceIn = _balances[0];
            balanceOut = _balances[1];
        } else {
            // in is _token1, out is _token0
            balanceOut = _balances[0];
            balanceIn = _balances[1];
        }

        uint256 amountOut;
        protocolSwapFeeAmount = new uint256[](2);

        // 'amountOut' is the result of 'onVirtualSwap'
        // 'amountsInForVirtualSwap' is the input amount used when calling 'onVirtualSwap'
        (
            amountOut,
            amountInForVirtualSwap,
            protocolSwapFeeAmount
        ) = _doVirtualSwap(
            amountsIn[tokenIndex],
            0,
            amountInForVirtualSwap,
            tokenInForVirtualSwap,
            _protocolSwapFeePercentage,
            balanceIn,
            balanceOut
        );

        // To store 'virtual join amounts' for '_calculateHptOut'
        uint256[] memory virtualAmountsInForTokensJoin = new uint256[](2);
        (
            virtualAmountsInForTokensJoin[0],
            virtualAmountsInForTokensJoin[1]
        ) = tokenIndex == 0
            ? (amountsIn[tokenIndex] - amountInForVirtualSwap, amountOut)
            : (amountOut, amountsIn[tokenIndex] - amountInForVirtualSwap);

        hptAmountOut = _calculateHptOut(
            _balances,
            virtualAmountsInForTokensJoin
        );
    }

    function _calculateHptOut(
        uint256[] memory balances,
        uint256[] memory actualJoinAmountsIn
    ) private view returns (uint256 hptAmountOut) {
        hptAmountOut = WeightedMath._calcHptOutGivenExactTokensIn(
            balances,
            _weights(),
            actualJoinAmountsIn,
            totalSupply(),
            getSwapFeePercentage()
        );
    }

    function _doVirtualSwap(
        uint256 amountIn,
        uint256 amountOutIn,
        uint256 amountInForVirtualSwap,
        IERC20 tokenInForVirtualSwap,
        uint256 protocolSwapFeePercentage,
        uint256 balanceTokenIn,
        uint256 balanceTokenOut
    )
        private
        returns (
            uint256 amountOut,
            uint256 amountInLastForVirtualSwap,
            uint256[] memory protocolSwapFeeAmount
        )
    {
        (
            bool tokenInIsToken0,
            uint256 weightIn,
            ,
            ,

        ) = getWeightsAndScalingFactors(tokenInForVirtualSwap);

        uint256 protocolSwapFee;
        for (uint256 i = 0; i < 3; i++) {
            if (i != 2) {
                amountOut = _calcSwapOut(
                    tokenInForVirtualSwap,
                    amountInForVirtualSwap,
                    balanceTokenIn,
                    balanceTokenOut
                );

                amountInForVirtualSwap = _calculateNextIterationAmountIn(
                    amountIn,
                    // AmountOutIn should be zero incase of single token join
                    amountOutIn,
                    amountInForVirtualSwap,
                    weightIn,
                    amountOut,
                    balanceTokenIn,
                    balanceTokenOut
                );
            } else {
                (amountOut, protocolSwapFee) = _onVirtualSwap(
                    tokenInForVirtualSwap,
                    amountInForVirtualSwap,
                    balanceTokenIn,
                    balanceTokenOut,
                    protocolSwapFeePercentage
                );
            }
        }
        protocolSwapFeeAmount = new uint256[](2);

        // Will pay protocol swap fee in amountIn token
        uint256 protocolFeeTokenIndex = tokenInIsToken0 ? 0 : 1;
        protocolSwapFeeAmount[protocolFeeTokenIndex] = protocolSwapFee;
        amountInLastForVirtualSwap = amountInForVirtualSwap;
    }

    // Exit Hook

    function onExitPool(
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    ) external onlyRouter returns (uint256[] memory, uint256[] memory) {
        _upscaleArray(balances);
        (
            uint256 hptAmountIn,
            uint256[] memory amountsOut,
            uint256[] memory protocolSwapFeeAmount
        ) = _onExitPool(
                sender,
                recipient,
                balances,
                protocolSwapFeePercentage,
                userData
            );

        _burn(sender, hptAmountIn);

        _downscaleDownArray(amountsOut);

        return (amountsOut, protocolSwapFeeAmount);
    }

    /**
     * @dev Called whenever the Pool is exited.
     *
     * Returns the amount of HPT to burn, the token amounts for each Pool token that the Pool will grant in return, and
     * the number of tokens to pay in protocol swap fees.
     *
     * HPT will be burnt from `sender`.
     *
     * The Pool will grant tokens to `recipient`. These amounts are considered upscaled and will be downscaled
     * (rounding down) before being returned to the Vault.
     */
    function _onExitPool(
        address,
        address,
        uint256[] memory balances,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    )
        private
        returns (
            uint256 hptAmountIn,
            uint256[] memory amountsOut,
            uint256[] memory protocolSwapFeeAmount
        )
    {
        (hptAmountIn, amountsOut, protocolSwapFeeAmount) = _doExit(
            balances,
            protocolSwapFeePercentage,
            userData
        );
        return (hptAmountIn, amountsOut, protocolSwapFeeAmount);
    }

    function _doExit(
        uint256[] memory balances,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    )
        private
        returns (
            uint256 hptAmountIn,
            uint256[] memory amountsOut,
            uint256[] memory protocolSwapFeeAmount
        )
    {
        // Note that there is no minimum amountOut parameter: this is handled by `Router.exitPool`.
        uint256 weightInputToken0;
        (hptAmountIn, weightInputToken0) = userData.exactHptInForTokensOut();

        // Ensure that the input weight is not more than 1
        _require(
            weightInputToken0 <= FixedPoint.ONE,
            Errors.NORMALIZED_WEIGHT_INVARIANT
        );

        uint256 weightInputToken1 = ONE - weightInputToken0;

        // 'amountsOut' contains amount of both tokens in the pool according to the pool ratio
        amountsOut = WeightedMath._calcTokensOutGivenExactHptIn(
            balances,
            hptAmountIn,
            totalSupply()
        );

        protocolSwapFeeAmount = new uint256[](2);
        uint256 protocolSwapFee;

        // If user wants to exit with weights that are different than pool's
        if (!(_weight0 == weightInputToken0 && _weight1 == weightInputToken1)) {
            uint256 amountOut;

            if (_weight0 > weightInputToken0) {
                uint256 amountInForVirtualSwap = amountsOut[0]
                    .divDown(_weight0)
                    .mulDown(_weight0 - weightInputToken0);

                (amountOut, protocolSwapFee) = _onVirtualSwap(
                    _token0,
                    amountInForVirtualSwap,
                    balances[0] - amountsOut[0],
                    balances[1] - amountsOut[1],
                    protocolSwapFeePercentage
                );

                amountsOut[0] = amountsOut[0] - amountInForVirtualSwap;
                amountsOut[1] = amountsOut[1] + amountOut;

                // Will pay protocol swap fee in amountIn token
                // 0 index, cause token in will be _token0
                protocolSwapFeeAmount[0] = protocolSwapFee;
            } else {
                uint256 amountInForVirtualSwap = amountsOut[1]
                    .divDown(_weight1)
                    .mulDown(_weight1 - weightInputToken1);

                (amountOut, protocolSwapFee) = _onVirtualSwap(
                    _token1,
                    amountInForVirtualSwap,
                    balances[1] - amountsOut[1],
                    balances[0] - amountsOut[0],
                    protocolSwapFeePercentage
                );

                amountsOut[1] = amountsOut[1] - amountInForVirtualSwap;
                amountsOut[0] = amountsOut[0] + amountOut;

                // Will pay protocol swap fee in amountIn token
                // 1 index, cause token in will be _token1
                protocolSwapFeeAmount[1] = protocolSwapFee;
            }
        }
    }

    // Helpers

    // Scaling

    /**
     * @dev Returns a scaling factor that, when multiplied to a token amount for `token`, normalizes its balance as if
     * it had 18 decimals.
     */
    function _computeScalingFactor(IERC20 token)
        private
        view
        returns (uint256)
    {
        // Tokens that don't implement the `decimals` method are not supported.
        uint256 tokenDecimals = ERC20(address(token)).decimals();

        // Tokens with more than 18 decimals are not supported.
        uint256 decimalsDifference = 18 - tokenDecimals;
        return 10**decimalsDifference;
    }

    /**
     * @dev Returns the scaling factor for one of the Pool's tokens.
     */
    function _scalingFactor(bool token0) private view returns (uint256) {
        return token0 ? _scalingFactor0 : _scalingFactor1;
    }

    /**
     * @dev Applies `scalingFactor` to `amount`, resulting in a larger or equal value depending on whether it needed
     * scaling or not.
     */
    function _upscale(uint256 amount, uint256 scalingFactor)
        private
        pure
        returns (uint256)
    {
        return amount * scalingFactor;
    }

    /**
     * @dev Same as `_upscale`, but for an entire array (of two elements). This function does not return anything, but
     * instead *mutates* the `amounts` array.
     */
    function _upscaleArray(uint256[] memory amounts) private view {
        amounts[0] = amounts[0] * _scalingFactor(true);
        amounts[1] = amounts[1] * _scalingFactor(false);
    }

    /**
     * @dev Reverses the `scalingFactor` applied to `amount`, resulting in a smaller or equal value depending on
     * whether it needed scaling or not. The result is rounded down.
     */
    function _downscaleDown(uint256 amount, uint256 scalingFactor)
        private
        pure
        returns (uint256)
    {
        return Math.divDown(amount, scalingFactor);
    }

    /**
     * @dev Same as `_downscaleDown`, but for an entire array (of two elements). This function does not return anything,
     * but instead *mutates* the `amounts` array.
     */
    function _downscaleDownArray(uint256[] memory amounts) private view {
        amounts[0] = Math.divDown(amounts[0], _scalingFactor(true));
        amounts[1] = Math.divDown(amounts[1], _scalingFactor(false));
    }

    /**
     * @dev Reverses the `scalingFactor` applied to `amount`, resulting in a smaller or equal value depending on
     * whether it needed scaling or not. The result is rounded up.
     */
    function _downscaleUp(uint256 amount, uint256 scalingFactor)
        private
        pure
        returns (uint256)
    {
        return Math.divUp(amount, scalingFactor);
    }

    /**
     * @dev Same as `_downscaleUp`, but for an entire array (of two elements). This function does not return anything,
     * but instead *mutates* the `amounts` array.
     */
    function _downscaleUpArray(uint256[] memory amounts) private view {
        amounts[0] = Math.divUp(amounts[0], _scalingFactor(true));
        amounts[1] = Math.divUp(amounts[1], _scalingFactor(false));
    }
}




interface IProtocolFeesCollector {
    function getProtocolSwapFeePercentage() external view returns (uint256);
}

 

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
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
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


contract HedgeFactory is Ownable {
    IProtocolFeesCollector private _protocolFeesCollector;

    address private immutable ROUTER;

    // To get the address of the nth pair (0-indexed) created through the factory,
    // or address(0) if not enough pairs have been created yet.
    // Pass 0 for the address of the first pair created, 1 for the second, etc.
    address[] public allPools;

    mapping(address => mapping(address => address)) public getPool;

    event ProtocolFeeCollectorSet(address protocolFeeCollectorAddress);

    event PoolCreated(
        address indexed token0,
        address indexed token1,
        address indexed pool
    );

    constructor(address routerAddress) {
        ROUTER = routerAddress;
    }

    function getRouter() public view returns (address) {
        return ROUTER;
    }

    /**
     * @dev Sets the protocol fee collector.
     */

    function setProtocolFeeCollector(address _newProtocolFeeCollector)
        external
        onlyOwner
    {
        _require(_newProtocolFeeCollector != address(0), Errors.ZERO_TOKEN);
        _protocolFeesCollector = IProtocolFeesCollector(
            _newProtocolFeeCollector
        );
        emit ProtocolFeeCollectorSet(_newProtocolFeeCollector);
    }

    /**
     * @dev Returns the protocol swap fee collector address.
     */
    function getProtocolFeesCollector() public view returns (address) {
        return address(_protocolFeesCollector);
    }

    /**
     * @dev Returns the protocol swap fee percentage.
     */
    function _getProtocolSwapFeePercentage() external view returns (uint256) {
        return
            address(_protocolFeesCollector) != address(0)
                ? _protocolFeesCollector.getProtocolSwapFeePercentage()
                : 0;
    }

    /**
     * @dev Returns the total number of pairs created through the factory so far.
     */
    function allPoolsLength() external view returns (uint256) {
        return allPools.length;
    }

    /**
     * @dev Deploys a new Pool.
     *
     * Note '_changeSwapFee' true indicates that swap can be changed by the pool owner after Pool is created.
     */
    function create(
        address tokenA,
        address tokenB,
        uint256 weightA,
        uint256 weightB,
        uint256 _swapFeePercentage,
        bool _changeSwapFee
    ) external returns (address) {
        _require(tokenA != tokenB, Errors.IDENTICAL_ADDRESSES);
        // Sorting tokens in ascending order
        (
            address _token0,
            address _token1,
            uint256 _weight0,
            uint256 _weight1
        ) = tokenA < tokenB
                ? (tokenA, tokenB, weightA, weightB)
                : (tokenB, tokenA, weightB, weightA);

        _require(_token0 != address(0), Errors.ZERO_TOKEN);
        _require(_token1 != address(0), Errors.ZERO_TOKEN);
      
        _require(getPool[_token0][_token1] == address(0), Errors.POOL_EXISTS);

        Pool.NewPoolParams memory params = Pool.NewPoolParams({
            router: getRouter(),
            token0: IERC20(_token0),
            token1: IERC20(_token1),
            weight0: _weight0,
            weight1: _weight1,
            swapFeePercentage: _swapFeePercentage,
            changeSwapFeeEnabled: _changeSwapFee,
            owner: msg.sender
        });

        address pool = address(new Pool(params));
        getPool[_token0][_token1] = pool;
        getPool[_token1][_token0] = pool; // populate mapping in the reverse direction
        allPools.push(pool);
        emit PoolCreated(_token0, _token1, pool);
        return pool;
    }
}