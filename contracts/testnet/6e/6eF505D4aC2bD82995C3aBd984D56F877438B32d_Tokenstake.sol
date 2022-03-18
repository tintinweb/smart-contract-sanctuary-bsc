/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

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

contract Tokenstake {
    using SafeMath for uint256;
    IERC20 public stakeToken; //

    address payable public owner;

    uint256 public maxStakeableToken;
    uint256 public minimumStakeToken;
    uint256 public totalUnStakedToken;
    uint256 public totalStakedToken;
    uint256 public totalClaimedRewardToken;
    uint256 public totalStakers;
    uint256 public percentDivider;
    uint256 public totalFee;

    uint256[5] public Duration = [7 days, 14 days, 30 days, 60 days, 90 days];  // these are locking period of token we can also place  no of seconds here
    uint256[5] public Bonus = [6, 18, 50, 125, 250]; // these four bonus variable is related to duration and the amount will be multiply by 10 like we have to set 10 percent then put 100

    struct Stake {
        uint256 unstaketime;
        uint256 staketime;
        uint256 amount;
        uint256 reward;
        uint256 lastharvesttime;
        uint256 remainingreward;
        uint256 harvestreward;
        uint256 persecondreward;
        uint256 stakeDurationIndex;
        bool withdrawan;
        bool unstaked;
    }

    struct User {
        uint256 totalStakedTokenUser;
        uint256 totalUnstakedTokenUser;
        uint256 totalClaimedRewardTokenUser;
        uint256 stakeCount;
        uint256 firstduraIndex;
        uint256 secduraIndex;
        uint256 thirdduraIndex;
        uint256 fourthduraIndex;
        uint256 fifthduraIndex;
        bool alreadyExists;
    }

    mapping(address => User) public Stakers;
    mapping(uint256 => address) public StakersID;
    mapping(address => mapping(uint256 => Stake)) public stakersRecord;

    event STAKE(address Staker, uint256 amount);
    event HARVEST(address Staker, uint256 amount);
    event UNSTAKE(address Staker, uint256 amount);



    modifier onlyowner() {
        require(owner == msg.sender, "only owner");
        _;
    }
    constructor(address payable _owner, address token1) {
        owner = _owner; // address of owner of contract
        stakeToken = IERC20(token1); // address of token that we are using here
        totalFee = 0; // put the percent fee if token is getting any fee on transaction (also multiply with 10)
        maxStakeableToken = 1e25; // this is the maximum limit user can stake 
        percentDivider = 1000;
        minimumStakeToken = 1e18; // this is minimum iser can stake
    }

    /** This function is used for staking */
    function stake(uint256 amount1, uint256 timeperiod) public {
        require(timeperiod >= 0 && timeperiod <= 4, "Invalid Time Period");
        require(amount1 >= minimumStakeToken, "stake more than minimum amount");
        uint256 index = Stakers[msg.sender].stakeCount+1;
        if(timeperiod == 0){
            require(Stakers[msg.sender].firstduraIndex != 0,"Already Staked");
            Stakers[msg.sender].firstduraIndex = index;
            stakersRecord[msg.sender][index].stakeDurationIndex = 0;
        }
        if(timeperiod == 1){
            require(Stakers[msg.sender].secduraIndex != 0,"Already Staked");
            Stakers[msg.sender].secduraIndex = index;
            stakersRecord[msg.sender][index].stakeDurationIndex = 1;
        }
        if(timeperiod == 2){
            require(Stakers[msg.sender].thirdduraIndex != 0,"Already Staked");
            Stakers[msg.sender].thirdduraIndex = index;
            stakersRecord[msg.sender][index].stakeDurationIndex = 2;
        }
        if(timeperiod == 3){
            require(Stakers[msg.sender].fourthduraIndex != 0,"Already Staked");
            Stakers[msg.sender].fourthduraIndex = index;
            stakersRecord[msg.sender][index].stakeDurationIndex = 3;
        }
        if(timeperiod == 4){
            require(Stakers[msg.sender].fifthduraIndex != 0,"Already Staked");
            Stakers[msg.sender].fifthduraIndex = index;
            stakersRecord[msg.sender][index].stakeDurationIndex = 4;
        }


        uint256 amount = amount1.sub((amount1.mul(totalFee)).div(percentDivider));  // calculate the amount that goes in contract if token have fees 
        if (!Stakers[msg.sender].alreadyExists) {
            Stakers[msg.sender].alreadyExists = true;
            StakersID[totalStakers] = msg.sender;
            totalStakers++;
        }

        stakeToken.transferFrom(msg.sender, address(this), amount1);

        
        Stakers[msg.sender].totalStakedTokenUser = Stakers[msg.sender]
            .totalStakedTokenUser
            .add(amount);
        totalStakedToken = totalStakedToken.add(amount);
        stakersRecord[msg.sender][index].unstaketime = block.timestamp.add(
            Duration[timeperiod]
        );
        stakersRecord[msg.sender][index].staketime = block.timestamp;
        stakersRecord[msg.sender][index].amount = amount;
        stakersRecord[msg.sender][index].reward = amount
            .mul(Bonus[timeperiod])
            .div(percentDivider);
        stakersRecord[msg.sender][index].persecondreward = stakersRecord[
            msg.sender
        ][index].reward.div(Duration[timeperiod]);
        stakersRecord[msg.sender][index].lastharvesttime = 0;
        stakersRecord[msg.sender][index].remainingreward = stakersRecord[msg.sender][index].reward;
        stakersRecord[msg.sender][index].harvestreward = 0;
        Stakers[msg.sender].stakeCount++;

        emit STAKE(msg.sender, amount);
    }

    /** after locking period passed user will able to unstake token and if there is any remaining reward this will also withdrawn */

    function unstake(uint256 index) public {
        require(!stakersRecord[msg.sender][index].unstaked, "already unstaked");
        require(
            stakersRecord[msg.sender][index].unstaketime < block.timestamp,
            "cannot unstake after before duration"
        );
        
        uint256 stakeDuration = stakersRecord[msg.sender][index].stakeDurationIndex;
        if(stakeDuration == 0){
            Stakers[msg.sender].firstduraIndex = 0;
        }
        if(stakeDuration == 1){
            Stakers[msg.sender].secduraIndex = 0;
        }
        if(stakeDuration == 2){
            Stakers[msg.sender].thirdduraIndex = 0;
        }
        if(stakeDuration == 3){
            Stakers[msg.sender].fourthduraIndex = 0;
        }
        if(stakeDuration == 4){
            Stakers[msg.sender].fifthduraIndex = 0;
        }

        if(!stakersRecord[msg.sender][index].withdrawan){
            harvest(index);
        }
        stakersRecord[msg.sender][index].unstaked = true;

        stakeToken.transfer(
            msg.sender,
            stakersRecord[msg.sender][index].amount
        );
        
        totalUnStakedToken = totalUnStakedToken.add(
            stakersRecord[msg.sender][index].amount
        );
        Stakers[msg.sender].totalUnstakedTokenUser = Stakers[msg.sender]
            .totalUnstakedTokenUser
            .add(stakersRecord[msg.sender][index].amount);

        emit UNSTAKE(
            msg.sender,
            stakersRecord[msg.sender][index].amount
        );
    }

    /** this function will harvest reward in realtime */
    function harvest(uint256 index) public {
        require(
            !stakersRecord[msg.sender][index].withdrawan,
            "already withdrawan"
        );
        require(!stakersRecord[msg.sender][index].unstaked, "already unstaked");
        uint256 rewardTillNow;
        uint256 commontimestamp;
        (rewardTillNow,commontimestamp) = realtimeRewardPerBlock(msg.sender , index);
        stakersRecord[msg.sender][index].lastharvesttime =  commontimestamp;
        stakeToken.transfer(
            msg.sender,
            rewardTillNow
        );
        totalClaimedRewardToken = totalClaimedRewardToken.add(
            rewardTillNow
        );
        stakersRecord[msg.sender][index].remainingreward = stakersRecord[msg.sender][index].remainingreward.sub(rewardTillNow);
        stakersRecord[msg.sender][index].harvestreward = stakersRecord[msg.sender][index].harvestreward.add(rewardTillNow);
        Stakers[msg.sender].totalClaimedRewardTokenUser = Stakers[msg.sender]
            .totalClaimedRewardTokenUser
            .add(rewardTillNow);

        if(stakersRecord[msg.sender][index].harvestreward == stakersRecord[msg.sender][index].reward){
            stakersRecord[msg.sender][index].withdrawan = true;

        }

        emit HARVEST(
            msg.sender,
            rewardTillNow
        );
    }

     /** this function will return real time rerward of particular user's every block */
    function realtimeRewardPerBlock(address user, uint256 blockno) public view returns (uint256,uint256) {
        uint256 ret;
        uint256 commontimestamp;
            if (
                !stakersRecord[user][blockno].withdrawan &&
                !stakersRecord[user][blockno].unstaked
            ) {
                uint256 val;
                uint256 tempharvesttime = stakersRecord[user][blockno].lastharvesttime;
                commontimestamp = block.timestamp;
                if(tempharvesttime == 0){
                    tempharvesttime = stakersRecord[user][blockno].staketime;
                }
                val = commontimestamp - tempharvesttime;
                val = val.mul(stakersRecord[user][blockno].persecondreward);
                if (val < stakersRecord[user][blockno].remainingreward) {
                    ret += val;
                } else {
                    ret += stakersRecord[user][blockno].remainingreward;
                }
            }
        return (ret,commontimestamp);
    }

     /** this function will return real time rerward of particular user's every block */

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

    /** using this function owner of this contract will change the minimum and maximum stake limit we can also remove this method this doesn't affect the calculation */
    function SetStakeLimits(uint256 _min, uint256 _max) external onlyowner {
        minimumStakeToken = _min;
        maxStakeableToken = _max;
    }

    /** if token fees percentage change owner have to update using this method value will be multiplied with 10 */
    function SetTotalFees(uint256 _fee) external onlyowner {
        totalFee = _fee;
    }
    /** this method is only callable by owner address and it is used to change the stake duration (locking period ), argument will be in second */
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

    /** this method is used to base currency*/

    function withdrawBaseCurrency() public onlyowner {
        uint256 balance = address(this).balance;
        require(balance > 0, "does not have any balance");
        payable(msg.sender).transfer(balance);
    }
    /** these two method will help owner to withdraw any wrongly deposit token
    * first call initToken method with passing token contract address as an argument 
    * then call withdrawToken with valur in wei as an argument */
    function withdrawToken(address addr,uint256 amount) public onlyowner {
        IERC20(addr).transfer(msg.sender
        , amount);
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