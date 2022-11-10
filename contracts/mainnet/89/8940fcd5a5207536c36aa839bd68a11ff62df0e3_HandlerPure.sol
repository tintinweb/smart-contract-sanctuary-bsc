// SPDX-License-Identifier: BSD-3-Clause

pragma solidity 0.8.17;

import "./Bank.sol";

contract HandlerPure is Bank {  

  constructor(address[] memory _addr, uint[] memory _perc, uint[] memory _amount, bool[] memory _withdraw) {
    reEntryStatus = ENTRY_ENABLED;
    owner = msg.sender;

    uint percentage = 0;

    for (uint i = 0;i < _addr.length;i++) {
      percentage = percentage + _perc[i];
    }

    require(percentage == 100, "Percentage does not equal 100%");

    for (uint i=0;i < _addr.length;i++) {
      if (i == 0) {
        createAccount(_addr[i], address(this).balance, _perc[i], _amount[i], _withdraw[i]);
      } else {
        createAccount(_addr[i], 0, _perc[i], _amount[i], _withdraw[i]);
      }
    }
  }
}