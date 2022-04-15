/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

contract CREATE2Deployer {
    event ContractDeployed(address addr);

    function deploy(
        bytes memory code,
        bytes32 salt,
        bytes memory initData
    ) public returns (address addr) {
        assembly {
            addr := create2(0, add(code, 0x20), mload(code), salt)
            if iszero(extcodesize(addr)) { revert(0, 0) }
        }

        if (initData.length != 0) {
            bool success;
            bytes memory err;
            (success, err) = addr.call(initData);
            require(success, string(err));
        }

        emit ContractDeployed(addr);
    }
}