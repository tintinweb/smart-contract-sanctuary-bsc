/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

/**
 * Vesting of the Hibiki token.
 * It is linear, smaller vested amounts take less time than longer amounts.
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IBEP20 {
	function transfer(address recipient, uint256 amount) external returns (bool);
	function balanceOf(address account) external view returns (uint256);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract HibikiVesting {

	address public owner;
	address public hibiki;
	mapping (address => bool) hasVest;
	mapping (address => uint256) totalToGive;
	mapping (address => uint256) given;
	address[] public vesters;
	uint256 public totalVested;
	uint256 public totalGiven;

	constructor(address token) {
		owner = msg.sender;
		hibiki = token;
	}

	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}

	function addVest(address receiver, uint256 total) external onlyOwner {
		hasVest[receiver] = true;
		totalToGive[receiver] += total;
		totalVested += total;
		vesters.push(receiver);
	}

	function removeVest(address receiver) external onlyOwner {
		hasVest[receiver] = false;
		totalVested -= totalToGive[receiver];
		uint256 index;
		for (uint256 i = 0; i < vesters.length; i++) {
			if (vesters[i] == receiver) {
				index = i;
				break;
			}
		}
		vesters[index] = vesters[vesters.length - 1];
		vesters.pop();
	}

	function runVest() external {
		IBEP20 t = IBEP20(hibiki);
		uint256 toGive = t.balanceOf(address(this));
		uint256 individual = toGive / vesters.length;
		uint256[] memory topped;
		uint256 j = 0;

		// Share equally the received tokens to all people in vesting.
		for (uint256 i = 0; i < vesters.length; i++) {
			address v = vesters[i];
			if (!hasVest[v]) {
				topped[j] = i;
				j++;
				continue;
			}
			uint256 gib = individual;
			if (totalToGive[v] - given[v] < individual) {
				gib = totalToGive[v] - given[v];
			}
			t.transfer(v, gib);
			given[v] += gib;
			totalGiven += gib;
		}

		// Remove people who do not need more vesting.
		for (uint256 i = 0; i < topped.length; i++) {
			uint256 index = topped[i];
			vesters[index] = vesters[vesters.length - 1];
			vesters.pop();
		}
	}

	function recoverTokens() external {
		IBEP20 bikky = IBEP20(hibiki);
		bikky.transfer(owner, bikky.balanceOf(address(this)));
	}
}