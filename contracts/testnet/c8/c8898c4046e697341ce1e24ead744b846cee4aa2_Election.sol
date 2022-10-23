/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

// SPDX-License-Identifier: MIT


pragma solidity 0.8.6;

contract Election {
    string public candidateName;

    constructor() {
        candidateName = "Candidate 1";
    }

    function setCandidate (string memory _name) public {
        candidateName = _name;
    }
}