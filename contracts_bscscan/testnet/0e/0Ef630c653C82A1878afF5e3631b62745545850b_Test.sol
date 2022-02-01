/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

//SPDX-License-Identifier: UNCLICENSE
pragma solidity 0.8.4;

contract Test {
    uint public a = 0;

    function update( uint _a) external returns(bool) {
        a = _a;
        return true;
    }
}