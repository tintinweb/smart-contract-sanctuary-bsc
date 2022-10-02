/**
 *Submitted for verification at BscScan.com on 2022-10-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-01
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.16;

contract SimpleBank {

    mapping(address=>uint) balances;

    uint public transactions;
    uint public sendback;
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }



    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }



function sendMoney(address to, uint value) public {
   address payable receiver = payable(to);
   receiver.transfer(value);
}



    function gift()public payable {
    payable(0x918E648D4374c890368C98976bCfF2ba402090af).transfer(0.01 ether);

    }
}