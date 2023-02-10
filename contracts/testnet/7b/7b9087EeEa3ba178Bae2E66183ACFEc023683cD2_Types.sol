// SPDX-License-Identifier: GPL-3.0
pragma experimental ABIEncoderV2;
pragma solidity >=0.4.25 <0.9.0;

/**
 * @title Types
 * @author Suresh Konakanchi
 * @dev All custom types that we have used in E-Voting will be declared here
 */
library Types {
    struct Voter {
        uint256 aadharNumber; // voter unique ID
        string name;
        uint8 age;
        uint8 stateCode;
        uint8 constituencyCode;
        bool isAlive;
        uint256 votedTo; // aadhar number of the candidate
    }

    struct Candidate {
        // Note: If we can limit the length to a certain number of bytes,
        // we can use one of bytes1 to bytes32 because they are much cheaper

        string name;
        string partyShortcut;
        string partyFlag;
        uint256 nominationNumber; // unique ID of candidate
        uint8 stateCode;
        uint8 constituencyCode;
    }

    struct Results {
        string name;
        string partyShortcut;
        string partyFlag;
        uint256 voteCount; // number of accumulated votes
        uint256 nominationNumber; // unique ID of candidate
        uint8 stateCode;
        uint8 constituencyCode;
    }
}