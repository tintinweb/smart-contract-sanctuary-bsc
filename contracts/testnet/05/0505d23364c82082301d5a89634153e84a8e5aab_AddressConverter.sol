/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.4;

contract AddressConverter {

    function add(address contractAddress) public pure returns (uint256) {
        return (uint256(bytes32(uint256(uint160(contractAddress)))));
    }

    function getAddress(uint256 convertedUint256) public pure returns (address) {
        return address(uint160(uint256(bytes32(convertedUint256))));
    }
}