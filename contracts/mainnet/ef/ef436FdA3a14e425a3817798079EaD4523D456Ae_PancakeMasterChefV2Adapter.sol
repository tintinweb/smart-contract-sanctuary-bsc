// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IPoolAdapter.sol";

// Interface of https://bscscan.com/address/0x45c54210128a065de780C4B0Df3d16664f7f859e#code
interface IPancakeMasterChefPoolV2 {
    struct UserInfo {
        uint256 shares; // number of shares for a user.
        uint256 lastDepositedTime; // keep track of deposited time for potential penalty.
        uint256 cakeAtLastUserAction; // keep track of cake deposited at the last user action.
        uint256 lastUserActionTime; // keep track of the last user action time.
        uint256 lockStartTime; // lock start time.
        uint256 lockEndTime; // lock end time.
        uint256 userBoostedShare; // boost share, in order to give the user higher reward. The user only enjoys the reward, so the principal needs to be recorded as a debt.
        bool locked; //lock status.
        uint256 lockedAmount; // amount deposited during lock period.
    }

    function userInfo(address) external view returns (UserInfo memory);

    function getPricePerFullShare() external view returns (uint256);

    function deposit(uint256 _amount, uint256 _lockDuration) external;

    function withdrawByAmount(uint256 _amount) external;

    function withdrawAll() external;

    function token() external view returns (address);
}

contract PancakeMasterChefV2Adapter is IPoolAdapter {
    function deposit(
        address pool,
        uint256 amount,
        bytes memory /* args */
    ) external {
        IPancakeMasterChefPoolV2(pool).deposit(amount, 0);
    }

    function stakingBalance(
        address pool,
        bytes memory /* args */
    ) external view returns (uint256) {
        uint256 sharesBalance = IPancakeMasterChefPoolV2(pool).userInfo(address(this)).shares;
        uint256 sharePrice = IPancakeMasterChefPoolV2(pool).getPricePerFullShare();
        return (sharesBalance * sharePrice) / 1e18;
    }

    function rewardBalances(address, bytes memory) external pure returns (uint256[] memory) {
        return new uint256[](0);
    }

    function withdraw(
        address pool,
        uint256 amount,
        bytes memory /* args */
    ) external {
        IPancakeMasterChefPoolV2(pool).withdrawByAmount(amount);
    }

    function withdrawAll(
        address pool,
        bytes memory /* args */
    ) external {
        IPancakeMasterChefPoolV2(pool).withdrawAll();
    }

    function stakedToken(
        address pool,
        bytes memory /* args */
    ) external view returns (address) {
        return IPancakeMasterChefPoolV2(pool).token();
    }

    function rewardTokens(address, bytes memory args) external pure returns (address[] memory) {
        return new address[](0);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPoolAdapter {
    function stakingBalance(address pool, bytes memory) external returns (uint256);

    function rewardBalances(address, bytes memory) external returns (uint256[] memory);

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

    function rewardTokens(address pool, bytes memory args) external view returns (address[] memory);
}