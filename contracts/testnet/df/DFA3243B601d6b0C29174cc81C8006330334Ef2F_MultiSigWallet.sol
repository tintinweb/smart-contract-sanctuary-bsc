// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

contract MultiSigWallet {
    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    event ConfirmTransaction(address indexed owner, uint256 indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint256 indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint256 indexed txIndex);
    event TransferETHTransaction(
        address indexed owner,
        uint256 indexed txIndex,
        address indexed to,
        uint256 value
    );
    event TransferERC20Transaction(
        address indexed owner,
        uint256 indexed txIndex,
        address token,
        address indexed to,
        uint256 value
    );
    event AddOwnerTransaction(
        address indexed creator,
        address indexed ownerToAdd,
        uint256 indexed txIndex,
        uint256 numConfirmationsRequired
    );
    event RemoveOwnerTransaction(
        address indexed creator,
        address indexed ownerToRemove,
        uint256 indexed txIndex,
        uint256 numConfirmationsRequired
    );

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public numConfirmationsRequired;

    enum TransactionType {
        TransferETH,
        TransferERC20,
        AddOwner,
        RemoveOwner
    }

    struct Transaction {
        address to;
        address token;
        uint256 value;
        bool executed;
        uint numConfirmations;
        TransactionType txType;
    }

    // mapping from tx index => owner => bool
    mapping(uint256 => mapping(address => bool)) public isConfirmed;

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
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint256 _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }

    constructor(address[] memory _owners, uint256 _numConfirmationsRequired) {
        require(_owners.length > 0, "owners required");
        require(
            _numConfirmationsRequired > 0 &&
                _numConfirmationsRequired <= _owners.length,
            "invalid number of required confirmations"
        );

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        numConfirmationsRequired = _numConfirmationsRequired;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function transferETHTransaction(
        address _to,
        uint256 _value
    ) public onlyOwner {
        uint256 txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                token: address(0),
                executed: false,
                numConfirmations: 0,
                txType: TransactionType.TransferETH
            })
        );

        emit TransferETHTransaction(
            msg.sender,
            txIndex,
            _to,
            _value
        );
    }

    function transferERC20Transaction(
        address _token,
        address _to,
        uint256 _value
    ) public onlyOwner {
        uint256 txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                token: _token,
                executed: false,
                numConfirmations: 0,
                txType: TransactionType.TransferERC20
            })
        );

        emit TransferERC20Transaction(
            msg.sender,
            txIndex,
            _token,
            _to,
            _value
        );
    }

    function addOwnerTransaction(
        address _ownerToAdd,
        uint256 _numConfirmationsRequired
    ) public onlyOwner {
        uint256 txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _ownerToAdd,
                value: _numConfirmationsRequired,
                token: address(0),
                executed: false,
                numConfirmations: 0,
                txType: TransactionType.AddOwner
            })
        );

        emit AddOwnerTransaction(
            msg.sender,
            _ownerToAdd,
            txIndex,
            _numConfirmationsRequired
        );
    }

    function removeOwnerTransaction(
        address _ownerToRemove,
        uint256 _numConfirmationsRequired
    ) public onlyOwner {
        uint256 txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _ownerToRemove,
                value: _numConfirmationsRequired,
                token: address(0),
                executed: false,
                numConfirmations: 0,
                txType: TransactionType.RemoveOwner
            })
        );

        emit RemoveOwnerTransaction(
            msg.sender,
            _ownerToRemove,
            txIndex,
            _numConfirmationsRequired
        );
    }

    function confirmTransaction(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;

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

        TransactionType txType = transaction.txType;
        if (txType == TransactionType.TransferETH) {
            (bool success, ) = transaction.to.call{value: transaction.value}("");
            require(success, "tx failed");
        } else if (txType == TransactionType.TransferERC20) {
            (bool success, ) = transaction.token.call(
                abi.encodeWithSignature(
                    "transfer(address,uint256)",
                    transaction.to,
                    transaction.value
                )
            );
            require(success, "tx failed");
        } else if (txType == TransactionType.AddOwner) {
            address owner = transaction.to;
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
            numConfirmationsRequired = transaction.value;
        } else if (txType == TransactionType.RemoveOwner) {
            address owner = transaction.to;
            require(isOwner[owner], "Not an owner");
            isOwner[owner] = false;

            uint256 length = owners.length;
            uint256 i;
            for (i = 0; i < length; i++) {
                if (owners[i] == owner)
                    break;
            }

            owners[i] = owners[length - 1];
            owners.pop();
            numConfirmationsRequired = transaction.value;
        }

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    function revokeConfirmation(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");

        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

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
        returns (
            address to,
            address token,
            uint256 value,
            bool executed,
            uint numConfirmations,
            TransactionType txType
        )
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.token,
            transaction.value,
            transaction.executed,
            transaction.numConfirmations,
            transaction.txType
        );
    }
}