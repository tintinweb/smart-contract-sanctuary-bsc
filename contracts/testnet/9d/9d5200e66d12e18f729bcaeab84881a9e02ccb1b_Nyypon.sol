// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";

contract Nyypon is ERC20 {
	constructor() ERC20("Nyypon", "NYPN") {
		_mint(msg.sender, 1000000 * (10 ** uint256(decimals())));
	}
}