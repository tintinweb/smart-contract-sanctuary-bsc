// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    uint256 public override totalSupply;
    string public name;
    string public symbol;

    uint8 public decimals = 18;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function msgSender() internal view returns(address) {
        return msg.sender;
    }

    function transfer(address to, uint256 amount) external override returns(bool) {
        balanceOf[msgSender()] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msgSender(), to, amount);
        return true;
    }

   function approve(address spender, uint256 amount) external override returns(bool) {
        allowance[msgSender()][spender] = amount;
        emit Approval(msgSender(), spender, amount);
        return true;
   }

    function transferFrom(address from, address to, uint256 amount) external override returns(bool) {
        require(allowance[from][msgSender()] >= amount, "Insufficient allowence");
        allowance[from][msgSender()] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function mint(uint256 amount) external {
        balanceOf[msgSender()] += amount; 
        totalSupply += amount;
        emit Transfer(address(0), msgSender(), amount);
    }

    function burn(uint256 amount) external {
        uint256 balance = balanceOf[msgSender()] >= amount ? amount : balanceOf[msgSender()];
        balanceOf[msgSender()] -= balance;
        totalSupply -= balance;

        emit Transfer(msgSender(), address(0), amount);
    }
}