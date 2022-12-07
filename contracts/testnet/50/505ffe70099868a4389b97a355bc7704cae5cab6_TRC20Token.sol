// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TRC20.sol";
import "./Ownable.sol";

contract TRC20Token is TRC20, Ownable {
    constructor() TRC20("FAST SWAP TOKEN", "FST") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}