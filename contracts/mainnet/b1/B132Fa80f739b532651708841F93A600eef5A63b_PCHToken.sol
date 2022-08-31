// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./BEP20.sol";
import "./BEP20Burnable.sol";

contract PCHToken is BEP20, BEP20Burnable {
    constructor() BEP20("PCHToken", "PCH") {}
}