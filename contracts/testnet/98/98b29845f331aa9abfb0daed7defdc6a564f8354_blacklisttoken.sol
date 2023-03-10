/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: Unlicensed


contract blacklisttoken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public blacklist;
    bool public isBlocked;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Blacklist(address indexed account, bool isBlacklisted);
    event BlockAllSellings(bool isBlocked);

   constructor () {
    name = "Blacklist Token";
    symbol = "BLCK";
    decimals = 9;
    totalSupply = 1000000 * 10 ** 9; // Total supply is set to 1000000
    balanceOf[msg.sender] = totalSupply;
    isBlocked = false;
    owner = msg.sender;
}


    function transfer(address _to, uint256 _value) public returns (bool success) {
    require(_to != address(0), "Cannot send tokens to the zero address.");
    require(!blacklist[msg.sender], "Your account has been blacklisted.");
    require(!isBlocked, "All sellings are currently blocked.");
    require(balanceOf[msg.sender] >= _value, "Insufficient balance.");
    require(balanceOf[_to] + _value > balanceOf[_to], "Integer overflow.");
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
    require(_from != address(0), "Cannot send tokens from the zero address.");
    require(_to != address(0), "Cannot send tokens to the zero address.");
    require(!blacklist[_from], "Your account has been blacklisted.");
    require(!isBlocked, "All sellings are currently blocked.");
    require(balanceOf[_from] >= _value, "Insufficient balance.");
    require(allowance[_from][msg.sender] >= _value, "Allowance exceeded.");
    require(balanceOf[_to] + _value > balanceOf[_to], "Integer overflow.");
    balanceOf[_from] -= _value;
    balanceOf[_to] += _value;
    allowance[_from][msg.sender] -= _value;
    emit Transfer(_from, _to, _value);
    return true;
}


   function addToBlacklist(address _account) public {
    require(_account != address(0), "Cannot add the zero address to the blacklist.");
    require(msg.sender == owner, "Only contract owner can blacklist an account.");
    require(!blacklist[_account], "Account is already blacklisted.");
    blacklist[_account] = true;
    emit Blacklist(_account, true);
}

function removeFromBlacklist(address _account) public {
    require(_account != address(0), "Cannot remove the zero address from the blacklist.");
    require(msg.sender == owner, "Only contract owner can remove an account from the blacklist.");
    require(blacklist[_account], "Account is not blacklisted.");
blacklist[_account] = false;
emit Blacklist(_account, false);
}

function blockAllSellings() public {
require(msg.sender == owner, "Only contract owner can block all sellings.");
require(!isBlocked, "Sellings are already blocked.");
isBlocked = true;
emit BlockAllSellings(true);
}

function unblockAllSellings() public {
require(msg.sender == owner, "Only contract owner can unblock all sellings.");
require(isBlocked, "Sellings are not blocked.");
isBlocked = false;
emit BlockAllSellings(false);
}

}