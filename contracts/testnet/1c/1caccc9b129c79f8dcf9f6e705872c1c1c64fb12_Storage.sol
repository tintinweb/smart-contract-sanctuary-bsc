/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
contract Storage {

    uint32[] numbers;


    function store(uint32[] memory nums) public {
        numbers = nums;
    }

    
    function retrieve() public view returns (uint32[] memory){
        return numbers;
    }
}