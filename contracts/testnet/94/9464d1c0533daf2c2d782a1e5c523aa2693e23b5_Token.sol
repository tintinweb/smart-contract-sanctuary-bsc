/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

contract Token {
    address owner;
    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint8 public decimals;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    uint256 public buyFeeRate = 5;
    uint256 public sellFeeRate = 100;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event FeesUpdated(uint256 _buyFeeRate, uint256 _sellFeeRate);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        uint8 _decimals
    ) {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
        decimals = _decimals;
        balanceOf[owner] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        uint256 fee = (_value * buyFeeRate) / 100;
        uint256 valueAfterFee = _value - fee;
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += valueAfterFee;
        emit Transfer(msg.sender, _to, valueAfterFee);
        emit Transfer(msg.sender, owner, fee);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        uint256 fee = (_value * buyFeeRate) / 100;
        uint256 valueAfterFee = _value - fee;
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        balanceOf[_to] += valueAfterFee;
        emit Transfer(_from, _to, valueAfterFee);
        emit Transfer(_from, owner, fee);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function updateFees(uint256 _buyFeeRate, uint256 _sellFeeRate) public returns (bool success) {
        require(msg.sender == owner);
        buyFeeRate = _buyFeeRate;
        sellFeeRate = _sellFeeRate;
        emit FeesUpdated(buyFeeRate, sellFeeRate);
        return true;
    }

    function sell(uint256 _value) public returns (bool success) {
        uint256 sellAmount = _value;
        uint256 fee = (sellAmount * sellFeeRate) / 100;
        balanceOf[msg.sender] -= sellAmount;
        totalSupply -= sellAmount;
        balanceOf[owner] += fee;
        emit Transfer(msg.sender, owner, sellAmount);
        emit Transfer(msg.sender, owner, fee);
        return true;
    }

    function burn(uint256 _value) public returns (bool success) {
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }
}