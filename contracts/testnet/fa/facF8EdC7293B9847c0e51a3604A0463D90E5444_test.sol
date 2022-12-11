/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

// File: contracts/test.sol


pragma solidity ^0.8.7;


contract test{

    mapping(uint => uint) maps;
    mapping(uint => uint) mapsx;


    function add(uint idx) public {
        maps[idx] += 1;
        mapsx[idx] = mapsx[idx] +1;
    }

    function getMap(uint idx) public view returns(uint){
        //require(maps[_wallet] == )
        return maps[idx];
    }
    function getMapx(uint idx) public view returns(uint){
        //require(maps[_wallet] == )
        return mapsx[idx];
    }
 
}