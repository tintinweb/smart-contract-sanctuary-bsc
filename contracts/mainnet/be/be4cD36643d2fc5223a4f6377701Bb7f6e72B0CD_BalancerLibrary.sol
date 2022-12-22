/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.0;


// 
library BalancerLibrary {
    uint256 private constant MAX_LOOP_LIMIT = 256;
    uint256 private constant DERIVATIVE_MULTIPLIER = 1000000;

    struct BalanceRequest {
        uint256 r0;
        uint256 r1;
        uint256 b0;
        uint256 b1;
    }

    struct SSDerivativeRequest {
        uint256 r0;
        uint256 r1;
        uint256 x;
        uint256 y;
        uint256 d;
    }

    struct BalanceResult {
        uint256 give0;
        uint256 give1;
        uint256 take0;
        uint256 take1;
    }

    function balanceLiquidityCP(
        BalanceRequest memory req,
        uint256 fee,
        uint256 maxFee
    ) public pure returns (BalanceResult memory) {
        {
            uint256 balanced0 = (req.b1 * req.r0) / req.r1;
            if (balanced0 > req.b0) {
                invertRequest(req);
                BalanceResult memory _result = balanceLiquidityCP(req, fee, maxFee);
                invertResult(_result);
                return _result;
            }
        }
        BalanceResult memory result;
        result.give0 = 1;
        uint256 prevX;
        uint256 feeNumerator = maxFee - fee;
        for (uint256 i = 0; i < MAX_LOOP_LIMIT; i++) {
            prevX = result.give0;
            result.take1 = getYCP(req.r0, req.r1, result.give0, feeNumerator, maxFee);
            uint256 yDerivative = getYDerivativeCP(
                req.r0,
                req.r1,
                result.give0,
                result.take1,
                feeNumerator,
                maxFee,
                DERIVATIVE_MULTIPLIER
            );
            result.give0 = getX(req, result.give0, result.take1, yDerivative);
            if (within1(result.give0, prevX)) {
                break;
            }
        }
        return result;
    }

    function balanceLiquiditySS(
        BalanceRequest memory req,
        uint256 fee,
        uint256 maxFee,
        uint256 A,
        uint256 A_PRECISION
    ) public pure returns (BalanceResult memory) {
        {
            uint256 balanced0 = (req.b1 * req.r0) / req.r1;
            if (balanced0 > req.b0) {
                invertRequest(req);
                BalanceResult memory _result = balanceLiquiditySS(req, fee, maxFee, A, A_PRECISION);
                invertResult(_result);
                return _result;
            }
        }
        BalanceResult memory result;
        result.give0 = 1;
        uint256 prevX;
        uint256 feeNumerator = maxFee - fee;
        uint256 d = getD(req.r0, req.r1, A, A_PRECISION);
        for (uint256 i = 0; i < MAX_LOOP_LIMIT; i++) {
            prevX = result.give0;
            result.take1 = getYSS(req.r0, req.r1, result.give0, d, feeNumerator, maxFee, A, A_PRECISION);
            SSDerivativeRequest memory dReq;
            dReq.r0 = req.r0;
            dReq.r1 = req.r1;
            dReq.x = result.give0;
            dReq.y = result.take1;
            dReq.d = d;
            uint256 yDerivative = getYDerivativeSS(dReq, feeNumerator, maxFee, A, A_PRECISION, DERIVATIVE_MULTIPLIER);
            result.give0 = getX(req, result.give0, result.take1, yDerivative);
            if (within1(result.give0, prevX)) {
                break;
            }
        }
        return result;
    }

    function invertRequest(BalanceRequest memory req) private pure {
        uint256 tmp = req.r0;
        req.r0 = req.r1;
        req.r1 = tmp;
        tmp = req.b0;
        req.b0 = req.b1;
        req.b1 = tmp;
    }

    function invertResult(BalanceResult memory result) private pure {
        uint256 tmp = result.give0;
        result.give0 = result.give1;
        result.give1 = tmp;
        tmp = result.take0;
        result.take0 = result.take1;
        result.take1 = tmp;
    }

    function getX(
        BalanceRequest memory req,
        uint256 x,
        uint256 y,
        uint256 yDerivative
    ) private pure returns (uint256) {
        uint256 numerator = (req.b0 - x) * (req.r1 - y) - (req.b1 + req.r1) * (req.r0 + x);
        numerator = numerator * DERIVATIVE_MULTIPLIER;
        uint256 denominator = yDerivative * (req.r0 + req.b0) + req.r1 * DERIVATIVE_MULTIPLIER;
        return x + numerator / denominator;
    }

    function getYCP(
        uint256 r0,
        uint256 r1,
        uint256 x,
        uint256 feeNumerator,
        uint256 feeDenominator
    ) private pure returns (uint256) {
        uint256 numerator = r0 * r1 * feeDenominator;
        uint256 denominator = r0 * feeDenominator + x * feeNumerator;
        return (r1 * denominator - numerator) / denominator;
    }

    function getYDerivativeCP(
        uint256 r0,
        uint256 r1,
        uint256 x,
        uint256 y,
        uint256 feeNumerator,
        uint256 feeDenominator,
        uint256 resultMultiplier
    ) private pure returns (uint256) {
        uint256 numerator = (r1 - y) * feeNumerator * resultMultiplier;
        uint256 denominator = r0 * feeDenominator + x * feeNumerator;
        return numerator / denominator;
    }

    function getYSS(
        uint256 r0,
        uint256 r1,
        uint256 x,
        uint256 d,
        uint256 feeNumerator,
        uint256 feeDenominator,
        uint256 A,
        uint256 A_PRECISION
    ) private pure returns (uint256) {
        x = (x * feeNumerator) / feeDenominator;
        return r1 - getY(r0 + x, d, A, A_PRECISION);
    }

    function getYDerivativeSS(
        SSDerivativeRequest memory req,
        uint256 feeNumerator,
        uint256 feeDenominator,
        uint256 A,
        uint256 A_PRECISION,
        uint256 resultMultiplier
    ) private pure returns (uint256) {
        uint256 val1 = (req.r0 * feeDenominator + feeNumerator * req.x) / feeDenominator;
        uint256 val2 = req.r1 - req.y;
        uint256 denominator = 4 * A * 16 * val1 * val2;
        uint256 dP = (((A_PRECISION * req.d * req.d) / val1) * req.d) / val2;
        uint256 numerator = (denominator * feeNumerator) / feeDenominator + dP;
        numerator = numerator * resultMultiplier;
        return numerator / denominator;
    }

    function getD(
        uint256 xp0,
        uint256 xp1,
        uint256 A,
        uint256 A_PRECISION
    ) private pure returns (uint256 d) {
        uint256 x = xp0 < xp1 ? xp0 : xp1;
        uint256 y = xp0 < xp1 ? xp1 : xp0;
        uint256 s = x + y;
        if (s == 0) {
            return 0;
        }

        uint256 N_A = 16 * A;
        uint256 numeratorP = N_A * s * y;
        uint256 denominatorP = (N_A - 4 * A_PRECISION) * y;

        uint256 prevD;
        d = s;
        for (uint256 i = 0; i < MAX_LOOP_LIMIT; i++) {
            prevD = d;
            uint256 N_D = (A_PRECISION * d * d) / x;
            d = (2 * d * N_D + numeratorP) / (3 * N_D + denominatorP);
            if (within1(d, prevD)) {
                break;
            }
        }
    }

    function getY(
        uint256 x,
        uint256 d,
        uint256 A,
        uint256 A_PRECISION
    ) private pure returns (uint256 y) {
        uint256 yPrev;
        y = d;
        uint256 N_A = A * 4;
        uint256 numeratorP = (((A_PRECISION * d * d) / x) * d) / 4;
        unchecked {
            uint256 denominatorP = N_A * (x - d) + d * A_PRECISION; // underflow is possible and desired

            // @dev Iterative approximation.
            for (uint256 i = 0; i < MAX_LOOP_LIMIT; i++) {
                yPrev = y;
                uint256 N_Y = N_A * y;
                y = (N_Y * y + numeratorP) / (2 * N_Y + denominatorP);
                if (within1(y, yPrev)) {
                    break;
                }
            }
        }
    }

    function within1(uint256 a, uint256 b) internal pure returns (bool) {
        unchecked {
            if (a > b) {
                return a - b <= 1;
            }
            return b - a <= 1;
        }
    }
}