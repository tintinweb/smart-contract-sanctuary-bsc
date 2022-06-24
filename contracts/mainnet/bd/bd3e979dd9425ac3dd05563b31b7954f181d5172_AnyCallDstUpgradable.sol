/**
 *Submitted for verification at BscScan.com on 2022-06-24
*/

// Sources flattened with hardhat v2.9.5 https://hardhat.org

// File contracts/AnyCallDstUpgradable.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AnyCallDstUpgradable{
  event NewMsg(string msg);

  //this function is supposed to be executed by mpc address and anycall contract
  function step2_createMsg(string calldata _msg) external {
    emit NewMsg(_msg);
  }
}