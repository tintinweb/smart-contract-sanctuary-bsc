/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

pragma solidity 0.7.6;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
       
        require(b > 0, errorMessage);
        uint256 c = a / b;
        
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

////////////////////////////////////////////////////////

contract LinoStaker is Ownable {
    using SafeMath for uint256;

    struct UserInfo {
        uint256 deposited;
        uint256 reward;
        uint256 lastTimeStaked;
        bool Staked;
    }

    //Setting
    uint256 public PercentOfReward = 7; //7 %
    uint256 public PeriodTimeBySecond=60*60*24*1;//one Month is 60*60*24*30
    uint256 public StartedTimer=0;

    mapping (address => UserInfo) users;
    address[] Stakers;

    //Token
    IERC20 public depositToken;
    IERC20 public rewardToken;

    //Pool
    uint256 public totalStaked=0;
    uint256 public PoolReward=0;
    

    ///////Events
    event AddRewards(uint256 amount, uint256 lengthInDays);
    event ClaimReward(address indexed user);
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Skim(uint256 amount);
    ///////////////////////

    constructor(address _depositToken, address _rewardToken) {
        depositToken = IERC20(_depositToken);
        rewardToken = IERC20(_rewardToken);
    }

    //Functions Setting 
    function AddRewardByChangeSetting(uint256 _amount,uint256 _percent,uint256 _days) onlyOwner public{
        require((block.timestamp-StartedTimer)>PeriodTimeBySecond,"Staker: Not Finish Last Stake");
        uint256 newAdd = _amount*1000000000000000000;
        require(rewardToken.transferFrom(msg.sender,address(this),newAdd),"Staker: transfer faild");
        PoolReward=PoolReward.add(_amount);
        for(uint i=0; i<Stakers.length; i++){
            UserInfo storage user = users[Stakers[i]];
            uint256 Rewarded = CalcaluateReward(Stakers[i]);
            PoolReward = PoolReward.sub(Rewarded);
            users[Stakers[i]].reward=users[Stakers[i]].reward.add(Rewarded);
            PoolReward = PoolReward.sub(Rewarded);
        }
        StartedTimer = block.timestamp;
        PeriodTimeBySecond = _days*60*60*24;
        PercentOfReward = _percent;
    }
    //
    function AddRewardPool(uint256 _amount) onlyOwner public {
        uint256 newAdd = _amount*1000000000000000000;
        require(rewardToken.transferFrom(msg.sender,address(this),newAdd),"Staker: transfer faild");
        PoolReward.add(_amount);
    }
    //
    function setPeriodOfReward(uint256 _dayOfPeriod) onlyOwner public{
        PeriodTimeBySecond = _dayOfPeriod*60*60*24;
    }
    //
    function setPercentOfReward(uint256 _percent) onlyOwner public{
        require((block.timestamp-StartedTimer)>PeriodTimeBySecond,"Staker: Not Finish Last Stake");
        for(uint i=0; i<Stakers.length; i++){
            UserInfo storage user = users[Stakers[i]];
            uint256 Rewarded = CalcaluateReward(Stakers[i]);
            users[Stakers[i]].reward=users[Stakers[i]].reward.add(Rewarded);
            PoolReward = PoolReward.sub(Rewarded);
        }
        PercentOfReward = _percent;
    }
    ////////////////////////////

    function deposit(uint256 _amount)
    public {
        UserInfo storage user = users[msg.sender];
        // require(user.deposited==0,"Staker: transferFrom failed");
        //////List Of Users
        bool insert = true;
        for(uint i=0; i<Stakers.length; i++){
            if(Stakers[i]==msg.sender) insert=false;
        }
        if(insert==true) Stakers.push(msg.sender);
        ///////////////////
        user.deposited = user.deposited.add(_amount);
        totalStaked = totalStaked.add(_amount);
        user.lastTimeStaked=block.timestamp;
        uint256 depositnew = _amount*1000000000000000000;
        require(depositToken.transferFrom(msg.sender, address(this), depositnew), "Staker: transferFrom failed");
        user.Staked = true;
        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _amount)
    public {
        UserInfo storage user = users[msg.sender];
        require(user.deposited >= _amount, "Staker: balance not enough");
        uint256 Rewarded = CalcaluateReward(msg.sender);
        users[msg.sender].reward=users[msg.sender].reward.add(Rewarded);
        users[msg.sender].deposited = users[msg.sender].deposited.add(users[msg.sender].reward);
        users[msg.sender].reward = 0;
        user.lastTimeStaked = block.timestamp;
        uint256 newWithdraw = users[msg.sender].deposited*1000000000000000000;
        require(depositToken.transfer(msg.sender,newWithdraw),"Staker: Error Withdraw");
        users[msg.sender].deposited = users[msg.sender].deposited.sub(_amount);
        totalStaked = totalStaked.sub(_amount);
        PoolReward = PoolReward.sub(Rewarded);
        user.Staked = false;
        emit Withdraw(msg.sender, _amount);
    }


    function claimReward() public{
        UserInfo storage user = users[msg.sender];
        require(user.deposited!=0,"Staker: transferFrom failed");
        require((block.timestamp-StartedTimer)<=PeriodTimeBySecond);
        uint256 Rewarded = CalcaluateReward(msg.sender);
        user.reward = user.reward.add(Rewarded);
        uint256 newReward = user.reward * 1000000000000000000;
        require(rewardToken.transfer(msg.sender,newReward),"Staker: Error Withdraw");
        PoolReward = PoolReward.sub(Rewarded);
        user.reward = 0;
        user.lastTimeStaked = block.timestamp;
        emit ClaimReward(msg.sender);
    }

    ////////Change Token
    function changeDepositToken(address _depositToken) onlyOwner public {
        depositToken = IERC20(_depositToken);
    }
    function changeRewardToken(address _rewardToken) onlyOwner public {
        rewardToken = IERC20(_rewardToken);
    }
    /////////////////////////////////////////
    
    //////////////////Views
    function poolSupply() public view returns (uint256){
        return PoolReward;
    }
    
    function TimeStamp() public view returns(uint256){
        return block.timestamp;
    }

    function ShowViews() view public returns
    (uint256 _percentOfReward,uint256 _StartedTimer,uint256 _PeriodTimeBySecond,uint256 _totalStaked,uint256 _Poolreward) {
        _percentOfReward = PercentOfReward;
        _StartedTimer = StartedTimer;
        _PeriodTimeBySecond = PeriodTimeBySecond;
        _totalStaked = totalStaked;
        _Poolreward = PoolReward;
    }

    function RewardUser(address _user) view public returns
    (uint256 AllReward,uint256 Rewarded,
    uint256 PercentOfTime,uint256 StakedTime,uint256 AllTimesRun,uint256 lasttimeuser,
    uint256 Deposited){
        UserInfo storage user = users[_user];
        lasttimeuser = user.lastTimeStaked;
        AllTimesRun = block.timestamp - StartedTimer;
        StakedTime = block.timestamp - user.lastTimeStaked;
        PercentOfTime = (StakedTime*100)/PeriodTimeBySecond;
        AllReward = (user.deposited*PercentOfReward)/100;
        Rewarded = (AllReward*PercentOfTime)/100;
        Deposited = user.deposited;
    }

    function BalanceOfTokenDeposit(address user) public view returns (uint256){
        return depositToken.balanceOf(user);
    }

    function CalcaluateReward(address _user) view internal returns(uint256){
        UserInfo storage user = users[_user];
        uint256 lasttimeuser = user.lastTimeStaked;
        uint256 AllTimesRun = block.timestamp - StartedTimer;
        uint256 StakedTime = block.timestamp - user.lastTimeStaked;
        uint256 PercentOfTime = (StakedTime*100)/PeriodTimeBySecond;
        uint256 AllReward = (user.deposited*PercentOfReward)/100;
        uint256 Rewarded = (AllReward*PercentOfTime)/100;
        return Rewarded;
    }

    function WithdrawAllPool() public onlyOwner{
        rewardToken.transfer(msg.sender,rewardToken.balanceOf(address(this)));
        depositToken.transfer(msg.sender,depositToken.balanceOf(address(this)));
    }

}