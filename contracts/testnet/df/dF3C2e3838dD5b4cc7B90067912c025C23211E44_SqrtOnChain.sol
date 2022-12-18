//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SqrtOnChain
 * @author kotsmile
 */

contract SqrtOnChain {
    int256 public value;

    function sqrt(int256 x) external {
        int256 z = (x + 1) / 2;
        int256 y = x;
        while ((z - y) < 0) {
            y = z;
            z = (x / z + z) / 2;
        }
        value = y;
    }
}