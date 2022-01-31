/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

//SPDX-License-Identifier: MIT

/**
   multisig wallet
*/

pragma solidity ^0.8.11;

contract MultiSigWallet {
    event Deposit(address indexed sender, uint256 amount);
    event Submit(uint256 indexed txId);
    event Approve(address indexed owner, uint256 indexed txId);
    event Revoke(address indexed owner, uint256 indexed txId);
    event Execute(uint256 indexed txID);
    event OwnerAdded(address indexed);
    event OwnerRemoved(address indexed);

    struct Transaction {
       address to;
       uint256 value;
       bytes data;
       bool executed;
    } 

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public required;
    
    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public approved;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    modifier txExist(uint256 _txId){
        require(_txId < transactions.length, "Tx does not exist");
        _;
    }

    modifier notApproved(uint _txId){
        require(!approved[_txId][msg.sender], "Tx already approved");
        _;
    }

    modifier notExecuted(uint256 _txId){
        require(!transactions[_txId].executed, "Tx already executed");
        _;
    }

    constructor() {
        isOwner[msg.sender] = true;
        owners.push(msg.sender);
        required = owners.length;
    }
  
    receive() external payable{
        emit Deposit(msg.sender, msg.value);
    }
    
    function submit(address _to, uint256 _value, bytes calldata _data)
        external
        onlyOwner
    {
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false
        })); 
        emit Submit(transactions.length - 1);
    }
 
    function approve(uint256 _txId)
        external
        onlyOwner
        txExist(_txId)
        notApproved(_txId)
        notExecuted(_txId)
    {
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }
  
    function _getApprovalCount(uint256 _txId) private view returns (uint256 count){
        for (uint256 i; i < owners.length; i++) {
            if (approved[_txId][owners[i]]) {
                count += 1;
            }
        }
    }
 
    function execute(uint256 _txId) external txExist(_txId) notExecuted(_txId){
        require(_getApprovalCount(_txId) >= required, "Approvals bellow required");
        Transaction storage transaction = transactions[_txId];
        transaction.executed = true;
        (bool success,) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, "Tx failed");
        emit Execute(_txId);
    }
  
    function revoke(uint256 _txId) external onlyOwner txExist(_txId) notExecuted(_txId){
        require(approved[_txId][msg.sender], "Tx not approved");
        emit Revoke(msg.sender, _txId);
    }

    function addOwner(address newOwner) external onlyOwner {
        require(!isOwner[newOwner], "Address already owner"); 
        require(newOwner != address(0), "Invalid owner");
        isOwner[newOwner] = true;
        owners.push(newOwner);
        required += 1;
        emit OwnerAdded(newOwner);
    }

    function removeOwner(address oldOwner) external onlyOwner {
        require(isOwner[oldOwner], "Address not owner");
        isOwner[oldOwner] = false;
        required -= 1;
        emit OwnerRemoved(oldOwner);
    }
}