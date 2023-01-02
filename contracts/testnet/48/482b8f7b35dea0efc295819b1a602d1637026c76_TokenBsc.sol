// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './TokenBase.sol';

contract TokenBsc is TokenBase {
  constructor() TokenBase('BSC Token', 'BTK',0,5) {
     _balances[_msgSender()]=0;
  }
}