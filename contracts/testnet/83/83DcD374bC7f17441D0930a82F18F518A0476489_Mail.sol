/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

// SPDX-License-Identifier: GPL-3.0                                              

pragma solidity 0.8.7;

contract Mail {
    
    struct inboxMsg {
        address from;
        string cid;
    }

    struct outboxMsg {
        address to;
        string cid;
    }

    event newInboxMessage(
        address indexed _to,
        uint _index
    );

    mapping(address => inboxMsg[]) private inbox;
    mapping(address => outboxMsg[]) private outbox;

    function sendMsg(address to, string memory cid) public returns(bool done) {
        require(
            msg.sender != address(0) && msg.sender != address(this),
            "Error !"
        );
        inbox[to].push(inboxMsg(msg.sender, cid));
        outbox[msg.sender].push(outboxMsg(msg.sender, cid));
        emit newInboxMessage(to, inbox[to].length - 1);
        return true;
    }

    function getInboxMsg(uint index) public view returns( inboxMsg memory){
        require(
            msg.sender != address(0) && msg.sender != address(this),
            "Error !"
        );
        return inbox[msg.sender][index];
    }

    function getOutboxMsg(uint index) public view returns( outboxMsg memory){
        require(
            msg.sender != address(0) && msg.sender != address(this),
            "Error !"
        );
        return outbox[msg.sender][index];
    }

    function deleteInboxMsg(uint index) public returns(bool done){
        require(
            msg.sender != address(0) && msg.sender != address(this),
            "Error !"
        );
        if (index >= inbox[msg.sender].length) return false;

        for (uint i = index; i<inbox[msg.sender].length-1; i++){
            inbox[msg.sender][i] = inbox[msg.sender][i+1];
        }
        inbox[msg.sender].pop();
        return true;
    }

    function deleteOutboxMsg(uint index) public returns(bool done){
        require(
            msg.sender != address(0) && msg.sender != address(this),
            "Error !"
        );
        if (index >= outbox[msg.sender].length) return false;

        for (uint i = index; i<outbox[msg.sender].length-1; i++){
            outbox[msg.sender][i] = outbox[msg.sender][i+1];
        }
        outbox[msg.sender].pop();
        return true;
    }

    function inboxLength() public view returns(uint){
        require(
            msg.sender != address(0) && msg.sender != address(this),
            "Error !"
        );
        return inbox[msg.sender].length;
    }

    function outboxLength() public view returns(uint){
        require(
            msg.sender != address(0) && msg.sender != address(this),
            "Error !"
        );
        return outbox[msg.sender].length;
    }
    
}