/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract MessageStorage {

    struct Message {
        address sender;
        string content;
        uint256 at;
    }

    Message[] public messages;

    event MessageStored(address sender, string content, uint256 at);

    function storeMessage(string memory content) external {
        Message memory newMessage = Message({
            sender: msg.sender,
            content: content,
            at: block.timestamp
        });
        messages.push(newMessage);
        emit MessageStored(msg.sender,content, block.timestamp);
    }


    function getAllMessages() public view returns(Message[] memory) {
        return messages;
    }
}