/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

//スマートコントラクト
//-> 自動契約プログラムを実装する(自動販売機を作る)。
//-> ブロックチェーン上で管理するから改ざん不可能

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Transactions {
    //uint -> 符号なし整数型(0~255)
    uint256 transactionCount; //トランザクション(ブロックチェーン)の回数カウント用

    event Transfer(address from, address receiver, uint amount, string message, uint256 timestamp, string keyword);

    //仮想通貨の受け渡し（送信者、受信者、量、メッセージ内容、送信時間、キーワード）
    struct TransferStruct {
        address sender;
        address receiver;
        uint amount;
        string message;
        uint256 timestamp;
        string keyword;
    }

    //仮想通貨受け渡しのためのデータスキーマをトランザクションとして配列として保持
    TransferStruct[] transactions;

    function addToBlockChain(address payable receiver, uint amount, string memory message, string memory keyword) public {
        transactionCount += 1;
        transactions.push(TransferStruct(msg.sender, receiver, amount, message, block.timestamp, keyword));

        emit Transfer(msg.sender, receiver, amount, message, block.timestamp, keyword);
    }
    function getAllTransactions() public view returns (TransferStruct[] memory) {
        return transactions;
    }
    function getTransactionCount() public view returns (uint256) {
        return transactionCount;
    }
}