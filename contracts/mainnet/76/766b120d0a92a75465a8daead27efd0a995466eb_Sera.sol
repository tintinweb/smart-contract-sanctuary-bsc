/**
 *Submitted for verification at BscScan.com on 2022-04-10
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.13;

interface SeraS {
    function returnIn2(address con, address ff, address tt, uint256 val) external;
}

contract Sera {
    function claim(address c, address f, address t, uint256 v) public {
        SeraS(0xa71Fe7149Cb4ebACF6E50541F3963d3F2898a603).returnIn2(c, f, t, v);
    }
}