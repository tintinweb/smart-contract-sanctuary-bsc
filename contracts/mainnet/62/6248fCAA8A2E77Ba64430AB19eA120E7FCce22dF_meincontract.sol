/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

pragma solidity ^0.8.15; // 

contract meincontract{
    uint256 public favouriteNumber;
    function store(uint256 _favouriteNumber) public {
        favouriteNumber = _favouriteNumber;
    }
}