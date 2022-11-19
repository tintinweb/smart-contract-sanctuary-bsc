//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import './Bank.sol';

contract BankFactory {

  Bank bank;

  Bank[] public list_of_banks;

 function createBank(address _owner, uint256 _funds) external {
    bank = new Bank(_owner, _funds);
    list_of_banks.push(bank);
  }
}