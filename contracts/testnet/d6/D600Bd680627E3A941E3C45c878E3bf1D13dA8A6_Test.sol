/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

contract Test {
    uint[] public array;

    event List (
        uint[] array
    );

    function LoopInput(uint index) public {
        // array[] = [];
        // loop push
        array = new uint256[](index);
        for (uint i=0;i<index;i++){
            // array.push() = i;
            array[i] = i;
        }
        emit List(array);
        // return array;
    }

    // LoopInput(2);

}