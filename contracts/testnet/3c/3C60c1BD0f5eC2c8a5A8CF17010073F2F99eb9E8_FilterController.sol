/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8;

contract FilterController {
    address[] public signatories;
    mapping(address => bool) public isSignatory;

    uint public approvalsRequired;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numApprovals;
    }

    mapping(uint => mapping(address => bool)) public isConfirmed;

    Transaction[] public transactions;

    modifier onlySignatories() {
        require(isSignatory[msg.sender], "FilterController: FORBIDDEN");
        _;
    }

    constructor(address[] memory _initialSignatories) {
        require(_initialSignatories.length >= 2);

        for (uint i = 0; i < _initialSignatories.length; i++) {
            address initialSignatory = _initialSignatories[i];

            isSignatory[initialSignatory] = true;
            signatories.push(initialSignatory);
        }

        approvalsRequired = _initialSignatories.length / 2;
    }

    receive() external payable {}

    function proposeTransaction(address _to, uint _value, bytes memory _data) public onlySignatories {
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            numApprovals: 0
        }));
    }

    function approveTransaction(uint _txIndex) public onlySignatories {
        require(_txIndex < transactions.length, "FilterController: TX_DOESNT_EXIST");
        require(!isConfirmed[_txIndex][msg.sender], "FilterController: TX_ALREADY_CONFIRMED");
        require(!transactions[_txIndex].executed, "FilterController: TX_ALREADY_EXECUTED");

        Transaction storage transaction = transactions[_txIndex];
        transaction.numApprovals += 1;
        isConfirmed[_txIndex][msg.sender] = true;
    }

    function executeTransaction(uint _txIndex) public onlySignatories {
        require(_txIndex < transactions.length, "FilterController: TX_DOESNT_EXIST");
        require(!transactions[_txIndex].executed, "FilterController: TX_ALREADY_EXECUTED");
        
        Transaction storage transaction = transactions[_txIndex];

        require(transaction.numApprovals >= approvalsRequired, "FilterController: NOT_ENOUGH_APPROVALS");
        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "FilterController: TX_FAILED");
    }

    function addSignatory(address _signatoryAddress) internal {
        signatories.push(_signatoryAddress);
        approvalsRequired = signatories.length / 2;
    }

    function removeSignatory(address _signatoryAddress) internal {
        uint indexForRemoval;

        for (uint i = 0; i < signatories.length; i++) {
            if (signatories[i] == _signatoryAddress) {
                indexForRemoval = i;
            } 

            if (i >= indexForRemoval && i < signatories.length - 1) {
                signatories[i] = signatories[i + 1];
            }                  
        }

        signatories.pop();
        approvalsRequired = signatories.length / 2;
    }

    function getTransactionInfo(uint _txIndex) public view returns (address, uint, bytes memory, bool, uint) {
        Transaction storage transaction = transactions[_txIndex];

        return (transaction.to, transaction.value, transaction.data, transaction.executed, transaction.numApprovals);
    }
}