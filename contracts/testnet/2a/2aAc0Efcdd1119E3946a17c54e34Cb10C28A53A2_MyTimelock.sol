// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "./TimelockController.sol";

contract MyTimelock is TimelockController {
    constructor(uint256 delay, address[] memory proposers, address[] memory executors, address admin) TimelockController(delay, proposers, executors, admin) {}
}