/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

contract DeterministicDeployFactory {

    constructor() {
    }

    event Deploy(address addr);

    function deploy(bytes memory bytecode, bytes32 _salt) external {
        address addr;
        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), _salt)
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        emit Deploy(addr);
    }
}