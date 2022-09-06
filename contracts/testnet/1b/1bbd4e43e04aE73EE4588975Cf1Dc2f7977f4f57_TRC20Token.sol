// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BNP20.sol";
import "./Ownable.sol";

contract TRC20Token is BNP20, Ownable {
    constructor() BNP20("Tron", "TRX") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}