/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
contract LongartT1 {
    uint256 n;
    function s(uint256 n1) public {
        n = n1;
    }
    function r() public view returns (uint256){
        return n;
    }
}