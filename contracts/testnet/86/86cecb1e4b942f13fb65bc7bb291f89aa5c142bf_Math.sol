/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

//SPDX-License-Identifier: MIT
pragma solidity =0.8.11;

contract Math {

    function Addition(int firstNumber, int secondNumber) public pure returns (int){
        int add = firstNumber + secondNumber;
        return add;
    }

    function Subtraction(int firstNumber, int secondNumber) public pure returns (int){
        int subtraction = firstNumber - secondNumber;
        return subtraction;
    }

    function Multiplication(int firstNumber, int secondNumber) public pure returns (int){
        int multiplication = firstNumber * secondNumber;
        return multiplication;
    }

    function Division(int firstNumber, int secondNumber) public pure returns (int){
        int division = firstNumber / secondNumber;
        return division;
    }

    function Power(uint128 firstNumber, uint128 secondNumber) public pure returns (uint128){
        uint128 power = firstNumber ** secondNumber;
        return power;
    }

    function Modulo(int firstNumber, int secondNumber) public pure returns(int){
        int modulo = firstNumber % secondNumber;
        return modulo;
    }

}