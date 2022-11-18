pragma solidity ^0.8.0;

contract Administrable {
    address public admin;
    address public pendingAdmin;
    event LogSetAdmin(address admin);
    event LogTransferAdmin(address oldadmin, address newadmin);
    event LogAcceptAdmin(address admin);

    function setAdmin(address admin_) internal {
        admin = admin_;
        emit LogSetAdmin(admin_);
    }

    function transferAdmin(address newAdmin) external onlyAdmin {
        address oldAdmin = pendingAdmin;
        pendingAdmin = newAdmin;
        emit LogTransferAdmin(oldAdmin, newAdmin);
    }

    function acceptAdmin() external {
        require(msg.sender == pendingAdmin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
        emit LogAcceptAdmin(admin);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMessageChannel {
    function send(
        uint256 toChainID,
        address to,
        bytes memory message
    ) external virtual;
}

interface IMessageClient {
    function onReceiveMessage(
        address caller,
        uint256 fromChainID,
        bytes memory message
    ) external virtual;
}

abstract contract MessageChannelBase is IMessageChannel {
    function onReceive(
        address client,
        address caller,
        uint256 fromChainID,
        bytes memory message
    ) internal {
        IMessageClient(client).onReceiveMessage(caller, fromChainID, message);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TimedTaskTrigger.sol";
import "./messageChannel/MessageChannel.sol";
import "./Administrable.sol";

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

contract RewardDistributor is TimedTaskTrigger, Administrable, IMessageClient {
    address public ve;
    address public reward; // AdminCallModifier
    uint256 constant interval = 1 weeks;
    uint256[] public destChains;
    IMessageChannel public messageChannel;
    mapping(uint256 => uint256) public totalReward; // epoch -> totalReward

    struct Power {
        uint256 epoch;
        uint256 value;
    }

    Power public power;
    mapping(uint256 => address) public peer;

    mapping(uint256 => Power) public peerPowers;

    event TotalReward(uint256 totalReward);
    event SetReward(uint256 epochId, uint256 accurateTotalReward);
    event LatestReward(uint256 accurateTotalReward);

    constructor(
        address _ve,
        address _reward,
        uint256[] memory destChains_
    ) {
        setAdmin(msg.sender);
        ve = _ve;
        reward = _reward;
        uint256 zeroTime = (block.timestamp / interval + 1) *
            interval -
            3600 *
            12;
        uint256 window = 3600 * 6;
        uint256 peroid = 1 weeks;
        _initTimedTask(zeroTime, peroid, window);
        destChains = destChains_;
    }

    function setMessageChannel(address messageChannel_) public onlyAdmin {
        messageChannel = IMessageChannel(messageChannel_);
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
            messageChannel.send(destChains[i], peer[destChains[i]], acmsg);
        }
    }

    function onReceiveMessage(
        address caller,
        uint256 fromChainID,
        bytes memory message
    ) external override {
        require(peer[fromChainID] == caller);
        assert(power.epoch == block.timestamp / interval + 1);
        Power memory peerPower = abi.decode(message, (Power));
        peerPowers[fromChainID] = peerPower;
        // check all arrived
        uint256 totalPower = power.value;
        for (uint256 i = 0; i < destChains.length; i++) {
            if (peerPowers[destChains[i]].epoch != power.epoch) {
                return;
            }
            totalPower += peerPowers[destChains[i]].value;
        }
        emit TotalReward(totalPower);
        // set reward
        uint256 start = (power.epoch) * interval;
        uint256 end = start + interval;
        uint256 rewardi = (power.value * totalReward[power.epoch]) / totalPower;
        // set reward
        /*(uint256 epochId, uint256 accurateTotalReward) = IReward(reward)
            .addEpoch(start, end, rewardi);*/
        //emit SetReward(epochId, accurateTotalReward);
        emit LatestReward(rewardi);
        return;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Trigger {
    function doTask() internal virtual;

    function _beforeTriggered() internal virtual {}

    function _afterTriggered() internal virtual {}

    function triggerTask() external virtual {
        _beforeTriggered();
        doTask();
        _afterTriggered();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TaskTrigger.sol";

abstract contract TimedTaskTrigger is Trigger {
    uint256 public zeroTime;
    uint256 public peroid;
    uint256 public window;

    function _initTimedTask(
        uint256 zeroTime_,
        uint256 peroid_,
        uint256 window_
    ) internal {
        require(window_ <= peroid_, "invalid time params");
        zeroTime = zeroTime_;
        peroid = peroid_;
        window = window_;
    }

    uint256 public lastTriggerTime;

    function currentPeroid() view public returns (uint256) {
        if (block.timestamp < zeroTime) {
            return 1;
        }
        return (block.timestamp - zeroTime) / peroid + 1;
    }

    function _beforeTriggered() internal override {
        super._beforeTriggered();
    
        uint256 currentPeroid_ = currentPeroid();

        uint256 start = (currentPeroid_ - 1) * peroid + zeroTime;
        uint256 end = start + window;
        require(lastTriggerTime < start, "already triggered");
        require(block.timestamp >= start && block.timestamp < end, "currently not available");
    }

    function _afterTriggered() internal override {
        lastTriggerTime = block.timestamp;

        super._afterTriggered();
    }
}