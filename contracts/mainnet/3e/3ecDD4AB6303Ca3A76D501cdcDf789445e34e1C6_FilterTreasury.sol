/**
 *Submitted for verification at BscScan.com on 2023-01-23
*/

//FilterSwap (V1): filterswap.exchange

pragma solidity ^0.8;

contract FilterTreasury {
    uint public totalNumSignatories;
    mapping(address => bool) public isSignatory;
    mapping(uint => mapping(address => bool)) public isConfirmed;

    uint public approvalsRequired;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numApprovals;
    }

    Transaction[] public transactions;

    // **** CONTRUCTOR, FALLBACK & MODIFIER FUNCTIONS ****

    constructor(address[] memory _initialSignatories) {
        require(_initialSignatories.length >= 2);

        for (uint i = 0; i < _initialSignatories.length; i++) {
            address initialSignatory = _initialSignatories[i];

            isSignatory[initialSignatory] = true;
            totalNumSignatories += 1;
        }

        approvalsRequired = (_initialSignatories.length / 2) + 1;
    }

    receive() external payable {}

    modifier onlySignatories() {
        require(isSignatory[msg.sender], "FilterTreasury: FORBIDDEN");
        _;
    }

    modifier onlyInternal() {
        require(msg.sender == address(this), "FilterTreasury: FORBIDDEN");
        _;
    }

    // **** EVENTS ****

    event newProposal(uint, address, uint, bytes);
    event proposalAccepted(address, uint);
    event proposalExecuted(uint);

    // **** SIGNATORY FUNCTIONS ****

    function proposeTransaction(address _to, uint _value, bytes calldata _data) external onlySignatories {
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            numApprovals: 0
        }));

        emit newProposal(transactions.length - 1, _to, _value, _data);
    }

    function approveTransaction(uint _proposalID) external onlySignatories {
        require(_proposalID < transactions.length, "FilterTreasury: PROPOSAL_DOESNT_EXIST");
        require(!isConfirmed[_proposalID][msg.sender], "FilterTreasury: PROPOSAL_ALREADY_CONFIRMED");
        require(!transactions[_proposalID].executed, "FilterTreasury: PROPOSAL_ALREADY_EXECUTED");

        Transaction storage transaction = transactions[_proposalID];
        transaction.numApprovals += 1;
        isConfirmed[_proposalID][msg.sender] = true;

        emit proposalAccepted(msg.sender, _proposalID);
    }

    function executeTransaction(uint _proposalID) external onlySignatories {
        require(_proposalID < transactions.length, "FilterTreasury: PROPOSAL_DOESNT_EXIST");
        require(!transactions[_proposalID].executed, "FilterTreasury: PROPOSAL_ALREADY_EXECUTED");
        
        Transaction storage transaction = transactions[_proposalID];

        require(transaction.numApprovals >= approvalsRequired, "FilterTreasury: NOT_ENOUGH_APPROVALS");
        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "FilterTreasury: TX_FAILED");

        emit proposalExecuted(_proposalID);
    }

    // **** INTERNAL FUNCTIONS ****

    function addSignatory(address _signatoryAddress) public onlyInternal {
        isSignatory[_signatoryAddress] = true;

        totalNumSignatories += 1;
        approvalsRequired = (totalNumSignatories / 2) + 1;
    }

    function removeSignatory(address _signatoryAddress) public onlyInternal {
        require(isSignatory[_signatoryAddress]);
        isSignatory[_signatoryAddress] = false;

        totalNumSignatories -= 1;
        approvalsRequired = (totalNumSignatories / 2) + 1;
    }
}