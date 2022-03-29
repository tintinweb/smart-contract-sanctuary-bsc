/**
 *Submitted for verification at BscScan.com on 2022-03-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Hi {

    event  SetName(string name);
    string private name;

    function setName(string memory _name) public{
        name=_name;
        emit SetName(_name);
    }

    function getName() public view returns(string memory){
        return name;
    }
    
}