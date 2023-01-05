/**
 *Submitted for verification at BscScan.com on 2023-01-04
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Unknow {

    event timestampEvt(
        uint time,
        bool b
    );

    function judge(uint t) public  returns (bool) {    
        emit timestampEvt(block.timestamp, block.timestamp > t);
        return block.timestamp > t;
    }

    function timestamp() public view returns (uint) {
        uint time = block.timestamp;
        return time;
    }
}