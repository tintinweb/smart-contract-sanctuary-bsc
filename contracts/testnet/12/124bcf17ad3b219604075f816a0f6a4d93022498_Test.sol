/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.14;
contract Test {
    uint a;
    address d = 0xdCad3a6d3569DF655070DEd06cb7A1b2Ccd1D3AF;

    constructor(uint testInt)  { a = testInt;}

    event Event(uint indexed b, bytes32 c);

    event Event2(uint indexed b, bytes32 c);

    function foo(uint b, bytes32 c) public returns(address) {
        emit Event(b, c);
        return d;
    }
}