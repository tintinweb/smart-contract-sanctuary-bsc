// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract EmitEvent {
    event Say(string message, uint256 traceid);

    function mintNFT(string memory message, uint256 traceid) external {
        emit Say(message, traceid);
    }
}