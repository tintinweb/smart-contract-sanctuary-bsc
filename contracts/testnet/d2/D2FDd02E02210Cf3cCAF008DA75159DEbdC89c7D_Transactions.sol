/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

// File: contracts/1_Storage.sol



pragma solidity ^0.8.0;

contract Transactions {

    //Intializing Message Count
    uint256 MessageCount;

    //Event TRANFER DECLARATION
    event Transfer(address from, string ciphertext, string salt, uint256 timestamp);

    //MESSAGE STRUCT DECALRATION
  
    struct MessageStruct {
        address sender;
        string ciphertext;
        string salt;
        uint256 timestamp;
    }

    //MAKE A OBJECT 
    MessageStruct[] messages;

    //Where we add msg to block chain
    function addToBlockchain(string memory ciphertext ,string memory salt) public {
        MessageCount += 1;
        messages.push(MessageStruct(msg.sender,ciphertext,salt,block.timestamp));

        emit Transfer(msg.sender,ciphertext,salt,block.timestamp);
    }

    //GET ALL MESSAGES 

    function getAllTransactions() public view returns (MessageStruct[] memory) {
        return messages;
    }



    //GET MESSAGES

    function getTransactionCount() public view returns (uint256) {
        return MessageCount;
    }

  

   

}