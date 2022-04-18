// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TestPayable {
    
    fallback() external payable { }
    
    receive() external payable { }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}