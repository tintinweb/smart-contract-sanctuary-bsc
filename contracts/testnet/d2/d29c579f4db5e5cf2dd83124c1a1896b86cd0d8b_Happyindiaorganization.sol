/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Happyindiaorganization {
    address[] public deployedCharities;
    
    function createhappyindiaorganization() public {
        address newhappyindiaorganization = address(new happyindiaorganization(msg.sender));
        deployedCharities.push(newhappyindiaorganization);
    }
    
    function getDeployedCharity() public view returns (address[] memory) {
        return deployedCharities;
    }
}


contract happyindiaorganization{
    
  event CharityEvent(
    address _from,
    string _message,
    string _username,
    uint _value
  );
  
  event ApplicantPayout(
      address _from,
      address _to,
      uint value
  );
  
  struct Donator {
    string message;
    string username;
    uint value;
 }
 
 struct Applicant{
     address appaddress;
     string reason;
     uint value;
     string status;
 }
 
 struct addandpass{
     address _createaddress;
     string password;
 }

address public organization;
Applicant[] public Applicants;
Donator[] public donators;
uint public charityCount;
uint public ApplicantCount;
mapping (address=>string) accounts;
mapping (address=>string) creatorlogin;

     constructor( address creator) {
          organization = creator;
          creatorlogin[organization]="Admin";      
    }
    
    
    function createAccount(address _createaddress,string memory password) public {
        accounts[_createaddress]=password;
    }
    
    function login(address _createaddress,string memory password) public view returns(bool){
        if(keccak256(bytes(accounts[_createaddress])) == keccak256(bytes(password))){
            return true;
        }else{
            return false;
        }
    }
    
    function Adminlogin(address _createaddress,string memory password) public view returns(bool){
        if(keccak256(bytes(creatorlogin[_createaddress])) == keccak256(bytes(password))){
            return true;
        }else{
            return false;
        }
    }
    
  
    function getSummary() public view returns ( uint, uint, uint ) {
          return (
              address(0x42fA6d2EafaDD30DEc88463e408752f89e8eEaae).balance,
              donators.length,
              charityCount
          );
      }

    function contributeMessage(string memory message , string memory username) public payable {
        charityCount++;
        address _address = msg.sender;
        emit CharityEvent(_address, message, username, msg.value);
        Donator memory newDonator = Donator({
        message: message,
        username: username,
        value: msg.value
    });
        donators.push(newDonator);
    }
    
    function ApplyForFund(address _appaddress, string memory _reason, uint _value) public{
        ApplicantCount++;
        Applicant memory newApplicant = Applicant({
            appaddress : _appaddress,
            reason : _reason,
            value : _value,
            status: "Pending"
        });
        Applicants.push(newApplicant);
    }
    
    function ApproveApplicant(address payable _appaddress, uint _EtherValue) payable public{
        require(
            msg.sender == organization,
            "Only organization can approve applicants"
        );
        
        require(_appaddress!=organization,"Your shouldn't pay yourself");
        
        _appaddress.transfer(_EtherValue* 1 ether);
        emit ApplicantPayout(address(0x42fA6d2EafaDD30DEc88463e408752f89e8eEaae),_appaddress,msg.value);
        
        for(uint i=0;i<ApplicantCount;i++){
            if(Applicants[i].appaddress==_appaddress&&Applicants[i].value==_EtherValue){
                Applicants[i].status="Paid out";
            }
        }
    }
    
    
    function DisApproveApplicant(address _appaddress,uint _EtherValue) public{
        require(
            msg.sender == organization,
            "Only organization can disapprove applicants"
        );
        
        for(uint i=0;i<ApplicantCount;i++){
            if(Applicants[i].appaddress==_appaddress&&Applicants[i].value==_EtherValue){
                Applicants[i].status="Declined";
            }
        }
    }
}