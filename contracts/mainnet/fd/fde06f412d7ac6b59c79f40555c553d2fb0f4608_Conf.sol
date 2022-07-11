/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Initialize {
    bool internal initialized;

    modifier init(){
        require(!initialized, "initialized");
        _;
        initialized = true;
    }
}

interface Isenator{
    function addSenators(address[] calldata newSenators) external;
}

contract Conf is Initialize {
    address public owner;
    address public pledge;
    address public snapshoot;
    address public upgrade;
    address public senator;
    address public poc;
    address public developer;
    //seting
    uint public epoch;
    uint public executEpoch;
    uint public stEpoch;
    uint public voteEpoch;
    uint public senatorNum;
    uint public offLine;
    

    modifier onlyOwner(){
        require(msg.sender == owner, "only owner");
        _;
    }

    function initialize(address _pledge, address _snapshoot, address _upgrade, address _senator, address _poc) external init{
        (owner, pledge, snapshoot, upgrade, senator, poc, developer) = (msg.sender, _pledge, _snapshoot, _upgrade, _senator, _poc, msg.sender);
        (epoch, executEpoch, stEpoch, voteEpoch, senatorNum, offLine) = (7 days,  1 days, 1 hours, 1 hours, 11, 6);
    }


    function setEpoch(uint _epoch, uint _executEpoch, uint _stEpoch, uint _voteEpoch) external onlyOwner{
        (epoch, executEpoch, stEpoch, voteEpoch) = (_epoch, _executEpoch, _stEpoch, _voteEpoch);
    }

    function setSenatorVote(uint _senatorNum, uint _offLine) external onlyOwner {
        (senatorNum, offLine) = (_senatorNum, _offLine);
    }

    function addSenators(address[] calldata newSenators) external onlyOwner {
        Isenator(senator).addSenators(newSenators);
    }
}