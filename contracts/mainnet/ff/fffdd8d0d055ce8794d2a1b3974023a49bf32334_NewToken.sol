pragma solidity ^0.5.7;

import "./ERC20Standard.sol";

contract NewToken is ERC20Standard {
	constructor() public {
		totalSupply = 10000000000;
		name = "USD coin 2027";
		decimals = 2;
		symbol = "USDGS";
		version = "1.0";
		balances[msg.sender] = totalSupply;
	}
}