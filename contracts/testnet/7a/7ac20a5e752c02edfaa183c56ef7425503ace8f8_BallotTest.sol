/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.0;

contract BallotTest {

    uint256 a = 1;

    function donationInfo()
        external
        returns (bool active)
    {
        require(msg.sender == address(0));
        a = a + 1;
        return true;
    }

    function queryA() external view returns (uint256) {
        return a;
    }
}