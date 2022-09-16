// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TimedTaskTrigger.sol";
import "./AnyCallApp.sol";

interface IVE {
    function totalSupplyAtT(uint256 t) external view returns (uint256); // query total power at a future time
}

interface IReward {
    function addEpoch(
        uint256 startTime,
        uint256 endTime,
        uint256 totalReward
    ) external returns (uint256, uint256);
}

contract RewardDistributor_Test is TimedTaskTrigger, AnyCallApp {
    address public ve;
    address public reward; // AdminCallModifier
    uint256[] public destChains;
    mapping(uint256 => uint256) public totalReward; // epoch -> totalReward

    struct Power {
        uint256 epoch;
        uint256 value;
    }

    Power public power;

    mapping(uint256 => Power) public peerPowers;

    event TotalReward(uint256 totalReward);
    event SetReward(uint256 epochId, uint256 accurateTotalReward);

    uint256 interval = 15 minutes;

    constructor(
        address _ve,
        address _reward,
        uint256[] memory destChains_,
        address anyCallProxy
    ) AnyCallApp(anyCallProxy, 2) {
        setAdmin(msg.sender);
        ve = _ve;
        reward = _reward;
        uint256 zeroTime = (block.timestamp / interval + 1) * interval - 600;
        uint256 window = 300;
        _initTimedTask(zeroTime, interval, window);
        destChains = destChains_;
    }

    function snapshotTime() public view returns (uint256) {
        return (block.timestamp / interval + 1) * interval;
    }

    function setTotalReward(uint256[] calldata epochNums, uint256 _totalReward)
        external
        onlyAdmin
    {
        for (uint256 i = 0; i < epochNums.length; i++) {
            totalReward[epochNums[i]] = _totalReward;
        }
    }

    function currentEpoch() public view returns (uint256) {
        return block.timestamp / interval + 1;
    }

    function doTask() internal override {
        // query total power
        power = Power(
            block.timestamp / interval + 1,
            IVE(ve).totalSupplyAtT(snapshotTime())
        );
        // send anycall message
        bytes memory acmsg = abi.encode(power);
        for (uint256 i = 0; i < destChains.length; i++) {
            _anyCall(peer[destChains[i]], acmsg, address(0), destChains[i]);
        }
    }

    function _anyExecute(uint256 fromChainID, bytes calldata data)
        internal
        override
        returns (bool success, bytes memory result)
    {
        assert(power.epoch == block.timestamp / interval + 1);
        Power memory peerPower = abi.decode(data, (Power));
        peerPowers[fromChainID] = peerPower;
        // check all arrived
        uint256 totalPower = power.value;
        for (uint256 i = 0; i < destChains.length; i++) {
            if (peerPowers[destChains[i]].epoch != power.epoch) {
                return (true, "");
            }
            totalPower += peerPowers[destChains[i]].value;
        }
        emit TotalReward(totalPower);
        // set reward
        uint256 start = (power.epoch) * interval;
        uint256 end = start + interval;
        uint256 rewardi = (power.value * totalReward[power.epoch]) / totalPower;
        // set reward
        (uint256 epochId, uint256 accurateTotalReward) = IReward(reward)
            .addEpoch(start, end, rewardi);
        emit SetReward(epochId, accurateTotalReward);
        return (true, "");
    }
}