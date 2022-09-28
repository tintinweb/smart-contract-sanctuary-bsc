// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./interfaces/AggregatorV2V3Interface.sol";
import "./access/OwnerIsCreator.sol";
import "./access/ReadWriteAccessControlled.sol";

/**
 * @title Aggregator for a pair
 * @dev This contract does not perform any aggregation. The name is chosen inline with ChainLink's API
 * @author Sri Krishna Mannem
 */
contract BinanceAggregator is AggregatorV2V3Interface, ReadWriteAccessControlled {
  /***************************************************************************
   * Section: Variables used in multiple other sections
   **************************************************************************/

  /// @dev Transmission records an update request from the OnChainOracle
  struct Transmission {
    int192 answer; // 192 bits ought to be enough for anyone
    uint64 observationsTimestamp; // when were observations made offchain
    uint64 transmissionTimestamp; // when was report received onchain
  }

  /// @dev which pair this aggregator updates. Ex: 'BTC/USD'
  string internal PAIR_NAME;
  string internal AGGREGATOR_DESCRIPTION;

  /// @dev The aggregator roundId to transmission map
  mapping(uint32 => Transmission) internal s_transmissions;

  /// @dev incrementing counter for the aggregator
  uint32 s_latestAggregatorRoundId;

  /// @dev answers are stored in fixed-point format, with this many digits of precision
  uint8 public immutable override decimals;

  /// @notice aggregator contract version
  uint256 public constant override version = 6;

  /// @notice if true, stores all historical updates. Otherwise only stores latest data
  bool public immutable storeHistoricalData;

  /***************************************************************************
   * Section: Constructor and modifiers
   **************************************************************************/

  /**
   * @param pair_ pair this aggregator updates. Ex: 'BTC/USD'
   * @param decimals_ answers are stored in fixed-point format, with this many digits of precision
   * @param description_ short human-readable description of observable this contract's answers pertain to
   * @param storeHistoricalData_ if true, stores all historical updates. Otherwise only stores latest data
   */
  constructor(
    string memory pair_,
    uint8 decimals_,
    string memory description_,
    bool storeHistoricalData_
  ) {
    PAIR_NAME = pair_;
    decimals = decimals_;
    AGGREGATOR_DESCRIPTION = description_;
    storeHistoricalData = storeHistoricalData_;
  }

  /**
   * @dev reverts if the caller does not have write access granted by the accessController contract
   */
  modifier checkWriteAccess() {
    require(
      address(s_accessController) == address(0) || s_accessController.hasWriteAccess(msg.sender),
      "No write access"
    );
    _;
  }

  /**
   * @dev reverts if the caller does not have read access granted by the accessController contract
   */
  modifier checkReadAccess() {
    require(
      address(s_accessController) == address(0) || s_accessController.hasReadAccess(msg.sender),
      "No read access"
    );
    _;
  }

  /***************************************************************************
   * Section: Updater
   **************************************************************************/

  /**
   * @notice Transmit price updates for a particular pair from OnChainOracle
   * @dev When the aggregator is paused, it overwrites the latest round data
   *
   */
  function transmit(uint64 timestamp_, int192 newPrice_) external checkWriteAccess {
    Transmission memory prior = s_transmissions[s_latestAggregatorRoundId];
    require(
      timestamp_ > prior.observationsTimestamp,
      "Aggregator: Received time stamp less than previous recorded value"
    );
    require(block.timestamp < timestamp_ + 60 minutes, "Aggregator: Update took longer than an hour, hence expired");
    //Store historical records when not paused
    if (storeHistoricalData) {
      s_latestAggregatorRoundId++;
    }
    s_transmissions[s_latestAggregatorRoundId] = Transmission({
      answer: newPrice_,
      observationsTimestamp: timestamp_,
      transmissionTimestamp: uint32(block.timestamp)
    });
  }

  /**
   * @notice Pair this aggregator handles
   */
  function getPair() external view returns (string memory) {
    return PAIR_NAME;
  }

  /***************************************************************************
   * Section: v2 AggregatorInterface
   **************************************************************************/

  /**
   * @notice median from the most recent report
   */
  function latestAnswer() external view virtual override checkReadAccess returns (int256) {
    return s_transmissions[s_latestAggregatorRoundId].answer;
  }

  /**
   * @notice timestamp of block in which last report was transmitted
   */
  function latestTimestamp() external view virtual override checkReadAccess returns (uint256) {
    return s_transmissions[s_latestAggregatorRoundId].transmissionTimestamp;
  }

  /**
   * @notice Aggregator round (NOT OCR round) in which last report was transmitted
   */
  function latestRound() external view virtual override checkReadAccess returns (uint256) {
    return s_latestAggregatorRoundId;
  }

  /**
   * @notice price of the asset at this round
   * @param roundId the aggregator round of the target report
   */
  function getAnswer(uint256 roundId) external view virtual override checkReadAccess returns (int256) {
    require(storeHistoricalData, "Aggregator does not record historical data");
    if (roundId > 0xFFFFFFFF) {
      return 0;
    }
    return s_transmissions[uint32(roundId)].answer;
  }

  /**
   * @notice timestamp of block in which report from given aggregator round was transmitted
   * @param roundId round to retrieve the timestamp for
   */
  function getTimestamp(uint256 roundId) external view virtual override checkReadAccess returns (uint256) {
    require(storeHistoricalData, "Aggregator does not record historical data");
    if (roundId > 0xFFFFFFFF) {
      return 0;
    }
    return s_transmissions[uint32(roundId)].transmissionTimestamp;
  }

  /***************************************************************************
   * Section: v3 AggregatorInterface
   **************************************************************************/

  /**
   * @notice human-readable description of observable this contract is reporting on
   */
  function description() external view virtual override returns (string memory) {
    return AGGREGATOR_DESCRIPTION;
  }

  /**
   * @notice details for the given aggregator round
   * @param roundId round to retrieve the data for
   * @return roundId_ roundId
   * @return answer price of the pair at this round
   * @return startedAt timestamp of when observations were made offchain
   * @return updatedAt timestamp of block in which report from given roundId was transmitted
   * @return answeredInRound roundId
   */
  function getRoundData(uint80 roundId)
    external
    view
    virtual
    override
    checkReadAccess
    returns (
      uint80 roundId_,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {
    require(storeHistoricalData, "Aggregator does not record historical data");
    if (roundId > type(uint32).max) {
      return (0, 0, 0, 0, 0);
    }
    Transmission memory transmission = s_transmissions[uint32(roundId)];
    return (
      roundId,
      transmission.answer,
      transmission.observationsTimestamp,
      transmission.transmissionTimestamp,
      roundId
    );
  }

  /**
   * @notice aggregator details for the most recently transmitted report
   * @return roundId round to get the data for
   * @return answer price of the pair at this round
   * @return startedAt timestamp of when observations were made offchain
   * @return updatedAt timestamp of block containing latest report
   * @return answeredInRound aggregator round of latest report
   */
  function latestRoundData()
    external
    view
    virtual
    override
    checkReadAccess
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {
    Transmission memory transmission = s_transmissions[s_latestAggregatorRoundId];
    return (
      s_latestAggregatorRoundId,
      transmission.answer,
      transmission.observationsTimestamp,
      transmission.transmissionTimestamp,
      s_latestAggregatorRoundId
    );
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AggregatorInterface.sol";
import "./AggregatorV3Interface.sol";

interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface {}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ConfirmedOwner.sol";

/**
 * @title The OwnerIsCreator contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract OwnerIsCreator is ConfirmedOwner {
  constructor() ConfirmedOwner(msg.sender) {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ConfirmedOwner.sol";
import "../interfaces/ReadWriteAccessControllerInterface.sol";
import "../interfaces/ReadWriteAccessControlledInterface.sol";

contract ReadWriteAccessControlled is ReadWriteAccessControlledInterface, ConfirmedOwner(msg.sender) {
  ReadWriteAccessControllerInterface internal s_accessController;

  function setAccessController(ReadWriteAccessControllerInterface _accessController) external override onlyOwner {
    require(address(_accessController) != address(s_accessController), "Access controller is already set");
    s_accessController = _accessController;
    emit AccessControllerSet(address(_accessController), msg.sender);
  }

  function getAccessController() external view override returns (ReadWriteAccessControllerInterface) {
    return s_accessController;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
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
pragma solidity ^0.8.0;

import "./ConfirmedOwnerWithProposal.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/OwnableInterface.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwnerWithProposal is OwnableInterface {
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
  function transferOwnership(address to) external override onlyOwner {
    require(to != address(0), "Cannot set owner to zero");
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
  function owner() external view override returns (address) {
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
pragma solidity ^0.8.0;

interface OwnableInterface {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ReadWriteAccessControllerInterface {
  function hasReadAccess(address user) external view returns (bool);

  function hasWriteAccess(address user) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ReadWriteAccessControllerInterface.sol";

/**
 *  @notice Getters and setters for access controller
 */
interface ReadWriteAccessControlledInterface {
  event AccessControllerSet(address indexed accessController, address indexed sender);

  function setAccessController(ReadWriteAccessControllerInterface _accessController) external;

  function getAccessController() external view returns (ReadWriteAccessControllerInterface);
}