/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.13;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
}

interface iNomiFarm {

    struct Staker {
        uint256 amount;
        uint128 initialRewardRate;
        uint128 reward;
        uint256 claimedReward;
    }

    function stakers(address staker) external view returns (Staker memory);
}

contract iFarm {

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    function getAmount(
        uint256 pid,
        address targetAddress
)
    public view returns (uint) {
        uint farmAmount = userInfo[pid][targetAddress].amount;
        return farmAmount;
}

}


contract AtomicViewerV1 {

    function viewFarm(
        address targetAddress,
        address tokenAddress,
        address lpTokenAddress,
        address farmAddress,
        uint pid
)
    public view returns (uint [3] memory) {
        IBEP20 token = IBEP20(tokenAddress);
        IBEP20 lpToken = IBEP20(lpTokenAddress);
        uint256 tokenAmount = token.balanceOf(targetAddress);
        uint256 lpTokenAmount = lpToken.balanceOf(targetAddress);
        iFarm farm = iFarm(farmAddress);
        uint256 farmAmount = farm.getAmount(pid, targetAddress);

        uint[3] memory ans = [tokenAmount, lpTokenAmount, farmAmount];
        return ans;
    }

    function viewNomiFarm(
        address targetAddress,
        address tokenAddress,
        address lpTokenAddress,
        address nomiFarmAddress
)
    public view returns (uint [3] memory) {
        IBEP20 token = IBEP20(tokenAddress);
        IBEP20 lpToken = IBEP20(lpTokenAddress);
        iNomiFarm nomiFarm = iNomiFarm(nomiFarmAddress);
        uint256 tokenAmount = token.balanceOf(targetAddress);
        uint256 lpTokenAmount = lpToken.balanceOf(targetAddress);

        iNomiFarm.Staker memory stakerInfo = nomiFarm.stakers(targetAddress);
        uint256 farmAmount = stakerInfo.amount;

        uint[3] memory ans = [tokenAmount, lpTokenAmount, farmAmount];
        return ans;
    }

}