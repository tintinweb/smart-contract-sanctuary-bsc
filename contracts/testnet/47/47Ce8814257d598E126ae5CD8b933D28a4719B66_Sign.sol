/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Sign {
    uint public a ;
    function sig()public pure{
        assembly{
           mstore(0x20,0x15)
        }
    }


}