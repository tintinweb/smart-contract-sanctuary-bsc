/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IBEP20 {
	function balanceOf(address account) external view returns (uint256);
}

contract Hibiversary {

	address public owner;
	address public HIBIKI;
	mapping (address => bool) public participating;
	address[] public participatingWallets;
	uint40 public end;
	bool public finished = false;
	address public winner;

	event Participation(address indexed participant);
	event WinnerPicked(address indexed winner);

	modifier onlyOwner {
		require(msg.sender == owner, "not so fast cowboy");
		_;
	}

	constructor(address bibiki, uint256 duration) {
		owner = msg.sender;
		HIBIKI = bibiki;
		end = uint40(block.timestamp + duration);
	}

	function participate() external {
		require(block.timestamp < end, "The time to join is over.");
		require(participating[msg.sender] == false, "You are already participating.");
		uint256 hb = IBEP20(HIBIKI).balanceOf(msg.sender);
		require(hb >= 1000 ether, "You need to own at least 1000 HIBIKI to participate");
		participating[msg.sender] = true;
		participatingWallets.push(msg.sender);

		emit Participation(msg.sender);
	}

	function pickWinner() external onlyOwner returns (bool) {
		require(!finished, "Finished");
		uint256 rand = prng();
		uint256 winn = rand % participatingWallets.length;
		address possible = participatingWallets[winn];
		uint256 hb = IBEP20(HIBIKI).balanceOf(possible);
		if (hb < 1000 ether) {
			participatingWallets[winn] = participatingWallets[participatingWallets.length - 1];
			participatingWallets.pop();
			return false;
		} else {
			finished = true;
			winner = possible;
			emit WinnerPicked(possible);
			return true;
		}
	}

	function prng() internal view returns (uint256) {
		return uint256(
			keccak256(
				abi.encodePacked(
					block.timestamp + block.difficulty + ((uint256(keccak256(abi.encodePacked(block.coinbase)))) /
					(block.timestamp)) + block.gaslimit + ((uint256(keccak256(abi.encodePacked(msg.sender)))) /
					(block.timestamp)) + block.number
				)
			)
		);
	}

	function getWinner() external view returns (address) {
		if (block.timestamp < end || !finished) {
			return address(0);
		}

		return winner;
	}

	function participants() external view returns (address[] memory) {
		return participatingWallets;
	}
}