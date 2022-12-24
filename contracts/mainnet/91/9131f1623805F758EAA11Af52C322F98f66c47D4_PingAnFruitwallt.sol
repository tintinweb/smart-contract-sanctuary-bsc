/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PingAnFruitwallt{
    address payable public owner;

    constructor(){
        owner = payable (msg.sender);
    }

    receive() external payable {}
    
    function withdraw(uint _amount) external {
        require(msg.sender == owner,"caller is not owner");
        
        payable(msg.sender).transfer(_amount);
    }
    function getBalance()external view returns (uint){
        return address(this).balance;
    }
}