/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract MultiSig {
    
    address mainOwner;
    address[] walletowners;
    uint limit;
    uint depositId = 0;
    uint withdrawalId = 0;
    uint transferId = 0;
    
    constructor() {
        
        mainOwner = msg.sender;
        walletowners.push(mainOwner);
        limit = walletowners.length - 1;
    }
    
    mapping(address => uint) balance;
    mapping(address => mapping(uint => bool)) approvals;
    
    struct Transfer {
        
        address sender;
        address payable receiver;
        uint amount;
        uint id;
        uint approvals;
        uint timeOfTransaction;
    }
    
    Transfer[] transferRequests;
    
    event walletOwnerAdded(address addedBy, address ownerAdded, uint timeOfTransaction);
    event walletOwnerRemoved(address removedBy, address ownerRemoved, uint timeOfTransaction);
    event fundsDeposited(address sender, uint amount, uint depositId, uint timeOfTransaction);
    event fundsWithdrawed(address sender, uint amount, uint withdrawalId, uint timeOfTransaction);
    event transferCreated(address sender, address receiver, uint amount, uint id, uint approvals, uint timeOfTransaction);
    event transferCancelled(address sender, address receiver, uint amount, uint id, uint approvals, uint timeOfTransaction);
    event transferApproved(address sender, address receiver, uint amount, uint id, uint approvals, uint timeOfTransaction);
    event fundsTransfered(address sender, address receiver, uint amount, uint id, uint approvals, uint timeOfTransaction);
    
    modifier onlyowners() {
        
       bool isOwner = false;
       for (uint i = 0; i< walletowners.length; i++) {
           
           if (walletowners[i] == msg.sender) {
               
               isOwner = true;
               break;
           }
       }
       
       require(isOwner == true, "only wallet owners can call this function");
       _;
        
    }
   
    
    function getWalletOners() public view returns(address[] memory) {
        
        return walletowners;
    }
    
    function addWalletOwner(address owner) public onlyowners {
        
        
       for (uint i = 0; i < walletowners.length; i++) {
           
           if(walletowners[i] == owner) {
               
               revert("cannot add duplicate owners");
           }
       }
        
        walletowners.push(owner);
        limit = walletowners.length - 1;
        
        emit walletOwnerAdded(msg.sender, owner, block.timestamp);
    }
    
    
    function removeWalletOwner(address owner) public onlyowners {
        
        bool hasBeenFound = false;
        uint ownerIndex;
        for (uint i = 0; i < walletowners.length; i++) {
            
            if(walletowners[i] == owner) {
                
                hasBeenFound = true;
                ownerIndex = i;
                break;
            }
        }
        
        require(hasBeenFound == true, "wallet owner not detected");
        
        walletowners[ownerIndex] = walletowners[walletowners.length - 1];
        walletowners.pop();
        limit = walletowners.length - 1;
        
         emit walletOwnerRemoved(msg.sender, owner, block.timestamp);
       
    }
    
    function deposit() public payable onlyowners {
        
        require(balance[msg.sender] >= 0, "cannot deposiit a calue of 0");
        
        balance[msg.sender] = msg.value;
        
        emit fundsDeposited(msg.sender, msg.value, depositId, block.timestamp);
        depositId++;
        
    } 
    
    function withdraw(uint amount) public onlyowners {
        
        require(balance[msg.sender] >= amount);
        
        balance[msg.sender] -= amount;
        
        payable(msg.sender).transfer(amount);
        
        emit fundsWithdrawed(msg.sender, amount, withdrawalId, block.timestamp);
         withdrawalId++;
        
    }
    
    function createTrnasferRequest(address payable receiver, uint amount) public onlyowners {
        
        require(balance[msg.sender] >= amount, "insufficent funds to create a transfer");
        
        for (uint i = 0; i < walletowners.length; i++) {
            
            require(walletowners[i] != receiver, "cannot transfer funds withiwn the wallet");
        }
        
        balance[msg.sender] -= amount;
        transferRequests.push(Transfer(msg.sender, receiver, amount, transferId, 0, block.timestamp));
        transferId++;
        emit transferCreated(msg.sender, receiver, amount, transferId, 0, block.timestamp);
    }
    
    function cancelTransferRequest(uint id) public onlyowners {
        
        bool hasBeenFound = false;
        uint transferIndex = 0;
        for (uint i = 0; i < transferRequests.length; i++) {
            
            if(transferRequests[i].id == id) {
                
                hasBeenFound = true;
                break;
               
            }
            
             transferIndex++;
        }
        
        require(transferRequests[transferIndex].sender == msg.sender, "only the transfer creator can cancel");
        require(hasBeenFound, "transfer request does not exist");
        
        balance[msg.sender] += transferRequests[transferIndex].amount;
        
        transferRequests[transferIndex] = transferRequests[transferRequests.length - 1];
        
        emit transferCancelled(msg.sender, transferRequests[transferIndex].receiver, transferRequests[transferIndex].amount, transferRequests[transferIndex].id, transferRequests[transferIndex].approvals, transferRequests[transferIndex].timeOfTransaction);
        transferRequests.pop();
    }
    
    function approveTransferRequest(uint id) public onlyowners {
        
        bool hasBeenFound = false;
        uint transferIndex = 0;
        for (uint i = 0; i < transferRequests.length; i++) {
            
            if(transferRequests[i].id == id) {
                
                hasBeenFound = true;
                break;
                
            }
            
             transferIndex++;
        }
        
        require(hasBeenFound, "only the transfer creator can cancel");
        require(approvals[msg.sender][id] == false, "cannot approve the same transfer twice");
        require(transferRequests[transferIndex].sender != msg.sender);
        
        approvals[msg.sender][id] = true;
        transferRequests[transferIndex].approvals++;
        
        emit transferApproved(msg.sender, transferRequests[transferIndex].receiver, transferRequests[transferIndex].amount, transferRequests[transferIndex].id, transferRequests[transferIndex].approvals, transferRequests[transferIndex].timeOfTransaction);
        
        if (transferRequests[transferIndex].approvals == limit) {
            
            transferFunds(transferIndex);
        }
    }
    
    function transferFunds(uint id) private {
        
        balance[transferRequests[id].receiver] += transferRequests[id].amount;
        transferRequests[id].receiver.transfer(transferRequests[id].amount);
        
        emit fundsTransfered(msg.sender, transferRequests[id].receiver, transferRequests[id].amount, transferRequests[id].id, transferRequests[id].approvals, transferRequests[id].timeOfTransaction);
        
        transferRequests[id] = transferRequests[transferRequests.length - 1];
        transferRequests.pop();
    }
    
    function getApprovals(uint id) public view returns(bool) {
        
        return approvals[msg.sender][id];
    }
    
    function getTransferRequests() public view returns(Transfer[] memory) {
        
        return transferRequests;
    }
    
    function getBalance() public view returns(uint) {
        
        return balance[msg.sender];
    }
    
    function getApprovalLimit() public view returns (uint) {
        
        return limit;
    }
    
     function getContractBalance() public view returns(uint) {
        
        return address(this).balance;
    }
    
   
    
    
}