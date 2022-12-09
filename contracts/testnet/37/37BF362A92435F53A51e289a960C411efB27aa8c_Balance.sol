/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Balance{
    address public owner;
     constructor(){
        owner = msg.sender;
    }
    
    receive() payable external {
        /*
        payable(owner).transfer(address(this).balance);
        }*/

    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function getBalance() external view onlyOwner returns (uint256) {
        return address(this).balance;
    }

}