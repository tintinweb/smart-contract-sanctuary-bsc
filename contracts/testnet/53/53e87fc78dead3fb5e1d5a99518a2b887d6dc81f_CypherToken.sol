// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract CypherToken is ERC20 {
  constructor() ERC20("Cypher Token", "CYPHER") {
        _mint(address(this), 50000000 * (10 ** uint256(decimals())));
        _approve(address(this), msg.sender, totalSupply());
        _transfer(address(this), msg.sender, totalSupply());
  }
}