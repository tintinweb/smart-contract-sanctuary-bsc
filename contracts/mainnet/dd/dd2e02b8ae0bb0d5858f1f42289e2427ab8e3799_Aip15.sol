// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { OwnableUpgradeable } from "./OwnableUpgradeable.sol";
import { Initializable } from "./Initializable.sol";
import { ERC20Upgradeable } from "./ERC20Upgradeable.sol";
import { SafeERC20Upgradeable } from "./SafeERC20Upgradeable.sol";
import { IFairLaunch } from "./IFairLaunch.sol";
import { IProxyToken } from "./IProxyToken.sol";

contract Aip15 is Initializable, OwnableUpgradeable {
  // dependencies
  using SafeERC20Upgradeable for ERC20Upgradeable;

  // configurations
  IFairLaunch public fairLaunch;
  uint256 public febEmissionPoolId;
  ERC20Upgradeable public febEmissionDummy;
  ERC20Upgradeable public alpaca;
  uint256 public targetEmission;

  // states
  bool public isStarted;
  bool public isReached;

  event DepositFebEmissionDummy();
  event SetTargetEmission(
    uint256 prevTargetEmission,
    uint256 newTargetEmission
  );
  event WithdrawFebEmissionDummy();

  function initialize(
    IFairLaunch _fairLaunch,
    ERC20Upgradeable _febEmissionDummy,
    uint256 _febEmissionPoolId,
    uint256 _targetEmission
  ) external initializer {
    // Check
    (address shouldBeFebEmissionDummy, , , , ) = _fairLaunch.poolInfo(
      _febEmissionPoolId
    );
    require(
      shouldBeFebEmissionDummy == address(_febEmissionDummy),
      "bad febEmissionPoolId"
    );
    require(_targetEmission >= 240_000 ether, "bad targetEmission");

    OwnableUpgradeable.__Ownable_init();
    // Default state
    isStarted = false;
    isReached = false;

    // Assign configurations
    fairLaunch = _fairLaunch;
    febEmissionDummy = _febEmissionDummy;
    febEmissionPoolId = _febEmissionPoolId;
    alpaca = ERC20Upgradeable(fairLaunch.alpaca());
    targetEmission = _targetEmission;
  }

  /// @notice Deposit FEB_EMISSION_DUMMY to FairLaunch.
  function depositFebEmissionDummy() external onlyOwner {
    // Check
    // Only allow to deposit FEB_EMISSION_DUMMY once.
    require(!isStarted, "started");

    // Effect
    isStarted = true;

    // Interaction
    IProxyToken(address(febEmissionDummy)).mint(address(this), 1e18);
    febEmissionDummy.safeApprove(address(fairLaunch), 1e18);
    fairLaunch.deposit(address(this), febEmissionPoolId, 1e18);

    // Log
    emit DepositFebEmissionDummy();
  }

  /// @notice Withdraw FEB_EMISSION_DUMMY from FairLaunch.
  function withdrawFebEmissionDummy() external {
    // Check
    require(!isReached, "reached");
    uint256 balance = alpaca.balanceOf(address(this)) +
      fairLaunch.pendingAlpaca(febEmissionPoolId, address(this));
    // Only allow to withdraw FEB_EMISSION_DUMMY once ALPACA balance + pending ALPACA more than targetEmission.
    require(balance >= targetEmission, "!reached");

    // Effect
    isReached = true;

    // Interaction
    // Withdraw FEB_EMISSION_DUMMY from FairLaunch.
    fairLaunch.withdraw(address(this), febEmissionPoolId, 1e18);
    // Burn FEB_EMISSION_DUMMY.
    IProxyToken(address(febEmissionDummy)).burn(address(this), 1e18);
    // Withdraw all ALPACA from Aip15 to owner.
    // Use balanceOf(address(this)) instead of balance to avoid leftover ALPACA
    // due to withdraw also harvest ALPACA.
    alpaca.safeTransfer(owner(), alpaca.balanceOf(address(this)));

    // Log
    emit WithdrawFebEmissionDummy();
  }

  /// @notice Harvest ALPACA from FairLaunch.
  function harvest() external {
    fairLaunch.harvest(febEmissionPoolId);
  }

  /// @notice Set target emission.
  /// @param _targetEmission Target emission.
  function setTargetEmission(uint256 _targetEmission) external onlyOwner {
    require(_targetEmission >= 240_000 ether, "bad targetEmission");
    emit SetTargetEmission(targetEmission, _targetEmission);
    targetEmission = _targetEmission;
  }
}