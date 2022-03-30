/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract LogicOne {
    uint256 public param;

    event GetValEvent(address sender);

    constructor(uint256 params) {
        param = params;
    }

    function setVal(uint256 _val) public payable returns (bool) {
        emit GetValEvent(msg.sender);
        param += _val;
        return true;
    }
}