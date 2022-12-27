// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "./BEP20.sol";

contract APRA is BEP20{

  /**
  * @param wallet Address of the wallet, where tokens will be transferred to
  */
  constructor(address wallet, address feeWallet) BEP20("Apraemio", "APRA", 1, feeWallet){
    _mint(wallet, uint256(1_000_000_000) * 1 ether);
  }
}