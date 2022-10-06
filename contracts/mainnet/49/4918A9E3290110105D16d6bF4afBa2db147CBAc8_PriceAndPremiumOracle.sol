/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LPContract {
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
}

interface EBHorde {
    function  nodeCount() external view returns(uint16);

    function totalShareCount() external view returns (uint256);

    function premiumCollected() external view returns (uint256);
}

contract PriceAndPremiumOracle {
    address public manager;

    uint256 public lastUpdateReward;
    uint256 public lastUpdateTimestamp;

    LPContract lpContract = LPContract(0x990d2F68d869B314201eC2c1572A0e66b90b391B);
    EBHorde ebContract = EBHorde(0x827674a42694ce061d594C091B3278173e57feA8);

    constructor() {
        manager = msg.sender;
        lastUpdateTimestamp = block.timestamp;
    }

    // HELPER
    function getHordePrice() public view returns(uint112) {
        uint112 reserve0;
        uint112 reserve1;
        uint32 timestamp;
        (reserve0, reserve1, timestamp) = lpContract.getReserves();

        uint112 hordePrice = reserve1 * (10**2) / reserve0 * (10**16); // With 2 decimal points

        return hordePrice;
    }

    function secondsSinceLastUpdate() public view returns(uint256) {
        return block.timestamp - lastUpdateTimestamp;
    }

    function getReward() public view returns(uint256) {
        uint256 nodeCount = ebContract.nodeCount();
        uint256 timePast = secondsSinceLastUpdate(); // in seconds

        uint256 rewardGenerated = nodeCount * 1e18 * timePast / 60 / 60 / 24 / 10; // Every plot generates 0.1 $HORDE per day
        return rewardGenerated + lastUpdateReward;
    }

    function getRewardUsd() public view returns(uint256) {
        uint256 hordePrice = uint256(getHordePrice());

        return getReward() * hordePrice / (10**18);
    }

    // PRICE
    function getPrice() public view returns(uint256) {
        uint112 sharePrice = getHordePrice() / 10 / (10**4); // BUSD has 18 decimals, 1 share is 1/10th of horde, every UI share is actually 10000 shares
        return uint256(sharePrice);
    }

    // PREMIUM
    function updateReward(uint256 _reward) public {
        require(msg.sender == manager);
        lastUpdateReward = _reward * 1e15; // Reward is inputed in 4 digits for x.yyy format, $HORDE includes 18 decimals
        lastUpdateTimestamp = block.timestamp;
    }

    function getPremium() public view returns(uint256) {
        return (getRewardUsd() * 2 / 3 + ebContract.premiumCollected()) / ebContract.totalShareCount() / 1e12 * 1e12; // 33% of reward is used for auto re-investment. Don't care about the decimals corresponding to after .yy
    }
}