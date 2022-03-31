// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./BEP20.sol";

contract QOOMED is BEP20("QOOMED", "QOOMED") {

  /**
  * @param wallet Address of the wallet, where tokens will be transferred to
  */
  constructor(address wallet) {
    _mint(wallet, uint256(5000000000) * 1 ether);
  }
}