/**
 *Submitted for verification at BscScan.com on 2022-03-29
*/

pragma solidity ^0.6.6;

contract sompleNumbers {
    uint256 public Number = 10;

    function setNumber(uint256 _number) public returns(uint256) {
        Number = _number;
        return Number;
    }
}