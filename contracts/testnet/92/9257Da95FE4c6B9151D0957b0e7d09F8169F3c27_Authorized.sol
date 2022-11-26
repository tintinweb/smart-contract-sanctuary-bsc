// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "./Ownable.sol";
import "./IERC20.sol";

contract Authorized is Ownable {
  mapping(uint8 => mapping(address => bool)) internal permissions;

  constructor() {
    permissions[0][_msgSender()] = true; // admin
    permissions[1][_msgSender()] = true; // controller
  }

  modifier isAuthorized(uint8 index) {
    require(permissions[index][_msgSender()] == true, "Account does not have permission");
    _;
  }

  function safeApprove(
    address token,
    address spender,
    uint amount
  ) external isAuthorized(0) {
    IERC20(token).approve(spender, amount);
  }

  function safeTransfer(
    address token,
    address receiver,
    uint amount
  ) external isAuthorized(0) {
    IERC20(token).transfer(receiver, amount);
  }

  function grantPermission(address operator, uint8 typed) external isAuthorized(0) {
    permissions[typed][operator] = true;
  }

  function revokePermission(address operator, uint8 typed) external isAuthorized(0) {
    permissions[typed][operator] = false;
  }
}