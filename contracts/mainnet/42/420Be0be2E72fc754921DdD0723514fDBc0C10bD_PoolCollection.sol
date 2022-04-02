/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;


interface poolContract {
    function startBlock() external view returns (uint256 startBlock);
    function bonusEndBlock() external view returns (uint256 bonusEndBlock);
    function rewardPerBlock() external view returns (uint256 rewardPerBlock);
    function totalStaked() external view returns (uint256 totalStaked);
    function stakedToken() external view returns (address stakedToken);
    function rewardToken() external view returns (address rewardToken);

    function userInfo(address _user) external view returns (uint256 amount, uint256 rewardDebt);
    function pendingReward(address _user) external view returns (uint256 pendingReward);
}
interface token{
     function balanceOf(address account) external view returns (uint256);
     function decimals() external view returns (uint256 decimals);
     function symbol() external view returns (string calldata symbol);
     function name() external view returns (string calldata name);
}



contract PoolCollection  {
    
    function getTotalStaked(address Pool) internal view returns (uint256 TS) {
        address _token = poolContract(Pool).rewardToken();
        try poolContract(Pool).totalStaked(){TS = poolContract(Pool).totalStaked();}catch{TS = token(_token).balanceOf(Pool);}
    }

    function poolInfo(address Pool) internal view returns (uint256 start, uint256 end, uint256 rwpb, uint256 ts) {
        start = poolContract(Pool).startBlock();
        end = poolContract(Pool).bonusEndBlock();
        rwpb = poolContract(Pool).rewardPerBlock();
        ts = getTotalStaked(Pool);
    }

    function userInfo(address Pool, address User) internal view returns (uint256 amount, uint256 pendingReward) {
        (amount,) = poolContract(Pool).userInfo(User);
        pendingReward = poolContract(Pool).pendingReward(User);
    }

// Get Simple pool and User Info
    function getManyPoolInfo(address[] calldata Pool) external view returns (uint256[] memory start, uint256[] memory end, uint256[] memory rwpb, uint256[] memory ts) {
      
      uint256 arrl = Pool.length;
      start = new uint256[](arrl);
      end = new uint256[](arrl);
      rwpb = new uint256[](arrl);
      ts = new uint256[](arrl);

        for (uint i = 0; i < arrl; i++) {
            (start[i], end[i], rwpb[i], ts[i]) = poolInfo(Pool[i]);
        }

    }

    function getManyUserInfo(address[] memory Pool, address User) external view returns (uint256[] memory amount, uint256[] memory pendingReward) {

      uint256 arrl = Pool.length;
      amount = new uint256[](arrl);
      pendingReward = new uint256[](arrl); 

        for (uint i = 0; i < arrl; i++) {
            (amount[i], pendingReward[i]) = userInfo(Pool[i], User);
        }
        
    }

// Token Info section
    function getTokenInfo(address Pool) internal view returns (address stakedToken, uint256 sDec, string memory sSymbol,address rewardToken, uint256 rDec, string memory rSymbol) {
        stakedToken = poolContract(Pool).stakedToken();
        sDec = token(stakedToken).decimals();
        sSymbol = token(stakedToken).symbol();
       
        rewardToken = poolContract(Pool).rewardToken();
        rDec = token(rewardToken).decimals();
        rSymbol = token(rewardToken).symbol();
       
    }

    function getAllTokenInfo(address[] calldata Pool) external view returns (address[] memory stakedToken, uint256[] memory sDec, string[] memory sSymbol, address[] memory rewardToken, uint256[] memory rDec, string[] memory rSymbol) {
    
      uint256 arrl = Pool.length;
      stakedToken = new address[](arrl);
      sDec = new uint256[](arrl);
      sSymbol = new string[](arrl);

      rewardToken = new address[](arrl);
      rDec = new uint256[](arrl);
      rSymbol = new string[](arrl);  
    
        for (uint i = 0; i < arrl; i++) {
            (stakedToken[i], sDec[i], sSymbol[i], rewardToken[i], rDec[i], rSymbol[i]) = getTokenInfo(Pool[i]);
        }
    
    }
    
// get all info including token info
    function getAllPoolInfo(address[] calldata Pool) external view returns (uint256[] memory start, uint256[] memory end, uint256[] memory rwpb, uint256[] memory ts  ,address[] memory stakedToken, uint256[] memory sDec, string[] memory sSymbol, address[] memory rewardToken, uint256[] memory rDec, string[] memory rSymbol) {
      
      uint256 arrl = Pool.length;
      start = new uint256[](arrl);
      end = new uint256[](arrl);
      rwpb = new uint256[](arrl);
      ts = new uint256[](arrl);

      stakedToken = new address[](arrl);
      sDec = new uint256[](arrl);
      sSymbol = new string[](arrl);

      rewardToken = new address[](arrl);
      rDec = new uint256[](arrl);
      rSymbol = new string[](arrl); 

        for (uint i = 0; i < arrl; i++) {
            (start[i], end[i], rwpb[i], ts[i]) = poolInfo(Pool[i]);
            (stakedToken[i], sDec[i], sSymbol[i], rewardToken[i], rDec[i],  rSymbol[i]) = getTokenInfo(Pool[i]);
        }

    }

}