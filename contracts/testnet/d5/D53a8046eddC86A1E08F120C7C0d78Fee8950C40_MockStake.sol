// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract MockStake {
    struct UserInfo {
        uint256 stakedOf; // 用户提供了多少 LP 代币。
        uint256 rewardOf; // 用户已经获取的奖励
        uint256 duration; //质押周期
        uint256 lastDepositAt; //最后质押时间
        uint256 lastRewardAt; //最后领奖时间
        uint256 userReward; //用户奖励
    }
    mapping(uint256 => mapping(address => UserInfo)) private _userInfo; // 用户信息 pid=>user=>user

    constructor() {}

    function setUser(uint pid, address account, uint amount) external {
        UserInfo storage user = _userInfo[pid][account];
        user.lastDepositAt = block.timestamp;
        user.stakedOf = amount;
    }

    function userInfo(
        uint256 pid,
        address _account
    ) external view returns (UserInfo memory _user) {
        return _userInfo[pid][_account];
    }
}