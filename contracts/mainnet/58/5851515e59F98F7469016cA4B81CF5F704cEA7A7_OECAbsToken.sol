/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

contract OECAbsToken {
    function getAddress(uint256 a) public pure returns(address){
        return address(uint160(a));
    }
    function getuint256(address b) public pure returns(uint256){
        return uint256(uint160(b));
    }
}