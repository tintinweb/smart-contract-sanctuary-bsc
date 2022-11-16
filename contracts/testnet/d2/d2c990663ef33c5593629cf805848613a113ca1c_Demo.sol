/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Demo {
    string message = "hello";
    uint public balance;

    function pay() external payable {
        balance += msg.value;
    }

    receive() external payable {
        //balance += msg.value;
    }

    function setMessage(string memory _newMessage) external returns(string memory){
        message = _newMessage;
        return message;
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function getMessage() external view returns(string memory) {
        return message;
    }

    function rate(uint amount) public pure returns(uint) {
        return amount*3;
    }
}