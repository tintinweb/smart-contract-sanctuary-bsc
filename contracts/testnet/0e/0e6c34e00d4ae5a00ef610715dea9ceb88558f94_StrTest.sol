/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract StrTest {
	string public test;

	function setStr(string memory s) external {
		test = s;
	}
}