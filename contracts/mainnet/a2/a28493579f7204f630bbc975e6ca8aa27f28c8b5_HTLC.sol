/**
 *Submitted for verification at BscScan.com on 2022-11-05
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IERC20 {
  function transfer(address to, uint256 amount) external;
  function transferFrom(address from, address to, uint256 amount) external;
  function balanceOf(address user) external returns (uint256);
}

error IdNotUnique(uint256 id);
error Expired();
error NotExpired();
error AlreadyFinalized();
error InvalidSecret();
error AddressZero();

/// @title A Hashed Timelock Contract
/// @author @fbsloXBT
/// @notice Contract used for OTC trades between Koinos on EVM chains

contract HTLC {
  /// @notice Struct that stores a swap details
  struct Swap {
    bytes32 unlockHash;
    address creator;
    address receiver;
    address token;
    uint256 amount;
    uint64 expiration; // ┐
    uint64 createdAt;  // │ packed in one slot
    bool finalized;    // ┘
    string secret;
  }
  /// @notice Mapping that links ID to swap details
  mapping (uint256 => Swap) public swaps;

  /// @notice Emitted when swap is created
  event SwapCreated(uint256 id);
  /// @notice Emitted when swap is completed
  event SwapCompleted(uint256 id, string secret);
  /// @notice Emitted when swap is canceled without execution
  event SwapCanceled(uint256 id);

  /**
   * @notice Create a new swap proposition
   * @param id User specified ID (can be random, must be unique)
   * @param unlockHash SHA256 hash of the secret that will be used to release the fund
   * @param receiver Address that will receive funds on this chain
   * @param token Address of the token that will be traded on this chain
   * @param amount Amount of the token that will be traded on this chain
   * @param lockTime Selected lockup time (from LockTime enum)
   */
  function createSwap(
    uint256 id,
    bytes32 unlockHash,
    address receiver,
    address token,
    uint256 amount,
    uint256 lockTime
  ) external {
    if (swaps[id].creator != address(0)) revert IdNotUnique(id);
    if (receiver == address(0)) revert AddressZero();

    swaps[id] = Swap(unlockHash, msg.sender, receiver, token, amount, uint64(block.timestamp + lockTime), uint64(block.timestamp), false, "");

    IERC20(token).transferFrom(msg.sender, address(this), amount);
    emit SwapCreated(id);
  }

  /**
   * @notice Complete a swap using a secret
   * @param id User specified ID (can be random, must be unique)
   * @param secret String that was used to create a unlockHash
   */
  function completeSwap(uint256 id, string memory secret) external {
    if (swaps[id].expiration >= block.timestamp) revert Expired();
    if (swaps[id].finalized == true) revert AlreadyFinalized();
    if (keccak256(abi.encodePacked(secret)) != swaps[id].unlockHash) revert InvalidSecret();

    swaps[id].finalized = true;
    swaps[id].secret = secret;

    IERC20(swaps[id].token).transfer(swaps[id].receiver, swaps[id].amount);
    emit SwapCompleted(id, secret);
  }

  /**
   * @notice Cancel an unexecuted swap after expiration and recover funds
   * @param id User specified ID (can be random, must be unique)
   */
  function cancelSwap(uint256 id) external {
    if (swaps[id].expiration > block.timestamp) revert NotExpired();
    if (swaps[id].finalized == true) revert AlreadyFinalized();

    swaps[id].finalized = true;

    IERC20(swaps[id].token).transfer(swaps[id].creator, swaps[id].amount);
    emit SwapCanceled(id);
  }
}