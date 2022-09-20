// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract XTO is ERC20 {
    string public constant coin_name = "XTO";
    string public constant coin_symbol = "XTO";

    uint256 public coin_init_supply_count = 2100000000;

    uint256 public coin_decimals = 18;

    constructor() ERC20(coin_name, coin_symbol) {
        _mint(msg.sender, coin_init_supply_count * ( 10 ** coin_decimals));
    }
}