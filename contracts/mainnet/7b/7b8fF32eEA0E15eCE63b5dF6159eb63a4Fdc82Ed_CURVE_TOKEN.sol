/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CURVE_TOKEN {
    address public owner;
    string public constant name = "CURVE-TOKEN";
    string public constant symbol = "CURVE";
    uint8 public constant decimals = 18;
    uint256 private _totalSupply = 1000000000 * 10**decimals;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        owner = msg.sender;
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _address) public view returns (uint256) {
        return balances[_address];
    }

    function transfer(address _receiver, uint256 _numTokens) public returns (bool) {
        return _transfer(msg.sender, _receiver, _numTokens);
    }

    function transferFrom(address _sender, address _receiver, uint256 _numTokens) public returns (bool) {
        require(_numTokens <= allowed[_sender][msg.sender], "Invalid number of tokens allowed by owner");
        allowed[_sender][msg.sender] -= _numTokens;
        return _transfer(_sender, _receiver, _numTokens);
    }

    function approve(address _spender, uint256 _numTokens) public returns (bool) {
        allowed[msg.sender][_spender] = _numTokens;
        emit Approval(msg.sender, _spender, _numTokens);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function _transfer(address sender, address receiver, uint256 _numTokens) internal returns (bool) {
        require(sender != address(0) && receiver != address(0), "invalid send or receiver address");
        require(_numTokens <= balances[sender], "Invalid number of tokens");
        balances[sender] -= _numTokens;
        balances[receiver] += _numTokens;
        emit Transfer(sender, receiver, _numTokens);
        return true;
    }
}