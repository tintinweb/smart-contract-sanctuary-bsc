/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

contract MyContract{
    uint private data;
    function setData(uint _data) public{
        data = _data;
    }
    
    function getData() public view returns(uint){
        return data;
    }
}