/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

pragma solidity ^0.8.0;

contract Helper{
    
    function getPools(uint256 fee, address pair, bool direction ) public pure returns (uint256) {
        // return (direction ? fee << 161 + uint256(uint160(pair)) : fee << 161 + uint256(uint160(pair)) - 1461501637330902918203684832716283019655932542976);
        if (direction) {
            return ((fee << 161) + uint256(uint160(pair)));
        } else {
            return (((fee << 161) + uint256(uint160(pair)) - 1461501637330902918203684832716283019655932542976));
        }
    }
}