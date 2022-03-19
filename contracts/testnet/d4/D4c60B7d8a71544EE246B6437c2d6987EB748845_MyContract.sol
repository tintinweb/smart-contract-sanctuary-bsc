/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract MyContract {

    string _name;
    uint _balance;

    constructor(
        string memory name,
        uint balance
    ) {
        require(balance > 0, "balance greater zero (money > 0)");
        _name = name;
        _balance = balance;
    }

    function getBalance() public view returns (uint balance) {
        return _balance;
    }

    function deposite(uint amount) public {
        _balance += amount;
    }

}