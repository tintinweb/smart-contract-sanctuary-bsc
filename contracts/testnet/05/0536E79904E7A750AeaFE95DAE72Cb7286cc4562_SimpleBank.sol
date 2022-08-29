/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/

// SPDX-License-Identifier: GPL-3.0
// működik
pragma solidity ^0.8.4;

contract SimpleBank {
    uint public transactions;
    uint public sendback;
    mapping(address=>uint) balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        transactions++;
        sendback = (msg.value / 2);
       (bool tmpSuccess,) = payable(msg.sender).call{value: sendback, gas: 30000}("");
        tmpSuccess = false;
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