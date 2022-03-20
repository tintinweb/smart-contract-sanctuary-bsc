// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ILotteryRandom.sol";

contract LotteryRandom is IDynamixLotteryRandom {
	constructor() {
	
    }
	
    function getRandomNumber(uint256 random) override external view returns(uint32) {
		return uint32(uint(keccak256(abi.encodePacked(random, block.timestamp, block.difficulty, msg.sender))) % 1000000);
	}
}