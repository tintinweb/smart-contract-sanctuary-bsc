/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract Token {
    uint256 private _totalSupply;
    address public owner;
    mapping (address => uint256) balances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping (address => mapping(address => uint256)) allowances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);


    constructor(string memory cname, string memory csymbol, uint8 cdecimals, uint256 totalAmount) {
        _name = cname;
        _symbol = csymbol;
        _decimals = cdecimals;
        _totalSupply = totalAmount * (10 ** (_decimals));
        owner = msg.sender;
        balances[msg.sender] += _totalSupply;
    }

    function name() external view returns(string memory) {
        return _name;
    }

    function symbol() external view returns(string memory) {
        return _symbol;
    }

    function decimals() external view returns(uint256){
        return _decimals;
    }

    function totalSupply() external view returns(uint256){
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns(uint256){
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) external{
        require(balances[msg.sender] >= _value, "Not enough tokens");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) external{
        require(allowances[_from][msg.sender] >= _value, "You can't transfer this amount of tokens");
        allowances[_from][msg.sender] -= _value;
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) external{
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
    }

    function allowance(address _owner, address _spender) external view returns(uint256){
        return allowances[_owner][_spender];
    }

    receive () external payable {}
}