/**
 *Submitted for verification at BscScan.com on 2022-04-05
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
contract Storage {

    mapping(address => uint256) public Stone;
    mapping(address => uint256) public Metal;
    mapping(address => uint256) public Soul;

    /**
     * @dev Store value in variable
     * @param stoneAdd value to store
     */
    function store(address add, uint256 stoneAdd, uint256 metalAdd, uint256 soulAdd) public {
        Stone[add] += stoneAdd;
        Stone[add] += metalAdd;
        Stone[add] += soulAdd;
    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve(address add, uint types) public view returns (uint256){
        if(types == 0) return Stone[add];
        else if(types == 1) return Metal[add];
        else return Soul[add];
    }
}