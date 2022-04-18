/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Betplay  {
    constructor() public{       
   }
    mapping(address => uint256) public totalA;
    mapping(address => uint256) public totalB;
    mapping(address => uint256) public count;
    bool public betstate;
    bool public winner;
    uint256 sum = 0;
    uint256 bet = 0;
    uint256 betnumA;
    uint256 betnumB;
    function setOpenbet() public  returns(bool){
          betstate = true;
          betnumA = 0;
          betnumB = 0;
          bet = 0;
          return betstate;
    }
    
    
    function bid(uint256 team , uint256 amount) public returns(uint256){
    
        if(betstate == true){
            
            if(team == 1) {
                totalA[msg.sender] += amount;
                count[msg.sender]++;
                betnumA++;
                bet = amount;
             }
            else if(team == 2){
                totalB[msg.sender] += amount;
                count[msg.sender]++;
                betnumB++;
                bet = amount;
            }
            return bet;
        }
        
    }
    
    function setWinner(bool setwinner) public returns(bool){
        betstate = false;
        winner = setwinner;
        return winner;
    }
    
    function winnings() public returns(uint256){
        if(winner == true) return (bet + betnumB/betnumA);
        else if(winner == false) return (bet + betnumA/betnumB);
    }
    
    function betsPlayed(address user) public returns(uint256){ 
        return count[user];
    }
    
    function totalBets(address user) public returns(uint256){
        sum = totalA[user] + totalB[user];
        return sum; 
    }
     /**
      * @notice Set the message
      * @param message   Message
      */
 }