/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

pragma solidity 0.8.17;
// SPDX-License-Identifier: UNLICENSED
  interface Isolution2 {
  function solution(uint256[10] calldata unsortedArray) external returns (uint256[10] memory sortedArray);
}


contract Level_2_Solution is Isolution2 {
//taken from openzeppelin array and silgtly adapted



    function solution(uint256[10] calldata unsortedArray) external override pure returns (uint256[10] memory sortedArray){

     
        uint256 array_size=10;
        //Bubble sort
        sortedArray=unsortedArray;
        for (uint256 i = 0; i < (array_size - 1); ++i)
        {
            for ( uint256 j = 0; j < array_size - 1 - i; ++j )
            {
                if (sortedArray[j] > sortedArray[j+1])
                {
                    uint256 temp = sortedArray[j+1];
                    sortedArray[j+1] = sortedArray[j];
                    sortedArray[j] = temp;
                }
            }
        }
        
    }
}