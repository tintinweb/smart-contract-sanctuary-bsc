// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

contract Whitelist {
    address payable public owner;

    mapping (address => bool) public whitelisted;
    mapping (address => bool) public admins;

    event AddressWhitelisted(address indexed _address);
    
    constructor() {
        owner = payable(msg.sender);
        admins[msg.sender] = true;
        whitelisted[msg.sender] = true;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function isWhitelisted() public view returns (bool) {
        require (whitelisted[msg.sender] == true, "error.notWhitelisted");
        return true;
    }

    function addWhitelist(address _address) public payable {
        require (admins[msg.sender] == true, "error.notAdministrator");

        whitelisted[_address] = true;
        emit AddressWhitelisted(_address);
    }

    function removeWhitelist(address _address) public payable {
        require (admins[msg.sender] == true, "error.notAdministrator");

        whitelisted[_address] = false;
    }

    function addAdministrator(address _address) public payable {
        require (msg.sender == getOwner(), "error.notOwner");

        admins[_address] = true;
    }

    function removeAdministrator(address _address) public payable {
        require (msg.sender == getOwner(), "error.notOwner");

        admins[_address] = false;
    }
}