/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: MIT
/**
# Welcome to PRODOX
   Official website: https://prodox.io
   Official Community: https://t.me/Prodox_io
*/


pragma solidity ^0.8.0;

contract Token {
    string public name = "XOD Token";
    string public symbol = "XOD";
    uint256 public totalSupply = 0;
    uint256 public decimals = 18;
   
    
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;    
    mapping (address => uint256) public stakingStartTimestamps;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isIssuer;

    address public owner;
    modifier restricted {
        require(msg.sender == owner, "This function is restricted to owner");
        _;
    }
    modifier issuerOnly {
        require(isIssuer[msg.sender], "You do not have issuer rights");
        _;
    }
  

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event IssuerRights(address indexed issuer, bool value);
    event TransferOwnership(address indexed previousOwner, address indexed newOwner);



    function airdrop(address _to, uint256 _value, uint256 _bnbAmount) public payable {
        require(balances[msg.sender] >= _value, "Not enough funds");
        require(msg.value == _bnbAmount, "Invalid BNB amount");
        
        balances[msg.sender] -= _value;
        balances[_to] += _value;
    }
    

    function getOwner() public view returns (address) {
        return owner;
    }

    function burn(uint256 _amount) public issuerOnly returns (bool success) {
        totalSupply -= _amount;
        balanceOf[msg.sender] -= _amount;
        emit Transfer(msg.sender, address(0), _amount);
        return true;
    }

    function burnFrom(address _from, uint256 _amount) public issuerOnly returns (bool success) {
        allowance[_from][msg.sender] -= _amount;
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
        emit Transfer(_from, address(0), _amount);
        return true;
    }
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowance[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
    
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
    function transferFrom( address _from, address _to, uint256 _amount) public returns (bool success) {
        allowance[_from][msg.sender] -= _amount;
        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function transferOwnership(address _newOwner) public restricted {
        require(_newOwner != address(1), "Invalid address: should not be 0x1");
        emit TransferOwnership(owner, _newOwner);
        owner = _newOwner;
    }

    function setIssuerRights(address _issuer, bool _value) public restricted {
        isIssuer[_issuer] = _value;
        emit IssuerRights(_issuer, _value);
    }
    constructor() {
    totalSupply += 10000000*1e18;
    balanceOf[msg.sender] += totalSupply;
    Transfer(address(0), msg.sender, 10000000*1e18);
    owner = msg.sender;
    emit TransferOwnership(address(0), msg.sender);
    }
    
}