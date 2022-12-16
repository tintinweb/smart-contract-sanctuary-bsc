/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.4;
contract DemoServer{
    function Deposit() public payable{

    }
    function getBalance() public view returns(uint){
        return (address(this).balance);
    }
}