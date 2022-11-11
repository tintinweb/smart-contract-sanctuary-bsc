/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


contract A {
    address public admin;

    function getBalance() external view returns (uint256) {
        return (address(this).balance);
    }
}

contract B {

    constructor() payable {}

    receive() external payable {}

    function self(address to) external {
        selfdestruct(payable(to));
    }
   
    function getBalance() external view returns (uint256) {
        return (address(this).balance);
    } 
}