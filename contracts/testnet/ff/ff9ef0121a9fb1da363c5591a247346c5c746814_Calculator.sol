/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;
contract Calculator {
    uint public calculateResult;
    address public user;
    event Add(uint a, uint b);

    function add(uint a, uint b) public returns(uint) {
        calculateResult = a + b;
        assert(calculateResult >= a);
        emit Add(a, b);
        user = msg.sender;
        return calculateResult;
    }
}