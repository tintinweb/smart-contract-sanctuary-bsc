// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Multicall {
    function multicall(address[] memory _targets, bytes[] memory _data) public {
        for (uint i = 0; i < _targets.length; i++) {
            address target = _targets[i];
            (bool success, ) = target.delegatecall(_data[i]);
            require(success, "The delegate call to the target contract failed");
        }
    }
}