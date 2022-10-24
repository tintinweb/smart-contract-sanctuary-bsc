// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { IReceiver } from "./interfaces/IReceiver.sol";
import { ConfirmedOwner } from "./ConfirmedOwner.sol";
import { ITypeAndVersion } from "./interfaces/ITypeAndVersion.sol";
import { IKeeperRegistryBase } from "./interfaces/IKeeperRegistry.sol";

/**
 * @notice Contract to accept requests for upkeep registrations
 * @dev There are 2 registration workflows in this contract
 * Flow 1. auto approve OFF / manual registration - UI calls `register` function on this contract, this contract owner at a later time then manually
 *  calls `approve` to register upkeep and emit events to inform UI and others interested.
 * Flow 2. auto approve ON / real time registration - UI calls `register` function as before, which calls the `registerUpkeep` function directly on
 *  keeper registry and then emits approved event to finish the flow automatically without manual intervention.
 * The idea is to have same interface(functions,events) for UI or anyone using this contract irrespective of auto approve being enabled or not.
 * they can just listen to `RegistrationRequested` & `RegistrationApproved` events and know the status on registrations.
 */
contract KeeperRegistrar is ITypeAndVersion, ConfirmedOwner, IReceiver {
  /**
   * DISABLED: No auto approvals, all new upkeeps should be approved manually.
   * ENABLED_SENDER_ALLOWLIST: Auto approvals for allowed senders subject to max allowed. Manual for rest.
   * ENABLED_ALL: Auto approvals for all new upkeeps subject to max allowed.
   */
  enum AutoApproveType {
    DISABLED,
    ENABLED_SENDER_ALLOWLIST,
    ENABLED_ALL
  }

  bytes4 private constant REGISTER_REQUEST_SELECTOR = this.register.selector;

  mapping(bytes32 => PendingRequest) private s_pendingRequests;

  /**
   * @notice versions:
   * - KeeperRegistrar 1.1.0: Add functionality for sender allowlist in auto approve
   *                        : Remove rate limit and add max allowed for auto approve
   * - KeeperRegistrar 1.0.0: initial release
   */
  string public constant override typeAndVersion = "KeeperRegistrar 1.1.0";

  struct Config {
    AutoApproveType autoApproveConfigType;
    uint32 autoApproveMaxAllowed;
    uint32 approvedCount;
    IKeeperRegistryBase keeperRegistry;
    uint96 minBNBAmount;
  }

  struct PendingRequest {
    address admin;
    uint96 balance;
  }

  Config private s_config;
  // Only applicable if s_config.configType is ENABLED_SENDER_ALLOWLIST
  mapping(address => bool) private s_autoApproveAllowedSenders;

  event RegistrationRequested(
    bytes32 indexed hash,
    string name,
    bytes encryptedEmail,
    address indexed upkeepContract,
    uint32 gasLimit,
    address adminAddress,
    bytes checkData,
    uint96 amount,
    uint8 indexed source
  );

  event RegistrationApproved(bytes32 indexed hash, string displayName, uint256 indexed upkeepId);

  event RegistrationRejected(bytes32 indexed hash);

  event AutoApproveAllowedSenderSet(address indexed senderAddress, bool allowed);

  event ConfigChanged(
    AutoApproveType autoApproveConfigType,
    uint32 autoApproveMaxAllowed,
    address keeperRegistry,
    uint96 minBNBAmount
  );

  error InvalidAdminAddress();
  error RequestNotFound();
  error HashMismatch();
  error OnlyAdminOrOwner();
  error InsufficientPayment();
  error RegistrationRequestFailed();
  error AmountMismatch();
  error SenderMismatch();
  error OnlyThisContract();
  error FunctionNotPermitted();
  error TransferFailed(address to);
  error InvalidDataLength();

  /*
   * @param autoApproveConfigType setting for auto-approve registrations
   * @param autoApproveMaxAllowed max number of registrations that can be auto approved
   * @param keeperRegistry keeper registry address
   * @param minBNBAmount minimum BNB that new registrations should fund their upkeep with
   */
  constructor(
    AutoApproveType autoApproveConfigType,
    uint16 autoApproveMaxAllowed,
    address keeperRegistry,
    uint96 minBNBAmount
  ) ConfirmedOwner(msg.sender) {
    setRegistrationConfig(
      autoApproveConfigType,
      autoApproveMaxAllowed,
      keeperRegistry,
      minBNBAmount
    );
  }

  //EXTERNAL

  /**
   * @notice register can only be called through transferWithData
   * @param name string of the upkeep to be registered
   * @param encryptedEmail email address of upkeep contact
   * @param upkeepContract address to perform upkeep on
   * @param gasLimit amount of gas to provide the target contract when performing upkeep
   * @param adminAddress address to cancel upkeep and withdraw remaining funds
   * @param checkData data passed to the contract when checking for upkeep
   * @param amount quantity of Native upkeep is funded with (specified in Juels)
   * @param source application sending this request
   * @param sender address of the sender making the request
   */
  function register(
    string memory name,
    bytes calldata encryptedEmail,
    address upkeepContract,
    uint32 gasLimit,
    address adminAddress,
    bytes calldata checkData,
    uint96 amount,
    uint8 source,
    address sender
  ) external onlyThisContract {
    if (adminAddress == address(0)) {
      revert InvalidAdminAddress();
    }
    bytes32 hash = keccak256(abi.encode(upkeepContract, gasLimit, adminAddress, checkData));

    emit RegistrationRequested(
      hash,
      name,
      encryptedEmail,
      upkeepContract,
      gasLimit,
      adminAddress,
      checkData,
      amount,
      source
    );

    Config memory config = s_config;
    if (_shouldAutoApprove(config, sender)) {
      s_config.approvedCount = config.approvedCount + 1;

      _approve(name, upkeepContract, gasLimit, adminAddress, checkData, amount, hash);
    } else {
      uint96 newBalance = s_pendingRequests[hash].balance + amount;
      s_pendingRequests[hash] = PendingRequest({ admin: adminAddress, balance: newBalance });
    }
  }

  /**
   * @dev register upkeep on KeeperRegistry contract and emit RegistrationApproved event
   */
  function approve(
    string memory name,
    address upkeepContract,
    uint32 gasLimit,
    address adminAddress,
    bytes calldata checkData,
    bytes32 hash
  ) external onlyOwner {
    PendingRequest memory request = s_pendingRequests[hash];
    if (request.admin == address(0)) {
      revert RequestNotFound();
    }
    bytes32 expectedHash = keccak256(abi.encode(upkeepContract, gasLimit, adminAddress, checkData));
    if (hash != expectedHash) {
      revert HashMismatch();
    }
    delete s_pendingRequests[hash];
    _approve(name, upkeepContract, gasLimit, adminAddress, checkData, request.balance, hash);
  }

  /**
   * @notice cancel will remove a registration request and return the refunds to the msg.sender
   * @param hash the request hash
   */
  function cancel(bytes32 hash) external {
    PendingRequest memory request = s_pendingRequests[hash];
    if (!(msg.sender == request.admin || msg.sender == owner())) {
      revert OnlyAdminOrOwner();
    }
    if (request.admin == address(0)) {
      revert RequestNotFound();
    }
    delete s_pendingRequests[hash];
    bool success = payable(msg.sender).send(request.balance);
    if (!success) {
      revert TransferFailed(msg.sender);
    }
    emit RegistrationRejected(hash);
  }

  /**
   * @notice owner calls this function to set if registration requests should be sent directly to the Keeper Registry
   * @param autoApproveConfigType setting for auto-approve registrations
   *                   note: autoApproveAllowedSenders list persists across config changes irrespective of type
   * @param autoApproveMaxAllowed max number of registrations that can be auto approved
   * @param keeperRegistry new keeper registry address
   * @param minBNBAmount minimum LINK that new registrations should fund their upkeep with
   */
  function setRegistrationConfig(
    AutoApproveType autoApproveConfigType,
    uint16 autoApproveMaxAllowed,
    address keeperRegistry,
    uint96 minBNBAmount
  ) public onlyOwner {
    uint32 approvedCount = s_config.approvedCount;
    s_config = Config({
      autoApproveConfigType: autoApproveConfigType,
      autoApproveMaxAllowed: autoApproveMaxAllowed,
      approvedCount: approvedCount,
      minBNBAmount: minBNBAmount,
      keeperRegistry: IKeeperRegistryBase(keeperRegistry)
    });

    emit ConfigChanged(autoApproveConfigType, autoApproveMaxAllowed, keeperRegistry, minBNBAmount);
  }

  /**
   * @notice owner calls this function to set allowlist status for senderAddress
   * @param senderAddress senderAddress to set the allowlist status for
   * @param allowed true if senderAddress needs to be added to allowlist, false if needs to be removed
   */
  function setAutoApproveAllowedSender(address senderAddress, bool allowed) external onlyOwner {
    s_autoApproveAllowedSenders[senderAddress] = allowed;

    emit AutoApproveAllowedSenderSet(senderAddress, allowed);
  }

  /**
   * @notice read the allowlist status of senderAddress
   * @param senderAddress address to read the allowlist status for
   */
  function getAutoApproveAllowedSender(address senderAddress) external view returns (bool) {
    return s_autoApproveAllowedSenders[senderAddress];
  }

  /**
   * @notice read the current registration configuration
   */
  function getRegistrationConfig()
    external
    view
    returns (
      AutoApproveType autoApproveConfigType,
      uint32 autoApproveMaxAllowed,
      uint32 approvedCount,
      address keeperRegistry,
      uint256 minBNBAmount
    )
  {
    Config memory config = s_config;
    return (
      config.autoApproveConfigType,
      config.autoApproveMaxAllowed,
      config.approvedCount,
      address(config.keeperRegistry),
      config.minBNBAmount
    );
  }

  /**
   * @notice gets the admin address and the current balance of a registration request
   */
  function getPendingRequest(bytes32 hash) external view returns (address, uint96) {
    PendingRequest memory request = s_pendingRequests[hash];
    return (request.admin, request.balance);
  }

  /**
   * @notice Called when Native is sent to the contract via `transferWithData`
   * @param data Payload of the transaction
   */
  function transferWithData(bytes calldata data)
    external
    payable
    override
    permittedFunction(data)
    isActualAmount(data)
    isActualSender(data)
    returns (bool)
  {
    if (data.length < 292) revert InvalidDataLength();
    if (msg.value < s_config.minBNBAmount) {
      revert InsufficientPayment();
    }
    (bool success, ) = address(this).call(data);
    // calls register
    if (!success) {
      revert RegistrationRequestFailed();
    }
    return true;
  }

  //PRIVATE

  /**
   * @dev register upkeep on KeeperRegistry contract and emit RegistrationApproved event
   */
  function _approve(
    string memory name,
    address upkeepContract,
    uint32 gasLimit,
    address adminAddress,
    bytes calldata checkData,
    uint96 amount,
    bytes32 hash
  ) private {
    IKeeperRegistryBase keeperRegistry = s_config.keeperRegistry;

    // register upkeep
    uint256 upkeepId = keeperRegistry.registerUpkeep(
      upkeepContract,
      gasLimit,
      adminAddress,
      checkData
    );
    // fund upkeep
    bool success = keeperRegistry.transferWithData{ value: amount }(abi.encode(upkeepId));
    if (!success) {
      revert TransferFailed(address(keeperRegistry));
    }

    emit RegistrationApproved(hash, name, upkeepId);
  }

  /**
   * @dev verify sender allowlist if needed and check max limit
   */
  function _shouldAutoApprove(Config memory config, address sender) private returns (bool) {
    if (config.autoApproveConfigType == AutoApproveType.DISABLED) {
      return false;
    }
    if (
      config.autoApproveConfigType == AutoApproveType.ENABLED_SENDER_ALLOWLIST &&
      (!s_autoApproveAllowedSenders[sender])
    ) {
      return false;
    }
    if (config.approvedCount < config.autoApproveMaxAllowed) {
      return true;
    }
    return false;
  }

  //MODIFIERS

  /**
   * @dev Reverts if not sent from the current contract token
   */
  modifier onlyThisContract() {
    if (msg.sender != address(this)) {
      revert OnlyThisContract();
    }
    _;
  }

  /**
   * @dev Reverts if the given data does not begin with the `register` function selector
   * @param data The data payload of the request
   */
  modifier permittedFunction(bytes memory data) {
    bytes4 funcSelector;
    assembly {
      // solhint-disable-next-line avoid-low-level-calls
      funcSelector := mload(add(data, 32)) // First 32 bytes contain length of data
    }
    if (funcSelector != REGISTER_REQUEST_SELECTOR) {
      revert FunctionNotPermitted();
    }
    _;
  }

  /**
   * @dev Reverts if the actual amount passed does not match the expected amount
   * @param data bytes
   */
  modifier isActualAmount(bytes memory data) {
    uint256 actual;
    assembly {
      actual := mload(add(data, 228))
    }
    if (msg.value != actual) {
      revert AmountMismatch();
    }
    _;
  }

  /**
   * @dev Reverts if the actual sender address does not match the expected sender address
   * @param data bytes
   */
  modifier isActualSender(bytes memory data) {
    address actual;
    assembly {
      actual := mload(add(data, 292))
    }
    if (msg.sender != actual) {
      revert SenderMismatch();
    }
    _;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IReceiver {
  function transferWithData(bytes calldata data) external payable returns (bool);
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

abstract contract ITypeAndVersion {
  function typeAndVersion() external pure virtual returns (string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { IReceiver } from "./IReceiver.sol";

/**
 * @notice config of the registry
 * @dev only used in params and return values
 * @member paymentPremiumPPB payment premium rate oracles receive on top of
 * being reimbursed for gas, measured in parts per billion
 * @member flatFeeMicroLink flat fee paid to oracles for performing upkeeps,
 * priced in MicroLink; can be used in conjunction with or independently of
 * paymentPremiumPPB
 * @member blockCountPerTurn number of blocks each oracle has during their turn to
 * perform upkeep before it will be the next keeper's turn to submit
 * @member checkGasLimit gas limit when checking for upkeep
 * @member stalenessSeconds number of seconds that is allowed for feed data to
 * be stale before switching to the fallback pricing
 * @member gasCeilingMultiplier multiplier to apply to the fast gas feed price
 * when calculating the payment ceiling for keepers
 * @member minUpkeepSpend minimum LINK that an upkeep must spend before cancelling
 * @member maxPerformGas max executeGas allowed for an upkeep on this registry
 * @member fallbackGasPrice gas price used if the gas price feed is stale
 * @member registrar address of the registrar contract
 */
struct Config {
  uint32 paymentPremiumPPB;
  uint32 flatFeeMicroLink; // min 0.000001 LINK, max 4294 LINK
  uint24 blockCountPerTurn;
  uint32 checkGasLimit;
  uint24 stalenessSeconds;
  uint16 gasCeilingMultiplier;
  uint256 minUpkeepSpend;
  uint32 maxPerformGas;
  uint256 fallbackGasPrice;
  address registrar;
}

/**
 * @notice state of the registry
 * @dev only used in params and return values
 * @member nonce used for ID generation
 * @member ownerLinkBalance withdrawable balance of LINK by contract owner
 * @member expectedLinkBalance the expected balance of LINK of the registry
 * @member numUpkeeps total number of upkeeps on the registry
 */
struct State {
  uint32 nonce;
  uint256 ownerLinkBalance;
  uint256 expectedLinkBalance;
  uint256 numUpkeeps;
}

interface IKeeperRegistryBase is IReceiver {
  function registerUpkeep(
    address target,
    uint32 gasLimit,
    address admin,
    bytes calldata checkData
  ) external returns (uint256 id);

  function performUpkeep(uint256 id, bytes calldata performData) external returns (bool success);

  function cancelUpkeep(uint256 id) external;

  function addFunds(uint256 id) external payable;

  function setUpkeepGasLimit(uint256 id, uint32 gasLimit) external;

  function getUpkeep(uint256 id)
    external
    view
    returns (
      address target,
      uint32 executeGas,
      bytes memory checkData,
      uint256 balance,
      address lastKeeper,
      address admin,
      uint64 maxValidBlocknumber,
      uint256 amountSpent
    );

  function getActiveUpkeepIDs(uint256 startIndex, uint256 maxCount)
    external
    view
    returns (uint256[] memory);

  function getKeeperInfo(address query)
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
interface IKeeperRegistry is IKeeperRegistryBase {
  function checkUpkeep(uint256 upkeepId, address from)
    external
    view
    returns (
      bytes memory performData,
      uint256 maxLinkPayment,
      uint256 gasLimit,
      int256 gasWei
    );
}

interface IKeeperRegistryExecutable is IKeeperRegistryBase {
  function checkUpkeep(uint256 upkeepId, address from)
    external
    returns (
      bytes memory performData,
      uint256 maxLinkPayment,
      uint256 gasLimit,
      uint256 adjustedGasWei
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { IOwnable } from "./interfaces/IOwnable.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwnerWithProposal is IOwnable {
  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    require(newOwner != address(0), "Cannot set owner to zero");

    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
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
    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /**
   * @notice Get the current owner
   */
  function owner() public view override returns (address) {
    return s_owner;
  }

  /**
   * @notice validate, transfer ownership, and emit relevant events
   */
  function _transferOwnership(address to) private {
    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /**
   * @notice validate access
   */
  function _validateOwnership() internal view {
    require(msg.sender == s_owner, "Only callable by owner");
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