// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "./Ownable.sol";
import "./IERC721.sol";
import "./ReentrancyGuard.sol";
import "./IERC20.sol";
import "./DateTime.sol";
import "./IERC20.sol";


contract HappyCatsPledge is Ownable, ReentrancyGuard {

    // 份额
    mapping (address => uint256) public share;

    // 质押数量
    uint256 public totalNum;

    // 奖励数量
    uint256 public rewardAmount;

    // 所属
    mapping (uint256 => address) public ownerOf;

    // 每个地址提取数量
    mapping (address => uint256) public withdraw;

    IERC721 public happyCats;

    IERC20 public TCD;

    constructor(address _happyCats, address _tcd) {
        happyCats = IERC721(_happyCats);
        TCD = IERC20(_tcd);
    }

    // 质押
    function pledge(uint256 tokenId) external nonReentrant {
        share[msg.sender] += 1;
        totalNum += 1;
        ownerOf[tokenId] = msg.sender;
        happyCats.transferFrom(msg.sender, address(this), tokenId);
    }

    // 解压
    function unpledge(uint256 tokenId) external nonReentrant {
        require(ownerOf[tokenId] == msg.sender, "Invalid");
        share[msg.sender] -= 1;
        totalNum -= 1;
        happyCats.transferFrom(msg.sender, address(this), tokenId);
    }

    // 填充奖励
    function fixReward(uint256 fixAmount) external onlyOwner {
        rewardAmount += fixAmount;
        TCD.transferFrom(msg.sender, address(this), fixAmount);
    }

    // 提币
    function withdrawal() external nonReentrant {
        require (totalNum > 0, "totalNum <= 0");
        uint256 amount = share[msg.sender] * rewardAmount / totalNum;
        uint256 withdrawAmount = amount - withdraw[msg.sender];
        TCD.transfer(msg.sender, withdrawAmount);
        withdraw[msg.sender] += withdrawAmount;
    }

    function changeHappyCats(IERC721 hc) external onlyOwner {
        happyCats = hc;
    }

    function changeTCD(IERC20 tcd) external onlyOwner {
        TCD = tcd;
    }
}