// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

/**
 * The DappTokenSale contract does this and that...
 */

import "./DappToken.sol";

contract DappTokenSale {

	address admin;
	DappToken public tokenContract;
	uint256 public tokenPrice;
	uint256 public tokenSold;

	event Sell(address _buyer, uint256 _amount);

    constructor(DappToken _tokenContract, uint256 _tokenPrice) {

	  	// Assign an admin
	  	admin = msg.sender;

	  	// Token contract
	  	tokenContract = _tokenContract;
	  	// Token price
	  	tokenPrice = _tokenPrice;
	}

	function multiply (uint x, uint y) internal pure returns(uint res) {
		require (y == 0 || (res = x * y) / y == x);
	}
	

	function buyTokens (uint256 _numberOfTokens) public payable {

		// Require that value is equal to tokens
		require(msg.value == multiply(_numberOfTokens, tokenPrice));
		// Require that the contract has enough tokens
		require (tokenContract.balanceOf(address(this)) >= _numberOfTokens);
		require (tokenContract.transfer(msg.sender, _numberOfTokens));
		
		// keep track of the tokenSold
		tokenSold += _numberOfTokens;

		emit Sell(msg.sender, _numberOfTokens);
	}

	function endSale () public {
		// Require admin
		require (msg.sender == admin);
		
		// Transfer remaining dapp tokens to admin
		require (tokenContract.transfer(admin, tokenContract.balanceOf(address(this))));
	
        // UPDATE: Let's not destroy the contract here
        // Just transfer the balance to the admin
        payable(admin).transfer(address(this).balance);
	}
	
	
}