/**
 *Submitted for verification at BscScan.com on 2023-01-18
*/

/**
  LP timelock of cocoswap.finance
  COCO-BNB liquidity locked for 5 years within this contract.

  https://cocoswap.finance
  https://t.me/cocoswap_bsc
  
**/

pragma solidity =0.7.6;


contract TimeLockLP {

    address public Owner;
    address public constant Token = 0x6579cAE1B66651389B08529e1cc5ab21FF5ac71C;

    uint256 public constant StartLock = 1674048950;     // Wed Jan 18 2023 13:35:50 GMT+0000
    uint256 public constant LockedUntil = 1831815350;   // Tue Jan 18 2028 13:35:50 GMT+0000

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