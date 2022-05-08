/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract One {

    struct _number {
        uint _num;
    }

    _number[] public Number;

    function add(uint num_) public {
        Number.push(_number({
            _num: num_
        }));
    }
    
}