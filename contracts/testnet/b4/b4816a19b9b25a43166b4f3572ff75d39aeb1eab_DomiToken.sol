/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract DomiToken {
    string public name;
    string public symbol;
    uint8 public decimals = 18;  
    uint256 public totalSupply;

    mapping (address => uint256) public balance;  
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Burn(address indexed from, uint256 value);

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balance[msg.sender] = totalSupply;
        name = "Domichain token";
        symbol = "DOMI";
    }

    function balanceOf(address owner) public view returns(uint256) {
        return balance[owner];
    }

    function _transfer(address _from, address _to, uint _value) internal {
        require(balance[_from] >= _value);
        require(balance[_to] + _value > balance[_to]);
        uint previousBalances = balance[_from] + balance[_to];
        balance[_from] -= _value;
        balance[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balance[_from] + balance[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balance[msg.sender] >= _value);
        balance[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balance[_from] >= _value);
        require(_value <= allowance[_from][msg.sender]);
        balance[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(_from, _value);
        return true;
    }
}