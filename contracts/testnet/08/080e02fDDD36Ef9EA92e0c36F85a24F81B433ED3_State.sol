/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// File: testcontract.sol


pragma solidity 0.8.10;
contract State{
    uint256 _totalValue;

    function increment(uint256 _newValue) external {
        _totalValue += _newValue;
        emit Incremented(_totalValue,_newValue);
    }

    event Incremented (uint256 _totalValue, uint256 _newValue);
}