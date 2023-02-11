/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.4.4;

contract PaybleKeyword{


    function deposit() public payable{

        address Acount2 = 0x09bbb146B200Df271dF6167FD05A89E3012cCcCD;
        Acount2.transfer(msg.value);
    }

    function getAccount2Balance() public constant returns (uint){

        address Acount2 = 0x09bbb146B200Df271dF6167FD05A89E3012cCcCD;

        return Acount2.balance;
    }

    function getOwnerBalance() public constant returns (uint){

        address Owner = msg.sender;
        return Owner.balance;
    }




}