// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Receiver {
    address public owner;

    receive() external payable {
        require(msg.sender != address(0), "invalid address");
    }

    function initialize() external {
        require(msg.sender != address(0), "invalid address");
        owner = msg.sender;
    }
}