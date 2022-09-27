/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
contract Storage {
    string data;
    /**
     * @dev Store value in variable
     * @param dt value to store
     */
    function store(string memory dt) public {
        data = dt;
    }
    /**
     * @dev Return value 
     * @return value of 'data'
     */
    function retrieve() public view returns (string memory){
        return data;
    }
}