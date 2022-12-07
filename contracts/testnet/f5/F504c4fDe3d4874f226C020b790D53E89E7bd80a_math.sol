/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// File: V2BNB/math.sol


pragma solidity ^0.8.17;

contract math {

    mapping(address => mapping(uint => bytes32[])) private ticketsforuser;

    function hashNums(uint256[6][] calldata tickets) public pure returns(uint256[] memory numbers) {

        for (uint i = 0; i < tickets.length; i++) {
            for (uint k = 0; k < 6; k++) {
                numbers[i] = tickets[k][i];
            }
            
        }

        return numbers;





        // 1. takes an array of arrays, nested arrays max l = 6, base array max l = 100 (0-99)
        // 2. for each nested array, sort the numbers from smallest to largest, and make sure there are no duplicates
        // 3. make sure each number is from 01 - 48
        // 4. concatenate 6 nums into one, then hash it,
        // 5. store that hash in the mapping, iteratively for each memeber of the array







        //uint[6] memory nums = [num1, num2, num3, num4, num5, num6];



    }
            

        
    
}