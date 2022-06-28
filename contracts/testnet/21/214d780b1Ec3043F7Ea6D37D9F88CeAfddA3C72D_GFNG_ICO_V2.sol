/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract GFNG_ICO_V2 {
   bool public icoCompleted;
   uint256 public purchaseLimitLow = 1 * 10 ** 18;
   uint256 public purchaseLimitHigh = 100 * 10 ** 18;
   uint256 public tokenRate = 0.001 * 10 ** 18;
   uint256 public initialTokenPool = 1000;
   uint256 public tokensRaised;
   uint256 public etherRaised;
   address fundingWallet = 0x43E575D5b291a00F692db3227d6fa6fA64C22386;
   IERC20 public token = IERC20(0x8f49d9B66A9886da9c1E383E12cF18a90aefD818);

    modifier whenIcoActive {
      require(!icoCompleted);
      _;
   }

   modifier whenIcoCompleted {
      require(icoCompleted);
      _;
   }

   function startIco() private{
        require(tokenRate != 0);

        icoCompleted = false;
   }

   function stopIco() private{
        icoCompleted = true;
    }

   constructor() {
      startIco();
    }

   function buy() public payable whenIcoActive {
      require(!icoCompleted);
      require(tokensRaised < initialTokenPool - purchaseLimitHigh);
      uint256 tokensToBuy;
      uint256 etherUsed = msg.value;
      tokensToBuy = etherUsed * (10 ** 18) / 1 ether * tokenRate;
      // Check if we have reached and exceeded the funding goal to refund the exceeding tokens and ether
      if(tokensToBuy < purchaseLimitHigh) {
        // Send the tokens to the buyer
        token.transferFrom(address(this), msg.sender, tokensToBuy);
        // Increase the tokens raised and ether raised state variables
        tokensRaised += tokensToBuy;
        etherRaised += etherUsed;
      }
      
      if(initialTokenPool - tokensRaised < purchaseLimitHigh)
      {
         icoCompleted = true;
      }
   }

   function extractAll() private whenIcoCompleted {
      // transfer any remaining ETH balance in the contract to the owner
      token.transferFrom(address(this), fundingWallet, address(this).balance); 
   }

}