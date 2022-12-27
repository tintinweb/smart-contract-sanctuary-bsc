// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract RaceForBNB {
    // 100 points to win!
    uint256 public SCORE_TO_WIN = 0.1 ether;
    uint256 public PRIZE;

    // 100 points = 0.1 ether
    // Speed limit: 0.05 eth to prevent insta-win
    // Prevents people from going too fast!
    uint256 public speed_limit = 0.05 ether;

    // Keep track of everyone's score
    mapping (address => uint256) public racerScore;
    mapping (address => uint256) public racerSpeedLimit;

    uint256 latestTimestamp;
    address owner;

    constructor() payable {
        PRIZE = msg.value;
        owner = msg.sender;
    }

    function race() public payable {
        if (racerSpeedLimit[msg.sender] == 0) {
            racerSpeedLimit[msg.sender] = speed_limit;
        }

        require(msg.value <= racerSpeedLimit[msg.sender] && msg.value > 1 wei);

        racerScore[msg.sender] += msg.value;
        racerSpeedLimit[msg.sender] = (racerSpeedLimit[msg.sender] / 2);

        latestTimestamp = block.timestamp;

        // YOU WON
        if (racerScore[msg.sender] >= SCORE_TO_WIN) {
            (bool success, ) = msg.sender.call{value: PRIZE}("");
            require(success, "failed");
        }
    }

    receive() external payable {
        race();
    }

    // Pull the prize if no one has raced in 3 days :(
    function endRace() external  {
        require(msg.sender == owner);
        require(block.timestamp >= latestTimestamp + 3 days);

        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "failed");
    }
}