// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "./ConfirmedOwner.sol";
import "../interfaces/ReadWriteAccessControllerInterface.sol";

/**
 * @title ReadWriteAccessController
 * @notice Grants read and write permissions to the aggregator
 * @dev does not make any special permissions for EOAs, see
 * ReadAccessController for that.
 */
contract AggregatorReadWriteAccessController is ReadWriteAccessControllerInterface, ConfirmedOwner(msg.sender) {
  mapping(address => bool) internal s_readAccessList;
  mapping(address => bool) internal s_writeAccessList;

  event ReadAccessAdded(address user, address sender);
  event ReadAccessRemoved(address user, address sender);
  event WriteAccessAdded(address user, address sender);
  event WriteAccessRemoved(address user, address sender);

  /**
   * @notice Returns the read access of an address
   * @param user The address to query
   */
  function hasReadAccess(address user) external view virtual override returns (bool) {
    return s_readAccessList[user];
  }

  /**
   * @notice Returns the write access of an address
   * @param user The address to query
   */
  function hasWriteAccess(address user) external view virtual override returns (bool) {
    return s_writeAccessList[user];
  }

  /**
   * @notice Revokes read access of a address if  already added
   * @param user The address to remove
   */
  function removeReadAccess(address user) external onlyOwner {
    _removeReadAccess(user);
  }

  /**
   * @notice Provide read access to a address
   * @param user The address to add
   */
  function addReadAccess(address user) external onlyOwner {
    _addReadAccess(user);
  }

  /**
   * @notice Revokes write access of a address if already added
   * @param user The address to remove
   */
  function removeWriteAccess(address user) external onlyOwner {
    _removeWriteAccess(user);
  }

  /**
   * @notice Provide write access to a address
   * @param user The address to add
   */
  function addWriteAccess(address user) external onlyOwner {
    _addWriteAccess(user);
  }

  function _addReadAccess(address user) internal {
    if (!s_readAccessList[user]) {
      s_readAccessList[user] = true;
      emit ReadAccessAdded(user, msg.sender);
    }
  }

  function _removeReadAccess(address user) internal {
    if (s_readAccessList[user]) {
      s_readAccessList[user] = false;
      emit ReadAccessRemoved(user, msg.sender);
    }
  }

  function _addWriteAccess(address user) internal {
    if (!s_writeAccessList[user]) {
      s_writeAccessList[user] = true;
      emit WriteAccessAdded(user, msg.sender);
    }
  }

  function _removeWriteAccess(address user) internal {
    if (s_writeAccessList[user]) {
      s_writeAccessList[user] = false;
      emit WriteAccessRemoved(user, msg.sender);
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "./ConfirmedOwnerWithProposal.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

interface ReadWriteAccessControllerInterface {
  function hasReadAccess(address user) external view returns (bool);

  function hasWriteAccess(address user) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

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
pragma solidity 0.8.2;

interface OwnableInterface {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}