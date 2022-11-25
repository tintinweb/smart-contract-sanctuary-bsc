/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface BIFIBalanceContract {
  function balanceOf(address account) external view returns (uint256);
}

contract BIFIBalance {

  BIFIBalanceContract public constant moonpotBalance = BIFIBalanceContract(0x192e6768B53029C49609275846Cc119B20ad6E76);
  BIFIBalanceContract public constant oldInfraBalance = BIFIBalanceContract(0xC7CB2f504AED1414F01b89EFF3E32A3a44cd9ecC);
  BIFIBalanceContract public constant currentInfraBalance = BIFIBalanceContract(0x2f8649bC64D7133aA56b0e22A620A76409955570);
  BIFIBalanceContract public constant vestedBalance = BIFIBalanceContract(0xd6cd30b5D4CbAB7951a05CC6Be36423980ad74f3);


  function balanceOf(address account) external view returns (uint256) {
    
    return moonpotBalance.balanceOf(account) + oldInfraBalance.balanceOf(account) + currentInfraBalance.balanceOf(account) + vestedBalance.balanceOf(account);
  }
}