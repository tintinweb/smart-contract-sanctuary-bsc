// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Transactions {
	event Transfer(
		address indexed sender,
		address indexed receiver,
		uint256 amount,
		string message,
		uint256 timestamp,
		string keyword
	);

	function publishTransaction(
		address payable _receiver,
		uint256 _amount,
		string memory _message,
		string memory _keyword
	) external {
		emit Transfer(msg.sender, _receiver, _amount, _message, block.timestamp, _keyword);
	}
}