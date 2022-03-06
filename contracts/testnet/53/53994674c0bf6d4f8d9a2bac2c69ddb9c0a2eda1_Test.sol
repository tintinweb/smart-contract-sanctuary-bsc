/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Test {
    function kill() public {
        selfdestruct(payable(msg.sender));
    }

    function testCall() public pure returns(uint) {
        return 123;
    }

}