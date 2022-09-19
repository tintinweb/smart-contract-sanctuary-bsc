/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// SPDX-License-Identifier: Unlicensed

/*

BOOM TOKEN PROTOCOL (C) 2022

Feature: 1 year locking period

https://boomtoken.info
https://t.me/boomvacuum

*/

pragma solidity =0.7.6;

contract TimeLock {

    address public Owner;
    address public constant Token = 0x6232A658a9c1f96fB48f51e69038e77B0A3cE9a6;

    uint256 public constant StartLock = 1663257490;     // Thu Sep 15 2022 15:58:10 GMT+0000
    uint256 public constant LockedUntil = 1694782681;   // Fri Sep 15 2023 12:58:01 GMT+0000

	uint256 constant Decimals = 2;
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