/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface ve {
    function balanceOfAtNFT(uint _tokenId, uint _block) external view returns (uint);
    function balanceOfNFTAt(uint _tokenId, uint _t) external view returns (uint);
    function totalSupplyAt(uint _block) external view returns (uint);
    function totalSupplyAtT(uint t) external view returns (uint);
    function ownerOf(uint) external view returns (address);
    function create_lock(uint _value, uint _lock_duration) external returns (uint);
}

contract Reward {
    using SafeERC20 for IERC20;

    struct EpochInfo {
        uint startTime;
        uint endTime;
        uint rewardPerSecond; // totalReward * RewardMultiplier / (endBlock - startBlock)
    }

    /// @dev Ve nft
    address public immutable _ve;
    /// @dev reward erc20 token, USDT
    address public immutable rewardToken;
    /// @dev RewardMultiplier
    uint immutable RewardMultiplier = 10000000;
    /// @dev BlockMultiplier
    uint immutable BlockMultiplier = 1000000000000000000;
    /// @dev Max epoch number user can query
    uint immutable MaxQueryEpochNumber = 360;
    /// @dev Max epoch number user can claim
    uint immutable MaxClaimEpochNumber = 30;

    /// @dev reward epochs.
    EpochInfo[] public epochInfo;

    /// @dev user's last claim time.
    mapping(uint => mapping(uint => uint)) public userLastClaimTime; // tokenId -> epoch id -> last claim timestamp\
    /// @dev first unfinish epoch.
    uint public firstUnfinishedEpochId;
    /// @dev user's first unfinished epoch.
    mapping(uint => uint) public userFirstUnfinishedEpoch;
    /// @dev total claimed reward in an epoch
    mapping(uint => uint) public totalClaimed; // epochInfo index -> total claimed amount

    address public admin;

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    event LogClaimReward(uint tokenId, uint reward);
    event LogAddEpoch(uint epochId, EpochInfo epochInfo);
    event LogAddEpoch(uint startTime, uint endTime, uint epochLength, uint startEpochId);

    struct epochBatch {
        uint startEpochId;
        uint endEpochId;
        uint startTime;
        uint endTime;
        uint epochLength;
    }

    constructor (
        address _ve_,
        address rewardToken_
    ) {
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
    function getBlockByTime(uint _time) public view returns (uint) {
        // Binary search
        uint _min = 0;
        uint _max = point_history.length - 1; // asserting length >= 2
        for (uint i = 0; i < 128; ++i) {
            // Will be always enough for 128-bit numbers
            if (_min >= _max) {
                break;
            }
            uint _mid = (_min + _max + 1) / 2;
            if (point_history[_mid].ts <= _time) {
                _min = _mid;
            } else {
                _max = _mid - 1;
            }
        }

        Point memory point0 = point_history[_min];
        Point memory point1 = point_history[_min + 1];
        // asserting point0.blk < point1.blk, point0.ts < point1.ts
        uint block_slope; // dblock/dt
        block_slope = (BlockMultiplier * (point1.blk - point0.blk)) / (point1.ts - point0.ts);
        uint dblock = (block_slope * (_time - point0.ts)) / BlockMultiplier;
        return point0.blk + dblock;
    }

    function withdrawFee(uint amount) external onlyAdmin {
        IERC20(rewardToken).safeTransfer(admin, amount);
    }

    /// @notice get user's power at some point in the past
    /// panic when epoch hasn't started
    function getPower(uint tokenId, uint epochId) view public returns (uint) {
        EpochInfo memory epoch = epochInfo[epochId];
        uint startBlock = getBlockByTime(epoch.startTime);
        return ve(_ve).balanceOfAtNFT(tokenId, startBlock);
    }

    /// @notice total power at some point in the past
    /// panic when epoch hasn't started
    function getTotalPower(uint epochId) view public returns (uint) {
        EpochInfo memory epoch = epochInfo[epochId];
        uint startBlock = getBlockByTime(epoch.startTime);
        return ve(_ve).totalSupplyAt(startBlock);
    }

    function transferAdmin(address _admin) external onlyAdmin {
        admin = _admin;
    }

    /// @notice add one epoch
    /// @return epochId
    /// @return accurateTotalReward
    function addEpoch(uint startTime, uint endTime, uint totalReward) external onlyAdmin returns(uint, uint) {
        assert(block.timestamp < endTime && startTime < endTime);
        (uint epochId, uint accurateTotalReward) = _addEpoch(startTime, endTime, totalReward);
        uint lastPointTime = point_history[point_history.length - 1].ts;
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
    function addEpochBatch(uint startTime, uint endTime, uint epochLength, uint totalReward) external onlyAdmin returns(uint, uint, uint) {
        assert(block.timestamp < endTime && startTime < endTime);
        uint numberOfEpoch = (endTime + 1 - startTime) / epochLength;
        uint _reward = totalReward / numberOfEpoch;
        uint _start = startTime;
        uint _end;
        uint _epochId;
        uint accurateTR;
        for (uint i = 0; i < numberOfEpoch; i++) {
            _end = _start + epochLength;
            (_epochId, accurateTR) = _addEpoch(_start, _end, _reward);
            _start = _end;
        }
        uint lastPointTime = point_history[point_history.length - 1].ts;
        if (lastPointTime < block.timestamp) {
            addCheckpoint();
        }
        emit LogAddEpoch(startTime, _end, epochLength, _epochId + 1 - numberOfEpoch);
        return (_epochId + 1 - numberOfEpoch, _epochId, accurateTR);
    }

    /// @notice add one epoch
    /// @return epochId
    /// @return accurateTotalReward
    function _addEpoch(uint startTime, uint endTime, uint totalReward) internal returns(uint, uint) {
        uint rewardPerSecond = totalReward * RewardMultiplier / (endTime - startTime);
        uint epochId = epochInfo.length;
        epochInfo.push(EpochInfo(startTime, endTime, rewardPerSecond));
        uint accurateTotalReward = (endTime - startTime) * rewardPerSecond / RewardMultiplier;
        return (epochId, accurateTotalReward);
    }

    /// @notice set epoch reward
    function updateEpochReward(uint epochId, uint totalReward) external onlyAdmin {
        require(block.timestamp < epochInfo[epochId].startTime);
        epochInfo[epochId].rewardPerSecond = totalReward * RewardMultiplier / (epochInfo[epochId].endTime - epochInfo[epochId].startTime);
    }

    /// @notice query pending reward by epoch
    /// @return pendingReward
    /// @return finished
    /// panic when block.timestamp < epoch.startTime
    function pendingRewardSingle(uint tokenId, uint epochId, EpochInfo memory epoch) internal view returns (uint, bool) {
        uint startBlock = getBlockByTime(epoch.startTime);
        uint power = ve(_ve).balanceOfAtNFT(tokenId, startBlock);
        uint totalPower = ve(_ve).totalSupplyAt(startBlock);
        
        uint last = userLastClaimTime[tokenId][epochId];
        last = last >= epoch.startTime ? last : epoch.startTime;
        if (last >= epoch.endTime) {
            return (0, true);
        }
        
        uint end = block.timestamp;
        bool finished = false;
        if (end > epoch.endTime) {
            end = epoch.endTime;
            finished = true;
        }
        
        uint reward = epoch.rewardPerSecond * (end - last) * power / totalPower / RewardMultiplier;
        return (reward, finished);
    }

    /// @notice query all unexpired pending reward
    function pendingReward(uint tokenId) public view returns (uint reward, bool complete) {
        uint cnt = 0;
        complete = true;
        for (uint i = userFirstUnfinishedEpoch[tokenId]; i < epochInfo.length; i++) {
            (uint reward_i,) = pendingRewardSingle(tokenId, i, epochInfo[i]);
            reward + reward_i;
            cnt++;
            if (cnt == MaxQueryEpochNumber) {
                if (i < epochInfo.length - 1) {
                    complete = false;
                }
                break;
            }
        }
        return (reward, complete);
    }

    /// @notice claim all unexpired pending reward
    function claimReward(uint tokenId) external returns (uint reward, bool complete) {
        require(msg.sender == ve(_ve).ownerOf(tokenId));
        point_history[point_history.length - 1];
        uint cnt = 0;
        complete = true;
        EpochInfo memory epoch;
        uint lastPointTime = point_history[point_history.length - 1].ts;
        uint u_firstUnfinished = 0;
        for (uint i = userFirstUnfinishedEpoch[tokenId]; i < epochInfo.length; i++) {
            epoch = epochInfo[i];
            if (block.timestamp < epoch.startTime) {
                continue;
            }
            if (lastPointTime < epoch.startTime) {
                // this branch runs 0 or 1 time
                lastPointTime = block.timestamp;
                addCheckpoint();
            }
            (uint reward_i, bool finished) = pendingRewardSingle(tokenId, i, epoch);
            if (!finished && u_firstUnfinished == 0) {
                u_firstUnfinished = i + 1;
            }
            reward += reward_i;
            totalClaimed[i] += reward_i;
            if (reward_i > 0) {
                userLastClaimTime[tokenId][i] = block.timestamp;
            }
            if (cnt == MaxClaimEpochNumber) {
                if (i < epochInfo.length - 1) {
                    complete = false;
                }
                break;
            }
        }
        if (u_firstUnfinished > 0) {
            userFirstUnfinishedEpoch[tokenId] = u_firstUnfinished - 1;
            if (firstUnfinishedEpochId < u_firstUnfinished) {
                firstUnfinishedEpochId = u_firstUnfinished;
            }
        }
        IERC20(rewardToken).safeTransfer(ve(_ve).ownerOf(tokenId), reward);
        emit LogClaimReward(tokenId, reward);
        return (reward, complete);
    }

    /// @notice get last epoch info
    /// @return startTime
    /// @return endTime
    /// @return totalReward
    function getFirstUnfinishedEpochInfo() public view returns (uint, uint, uint) {
        EpochInfo memory epoch = epochInfo[firstUnfinishedEpochId];
        uint totalReward = (epoch.endTime - epoch.startTime) * epoch.rewardPerSecond / RewardMultiplier;
        return (epoch.startTime, epoch.endTime, totalReward);
    }
}