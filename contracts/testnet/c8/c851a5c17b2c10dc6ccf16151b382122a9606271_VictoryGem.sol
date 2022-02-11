// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20Burnable.sol";

contract VictoryGem is ERC20Burnable {
    uint256 private totalTokens;

    constructor() ERC20("Victory Gem", "VTG") {
        totalTokens = 1000000000 * 10**uint(decimals());
        _mint(msg.sender, totalTokens);
    }

    /**
     * Transfer tokens to the provided list of recipients with respective amount
     *
     * Requirements:
     *
     * - `recipients` and `amounts` should have same length.
     */
    function batchTransfer(address[] calldata recipients, uint256[] calldata amounts) external returns (bool) {
      require(recipients.length == amounts.length, "Invalid input parameters");

      for(uint256 indx = 0; indx < recipients.length; indx++) {
          _transfer(_msgSender(), recipients[indx], amounts[indx]);
      }
      return true;
  }

    /**
     * Total number of burned tokens
     */
    function getBurnedAmountTotal() external view returns (uint256 _amount) {
        uint256 _totalSupply = totalSupply();
        require(totalTokens >= _totalSupply, "Invalid total suuply");
        return totalTokens - _totalSupply;
    }
}