/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

// "SPDX-License-Identifier: UNLICENSED"

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
Auto-rebasing DeFi protocol bonded with gambling industry.

 > Timelocked contract for Entity Pancakeswap liquidity pair (Pancake-LP) tokens
 > The liquidity is initially locked for a 4 years period
 > Tokens unlock can be triggered after Fri May 15, 2026 16:19:21 GMT+0000

Entity is a DeFi ecosystem developing and deploying the missing links between DeFi and gambling protocols, 
backed by a high paying auto-staking & auto-compounding protocol, rebasing every 15 minutes,
and reflecting tokens to holders wallets after every rebase.

Entity is silently fairlaunched, without presale, ensuring an organic growth from scratch.

https://entity.capital
https://t.me/entitycapital
https://t.me/entityDAO

*/


pragma solidity =0.7.6;


contract TimeLock {

    address public Owner;
    address public constant Token = 0x91ED9dB8b03A5a8963D3f2DFF2c9846087BEFa7E;

    uint256 public constant StartLock = 1652631561;     // Sun May 15 2022 16:19:21 GMT+0000
    uint256 public constant LockedUntil = 1778861961;   // Fri May 15 2026 16:19:21 GMT+0000

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