/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

/**
    DECORE.Capital Token Timelock
    t.me/decorecapital
    v1.0

    DCORE Tokens are deposited into this contract, and locked until the release date.
    Once unlocked, these tokens will be used to create new pools, and/or will be locked again into a new timelocked contract.
**/

// SPDX-License-Identifier: Unlicensed

pragma solidity =0.7.6;

contract TimeLock {

    address public Owner;
    address public constant Token = 0x4493e8593FeBD85eaAf7a2531484e0e8758BC81C;

    uint256 public constant StartLock = 1656363854;   //  Mon Jun 27 2022 21:04:14 GMT+0000
    uint256 public constant LockedUntil = 1751047448; //  Fri Jun 27 2025 18:04:08 GMT+0000

	uint256 constant Decimals = 9;
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