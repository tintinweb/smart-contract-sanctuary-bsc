/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract MultiSigs {
    // Events
    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    event SubmitTransaction(
        address indexed owner,
        uint256 indexed txIndex,
        address indexed to,
        uint256 value,
        bytes data,
        uint256 delay
    );
    event ConfirmTransaction(address indexed owner, uint256 indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint256 indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint256 indexed txIndex);
    event RejectTransaction(address indexed owner, uint256 indexed txIndex);
    event RevokeRejection(address indexed owner, uint256 indexed txIndex);

    event ProposeNewAdmin(address indexed proposer, address indexed newAdmin, uint8 count);
    event ApproveNewAdmin(address indexed proposer, address indexed newAdmin, uint8 count);
    event AddAdmin(address indexed proposer, address indexed newAdmin, uint8 count);

    event ProposeRemovingAdmin(address indexed proposer, address indexed newAdmin, uint8 count);
    event ApproveRemovingAdmin(address indexed proposer, address indexed newAdmin, uint8 count);
    event RemoveAdmin(address indexed proposer, address indexed newAdmin, uint8 count);

    event ProposeNewConfirmationRequired(address indexed proposer, uint8 newNumber, uint8 count);
    event ApproveNewConfirmationRequired(address indexed proposer, uint8 newNumber, uint8 count);
    event RejectNewConfirmationRequired(address indexed proposer, uint8 newNumber, uint8 count);
    event ExecuteNewConfirmationRequired(address indexed proposer, uint8 newNumber, uint8 count);

    // a list of owners to this multisigs contract
    address[] public owners;
    // check if an address is owner or not
    mapping(address => bool) public isOwner;

    // Transaction info
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint8 numConfirmations;
        uint256 delay;
        bool isUrgent;
        uint8 numRejects;
    }
    // minimum delay time before a transaction can be executed
    uint256 public minDelay;
    // mapping from tx index => owner => bool
    mapping(uint256 => mapping(address => bool)) public isConfirmed;
    // mapping from tx index => owner => bool
    mapping(uint256 => mapping(address => bool)) public isRejected;
    // list of all transactions
    Transaction[] public transactions;

    // minimum number of confirmations from owner before a transaction can be executed
    uint8 public numConfirmationsRequired;
    // vote update numConfirmationsRequired
    struct NumConfirmationsRequiredProposal {
        uint8 newNumConfirmationsRequired;
        uint8 numConfirmations;
        uint8 numRejects;
        mapping(address => bool) isConfirmed;
    }
    // store NumConfirmationsRequiredProposal for voting
    NumConfirmationsRequiredProposal[] public numConfirmationsRequiredProposal;

    // list of pending admins waiting for approving to be an owner
    mapping(address => uint8) public pendingNewAdmins;
    // mapping from existing owner -> a pendingNewOwners. One owner can only approve a new admin 1 time only
    mapping(address => mapping(address => bool)) public approveToNewAdmin;
    // list of pending admins waiting to be removed
    mapping(address => uint8) public pendingRemoveAdmins;
    // mapping from existing owner -> a pendingRemoveOwners. one owner can only approve 1 time only
    mapping(address => mapping(address => bool)) public approveToRemoveAdmin;

    // Modifier
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

    constructor(
        address[] memory _owners,
        uint8 _numConfirmationsRequired,
        uint256 _minDelay
    ) {
        require(_owners.length > 0, "owners required");
        require(
            _numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length,
            "invalid number of required confirmations"
        );

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "_owners array not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        numConfirmationsRequired = _numConfirmationsRequired;
        minDelay = _minDelay;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    fallback() external payable {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value, address(this).balance);
        }
    }

    function submitTransaction(
        address _to,
        uint256 _value,
        bytes memory _data,
        uint256 _delay,
        bool _isUrgent
    ) public onlyOwner {
        require(_delay >= minDelay, "delay must >= minDelay");

        uint256 txIndex = transactions.length;

        transactions.push(Transaction({
        to : _to,
        value : _value,
        data : _data,
        executed : false,
        numConfirmations : 1,
        delay : block.timestamp + _delay,
        isUrgent : _isUrgent,
        numRejects : 0}));

        isConfirmed[txIndex][msg.sender] = true;

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data, _delay);
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

    function executeTransaction(uint256 _txIndex) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) {

        Transaction storage transaction = transactions[_txIndex];

        require(address(this).balance >= transaction.value, "Multisigs contract does not have enough ETH to execute tx");

        if (transaction.isUrgent == false) {
            require(transaction.numRejects < numConfirmationsRequired, "this proposal is rejected");
            require(transaction.numConfirmations >= numConfirmationsRequired, "not reach min confirmations");
            require(transaction.delay < block.timestamp, "tx is not ready");
        } else {
            require(transaction.numConfirmations >= owners.length - 1, "not reach min confirmations");
        }

        transaction.executed = true;

        (bool success,) = transaction.to.call{value : transaction.value}(transaction.data);
        require(success, "tx failed");

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    function revokeConfirmation(uint256 _txIndex) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        require(isConfirmed[_txIndex][msg.sender] == true, "you did not confirm this proposal before");

        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    // rejectTransaction
    function rejectTransaction(uint256 _txIndex)
    public
    onlyOwner
    txExists(_txIndex)
    notExecuted(_txIndex)
    {
        require(isRejected[_txIndex][msg.sender] == false, "you rejected this proposal already");

        Transaction storage transaction = transactions[_txIndex];
        transaction.numRejects += 1;
        isRejected[_txIndex][msg.sender] = true;

        emit RejectTransaction(msg.sender, _txIndex);
    }

    // revoke rejection
    function revokeRejection(uint256 _txIndex)
    public
    onlyOwner
    txExists(_txIndex)
    notExecuted(_txIndex)
    {
        require(isRejected[_txIndex][msg.sender] == true, "you did not reject this proposal before");

        Transaction storage transaction = transactions[_txIndex];
        transaction.numRejects -= 1;
        isRejected[_txIndex][msg.sender] = false;

        emit RevokeRejection(msg.sender, _txIndex);
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
    returns (Transaction memory transaction)
    {
        transaction = transactions[_txIndex];
    }

    function proposeNewAdmin(address _newOwnerAddress) external onlyOwner {
        require(_newOwnerAddress != address(0), "invalid address 0x");
        require(isOwner[_newOwnerAddress] == false, "This address is an admin.");
        require(pendingNewAdmins[_newOwnerAddress] == 0, "This address was added. Wait for approval");

        approveToNewAdmin[msg.sender][_newOwnerAddress] = true;
        pendingNewAdmins[_newOwnerAddress] = 1;

        emit ProposeNewAdmin(msg.sender, _newOwnerAddress, pendingNewAdmins[_newOwnerAddress]);
    }

    function approveNewAdmin(address _newOwnerAddress) external onlyOwner {
        require(pendingNewAdmins[_newOwnerAddress] >= 1, "You need to propose this address first");
        require(approveToNewAdmin[msg.sender][_newOwnerAddress] == false, "You already approved this address");

        approveToNewAdmin[msg.sender][_newOwnerAddress] = true;
        pendingNewAdmins[_newOwnerAddress]++;

        emit ApproveNewAdmin(msg.sender, _newOwnerAddress, pendingNewAdmins[_newOwnerAddress]);
    }

    function executeAddingNewAdmin(address _newOwnerAddress) external onlyOwner {
        require(pendingNewAdmins[_newOwnerAddress] >= numConfirmationsRequired, "Require other admin to approve this");
        require(!isOwner[_newOwnerAddress], "This address is an admin already");

        isOwner[_newOwnerAddress] = true;
        owners.push(_newOwnerAddress);

        emit AddAdmin(msg.sender, _newOwnerAddress, pendingNewAdmins[_newOwnerAddress]);

        delete pendingNewAdmins[_newOwnerAddress];
    }

    function proposeRemoveAdmin(address _removeAddress) external onlyOwner {
        require(_removeAddress != address(0), "invalid address 0x");
        require(isOwner[_removeAddress] == true, "This address is not an admin.");
        require(pendingRemoveAdmins[_removeAddress] == 0, "This address was added. Wait for approval");

        approveToRemoveAdmin[msg.sender][_removeAddress] = true;
        pendingRemoveAdmins[_removeAddress] = 1;

        emit ProposeRemovingAdmin(msg.sender, _removeAddress, pendingRemoveAdmins[_removeAddress]);
    }

    function approveRemoveAdmin(address _removeAddress) external onlyOwner {
        require(pendingRemoveAdmins[_removeAddress] >= 1, "You need to propose this address first");
        require(approveToRemoveAdmin[msg.sender][_removeAddress] == false, "You already approved this address");

        approveToRemoveAdmin[msg.sender][_removeAddress] = true;
        pendingRemoveAdmins[_removeAddress]++;

        emit ApproveRemovingAdmin(msg.sender, _removeAddress, pendingRemoveAdmins[_removeAddress]);
    }

    function executeRemoveAdmin(address _removeAddress) external onlyOwner {
        require(pendingRemoveAdmins[_removeAddress] >= numConfirmationsRequired, "Require other admin to approve this");
        require(isOwner[_removeAddress] == true, "This address is not an admin");
        isOwner[_removeAddress] = false;

        // remove the _removeAddress from "owners" array
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == _removeAddress) {
                owners[i] = owners[owners.length - 1];
                owners.pop();
                break;
            }
        }

        emit RemoveAdmin(msg.sender, _removeAddress, pendingRemoveAdmins[_removeAddress]);

        delete pendingRemoveAdmins[_removeAddress];
    }

    function proposeNewNumConfirmationsRequired(uint8 _newConfirmationsRequired) external onlyOwner {

        require(
            _newConfirmationsRequired > 0 && _newConfirmationsRequired <= owners.length,
            "invalid number of required confirmations. must > 0 and < owners.length"
        );

        require(numConfirmationsRequiredProposal.length == 0, "Having a proposal already, need to approve/reject it first");

        NumConfirmationsRequiredProposal storage proposal = numConfirmationsRequiredProposal.push();
        proposal.isConfirmed[msg.sender] = true;
        proposal.numConfirmations = 1;
        proposal.newNumConfirmationsRequired = _newConfirmationsRequired;

        emit ProposeNewConfirmationRequired(msg.sender, _newConfirmationsRequired, proposal.numConfirmations);
    }

    function approveNewNumConfirmationsRequired() external onlyOwner {
        NumConfirmationsRequiredProposal storage proposal = numConfirmationsRequiredProposal[0];
        require(proposal.isConfirmed[msg.sender] == false, "you confirmed already");

        proposal.numConfirmations++;
        proposal.isConfirmed[msg.sender] = true;

        emit ApproveNewConfirmationRequired(msg.sender, proposal.newNumConfirmationsRequired, proposal.numConfirmations);
    }

    function rejectNewNumConfirmationsRequired() external onlyOwner {
        NumConfirmationsRequiredProposal storage proposal = numConfirmationsRequiredProposal[0];
        require(proposal.isConfirmed[msg.sender] == false, "you confirmed already");

        proposal.numRejects++;
        proposal.isConfirmed[msg.sender] = true;

        emit RejectNewConfirmationRequired(msg.sender, proposal.newNumConfirmationsRequired, proposal.numConfirmations);
    }

    function executeNewNumConfirmationsRequired() external onlyOwner {
        NumConfirmationsRequiredProposal storage proposal = numConfirmationsRequiredProposal[0];
        require(proposal.newNumConfirmationsRequired > 0
            && proposal.newNumConfirmationsRequired <= owners.length,
            "invalid data newNumConfirmationsRequired");

        require((proposal.numConfirmations + proposal.numRejects) >= numConfirmationsRequired, "not enough confirmations");

        if (proposal.numConfirmations > proposal.numRejects) {
            numConfirmationsRequired = proposal.newNumConfirmationsRequired;
        }

        emit ExecuteNewConfirmationRequired(msg.sender, proposal.newNumConfirmationsRequired, proposal.numConfirmations);

        numConfirmationsRequiredProposal.pop();
    }
}