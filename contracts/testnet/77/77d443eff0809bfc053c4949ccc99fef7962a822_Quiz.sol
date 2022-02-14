/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;


library Quiz{

    
    function getMutated() external pure returns (uint8[1] memory a, uint8[1] memory b){
        a = [1];
        b = a;
        b[0] = 5;   
    }

    
}