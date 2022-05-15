// SPDX-License-Identifier: MIT
import "./IERC20.sol";
pragma solidity >=0.4.22 <0.9.0;

contract BalanceContract {
  struct Amount {
    address token;
    uint256 balance;
  }

  function getBalances(address _walletAddress, address[] memory _tokenAddresses) public view returns (Amount[] memory) {
    Amount[] memory tokenAmounts;
    for (uint256 i=0; i < _tokenAddresses.length; i++) {
      IERC20 token = IERC20(_tokenAddresses[i]);
      uint256 balance = token.balanceOf(_walletAddress);
      Amount memory _tokenAmount = Amount(_tokenAddresses[i],balance);
      tokenAmounts[i] = _tokenAmount;
    }
    return tokenAmounts;
  }
}