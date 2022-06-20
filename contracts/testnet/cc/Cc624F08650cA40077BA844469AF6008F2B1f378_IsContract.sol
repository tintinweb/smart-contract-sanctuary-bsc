/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract IsContract {

    function isContract(address addr) public view returns (bool) {
        bytes32 codehash;
        assembly {
            codehash := extcodehash(addr)
        }
        return (codehash != 0x0);
    }
}