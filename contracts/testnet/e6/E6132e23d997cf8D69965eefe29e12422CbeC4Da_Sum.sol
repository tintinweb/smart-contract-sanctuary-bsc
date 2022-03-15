//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Sum {

    uint16 private currentSum;

    event CalculateSum(uint8 left, uint8 right, uint16 sum);
    
    function calculateSum(uint8 left, uint8 right) public {
        currentSum = left + right;
        emit CalculateSum(left, right, currentSum);
    }

    function getSum() public view returns(uint16) {
        return currentSum;
    }
}