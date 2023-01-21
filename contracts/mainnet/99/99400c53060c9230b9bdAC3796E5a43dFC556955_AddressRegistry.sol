// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.4;

import "./Owned.sol";

contract AddressRegistry is Owned {

    address public transferGate;
    
    mapping (address => bool) public freeParticipantControllers;
    mapping (address => bool) public freeParticipant;
    mapping (address => bool) public blacklist;
    mapping (address => bool) public trustedHolder;

    modifier transferGateOnly() {
        require (msg.sender == transferGate, "Transfer Gate only");
        _;
    }

    function setTransferGate(address _transferGate) public ownerOnly() {
        transferGate = _transferGate;
    }

    function setFreeParticipantController(address freeParticipantController, bool allow) public transferGateOnly() {
        freeParticipantControllers[freeParticipantController] = allow;
    }

    function setFreeParticipant(address participant, bool free) public transferGateOnly() {
        freeParticipant[participant] = free;
    }

    function setTrustedWallet(address holder, bool trusted) public transferGateOnly() {
        trustedHolder[holder] = trusted;
    }

    function setBlackListed(address account, bool blacklisted) public ownerOnly() {
        blacklist[account] = blacklisted;
    }
}