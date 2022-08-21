// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";

contract DistributedResourceToken is ERC20, Ownable {
    constructor() ERC20("Distributed Resource Token", "DRT") {
        _mint(msg.sender, 10000000 * 10 ** decimals());
    }
}