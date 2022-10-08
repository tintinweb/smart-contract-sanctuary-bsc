// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./interfaces/IERC20.sol";

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

    function addTokenDonation(address _token, uint _amount) public {
        require(users[msg.sender].approved, 'Doner is not approved');
        require(tokens[_token], 'Token is not approved');
        IERC20 token = IERC20(_token);
        uint startBalance = token.balanceOf(address(this));
        token.transferFrom(msg.sender, address(this), _amount);
        uint received = token.balanceOf(address(this)) - startBalance;
        require(received > 0, 'No tokens receieved');
        users[msg.sender].donations[_token] += _amount;
        users[msg.sender].balances[_token] += received;
        emit AddDonation(msg.sender, _token, _amount);
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address _account) external view returns (uint256);
    function transfer(address _recipient, uint256 _amount) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address _spender, uint256 _amount) external returns (bool);
    function transferFrom(address _sender, address _recipient, uint256 _amount) external returns (bool);
    event Transfer(address _from, address _to, uint256 _value);
    event Approval(address _owner, address _spender, uint256 _value);
}