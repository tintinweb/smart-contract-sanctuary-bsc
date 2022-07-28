/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.5.0;

contract sometest {
    address public lastSender;
    uint public ret;

    function add(uint256 a,uint256 b) external {
        lastSender=msg.sender;
        ret=a+b;
    }

    function getRet() public view returns(uint) {
        return ret;
    }

    

}