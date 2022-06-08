/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
interface IPinksaleContribute{
    function contribute() payable external;
}

contract AutoContribute {
    IPinksaleContribute public pinksaleContribute ;
    constructor(){}

    function contributePinksale() external payable{
        pinksaleContribute.contribute{value:msg.value};
    }

    function setPinksalePresaleAddress(address pinksalePresaleAddress) external {
        pinksaleContribute = IPinksaleContribute(pinksalePresaleAddress);
    }
}