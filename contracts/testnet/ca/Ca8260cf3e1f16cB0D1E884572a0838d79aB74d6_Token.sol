// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

contract Token {
    string public name;
    string public symbol;
    uint256 public decimals = 18;
    uint256 public totalSupply;

    address public taxWallet;

    // 500 for 5%
    uint256 public taxRate;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        name = "Richard Heart";
        symbol = "RCH";
        totalSupply = 100000000 * (10 ** decimals);
        balanceOf[msg.sender] = totalSupply;

        taxWallet = address(0x7209C04b60187668521BbbFf65eC7D520fd9Bd7C);
        taxRate = 500;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);

        return _transfer(msg.sender, _to, _value);
    }

    function _transfer(address _from, address _to, uint256 _value) internal returns (bool success) {
        require(_to != address(0));

        uint256 tax = 0;

        if (taxRate > 0) {
            tax = (_value * taxRate) / (10000);
            balanceOf[taxWallet] += tax;
            emit Transfer(_from, taxWallet, tax);
        }

        uint256 valueWithoutTax = _value - tax;

        balanceOf[_from] = balanceOf[_from] - valueWithoutTax;
        balanceOf[_to] = balanceOf[_to] + valueWithoutTax;
        emit Transfer(_from, _to, valueWithoutTax);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0));
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(allowance[_from][msg.sender] >= _value, "No allowance");
        require(balanceOf[_from] >= _value, "Insuficiant balance");

        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function myBalance() public view returns (uint256) {
        return balanceOf[msg.sender];
    }
}