// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";

contract MTC is ERC20, Ownable {
    constructor() ERC20("MTC", "MTC") {
        _mint(address(0x1748f4bc45832C7A132e4214541BdE9FCfF10D7B), 50000000 * (10 ** uint256(decimals())));
    }
}