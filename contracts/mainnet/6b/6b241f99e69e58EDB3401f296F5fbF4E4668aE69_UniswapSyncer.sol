// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    function sync() external;
}

contract UniswapSyncer {
    address[] public pools;
    address admin;

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin");
        _;
    }
    constructor() {
        admin = msg.sender;
    }

    function addPools(address[] memory _pools) public onlyAdmin {
        for (uint256 i = 0; i < _pools.length; i++) {
            pools.push(_pools[i]);
        }
    }

    function removePoolByIndex(
        uint256 index
    ) public onlyAdmin returns (address) {
        require(index < pools.length);
        for (uint i = index; i < pools.length - 1; i++) {
            pools[i] = pools[i + 1];
        }
        address removedPool = pools[pools.length - 1];
        pools.pop();
        return removedPool;
    }

    function sync() public {
        for (uint i = 0; i < pools.length; i++) {
            IUniswapV2Pair(pools[i]).sync();
        }
    }
}