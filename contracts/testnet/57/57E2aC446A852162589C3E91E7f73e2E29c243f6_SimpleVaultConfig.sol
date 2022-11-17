// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract ContextUpgradeSafe is Initializable {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.

  function __Context_init() internal initializer {
    __Context_init_unchained();
  }

  function __Context_init_unchained() internal initializer {}

  function _msgSender() internal view virtual returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }

  uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.24 <0.7.0;

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {
  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(
      initializing || isConstructor() || !initialized,
      "Contract instance has already been initialized"
    );

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly {
      cs := extcodesize(self)
    }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// SPDX-License-Identifier: MIT


pragma solidity 0.6.6;

interface IVaultConfig {
  /// @dev Return minimum BaseToken debt size per position.
  function minDebtSize() external view returns (uint256);

  /// @dev Return the interest rate per second, using 1e18 as denom.
  function getInterestRate(uint256 debt, uint256 floating)
    external
    view
    returns (uint256);

  /// @dev Return the address of wrapped native token.
  function getWrappedNativeAddr() external view returns (address);

  /// @dev Return the address of wNative relayer.
  function getWNativeRelayer() external view returns (address);

  /// @dev Return the address of fair launch contract.
  function getFairLaunchAddr() external view returns (address);

  /// @dev Return the bps rate for reserve pool.
  function getReservePoolBps() external view returns (uint256);

  /// @dev Return the bps rate for Avada Kill caster.
  function getKillBps() external view returns (uint256);

  /// @dev Return if the caller is whitelisted.
  function whitelistedCallers(address caller) external returns (bool);

  /// @dev Return if the caller is whitelisted.
  function whitelistedLiquidators(address caller) external returns (bool);

  /// @dev Return if the given strategy is approved.
  function approvedAddStrategies(address addStrats) external returns (bool);

  /// @dev Return whether the given address is a worker.
  function isWorker(address worker) external view returns (bool);

  /// @dev Return whether the given worker accepts more debt. Revert on non-worker.
  function acceptDebt(address worker) external view returns (bool);

  /// @dev Return the work factor for the worker + BaseToken debt, using 1e4 as denom. Revert on non-worker.
  function workFactor(address worker, uint256 debt)
    external
    view
    returns (uint256);

  /// @dev Return the kill factor for the worker + BaseToken debt, using 1e4 as denom. Revert on non-worker.
  function killFactor(address worker, uint256 debt)
    external
    view
    returns (uint256);

  /// @dev Return the kill factor for the worker + BaseToken debt without checking isStable, using 1e4 as denom. Revert on non-worker.
  function rawKillFactor(address worker, uint256 debt)
    external
    view
    returns (uint256);

  /// @dev Return the portion of reward that will be transferred to treasury account after successfully killing a position.
  function getKillTreasuryBps() external view returns (uint256);

  /// @dev Return the address of treasury account
  function getTreasuryAddr() external view returns (address);

  /// @dev Return if worker is stable
  function isWorkerStable(address worker) external view returns (bool);

  /// @dev Return if reserve that worker is working with is consistent
  function isWorkerReserveConsistent(address worker)
    external
    view
    returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./Context.sol";
import "./Initializable.sol";

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
contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */

  function __Ownable_init() internal initializer {
    __Context_init_unchained();
    __Ownable_init_unchained();
  }

  function __Ownable_init_unchained() internal initializer {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT


pragma solidity 0.6.6;

import "./interface/Ownable.sol";
import "./interface/Initializable.sol";

import "./interface/IVaultConfig.sol";

contract SimpleVaultConfig is IVaultConfig, OwnableUpgradeSafe {
  /// @notice Configuration for each worker.
  struct WorkerConfig {
    bool isWorker;
    bool acceptDebt;
    uint256 workFactor;
    uint256 killFactor;
    bool isStable;
    bool isReserveConsistent;
  }

  /// The minimum BaseToken debt size per position.
  uint256 public override minDebtSize;
  /// The interest rate per second, multiplied by 1e18.
  uint256 public interestRate;
  /// The portion of interests allocated to the reserve pool.
  uint256 public override getReservePoolBps;
  /// The reward for successfully killing a position.
  uint256 public override getKillBps;
  /// Mapping for worker address to its configuration.
  mapping(address => WorkerConfig) public workers;
  /// address for wrapped native eg WBNB, WETH
  address public override getWrappedNativeAddr;
  /// address for wNative relater
  address public override getWNativeRelayer;
  /// address of fairLaunch contract
  address public override getFairLaunchAddr;
  /// list of whitelisted callers
  mapping(address => bool) public override whitelistedCallers;
  /// The portion of reward that will be transferred to treasury account after successfully killing a position.
  uint256 public override getKillTreasuryBps;
  /// address of treasury account
  address public treasury;
  // Mapping of approved add strategies
  mapping(address => bool) public override approvedAddStrategies;
  // list of whitelisted liquidators
  mapping(address => bool) public override whitelistedLiquidators;

  function initialize(
    uint256 _minDebtSize,
    uint256 _interestRate,
    uint256 _reservePoolBps,
    uint256 _killBps,
    address _getWrappedNativeAddr,
    address _getWNativeRelayer,
    address _getFairLaunchAddr,
    uint256 _getKillTreasuryBps,
    address _treasury
  ) external initializer {
    OwnableUpgradeSafe.__Ownable_init();

    setParams(
      _minDebtSize,
      _interestRate,
      _reservePoolBps,
      _killBps,
      _getWrappedNativeAddr,
      _getWNativeRelayer,
      _getFairLaunchAddr,
      _getKillTreasuryBps,
      _treasury
    );
  }

  /// @dev Set all the basic parameters. Must only be called by the owner.
  /// @param _minDebtSize The new minimum debt size value.
  /// @param _interestRate The new interest rate per second value.
  /// @param _reservePoolBps The new interests allocated to the reserve pool value.
  /// @param _killBps The new reward for killing a position value.
  function setParams(
    uint256 _minDebtSize,
    uint256 _interestRate,
    uint256 _reservePoolBps,
    uint256 _killBps,
    address _getWrappedNativeAddr,
    address _getWNativeRelayer,
    address _getFairLaunchAddr,
    uint256 _getKillTreasuryBps,
    address _treasury
  ) public onlyOwner {
    minDebtSize = _minDebtSize;
    interestRate = _interestRate;
    getReservePoolBps = _reservePoolBps;
    getKillBps = _killBps;
    getWrappedNativeAddr = _getWrappedNativeAddr;
    getWNativeRelayer = _getWNativeRelayer;
    getFairLaunchAddr = _getFairLaunchAddr;
    getKillTreasuryBps = _getKillTreasuryBps;
    treasury = _treasury;
  }

  /// @dev Set the configuration for the given worker. Must only be called by the owner.
  /// @param worker The worker address to set configuration.
  /// @param _isWorker Whether the given address is a valid worker.
  /// @param _acceptDebt Whether the worker is accepting new debts.
  /// @param _workFactor The work factor value for this worker.
  /// @param _killFactor The kill factor value for this worker.
  /// @param _isStable Whether the given worker is stable or not.
  function setWorker(
    address worker,
    bool _isWorker,
    bool _acceptDebt,
    uint256 _workFactor,
    uint256 _killFactor,
    bool _isStable,
    bool _isReserveConsistent
  ) public onlyOwner {
    workers[worker] = WorkerConfig({
      isWorker: _isWorker,
      acceptDebt: _acceptDebt,
      workFactor: _workFactor,
      killFactor: _killFactor,
      isStable: _isStable,
      isReserveConsistent: _isReserveConsistent
    });
  }

  /// @dev Set whitelisted callers. Must only be called by the owner.
  function setWhitelistedCallers(address[] calldata callers, bool ok) external onlyOwner {
    for (uint256 idx = 0; idx < callers.length; idx++) {
      whitelistedCallers[callers[idx]] = ok;
    }
  }

  /// @dev Set whitelisted liquidators. Must only be called by the owner.
  function setWhitelistedLiquidators(address[] calldata callers, bool ok) external onlyOwner {
    for (uint256 idx = 0; idx < callers.length; idx++) {
      whitelistedLiquidators[callers[idx]] = ok;
    }
  }

  /// @dev Set approved add strategies. Must only be called by the owner.
  function setApprovedAddStrategy(address[] calldata addStrats, bool ok) external onlyOwner {
    for (uint256 idx = 0; idx < addStrats.length; idx++) {
      approvedAddStrategies[addStrats[idx]] = ok;
    }
  }

  /// @dev Return the interest rate per second, using 1e18 as denom.
  function getInterestRate(
    uint256, /* debt */
    uint256 /* floating */
  ) external view override returns (uint256) {
    return interestRate;
  }

  /// @dev Return whether the given address is a worker.
  function isWorker(address worker) external view override returns (bool) {
    return workers[worker].isWorker;
  }

  /// @dev Return whether the given worker accepts more debt. Revert on non-worker.
  function acceptDebt(address worker) external view override returns (bool) {
    require(workers[worker].isWorker, "SimpleVaultConfig::acceptDebt:: !worker");
    return workers[worker].acceptDebt;
  }

  /// @dev Return the work factor for the worker + BaseToken debt, using 1e4 as denom. Revert on non-worker.
  function workFactor(
    address worker,
    uint256 /* debt */
  ) external view override returns (uint256) {
    require(workers[worker].isWorker, "SimpleVaultConfig::workFactor:: !worker");
    return workers[worker].workFactor;
  }

  /// @dev Return the kill factor for the worker + BaseToken debt, using 1e4 as denom. Revert on non-worker.
  function killFactor(
    address worker,
    uint256 /* debt */
  ) external view override returns (uint256) {
    require(workers[worker].isWorker, "SimpleVaultConfig::killFactor:: !worker");
    return workers[worker].killFactor;
  }

  /// @dev Return the kill factor for the worker + BaseToken debt, using 1e4 as denom.
  function rawKillFactor(
    address worker,
    uint256 /* debt */
  ) external view override returns (uint256) {
    require(workers[worker].isWorker, "SimpleVaultConfig::killFactor:: !worker");
    return workers[worker].killFactor;
  }

  /// @dev Return worker stability
  function isWorkerStable(address worker) external view override returns (bool) {
    require(workers[worker].isWorker, "SimpleVaultConfig::isWorkerStable:: !worker");
    return workers[worker].isStable;
  }

  /// @dev Return if pools is consistent
  function isWorkerReserveConsistent(address worker) external view override returns (bool) {
    return workers[worker].isReserveConsistent;
  }

  /// @dev Return the treasuryAddr
  function getTreasuryAddr() external view override returns (address) {
    return treasury == address(0) ? 0xC44f82b07Ab3E691F826951a6E335E1bC1bB0B51 : treasury;
  }
}