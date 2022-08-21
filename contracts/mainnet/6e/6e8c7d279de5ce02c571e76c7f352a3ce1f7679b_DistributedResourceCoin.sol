// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";

contract DistributedResourceCoin is ERC20, Ownable {
    constructor() ERC20("Distributed Resource Coin", "DRC") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}