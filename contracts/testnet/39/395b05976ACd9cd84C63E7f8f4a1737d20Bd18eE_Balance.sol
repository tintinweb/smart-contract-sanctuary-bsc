/**
 * SPDX-License-Identifier: MIT
 */

pragma solidity ^0.8.13;
 
contract Balance {

    mapping(address => uint256) public _addresses;
    uint256 public _balance = 0;

    function setAddressValue(address _address, uint256 _value) external {
        _addresses[_address] = _value;
    }

    function increaseBalance(uint256 _value) external {
        _balance += _value;
    }

    function decreaseBalance(uint256 _value) external returns (bool){
        require(_balance != 0, "Balance is 0");
        require( _balance >= _value, "Not enough balance");
        _balance -= _value;
 
        return true;
    }

}