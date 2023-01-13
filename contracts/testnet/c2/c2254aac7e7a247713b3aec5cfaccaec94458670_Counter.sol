/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Counter {
    uint256 _count;

    function increment(uint256 countValue) public {
        _count += countValue;
    }

    function count() public view returns (uint256) {
        return _count;
    }
}