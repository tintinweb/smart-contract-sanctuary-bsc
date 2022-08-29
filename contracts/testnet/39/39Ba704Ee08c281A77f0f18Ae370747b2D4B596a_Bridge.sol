// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bridge {
  event BridgeTransferred(
    address from,
    uint256 fromChainId,
    address to,
    uint256 toChainId,
    uint256 amount,
    address tokenAddress,
    bool isNativeCoin
  );

  function Transfer(
    uint256 fromChainId,
    address to,
    uint256 toChainId,
    uint256 amount,
    address tokenAddress,
    bool isNativeCoin
  ) external {
    emit BridgeTransferred(
      msg.sender,
      fromChainId,
      to,
      toChainId,
      amount,
      tokenAddress,
      isNativeCoin
    );
  }
}