// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract MockBct {
    mapping(address => uint256) public durable;

    constructor() {}

    function setUser(address account, uint amount) external {
        durable[account] = amount;
    }
}