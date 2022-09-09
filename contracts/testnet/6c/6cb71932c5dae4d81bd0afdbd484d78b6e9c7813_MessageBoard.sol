/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

contract MessageBoard {
    //specs:
    //- add a message
    //- see messages from other users
    //- delete messages that you posted
    //- give yourself a nickname

    //important:
    //- messages have unique ids

    struct Message {
        uint256 messageId;
        string text;
        address authorAddress; 
        uint date;
    }

    Message[] public messages;
    mapping(uint256 => Message) internal idToMessage;
    uint256 internal idCounter;
    mapping(address => string) public addressToNickname;

    //view messages
    function getMessages() public view returns(Message[] memory) {
        return messages;
    }

    //create new message
    function addMessage(string memory _text) public {
        //generate id
        uint256 messageId = idCounter;
        idCounter ++;

        //generate date
        uint currentDate = now;

        Message memory newMessage = Message(messageId, _text, msg.sender, currentDate);
        messages.push(newMessage);
        idToMessage[messageId] = newMessage;
    }

    //delete a message
    function deleteMessage(uint256 _messageId) public returns(string memory) {
        //get message that corresponds to the id
        Message memory message = idToMessage[_messageId];

        //check if addresses match up
        if (msg.sender == message.authorAddress) {
            //Note: id is the same as index in the messages array
            //Also: this will create a blank spot in the array. Need to handle that on the front-end.
            delete messages[_messageId];
            return "success";
        } else {
            return "error";
        }
    }

    // Add/update your nickname
    function updateNickname(string memory _nickname) public {
        addressToNickname[msg.sender] = _nickname;
    }
}