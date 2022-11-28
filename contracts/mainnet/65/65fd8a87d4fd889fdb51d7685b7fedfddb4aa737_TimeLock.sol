/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

// "SPDX-License-Identifier: UNLICENSED"

/*
             ________________________________________________
            /                                                \
           |    _________________________________________     |
           |   |                                         |    |
           |   |  CryptoLotto v1.0                       |    |
           |   |  Timelocked smart contract              |    |
           |   |                                         |    |
           |   |  C:\> Locking duration                  |    |
           |   |  - LOT/BNB LP locked for 3 years.       |    |
           |   |  - Lock start: Nov 28, 2022             |    |
           |   |  - Lock ends: Nov 28, 2025              |    |
           |   |                                         |    |
           |   |  C:\> _                                 |    |
           |   |                                         |    |
           |   |                                         |    |
           |   |                                         |    |
           |   |_________________________________________|    |
           |                                                  |
            \_________________________________________________/
                   \___________________________________/
                ___________________________________________
             _-'    .-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.  --- `-_
          _-'.-.-. .---.-.-.-.-.-.-.-.-.-.-.-.-.-.-.--.  .-.-.`-_
       _-'.-.-.-. .---.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-`__`. .-.-.-.`-_
    _-'.-.-.-.-. .-----.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-----. .-.-.-.-.`-_
 _-'.-.-.-.-.-. .---.-. .-------------------------. .-.---. .---.-.-.-.`-_
:-------------------------------------------------------------------------:
`---._.-------------------------------------------------------------._.---'


CRYPTOLOTTO PROTOCOL COPYRIGHT (C) 2022
Provably fair lottery protocol on BSC, powered by ChainLink VRF (provably fair and verifiable random number generator).

 > Timelocked contract for CryptoLotto (LOT) Pancakeswap liquidity pair (Pancake-LP) tokens
 > The liquidity is initially locked for a 3 years period
 > LPs unlock can be triggered after Nov 26, 2025
 > LPs may be relocked after the lock period.

https://cryptolotto.finance
https://t.me/cryptolottofi
https://t.me/cryptolottoinfos
https://twitter.com/cryptolottofi
https://medium.com/@cryptolottofi
https://linktr.ee/cryptolottofi

*/


pragma solidity =0.7.6;


contract TimeLock {

    address public Owner;
    address public constant Token = 0x8da1d3DCE78819c0889B92e4590acbf61dC1011C;

    uint256 public constant StartLock = 1669593600;     // Mon Nov 28 2022 00:00:00 GMT+0000
    uint256 public constant LockedUntil = 1764288000;   // Fri Nov 28 2025 00:00:00 GMT+0000

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