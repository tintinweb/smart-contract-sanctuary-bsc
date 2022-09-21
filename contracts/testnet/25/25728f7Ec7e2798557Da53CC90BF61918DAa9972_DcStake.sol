/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

//SPDX-License-Identifier: MIT

pragma solidity 0.8.7;


contract DcStake {
    address payable public treasury;
    mapping(address => address) public referralsA;

    struct StakeHolder {
        uint256 stakingAmount;
        uint256 stakingDate;
        uint256 stakingDuration;
        uint256 claimDate;
        uint256 expireDate;
        uint256 rewardAmount;
        bool isStaker;
    }

    mapping(address => mapping(uint => StakeHolder)) public stakeHolders;

    uint256[] internal stakePeriod = [7 days, 14 days, 28 days, 30 minutes];
    uint256[] internal rate = [2000, 3200, 4400, 5];
    uint256 private decimals = 10**18;
    uint256 private totalRewardAmount;

    constructor(address payable _treasury) {
        treasury = _treasury;
    }

    function staking(uint _amount, uint256 _duration, address ref) public {
        if (ref == msg.sender) {
            ref = address(0);
        }
        if (referralsA[msg.sender] == address(0)) {
            referralsA[msg.sender] = ref;
        }
        require(_amount >= 10000, "Insufficient Stake Amount");
        require(_duration < 4, "Duration not match");

        StakeHolder storage s = stakeHolders[msg.sender][_duration];
        s.stakingAmount = _amount * decimals;
        s.stakingDate = block.timestamp;
        s.claimDate = block.timestamp;
        s.stakingDuration = stakePeriod[_duration];
        s.expireDate = s.stakingDate + s.stakingDuration;
        s.isStaker = true;
    }

    function calculateRewardA_(address account, uint256 _duration) public {
        StakeHolder storage s = stakeHolders[account][_duration];
        require(s.isStaker == true, "You are not staker.");
        bool status = (block.timestamp - s.claimDate) > 7 seconds
            ? true
            : false;
        require(status == true, "Invalid Claim Date");

        uint currentTime = block.timestamp >= s.expireDate ? s.expireDate : block.timestamp;
        uint256 _pastTime = currentTime - s.claimDate;
        require(_pastTime >= stakePeriod[_duration], "Invalid Claim Date");

        uint reward = s.stakingAmount*rate[_duration]/1000;

        s.claimDate = block.timestamp;
        s.isStaker = false;

        uint256 fee = devFee(reward);
        (bool sent1, ) = treasury.call{value: fee}("");
        require(sent1, "ETH transfer Fail");

        (bool sent, ) = account.call{value: reward - 2 * fee}("");
        require(sent, "ETH transfer Fail");
    }

    function calculateRewardD_(address account, uint256 _duration) public {
        StakeHolder storage s = stakeHolders[account][_duration];
        require(s.isStaker == true, "You are not staker.");
        bool status = (block.timestamp - s.claimDate) > 7 seconds
            ? true
            : false;
        require(status == true, "Invalid Claim Date");

        uint currentTime = block.timestamp >= s.expireDate
            ? s.expireDate
            : block.timestamp;
        uint256 _pastTime = currentTime - s.claimDate;
        require(_pastTime >= stakePeriod[_duration], "Invalid Claim Date");
        uint reward = rate[_duration]*s.stakingAmount/(1000);

        s.claimDate = block.timestamp;
        s.isStaker = false;

        uint256 fee = devFee(reward);
        (bool sent1, ) = treasury.call{value: fee}("");
        require(sent1, "ETH transfer Fail");

        (bool sent, ) = account.call{value: reward - 2 * fee}("");
        require(sent, "ETH transfer Fail");
    }

    function calculateRewardAll_(address account) public {
        totalRewardAmount = 0;
        calculateRewardA_(account, 0);
        calculateRewardA_(account, 1);
        calculateRewardA_(account, 2);
        calculateRewardD_(account, 3);
    }

    function devFee(uint256 amount) public pure returns (uint256) {
        return (amount * 5) / 100;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}