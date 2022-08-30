/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

contract PesPatron{
    struct Project{
        address owner;
        uint timestamp;
        uint8 fundingType;
    }

    mapping(uint => Project) public projects;
    uint public allProjectsLength;
    
    function createNewProject(uint8 _fundingType) external{
        projects[allProjectsLength++] = Project({
            owner: msg.sender,
            timestamp: block.timestamp,
            fundingType: _fundingType
        });
    }
}