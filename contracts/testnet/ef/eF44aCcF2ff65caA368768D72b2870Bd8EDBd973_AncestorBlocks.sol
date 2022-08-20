/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract AncestorBlocks {
    function ancestorBlocks(uint256 depth)
        public
        view
        returns (uint256 block_number, bytes32[] memory blocks)
    {
        block_number = block.number;
        blocks = new bytes32[](depth);
        for (uint256 i = 1; i <= depth; i++) {
            blocks[i - 1] = blockhash(block_number - i);
        }
    }
}