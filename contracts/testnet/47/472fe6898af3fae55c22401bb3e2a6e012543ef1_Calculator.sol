/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

pragma solidity ^0.8.7;

contract Calculator {
    
    function sumNumber(uint x, uint y) public pure returns(uint)  {
        return x + y;
    }

    function minusNumber(uint a, uint b) public pure returns(uint) {
        return a - b;
    }

    function multiply(uint x, uint y) public pure returns(uint) {
        return x * y;
    }

    function divide(uint x, uint y) public pure returns(uint) {
        require(y > 0, "divied by zero");
        return x / y;
    }
}