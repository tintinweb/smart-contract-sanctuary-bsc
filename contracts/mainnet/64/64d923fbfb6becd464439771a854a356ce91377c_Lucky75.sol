/**
 *Submitted for verification at BscScan.com on 2023-01-25
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract Lucky75 {
    address payable public marketingWallet;
    address payable public devWallet;
    uint256 public ticketPrice;
    uint256 public numberOfTickets;
    address[] public ticketHolders;
    event TicketBought(address indexed holder, uint256 ticketPrice);
    event WinnerSelected(address indexed winner, uint256 prize);
    event Burned(address indexed holder);


    function setInitialValues() public {
        require(msg.sender == msg.sender, "Only owner can set initial values");
        ticketPrice = 10000000000000000; // 0.01 BNB
        numberOfTickets = 0;
    }

    function setMarketingWallet(address payable _marketingWallet) public {
        require(msg.sender == msg.sender, "Only owner can set Marketing Wallet address");
        marketingWallet = _marketingWallet;
    }

    function setDevWallet(address payable _devWallet) public {
        require(msg.sender == msg.sender, "Only owner can set Dev Wallet address");
        devWallet = _devWallet;
    }

    function setTicketPrice(uint256 _ticketPrice) public {
        require(msg.sender == msg.sender, "Only owner can set ticket price");
        ticketPrice = _ticketPrice;
    }

    function setNumberOfTickets(uint256 _numberOfTickets) public {
        require(msg.sender == msg.sender, "Only owner can set number of tickets");
        numberOfTickets = _numberOfTickets;
    }

    function buyTicket() external payable {
        require(msg.value >= ticketPrice, "The BNB sent must greater or equal the ticket price");
        ticketHolders.push(msg.sender);
        numberOfTickets++;
        emit TicketBought(msg.sender, ticketPrice);
        if (numberOfTickets == 20) {
            selectWinner();
        }
    }

    function selectWinner() private {
        require(numberOfTickets >= 20, "Not enough tickets sold.");
        uint256 winnerIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % numberOfTickets;
        address winner = ticketHolders[winnerIndex];
        uint256 prize = ticketPrice * numberOfTickets * 15 / 20;
        payable (winner).transfer(prize);
        emit WinnerSelected(winner, prize);
        devWallet.transfer(ticketPrice * numberOfTickets * 1 / 40);
        marketingWallet.transfer(ticketPrice * numberOfTickets * 1 / 40);
        burnTickets();
    }

    function burnTickets() private {
        delete ticketHolders;
        numberOfTickets = 20;
    }
}