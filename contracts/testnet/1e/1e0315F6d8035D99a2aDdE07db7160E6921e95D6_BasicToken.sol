/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

//SPDX-License-Identifier: UNLICENSED 

pragma solidity ^0.8;

contract BasicToken {
    uint public constant templateType = 0;

    string public name;
    string public symbol;
    uint8 public decimals;
    address private owner;

    uint public totalSupply;

    bool private isInitialized;

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    function initializeToken(string memory _name, string memory _symbol, address _owner, address _tokenDeployer, bytes32[] memory _tokenArgs) external {
        require(!isInitialized);
        require(_tokenArgs.length == 1, "FilterToken: INCORRECT_ARGUMENTS");

        name = _name;
        symbol = _symbol;
        decimals = 18;

        totalSupply = uint(bytes32(_tokenArgs[0])) * (10 ** decimals);

        owner = _owner;

        balanceOf[_tokenDeployer] = totalSupply;
        emit Transfer(address(0), _tokenDeployer, totalSupply);

        isInitialized = true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function transfer(address _to, uint _value) external returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint _value) external returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) external returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}