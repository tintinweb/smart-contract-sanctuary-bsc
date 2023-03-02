/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

contract BewebToken{


    address public _owner;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 private _totalSupply;

    mapping (address => uint256) private _balances;
    mapping (address => mapping(address => uint256)) private _allowed;

    constructor() {
        _owner = msg.sender;
        name = "Beweb Token";
        symbol = "BWB";
        decimals = 18;
        _totalSupply = 1_000_000_000 * 10 ** decimals;
        _balances[msg.sender] = _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success){
        require(_spender != address(0));
        _allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_balances[msg.sender] >= _value);
        require(_to != address(0));
        
        
        _balances[msg.sender] -= _value;
        _balances[_to] += _value;
        
        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require(_allowed[_from][msg.sender] >= _value);
        require(_balances[_from] >= _value);
        require(_from != address(0));

        _balances[_from] -= _value;
        _balances[_to] += _value;
        _allowed[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256)  {
        return _allowed[owner][spender];
    }


    function increaseAllowance(    address spender,    uint256 addedValue  )
        public returns (bool)  {
        require(spender != address(0));

        _allowed[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue  )    public    returns (bool)
    {
        require(spender != address(0));

        _allowed[msg.sender][spender] -= subtractedValue;
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}