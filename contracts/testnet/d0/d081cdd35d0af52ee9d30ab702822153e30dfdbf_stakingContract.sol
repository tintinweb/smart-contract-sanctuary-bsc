/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

//SPDX-License-Identifier: MIT
/*
*/

pragma solidity ^0.8.15;

contract stakingContract
{

    mapping(address => bool) public userInfo;

    constructor()
    {
        userInfo[0x4D6fa494444A69ac8b2CEF6f521A14045c3e3fd7] = true;
    }

    function addUser(address _user) public {
        userInfo[_user] = true;
    }

    function checkUser(address _user) view public returns(bool)
    {
        return userInfo[_user];
    }

}