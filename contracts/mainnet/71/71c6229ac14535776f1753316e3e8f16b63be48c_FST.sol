// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./BEP20.sol";
import "./BEP20Burnable.sol";

contract FST is BEP20, BEP20Burnable {
    constructor() BEP20("FST", "FST") {}
}