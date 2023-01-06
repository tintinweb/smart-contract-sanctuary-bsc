// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "../access/OwnerIsCreator.sol";
import "./interfaces/XAssetReadWriteInterface.sol";
import "./interfaces/XErrorInterface.sol";

/**
 * @title XAsset.sol
 * @dev Stores the balance of an asset with 5 historical records
 * @author Lawson Cheng
 */
contract XAsset is XAssetReadWriteInterface,  OwnerIsCreator, XErrorInterface {

  // the asset name and type
  address internal immutable TOKEN_ADDRESS;
  AssetType internal immutable ASSET_TYPE;

  // number of historical record of the contract stored
  uint8 constant STORAGE_SIZE = 5;

  // timestamp of the observation made of the latest data
  uint64 internal observationTimestamp;

  // Stores the latest record including historical data
  // @notice The latest record at index 0
  mapping(uint256 => AssetRecord) internal records;

  /**
  * @dev creates an AssetBalance instance
  * @param _tokenAddress: the asset token address
  * @param _assetType: the asset type (Asset or Pnl)
  */
  constructor(
    address _tokenAddress,
    AssetType _assetType
  ) {
    TOKEN_ADDRESS = _tokenAddress;
    ASSET_TYPE = _assetType;
  }

  /**
  * @dev update balance of the asset
  * @param blockNumber: the block number where the update transaction is happened
  * @param balance: the latest balance of that asset
  */
  function update(uint64 blockNumber, int192 balance, uint64 _observationTimestamp) external override onlyOwner {
    if(_observationTimestamp <= observationTimestamp) {
      revert InvalidObservationTimestamp();
    }
    records[4] = records[3];
    records[3] = records[2];
    records[2] = records[1];
    records[1] = records[0];
    records[0] = AssetRecord({
      balance: balance,
      blockNumber: blockNumber
    });
    observationTimestamp = _observationTimestamp;
  }

  /**
  * @dev returns all historical balance records
  */
  function getRecordAtIndex(uint256 _index) external view override returns (AssetDetailRecord memory, uint64) {
    if(_index + 1 > STORAGE_SIZE) {
      revert ExceededStorageLimit(STORAGE_SIZE);
    }
    return (
      AssetDetailRecord({
        symbol: TOKEN_ADDRESS,
        assetType: ASSET_TYPE,
        balance: records[_index].balance
      }),
      records[_index].blockNumber
    );
  }

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./ConfirmedOwner.sol";

/**
 * @title The OwnerIsCreator contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract OwnerIsCreator is ConfirmedOwner {
  constructor() ConfirmedOwner(msg.sender) {}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "./XAssetInterface.sol";

interface XAssetReadWriteInterface is XAssetInterface {

  function getRecordAtIndex(uint256 index) external view returns (AssetDetailRecord memory, uint64);

  function update(uint64 blockNumber, int192 balance, uint64 observationTimestamp) external;

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./XAssetInterface.sol";

interface XErrorInterface is XAssetInterface {
  // custom errors for XOracle
  error UnexpectedBatchID();
  error InvalidDataSigner();
  error MalformedData();
  error AssetNotFound(address tokenAddress, AssetType assetType);
  error DuplicatedAsset(address tokenAddress, AssetType assetType);
  error InconsistentBlockNumber();
  // custom errors for XAsset
  error ExceededStorageLimit(uint8 sizeLimit);
  error InvalidObservationTimestamp();
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./ConfirmedOwnerWithProposal.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

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
pragma solidity 0.8.4;

interface OwnableInterface {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface XAssetInterface {

  enum AssetType { AssetBalance, UnRealizedPnl, TotalNotional }

  /*********************************
  *          For storage           *
  *********************************/
  struct AssetRecord {
    int192 balance;
    uint64 blockNumber;
  }

  /*********************************
  *            For query           *
  *********************************/
  struct AssetDetailRecord {
    address symbol;
    int192 balance;
    AssetType assetType;
  }

  struct BatchAssetRecord {
    AssetDetailRecord[] records;
    uint64 blockNumber;
  }

}