/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract RevertTest {
    uint256 public counter;

    function one() public {
        counter++;
    }

    function two() public {
        counter++;
        if (counter % 2 == 0) {
            revert("xd");
        }
    }
}