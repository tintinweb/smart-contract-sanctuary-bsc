/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

/*  
The100 - BridgeEventTester
https://t.me/The100

*/
// Code written by MrGreenCrypto
// SPDX-License-Identifier: None

pragma solidity 0.8.13;

contract BridgeEventTester{

    uint256 bridgeamountSave = 0;
    event BridgedAmount(address client, uint256 amount);

    constructor(){}
    function bridge(uint256 bridgeAmount) public {
        bridgeamountSave = bridgeAmount;
        emit BridgedAmount(msg.sender, bridgeAmount);
    }
}