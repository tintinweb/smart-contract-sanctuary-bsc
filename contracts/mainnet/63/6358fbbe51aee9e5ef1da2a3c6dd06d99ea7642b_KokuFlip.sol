/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

/*
Gambling Game
50% odds of winning
Reward is 99% on top of entry
Burn in excess of 100 entries
*/
contract KokuFlip {
  IERC20 public token;
  uint public entry;
  uint public reward;
  mapping (address => uint) public entered;

  constructor(
    IERC20 token_,
    uint entry_,
    uint reward_
  ) {
    token = token_;
    entry = entry_;
    reward = reward_;
  }

//Simple coin flip to win. One transaction to enter. One transaction to check the hash of the next block.
  function play() external {
    require(token.balanceOf(address(this)) > reward, "Uh oh! Contract needs reload!"); //Be sure reward is less than 2x the entry
    if (entered[msg.sender] > 0){
      require(block.number > (entered[msg.sender] + 1), "Wait a second, please."); //Next block needs to be completed first
      if ((uint(blockhash(entered[msg.sender] + 1)) % 2) == 1) {
          token.transfer(msg.sender, reward);
      }
      entered[msg.sender] = 0;
    } else {
      token.transferFrom(msg.sender, address(this), entry);
      entered[msg.sender] = block.number;
    }
  }

//If the contract accumulates more than 100x the entry fee, the remainder will be burned
  function burn() external {
    require(token.balanceOf(address(this)) > (entry*100), "Nothing to burn here :)");
    token.transfer(address(0x000000000000000000000000000000000000dEaD), (token.balanceOf(address(this)) - (entry*100)));
  }
}