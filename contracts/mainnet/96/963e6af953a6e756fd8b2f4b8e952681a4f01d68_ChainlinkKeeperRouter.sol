// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { ChainlinkKeeperRegistryInterface } from "./ChainlinkKeeperRegistryInterface.sol";
import { ChainlinkPegSwapInterface } from "./ChainlinkPegSwapInterface.sol";
import { IERC20 } from "./IERC20.sol";
import { SafeERC20 } from "./SafeERC20.sol";

contract ChainlinkKeeperRouter {
  using SafeERC20 for IERC20;

  IERC20 public binancePeggedLINK;
  IERC20 public wrappedErc677LINK;

  ChainlinkPegSwapInterface public chainlinkPegSwap;
  ChainlinkKeeperRegistryInterface public chainlinkKeeperRegistry;

  constructor(
    IERC20 _binancePeggeedLINK,
    IERC20 _wrappedErc677LINK,
    ChainlinkPegSwapInterface _chainlinkPegSwap,
    ChainlinkKeeperRegistryInterface _chainlinkKeeperRegistry
  ) {
    binancePeggedLINK = _binancePeggeedLINK;
    wrappedErc677LINK = _wrappedErc677LINK;
    chainlinkPegSwap = _chainlinkPegSwap;
    chainlinkKeeperRegistry = _chainlinkKeeperRegistry;
  }

  function addFunds(uint256 id, uint96 amount) external {
    binancePeggedLINK.safeTransferFrom(msg.sender, address(this), amount);

    // Swap from Binance Pegged to Wrapped ERC677 LINK
    binancePeggedLINK.safeApprove(address(chainlinkPegSwap), amount);
    chainlinkPegSwap.swap(
      amount,
      address(binancePeggedLINK),
      address(wrappedErc677LINK)
    );

    // Add funds to the keeper
    wrappedErc677LINK.safeApprove(address(chainlinkKeeperRegistry), amount);
    chainlinkKeeperRegistry.addFunds(id, amount);
  }
}