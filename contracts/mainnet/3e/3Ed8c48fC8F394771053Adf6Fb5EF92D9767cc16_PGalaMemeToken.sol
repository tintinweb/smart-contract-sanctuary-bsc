// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "ERC20.sol";
import "Ownable.sol";

contract PGalaMemeToken is ERC20, Ownable {
    constructor() ERC20("PGala Meme Token", "PGALA") {
        _mint(msg.sender, 621101458257982347 * 10 ** (decimals() - 8));
    }
}