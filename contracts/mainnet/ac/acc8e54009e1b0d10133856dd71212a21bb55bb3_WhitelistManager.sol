/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

// SPDX-License-Identifier: --🌲--

pragma solidity ^0.8.0;

/**
 * @title Treedefi whitelist Manager Version 1.0
 *
 * @author Treedefi
 */
contract WhitelistManager {
  // Admin address
  address public admin;

  // Mapping from address to whitelist  
  mapping(address => bool) public isWhitelisted;

  /**
   * @dev Fired in transferAdminship() when ownership is transferred
   *
   * @param _previousAdmin an address of previous owner
   * @param _newAdmin an address of new owner
   */
  event AdminshipTransferred(address indexed _previousAdmin, address indexed _newAdmin);

  /**
   * @dev Fired in addToWhitelist() and removeFromWhitelist() when address is added into/removed from
   *      whitelist
   *
   * @param account an address of user
   * @param isAllowed defines if address is added or removed
   */
  event Whitelist(address account, bool isAllowed);

  /**
   * @dev Creates/deploys Treedefi whitelist Manager Version 1.0
   *
   * @param admin_ address of admin
   */
  constructor(address admin_)
  {
    // Setup smart contract internal state
    admin = admin_;
  }

  /**
   * @dev Transfer adminship to given address
   *
   * @notice restricted function, should be called by admin only
   * @param newAdmin_ address of new owner
   */
  function transferAdminship(address newAdmin_) external {
    require(msg.sender == admin, "Only admin can transfer ownership");

    // Update admin address
    admin = newAdmin_;
    
    // Emits an event
    emit AdminshipTransferred(msg.sender, newAdmin_);
  }

  /**
   * @dev Adds addresses to whitelist 
   *
   * @notice restricted function, should be called by owner only
   * @param allowed_ address list that will be added to the whitelist
   */
  function addToWhitelist(address[] memory allowed_) external {
    require(msg.sender == admin, "Access denied");

    for(uint8 i; i < allowed_.length; i++) {
        // Add address to the list
        isWhitelisted[allowed_[i]] = true;

        // Emit an event
        emit Whitelist(allowed_[i], true);
    }
  }

  /**
   * @dev Removes addresses from whitelist
   *
   * @notice restricted function, should be called by owner only
   * @param notAllowed_ address list that will be removed from the whitelist
   */
  function removeFromWhitelist(address[] memory notAllowed_) external {
    require(msg.sender == admin, "Access denied");

    for(uint8 i; i < notAllowed_.length; i++) {
        // Remove address from the list
        isWhitelisted[notAllowed_[i]] = false;

        // Emit an event
        emit Whitelist(notAllowed_[i], false);
    }
  }
}