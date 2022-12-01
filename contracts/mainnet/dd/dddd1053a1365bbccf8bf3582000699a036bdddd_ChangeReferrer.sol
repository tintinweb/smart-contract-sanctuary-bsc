/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

/*
 * ARK Change Referrer
 * 
 * SPDX-License-Identifier: None
 */

pragma solidity 0.8.17;

contract ChangeReferrer {
    event ChangeRegistered(address investor, address referrer);
    constructor() {}
    function setReferrer(address referrer) external {emit ChangeRegistered(msg.sender, referrer);}
}