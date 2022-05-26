/**
 *Submitted for verification at BscScan.com on 2022-05-26
*/

// SPDX-License-Identifier: MIT

/*
#AMPL + #USDT + #OHM = #GOH

GoHigh (GOH) is a new kind of elastic supply token, 
that is mathematically guaranteed to increase in price from a $0.001 peg
(at a fast rate of 10% every hour) until it exceeds the price of Bitcoin.

https://gohigh.finance
https://t.me/gohtoken
https://twitter.com/gohtoken
_____________________  __
__  ____/_  __ \__  / / /
_  / __ _  / / /_  /_/ / 
/ /_/ / / /_/ /_  __  /  
\____/  \____/ /_/ /_/   
                                                          
*/


pragma solidity =0.7.6;


contract TimeLock {

    address public Owner;
    address public constant Token = 0x99924C2EE3E8328d65421cfA43565ae420a71d33;

    uint256 public constant StartLock = 1653562894;     // Thu May 26 2022 11:01:34 GMT+0000
    uint256 public constant LockedUntil = 1969182094;   // Wed May 26 2032 11:01:34 GMT+0000

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

}

// Interface for TIMELOCK
abstract contract TIMELOCK {
    function balanceOf(address tokenOwner) virtual external view returns (uint256);
    function transfer(address receiver, uint256 numTokens) virtual public returns (bool);
}