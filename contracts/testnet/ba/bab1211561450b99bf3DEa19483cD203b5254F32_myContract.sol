// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
contract myContract {
    uint public vaal;

    // constructor(uint _val) {
    //     val = _val;
    // }

    function initialize(uint _val) external {
        vaal = _val;
    }
}