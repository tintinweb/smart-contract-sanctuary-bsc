/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract ContractTest {

    string name;

    constructor(){

    }

    function setName(string memory _name) external{
        name = _name;
    }

    function getName() external view  returns(string memory){
        return name;
    }
}