/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

pragma solidity ^0.8.10;

// SPDX-License-Identifier: MIT

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}

contract ADADAOStaking {
    using SafeMath for uint256;
    address payable public owner;
    IERC20 public stakeToken;

    uint256 public totalStakedToken;
    uint256 public totalUnStakedToken;
    uint256 public totalWithdrawanToken;
    uint256 public totalClaimedRewardToken;
    uint256 public totalStakers;
    uint256 public percentDivider;

    uint256[6] public Duration = [
        30 days,
        60 days,
        90 days,
        180 days,
        365 days,
        365 days
    ];
    uint256[6] public Bonus = [33, 100, 200, 500, 1250, 1250];
    uint256[6] public totalStakedPerPlan;
    uint256[6] public totalStakersPerPlan;

    struct Stake {
        uint256 plan;
        uint256 withdrawtime;
        uint256 staketime;
        uint256 amount;
        uint256 reward;
        uint256 persecondreward;
        bool withdrawan;
        bool unstaked;
    }

    struct User {
        uint256 totalStakedTokenUser;
        uint256 totalWithdrawanTokenUser;
        uint256 totalUnStakedTokenUser;
        uint256 totalClaimedRewardTokenUser;
        uint256 stakeCount;
        uint256 stakedReward;
        bool alreadyExists;
    }

    mapping(address => User) public Stakers;
    mapping(uint256 => address) public StakersID;
    mapping(address => mapping(uint256 => Stake)) public stakersRecord;
    mapping(address => mapping(uint256 => uint256)) public userStakedPerPlan;

    event STAKE(address Staker, uint256 amount);
    event UNSTAKE(address Staker, uint256 amount);
    event WITHDRAW(address Staker, uint256 amount);
    event RESTAKE(address staker, uint256 amount);

    modifier onlyowner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    constructor(address _owner, address _token) {
        owner = payable(_owner);
        stakeToken = IERC20(_token);
        percentDivider = 1000;
    }

    function stake(uint256 amount, uint256 planIndex) public {
        require(planIndex < 6, "Invalid Time Period");
        require(amount >= 0, "stake more than 0");

        if (!Stakers[msg.sender].alreadyExists) {
            Stakers[msg.sender].alreadyExists = true;
            StakersID[totalStakers] = msg.sender;
            totalStakers++;
        }

        stakeToken.transferFrom(msg.sender, address(this), amount);

        uint256 index = Stakers[msg.sender].stakeCount;
        Stake storage userStake = stakersRecord[msg.sender][index];
        Stakers[msg.sender].totalStakedTokenUser = Stakers[msg.sender]
            .totalStakedTokenUser
            .add(amount);
        totalStakedToken = totalStakedToken.add(amount);
        userStake.withdrawtime = block.timestamp.add(Duration[planIndex]);

        userStake.staketime = block.timestamp;
        userStake.amount = amount;
        userStake.reward = amount.mul(Bonus[planIndex]).div(percentDivider);
        userStake.persecondreward = stakersRecord[msg.sender][index].reward.div(
            Duration[planIndex]
        );
        userStake.plan = planIndex;
        Stakers[msg.sender].stakeCount++;
        userStakedPerPlan[msg.sender][planIndex] = userStakedPerPlan[
            msg.sender
        ][planIndex].add(amount);
        totalStakedPerPlan[planIndex] = totalStakedPerPlan[planIndex].add(
            amount
        );
        totalStakersPerPlan[planIndex]++;

        emit STAKE(msg.sender, amount);
    }

    function unstake(uint256 index) public {
        Stake storage userStake = stakersRecord[msg.sender][index];
        uint256 planIndex = userStake.plan;
        require(planIndex < 5, "invalid plan");
        require(!userStake.withdrawan, "already withdrawan");
        require(!userStake.unstaked, "already unstaked");
        require(index < Stakers[msg.sender].stakeCount, "Invalid index");
        userStake.unstaked = true;
        stakeToken.transfer(msg.sender, (userStake.amount));
        totalUnStakedToken = totalUnStakedToken.add(userStake.amount);
        Stakers[msg.sender].totalUnStakedTokenUser = Stakers[msg.sender]
            .totalUnStakedTokenUser
            .add(userStake.amount);
        userStakedPerPlan[msg.sender][planIndex] = userStakedPerPlan[
            msg.sender
        ][planIndex].sub(userStake.amount, "user stake");
        totalStakedPerPlan[planIndex] = totalStakedPerPlan[planIndex].sub(
            userStake.amount,
            "total stake"
        );
        totalStakersPerPlan[planIndex]--;

        emit UNSTAKE(msg.sender, userStake.amount);
    }

    function withdraw(uint256 index) public {
        Stake storage userStake = stakersRecord[msg.sender][index];
        uint256 planIndex = userStake.plan;
        require(planIndex < 5, "invalid plan");
        require(!userStake.withdrawan, "already withdrawan");
        require(!userStake.unstaked, "already unstaked");
        require(
            userStake.withdrawtime < block.timestamp,
            "cannot withdraw before stake duration"
        );
        require(index < Stakers[msg.sender].stakeCount, "Invalid index");

        userStake.withdrawan = true;
        stakeToken.transfer(msg.sender, userStake.amount);
        stakeToken.transferFrom(owner, msg.sender, userStake.reward);
        totalWithdrawanToken = totalWithdrawanToken.add(userStake.amount);
        totalClaimedRewardToken = totalClaimedRewardToken.add(userStake.reward);
        Stakers[msg.sender].totalWithdrawanTokenUser = Stakers[msg.sender]
            .totalWithdrawanTokenUser
            .add(userStake.amount);
        Stakers[msg.sender].totalClaimedRewardTokenUser = Stakers[msg.sender]
            .totalClaimedRewardTokenUser
            .add(userStake.reward);
        userStakedPerPlan[msg.sender][planIndex] = userStakedPerPlan[
            msg.sender
        ][planIndex].sub(userStake.amount, "user stake");
        totalStakedPerPlan[planIndex] = totalStakedPerPlan[planIndex].sub(
            userStake.amount,
            "total stake"
        );
        totalStakersPerPlan[planIndex]--;

        emit WITHDRAW(msg.sender, userStake.reward.add(userStake.amount));
    }

    function withdrawUnlocked(uint256 index) public {
        Stake storage userStake = stakersRecord[msg.sender][index];
        uint256 planIndex = userStake.plan;
        require(planIndex == 5, "invalid plan");
        require(!userStake.withdrawan, "already withdrawan");
        require(!userStake.unstaked, "already unstaked");
        require(index < Stakers[msg.sender].stakeCount, "Invalid index");

        uint256 rewardTime = block.timestamp - userStake.staketime;
        uint256 rewardAmount = rewardTime.mul(userStake.persecondreward);
        userStake.withdrawan = true;
        stakeToken.transfer(msg.sender, userStake.amount);
        stakeToken.transferFrom(owner, msg.sender, rewardAmount);
        totalWithdrawanToken = totalWithdrawanToken.add(userStake.amount);
        totalClaimedRewardToken = totalClaimedRewardToken.add(rewardAmount);
        Stakers[msg.sender].totalWithdrawanTokenUser = Stakers[msg.sender]
            .totalWithdrawanTokenUser
            .add(userStake.amount);
        Stakers[msg.sender].totalClaimedRewardTokenUser = Stakers[msg.sender]
            .totalClaimedRewardTokenUser
            .add(rewardAmount);
        userStakedPerPlan[msg.sender][planIndex] = userStakedPerPlan[
            msg.sender
        ][planIndex].sub(userStake.amount, "user stake");
        totalStakedPerPlan[planIndex] = totalStakedPerPlan[planIndex].sub(
            userStake.amount,
            "total stake"
        );
        totalStakersPerPlan[planIndex]--;

        emit WITHDRAW(msg.sender, rewardAmount.add(userStake.amount));
    }

    function reStakeReward(uint256 index) public {
        Stake storage userStake = stakersRecord[msg.sender][index];
        uint256 planIndex = userStake.plan;
        if(planIndex < 5){
            require(
            userStake.withdrawtime < block.timestamp,
            "cannot restake before stake duration"
        );
        }
        require(!userStake.withdrawan, "already withdrawan");
        require(!userStake.unstaked, "already unstaked");
        require(index < Stakers[msg.sender].stakeCount, "Invalid index");
        uint256 rewardTime;
        if(block.timestamp >= userStake.withdrawtime){
            rewardTime = userStake.withdrawtime - userStake.staketime;
        } else {
            rewardTime = block.timestamp - userStake.staketime;
        }
        uint256 rewardAmount = rewardTime.mul(userStake.persecondreward);
        uint256 amountBefore = userStake.amount;

        stakeToken.transferFrom(owner, address(this), rewardAmount);

        userStake.amount = amountBefore.add(rewardAmount);
        userStake.staketime = block.timestamp;
        userStake.withdrawtime = block.timestamp.add(Duration[planIndex]);
        userStake.reward = userStake.amount.mul(Bonus[planIndex]).div(
            percentDivider
        );
        userStake.persecondreward = userStake.reward.div(Duration[planIndex]);
        Stakers[msg.sender].totalStakedTokenUser = Stakers[msg.sender]
            .totalStakedTokenUser
            .add(rewardAmount);
        userStakedPerPlan[msg.sender][planIndex] = userStakedPerPlan[msg.sender][
            planIndex
        ].add(rewardAmount);
        totalStakedPerPlan[planIndex] = totalStakedPerPlan[planIndex].add(rewardAmount);
        totalStakedToken = totalStakedToken.add(rewardAmount);
        Stakers[msg.sender].stakedReward += rewardAmount;

        emit RESTAKE(msg.sender, rewardAmount);
    }

    function SetStakeDuration(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth,
        uint256 fifth,
        uint256 sixth
    ) external onlyowner {
        Duration[0] = first;
        Duration[1] = second;
        Duration[2] = third;
        Duration[3] = fourth;
        Duration[4] = fifth;
        Duration[5] = sixth;
    }

    function SetStakeBonus(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth,
        uint256 fifth,
        uint256 sixth
    ) external onlyowner {
        Bonus[0] = first;
        Bonus[1] = second;
        Bonus[2] = third;
        Bonus[3] = fourth;
        Bonus[4] = fifth;
        Bonus[5] = sixth;
    }

    function realtimeReward(address user) public view returns (uint256) {
        uint256 ret;
        for (uint256 i; i < Stakers[user].stakeCount; i++) {
            if (
                !stakersRecord[user][i].withdrawan &&
                !stakersRecord[user][i].unstaked
            ) {
                uint256 val;
                val = block.timestamp - stakersRecord[user][i].staketime;
                val = val.mul(stakersRecord[user][i].persecondreward);
                if (val < stakersRecord[user][i].reward) {
                    ret += val;
                } else {
                    ret += stakersRecord[user][i].reward;
                }
            }
        }
        return ret;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}