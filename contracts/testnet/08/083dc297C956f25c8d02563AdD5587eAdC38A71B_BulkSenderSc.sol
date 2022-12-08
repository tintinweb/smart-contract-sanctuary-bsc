/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

//SPDX-License-Identifier: Unlicensed
pragma solidity >=0.7.0 <0.9.0;

contract BulkSenderSc {
    
    address private owner;
    uint256 total_value;
    
    
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    constructor() payable{
        owner = msg.sender; 
        total_value = msg.value;
    }
      
    function getOwner() external view returns (address) {
        return owner;
    }
 
    function sum(uint[] memory amount) private pure returns (uint retVal) {
        uint totalamount = 0; 
        for (uint i=0; i < amount.length; i++) {
            totalamount += amount[i];
        } 
        return totalamount;
    }
    
    function withdraw(address payable receiveraddresses, uint amount) private {
        receiveraddresses.transfer(amount);
    }

    function MultipleWithdraw(address payable[] memory addresses, uint[] memory amount) payable public isOwner {
        
        total_value += msg.value;
        require(addresses.length == amount.length, "The length of 2 array should be the same");
        uint totalamount = sum(amount);    
        require(total_value >= totalamount, "The value is unsufficient ");
           
        for (uint i=0; i < addresses.length; i++) {
            total_value -= amount[i];
            
            withdraw(addresses[i], amount[i]);
        }
    }
    
}