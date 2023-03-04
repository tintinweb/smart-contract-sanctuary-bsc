// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Affinity.sol";

contract Testcraft {
    Affinity public token;
    address public owner;
    uint256 public rewardPerBlockMined;
    uint256 public rewardPerMobKilled;
    mapping(uint256 => uint256) public rewardPerBlockType;
    mapping(uint256 => uint256) public rewardPerMobType;
    mapping(address => uint256) public timePlayed;
    uint256 public earningMultiplier;

    bool public paused;

    event TokensEarned(address indexed player, uint256 amount);

    constructor(Affinity _token) {
        token = _token;
        owner = msg.sender;
        rewardPerBlockMined = 1;
        rewardPerMobKilled = 10;
        earningMultiplier = 1;
    }

    function setRewardPerBlockMined(uint256 amount) external onlyOwner {
        rewardPerBlockMined = amount;
    }

    function setRewardPerMobKilled(uint256 amount) external onlyOwner {
        rewardPerMobKilled = amount;
    }

    function setRewardPerBlockType(uint256 blockType, uint256 amount) external onlyOwner {
        rewardPerBlockType[blockType] = amount;
    }

    function setRewardPerMobType(uint256 mobType, uint256 amount) external onlyOwner {
        rewardPerMobType[mobType] = amount;
    }

    function setTimePlayed(address player, uint256 time) external onlyOwner {
        timePlayed[player] = time;
    }

    function setEarningMultiplier(uint256 multiplier) external onlyOwner {
        earningMultiplier = multiplier;
    }

    function earnTokens(uint256 blocksMined, uint256 mobsKilled, uint256[] memory blockTypes, uint256[] memory mobTypes) external {
        require(!paused, "Contract is paused");
        uint256 totalTokensEarned = (blocksMined * rewardPerBlockMined) + (mobsKilled * rewardPerMobKilled);
        for (uint256 i = 0; i < blockTypes.length; i++) {
            totalTokensEarned += rewardPerBlockType[blockTypes[i]];
        }
        for (uint256 i = 0; i < mobTypes.length; i++) {
            totalTokensEarned += rewardPerMobType[mobTypes[i]];
        }
        totalTokensEarned = totalTokensEarned * earningMultiplier * timePlayed[msg.sender];
        token.transfer(msg.sender, totalTokensEarned);
        emit TokensEarned(msg.sender, totalTokensEarned);
    }

    function withdrawTokens(uint256 amount) external onlyOwner {
        token.transfer(owner, amount);
    }

    function pauseContract() external onlyOwner {
        paused = true;
    }

    function unpauseContract() external onlyOwner {
        paused = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }
}