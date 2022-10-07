// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

struct CharityDetails {
    bool enabled;
    string name;
    address primary;
}

contract Ethnos {
    address public owner;
    address public service;
    
    mapping (address => bool) public admins;
    mapping (address => bool) public approved;
    mapping (address => bool) public tokens;
    mapping (string => CharityDetails) public charities;

    event OwnershipTransferred(address _newOwner, address _previousOwner);
    event AdminUpdate(address _user, bool _isAdmin, address _approver);
    event UserApproved(address _user, address _approver);
    event TokenApproved(address _token, address _approver);
    event CharityEnabled(string _ein, string _name, address _primary, address _approver);

    constructor (address _service) {
        owner = msg.sender;
        service = _service;
    }

    function setAdmin(address _user, bool _isAdmin) public {
        _requireOwner();
        admins[_user] = _isAdmin;
        emit AdminUpdate(_user, _isAdmin, msg.sender);
    }

    function transferOwnership(address _newOwner) public {
        _requireOwner();
        address _oldOwner = owner;
        owner = _newOwner;
        emit OwnershipTransferred(owner, _oldOwner);
    }

    function setApproved(address _user) public {
        _requireAdmin();
        approved[_user] = true;
        emit UserApproved(_user, msg.sender);
    }

    function setTokenApproved(address _token) public {
        _requireAdmin();
        tokens[_token] = true;
        emit TokenApproved(_token, msg.sender);
    }

    function enableCharity(string calldata _ein, string calldata _name, address _primary) public {
        _requireAdmin();
        require(!charities[_ein].enabled, 'Charity is already enabled');

        CharityDetails memory charity = CharityDetails({
            enabled: true,
            name: _name,
            primary: _primary
        });
        
        charities[_ein] = charity;
        emit CharityEnabled(_ein, _name, _primary, msg.sender);
    }

    function _requireOwner() private view {
        require(msg.sender == owner, 'Must be contract owner');
    }

    function _requireAdmin() private view {
        require(admins[msg.sender] || msg.sender == service, 'Must be contract admin or service');
    }
}