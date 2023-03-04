/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract MetaGem {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    uint256 public buyFee;
    uint256 public sellFee;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalSupply,
        uint256 _buyFee,
        uint256 _sellFee
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply * 10 ** decimals;
        balanceOf[msg.sender] = totalSupply;
        buyFee = _buyFee;
        sellFee = _sellFee;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function buy() public payable {
        uint256 amount = msg.value * (10 ** decimals) / (1 ether);
        uint256 fee = amount * buyFee / 100;
        totalSupply += fee;
        balanceOf[msg.sender] += amount - fee;
        emit Transfer(address(0), msg.sender, amount - fee);
    }

    function sell(uint256 _amount) public {
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance");
        uint256 fee = _amount * sellFee / 100;
        totalSupply += fee;
        balanceOf[msg.sender] -= _amount;
        payable(msg.sender).transfer((_amount - fee) * (1 ether) / (10 ** decimals));
        emit Transfer(msg.sender, address(0), _amount - fee);
    }
}