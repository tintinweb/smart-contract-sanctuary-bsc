// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

library EasyMath {
	/// @dev Amount - amount * slippage
  /// @param a Amount of token
  /// @param s Desired slippage in 10^4 (e.g. 0.01% => 0.01e4 => 100)
	function amountLessSlippage(uint256 a, uint256 s) public pure returns (uint256) {
    return (a * (10 ** 6 - s)) / 10 ** 6;
  }

  /// @dev Amount + amount * slippage
  /// @param a Amount of token
  /// @param s Desired slippage in 10^4 (e.g. 0.01% => 0.01e4 => 100)
  function amountMoreSlippage(uint256 a, uint256 s) public pure returns (uint256) {
    // slippage: 0.5e4 (0.5%)
    return (a * (10 ** 6 + s)) / 10 ** 6;
  }
}