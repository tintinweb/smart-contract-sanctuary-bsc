/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

contract ChainOxProxy {
    event Swap(uint256 address_bep20, uint256 address_native, uint256 amount);
    function swap(uint256 address_bep20, uint256 address_native, uint256 amount) public {
        emit Swap(address_bep20, address_native, amount);
    }
}