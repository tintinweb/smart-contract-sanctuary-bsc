// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Array {
    function remove(uint256[] storage array, uint256 element) public {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == element) {
                array[i] = array[array.length - 1];
                array.pop();
            }
        }
    }
}