/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

contract Wallet {
    address[] public approvers;
    uint256 public quorum;
    struct Transfer {
        uint256 id;
        uint256 amount;
        address payable to;
        uint256 approvals;
        bool sent;
    }
    Transfer[] public transfers;
    mapping(address => mapping(uint256 => bool)) public approvals;

    modifier onlyApprover() {
        bool allowed = false;
        for (uint256 i = 0; i < approvers.length; i++) {
            if (approvers[i] == msg.sender) {
                allowed = true;
            }
        }
        require(allowed == true, "only approved users can access");
        _;
    }

    constructor(address[] memory _approvers, uint256 _quorum)  {
        approvers = _approvers;
        quorum = _quorum;
    }


    function addApprover(address approver) external onlyApprover{
        approvers.push(approver);
    }

    function removeApprover(address approver) external  onlyApprover{

        for (uint i=0; i<approvers.length - 1; i++)
            if (approvers[i] == approver) {
                approvers[i] = approvers[approvers.length - 1];
                break;
            }
    }

    function setQuorum(uint256 _quorum) external  onlyApprover{
        quorum = _quorum;
    }

    function getApprovers() external view returns (address[] memory) {
        return approvers;
    }

    function getTransfers() external view returns (Transfer[] memory) {
        return transfers;
    }

    function createTransfer(uint256 _amount, address payable _to)
        external
        onlyApprover
    {
        transfers.push(Transfer(transfers.length, _amount, _to, 0, false));
    }

    function approveTransfer(uint256 _id) external onlyApprover {
        require(transfers[_id].sent == false, "Already sent!");
        require(approvals[msg.sender][_id] == false, "Cannot approve twice");
        approvals[msg.sender][_id] = true;
        transfers[_id].approvals++;

        if (transfers[_id].approvals >= quorum) {
            transfers[_id].sent = true;
            address payable to = transfers[_id].to;
            uint256 amount = transfers[_id].amount;
            to.transfer(amount);
        }
    }

    receive() external payable {}
}