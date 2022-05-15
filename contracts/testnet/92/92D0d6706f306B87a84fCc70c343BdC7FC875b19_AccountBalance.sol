// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IBEP20.sol";

contract AccountBalance {
  struct TokenAmount {
    address token;
    uint256 balance;
  }
  function getBalances(address _walletAddr, address[] memory _tokenAddrList) public view returns (TokenAmount[] memory) {
    TokenAmount[] memory tokenAmounts;
    for (uint i = 0; i < _tokenAddrList.length; i++) {
      IBEP20 token = IBEP20(_tokenAddrList[i]);
      uint256 balance = token.balanceOf(_walletAddr);
      TokenAmount memory _tokenAmount = TokenAmount(_tokenAddrList[i], balance);
      tokenAmounts[i] = _tokenAmount;
    }
    return tokenAmounts;
  }
}