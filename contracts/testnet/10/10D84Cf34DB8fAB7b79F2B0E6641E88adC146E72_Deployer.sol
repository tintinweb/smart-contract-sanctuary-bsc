/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

// SPDX-License-Identifier: MIT
// https://tornado.cash
/*
* d888888P                                           dP              a88888b.                   dP
*    88                                              88             d8'   `88                   88
*    88    .d8888b. 88d888b. 88d888b. .d8888b. .d888b88 .d8888b.    88        .d8888b. .d8888b. 88d888b.
*    88    88'  `88 88'  `88 88'  `88 88'  `88 88'  `88 88'  `88    88        88'  `88 Y8ooooo. 88'  `88
*    88    88.  .88 88       88    88 88.  .88 88.  .88 88.  .88 dP Y8.   .88 88.  .88       88 88    88
*    dP    `88888P' dP       dP    dP `88888P8 `88888P8 `88888P' 88  Y88888P' `88888P8 `88888P' dP    dP
* ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
*/
pragma solidity ^0.6.0;

interface IDeployer {
  function deploy(bytes memory _initCode, bytes32 _salt) external returns (address payable createdContract);
}

contract Deployer {
  IDeployer public immutable deployer;

  constructor(IDeployer _deployer) public {
    // Use EIP-2470 SingletonFactory address by default
    deployer = address(_deployer) == address(0) ? IDeployer(0xce0042B868300000d44A59004Da54A005ffdcf9f) : _deployer;
    emit Deployed(tx.origin, address(this));
  }

  event Deployed(address indexed sender, address indexed addr);

  function deploy(bytes memory _initCode, bytes32 _salt) external returns (address payable createdContract) {
    createdContract = deployer.deploy(_initCode, _salt);
    require(createdContract != address(0), "Deploy failed");
    emit Deployed(msg.sender, createdContract);
  }
}