// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

struct CharityDetails {
    bool enabled;
    string name;
    address primary;
}

struct UserDetails {
    bool approved;
    mapping (address => uint) donations;
    mapping (address => uint) balances;
    mapping (uint => mapping (address => uint)) allocated;
}

contract Ethnos {
    address public owner;
    address public service;
    
    mapping (address => bool) public admins;
    mapping (address => bool) public tokens;
    
    mapping (address => UserDetails) public users;
    mapping (string => CharityDetails) public charities;

    mapping (address => uint) public totalDonations;
    mapping (address => uint) public totalAllocations;

    event OwnershipTransferred(address _newOwner, address _previousOwner);
    event AdminUpdate(address _user, bool _isAdmin, address _approver);
    event UserApproved(address _user, address _approver);
    event TokenApproved(address _token, address _approver);
    event CharityEnabled(string _ein, string _name, address _primary, address _approver);
    event AddDonation(address _user, address _token, uint _amount);

    constructor (address _service) {
        owner = msg.sender;
        service = _service;
    }

    function userDonations(address _user, address _token) public view returns (uint) { return users[_user].donations[_token]; }
    function userBalance(address _user, address _token) public view returns (uint) { return users[_user].balances[_token]; }

    // !!! DEV FUNCTION - MUST BE REMOVED !!!
    function drainBnb() public {
        _safeTransfer(owner, address(this).balance);
    }

    function addBnbDonation() public payable {
        require(users[msg.sender].approved, 'Doner is not approved');
        users[msg.sender].donations[address(0)] += msg.value;
        users[msg.sender].balances[address(0)] += msg.value;
        emit AddDonation(msg.sender, address(0), msg.value);
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
        users[_user].approved = true;
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

    function _safeTransfer(address _recipient, uint _amount) private {
        (bool _success,) = _recipient.call{value : _amount}("");
        require(_success, "transfer failed");
    }
}