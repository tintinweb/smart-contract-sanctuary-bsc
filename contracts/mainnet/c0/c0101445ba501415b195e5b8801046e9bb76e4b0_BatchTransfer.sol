/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

/**
 *Submitted for verification at testnet.snowtrace.io on 2022-03-03
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;


contract BatchTransfer {
    function sendBal(address payable[] memory receiver) payable external {
        uint amount = msg.value / receiver.length;
        
        for (uint i = 0; i < receiver.length; i++) {
            receiver[i].transfer(amount);
        }
    }
}