/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


contract FactoryAssembly {
    event Deployed(address addr, uint salt);

    // 2. Compute the address of the contract to be deployed
    // NOTE: _salt is a random number used to create an address
    function getAddress(
        bytes memory bytecode,
        uint _salt
    ) public view returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                _salt,
                keccak256(bytecode)
            )
        );

        // NOTE: cast last 20 bytes of hash to address
        return address(uint160(uint(hash)));
    }

    function deploy(
        bytes memory bytecode,
        uint _salt
    ) public returns (address addr) {
        assembly {
            addr := create2(
                callvalue(), // wei sent with current call
                // Actual code starts after skipping the first 32 bytes
                add(bytecode, 0x20),
                mload(bytecode), // Load the size of code contained in the first 32 bytes
                _salt // Salt from function arguments
            )

            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        emit Deployed(addr, _salt);
    }
}