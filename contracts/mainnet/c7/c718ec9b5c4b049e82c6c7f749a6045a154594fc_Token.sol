// SPDX-License-Identifier: TIM

pragma solidity ^0.8.0;

import "./ERC20.sol";

contract Token is ERC20 {

    constructor () ERC20("ArtKit", "ARTI") {
        _mint(msg.sender, 100000000000 * (10 ** uint256(decimals())));
    }
}