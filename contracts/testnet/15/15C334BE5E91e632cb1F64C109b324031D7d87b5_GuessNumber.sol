/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

contract GuessNumber {

	uint256 public balances;
	
	event Deposit(address from, uint256 amount);

    function deposit(uint256 amount) payable external {
        balances += amount;
        emit Deposit(msg.sender, amount);
    }

	function checkBalance() public view returns (uint256)  {
		return address(this).balance;
	}
	
}