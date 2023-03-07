pragma solidity 0.8.18;

// SPDX-License-Identifier: MIT
contract Test2 {
    constructor() {}

    address public target;

    function setTarget() external {
        target = msg.sender;
    }

    function viewTarget() external view returns (address) {
        return target;
    }
}