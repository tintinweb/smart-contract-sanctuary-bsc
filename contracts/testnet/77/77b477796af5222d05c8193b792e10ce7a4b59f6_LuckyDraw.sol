/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

pragma solidity ^0.8.0;

contract LuckyDraw {
    address payable public developerAddress;
    uint256 public ticketPrice;
    uint256 public totalTicketsSold;
    uint256 public totalPrizeAmount;
    mapping(address => uint256) public ticketCounts;
    address[] public participants;

    constructor(uint256 _ticketPrice) {
        developerAddress = payable(msg.sender);
        ticketPrice = _ticketPrice;
        totalTicketsSold = 0;
        totalPrizeAmount = 0;
    }

    function buyTickets(uint256 _numTickets) public payable {
        require(msg.value == _numTickets * ticketPrice, "Insufficient funds.");
        require(_numTickets > 0, "Number of tickets must be greater than 0.");
        
        // Add tickets to buyer's ticket count
        ticketCounts[msg.sender] += _numTickets;

        // Add buyer to list of participants if they haven't bought tickets before
        if (ticketCounts[msg.sender] == _numTickets) {
            participants.push(msg.sender);
        }

        // Update total tickets sold and prize amount
        totalTicketsSold += _numTickets;
        totalPrizeAmount += msg.value;
    }

    function drawWinner() public {
        require(totalTicketsSold > 0, "No tickets sold yet.");

        // Generate random index for selecting winner
        uint256 winnerIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, participants.length))) % participants.length;
        address payable winner = payable(participants[winnerIndex]);

        // Transfer 90% of prize amount to winner
        uint256 prizeAmount = totalPrizeAmount * 9 / 10;
        winner.transfer(prizeAmount);

        // Transfer 10% of prize amount to developer
        uint256 developerFee = totalPrizeAmount - prizeAmount;
        developerAddress.transfer(developerFee);

        // Reset the state variables for the next round
        totalTicketsSold = 0;
        totalPrizeAmount = 0;
        for (uint256 i = 0; i < participants.length; i++) {
            ticketCounts[participants[i]] = 0;
        }
        delete participants;
    }
}