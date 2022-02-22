// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./CloneFactory.sol";

contract PoolFactoryUpgrade {
    /* constrant address for temporary store */
    address poolFactoryAddress = 0x4ff306Bd02832B1168FE1613Edf092887b43a3e2;

    CloneFactory cloneFactory;

    address[] public deployedPools;

    constructor(address _cloneFactoryAddress) {
        cloneFactory = CloneFactory(_cloneFactoryAddress);
    }

    function createFund() public {
        address deployedPool = cloneFactory.deployPool(poolFactoryAddress);
        deployedPools.push(deployedPool);
    }
}