// SPDX-License-Identifier: BSD-3-Clause

pragma solidity 0.8.17;

import "./Bank.sol";

contract Distribute is Bank {

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

  function reviewAgreement(uint _account) external hasAccount(msg.sender) {
    require(agreementAmount[_account] > 0, "No agreement on account");

    if (accountStorage[accountLookup[_account]].received > agreementAmount[_account]) {
      agreementAmount[_account] = 0;
      subPercentage(accountLookup[_account], 72);
      deleteAccount(accountLookup[_account], accountLookup[0]);
      addPercentage(accountLookup[1], 18);
      addPercentage(accountLookup[2], 18);
      addPercentage(accountLookup[3], 18);
      addPercentage(accountLookup[4], 14);
      addPercentage(accountLookup[5], 4);
    }
  }

  function isAgreementCompleted(uint _account) external view hasAccount(msg.sender) returns (bool) {
    return agreementAmount[_account] == 0;
  }
}