/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

// File: Fibonacci_flat.sol


// File: contracts/Fibonacci.sol


pragma solidity 0.8.12;

contract Fibonacci {
  
  function getFibonacciNumber(uint index) external pure returns (uint) {
    uint n1 = 0;
    uint n2 = 1;
    uint nextNumber;
        
    for (uint i =1; i < index; i++) {
        nextNumber = n1 + n2;
        n1 = n2;
        n2 = nextNumber;
    }
        
    return n2;
  }
}