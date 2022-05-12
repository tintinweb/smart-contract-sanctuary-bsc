/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// SPDX-License-Identifier: MIT

// This contract contains the vesting supply of Decore Capital project, that is initially timelocked for 6 months from launch.
// https://decore.capital
// t.me/decorecapital

pragma solidity =0.7.6;


contract DCOREVestingTimeLock {

    address public Owner;
    address public constant Token = 0x70919a889509c52f32666A79777F27CabBd41499;

    uint256 public constant StartLock = 1652360353;   //  Thursday 12 May 2022 12:59:13 GMT
    uint256 public constant LockedUntil = 1668261744; //  Saturday 12 November 2022 14:02:24 GMT

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