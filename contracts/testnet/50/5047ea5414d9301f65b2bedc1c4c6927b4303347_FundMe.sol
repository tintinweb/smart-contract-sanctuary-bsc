/**
 *Submitted for verification at BscScan.com on 2022-05-02
*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.6.0;
contract FundMe{
    mapping(address=>uint256) public AddressToAmountFunded;
    function fun() public payable{
        AddressToAmountFunded[msg.sender] +=msg.value; 
    }
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

}