/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FlashQuery {
    event Transfer(address indexed from, uint value);

    function emitEvent()
        external
    {
        emit Transfer(0xA58b3E8AaB312e16EF48f65ceB30C6D538575D31, 100);
    }
}