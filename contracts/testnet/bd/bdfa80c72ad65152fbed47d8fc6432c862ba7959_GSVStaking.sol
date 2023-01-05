/**
 *Submitted for verification at BscScan.com on 2023-01-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
 
contract GSVStaking {
    address public primaryAdmin;
  
   uint256[10] public tierFromSlab1Year = [0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether];
    uint256[10] public tierToSlab1Year = [0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether];
    uint[10] public tierAPY1Year = [0,0,0,0,0,0,0,0,0,0];
    uint[10] public tierPenaltyPer1Year = [0,0,0,0,0,0,0,0,0,0];
    uint[10] public tierLocking1YearPer = [0,0,0,0,0,0,0,0,0,0];

    uint256[10] public tierFromSlab2Year = [0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether];
    uint256[10] public tierToSlab2Year = [0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether];
    uint[10] public tierAPY2Year = [0,0,0,0,0,0,0,0,0,0];
    uint[10] public tierPenaltyPer2Year = [0,0,0,0,0,0,0,0,0,0];
    uint[10] public tierLocking2YearPer = [0,0,0,0,0,0,0,0,0,0];

    uint256[10] public tierFromSlab3Year = [0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether];
    uint256[10] public tierToSlab3Year = [0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether,0 ether];
    uint[10] public tierAPY3Year = [0,0,0,0,0,0,0,0,0,0];
    uint[10] public tierPenaltyPer3Year = [0,0,0,0,0,0,0,0,0,0];
    uint[10] public tierLocking3YearPer = [0,0,0,0,0,0,0,0,0,0];

  
    constructor() {
        primaryAdmin = 0xc314c1cA1937bFd7b785e418e40de975A5f63103;
    }
  
  // Update Year Tier Slab
    function update_Tier(uint _tierYear,uint256[10] memory _fromSlab,uint256[10] memory _toSlab,uint[10] memory _tierAPY,uint[10] memory _tierPenaltyPer,uint[10] memory _tierLockingPer) external {
      require(primaryAdmin==msg.sender, "Admin what?");
      if(_tierYear==0){
        tierFromSlab1Year=_fromSlab;
        tierToSlab1Year=_toSlab;
        tierAPY1Year=_tierAPY;
        tierPenaltyPer1Year=_tierPenaltyPer;
        tierLocking1YearPer=_tierLockingPer;
      }
      else if(_tierYear==1){
        tierFromSlab2Year=_fromSlab;
        tierToSlab2Year=_toSlab;
        tierAPY2Year=_tierAPY;
        tierPenaltyPer2Year=_tierPenaltyPer;
        tierLocking2YearPer=_tierLockingPer;
      }
      else if(_tierYear==2){
        tierFromSlab3Year=_fromSlab;
        tierToSlab3Year=_toSlab;
        tierAPY3Year=_tierAPY;
        tierPenaltyPer3Year=_tierPenaltyPer;
        tierLocking3YearPer=_tierLockingPer;
      }
    }
}