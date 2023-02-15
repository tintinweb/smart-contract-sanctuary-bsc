/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public botWallets;
    mapping(address => uint256) public stakingWallets;
    mapping(address => uint256) public marketingWallets;

    address public owner;
    uint256 public buyTaxPercentage;
    uint256 public sellTaxPercentage;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply, uint256 _buyTaxPercentage, uint256 _sellTaxPercentage) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = _totalSupply;
        owner = msg.sender;
        buyTaxPercentage = _buyTaxPercentage;
        sellTaxPercentage = _sellTaxPercentage;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function setBuyTaxPercentage(uint256 _buyTaxPercentage) public onlyOwner {
        buyTaxPercentage = _buyTaxPercentage;
    }

    function setSellTaxPercentage(uint256 _sellTaxPercentage) public onlyOwner {
        sellTaxPercentage = _sellTaxPercentage;
    }

    function removeBotWallet(address botWallet) public onlyOwner {
        botWallets[botWallet] = false;
    }

    function transfer(address to, uint256 value) public {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        require(to != address(0), "Invalid address");

        if (botWallets[msg.sender] || botWallets[to]) {
            balanceOf[msg.sender] -= value;
            balanceOf[to] += value;
            emit Transfer(msg.sender, to, value);
        } else {
            uint256 taxPercentage = msg.sender == owner ? 0 : msg.sender == address(this) ? sellTaxPercentage : buyTaxPercentage;
            uint256 tax = (value * taxPercentage) / 100;
            uint256 netValue = value - tax;

            balanceOf[msg.sender] -= value;
            balanceOf[owner] += tax;
            balanceOf[to] += netValue;

            emit Transfer(msg.sender, to, netValue);
        }
    }

    function addBotWallet(address botWallet) public onlyOwner {
        botWallets[botWallet] = true;
    }

    function setStakingWallet(address stakingWallet, uint256 amount) public onlyOwner {
        stakingWallets[stakingWallet] = amount;
    }

    function setMarketingWallet(address marketingWallet, uint256 amount) public onlyOwner {
        marketingWallets[marketingWallet] = amount;
    }
}