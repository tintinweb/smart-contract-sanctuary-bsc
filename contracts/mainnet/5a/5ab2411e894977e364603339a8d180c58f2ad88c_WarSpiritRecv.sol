/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract WarSpiritRecv {

	event RecvSuccess(address indexed from, string requestId);

	function recv(string memory requestId) public returns (bool) {
		emit RecvSuccess(msg.sender, requestId);
        return true;
	}
}