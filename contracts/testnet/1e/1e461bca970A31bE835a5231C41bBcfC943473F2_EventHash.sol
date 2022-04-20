// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;


contract EventHash {

    constructor () {}

    function getEventHash() public pure returns (bytes32) {
        return keccak256("Deposit(address,bytes32,uint256)");
    }
}