/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract Arbi is Ownable {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public totalSupply;
    uint public maxSupply;

    bool public tradingEnabled = false;

    mapping (address => uint) public balanceOf;
    mapping (address => bool) public hasMinted;

    event Transfer(address indexed from, address indexed to, uint value);

    constructor() {
        name = "Arbi";
        symbol = "ARB";
        decimals = 18;
        totalSupply = 0;
        maxSupply = 20000000 * (10 ** uint(decimals));
    }

    function enableTrading() public onlyOwner {
        require(totalSupply >= 10000000 * (10 ** uint(decimals)), "Can only enable trading once 10 million tokens are minted");
        tradingEnabled = true;
    }

    function mint(address to, uint amount) public payable onlyOwner {
    require(totalSupply + amount <= maxSupply, "Max supply reached");
    require(!hasMinted[to], "Address has already been minted tokens");
    balanceOf[to] += amount;
    totalSupply += amount;
    hasMinted[to] = true;
    emit Transfer(address(0), to, amount);
}

    function transfer(address to, uint value) public {
        require(tradingEnabled, "Trading is not yet enabled");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        require(to != address(0), "Invalid recipient address");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
    }
}