/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Campaign {
    function test(uint256 _revealBlockNumber) public view returns(uint256 rand) {
        uint256 rand = uint256(
            keccak256(
                abi.encodePacked(blockhash(_revealBlockNumber))
            )
        );
        return rand;
    }
}