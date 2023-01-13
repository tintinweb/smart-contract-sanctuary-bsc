/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.10;


contract CoefficientCalculator {
    uint256 public decimals;

    constructor() {
        decimals = 10 ** 9;
    }

    struct CoefficientsItem {
    uint256[] subCoefficients;
    uint256 coefficient;
}

struct CoefficientsData {
    CoefficientsItem[] subCoefficientsItems;
    uint256 finalCoefficient;
}

event CalculatedResult(uint256 indexed amount, CoefficientsData coefficientsData);

    function Calculate(bytes calldata betData)external returns (uint256){
        (
            uint256[] memory coefficients_,
            int8[] memory results,
            uint256[] memory voidFactors,
            uint256 amount
        ) = abi.decode(
                betData,
                (uint256[], int8[], uint256[], uint256)
            );

        require(
            coefficients_.length == results.length &&
                coefficients_.length == voidFactors.length &&
                coefficients_.length >= 1,
            "Bet data is not valid."
        );

        uint256 conditionLength = coefficients_.length;

        uint256 finalCoefficient = 0;
        uint256 voidFactor_ = decimals;
        uint256 voidFactorCount = 0;
        uint256[] memory voidFactorIndex = new uint256[](conditionLength);
        uint256[] memory coefficients = new uint256[](conditionLength);

        CoefficientsData memory coefficientsData;

        for (uint256 i = 0; i < conditionLength; ++i) {
            uint256 voidFactor = voidFactors[i];
            int8 result = results[i];
            uint256 coefficient = coefficients_[i];
            require(
                voidFactor >= 0 &&
                    voidFactor <= decimals,
                "Core: Invalid void_factor"
            );

            uint256 subCoefficient = 0;

            if (result == -1) {
                // UNDECIDED_YET
                revert("Core: Invalid settlement data");
            } else if (result == 0) {
                // LOST
                if (voidFactor == decimals) {
                    // refund bet
                    subCoefficient = decimals;
                } else {
                    subCoefficient = 0;
                }
            } else if (result == 1) {
                // WIN
                subCoefficient = coefficient;
            }

            if (
                voidFactor != 0 &&
                voidFactor != decimals
            ) // half win/lose
            {
                voidFactorIndex[voidFactorCount] = i;
                voidFactorCount += 1;
                voidFactor_ =
                    (voidFactor_ * voidFactor) /
                    decimals;
            }

            coefficients[i] = subCoefficient;
        }

                // calculate final coefficient
        if (voidFactorCount == 0) {
            // no half win/lose
            finalCoefficient = _calcCoefficient(coefficients, conditionLength);
            CoefficientsItem memory coefficientItem;
            coefficientsData.subCoefficientsItems = new CoefficientsItem[](1);
            coefficientItem.subCoefficients = coefficients;
            coefficientItem.coefficient = finalCoefficient;

            coefficientsData.subCoefficientsItems[0] = coefficientItem;
            coefficientsData.finalCoefficient = finalCoefficient;
        } else {
            coefficientsData = _genCoefficients(
                coefficients,
                conditionLength,
                voidFactorIndex,
                voidFactorCount
            );

            finalCoefficient = coefficientsData.finalCoefficient;
        }

        uint256 winAmount = amount *
            (finalCoefficient / decimals) *
            (voidFactor_ / decimals);
        emit CalculatedResult(winAmount, coefficientsData);
        return winAmount;
    }


    function _genCoefficients(
        uint256[] memory coefficients,
        uint256 coefficientsCount,
        uint256[] memory voidFactorIndex,
        uint256 voidFactorsCount
    ) internal view returns (CoefficientsData memory) {
        require(
            coefficientsCount >= voidFactorsCount,
            "Core: GenCoeff invalid data"
        );
        CoefficientsData memory coefficientsData;
        coefficientsData.subCoefficientsItems = new CoefficientsItem[](voidFactorsCount * (voidFactorsCount - 1) + 2);
        uint256 pos = 0;
        uint256 finalCoefficient = 0;
        for (uint256 i = 0; i <= voidFactorsCount; ++i) {
            for (uint256 j = 0; j < voidFactorsCount; ++j) {
                uint256[] memory tempCoefficients = _copyArray(
                    coefficients,
                    coefficientsCount
                );

                for (uint256 k = 0; k < i; ++k) {
                    tempCoefficients[
                        (voidFactorIndex[(k + j) % voidFactorsCount]) %
                            coefficientsCount
                    ] = decimals;
                }

                CoefficientsItem memory coefficientItem;
                coefficientItem.subCoefficients = tempCoefficients;
                coefficientItem.coefficient = _calcCoefficient(
                    tempCoefficients,
                    coefficientsCount
                );
                coefficientsData.subCoefficientsItems[pos++] = coefficientItem;
                finalCoefficient += coefficientItem.coefficient;

                if (i % voidFactorsCount == 0) {
                    break;
                }
            }
        }

        coefficientsData.finalCoefficient = finalCoefficient;

        return coefficientsData;
    }

    function _copyArray(
        uint256[] memory data,
        uint256 dataCount
    ) internal pure returns (uint256[] memory) {
        uint256[] memory dupData = new uint256[](dataCount);
        for (uint256 i = 0; i < dataCount; ++i) {
            dupData[i] = data[i];
        }
        return dupData;
    }

    function _calcCoefficient(
        uint256[] memory coefficients,
        uint256 coefficientsCount
    ) internal view returns (uint256) {
        uint256 retValue = decimals;
        for (uint256 i = 0; i < coefficientsCount; ++i) {
            retValue = (retValue * coefficients[i]) / decimals;
        }

        return retValue;
    }
}