/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// Develop and deploy the event registration smart contract on Avalanche/Binanace using the following
 	
// Event organizers can sell tickets for the events
 	
// While deploying the contract,the owner of the contract can specify event quota(number of tickets to sell) and price of each ticket
// People interested in attending the event can able to purchase event tickets by sending a transaction to the smart contract
 	
// Event organizers should be able to refund the amount in the case of cancel request

pragma solidity ^0.6.0;

contract EventRegistration{

    address owner;
    uint public totalTickets;
    uint public ticketPrice; 
    address[] public cancelRequests;

    mapping(address => bool) public attendees;
    event TicketPurchased(address indexed _addr);
    event TicketCancelled(address indexed _addr);

    constructor(uint _totalTicketsQuota, uint _ticketPrice) public {
        owner = msg.sender;
        totalTickets = _totalTicketsQuota;  // 1000 tickets
        ticketPrice = _ticketPrice;  // 0.02 BNB per ticket
    }

    fallback() external {
        buyTicket();
    }
 
    modifier onlyOwner{
        require(owner == msg.sender);
        _;
    }
    // only one ticket per address
    // ticket will be purchased only for wxact value of the ticket price
    function buyTicket () public payable {
        require(attendees[msg.sender] == false, "already purchased"); 
        require(msg.value == ticketPrice, "Bad Amount"); 
 
            attendees[msg.sender]= true; 
            totalTickets--;
        emit TicketPurchased(msg.sender);
    }

    // refund amount will be directly sent to attendees on request
    function cancelTicket () public payable {
        require(attendees[msg.sender] == true, "you dont have any tickets"); 
        require(address(this).balance >= ticketPrice, "Low balance");

        msg.sender.transfer(ticketPrice);
        attendees[msg.sender] = false;
        totalTickets++;

        emit TicketCancelled(msg.sender);
         
    }

    // array of users requested for cancellation -> organizer can send refund manually
    function cancelRequest() external {
        require(attendees[msg.sender] == true, "you dont have any tickets"); 
        
        cancelRequests.push(msg.sender);
        attendees[msg.sender] = false;
        totalTickets++;

        emit TicketCancelled(msg.sender); 
    } 

}