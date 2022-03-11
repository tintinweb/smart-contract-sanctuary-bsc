// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IPoolAdapter.sol";

// IPancakeMasterChefPool implementation can be found at
// https://github.com/pancakeswap/pancake-farm/blob/master/contracts/MasterChef.sol
interface IPancakeMasterChefPool {
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    function userInfo(uint256, address) external returns (UserInfo memory);

    function enterStaking(uint256) external;

    function leaveStaking(uint256) external;
}

contract PancakeMasterChefAdapter is IPoolAdapter {
    address private immutable token;

    constructor (address _token) {
        token = _token;
    }

    function deposit(
        address pool,
        uint256 amount,
        bytes memory
    ) external {
        IPancakeMasterChefPool(pool).enterStaking(amount);
    }

    function withdraw(
        address pool,
        uint256 amount,
        bytes memory
    ) external {
        IPancakeMasterChefPool(pool).leaveStaking(amount);
    }

    function withdrawAll(
        address pool,
        bytes memory
    ) external {
        IPancakeMasterChefPool masterPool = IPancakeMasterChefPool(pool);
        uint256 withdrawAmount = masterPool.userInfo(0, address(this)).amount;
        masterPool.leaveStaking(withdrawAmount);
    }

    function stakedToken(address) external view returns (address) {
        return token;
    }

    function rewardToken(address) external view returns (address) {
        return token;
    }
}