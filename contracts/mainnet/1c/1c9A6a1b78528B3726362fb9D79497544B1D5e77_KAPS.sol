// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./BEP20.sol";

contract KAPS is BEP20("KAPS", "KAPS", 1, 0x5CEDA50c8B31c1c2FAA324Fd610c243EcD536781) {

  /**
  * @param wallet Address of the wallet, where tokens will be transferred to
  */
  constructor(address wallet) {
    _mint(wallet, uint256(50000000) * 1 ether);
  }
}