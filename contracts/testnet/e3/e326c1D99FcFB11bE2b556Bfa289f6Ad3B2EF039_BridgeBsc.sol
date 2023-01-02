// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './BridgeBase.sol';

contract BridgeBsc is BridgeBase {
  constructor(address token) BridgeBase(token) {}
}