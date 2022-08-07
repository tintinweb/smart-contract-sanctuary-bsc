/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

//SPDX-License-Identifier:NOLICENSE
pragma solidity 0.8.14;
contract deployer {
    function deploy(bytes memory bytecode) external returns (address pair) {
        bytes32 salt = keccak256(abi.encodePacked("1"));
        assembly {
            pair := create2(0x000, add(bytecode, 32), mload(bytecode), salt)
        }
    }
}