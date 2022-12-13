// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract RandomOracle {

    uint256 nonce = 3131075268430910863;

    function getRandom() external returns (uint256) {

        nonce = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, msg.sender, nonce, tx.origin)
            )
        );
        return  nonce;
    }
}