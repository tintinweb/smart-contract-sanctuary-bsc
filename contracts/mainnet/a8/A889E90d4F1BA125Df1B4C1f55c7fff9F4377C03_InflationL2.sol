// SPDX-License-Identifier: Apache 2.0

/*

 Copyright 2017-2019 RigoBlock, Rigo Investment Sagl, 2020-2022 Rigo Intl.

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
pragma experimental ABIEncoderV2;

import {IInflation} from "../interfaces/IInflation.sol";
import {IRigoToken} from "../interfaces/IRigoToken.sol";
import {IStaking} from "../../staking/interfaces/IStaking.sol";

/// @title Inflation - Allows ProofOfPerformance to mint tokens.
/// @author Gabriele Rigo - <[email protected]>
/// @notice Inflation on L2s is only produced by distributing tokens owned by this contract.
/// @dev excess tokens are held in this contract until fully distributed.
// solhint-disable-next-line
contract InflationL2 is IInflation {
    /// @inheritdoc IInflation
    address public override rigoToken;

    /// @inheritdoc IInflation
    address public override stakingProxy;

    /// @inheritdoc IInflation
    uint48 public override epochLength;

    /// @inheritdoc IInflation
    uint32 public override slot;

    uint32 private constant _ANNUAL_INFLATION_RATE = 2 * 10e4; // 2% annual inflation
    uint32 private constant _PPM_DENOMINATOR = 10e6; // 100% in parts-per-million

    uint48 private _epochEndTime;

    address private _initializer;

    modifier onlyInitializer() {
        require(msg.sender == _initializer, "INFLATIONL2_CALLER_ERROR");
        _;
    }

    modifier onlyStakingProxy() {
        _assertCallerIsStakingProxy();
        _;
    }

    modifier alreadyInitialized() {
        require(rigoToken != address(0) && stakingProxy != address(0), "INFLATIONL2_NOT_INIT_ERROR");
        _;
    }

    constructor(address initializer) {
        _initializer = initializer;
        epochLength = 0;
        slot = 0;
    }

    /*
     * CORE FUNCTIONS
     */
    /// @notice We initialize parameters here instead of in the constructor.
    /// @dev On L2, inflation depends on staking proxy, which depends on inflation.
    /// @dev As deterministic deployment addresses are affected by the constructor, we save params in storage.
    function initParams(address newRigoToken, address newStakingProxy) external onlyInitializer {
        require(rigoToken == address(0) || stakingProxy == address(0), "INFLATION_ALREADY_INIT_ERROR");
        require(newRigoToken != address(0) && newStakingProxy != address(0), "INFLATION_NULL_INPUTS_ERROR");
        rigoToken = newRigoToken;
        stakingProxy = newStakingProxy;
    }

    /// @inheritdoc IInflation
    function mintInflation() external override alreadyInitialized onlyStakingProxy returns (uint256 mintedInflation) {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp >= _epochEndTime, "INFLATION_EPOCH_END_ERROR");
        (uint256 epochDuration, , , , ) = IStaking(stakingProxy).getParams();

        // sanity check for epoch length queried from staking
        if (epochLength != epochDuration) {
            require(epochDuration >= 5 days && epochDuration <= 90 days, "INFLATION_TIME_ANOMALY_ERROR");

            // we update epoch length in storage
            epochLength = uint48(epochDuration);
        }

        uint256 epochInflation = getEpochInflation();

        // we update epoch end time in storage
        // solhint-disable-next-line not-rely-on-time
        _epochEndTime = uint48(block.timestamp + epochLength);

        // we increase slot by 1, should we upgrade inflation, we will have to start from latest slot.
        ++slot;

        uint256 tokenBalance = IRigoToken(rigoToken).balanceOf(address(this));

        // distribute rewards, we skip transfer if null amount
        if (tokenBalance == 0) {
            mintedInflation = 0;
        } else {
            mintedInflation = tokenBalance >= epochInflation ? epochInflation : tokenBalance;
            IRigoToken(rigoToken).transfer(stakingProxy, mintedInflation);
        }

        return mintedInflation;
    }

    /*
     * CONSTANT PUBLIC FUNCTIONS
     */
    /// @inheritdoc IInflation
    function epochEnded() external view override returns (bool) {
        // solhint-disable-next-line not-rely-on-time
        return block.timestamp >= _epochEndTime;
    }

    /// @inheritdoc IInflation
    function getEpochInflation() public view override returns (uint256) {
        // 2% of GRG total supply
        // total supply * annual percentage inflation * time period (1 epoch)
        uint256 grgSupply = IRigoToken(rigoToken).totalSupply();
        return ((_ANNUAL_INFLATION_RATE * epochLength * grgSupply) / _PPM_DENOMINATOR / 365 days);
    }

    /// @inheritdoc IInflation
    function timeUntilNextClaim() external view override returns (uint256) {
        // solhint-disable-next-line not-rely-on-time
        return block.timestamp < _epochEndTime ? _epochEndTime - block.timestamp : 0;
    }

    /*
     * INTERNAL METHODS
     */
    /// @dev Asserts that the caller is the Staking Proxy.
    function _assertCallerIsStakingProxy() private view {
        require(msg.sender == stakingProxy, "CALLER_NOT_STAKING_PROXY_ERROR");
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
/// @author Gabriele Rigo - <[email protected]lock.com>
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