/**
 *Submitted for verification at BscScan.com on 2022-09-22
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface FlashQuery {
    function emitEvent() external;
}

contract FlashQueryProxy {
    function proxyEvent()
        external
    {
        FlashQuery(0x7E6711379F2Ae28350fEe883f2343F6835614515).emitEvent();
    }
}