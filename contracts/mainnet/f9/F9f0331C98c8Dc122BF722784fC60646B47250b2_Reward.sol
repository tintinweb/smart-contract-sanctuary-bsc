// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import './libraries/SafeERC20.sol';
import './libraries/Address.sol';
import './interfaces/IERC20.sol';
import './interfaces/ve.sol';

contract Reward {
    using SafeERC20 for IERC20;

    struct EpochInfo {
        uint256 startTime;
        uint256 endTime;
        uint256 rewardPerSecond; // totalReward * RewardMultiplier / (endBlock - startBlock)
        uint256 totalPower;
        uint256 startBlock;
    }

    /// @dev Ve nft
    address public immutable _ve;
    /// @dev reward erc20 token, USDT
    address public immutable rewardToken;
    /// @dev RewardMultiplier
    uint256 immutable RewardMultiplier = 10000000;
    /// @dev BlockMultiplier
    uint256 immutable BlockMultiplier = 1000000000000000000;

    /// @dev reward epochs.
    EpochInfo[] public epochInfo;

    /// @dev user's last claim time.
    mapping(uint256 => mapping(uint256 => uint256)) public userLastClaimTime; // tokenId -> epoch id -> last claim timestamp\

    address public admin;
    address public pendingAdmin;

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    event LogClaimReward(uint256 tokenId, uint256 reward);
    event LogAddEpoch(uint256 epochId, EpochInfo epochInfo);
    event LogAddEpoch(uint256 startTime, uint256 epochLength, uint256 epochCount, uint256 startEpochId);
    event LogTransferAdmin(address pendingAdmin);
    event LogAcceptAdmin(address admin);

    constructor(address _ve_, address rewardToken_) {
        admin = msg.sender;
        _ve = _ve_;
        rewardToken = rewardToken_;
        // add init point
        addCheckpoint();
    }

    struct Point {
        uint256 ts;
        uint256 blk; // block
    }

    /// @dev list of checkpoints, used in getBlockByTime
    Point[] public point_history;

    /// @notice add checkpoint to point_history
    /// called in constructor, addEpoch, addEpochBatch and claimReward
    /// point_history increments without repetition, length always >= 1
    function addCheckpoint() internal {
        point_history.push(Point(block.timestamp, block.number));
    }

    /// @notice estimate last block number before given time
    /// @return blockNumber
    function getBlockByTime(uint256 _time) public view returns (uint256) {
        // Binary search
        uint256 _min;
        uint256 _max = point_history.length - 1; // asserting length >= 2
        for (uint256 i; i < 128; ) {
            // Will be always enough for 128-bit numbers
            if (_min >= _max) {
                break;
            }
            uint256 _mid = (_min + _max + 1) / 2;
            if (point_history[_mid].ts <= _time) {
                _min = _mid;
            } else {
                _max = _mid - 1;
            }
            unchecked {
                ++i;
            }
        }

        Point memory point0 = point_history[_min];
        Point memory point1 = point_history[_min + 1];
        if (_time == point0.ts) {
            return point0.blk;
        }
        // asserting point0.blk < point1.blk, point0.ts < point1.ts
        uint256 block_slope; // dblock/dt
        block_slope = (BlockMultiplier * (point1.blk - point0.blk)) / (point1.ts - point0.ts);
        uint256 dblock = (block_slope * (_time - point0.ts)) / BlockMultiplier;
        return point0.blk + dblock;
    }

    function sweepTokens(address _token, uint256 _amount) external onlyAdmin {
        _sendToken(_token, _amount, msg.sender);
    }

    function _sendToken(
        address _token,
        uint256 _amount,
        address _receiver
    ) private {
        if (_token == address(0)) {
            (bool sent, ) = _receiver.call{value: _amount}('');
            require(sent, 'failed to send native');
        } else {
            IERC20(_token).safeTransfer(_receiver, _amount);
        }
    }

    function transferAdmin(address _admin) external onlyAdmin {
        pendingAdmin = _admin;
        emit LogTransferAdmin(pendingAdmin);
    }

    function acceptAdmin() external {
        require(msg.sender == pendingAdmin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
        emit LogAcceptAdmin(admin);
    }

    /// @notice add one epoch
    /// @return epochId
    /// @return accurateTotalReward
    function addEpoch(
        uint256 startTime,
        uint256 endTime,
        uint256 totalReward
    ) external onlyAdmin returns (uint256, uint256) {
        assert(block.timestamp < endTime && startTime < endTime);
        if (epochInfo.length > 0) {
            require(epochInfo[epochInfo.length - 1].endTime <= startTime);
        }
        (uint256 epochId, uint256 accurateTotalReward) = _addEpoch(startTime, endTime, totalReward);
        uint256 lastPointTime = point_history[point_history.length - 1].ts;
        if (lastPointTime < block.timestamp) {
            addCheckpoint();
        }
        emit LogAddEpoch(epochId, epochInfo[epochId]);
        return (epochId, accurateTotalReward);
    }

    /// @notice add a batch of continuous epochs
    /// @return firstEpochId
    /// @return lastEpochId
    /// @return accurateTotalReward
    function addEpochBatch(
        uint256 startTime,
        uint256 epochLength,
        uint256 epochCount,
        uint256 totalReward
    )
        external
        onlyAdmin
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        require(block.timestamp < startTime + epochLength);
        if (epochInfo.length > 0) {
            require(epochInfo[epochInfo.length - 1].endTime <= startTime);
        }
        uint256 _reward = totalReward / epochCount;
        uint256 _epochId;
        uint256 accurateTR;
        uint256 _start = startTime;
        uint256 _end = _start + epochLength;
        for (uint256 i; i < epochCount; ++i) {
            (_epochId, accurateTR) = _addEpoch(_start, _end, _reward);
            _start = _end;
            _end = _start + epochLength;
        }
        uint256 lastPointTime = point_history[point_history.length - 1].ts;
        if (lastPointTime < block.timestamp) {
            addCheckpoint();
        }
        emit LogAddEpoch(startTime, epochLength, epochCount, _epochId + 1 - epochCount);
        return (_epochId + 1 - epochCount, _epochId, accurateTR * epochCount);
    }

    /// @notice add one epoch
    /// @return epochId
    /// @return accurateTotalReward
    function _addEpoch(
        uint256 startTime,
        uint256 endTime,
        uint256 totalReward
    ) internal returns (uint256, uint256) {
        uint256 rewardPerSecond = (totalReward * RewardMultiplier) / (endTime - startTime);
        uint256 epochId = epochInfo.length;
        epochInfo.push(EpochInfo(startTime, endTime, rewardPerSecond, 1, 1));
        uint256 accurateTotalReward = ((endTime - startTime) * rewardPerSecond) / RewardMultiplier;
        return (epochId, accurateTotalReward);
    }

    /// @notice set epoch reward
    function updateEpochReward(uint256 epochId, uint256 totalReward) external onlyAdmin {
        require(block.timestamp < epochInfo[epochId].startTime);
        epochInfo[epochId].rewardPerSecond =
            (totalReward * RewardMultiplier) /
            (epochInfo[epochId].endTime - epochInfo[epochId].startTime);
    }

    /// @notice query pending reward by epoch
    /// @return pendingReward
    /// @return finished
    /// panic when block.timestamp < epoch.startTime
    function _pendingRewardSingle(
        uint256 tokenId,
        uint256 lastClaimTime,
        EpochInfo memory epoch
    ) internal view returns (uint256, bool) {
        uint256 last = lastClaimTime >= epoch.startTime ? lastClaimTime : epoch.startTime;
        if (last >= epoch.endTime) {
            return (0, true);
        }
        if (epoch.totalPower == 0) {
            return (0, true);
        }

        uint256 end = block.timestamp;
        bool finished = false;
        if (end > epoch.endTime) {
            end = epoch.endTime;
            finished = true;
        }

        uint256 power = ve(_ve).balanceOfAtNFT(tokenId, epoch.startBlock);

        uint256 reward = (epoch.rewardPerSecond * (end - last) * power) / (epoch.totalPower * RewardMultiplier);
        return (reward, finished);
    }

    function checkpointAndCheckEpoch(uint256 epochId) public {
        uint256 lastPointTime = point_history[point_history.length - 1].ts;
        if (lastPointTime < block.timestamp) {
            addCheckpoint();
        }
        checkEpoch(epochId);
    }

    function checkEpoch(uint256 epochId) internal {
        if (epochInfo[epochId].startBlock == 1) {
            epochInfo[epochId].startBlock = getBlockByTime(epochInfo[epochId].startTime);
        }
        if (epochInfo[epochId].totalPower == 1) {
            epochInfo[epochId].totalPower = ve(_ve).totalSupplyAt(epochInfo[epochId].startBlock);
        }
    }

    struct Interval {
        uint256 startEpoch;
        uint256 endEpoch;
    }

    struct IntervalReward {
        uint256 startEpoch;
        uint256 endEpoch;
        uint256 reward;
    }

    function claimRewardMany(uint256[] calldata tokenIds, Interval[][] calldata intervals)
        public
        returns (uint256[] memory rewards)
    {
        require(tokenIds.length == intervals.length, 'length not equal');
        rewards = new uint256[](tokenIds.length);
        for (uint256 i; i < tokenIds.length; ++i) {
            rewards[i] = claimReward(tokenIds[i], intervals[i]);
        }
        return rewards;
    }

    function claimReward(uint256 tokenId, Interval[] calldata intervals) public returns (uint256 reward) {
        for (uint256 i; i < intervals.length; ++i) {
            reward += claimReward(tokenId, intervals[i].startEpoch, intervals[i].endEpoch);
        }
        return reward;
    }

    /// @notice claim reward in range
    function claimReward(
        uint256 tokenId,
        uint256 startEpoch,
        uint256 endEpoch
    ) public returns (uint256 reward) {
        require(msg.sender == ve(_ve).ownerOf(tokenId));
        require(endEpoch < epochInfo.length, 'claim out of range');
        EpochInfo memory epoch;
        uint256 lastPointTime = point_history[point_history.length - 1].ts;
        for (uint256 i = startEpoch; i <= endEpoch; ++i) {
            epoch = epochInfo[i];
            if (block.timestamp < epoch.startTime) {
                break;
            }
            if (lastPointTime < epoch.startTime) {
                // this branch runs 0 or 1 time
                lastPointTime = block.timestamp;
                addCheckpoint();
            }
            checkEpoch(i);
            (uint256 reward_i, bool finished) = _pendingRewardSingle(
                tokenId,
                userLastClaimTime[tokenId][i],
                epochInfo[i]
            );
            if (reward_i > 0) {
                reward += reward_i;
                userLastClaimTime[tokenId][i] = block.timestamp;
            }
            if (!finished) {
                break;
            }
        }
        IERC20(rewardToken).safeTransfer(ve(_ve).ownerOf(tokenId), reward);
        emit LogClaimReward(tokenId, reward);
        return reward;
    }

    /// @notice get epoch by time
    function getEpochIdByTime(uint256 _time) public view returns (uint256) {
        assert(epochInfo[0].startTime <= _time);
        if (_time > epochInfo[epochInfo.length - 1].startTime) {
            return epochInfo.length - 1;
        }
        // Binary search
        uint256 _min;
        uint256 _max = epochInfo.length - 1; // asserting length >= 2
        for (uint256 i; i < 128; ) {
            // Will be always enough for 128-bit numbers
            if (_min >= _max) {
                break;
            }
            uint256 _mid = (_min + _max + 1) / 2;
            if (epochInfo[_mid].startTime <= _time) {
                _min = _mid;
            } else {
                _max = _mid - 1;
            }
            unchecked { ++i; }
        }
        return _min;
    }

    /**
    External read functions
     */
    struct RewardInfo {
        uint256 epochId;
        uint256 reward;
    }

    uint256 constant MaxQueryLength = 50; // not used?

    /// @notice get epoch info
    /// @return startTime
    /// @return endTime
    /// @return totalReward
    function getEpochInfo(uint256 epochId)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        if (epochId >= epochInfo.length) {
            return (0, 0, 0);
        }
        EpochInfo memory epoch = epochInfo[epochId];
        uint256 totalReward = ((epoch.endTime - epoch.startTime) * epoch.rewardPerSecond) / RewardMultiplier;
        return (epoch.startTime, epoch.endTime, totalReward);
    }

    function getCurrentEpochId() public view returns (uint256) {
        uint256 currentEpochId = getEpochIdByTime(block.timestamp);
        return currentEpochId;
    }

    /// @notice only for external view functions
    /// Time beyond last checkpoint resulting in inconsistent estimated block number.
    function getBlockByTimeWithoutLastCheckpoint(uint256 _time) public view returns (uint256) {
        if (point_history[point_history.length - 1].ts >= _time) {
            return getBlockByTime(_time);
        }
        Point memory point0 = point_history[point_history.length - 1];
        if (_time == point0.ts) {
            return point0.blk;
        }
        uint256 block_slope;
        block_slope = (BlockMultiplier * (block.number - point0.blk)) / (block.timestamp - point0.ts);
        uint256 dblock = (block_slope * (_time - point0.ts)) / BlockMultiplier;
        return point0.blk + dblock;
    }

    function getEpochStartBlock(uint256 epochId) public view returns (uint256) {
        if (epochInfo[epochId].startBlock == 1) {
            return getBlockByTimeWithoutLastCheckpoint(epochInfo[epochId].startTime);
        }
        return epochInfo[epochId].startBlock;
    }

    function getEpochTotalPower(uint256 epochId) public view returns (uint256) {
        if (epochInfo[epochId].totalPower == 1) {
            uint256 blk = getEpochStartBlock(epochId);
            if (blk > block.number) {
                return ve(_ve).totalSupplyAtT(epochInfo[epochId].startTime);
            }
            return ve(_ve).totalSupplyAt(blk);
        }
        return epochInfo[epochId].totalPower;
    }

    /// @notice get user's power at epochId
    function getUserPower(uint256 tokenId, uint256 epochId) public view returns (uint256) {
        EpochInfo memory epoch = epochInfo[epochId];
        uint256 blk = getBlockByTimeWithoutLastCheckpoint(epoch.startTime);
        if (blk < block.number) {
            return ve(_ve).balanceOfAtNFT(tokenId, blk);
        }
        return ve(_ve).balanceOfNFTAt(tokenId, epochInfo[epochId].startTime);
    }

    /// @notice
    /// Current epoch reward is inaccurate
    /// because the checkpoint may not have been added.
    function getPendingRewardSingle(uint256 tokenId, uint256 epochId)
        public
        view
        returns (uint256 reward, bool finished)
    {
        if (epochId > getCurrentEpochId()) {
            return (0, false);
        }
        EpochInfo memory epoch = epochInfo[epochId];
        uint256 startBlock = getEpochStartBlock(epochId);
        uint256 totalPower = getEpochTotalPower(epochId);
        if (totalPower == 0) {
            return (0, true);
        }
        uint256 power = ve(_ve).balanceOfAtNFT(tokenId, startBlock);

        uint256 last = userLastClaimTime[tokenId][epochId];
        last = last >= epoch.startTime ? last : epoch.startTime;
        if (last >= epoch.endTime) {
            return (0, true);
        }

        uint256 end = block.timestamp;
        finished = false;
        if (end > epoch.endTime) {
            end = epoch.endTime;
            finished = true;
        }

        reward = (epoch.rewardPerSecond * (end - last) * power) / (totalPower * RewardMultiplier);
        return (reward, finished);
    }

    /// @notice get claimable reward
    function pendingReward(
        uint256 tokenId,
        uint256 start,
        uint256 end
    ) public view returns (IntervalReward[] memory intervalRewards) {
        uint256 current = getCurrentEpochId();
        require(start <= end);
        if (end > current) {
            end = current;
        }
        RewardInfo[] memory rewards = new RewardInfo[](end - start + 1);
        for (uint256 i = start; i <= end; ++i) {
            if (block.timestamp < epochInfo[i].startTime) {
                break;
            }
            (uint256 reward_i, ) = getPendingRewardSingle(tokenId, i);
            rewards[i - start] = RewardInfo(i, reward_i);
        }

        uint256 rewardsLength = rewards.length;

        // omit zero rewards and convert epoch list to intervals
        IntervalReward[] memory intervalRewards_0 = new IntervalReward[](rewardsLength);
        uint256 intv;
        uint256 intvCursor;
        uint256 sum;
        for (uint256 i; i < rewardsLength; ++i) {
            if (rewards[i].reward == 0) {
                if (i != intvCursor) {
                    intervalRewards_0[intv] = IntervalReward(rewards[intvCursor].epochId, rewards[i - 1].epochId, sum);
                    intv++;
                    sum = 0;
                }
                intvCursor = i + 1;
                continue;
            }
            sum += rewards[i].reward;
        }
        if (sum > 0) {
            intervalRewards_0[intv] = IntervalReward(
                rewards[intvCursor].epochId,
                rewards[rewards.length - 1].epochId,
                sum
            );
            intervalRewards = new IntervalReward[](intv + 1);
            // Copy interval array
            for (uint256 i; i < intv + 1; ++i) {
                intervalRewards[i] = intervalRewards_0[i];
            }
        } else {
            intervalRewards = new IntervalReward[](intv);
            // Copy interval array
            for (uint256 i; i < intv; ++i) {
                intervalRewards[i] = intervalRewards_0[i];
            }
        }

        return intervalRewards;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './Address.sol';
import '../interfaces/IERC20.sol';

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), 'SafeERC20: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, 'SafeERC20: low-level call failed');

        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeERC20: ERC20 operation did not succeed');
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;

        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ve {
    function balanceOfAtNFT(uint256 _tokenId, uint256 _block) external view returns (uint256);

    function balanceOfNFTAt(uint256 _tokenId, uint256 _t) external view returns (uint256);

    function totalSupplyAt(uint256 _block) external view returns (uint256);

    function totalSupplyAtT(uint256 t) external view returns (uint256);

    function ownerOf(uint256) external view returns (address);

    function create_lock(uint256 _value, uint256 _lock_duration) external returns (uint256);
}