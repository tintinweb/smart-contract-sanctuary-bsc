/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// SPDX-License-Identifier: Unlicensed

/*
   _______   ________   _________  ___  _________    ___    ___ 
  |\  ___ \ |\   ___  \|\___   ___\\  \|\___   ___\ |\  \  /  /|
  \ \   __/|\ \  \\ \  \|___ \  \_\ \  \|___ \  \_| \ \  \/  / /
   \ \  \_|/_\ \  \\ \  \   \ \  \ \ \  \   \ \  \   \ \    / / 
    \ \  \_|\ \ \  \\ \  \   \ \  \ \ \  \   \ \  \   \/  /  /  
     \ \_______\ \__\\ \__\   \ \__\ \ \__\   \ \__\__/  / /    
      \|_______|\|__| \|__|    \|__|  \|__|    \|__|\___/ /     
                                                   \|___|/      

ENTITY PROTOCOL COPYRIGHT (C) 2022

Feature: 1 year locking period

https://entity.capital
https://t.me/entitycapital

*/


pragma solidity =0.7.6;


contract TimeLock {

    address public Owner;
    address public constant Token = 0xeEf6020B7720f4e000476b017Fc4e224dFC0aA36;

    uint256 public constant StartLock = 1659607200;     // Thu Aug 04 2022 10:00:00 GMT+0000
    uint256 public constant LockedUntil = 1691143200;   // Fri Aug 04 2023 10:00:00 GMT+0000

	uint256 constant Decimals = 18;
	uint256 constant incrementAmount = 10 ** (5 + Decimals);
	
    
    // Constructor. 
   constructor() payable {  
		Owner = payable(msg.sender);
    }  
    

    // Modifiers
    modifier checkRequirements {
        require(StartLock < block.timestamp, "Time travel is not allowed!");
		require(LockedUntil > block.timestamp, "Locking period is not over!");
		require(msg.sender == Owner, "Admin function!");
        _;
    }
    

    function payOutIncrementToken() external checkRequirements {
        TIMELOCK(Token).transfer(Owner, incrementAmount);
    }
    
    
    function payOutTotalToken() external checkRequirements {
        uint256 balance = TIMELOCK(Token).balanceOf(address(this));
		TIMELOCK(Token).transfer(Owner, balance);
    }

    function payOutCustomAmountToken(address tokenAddress, uint tokens) external checkRequirements {
        TIMELOCK(tokenAddress).transfer(Owner, tokens);
    }

}

// Interface for TIMELOCK
abstract contract TIMELOCK {
    function balanceOf(address tokenOwner) virtual external view returns (uint256);
    function transfer(address receiver, uint256 numTokens) virtual public returns (bool);
}