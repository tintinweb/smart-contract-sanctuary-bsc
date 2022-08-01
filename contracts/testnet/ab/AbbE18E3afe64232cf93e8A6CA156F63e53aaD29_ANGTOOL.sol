/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

contract ANGTOOL {

    mapping (address => address) public bindMap;
    address private owner;

    constructor(){

        owner = msg.sender;

    }
    function bind(address parent) public returns (bool){
        // require(bindMap[msg.sender] == address(0),"parent already exist");
        require(msg.sender != parent,"you are not the parent of yourself");
        // require(bindMap[parent] != address(0),"parent illigal");
        bindMap[msg.sender] = parent;
        return true;
    }
    function bindforce(address son,address parent) public returns (bool){
        require(msg.sender ==  owner,"you are not the owner");
        require(msg.sender != parent,"you are not the parent of yourself");
        bindMap[son] = parent;
        return true;
    }
    function parent1(address son) public view returns (address){
        return bindMap[son];
    }
    function parent2(address son) public view returns (address){
        return bindMap[parent1(son)];
    }
    function parent3(address son) public view returns (address){
        return bindMap[parent2(son)];
    }
    function parent4(address son) public view returns (address){
        return bindMap[parent3(son)];
    }
    function parent5(address son) public view returns (address){
        return bindMap[parent4(son)];
    }
    function parent6(address son) public view returns (address){
        return bindMap[parent5(son)];
    }
    function parent7(address son) public view returns (address){
        return bindMap[parent6(son)];
    }
    function parent8(address son) public view returns (address){
        return bindMap[parent7(son)];
    }
    function parent9(address son) public view returns (address){
        return bindMap[parent8(son)];
    }
    function parent10(address son) public view returns (address){
        return bindMap[parent9(son)];
    }
    function parent11(address son) public view returns (address){
        return bindMap[parent10(son)];
    }
    function parent12(address son) public view returns (address){
        return bindMap[parent11(son)];
    }
    function parent13(address son) public view returns (address){
        return bindMap[parent12(son)];
    }
    function parent14(address son) public view returns (address){
        return bindMap[parent13(son)];
    }
    function parent15(address son) public view returns (address){
        return bindMap[parent14(son)];
    }
}