/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8;

interface IFilterManager {
    function governanceToken() external view returns (address);
    function governanceVoteDeadline() external view returns (uint);
    function governanceMinVotesRequired() external view returns (uint);
    function governanceMaxVotingPower() external view returns (uint);
}

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function approve(address, uint) external returns (bool);
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
}

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        require(IERC20(token).approve(to, value), "FilterGovernor: APPROVE_FAILED");
    }

    function safeTransfer(address token, address to, uint value) internal {
        require(IERC20(token).transfer(to, value), "FilterRouter: TRANSFER_FAILED");
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        require(IERC20(token).transferFrom(from, to, value), "FilterGovernor: TRANSFER_FROM_FAILED");
    }
}

contract FilterGovernor {
    address public managerAddress;
    IFilterManager filterManager;

    uint public totalNumSignatories;
    mapping(address => bool) public isSignatory;

    bytes4[] public signatoryFunctionsWhitelist;


    mapping(uint => mapping(address => bool)) public isSignatoryConfirmed;
    mapping(uint => mapping(address => bool)) public isGovernableConfirmed;

    uint public signatoryApprovalsRequired;

    struct SignatoryTransaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numApprovals;
    }

    struct GovernableTransaction {
        address to;
        bytes data;
        bool executed;
        uint numApprovals;
        uint numRejections;
        uint deadline;
    }

    SignatoryTransaction[] public signatoryTransactions;
    GovernableTransaction[] public governableTransactions;

    mapping(address => uint) public governanceTokensLocked;
    mapping(address => uint) public governanceTokenTransferDeadline;

    uint public totalGovernanceTokensLocked;

    // **** CONTRUCTOR, FALLBACK & MODIFIER FUNCTIONS ****

    constructor(address _managerAddress, address[] memory _initialSignatories) {  
        managerAddress = _managerAddress;
        filterManager = IFilterManager(managerAddress);
        
        require(_initialSignatories.length >= 2);
        
        for (uint i = 0; i < _initialSignatories.length; i++) {
            address initialSignatory = _initialSignatories[i];

            isSignatory[initialSignatory] = true;
            totalNumSignatories += 1;
        }

        signatoryApprovalsRequired = (_initialSignatories.length / 2) + 1;

        signatoryFunctionsWhitelist.push(0x6605bfda); //setTreasuryAddress
        signatoryFunctionsWhitelist.push(0x4130276b); //verifyToken
        signatoryFunctionsWhitelist.push(0x61fb13e1); //rejectVerificationRequest
        signatoryFunctionsWhitelist.push(0xfe43cb66); //acceptVerificationRequest
        signatoryFunctionsWhitelist.push(0x21dd877f); //addSignatory
        signatoryFunctionsWhitelist.push(0xd5ab92fd); //removeSignatory
    }

    receive() external payable {}

    modifier onlySignatories() {
        require(isSignatory[msg.sender], "FilterGovernor: FORBIDDEN");
        _;
    }

    modifier onlyInternal() {
        require(msg.sender == address(this), "FilterGovernor: FORBIDDEN");
        _;
    }

    // **** EVENTS ****

    event newSignatoryProposal(uint, address, uint, bytes);
    event newGovernableProposal(uint, bytes);
    event proposalAccepted(uint, uint);
    event proposalRejected(uint, uint);

    // **** GOVERNABLE FUNCTIONS ****

    function isSignatoryTransaction(bytes calldata _data) private view returns (bool) {
        bytes4 functionHash;

        assembly {
            functionHash := calldataload(_data.offset)
        }

        for (uint i = 0; i < signatoryFunctionsWhitelist.length; i++) {
            if (functionHash == signatoryFunctionsWhitelist[i]) return true;
        }

        return false;
    }

    function getVotingPower() private view returns (uint) {
        uint votingPower = governanceTokensLocked[msg.sender];
        uint maxVotingPower = filterManager.governanceMaxVotingPower();

        if (votingPower >= maxVotingPower) votingPower = maxVotingPower;

        return votingPower;
    }

    function proposeGovernableTransaction(address _to, bytes calldata _data) external onlySignatories {
        require(!isSignatoryTransaction(_data), "FilterGovernor: NOT_GOVERNABLE_TRANSACTION");

        governableTransactions.push(GovernableTransaction({
            to: _to,
            data: _data,
            executed: false,
            numApprovals: 0,
            numRejections: 0,
            deadline: block.timestamp + filterManager.governanceVoteDeadline()
        }));

        emit newGovernableProposal(governableTransactions.length - 1, _data);
    }

    function depositGovernanceTokens() private {
        address governanceToken = filterManager.governanceToken();
        uint governanceTokenBalance = IERC20(governanceToken).balanceOf(msg.sender);
        TransferHelper.safeTransferFrom(governanceToken, msg.sender, address(this), governanceTokenBalance);

        governanceTokensLocked[msg.sender] += governanceTokenBalance;
        totalGovernanceTokensLocked += governanceTokenBalance;
    }

    function withdrawGovernanceTokens() external {
        require(block.timestamp >= governanceTokenTransferDeadline[msg.sender], "FilterGovernor: CANNOT_WITHDRAW");
        uint userTokenBalance = governanceTokensLocked[msg.sender];
        TransferHelper.safeTransfer(filterManager.governanceToken(), msg.sender, userTokenBalance);

        totalGovernanceTokensLocked -= userTokenBalance;
        governanceTokensLocked[msg.sender] = 0;
    }

    function acceptProposal(uint _txID) external {
        depositGovernanceTokens();

        require(_txID < governableTransactions.length, "FilterGovernor: PROPOSAL_DOESNT_EXIST");
        require(!isGovernableConfirmed[_txID][msg.sender], "FilterGovernor: PROPOSAL_ALREADY_CONFIRMED");
        require(!governableTransactions[_txID].executed, "FilterGovernor: PROPOSAL_ALREADY_EXECUTED");

        GovernableTransaction storage transaction = governableTransactions[_txID];

        require(block.timestamp < transaction.deadline, "FilterGovernor: PROPOSAL_CLOSED");
        transaction.numApprovals += getVotingPower();
        isGovernableConfirmed[_txID][msg.sender] = true;

        if (governanceTokenTransferDeadline[msg.sender] < transaction.deadline) governanceTokenTransferDeadline[msg.sender] = transaction.deadline;

        emit proposalAccepted(_txID, getVotingPower());
   
    }

    function rejectProposal(uint _txID) external {
        depositGovernanceTokens();

        require(_txID < governableTransactions.length, "FilterGovernor: PROPOSAL_DOESNT_EXIST");
        require(!isGovernableConfirmed[_txID][msg.sender], "FilterGovernor: PROPOSAL_ALREADY_CONFIRMED");
        require(!governableTransactions[_txID].executed, "FilterGovernor: PROPOSAL_ALREADY_EXECUTED");

        GovernableTransaction storage transaction = governableTransactions[_txID];

        require(block.timestamp < transaction.deadline, "FilterGovernor: PROPOSAL_CLOSED");
        transaction.numRejections += getVotingPower();
        isGovernableConfirmed[_txID][msg.sender] = true;

        if (governanceTokenTransferDeadline[msg.sender] < transaction.deadline) governanceTokenTransferDeadline[msg.sender] = transaction.deadline;  

        emit proposalRejected(_txID, getVotingPower());
    }

    function executeGovernableTransaction(uint _txID) external onlySignatories {
        require(_txID < governableTransactions.length, "FilterGovernor: PROPOSAL_DOESNT_EXIST");
        require(!governableTransactions[_txID].executed, "FilterGovernor: PROPOSAL_ALREADY_EXECUTED");
        
        GovernableTransaction storage transaction = governableTransactions[_txID];

        require(block.timestamp >= transaction.deadline, "FilterGovernor: DEADLINE_NOT_REACHED");
        require((transaction.numApprovals + transaction.numRejections) >= filterManager.governanceMinVotesRequired(), "FilterGovernor: NOT_ENOUGH_APPROVALS");
        require(transaction.numApprovals >= transaction.numRejections, "FilterGovernor: TOO_MANY_REJECTIONS");      

        (bool success, ) = managerAddress.call(transaction.data);
        require(success, "FilterGovernor: TX_FAILED");

        transaction.executed = true;
    }

    // **** SIGNATORY PROPOSALS ****

    function proposeSignatoryTransaction(address _to, uint _value, bytes calldata _data) external onlySignatories {
        require(isSignatoryTransaction(_data), "FilterGovernor: NOT_SIGNATORY_TRANSACTION");
        require(_to != filterManager.governanceToken(), "FilterGovernor: FORBIDDEN");

        signatoryTransactions.push(SignatoryTransaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            numApprovals: 0
        }));

        emit newSignatoryProposal(signatoryTransactions.length - 1, _to, _value, _data);
    }

    function approveSignatoryTransaction(uint _txID) external onlySignatories {
        require(_txID < signatoryTransactions.length, "FilterGovernor: PROPOSAL_DOESNT_EXIST");
        require(!isSignatoryConfirmed[_txID][msg.sender], "FilterGovernor: PROPOSAL_ALREADY_CONFIRMED");
        require(!signatoryTransactions[_txID].executed, "FilterGovernor: PROPOSAL_ALREADY_EXECUTED");

        SignatoryTransaction storage transaction = signatoryTransactions[_txID];
        transaction.numApprovals += 1;
        isSignatoryConfirmed[_txID][msg.sender] = true;
    }

    function executeSignatoryTransaction(uint _txID) external onlySignatories {
        require(_txID < signatoryTransactions.length, "FilterGovernor: PROPOSAL_DOESNT_EXIST");
        require(!signatoryTransactions[_txID].executed, "FilterGovernor: PROPOSAL_ALREADY_EXECUTED");
        
        SignatoryTransaction storage transaction = signatoryTransactions[_txID];

        require(transaction.numApprovals >= signatoryApprovalsRequired, "FilterGovernor: NOT_ENOUGH_APPROVALS");
        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "FilterGovernor: TX_FAILED");
    }

    // **** SIGNATORY FUNCTIONS ****

    function addSignatory(address _signatoryAddress) public onlyInternal {
        isSignatory[_signatoryAddress] = true;

        totalNumSignatories += 1;
        signatoryApprovalsRequired = (totalNumSignatories / 2) + 1;
    }

    function removeSignatory(address _signatoryAddress) public onlyInternal {
        require(isSignatory[_signatoryAddress]);
        isSignatory[_signatoryAddress] = false;

        totalNumSignatories -= 1;
        signatoryApprovalsRequired = (totalNumSignatories / 2) + 1;
    }
}