/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface Token {
  function balanceOf(address account) external view returns (uint256);
}

interface LP {
  function balanceOf(address account) external view returns (uint256);
  function totalSupply() external view returns (uint256);
}

interface LPVault {
  function want() external view returns (LP);
  function balanceOf(address account) external view returns (uint256);
  function getPricePerFullShare() external view returns (uint256);
  function totalSupply() external view returns (uint256);
}

interface MoonpotGate {
  function userTotalBalance(address user) external view returns (uint256);
}


contract POTSLPBalance {

  Token public POTS;
  LPVault public vault;
  MoonpotGate public moonpotGate;

  constructor(Token _POTS, LPVault _vault, MoonpotGate _moonpotGate) {
    POTS = _POTS;
    vault = _vault;
    moonpotGate = _moonpotGate;
  }

  function lpToPOTSRatio() public view returns (uint256) {
    LP lp = vault.want();
    uint256 lpTotalSupply = lp.totalSupply();
    uint256 lpPOTSBalance = POTS.balanceOf(address(lp));
    return lpPOTSBalance * 1e18 / lpTotalSupply;
  }

  function balanceOf(address account) external view returns (uint256) {
    uint256 ratio = lpToPOTSRatio();
    uint256 ppfs = vault.getPricePerFullShare();
    uint256 amountOfLp = vault.balanceOf(account) * ppfs / 1e18 + vault.want().balanceOf(account) + moonpotGate.userTotalBalance(account);
    return amountOfLp * ratio / 1e18;
  }

}