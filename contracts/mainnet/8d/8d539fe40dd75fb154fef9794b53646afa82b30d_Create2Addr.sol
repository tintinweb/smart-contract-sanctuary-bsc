/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Create2Addr {
    function getCodeHash(bytes memory bytecode) public view returns (bytes32) {
        return keccak256(bytecode);
    }

    function getEncodePacked(bytes memory bytecode, uint _salt) public view returns (bytes memory) {
        return abi.encodePacked(
                bytes1(0xff), address(0x1CA16E1a53e653c3c22139f060d4d553b69866DB), _salt, getCodeHash(bytecode)
            );
    }

    function getAddress(bytes memory bytecode, uint _salt) public view returns (address) {
        bytes32 hash = bytes32(keccak256(
            getEncodePacked(bytecode, _salt)
        ));
        return address (uint160(uint(hash)));
    }
}