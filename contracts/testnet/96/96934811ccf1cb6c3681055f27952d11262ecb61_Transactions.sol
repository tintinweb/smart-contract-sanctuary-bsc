/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
contract Transactions{
    uint256 TransactionsCount;
    event Transfer(address _from ,address _receiver ,uint __amount,string _message,uint _timestamp, string _keyword);
    struct TransferStruct{
        address sender;
        address receiver;
        uint amount;
        string message;
        uint timestamp;
        string keyword;
    }
    TransferStruct[] transactions;

    function addToBlockchain(address payable receiver, uint amount, string memory message, string memory keyword) public{
        TransactionsCount+=1;
        transactions.push(TransferStruct(msg.sender,receiver,amount,message,block.timestamp,keyword));
        emit Transfer(msg.sender,receiver,amount,message,block.timestamp,keyword);
    }
    function getAllTransactions() public view returns (TransferStruct[] memory){
        return transactions;
    }
    function getTransactionsCount() public view returns (uint256){
        return TransactionsCount;
    }
}