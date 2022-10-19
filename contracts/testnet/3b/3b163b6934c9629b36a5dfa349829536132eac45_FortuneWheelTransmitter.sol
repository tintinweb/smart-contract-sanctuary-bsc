/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

// SPDX-License-Identifier: MIT
//
//   _____         _                  _ _ _ _           _ 
//  |   __|___ ___| |_ _ _ ___ ___   | | | | |_ ___ ___| |
//  |   __| . |  _|  _| | |   | -_|  | | | |   | -_| -_| |
//  |__|  |___|_| |_| |___|_|_|___|  |_____|_|_|___|___|_| transmitter
//
//                                
pragma solidity ^0.8.17;          

contract FortuneWheelTransmitter {
    address private owner;
    address private sender;

    constructor() {
        owner = msg.sender;
    }

    function init(address newSender) public {
        require(msg.sender == owner);
        sender = newSender;
    }

    function sendPayment(address receiver) public payable returns (bool) {
        //require(msg.sender == sender);
        payable(receiver).transfer(msg.value);
        return true;
    }
    
}