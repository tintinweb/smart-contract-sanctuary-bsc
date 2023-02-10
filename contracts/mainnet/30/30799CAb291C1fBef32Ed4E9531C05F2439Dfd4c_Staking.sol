// SPDX-License-Identifier: Apache 2.0

/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

// solhint-disable-next-line
pragma solidity 0.8.17;

import "./interfaces/IStaking.sol";
import "./sys/MixinParams.sol";
import "./stake/MixinStake.sol";
import "./rewards/MixinPopRewards.sol";

contract Staking is IStaking, MixinParams, MixinStake, MixinPopRewards {
    /// @notice Setting owner to null address prevents admin direct calls to implementation.
    /// @dev Initializing immutable implementation address is used to allow delegatecalls only.
    /// @dev Direct calls to the  implementation contract are effectively locked.
    /// @param grgVault Address of the Grg vault.
    /// @param poolRegistry Address of the RigoBlock pool registry.
    /// @param rigoToken Address of the Grg token.
    constructor(
        address grgVault,
        address poolRegistry,
        address rigoToken
    ) Authorizable(address(0)) MixinDeploymentConstants(grgVault, poolRegistry, rigoToken) {}

    /// @notice Initialize storage owned by this contract.
    /// @dev This function should not be called directly.
    /// @dev The StakingProxy contract will call it in `attachStakingContract()`.
    function init() public override onlyAuthorized {
        // DANGER! When performing upgrades, take care to modify this logic
        // to prevent accidentally clearing prior state.
        _initMixinScheduler();
        _initMixinParams();
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import {IPoolRegistry as PoolRegistry} from "../../protocol/interfaces/IPoolRegistry.sol";
import {IRigoToken as RigoToken} from "../../rigoToken/interfaces/IRigoToken.sol";
import "./IStructs.sol";
import {IGrgVault as GrgVault} from "./IGrgVault.sol";

interface IStaking {
    /// @notice Adds a new proof_of_performance address.
    /// @param addr Address of proof_of_performance contract to add.
    function addPopAddress(address addr) external;

    /// @notice Create a new staking pool. The sender will be the staking pal of this pool.
    /// @dev Note that a staking pal must be payable.
    /// @dev When governance updates registry address, pools must be migrated to new registry, or this contract must query from both.
    /// @param rigoblockPoolAddress Adds rigoblock pool to the created staking pool for convenience if non-null.
    /// @return poolId The unique pool id generated for this pool.
    function createStakingPool(address rigoblockPoolAddress) external returns (bytes32 poolId);

    /// @notice Allows the operator to update the staking pal address.
    /// @param poolId Unique id of pool.
    /// @param newStakingPalAddress Address of the new staking pal.
    function setStakingPalAddress(bytes32 poolId, address newStakingPalAddress) external;

    /// @notice Decreases the operator share for the given pool (i.e. increases pool rewards for members).
    /// @param poolId Unique Id of pool.
    /// @param newOperatorShare The newly decreased percentage of any rewards owned by the operator.
    function decreaseStakingPoolOperatorShare(bytes32 poolId, uint32 newOperatorShare) external;

    /// @notice Begins a new epoch, preparing the prior one for finalization.
    /// @dev Throws if not enough time has passed between epochs or if the
    /// @dev previous epoch was not fully finalized.
    /// @return numPoolsToFinalize The number of unfinalized pools.
    function endEpoch() external returns (uint256 numPoolsToFinalize);

    /// @notice Instantly finalizes a single pool that earned rewards in the previous epoch,
    /// @dev crediting it rewards for members and withdrawing operator's rewards as GRG.
    /// @dev This can be called by internal functions that need to finalize a pool immediately.
    /// @dev Does nothing if the pool is already finalized or did not earn rewards in the previous epoch.
    /// @param poolId The pool ID to finalize.
    function finalizePool(bytes32 poolId) external;

    /// @notice Initialize storage owned by this contract.
    /// @dev This function should not be called directly.
    /// @dev The StakingProxy contract will call it in `attachStakingContract()`.
    function init() external;

    /// @notice Moves stake between statuses: 'undelegated' or 'delegated'.
    /// @dev Delegated stake can also be moved between pools.
    /// @dev This change comes into effect next epoch.
    /// @param from Status to move stake out of.
    /// @param to Status to move stake into.
    /// @param amount Amount of stake to move.
    function moveStake(
        IStructs.StakeInfo calldata from,
        IStructs.StakeInfo calldata to,
        uint256 amount
    ) external;

    /// @notice Credits the value of a pool's pop reward.
    /// @dev Only a known RigoBlock pop can call this method. See (MixinPopManager).
    /// @param poolAccount The address of the rigoblock pool account.
    /// @param popReward The pop reward.
    function creditPopReward(address poolAccount, uint256 popReward) external payable;

    /// @notice Removes an existing proof_of_performance address.
    /// @param addr Address of proof_of_performance contract to remove.
    function removePopAddress(address addr) external;

    /// @notice Set all configurable parameters at once.
    /// @param _epochDurationInSeconds Minimum seconds between epochs.
    /// @param _rewardDelegatedStakeWeight How much delegated stake is weighted vs operator stake, in ppm.
    /// @param _minimumPoolStake Minimum amount of stake required in a pool to collect rewards.
    /// @param _cobbDouglasAlphaNumerator Numerator for cobb douglas alpha factor.
    /// @param _cobbDouglasAlphaDenominator Denominator for cobb douglas alpha factor.
    function setParams(
        uint256 _epochDurationInSeconds,
        uint32 _rewardDelegatedStakeWeight,
        uint256 _minimumPoolStake,
        uint32 _cobbDouglasAlphaNumerator,
        uint32 _cobbDouglasAlphaDenominator
    ) external;

    /// @notice Stake GRG tokens. Tokens are deposited into the GRG Vault.
    /// @dev Unstake to retrieve the GRG. Stake is in the 'Active' status.
    /// @param amount of GRG to stake.
    function stake(uint256 amount) external;

    /// @notice Unstake. Tokens are withdrawn from the GRG Vault and returned to the staker.
    /// @dev Stake must be in the 'undelegated' status in both the current and next epoch in order to be unstaked.
    /// @param amount of GRG to unstake.
    function unstake(uint256 amount) external;

    /// @notice Withdraws the caller's GRG rewards that have accumulated until the last epoch.
    /// @param poolId Unique id of pool.
    function withdrawDelegatorRewards(bytes32 poolId) external;

    /// @notice Computes the reward balance in GRG of a specific member of a pool.
    /// @param poolId Unique id of pool.
    /// @param member The member of the pool.
    /// @return reward Balance in GRG.
    function computeRewardBalanceOfDelegator(bytes32 poolId, address member) external view returns (uint256 reward);

    /// @notice Computes the reward balance in GRG of the operator of a pool.
    /// @param poolId Unique id of pool.
    /// @return reward Balance in GRG.
    function computeRewardBalanceOfOperator(bytes32 poolId) external view returns (uint256 reward);

    /// @notice Returns the earliest end time in seconds of this epoch.
    /// @dev The next epoch can begin once this time is reached.
    /// @dev Epoch period = [startTimeInSeconds..endTimeInSeconds)
    /// @return Time in seconds.
    function getCurrentEpochEarliestEndTimeInSeconds() external view returns (uint256);

    /// @notice Gets global stake for a given status.
    /// @param stakeStatus UNDELEGATED or DELEGATED
    /// @return balance Global stake for given status.
    function getGlobalStakeByStatus(IStructs.StakeStatus stakeStatus)
        external
        view
        returns (IStructs.StoredBalance memory balance);

    /// @notice Gets an owner's stake balances by status.
    /// @param staker Owner of stake.
    /// @param stakeStatus UNDELEGATED or DELEGATED
    /// @return balance Owner's stake balances for given status.
    function getOwnerStakeByStatus(address staker, IStructs.StakeStatus stakeStatus)
        external
        view
        returns (IStructs.StoredBalance memory balance);

    /// @notice Returns the total stake for a given staker.
    /// @param staker of stake.
    /// @return Total GRG staked by `staker`.
    function getTotalStake(address staker) external view returns (uint256);

    /// @dev Retrieves all configurable parameter values.
    /// @return _epochDurationInSeconds Minimum seconds between epochs.
    /// @return _rewardDelegatedStakeWeight How much delegated stake is weighted vs operator stake, in ppm.
    /// @return _minimumPoolStake Minimum amount of stake required in a pool to collect rewards.
    /// @return _cobbDouglasAlphaNumerator Numerator for cobb douglas alpha factor.
    /// @return _cobbDouglasAlphaDenominator Denominator for cobb douglas alpha factor.
    function getParams()
        external
        view
        returns (
            uint256 _epochDurationInSeconds,
            uint32 _rewardDelegatedStakeWeight,
            uint256 _minimumPoolStake,
            uint32 _cobbDouglasAlphaNumerator,
            uint32 _cobbDouglasAlphaDenominator
        );

    /// @notice Returns stake delegated to pool by staker.
    /// @param staker of stake.
    /// @param poolId Unique Id of pool.
    /// @return balance Stake delegated to pool by staker.
    function getStakeDelegatedToPoolByOwner(address staker, bytes32 poolId)
        external
        view
        returns (IStructs.StoredBalance memory balance);

    /// @notice Returns a staking pool
    /// @param poolId Unique id of pool.
    function getStakingPool(bytes32 poolId) external view returns (IStructs.Pool memory);

    /// @notice Get stats on a staking pool in this epoch.
    /// @param poolId Pool Id to query.
    /// @return PoolStats struct for pool id.
    function getStakingPoolStatsThisEpoch(bytes32 poolId) external view returns (IStructs.PoolStats memory);

    /// @notice Returns the total stake delegated to a specific staking pool, across all members.
    /// @param poolId Unique Id of pool.
    /// @return balance Total stake delegated to pool.
    function getTotalStakeDelegatedToPool(bytes32 poolId) external view returns (IStructs.StoredBalance memory balance);

    /// @notice An overridable way to access the deployed GRG contract.
    /// @dev Must be view to allow overrides to access state.
    /// @return The GRG contract instance.
    function getGrgContract() external view returns (RigoToken);

    /// @notice An overridable way to access the deployed grgVault.
    /// @dev Must be view to allow overrides to access state.
    /// @return The GRG vault contract.
    function getGrgVault() external view returns (GrgVault);

    /// @notice An overridable way to access the deployed rigoblock pool registry.
    /// @dev Must be view to allow overrides to access state.
    /// @return The pool registry contract.
    function getPoolRegistry() external view returns (PoolRegistry);
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "../immutable/MixinStorage.sol";
import "../immutable/MixinConstants.sol";
import "../interfaces/IStakingEvents.sol";
import "../interfaces/IStakingProxy.sol";
import "../interfaces/IStaking.sol";

abstract contract MixinParams is IStaking, IStakingEvents, MixinStorage, MixinConstants {
    /// @inheritdoc IStaking
    function setParams(
        uint256 _epochDurationInSeconds,
        uint32 _rewardDelegatedStakeWeight,
        uint256 _minimumPoolStake,
        uint32 _cobbDouglasAlphaNumerator,
        uint32 _cobbDouglasAlphaDenominator
    ) external override onlyAuthorized {
        _setParams(
            _epochDurationInSeconds,
            _rewardDelegatedStakeWeight,
            _minimumPoolStake,
            _cobbDouglasAlphaNumerator,
            _cobbDouglasAlphaDenominator
        );

        // Let the staking proxy enforce that these parameters are within
        // acceptable ranges.
        IStakingProxy(address(this)).assertValidStorageParams();
    }

    /// @inheritdoc IStaking
    function getParams()
        external
        view
        override
        returns (
            uint256 _epochDurationInSeconds,
            uint32 _rewardDelegatedStakeWeight,
            uint256 _minimumPoolStake,
            uint32 _cobbDouglasAlphaNumerator,
            uint32 _cobbDouglasAlphaDenominator
        )
    {
        _epochDurationInSeconds = epochDurationInSeconds;
        _rewardDelegatedStakeWeight = rewardDelegatedStakeWeight;
        _minimumPoolStake = minimumPoolStake;
        _cobbDouglasAlphaNumerator = cobbDouglasAlphaNumerator;
        _cobbDouglasAlphaDenominator = cobbDouglasAlphaDenominator;
    }

    /// @dev Initialize storage belonging to this mixin.
    function _initMixinParams() internal {
        // Ensure state is uninitialized.
        _assertParamsNotInitialized();

        // Set up defaults.
        uint256 _epochDurationInSeconds = 14 days;
        uint32 _rewardDelegatedStakeWeight = (90 * _PPM_DENOMINATOR) / 100;
        uint256 _minimumPoolStake = 100 * _MIN_TOKEN_VALUE;
        uint32 _cobbDouglasAlphaNumerator = 2;
        uint32 _cobbDouglasAlphaDenominator = 3;

        _setParams(
            _epochDurationInSeconds,
            _rewardDelegatedStakeWeight,
            _minimumPoolStake,
            _cobbDouglasAlphaNumerator,
            _cobbDouglasAlphaDenominator
        );
    }

    /// @dev Asserts that upgradable storage has not yet been initialized.
    function _assertParamsNotInitialized() internal view {
        if (
            epochDurationInSeconds != 0 &&
            rewardDelegatedStakeWeight != 0 &&
            minimumPoolStake != 0 &&
            cobbDouglasAlphaNumerator != 0 &&
            cobbDouglasAlphaDenominator != 0
        ) {
            revert("STAKING_PARAMS_ALREADY_INIZIALIZED_ERROR");
        }
    }

    /// @dev Set all configurable parameters at once.
    /// @param _epochDurationInSeconds Minimum seconds between epochs.
    /// @param _rewardDelegatedStakeWeight How much delegated stake is weighted vs operator stake, in ppm.
    /// @param _minimumPoolStake Minimum amount of stake required in a pool to collect rewards.
    /// @param _cobbDouglasAlphaNumerator Numerator for cobb douglas alpha factor.
    /// @param _cobbDouglasAlphaDenominator Denominator for cobb douglas alpha factor.
    function _setParams(
        uint256 _epochDurationInSeconds,
        uint32 _rewardDelegatedStakeWeight,
        uint256 _minimumPoolStake,
        uint32 _cobbDouglasAlphaNumerator,
        uint32 _cobbDouglasAlphaDenominator
    ) private {
        epochDurationInSeconds = _epochDurationInSeconds;
        rewardDelegatedStakeWeight = _rewardDelegatedStakeWeight;
        minimumPoolStake = _minimumPoolStake;
        cobbDouglasAlphaNumerator = _cobbDouglasAlphaNumerator;
        cobbDouglasAlphaDenominator = _cobbDouglasAlphaDenominator;

        emit ParamsSet(
            _epochDurationInSeconds,
            _rewardDelegatedStakeWeight,
            _minimumPoolStake,
            _cobbDouglasAlphaNumerator,
            _cobbDouglasAlphaDenominator
        );
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "../staking_pools/MixinStakingPool.sol";

abstract contract MixinStake is MixinStakingPool {
    /// @inheritdoc IStaking
    function stake(uint256 amount) external override {
        address staker = msg.sender;

        // deposit equivalent amount of GRG into vault
        getGrgVault().depositFrom(staker, amount);

        // mint stake
        _increaseCurrentAndNextBalance(_ownerStakeByStatus[uint8(IStructs.StakeStatus.UNDELEGATED)][staker], amount);

        // notify
        emit Stake(staker, amount);
    }

    /// @inheritdoc IStaking
    function unstake(uint256 amount) external override {
        address staker = msg.sender;

        IStructs.StoredBalance memory undelegatedBalance = _loadCurrentBalance(
            _ownerStakeByStatus[uint8(IStructs.StakeStatus.UNDELEGATED)][staker]
        );

        // stake must be undelegated in current and next epoch to be withdrawn
        uint256 currentWithdrawableStake = undelegatedBalance.currentEpochBalance < undelegatedBalance.nextEpochBalance
            ? undelegatedBalance.currentEpochBalance
            : undelegatedBalance.nextEpochBalance;

        require(amount <= currentWithdrawableStake, "MOVE_STAKE_AMOUNT_HIGHER_THAN_WITHDRAWABLE_ERROR");

        // burn undelegated stake
        _decreaseCurrentAndNextBalance(_ownerStakeByStatus[uint8(IStructs.StakeStatus.UNDELEGATED)][staker], amount);

        // withdraw equivalent amount of GRG from vault
        getGrgVault().withdrawFrom(staker, amount);

        // emit stake event
        emit Unstake(staker, amount);
    }

    /// @inheritdoc IStaking
    function moveStake(
        IStructs.StakeInfo calldata from,
        IStructs.StakeInfo calldata to,
        uint256 amount
    ) external override {
        address staker = msg.sender;

        // Sanity check: no-op if no stake is being moved.
        require(amount != 0, "MOVE_STAKE_AMOUNT_NULL_ERROR");

        // Sanity check: no-op if moving stake from undelegated to undelegated.
        if (from.status == IStructs.StakeStatus.UNDELEGATED && to.status == IStructs.StakeStatus.UNDELEGATED) {
            revert("MOVE_STAKE_UNDELEGATED_STATUS_UNCHANGED_ERROR");
        }

        // handle delegation
        if (from.status == IStructs.StakeStatus.DELEGATED) {
            _undelegateStake(from.poolId, staker, amount);
        }

        if (to.status == IStructs.StakeStatus.DELEGATED) {
            _delegateStake(to.poolId, staker, amount);
        }

        // execute move
        IStructs.StoredBalance storage fromPtr = _ownerStakeByStatus[uint8(from.status)][staker];
        IStructs.StoredBalance storage toPtr = _ownerStakeByStatus[uint8(to.status)][staker];
        _moveStake(fromPtr, toPtr, amount);

        // notify
        emit MoveStake(staker, amount, uint8(from.status), from.poolId, uint8(to.status), to.poolId);
    }

    /// @dev Delegates a owners stake to a staking pool.
    /// @param poolId Id of pool to delegate to.
    /// @param staker Owner who wants to delegate.
    /// @param amount Amount of stake to delegate.
    function _delegateStake(
        bytes32 poolId,
        address staker,
        uint256 amount
    ) private {
        // Sanity check the pool we're delegating to exists.
        _assertStakingPoolExists(poolId);

        _withdrawAndSyncDelegatorRewards(poolId, staker);

        // Increase how much stake the staker has delegated to the input pool.
        _increaseNextBalance(_delegatedStakeToPoolByOwner[staker][poolId], amount);

        // Increase how much stake has been delegated to pool.
        _increaseNextBalance(_delegatedStakeByPoolId[poolId], amount);

        // Increase next balance of global delegated stake.
        _increaseNextBalance(_globalStakeByStatus[uint8(IStructs.StakeStatus.DELEGATED)], amount);
    }

    /// @dev Un-Delegates a owners stake from a staking pool.
    /// @param poolId Id of pool to un-delegate from.
    /// @param staker Owner who wants to un-delegate.
    /// @param amount Amount of stake to un-delegate.
    function _undelegateStake(
        bytes32 poolId,
        address staker,
        uint256 amount
    ) private {
        // sanity check the pool we're undelegating from exists
        _assertStakingPoolExists(poolId);

        _withdrawAndSyncDelegatorRewards(poolId, staker);

        // Decrease how much stake the staker has delegated to the input pool.
        _decreaseNextBalance(_delegatedStakeToPoolByOwner[staker][poolId], amount);

        // Decrease how much stake has been delegated to pool.
        _decreaseNextBalance(_delegatedStakeByPoolId[poolId], amount);

        // Decrease next balance of global delegated stake (aggregated across all stakers).
        _decreaseNextBalance(_globalStakeByStatus[uint8(IStructs.StakeStatus.DELEGATED)], amount);
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "../../utils/0xUtils/LibMath.sol";
import "../interfaces/IStructs.sol";
import "../sys/MixinFinalizer.sol";
import "../staking_pools/MixinStakingPool.sol";
import "./MixinPopManager.sol";

abstract contract MixinPopRewards is MixinPopManager, MixinStakingPool, MixinFinalizer {
    /// @dev Asserts that the call is coming from a valid pop.
    modifier onlyPop() {
        require(validPops[msg.sender], "STAKING_ONLY_CALLABLE_BY_POP_ERROR");
        _;
    }

    /// @inheritdoc IStaking
    function creditPopReward(address poolAccount, uint256 popReward) external payable override onlyPop {
        // Get the pool id of the maker address.
        bytes32 poolId = poolIdByRbPoolAccount[poolAccount];

        // Only attribute the pop reward to a pool if the pool account is
        // registered to a pool.
        require(poolId != _NIL_POOL_ID, "STAKING_NULL_POOL_ID_ERROR");

        uint256 poolStake = getTotalStakeDelegatedToPool(poolId).currentEpochBalance;
        // Ignore pools with dust stake.
        require(poolStake >= minimumPoolStake, "STAKING_STAKE_BELOW_MINIMUM_ERROR");

        // Look up the pool stats and aggregated stats for this epoch.
        uint256 currentEpoch_ = currentEpoch;
        IStructs.PoolStats storage poolStatsPtr = poolStatsByEpoch[poolId][currentEpoch_];
        IStructs.AggregatedStats storage aggregatedStatsPtr = aggregatedStatsByEpoch[currentEpoch_];

        // Perform some initialization if this is the pool's first protocol fee in this epoch.
        uint256 feesCollectedByPool = poolStatsPtr.feesCollected;
        if (feesCollectedByPool == 0) {
            // Compute member and total weighted stake.
            (uint256 membersStakeInPool, uint256 weightedStakeInPool) = _computeMembersAndWeightedStake(
                poolId,
                poolStake
            );
            poolStatsPtr.membersStake = membersStakeInPool;
            poolStatsPtr.weightedStake = weightedStakeInPool;

            // Increase the total weighted stake.
            aggregatedStatsPtr.totalWeightedStake += weightedStakeInPool;

            // Increase the number of pools to finalize.
            aggregatedStatsPtr.numPoolsToFinalize += 1;

            // Emit an event so keepers know what pools earned rewards this epoch.
            emit StakingPoolEarnedRewardsInEpoch(currentEpoch_, poolId);
        }

        if (popReward > feesCollectedByPool) {
            // Credit the fees to the pool.
            poolStatsPtr.feesCollected = popReward;

            // Increase the total fees collected this epoch.
            aggregatedStatsPtr.totalFeesCollected += popReward - feesCollectedByPool;
        }
    }

    /// @inheritdoc IStaking
    function getStakingPoolStatsThisEpoch(bytes32 poolId) external view override returns (IStructs.PoolStats memory) {
        return poolStatsByEpoch[poolId][currentEpoch];
    }

    /// @dev Computes the members and weighted stake for a pool at the current
    ///      epoch.
    /// @param poolId ID of the pool.
    /// @param totalStake Total (unweighted) stake in the pool.
    /// @return membersStake Non-operator stake in the pool.
    /// @return weightedStake Weighted stake of the pool.
    function _computeMembersAndWeightedStake(bytes32 poolId, uint256 totalStake)
        private
        view
        returns (uint256 membersStake, uint256 weightedStake)
    {
        uint256 operatorStake = getStakeDelegatedToPoolByOwner(_poolById[poolId].operator, poolId).currentEpochBalance;

        membersStake = totalStake - operatorStake;
        weightedStake =
            operatorStake +
            LibMath.getPartialAmountFloor(rewardDelegatedStakeWeight, _PPM_DENOMINATOR, membersStake);
        return (membersStake, weightedStake);
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

 Copyright 2017-2022 RigoBlock, Rigo Investment Sagl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity >=0.7.0 <0.9.0;

/// @title Pool Registry Interface - Allows external interaction with pool registry.
/// @author Gabriele Rigo - <[email protected]>
// solhint-disable-next-line
interface IPoolRegistry {
    /// @notice Mapping of pool meta by pool key.
    /// @param meta Mapping of bytes32 key to bytes32 meta.
    struct PoolMeta {
        mapping(bytes32 => bytes32) meta;
    }

    /// @notice Emitted when Rigoblock Dao updates authority address.
    /// @param authority Address of the new authority contract.
    event AuthorityChanged(address indexed authority);

    /// @notice Emitted when pool owner updates meta data for its pool.
    /// @param pool Address of the pool.
    /// @param key Bytes32 key for indexing.
    /// @param value Bytes32 of the value associated with the key.
    event MetaChanged(address indexed pool, bytes32 indexed key, bytes32 value);

    /// @notice Emitted when a new pool is registered in registry.
    /// @param group Address of the pool factory.
    /// @param pool Address of the registered pool.
    /// @param name String name of the pool.
    /// @param symbol String name of the pool.
    /// @param id Bytes32 id of the pool.
    event Registered(
        address indexed group,
        address pool,
        bytes32 indexed name, // client can prune sybil pools
        bytes32 indexed symbol,
        bytes32 id
    );

    /// @notice Emitted when rigoblock Dao address is updated.
    /// @param rigoblockDao New Dao address.
    event RigoblockDaoChanged(address indexed rigoblockDao);

    /// @notice Returns the address of the Rigoblock authority contract.
    /// @return Address of the authority contract.
    function authority() external view returns (address);

    /// @notice Returns the address of the Rigoblock Dao.
    /// @return Address of the Rigoblock Dao.
    function rigoblockDao() external view returns (address);

    /// @notice Allows a factory which is an authority to register a pool.
    /// @param pool Address of the pool.
    /// @param name String name of the pool (31 characters/bytes or less).
    /// @param symbol String symbol of the pool (3 to 5 characters/bytes).
    /// @param poolId Bytes32 of the pool id.
    function register(
        address pool,
        string calldata name,
        string calldata symbol,
        bytes32 poolId
    ) external;

    /// @notice Allows Rigoblock governance to update authority.
    /// @param authority Address of the authority contract.
    function setAuthority(address authority) external;

    /// @notice Allows pool owner to set metadata for a pool.
    /// @param pool Address of the pool.
    /// @param key Bytes32 of the key.
    /// @param value Bytes32 of the value.
    function setMeta(
        address pool,
        bytes32 key,
        bytes32 value
    ) external;

    /// @notice Allows Rigoblock Dao to update its address.
    /// @dev Creates internal record.
    /// @param newRigoblockDao Address of the Rigoblock Dao.
    function setRigoblockDao(address newRigoblockDao) external;

    /// @notice Returns metadata for a given pool.
    /// @param pool Address of the pool.
    /// @param key Bytes32 key.
    /// @return poolMeta Meta by key.
    function getMeta(address pool, bytes32 key) external view returns (bytes32 poolMeta);

    /// @notice Returns the id of a pool from its address.
    /// @param pool Address of the pool.
    /// @return poolId bytes32 id of the pool.
    function getPoolIdFromAddress(address pool) external view returns (bytes32 poolId);
}

// SPDX-License-Identifier: Apache 2.0
/*

 Copyright 2017-2018 RigoBlock, Rigo Investment Sagl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "../../tokens/ERC20/IERC20.sol";

/// @title Rigo Token Interface - Allows interaction with the Rigo token.
/// @author Gabriele Rigo - <[email protected]>
// solhint-disable-next-line
interface IRigoToken is IERC20 {
    /// @notice Emitted when new tokens have been minted.
    /// @param recipient Address receiving the new tokens.
    /// @param amount Number of minted units.
    event TokenMinted(address indexed recipient, uint256 amount);

    /// @notice Returns the address of the minter.
    /// @return Address of the minter.
    function minter() external view returns (address);

    /// @notice Returns the address of the Rigoblock Dao.
    /// @return Address of the Dao.
    function rigoblock() external view returns (address);

    /// @notice Allows minter to create new tokens.
    /// @dev Mint method is reserved for minter module.
    /// @param recipient Address receiving the new tokens.
    /// @param amount Number of minted tokens.
    function mintToken(address recipient, uint256 amount) external;

    /// @notice Allows Rigoblock Dao to update minter.
    /// @param newAddress Address of the new minter.
    function changeMintingAddress(address newAddress) external;

    /// @notice Allows Rigoblock Dao to update its address.
    /// @param newAddress Address of the new Dao.
    function changeRigoblockAddress(address newAddress) external;
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

interface IStructs {
    /// @notice Stats for a pool that earned rewards.
    /// @param feesCollected Fees collected in ETH by this pool.
    /// @param weightedStake Amount of weighted stake in the pool.
    /// @param membersStake Amount of non-operator stake in the pool.
    struct PoolStats {
        uint256 feesCollected;
        uint256 weightedStake;
        uint256 membersStake;
    }

    /// @notice Holds stats aggregated across a set of pools.
    /// @dev rewardsAvailable is simply the balanc of the contract at the end of the epoch.
    /// @param rewardsAvailable Rewards (GRG) available to the epoch being finalized (the previous epoch).
    /// @param numPoolsToFinalize The number of pools that have yet to be finalized through `finalizePools()`.
    /// @param totalFeesCollected The total fees collected for the epoch being finalized.
    /// @param totalWeightedStake The total fees collected for the epoch being finalized.
    /// @param totalRewardsFinalized Amount of rewards that have been paid during finalization.
    struct AggregatedStats {
        uint256 rewardsAvailable;
        uint256 numPoolsToFinalize;
        uint256 totalFeesCollected;
        uint256 totalWeightedStake;
        uint256 totalRewardsFinalized;
    }

    /// @notice Encapsulates a balance for the current and next epochs.
    /// @dev Note that these balances may be stale if the current epoch is greater than `currentEpoch`.
    /// @param currentEpoch The current epoch
    /// @param currentEpochBalance Balance in the current epoch.
    /// @param nextEpochBalance Balance in `currentEpoch+1`.
    struct StoredBalance {
        uint64 currentEpoch;
        uint96 currentEpochBalance;
        uint96 nextEpochBalance;
    }

    /// @notice Statuses that stake can exist in.
    /// @dev Any stake can be (re)delegated effective at the next epoch.
    /// @dev Undelegated stake can be withdrawn if it is available in both the current and next epoch.
    enum StakeStatus {
        UNDELEGATED,
        DELEGATED
    }

    /// @notice Info used to describe a status.
    /// @param status Status of the stake.
    /// @param poolId Unique Id of pool. This is set when status=DELEGATED.
    struct StakeInfo {
        StakeStatus status;
        bytes32 poolId;
    }

    /// @notice Struct to represent a fraction.
    /// @param numerator Numerator of fraction.
    /// @param denominator Denominator of fraction.
    struct Fraction {
        uint256 numerator;
        uint256 denominator;
    }

    /// @notice Holds the metadata for a staking pool.
    /// @param operator Operator of the pool.
    /// @param stakingPal Staking pal of the pool.
    /// @param operatorShare Fraction of the total balance owned by the operator, in ppm.
    /// @param stakingPalShare Fraction of the operator reward owned by the staking pal, in ppm.
    struct Pool {
        address operator;
        address stakingPal;
        uint32 operatorShare;
        uint32 stakingPalShare;
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

interface IGrgVault {
    /// @notice Emmitted whenever a StakingProxy is set in a vault.
    /// @param stakingProxyAddress Address of the staking proxy contract.
    event StakingProxySet(address stakingProxyAddress);

    /// @notice Emitted when the Staking contract is put into Catastrophic Failure Mode
    /// @param sender Address of sender (`msg.sender`)
    event InCatastrophicFailureMode(address sender);

    /// @notice Emitted when Grg Tokens are deposited into the vault.
    /// @param staker Address of the Grg staker.
    /// @param amount of Grg Tokens deposited.
    event Deposit(address indexed staker, uint256 amount);

    /// @notice Emitted when Grg Tokens are withdrawn from the vault.
    /// @param staker Address of the Grg staker.
    /// @param amount of Grg Tokens withdrawn.
    event Withdraw(address indexed staker, uint256 amount);

    /// @notice Emitted whenever the Grg AssetProxy is set.
    /// @param grgProxyAddress Address of the Grg transfer proxy.
    event GrgProxySet(address grgProxyAddress);

    /// @notice Sets the address of the StakingProxy contract.
    /// @dev Note that only the contract staker can call this function.
    /// @param stakingProxyAddress Address of Staking proxy contract.
    function setStakingProxy(address stakingProxyAddress) external;

    /// @notice Vault enters into Catastrophic Failure Mode.
    /// @dev *** WARNING - ONCE IN CATOSTROPHIC FAILURE MODE, YOU CAN NEVER GO BACK! ***
    /// @dev Note that only the contract staker can call this function.
    function enterCatastrophicFailure() external;

    /// @notice Sets the Grg proxy.
    /// @dev Note that only the contract staker can call this.
    /// @dev Note that this can only be called when *not* in Catastrophic Failure mode.
    /// @param grgProxyAddress Address of the RigoBlock Grg Proxy.
    function setGrgProxy(address grgProxyAddress) external;

    /// @notice Deposit an `amount` of Grg Tokens from `staker` into the vault.
    /// @dev Note that only the Staking contract can call this.
    /// @dev Note that this can only be called when *not* in Catastrophic Failure mode.
    /// @param staker Address of the Grg staker.
    /// @param amount of Grg Tokens to deposit.
    function depositFrom(address staker, uint256 amount) external;

    /// @notice Withdraw an `amount` of Grg Tokens to `staker` from the vault.
    /// @dev Note that only the Staking contract can call this.
    /// @dev Note that this can only be called when *not* in Catastrophic Failure mode.
    /// @param staker Address of the Grg staker.
    /// @param amount of Grg Tokens to withdraw.
    function withdrawFrom(address staker, uint256 amount) external;

    /// @notice Withdraw ALL Grg Tokens to `staker` from the vault.
    /// @dev Note that this can only be called when *in* Catastrophic Failure mode.
    /// @param staker Address of the Grg staker.
    function withdrawAllFrom(address staker) external returns (uint256);

    /// @notice Returns the balance in Grg Tokens of the `staker`
    /// @param staker Address of the Grg staker.
    /// @return Balance in Grg.
    function balanceOf(address staker) external view returns (uint256);

    /// @notice Returns the entire balance of Grg tokens in the vault.
    /// @return Balance in Grg.
    function balanceOfGrgVault() external view returns (uint256);
}

// SPDX-License-Identifier: Apache 2.0
pragma solidity >=0.5.0;

interface IERC20 {
    /// @notice Emitted when a token is transferred.
    /// @param from Address transferring the tokens.
    /// @param to Address receiving the tokens.
    /// @param value Number of token units.
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @notice Emitted when a token holder sets and approval.
    /// @param owner Address of the account setting the approval.
    /// @param spender Address of the allowed account.
    /// @param value Number of approved units.
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice Transfers token from holder to another address.
    /// @param to Address to send tokens to.
    /// @param value Number of token units to send.
    /// @return success Bool the transaction was successful.
    function transfer(address to, uint256 value) external returns (bool success);

    /// @notice Allows spender to transfer tokens from the holder.
    /// @param from Address of the token holder.
    /// @param to Address to send tokens to.
    /// @param value Number of units to transfer.
    /// @return success Bool the transaction was successful.
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool success);

    /// @notice Allows a holder to approve a spender.
    /// @param spender Address of the token spender.
    /// @param value Number of units to be approved.
    /// @return success Bool the transaction was successful.
    function approve(address spender, uint256 value) external returns (bool success);

    /// @notice Returns token balance for an address.
    /// @param who Address to query balance for.
    /// @return Number of units held.
    function balanceOf(address who) external view returns (uint256);

    /// @notice Returns token allowance of an address to another address.
    /// @param owner Address of token hodler.
    /// @param spender Address of the token spender.
    /// @return Number of allowed units.
    function allowance(address owner, address spender) external view returns (uint256);

    /// @notice Returns the total supply of the token.
    /// @return Number of issued units.
    function totalSupply() external view returns (uint256);
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "../../utils/0xUtils/Authorizable.sol";
import "../interfaces/IGrgVault.sol";
import "../interfaces/IStorage.sol";
import "../interfaces/IStructs.sol";

// solhint-disable max-states-count, no-empty-blocks
abstract contract MixinStorage is IStorage, Authorizable {
    /// @inheritdoc IStorage
    address public override stakingContract;

    // mapping from StakeStatus to global stored balance
    // NOTE: only Status.DELEGATED is used to access this mapping, but this format
    // is used for extensibility
    mapping(uint8 => IStructs.StoredBalance) internal _globalStakeByStatus;

    // mapping from StakeStatus to address of staker to stored balance
    mapping(uint8 => mapping(address => IStructs.StoredBalance)) internal _ownerStakeByStatus;

    // Mapping from Owner to Pool Id to Amount Delegated
    mapping(address => mapping(bytes32 => IStructs.StoredBalance)) internal _delegatedStakeToPoolByOwner;

    // Mapping from Pool Id to Amount Delegated
    mapping(bytes32 => IStructs.StoredBalance) internal _delegatedStakeByPoolId;

    /// @inheritdoc IStorage
    mapping(address => bytes32) public override poolIdByRbPoolAccount;

    // mapping from Pool Id to Pool
    mapping(bytes32 => IStructs.Pool) internal _poolById;

    /// @inheritdoc IStorage
    mapping(bytes32 => uint256) public override rewardsByPoolId;

    /// @inheritdoc IStorage
    uint256 public override currentEpoch;

    /// @inheritdoc IStorage
    uint256 public override currentEpochStartTimeInSeconds;

    // mapping from Pool Id to Epoch to Reward Ratio
    mapping(bytes32 => mapping(uint256 => IStructs.Fraction)) internal _cumulativeRewardsByPool;

    // mapping from Pool Id to Epoch
    mapping(bytes32 => uint256) internal _cumulativeRewardsByPoolLastStored;

    /// @inheritdoc IStorage
    mapping(address => bool) public override validPops;

    /* Tweakable parameters */

    /// @inheritdoc IStorage
    uint256 public override epochDurationInSeconds;

    /// @inheritdoc IStorage
    uint32 public override rewardDelegatedStakeWeight;

    /// @inheritdoc IStorage
    uint256 public override minimumPoolStake;

    /// @inheritdoc IStorage
    uint32 public override cobbDouglasAlphaNumerator;

    /// @inheritdoc IStorage
    uint32 public override cobbDouglasAlphaDenominator;

    /* State for finalization */

    /// @inheritdoc IStorage
    mapping(bytes32 => mapping(uint256 => IStructs.PoolStats)) public override poolStatsByEpoch;

    /// @inheritdoc IStorage
    mapping(uint256 => IStructs.AggregatedStats) public aggregatedStatsByEpoch;

    /// @inheritdoc IStorage
    uint256 public grgReservedForPoolRewards;
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

abstract contract MixinConstants {
    // 100% in parts-per-million.
    uint32 internal constant _PPM_DENOMINATOR = 10**6;

    bytes32 internal constant _NIL_POOL_ID = 0x0000000000000000000000000000000000000000000000000000000000000000;

    address internal constant _NIL_ADDRESS = 0x0000000000000000000000000000000000000000;

    uint256 internal constant _MIN_TOKEN_VALUE = 10**18;
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

interface IStakingEvents {
    /// @notice Emitted by MixinStake when GRG is staked.
    /// @param staker of GRG.
    /// @param amount of GRG staked.
    event Stake(address indexed staker, uint256 amount);

    /// @notice Emitted by MixinStake when GRG is unstaked.
    /// @param staker of GRG.
    /// @param amount of GRG unstaked.
    event Unstake(address indexed staker, uint256 amount);

    /// @notice Emitted by MixinStake when GRG is unstaked.
    /// @param staker of GRG.
    /// @param amount of GRG unstaked.
    event MoveStake(
        address indexed staker,
        uint256 amount,
        uint8 fromStatus,
        bytes32 indexed fromPool,
        uint8 toStatus,
        bytes32 indexed toPool
    );

    /// @notice Emitted by MixinExchangeManager when an exchange is added.
    /// @param exchangeAddress Address of new exchange.
    event PopAdded(address exchangeAddress);

    /// @notice Emitted by MixinExchangeManager when an exchange is removed.
    /// @param exchangeAddress Address of removed exchange.
    event PopRemoved(address exchangeAddress);

    /// @notice Emitted by MixinExchangeFees when a pool starts earning rewards in an epoch.
    /// @param epoch The epoch in which the pool earned rewards.
    /// @param poolId The ID of the pool.
    event StakingPoolEarnedRewardsInEpoch(uint256 indexed epoch, bytes32 indexed poolId);

    /// @notice Emitted by MixinFinalizer when an epoch has ended.
    /// @param epoch The epoch that ended.
    /// @param numPoolsToFinalize Number of pools that earned rewards during `epoch` and must be finalized.
    /// @param rewardsAvailable Rewards available to all pools that earned rewards during `epoch`.
    /// @param totalWeightedStake Total weighted stake across all pools that earned rewards during `epoch`.
    /// @param totalFeesCollected Total fees collected across all pools that earned rewards during `epoch`.
    event EpochEnded(
        uint256 indexed epoch,
        uint256 numPoolsToFinalize,
        uint256 rewardsAvailable,
        uint256 totalFeesCollected,
        uint256 totalWeightedStake
    );

    /// @notice Emitted by MixinFinalizer when an epoch is fully finalized.
    /// @param epoch The epoch being finalized.
    /// @param rewardsPaid Total amount of rewards paid out.
    /// @param rewardsRemaining Rewards left over.
    event EpochFinalized(uint256 indexed epoch, uint256 rewardsPaid, uint256 rewardsRemaining);

    /// @notice Emitted by MixinFinalizer when rewards are paid out to a pool.
    /// @param epoch The epoch when the rewards were paid out.
    /// @param poolId The pool's ID.
    /// @param operatorReward Amount of reward paid to pool operator.
    /// @param membersReward Amount of reward paid to pool members.
    event RewardsPaid(uint256 indexed epoch, bytes32 indexed poolId, uint256 operatorReward, uint256 membersReward);

    /// @notice Emitted whenever staking parameters are changed via the `setParams()` function.
    /// @param epochDurationInSeconds Minimum seconds between epochs.
    /// @param rewardDelegatedStakeWeight How much delegated stake is weighted vs operator stake, in ppm.
    /// @param minimumPoolStake Minimum amount of stake required in a pool to collect rewards.
    /// @param cobbDouglasAlphaNumerator Numerator for cobb douglas alpha factor.
    /// @param cobbDouglasAlphaDenominator Denominator for cobb douglas alpha factor.
    event ParamsSet(
        uint256 epochDurationInSeconds,
        uint32 rewardDelegatedStakeWeight,
        uint256 minimumPoolStake,
        uint256 cobbDouglasAlphaNumerator,
        uint256 cobbDouglasAlphaDenominator
    );

    /// @notice Emitted by MixinStakingPool when a new pool is created.
    /// @param poolId Unique id generated for pool.
    /// @param operator The operator (creator) of pool.
    /// @param operatorShare The share of rewards given to the operator, in ppm.
    event StakingPoolCreated(bytes32 poolId, address operator, uint32 operatorShare);

    /// @notice Emitted by MixinStakingPool when a rigoblock pool is added to its staking pool.
    /// @param rbPoolAddress Adress of maker added to pool.
    /// @param poolId Unique id of pool.
    event RbPoolStakingPoolSet(address indexed rbPoolAddress, bytes32 indexed poolId);

    /// @notice Emitted when a staking pool's operator share is decreased.
    /// @param poolId Unique Id of pool.
    /// @param oldOperatorShare Previous share of rewards owned by operator.
    /// @param newOperatorShare Newly decreased share of rewards owned by operator.
    event OperatorShareDecreased(bytes32 indexed poolId, uint32 oldOperatorShare, uint32 newOperatorShare);

    /// @notice Emitted when an inflation mint call is executed successfully.
    /// @param grgAmount Amount of GRG tokens minted to the staking proxy.
    event GrgMintEvent(uint256 grgAmount);

    /// @notice Emitted whenever an inflation mint call is reverted.
    /// @param reason String of the revert message.
    event CatchStringEvent(string reason);

    /// @notice Emitted to catch any other inflation mint call fail.
    /// @param reason Bytes output of the reverted transaction.
    event ReturnDataEvent(bytes reason);
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "./IStructs.sol";

interface IStakingProxy {
    /// @notice Emitted by StakingProxy when a staking contract is attached.
    /// @param newStakingContractAddress Address of newly attached staking contract.
    event StakingContractAttachedToProxy(address newStakingContractAddress);

    /// @notice Emitted by StakingProxy when a staking contract is detached.
    event StakingContractDetachedFromProxy();

    /// @notice Attach a staking contract; future calls will be delegated to the staking contract.
    /// @dev Note that this is callable only by an authorized address.
    /// @param stakingImplementation Address of staking contract.
    function attachStakingContract(address stakingImplementation) external;

    /// @notice Detach the current staking contract.
    /// @dev Note that this is callable only by an authorized address.
    function detachStakingContract() external;

    /// @notice Batch executes a series of calls to the staking contract.
    /// @param data An array of data that encodes a sequence of functions to call in the staking contracts.
    function batchExecute(bytes[] calldata data) external returns (bytes[] memory batchReturnData);

    /// @notice Asserts initialziation parameters are correct.
    /// @dev Asserts that an epoch is between 5 and 30 days long.
    /// @dev Asserts that 0 < cobb douglas alpha value <= 1.
    /// @dev Asserts that a stake weight is <= 100%.
    /// @dev Asserts that pools allow >= 1 maker.
    /// @dev Asserts that all addresses are initialized.
    function assertValidStorageParams() external view;
}

// SPDX-License-Identifier: Apache 2.0
/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.9.0;

import "./interfaces/IAuthorizable.sol";
import "./Ownable.sol";

// solhint-disable no-empty-blocks
// TODO: check if should use OwnedUninitialized and remove duplicate contract
abstract contract Authorizable is Ownable, IAuthorizable {
    /// @dev Only authorized addresses can invoke functions with this modifier.
    modifier onlyAuthorized() {
        _assertSenderIsAuthorized();
        _;
    }

    /// @dev Whether an address is authorized to call privileged functions.
    /// @dev 0 Address to query.
    /// @return 0 Whether the address is authorized.
    mapping(address => bool) public authorized;
    /// @dev Whether an adderss is authorized to call privileged functions.
    /// @dev 0 Index of authorized address.
    /// @return 0 Authorized address.
    address[] public authorities;

    /// @dev Initializes the `owner` address.
    constructor(address newOwner) Ownable(newOwner) {}

    /// @dev Authorizes an address.
    /// @param target Address to authorize.
    function addAuthorizedAddress(address target) external override onlyOwner {
        _addAuthorizedAddress(target);
    }

    /// @dev Removes authorizion of an address.
    /// @param target Address to remove authorization from.
    function removeAuthorizedAddress(address target) external override onlyOwner {
        require(authorized[target], "TARGET_NOT_AUTHORIZED");
        for (uint256 i = 0; i < authorities.length; i++) {
            if (authorities[i] == target) {
                _removeAuthorizedAddressAtIndex(target, i);
                break;
            }
        }
    }

    /// @dev Removes authorizion of an address.
    /// @param target Address to remove authorization from.
    /// @param index Index of target in authorities array.
    function removeAuthorizedAddressAtIndex(address target, uint256 index) external override onlyOwner {
        _removeAuthorizedAddressAtIndex(target, index);
    }

    /// @dev Gets all authorized addresses.
    /// @return Array of authorized addresses.
    function getAuthorizedAddresses() external view override returns (address[] memory) {
        return authorities;
    }

    /// @dev Reverts if msg.sender is not authorized.
    function _assertSenderIsAuthorized() internal view {
        require(authorized[msg.sender], "AUTHORIZABLE_SENDER_NOT_AUTHORIZED_ERROR");
    }

    /// @dev Authorizes an address.
    /// @param target Address to authorize.
    function _addAuthorizedAddress(address target) internal {
        // Ensure that the target is not the zero address.
        require(target != address(0), "AUTHORIZABLE_NULL_ADDRESS_ERROR");

        // Ensure that the target is not already authorized.
        require(!authorized[target], "AUTHORIZABLE_ALREADY_AUTHORIZED_ERROR");

        authorized[target] = true;
        authorities.push(target);
        emit AuthorizedAddressAdded(target, msg.sender);
    }

    /// @dev Removes authorization of an address.
    /// @param target Address to remove authorization from.
    /// @param index Index of target in authorities array.
    function _removeAuthorizedAddressAtIndex(address target, uint256 index) internal {
        require(authorized[target], "AUTHORIZABLE_ADDRESS_NOT_AUTHORIZED_ERROR");
        require(index < authorities.length, "AUTHORIZABLE_INDEX_OUT_OF_BOUNDS_ERROR");
        require(authorities[index] == target, "AUTHORIZABLE_ADDRESS_MISMATCH_ERROR");

        delete authorized[target];
        authorities[index] = authorities[authorities.length - 1];
        authorities.pop();
        emit AuthorizedAddressRemoved(target, msg.sender);
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

interface IStorage {
    /// @notice Address of staking contract.
    /// @return stakingContract Address of the staking contract.
    function stakingContract() external view returns (address);

    /// @notice Mapping from RigoBlock pool subaccount to pool Id of rigoblock pool
    /// @dev 0 RigoBlock pool subaccount address.
    /// @return 0 The pool ID.
    function poolIdByRbPoolAccount(address) external view returns (bytes32);

    /// @notice mapping from pool ID to reward balance of members
    /// @dev 0 Pool ID.
    /// @return 0 The total reward balance of members in this pool.
    function rewardsByPoolId(bytes32) external view returns (uint256);

    /// @notice The current epoch.
    /// @return currentEpoch The number of the current epoch.
    function currentEpoch() external view returns (uint256);

    /// @notice The current epoch start time.
    /// @return currentEpochStartTimeInSeconds Timestamp of start time.
    function currentEpochStartTimeInSeconds() external view returns (uint256);

    /// @notice Registered RigoBlock Proof_of_Performance contracts, capable of paying protocol fees.
    /// @dev 0 The address to check.
    /// @return 0 Whether the address is a registered proof_of_performance.
    function validPops(address popAddress) external view returns (bool);

    /// @notice Minimum seconds between epochs.
    /// @return epochDurationInSeconds Number of seconds.
    function epochDurationInSeconds() external view returns (uint256);

    // @notice How much delegated stake is weighted vs operator stake, in ppm.
    /// @return rewardDelegatedStakeWeight Number in units of a million.
    function rewardDelegatedStakeWeight() external view returns (uint32);

    /// @notice Minimum amount of stake required in a pool to collect rewards.
    /// @return minimumPoolStake Minimum amount required.
    function minimumPoolStake() external view returns (uint256);

    /// @notice Numerator for cobb douglas alpha factor.
    /// @return cobbDouglasAlphaNumerator Number of the numerator.
    function cobbDouglasAlphaNumerator() external view returns (uint32);

    /// @notice Denominator for cobb douglas alpha factor.
    /// @return cobbDouglasAlphaDenominator Number of the denominator.
    function cobbDouglasAlphaDenominator() external view returns (uint32);

    /// @notice Stats for each pool that generated fees with sufficient stake to earn rewards.
    /// @dev See `_minimumPoolStake` in `MixinParams`.
    /// @param key Pool ID.
    /// @param epoch Epoch number.
    /// @return feesCollected Amount of fees collected in epoch.
    /// @return weightedStake Weighted stake per million.
    /// @return membersStake Members stake per million.
    function poolStatsByEpoch(bytes32 key, uint256 epoch)
        external
        view
        returns (
            uint256 feesCollected,
            uint256 weightedStake,
            uint256 membersStake
        );

    /// @notice Aggregated stats across all pools that generated fees with sufficient stake to earn rewards.
    /// @dev See `_minimumPoolStake` in MixinParams.
    /// @param epoch Epoch number.
    /// @return rewardsAvailable Rewards (GRG) available to the epoch being finalized (the previous epoch).
    /// @return numPoolsToFinalize The number of pools that have yet to be finalized through `finalizePools()`.
    /// @return totalFeesCollected The total fees collected for the epoch being finalized.
    /// @return totalWeightedStake The total fees collected for the epoch being finalized.
    /// @return totalRewardsFinalized Amount of rewards that have been paid during finalization.
    function aggregatedStatsByEpoch(uint256 epoch)
        external
        view
        returns (
            uint256 rewardsAvailable,
            uint256 numPoolsToFinalize,
            uint256 totalFeesCollected,
            uint256 totalWeightedStake,
            uint256 totalRewardsFinalized
        );

    /// @notice The GRG balance of this contract that is reserved for pool reward payouts.
    /// @return grgReservedForPoolRewards Number of tokens reserved for rewards.
    function grgReservedForPoolRewards() external view returns (uint256);
}

// SPDX-License-Identifier: Apache 2.0
/*
  Copyright 2019 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity >=0.5.9 <0.9.0;

abstract contract IAuthorizable {
    /// @dev Emitted when a new address is authorized.
    /// @param target Address of the authorized address.
    /// @param caller Address of the address that authorized the target.
    event AuthorizedAddressAdded(address indexed target, address indexed caller);

    /// @dev Emitted when a currently authorized address is unauthorized.
    /// @param target Address of the authorized address.
    /// @param caller Address of the address that authorized the target.
    event AuthorizedAddressRemoved(address indexed target, address indexed caller);

    /// @dev Authorizes an address.
    /// @param target Address to authorize.
    function addAuthorizedAddress(address target) external virtual;

    /// @dev Removes authorizion of an address.
    /// @param target Address to remove authorization from.
    function removeAuthorizedAddress(address target) external virtual;

    /// @dev Removes authorizion of an address.
    /// @param target Address to remove authorization from.
    /// @param index Index of target in authorities array.
    function removeAuthorizedAddressAtIndex(address target, uint256 index) external virtual;

    /// @dev Gets all authorized addresses.
    /// @return Array of authorized addresses.
    function getAuthorizedAddresses() external view virtual returns (address[] memory);
}

// SPDX-License-Identifier: Apache 2.0
/*
  Copyright 2019 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity >=0.5.9 <0.9.0;

import "./interfaces/IOwnable.sol";

abstract contract Ownable is IOwnable {
    /// @dev The owner of this contract.
    /// @return 0 The owner address.
    address public owner;

    constructor(address newOwner) {
        owner = newOwner;
    }

    modifier onlyOwner() {
        _assertSenderIsOwner();
        _;
    }

    /// @dev Change the owner of this contract.
    /// @param newOwner New owner address.
    function transferOwnership(address newOwner) public override onlyOwner {
        require(newOwner != address(0), "INPUT_ADDRESS_NULL_ERROR");
        owner = newOwner;
        emit OwnershipTransferred(msg.sender, newOwner);
    }

    function _assertSenderIsOwner() internal view {
        require(msg.sender == owner, "CALLER_NOT_OWNER_ERROR");
    }
}

// SPDX-License-Identifier: Apache 2.0
/*
  Copyright 2019 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity >=0.5.9 <0.9.0;

abstract contract IOwnable {
    /// @dev Emitted by Ownable when ownership is transferred.
    /// @param previousOwner The previous owner of the contract.
    /// @param newOwner The new owner of the contract.
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @dev Transfers ownership of the contract to a new address.
    /// @param newOwner The address that will become the owner.
    function transferOwnership(address newOwner) public virtual;
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "../../protocol/IRigoblockV3Pool.sol";
import "../interfaces/IStructs.sol";
import "./MixinStakingPoolRewards.sol";

abstract contract MixinStakingPool is MixinStakingPoolRewards {
    using LibSafeDowncast for uint256;

    /// @dev Asserts that the sender is the operator of the input pool.
    /// @param poolId Pool sender must be operator of.
    modifier onlyStakingPoolOperator(bytes32 poolId) {
        _assertSenderIsPoolOperator(poolId);
        _;
    }

    modifier onlyDelegateCall() {
        _assertDelegateCall();
        _;
    }

    /// @inheritdoc IStaking
    function createStakingPool(address rigoblockPoolAddress)
        external
        override
        onlyDelegateCall
        returns (bytes32 poolId)
    {
        bytes32 rbPoolId = getPoolRegistry().getPoolIdFromAddress(rigoblockPoolAddress);
        require(rbPoolId != bytes32(0), "NON_REGISTERED_RB_POOL_ERROR");
        // note that an operator must be payable
        address operator = IRigoblockV3Pool(payable(rigoblockPoolAddress)).owner();

        // add stakingPal, which receives part of operator reward
        address stakingPal = msg.sender != operator ? msg.sender : address(0);

        // operator initially shares 30% with stakers
        uint32 operatorShare = uint32(700000);

        // staking pal received 10% of operator rewards
        uint32 stakingPalShare = uint32(100000);

        // check that staking pool does not exist and add unique id for this pool
        _assertStakingPoolDoesNotExist(bytes32(rbPoolId));
        poolId = bytes32(rbPoolId);

        // @notice _assertNewOperatorShare if operatorShare, stakingPalShare are inputs after an upgrade

        // create and store pool
        IStructs.Pool memory pool = IStructs.Pool({
            operator: operator,
            stakingPal: stakingPal,
            operatorShare: operatorShare,
            stakingPalShare: stakingPalShare
        });
        _poolById[poolId] = pool;

        // Staking pool has been created
        emit StakingPoolCreated(poolId, operator, operatorShare);

        _joinStakingPoolAsRbPoolAccount(poolId, rigoblockPoolAddress);

        return poolId;
    }

    /// @inheritdoc IStaking
    function setStakingPalAddress(bytes32 poolId, address newStakingPalAddress)
        external
        override
        onlyStakingPoolOperator(poolId)
    {
        IStructs.Pool storage pool = _poolById[poolId];
        require(
            newStakingPalAddress != address(0) && pool.stakingPal != newStakingPalAddress,
            "STAKING_PAL_NULL_OR_SAME_ERROR"
        );
        pool.stakingPal = newStakingPalAddress;
    }

    /// @inheritdoc IStaking
    function decreaseStakingPoolOperatorShare(bytes32 poolId, uint32 newOperatorShare)
        external
        override
        onlyStakingPoolOperator(poolId)
    {
        // load pool and assert that we can decrease
        uint32 currentOperatorShare = _poolById[poolId].operatorShare;
        _assertNewOperatorShare(currentOperatorShare, newOperatorShare);

        // decrease operator share
        _poolById[poolId].operatorShare = newOperatorShare;
        emit OperatorShareDecreased(poolId, currentOperatorShare, newOperatorShare);
    }

    /// @inheritdoc IStaking
    function getStakingPool(bytes32 poolId) public view override returns (IStructs.Pool memory) {
        return _poolById[poolId];
    }

    /// @dev Allows caller to join a staking pool as a rigoblock pool account.
    /// @param _poold Id of the pool.
    /// @param _rigoblockPoolAccount Address of pool to be added to staking pool.
    function _joinStakingPoolAsRbPoolAccount(bytes32 _poold, address _rigoblockPoolAccount) internal {
        poolIdByRbPoolAccount[_rigoblockPoolAccount] = _poold;
        emit RbPoolStakingPoolSet(_rigoblockPoolAccount, _poold);
    }

    /// @dev Reverts iff a staking pool does not exist.
    /// @param poolId Unique id of pool.
    function _assertStakingPoolExists(bytes32 poolId) internal view {
        require(_poolById[poolId].operator != _NIL_ADDRESS, "STAKING_POOL_DOES_NOT_EXIST_ERROR");
    }

    /// @dev Reverts iff a staking pool does exist.
    /// @param poolId Unique id of pool.
    function _assertStakingPoolDoesNotExist(bytes32 poolId) internal view {
        require(_poolById[poolId].operator == _NIL_ADDRESS, "STAKING_POOL_ALREADY_EXISTS_ERROR");
    }

    /// @dev Asserts that the sender is the operator of the input pool.
    /// @param poolId Pool sender must be operator of.
    function _assertSenderIsPoolOperator(bytes32 poolId) private view {
        address operator = _poolById[poolId].operator;
        require(msg.sender == operator, "CALLER_NOT_OPERATOR_ERROR");
    }

    /// @dev Preventing direct calls to this contract where applied.
    function _assertDelegateCall() private view {
        require(address(this) != _implementation, "STAKING_DIRECT_CALL_NOT_ALLOWED_ERROR");
    }

    /// @dev Reverts iff the new operator share is invalid.
    /// @param currentOperatorShare Current operator share.
    /// @param newOperatorShare New operator share.
    function _assertNewOperatorShare(uint32 currentOperatorShare, uint32 newOperatorShare) private pure {
        // sanity checks
        if (newOperatorShare > _PPM_DENOMINATOR) {
            // operator share must be a valid fraction
            revert("OPERATOR_SHARE_BIGGER_THAN_MAX_ERROR");
        } else if (newOperatorShare > currentOperatorShare) {
            // new share must be less than or equal to the current share
            revert("OPERATOR_SHARE_BIGGER_THAN_CURRENT_ERROR");
        }
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

 Copyright 2022 Rigo Intl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "./interfaces/IERC20.sol";
import "./interfaces/pool/IRigoblockV3PoolActions.sol";
import "./interfaces/pool/IRigoblockV3PoolEvents.sol";
import "./interfaces/pool/IRigoblockV3PoolFallback.sol";
import "./interfaces/pool/IRigoblockV3PoolImmutable.sol";
import "./interfaces/pool/IRigoblockV3PoolInitializer.sol";
import "./interfaces/pool/IRigoblockV3PoolOwnerActions.sol";
import "./interfaces/pool/IRigoblockV3PoolState.sol";
import "./interfaces/pool/IStorageAccessible.sol";

/// @title Rigoblock V3 Pool Interface - Allows interaction with the pool contract.
/// @author Gabriele Rigo - <[email protected]>
// solhint-disable-next-line
interface IRigoblockV3Pool is
    IERC20,
    IRigoblockV3PoolImmutable,
    IRigoblockV3PoolEvents,
    IRigoblockV3PoolFallback,
    IRigoblockV3PoolInitializer,
    IRigoblockV3PoolActions,
    IRigoblockV3PoolOwnerActions,
    IRigoblockV3PoolState,
    IStorageAccessible
{

}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "../../utils/0xUtils/LibMath.sol";
import "../interfaces/IStaking.sol";
import "./MixinCumulativeRewards.sol";
import "../sys/MixinAbstract.sol";

abstract contract MixinStakingPoolRewards is IStaking, MixinAbstract, MixinCumulativeRewards {
    /// @inheritdoc IStaking
    function withdrawDelegatorRewards(bytes32 poolId) external override {
        _withdrawAndSyncDelegatorRewards(poolId, msg.sender);
    }

    /// @inheritdoc IStaking
    function computeRewardBalanceOfOperator(bytes32 poolId) external view override returns (uint256 reward) {
        // Because operator rewards are immediately withdrawn as WETH
        // on finalization, the only factor in this function are unfinalized
        // rewards.
        IStructs.Pool memory pool = _poolById[poolId];
        // Get any unfinalized rewards.
        (uint256 unfinalizedTotalRewards, uint256 unfinalizedMembersStake) = _getUnfinalizedPoolRewards(poolId);

        // Get the operators' portion.
        (reward, ) = _computePoolRewardsSplit(pool.operatorShare, unfinalizedTotalRewards, unfinalizedMembersStake);
        return reward;
    }

    /// @inheritdoc IStaking
    function computeRewardBalanceOfDelegator(bytes32 poolId, address member)
        external
        view
        override
        returns (uint256 reward)
    {
        IStructs.Pool memory pool = _poolById[poolId];
        // Get any unfinalized rewards.
        (uint256 unfinalizedTotalRewards, uint256 unfinalizedMembersStake) = _getUnfinalizedPoolRewards(poolId);

        // Get the members' portion.
        (, uint256 unfinalizedMembersReward) = _computePoolRewardsSplit(
            pool.operatorShare,
            unfinalizedTotalRewards,
            unfinalizedMembersStake
        );
        return _computeDelegatorReward(poolId, member, unfinalizedMembersReward, unfinalizedMembersStake);
    }

    /// @dev Syncs rewards for a delegator. This includes withdrawing rewards
    ///      rewards and adding/removing dependencies on cumulative rewards.
    /// @param poolId Unique id of pool.
    /// @param member of the pool.
    function _withdrawAndSyncDelegatorRewards(bytes32 poolId, address member) internal {
        // Ensure the pool is finalized.
        _assertPoolFinalizedLastEpoch(poolId);

        // Compute balance owed to delegator
        uint256 balance = _computeDelegatorReward(
            poolId,
            member,
            // No unfinalized values because we ensured the pool is already
            // finalized.
            0,
            0
        );

        // Sync the delegated stake balance. This will ensure future calls of
        // `_computeDelegatorReward` during this epoch will return 0,
        // preventing a delegator from withdrawing more than once an epoch.
        _delegatedStakeToPoolByOwner[member][poolId] = _loadCurrentBalance(
            _delegatedStakeToPoolByOwner[member][poolId]
        );

        // Withdraw non-0 balance
        if (balance != 0) {
            // Decrease the balance of the pool
            _decreasePoolRewards(poolId, balance);

            // Withdraw the member's GRG balance
            getGrgContract().transfer(member, balance);
        }

        // Ensure a cumulative reward entry exists for this epoch,
        // copying the previous epoch's CR if one doesn't exist already.
        _updateCumulativeReward(poolId);
    }

    /// @dev Handles a pool's reward at the current epoch.
    ///      This will split the reward between the operator and members,
    ///      depositing them into their respective vaults, and update the
    ///      accounting needed to allow members to withdraw their individual
    ///      rewards.
    /// @param poolId Unique Id of pool.
    /// @param reward received by the pool.
    /// @param membersStake the amount of non-operator delegated stake that
    ///        will split the  reward.
    /// @return operatorReward Portion of `reward` given to the pool operator.
    /// @return membersReward Portion of `reward` given to the pool members.
    function _syncPoolRewards(
        bytes32 poolId,
        uint256 reward,
        uint256 membersStake
    ) internal returns (uint256 operatorReward, uint256 membersReward) {
        IStructs.Pool memory pool = _poolById[poolId];

        // Split the reward between operator and members
        (operatorReward, membersReward) = _computePoolRewardsSplit(pool.operatorShare, reward, membersStake);

        if (operatorReward > 0) {
            // if staking pal is null, pool operator receives full reward
            if (pool.stakingPal == address(0)) {
                // Transfer the operator's grg reward to the operator
                getGrgContract().transfer(pool.operator, operatorReward);
            } else {
                // Transfer staking pal share of operator's reward to staking pal
                // Transfer the reamining operator's grg reward to the operator
                uint256 stakingPalReward = (operatorReward * pool.stakingPalShare) / _PPM_DENOMINATOR;
                getGrgContract().transfer(pool.stakingPal, stakingPalReward);
                getGrgContract().transfer(pool.operator, operatorReward - stakingPalReward);
            }
        }

        if (membersReward > 0) {
            // Increase the balance of the pool
            _increasePoolRewards(poolId, membersReward);
            // Create a cumulative reward entry at the current epoch.
            _addCumulativeReward(poolId, membersReward, membersStake);
        }

        return (operatorReward, membersReward);
    }

    /// @dev Compute the split of a pool reward between the operator and members
    ///      based on the `operatorShare` and `membersStake`.
    /// @param operatorShare The fraction of rewards owed to the operator,
    ///        in PPM.
    /// @param totalReward The pool reward.
    /// @param membersStake The amount of member (non-operator) stake delegated
    ///        to the pool in the epoch the rewards were earned.
    /// @return operatorReward Portion of `totalReward` given to the pool operator.
    /// @return membersReward Portion of `totalReward` given to the pool members.
    function _computePoolRewardsSplit(
        uint32 operatorShare,
        uint256 totalReward,
        uint256 membersStake
    ) internal pure returns (uint256 operatorReward, uint256 membersReward) {
        if (membersStake == 0) {
            operatorReward = totalReward;
        } else {
            operatorReward = LibMath.getPartialAmountCeil(uint256(operatorShare), _PPM_DENOMINATOR, totalReward);
            membersReward = totalReward - operatorReward;
        }
        return (operatorReward, membersReward);
    }

    /// @dev Computes the reward balance in ETH of a specific member of a pool.
    /// @param poolId Unique id of pool.
    /// @param member of the pool.
    /// @param unfinalizedMembersReward Unfinalized total members reward (if any).
    /// @param unfinalizedMembersStake Unfinalized total members stake (if any).
    /// @return reward Balance in WETH.
    function _computeDelegatorReward(
        bytes32 poolId,
        address member,
        uint256 unfinalizedMembersReward,
        uint256 unfinalizedMembersStake
    ) private view returns (uint256 reward) {
        uint256 currentEpoch_ = currentEpoch;
        IStructs.StoredBalance memory delegatedStake = _delegatedStakeToPoolByOwner[member][poolId];

        // There can be no rewards if the last epoch when stake was stored is
        // equal to the current epoch, because all prior rewards, including
        // rewards finalized this epoch have been claimed.
        if (delegatedStake.currentEpoch == currentEpoch_) {
            return 0;
        }

        // We account for rewards over 3 intervals, below.

        // 1/3 Unfinalized rewards earned in `currentEpoch - 1`.
        reward = _computeUnfinalizedDelegatorReward(
            delegatedStake,
            currentEpoch_,
            unfinalizedMembersReward,
            unfinalizedMembersStake
        );

        // 2/3 Finalized rewards earned in epochs [`delegatedStake.currentEpoch + 1` .. `currentEpoch - 1`]
        uint256 delegatedStakeNextEpoch = uint256(delegatedStake.currentEpoch) + 1;
        reward += _computeMemberRewardOverInterval(
            poolId,
            delegatedStake.currentEpochBalance,
            delegatedStake.currentEpoch,
            delegatedStakeNextEpoch
        );

        // 3/3 Finalized rewards earned in epoch `delegatedStake.currentEpoch`.
        reward += _computeMemberRewardOverInterval(
            poolId,
            delegatedStake.nextEpochBalance,
            delegatedStakeNextEpoch,
            currentEpoch_
        );

        return reward;
    }

    /// @dev Computes the unfinalized rewards earned by a delegator in the last epoch.
    /// @param delegatedStake Amount of stake delegated to pool by a specific staker
    /// @param currentEpoch_ The epoch in which this call is executing
    /// @param unfinalizedMembersReward Unfinalized total members reward (if any).
    /// @param unfinalizedMembersStake Unfinalized total members stake (if any).
    /// @return reward Balance in WETH.
    function _computeUnfinalizedDelegatorReward(
        IStructs.StoredBalance memory delegatedStake,
        uint256 currentEpoch_,
        uint256 unfinalizedMembersReward,
        uint256 unfinalizedMembersStake
    ) private pure returns (uint256) {
        // If there are unfinalized rewards this epoch, compute the member's
        // share.
        if (unfinalizedMembersReward == 0 || unfinalizedMembersStake == 0) {
            return 0;
        }

        // Unfinalized rewards are always earned from stake in
        // the prior epoch so we want the stake at `currentEpoch_-1`.
        uint256 unfinalizedStakeBalance = delegatedStake.currentEpoch >= currentEpoch_ - 1
            ? delegatedStake.currentEpochBalance
            : delegatedStake.nextEpochBalance;

        // Sanity check to save gas on computation
        if (unfinalizedStakeBalance == 0) {
            return 0;
        }

        // Compute unfinalized reward
        return
            LibMath.getPartialAmountFloor(unfinalizedMembersReward, unfinalizedMembersStake, unfinalizedStakeBalance);
    }

    /// @dev Increases rewards for a pool.
    /// @param poolId Unique id of pool.
    /// @param amount Amount to increment rewards by.
    function _increasePoolRewards(bytes32 poolId, uint256 amount) private {
        rewardsByPoolId[poolId] += amount;
        grgReservedForPoolRewards += amount;
    }

    /// @dev Decreases rewards for a pool.
    /// @param poolId Unique id of pool.
    /// @param amount Amount to decrement rewards by.
    function _decreasePoolRewards(bytes32 poolId, uint256 amount) private {
        rewardsByPoolId[poolId] -= amount;
        grgReservedForPoolRewards -= amount;
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

 Copyright 2018 RigoBlock, Rigo Investment Sagl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

interface IERC20 {
    /// @notice Emitted when a token is transferred.
    /// @param from Address transferring the tokens.
    /// @param to Address receiving the tokens.
    /// @param value Number of token units.
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @notice Emitted when a token holder sets and approval.
    /// @param owner Address of the account setting the approval.
    /// @param spender Address of the allowed account.
    /// @param value Number of approved units.
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice Transfers token from holder to another address.
    /// @param to Address to send tokens to.
    /// @param value Number of token units to send.
    /// @return success Bool the transaction was successful.
    function transfer(address to, uint256 value) external returns (bool success);

    /// @notice Allows spender to transfer tokens from the holder.
    /// @param from Address of the token holder.
    /// @param to Address to send tokens to.
    /// @param value Number of units to transfer.
    /// @return success Bool the transaction was successful.
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool success);

    /// @notice Allows a holder to approve a spender.
    /// @param spender Address of the token spender.
    /// @param value Number of units to be approved.
    /// @return success Bool the transaction was successful.
    function approve(address spender, uint256 value) external returns (bool success);

    /// @notice Returns token balance for an address.
    /// @param who Address to query balance for.
    /// @return Number of units held.
    function balanceOf(address who) external view returns (uint256);

    /// @notice Returns token allowance of an address to another address.
    /// @param owner Address of token hodler.
    /// @param spender Address of the token spender.
    /// @return Number of allowed units.
    function allowance(address owner, address spender) external view returns (uint256);

    /// @notice Returns token decimals.
    /// @return Uint8 number of decimals.
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: Apache 2.0
/*

 Copyright 2022 Rigo Intl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

/// @title Rigoblock V3 Pool Actions Interface - Allows interaction with the pool contract.
/// @author Gabriele Rigo - <[email protected]>
// solhint-disable-next-line
interface IRigoblockV3PoolActions {
    /// @notice Allows a user to mint pool tokens on behalf of an address.
    /// @param recipient Address receiving the tokens.
    /// @param amountIn Amount of base tokens.
    /// @param amountOutMin Minimum amount to be received, prevents pool operator frontrunning.
    /// @return recipientAmount Number of tokens minted to recipient.
    function mint(
        address recipient,
        uint256 amountIn,
        uint256 amountOutMin
    ) external payable returns (uint256 recipientAmount);

    /// @notice Allows a pool holder to burn pool tokens.
    /// @param amountIn Number of tokens to burn.
    /// @param amountOutMin Minimum amount to be received, prevents pool operator frontrunning.
    /// @return netRevenue Net amount of burnt pool tokens.
    function burn(uint256 amountIn, uint256 amountOutMin) external returns (uint256 netRevenue);
}

// SPDX-License-Identifier: Apache 2.0
pragma solidity >=0.8.0 <0.9.0;

/// @title Rigoblock V3 Pool Events - Declares events of the pool contract.
/// @author Gabriele Rigo - <[email protected]>
interface IRigoblockV3PoolEvents {
    /// @notice Emitted when a new pool is initialized.
    /// @dev Pool is initialized at new pool creation.
    /// @param group Address of the factory.
    /// @param owner Address of the owner.
    /// @param baseToken Address of the base token.
    /// @param name String name of the pool.
    /// @param symbol String symbol of the pool.
    event PoolInitialized(
        address indexed group,
        address indexed owner,
        address indexed baseToken,
        string name,
        bytes8 symbol
    );

    /// @notice Emitted when new owner is set.
    /// @param old Address of the previous owner.
    /// @param current Address of the new owner.
    event NewOwner(address indexed old, address indexed current);

    /// @notice Emitted when pool operator updates NAV.
    /// @param poolOperator Address of the pool owner.
    /// @param pool Address of the pool.
    /// @param unitaryValue Value of 1 token in wei units.
    event NewNav(address indexed poolOperator, address indexed pool, uint256 unitaryValue);

    /// @notice Emitted when pool operator sets new mint fee.
    /// @param pool Address of the pool.
    /// @param who Address that is sending the transaction.
    /// @param transactionFee Number of the new fee in wei.
    event NewFee(address indexed pool, address indexed who, uint16 transactionFee);

    /// @notice Emitted when pool operator updates fee collector address.
    /// @param pool Address of the pool.
    /// @param who Address that is sending the transaction.
    /// @param feeCollector Address of the new fee collector.
    event NewCollector(address indexed pool, address indexed who, address feeCollector);

    /// @notice Emitted when pool operator updates minimum holding period.
    /// @param pool Address of the pool.
    /// @param minimumPeriod Number of seconds.
    event MinimumPeriodChanged(address indexed pool, uint48 minimumPeriod);

    /// @notice Emitted when pool operator updates the mint/burn spread.
    /// @param pool Address of the pool.
    /// @param spread Number of the spread in basis points.
    event SpreadChanged(address indexed pool, uint16 spread);

    /// @notice Emitted when pool operator sets a kyc provider.
    /// @param pool Address of the pool.
    /// @param kycProvider Address of the kyc provider.
    event KycProviderSet(address indexed pool, address indexed kycProvider);
}

// SPDX-License-Identifier: Apache 2.0
pragma solidity >=0.8.0 <0.9.0;

/// @title Rigoblock V3 Pool Fallback Interface - Interface of the fallback method.
/// @author Gabriele Rigo - <[email protected]>
interface IRigoblockV3PoolFallback {
    /// @notice Delegate calls to pool extension.
    /// @dev Delegatecall restricted to owner, staticcall accessible by everyone.
    /// @dev Restricting delegatecall to owner effectively locks direct calls.
    fallback() external payable;

    /// @notice Allows transfers to pool.
    /// @dev Prevents accidental transfer to implementation contract.
    receive() external payable;
}

// SPDX-License-Identifier: Apache 2.0
pragma solidity >=0.8.0 <0.9.0;

/// @title Rigoblock V3 Pool Immutable - Interface of the pool storage.
/// @author Gabriele Rigo - <[email protected]>
interface IRigoblockV3PoolImmutable {
    /// @notice Returns a string of the pool version.
    /// @return String of the pool implementation version.
    function VERSION() external view returns (string memory);

    /// @notice Returns the address of the authority contract.
    /// @return Address of the authority contract.
    function authority() external view returns (address);
}

// SPDX-License-Identifier: Apache 2.0
/*

 Copyright 2022 Rigo Intl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

/// @title Rigoblock V3 Pool Initializer Interface - Allows initializing a pool contract.
/// @author Gabriele Rigo - <[email protected]>
// solhint-disable-next-line
interface IRigoblockV3PoolInitializer {
    /// @notice Initializes to pool storage.
    /// @dev Pool can only be initialized at creation, meaning this method cannot be called directly to implementation.
    function initializePool() external;
}

// SPDX-License-Identifier: Apache 2.0
pragma solidity >=0.8.0 <0.9.0;

/// @title Rigoblock V3 Pool Owner Actions Interface - Interface of the owner methods.
/// @author Gabriele Rigo - <[email protected]>
interface IRigoblockV3PoolOwnerActions {
    /// @notice Allows owner to decide where to receive the fee.
    /// @param feeCollector Address of the fee receiver.
    function changeFeeCollector(address feeCollector) external;

    /// @notice Allows pool owner to change the minimum holding period.
    /// @param minPeriod Time in seconds.
    function changeMinPeriod(uint48 minPeriod) external;

    /// @notice Allows pool owner to change the mint/burn spread.
    /// @param newSpread Number between 0 and 1000, in basis points.
    function changeSpread(uint16 newSpread) external;

    /// @notice Allows pool owner to set/update the user whitelist contract.
    /// @dev Kyc provider can be set to null, removing user whitelist requirement.
    /// @param kycProvider Address if the kyc provider.
    function setKycProvider(address kycProvider) external;

    /// @notice Allows pool owner to set a new owner address.
    /// @dev Method restricted to owner.
    /// @param newOwner Address of the new owner.
    function setOwner(address newOwner) external;

    /// @notice Allows pool owner to set the transaction fee.
    /// @param transactionFee Value of the transaction fee in basis points.
    function setTransactionFee(uint16 transactionFee) external;

    /// @notice Allows pool owner to set the pool price.
    /// @param unitaryValue Value of 1 token in wei units.
    function setUnitaryValue(uint256 unitaryValue) external;
}

// SPDX-License-Identifier: Apache 2.0
pragma solidity >=0.8.0 <0.9.0;

/// @title Rigoblock V3 Pool State - Returns the pool view methods.
/// @author Gabriele Rigo - <[email protected]>
interface IRigoblockV3PoolState {
    /// @notice Returned pool initialization parameters.
    /// @dev Symbol is stored as bytes8 but returned as string to facilitating client view.
    /// @param name String of the pool name (max 32 characters).
    /// @param symbol String of the pool symbol (from 3 to 5 characters).
    /// @param decimals Uint8 decimals.
    /// @param owner Address of the pool operator.
    /// @param baseToken Address of the base token of the pool (0 for base currency).
    struct ReturnedPool {
        string name;
        string symbol;
        uint8 decimals;
        address owner;
        address baseToken;
    }

    /// @notice Returns the struct containing pool initialization parameters.
    /// @dev Symbol is stored as bytes8 but returned as string in the returned struct, unlocked is omitted as alwasy true.
    /// @return ReturnedPool struct.
    function getPool() external view returns (ReturnedPool memory);

    /// @notice Pool variables.
    /// @param minPeriod Minimum holding period in seconds.
    /// @param spread Value of spread in basis points (from 0 to +-10%).
    /// @param transactionFee Value of transaction fee in basis points (from 0 to 1%).
    /// @param feeCollector Address of the fee receiver.
    /// @param kycProvider Address of the kyc provider.
    struct PoolParams {
        uint48 minPeriod;
        uint16 spread;
        uint16 transactionFee;
        address feeCollector;
        address kycProvider;
    }

    /// @notice Returns the struct compaining pool parameters.
    /// @return PoolParams struct.
    function getPoolParams() external view returns (PoolParams memory);

    /// @notice Pool tokens.
    /// @param unitaryValue A token's unitary value in base token.
    /// @param totalSupply Number of total issued pool tokens.
    struct PoolTokens {
        uint256 unitaryValue;
        uint256 totalSupply;
    }

    /// @notice Returns the struct containing pool tokens info.
    /// @return PoolTokens struct.
    function getPoolTokens() external view returns (PoolTokens memory);

    /// @notice Returns the aggregate pool generic storage.
    /// @return poolInitParams The pool's initialization parameters.
    /// @return poolVariables The pool's variables.
    /// @return poolTokensInfo The pool's tokens info.
    function getPoolStorage()
        external
        view
        returns (
            ReturnedPool memory poolInitParams,
            PoolParams memory poolVariables,
            PoolTokens memory poolTokensInfo
        );

    /// @notice Pool holder account.
    /// @param userBalance Number of tokens held by user.
    /// @param activation Time when tokens become active.
    struct UserAccount {
        uint208 userBalance;
        uint48 activation;
    }

    /// @notice Returns a pool holder's account struct.
    /// @return UserAccount struct.
    function getUserAccount(address _who) external view returns (UserAccount memory);

    /// @notice Returns a string of the pool name.
    /// @dev Name maximum length 31 bytes.
    /// @return String of the name.
    function name() external view returns (string memory);

    /// @notice Returns the address of the owner.
    /// @return Address of the owner.
    function owner() external view returns (address);

    /// @notice Returns a string of the pool symbol.
    /// @return String of the symbol.
    function symbol() external view returns (string memory);

    /// @notice Returns the total amount of issued tokens for this pool.
    /// @return Number of total issued tokens.
    function totalSupply() external view returns (uint256);
}

// SPDX-License-Identifier: Apache 2.0
pragma solidity >=0.7.0 <0.9.0;

/// @title IStorageAccessible - generic base interface that allows callers to access all internal storage.
/// @notice See https://github.com/gnosis/util-contracts/blob/bb5fe5fb5df6d8400998094fb1b32a178a47c3a1/contracts/StorageAccessible.sol
interface IStorageAccessible {
    /// @notice Reads `length` bytes of storage in the currents contract.
    /// @param offset - the offset in the current contract's storage in words to start reading from.
    /// @param length - the number of words (32 bytes) of data to read.
    /// @return Bytes string of the bytes that were read.
    function getStorageAt(uint256 offset, uint256 length) external view returns (bytes memory);

    /// @notice Reads bytes of storage at different storage locations.
    /// @dev Returns a string with values regarless of where they are stored, i.e. variable, mapping or struct.
    /// @param slots The array of storage slots to query into.
    /// @return Bytes string composite of different storage locations' value.
    function getStorageSlotsAt(uint256[] memory slots) external view returns (bytes memory);
}

// SPDX-License-Identifier: Apache 2.0
/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

library LibMath {
    /// @dev Calculates partial value given a numerator and denominator rounded down.
    ///      Reverts if rounding error is >= 0.1%
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return partialAmount Partial value of target rounded down.
    function safeGetPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (uint256 partialAmount) {
        require(!isRoundingErrorFloor(numerator, denominator, target), "LIBMATH_ROUNDING_FLOOR_ERROR");

        partialAmount = (numerator * target) / denominator;
        return partialAmount;
    }

    /// @dev Calculates partial value given a numerator and denominator rounded down.
    ///      Reverts if rounding error is >= 0.1%
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return partialAmount Partial value of target rounded up.
    function safeGetPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (uint256 partialAmount) {
        require(!isRoundingErrorCeil(numerator, denominator, target), "LIBMATH_ROUNDING_CEIL_ERROR");

        // safeDiv computes `floor(a / b)`. We use the identity (a, b integer):
        //       ceil(a / b) = floor((a + b - 1) / b)
        // To implement `ceil(a / b)` using safeDiv.
        partialAmount = (numerator * target + (denominator - 1)) / denominator;

        return partialAmount;
    }

    /// @dev Calculates partial value given a numerator and denominator rounded down.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return partialAmount Partial value of target rounded down.
    function getPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (uint256 partialAmount) {
        partialAmount = (numerator * target) / denominator;
        return partialAmount;
    }

    /// @dev Calculates partial value given a numerator and denominator rounded down.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return partialAmount Partial value of target rounded up.
    function getPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (uint256 partialAmount) {
        // safeDiv computes `floor(a / b)`. We use the identity (a, b integer):
        //       ceil(a / b) = floor((a + b - 1) / b)
        // To implement `ceil(a / b)` using safeDiv.
        partialAmount = (numerator * target + (denominator - 1)) / denominator;

        return partialAmount;
    }

    /// @dev Checks if rounding error >= 0.1% when rounding down.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to multiply with numerator/denominator.
    /// @return isError Rounding error is present.
    function isRoundingErrorFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (bool isError) {
        require(denominator != 0, "LIBMATH_DIVISION_BY_ZERO_ERROR");

        // The absolute rounding error is the difference between the rounded
        // value and the ideal value. The relative rounding error is the
        // absolute rounding error divided by the absolute value of the
        // ideal value. This is undefined when the ideal value is zero.
        //
        // The ideal value is `numerator * target / denominator`.
        // Let's call `numerator * target % denominator` the remainder.
        // The absolute error is `remainder / denominator`.
        //
        // When the ideal value is zero, we require the absolute error to
        // be zero. Fortunately, this is always the case. The ideal value is
        // zero iff `numerator == 0` and/or `target == 0`. In this case the
        // remainder and absolute error are also zero.
        if (target == 0 || numerator == 0) {
            return false;
        }

        // Otherwise, we want the relative rounding error to be strictly
        // less than 0.1%.
        // The relative error is `remainder / (numerator * target)`.
        // We want the relative error less than 1 / 1000:
        //        remainder / (numerator * denominator)  <  1 / 1000
        // or equivalently:
        //        1000 * remainder  <  numerator * target
        // so we have a rounding error iff:
        //        1000 * remainder  >=  numerator * target
        uint256 remainder = mulmod(target, numerator, denominator);
        isError = remainder * 1000 >= numerator * target;
        return isError;
    }

    /// @dev Checks if rounding error >= 0.1% when rounding up.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to multiply with numerator/denominator.
    /// @return isError Rounding error is present.
    function isRoundingErrorCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (bool isError) {
        require(denominator != 0, "LIBMATH_DIVISION_BY_ZERO_ERROR");

        // See the comments in `isRoundingError`.
        if (target == 0 || numerator == 0) {
            // When either is zero, the ideal value and rounded value are zero
            // and there is no rounding error. (Although the relative error
            // is undefined.)
            return false;
        }
        // Compute remainder as before
        uint256 remainder = mulmod(target, numerator, denominator);
        remainder = (denominator - remainder) % denominator;
        isError = remainder * 1000 >= numerator * target;
        return isError;
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "../../utils/0xUtils/LibFractions.sol";
import "../stake/MixinStakeBalances.sol";
import "../immutable/MixinConstants.sol";

abstract contract MixinCumulativeRewards is MixinStakeBalances, MixinConstants {
    /// @dev returns true iff Cumulative Rewards are set
    function _isCumulativeRewardSet(IStructs.Fraction memory cumulativeReward) internal pure returns (bool) {
        // We use the denominator as a proxy for whether the cumulative
        // reward is set, as setting the cumulative reward always sets this
        // field to at least 1.
        return cumulativeReward.denominator != 0;
    }

    /// @dev Sets a pool's cumulative delegator rewards for the current epoch,
    ///      given the rewards earned and stake from the last epoch, which will
    ///      be summed with the previous cumulative rewards for this pool.
    ///      If the last cumulative reward epoch is the current epoch, this is a
    ///      no-op.
    /// @param poolId The pool ID.
    /// @param reward The total reward earned by pool delegators from the last epoch.
    /// @param stake The total delegated stake in the pool in the last epoch.
    function _addCumulativeReward(
        bytes32 poolId,
        uint256 reward,
        uint256 stake
    ) internal {
        // Fetch the last epoch at which we stored an entry for this pool;
        // this is the most up-to-date cumulative rewards for this pool.
        uint256 lastStoredEpoch = _cumulativeRewardsByPoolLastStored[poolId];
        uint256 currentEpoch_ = currentEpoch;

        // If we already have a record for this epoch, don't overwrite it.
        if (lastStoredEpoch == currentEpoch_) {
            return;
        }

        IStructs.Fraction memory mostRecentCumulativeReward = _cumulativeRewardsByPool[poolId][lastStoredEpoch];

        // Compute new cumulative reward
        IStructs.Fraction memory cumulativeReward;
        if (_isCumulativeRewardSet(mostRecentCumulativeReward)) {
            // If we have a prior cumulative reward entry, we sum them as fractions.
            (cumulativeReward.numerator, cumulativeReward.denominator) = LibFractions.add(
                mostRecentCumulativeReward.numerator,
                mostRecentCumulativeReward.denominator,
                reward,
                stake
            );
            // Normalize to prevent overflows in future operations.
            (cumulativeReward.numerator, cumulativeReward.denominator) = LibFractions.normalize(
                cumulativeReward.numerator,
                cumulativeReward.denominator
            );
        } else {
            (cumulativeReward.numerator, cumulativeReward.denominator) = (reward, stake);
        }

        // Store cumulative rewards for this epoch.
        _cumulativeRewardsByPool[poolId][currentEpoch_] = cumulativeReward;
        _cumulativeRewardsByPoolLastStored[poolId] = currentEpoch_;
    }

    /// @dev Sets a pool's cumulative delegator rewards for the current epoch,
    ///      using the last stored cumulative rewards. If we've already set
    ///      a CR for this epoch, this is a no-op.
    /// @param poolId The pool ID.
    function _updateCumulativeReward(bytes32 poolId) internal {
        // Just add empty rewards for this epoch, which will be added to
        // the previous CR, so we end up with the previous CR being set for
        // this epoch.
        _addCumulativeReward(poolId, 0, 1);
    }

    /// @dev Computes a member's reward over a given epoch interval.
    /// @param poolId Uniqud Id of pool.
    /// @param memberStakeOverInterval Stake delegated to pool by member over
    ///        the interval.
    /// @param beginEpoch Beginning of interval.
    /// @param endEpoch End of interval.
    /// @return reward Reward accumulated over interval [beginEpoch, endEpoch]
    function _computeMemberRewardOverInterval(
        bytes32 poolId,
        uint256 memberStakeOverInterval,
        uint256 beginEpoch,
        uint256 endEpoch
    ) internal view returns (uint256 reward) {
        // Sanity check if we can skip computation, as it will result in zero.
        if (memberStakeOverInterval == 0 || beginEpoch == endEpoch) {
            return 0;
        }

        // Sanity check interval
        require(beginEpoch < endEpoch, "CR_INTERVAL_INVALID");

        // Sanity check begin reward
        IStructs.Fraction memory beginReward = _getCumulativeRewardAtEpoch(poolId, beginEpoch);
        IStructs.Fraction memory endReward = _getCumulativeRewardAtEpoch(poolId, endEpoch);

        // Compute reward
        reward = LibFractions.scaleDifference(
            endReward.numerator,
            endReward.denominator,
            beginReward.numerator,
            beginReward.denominator,
            memberStakeOverInterval
        );
    }

    /// @dev Fetch the cumulative reward for a given epoch.
    ///      If the corresponding CR does not exist in state, then we backtrack
    ///      to find its value by querying `epoch-1` and then most recent CR.
    /// @param poolId Unique ID of pool.
    /// @param epoch The epoch to find the
    /// @return cumulativeReward The cumulative reward for `poolId` at `epoch`.
    function _getCumulativeRewardAtEpoch(bytes32 poolId, uint256 epoch)
        private
        view
        returns (IStructs.Fraction memory cumulativeReward)
    {
        // Return CR at `epoch`, given it's set.
        cumulativeReward = _cumulativeRewardsByPool[poolId][epoch];
        if (_isCumulativeRewardSet(cumulativeReward)) {
            return cumulativeReward;
        }

        // Return CR at `epoch-1`, given it's set.
        uint256 lastEpoch = epoch - 1;
        cumulativeReward = _cumulativeRewardsByPool[poolId][lastEpoch];
        if (_isCumulativeRewardSet(cumulativeReward)) {
            return cumulativeReward;
        }

        // Return the most recent CR, given it's less than `epoch`.
        uint256 mostRecentEpoch = _cumulativeRewardsByPoolLastStored[poolId];
        if (mostRecentEpoch < epoch) {
            cumulativeReward = _cumulativeRewardsByPool[poolId][mostRecentEpoch];
            if (_isCumulativeRewardSet(cumulativeReward)) {
                return cumulativeReward;
            }
        }

        // Otherwise return an empty CR.
        return IStructs.Fraction(0, 1);
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

/// @dev Exposes some internal functions from various contracts to avoid
///      cyclical dependencies.
abstract contract MixinAbstract {
    /// @dev Computes the reward owed to a pool during finalization.
    ///      Does nothing if the pool is already finalized.
    /// @param poolId The pool's ID.
    /// @return totalReward The total reward owed to a pool.
    /// @return membersStake The total stake for all non-operator members in
    ///         this pool.
    function _getUnfinalizedPoolRewards(bytes32 poolId)
        internal
        view
        virtual
        returns (uint256 totalReward, uint256 membersStake);

    /// @dev Asserts that a pool has been finalized last epoch.
    /// @param poolId The id of the pool that should have been finalized.
    function _assertPoolFinalizedLastEpoch(bytes32 poolId) internal view virtual;
}

// SPDX-License-Identifier: Apache 2.0
pragma solidity >=0.8.0 <0.9.0;

library LibFractions {
    /// @dev Safely adds two fractions `n1/d1 + n2/d2`
    /// @param n1 numerator of `1`
    /// @param d1 denominator of `1`
    /// @param n2 numerator of `2`
    /// @param d2 denominator of `2`
    /// @return numerator Numerator of sum
    /// @return denominator Denominator of sum
    function add(
        uint256 n1,
        uint256 d1,
        uint256 n2,
        uint256 d2
    ) internal pure returns (uint256 numerator, uint256 denominator) {
        if (n1 == 0) {
            return (numerator = n2, denominator = d2);
        }
        if (n2 == 0) {
            return (numerator = n1, denominator = d1);
        }
        numerator = n1 * d2 + (n2 * d1);
        denominator = d1 * d2;
        return (numerator, denominator);
    }

    /// @dev Rescales a fraction to prevent overflows during addition if either
    ///      the numerator or the denominator are > `maxValue`.
    /// @param numerator The numerator.
    /// @param denominator The denominator.
    /// @param maxValue The maximum value allowed for both the numerator and
    ///        denominator.
    /// @return scaledNumerator The rescaled numerator.
    /// @return scaledDenominator The rescaled denominator.
    function normalize(
        uint256 numerator,
        uint256 denominator,
        uint256 maxValue
    ) internal pure returns (uint256 scaledNumerator, uint256 scaledDenominator) {
        // If either the numerator or the denominator are > `maxValue`,
        // re-scale them by `maxValue` to prevent overflows in future operations.
        if (numerator > maxValue || denominator > maxValue) {
            uint256 rescaleBase = numerator >= denominator ? numerator : denominator;
            rescaleBase = rescaleBase / maxValue;
            scaledNumerator = numerator / rescaleBase;
            scaledDenominator = denominator / rescaleBase;
        } else {
            scaledNumerator = numerator;
            scaledDenominator = denominator;
        }
        return (scaledNumerator, scaledDenominator);
    }

    /// @dev Rescales a fraction to prevent overflows during addition if either
    ///      the numerator or the denominator are > 2 ** 127.
    /// @param numerator The numerator.
    /// @param denominator The denominator.
    /// @return scaledNumerator The rescaled numerator.
    /// @return scaledDenominator The rescaled denominator.
    function normalize(uint256 numerator, uint256 denominator)
        internal
        pure
        returns (uint256 scaledNumerator, uint256 scaledDenominator)
    {
        return normalize(numerator, denominator, 2**127);
    }

    /// @dev Safely scales the difference between two fractions.
    /// @param n1 numerator of `1`
    /// @param d1 denominator of `1`
    /// @param n2 numerator of `2`
    /// @param d2 denominator of `2`
    /// @param s scalar to multiply by difference.
    /// @return result `s * (n1/d1 - n2/d2)`.
    function scaleDifference(
        uint256 n1,
        uint256 d1,
        uint256 n2,
        uint256 d2,
        uint256 s
    ) internal pure returns (uint256 result) {
        if (s == 0) {
            return 0;
        }
        if (n2 == 0) {
            return result = (s * n1) / d1;
        }
        uint256 numerator = n1 * d2 - (n2 * d1);
        uint256 tmp = numerator / d2;
        return (s * tmp) / d1;
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "../libs/LibSafeDowncast.sol";
import "../interfaces/IStructs.sol";
import "../immutable/MixinDeploymentConstants.sol";
import "./MixinStakeStorage.sol";

abstract contract MixinStakeBalances is MixinStakeStorage, MixinDeploymentConstants {
    using LibSafeDowncast for uint256;

    /// @inheritdoc IStaking
    function getGlobalStakeByStatus(IStructs.StakeStatus stakeStatus)
        external
        view
        override
        returns (IStructs.StoredBalance memory balance)
    {
        balance = _loadCurrentBalance(_globalStakeByStatus[uint8(IStructs.StakeStatus.DELEGATED)]);
        if (stakeStatus == IStructs.StakeStatus.UNDELEGATED) {
            // Undelegated stake is the difference between total stake and delegated stake
            // Note that any ZRX erroneously sent to the vault will be counted as undelegated stake
            uint256 totalStake = getGrgVault().balanceOfGrgVault();
            balance.currentEpochBalance = (totalStake - balance.currentEpochBalance).downcastToUint96();
            balance.nextEpochBalance = (totalStake - balance.nextEpochBalance).downcastToUint96();
        }
        return balance;
    }

    /// @inheritdoc IStaking
    function getOwnerStakeByStatus(address staker, IStructs.StakeStatus stakeStatus)
        external
        view
        override
        returns (IStructs.StoredBalance memory balance)
    {
        balance = _loadCurrentBalance(_ownerStakeByStatus[uint8(stakeStatus)][staker]);
        return balance;
    }

    /// @inheritdoc IStaking
    function getTotalStake(address staker) public view override returns (uint256) {
        return getGrgVault().balanceOf(staker);
    }

    /// @inheritdoc IStaking
    function getStakeDelegatedToPoolByOwner(address staker, bytes32 poolId)
        public
        view
        override
        returns (IStructs.StoredBalance memory balance)
    {
        balance = _loadCurrentBalance(_delegatedStakeToPoolByOwner[staker][poolId]);
        return balance;
    }

    /// @inheritdoc IStaking
    function getTotalStakeDelegatedToPool(bytes32 poolId)
        public
        view
        override
        returns (IStructs.StoredBalance memory balance)
    {
        balance = _loadCurrentBalance(_delegatedStakeByPoolId[poolId]);
        return balance;
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

library LibSafeDowncast {
    /// @dev Safely downcasts to a uint96
    /// Note that this reverts if the input value is too large.
    function downcastToUint96(uint256 a) internal pure returns (uint96 b) {
        b = uint96(a);
        require(uint256(b) == a, "VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT96");
        return b;
    }

    /// @dev Safely downcasts to a uint64
    /// Note that this reverts if the input value is too large.
    function downcastToUint64(uint256 a) internal pure returns (uint64 b) {
        b = uint64(a);
        require(uint256(b) == a, "VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT64");
        return b;
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import {IGrgVault as GrgVault} from "../interfaces/IGrgVault.sol";
import "../interfaces/IStaking.sol";
import {IPoolRegistry as PoolRegistry} from "../../protocol/interfaces/IPoolRegistry.sol";
import {IRigoToken as RigoToken} from "../../rigoToken/interfaces/IRigoToken.sol";

// solhint-disable separate-by-one-line-in-contract
abstract contract MixinDeploymentConstants is IStaking {
    // we store this address in the bytecode to being able to prevent direct calls to the implementation.
    address internal immutable _implementation;

    address private immutable _inflationL2;
    address private immutable _rigoToken;
    address private immutable _grgVault;
    address private immutable _poolRegistry;

    constructor(
        address grgVault,
        address poolRegistry,
        address rigoToken
    ) {
        _grgVault = grgVault;
        _poolRegistry = poolRegistry;
        _rigoToken = rigoToken;
        _implementation = address(this);
        uint256 chainId = block.chainid;
        address inflationL2 = address(0);

        // we do not overwrite in test environment as we want to separately handle inflationL2 within the tests
        if (chainId != 1 && chainId != 5 && chainId != 31337) {
            inflationL2 = 0xA889E90d4F1BA125Df1B4C1f55c7fff9F4377C03;
        }

        _inflationL2 = inflationL2;
    }

    /// @inheritdoc IStaking
    function getGrgContract() public view virtual override returns (RigoToken) {
        return RigoToken(_rigoToken);
    }

    /// @inheritdoc IStaking
    function getGrgVault() public view virtual override returns (GrgVault) {
        return GrgVault(_grgVault);
    }

    /// @inheritdoc IStaking
    function getPoolRegistry() public view virtual override returns (PoolRegistry) {
        return PoolRegistry(_poolRegistry);
    }

    function _getInflation() internal view returns (address) {
        return (_inflationL2 != address(0) ? _inflationL2 : getGrgContract().minter());
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "../libs/LibSafeDowncast.sol";
import "../interfaces/IStructs.sol";
import "../sys/MixinScheduler.sol";

/// @dev This mixin contains logic for managing stake storage.
abstract contract MixinStakeStorage is MixinScheduler {
    using LibSafeDowncast for uint256;

    /// @dev Moves stake between states: 'undelegated' or 'delegated'.
    ///      This change comes into effect next epoch.
    /// @param fromPtr pointer to storage location of `from` stake.
    /// @param toPtr pointer to storage location of `to` stake.
    /// @param amount of stake to move.
    function _moveStake(
        IStructs.StoredBalance storage fromPtr,
        IStructs.StoredBalance storage toPtr,
        uint256 amount
    ) internal {
        // do nothing if pointers are equal
        require(!_arePointersEqual(fromPtr, toPtr), "STAKING_POINTERS_EQUAL_ERROR");

        // load current balances from storage
        IStructs.StoredBalance memory from = _loadCurrentBalance(fromPtr);
        IStructs.StoredBalance memory to = _loadCurrentBalance(toPtr);

        // sanity check on balance
        require(amount <= from.nextEpochBalance, "STAKING_INSUFFICIENT_BALANCE_ERROR");

        // move stake for next epoch
        from.nextEpochBalance -= amount.downcastToUint96();
        to.nextEpochBalance += amount.downcastToUint96();

        // update state in storage
        _storeBalance(fromPtr, from);
        _storeBalance(toPtr, to);
    }

    /// @dev Loads a balance from storage and updates its fields to reflect values for the current epoch.
    /// @param balancePtr to load.
    /// @return balance current balance.
    function _loadCurrentBalance(IStructs.StoredBalance storage balancePtr)
        internal
        view
        returns (IStructs.StoredBalance memory balance)
    {
        balance = balancePtr;
        uint256 currentEpoch_ = currentEpoch;
        if (currentEpoch_ > balance.currentEpoch) {
            balance.currentEpoch = currentEpoch_.downcastToUint64();
            balance.currentEpochBalance = balance.nextEpochBalance;
        }
        return balance;
    }

    /// @dev Increments both the `current` and `next` fields.
    /// @param balancePtr storage pointer to balance.
    /// @param amount to mint.
    function _increaseCurrentAndNextBalance(IStructs.StoredBalance storage balancePtr, uint256 amount) internal {
        // Remove stake from balance
        IStructs.StoredBalance memory balance = _loadCurrentBalance(balancePtr);
        balance.nextEpochBalance += amount.downcastToUint96();
        balance.currentEpochBalance += amount.downcastToUint96();

        // update state
        _storeBalance(balancePtr, balance);
    }

    /// @dev Decrements both the `current` and `next` fields.
    /// @param balancePtr storage pointer to balance.
    /// @param amount to mint.
    function _decreaseCurrentAndNextBalance(IStructs.StoredBalance storage balancePtr, uint256 amount) internal {
        // Remove stake from balance
        IStructs.StoredBalance memory balance = _loadCurrentBalance(balancePtr);
        balance.nextEpochBalance -= amount.downcastToUint96();
        balance.currentEpochBalance -= amount.downcastToUint96();

        // update state
        _storeBalance(balancePtr, balance);
    }

    /// @dev Increments the `next` field (but not the `current` field).
    /// @param balancePtr storage pointer to balance.
    /// @param amount to increment by.
    function _increaseNextBalance(IStructs.StoredBalance storage balancePtr, uint256 amount) internal {
        // Add stake to balance
        IStructs.StoredBalance memory balance = _loadCurrentBalance(balancePtr);
        balance.nextEpochBalance += amount.downcastToUint96();

        // update state
        _storeBalance(balancePtr, balance);
    }

    /// @dev Decrements the `next` field (but not the `current` field).
    /// @param balancePtr storage pointer to balance.
    /// @param amount to decrement by.
    function _decreaseNextBalance(IStructs.StoredBalance storage balancePtr, uint256 amount) internal {
        // Remove stake from balance
        IStructs.StoredBalance memory balance = _loadCurrentBalance(balancePtr);
        balance.nextEpochBalance -= amount.downcastToUint96();

        // update state
        _storeBalance(balancePtr, balance);
    }

    /// @dev Stores a balance in storage.
    /// @param balancePtr points to where `balance` will be stored.
    /// @param balance to save to storage.
    function _storeBalance(IStructs.StoredBalance storage balancePtr, IStructs.StoredBalance memory balance) private {
        // note - this compresses into a single `sstore` when optimizations are enabled,
        // since the StoredBalance struct occupies a single word of storage.
        balancePtr.currentEpoch = balance.currentEpoch;
        balancePtr.nextEpochBalance = balance.nextEpochBalance;
        balancePtr.currentEpochBalance = balance.currentEpochBalance;
    }

    /// @dev Returns true iff storage pointers resolve to same storage location.
    /// @param balancePtrA first storage pointer.
    /// @param balancePtrB second storage pointer.
    /// @return areEqual true iff pointers are equal.
    function _arePointersEqual(
        // solhint-disable-next-line no-unused-vars
        IStructs.StoredBalance storage balancePtrA,
        // solhint-disable-next-line no-unused-vars
        IStructs.StoredBalance storage balancePtrB
    ) private pure returns (bool areEqual) {
        assembly {
            areEqual := and(eq(balancePtrA.slot, balancePtrB.slot), eq(balancePtrA.offset, balancePtrB.offset))
        }
        return areEqual;
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "../immutable/MixinStorage.sol";
import "../interfaces/IStakingEvents.sol";
import "../interfaces/IStaking.sol";

abstract contract MixinScheduler is IStaking, IStakingEvents, MixinStorage {
    /// @inheritdoc IStaking
    function getCurrentEpochEarliestEndTimeInSeconds() public view override returns (uint256) {
        return currentEpochStartTimeInSeconds + epochDurationInSeconds;
    }

    /// @dev Initializes state owned by this mixin.
    ///      Fails if state was already initialized.
    function _initMixinScheduler() internal {
        // assert the current values before overwriting them.
        _assertSchedulerNotInitialized();

        // solhint-disable-next-line
        currentEpochStartTimeInSeconds = block.timestamp;
        currentEpoch = 1;
    }

    /// @dev Moves to the next epoch, given the current epoch period has ended.
    ///      Time intervals that are measured in epochs (like timeLocks) are also incremented, given
    ///      their periods have ended.
    function _goToNextEpoch() internal {
        // get current timestamp
        // solhint-disable-next-line not-rely-on-time
        uint256 currentBlockTimestamp = block.timestamp;

        // validate that we can increment the current epoch
        uint256 epochEndTime = getCurrentEpochEarliestEndTimeInSeconds();
        require(epochEndTime <= currentBlockTimestamp, "STAKING_TIMESTAMP_TOO_LOW_ERROR");

        // incremment epoch
        uint256 nextEpoch = currentEpoch + 1;
        currentEpoch = nextEpoch;
        currentEpochStartTimeInSeconds = currentBlockTimestamp;
    }

    /// @dev Assert scheduler state before initializing it.
    /// This must be updated for each migration.
    function _assertSchedulerNotInitialized() internal view {
        require(currentEpochStartTimeInSeconds == 0, "STAKING_SCHEDULER_ALREADY_INITIALIZED_ERROR");
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "../libs/LibCobbDouglas.sol";
import "../interfaces/IStructs.sol";
import "../staking_pools/MixinStakingPoolRewards.sol";
import "../../rigoToken/interfaces/IInflation.sol";

abstract contract MixinFinalizer is MixinStakingPoolRewards {
    /// @inheritdoc IStaking
    function endEpoch() external override returns (uint256 numPoolsToFinalize) {
        uint256 currentEpoch_ = currentEpoch;
        uint256 prevEpoch = currentEpoch_ - 1;

        // Make sure the previous epoch has been fully finalized.
        uint256 numPoolsToFinalizeFromPrevEpoch = aggregatedStatsByEpoch[prevEpoch].numPoolsToFinalize;
        require(numPoolsToFinalizeFromPrevEpoch == 0, "STAKING_MISSING_POOLS_TO_BE_FINALIZED_ERROR");

        // mint epoch inflation, jump first epoch as all registered pool accounts will become active from following epoch
        //  mint happens before time has passed check, therefore tokens will be allocated even before expiry if method is called
        //  but will not be minted again until epoch time has passed. This could happen when epoch length is changed only.
        if (currentEpoch_ > uint256(1)) {
            try IInflation(_getInflation()).mintInflation() returns (uint256 mintedInflation) {
                emit GrgMintEvent(mintedInflation);
            } catch Error(string memory revertReason) {
                emit CatchStringEvent(revertReason);
            } catch (bytes memory returnData) {
                emit ReturnDataEvent(returnData);
            }
        }

        // Load aggregated stats for the epoch we're ending.
        aggregatedStatsByEpoch[currentEpoch_].rewardsAvailable = _getAvailableGrgBalance();
        IStructs.AggregatedStats memory aggregatedStats = aggregatedStatsByEpoch[currentEpoch_];

        // Emit an event.
        emit EpochEnded(
            currentEpoch_,
            aggregatedStats.numPoolsToFinalize,
            aggregatedStats.rewardsAvailable,
            aggregatedStats.totalFeesCollected,
            aggregatedStats.totalWeightedStake
        );

        // Advance the epoch. This will revert if not enough time has passed.
        _goToNextEpoch();

        // If there are no pools to finalize then the epoch is finalized.
        if (aggregatedStats.numPoolsToFinalize == 0) {
            emit EpochFinalized(currentEpoch_, 0, aggregatedStats.rewardsAvailable);
        }

        return aggregatedStats.numPoolsToFinalize;
    }

    /// @inheritdoc IStaking
    function finalizePool(bytes32 poolId) external override {
        // Compute relevant epochs
        uint256 currentEpoch_ = currentEpoch;
        uint256 prevEpoch = currentEpoch_ - 1;

        // Load the aggregated stats into memory; noop if no pools to finalize.
        IStructs.AggregatedStats memory aggregatedStats = aggregatedStatsByEpoch[prevEpoch];
        if (aggregatedStats.numPoolsToFinalize == 0) {
            return;
        }

        // Noop if the pool did not earn rewards or already finalized (has no fees).
        IStructs.PoolStats memory poolStats = poolStatsByEpoch[poolId][prevEpoch];
        if (poolStats.feesCollected == 0) {
            return;
        }

        // Clear the pool stats so we don't finalize it again, and to recoup
        // some gas.
        delete poolStatsByEpoch[poolId][prevEpoch];

        // Compute the rewards.
        uint256 rewards = _getUnfinalizedPoolRewardsFromPoolStats(poolStats, aggregatedStats);

        // Pay the operator and update rewards for the pool.
        // Note that we credit at the CURRENT epoch even though these rewards
        // were earned in the previous epoch.
        (uint256 operatorReward, uint256 membersReward) = _syncPoolRewards(poolId, rewards, poolStats.membersStake);

        // Emit an event.
        emit RewardsPaid(currentEpoch_, poolId, operatorReward, membersReward);

        uint256 totalReward = operatorReward + membersReward;

        // Increase `totalRewardsFinalized`.
        aggregatedStatsByEpoch[prevEpoch].totalRewardsFinalized = aggregatedStats.totalRewardsFinalized =
            aggregatedStats.totalRewardsFinalized +
            totalReward;

        // Decrease the number of unfinalized pools left.
        aggregatedStatsByEpoch[prevEpoch].numPoolsToFinalize = aggregatedStats.numPoolsToFinalize =
            aggregatedStats.numPoolsToFinalize -
            1;

        // If there are no more unfinalized pools remaining, the epoch is
        // finalized.
        if (aggregatedStats.numPoolsToFinalize == 0) {
            emit EpochFinalized(
                prevEpoch,
                aggregatedStats.totalRewardsFinalized,
                aggregatedStats.rewardsAvailable - aggregatedStats.totalRewardsFinalized
            );
        }
    }

    /// @dev Computes the reward owed to a pool during finalization.
    ///      Does nothing if the pool is already finalized.
    /// @param poolId The pool's ID.
    /// @return reward The total reward owed to a pool.
    /// @return membersStake The total stake for all non-operator members in
    ///         this pool.
    function _getUnfinalizedPoolRewards(bytes32 poolId)
        internal
        view
        virtual
        override
        returns (uint256 reward, uint256 membersStake)
    {
        uint256 prevEpoch = currentEpoch - 1;
        IStructs.PoolStats memory poolStats = poolStatsByEpoch[poolId][prevEpoch];
        reward = _getUnfinalizedPoolRewardsFromPoolStats(poolStats, aggregatedStatsByEpoch[prevEpoch]);
        membersStake = poolStats.membersStake;
    }

    /// @dev Returns the GRG balance of this contract, minus
    ///      any GRG that has already been reserved for rewards.
    function _getAvailableGrgBalance() internal view returns (uint256 grgBalance) {
        grgBalance = getGrgContract().balanceOf(address(this)) - grgReservedForPoolRewards;

        return grgBalance;
    }

    /// @dev Asserts that a pool has been finalized last epoch.
    /// @param poolId The id of the pool that should have been finalized.
    function _assertPoolFinalizedLastEpoch(bytes32 poolId) internal view virtual override {
        uint256 prevEpoch = currentEpoch - 1;
        IStructs.PoolStats memory poolStats = poolStatsByEpoch[poolId][prevEpoch];

        // A pool that has any fees remaining has not been finalized
        require(poolStats.feesCollected == 0, "STAKING_POOL_NOT_FINALIZED_ERROR");
    }

    /// @dev Computes the reward owed to a pool during finalization.
    /// @param poolStats Stats for a specific pool.
    /// @param aggregatedStats Stats aggregated across all pools.
    /// @return rewards Unfinalized rewards for the input pool.
    function _getUnfinalizedPoolRewardsFromPoolStats(
        IStructs.PoolStats memory poolStats,
        IStructs.AggregatedStats memory aggregatedStats
    ) private view returns (uint256 rewards) {
        // There can't be any rewards if the pool did not collect any fees.
        if (poolStats.feesCollected == 0) {
            return rewards;
        }

        // Use the cobb-douglas function to compute the total reward.
        rewards = LibCobbDouglas.cobbDouglas(
            aggregatedStats.rewardsAvailable,
            poolStats.feesCollected,
            aggregatedStats.totalFeesCollected,
            poolStats.weightedStake,
            aggregatedStats.totalWeightedStake,
            cobbDouglasAlphaNumerator,
            cobbDouglasAlphaDenominator
        );

        // Clip the reward to always be under
        // `rewardsAvailable - totalRewardsPaid`,
        // in case cobb-douglas overflows, which should be unlikely.
        uint256 rewardsRemaining = aggregatedStats.rewardsAvailable - aggregatedStats.totalRewardsFinalized;
        if (rewardsRemaining < rewards) {
            rewards = rewardsRemaining;
        }
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

import "../interfaces/IStakingEvents.sol";
import "../interfaces/IStaking.sol";
import "../immutable/MixinStorage.sol";

abstract contract MixinPopManager is IStaking, IStakingEvents, MixinStorage {
    /// @inheritdoc IStaking
    function addPopAddress(address addr) external override onlyAuthorized {
        require(!validPops[addr], "STAKING_POP_ALREADY_REGISTERED_ERROR");
        validPops[addr] = true;
        emit PopAdded(addr);
    }

    /// @inheritdoc IStaking
    function removePopAddress(address addr) external override onlyAuthorized {
        require(validPops[addr], "STAKING_POP_NOT_REGISTERED_ERROR");
        validPops[addr] = false;
        emit PopRemoved(addr);
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "./LibFixedMath.sol";

library LibCobbDouglas {
    /// @dev The cobb-douglas function used to compute fee-based rewards for
    ///      staking pools in a given epoch. This function does not perform
    ///      bounds checking on the inputs, but the following conditions
    ///      need to be true:
    ///         0 <= fees / totalFees <= 1
    ///         0 <= stake / totalStake <= 1
    ///         0 <= alphaNumerator / alphaDenominator <= 1
    /// @param totalRewards collected over an epoch.
    /// @param fees Fees attributed to the the staking pool.
    /// @param totalFees Total fees collected across all pools that earned rewards.
    /// @param stake Stake attributed to the staking pool.
    /// @param totalStake Total stake across all pools that earned rewards.
    /// @param alphaNumerator Numerator of `alpha` in the cobb-douglas function.
    /// @param alphaDenominator Denominator of `alpha` in the cobb-douglas
    ///        function.
    /// @return rewards Rewards owed to the staking pool.
    function cobbDouglas(
        uint256 totalRewards,
        uint256 fees,
        uint256 totalFees,
        uint256 stake,
        uint256 totalStake,
        uint32 alphaNumerator,
        uint32 alphaDenominator
    ) internal pure returns (uint256 rewards) {
        int256 feeRatio = LibFixedMath.toFixed(fees, totalFees);
        int256 stakeRatio = LibFixedMath.toFixed(stake, totalStake);
        if (feeRatio == 0 || stakeRatio == 0) {
            return rewards = 0;
        }
        // The cobb-doublas function has the form:
        // `totalRewards * feeRatio ^ alpha * stakeRatio ^ (1-alpha)`
        // This is equivalent to:
        // `totalRewards * stakeRatio * e^(alpha * (ln(feeRatio / stakeRatio)))`
        // However, because `ln(x)` has the domain of `0 < x < 1`
        // and `exp(x)` has the domain of `x < 0`,
        // and fixed-point math easily overflows with multiplication,
        // we will choose the following if `stakeRatio > feeRatio`:
        // `totalRewards * stakeRatio / e^(alpha * (ln(stakeRatio / feeRatio)))`

        // Compute
        // `e^(alpha * ln(feeRatio/stakeRatio))` if feeRatio <= stakeRatio
        // or
        // `e^(alpa * ln(stakeRatio/feeRatio))` if feeRatio > stakeRatio
        int256 n = feeRatio <= stakeRatio
            ? LibFixedMath.div(feeRatio, stakeRatio)
            : LibFixedMath.div(stakeRatio, feeRatio);
        n = LibFixedMath.exp(
            LibFixedMath.mulDiv(LibFixedMath.ln(n), int256(int32(alphaNumerator)), int256(int32(alphaDenominator)))
        );
        // Compute
        // `totalRewards * n` if feeRatio <= stakeRatio
        // or
        // `totalRewards / n` if stakeRatio > feeRatio
        // depending on the choice we made earlier.
        n = feeRatio <= stakeRatio ? LibFixedMath.mul(stakeRatio, n) : LibFixedMath.div(stakeRatio, n);
        // Multiply the above with totalRewards.
        rewards = LibFixedMath.uintMul(n, totalRewards);
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

 Copyright 2017-2019 RigoBlock, Rigo Investment Sagl, 2020 Rigo Intl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

/// @title Inflation Interface - Allows interaction with the Inflation contract.
/// @author Gabriele Rigo - <[email protected]>
// solhint-disable-next-line
interface IInflation {
    /*
     * STORAGE
     */
    /// @notice Returns the address of the GRG token.
    /// @return Address of the Rigo token contract.
    function rigoToken() external view returns (address);

    /// @notice Returns the address of the GRG staking proxy.
    /// @return Address of the proxy contract.
    function stakingProxy() external view returns (address);

    /// @notice Returns the epoch length in seconds.
    /// @return Number of seconds.
    function epochLength() external view returns (uint48);

    /// @notice Returns epoch slot.
    /// @dev Increases by one every new epoch.
    /// @return Number of latest epoch slot.
    function slot() external view returns (uint32);

    /*
     * CORE FUNCTIONS
     */
    /// @notice Allows staking proxy to mint rewards.
    /// @return mintedInflation Number of allocated tokens.
    function mintInflation() external returns (uint256 mintedInflation);

    /*
     * CONSTANT PUBLIC FUNCTIONS
     */
    /// @notice Returns whether an epoch has ended.
    /// @return Bool the epoch has ended.
    function epochEnded() external view returns (bool);

    /// @notice Returns the epoch inflation.
    /// @return Value of units of GRG minted in an epoch.
    function getEpochInflation() external view returns (uint256);

    /// @notice Returns how long until next claim.
    /// @return Number in seconds.
    function timeUntilNextClaim() external view returns (uint256);
}

// SPDX-License-Identifier: Apache 2.0
/*

  Copyright 2017 Bprotocol Foundation, 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

// solhint-disable indent
/// @dev Signed, fixed-point, 127-bit precision math library.
library LibFixedMath {
    // 1
    int256 private constant FIXED_1 = int256(0x0000000000000000000000000000000080000000000000000000000000000000);
    // 2**255
    int256 private constant MIN_FIXED_VAL = type(int256).min;
    // 1^2 (in fixed-point)
    int256 private constant FIXED_1_SQUARED =
        int256(0x4000000000000000000000000000000000000000000000000000000000000000);
    // 1
    int256 private constant LN_MAX_VAL = FIXED_1;
    // e ^ -63.875
    int256 private constant LN_MIN_VAL = int256(0x0000000000000000000000000000000000000000000000000000000733048c5a);
    // 0
    int256 private constant EXP_MAX_VAL = 0;
    // -63.875
    int256 private constant EXP_MIN_VAL = -int256(0x0000000000000000000000000000001ff0000000000000000000000000000000);

    /// @dev Returns the multiplication of two fixed point numbers, reverting on overflow.
    function mul(int256 a, int256 b) internal pure returns (int256 c) {
        unchecked {
            c = _mul(a, b) / FIXED_1;
        }
    }

    /// @dev Returns the division of two fixed point numbers.
    function div(int256 a, int256 b) internal pure returns (int256 c) {
        c = _div(_mul(a, FIXED_1), b);
    }

    /// @dev Performs (a * n) / d, without scaling for precision.
    function mulDiv(
        int256 a,
        int256 n,
        int256 d
    ) internal pure returns (int256 c) {
        c = _div(_mul(a, n), d);
    }

    /// @dev Returns the unsigned integer result of multiplying a fixed-point
    ///      number with an integer, reverting if the multiplication overflows.
    ///      Negative results are clamped to zero.
    function uintMul(int256 f, uint256 u) internal pure returns (uint256) {
        require(int256(u) >= int256(0), "U_TOO_LARGE_ERROR");
        int256 c = _mul(f, int256(u));
        if (c <= 0) {
            return 0;
        }
        return uint256(uint256(c) >> 127);
    }

    /// @dev Convert unsigned `n` / `d` to a fixed-point number.
    ///      Reverts if `n` / `d` is too large to fit in a fixed-point number.
    function toFixed(uint256 n, uint256 d) internal pure returns (int256 f) {
        require(int256(n) >= int256(0), "N_TOO_LARGE_ERROR");
        require(int256(d) >= int256(0), "D_TOO_LARGE_ERROR");
        f = _div(_mul(int256(n), FIXED_1), int256(d));
    }

    /// @dev Get the natural logarithm of a fixed-point number 0 < `x` <= LN_MAX_VAL
    function ln(int256 x) internal pure returns (int256 r) {
        require(x <= LN_MAX_VAL, "X_TOO_LARGE_ERROR");
        require(x > 0, "X_TOO_SMALL_ERROR");

        if (x == FIXED_1) {
            return 0;
        }

        if (x <= LN_MIN_VAL) {
            return EXP_MIN_VAL;
        }

        int256 y;
        int256 z;
        int256 w;

        // Rewrite the input as a quotient of negative natural exponents and a single residual q, such that 1 < q < 2
        // For example: log(0.3) = log(e^-1 * e^-0.25 * 1.0471028872385522)
        //              = 1 - 0.25 - log(1 + 0.0471028872385522)
        // e ^ -32
        if (x <= int256(0x00000000000000000000000000000000000000000001c8464f76164760000000)) {
            r -= int256(0x0000000000000000000000000000001000000000000000000000000000000000); // - 32
            x = (x * FIXED_1) / int256(0x00000000000000000000000000000000000000000001c8464f76164760000000); // / e ^ -32
        }
        // e ^ -16
        if (x <= int256(0x00000000000000000000000000000000000000f1aaddd7742e90000000000000)) {
            r -= int256(0x0000000000000000000000000000000800000000000000000000000000000000); // - 16
            x = (x * FIXED_1) / int256(0x00000000000000000000000000000000000000f1aaddd7742e90000000000000); // / e ^ -16
        }
        // e ^ -8
        if (x <= int256(0x00000000000000000000000000000000000afe10820813d78000000000000000)) {
            r -= int256(0x0000000000000000000000000000000400000000000000000000000000000000); // - 8
            x = (x * FIXED_1) / int256(0x00000000000000000000000000000000000afe10820813d78000000000000000); // / e ^ -8
        }
        // e ^ -4
        if (x <= int256(0x0000000000000000000000000000000002582ab704279ec00000000000000000)) {
            r -= int256(0x0000000000000000000000000000000200000000000000000000000000000000); // - 4
            x = (x * FIXED_1) / int256(0x0000000000000000000000000000000002582ab704279ec00000000000000000); // / e ^ -4
        }
        // e ^ -2
        if (x <= int256(0x000000000000000000000000000000001152aaa3bf81cc000000000000000000)) {
            r -= int256(0x0000000000000000000000000000000100000000000000000000000000000000); // - 2
            x = (x * FIXED_1) / int256(0x000000000000000000000000000000001152aaa3bf81cc000000000000000000); // / e ^ -2
        }
        // e ^ -1
        if (x <= int256(0x000000000000000000000000000000002f16ac6c59de70000000000000000000)) {
            r -= int256(0x0000000000000000000000000000000080000000000000000000000000000000); // - 1
            x = (x * FIXED_1) / int256(0x000000000000000000000000000000002f16ac6c59de70000000000000000000); // / e ^ -1
        }
        // e ^ -0.5
        if (x <= int256(0x000000000000000000000000000000004da2cbf1be5828000000000000000000)) {
            r -= int256(0x0000000000000000000000000000000040000000000000000000000000000000); // - 0.5
            x = (x * FIXED_1) / int256(0x000000000000000000000000000000004da2cbf1be5828000000000000000000); // / e ^ -0.5
        }
        // e ^ -0.25
        if (x <= int256(0x0000000000000000000000000000000063afbe7ab2082c000000000000000000)) {
            r -= int256(0x0000000000000000000000000000000020000000000000000000000000000000); // - 0.25
            x = (x * FIXED_1) / int256(0x0000000000000000000000000000000063afbe7ab2082c000000000000000000); // / e ^ -0.25
        }
        // e ^ -0.125
        if (x <= int256(0x0000000000000000000000000000000070f5a893b608861e1f58934f97aea57d)) {
            r -= int256(0x0000000000000000000000000000000010000000000000000000000000000000); // - 0.125
            x = (x * FIXED_1) / int256(0x0000000000000000000000000000000070f5a893b608861e1f58934f97aea57d); // / e ^ -0.125
        }
        // `x` is now our residual in the range of 1 <= x <= 2 (or close enough).

        // Add the taylor series for log(1 + z), where z = x - 1
        z = y = x - FIXED_1;
        w = (y * y) / FIXED_1;
        r += (z * (0x100000000000000000000000000000000 - y)) / 0x100000000000000000000000000000000;
        z = (z * w) / FIXED_1; // add y^01 / 01 - y^02 / 02
        r += (z * (0x0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa - y)) / 0x200000000000000000000000000000000;
        z = (z * w) / FIXED_1; // add y^03 / 03 - y^04 / 04
        r += (z * (0x099999999999999999999999999999999 - y)) / 0x300000000000000000000000000000000;
        z = (z * w) / FIXED_1; // add y^05 / 05 - y^06 / 06
        r += (z * (0x092492492492492492492492492492492 - y)) / 0x400000000000000000000000000000000;
        z = (z * w) / FIXED_1; // add y^07 / 07 - y^08 / 08
        r += (z * (0x08e38e38e38e38e38e38e38e38e38e38e - y)) / 0x500000000000000000000000000000000;
        z = (z * w) / FIXED_1; // add y^09 / 09 - y^10 / 10
        r += (z * (0x08ba2e8ba2e8ba2e8ba2e8ba2e8ba2e8b - y)) / 0x600000000000000000000000000000000;
        z = (z * w) / FIXED_1; // add y^11 / 11 - y^12 / 12
        r += (z * (0x089d89d89d89d89d89d89d89d89d89d89 - y)) / 0x700000000000000000000000000000000;
        z = (z * w) / FIXED_1; // add y^13 / 13 - y^14 / 14
        r += (z * (0x088888888888888888888888888888888 - y)) / 0x800000000000000000000000000000000; // add y^15 / 15 - y^16 / 16
    }

    /// @dev Compute the natural exponent for a fixed-point number EXP_MIN_VAL <= `x` <= 1
    function exp(int256 x) internal pure returns (int256 r) {
        if (x < EXP_MIN_VAL) {
            // Saturate to zero below EXP_MIN_VAL.
            return 0;
        }
        if (x == 0) {
            return FIXED_1;
        }
        if (x > EXP_MAX_VAL) {
            revert("X_TOO_LARGE_ERROR");
        }

        // Rewrite the input as a product of natural exponents and a
        // single residual q, where q is a number of small magnitude.
        // For example: e^-34.419 = e^(-32 - 2 - 0.25 - 0.125 - 0.044)
        //              = e^-32 * e^-2 * e^-0.25 * e^-0.125 * e^-0.044
        //              -> q = -0.044

        // Multiply with the taylor series for e^q
        int256 y;
        int256 z;
        // q = x % 0.125 (the residual)
        z = y = x % 0x0000000000000000000000000000000010000000000000000000000000000000;
        z = (z * y) / FIXED_1;
        r += z * 0x10e1b3be415a0000; // add y^02 * (20! / 02!)
        z = (z * y) / FIXED_1;
        r += z * 0x05a0913f6b1e0000; // add y^03 * (20! / 03!)
        z = (z * y) / FIXED_1;
        r += z * 0x0168244fdac78000; // add y^04 * (20! / 04!)
        z = (z * y) / FIXED_1;
        r += z * 0x004807432bc18000; // add y^05 * (20! / 05!)
        z = (z * y) / FIXED_1;
        r += z * 0x000c0135dca04000; // add y^06 * (20! / 06!)
        z = (z * y) / FIXED_1;
        r += z * 0x0001b707b1cdc000; // add y^07 * (20! / 07!)
        z = (z * y) / FIXED_1;
        r += z * 0x000036e0f639b800; // add y^08 * (20! / 08!)
        z = (z * y) / FIXED_1;
        r += z * 0x00000618fee9f800; // add y^09 * (20! / 09!)
        z = (z * y) / FIXED_1;
        r += z * 0x0000009c197dcc00; // add y^10 * (20! / 10!)
        z = (z * y) / FIXED_1;
        r += z * 0x0000000e30dce400; // add y^11 * (20! / 11!)
        z = (z * y) / FIXED_1;
        r += z * 0x000000012ebd1300; // add y^12 * (20! / 12!)
        z = (z * y) / FIXED_1;
        r += z * 0x0000000017499f00; // add y^13 * (20! / 13!)
        z = (z * y) / FIXED_1;
        r += z * 0x0000000001a9d480; // add y^14 * (20! / 14!)
        z = (z * y) / FIXED_1;
        r += z * 0x00000000001c6380; // add y^15 * (20! / 15!)
        z = (z * y) / FIXED_1;
        r += z * 0x000000000001c638; // add y^16 * (20! / 16!)
        z = (z * y) / FIXED_1;
        r += z * 0x0000000000001ab8; // add y^17 * (20! / 17!)
        z = (z * y) / FIXED_1;
        r += z * 0x000000000000017c; // add y^18 * (20! / 18!)
        z = (z * y) / FIXED_1;
        r += z * 0x0000000000000014; // add y^19 * (20! / 19!)
        z = (z * y) / FIXED_1;
        r += z * 0x0000000000000001; // add y^20 * (20! / 20!)
        r = r / 0x21c3677c82b40000 + y + FIXED_1; // divide by 20! and then add y^1 / 1! + y^0 / 0!

        // Multiply with the non-residual terms.
        x = -x;
        // e ^ -32
        if ((x & int256(0x0000000000000000000000000000001000000000000000000000000000000000)) != 0) {
            r =
                (r * int256(0x00000000000000000000000000000000000000f1aaddd7742e56d32fb9f99744)) /
                int256(0x0000000000000000000000000043cbaf42a000812488fc5c220ad7b97bf6e99e); // * e ^ -32
        }
        // e ^ -16
        if ((x & int256(0x0000000000000000000000000000000800000000000000000000000000000000)) != 0) {
            r =
                (r * int256(0x00000000000000000000000000000000000afe10820813d65dfe6a33c07f738f)) /
                int256(0x000000000000000000000000000005d27a9f51c31b7c2f8038212a0574779991); // * e ^ -16
        }
        // e ^ -8
        if ((x & int256(0x0000000000000000000000000000000400000000000000000000000000000000)) != 0) {
            r =
                (r * int256(0x0000000000000000000000000000000002582ab704279e8efd15e0265855c47a)) /
                int256(0x0000000000000000000000000000001b4c902e273a58678d6d3bfdb93db96d02); // * e ^ -8
        }
        // e ^ -4
        if ((x & int256(0x0000000000000000000000000000000200000000000000000000000000000000)) != 0) {
            r =
                (r * int256(0x000000000000000000000000000000001152aaa3bf81cb9fdb76eae12d029571)) /
                int256(0x00000000000000000000000000000003b1cc971a9bb5b9867477440d6d157750); // * e ^ -4
        }
        // e ^ -2
        if ((x & int256(0x0000000000000000000000000000000100000000000000000000000000000000)) != 0) {
            r =
                (r * int256(0x000000000000000000000000000000002f16ac6c59de6f8d5d6f63c1482a7c86)) /
                int256(0x000000000000000000000000000000015bf0a8b1457695355fb8ac404e7a79e3); // * e ^ -2
        }
        // e ^ -1
        if ((x & int256(0x0000000000000000000000000000000080000000000000000000000000000000)) != 0) {
            r =
                (r * int256(0x000000000000000000000000000000004da2cbf1be5827f9eb3ad1aa9866ebb3)) /
                int256(0x00000000000000000000000000000000d3094c70f034de4b96ff7d5b6f99fcd8); // * e ^ -1
        }
        // e ^ -0.5
        if ((x & int256(0x0000000000000000000000000000000040000000000000000000000000000000)) != 0) {
            r =
                (r * int256(0x0000000000000000000000000000000063afbe7ab2082ba1a0ae5e4eb1b479dc)) /
                int256(0x00000000000000000000000000000000a45af1e1f40c333b3de1db4dd55f29a7); // * e ^ -0.5
        }
        // e ^ -0.25
        if ((x & int256(0x0000000000000000000000000000000020000000000000000000000000000000)) != 0) {
            r =
                (r * int256(0x0000000000000000000000000000000070f5a893b608861e1f58934f97aea57d)) /
                int256(0x00000000000000000000000000000000910b022db7ae67ce76b441c27035c6a1); // * e ^ -0.25
        }
        // e ^ -0.125
        if ((x & int256(0x0000000000000000000000000000000010000000000000000000000000000000)) != 0) {
            r =
                (r * int256(0x00000000000000000000000000000000783eafef1c0a8f3978c7f81824d62ebf)) /
                int256(0x0000000000000000000000000000000088415abbe9a76bead8d00cf112e4d4a8); // * e ^ -0.125
        }
    }

    /// @dev Returns the multiplication two numbers, reverting on overflow.
    function _mul(int256 a, int256 b) private pure returns (int256 c) {
        if (a == 0 || b == 0) {
            return 0;
        }
        unchecked {
            c = a * b;
        }
        if (c / a != b || c / b != a) {
            revert("MULTIPLICATION_OVERFLOW_ERROR");
        }
    }

    /// @dev Returns the division of two numbers, reverting on division by zero.
    function _div(int256 a, int256 b) private pure returns (int256 c) {
        if (b == 0) {
            revert("DIVISION_BY_ZERO_ERROR");
        }
        if (a == MIN_FIXED_VAL && b == -1) {
            revert("DIVISION_OVERFLOW_ERROR");
        }
        unchecked {
            c = a / b;
        }
    }
}