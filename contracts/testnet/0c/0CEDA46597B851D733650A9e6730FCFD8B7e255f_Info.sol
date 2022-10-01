/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;



contract Info {


    uint age;
    string name;

    function setInfo(string memory _name, uint _age) public {
        name = _name;
        age = _age;
    }

    function getInfo() public view returns(string memory, uint){
        return (name, age);
    }

}