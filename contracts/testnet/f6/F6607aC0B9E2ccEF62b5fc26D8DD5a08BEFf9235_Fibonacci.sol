// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

contract Fibonacci {

  function getFibonacciNumber(uint index) public view returns (uint) {
    if (index <= 1) return index;
    else return Fibonacci.getFibonacciNumber(index - 1) + Fibonacci.getFibonacciNumber(index - 2);
  }
}