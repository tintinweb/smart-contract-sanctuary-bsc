/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

// SPDX-License-Identifier: MIT
// https://smartearners.team
pragma solidity ^0.8.17;

contract sha256Encoder {
// Compute the SHA-3 (Keccak-256) hash of a value
function computeDigit(uint256 x) public pure returns (bytes32) {
    return keccak256(abi.encodePacked(x));
}

function computeAddress(address x) public pure returns (bytes32) {
    return keccak256(abi.encode(x));
}

function computeAddressPacked(address x) public pure returns (bytes32) {
    return keccak256(abi.encodePacked(x));
}

function computeStringPacked(string memory x) public pure returns (bytes32) {
    return keccak256(abi.encodePacked(x));
}

function computeString(string memory x) public pure returns (bytes32) {
    return keccak256(abi.encode(x));
}

}