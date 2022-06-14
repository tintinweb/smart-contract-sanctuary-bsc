//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BNBstore {
    address public owner;
    uint public balance;

    constructor() {
        owner = msg.sender;
        balance = 0;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    function sendBNB() public payable returns(bool){
        balance = balance + msg.value;
        return true;
    }

    function withdraw()public {
        require(balance > 1 ether,"Insufficient balance");
        payable(msg.sender).transfer(1 ether);
    }

    function destroy() public onlyOwner{
        selfdestruct(payable(owner));
    }
}