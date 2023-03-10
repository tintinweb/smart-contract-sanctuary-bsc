/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

contract CreditManager{
   
    uint256 public totalCreditsClaimed = 0;
    mapping(address => uint256) public credits;
    address[] public claimedAddresses;

    uint256 public freeCreditsPerUser = 20;
    address public owner;   

    constructor(){
        owner = msg.sender;
    }

    function claimCredits()  public  {
        bool alreadyExist ;
         for(uint256 i = 0; i < claimedAddresses.length; i++){
             address claimedAddress = claimedAddresses[i];
             if(msg.sender == claimedAddress){
                alreadyExist = true;
             }
         }
        require(alreadyExist == false, "You already claimed your credits");
        credits[msg.sender] = freeCreditsPerUser;
        totalCreditsClaimed += freeCreditsPerUser;
      
        claimedAddresses.push(msg.sender);
    }   
       
    function mint()  public  {
        require(credits[msg.sender]> 1, "You dont have sufficient Credits");
        credits[msg.sender] -= 1;

    }   

}