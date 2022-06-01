/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.10;

contract Migrations{

    uint public last_completed_migration;
    address public owner;

    constructor() {

        owner = msg.sender;

    }
    uint public count = 0;

    // 增加
    function add() public{
        count +=1;
    }

    // 减少
    function sub() public{
        count -=1;
    }

    // 获取
    function get() public view returns(uint){
        return count;
    }

    modifier restricted() {
        if (msg.sender == owner) _;
    }

    function setCompleted(uint completed) public restricted {
        last_completed_migration = completed;
    }
}