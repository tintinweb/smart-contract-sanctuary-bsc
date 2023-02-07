// SPDX-License-Identifier: MIT
/**
  ∩~~~~∩ 
  ξ ･×･ ξ 
  ξ　~　ξ 
  ξ　　 ξ 
  ξ　　 “~～~～〇 
  ξ　　　　　　 ξ 
  ξ ξ ξ~～~ξ ξ ξ 
　 ξ_ξξ_ξ　ξ_ξξ_ξ
Alpaca Fin Corporation
*/

pragma solidity 0.8.12;

import { Ownable } from "./Ownable.sol";
import { IntervalKeepers } from "./IntervalKeepers.sol";
import { ReentrancyGuard } from "./ReentrancyGuard.sol";
import { KeeperCompatibleInterface } from "./KeeperCompatible.sol";
import { IAip15 } from "./IAip15.sol";

/// @title Aip15 Harvest Keeper - A Chainlink's Keepers compatible contract
/// for harvesting AIP15 rewards.
/// @dev The downstream contract must implement the IAip15 interface.
/// @author spicysquid168
// solhint-disable not-rely-on-time
contract Aip15HarvestKeeper is
  Ownable,
  ReentrancyGuard,
  IntervalKeepers,
  KeeperCompatibleInterface
{
  /// Errors
  error EmissionBridgeKeeper_NotPassTriggerWei();

  /// Configs
  IAip15 public aip15;

  /// Events
  event LogPerformUpkeep(uint256 _timestamp);
  event LogSetTriggerWei(uint256 _prevTriggerWei, uint256 _triggerWei);

  constructor(
    string memory _name,
    uint256 _interval,
    IAip15 _aip15
  ) IntervalKeepers(_name, _interval) {
    // Effect
    aip15 = IAip15(_aip15);
  }

  function checkUpkeep(bytes calldata _checkData)
    external
    view
    override
    returns (bool, bytes memory)
  {
    return _checkUpkeep(_checkData);
  }

  function performUpkeep(
    bytes calldata /* _performData */
  ) external nonReentrant {
    lastTimestamp = block.timestamp;

    aip15.harvest();
    emit LogPerformUpkeep(block.timestamp);
  }
}