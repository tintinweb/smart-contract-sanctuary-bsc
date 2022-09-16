/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-13
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

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

contract NTClaimableStaking {
    using SafeMath for uint256;
    IBEP20 public token;
    address payable public owner;

    uint256 public totalStakedToken;
    uint256 public totalUnStakedToken;
    uint256 public totalClaimedRewardToken;
    uint256 public totalStakers;
    uint256 public unstakeFeePercentage = 20; //2%
    uint256 public percentDivider = 1000;

    uint256[4] public Duration = [
        7 days,
        14 days,
        30 days,
        90 days
    ];
    uint256[4] public Reward = [12, 36, 99, 493];
    uint256[4] public totalStakedPerPlan;
    uint256[4] public totalStakersPerPlan;

    struct Stake {
        uint256 plan;
        uint256 unstaketime;
        uint256 lastclaimtime;
        uint256 staketime;
        uint256 stakeamount;
        uint256 reward;
        uint256 hourlyreward;
        uint256 rewardclaimed;
        bool unstaked;
    }

    struct User {
        uint256 totalStakedTokenUser;
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
    event CLAIM(address Staker, uint256 amount);

    modifier onlyowner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    constructor(address _owner, address _token) {
        owner = payable(_owner);
        token = IBEP20(_token);
    }

    function stake(uint256 amount, uint256 planIndex) public {
        require(planIndex >= 0 && planIndex <= 3, "Invalid plan index");
        require(amount >= 0, "Stake more than 0");
        require(token.balanceOf(msg.sender) >= amount,"Insufficient balance");

        if (!Stakers[msg.sender].alreadyExists) {
            Stakers[msg.sender].alreadyExists = true;
            totalStakers++;
        }

        token.transferFrom(
          msg.sender,
          owner,
          amount*1e9
        );

        uint256 index = Stakers[msg.sender].stakeCount;
        Stakers[msg.sender].totalStakedTokenUser = Stakers[msg.sender].totalStakedTokenUser.add(amount);
        stakedTokens[msg.sender] = stakedTokens[msg.sender].add(amount);
        totalStakedToken = totalStakedToken.add(amount);
        stakersRecord[msg.sender][index].unstaketime = block.timestamp.add(Duration[planIndex]);
        stakersRecord[msg.sender][index].staketime = block.timestamp;
        stakersRecord[msg.sender][index].stakeamount = amount;
        stakersRecord[msg.sender][index].reward = amount.mul(Reward[planIndex]).div(percentDivider);

        uint256 _hours = Duration[planIndex].div(1 hours);
        
        stakersRecord[msg.sender][index].hourlyreward = stakersRecord[msg.sender][index].reward.div(_hours);
        stakersRecord[msg.sender][index].plan = planIndex;
        stakersRecord[msg.sender][index].rewardclaimed = 0;
        Stakers[msg.sender].stakeCount++;
        userStakedPerPlan[msg.sender][planIndex] = userStakedPerPlan[msg.sender][planIndex].add(amount);
        totalStakedPerPlan[planIndex] = totalStakedPerPlan[planIndex].add(amount);
        totalStakersPerPlan[planIndex]++;

        emit STAKE(msg.sender, amount);
    }

    function unstake(uint256 index) public {
        require(!stakersRecord[msg.sender][index].unstaked, "Already unstaked");
        require(index < Stakers[msg.sender].stakeCount, "Stake not found");
        require(stakersRecord[msg.sender][index].unstaketime < block.timestamp, "Wait unstake time");

        uint256 _unstakeAmount = stakersRecord[msg.sender][index].stakeamount;
        uint256 _unstakeFee = _unstakeAmount.mul(unstakeFeePercentage).div(percentDivider);
        uint256 _amount = _unstakeAmount.sub(_unstakeFee);

        stakersRecord[msg.sender][index].unstaked = true;
        
        token.transfer(owner, _unstakeFee*1e9);
        token.transfer(msg.sender, _amount*1e9);

        stakedTokens[msg.sender] = stakedTokens[msg.sender].sub(_amount+_unstakeFee);
        totalUnStakedToken = totalUnStakedToken.add(_amount+_unstakeFee);
        Stakers[msg.sender].totalUnStakedTokenUser = Stakers[msg.sender].totalUnStakedTokenUser.add(_amount+_unstakeFee);
        uint256 planIndex = stakersRecord[msg.sender][index].plan;
        userStakedPerPlan[msg.sender][planIndex] = userStakedPerPlan[msg.sender][planIndex].sub(_amount+_unstakeFee);
        totalStakedPerPlan[planIndex] = totalStakedPerPlan[planIndex].sub(_amount+_unstakeFee);
        totalStakersPerPlan[planIndex]--;

        emit UNSTAKE(msg.sender, _amount);
    }

    function getClaimable(address user, uint256 _index) public view returns(uint256) {

        uint256 _hourlyreward = stakersRecord[user][_index].hourlyreward;
        uint256 _sincelastclaim = block.timestamp.sub(stakersRecord[user][_index].lastclaimtime);
        uint256 _claimable = _hourlyreward.mul(_sincelastclaim).div(1 hours);

        return _claimable;
    }

    function claimRewards(uint256 index) public {
        require(index < Stakers[msg.sender].stakeCount, "Invalid index");
        require(stakersRecord[msg.sender][index].rewardclaimed < stakersRecord[msg.sender][index].reward, "All rewards claimed");
        //require(block.timestamp.sub(stakersRecord[msg.sender][index].lastclaimtime) >= 86400, "Please wait next claim time");
        
        uint256 _claimable = getClaimable(msg.sender, index);

        if(_claimable > (stakersRecord[msg.sender][index].reward).sub(stakersRecord[msg.sender][index].rewardclaimed)){
            _claimable = (stakersRecord[msg.sender][index].reward).sub(stakersRecord[msg.sender][index].rewardclaimed);
        }
         
        token.transfer(msg.sender, _claimable*1e9);

        stakersRecord[msg.sender][index].lastclaimtime = block.timestamp;
        totalClaimedRewardToken = totalClaimedRewardToken.add(_claimable);
        Stakers[msg.sender].totalClaimedRewardTokenUser = Stakers[msg.sender].totalClaimedRewardTokenUser.add(_claimable);
        stakersRecord[msg.sender][index].rewardclaimed = stakersRecord[msg.sender][index].rewardclaimed.add(_claimable);

        emit CLAIM(msg.sender, _claimable);
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

    function SetStakeReward(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth
    ) external onlyowner {
        Reward[0] = first;
        Reward[1] = second;
        Reward[2] = third;
        Reward[3] = fourth;
    }

    function setPercentDivider(uint256 _divider) external onlyowner {
        percentDivider = _divider;
    }

     function setUnstakeFeePercentage(uint256 _percentage) external onlyowner {
        unstakeFeePercentage = _percentage;
    }

    function changeOwner(address payable _owner) external onlyowner {
        require(_owner == address(this) || _owner == owner, "Not allowed");
        owner = _owner;
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