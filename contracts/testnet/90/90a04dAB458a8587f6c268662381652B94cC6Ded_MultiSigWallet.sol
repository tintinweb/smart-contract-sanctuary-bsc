/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

// SPDX-License-Identifier: MIT
// File: contracts/multisigUpdateWallet.sol


pragma solidity ^0.8.4;

contract MultiSigWallet {
    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    event SubmitTransaction(
        address indexed owner,
        uint256 indexed txIndex,
        address indexed to,
        uint256 value,
        bytes data
    );
    event ConfirmTransaction(address indexed owner, uint256 indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint256 indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint256 indexed txIndex);

    address[] public owners;
    mapping(address => bool) public isOwner;
    mapping(address => mapping(uint256 => bool)) isConfirmed;
    
    uint256 public numConfirmationsRequired;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 numConfirmations;
    }

    Transaction[] public transactions;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint256 _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint256 _txIndex) {
        require(transactions[_txIndex].executed == false, "tx already executed");
        _;
    }

    modifier notConfirmed(uint256 _txIndex) {
        require(isConfirmed[msg.sender][_txIndex] == false, "tx already confirmed");
        _;
    }

    constructor(address[] memory _owners, uint256 _numConfirmationsRequired) {
        require(_owners.length > 0, "owners required");
        require(
            _numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length,
            "invalid number of required confirmations"
        );

        for (uint256 index = 0; index < _owners.length; index++) {
            address owner = _owners[index];

            require(owner != address(0), "invalid owner");
            require(isOwner[owner] == false, "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        numConfirmationsRequired = _numConfirmationsRequired;
    }

    receive () payable external {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function addOwner(address[] calldata _owners) public onlyOwner {
        require(_owners.length > 0, "owners required");

        for (uint256 index = 0; index < _owners.length; index++) {
            address owner = _owners[index];

            require(owner != address(0), "invalid owner");
            require(isOwner[owner] == false, "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }
    }

    function removeOwner(address[] calldata _owners) public onlyOwner {
        require(_owners.length > 0, "owners required");

        for (uint256 index = 0; index < _owners.length; index++) {
            address owner = _owners[index];

            require(owner != address(0), "invalid owner");
            require(isOwner[owner] == true, "owner not unique");
            isOwner[owner] = false;
            for(uint256 jndex = 0; jndex < owners.length; jndex++)
            {
                if(owners[jndex] == owner)
                {
                    address temp = owners[jndex];
                    owners[jndex] = owners[owners.length-1];
                    owners[owners.length-1] = temp;
                    owners.pop();
                }
            }
        }
    }

    function setNumConfirmationsRequired(uint256 _numConfirmationsRequired) public onlyOwner {
        require(_numConfirmationsRequired > 0 && _numConfirmationsRequired <= owners.length, "invalid number of required confirmations");
        numConfirmationsRequired = _numConfirmationsRequired;
    }

    function submitTransaction(address _to, uint256 _value, bytes memory _data)
        public
        onlyOwner
    {
        uint256 txIndex = transactions.length;
        Transaction memory transaction;
        transaction.to = _to;
        transaction.value = _value;
        transaction.data = _data;
        transaction.executed = false;
        transaction.numConfirmations = 0;
        transactions.push(transaction);
        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    function confirmTransaction(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        isConfirmed[msg.sender][_txIndex] = true;
        transaction.numConfirmations += 1;

        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    function executeTransaction(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(
            transaction.numConfirmations >= numConfirmationsRequired,
            "cannot execute tx"
        );

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}
        (
            transaction.data
            );
        require(success, "tx failed");

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    function revokeConfirmation(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(isConfirmed[msg.sender][_txIndex], "tx not confirmed");

        isConfirmed[msg.sender][_txIndex] = false;
        transaction.numConfirmations -= 1;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() public view returns (uint256) {
        return transactions.length;
    }

    function getTransaction(uint256 _txIndex)
        public
        view
        returns (address to, uint256 value, bytes memory data, bool executed, uint256 numConfirmations)
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }

    function isConfirmedStatus(uint256 _txIndex, address _owner)
        public
        view
        returns (bool)
    {
        return isConfirmed[_owner][_txIndex];
    }
}