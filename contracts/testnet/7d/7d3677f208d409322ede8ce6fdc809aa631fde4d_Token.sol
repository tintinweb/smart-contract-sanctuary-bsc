/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract Token {
    uint totalSupply = 100000e18;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    mapping(address => bool) public blacklist;

    string public name = "TOKEN SCAM CLASSIC";
    string public symbol = "TSC";
    uint8 public decimal = 18;
 
    modifier notInBlacklist(address account) {
        require(!blacklist[account], "Address is in blacklist");
    _;
    }
 
    modifier inBlacklist(address account) {
        require(blacklist[account], "Address is not in blacklist");
        _;
    }
 
  function addBlacklist(address account) internal virtual notInBlacklist(account) {
    blacklist[account] = true;

  }
 
  function revokeBlacklist(address account) internal virtual inBlacklist(account) {
    blacklist[account] = false;

  }



    function getTotalSupply() external view returns(uint) {
        return totalSupply;
    }

    function getBalanceOf(address account) external view returns(uint) {
        return balanceOf[account];
    }

    function transfer(address recipient, uint amount) inBlacklist(recipient) external returns(bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function getAllowance(address owner, address spender) external view returns(uint) {
        return allowance[owner][spender];
    }

    function mint() public {
        balanceOf[msg.sender] = 500e18;
    }

    function approve(address spender, uint amount) external returns(bool) {
        allowance[msg.sender][spender] = amount;
        emit Approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) external returns(bool) {
        allowance[sender][recipient] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }


    event Transfer(address indexed from, address  indexed to, uint amount);

    event Approve(address indexed owner, address indexed spender, uint amount);
}