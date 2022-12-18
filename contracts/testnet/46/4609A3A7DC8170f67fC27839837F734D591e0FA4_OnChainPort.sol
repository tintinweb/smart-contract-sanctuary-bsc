//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title OnChainPort
 * @author
 */

contract OnChainPort {
    int256[31] public index = [
        int256(3_00),
        int256(1_23),
        int256(2_00),
        int256(3_00),
        int256(1_23),
        int256(2_33),
        int256(3_01),
        int256(1_23),
        int256(2_00),
        int256(3_00),
        int256(1_23),
        int256(2_00),
        int256(3_03),
        int256(1_23),
        int256(2_00),
        int256(3_00),
        int256(1_23),
        int256(2_00),
        int256(3_00),
        int256(1_23),
        int256(2_00),
        int256(3_00),
        int256(1_23),
        int256(2_00),
        int256(2_00),
        int256(3_00),
        int256(1_23),
        int256(2_00),
        int256(3_00),
        int256(1_23),
        int256(2_00)
    ];
    int256[31] public assetCorr = [
        int256(3_00),
        int256(1_23),
        int256(2_00),
        int256(3_00),
        int256(1_23),
        int256(2_33),
        int256(3_01),
        int256(1_23),
        int256(2_00),
        int256(3_00),
        int256(1_23),
        int256(2_00),
        int256(3_03),
        int256(1_23),
        int256(2_00),
        int256(3_00),
        int256(1_23),
        int256(2_00),
        int256(3_00),
        int256(1_23),
        int256(2_00),
        int256(3_00),
        int256(1_23),
        int256(2_00),
        int256(2_00),
        int256(3_00),
        int256(1_23),
        int256(2_00),
        int256(3_00),
        int256(1_23),
        int256(2_00)
    ];
    int256[31] public assetNot = [
        int256(3_00),
        int256(1_23),
        int256(5_05),
        int256(6_05),
        int256(4_28),
        int256(5_38),
        int256(6_06),
        int256(4_28),
        int256(5_10),
        int256(6_05),
        int256(4_28),
        int256(13_05),
        int256(7_10),
        int256(5_28),
        int256(6_05),
        int256(7_05),
        int256(5_28),
        int256(3_05),
        int256(8_05),
        int256(6_28),
        int256(10_05),
        int256(8_05),
        int256(6_28),
        int256(7_05),
        int256(7_05),
        int256(7_05),
        int256(5_28),
        int256(6_00),
        int256(7_00),
        int256(5_23),
        int256(6_00)
    ];
    uint32 public constant SIZE = 31;

    function mean(int256[SIZE] memory arr) internal pure returns (int256) {
        int256 sum = 0;
        for (uint256 i; i < SIZE; i++) {
            sum = sum + arr[i];
        }
        return sum / int32(SIZE);
    }

    function disp(int256[SIZE] memory arr) internal pure returns (int256) {
        int256 m = mean(arr);
        int256 sum = 0;
        for (uint256 i; i < SIZE; i++) {
            sum = sum + (arr[i] - m)**2;
        }
        return sum / int32(SIZE);
    }

    function cov(int256[SIZE] memory arr1, int256[SIZE] memory arr2)
        internal
        pure
        returns (int256)
    {
        int256 m1 = mean(arr1);
        int256 m2 = mean(arr2);

        int256 sum = 0;
        for (uint256 i; i < SIZE; i++) {
            sum = sum + (arr1[i] - m1) * (arr2[i] - m2);
        }

        return sum / int32(SIZE);
    }

    int256 public value;

    function calccorr() external {
        value = cov(index, assetCorr) / disp(index);
    }

    function calcNot() external {
        value = cov(index, assetNot) / disp(index);
    }
}