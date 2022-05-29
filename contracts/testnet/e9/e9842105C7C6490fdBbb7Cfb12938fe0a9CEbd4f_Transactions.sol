/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Transactions {
    uint256 transactionCount;
    address public owner;

    modifier checkOwner(){
        require(msg.sender==owner, "[1] You are not owner.");
        _;
    }

    event Transfer(address from, address receiver, uint amount, string message, uint256 timestamp, string keyword);

    struct TransferStruct {
        address sender;
        address receiver;
        uint amount;
        string message;
        uint256 timestamp;
        string keyword;
    }
    TransferStruct[] transactions;

    function addToBlockchain(address payable receiver, uint amount, string memory message, string memory keyword ) public{
        transactionCount +=1;
        transactions.push(TransferStruct(msg.sender, receiver, amount, message, block.timestamp, keyword));
        emit Transfer(msg.sender, receiver, amount, message, block.timestamp, keyword);
    }

    function withdraw_BNB(address receiver, uint amount) public checkOwner{
        require(address(this).balance>amount, "BNB balance is zero");
        payable(receiver).transfer(amount);
    }

     function getAllTransactions() public view returns (TransferStruct[] memory){
         return transactions;

    }

     function getTransactionsCount() public view returns (uint256) {
        return transactionCount;
     }

   

     

}