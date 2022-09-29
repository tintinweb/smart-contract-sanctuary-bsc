// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract Ethnos {
    address public owner;
    address public service;
    
    mapping (address => bool) admins;
    mapping (address => bool) approved;

    event OwnershipTransferred(address _newOwner, address _previousOwner);
    event AdminUpdate(address _user, bool _isAdmin);
    event UserApproval(address _user, bool _approved);

    constructor (address _service) {
        owner = msg.sender;
        service = _service;
    }

    function setAdmin(address _user, bool _isAdmin) public {
        _requireOwner();
        admins[_user] = _isAdmin;
        emit AdminUpdate(_user, _isAdmin);
    }

    function transferOwnership(address _newOwner) public {
        _requireOwner();
        address _oldOwner = owner;
        owner = _newOwner;
        emit OwnershipTransferred(owner, _oldOwner);
    }

    function setApproved(address _user, bool _approved) public {
        _requireAdmin();
        approved[_user] = _approved;
        emit UserApproval(_user, _approved);
    }

    function _requireOwner() private view {
        require(msg.sender == owner, 'Must be contract owner');
    }

    function _requireAdmin() private view {
        require(admins[msg.sender] || msg.sender == service, 'Must be contract admin or service');
    }
}