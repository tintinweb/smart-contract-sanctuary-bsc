/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Multisig {

    struct transaction {
        address from;
        address to;
        uint256 amount;
        uint8 approvals;
        bool isCompleted;     
    }

    address[] public approvers;
    mapping(address => bool) public isApproverExist;
    mapping(address => mapping(uint256 => bool)) public approvecheck;
    mapping(uint256 => transaction) public transactionslist;
    uint8 public totalTransactioncount;

    modifier notOwner() {
        require(!isApproverExist[msg.sender], "Approvers cannot submit the transactions");
        _;
    }

    modifier onlyApprover() {
        require(isApproverExist[msg.sender], "Only approver can approve, revoke and execute the transactions");
        _;
    }

    modifier transactionExist(uint256 transactionid) {
        require(transactionslist[transactionid].approvals >= 0, "Transaction does not exist");
        _;
    }

    modifier checkApprovalLength(uint256 transactionid) {
        require(transactionslist[transactionid].approvals <= 2, "Approval limit already reached");
        _;
    }

    modifier checkAlreadyApproved(uint256 transactionid) {
        require(!approvecheck[msg.sender][transactionid], "Already approved");
        _;
    }

    modifier isTransactionapproved(uint256 transactionid) {
        require(!transactionslist[transactionid].isCompleted, "Already completed");
        _;
    }

    event eSubmitTransaction(address sender, uint256 transactionid);

    constructor (address[] memory _approvers, uint approvercount) {
        require(_approvers.length > 0, "Invalid approvers list");
        require(approvercount == _approvers.length, "approver count should be matched approvers list");
        for (uint i = 0; i < _approvers.length; i++) {
            require(!isApproverExist[_approvers[i]], "Duplicate approver address");
            isApproverExist[_approvers[i]] = true;
            approvers.push(_approvers[i]);
        }
    }

    function getApproversCount() external view returns(uint) {
        return approvers.length;
    }

    function submitTransaction(address _from, address _to, uint amount) external notOwner returns (uint256){
        require(msg.sender == _from, "Sender should be match");
        uint randomNumber = rand();
        transactionslist[randomNumber] = transaction(_from, _to, amount * 10 ** 18, 0, false);
        totalTransactioncount++;
        emit eSubmitTransaction(msg.sender, randomNumber);
        return randomNumber;
    }

    function getApprovalCount(uint256 transactionid) external view returns(uint) {
        return transactionslist[transactionid].approvals;
    }

    function approveTransaction(uint256 transactionid) external 
        onlyApprover 
        transactionExist(transactionid)
        checkApprovalLength(transactionid)
        checkAlreadyApproved(transactionid)
        isTransactionapproved(transactionid)
        {
            transactionslist[transactionid].approvals++;
            approvecheck[msg.sender][transactionid] = true;
    }

    function revokeApproval(uint256 transactionid) external 
        onlyApprover 
        transactionExist(transactionid)
        checkAlreadyApproved(transactionid)
        isTransactionapproved(transactionid)
        {
            transactionslist[transactionid].approvals--;
            approvecheck[msg.sender][transactionid] = false;
    }

    function getTransaction(uint256 transactionid) external view returns(
        address from,
        address to,
        uint256 amount,
        uint8 approvals
    ) {
        transaction storage trans = transactionslist[transactionid];
        return (
            trans.from,
            trans.to,
            trans.amount,
            trans.approvals
        );
    }

    function executeTransaction(uint256 transactionid) external payable
        transactionExist(transactionid)
        isTransactionapproved(transactionid)
        {
            require(transactionslist[transactionid].from == msg.sender, "sender should be match");
            require(transactionslist[transactionid].approvals == 2, "Approval limit does not reached");
            transaction storage trans = transactionslist[transactionid];
            require(msg.value == trans.amount, "Transaction amount should be same");
            payable(trans.to).transfer(trans.amount);
            totalTransactioncount--;
            transactionslist[transactionid].isCompleted = true;
    }

    function rand()
    internal
    view
    returns(uint256)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
            block.number
        )));

        return (seed - ((seed / 1000) * 1000));
    }
}