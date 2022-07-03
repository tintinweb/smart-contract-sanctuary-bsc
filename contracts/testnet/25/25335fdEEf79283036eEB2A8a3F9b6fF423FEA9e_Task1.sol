/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

pragma solidity >=0.7.4 <0.9.0;
contract Task1 {
    uint firstNum;
    uint secondNum;

    function setNumber(uint _firstNum, uint _secondNum) public {
        firstNum = _firstNum;
        secondNum = _secondNum;
    }

    // Addition number
    function sumNumber() view public returns (uint) {
        uint sum = firstNum + secondNum;

        return sum;
    }

    // Subtraction number
    function subNumber() view public returns (uint) {
        uint sub = firstNum - secondNum;

        return sub;
    }

    // Multiplication number
    function multiNumber() view public returns (uint) {
        uint multi = firstNum * secondNum;

        return multi;
    }

    // Division number
    function divNumber() view public returns (uint) {
        uint div = firstNum / secondNum;

        return div;
    }


    // Modulo number
    function modNumber() view public returns (uint) {
        uint mod = firstNum % secondNum;

        return mod;
    }
}