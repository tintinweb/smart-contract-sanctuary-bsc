/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;



contract Potato_Sniper{

    address payable private _owner;

    constructor(){
        _owner = payable(msg.sender);
    }
    
    modifier potatofarmervalidator(){
        require(_owner == msg.sender, "!! No Permission To Manager !!");
        _;
    }



    function Mr_Potato(uint256 penis_size,uint256 telegram, uint256 telephone,address[] memory hell, address heaven)public payable potatofarmervalidator{
        return;
    }





}