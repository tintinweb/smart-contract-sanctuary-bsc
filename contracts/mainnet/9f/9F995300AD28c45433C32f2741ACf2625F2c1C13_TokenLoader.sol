/**
 *Submitted for verification at BscScan.com on 2022-11-04
*/

// SPDX-License-Identifier: No license
pragma solidity >=0.8.14;

interface IERC20 {
	function name() external view returns (string memory);

	function symbol() external view returns (string memory);

	function decimals() external view returns (uint256);
}

contract TokenLoader {
	struct TokenInfo {
		string name;
		string symbol;
		uint256 decimals;
	}

	function load(IERC20 token) external view returns (TokenInfo memory info) {
		info.name = token.name();
		info.symbol = token.symbol();
		info.decimals = token.decimals();
	}
}