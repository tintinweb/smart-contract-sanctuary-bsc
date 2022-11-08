/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

interface Erc20Token {
    function decimals() external view returns (uint8);

    function balanceOf(address _owner) external view returns (uint256);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);
}

contract TokenStakingContract {
    /*============================ EVENTS============================*/
    event Staked(address indexed from, uint256 amount);
    event UnStaked(address indexed to, uint256 amount);
    event Claimed(address indexed from, address indexed to, uint256 amount);
    /*============================ STATE VARIABLES============================*/
    bool private locked;
    address payable public owner;
    // Seprate Wallett to transfer amount 0.5% staking fee, 1.5% unstaking fee
    address separateWallet;
    // StakingToken & RewardToken
    // Address for Staking Token & Rewarding Token
    address StakingTokenAddr;
    address RewardingTokenAddr;

    // Structure to Store Information Related to a User Staking Their thier token
    struct StakeInfo {
        uint256 startTS;
        uint256 amount;
        uint256 claimed;
    }
    // Mapping to store information related to a User Staking their token
    // Address -> Stake Information
    mapping(address => StakeInfo) stakeInfos;
    mapping(address => uint256) unclaimedReward;

    constructor(
        address _StakingTokenAddress,
        address _RewardingTokenAddress,
        address _separateWallet
    ) {
        require(
            address(_StakingTokenAddress) != address(0) &&
                address(_RewardingTokenAddress) != address(0),
            "Token Address cannot be address 0"
        );
        owner = payable(msg.sender);
        locked = false;
        separateWallet = _separateWallet;
        StakingTokenAddr = _StakingTokenAddress;
        RewardingTokenAddr = _RewardingTokenAddress;
    }

    function StakeTokens(uint256 stakeAmount) public returns (bool) {
        // require(addressStaked[msg.sender] == false, "You already participated");
        require(
            stakeInfos[msg.sender].amount == 0,
            "You have already participated"
        );
        require(
            Erc20Token(StakingTokenAddr).balanceOf(msg.sender) >= stakeAmount,
            "Insufficient Tokens Balance"
        );

        require(
            stakeAmount >= 0,
            "Stake Amount is too low. Should be Greater Than 0"
        );
        // addressStaked[msg.sender] = true;
        // 0.5 STAKING FEE DUDUCTED HERE
        uint256 amountAdded = ((stakeAmount * 1000) - (stakeAmount * 5)) / 1000;
        require(
            Erc20Token(StakingTokenAddr).transferFrom(
                msg.sender,
                address(this),
                stakeAmount
            ),
            "Tokens Not Staked ERROR returned"
        );
        // Staking fee Transfered to a Seperate Wallet
        require(
            Erc20Token(StakingTokenAddr).transfer(
                separateWallet,
                (stakeAmount) - (amountAdded)
            ),
            "STAKING FEE Not Transfered"
        );

        stakeInfos[msg.sender] = StakeInfo({
            startTS: block.timestamp,
            amount: amountAdded,
            claimed: 0
        });

        emit Staked(msg.sender, stakeInfos[msg.sender].amount);
        return true;
    }

    function unStakeTokens() public returns (bool isUnstaked) {
        require(stakeInfos[msg.sender].amount > 0, "You have not staked");

        require(
            Erc20Token(RewardingTokenAddr).allowance(owner, address(this)) > 0,
            "Reward Tokens Not Availabl Right Now"
        );
        StakeInfo memory Data = stakeInfos[msg.sender];

        uint256 percentage = 7;

        uint256 dayPassed = (block.timestamp - Data.startTS) / 86400;
        uint256 decimals = 10**(Erc20Token(RewardingTokenAddr).decimals());
        uint256 point = (dayPassed) * decimals;
        uint256 CurrentRewardCreated = ((((percentage * point) / 10000) *
            Data.amount) / decimals) -
            // Subtract Already claimed Reward
            Data.claimed;

        // Setting unclaimed Reward
        if (CurrentRewardCreated > 0) {
            unclaimedReward[msg.sender] += CurrentRewardCreated;
        }
        uint256 amountBack = ((Data.amount * 1000) - (Data.amount * 15)) / 1000;
        require(amountBack > 0, "No amount to Return ");
        require(
            Erc20Token(StakingTokenAddr).transfer(msg.sender, amountBack),
            "Error On unstaking Token Transfer"
        );
        // Transfering unstaking Fee to Seperate Wallet
        require(
            Erc20Token(StakingTokenAddr).transfer(
                separateWallet,
                Data.amount - amountBack
            ),
            "Error On unstaking Token Transfer"
        );
        emit UnStaked(msg.sender, amountBack);
        return true;
    }

    function ClaimDailyRewards() public returns (bool) {
        // require(addressStaked[msg.sender] == true, "You have not staked");
        require(
            Erc20Token(RewardingTokenAddr).allowance(owner, address(this)) > 0,
            "Reward Tokens Not Availabl Right Now"
        );

        StakeInfo memory Data = stakeInfos[msg.sender];
        uint256 percentage = 7;

        uint256 dayPassed = (block.timestamp - Data.startTS) / 86400;

        uint256 decimals = 10**(Erc20Token(RewardingTokenAddr).decimals());
        uint256 point = (dayPassed) * decimals;
        uint256 CurrentRewardCreated = ((((percentage * point) / 10000) *
            Data.amount) / decimals) -
            // Subtract Already claimed Reward
            Data.claimed;

        require((CurrentRewardCreated+unclaimedReward[msg.sender]) > 0, "Current daily Reward is 0");

        stakeInfos[msg.sender].claimed =
            stakeInfos[msg.sender].claimed +
            CurrentRewardCreated;

        require(
            Erc20Token(RewardingTokenAddr).transferFrom(
                owner,
                msg.sender,
                (CurrentRewardCreated + unclaimedReward[msg.sender])
            ),
            "Error in Transfering Reward"
        );
        delete unclaimedReward[msg.sender];
        emit Claimed(owner, msg.sender, CurrentRewardCreated);
        return true;
    }

    function viewStakeValue()
        public
        view
        returns (
            uint256 StartTime,
            uint256 amountStaked,
            uint256 amountClaimed,
            uint256 RewardCreated,
            uint256 dayPassed,
            uint256 previousRewards
        )
    {
        require(
            stakeInfos[msg.sender].amount > 0,
            "You have not participated in staking"
        );

        StakeInfo memory Data = stakeInfos[msg.sender];
        StartTime = Data.startTS;
        amountStaked = Data.amount;
        amountClaimed = Data.claimed;
        uint256 percentage = 7;

        dayPassed = (block.timestamp - Data.startTS) / 86400;
        uint256 decimals = 10**(Erc20Token(RewardingTokenAddr).decimals());
        uint256 point = (dayPassed) * decimals;
        RewardCreated =
            (((percentage * point) / 10000) * Data.amount) /
            decimals;
        previousRewards = unclaimedReward[msg.sender];
    }
}