/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
contract ChickenFight {
  IERC20 public token;
  uint public chickenFee;
  uint public minWager;
  uint public maxWager;
  struct Entry {
      uint blocknum;
      uint wager;
  }
  mapping (address => Entry) public entries;
  mapping (address => bool) public chickens;
  address owner;

//Call setFees() to initialize everything else
  constructor(
    IERC20 token_
  ) {
    token = token_;
    owner = msg.sender;
  }

//last function to make
  function play(uint wager) external {
    require(token.balanceOf(address(this)) > (wager*2), "Uh oh! Contract needs reload!");
    require(wager > minWager, "Wager is too small");
    require(wager > maxWager, "Wager is too large");
    require(entries[msg.sender].wager < minWager, "Your chicken is ready to fight");
    if (chickens[msg.sender]){
      token.transferFrom(msg.sender, address(this), wager);
      entries[msg.sender] = Entry(block.number, wager);
    } else {
      token.transferFrom(msg.sender, address(this), (wager + chickenFee));
      entries[msg.sender] = Entry(block.number, wager);
      chickens[msg.sender] = true;
    }
  }

  function fight() external {
    require(entries[msg.sender].blocknum > 0, "Enter first");
    require(block.number > (entries[msg.sender].blocknum), "Wait a second, please.");
    if ((uint(blockhash(entries[msg.sender].blocknum)) % 2) == 1) {
      token.transfer(msg.sender, entries[msg.sender].wager * 2);
    } else {
      chickens[msg.sender] = false;
    }
    entries[msg.sender] = Entry(0,0);
  }

//If the contract accumulates more than 100x the entry fee, the remainder will be burned
  function burn() external {
  }

  function setFees(uint chickFee, uint min, uint max) external {
    require(msg.sender == owner, "Owners only");
    chickenFee = chickFee;
    minWager = min;
    maxWager = max;
  }

  function changeOwner(address newOwner) external {
    require(msg.sender == owner, "Owners only");
    owner = newOwner;
  }
}