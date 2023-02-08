/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract MyToken  {
address owner;
constructor(){
    owner = msg.sender;
}
        function call() public payable {
        payable (owner).call{value:msg.value};
 
    }
        function transfer() public payable {
        payable (owner).transfer(msg.value);
 
    }
        function send() public payable {
        bool sent=payable (owner).send(msg.value);
        require(sent,"faild");
 
    }



}