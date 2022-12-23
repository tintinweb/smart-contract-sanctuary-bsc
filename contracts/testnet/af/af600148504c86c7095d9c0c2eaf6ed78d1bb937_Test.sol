/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Test {
    event Incremented(uint256 indexed newValue);

    uint256 public counter;

    function increment(uint256 amount) public {
        counter += amount;
        emit Incremented(counter);
    }
}