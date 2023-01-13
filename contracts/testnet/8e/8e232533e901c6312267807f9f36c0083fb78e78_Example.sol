/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

//SPDX-License-Identifier: No-Idea!

pragma solidity 0.8.1;


contract Example  {
    uint _value;

    

    function getUint() public view returns (uint) {
        return _value;
    }

    function setUint(uint value) public {
        _value = value;
    }
}