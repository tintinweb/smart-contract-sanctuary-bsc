/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

pragma solidity ^0.8.10;

// SPDX-License-Identifier: MIT

interface IBEP20 {
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

contract OTStaking {
    using SafeMath for uint256;
    IBEP20 public token;
    address payable public owner;

    uint256 public totalStakedToken;
    uint256 public totalUnStakedToken;
    uint256 public totalWithdrawanToken;
    uint256 public totalClaimedRewardToken;
    uint256 public totalStakers;
    uint256 public percentDivider = 1000;

    uint256[3] public Duration = [
        7 days,
        14 days,
        30 days
    ];
    uint256[3] public Reward = [50, 75, 100]; //gives: 60%, 90% and 120% in 1 year
    uint256[3] public totalStakedPerPlan;
    uint256[3] public totalStakersPerPlan;

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

    mapping(address => User) public Stakers;
    mapping(address => mapping(uint256 => Stake)) public stakersRecord;
    mapping(address => mapping(uint256 => uint256)) public userStakedPerPlan;
    mapping(address => uint256) public stakedTokens;

    event STAKE(address Staker, uint256 amount);
    event UNSTAKE(address Staker, uint256 amount);
    event WITHDRAW(address Staker, uint256 amount);

    modifier onlyowner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    constructor(address _owner, address _token) {
        owner = payable(_owner);
        token = IBEP20(_token);
    }

    function stake(uint256 amount, uint256 planIndex) public {
        require(planIndex >= 0 && planIndex <= 3, "Invalid time period");
        require(amount >= 0, "Stake more than 0");
        require(token.balanceOf(msg.sender) >= amount,"Insufficient balance");

        if (!Stakers[msg.sender].alreadyExists) {
            Stakers[msg.sender].alreadyExists = true;
            totalStakers++;
        }

        token.transferFrom(
          msg.sender,
          owner,
          amount*10**9
        );

        uint256 index = Stakers[msg.sender].stakeCount;
        Stakers[msg.sender].totalStakedTokenUser = Stakers[msg.sender]
            .totalStakedTokenUser
            .add(amount);
        stakedTokens[msg.sender] = stakedTokens[msg.sender].add(amount);
        totalStakedToken = totalStakedToken.add(amount);
        stakersRecord[msg.sender][index].withdrawtime = block.timestamp.add(
            Duration[planIndex]
        );
        stakersRecord[msg.sender][index].staketime = block.timestamp;
        stakersRecord[msg.sender][index].amount = amount;
        stakersRecord[msg.sender][index].reward = amount
            .mul(Reward[planIndex])
            .div(percentDivider);
        stakersRecord[msg.sender][index].persecondreward = stakersRecord[
            msg.sender
        ][index].reward.div(Duration[planIndex]);
        stakersRecord[msg.sender][index].plan = planIndex;
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
        require(!stakersRecord[msg.sender][index].withdrawan,"Already withdrawan");
        require(!stakersRecord[msg.sender][index].unstaked, "Already unstaked");
        require(index < Stakers[msg.sender].stakeCount,"Stake not found");
        require(stakersRecord[msg.sender][index].withdrawtime < block.timestamp, "Wait unlock time");

        uint256 _amount = stakersRecord[msg.sender][index].amount;

        stakersRecord[msg.sender][index].unstaked = true;
        
        token.transfer(
            msg.sender,
            _amount*1e9
        );

        stakedTokens[msg.sender] = stakedTokens[msg.sender].sub(_amount);
        totalUnStakedToken = totalUnStakedToken.add(
            _amount
        );
        Stakers[msg.sender].totalUnStakedTokenUser = Stakers[msg.sender]
            .totalUnStakedTokenUser
            .add(_amount);
        uint256 planIndex = stakersRecord[msg.sender][index].plan;
        userStakedPerPlan[msg.sender][planIndex] = userStakedPerPlan[
            msg.sender
        ][planIndex].sub(_amount, "User stake");
        totalStakedPerPlan[planIndex] = totalStakedPerPlan[planIndex].sub(
            _amount,
            "Total stake"
        );
        totalStakersPerPlan[planIndex]--;

        emit UNSTAKE(msg.sender, _amount);
    }

    function withdrawRewards(uint256 index) public {
        require(!stakersRecord[msg.sender][index].withdrawan, "Already withdrawan");
        require(!stakersRecord[msg.sender][index].unstaked, "Already unstaked");
        require(stakersRecord[msg.sender][index].withdrawtime < block.timestamp, "Wait unlock time");
        require(index < Stakers[msg.sender].stakeCount, "Invalid index");

        uint256 _amount = stakersRecord[msg.sender][index].reward;
        stakersRecord[msg.sender][index].withdrawan = true;
        
        token.transfer(
            msg.sender,
            _amount*1e9
        );

        totalWithdrawanToken = totalWithdrawanToken.add(_amount);
        totalClaimedRewardToken = totalClaimedRewardToken.add(_amount);
        Stakers[msg.sender].totalWithdrawanTokenUser = Stakers[msg.sender]
            .totalWithdrawanTokenUser
            .add(_amount);
        Stakers[msg.sender].totalClaimedRewardTokenUser = Stakers[msg.sender]
            .totalClaimedRewardTokenUser
            .add(_amount);

        emit WITHDRAW(
            msg.sender,
            _amount
        );
    }

    function SetStakeDuration(
        uint256 first,
        uint256 second,
        uint256 third
    ) external onlyowner {
        Duration[0] = first;
        Duration[1] = second;
        Duration[2] = third;
    }

    function SetStakeReward(
        uint256 first,
        uint256 second,
        uint256 third
    ) external onlyowner {
        Reward[0] = first;
        Reward[1] = second;
        Reward[2] = third;
    }

    function setPercentDivider(uint256 _divider) external onlyowner {
        percentDivider = _divider;
    }

    function changeOwner(address payable _owner) external onlyowner {
        owner = _owner;
    }

    function changeToken(address _token) external onlyowner {
        token = IBEP20(_token);
    }

    function removeStuckToken(address _token) external onlyowner {
        IBEP20(_token).transfer(owner, IBEP20(_token).balanceOf(address(this)));
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