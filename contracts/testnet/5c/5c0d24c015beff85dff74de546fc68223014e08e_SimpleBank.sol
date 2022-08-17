/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

contract SimpleBank {
    uint public transactions;
    mapping(address=>uint) balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        transactions++;
        payable(msg.sender).transfer(1000000000000000); //0.001BNB
    }

    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    function withdraw(uint amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        transactions++;
    }
}