// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ShieldWallet {
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
    event addOwnerEvent(address indexed owner);
    event removeOwnerEvent(address indexed owner);
    event addApproverEvent(address indexed owner);
    event removeApproverEvent(address indexed owner);

    address[] public owners;
    address[] public approvers;
    mapping(address => bool) public isOwner;
    mapping(address => bool) public isApprover;
    uint256 public numConfirmationsRequired;
    uint256 public fee = 3000000000000000;
    address public fee_address = 0x3eAdEfb36946DaFa1a11C8A0fDaEb49db08ff411;
    bool public allowExecuteApprovers = false;

    enum TransactionStatus {
        PENDING,
        EXECUTED,
        CANCELED
    }

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        TransactionStatus status;
        uint256 numConfirmations;
    }

    // mapping from tx index => owner => bool
    mapping(uint256 => mapping(address => bool)) public isConfirmed;

    Transaction[] public transactions;

    // constructor(address[] memory _owners, uint256 _numConfirmationsRequired)
    //     payable
    // {
    //     require(
    //         _numConfirmationsRequired > 0 &&
    //             _numConfirmationsRequired <= _owners.length,
    //         "ShieldWallet.constructor: INVALID_REQUIRED_CONFIRMATIONS"
    //     );

    //     applyFee(msg.value);
    //     addOwner(msg.sender);

    //     numConfirmationsRequired = _numConfirmationsRequired;

    //     for (uint256 i = 0; i < _owners.length; i++) {
    //         if (!isOwner[_owners[i]]) {
    //             addOwner(_owners[i]);
    //         }
    //     }
    // }

    constructor(uint256 _numConfirmationsRequired) payable {
        require(
            _numConfirmationsRequired == 1,
            "ShieldWallet.constructor: INVALID_REQUIRED_CONFIRMATIONS"
        );

        applyFee(msg.value);

        //TODO: Revisar, no se puede llamar a _addApprover ya que esa funcion solo está disponible para el owner
        isOwner[msg.sender] = true;
        owners.push(msg.sender);
        emit addOwnerEvent(msg.sender);

        numConfirmationsRequired = _numConfirmationsRequired;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function applyFee(uint256 amount) private {
        require(amount >= fee, "ShieldWallet.applyFee: NOT_ENOUGHT_FUNDS");
        payable(fee_address).transfer(amount);
    }

    function submitTransaction(
        address _to,
        uint256 _value,
        bytes memory _data
    ) public onlyOwner {
        uint256 txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                status: TransactionStatus.PENDING,
                numConfirmations: 0
            })
        );

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    function setFeeAmount(uint256 _fee_amount) public onlyOwner {
        fee = _fee_amount;
    }

    function setFeeAddress(address _fee_address) public onlyOwner {
        fee_address = _fee_address;
    }

    function confirmTransaction(uint256 _txIndex) public {
        _confirmTransaction(_txIndex);

        if (
            transactions[_txIndex].numConfirmations >= numConfirmationsRequired
        ) {
            if (allowExecuteApprovers == true || isOwner[msg.sender]) {
                executeTransaction(_txIndex);
            }
        }
    }

    function _confirmTransaction(uint256 _txIndex)
        private
        isOwnerOrApprover
        txExists(_txIndex)
        txPending(_txIndex)
        notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    function executeTransaction(uint256 _txIndex)
        public
        onlyValidator
        txExists(_txIndex)
        txPending(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(
            transaction.numConfirmations >= numConfirmationsRequired,
            "ShieldWallet.executeTransaction: CANNOT_EXECUTE_TRANSACTION"
        );

        transaction.status = TransactionStatus.EXECUTED;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(
            success,
            "ShieldWallet.executeTransactiion: TRANSACTION_FAILED"
        );

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    function revokeConfirmation(uint256 _txIndex)
        public
        isOwnerOrApprover
        txExists(_txIndex)
        txPending(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(
            isConfirmed[_txIndex][msg.sender],
            "ShieldWallet.revokeConfirmation: TRANSACTION_NOT_CONFIRMED"
        );

        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function addApprovers(address[] memory _approvers) public {
        for (uint256 i = 0; i < _approvers.length; i++) {
            addApprover(_approvers[i]);
        }
    }

    function addApprover(address _approver) public {
        _addApprover(_approver);
    }

    function _addApprover(address _approver) private onlyOwner {
        require(
            !isApprover[_approver] == false,
            "ShieldWallet._addApprover: APPROVER_ALREADY_SET"
        );
        require(
            _approver != address(0),
            "ShieldWallet._addApprover:INVALID_ADDRESS"
        );
        require(
            !isOwner[_approver],
            "ShieldWallet._addApprover:ADDRESS_IS_OWNER"
        );

        isApprover[_approver] = true;
        approvers.push(_approver);
        emit addApproverEvent(_approver);
    }

    function removeApprovers(address[] memory _approvers) public {
        for (uint256 i = 0; i < _approvers.length; i++) {
            _removeApprover(_approvers[i]);
        }
    }

    function removeApprover(address _approver) public {
        _removeApprover(_approver);
    }

    function _removeApprover(address _approver) private onlyOwner {
        require(
            !isApprover[_approver] == true,
            "ShieldWallet._addApprover: APPROVER_NOT_SET"
        );
        require(
            _approver != address(0),
            "ShieldWallet._addApprover:INVALID_ADDRESS"
        );

        delete isApprover[_approver];

        for (uint256 i = 0; i < approvers.length; i++) {
            if (approvers[i] == _approver) {
                delete approvers[i];
                break;
            }
        }

        emit removeApproverEvent(_approver);
    }

    function addOwners(address[] memory _owners) public {
        for (uint256 i = 0; i < _owners.length; i++) {
            _addOwner(_owners[i]);
        }
        _removePendingTransactions();
    }

    function addOwner(address _owner) public {
        _addOwner(_owner);
        _removePendingTransactions();
    }

    function _addOwner(address _owner) private onlyOwner {
        require(!isOwner[_owner], "ShieldWallet._addOwner: OWNER_ALREADY_SET");
        require(
            _owner != address(0),
            "ShieldWallet._addOwner: INVALID_ADDRESS"
        );
        require(
            !isApprover[_owner],
            "ShieldWallet._addOwner: ADDRESS_IS_APPROVER"
        );

        isOwner[_owner] = true;
        owners.push(_owner);
        emit addOwnerEvent(_owner);
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getApprovers() public view returns (address[] memory) {
        return approvers;
    }

    function getTransactionCount() public view returns (uint256) {
        return transactions.length;
    }

    function getTransaction(uint256 _txIndex)
        public
        view
        returns (
            address to,
            uint256 value,
            bytes memory data,
            TransactionStatus status,
            uint256 numConfirmations
        )
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.status,
            transaction.numConfirmations
        );
    }

    function _removePendingTransactions() private {
        for (uint256 i = transactions.length - 1; i >= 0; i--) {
            if (transactions[i].status == TransactionStatus.PENDING) {
                transactions[i].status = TransactionStatus.CANCELED;
            }
        }
    }

    //Modifiers
    modifier txExists(uint256 _txIndex) {
        require(
            _txIndex < transactions.length,
            "ShieldWallet.txExists: TRANSACTION_DOES_NOT_EXIST"
        );
        _;
    }

    modifier txPending(uint256 _txIndex) {
        require(
            transactions[_txIndex].status == TransactionStatus.PENDING,
            "ShieldWallet.txPending: TRANSACTION_NOT_PENDING"
        );
        _;
    }

    modifier notConfirmed(uint256 _txIndex) {
        require(
            !isConfirmed[_txIndex][msg.sender],
            "ShieldWallet.txPending: TRANSACTION_NOT_CONFIRMED"
        );
        _;
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "ShieldWallet.onlyOwner: NOT_OWNER");
        _;
    }

    modifier onlyValidator() {
        require(
            isOwner[msg.sender] || isApprover[msg.sender],
            "ShieldWallet.onlyValidator: NOT_VALID_ADDRESS"
        );
        if (allowExecuteApprovers == false) {
            require(
                isOwner[msg.sender],
                "ShieldWallet.onlyValidator: NOT_OWNER"
            );
        }
        _;
    }

    modifier isOwnerOrApprover() {
        require(
            isOwner[msg.sender] || isApprover[msg.sender],
            "ShieldWalletisOwnerOrApprover: ADDRESS_UNAUTHORIZED"
        );
        _;
    }
}