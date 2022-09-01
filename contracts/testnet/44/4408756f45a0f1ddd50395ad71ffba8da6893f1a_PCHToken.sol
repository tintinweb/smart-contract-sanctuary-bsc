// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./ERC20Burnable.sol";

contract PCHToken is ERC20, ERC20Burnable {
    constructor() ERC20("PCHToken", "PCH") {}
}