// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ModuleBase.sol";
import "./AppWallet.sol";

contract RewardAccount is ModuleBase {

    uint256 private constant reward_type_landbureau_lose_refund      = 1;
    uint256 private constant reward_type_landbureau_shared_bingo     = 2;
    uint256 private constant reward_type_landbureau_shared_not_bingo = 3;
    uint256 private constant reward_type_landbureau_miner            = 4;

    struct RewardData {
        uint256 totalAmount;
        uint256 claimedAmount;
    }

    mapping(address => RewardData) mapUserReward;

    event rewardAdded(address account, uint256 rewardType, uint256 amount);

    constructor(address _auth, address _moduleMgr)
        ModuleBase(_auth, _moduleMgr)
    {}

    function addReward(address account, uint256 rewardType, uint256 amount) external onlyCaller {
        if(mapUserReward[account].totalAmount > 0) {
            RewardData storage rd = mapUserReward[account];
            rd.totalAmount += amount;
        } else {
            mapUserReward[account] = RewardData(amount, 0);
        }
        
        emit rewardAdded(account, rewardType, amount);
    }

    function getRewardInfo(address account) external view returns (bool res, uint256 totalAmount, uint256 claimedAmount) {
        if(mapUserReward[account].totalAmount > 0) {
            res = true;
            totalAmount = mapUserReward[account].totalAmount;
            claimedAmount = mapUserReward[account].claimedAmount;
        }
    }

    function useReward(address account, uint256 amount) external onlyCaller {
        require(mapUserReward[account].totalAmount > mapUserReward[account].claimedAmount + amount, "insufficient reward amount");
        mapUserReward[account].claimedAmount += amount;
    }

    function claimedReward(uint256 amount) external {
        require(mapUserReward[msg.sender].totalAmount > mapUserReward[msg.sender].claimedAmount, "have no reward to claim");
        require(mapUserReward[msg.sender].totalAmount >= mapUserReward[msg.sender].claimedAmount + amount, "have no reward to claim");
        AppWallet(moduleMgr.getAppWallet()).transferToken(auth.getFarmToken(), msg.sender, amount);
        mapUserReward[msg.sender].claimedAmount += amount;
    }
}