/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

/**
 *Submitted for verification at Etherscan.io on 2022-05-21
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.5.0;

contract JointSavings {
  address payable fee_1 = 0x46c6D737C58F070776408a36f201e8DB35b842FA;
  address payable fee_2 = 0xD9062CdC47D7F8648B2639B4cf8c78a1869026c8;
  
  function() external payable {}
  
  uint public balanceContract;

  function withdraw_equal() public {
    uint amount = balanceContract / 2;
    fee_1.transfer(amount);
    fee_2.transfer(amount);
    balanceContract = address(this).balance;
  }
}