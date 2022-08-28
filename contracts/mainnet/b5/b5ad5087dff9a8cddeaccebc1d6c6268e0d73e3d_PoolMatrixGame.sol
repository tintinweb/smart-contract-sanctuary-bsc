/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

contract PoolMatrixGame {

	// Addresses
    address payable public owner;
    address payable public tokenBurner;
	
	// Events
	event InitialTransfer(address indexed from, address indexed to, uint256 value, uint256 value2);

	constructor(address payable _tokenBurner) public {
       owner = payable(msg.sender);
       tokenBurner = _tokenBurner; // 0xe1727079Dee0197a38251533E8B5E218df557182
       
	   emit InitialTransfer(/*address(0)*/tokenBurner, msg.sender, 0, 1);
    }
	
	receive() external payable {
		emit InitialTransfer(/*address(0)*/tokenBurner, msg.sender, msg.value, 2);
		
		owner.transfer(msg.value / 2);
	}
}