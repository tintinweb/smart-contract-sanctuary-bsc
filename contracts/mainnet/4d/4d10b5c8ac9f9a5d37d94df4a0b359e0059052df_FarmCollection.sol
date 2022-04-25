/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

interface Token{
     function balanceOf(address account) external view returns (uint256);
     function decimals() external view returns (uint8 decimals);
     function symbol() external view returns (string calldata symbol);
     function name() external view returns (string calldata name);
}

interface LPToken {
    function balanceOf(address account) external view returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function totalSupply() external view returns (uint256);
}


// edit this and MasterChef address for different masterchefs
interface MasterChef {
    function cakePerBlock() external view returns (uint256);                                // change with masterchef
    function cake() external view returns (address);                                        // change with masterchef
    function poolLength() external view returns (uint256);
    function poolInfo(uint256 pid) external view returns (address, uint256, uint256, uint256);
    function totalAllocPoint() external view returns (uint256);
    
    function userInfo(uint256, address) external view returns (uint256, uint256);
    function pendingCake(uint256 pid, address user) external view returns(uint256);         // change with masterchef
}

contract FarmCollection  {
    address public masterChef = 0x73feaa1eE314F8c655E354234017bE2193C9E24E;                    // change with masterchef
   
// FARM CALLS

    function getPoolLength() public view returns (uint256 Length) {
        return MasterChef(masterChef).poolLength();
    }

// V1 calls for original code
    function farmInfo(uint256 pid, address lpToken, address qToken, address token) public view returns (uint256 TPB, uint256 APOINT, uint256 TAPOINT, uint8 tDec, uint8 qtDec, uint8 pDec, uint256 tBalLP, uint256 qtBalLP, uint256 lpBalMC, uint256 lpTotalSupply ) {
        TPB = MasterChef(masterChef).cakePerBlock();            // Token per block
        (,APOINT,,) = MasterChef(masterChef).poolInfo(pid);     // PID - Alloc Point
        TAPOINT = MasterChef(masterChef).totalAllocPoint();     // total Alloc Point
        tDec = Token(token).decimals();
        qtDec = Token(qToken).decimals();
        address rToken = MasterChef(masterChef).cake();
        pDec = Token(rToken).decimals();
        tBalLP = Token(token).balanceOf(lpToken);
        qtBalLP = Token(qToken).balanceOf(lpToken);
        lpBalMC = LPToken(lpToken).balanceOf(masterChef);
        lpTotalSupply = LPToken(lpToken).totalSupply();
     }
     
}