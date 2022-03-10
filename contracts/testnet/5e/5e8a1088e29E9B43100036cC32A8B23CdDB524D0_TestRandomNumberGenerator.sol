/**
 *Submitted for verification at BscScan.com on 2022-03-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ITitanoLottery {
    function viewCurrentLotteryId() external returns (uint256);
}
contract TestRandomNumberGenerator {
    address public titanoLottery;
    uint32 public randomResult;
    uint256 public latestLotteryId;

    function getRandomNumber(uint256 _seed) external {
        require(msg.sender == titanoLottery, "Only TitanoLottery");
        uint random = uint256(keccak256(abi.encode(_seed)));
        fulfillRandomness(random);
    }

    function setLotteryAddress(address _titanoLottery) external {
        titanoLottery = _titanoLottery;
    }

    function viewLatestLotteryId() external view returns (uint256) {
        return latestLotteryId;
    }

    function viewRandomResult() external view returns (uint32) {
        return randomResult;
    }

    function fulfillRandomness(uint256 randomness) internal {
        randomResult = uint32(100000000 + (randomness % 100000000));
        latestLotteryId = ITitanoLottery(titanoLottery).viewCurrentLotteryId();
    }
}