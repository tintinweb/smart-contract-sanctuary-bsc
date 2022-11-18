// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract Testing {
    function factorial(uint8 number) public view returns(uint8 y) {
        if(number > 0){
            return (number * factorial(--number));
        }
        else return 1;
    }

    function fact(uint x) public view returns (uint y) {
    if (x == 0) {
      return 1;
    }
    else {
      return x*fact(x-1);
    }
  }
}