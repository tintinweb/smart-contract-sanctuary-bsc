// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
contract myContract {
    uint public vil;

    // constructor(uint _val) {
    //     val = _val;
    // }

    function initialize(uint _val) external {
        vil = _val;
    }
}