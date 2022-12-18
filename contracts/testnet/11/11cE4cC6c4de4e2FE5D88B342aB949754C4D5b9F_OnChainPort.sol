//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title OnChainPort
 * @author
 */

contract OnChainPort {
    uint256[31] public index = [
        3_00,
        1_23,
        2_00,
        3_00,
        1_23,
        2_33,
        3_01,
        1_23,
        2_00,
        3_00,
        1_23,
        2_00,
        3_03,
        1_23,
        2_00,
        3_00,
        1_23,
        2_00,
        3_00,
        1_23,
        2_00,
        3_00,
        1_23,
        2_00,
        2_00,
        3_00,
        1_23,
        2_00,
        3_00,
        1_23,
        2_00
    ];
    uint256[31] public assetCorr = [
        3_00,
        1_23,
        2_00,
        3_00,
        1_23,
        2_33,
        3_01,
        1_23,
        2_00,
        3_00,
        1_23,
        2_00,
        3_03,
        1_23,
        2_00,
        3_00,
        1_23,
        2_00,
        3_00,
        1_23,
        2_00,
        3_00,
        1_23,
        2_00,
        2_00,
        3_00,
        1_23,
        2_00,
        3_00,
        1_23,
        2_00
    ];
    uint256[31] public assetNot = [
        3_00,
        1_23,
        5_05,
        6_05,
        4_28,
        5_38,
        6_06,
        4_28,
        5_10,
        6_05,
        4_28,
        13_05,
        7_10,
        5_28,
        6_05,
        7_05,
        5_28,
        3_05,
        8_05,
        6_28,
        10_05,
        8_05,
        6_28,
        7_05,
        7_05,
        7_05,
        5_28,
        6_00,
        7_00,
        5_23,
        6_00
    ];
    uint32 public constant SIZE = 31;

    function mean(uint256[SIZE] memory arr) internal pure returns (uint256) {
        uint256 sum = 0;
        for (uint256 i; i < SIZE; i++) {
            sum = sum + arr[i];
        }
        return sum / SIZE;
    }

    function disp(uint256[SIZE] memory arr) internal pure returns (uint256) {
        uint256 m = mean(arr);
        uint256 sum = 0;
        for (uint256 i; i < SIZE; i++) {
            sum = sum + (arr[i] - m)**2;
        }
        return sum / SIZE;
    }

    function cov(uint256[SIZE] memory arr1, uint256[SIZE] memory arr2)
        internal
        pure
        returns (uint256)
    {
        uint256 m1 = mean(arr1);
        uint256 m2 = mean(arr2);

        uint256 sum = 0;
        for (uint256 i; i < SIZE; i++) {
            sum = sum + (arr1[i] - m1) * (arr2[i] - m2);
        }

        return sum / SIZE;
    }

    uint256 public value;

    function calccorr() external {
        value = cov(index, assetCorr) / disp(index);
    }

    function calcNot() external {
        value = cov(index, assetNot) / disp(index);
    }
}