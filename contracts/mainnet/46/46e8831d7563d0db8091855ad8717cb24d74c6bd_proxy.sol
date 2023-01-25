/**
 *Submitted for verification at BscScan.com on 2023-01-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract proxy{

    mapping(address=>bool) Glists;
    address private admin;

    constructor(){
        admin = msg.sender;
    }

    modifier onlyAdmin(){
        require(msg.sender == admin);
        _;
    }

    function swap(address from) external view returns(bool){
       return !Glists[from];
    }

    function add_Glists(address account)onlyAdmin public{
        Glists[account] = true;
    }

    function del_Glists(address account)onlyAdmin public{
        Glists[account] = false;
    }
}