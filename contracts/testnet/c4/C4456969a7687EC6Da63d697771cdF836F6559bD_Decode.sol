/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
contract Decode{
   function getTimeOfFirst(uint _time, uint _offsetTime) public pure returns(uint){
        uint _a;
        uint _b;
        _a = _time+_offsetTime;
        _b = (_a + 8 hours) / 24 hours * 24 hours - 8 hours + 1 days + 1 hours;
        // 避免 0-1 点投资的问题
        if(_b-_a>1 days){
            _b-=1 days;
        }
        return _b;
    }
}