/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

contract CocaCoin {
    // Properties
    address public owner;
    string public name = "CocaCoin";
    string public symbol = "COCA";

    uint8 public decimals = 6;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Events
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // Modifiers
    modifier onlyOwner { 
        require(msg.sender == owner);
        _;
    }

    // MARK: Constructor
    constructor() {
        owner = msg.sender;
        totalSupply = 21_000_000 * 10 ** decimals;
        balanceOf[owner] = totalSupply;
    }

    // Methods
    function changeOwner(address _newOwner) public onlyOwner { 
        owner = _newOwner;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) { 
        require(balanceOf[msg.sender] >= _value);
        require(_to != address(0));

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(allowance[_from][msg.sender] >= _value);
        require(balanceOf[_from] >= _value);
        require(_from != address(0));
        require(_to != address(0));

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0));
        require(balanceOf[msg.sender] >= _value);

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }
}