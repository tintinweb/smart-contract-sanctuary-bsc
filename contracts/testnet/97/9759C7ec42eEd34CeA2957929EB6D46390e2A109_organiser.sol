/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

pragma solidity 0.8.7;

// SPDX-License-Identifier: GPL-3.0

contract organiser{
   

   struct Event{
       address orgniser;
       string name;
       uint date;
       uint price;
       uint ticketCount;
       uint remTicket;
       uint id;
   }

    mapping( uint=>Event) public events;
    mapping( string=> Event) public checkEvents;
    mapping(address=> mapping(uint=>uint)) public tickets;
    uint public totalEvents;

    event recEvents(address creator, string name, uint date, uint price, uint ticketCount, uint id);

    function createEvents(string memory name,uint date, uint price, uint ticketCount, uint id ) public{
        events[totalEvents]= Event(msg.sender, name, date,price, ticketCount, ticketCount, id);
        checkEvents[name]= Event(msg.sender, name, date,price, ticketCount, ticketCount, id);
        totalEvents++;
        emit recEvents(msg.sender,name, date, price,ticketCount, id);
    }

    function buyTickets(uint _id, uint quantity ) public payable{
        require(events[_id].date!=0);
        require(events[_id].date> block.timestamp);
        Event storage _event = events[_id];
        require(msg.value== _event.price*quantity);
        require(_event.remTicket>0);
        _event.remTicket-= quantity;
        tickets[msg.sender][_id]+=quantity;
        
    }

    function transferTicket( uint _id, uint _quantity, address to) public{
        require(events[_id].date!=0);
        require(events[_id].date> block.timestamp);
        require(tickets[msg.sender][_id] >_quantity);
        
        tickets[msg.sender][_id]-= _quantity;
        tickets[to][_id]+=_quantity;
    }

    
}