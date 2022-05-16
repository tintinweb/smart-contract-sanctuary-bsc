/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-14
 */

pragma solidity ^0.8.6;

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

interface oldStaking {
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

    function stakersRecord(address staker, uint256 index)
        external
        view
        returns (Stake memory stakeData);

    function Stakers(address staker) external view returns (User memory user);
}

contract LiveCryptoPartyStaking {
    using SafeMath for uint256;
    IERC20 public stakeToken;
    oldStaking public oldStakingAddress;

    address payable public owner;

    uint256 public totalStakedLCP;
    uint256 public totalUnStakedLCP;
    uint256 public totalWithdrawanLCP;
    uint256 public totalClaimedRewardLCP;
    uint256 public totalStakersLCP;
    uint256 public percentDivider;

    uint256[4] public Duration = [30 days, 60 days, 90 days, 120 days];
    uint256[4] public Bonus = [50, 120, 200, 500];
    uint256[4] public totalStakedPerPlanLCP;
    uint256[4] public totalStakersPerPlanLCP;

    struct StakeLCP {
        uint256 planLCP;
        uint256 withdrawtimeLCP;
        uint256 staketimeLCP;
        uint256 amountLCP;
        uint256 rewardLCP;
        uint256 persecondrewardLCP;
        bool withdrawanLCP;
        bool unstakedLCP;
    }

    struct UserLCP {
        uint256 totalStakedTokenUserLCP;
        uint256 totalWithdrawanTokenUserLCP;
        uint256 totalUnStakedTokenUserLCP;
        uint256 totalClaimedRewardTokenUserLCP;
        uint256 stakeCountLCP;
        bool alreadyExistsLCP;
    }

    mapping(address => UserLCP) public StakersLCP;
    mapping(uint256 => address) public StakersIDLCP;
    mapping(address => mapping(uint256 => StakeLCP)) public stakersRecordLCP;
    mapping(address => mapping(uint256 => uint256)) public userStakedPerPlanLCP;

    event STAKE(address Staker, uint256 amount);
    event UNSTAKE(address Staker, uint256 amount);
    event WITHDRAW(address Staker, uint256 amount);

    modifier onlyowner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    constructor(
        address _owner,
        address _token,
        address _addr
    ) {
        owner = payable(_owner);
        stakeToken = IERC20(_token);
        percentDivider = 1000;
        oldStakingAddress = oldStaking(_addr);
    }

    function stake(uint256 amount, uint256 planIndex) public {
        require(planIndex >= 0 && planIndex <= 3, "Invalid Time Period");
        require(amount >= 0, "stake more than 0");

        if (!StakersLCP[msg.sender].alreadyExistsLCP) {
            StakersLCP[msg.sender].alreadyExistsLCP = true;
            StakersIDLCP[totalStakersLCP] = msg.sender;
            totalStakersLCP++;
        }

        stakeToken.transferFrom(msg.sender, address(this), amount);

        uint256 index = StakersLCP[msg.sender].stakeCountLCP;
        StakersLCP[msg.sender].totalStakedTokenUserLCP = StakersLCP[msg.sender]
            .totalStakedTokenUserLCP
            .add(amount);
        totalStakedLCP = totalStakedLCP.add(amount);
        stakersRecordLCP[msg.sender][index].withdrawtimeLCP = block
            .timestamp
            .add(Duration[planIndex]);
        stakersRecordLCP[msg.sender][index].staketimeLCP = block.timestamp;
        stakersRecordLCP[msg.sender][index].amountLCP = amount;
        stakersRecordLCP[msg.sender][index].rewardLCP = amount
            .mul(Bonus[planIndex])
            .div(percentDivider);
        stakersRecordLCP[msg.sender][index]
            .persecondrewardLCP = stakersRecordLCP[msg.sender][index]
            .rewardLCP
            .div(Duration[planIndex]);
        stakersRecordLCP[msg.sender][index].planLCP = planIndex;
        StakersLCP[msg.sender].stakeCountLCP++;
        userStakedPerPlanLCP[msg.sender][planIndex] = userStakedPerPlanLCP[
            msg.sender
        ][planIndex].add(amount);
        totalStakedPerPlanLCP[planIndex] = totalStakedPerPlanLCP[planIndex].add(
            amount
        );
        totalStakersPerPlanLCP[planIndex]++;

        emit STAKE(msg.sender, amount);
    }

    function unstake(uint256 index) public {
        require(
            !stakersRecordLCP[msg.sender][index].withdrawanLCP,
            "already withdrawan"
        );
        require(
            !stakersRecordLCP[msg.sender][index].unstakedLCP,
            "already unstaked"
        );
        require(index < StakersLCP[msg.sender].stakeCountLCP, "Invalid index");

        stakersRecordLCP[msg.sender][index].unstakedLCP = true;
        stakeToken.transfer(
            msg.sender,
            (stakersRecordLCP[msg.sender][index].amountLCP)
        );
        totalUnStakedLCP = totalUnStakedLCP.add(
            stakersRecordLCP[msg.sender][index].amountLCP
        );
        StakersLCP[msg.sender].totalUnStakedTokenUserLCP = StakersLCP[
            msg.sender
        ].totalUnStakedTokenUserLCP.add(
                stakersRecordLCP[msg.sender][index].amountLCP
            );
        uint256 planIndex = stakersRecordLCP[msg.sender][index].planLCP;
        userStakedPerPlanLCP[msg.sender][planIndex] = userStakedPerPlanLCP[
            msg.sender
        ][planIndex].sub(
                stakersRecordLCP[msg.sender][index].amountLCP,
                "user stake"
            );
        totalStakedPerPlanLCP[planIndex] = totalStakedPerPlanLCP[planIndex].sub(
            stakersRecordLCP[msg.sender][index].amountLCP,
            "total stake"
        );
        totalStakersPerPlanLCP[planIndex]--;

        emit UNSTAKE(msg.sender, stakersRecordLCP[msg.sender][index].amountLCP);
    }

    function withdraw(uint256 index) public {
        require(
            !stakersRecordLCP[msg.sender][index].withdrawanLCP,
            "already withdrawan"
        );
        require(
            !stakersRecordLCP[msg.sender][index].unstakedLCP,
            "already unstaked"
        );
        require(
            stakersRecordLCP[msg.sender][index].withdrawtimeLCP <
                block.timestamp,
            "cannot withdraw before stake duration"
        );
        require(index < StakersLCP[msg.sender].stakeCountLCP, "Invalid index");

        stakersRecordLCP[msg.sender][index].withdrawanLCP = true;
        stakeToken.transfer(
            msg.sender,
            stakersRecordLCP[msg.sender][index].amountLCP
        );
        stakeToken.transferFrom(
            owner,
            msg.sender,
            stakersRecordLCP[msg.sender][index].rewardLCP
        );
        totalWithdrawanLCP = totalWithdrawanLCP.add(
            stakersRecordLCP[msg.sender][index].amountLCP
        );
        totalClaimedRewardLCP = totalClaimedRewardLCP.add(
            stakersRecordLCP[msg.sender][index].rewardLCP
        );
        StakersLCP[msg.sender].totalWithdrawanTokenUserLCP = StakersLCP[
            msg.sender
        ].totalWithdrawanTokenUserLCP.add(
                stakersRecordLCP[msg.sender][index].amountLCP
            );
        StakersLCP[msg.sender].totalClaimedRewardTokenUserLCP = StakersLCP[
            msg.sender
        ].totalClaimedRewardTokenUserLCP.add(
                stakersRecordLCP[msg.sender][index].rewardLCP
            );
        uint256 planIndex = stakersRecordLCP[msg.sender][index].planLCP;
        userStakedPerPlanLCP[msg.sender][planIndex] = userStakedPerPlanLCP[
            msg.sender
        ][planIndex].sub(
                stakersRecordLCP[msg.sender][index].amountLCP,
                "user stake"
            );
        totalStakedPerPlanLCP[planIndex] = totalStakedPerPlanLCP[planIndex].sub(
            stakersRecordLCP[msg.sender][index].amountLCP,
            "total stake"
        );
        totalStakersPerPlanLCP[planIndex]--;

        emit WITHDRAW(
            msg.sender,
            stakersRecordLCP[msg.sender][index].rewardLCP.add(
                stakersRecordLCP[msg.sender][index].amountLCP
            )
        );
    }

    function reStake() public {
        if (!StakersLCP[msg.sender].alreadyExistsLCP) {
            StakersLCP[msg.sender].alreadyExistsLCP = true;
            StakersIDLCP[totalStakersLCP] = msg.sender;
            totalStakersLCP++;
        }

        oldStaking.Stake memory userOldStake = oldStakingAddress.stakersRecord(
            msg.sender,
            0
        );
        uint256 planIndex = userOldStake.plan;
        uint256 rewardTime;
        if (block.timestamp >= userOldStake.withdrawtime) {
            rewardTime = userOldStake.withdrawtime - userOldStake.staketime;
        } else {
            rewardTime = block.timestamp - userOldStake.staketime;
        }
        uint256 rewardAmount = rewardTime.mul(userOldStake.persecondreward);
        uint256 amountBefore = userOldStake.amount;
        uint256 amount = amountBefore.add(rewardAmount);

        stakeToken.transferFrom(msg.sender, address(this), amount);

        // uint256 index = Stakers[msg.sender].stakeCount;
        // Stakers[msg.sender].totalStakedTokenUser = Stakers[msg.sender]
        //     .totalStakedTokenUser
        //     .add(amount);
        // totalStakedToken = totalStakedToken.add(amount);
        // stakersRecord[msg.sender][index].withdrawtime = block.timestamp.add(
        //     Duration[planIndex]
        // );
        // stakersRecord[msg.sender][index].staketime = block.timestamp;
        // stakersRecord[msg.sender][index].amount = amount;
        // stakersRecord[msg.sender][index].reward = amount
        //     .mul(Bonus[planIndex])
        //     .div(percentDivider);
        // stakersRecord[msg.sender][index].persecondreward = stakersRecord[
        //     msg.sender
        // ][index].reward.div(Duration[planIndex]);
        // stakersRecord[msg.sender][index].plan = planIndex;
        // Stakers[msg.sender].stakeCount++;
        // userStakedPerPlan[msg.sender][planIndex] = userStakedPerPlan[
        //     msg.sender
        // ][planIndex].add(amount);
        // totalStakedPerPlan[planIndex] = totalStakedPerPlan[planIndex].add(
        //     amount
        // );
        // totalStakersPerPlan[planIndex]++;

        emit STAKE(msg.sender, amount);
    }

    function SetStakeDuration(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth
    ) external onlyowner {
        Duration[0] = first;
        Duration[1] = second;
        Duration[2] = third;
        Duration[3] = fourth;
    }

    function SetStakeBonus(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth
    ) external onlyowner {
        Bonus[0] = first;
        Bonus[1] = second;
        Bonus[2] = third;
        Bonus[3] = fourth;
    }

    function realtimeReward(address user) public view returns (uint256) {
        uint256 ret;
        for (uint256 i; i < StakersLCP[user].stakeCountLCP; i++) {
            if (
                !stakersRecordLCP[user][i].withdrawanLCP &&
                !stakersRecordLCP[user][i].unstakedLCP
            ) {
                uint256 val;
                val = block.timestamp - stakersRecordLCP[user][i].staketimeLCP;
                val = val.mul(stakersRecordLCP[user][i].persecondrewardLCP);
                if (val < stakersRecordLCP[user][i].rewardLCP) {
                    ret += val;
                } else {
                    ret += stakersRecordLCP[user][i].rewardLCP;
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