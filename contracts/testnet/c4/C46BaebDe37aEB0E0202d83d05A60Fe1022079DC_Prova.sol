/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

pragma solidity ^0.8.2;


contract Prova {

    uint256 private _value;

    constructor() {}

    function getValue() external view returns (uint256 value) {
        return _value;
    }

    function addValue(uint256 value) external {
        _value = value;
    }
}