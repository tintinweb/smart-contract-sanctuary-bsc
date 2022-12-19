// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { Pausable } from "@openzeppelin/contracts/security/Pausable.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import { AutomateBase } from "./AutomateBase.sol";
import { ConfirmedOwner } from "./ConfirmedOwner.sol";
import { IReceiver } from "./interfaces/IReceiver.sol";
import { IAggregatorV3 } from "./interfaces/IAggregatorV3.sol";
import { IVersion } from "./interfaces/IVersion.sol";
import { IAutomateCompatible } from "./interfaces/IAutomateCompatible.sol";
import { Config, State, IAutomateRegistryExecutable } from "./interfaces/IAutomateRegistry.sol";

/**
 * @notice Registry for adding work for Chainlink Automates to perform on client
 * contracts. Clients must support the Task interface.
 */
contract AutomateRegistry is
  IVersion,
  IReceiver,
  IAutomateRegistryExecutable,
  ConfirmedOwner,
  AutomateBase,
  ReentrancyGuard,
  Pausable
{
  using Address for address;
  using EnumerableSet for EnumerableSet.UintSet;

  address private constant ZERO_ADDRESS = address(0);
  address private constant IGNORE_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
  bytes4 private constant CHECK_SELECTOR = IAutomateCompatible.checkTask.selector;
  bytes4 private constant PERFORM_SELECTOR = IAutomateCompatible.performTask.selector;
  uint256 private constant PERFORM_GAS_MIN = 2_300;
  uint256 private constant CANCELATION_DELAY = 50;
  uint256 private constant PERFORM_GAS_CUSHION = 5_000;
  uint256 private constant REGISTRY_GAS_OVERHEAD = 80_000;
  uint256 private constant PPB_BASE = 1_000_000_000;
  uint64 private constant UINT64_MAX = 2**64 - 1;

  address[] private _automateList;
  EnumerableSet.UintSet private _taskIDs;
  mapping(uint256 => Task) private _task;
  mapping(address => AutomateInfo) private _automateInfo;
  mapping(address => address) private _proposedPayee;
  mapping(uint256 => bytes) private _checkData;
  Storage private _storage;
  uint256 private _defaultGasPrice; // not in config object for gas savings
  uint256 private _ownerBNBBalance;
  uint256 private _expectedBNBBalance;
  address private _registrar;

  mapping(address => uint256) private _userBalance;
  mapping(address => EnumerableSet.UintSet) private _userTasks;

  IAggregatorV3 public immutable FAST_GAS_FEED;

  string public constant override version = "AutomateRegistry 1.0.0";

  error CannotCancel();
  error TaskNotActive();
  error TaskNotCanceled();
  error TaskNotNeeded();
  error NotAContract();
  error OnlyActiveAutomates();
  error InsufficientFunds();
  error AutomatesMustTakeTurns();
  error ParameterLengthError();
  error OnlyOwnerOrAdmin();
  error InvalidPayee();
  error DuplicateEntry();
  error ValueNotChanged();
  error IndexOutOfRange();
  error ArrayHasNoEntries();
  error GasLimitOutsideRange();
  error OnlyByPayee();
  error OnlyByProposedPayee();
  error GasLimitCanOnlyIncrease();
  error OnlyByAdmin();
  error OnlyByOwnerOrregistrar();
  error InvalidRecipient();
  error InvalidDataLength();
  error TargetCheckReverted(bytes reason);
  error TaskPaused();

  /**
   * @notice storage of the registry, contains a mix of config and state data
   */
  struct Storage {
    uint32 paymentFee;
    uint32 flatFee;
    uint24 blockCountPerAutomate; 
    uint32 gasLimit;
    uint24 lastFeedSecondsAmt;
    uint16 gasMultiplier;
    uint32 maxGas;
    uint32 nonce;
    uint256 minTaskSpend;
  }

  struct Task {
    uint256 balance;
    address lastAutomate;
    uint32 executeGas;
    uint64 maxValidBlocknumber;
    uint256 amountSpent;
    address target;
    address admin;
    bool isPaused;
    uint256 startTime;
  }

  struct AutomateInfo {
    address payee;
    uint256 balance;
    bool active;
  }

  struct PerformParams {
    address from;
    uint256 id;
    bytes performData;
    uint256 maxNativePayment;
    uint256 gasLimit;
    uint256 adjustedGasWei;
  }

  event TaskRegistered(uint256 indexed id, uint32 executeGas, address admin);
  event TaskPerformed(
    uint256 indexed id,
    bool indexed success,
    address indexed from,
    uint256 payment,
    bytes performData
  );
  event TaskCanceled(uint256 indexed id, uint64 indexed atBlockHeight);
  event FundsAdded(uint256 indexed id, address indexed from, uint256 amount);
  event FundsAddedToUser(address indexed user, address indexed from, uint256 amount);
  event FundsWithdrawn(uint256 indexed id, uint256 amount, address to);
  event FundsWithdrawnForUser(address indexed user, uint256 amount, address to);
  event OwnerFundsWithdrawn(uint256 amount);
  event TaskMigrated(uint256 indexed id, uint256 remainingBalance, address destination);
  event TaskReceived(uint256 indexed id, uint256 startingBalance, address importedFrom);
  event ConfigSet(Config config);
  event AutomatesUpdated(address[] automates, address[] payees);
  event PaymentWithdrawn(
    address indexed automate,
    uint256 indexed amount,
    address indexed to,
    address payee
  );
  event PayeeshipTransferRequested(
    address indexed automate,
    address indexed from,
    address indexed to
  );
  event PayeeshipTransferred(address indexed automate, address indexed from, address indexed to);
  event TaskGasLimitSet(uint256 indexed id, uint256 gasLimit);

  /**
   * @param fastGasFeed address of the Fast Gas price feed
   * @param config registry config settings
   */
  constructor(address fastGasFeed, Config memory config) ConfirmedOwner(msg.sender) {
    FAST_GAS_FEED = IAggregatorV3(fastGasFeed);
    setConfig(config);
  }

  // ACTIONS

  /**
   * @notice adds a new task
   * @param target address to perform task on
   * @param gasLimit amount of gas to provide the target contract when
   * performing task
   * @param admin address to cancel task and withdraw remaining funds
   * @param checkData data passed to the contract when checking for task
   */
  function registerTask(
    address target,
    uint32 gasLimit,
    address admin,
    bytes calldata checkData,
    uint256 startTime
  ) external override onlyOwnerOrregistrar returns (uint256 id) {
    id = uint256(
      keccak256(abi.encodePacked(blockhash(block.number - 1), address(this), _storage.nonce))
    );
    _createTask(id, target, gasLimit, admin, 0, checkData, startTime);
    _storage.nonce++;
    emit TaskRegistered(id, gasLimit, admin);
    return id;
  }

  /**
   * @notice simulated by automates via eth_call to see if the task needs to be
   * performed. If task is needed, the call then simulates performTask
   * to make sure it succeeds. Finally, it returns the success status along with
   * payment information and the perform data payload.
   * @param id identifier of the task to check
   * @param from the address to simulate performing the task from
   */
  function checkTask(uint256 id, address from)
    external
    override
    notExecute
    returns (
      bytes memory performData,
      uint256 maxNativePayment,
      uint256 gasLimit,
      uint256 adjustedGasWei
    )
  {
    Task memory task = _task[id];
    if (task.isPaused) revert TaskPaused();
    if (task.startTime < block.timestamp) revert TaskNotActive();

    bytes memory callData = abi.encodeWithSelector(CHECK_SELECTOR, _checkData[id]);
    (bool success, bytes memory result) = task.target.call{ gas: _storage.gasLimit }(
      callData
    );

    if (!success) revert TargetCheckReverted(result);

    (success, performData) = abi.decode(result, (bool, bytes));
    if (!success) revert TaskNotNeeded();

    PerformParams memory params = _generatePerformParams(from, id, performData, false);
    _prePerformTask(task, params.from, params.maxNativePayment);

    return (performData, params.maxNativePayment, params.gasLimit, params.adjustedGasWei);
  }

  /**
   * @notice executes the task with the perform data returned from
   * checkTask, validates the automate's permissions, and pays the automate.
   * @param id identifier of the task to execute the data with.
   * @param performData calldata parameter to be passed to the target task.
   */
  function performTask(uint256 id, bytes calldata performData)
    external
    override
    whenNotPaused
    returns (bool success)
  {
    if (_task[id].isPaused) revert TaskPaused();
    return _performTaskWithParams(_generatePerformParams(msg.sender, id, performData, true));
  }

  function pauseTask(uint256 id) external onlyActiveTask(id) {
    if (msg.sender == owner && msg.sender != _task[id].admin)
      revert OnlyOwnerOrAdmin();
    _task[id].isPaused = true;
  }

  function unpauseTask(uint256 id) external onlyActiveTask(id) {
    if (msg.sender == owner && msg.sender != _task[id].admin)
      revert OnlyOwnerOrAdmin();
    _task[id].isPaused = false;
  }

  /**
   * @notice prevent an task from being performed in the future
   * @param id task to be canceled
   */
  function cancelTask(uint256 id) external override {
    uint64 maxValid = _task[id].maxValidBlocknumber;
    bool canceled = maxValid != UINT64_MAX;
    bool isOwner = msg.sender == owner;

    if (canceled && !(isOwner && maxValid > block.number)) revert CannotCancel();
    if (!isOwner && msg.sender != _task[id].admin) revert OnlyOwnerOrAdmin();

    uint256 height = block.number;
    if (!isOwner) {
      height = height + CANCELATION_DELAY;
    }
    _userTasks[_task[id].admin].remove(id);
    _task[id].maxValidBlocknumber = uint64(height);
    _taskIDs.remove(id);

    emit TaskCanceled(id, uint64(height));
  }

  /**
   * @notice adds LINK funding for an task by transferring from the sender's
   * LINK balance
   * @param id task to fund
   */
  function addFunds(uint256 id) external payable override onlyActiveTask(id) {
    uint256 amount = msg.value;
    _task[id].balance += amount;
    _expectedBNBBalance += amount;
    emit FundsAdded(id, msg.sender, amount);
  }

  function addUserFunds(address userToFund) external payable {
    require(userToFund != address(0), "cannot fund zero address");
    uint256 amount = msg.value;
    _userBalance[userToFund] += amount;
    _expectedBNBBalance += amount;
    emit FundsAddedToUser(userToFund, msg.sender, amount);
  }

  // TODO: needs to be changed in case of ANKR Token
  /**
   * @notice uses Native's transferAndCall to LINK and add funding to an task
   */
  function transferWithData(bytes calldata data) external payable override returns (bool) {
    uint256 amount = msg.value;
    address sender = msg.sender;
    if (data.length != 32) revert InvalidDataLength();
    uint256 id = abi.decode(data, (uint256));
    if (_task[id].maxValidBlocknumber != UINT64_MAX) revert TaskNotActive();

    _task[id].balance += amount;
    _expectedBNBBalance += amount;

    emit FundsAdded(id, sender, amount);
    return true;
  }

  /**
   * @notice removes funding from a canceled task
   * @param id task to withdraw funds from
   * @param to destination address for sending remaining funds
   */
  function withdrawFunds(uint256 id, address to) external validRecipient(to) onlyTaskAdmin(id) {
    if (_task[id].maxValidBlocknumber > block.number) revert TaskNotCanceled();

    uint256 minTaskSpend = _storage.minTaskSpend;
    uint256 amountLeft = _task[id].balance;
    uint256 amountSpent = _task[id].amountSpent;

    uint256 cancellationFee = 0;
    // cancellationFee is supposed to be min(max(minTaskSpend - amountSpent,0), amountLeft)
    if (amountSpent < minTaskSpend) {
      cancellationFee = minTaskSpend - amountSpent;
      if (cancellationFee > amountLeft) {
        cancellationFee = amountLeft;
      }
    }
    uint256 amountToWithdraw = amountLeft - cancellationFee;

    _task[id].balance = 0;
    _ownerBNBBalance += cancellationFee;

    _expectedBNBBalance -= amountToWithdraw;
    emit FundsWithdrawn(id, amountToWithdraw, to);

    payable(to).transfer(amountToWithdraw);
  }

  function withdrawUserFunds(uint256 amount, address to) external validRecipient(to) {
    address sender = msg.sender;
    if (amount == type(uint256).max) {
      amount = _userBalance[sender];
    } else {
      require(_userBalance[sender] >= amount, "cannot withdraw more amount that user has");
    }
    unchecked {
      _userBalance[sender] -= amount;
    }
    emit FundsWithdrawnForUser(msg.sender, amount, to);

    payable(to).transfer(amount);
  }

  /**
   * @notice withdraws Native funds collected through cancellation fees
   */
  function withdrawOwnerFunds() external onlyOwner {
    uint256 amount = _ownerBNBBalance;

    _expectedBNBBalance -= amount;
    _ownerBNBBalance = 0;

    emit OwnerFundsWithdrawn(amount);
    payable(msg.sender).transfer(amount);
  }

  /**
   * @notice allows the admin of an task to modify gas limit
   * @param id task to be change the gas limit for
   * @param gasLimit new gas limit for the task
   */
  function setTaskGasLimit(uint256 id, uint32 gasLimit)
    external
    override
    onlyActiveTask(id)
    onlyTaskAdmin(id)
  {
    if (gasLimit < PERFORM_GAS_MIN || gasLimit > _storage.maxGas)
      revert GasLimitOutsideRange();

    _task[id].executeGas = gasLimit;

    emit TaskGasLimitSet(id, gasLimit);
  }

  /**
   * @notice recovers LINK funds improperly transferred to the registry
   * @dev In principle this function’s execution cost could exceed block
   * gas limit. However, in our anticipated deployment, the number of tasks and
   * automates will be low enough to avoid this problem.
   */
  function recoverFunds() external onlyOwner {
    uint256 total = address(this).balance;
    payable(msg.sender).transfer(total - _expectedBNBBalance);
  }

  /**
   * @notice withdraws a automate's payment, callable only by the automate's payee
   * @param from automate address
   * @param to address to send the payment to
   */
  function withdrawPayment(address from, address to) external validRecipient(to) {
    AutomateInfo memory automate = _automateInfo[from];
    if (automate.payee != msg.sender) revert OnlyByPayee();

    _automateInfo[from].balance = 0;
    _expectedBNBBalance -= automate.balance;
    emit PaymentWithdrawn(from, automate.balance, to, msg.sender);

    payable(to).transfer(automate.balance);
  }

  /**
   * @notice proposes the safe transfer of a automate's payee to another address
   * @param automate address of the automate to transfer payee role
   * @param proposed address to nominate for next payeeship
   */
  function transferPayeeship(address automate, address proposed) external {
    if (_automateInfo[automate].payee != msg.sender) revert OnlyByPayee();
    if (proposed == msg.sender) revert ValueNotChanged();

    if (_proposedPayee[automate] != proposed) {
      _proposedPayee[automate] = proposed;
      emit PayeeshipTransferRequested(automate, msg.sender, proposed);
    }
  }

  /**
   * @notice accepts the safe transfer of payee role for a automate
   * @param automate address to accept the payee role for
   */
  function acceptPayeeship(address automate) external {
    if (_proposedPayee[automate] != msg.sender) revert OnlyByProposedPayee();
    address past = _automateInfo[automate].payee;
    _automateInfo[automate].payee = msg.sender;
    _proposedPayee[automate] = ZERO_ADDRESS;

    emit PayeeshipTransferred(automate, past, msg.sender);
  }

  /**
   * @notice signals to automates that they should not perform tasks until the
   * contract has been unpaused
   */
  function pause() external onlyOwner {
    _pause();
  }

  /**
   * @notice signals to automates that they can perform tasks once again after
   * having been paused
   */
  function unpause() external onlyOwner {
    _unpause();
  }

  // SETTERS

  /**
   * @notice updates the configuration of the registry
   * @param config registry config fields
   */
  function setConfig(Config memory config) public onlyOwner {
    if (config.maxGas < _storage.maxGas) revert GasLimitCanOnlyIncrease();
    _storage = Storage({
      paymentFee: config.paymentFee,
      flatFee: config.flatFee,
      blockCountPerAutomate: config.blockCountPerAutomate, 
      gasLimit: config.gasLimit,
      lastFeedSecondsAmt: config.lastFeedSecondsAmt,
      gasMultiplier: config.gasMultiplier,
      minTaskSpend: config.minTaskSpend,
      maxGas: config.maxGas,
      nonce: _storage.nonce
    });
    _defaultGasPrice = config.defaultGasPrice;
    _registrar = config.registrar;
    emit ConfigSet(config);
  }

  /**
   * @notice update the list of automates allowed to perform task
   * @param automates list of addresses allowed to perform task
   * @param payees addresses corresponding to automates who are allowed to
   * move payments which have been accrued
   */
  function setAutomates(address[] calldata automates, address[] calldata payees) external onlyOwner {
    if (automates.length != payees.length || automates.length < 2) revert ParameterLengthError();
    for (uint256 i = 0; i < _automateList.length; i++) {
      address automate = _automateList[i];
      _automateInfo[automate].active = false;
    }
    for (uint256 i = 0; i < automates.length; i++) {
      address automate = automates[i];
      AutomateInfo storage s_automate = _automateInfo[automate];
      address oldPayee = s_automate.payee;
      address newPayee = payees[i];
      if (
        (newPayee == ZERO_ADDRESS) ||
        (oldPayee != ZERO_ADDRESS && oldPayee != newPayee && newPayee != IGNORE_ADDRESS)
      ) revert InvalidPayee();
      if (s_automate.active) revert DuplicateEntry();
      s_automate.active = true;
      if (newPayee != IGNORE_ADDRESS) {
        s_automate.payee = newPayee;
      }
    }
    _automateList = automates;
    emit AutomatesUpdated(automates, payees);
  }

  // GETTERS

  /**
   * @notice read all of the details about an task
   */
  function getTask(uint256 id)
    external
    view
    override
    returns (
      address target,
      uint32 executeGas,
      bytes memory checkData,
      uint256 balance,
      address lastAutomate,
      address admin,
      uint64 maxValidBlocknumber,
      uint256 amountSpent,
      bool isPaused,
      uint256 startTime
    )
  {
    Task memory reg = _task[id];
    return (
      reg.target,
      reg.executeGas,
      _checkData[id],
      reg.balance,
      reg.lastAutomate,
      reg.admin,
      reg.maxValidBlocknumber,
      reg.amountSpent,
      reg.isPaused,
      reg.startTime
    );
  }

  /**
   * @notice retrieve active task IDs
   * @param startIndex starting index in list
   * @param maxCount max count to retrieve (0 = unlimited)
   * @dev the order of IDs in the list is **not guaranteed**, therefore, if making successive calls, one
   * should consider keeping the blockheight constant to ensure a wholistic picture of the contract state
   */
  function getActiveTaskIDs(uint256 startIndex, uint256 maxCount)
    external
    view
    override
    returns (uint256[] memory)
  {
    uint256 maxIdx = _taskIDs.length();
    if (startIndex >= maxIdx) revert IndexOutOfRange();
    if (maxCount == 0) {
      maxCount = maxIdx - startIndex;
    }
    uint256[] memory ids = new uint256[](maxCount);
    for (uint256 idx = 0; idx < maxCount; idx++) {
      ids[idx] = _taskIDs.at(startIndex + idx);
    }
    return ids;
  }

  /**
   * @notice read the current info about any automate address
   */
  function getAutomateInfo(address query)
    external
    view
    override
    returns (
      address payee,
      bool active,
      uint256 balance
    )
  {
    AutomateInfo memory automate = _automateInfo[query];
    return (automate.payee, automate.active, automate.balance);
  }

  /**
   * @notice read the current state of the registry
   */
  function getState()
    external
    view
    override
    returns (
      State memory state,
      Config memory config,
      address[] memory automates
    )
  {
    Storage memory store = _storage;
    state.nonce = store.nonce;
    state.ownerBNBBalance = _ownerBNBBalance;
    state.expectedBNBBalance = _expectedBNBBalance;
    state.numTasks = _taskIDs.length();
    config.paymentFee = store.paymentFee;
    config.flatFee = store.flatFee;
    config.blockCountPerAutomate = store.blockCountPerAutomate; 
    config.gasLimit = store.gasLimit;
    config.lastFeedSecondsAmt = store.lastFeedSecondsAmt;
    config.gasMultiplier = store.gasMultiplier;
    config.minTaskSpend = store.minTaskSpend;
    config.maxGas = store.maxGas;
    config.defaultGasPrice = _defaultGasPrice;
    config.registrar = _registrar;
    return (state, config, _automateList);
  }

  /**
   * @notice calculates the minimum balance required for an task to remain eligible
   * @param id the task id to calculate minimum balance for
   */
  function getMinBalanceForTask(uint256 id) external view returns (uint256 minBalance) {
    return getMaxPaymentForGas(_task[id].executeGas);
  }

  /**
   * @notice calculates the maximum payment for a given gas limit
   * @param gasLimit the gas to calculate payment for
   */
  function getMaxPaymentForGas(uint256 gasLimit) public view returns (uint256 maxPayment) {
    uint256 gasWei = _getFeedData();
    uint256 adjustedGasWei = _adjustGasPrice(gasWei, false);
    return _calculatePaymentAmount(gasLimit, adjustedGasWei);
  }

  function userBalance(address user) external view returns (uint256) {
    return _userBalance[user];
  }

  function userTasks(address user) external view returns (uint256[] memory) {
    return _userTasks[user].values();
  }

  function userTasksCount(address user) external view returns (uint256) {
    return _userTasks[user].length();
  }

  function userTasksAt(address user, uint256 index) external view returns (uint256) {
    return _userTasks[user].at(index);
  }

  function userTasksContains(address user, uint256 taskId) external view returns (bool) {
    return _userTasks[user].contains(taskId);
  }

  /**
   * @notice creates a new task with the given fields
   * @param target address to perform task on
   * @param gasLimit amount of gas to provide the target contract when
   * performing task
   * @param admin address to cancel task and withdraw remaining funds
   * @param checkData data passed to the contract when checking for task
   */
  function _createTask(
    uint256 id,
    address target,
    uint32 gasLimit,
    address admin,
    uint256 balance,
    bytes memory checkData,
    uint256 startTime
  ) internal whenNotPaused {
    if (!target.isContract()) revert NotAContract();
    if (gasLimit < PERFORM_GAS_MIN || gasLimit > _storage.maxGas)
      revert GasLimitOutsideRange();
    _task[id] = Task({
      target: target,
      executeGas: gasLimit,
      balance: balance,
      admin: admin,
      maxValidBlocknumber: UINT64_MAX,
      lastAutomate: ZERO_ADDRESS,
      amountSpent: 0,
      isPaused: false,
      startTime: startTime
    });
    _expectedBNBBalance += balance;
    _checkData[id] = checkData;
    _taskIDs.add(id);
    _userTasks[admin].add(id);
  }

  /**
   * @dev retrieves feed data for fast gas/eth and link/eth prices. if the feed
   * data is stale it uses the configured fallback price. Once a price is picked
   * for gas it takes the min of gas price in the transaction or the fast gas
   * price in order to reduce costs for the task clients.
   */
  function _getFeedData() private view returns (uint256 gasWei) {
    uint32 lastFeedSecondsAmt = _storage.lastFeedSecondsAmt;
    bool staleFallback = lastFeedSecondsAmt > 0;
    uint256 timestamp;
    int256 feedValue;
    (, feedValue, , timestamp, ) = FAST_GAS_FEED.latestRoundData();
    if ((staleFallback && lastFeedSecondsAmt < block.timestamp - timestamp) || feedValue <= 0) {
      gasWei = _defaultGasPrice;
    } else {
      gasWei = uint256(feedValue);
    }
    return gasWei;
  }

  /**
   * @dev calculates Native paid for gas spent plus a configure premium percentage
   */
  function _calculatePaymentAmount(uint256 gasLimit, uint256 gasWei)
    private
    view
    returns (uint256 payment)
  {
    uint256 weiForGas = gasWei * (gasLimit + REGISTRY_GAS_OVERHEAD);
    uint256 premium = PPB_BASE + _storage.paymentFee;
    uint256 total = ((weiForGas * (1e9) * (premium)) / 1e18) +
      (uint256(_storage.flatFee) * (1e12));
    return total;
  }

  /**
   * @dev calls target address with exactly gasAmount gas and data as calldata
   * or reverts if at least gasAmount gas is not available
   */
  function _callWithExactGas(
    uint256 gasAmount,
    address target,
    bytes memory data
  ) private returns (bool success) {
    assembly {
      let g := gas()
      // Compute g -= PERFORM_GAS_CUSHION and check for underflow
      if lt(g, PERFORM_GAS_CUSHION) {
        revert(0, 0)
      }
      g := sub(g, PERFORM_GAS_CUSHION)
      // if g - g//64 <= gasAmount, revert
      // (we subtract g//64 because of EIP-150)
      if iszero(gt(sub(g, div(g, 64)), gasAmount)) {
        revert(0, 0)
      }
      // solidity calls check that a contract actually exists at the destination, so we do the same
      if iszero(extcodesize(target)) {
        revert(0, 0)
      }
      // call and return whether we succeeded. ignore return data
      success := call(gasAmount, target, 0, add(data, 0x20), mload(data), 0, 0)
    }
    return success;
  }

  /**
   * @dev calls the Task target with the performData param passed in by the
   * automate and the exact gas required by the Task
   */
  function _performTaskWithParams(PerformParams memory params)
    private
    nonReentrant
    validTask(params.id)
    returns (bool success)
  {
    Task memory task = _task[params.id];
    _prePerformTask(task, params.from, params.maxNativePayment);

    uint256 gasUsed = gasleft();
    bytes memory callData = abi.encodeWithSelector(PERFORM_SELECTOR, params.performData);
    success = _callWithExactGas(params.gasLimit, task.target, callData);
    gasUsed -= gasleft();

    uint256 payment = _calculatePaymentAmount(gasUsed, params.adjustedGasWei);

    uint256 taskBal = _task[params.id].balance;
    if (taskBal >= payment) {
      _task[params.id].balance -= payment;
    } else {
      uint256 remainingAmount = payment - taskBal;
      _task[params.id].balance = 0;
      _userBalance[_task[params.id].admin] -= remainingAmount;
    }
    _task[params.id].amountSpent += payment;
    _task[params.id].lastAutomate = params.from;
    _automateInfo[params.from].balance += payment;

    emit TaskPerformed(params.id, success, params.from, payment, params.performData);
    return success;
  }

  /**
   * @dev ensures all required checks are passed before an task is performed
   */
  function _prePerformTask(
    Task memory task,
    address from,
    uint256 maxNativePayment
  ) private view {
    if (!_automateInfo[from].active) revert OnlyActiveAutomates();
    if (task.balance + _userBalance[task.admin] < maxNativePayment) revert InsufficientFunds();
    if (task.lastAutomate == from) revert AutomatesMustTakeTurns();
  }

  /**
   * @dev adjusts the gas price to min(ceiling, tx.gasprice) or just uses the ceiling if tx.gasprice is disabled
   */
  function _adjustGasPrice(uint256 gasWei, bool useTxGasPrice)
    private
    view
    returns (uint256 adjustedPrice)
  {
    adjustedPrice = gasWei * _storage.gasMultiplier;
    if (useTxGasPrice && tx.gasprice < adjustedPrice) {
      adjustedPrice = tx.gasprice;
    }
  }

  /**
   * @dev generates a PerformParams struct for use in _performTaskWithParams()
   */
  function _generatePerformParams(
    address from,
    uint256 id,
    bytes memory performData,
    bool useTxGasPrice
  ) private view returns (PerformParams memory) {
    uint256 gasLimit = _task[id].executeGas;
    uint256 gasWei = _getFeedData();
    uint256 adjustedGasWei = _adjustGasPrice(gasWei, useTxGasPrice);
    uint256 maxNativePayment = _calculatePaymentAmount(gasLimit, adjustedGasWei);

    return
      PerformParams({
        from: from,
        id: id,
        performData: performData,
        maxNativePayment: maxNativePayment,
        gasLimit: gasLimit,
        adjustedGasWei: adjustedGasWei
      });
  }

  // MODIFIERS

  /**
   * @dev ensures a task is valid
   */
  modifier validTask(uint256 id) {
    if (
      _task[id].maxValidBlocknumber <= block.number ||
      _task[id].startTime < block.timestamp  
    ) revert TaskNotActive();
    _;
  }

  /**
   * @dev Reverts if called by anyone other than the admin of task #id
   */
  modifier onlyTaskAdmin(uint256 id) {
    if (msg.sender != _task[id].admin) revert OnlyByAdmin();
    _;
  }

  /**
   * @dev Reverts if called on a cancelled task
   */
  modifier onlyActiveTask(uint256 id) {
    if (_task[id].maxValidBlocknumber != UINT64_MAX) revert TaskNotActive();
    _;
  }

  /**
   * @dev ensures that burns don't accidentally happen by sending to the zero
   * address
   */
  modifier validRecipient(address to) {
    if (to == ZERO_ADDRESS) revert InvalidRecipient();
    _;
  }

  /**
   * @dev Reverts if called by anyone other than the contract owner or registrar.
   */
  modifier onlyOwnerOrregistrar() {
    if (msg.sender != owner && msg.sender != _registrar) revert OnlyByOwnerOrregistrar();
    _;
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
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
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract AutomateBase {
  error OnlyForCalling();

  /**
   * @notice method that allows it to be simulated via eth_call by checking that
   * the sender is the zero address.
   */
  function doNotExecute() internal view {
    if (tx.origin != address(0)) {
      revert OnlyForCalling();
    }
  }

  /**
   * @notice modifier that allows it to be simulated via eth_call by checking
   * that the sender is the zero address.
   */
  modifier notExecute() {
    doNotExecute();
    _;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { ConfirmedOwnerWithProposal } from "./ConfirmedOwnerWithProposal.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IReceiver {
  function transferWithData(bytes calldata data) external payable returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IAggregatorV3 {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

abstract contract IVersion {
  function version() external pure virtual returns (string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IAutomateCompatible {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from AutomateBase to your implementation of this
   * method.
   * @param checkData specified in the task registration so it is always the
   * same for a registered task. This can easily be broken down into specific
   * arguments using `abi.decode`, so multiple tasks can be registered on the
   * same contract and easily differentiated by the contract.
   * @return taskNeeded boolean to indicate whether the keeper should call
   * performtask or not.
   * @return performData bytes that the keeper should call performtask with, if
   * task is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkTask(bytes calldata checkData) external returns (bool taskNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkTask simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkTask. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performTask transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performTask(bytes calldata performData) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { IReceiver } from "./IReceiver.sol";

/**
 * @notice config of the registry
 * @dev only used in params and return values
 * @member paymentFee payment premium rate oracles receive on top of
 * being reimbursed for gas, measured in parts per billion
 * @member flatFee flat fee paid to oracles for performing tasks,
 * priced in MicroBNB; can be used in conjunction with or independently of
 * paymentPremiumPPB
 * @member blockCountPerAutomate number of blocks each oracle has during their turn to
 * perform task before it will be the next keeper's turn to submit
 * @member gasLimit gas limit when checking for task
 * @member lastFeedSecondsAmt number of seconds that is allowed for feed data to
 * be stale before switching to the fallback pricing
 * @member gasMultiplier multiplier to apply to the fast gas feed price
 * when calculating the payment ceiling for keepers
 * @member minTaskSpend minimum BNB that an task must spend before cancelling
 * @member maxGas max executeGas allowed for an task on this registry
 * @member defaultGasPrice gas price used if the gas price feed is stale
 * @member registrar address of the registrar contract
 */
struct Config {
  uint32 paymentFee;
  uint32 flatFee; 
  uint24 blockCountPerAutomate;
  uint32 gasLimit;
  uint24 lastFeedSecondsAmt;
  uint16 gasMultiplier;
  uint256 minTaskSpend;
  uint32 maxGas;
  uint256 defaultGasPrice;
  address registrar;
}

/**
 * @notice state of the registry
 * @dev only used in params and return values
 * @member nonce used for ID generation
 * @member ownerBNBBalance withdrawable balance of BNB by contract owner
 * @member expectedBNBBalance the expected balance of BNB of the registry
 * @member numTasks total number of tasks on the registry
 */
struct State {
  uint32 nonce;
  uint256 ownerBNBBalance;
  uint256 expectedBNBBalance;
  uint256 numTasks;
}

interface IAutomateRegistryBase is IReceiver {
  function registerTask(
    address target,
    uint32 gasLimit,
    address admin,
    bytes calldata checkData,
    uint256 startTime
  ) external returns (uint256 id);

  function performTask(uint256 id, bytes calldata performData) external returns (bool success);

  function cancelTask(uint256 id) external;

  function addFunds(uint256 id) external payable;

  function setTaskGasLimit(uint256 id, uint32 gasLimit) external;

  function getTask(uint256 id)
    external
    view
    returns (
      address target,
      uint32 executeGas,
      bytes memory checkData,
      uint256 balance,
      address lastAutomater,
      address admin,
      uint64 maxValidBlocknumber,
      uint256 amountSpent,
      bool isPaused,
      uint256 startTime
    );

  function getActiveTaskIDs(uint256 startIndex, uint256 maxCount)
    external
    view
    returns (uint256[] memory);

  function getAutomateInfo(address query)
    external
    view
    returns (
      address payee,
      bool active,
      uint256 balance
    );

  function getState()
    external
    view
    returns (
      State memory,
      Config memory,
      address[] memory
    );
}

/**
 * @dev The view methods are not actually marked as view in the implementation
 * but we want them to be easily queried off-chain. Solidity will not compile
 * if we actually inherit from this interface, so we document it here.
 */
interface IAutomateRegistry is IAutomateRegistryBase {
  function checkTask(uint256 taskId, address from)
    external
    view
    returns (
      bytes memory performData,
      uint256 maxBNBPayment,
      uint256 gasLimit,
      int256 gasWei
    );
}

interface IAutomateRegistryExecutable is IAutomateRegistryBase {
  function checkTask(uint256 taskId, address from)
    external
    returns (
      bytes memory performData,
      uint256 maxBNBPayment,
      uint256 gasLimit,
      uint256 adjustedGasWei
    );
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { IOwnable } from "./interfaces/IOwnable.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwnerWithProposal is IOwnable {
  address public owner;
  address private pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address _pendingOwner) {
    require(newOwner != address(0), "Cannot set owner to zero");

    owner = newOwner;
    if (_pendingOwner != address(0)) {
      _transferOwnership(_pendingOwner);
    }
  }

  /**
   * @notice Allows an owner to begin transferring ownership to a new address,
   * pending.
   */
  function transferOwnership(address to) public override onlyOwner {
    _transferOwnership(to);
  }

  /**
   * @notice Allows an ownership transfer to be completed by the recipient.
   */
  function acceptOwnership() external override {
    require(msg.sender == pendingOwner, "Must be proposed owner");

    address oldOwner = owner;
    owner = msg.sender;
    pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /**
   * @notice validate, transfer ownership, and emit relevant events
   */
  function _transferOwnership(address to) private {
    require(to != msg.sender, "Cannot transfer to self");

    pendingOwner = to;

    emit OwnershipTransferRequested(owner, to);
  }

  /**
   * @notice validate access
   */
  function _validateOwnership() internal view {
    require(msg.sender == owner, "Only callable by owner");
  }

  /**
   * @notice Reverts if called by anyone other than the contract owner.
   */
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IOwnable {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}