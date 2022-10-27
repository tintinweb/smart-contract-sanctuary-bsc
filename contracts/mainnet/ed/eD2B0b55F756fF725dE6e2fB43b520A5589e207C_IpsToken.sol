/**
 *Submitted for verification at BscScan.com on 2022-10-27
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract IpsToken{

    string public name = "IPS Token";
    string public symbol = "IPS";
    uint256 public totalSupply;
    address private admin;
    uint8 public _decimals = 0;
    bool public claimStatus = false;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval (
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    constructor(uint256 _initialSupply) { 
        balanceOf[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
        admin = msg.sender;
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function claimStatusChange(bool _claimStatus) public returns (bool) {
        require(msg.sender == admin, 'not admin');
        claimStatus = _claimStatus;
        return true;
    }

    function claimToken(address _to, uint256 _value) public returns (bool) {
        require(balanceOf[admin] >= _value, 'not enought tokens in contract');
        require(claimStatus == true, 'claim is not active');
        balanceOf[admin] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(admin, _to, _value);
        return true;
    }
}