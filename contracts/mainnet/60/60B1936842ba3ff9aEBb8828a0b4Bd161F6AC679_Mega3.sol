/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// SPDX-License-Identifier: GPL-3.0

/*
Mega Decentralized Financial Participation Programs (MegaDFP)
Mega3 is a smart contract provided by MegaDFP which is designed to act as an automatic financial participation system without any human control.
Find more on official links below:
    Website: https://megadfp.github.io/Mega3
    Github: https://github.com/megadfp/Mega3
    Twitter: https://twitter.com/MegaDFP
*/

pragma solidity ^0.8.0;

contract Mega3 {

    address internal owner;
    address internal zero = address(0);
    address[] public index;
    uint public cursor = 0; 
    uint public ticket = 50000000 gwei;
    uint public circulating = 0;

    struct Node {
        bool registered;
        uint children;
        uint paid;
        bool cashback;
        address account;
        address parent;
        address child1;
        address child2;
        address child3;
    }

    mapping (address => Node) public nodes;

    event Info(uint participants, uint circulating);
    event Join(address account, uint value, uint timestamp);
    event Sent(address account, uint value, uint timestamp);
    event Fail(address account, uint value, uint timestamp);

    modifier adminOnly {
        require(msg.sender == owner, "Permission denied");
        _;
    }

    constructor(){
        owner = msg.sender;
        nodes[msg.sender] = Node(true, 0, 0, false, owner, zero, zero, zero, zero);
        index.push(msg.sender);
    }

    function entrust(address _owner) public adminOnly {
        owner = _owner;
    }

    function setticket(uint price) public adminOnly {
        ticket = price;
    }

    function participants() public view returns (uint) {
        return index.length;
    }

    function send(address to, uint amount) private returns (bool success) {
        (bool sent,) = to.call{value: amount}("");
        if (sent) {
            nodes[to].paid += amount;
            emit Sent(to, amount, block.timestamp);
            success = true;
        }
        else {
            emit Fail(to, amount, block.timestamp);
            success = false;
        }
    }

    // Manually join the participant to specific parent
    function join(address parent) public payable {
        require(parent != zero, "Parent can not be zero address");
        require(msg.value == ticket, "You have to pay the entrance ticket");
        require(nodes[msg.sender].registered == false, "Your account is already registered");
        if (nodes[parent].child1 == zero) nodes[parent].child1 = msg.sender;
        else if (nodes[parent].child2 == zero) nodes[parent].child2 = msg.sender;
        else if (nodes[parent].child3 == zero) nodes[parent].child3 = msg.sender;
        else revert("Parent does not have empty slot");
        nodes[msg.sender] = Node(true, 0, 0, false, msg.sender, parent, zero, zero, zero);
        index.push(msg.sender);
        // Find ancestors
        address L3 = nodes[parent].parent;
        address L4 = nodes[L3].parent;
        address L5 = nodes[L4].parent;
        address L6 = nodes[L5].parent;
        address L7 = nodes[L6].parent;
        address L8 = nodes[L7].parent;
        address L9 = nodes[L8].parent;
        // Cashback if parent has three children
        if (nodes[parent].cashback == false && nodes[parent].child1 != zero && nodes[parent].child2 != zero && nodes[parent].child3 != zero) {
            (bool sent) = send(parent, ticket * 99 / 100);
            if (sent) nodes[parent].cashback = true;
        }
        // Ancestors rewards
        else {
            if (L3 != zero) send(L3, ticket * 7 / 100);
            if (L5 != zero) send(L5, ticket * 14 / 100);
            if (L7 != zero) send(L7, ticket * 28 / 100);
            if (L9 != zero) send(L9, ticket * 50 / 100);
        }
        // Donation fees
        send(owner, address(this).balance);
        // Add a child to each ancestor
        nodes[parent].children++;
        if (L3 != zero) nodes[L3].children++;
        if (L4 != zero) nodes[L4].children++;
        if (L5 != zero) nodes[L5].children++;
        if (L6 != zero) nodes[L6].children++;
        if (L7 != zero) nodes[L7].children++;
        if (L8 != zero) nodes[L8].children++;
        if (L9 != zero) nodes[L9].children++;
        unchecked { circulating += ticket; }
        emit Join(msg.sender, ticket, block.timestamp);
        emit Info(participants(), circulating);
    }

    // Find a parent with empty child slot
    function autojoin() public payable {
        Node memory node = nodes[index[cursor]];
        if (node.child1 == zero || node.child2 == zero || node.child3 == zero) join(index[cursor]);
        else {
            cursor++;
            autojoin();
        }
    }

    // Send participation fee directly to the smart contract address
    fallback() external payable {
        autojoin();
    }

    receive() external payable {
        autojoin();
    }

}