/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IVE {
    function balanceOf(address account) external view returns (uint256);
    function tokenOfOwnerByIndex(address account, uint256 tokenIndex) external view returns (uint256);
    function balanceOfNFT(uint256 tokenId) external view returns (uint256);
}

contract ve_query {
    address public ve;
    uint public maxQueryNumber = 10;

    constructor (address ve_) public {
        ve = ve_;
    }

    function powerOf(address owner) external view returns (uint256) {
        uint256 cnt = IVE(ve).balanceOf(owner);
        if (cnt > maxQueryNumber) {
            cnt = maxQueryNumber;
        }
        uint256 power;
        for (uint i = 0; i < cnt; i++) {
            uint256 tokenId = IVE(ve).tokenOfOwnerByIndex(owner, i);
            power += IVE(ve).balanceOfNFT(tokenId);
        }
        return power;
    }
}