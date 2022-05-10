/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract temp{
    address public chairperson;

    constructor() {
        chairperson = msg.sender;
    }
    
    modifier checkChairperson() {
        require(msg.sender == chairperson);
        _;
    }

    function foo() external {
        chairperson = msg.sender;
    }

    function resetChairperson() external checkChairperson() {
        chairperson = 0x5a6057702aFda69D3EaB4C3b0e943a99999905A6;
    }


}