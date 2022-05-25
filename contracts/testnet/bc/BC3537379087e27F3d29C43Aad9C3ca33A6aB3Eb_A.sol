/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;
interface IERC20 {
    function withdrawStakingReward(address _staker, uint256 _amount) external;
}

contract A{
    IERC20 public USDT;
    constructor(IERC20 _token){
        USDT = _token;
    }
    function withdrawReward(uint256 _reward) external{
        USDT.withdrawStakingReward(msg.sender, _reward);
    }
}