/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface Erc20 {
function name() external view returns ( string memory);
function symbol() external view returns ( string memory);
function decimals() external view returns (uint8);
function totalSupply() external view returns (uint256);
function balanceOf(address _owner) external view returns (uint256 balance);
function transfer(address _to, uint256 _value) external returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
function approve(address _spender, uint256 _value) external returns (bool success);
function allowance(address _owner, address _spender) external view returns (uint256 remaining);

event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}
contract ABCTOKEN is Erc20{
    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed; 
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    
    constructor(){
        _name = "ABCTOKEN";
        _symbol ="ABC";
        _decimals = 18;
        _totalSupply = 10000000*10**18;
        balances[msg.sender] = _totalSupply;
    }
    function name() external view override returns (string memory){
        return _name;
    }
    function symbol()external view override returns(string memory){
        return _symbol;
    }
    function decimals()external view override returns(uint8){
        return _decimals;
    }
    function totalSupply()external view override returns(uint256){
        return _totalSupply;
    }
    function balanceOf(address _owner)external view override returns(uint256 balance){
        return balances[_owner];
    }
    function approve(address _sender,uint _value)external override returns(bool success){
         allowed[msg.sender][_sender] = _value;
         emit Approval(msg.sender,_sender,_value);
         return true;
    }
    function transfer(address _to,uint _value)external override returns(bool success){
        require(balances[msg.sender] >= _value,"not enough amount");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender,_to,_value);
        return true;
    }
    function allowance(address _owner,address _spender)external override view returns(uint256 remaining){
        return allowed[_owner][_spender];
    }
    function transferFrom(address _from,address _to,uint256 _value)external override returns(bool success){
        uint256 all = allowed[_from][msg.sender];
        require(all >= _value && balances[_from]>=_value,"not enough amount");
        balances[_from]-= _value;
        balances[_to] += _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from,_to,_value);
        return true;
    }
}