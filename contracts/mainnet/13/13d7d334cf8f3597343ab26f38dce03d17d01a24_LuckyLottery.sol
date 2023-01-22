/**
 *Submitted for verification at BscScan.com on 2023-01-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LuckyLottery {
    address public marketingWallet;
    address developerWallet = 0x2EE0570de8421a01E2896B51e02F4a3C0EA92035;
    address[] ticketHolders; // array of addresses that have purchased tickets
    uint ticketPrice;
    uint ticketCount;

    constructor() {
        marketingWallet = 0xD78aB5e5FDD68ae50dB302bdFAC209E3448473F7;
        ticketPrice = 1000000000000000000;  //0.01 BNB
    }

    function buyTicket() public payable {
        require(msg.value == ticketPrice, "Incorrect ticket price.");
        ticketHolders.push(msg.sender);
        ticketCount++;
    }

    function selectWinner() public {
        require(ticketCount >= 20, "Not enough tickets sold.");
        uint randomIndex = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % ticketCount;
        address winner = ticketHolders[randomIndex];
        payable(winner).transfer(15 * ticketPrice * 10 ** 18);
        ticketCount = 0;
        delete ticketHolders;
        payable(marketingWallet).transfer(address(this).balance * 9 / 10);
        payable(developerWallet).transfer(address(this).balance * 1 / 10);
    }
    function setMarketingWallet(address _marketingWallet) public {
        require(msg.sender == developerWallet, "Only the developer can change the marketing wallet.");
        marketingWallet = _marketingWallet;
    }
}