// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IPoolAdapter.sol";

// Interface of https://bscscan.com/address/0x60c4998C058BaC8042712B54E7e43b892Ab0B0c4#code
interface IPancakeSmartChefPool {
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    function userInfo(address) external view returns (UserInfo memory);

    function pendingReward(address) external view returns (uint256);

    function deposit(uint256) external;

    function withdraw(uint256) external;

    function rewardToken() external view returns (address);

    function stakedToken() external view returns (address);
}

contract PancakeSmartChefAdapter is IPoolAdapter {
    function deposit(
        address pool,
        uint256 amount,
        bytes memory /* args */
    ) external {
        IPancakeSmartChefPool(pool).deposit(amount);
    }

    function stakingBalance(
        address pool,
        bytes memory /* args */
    ) external view returns (uint256) {
        IPancakeSmartChefPool smartPool = IPancakeSmartChefPool(pool);
        return smartPool.userInfo(address(this)).amount;
    }

    function rewardBalance(
        address pool,
        bytes memory /* args */
    ) external view returns (uint256) {
        IPancakeSmartChefPool smartPool = IPancakeSmartChefPool(pool);
        return smartPool.pendingReward(address(this));
    }

    function withdraw(
        address pool,
        uint256 amount,
        bytes memory /* args */
    ) external {
        IPancakeSmartChefPool(pool).withdraw(amount);
    }

    function withdrawAll(
        address pool,
        bytes memory /* args */
    ) external {
        IPancakeSmartChefPool smartPool = IPancakeSmartChefPool(pool);
        uint256 withdrawAmount = smartPool.userInfo(address(this)).amount;
        smartPool.withdraw(withdrawAmount);
    }

    function stakedToken(
        address pool,
        bytes memory /* args */
    ) external view returns (address) {
        return IPancakeSmartChefPool(pool).stakedToken();
    }

    function rewardToken(
        address pool,
        bytes memory /* args */
    ) external view returns (address) {
        return IPancakeSmartChefPool(pool).rewardToken();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPoolAdapter {
    function stakingBalance(address pool, bytes memory) external returns (uint256);

    function rewardBalance(address pool, bytes memory) external returns (uint256);

    function deposit(
        address pool,
        uint256 amount,
        bytes memory args
    ) external;

    function withdraw(
        address pool,
        uint256 amount,
        bytes memory args
    ) external;

    function withdrawAll(address pool, bytes memory args) external;

    function stakedToken(address pool, bytes memory args) external returns (address);

    function rewardToken(address pool, bytes memory args) external returns (address);
}