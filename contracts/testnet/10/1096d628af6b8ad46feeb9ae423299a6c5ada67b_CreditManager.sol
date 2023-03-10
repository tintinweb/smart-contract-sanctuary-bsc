/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

contract CreditManager{
   
    uint256 public totalCreditsClaimed = 0;
    mapping(address => uint256) public userCredits;
    mapping(address=> bool) public isClaimed;
    uint256 public freeCreditsPerUser = 20;
    address public owner;   

    constructor(){
        owner = msg.sender;
    }

    function claimCredits()  public  {
        require(isClaimed[msg.sender] == false, "You have already claimed your credits");
        userCredits [msg.sender] = freeCreditsPerUser;
        totalCreditsClaimed += freeCreditsPerUser;
        isClaimed[msg.sender] = true;

    }   
       
    function mint()  public  {
        require(userCredits [msg.sender] > 0, "You dont have sufficient Credits");
        userCredits[msg.sender] -= 1;

    }   

}