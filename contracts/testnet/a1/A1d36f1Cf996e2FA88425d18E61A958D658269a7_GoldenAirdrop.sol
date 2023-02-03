/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

// SPDX-License-Identifier:MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function balanceOf(address account) external view returns(uint256);
    function transfer(address receiver, uint256 tokenAmount) external  returns(bool);
    function transferFrom( address tokenOwner, address recipient, uint256 tokenAmount) external returns(bool);
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
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract GoldenAirdrop is Ownable {
    using SafeMath for uint256;

    IERC20 public HPG;
    uint256 public timeSlot ;
    uint256 public rewardPercentage ;
    uint256 public lockTime ;
    uint256 public fee;
    uint256 public slotTime;
    uint256 public startStakingTime;
    uint256 public startStakingTime1;
    uint256 public minimumWithdraw;

    address public taxAddress;
    address[] private Stakeholders;

    struct Staking {
        uint256 stakedAmount;
        uint256 claimedReward;
        uint256 stakingTime;
        uint256 unstakeTime;
    }

    mapping(address => Staking) public userInfo;
    mapping (address => bool) public  blacklist;


    constructor() {
        HPG = IERC20(0x42CB5042b9973C22fc8E6799151243fAB34041dc);
        timeSlot = 60 seconds;
        rewardPercentage = 250000000000000000;
        lockTime = 30 minutes;
        startStakingTime = 5;
        startStakingTime1 = 300 seconds;
        minimumWithdraw = 300e18;
        slotTime = 30;
        fee = 10;
        taxAddress = 0xc2E3aDdd10F6C48082Ac8173B864dd304930E6d8;
    }

    function airDrop(address[] memory _recipients,uint256[] memory amount) public onlyOwner {
        
        for (uint256 i;i<_recipients.length; i++) {
            require(_recipients[i] != address(0));
            lockStake(_recipients[i], amount[i]);
        }
    }

    function lockStake(address user,uint256 amount) private {
        userInfo[user].stakedAmount = amount;
        userInfo[user].stakingTime = block.timestamp;
        userInfo[user].unstakeTime = userInfo[user].stakingTime.add(lockTime);
        Stakeholders.push(user);
    }

    function unStake(address user) private {
        require(userInfo[user].stakedAmount > 0, " No staking found for the given user ");
        if(block.timestamp >= userInfo[user].unstakeTime)
        { userInfo[user].stakedAmount = 0; }
    }

    function calcTime(address user) public view returns(uint256 time_) {
        uint256 time = ((block.timestamp.sub(userInfo[user].stakingTime)).div(timeSlot));
        if(time > 10){
            time = 10;
        }
        time_= time;
    } 

    function calculateReward(address user) public view 
    returns (uint256 lockedAmount,uint256 stakedAmounts,uint256 rewards,uint256 Days) {
        uint256 reward;
        uint256 totalReward;
        uint256 day = calcTime(user);
        if(day <= 5){
            return (userInfo[user].stakedAmount,0,0,day);
        }else{
        uint256 stakeAmount = userInfo[user].stakedAmount;
        reward = (((userInfo[user].stakedAmount).mul(rewardPercentage)).div(100));
        day = day.sub(startStakingTime);     
        reward = reward.mul(day);
        reward = reward.div(1e18);
        totalReward = (reward.sub(userInfo[user].claimedReward));
        return (0,stakeAmount,totalReward,day);
        }
    }

    function calculateFees(uint256 amount) private view returns(uint256 taxFee, uint256 withdrawAble){
        taxFee = (amount.mul(fee)).div(100);
        withdrawAble = amount.sub(taxFee);
    }

    function claimReward(address user) public {
        require(blacklist[user] != true,"you are blacklisted!");
        require(block.timestamp > (userInfo[user].stakingTime),"error");
        (,,uint256 _reward,) = calculateReward(user);
        require(_reward >= minimumWithdraw,"low amount!");
        (uint256 taxAmount , uint256 withdrawAble) = calculateFees(_reward);
        userInfo[user].claimedReward = userInfo[user].claimedReward.add(_reward);
        HPG.transfer(taxAddress, taxAmount);
        HPG.transfer(user, withdrawAble);
        unStake(user);
    }

    function addToblackList(address _addr)
    public
    onlyOwner
    {
        require(blacklist[_addr]==false,"already blacklisted");
        blacklist[_addr]=true;
    }

    function getStakeHolders() public view returns(uint256){
        return Stakeholders.length;
    }

    function setFee(uint256 feeAmount) public onlyOwner {
        fee = feeAmount;
    }

    function setRewardPercent(uint256 percent) public onlyOwner {
        rewardPercentage = percent;
    }

    function getTokens() public onlyOwner{
        HPG.transfer(owner(),HPG.balanceOf(address(this)));
    }

    function getTokensWithAmount(uint256 claimAble) public onlyOwner{
        HPG.transfer(owner(),claimAble);
    }
}

// ["100000000000000000000","10000000000000000000000"],"400000000000000000000","500000000000000000000","300000000000000000000"]

// ["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]