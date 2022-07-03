/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.1;
contract MyContract {
    int public a;
    int public b;

    function setab(int _a, int _b) public {
        a = _a;
        b = _b;
    }
    
    function sum() public view returns(int) {
        return a + b;
    }

    function subtract() public view returns(int) {

        return a-b;
    }
    
    function multiple() public view returns(int) {
        return a * b;
    }
    
    function divide() public view returns(int) {
        return a / b;
    }

    function remainder() public view returns(int) {
        return a % b;
    }

}