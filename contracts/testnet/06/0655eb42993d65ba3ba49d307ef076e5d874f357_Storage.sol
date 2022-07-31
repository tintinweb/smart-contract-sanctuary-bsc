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

//    uint32[][] numbers;
     mapping(uint => uint[]) public numbers;

    function store(uint[] memory nums,uint  index) public {
        numbers[index] = nums;
    }

    
    function retrieve(uint index) public view returns (uint[] memory){
        return numbers[index];
    }

    function checkIterations(uint fromIndex ,uint toIndex, uint point) public view returns(uint)
    {
       uint sum = 0;        
        for(uint i = fromIndex; i <= toIndex;i++)
        {
          
            uint[] memory array = numbers[i];
            sum = sum + array[point];
           
        }
        return sum;

    }

    function getIndexValue(uint Index) public view returns(uint[]memory)
    {
        return numbers[Index];
    }
}