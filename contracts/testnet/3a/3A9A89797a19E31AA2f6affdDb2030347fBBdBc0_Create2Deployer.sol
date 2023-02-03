// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Create2Deployer
{
    uint256 public constant VERSION = 202302031032;

    mapping(address => address) public deployRecords;

    function deploy(bytes memory code, uint256 salt) public {
        address addr;
        assembly {
            addr := create2(0, add(code, 0x20), mload(code), salt)
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        deployRecords[addr] = msg.sender;
    }
}