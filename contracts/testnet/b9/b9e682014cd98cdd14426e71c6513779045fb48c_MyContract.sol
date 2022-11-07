/**
 *Submitted for verification at BscScan.com on 2022-11-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface ERC721{
    function balanceOf(address owner) external view returns (uint256 balance);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}

contract MyContract{
    uint storedData;

    function set(uint x) public {
        storedData = x;
    }

    function getBalance(address _as, address _bas) public view returns (uint256) {
        return ERC721(_as).balanceOf(_bas);
    }

    function getTokenId(address _contract, address _owner, uint256 _index) public view returns (uint256) {
        return ERC721(_contract).tokenOfOwnerByIndex(_owner, _index);
    }
}