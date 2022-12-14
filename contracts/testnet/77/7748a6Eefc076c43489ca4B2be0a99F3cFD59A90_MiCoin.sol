/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

contract MiCoin {

    uint public totalSupply;
    mapping(address => uint256) public balanceof;

    address public owner;

    string public name ="Micoin"; 

    string public symbol = "MCN"; 

    uint8 public decimals = 8;

    // transferFrom, approval, allowance

    mapping(address => mapping(address => uint)) public allowance;

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    modifier  onlyOwner{
        require(msg.sender == owner);
        _;
    }

    constructor() {

        owner = msg.sender;
        totalSupply = 1_000_000_000 * 10 ** decimals;
        balanceof[owner] = totalSupply;

    }


    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        require(allowance[_from][msg.sender] >= _value);
        require(balanceof[_from] >= _value);
        require(_from != address(0));
        require(_to != address(0));

        balanceof[_from] -= _value;
        balanceof[_to] += _value;
        allowance[_from] [msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }



    function approve(address _spender, uint256 _value) public returns (bool success){
        require(_spender != address(0));      
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;

    }

    function changeOwner(address _newOwner) public onlyOwner {
        
        owner = _newOwner;


    }

    function transfer(address _to, uint256 _value) public returns (bool success){
        require(balanceof[msg.sender] >= _value);
        require(_to != address(0));
        balanceof[msg.sender] -= _value;
        balanceof[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;

    }




}