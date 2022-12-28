// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

/**
 * @dev Ownable extension that requires a two-step process of setting the pending owner and the owner accepting it.
 * @notice Existing OwnableUpgradeable contracts cannot be upgraded due to the extra storage variable
 * that will shift the other.
 */
abstract contract SafeOwnableUpgradeable is OwnableUpgradeable {
  /**
   * @notice Pending owner of this contract
   */
  address public pendingOwner;

  function __SafeOwnable_init() internal onlyInitializing {
    __Ownable_init();
  }

  struct AddressSlot {
    address value;
  }

  modifier onlyOwnerOrAdmin() {
    bool isOwner = owner() == _msgSender();
    if (!isOwner) {
      bytes32 _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
      AddressSlot storage adminSlot;
      assembly {
        adminSlot.slot := _ADMIN_SLOT
      }
      address admin = adminSlot.value;
      bool isAdmin = admin == _msgSender();
      require(isAdmin, "Ownable: caller is neither the owner nor the admin");
    }
    _;
  }

  /**
   * @notice Emitted when pendingOwner is changed
   */
  event NewPendingOwner(address oldPendingOwner, address newPendingOwner);

  /**
   * @notice Emitted when pendingOwner is accepted, which means owner is updated
   */
  event NewOwner(address oldOwner, address newOwner);

  /**
   * @notice Begins transfer of owner rights. The newPendingOwner must call `_acceptOwner` to finalize the transfer.
   * @dev Owner function to begin change of owner. The newPendingOwner must call `_acceptOwner` to finalize the transfer.
   * @param newPendingOwner New pending owner.
   */
  function _setPendingOwner(address newPendingOwner) public onlyOwner {
    // Save current value, if any, for inclusion in log
    address oldPendingOwner = pendingOwner;

    // Store pendingOwner with value newPendingOwner
    pendingOwner = newPendingOwner;

    // Emit NewPendingOwner(oldPendingOwner, newPendingOwner)
    emit NewPendingOwner(oldPendingOwner, newPendingOwner);
  }

  /**
   * @notice Accepts transfer of owner rights. msg.sender must be pendingOwner
   * @dev Owner function for pending owner to accept role and update owner
   */
  function _acceptOwner() public {
    // Check caller is pendingOwner and pendingOwner ≠ address(0)
    require(msg.sender == pendingOwner, "not the pending owner");

    // Save current values for inclusion in log
    address oldOwner = owner();
    address oldPendingOwner = pendingOwner;

    // Store owner with value pendingOwner
    _transferOwnership(pendingOwner);

    // Clear the pending value
    pendingOwner = address(0);

    emit NewOwner(oldOwner, pendingOwner);
    emit NewPendingOwner(oldPendingOwner, pendingOwner);
  }

  function renounceOwnership() public override onlyOwner {
    // do not remove this overriding fn
    revert("not used anymore");
  }

  function transferOwnership(address newOwner) public override onlyOwner {
    // do not remove this overriding fn
    revert("not used anymore");
  }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import { ERC20 } from "solmate/tokens/ERC20.sol";

interface IMidasFlywheel {
  function isRewardsDistributor() external returns (bool);

  function isFlywheel() external returns (bool);

  function flywheelPreSupplierAction(address market, address supplier) external;

  function flywheelPreBorrowerAction(address market, address borrower) external;

  function flywheelPreTransferAction(
    address market,
    address src,
    address dst
  ) external;

  function compAccrued(address user) external view returns (uint256);

  function addMarketForRewards(ERC20 strategy) external;

  function marketState(ERC20 strategy) external view returns (uint224 index, uint32 lastUpdatedTimestamp);
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import { ERC20 } from "solmate/tokens/ERC20.sol";
import { MidasFlywheelCore } from "./MidasFlywheelCore.sol";
import "./IMidasFlywheel.sol";

contract MidasFlywheel is MidasFlywheelCore, IMidasFlywheel {
  bool public constant isRewardsDistributor = true;

  bool public constant isFlywheel = true;

  function flywheelPreSupplierAction(address market, address supplier) external {
    accrue(ERC20(market), supplier);
  }

  function flywheelPreBorrowerAction(address market, address borrower) external {}

  function flywheelPreTransferAction(
    address market,
    address src,
    address dst
  ) external {
    accrue(ERC20(market), src, dst);
  }

  function compAccrued(address user) external view returns (uint256) {
    return rewardsAccrued[user];
  }

  function addMarketForRewards(ERC20 strategy) external onlyOwner {
    _addStrategyForRewards(strategy);
  }

  function marketState(ERC20 strategy) external view returns (uint224, uint32) {
    return (strategyState[strategy].index, strategyState[strategy].lastUpdatedTimestamp);
  }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import { ERC20 } from "solmate/tokens/ERC20.sol";
import { SafeTransferLib } from "solmate/utils/SafeTransferLib.sol";
import { SafeCastLib } from "solmate/utils/SafeCastLib.sol";

import { IFlywheelRewards } from "flywheel/interfaces/IFlywheelRewards.sol";
import { IFlywheelBooster } from "flywheel/interfaces/IFlywheelBooster.sol";

import { SafeOwnableUpgradeable } from "../../../midas/SafeOwnableUpgradeable.sol";

contract MidasFlywheelCore is SafeOwnableUpgradeable {
  using SafeTransferLib for ERC20;
  using SafeCastLib for uint256;

  /// @notice How much rewardsToken will be send to treasury
  uint256 public performanceFee;

  /// @notice Address that gets rewardsToken accrued by performanceFee
  address public feeRecipient;

  /// @notice The token to reward
  ERC20 public rewardToken;

  /// @notice append-only list of strategies added
  ERC20[] public allStrategies;

  /// @notice the rewards contract for managing streams
  IFlywheelRewards public flywheelRewards;

  /// @notice optional booster module for calculating virtual balances on strategies
  IFlywheelBooster public flywheelBooster;

  /// @notice The accrued but not yet transferred rewards for each user
  mapping(address => uint256) public rewardsAccrued;

  /// @notice The strategy index and last updated per strategy
  mapping(ERC20 => RewardsState) public strategyState;

  /// @notice user index per strategy
  mapping(ERC20 => mapping(address => uint224)) public userIndex;

  function initialize(
    ERC20 _rewardToken,
    IFlywheelRewards _flywheelRewards,
    IFlywheelBooster _flywheelBooster,
    address _owner
  ) public initializer {
    __SafeOwnable_init();

    rewardToken = _rewardToken;
    flywheelRewards = _flywheelRewards;
    flywheelBooster = _flywheelBooster;

    _transferOwnership(_owner);

    performanceFee = 10e16; // 10%
    feeRecipient = _owner;
  }

  /*///////////////////////////////////////////////////////////////
                        ACCRUE/CLAIM LOGIC
    //////////////////////////////////////////////////////////////*/

  /** 
      @notice Emitted when a user's rewards accrue to a given strategy.
      @param strategy the updated rewards strategy
      @param user the user of the rewards
      @param rewardsDelta how many new rewards accrued to the user
      @param rewardsIndex the market index for rewards per token accrued
    */
  event AccrueRewards(ERC20 indexed strategy, address indexed user, uint256 rewardsDelta, uint256 rewardsIndex);

  /** 
      @notice Emitted when a user claims accrued rewards.
      @param user the user of the rewards
      @param amount the amount of rewards claimed
    */
  event ClaimRewards(address indexed user, uint256 amount);

  /** 
      @notice accrue rewards for a single user on a strategy
      @param strategy the strategy to accrue a user's rewards on
      @param user the user to be accrued
      @return the cumulative amount of rewards accrued to user (including prior)
    */
  function accrue(ERC20 strategy, address user) public returns (uint256) {
    RewardsState memory state = strategyState[strategy];

    if (state.index == 0) return 0;

    state = accrueStrategy(strategy, state);
    return accrueUser(strategy, user, state);
  }

  /** 
      @notice accrue rewards for a two users on a strategy
      @param strategy the strategy to accrue a user's rewards on
      @param user the first user to be accrued
      @param user the second user to be accrued
      @return the cumulative amount of rewards accrued to the first user (including prior)
      @return the cumulative amount of rewards accrued to the second user (including prior)
    */
  function accrue(
    ERC20 strategy,
    address user,
    address secondUser
  ) public returns (uint256, uint256) {
    RewardsState memory state = strategyState[strategy];

    if (state.index == 0) return (0, 0);

    state = accrueStrategy(strategy, state);
    return (accrueUser(strategy, user, state), accrueUser(strategy, secondUser, state));
  }

  /** 
      @notice claim rewards for a given user
      @param user the user claiming rewards
      @dev this function is public, and all rewards transfer to the user
    */
  function claimRewards(address user) external {
    uint256 accrued = rewardsAccrued[user];

    if (accrued != 0) {
      rewardsAccrued[user] = 0;

      rewardToken.safeTransferFrom(address(flywheelRewards), user, accrued);

      emit ClaimRewards(user, accrued);
    }
  }

  /*///////////////////////////////////////////////////////////////
                          ADMIN LOGIC
    //////////////////////////////////////////////////////////////*/

  /** 
      @notice Emitted when a new strategy is added to flywheel by the admin
      @param newStrategy the new added strategy
    */
  event AddStrategy(address indexed newStrategy);

  /// @notice initialize a new strategy
  function addStrategyForRewards(ERC20 strategy) external onlyOwner {
    _addStrategyForRewards(strategy);
  }

  function _addStrategyForRewards(ERC20 strategy) internal {
    require(strategyState[strategy].index == 0, "strategy");
    strategyState[strategy] = RewardsState({
      index: (10**rewardToken.decimals()).safeCastTo224(),
      lastUpdatedTimestamp: block.timestamp.safeCastTo32()
    });

    allStrategies.push(strategy);
    emit AddStrategy(address(strategy));
  }

  function getAllStrategies() external view returns (ERC20[] memory) {
    return allStrategies;
  }

  /** 
      @notice Emitted when the rewards module changes
      @param newFlywheelRewards the new rewards module
    */
  event FlywheelRewardsUpdate(address indexed newFlywheelRewards);

  /// @notice swap out the flywheel rewards contract
  function setFlywheelRewards(IFlywheelRewards newFlywheelRewards) external onlyOwner {
    if (address(flywheelRewards) != address(0)) {
      uint256 oldRewardBalance = rewardToken.balanceOf(address(flywheelRewards));
      if (oldRewardBalance > 0) {
        rewardToken.safeTransferFrom(address(flywheelRewards), address(newFlywheelRewards), oldRewardBalance);
      }
    }

    flywheelRewards = newFlywheelRewards;

    emit FlywheelRewardsUpdate(address(newFlywheelRewards));
  }

  /** 
      @notice Emitted when the booster module changes
      @param newBooster the new booster module
    */
  event FlywheelBoosterUpdate(address indexed newBooster);

  /// @notice swap out the flywheel booster contract
  function setBooster(IFlywheelBooster newBooster) external onlyOwner {
    flywheelBooster = newBooster;

    emit FlywheelBoosterUpdate(address(newBooster));
  }

  event UpdatedFeeSettings(
    uint256 oldPerformanceFee,
    uint256 newPerformanceFee,
    address oldFeeRecipient,
    address newFeeRecipient
  );

  /**
   * @notice Update performanceFee and/or feeRecipient
   * @dev Claim rewards first from the previous feeRecipient before changing it
   */
  function updateFeeSettings(uint256 _performanceFee, address _feeRecipient) external onlyOwner {
    _updateFeeSettings(_performanceFee, _feeRecipient);
  }

  function _updateFeeSettings(uint256 _performanceFee, address _feeRecipient) internal {
    emit UpdatedFeeSettings(performanceFee, _performanceFee, feeRecipient, _feeRecipient);

    if (feeRecipient != _feeRecipient) {
      rewardsAccrued[_feeRecipient] += rewardsAccrued[feeRecipient];
      rewardsAccrued[feeRecipient] = 0;
    }
    performanceFee = _performanceFee;
    feeRecipient = _feeRecipient;
  }

  /*///////////////////////////////////////////////////////////////
                    INTERNAL ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

  struct RewardsState {
    /// @notice The strategy's last updated index
    uint224 index;
    /// @notice The timestamp the index was last updated at
    uint32 lastUpdatedTimestamp;
  }

  /// @notice accumulate global rewards on a strategy
  function accrueStrategy(ERC20 strategy, RewardsState memory state)
    private
    returns (RewardsState memory rewardsState)
  {
    // calculate accrued rewards through module
    uint256 strategyRewardsAccrued = flywheelRewards.getAccruedRewards(strategy, state.lastUpdatedTimestamp);

    rewardsState = state;

    if (strategyRewardsAccrued > 0) {
      // use the booster or token supply to calculate reward index denominator
      uint256 supplyTokens = address(flywheelBooster) != address(0)
        ? flywheelBooster.boostedTotalSupply(strategy)
        : strategy.totalSupply();

      // 100% = 100e16
      uint256 accruedFees = (strategyRewardsAccrued * performanceFee) / uint224(100e16);

      rewardsAccrued[feeRecipient] += accruedFees;
      strategyRewardsAccrued -= accruedFees;

      uint224 deltaIndex;

      if (supplyTokens != 0)
        deltaIndex = ((strategyRewardsAccrued * (10**strategy.decimals())) / supplyTokens).safeCastTo224();

      // accumulate rewards per token onto the index, multiplied by fixed-point factor
      rewardsState = RewardsState({
        index: state.index + deltaIndex,
        lastUpdatedTimestamp: block.timestamp.safeCastTo32()
      });
      strategyState[strategy] = rewardsState;
    }
  }

  /// @notice accumulate rewards on a strategy for a specific user
  function accrueUser(
    ERC20 strategy,
    address user,
    RewardsState memory state
  ) private returns (uint256) {
    // load indices
    uint224 strategyIndex = state.index;
    uint224 supplierIndex = userIndex[strategy][user];

    // sync user index to global
    userIndex[strategy][user] = strategyIndex;

    // if user hasn't yet accrued rewards, grant them interest from the strategy beginning if they have a balance
    // zero balances will have no effect other than syncing to global index
    if (supplierIndex == 0) {
      supplierIndex = (10**rewardToken.decimals()).safeCastTo224();
    }

    uint224 deltaIndex = strategyIndex - supplierIndex;
    // use the booster or token balance to calculate reward balance multiplier
    uint256 supplierTokens = address(flywheelBooster) != address(0)
      ? flywheelBooster.boostedBalanceOf(strategy, user)
      : strategy.balanceOf(user);

    // accumulate rewards by multiplying user tokens by rewardsPerToken index and adding on unclaimed
    uint256 supplierDelta = (deltaIndex * supplierTokens) / (10**strategy.decimals());
    uint256 supplierAccrued = rewardsAccrued[user] + supplierDelta;

    rewardsAccrued[user] = supplierAccrued;

    emit AccrueRewards(strategy, user, supplierDelta, strategyIndex);

    return supplierAccrued;
  }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {Auth, Authority} from "solmate/auth/Auth.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {SafeCastLib} from "solmate/utils/SafeCastLib.sol";

import {IFlywheelRewards} from "./interfaces/IFlywheelRewards.sol";
import {IFlywheelBooster} from "./interfaces/IFlywheelBooster.sol";

/**
 @title Flywheel Core Incentives Manager
 @notice Flywheel is a general framework for managing token incentives.
         It takes reward streams to various *strategies* such as staking LP tokens and divides them among *users* of those strategies.

         The Core contract maintaings three important pieces of state:
         * the rewards index which determines how many rewards are owed per token per strategy. User indexes track how far behind the strategy they are to lazily calculate all catch-up rewards.
         * the accrued (unclaimed) rewards per user.
         * references to the booster and rewards module described below.

         Core does not manage any tokens directly. The rewards module maintains token balances, and approves core to pull transfer them to users when they claim.

         SECURITY NOTE: For maximum accuracy and to avoid exploits, rewards accrual should be notified atomically through the accrue hook. 
         Accrue should be called any time tokens are transferred, minted, or burned.
 */
contract FlywheelCore is Auth {
    using SafeTransferLib for ERC20;
    using SafeCastLib for uint256;

    /// @notice The token to reward
    ERC20 public immutable rewardToken;

    /// @notice append-only list of strategies added
    ERC20[] public allStrategies;

    /// @notice the rewards contract for managing streams
    IFlywheelRewards public flywheelRewards;

    /// @notice optional booster module for calculating virtual balances on strategies
    IFlywheelBooster public flywheelBooster;

    constructor(
        ERC20 _rewardToken,
        IFlywheelRewards _flywheelRewards,
        IFlywheelBooster _flywheelBooster,
        address _owner,
        Authority _authority
    ) Auth(_owner, _authority) {
        rewardToken = _rewardToken;
        flywheelRewards = _flywheelRewards;
        flywheelBooster = _flywheelBooster;
    }

    /*///////////////////////////////////////////////////////////////
                        ACCRUE/CLAIM LOGIC
    //////////////////////////////////////////////////////////////*/

    /** 
      @notice Emitted when a user's rewards accrue to a given strategy.
      @param strategy the updated rewards strategy
      @param user the user of the rewards
      @param rewardsDelta how many new rewards accrued to the user
      @param rewardsIndex the market index for rewards per token accrued
    */
    event AccrueRewards(ERC20 indexed strategy, address indexed user, uint256 rewardsDelta, uint256 rewardsIndex);

    /** 
      @notice Emitted when a user claims accrued rewards.
      @param user the user of the rewards
      @param amount the amount of rewards claimed
    */
    event ClaimRewards(address indexed user, uint256 amount);

    /// @notice The accrued but not yet transferred rewards for each user
    mapping(address => uint256) public rewardsAccrued;

    /** 
      @notice accrue rewards for a single user on a strategy
      @param strategy the strategy to accrue a user's rewards on
      @param user the user to be accrued
      @return the cumulative amount of rewards accrued to user (including prior)
    */
    function accrue(ERC20 strategy, address user) public returns (uint256) {
        RewardsState memory state = strategyState[strategy];

        if (state.index == 0) return 0;

        state = accrueStrategy(strategy, state);
        return accrueUser(strategy, user, state);
    }

    /** 
      @notice accrue rewards for a two users on a strategy
      @param strategy the strategy to accrue a user's rewards on
      @param user the first user to be accrued
      @param user the second user to be accrued
      @return the cumulative amount of rewards accrued to the first user (including prior)
      @return the cumulative amount of rewards accrued to the second user (including prior)
    */
    function accrue(
        ERC20 strategy,
        address user,
        address secondUser
    ) public returns (uint256, uint256) {
        RewardsState memory state = strategyState[strategy];

        if (state.index == 0) return (0, 0);

        state = accrueStrategy(strategy, state);
        return (accrueUser(strategy, user, state), accrueUser(strategy, secondUser, state));
    }

    /** 
      @notice claim rewards for a given user
      @param user the user claiming rewards
      @dev this function is public, and all rewards transfer to the user
    */
    function claimRewards(address user) external {
        uint256 accrued = rewardsAccrued[user];

        if (accrued != 0) {
            rewardsAccrued[user] = 0;

            rewardToken.safeTransferFrom(address(flywheelRewards), user, accrued);

            emit ClaimRewards(user, accrued);
        }
    }

    /*///////////////////////////////////////////////////////////////
                          ADMIN LOGIC
    //////////////////////////////////////////////////////////////*/

    /** 
      @notice Emitted when a new strategy is added to flywheel by the admin
      @param newStrategy the new added strategy
    */
    event AddStrategy(address indexed newStrategy);

    /// @notice initialize a new strategy
    function addStrategyForRewards(ERC20 strategy) external requiresAuth {
        _addStrategyForRewards(strategy);
    }

    function _addStrategyForRewards(ERC20 strategy) internal {
        require(strategyState[strategy].index == 0, "strategy");
        strategyState[strategy] = RewardsState({index: ONE, lastUpdatedTimestamp: block.timestamp.safeCastTo32()});

        allStrategies.push(strategy);
        emit AddStrategy(address(strategy));
    }

    function getAllStrategies() external view returns (ERC20[] memory) {
        return allStrategies;
    }

    /** 
      @notice Emitted when the rewards module changes
      @param newFlywheelRewards the new rewards module
    */
    event FlywheelRewardsUpdate(address indexed newFlywheelRewards);

    /// @notice swap out the flywheel rewards contract
    function setFlywheelRewards(IFlywheelRewards newFlywheelRewards) external requiresAuth {
        uint256 oldRewardBalance = rewardToken.balanceOf(address(flywheelRewards));
        if (oldRewardBalance > 0) {
            rewardToken.safeTransferFrom(address(flywheelRewards), address(newFlywheelRewards), oldRewardBalance);
        }

        flywheelRewards = newFlywheelRewards;

        emit FlywheelRewardsUpdate(address(newFlywheelRewards));
    }

    /** 
      @notice Emitted when the booster module changes
      @param newBooster the new booster module
    */
    event FlywheelBoosterUpdate(address indexed newBooster);

    /// @notice swap out the flywheel booster contract
    function setBooster(IFlywheelBooster newBooster) external requiresAuth {
        flywheelBooster = newBooster;

        emit FlywheelBoosterUpdate(address(newBooster));
    }

    /*///////////////////////////////////////////////////////////////
                    INTERNAL ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    struct RewardsState {
        /// @notice The strategy's last updated index
        uint224 index;
        /// @notice The timestamp the index was last updated at
        uint32 lastUpdatedTimestamp;
    }

    /// @notice the fixed point factor of flywheel
    uint224 public constant ONE = 1e18;

    /// @notice The strategy index and last updated per strategy
    mapping(ERC20 => RewardsState) public strategyState;

    /// @notice user index per strategy
    mapping(ERC20 => mapping(address => uint224)) public userIndex;

    /// @notice accumulate global rewards on a strategy
    function accrueStrategy(ERC20 strategy, RewardsState memory state)
        private
        returns (RewardsState memory rewardsState)
    {
        // calculate accrued rewards through module
        uint256 strategyRewardsAccrued = flywheelRewards.getAccruedRewards(strategy, state.lastUpdatedTimestamp);

        rewardsState = state;
        if (strategyRewardsAccrued > 0) {
            // use the booster or token supply to calculate reward index denominator
            uint256 supplyTokens = address(flywheelBooster) != address(0)
                ? flywheelBooster.boostedTotalSupply(strategy)
                : strategy.totalSupply();

            uint224 deltaIndex;

            if (supplyTokens != 0) deltaIndex = ((strategyRewardsAccrued * ONE) / supplyTokens).safeCastTo224();

            // accumulate rewards per token onto the index, multiplied by fixed-point factor
            rewardsState = RewardsState({
                index: state.index + deltaIndex,
                lastUpdatedTimestamp: block.timestamp.safeCastTo32()
            });
            strategyState[strategy] = rewardsState;
        }
    }

    /// @notice accumulate rewards on a strategy for a specific user
    function accrueUser(
        ERC20 strategy,
        address user,
        RewardsState memory state
    ) private returns (uint256) {
        // load indices
        uint224 strategyIndex = state.index;
        uint224 supplierIndex = userIndex[strategy][user];

        // sync user index to global
        userIndex[strategy][user] = strategyIndex;

        // if user hasn't yet accrued rewards, grant them interest from the strategy beginning if they have a balance
        // zero balances will have no effect other than syncing to global index
        if (supplierIndex == 0) {
            supplierIndex = ONE;
        }

        uint224 deltaIndex = strategyIndex - supplierIndex;
        // use the booster or token balance to calculate reward balance multiplier
        uint256 supplierTokens = address(flywheelBooster) != address(0)
            ? flywheelBooster.boostedBalanceOf(strategy, user)
            : strategy.balanceOf(user);

        // accumulate rewards by multiplying user tokens by rewardsPerToken index and adding on unclaimed
        uint256 supplierDelta = (supplierTokens * deltaIndex) / ONE;
        uint256 supplierAccrued = rewardsAccrued[user] + supplierDelta;

        rewardsAccrued[user] = supplierAccrued;

        emit AccrueRewards(strategy, user, supplierDelta, strategyIndex);

        return supplierAccrued;
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {ERC20} from "solmate/tokens/ERC20.sol";

/**
 @title Balance Booster Module for Flywheel
 @notice Flywheel is a general framework for managing token incentives.
         It takes reward streams to various *strategies* such as staking LP tokens and divides them among *users* of those strategies.

         The Booster module is an optional module for virtually boosting or otherwise transforming user balances. 
         If a booster is not configured, the strategies ERC-20 balanceOf/totalSupply will be used instead.
        
         Boosting logic can be associated with referrals, vote-escrow, or other strategies.

         SECURITY NOTE: similar to how Core needs to be notified any time the strategy user composition changes, the booster would need to be notified of any conditions which change the boosted balances atomically.
         This prevents gaming of the reward calculation function by using manipulated balances when accruing.
*/
interface IFlywheelBooster {
    /**
      @notice calculate the boosted supply of a strategy.
      @param strategy the strategy to calculate boosted supply of
      @return the boosted supply
     */
    function boostedTotalSupply(ERC20 strategy) external view returns (uint256);

    /**
      @notice calculate the boosted balance of a user in a given strategy.
      @param strategy the strategy to calculate boosted balance of
      @param user the user to calculate boosted balance of
      @return the boosted balance
     */
    function boostedBalanceOf(ERC20 strategy, address user) external view returns (uint256);
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {FlywheelCore} from "../FlywheelCore.sol";

/**
 @title Rewards Module for Flywheel
 @notice Flywheel is a general framework for managing token incentives.
         It takes reward streams to various *strategies* such as staking LP tokens and divides them among *users* of those strategies.

         The Rewards module is responsible for:
         * determining the ongoing reward amounts to entire strategies (core handles the logic for dividing among users)
         * actually holding rewards that are yet to be claimed

         The reward stream can follow arbitrary logic as long as the amount of rewards passed to flywheel core has been sent to this contract.

         Different module strategies include:
         * a static reward rate per second
         * a decaying reward rate
         * a dynamic just-in-time reward stream
         * liquid governance reward delegation (Curve Gauge style)

         SECURITY NOTE: The rewards strategy should be smooth and continuous, to prevent gaming the reward distribution by frontrunning.
 */
interface IFlywheelRewards {
    /**
     @notice calculate the rewards amount accrued to a strategy since the last update.
     @param strategy the strategy to accrue rewards for.
     @param lastUpdatedTimestamp the last time rewards were accrued for the strategy.
     @return rewards the amount of rewards accrued to the market
    */
    function getAccruedRewards(ERC20 strategy, uint32 lastUpdatedTimestamp) external returns (uint256 rewards);

    /// @notice return the flywheel core address
    function flywheel() external view returns (FlywheelCore);

    /// @notice return the reward token associated with flywheel core.
    function rewardToken() external view returns (ERC20);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Provides a flexible and updatable auth pattern which is completely separate from application logic.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Auth.sol)
/// @author Modified from Dappsys (https://github.com/dapphub/ds-auth/blob/master/src/auth.sol)
abstract contract Auth {
    event OwnerUpdated(address indexed user, address indexed newOwner);

    event AuthorityUpdated(address indexed user, Authority indexed newAuthority);

    address public owner;

    Authority public authority;

    constructor(address _owner, Authority _authority) {
        owner = _owner;
        authority = _authority;

        emit OwnerUpdated(msg.sender, _owner);
        emit AuthorityUpdated(msg.sender, _authority);
    }

    modifier requiresAuth() virtual {
        require(isAuthorized(msg.sender, msg.sig), "UNAUTHORIZED");

        _;
    }

    function isAuthorized(address user, bytes4 functionSig) internal view virtual returns (bool) {
        Authority auth = authority; // Memoizing authority saves us a warm SLOAD, around 100 gas.

        // Checking if the caller is the owner only after calling the authority saves gas in most cases, but be
        // aware that this makes protected functions uncallable even to the owner if the authority is out of order.
        return (address(auth) != address(0) && auth.canCall(user, address(this), functionSig)) || user == owner;
    }

    function setAuthority(Authority newAuthority) public virtual {
        // We check if the caller is the owner first because we want to ensure they can
        // always swap out the authority even if it's reverting or using up a lot of gas.
        require(msg.sender == owner || authority.canCall(msg.sender, address(this), msg.sig));

        authority = newAuthority;

        emit AuthorityUpdated(msg.sender, newAuthority);
    }

    function setOwner(address newOwner) public virtual requiresAuth {
        owner = newOwner;

        emit OwnerUpdated(msg.sender, newOwner);
    }
}

/// @notice A generic interface for a contract which provides authorization data to an Auth instance.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Auth.sol)
/// @author Modified from Dappsys (https://github.com/dapphub/ds-auth/blob/master/src/auth.sol)
interface Authority {
    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) external view returns (bool);
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Safe unsigned integer casting library that reverts on overflow.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeCastLib.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeCast.sol)
library SafeCastLib {
    function safeCastTo248(uint256 x) internal pure returns (uint248 y) {
        require(x < 1 << 248);

        y = uint248(x);
    }

    function safeCastTo224(uint256 x) internal pure returns (uint224 y) {
        require(x < 1 << 224);

        y = uint224(x);
    }

    function safeCastTo192(uint256 x) internal pure returns (uint192 y) {
        require(x < 1 << 192);

        y = uint192(x);
    }

    function safeCastTo160(uint256 x) internal pure returns (uint160 y) {
        require(x < 1 << 160);

        y = uint160(x);
    }

    function safeCastTo128(uint256 x) internal pure returns (uint128 y) {
        require(x < 1 << 128);

        y = uint128(x);
    }

    function safeCastTo96(uint256 x) internal pure returns (uint96 y) {
        require(x < 1 << 96);

        y = uint96(x);
    }

    function safeCastTo64(uint256 x) internal pure returns (uint64 y) {
        require(x < 1 << 64);

        y = uint64(x);
    }

    function safeCastTo32(uint256 x) internal pure returns (uint32 y) {
        require(x < 1 << 32);

        y = uint32(x);
    }

    function safeCastTo24(uint256 x) internal pure returns (uint24 y) {
        require(x < 1 << 24);

        y = uint24(x);
    }

    function safeCastTo16(uint256 x) internal pure returns (uint16 y) {
        require(x < 1 << 16);

        y = uint16(x);
    }

    function safeCastTo8(uint256 x) internal pure returns (uint8 y) {
        require(x < 1 << 8);

        y = uint8(x);
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../tokens/ERC20.sol";

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), from) // Append the "from" argument.
            mstore(add(freeMemoryPointer, 36), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}