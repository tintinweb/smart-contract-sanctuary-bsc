/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract Base {
    uint public num;
    uint public resultNum;    // sum of 1 to num
    address public sender;

    function setVar(uint _num) public {
        num = _num;
        resultNum = 0;
        for(uint i=1;i<=_num;i++) {
            resultNum += i;
        }
        sender = msg.sender;
    }
}