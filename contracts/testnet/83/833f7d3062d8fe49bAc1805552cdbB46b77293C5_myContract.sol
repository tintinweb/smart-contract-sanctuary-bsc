// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
contract myContract {
    uint96 public age;

    function initialize(uint96 _age) external {
        age  = _age;
    }
}