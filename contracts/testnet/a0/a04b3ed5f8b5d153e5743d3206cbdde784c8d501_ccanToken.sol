/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


contract ccanToken {
    string public symbol;
    string public name;
    uint8 public decimals;
    uint public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint)) allowance;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor (){
        name = "Ccan Token";
        symbol = "CCAN";
        decimals = 18;
        totalSupply = 10*(10**decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    function transfer(address _to, uint _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Sender Not founds");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender,_to,_value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require(balanceOf[_from] >= _value, "Sender dont have founds");
        require(allowance[_from][msg.sender] >= _value, "Sender is not allowed");
        allowance[_from][msg.sender] -= _value;
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from,_to,_value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success){
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender,_spender,_value);
        return true;
    }

}