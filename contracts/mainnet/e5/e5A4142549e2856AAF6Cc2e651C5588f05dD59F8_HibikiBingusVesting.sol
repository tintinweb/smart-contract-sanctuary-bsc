/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

/**
 * Vesting of the Hibiki token for former Bingus holders.
 * It is linear, smaller vested amounts take less time than longer amounts.
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IBEP20 {
	function transfer(address recipient, uint256 amount) external returns (bool);
	function balanceOf(address account) external view returns (uint256);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract HibikiBingusVesting {

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

	function addVesters(address[] calldata receivers, uint256[] calldata totals) external onlyOwner {
		require(receivers.length == totals.length, "Array mismatch");
		for (uint256 i = 0; i < receivers.length; i++) {
			_addVest(receivers[i], totals[i]);
		}
	}

	function addVest(address receiver, uint256 total) external onlyOwner {
		_addVest(receiver, total);
	}
	
	function _addVest(address receiver, uint256 total) private {
		hasVest[receiver] = true;
		totalToGive[receiver] += total;
		totalVested += total;
		vesters.push(receiver);
	}

	function removeVest(address receiver) external onlyOwner {
		hasVest[receiver] = false;
		totalVested -= totalToGive[receiver];
		uint256 index = type(uint256).max;
		for (uint256 i = 0; i < vesters.length; i++) {
			if (vesters[i] == receiver) {
				index = i;
				break;
			}
		}
		if (index < type(uint256).max) {
			vesters[index] = vesters[vesters.length - 1];
			vesters.pop();
		}
	}

	function runVest() external {
		IBEP20 t = IBEP20(hibiki);
		uint256 toGive = t.balanceOf(address(this));
		uint256 individual = toGive / vesters.length;

		// Share equally the received tokens to all people in vesting.
		for (uint256 i = 0; i < vesters.length; i++) {
			address v = vesters[i];
			if (!hasVest[v]) {
				continue;
			}
			uint256 gib = individual;
			uint256 due = totalToGive[v] - given[v];
			if (due < individual) {
				gib = due;
				hasVest[v] = false;
			}
			t.transfer(v, gib);
			given[v] += gib;
			totalGiven += gib;
		}
	}

	function recoverTokens() external {
		IBEP20 bikky = IBEP20(hibiki);
		bikky.transfer(owner, bikky.balanceOf(address(this)));
	}

	function getVesters() external view returns (address[] memory) {
		return vesters;
	}

	function getVest(address add) external view returns (bool, uint256, uint256) {
		return (hasVest[add], totalToGive[add], given[add]);
	}
}