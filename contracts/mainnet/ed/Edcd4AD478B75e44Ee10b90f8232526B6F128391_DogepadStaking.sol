/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

/**

██████   ██████   ██████  ███████ ██████   █████  ██████  
██   ██ ██    ██ ██       ██      ██   ██ ██   ██ ██   ██ 
██   ██ ██    ██ ██   ███ █████   ██████  ███████ ██   ██ 
██   ██ ██    ██ ██    ██ ██      ██      ██   ██ ██   ██ 
██████   ██████   ██████  ███████ ██      ██   ██ ██████  
                                                          
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

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

contract DogepadStaking {
    using SafeMath for uint256;
    IERC20 public stakeToken;

    address payable public owner;

    uint256 public totalStakedToken;
    uint256 public totalWithdrawanToken;
    uint256 public totalClaimedRewardToken;
    uint256 public totalStakers;
    uint256 public percentDivider;
    uint256 public timePeriod;
    uint256 public depositFee;
    uint256 public withdrawFee;

    uint256[2] public Duration = [7 days, 14 days];
    uint256[2] public Bonus = [96, 384];

    struct Stake {
        uint256 plan;
        uint256 withdrawtime;
        uint256 staketime;
        uint256 amount;
        uint256 reward;
        uint256 perDayReward;
        bool withdrawan;
    }

    struct User {
        uint256 totalStakedTokenUser;
        uint256 totalClaimedRewardTokenUser;
        uint256 stakeCount;
        bool alreadyExists;
    }

    mapping(address => User) public Stakers;
    mapping(uint256 => address) public StakersID;
    mapping(address => mapping(uint256 => Stake)) public stakersRecord;
    mapping(address => mapping(uint256 => uint256)) public userStakedPerPlan;

    event STAKE(address Staker, uint256 amount);
    event UNSTAKE(address Staker, uint256 amount);
    event WITHDRAW(address Staker, uint256 amount);

    modifier onlyowner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    constructor(address _owner, address _token) {
        owner = payable(_owner);
        stakeToken = IERC20(_token);
        percentDivider = 10000;
        timePeriod = 1 days;
        depositFee = 200;
        withdrawFee = 200;
    }

    function stake(uint256 amount, uint256 planIndex) public {
        require(planIndex == 0 || planIndex == 1, "Invalid Index");
        require(amount >= 0, "stake more than 0");

        if (!Stakers[msg.sender].alreadyExists) {
            Stakers[msg.sender].alreadyExists = true;
            StakersID[totalStakers] = msg.sender;
            totalStakers++;
        }

        stakeToken.transferFrom(msg.sender, address(this), amount);
        uint256 _fee = amount.mul(depositFee).div(percentDivider);
        stakeToken.transfer(owner, _fee);
        amount -= _fee;

        uint256 index = Stakers[msg.sender].stakeCount;
        Stakers[msg.sender].totalStakedTokenUser = Stakers[msg.sender]
            .totalStakedTokenUser
            .add(amount);
        totalStakedToken = totalStakedToken.add(amount);
        stakersRecord[msg.sender][index].withdrawtime = block.timestamp.add(
            Duration[planIndex]
        );
        stakersRecord[msg.sender][index].staketime = block.timestamp;
        stakersRecord[msg.sender][index].amount = amount;
        stakersRecord[msg.sender][index].reward = amount
            .mul(Bonus[planIndex])
            .div(percentDivider);
        stakersRecord[msg.sender][index].perDayReward = stakersRecord[
            msg.sender
        ][index].reward.div(Duration[planIndex].div(timePeriod));
        stakersRecord[msg.sender][index].plan = planIndex;
        Stakers[msg.sender].stakeCount++;
        userStakedPerPlan[msg.sender][planIndex] = userStakedPerPlan[
            msg.sender
        ][planIndex].add(amount);

        emit STAKE(msg.sender, amount);
    }

    function unstake(uint256 index) public {
        require(
            !stakersRecord[msg.sender][index].withdrawan,
            "already withdrawan"
        );
        require(index < Stakers[msg.sender].stakeCount, "Invalid index");

        uint256 claimableReward;
        if (block.timestamp < stakersRecord[msg.sender][index].withdrawtime) {
            uint256 duration = (block.timestamp -
                stakersRecord[msg.sender][index].staketime) / timePeriod;
            claimableReward =
                duration *
                stakersRecord[msg.sender][index].perDayReward;
        } else {
            claimableReward = stakersRecord[msg.sender][index].reward;
        }
        if (claimableReward > stakersRecord[msg.sender][index].reward) {
            claimableReward = stakersRecord[msg.sender][index].reward;
        }
        stakersRecord[msg.sender][index].withdrawan = true;
        uint256 _fee = (
            stakersRecord[msg.sender][index].amount.add(claimableReward)
        ).mul(withdrawFee).div(percentDivider);
        stakeToken.transfer(
            msg.sender,
            (stakersRecord[msg.sender][index].amount).sub(_fee)
        );
        stakeToken.transferFrom(owner, msg.sender, claimableReward);
        stakeToken.transfer(owner, _fee);
        totalWithdrawanToken = totalWithdrawanToken.add(
            stakersRecord[msg.sender][index].amount
        );
        totalClaimedRewardToken = totalClaimedRewardToken.add(claimableReward);
        Stakers[msg.sender].totalClaimedRewardTokenUser = Stakers[msg.sender]
            .totalClaimedRewardTokenUser
            .add(claimableReward);
        uint256 planIndex = stakersRecord[msg.sender][index].plan;
        userStakedPerPlan[msg.sender][planIndex] = userStakedPerPlan[
            msg.sender
        ][planIndex].sub(stakersRecord[msg.sender][index].amount, "user stake");

        emit WITHDRAW(
            msg.sender,
            claimableReward.add(stakersRecord[msg.sender][index].amount)
        );
    }

    function SetStakeDuration(uint256 first, uint256 second)
        external
        onlyowner
    {
        Duration[0] = first;
        Duration[1] = second;
    }

    function SetStakeBonus(uint256 first, uint256 second) external onlyowner {
        Bonus[0] = first;
        Bonus[1] = second;
    }

    function SetDivider(uint256 percent) external onlyowner {
        percentDivider = percent;
    }

    function SetFee(uint256 percent1, uint256 percent2) external onlyowner {
        depositFee = percent1;
        withdrawFee = percent2;
    }

    function SetTime(uint256 time) external onlyowner {
        timePeriod = time;
    }

    function SetOwner(address payable newOwner) external onlyowner {
        owner = newOwner;
    }

    function getStakeInfo(address _user, uint256 index)
        external
        view
        returns (
            uint256 unlockTime,
            uint256 amount,
            uint256 reward
        )
    {
        require(index < Stakers[_user].stakeCount, "Invalid index");
        uint256 claimableReward;
        if (block.timestamp < stakersRecord[_user][index].withdrawtime) {
            uint256 duration = (block.timestamp -
                stakersRecord[_user][index].staketime) / timePeriod;
            claimableReward =
                duration *
                stakersRecord[_user][index].perDayReward;
        } else {
            claimableReward = stakersRecord[_user][index].reward;
        }
        if (claimableReward > stakersRecord[_user][index].reward) {
            claimableReward = stakersRecord[_user][index].reward;
        }

        return (
            stakersRecord[_user][index].staketime +
                Duration[stakersRecord[_user][index].plan],
            stakersRecord[_user][index].amount,
            claimableReward
        );
    }

    function realtimeReward(address user) public view returns (uint256) {
        uint256 ret;
        for (uint256 i; i < Stakers[user].stakeCount; i++) {
            if (!stakersRecord[user][i].withdrawan) {
                uint256 val;
                val =
                    block.timestamp -
                    stakersRecord[user][i].staketime /
                    timePeriod;
                val = val.mul(stakersRecord[user][i].perDayReward);
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