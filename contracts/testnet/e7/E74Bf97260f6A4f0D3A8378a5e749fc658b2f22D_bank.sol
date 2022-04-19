/**
 *Submitted for verification at BscScan.com on 2022-04-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract bank {

	function deposit() external payable returns(bool){
		return true;
	}

	function withdraw() external returns(bool){
		sendValue(payable(msg.sender), address(this).balance);
		return true;
	}


	function sendValue(address payable recipient, uint256 amount) private {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

}