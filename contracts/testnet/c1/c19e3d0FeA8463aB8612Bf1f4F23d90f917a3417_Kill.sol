/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title Ballot
 * @dev Implements voting process along with vote delegation
 */
contract Kill {
    constructor() payable { }

    function kill() external {
        selfdestruct(payable(msg.sender));
    }
}

contract Helper {
    function kill(Kill _test) external {
        _test.kill();
    }

    function balance() external view returns(uint) {
        return address(this).balance;
    }
}