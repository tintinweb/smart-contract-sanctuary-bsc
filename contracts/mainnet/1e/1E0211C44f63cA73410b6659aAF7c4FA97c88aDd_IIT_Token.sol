/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.10;

contract IIT_Token {
    string public constant name = "ITT Token";
    string public constant symbol = "ITT";
    uint256 public constant decimals = 18;
    uint256 public totalSupply = 5000000 * 10 ** uint256(decimals);
    uint256 public burnTaxRate = 1; // 1% burn tax rate

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed burner, uint256 value);

    constructor()  {
        balances[msg.sender] = totalSupply;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        uint256 burnTaxAmount = amount * burnTaxRate / 100;
        uint256 transferAmount = amount + burnTaxAmount;
        require(balances[msg.sender] >= transferAmount, "Not enough balance.");
        require(amount <= balances[recipient], "Recipient balance is too low.");
        require(amount > 0, "Amount must be greater than zero.");

        balances[msg.sender] -= transferAmount;
        balances[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        emit Burn(msg.sender, burnTaxAmount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        uint256 burnTaxAmount = amount * burnTaxRate / 100;
        uint256 transferAmount = amount + burnTaxAmount;
        require(balances[sender] >= transferAmount, "Sender balance is too low.");
        require(amount <= allowed[sender][msg.sender], "Amount not approved.");
        require(amount <= balances[recipient], "Recipient balance is too low.");
        require(amount > 0, "Amount must be greater than zero.");

        balances[sender] -= transferAmount;
        allowed[sender][msg.sender] -= amount;
        balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
        emit Burn(sender, burnTaxAmount);
        return true;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }
}