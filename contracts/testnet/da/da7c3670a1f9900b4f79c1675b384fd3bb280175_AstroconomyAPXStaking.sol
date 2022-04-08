/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

pragma solidity ^0.8.10;

// SPDX-License-Identifier: MIT

/**
:::'###:::::'######::'########:'########:::'#######:::'######:::'#######::'##::: ##::'#######::'##::::'##:'##:::'##:
::'## ##:::'##... ##:... ##..:: ##.... ##:'##.... ##:'##... ##:'##.... ##: ###:: ##:'##.... ##: ###::'###:. ##:'##::
:'##:. ##:: ##:::..::::: ##:::: ##:::: ##: ##:::: ##: ##:::..:: ##:::: ##: ####: ##: ##:::: ##: ####'####::. ####:::
'##:::. ##:. ######::::: ##:::: ########:: ##:::: ##: ##::::::: ##:::: ##: ## ## ##: ##:::: ##: ## ### ##:::. ##::::
 #########::..... ##:::: ##:::: ##.. ##::: ##:::: ##: ##::::::: ##:::: ##: ##. ####: ##:::: ##: ##. #: ##:::: ##::::
 ##.... ##:'##::: ##:::: ##:::: ##::. ##:: ##:::: ##: ##::: ##: ##:::: ##: ##:. ###: ##:::: ##: ##:.:: ##:::: ##::::
 ##:::: ##:. ######::::: ##:::: ##:::. ##:. #######::. ######::. #######:: ##::. ##:. #######:: ##:::: ##:::: ##::::
..:::::..:::......::::::..:::::..:::::..:::.......::::......::::.......:::..::::..:::.......:::..:::::..:::::..:::::
**/

// ASTROCONOMY™ Staking pools
// https://astroconomy.app

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

contract AstroconomyAPXStaking {
    using SafeMath for uint256;
    IBEP20 public token;
    IBEP20 public reward_token;
    address payable public owner;

    uint256 public totalStakedToken;
    uint256 public totalUnStakedToken;
    uint256 public totalWithdrawnToken;
    uint256 public totalClaimedRewardToken;
    uint256 public totalStakers;
    uint256 public unstakePercent = 10;
    uint256 public percentDivider = 100;

    uint256[5] public Duration = [
        1 days,
        15 days,
        30 days,
        90 days,
        180 days
    ];
    uint256[5] public Bonus = [15, 25, 35, 50, 75];
    uint256[5] public totalStakedPerPlan;
    uint256[5] public totalStakersPerPlan;

    struct Stake {
        uint256 plan;
        uint256 withdrawtime;
        uint256 staketime;
        uint256 amount;
        uint256 reward;
        uint256 persecondreward;
        bool withdrawn;
        bool unstaked;
    }

    struct User {
        uint256 totalStakedTokenUser;
        uint256 totalWithdrawnTokenUser;
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

    constructor(address _owner, address _token, address _reward_token ) {
        owner = payable(_owner);
        token = IBEP20(_token);
        reward_token = IBEP20(_reward_token);
    }

    function stake(uint256 amount, uint256 planIndex) public {
        require(planIndex >= 0 && planIndex <= 5, "Incorrect Staking Period Submitted");
        require(amount >= 0, "stake more than 0");
        require(token.balanceOf(msg.sender) >= amount,"Insufficient Staking Token Balance");

        if (!Stakers[msg.sender].alreadyExists) {
            Stakers[msg.sender].alreadyExists = true;
            totalStakers++;
        }

        uint256 index = Stakers[msg.sender].stakeCount;
        Stakers[msg.sender].totalStakedTokenUser = Stakers[msg.sender].totalStakedTokenUser.add(amount);

        stakedTokens[msg.sender] = stakedTokens[msg.sender].add(amount);
        totalStakedToken = totalStakedToken.add(amount);
        stakersRecord[msg.sender][index].withdrawtime = block.timestamp.add(Duration[planIndex]);

        stakersRecord[msg.sender][index].staketime = block.timestamp;
        stakersRecord[msg.sender][index].amount = amount;
        stakersRecord[msg.sender][index].reward = amount.mul(Bonus[planIndex]).div(percentDivider);

        stakersRecord[msg.sender][index].persecondreward = stakersRecord[msg.sender][index].reward.div(Duration[planIndex]);
        stakersRecord[msg.sender][index].plan = planIndex;
        Stakers[msg.sender].stakeCount++;

        userStakedPerPlan[msg.sender][planIndex] = userStakedPerPlan[msg.sender][planIndex].add(amount);
        totalStakedPerPlan[planIndex] = totalStakedPerPlan[planIndex].add( amount );

        totalStakersPerPlan[planIndex]++;

        emit STAKE(msg.sender, amount);
    }

    function unstake(uint256 index) public {
        require( !stakersRecord[msg.sender][index].withdrawn, "Cannot unstaked: already withdrawn" );
        require( !stakersRecord[msg.sender][index].unstaked, "Cannot unstaked: already unstaked" );
        require( index < Stakers[msg.sender].stakeCount,"Invalid index" );

        uint256 planIndex = stakersRecord[msg.sender][index].plan;
        uint256 _amount = stakersRecord[msg.sender][index].amount;
        uint256 deductionAmount = 0;

        stakersRecord[msg.sender][index].unstaked = true;
        if (planIndex > 0) {
            deductionAmount = unstakeDeductionAmount(msg.sender ,index);
            token.transferFrom( msg.sender, owner,deductionAmount);
        } 
        
        stakedTokens[msg.sender] = stakedTokens[msg.sender].sub(_amount);
        totalUnStakedToken = totalUnStakedToken.add( _amount );
        Stakers[msg.sender].totalUnStakedTokenUser = Stakers[msg.sender].totalUnStakedTokenUser.add(_amount);

        userStakedPerPlan[msg.sender][planIndex] = userStakedPerPlan[ msg.sender ][planIndex].sub(_amount, "user stake");
        totalStakedPerPlan[planIndex] = totalStakedPerPlan[planIndex].sub( _amount, "total stake" );
        totalStakersPerPlan[planIndex]--;

        emit UNSTAKE(msg.sender, _amount);
    }

    function getStakingId() public view returns (uint256) {
        return Stakers[msg.sender].stakeCount;
    }

    function getStakingIdByAddress(address addrToLookUp) public view returns (uint256) {
        return Stakers[addrToLookUp].stakeCount;
    }    

    function withdraw(uint256 index) public {

        require( !stakersRecord[msg.sender][index].withdrawn, "already withdrawn" );
        require( !stakersRecord[msg.sender][index].unstaked, "already unstaked" );
        require( stakersRecord[msg.sender][index].withdrawtime < block.timestamp, "cannot withdraw before stake duration" );
        require( index < Stakers[msg.sender].stakeCount,"Invalid index" );

        uint256 _amount = stakersRecord[msg.sender][index].amount;
        stakersRecord[msg.sender][index].withdrawn = true;
        
        // Send reward_token:
        reward_token.transferFrom( owner, msg.sender, stakersRecord[msg.sender][index].reward);

        stakedTokens[msg.sender] = stakedTokens[msg.sender].sub(_amount);
        totalWithdrawnToken = totalWithdrawnToken.add( _amount );
        totalClaimedRewardToken = totalClaimedRewardToken.add(stakersRecord[msg.sender][index].reward);
        Stakers[msg.sender].totalWithdrawnTokenUser = Stakers[msg.sender].totalWithdrawnTokenUser.add(_amount);
        Stakers[msg.sender].totalClaimedRewardTokenUser = Stakers[msg.sender].totalClaimedRewardTokenUser.add(stakersRecord[msg.sender][index].reward);
        uint256 planIndex = stakersRecord[msg.sender][index].plan;
        userStakedPerPlan[msg.sender][planIndex] = userStakedPerPlan[ msg.sender ][planIndex].sub(_amount, "user stake");
        totalStakedPerPlan[planIndex] = totalStakedPerPlan[planIndex].sub( _amount, "total stake" );
        totalStakersPerPlan[planIndex]--;

        emit WITHDRAW( msg.sender, stakersRecord[msg.sender][index].reward.add( _amount ) );

    }

    function unstakeDeductionAmount(address user, uint256 index) public view returns(uint256) {
        uint256 _amount = stakersRecord[user][index].amount;
        return _amount.mul(unstakePercent).div(percentDivider);
    }

    function SetStakeDuration(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth,
        uint256 fifth
    ) external onlyowner {
        Duration[0] = first;
        Duration[1] = second;
        Duration[2] = third;
        Duration[3] = fourth;
        Duration[4] = fifth;
    }

    function SetStakeBonus(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth,
        uint256 fifth
    ) external onlyowner {
        Bonus[0] = first;
        Bonus[1] = second;
        Bonus[2] = third;
        Bonus[3] = fourth;
        Bonus[4] = fifth;
    }

    function setUnstakePercent(uint256 _percent) external onlyowner {
        unstakePercent = _percent;
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

    function changeRewardToken(address _reward_token) external onlyowner {
        reward_token = IBEP20(_reward_token);
    }

    function removeStuckToken(address _token) external onlyowner {
        IBEP20(_token).transfer(owner, IBEP20(_token).balanceOf(address(this)));
    }

    function realtimeReward(address user) public view returns (uint256) {
        uint256 ret;
        for (uint256 i; i < Stakers[user].stakeCount; i++) {
            if (
                !stakersRecord[user][i].withdrawn &&
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