/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

// SPDX-License-Identifier: MIT
//
pragma solidity ^0.8.14;

contract OwnerMultiSigWallet {
    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    event Submit(uint256 indexed txId);
    event Approve(address indexed owner, uint256 indexed txId);
    event Execute(uint256 indexed txId);
    event Revoke(address indexed owner, uint256 indexed txId);
    event OwnerChange(uint8 indexed ownerIndex, address indexed oldOwner, address indexed newOwner);

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 numConfirmations;
    }
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public required;

    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public approved;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not an owner");
        _;
    }

    modifier txExists(uint256 _txId) {
        require(_txId < transactions.length, "tx does not exist");
        _;
    }

    modifier notApproved(uint256 _txId) {
        require(!approved[_txId][msg.sender], "tx already approved");
        _;
    }

    modifier notExecuted(uint256 _txId) {
        require(!transactions[_txId].executed, "tx already executed");
        _;
    }

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "at least one owner required");
        require(
            _required > 0 && _required <= _owners.length,
            "invalid number of owners"
        );

        for (uint256 i; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "invalid owner address");
            require(!isOwner[owner], "owner is not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        required = _required;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }


    function changeOwner(uint8 _ownerIndex, address _newOwner) public {
        // Owner changing may be performed only by the contract itself
        require (msg.sender == address (this));

        // Make sure new owner is not already an owner
        require (isOwner[_newOwner] == false);

        // Obtain address of existing owner with given index
        address oldOwner = owners[_ownerIndex];

        // Could you think of situation when this is not true?  We could!
        if (oldOwner != _newOwner) {
            // If owner with given index exists
            if (oldOwner != address (0)) {
                // Remove it!
                isOwner[oldOwner] = false;
            } 

            // If new owner is not zero
            if (_newOwner != address (0)) {
                // Add it!
                owners[_ownerIndex] = _newOwner;
                isOwner[_newOwner] = true;
            } 

            // Log OwnerChange event
            emit OwnerChange(_ownerIndex, oldOwner, _newOwner);
        }
    }

    function submitAndApprove(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner {
        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                numConfirmations: 1
            })
        );

        emit Submit(transactions.length - 1);

        // Approve Tx for submit caller
        uint256 _txId = transactions.length - 1;
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    function approve(uint256 _txId)
        external
        onlyOwner
        txExists(_txId)
        notApproved(_txId)
        notExecuted(_txId)
    {
        Transaction storage transaction = transactions[_txId];
        approved[_txId][msg.sender] = true;
        transaction.numConfirmations += 1;

        emit Approve(msg.sender, _txId);
    }

    function execute(uint256 _txId)
        external
        onlyOwner
        txExists(_txId)
        notExecuted(_txId)
    {
        Transaction storage transaction = transactions[_txId];
        require(
            transaction.numConfirmations >= required,
            "approvals is less than required"
        );

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );

        require(success, "tx failed");

        emit Execute(_txId);
    }

    function revoke(uint256 _txId)
        external
        onlyOwner
        txExists(_txId)
        notExecuted(_txId)
    {
        require(approved[_txId][msg.sender], "tx not approved");
        Transaction storage transaction = transactions[_txId];

        approved[_txId][msg.sender] = false;
        transaction.numConfirmations -= 1;

        emit Revoke(msg.sender, _txId);
    }
}