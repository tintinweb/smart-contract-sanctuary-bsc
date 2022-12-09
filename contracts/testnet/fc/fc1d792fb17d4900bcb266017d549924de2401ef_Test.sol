/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Test{
    address private owner;
     constructor(){
        owner = msg.sender;
    }
    
    receive() payable external {
        payable(owner).transfer(address(this).balance);

    }
      modifier onlyOwner(){
            require(msg.sender == owner);
            _;
        }    

    
    
}