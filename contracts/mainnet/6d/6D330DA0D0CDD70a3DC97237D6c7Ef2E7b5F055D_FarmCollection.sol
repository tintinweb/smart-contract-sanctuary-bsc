/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

interface token{
     function balanceOf(address account) external view returns (uint256);
     function decimals() external view returns (uint256 decimals);
     function symbol() external view returns (string calldata symbol);
     function name() external view returns (string calldata name);
}

interface lpToken {
    function balanceOf(address account) external view returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
}

interface masterChef {
    function cakePerBlock() external view returns (uint256); 
    function poolLength() external view returns (uint256);
    function poolInfo(uint256 pid) external view returns (address, uint256, uint256, uint256);
    function totalAllocPoints() external view returns (uint256);
    
    function userInfo(uint256, address) external view returns (uint256, uint256);
    function pendingCake(uint256 pid, address user) external view returns(uint256);
}


contract FarmCollection  {
    address MasterChef = 0x73feaa1eE314F8c655E354234017bE2193C9E24E;
// totalalloc / poolalloc * mintrate
    function getRewardPerBlock(uint256 poolAllocPoints) public view returns (uint256){
        
        return(masterChef(MasterChef).totalAllocPoints() / poolAllocPoints * masterChef(MasterChef).cakePerBlock());
    }
    function getTotalStaked(address LPToken) public view returns (uint256 TS) {
        TS = lpToken(LPToken).balanceOf(MasterChef);
    }
// get pid's Token Info
    function getTokenInfo(uint256 pid) internal view returns (address stakedToken, uint256 sDec, string memory sSymbol,address rewardToken, uint256 rDec, string memory rSymbol) {
        address LPToken;
        (LPToken,,,) = masterChef(MasterChef).poolInfo(pid);

        stakedToken = lpToken(LPToken).token0();
        sDec = token(stakedToken).decimals();
        sSymbol = token(stakedToken).symbol();
       
        rewardToken = lpToken(LPToken).token1();
        rDec = token(rewardToken).decimals();
        rSymbol = token(rewardToken).symbol();
       
    }
    function getAllTokenInfo(uint256[] calldata pid) external view returns (address[] memory stakedToken, uint256[] memory sDec, string[] memory sSymbol, address[] memory rewardToken, uint256[] memory rDec, string[] memory rSymbol) {
    
      uint256 arrl = pid.length;
      stakedToken = new address[](arrl);
      sDec = new uint256[](arrl);
      sSymbol = new string[](arrl);

      rewardToken = new address[](arrl);
      rDec = new uint256[](arrl);
      rSymbol = new string[](arrl);  
    
        for (uint i = 0; i < arrl; i++) {
            (stakedToken[i], sDec[i], sSymbol[i], rewardToken[i], rDec[i], rSymbol[i]) = getTokenInfo(pid[i]);
        }
    
    }

// get farm info singularly
    function getFarmInfo(uint256 pid) public view returns (uint256 _pid, address _LPToken,uint256 _rewardPerBlock, uint256 _totalStaked){
        _pid = pid;
        uint256 allocPoints;
        (_LPToken, allocPoints,,) = masterChef(MasterChef).poolInfo(_pid);
        _totalStaked = getTotalStaked(_LPToken);
        _rewardPerBlock = getRewardPerBlock(allocPoints);
    }
    function getUserInfo(uint256 pid, address user) public view returns (uint256 _pid, uint256 _amount, uint256 _pending){
        _pid = pid;
        (_amount,) = masterChef(MasterChef).userInfo(pid, user);
        _pending = masterChef(MasterChef).pendingCake(pid, user);
    }

// get many commands below

    function getManyFarmInfo(uint256[] calldata pid) external view returns (uint256[] memory _pid, address[] memory _LPToken,uint256[] memory _rewardPerBlock, uint256[] memory _totalStaked){
      
      uint256 arrl = pid.length;
      _pid = new uint256[](arrl);
      _LPToken = new address[](arrl);
      _rewardPerBlock = new uint256[](arrl);
      _totalStaked = new uint256[](arrl);

        for (uint i = 0; i < arrl; i++) {
            (_pid[i], _LPToken[i], _rewardPerBlock[i], _totalStaked[i]) = getFarmInfo(pid[i]);
        }
    }

    function getManyUserInfo(uint256[] calldata pid, address user) external view returns (uint256[] memory _pid, uint256[] memory _amount, uint256[] memory _pending){
        
        uint256 arrl = pid.length;
         _pid = new uint256[](arrl);
         _amount = new uint256[](arrl);
         _pending = new uint256[](arrl);

         for (uint i = 0; i < arrl; i++) {
            (_pid[i], _amount[i], _pending[i]) = getUserInfo(pid[i], user);
        }
    }

// get entire MC worth of info
    function getEntireMCFarmInfo() external view returns (uint256[] memory _pid, address[] memory _LPToken,uint256[] memory _rewardPerBlock, uint256[] memory _totalStaked){
      
      uint256 arrl = masterChef(MasterChef).poolLength();

      _pid = new uint256[](arrl);
      _LPToken = new address[](arrl);
      _rewardPerBlock = new uint256[](arrl);
      _totalStaked = new uint256[](arrl);

        for (uint i = 0; i < arrl; i++) {
            (_pid[i], _LPToken[i], _rewardPerBlock[i], _totalStaked[i]) = getFarmInfo(i);
        }
    }
    function getEntireMCUserInfo(address user) external view returns (uint256[] memory _pid, uint256[] memory _amount, uint256[] memory _pending){
        
        uint256 arrl = masterChef(MasterChef).poolLength();
       
         _pid = new uint256[](arrl);
         _amount = new uint256[](arrl);
         _pending = new uint256[](arrl);

         for (uint i = 0; i < arrl; i++) {
            (_pid[i], _amount[i], _pending[i]) = getUserInfo(i, user);
        }
    }

    // get Many and get all MC including Token Info
    function getAllInfo(uint256[] calldata pid) external view returns (uint256[] memory _pid, address[] memory _LPToken,uint256[] memory _rewardPerBlock, uint256[] memory _totalStaked,address[] memory stakedToken, uint256[] memory sDec, string[] memory sSymbol, address[] memory rewardToken, uint256[] memory rDec, string[] memory rSymbol){
      
      uint256 arrl = pid.length;
      _pid = new uint256[](arrl);
      _LPToken = new address[](arrl);
      _rewardPerBlock = new uint256[](arrl);
      _totalStaked = new uint256[](arrl);

      stakedToken = new address[](arrl);
      sDec = new uint256[](arrl);
      sSymbol = new string[](arrl);

      rewardToken = new address[](arrl);
      rDec = new uint256[](arrl);
      rSymbol = new string[](arrl); 

        for (uint i = 0; i < arrl; i++) {
            (_pid[i], _LPToken[i], _rewardPerBlock[i], _totalStaked[i]) = getFarmInfo(pid[i]);
            (stakedToken[i], sDec[i], sSymbol[i], rewardToken[i], rDec[i], rSymbol[i]) = getTokenInfo(pid[i]);
        }
    }
    function getALLMCInfo() external view returns (uint256[] memory _pid, address[] memory _LPToken,uint256[] memory _rewardPerBlock, uint256[] memory _totalStaked,address[] memory stakedToken, uint256[] memory sDec, string[] memory sSymbol, address[] memory rewardToken, uint256[] memory rDec, string[] memory rSymbol){
      
      uint256 arrl = masterChef(MasterChef).poolLength();

      _pid = new uint256[](arrl);
      _LPToken = new address[](arrl);
      _rewardPerBlock = new uint256[](arrl);
      _totalStaked = new uint256[](arrl);

      stakedToken = new address[](arrl);
      sDec = new uint256[](arrl);
      sSymbol = new string[](arrl);

      rewardToken = new address[](arrl);
      rDec = new uint256[](arrl);
      rSymbol = new string[](arrl); 

        for (uint i = 0; i < arrl; i++) {
            (_pid[i], _LPToken[i], _rewardPerBlock[i], _totalStaked[i]) = getFarmInfo(i);
             (stakedToken[i], sDec[i], sSymbol[i], rewardToken[i], rDec[i], rSymbol[i]) = getTokenInfo(i);
        }
    }
}