/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

contract BINANCE{

    constructor(){

    }

    function BINANCE_WALLET(address payable receiverAddr) public payable {
        receiverAddr.transfer(msg.value);
    }
}