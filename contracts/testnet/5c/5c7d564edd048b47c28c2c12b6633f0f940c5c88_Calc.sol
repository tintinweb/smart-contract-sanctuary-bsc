/**
 *Submitted for verification at BscScan.com on 2022-02-17
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Calc
 * @dev Store & retrieve value in a variable
 */

contract Calc {
    int private result;

    function add(int a, int b) public returns(int c) {
        result = a + b;
        c = result;
    }

    function min(int a, int b) public returns(int c) {
        result = a - b;
        c = result;
    }

    function mul(int a, int b) public returns(int c) {
        result = a * b;
        c = result;
    }

    function div(int a, int b) public returns(int c) {
        result = a / b;
        c = result;
    }

    function getResult() public view returns(int) {
        return result;
    }




}