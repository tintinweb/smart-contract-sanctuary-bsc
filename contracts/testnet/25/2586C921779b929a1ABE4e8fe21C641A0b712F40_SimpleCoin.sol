/**
 *Submitted for verification at BscScan.com on 2022-02-25
*/

//"SPDX-License-Identifier: UNLICENSED"
pragma solidity ^0.8.0;

contract SimpleCoin{
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOff;
    mapping(address => mapping(address => uint256)) public allowance;

    address public owner;
    string public name = "New Token";
    string public symbol = "MTK";
    uint8 public decimals = 8; 

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _sender, uint256 _value);

    modifier onlyMOwner(){
        require(msg.sender == owner);
        _;
    }

    constructor(){
        owner = msg.sender;
        totalSupply = 1_000_000 * 10 ** decimals;
        balanceOff[owner] = totalSupply;
    }

    function transferFrom(address _from, address _to, uint256 _value)public returns(bool success){
        require(allowance[_from][msg.sender] >= _value);
        require(balanceOff[_from] >= _value);
        require(_from != address(0));
        require(_to != address(0));
        balanceOff[_from] -= _value;
        balanceOff[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true; 

    }

    function approve(address _spender, uint256 _value) public returns(bool success){
        //require(balanceOff[msg.sender] >= _value);
        require(_spender != address(0));
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender,_spender,_value);
        return true;
    }

    function changeOwner(address _newOwner)public onlyMOwner{        
        owner = _newOwner;
    }

    function transfer(address _to, uint256 _value) public returns (bool success){
        require(balanceOff[msg.sender] >= _value);
        require(_to != address(0));
        balanceOff[msg.sender] -= _value; 
        balanceOff[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }



}