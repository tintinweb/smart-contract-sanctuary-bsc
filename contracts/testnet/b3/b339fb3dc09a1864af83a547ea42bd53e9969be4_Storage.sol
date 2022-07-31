/**
 *Submitted for verification at BscScan.com on 2022-07-30
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
contract Storage {

    uint32[][] numbers;


    function store(uint32[] memory nums,uint  index) public {
        numbers[index] = nums;
    }

    
    function retrieve(uint index) public view returns (uint32[] memory){
        return numbers[index];
    }

    function checkIterations(uint fromIndex ,uint toIndex) public view returns(uint)
    {
       uint sum = 0;        
        for(uint i = fromIndex; i <= toIndex;i++)
        {
            sum = sum 
            + numbers[i][0];
        }
        return sum;

    }
}