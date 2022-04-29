pragma solidity ^0.7.4;
// "SPDX-License-Identifier: Apache License 2.0"


contract Test {
    mapping(address => uint256) public _someIndexes;

    fallback() external {
        // solhint-disable-next-line reason-string
        revert();
    }

    function addSuite(address someAddress, uint256 someUint) external {
        _someIndexes[someAddress] = someUint;
    }
}