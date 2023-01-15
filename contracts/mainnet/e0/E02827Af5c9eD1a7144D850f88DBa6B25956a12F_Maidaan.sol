/**
 *Submitted for verification at BscScan.com on 2023-01-15
*/

// SPDX-License-Identifier: MIT

// |||\\\    ///|||   ///\\\   |||||||  |||||\\\     ///\\\      ///\\\   |||\\\  |||
// ||| \\\  /// |||  ///==\\\    |||    |||   |||   ///==\\\    ///==\\\  ||| \\\ |||
// |||  \\\///  ||| ///    \\\ |||||||  |||||///   ///    \\\  ///    \\\ |||  \\\|||


pragma solidity >=0.4.22 <0.9.0;

contract Maidaan {

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public owner;
    uint256 amount1;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    event Transfer(address indexed owner, address indexed recipient, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    constructor() {
        name = "Maidaan";
        symbol = "MDN";
        decimals = 18;
        totalSupply = 50000000 * (10 ** uint256(decimals));
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0),"Recipient address should not be zero");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance.");
        require(balanceOf[msg.sender] > 0, "Insufficient balance.");
        uint256 commission = amount/100000;
        amount1 = amount-commission;
        balanceOf[owner] = balanceOf[owner]+commission;
        balanceOf[msg.sender] = balanceOf[msg.sender]-amount;
        balanceOf[recipient] = balanceOf[recipient]+amount1;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0),"Recipient address should not be zero");
        require(allowance[sender][msg.sender] >= amount, "Insufficient allowance.");
        require(balanceOf[sender] >= amount, "Insufficient balance.");
        require(balanceOf[sender] > 0, "Insufficient balance.");
        uint256 commission = amount/100000;
        amount1 = amount-commission;
        balanceOf[owner] = balanceOf[owner]+commission;
        balanceOf[sender] = balanceOf[sender]-amount;
        balanceOf[recipient] = balanceOf[recipient]+amount1;
        allowance[sender][msg.sender] = allowance[sender][msg.sender] - amount;
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    

}