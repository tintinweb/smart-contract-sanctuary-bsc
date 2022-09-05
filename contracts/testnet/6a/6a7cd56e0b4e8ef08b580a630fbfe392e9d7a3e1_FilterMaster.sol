/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8;

interface IFilterManager {
    function governanceToken() external view returns (address);
    function governanceVoteDeadline() external view returns (uint);
    function minGovernanceVotesRequired() external view returns (uint);
    function maxGovernanceVotingPower() external view returns (uint);
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
        require(IERC20(token).approve(to, value), "FilterMaster: APPROVE_FAILED");
    }

    function safeTransfer(address token, address to, uint value) internal {
        require(IERC20(token).transfer(to, value), "FilterRouter: TRANSFER_FAILED");
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        require(IERC20(token).transferFrom(from, to, value), "FilterMaster: TRANSFER_FROM_FAILED");
    }
}

contract FilterMaster {
    address public managerAddress;

    uint public totalNumSignatories;
    mapping(address => bool) public isSignatory;

    bytes4[] public communityGovernableFunctionHashes;


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

    // **** CONTRUCTOR, FALLBACK & MODIFIERS ****

    constructor(address _managerAddress, address[] memory _initialSignatories, bytes4[] memory _communityGovernableFunctionHashes) {
        managerAddress = _managerAddress;

        require(_initialSignatories.length >= 2);

        for (uint i = 0; i < _initialSignatories.length; i++) {
            address initialSignatory = _initialSignatories[i];

            isSignatory[initialSignatory] = true;
        }

        signatoryApprovalsRequired = (_initialSignatories.length / 2) + 1;
        communityGovernableFunctionHashes = _communityGovernableFunctionHashes;
    }

    receive() external payable {}

    modifier onlySignatories() {
        require(isSignatory[msg.sender], "FilterMaster: FORBIDDEN");
        _;
    }

    // **** GOVERNABLE FUNCTIONS ****

    function isGovernableTransaction(bytes calldata _data) internal view returns (bool) {
        bytes4 functionHash;

        assembly {
            functionHash := calldataload(_data.offset)
        }

        for (uint i = 0; i < communityGovernableFunctionHashes.length; i++) {
            if (functionHash == communityGovernableFunctionHashes[i]) return true;
        }

        return false;
    }

    function getVotingPower() internal view returns (uint) {
        uint votingPower = governanceTokensLocked[msg.sender];
        uint maxVotingPower = IFilterManager(managerAddress).maxGovernanceVotingPower();

        if (votingPower >= maxVotingPower) votingPower = maxVotingPower;

        return votingPower;
    }

    function proposeGovernableTransaction(bytes calldata _data) public onlySignatories {
        require(isGovernableTransaction(_data), "FilterMaster: NOT_GOVERNABLE_TRANSACTION");

        governableTransactions.push(GovernableTransaction({
            data: _data,
            executed: false,
            numApprovals: 0,
            numRejections: 0,
            deadline: block.timestamp + IFilterManager(managerAddress).governanceVoteDeadline()
        }));
    }

    function depositGovernanceTokens() private {
        address governanceToken = IFilterManager(managerAddress).governanceToken();
        uint governanceTokenBalance = IERC20(governanceToken).balanceOf(msg.sender);
        TransferHelper.safeTransferFrom(governanceToken, msg.sender, address(this), governanceTokenBalance);

        governanceTokensLocked[msg.sender] += governanceTokenBalance;
        totalGovernanceTokensLocked += governanceTokenBalance;
    }

    function withdrawGovernanceTokens() external {
        require(block.timestamp >= governanceTokenTransferDeadline[msg.sender], "FilterMaster: CANNOT_WITHDRAW");
        uint userTokenBalance = governanceTokensLocked[msg.sender];
        TransferHelper.safeTransfer(IFilterManager(managerAddress).governanceToken(), msg.sender, userTokenBalance);

        totalGovernanceTokensLocked -= userTokenBalance;
        governanceTokensLocked[msg.sender] = 0;
    }

    function acceptProposal(uint _txID) external {
        depositGovernanceTokens();
        uint userVotingPower = getVotingPower();

        require(_txID < governableTransactions.length, "FilterMaster: PROPOSAL_DOESNT_EXIST");
        require(!isGovernableConfirmed[_txID][msg.sender], "FilterMaster: PROPOSAL_ALREADY_CONFIRMED");
        require(!governableTransactions[_txID].executed, "FilterMaster: PROPOSAL_ALREADY_EXECUTED");

        GovernableTransaction storage transaction = governableTransactions[_txID];

        require(block.timestamp < transaction.deadline, "FilterMaster: PROPOSAL_CLOSED");
        transaction.numApprovals += userVotingPower;
        isGovernableConfirmed[_txID][msg.sender] = true;

        if (governanceTokenTransferDeadline[msg.sender] < transaction.deadline) governanceTokenTransferDeadline[msg.sender] = transaction.deadline;
   
    }

    function rejectProposal(uint _txID) external {
        depositGovernanceTokens();
        uint userVotingPower = getVotingPower();  

        require(_txID < governableTransactions.length, "FilterMaster: PROPOSAL_DOESNT_EXIST");
        require(!isGovernableConfirmed[_txID][msg.sender], "FilterMaster: PROPOSAL_ALREADY_CONFIRMED");
        require(!governableTransactions[_txID].executed, "FilterMaster: PROPOSAL_ALREADY_EXECUTED");

        GovernableTransaction storage transaction = governableTransactions[_txID];

        require(block.timestamp < transaction.deadline, "FilterMaster: PROPOSAL_CLOSED");
        transaction.numRejections += userVotingPower;
        isGovernableConfirmed[_txID][msg.sender] = true;

        if (governanceTokenTransferDeadline[msg.sender] < transaction.deadline) governanceTokenTransferDeadline[msg.sender] = transaction.deadline;  
    }

    function executeGovernableTransaction(uint _txID) external onlySignatories {
        require(_txID < governableTransactions.length, "FilterMaster: PROPOSAL_DOESNT_EXIST");
        require(!governableTransactions[_txID].executed, "FilterMaster: PROPOSAL_ALREADY_EXECUTED");
        
        GovernableTransaction storage transaction = governableTransactions[_txID];

        require(block.timestamp < transaction.deadline, "FilterMaster: DEADLINE_NOT_REACHED");
        require((transaction.numApprovals + transaction.numRejections) >= IFilterManager(managerAddress).minGovernanceVotesRequired(), "FilterMaster: NOT_ENOUGH_APPROVALS");
        require(transaction.numApprovals >= transaction.numRejections, "FilterMaster: TOO_MANY_REJECTIONS");      

        (bool success, ) = managerAddress.call(transaction.data);
        require(success, "FilterMaster: TX_FAILED");

        transaction.executed = true;
    }

    // **** SIGNATORY PROPOSALS ****

    function proposeSignatoryTransaction(address _to, uint _value, bytes calldata _data) external onlySignatories {
        require(!isGovernableTransaction(_data), "FilterMaster: IS_GOVERNABLE_TRANSACTION");

        signatoryTransactions.push(SignatoryTransaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            numApprovals: 0
        }));
    }

    function approveSignatoryTransaction(uint _txID) external onlySignatories {
        require(_txID < signatoryTransactions.length, "FilterMaster: PROPOSAL_DOESNT_EXIST");
        require(!isSignatoryConfirmed[_txID][msg.sender], "FilterMaster: PROPOSAL_ALREADY_CONFIRMED");
        require(!signatoryTransactions[_txID].executed, "FilterMaster: PROPOSAL_ALREADY_EXECUTED");

        SignatoryTransaction storage transaction = signatoryTransactions[_txID];
        transaction.numApprovals += 1;
        isSignatoryConfirmed[_txID][msg.sender] = true;
    }

    function executeSignatoryTransaction(uint _txID) external onlySignatories {
        require(_txID < signatoryTransactions.length, "FilterMaster: PROPOSAL_DOESNT_EXIST");
        require(!signatoryTransactions[_txID].executed, "FilterMaster: PROPOSAL_ALREADY_EXECUTED");
        
        SignatoryTransaction storage transaction = signatoryTransactions[_txID];

        require(transaction.numApprovals >= signatoryApprovalsRequired, "FilterMaster: NOT_ENOUGH_APPROVALS");
        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "FilterMaster: TX_FAILED");

        uint finalGovernanceTokenBalance = IERC20(IFilterManager(managerAddress).governanceToken()).balanceOf(address(this));
        require(finalGovernanceTokenBalance >= totalGovernanceTokensLocked); // prevents devs from being able to steal governance tokens from contract
    }

    // **** SIGNATORY FUNCTIONS ****

    function addSignatory(address _signatoryAddress) external {
        require(msg.sender == address(this));
        isSignatory[_signatoryAddress] = true;

        totalNumSignatories += 1;
        signatoryApprovalsRequired = (totalNumSignatories / 2) + 1;
    }

    function removeSignatory(address _signatoryAddress) external {
        require(msg.sender == address(this));
        require(isSignatory[_signatoryAddress]);
        isSignatory[_signatoryAddress] = false;

        totalNumSignatories -= 1;
        signatoryApprovalsRequired = (totalNumSignatories / 2) + 1;
    }
}