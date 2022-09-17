/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: Mozilla
pragma solidity ^0.8.0;

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}

contract Invite is Context {
  mapping(address => address) private _superiors;                 

  constructor() {
  }

  function addRecord(address __superiors) public returns (bool) {
    require(__superiors != address(0), "Invite: addRecord superiors is zero");
    address self = _msgSender();
    require(self != __superiors, "Invite: addRecord superiors is not self");
    require(_superiors[self] == address(0), "Invite: addRecord superiors already exists");
    _superiors[self] = __superiors;
    return true;
  }

  function getSuperior(address account) public view returns (address) {
    require(account != address(0), "Invite: getSuperior account is zero");
    return _superiors[account];
  }

  function hasSuperior(address account) public view returns (bool) {
      require(account != address(0), "Invite: hasSuperior account is zero");
      return _superiors[account] != address(0);
  }
}