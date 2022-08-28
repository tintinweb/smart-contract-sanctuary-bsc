/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.16;

contract decentralizedChat {

mapping (address => uint256) private MessageId ;
mapping (address => string) private message;




function sendMessage (address _messageReciever,string memory _message) public {

MessageId[msg.sender] +=1;

message[_messageReciever] = _message;
}



function viewMessage () external view returns (string memory) {
    return message[msg.sender];


}



function viewer () external view returns(uint256) {
    return MessageId[msg.sender];
}

}