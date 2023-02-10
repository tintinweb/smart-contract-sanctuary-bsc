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

pragma solidity 0.8.17;

import "./libs/LibSafeDowncast.sol";
import "./immutable/MixinStorage.sol";
import "./immutable/MixinConstants.sol";
import "./interfaces/IStorageInit.sol";
import "./interfaces/IStakingProxy.sol";

/// #dev The RigoBlock Staking contract.
contract StakingProxy is IStakingProxy, MixinStorage, MixinConstants {
    using LibSafeDowncast for uint256;

    /// @notice Constructor.
    /// @param stakingImplementation Address of the staking contract to delegate calls to.
    /// @param newOwner Address of the staking proxy owner.
    constructor(address stakingImplementation, address newOwner) Authorizable(newOwner) MixinStorage() {
        // Deployer address must be authorized in order to call `init`
        // in the context of deterministic deployment, the deployer factory (msg.sender) must be authorized.
        _addAuthorizedAddress(msg.sender);

        // Attach the staking contract and initialize state
        _attachStakingContract(stakingImplementation);

        // Remove the sender as an authorized address
        _removeAuthorizedAddressAtIndex(msg.sender, 0);
    }

    /* solhint-disable payable-fallback, no-complex-fallback */
    /// @notice Delegates calls to the staking contract, if it is set.
    fallback() external {
        // Sanity check that we have a staking contract to call
        address stakingContract_ = stakingContract;
        require(stakingContract_ != _NIL_ADDRESS, "STAKING_ADDRESS_NULL_ERROR");

        // Call the staking contract with the provided calldata.
        (bool success, bytes memory returnData) = stakingContract_.delegatecall(msg.data);

        // Revert on failure or return on success.
        assembly {
            switch success
            case 0 {
                revert(add(0x20, returnData), mload(returnData))
            }
            default {
                return(add(0x20, returnData), mload(returnData))
            }
        }
    }

    /* solhint-enable payable-fallback, no-complex-fallback */

    /// @inheritdoc IStakingProxy
    function attachStakingContract(address stakingImplementation) external override onlyAuthorized {
        _attachStakingContract(stakingImplementation);
    }

    /// @inheritdoc IStakingProxy
    function detachStakingContract() external override onlyAuthorized {
        stakingContract = _NIL_ADDRESS;
        emit StakingContractDetachedFromProxy();
    }

    /// @inheritdoc IStakingProxy
    function batchExecute(bytes[] calldata data) external returns (bytes[] memory batchReturnData) {
        // Initialize commonly used variables.
        bool success;
        bytes memory returnData;
        uint256 dataLength = data.length;
        batchReturnData = new bytes[](dataLength);
        address staking = stakingContract;

        // Ensure that a staking contract has been attached to the proxy.
        require(staking != _NIL_ADDRESS, "STAKING_ADDRESS_NULL_ERROR");

        // Execute all of the calls encoded in the provided calldata.
        for (uint256 i = 0; i != dataLength; i++) {
            // Call the staking contract with the provided calldata.
            (success, returnData) = staking.delegatecall(data[i]);

            // Revert on failure.
            if (!success) {
                assembly {
                    revert(add(0x20, returnData), mload(returnData))
                }
            }

            // Add the returndata to the batch returndata.
            batchReturnData[i] = returnData;
        }

        return batchReturnData;
    }

    /// @inheritdoc IStakingProxy
    function assertValidStorageParams() public view override {
        // Epoch length must be between 5 and 90 days long
        uint256 _epochDurationInSeconds = epochDurationInSeconds;
        require(
            _epochDurationInSeconds >= 5 days && _epochDurationInSeconds <= 90 days,
            "STAKING_PROXY_INVALID_EPOCH_DURATION_ERROR"
        );

        // Alpha must be 0 < x <= 1
        uint32 _cobbDouglasAlphaDenominator = cobbDouglasAlphaDenominator;
        require(
            cobbDouglasAlphaNumerator <= _cobbDouglasAlphaDenominator && _cobbDouglasAlphaDenominator != 0,
            "STAKING_PROXY_INVALID_COBB_DOUGLAS_ALPHA_ERROR"
        );

        // Weight of delegated stake must be <= 100%
        require(rewardDelegatedStakeWeight <= _PPM_DENOMINATOR, "STAKING_PROXY_INVALID_STAKE_WEIGHT_ERROR");

        // Minimum stake must be > 1
        require(minimumPoolStake >= 2, "STAKING_PROXY_INVALID_MINIMUM_STAKE_ERROR");
    }

    /// @dev Attach a staking contract; future calls will be delegated to the staking contract.
    /// @param stakingImplementation Address of staking contract.
    function _attachStakingContract(address stakingImplementation) internal {
        // Attach the staking contract
        stakingContract = stakingImplementation;
        emit StakingContractAttachedToProxy(stakingImplementation);

        // Call `init()` on the staking contract to initialize storage.
        (bool didInitSucceed, bytes memory initReturnData) = stakingContract.delegatecall(
            abi.encodeWithSelector(IStorageInit.init.selector)
        );

        if (!didInitSucceed) {
            assembly {
                revert(add(initReturnData, 0x20), mload(initReturnData))
            }
        }

        // Assert initialized storage values are valid
        assertValidStorageParams();
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

interface IStorageInit {
    /// @notice Initialize storage owned by this contract.
    function init() external;
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