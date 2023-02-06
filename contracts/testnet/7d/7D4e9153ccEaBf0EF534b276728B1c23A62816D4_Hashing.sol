//Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Hashing {

     constructor() {}

    function encode(uint256 timestamp, string memory input, address addr) public pure returns (bytes32) {
        return sha256(abi.encodePacked(timestamp, input, addr));
    }

    function decode(bytes memory hash) public pure returns (uint256, string memory, address) {

        (uint timestamp, string memory input, address addr) = abi.decode(hash, (uint256, string, address));
        return (timestamp, input, addr);
    }

}