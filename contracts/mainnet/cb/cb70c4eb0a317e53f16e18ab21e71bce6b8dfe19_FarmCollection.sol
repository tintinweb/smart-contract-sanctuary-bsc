/**
 *Submitted for verification at BscScan.com on 2022-04-18
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

// edit this and MasterChef address for different masterchefs
interface masterChef {
    function cakePerBlock() external view returns (uint256);                                // change with masterchef
    function cake() external view returns (address);                                        // change with masterchef
    function poolLength() external view returns (uint256);
    function poolInfo(uint256 pid) external view returns (address, uint256, uint256, uint256);
    function totalAllocPoint() external view returns (uint256);
    
    function userInfo(uint256, address) external view returns (uint256, uint256);
    function pendingCake(uint256 pid, address user) external view returns(uint256);         // change with masterchef
}


contract FarmCollection  {
    address public MasterChef = 0x73feaa1eE314F8c655E354234017bE2193C9E24E;                    // change with masterchef
    address public rewardToken = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;                   // change with masterchef
    uint256 public rDec = 18;                                                                  // change with masterchef
    string public rSym = 'CAKE';                                                               // change with masterchef
   

    function getRewardTokenInfo() external view returns (address _rewardToken, uint _decimals, string memory _symbol) {
        return (rewardToken, rDec, rSym);
    }

// poolalloc * mintrate / totalalloc
    function getRewardPerBlock(uint256 poolAllocPoints) internal view returns (uint256 rpb){
       uint256 tpb = masterChef(MasterChef).cakePerBlock();
       uint256 tap = masterChef(MasterChef).totalAllocPoint();
        rpb = (poolAllocPoints * tpb) / tap;
    }
    function getTotalStaked(address LPToken) internal view returns (uint256 TS) {
        TS = lpToken(LPToken).balanceOf(MasterChef);
    }
// get pid's Token Info
    function getFarmTokenInfo(uint256 pid) internal view returns ( address token0, uint256 t0Dec, string memory t0Sym,address token1, uint256 t1Dec, string memory t1Sym) {
        address LPToken;
        (LPToken,,,) = masterChef(MasterChef).poolInfo(pid);

        token0 = lpToken(LPToken).token0();
        t0Dec = token(token0).decimals();
        t0Sym = token(token0).symbol();
       
        token1 = lpToken(LPToken).token1();
        t1Dec = token(token1).decimals();
        t1Sym = token(token1).symbol();
       
    }
    function getManyFarmTokenInfo(uint256[] calldata pid) external view returns (address[] memory token0, uint256[] memory t0Dec, string[] memory t0Sym, address[] memory token1, uint256[] memory t1Dec, string[] memory t1Sym) {
    
      uint256 arrl = pid.length;
      token0 = new address[](arrl);
      t0Dec = new uint256[](arrl);
      t0Sym = new string[](arrl);

      token1 = new address[](arrl);
      t1Dec = new uint256[](arrl);
      t1Sym = new string[](arrl);  
    
        for (uint i = 0; i < arrl; i++) {
            (token0[i], t0Dec[i], t0Sym[i], token1[i], t1Dec[i], t1Sym[i]) = getFarmTokenInfo(pid[i]);
        }
    
    }

// get farm info singularly
    function getFarmInfo(uint256 pid) internal view returns (address _LPToken, uint256 _rewardPerBlock, uint256 _totalStaked){
        uint256 allocPoints;
        (_LPToken, allocPoints,,) = masterChef(MasterChef).poolInfo(pid);
        _totalStaked = getTotalStaked(_LPToken);
        _rewardPerBlock = getRewardPerBlock(allocPoints);
    }

    function getFarmUserInfo(uint256 pid, address user) internal view returns (uint256 _amount, uint256 _pending){
        (_amount,) = masterChef(MasterChef).userInfo(pid, user);
        _pending = masterChef(MasterChef).pendingCake(pid, user);
    }

// get many commands below

    function getManyFarmInfo(uint256[] calldata pid) external view returns (address[] memory _LPToken,uint256[] memory _rewardPerBlock, uint256[] memory _totalStaked){
      
      uint256 arrl = pid.length;
      _LPToken = new address[](arrl);
      _rewardPerBlock = new uint256[](arrl);
      _totalStaked = new uint256[](arrl);

        for (uint i = 0; i < arrl; i++) {
            (_LPToken[i], _rewardPerBlock[i], _totalStaked[i]) = getFarmInfo(pid[i]);
        }
    }

    function getManyFarmUserInfo(uint256[] calldata pid, address user) external view returns (uint256[] memory _amount, uint256[] memory _pending){
        
        uint256 arrl = pid.length;
         _amount = new uint256[](arrl);
         _pending = new uint256[](arrl);

         for (uint i = 0; i < arrl; i++) {
            (_amount[i], _pending[i]) = getFarmUserInfo(pid[i], user);
        }
    }

    // get Many and get all MC including Token Info
    function getAllFarmInfo(uint256[] calldata pid) external view returns (address[] memory _LPToken,uint256[] memory _rewardPerBlock, uint256[] memory _totalStaked,address[] memory token0, uint256[] memory t0Dec, string[] memory t0Sym, address[] memory token1, uint256[] memory t1Dec, string[] memory t1Sym){
      
      uint256 arrl = pid.length;
      _LPToken = new address[](arrl);
      _rewardPerBlock = new uint256[](arrl);
      _totalStaked = new uint256[](arrl);

      token0 = new address[](arrl);
      t0Dec = new uint256[](arrl);
      t0Sym = new string[](arrl);

      token1 = new address[](arrl);
      t1Dec = new uint256[](arrl);
      t1Sym = new string[](arrl); 

        for (uint i = 0; i < arrl; i++) {
            (_LPToken[i], _rewardPerBlock[i], _totalStaked[i]) = getFarmInfo(pid[i]);
            (token0[i], t0Dec[i], t0Sym[i], token1[i], t1Dec[i], t1Sym[i]) = getFarmTokenInfo(pid[i]);
        }
    }

     function getAllSinglePoolInfo(uint256[] calldata pid) external view returns (uint256[] memory _rewardPerBlock, uint256[] memory _totalStaked,address[] memory stakedToken, uint256[] memory sDec, string[] memory sSym){
      
      uint256 arrl = pid.length;
      
      _rewardPerBlock = new uint256[](arrl);
      _totalStaked = new uint256[](arrl);

      stakedToken = new address[](arrl);
      sDec = new uint256[](arrl);
      sSym = new string[](arrl);

        for (uint i = 0; i < arrl; i++) {
            (stakedToken[i], _rewardPerBlock[i], _totalStaked[i]) = getFarmInfo(pid[i]);
            sDec[i] = token(stakedToken[i]).decimals();
            sSym[i] = token(stakedToken[i]).symbol();
        }
    }
}