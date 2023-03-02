// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract CollateralToken {
    string public name = "Collateral Token";
    string public symbol = "COLT";
    uint256 public totalSupply = 100000000000000000;
    uint8 public decimals = 9;
    uint256 public fixedValue = 100; // fixed value for the token
    
    mapping(address => uint256) public balanceOf;

    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply;
        balanceOf[msg.sender] = _initialSupply;
    }

    function updateFixedValue(uint256 _newValue) public {
        fixedValue = _newValue;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(allowance[_from][msg.sender] >= _value);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        return true;
    }

    mapping(address => mapping(address => uint256)) public allowance;

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }
}