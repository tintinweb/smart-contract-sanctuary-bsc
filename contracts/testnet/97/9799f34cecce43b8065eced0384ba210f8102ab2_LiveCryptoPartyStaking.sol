/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT

// Treat people with kindness: Rosie
// All copyrights, trademarks and patents belongs to Live Crypto Party livecryptoparty.com

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
    address payable public penaltyFeeReceiver =
        payable(0x1226E9F4d6f0d4D14a8265f281e4F928C4Eb3E1E);
    uint256 public unstakePenaltyFee = 0.005 ether;
    uint256 public claimFee = 0.001 ether;

    uint256 public totalStakedLCP;
    uint256 public totalUnStakedLCP;
    uint256 public totalWithdrawanLCP;
    uint256 public totalClaimedRewardLCP;
    uint256 public totalStakersLCP;
    uint256 public percentDivider;
    bool pauseStaking;
    mapping(address => bool) public _isExcludedFromReward;

    uint256[10] public Duration = [30 days, 60 days, 90 days, 180 days];
    uint256[10] public Bonus = [50, 120, 200, 500];
    uint256[10] public totalStakedPerPlanLCP;
    uint256[10] public totalStakersPerPlanLCP;
    uint256 public counter = 4;

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
    event RESTAKE(address Staker, uint256 amount);
    event WITHDRAW(address Staker, uint256 amount);

    modifier onlyowner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    constructor(
        address _owner,
        address _token,
        address _oldStaking
    ) {
        owner = payable(_owner);
        stakeToken = IERC20(_token);
        percentDivider = 1000;
        oldStakingAddress = oldStaking(_oldStaking);
    }

    function stake(uint256 amount, uint256 planIndex) public {
        require(planIndex >= 0 && planIndex <= 9, "Invalid Time Period");
        require(amount >= 0, "stake more than 0");
        require(!pauseStaking, "staking is paused");

        if (!StakersLCP[msg.sender].alreadyExistsLCP) {
            StakersLCP[msg.sender].alreadyExistsLCP = true;
            StakersIDLCP[totalStakersLCP] = msg.sender;
            totalStakersLCP++;
        }
        storeData(msg.sender, amount, planIndex);
        stakeToken.transferFrom(msg.sender, address(this), amount);

        emit STAKE(msg.sender, amount);
    }

    function storeData(
        address user,
        uint256 amount,
        uint256 planIndex
    ) internal {
        uint256 index = StakersLCP[user].stakeCountLCP;
        StakersLCP[user].totalStakedTokenUserLCP = StakersLCP[user]
            .totalStakedTokenUserLCP
            .add(amount);
        totalStakedLCP = totalStakedLCP.add(amount);
        stakersRecordLCP[user][index].withdrawtimeLCP = block.timestamp.add(
            Duration[planIndex]
        );
        stakersRecordLCP[user][index].staketimeLCP = block.timestamp;
        stakersRecordLCP[user][index].amountLCP = amount;
        stakersRecordLCP[user][index].rewardLCP = amount
            .mul(Bonus[planIndex])
            .div(percentDivider);
        stakersRecordLCP[user][index].persecondrewardLCP = stakersRecordLCP[
            user
        ][index].rewardLCP.div(Duration[planIndex]);
        stakersRecordLCP[user][index].planLCP = planIndex;
        StakersLCP[user].stakeCountLCP++;
        userStakedPerPlanLCP[user][planIndex] = userStakedPerPlanLCP[user][
            planIndex
        ].add(amount);
        totalStakedPerPlanLCP[planIndex] = totalStakedPerPlanLCP[planIndex].add(
            amount
        );
        totalStakersPerPlanLCP[planIndex]++;
    }

    function unstake(uint256 index) public payable {
        require(msg.value >= unstakePenaltyFee, "Insufficient Funds");
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
            stakersRecordLCP[msg.sender][index].amountLCP
        );
        totalUnStakedLCP = totalUnStakedLCP.add(
            stakersRecordLCP[msg.sender][index].amountLCP
        );
        penaltyFeeReceiver.transfer(msg.value);
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

    function withdraw(uint256 index) public payable {
        require(msg.value >= claimFee, "Insufficient Funds");
        require(!_isExcludedFromReward[msg.sender], "excluded from reward");
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
        penaltyFeeReceiver.transfer(msg.value);
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
        require(!StakersLCP[msg.sender].alreadyExistsLCP, "already restaked");
        StakersLCP[msg.sender].alreadyExistsLCP = true;
        StakersIDLCP[totalStakersLCP] = msg.sender;
        totalStakersLCP++;

        uint256 totalOldStaked;
        oldStaking.User memory userOldData = oldStakingAddress.Stakers(
            msg.sender
        );
        uint256 oldStakeCount = userOldData.stakeCount;

        for (uint256 i = 0; i < oldStakeCount; i++) {
            oldStaking.Stake memory userOldStake = oldStakingAddress
                .stakersRecord(msg.sender, i);
            uint256 planIndex = userOldStake.plan;
            if (!userOldStake.unstaked && !userOldStake.withdrawan) {
                uint256 rewardTime;
                if (block.timestamp >= userOldStake.withdrawtime) {
                    rewardTime =
                        userOldStake.withdrawtime -
                        userOldStake.staketime;
                } else {
                    rewardTime = block.timestamp - userOldStake.staketime;
                }
                uint256 rewardAmount = rewardTime.mul(
                    userOldStake.persecondreward
                );
                uint256 amountBefore = userOldStake.amount;
                uint256 totalrestaked = amountBefore.add(rewardAmount);
                totalOldStaked += totalrestaked;
                storeData(msg.sender, totalrestaked, planIndex);
            }
        }

        stakeToken.transferFrom(owner, address(this), totalOldStaked);

        emit RESTAKE(msg.sender, totalOldStaked);
    }

    function SetStakeDuration(uint256 index, uint256 duration)
        external
        onlyowner
    {
        Duration[index] = duration;
    }

    function SetPenalty(
        address payable _penaltyFeeReceiver,
        uint256 _penaltyFee,
        uint256 _claimFee
    ) external onlyowner {
        penaltyFeeReceiver = _penaltyFeeReceiver;
        unstakePenaltyFee = _penaltyFee;
        claimFee = _claimFee;
    }

    function SetStakeBonus(uint256 index, uint256 bonus) external onlyowner {
        Bonus[index] = bonus;
    }

    function addNewStakePlan(uint256 duration, uint256 bonus)
        external
        onlyowner
    {
        require(counter <= 9, "plan exceeds limit");
        Duration[counter] = duration;
        Bonus[counter] = bonus;
        counter++;
    }

    function PauseStaking(bool _pause) external onlyowner {
        pauseStaking = _pause;
    }

    function ExcludeFromReward(address staker, bool _state) external onlyowner {
        _isExcludedFromReward[staker] = _state;
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