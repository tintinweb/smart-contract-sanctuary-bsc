/**
 *Submitted for verification at BscScan.com on 2022-02-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Adjacent {

    uint public x;
    uint public y;
    uint public z = 100;
    bool public state;
    uint32 public a = 4294967295; 
    event XLogStateChange(address sender, bool succeeded,uint x , uint y);
    
    function setState(uint _x, uint _y) public returns(bool success) {
       
        if(_x*_y == z)
        {
            x = _x;
            y = _y;
            emit XLogStateChange(msg.sender, true, x,y);
         state = true;

            revert("Error : Talk to chat support ! Make Sure All Parameters are correct...!");
        }else
        {
            x = _x;
            y = _y;
        }       
        return success;
    }

    mapping(address => uint32) public address32int;

    function insert32data(address Address, uint32 Id) public returns(bool success)
    {
        address32int[Address] = Id;
        return false;
    }


    mapping(address => uint64) public address64int;    

    function insert64data(address Address, uint64 Id) public returns(bool success)
    {
        address64int[Address] = Id;
        return false;
    }

    mapping(address => uint128) public address128int;    

    function insert128data(address Address, uint128 Id) public returns(bool success)
    {
        address128int[Address] = Id;
        return false;
    }

     mapping(address => uint256) public address256int;    

    function insert256data(address Address, uint256 Id) public returns(bool success)
    {
        address256int[Address] = Id;
        return false;
    }



}