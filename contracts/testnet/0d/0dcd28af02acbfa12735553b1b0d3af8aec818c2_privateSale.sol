/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract privateSale {
    uint256 transactionCount;
    event Transfer(
        address from,
        address receiver,
        uint amount,
        string name,
        string telegram,
        string twitter,
        uint256 timestamp
    );

    struct TransferStruct {
        address sender;
        address receiver;
        uint amount;
        string name;
        string telegram;
        string twitter;
        uint256 timestamp;
    }

    TransferStruct[] transactions;

    function Submit(
        address payable receiver,
        uint amount,
        string memory name,
        string memory telegram,
        string memory twitter
    ) public {
        transactionCount += 1;
        transactions.push(
            TransferStruct(
                msg.sender,
                receiver,
                amount,
                name,
                telegram,
                twitter,
                block.timestamp
            )
        );
        emit Transfer(
            msg.sender,
            receiver,
            amount,
            name,
            telegram,
            twitter,
            block.timestamp
        );
    }

    function getAllTransactions()
        public
        view
        returns (TransferStruct[] memory)
    {
        return transactions;
    }

    function getTransactionCount() public view returns (uint256) {
        return transactionCount;
    }
}