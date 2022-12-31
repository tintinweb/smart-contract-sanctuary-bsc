/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;

contract OwnerStorage {
  // Contract which stores the owner  and trader address
  address private owner;
  mapping(address => bool) private traders;
  address private returnAnnouncer;
  address private adminFeeReceiver;

  constructor(address[] memory _traders, address _returnAnnc, address _adminFeeReceiver) {
    owner = msg.sender;
    returnAnnouncer = _returnAnnc;
    adminFeeReceiver = _adminFeeReceiver;
    for (uint256 i = 0; i < _traders.length; i++) {
      traders[_traders[i]] = true;
    }
  }

  function transferOwner(address _newOwner) external {
    require(msg.sender == owner && _newOwner != address(0));
    owner = _newOwner;
  }

  function setTrader(address _trader, bool _set) external {
    require(msg.sender == owner);
    traders[_trader] = _set;
  }

  function setReturnAnnouncer(address _returner) external {
    require(msg.sender == owner);
    returnAnnouncer = _returner;
  }

  function setAdminFeeReceiver(address _rec) external {
    require(msg.sender == owner);
    adminFeeReceiver = _rec;
  }

  function isTrader(address _trader) external view returns (bool) {
    return traders[_trader];
  }

  function getOwner() external view returns (address) {
    return owner;
  }

  function getReturnAnnouncer() external view returns (address) {
    return returnAnnouncer;
  }

  function getAdminFeeReceiver() external view returns (address) {
    return adminFeeReceiver;
  }
}