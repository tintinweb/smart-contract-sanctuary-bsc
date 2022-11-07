/**
 *Submitted for verification at BscScan.com on 2022-11-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface ERC721{
    function balanceOf(address owner) external view returns (uint256 balance);
}

contract MyContract{
    uint storedData;

    function set(uint x) public {
        storedData = x;
    }

    function get(address _as) public view returns (uint256) {
        return ERC721(_as).balanceOf(msg.sender);
    }
}