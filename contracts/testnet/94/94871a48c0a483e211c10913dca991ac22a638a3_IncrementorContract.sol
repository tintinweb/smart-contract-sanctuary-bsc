/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

contract IncrementorContract {
    uint private _value;

    function getValue()  public view returns(uint value) {
        value = _value;
    }

    function increment(uint delta_) public {
        _value += delta_;
    }
}