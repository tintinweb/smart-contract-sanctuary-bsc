/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

contract SimpleStorageContract {
    uint private _value;

    function setValue(uint value_ ) public {
        _value = value_;
    }

    function getValue()  public view returns(uint value) {
        value = _value;
    }
}