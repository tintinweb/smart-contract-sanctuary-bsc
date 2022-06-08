/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
interface IPinksaleContribute{
    function contribute() payable external;
}

contract AutoContribute {
    IPinksaleContribute public pinksaleContribute;
    address pinksaleAddress;
    constructor(){}

    function contributePinksale() external payable{
        (bool success, ) = payable(pinksaleAddress).call{value:msg.value}(abi.encodeWithSignature('contribute'));
        require(success, "not called distribute");
    }

    function setPinksalePresaleAddress(address pinksalePresaleAddress) external {
        pinksaleAddress = pinksalePresaleAddress;
        pinksaleContribute = IPinksaleContribute(pinksalePresaleAddress);
    }
}