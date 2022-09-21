/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract TicketBox {
    address public owner;
    uint16 private latestTicketId = 0;
    struct Ticket {
        uint16 id;
        uint256 price;
    }
    mapping(uint16 => uint256) tickets;
    mapping(uint16 => address) ticketOwner;
    constructor () {
        owner = msg.sender;
    }
    event NewTicketCreated (uint16 _id, uint256 _price);
    event NewTicketBought (uint16 _id, address _buyer);
    event MoneyCollected (uint256 _amount);
    function addNewTicket(uint256 _ticketPrice) public returns (bool) {
        require(msg.sender == owner, "Unauthorized");
        uint16 _newTicketId = latestTicketId+1;
        tickets[_newTicketId] = _ticketPrice;
        emit NewTicketCreated(_newTicketId, _ticketPrice);
        return true;
    }

    function buyTicket(uint16 _ticketId) public payable returns (bool) {
        uint256 _ticketPrice = tickets[_ticketId];
        require(_ticketPrice == msg.value, "Price is not match.");
        ticketOwner[_ticketId] = msg.sender;
        emit NewTicketBought(_ticketId, msg.sender);
        return true;
    }

    function collectMoney () payable public returns (bool) {
        require(msg.sender == owner, "Unauthorized");
        uint256 _balance = address(this).balance;
        payable(owner).transfer(_balance);

        emit MoneyCollected(_balance);
        return true;
    }

    function ownerOf(uint16 _ticketId) public view returns (address) {
        return ticketOwner[_ticketId];
    }

}