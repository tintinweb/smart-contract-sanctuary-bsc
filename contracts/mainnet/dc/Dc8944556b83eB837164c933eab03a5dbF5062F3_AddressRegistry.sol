// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.4;

import "./Owned.sol";

contract AddressRegistry is Owned {

    modifier transferGateOnly() {
        require (msg.sender == transferGate, "Transfer Gate only");
        _;
    }

    address public transferGate;
    
    mapping (address => bool) public freeParticipantControllers;
    mapping (address => bool) public freeParticipant;
    mapping (address => bool) public eliteParticipant;
    mapping (address => bool) public blacklist;

    function setTransferGate(address _transferGate) public ownerOnly() {
        transferGate = _transferGate;
    }

    function setFreeParticipantController(address freeParticipantController, bool allow) public transferGateOnly() {
        freeParticipantControllers[freeParticipantController] = allow;
    }

    function setFreeParticipant(address participant, bool free) public transferGateOnly() {
        freeParticipant[participant] = free;
    }

    function setEliteParticipant(address holder, bool trusted) public transferGateOnly() {
        eliteParticipant[holder] = trusted;
    }

    function setBlacklisted(address account, bool blacklisted) public transferGateOnly() {
        blacklist[account] = blacklisted;
    }
}