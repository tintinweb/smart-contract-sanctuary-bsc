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

    /**
     * @dev Store value in variable
     * @param stoneAdd value to store
     */
    function store(address add, uint256 stoneAdd) public {
        Stone[add] += stoneAdd;
    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve(address add) public view returns (uint256){
        return Stone[add];
    }
}