/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract Arbiprofit {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public totalSupply;
    uint public maxSupply;

    uint public maxBuyPercent = 1; // Maximum buy amount as a percentage of total supply
    uint public maxSellPercent = 1; // Maximum sell amount as a percentage of total supply

    bool public tradingEnabled = false;
    bool public buySellEnabled = false;

    mapping (address => uint) public balanceOf;
    mapping (address => bool) public hasMinted;
    mapping (address => uint) public lastBuyTime;
    mapping (address => uint) public lastSellTime;

    constructor() {
        name = "Arbi Profit";
        symbol = "ARB";
        decimals = 18;
        totalSupply = 0;
        maxSupply = 20000000 * (10 ** uint(decimals));
    }

    function enableTrading() public {
        require(!tradingEnabled, "Trading is already enabled");
        tradingEnabled = true;
    }

    function enableBuySell() public {
        require(!buySellEnabled, "Buying and selling is already enabled");
        require(totalSupply >= maxSupply / 2, "Can only enable buying and selling once half of max supply is minted");
        buySellEnabled = true;
    }

    function mint(address to, uint amount) public payable {
        require(totalSupply + amount <= maxSupply, "Max supply reached");
        require(!hasMinted[msg.sender], "Already minted tokens");
        require(tradingEnabled, "Trading is not yet enabled");

        uint fee = msg.value / 1000000000000000000; // Transaction fee is 1% of transaction value
        address payable feeRecipient = payable(0x65437A7cdFB92F46aba37aC59bb33514A33a2eB5);
        feeRecipient.transfer(fee);

        balanceOf[to] += amount;
        totalSupply += amount;
        hasMinted[msg.sender] = true;
    }

    function buy() public payable {
        require(buySellEnabled, "Buying and selling is not yet enabled");
        require(msg.value > 0, "Must send Ether to buy tokens");
        uint amount = msg.value / 100000000000000000;
        require(amount > 0, "Amount must be greater than zero");
        require(amount <= totalSupply * maxBuyPercent / 1, "Buy amount exceeds maximum limit");
        require(totalSupply + amount <= maxSupply, "Max supply reached");
        require(lastBuyTime[msg.sender] + 1 days < block.timestamp, "Can only buy once per day");

        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        lastBuyTime[msg.sender] = block.timestamp;
    }

    function sell(uint amount) public {
    require(buySellEnabled, "Buying and selling is not yet enabled");
    require(amount > 0, "Amount must be greater than zero");
    require(amount <= balanceOf[msg.sender] * maxSellPercent / 1, "Sell amount exceeds maximum limit");
    require(balanceOf[msg.sender] >= amount, "Insufficient balance");
    require(lastSellTime[msg.sender] + 1 days < block.timestamp, "Can only sell once per day");

    uint value = amount * 100000000000000000;
    payable(msg.sender).transfer(value); // cast msg.sender to payable

    balanceOf[msg.sender] -= amount;
    totalSupply -= amount;
    lastSellTime[msg.sender] = block.timestamp;
    }
}