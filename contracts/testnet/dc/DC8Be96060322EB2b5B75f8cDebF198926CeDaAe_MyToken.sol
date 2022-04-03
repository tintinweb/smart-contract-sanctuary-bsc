// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract MyToken is ERC20 {
    constructor() ERC20("ipfs2", "IPFS2") {
        _mint(msg.sender, 10000000 * 10 ** decimals());
    }
}