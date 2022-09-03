/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

contract Callee {

    uint public lastResult;
    uint public opCount = 0;
    event operation (address sender, uint parama, uint paramb);

    function add(uint a, uint b) public returns(uint){
        uint c = a + b;
        lastResult = c;
        opCount ++;
        emit operation(msg.sender, a,b);
        return c;
    }

}