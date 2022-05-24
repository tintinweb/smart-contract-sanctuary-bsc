/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract KredictTestv2 {

    address payable owner;
    mapping(address => uint) balances;
    address payable[] recipients;
    constructor() {
        owner = payable(msg.sender);
    }
    function acceptAmount() external payable {
        if(msg.value < 100) {
            revert();
        }
        balances[msg.sender] += msg.value;
    }

    receive() external payable {
        balances[msg.sender] += msg.value;
    }

    function sendAmount(address payable recipient, uint amount) external {
        recipient.transfer(amount);
        // transfer 100 wei to recipient from smart contract
    }
    function balanceOf() external view returns(uint) {
        return address(this).balance;
    }
    function whoIsOwner() external view returns(address) {
        return owner;
    }
    function currentSender() external view returns(address) {
        return msg.sender;
    }
    function collectOwnableAmount() external {
        
        require(msg.sender == owner);
        owner.transfer(address(this).balance);
       
    }
}