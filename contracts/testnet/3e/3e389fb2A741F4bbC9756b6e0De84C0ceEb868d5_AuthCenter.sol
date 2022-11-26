/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// SPDX-License-Identifier: COMMERCIAL

pragma solidity ^0.8.0;


// 
interface IAuthCenter {
    event UpdateOwner(address indexed _address);
    event AddAdmin(address indexed _address);
    event DiscardAdmin(address indexed _address);
    event FreezeAddress(address indexed _address);
    event UnFreezeAddress(address indexed _address);
    event AddClient(address indexed _address);
    event RemoveClient(address indexed _address);
    event ContractPausedState(bool value);

    function addAdmin(address _address) external returns (bool);
    function discarddAdmin(address _address) external returns (bool);
    function freezeAddress(address _address) external returns (bool);
    function unfreezeAddress(address _address) external returns (bool);
    function addClient(address _address) external returns (bool);
    function removeClient(address _address) external returns (bool);
    function isClient(address _address) external view returns (bool);
    function isAdmin(address _address) external view returns (bool);
    function isUnfrozen(address _address) external view returns (bool);
    function setContractPaused() external returns (bool);
    function setContractUnpaused() external returns (bool);
    function isContractPaused() external view returns (bool);
}

// 
contract AuthCenter is IAuthCenter {

    address private owner;

    mapping (address => bool) private admins;
    mapping (address => bool) private clients;
    mapping (address => bool) private whiteList;
    bool private contractPaused;

    constructor () { owner = msg.sender; }

    function updateOwner(address _address) external returns (bool) {
        require(msg.sender == owner, "AuthCenter: You are not contract owner");
        require(admins[_address], "AuthCenter: new contract owner is not our admin");
        owner = _address;
        emit UpdateOwner(_address);
        return true;
    }

    function addAdmin(address _address) external override returns (bool) {
        require((msg.sender == owner) || admins[msg.sender], "AuthCenter: You are not admin");
        admins[_address] = true;
        emit AddAdmin(_address);
        return true;
    }

    function discarddAdmin(address _address) external override returns (bool){
        require(admins[msg.sender], "AuthCenter: You are not admin");
        admins[_address] = false;
        emit DiscardAdmin(_address);
        return true;
    }

    function freezeAddress(address _address) external override returns (bool) {
        require(admins[msg.sender], "AuthCenter: You are not admin");
        whiteList[_address] = false;
        emit FreezeAddress(_address);
        return true;
    }

    function unfreezeAddress(address _address) external override returns (bool) {
        require(admins[msg.sender], "AuthCenter: You are not admin");
        whiteList[_address] = true;
        emit UnFreezeAddress(_address);
        return true;
    }

    function isUnfrozen(address _address) external view override returns (bool) {
        require(clients[msg.sender] || admins[msg.sender], "AuthCenter: Access denied");
        return whiteList[_address];
    }

    function addClient(address _address) external override returns (bool) {
        require(admins[msg.sender], "AuthCenter: You are not admin");
        clients[_address] = true;
        emit AddClient(_address);
        return true;
    }

    function removeClient(address _address) external override returns (bool) {
        require(admins[msg.sender], "AuthCenter: You are not admin");
        clients[_address] = false;
        emit RemoveClient(_address);
        return true;
    }

    function isClient(address _address) external view override returns (bool) {
        return clients[_address];
    }

    function isAdmin(address _address) external view override returns (bool) {
        return admins[_address];
    }

    function setContractPaused() external override returns (bool) {
        require(admins[msg.sender], "AuthCenter: You are not admin");
        contractPaused = true;
        emit ContractPausedState(true);
        return true;
    }

    function setContractUnpaused() external override returns (bool) {
        require(admins[msg.sender], "AuthCenter: You are not admin");
        contractPaused = false;
        emit ContractPausedState(false);
        return true;
    }

    function isContractPaused() external view override returns (bool) {
        return contractPaused;
    }

    //some gas ethers need for a normal work of this contract.
    //Only owner can put ethers to contract.
    receive() external payable {
        require(msg.sender == owner, "AuthCenter: You are not contract owner");
    }

    //Only owner can return to himself gas ethers before closing contract
    function withDrawAll() external {
        require(msg.sender == owner, "AuthCenter: You are not contract owner");
        payable(owner).transfer(address(this).balance);
    }
}