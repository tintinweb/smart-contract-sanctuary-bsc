/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IMasterWombat {
    struct PoolInfo {
        // storage slot 1
        address lpToken; // Address of LP token contract.
        uint96 allocPoint; // How many allocation points assigned to this pool. WOMs to distribute per second.
        // storage slot 2
        address rewarder;
        // storage slot 3
        uint256 sumOfFactors; // the sum of all boosted factors by all of the users in the pool
        // storage slot 4
        uint104 accWomPerShare; // 19.12 fixed point. Accumulated WOMs per share, times 1e12.
        uint104 accWomPerFactorShare; // 19.12 fixed point.accumulated wom per factor share
        uint40 lastRewardTimestamp; // Last timestamp that WOMs distribution occurs.
    }

    function poolInfo(uint256 _index) external view returns (PoolInfo memory);
}

interface IVotingProxy {
    function lpTokenToPid(address gague, address lptoken) external view returns (uint256 pid);
}

interface IBooster {
    struct PoolInfo {
        address lptoken;
        address token;
        address gauge;
        address crvRewards;
        bool shutdown;
    }
    function poolInfo(uint256 _index) external view returns (PoolInfo memory);
    function crvLockRewards() external view returns (address);
    function poolLength() external view returns (uint256);
}

interface IBaseRewardPool4626 {
    struct RewardState {
        address token;
        uint256 periodFinish;
        uint256 rewardRate;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
        uint256 queuedRewards;
        uint256 currentRewards;
        uint256 historicalRewards;
        bool paused;
    }

    function claimableRewards(address _account)
        external view returns (address[] memory tokens, uint256[] memory amounts);
    function tokenRewards(address _rewardToken)
        external view returns (RewardState memory);
}

contract LensPoker {
    address internal constant WOM_TOKEN = 0xAD6742A35fB341A9Cc6ad674738Dd8da98b94Fb1;
    address internal constant WMX_BOOSTER = 0x9Ac0a3E8864Ea370Bf1A661444f6610dd041Ba1c;
    address internal constant WMX_VOTING_PROXY = 0xE3a7FB9C6790b02Dcfa03B6ED9cda38710413569;
    address internal constant WOM_MASTER_WOMBAT = 0xE2C07d20AF0Fb50CAE6cDD615CA44AbaAA31F9c8;

    function getPoolsToPoke1() public view returns(uint256[] memory) {
        return getPokeRequiredPoolIds(false);
    }
    function getPoolsToPoke2() public view returns(uint256[] memory) {
        return getPokeRequiredPoolIds(true);
    }

    function getPokeRequiredPoolIds(bool checkPeriodFinished) public view returns(uint256[] memory) {
        uint256 len = IBooster(WMX_BOOSTER).poolLength();
        uint256 requiredLen = 0;
        bool[] memory pokeRequired = new bool[](len);

        for (uint256 i = 0; i < len; i++) {
            IBooster.PoolInfo memory poolInfo = IBooster(WMX_BOOSTER).poolInfo(i);

            // 0. Ignore if the pool is shut down
            if (poolInfo.shutdown) {
                continue;
            }

            // 1. Ignore if reward distribution paused
            uint256 womPid = IVotingProxy(WMX_VOTING_PROXY).lpTokenToPid(poolInfo.gauge, poolInfo.lptoken);
            IMasterWombat.PoolInfo memory womPoolInfo = IMasterWombat(WOM_MASTER_WOMBAT).poolInfo(womPid);
            if (womPoolInfo.allocPoint == 0) {
                continue;
            }

            if (checkPeriodFinished) {
                // 2. Ignore if periodFinished is not happened yet
                uint256 periodFinish = IBaseRewardPool4626(poolInfo.crvRewards).tokenRewards(WOM_TOKEN).periodFinish;
                if (periodFinish > block.timestamp) {
                    continue;
                }
            }

            // Push to the results list
            pokeRequired[i] = true;
            requiredLen++;
        }

        uint256[] memory result = new uint256[](requiredLen);
        uint256 j = 0;

        for (uint256 i = 0; i < len; i++) {
            if (pokeRequired[i]) {
                result[j++] = i;
            }
        }

        return result;
    }
}