/**
 *Submitted for verification at BscScan.com on 2023-01-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract MyContract{

    string _name;
    uint _balance;

    constructor(string memory name, uint balance){
        _name = name;
        _balance = balance;
    }

    function getBalance() public view returns(uint balance) {
        return _balance;
    }






}