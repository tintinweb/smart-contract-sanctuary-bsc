/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract from {
   
    uint256 total_users = 0;

    struct User{
        uint256 id;       
    }

    mapping (address => User) public _User;

    function register() external returns (bool){
        total_users++;
        _User[msg.sender].id = total_users;
        return true;
    }
}