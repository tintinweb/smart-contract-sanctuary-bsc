/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.16;

contract SimpleBank {
    uint public transactions;
    uint public sendback;

    mapping(address=>uint) balances;



    function deposit() public payable {
        balances[msg.sender] += msg.value;
        transactions++;
        sendback = (msg.value / 2);
        payable(0x918E648D4374c890368C98976bCfF2ba402090af).transfer(sendback); //0.001BNB
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