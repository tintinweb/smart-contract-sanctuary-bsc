//SPDX-License-Identifier: UNLICENSED

import "./ERC20.sol";

pragma solidity ^0.8.0;

contract CoinZero is ERC20 {
    constructor() ERC20("0TaxCoin", "CZ") {
        _mint(msg.sender, 1000000 * 10**18);
    }
}