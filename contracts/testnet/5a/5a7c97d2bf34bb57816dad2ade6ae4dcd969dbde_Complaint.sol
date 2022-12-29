/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

contract Complaint {
    address public officer;
    address public owner;
    uint256 public nextId;
   
    constructor(address _officer) {
        owner = msg.sender;
        officer = _officer;
        nextId = 1;
    }

    modifier onlyOwner() {
        require(msg.sender == owner,"You are not the owner of this smart contract");
        _;
    }

    modifier onlyOfficer() {
        require(msg.sender == officer,"You are not registered officer of this smart contract");
        _;
    }

    struct complaint {
        uint256 id;
        address complaintRegisteredBy;
        string title;
        string description;
        string approvalRemark;
        string resolutionRemark;
        bool isApproved;
        bool isResolved;
        bool exists;
    }
    mapping(uint256 => complaint) public Complaints;

    event complaintFiled(
        uint256 id,
        address complaintRegisteredBy,
        string title
    );

    function fileComplaint(string memory _title, string memory _description) public{
        complaint storage newComplaint = Complaints[nextId];
        newComplaint.id = nextId;
        newComplaint.complaintRegisteredBy = msg.sender;
        newComplaint.title = _title;
        newComplaint.description = _description;
        newComplaint.approvalRemark = "Pending Approval";
        newComplaint.resolutionRemark = "Pending Resolution";
        newComplaint.isApproved = false;
        newComplaint.isResolved = false;
        newComplaint.exists = true;
        emit complaintFiled(nextId, msg.sender, _title);
        nextId++;
    }

    function approveComplaint(uint256 _id, string memory _approvalRemark)public onlyOfficer {
        require(Complaints[_id].exists == true,"This complaint id does not exist");
        require(Complaints[_id].isApproved == false,"Complaint is already approved");
        Complaints[_id].isApproved = true;
        Complaints[_id].approvalRemark = _approvalRemark;
    }


    function resolveComplaint(uint256 _id, string memory _resolutionRemark) public onlyOfficer {
        require(Complaints[_id].exists == true, "This complaint id does not exist");
        require(Complaints[_id].isApproved == true, "Complaint is not yet approved");
        require(Complaints[_id].isResolved == false,"Complaint is already resolved");
        Complaints[_id].isResolved = true;
        Complaints[_id].resolutionRemark = _resolutionRemark;
    }

    function setOfficerAddress(address _officer) public onlyOwner {
        officer = _officer;
    }
}