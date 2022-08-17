/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

contract NeiOToken {
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    address public owner;

    string public name;
    string public symbol;
    uint8 public decimals;

    mapping(address => mapping(address => uint256)) public allowance;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor() {

        name = "NeiO";
        symbol = "NEIO";
        decimals = 8;

        owner = msg.sender;
        totalSupply = 700_000_000 * 10 ** decimals;
        balanceOf[owner] = totalSupply;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        // require(balanceOf[msg.sender] >= _value);
        require(_spender != address(0));

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(allowance[_from][msg.sender] >= _value);
        require(balanceOf[_from] >= _value);
        require(_from != address(0) && _to != address(0));

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

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


}