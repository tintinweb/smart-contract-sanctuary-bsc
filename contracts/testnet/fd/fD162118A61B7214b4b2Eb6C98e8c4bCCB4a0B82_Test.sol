/**
 *Submitted for verification at BscScan.com on 2022-03-01
*/

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.4;

contract Test {
    function recover(string memory message, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        bytes memory msgBytes = bytes(message);
        return ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(msgBytes))), v, r, s);
    }

    function generateMessage(string memory message) public pure returns (bytes32) {
        return keccak256(bytes(message));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked( "\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, uint8 v, bytes32 r, bytes32 s) public pure returns (address) {
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }
}