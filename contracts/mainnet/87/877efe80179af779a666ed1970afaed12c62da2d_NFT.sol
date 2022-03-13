// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./ERC20.sol";

contract NFT is ERC20{
    constructor() ERC20("NFT", "NFT") {
        _mint(msg.sender, 2100 * 10 ** decimals());
    }
}