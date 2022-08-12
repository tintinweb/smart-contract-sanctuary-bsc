// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

contract ETHTrustedSetup {
    event EpochDataMTRootRecorded(uint indexed epoch, bytes32 hash);

    mapping(uint => bytes32) public epochDataMTRoot;

    uint public startingEpoch;
    uint public epochCount;

    constructor(uint _startingEpoch) {
        startingEpoch = _startingEpoch;
    }

    function setEpochDataMTRoots(uint firstEpoch,  bytes32[] memory hashes) public {

       require(firstEpoch == epochCount + startingEpoch, "invalid param");

       for (uint i = 0; i < hashes.length; i++){
           epochDataMTRoot[firstEpoch + i] = hashes[i];
           emit EpochDataMTRootRecorded(firstEpoch + i, hashes[i]);
       }
       epochCount += hashes.length;
    }

    function nextEpoch() view public returns(uint) {
         return startingEpoch + epochCount;
    }
}