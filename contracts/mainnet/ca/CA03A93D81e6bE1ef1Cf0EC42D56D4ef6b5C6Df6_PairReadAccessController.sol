// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "./EOAContext.sol";
import "../interfaces/PairReadAccessControllerInterface.sol";
import "./ConfirmedOwner.sol";

/**
 * @title PairReadAccessController
 * @notice Controls read access for FeedRegistry and FeedAdapter
 * @notice Gives access to:
 * - any externally owned account (note that offchain actors can always read
 * any contract storage regardless of onchain access control measures, so this
 * does not weaken the access control while improving usability)
 * - accounts explicitly added to an access list (global access)
 * - accounts for specific pairs (local access)
 * - some pairs open to everybody
 */
contract PairReadAccessController is PairReadAccessControllerInterface, EOAContext, ConfirmedOwner(msg.sender) {
  bool private s_checkEnabled = true;
  mapping(address => bool) internal s_globalAccessList;
  mapping(address => mapping(address => mapping(address => bool))) internal s_localAccessList;
  mapping(address => mapping(address => bool)) internal s_openAccessList;

  event GlobalAccessAdded(address user);
  event GlobalAccessRemoved(address user);
  event PairAccessAdded(address user, address base, address quote);
  event PairAccessRemoved(address user, address base, address quote);
  event OpenAccessAdded(address base, address quote);
  event OpenAccessRemoved(address base, address quote);
  event CheckAccessEnabled();
  event CheckAccessDisabled();

  /**
   * @notice Returns the access of an address to an base / quote pair
   * @param user The address to whitelist
   */
  function hasGlobalAccess(address user) external view override returns (bool) {
    return !s_checkEnabled || s_globalAccessList[user] || _isEOA(user);
  }

  /**
   * @notice Checks if the pair is allowed for the given user
   * @param user The querying contract/ EOA address
   * @param base base token canonical address
   * @param quote quote token canonical address
   */
  function hasPairAccess(
    address user,
    address base,
    address quote
  ) external view override returns (bool) {
    return
      !s_checkEnabled ||
      s_globalAccessList[user] ||
      s_localAccessList[user][base][quote] ||
      s_openAccessList[base][quote] ||
      _isEOA(user);
  }

  function checkEnabled() external view returns (bool) {
    return s_checkEnabled;
  }

  /**
   * @notice Adds an address to the global access list
   * @param user The address to add
   */
  function addGlobalAccess(address user) external onlyOwner {
    _addGlobalAccess(user);
  }

  /**
   * @notice Adds an address+ pair data to the local access list
   * @param user The address to add
   * @param base base token canonical address
   * @param quote quote token canonical address
   */
  function addLocalAccess(
    address user,
    address base,
    address quote
  ) external onlyOwner {
    _addLocalAccess(user, base, quote);
  }

  /**
   * @notice Adds an address+ pair data to the local access list
   * @param base base token canonical address
   * @param quote quote token canonical address
   */
  function addPairToOpenAccess(address base, address quote) external onlyOwner {
    _addOpenAccess(base, quote);
  }

  /**
   * @notice Removes an address from the global access list
   * @param user The address to remove
   */
  function removeGlobalAccess(address user) external onlyOwner {
    _removeGlobalAccess(user);
  }

  /**
   * @notice Removes an address+ pair data from the local access list
   * @param user The address to remove
   * @param base base token canonical address
   * @param quote quote token canonical address
   */
  function removeLocalAccess(
    address user,
    address base,
    address quote
  ) external onlyOwner {
    _removeLocalAccess(user, base, quote);
  }

  /**
   * @notice Removes a pair from the open access list
   * @param base base token canonical address
   * @param quote quote token canonical address
   */
  function removePairFromOpenAccess(address base, address quote) external onlyOwner {
    _removeOpenAccess(base, quote);
  }

  /**
   * @notice makes the access check enforced
   */
  function enableAccessCheck() external onlyOwner {
    _enableAccessCheck();
  }

  /**
   * @notice makes the access check unenforced
   */
  function disableAccessCheck() external onlyOwner {
    _disableAccessCheck();
  }

  function _enableAccessCheck() internal {
    if (!s_checkEnabled) {
      s_checkEnabled = true;
      emit CheckAccessEnabled();
    }
  }

  function _disableAccessCheck() internal {
    if (s_checkEnabled) {
      s_checkEnabled = false;
      emit CheckAccessDisabled();
    }
  }

  function _addGlobalAccess(address user) internal {
    if (!s_globalAccessList[user]) {
      s_globalAccessList[user] = true;
      emit GlobalAccessAdded(user);
    }
  }

  function _removeGlobalAccess(address user) internal {
    if (s_globalAccessList[user]) {
      s_globalAccessList[user] = false;
      emit GlobalAccessRemoved(user);
    }
  }

  function _addLocalAccess(
    address user,
    address base,
    address quote
  ) internal {
    if (!s_localAccessList[user][base][quote]) {
      s_localAccessList[user][base][quote] = true;
      emit PairAccessAdded(user, base, quote);
    }
  }

  function _removeLocalAccess(
    address user,
    address base,
    address quote
  ) internal {
    if (s_localAccessList[user][base][quote]) {
      s_localAccessList[user][base][quote] = false;
      emit PairAccessRemoved(user, base, quote);
    }
  }

  function _addOpenAccess(address base, address quote) internal {
    if (!s_openAccessList[base][quote]) {
      s_openAccessList[base][quote] = true;
      emit OpenAccessAdded(base, quote);
    }
  }

  function _removeOpenAccess(address base, address quote) internal {
    if (s_openAccessList[base][quote]) {
      s_openAccessList[base][quote] = false;
      emit OpenAccessRemoved(base, quote);
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

/*
 * @dev Provides information about the current execution context, specifically on if an account is an EOA on that chain.
 * Different chains have different account abstractions, so this contract helps to switch behaviour between chains.
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract EOAContext {
  function _isEOA(address account) internal view virtual returns (bool) {
    return account == tx.origin; // solhint-disable-line avoid-tx-origin
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

interface PairReadAccessControllerInterface {
  function hasGlobalAccess(address user) external view returns (bool);

  function hasPairAccess(
    address user,
    address base,
    address quote
  ) external view returns (bool);
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