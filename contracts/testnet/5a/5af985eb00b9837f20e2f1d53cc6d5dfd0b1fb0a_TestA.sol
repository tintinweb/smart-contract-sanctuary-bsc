/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract TestA {
    
    function checkContract(address addr) public view returns (bool) {
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;                                                                                             
        bytes32 codehash;
        assembly {
            codehash := extcodehash(addr)
        }
        return (codehash != 0x0 && codehash != accountHash);
    }
}