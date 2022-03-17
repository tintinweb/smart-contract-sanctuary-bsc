pragma solidity 0.8.12;

// SPDX-License-Identifier: MIT

import "./Token.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract Earn_Finance_ICO is Ownable {
    using SafeMath for uint256;

    address public token = 0x2b148D62A4cE231cdDDAC5BF0fe4D9c16B288041;
    address public teamAddress = 0x33Bc71bB9aBf03e08CA43f2506650DEA6fA421F9;

    address[] public users;

    uint256 public tokenPrice = 7e3;
    uint256 public minAmount = 1e17;
    uint256 public maxAmount = 3e20;

    uint256 public totalSoldOut;
    uint256 public totalSoldOutIn_BNB;
    uint256 public totalTokenForSell = 35e24;

    bool public isICOActivated = false;

    mapping (address => uint256) public totalBoughtAmount;
    mapping (address => uint256) public totalInvested;
    mapping (address => bool) public isAnUser;

    function buy() public payable {
        require(isICOActivated, "Earn_Finance_ICO: ICO is not activated..");
        
        uint256 amountOfBNB = msg.value;
        require(amountOfBNB >= minAmount && amountOfBNB <= maxAmount, "Earn_Finance_ICO: Please enter a valid amount..");

        uint256 tokenAmount = amountOfBNB.mul(tokenPrice);
        
        if (!isAnUser[msg.sender]) {
            users.push(msg.sender);
            isAnUser[msg.sender] = true;
        }
        
        if (amountOfBNB > 0) {
            payable(teamAddress).transfer(amountOfBNB);
            Token(token).transferFrom(teamAddress, msg.sender, tokenAmount);
            totalBoughtAmount[msg.sender] = totalBoughtAmount[msg.sender].add(tokenAmount);
            totalInvested[msg.sender] = totalInvested[msg.sender].add(amountOfBNB);
            totalSoldOutIn_BNB = totalSoldOutIn_BNB.add(amountOfBNB);
            totalSoldOut = totalSoldOut.add(tokenAmount);
        }
    }

    function balanceOf(address user) public view returns (uint256) {
        return user.balance;
    }

    function numberOfUsers() public view returns (uint256) {
        return users.length;
    }

    function totalSoldOutEARN() public view returns (uint256) {
        return totalSoldOut;
    }

    function remainingTokenForSell() public view returns (uint256) {
        return totalTokenForSell.sub(totalSoldOut);
    }

    function _totalInvested(address user) public view returns (uint256) {
        return totalInvested[user];
    }

    function totalInvestedBNB() public view returns (uint256) {
        return totalSoldOutIn_BNB;
    }

    function _totalBoughtAmount(address userAdd) public view returns (uint256) {
        return totalBoughtAmount[userAdd];
    }

    function ActiveTheICO() public onlyOwner {
        require(!isICOActivated, "Earn_Finance_ICO: ICO alredy activated..");
        isICOActivated = true;
    }

    function DeactiveTheICO() public onlyOwner {
        require(isICOActivated, "Earn_Finance_ICO: ICO alredy deactivated..");
        isICOActivated = true;
    }

    function updateTokenPrice(uint256 newPrice) public onlyOwner {
        tokenPrice = newPrice;
    }

    function updateMinimumAmount(uint256 newAmount) public onlyOwner {
        require(newAmount != minAmount, "Earn_Finance_ICO: The minimum amount is the same that you enterd..");
        minAmount = newAmount;
    }

    function updateMaximumAmount(uint256 newAmount) public onlyOwner {
        require(newAmount != maxAmount, "Earn_Finance_ICO: The maximum amount is the same that you enterd..");
        maxAmount = newAmount;
    }

    function updateEARN_TokenAddress(address earnAdd) public onlyOwner {
        require(token != token, "Earn_Finance_ICO: The EARN address is the same that you enterd..");
        token = earnAdd;
    }

    function updateTeam_Address(address teamAdd) public onlyOwner {
        require(teamAddress != teamAdd, "Earn_Finance_ICO: The team address is the same that you enterd..");
        teamAddress = teamAdd;
    }

    function transferAnyBEP20Token(address _token, address to, uint256 amount) public onlyOwner {
        Token(_token).transfer(to, amount);
    }

    receive() external payable {
        buy();
    }
}