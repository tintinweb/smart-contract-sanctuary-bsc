// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ERC20.sol";

contract Token is ERC20 {

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 10000 * (10 ** 18));
    }

    function _claim (address recipient , uint amount) external {
        require(recipient != address(0), "Can't claim tokens to zero address");
      _mint(recipient, amount);
    }
}