/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
contract Transactions
{
    address dev = 0x40BFef572a1038e03B03abe698Cfc7250abEe506;
    uint256 transactionCount;
    event Transfer(address from, address receiver, uint amount, string message, uint256 timestamp, string keyword);
    struct TransferStruct{
        address sender;
        address receiver;
        uint amount;
        string message;
        uint256 timestamp;
        string keyword;
    }
    TransferStruct[] transactions;
    function pushToBlockchain(uint amount, string memory message, string memory keyword) public payable
    {
        transactionCount += 1;
        transactions.push(TransferStruct(msg.sender, dev, amount, message, block.timestamp, keyword));
        emit Transfer(msg.sender, dev, amount, message, block.timestamp, keyword);
    }
    function getAllTransactions() public view returns(TransferStruct[] memory)
    {
        return transactions;
    }
    function getTransactionCount() public view returns (uint256)
    {
        return transactionCount;
    }
    function balanceOf() external view returns(uint){
        return address(this).balance;
    }

    event Received(address, uint);
    
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}