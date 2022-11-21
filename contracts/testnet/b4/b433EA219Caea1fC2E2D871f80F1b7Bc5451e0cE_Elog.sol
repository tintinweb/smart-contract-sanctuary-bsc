/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;


contract Elog {
    event TestInputLogA(uint256 a);
    event TestInputLogB(uint256 b);
    event TestInputLogC(uint256 c);

    function CallFunc() public {
        emit TestInputLogA(0);
        emit TestInputLogB(1);
    }

    function CallFuncWithArgs(uint256 c) public {
        emit TestInputLogC(c);
    }
}