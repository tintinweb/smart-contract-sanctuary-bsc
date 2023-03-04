/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

pragma solidity ^0.8.0;

contract LuckyDraw {
    address public owner;
    uint256 public ticketPrice;
    uint256 public totalTickets;
    uint256 public ticketsSold;
    uint256 public winningTicket;
    bool public isComplete;
    mapping (address => uint256) public ticketsByAddress;
    
    event TicketPurchased(address indexed buyer, uint256 numTickets);
    event WinnerSelected(uint256 winningTicket);
    event ContestComplete(uint256 winningTicket);
    
    constructor(uint256 _ticketPrice, uint256 _totalTickets) {
        owner = msg.sender;
        ticketPrice = _ticketPrice;
        totalTickets = _totalTickets;
        ticketsSold = 0;
        isComplete = false;
    }
    
    function purchaseTickets(uint256 _numTickets) public payable {
        require(msg.value == _numTickets * ticketPrice, "Incorrect amount sent.");
        require(ticketsSold + _numTickets <= totalTickets, "Not enough tickets remaining.");
        
        ticketsByAddress[msg.sender] += _numTickets;
        ticketsSold += _numTickets;
        emit TicketPurchased(msg.sender, _numTickets);
        
        if (ticketsSold == totalTickets) {
            isComplete = true;
            selectWinner();
        }
    }
    
    function selectWinner() private {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, ticketsSold)));
        winningTicket = (randomNumber % totalTickets) + 1;
        emit WinnerSelected(winningTicket);
        emit ContestComplete(winningTicket);
    }
    
    function claimPrize() public {
        require(isComplete, "Contest is not yet complete.");
        require(ticketsByAddress[msg.sender] > 0, "You did not purchase any tickets.");
        require(ticketsByAddress[msg.sender] >= winningTicket, "You did not win the contest.");
        
        uint256 prizeAmount = address(this).balance;
        payable(msg.sender).transfer(prizeAmount);
    }
    
    function withdrawFunds() public {
        require(msg.sender == owner, "Only the owner can withdraw funds.");
        require(isComplete, "Contest is not yet complete.");
        
        uint256 prizeAmount = address(this).balance;
        payable(msg.sender).transfer(prizeAmount);
    }
}