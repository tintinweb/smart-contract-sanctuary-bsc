/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

// contracts/Deal.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract SmartDeal {

    enum State { Created, Started, Canceled, Completed }

    struct Deal {
        State state;
        string description;
        address payable creator;
        uint price;
        address payable client;
    }

    Deal[] public deals;

    function create(string memory description, uint price) external returns (uint) {
        uint id = deals.length;
        deals.push(Deal({
            state: State.Created,
            description: description,
            creator: payable(msg.sender),
            price: price,
            client: payable(address(0))
        }));
        return id;
    }

    function start(uint id) external payable {
        Deal storage deal = deals[id];
        require(deal.state == State.Created, 'Deal not available');
        require(msg.value == deal.price, 'Wrong amount');
        require(msg.sender != deal.creator, 'This deal is yours');
        deal.client = payable(msg.sender);
        deal.state = State.Started;
    }

    function cancelByCreator(uint id) external {
        Deal storage deal = deals[id];
        require(deal.state == State.Created, 'State is not "Created"');
        require(msg.sender == deal.creator, "This deal isn't yours");
        deal.state = State.Canceled;
    }

    function cancelByClient(uint id) external {
        Deal storage deal = deals[id];
        require(deal.state == State.Started, 'State is not "Started"');
        require(msg.sender == deal.client, "You aren't client");
        deal.client.transfer(deal.price);
        deal.state = State.Created;
    }

    /* When client has reseived and tested product */
    function complete(uint id) external {
        Deal storage deal = deals[id];
        require(deal.state == State.Started, 'State is not "Started"');
        require(msg.sender == deal.client, "You aren't client");
        deal.creator.transfer(deal.price);
        deal.state = State.Completed;
    }
}