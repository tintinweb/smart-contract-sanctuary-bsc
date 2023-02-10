/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;
pragma abicoder v2;

contract MultiSig {

    address[] public owners;
    uint signer;

    constructor(address[] memory _owners, uint _signer) {
        owners = _owners;
        signer = _signer;
    }

    modifier OnlyOwner() {
        bool owner = false;
        for(uint i=0; i<owners.length; i++){
            if(owners[i] == msg.sender) {
                owner = true;
            }
        }
        require(owner == true, "You are not the owner");
        _;

    }

    function deposit() public payable {  
                      
    }

    event transferRequestCreated(uint _id, uint _amount, address _initiator, address _reciever);
    event ApprovalRecieved(uint _id, uint _approvals, address _approver);
    event TransferApproved(uint _id);

    struct Transfer {
        uint amount;
        address payable reciever;
        uint approvals;
        bool hasBeenSent;
        uint id;
    }

    Transfer[] transferRequests;

    function createTransaction(uint _amount, address payable _reciever) public OnlyOwner {
        emit transferRequestCreated(transferRequests.length, _amount, msg.sender, _reciever);
        transferRequests.push(Transfer(_amount, _reciever, 0, false, transferRequests.length));
    }

    mapping(address => mapping(uint => bool)) public approvals;

    function approve(uint _id) public OnlyOwner {
        require(approvals[msg.sender][_id] == false, "You already voted");
        require(transferRequests[_id].hasBeenSent == false);

        approvals[msg.sender][_id] = true;
        transferRequests[_id].approvals++;
        
        emit ApprovalRecieved(_id, transferRequests[_id].approvals, msg.sender);

        if(transferRequests[_id].approvals >= signer) {
            transferRequests[_id].hasBeenSent = true;
            transferRequests[_id].reciever.transfer(transferRequests[_id].amount);
        }

        emit TransferApproved(_id);
    }

    function getTransferRequests() public view returns(Transfer[] memory) {
        return transferRequests;
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }     
}