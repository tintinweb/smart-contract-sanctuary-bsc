// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract LFWTest1 {
    uint id = 0;

    struct Cat {
        uint age;
        uint baby;
    }

    mapping (uint => Cat) public idToCat;

    function modifyCat() public {
        Cat memory cet;
        cet.age = 1;
        cet.baby = 2;
        idToCat[id] = cet;
        id += 1;
    }
}