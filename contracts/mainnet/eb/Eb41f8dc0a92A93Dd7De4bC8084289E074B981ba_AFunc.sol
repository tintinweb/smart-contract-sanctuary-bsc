// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract AFunc {
    uint256 public a;
    address public delegate;
    address public owner = msg.sender;

    function addAnum() external {
        a++;
    }
}