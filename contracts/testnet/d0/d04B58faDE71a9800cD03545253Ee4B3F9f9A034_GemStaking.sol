/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC721{
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function getTokenIdInfo(uint256 tokenID) external view returns(uint256,uint256);
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

contract GemStaking is Ownable{

    using SafeMath for uint256;
    IERC721 public gemNft;
    uint256 public Stakers;
    
    //////////////////////
    uint256 gen1Score = 8;
    uint256 gen2Score = 7;
    uint256 gen3Score = 6;
    uint256 gen4Score = 5;
    uint256 gen5Score = 4;
    uint256 gen6Score = 3;
    uint256 gen7Score = 2;
    uint256 gen8Score = 1;
    //////////////////////

    uint256 public curCycle = 1;
    uint256 public cycleSlots = 720; // maxCycleTime*60 minutes

    // uint256 public cycleSlots = 3; // maxCycleTime*60 minutes

    uint256 public totalRewardedOverTime;

    uint256 sizeMultiplier = 1;

    uint256 userMaxTime = 10 minutes;
    uint256 maxCycleTime = 720 minutes;

    // uint256 userMaxTime = 3 minutes;
    // uint256 maxCycleTime = 3 minutes;

    uint256 slotTime = 1 minutes;

    uint256 public lastbookKeeping;


    struct StakedInfo{
        uint256 stakedScore;
        uint256 startTime;
        uint256 endTime;
        uint256 cycleStake;
        uint256 cyclePool;
        uint256 tokenId;
    }

    struct cycleInfo{
        uint256 poolReward;
        uint256 totalCycleScore;
        uint256 cycleStartTime;
        uint256 cycleEndTime;
    }

    mapping (uint256 => cycleInfo) public cycles;
    mapping (address => StakedInfo) public userInfo;
    mapping (address => uint256) public claimedReward;
    mapping (uint256 => uint256) public cycleClaimedReward;


    constructor () payable
    {
        gemNft = IERC721(0x33a3FB2e4e5a1f31945d7A811415D72dEA70A517);
        cycles[curCycle].cycleStartTime = block.timestamp;
        cycles[curCycle].cycleEndTime = (block.timestamp).add(maxCycleTime);
        cycles[1].poolReward = msg.value;
        lastbookKeeping = block.timestamp.add(maxCycleTime);
    }

    function addETH() public payable{}

    function withdrawBNB() public onlyOwner{
        payable(owner()).transfer(address(this).balance);
    }
    /*
        address 1 => 9
        address 2 => 12
        address 3 => 15 total 36

        only for 3 user in cycle 1st which has balance of 0.1
        0.1 * 9 / 36 = 0.008333333333333333 per minute 0.024999999999999999
        0.1 * 12 / 36 = 0.0333333333333333 per minute 0.022222222222222222
        0.1 * 15 / 36 = 0.0138888888888889 per minute 0.027777777777777776 + 0.0595238095238095 

        now cycle 2 is started with zero balance and one new user 

        0.25 * 9 / 63 = 
        0.25 * 12 / 63 =
        0.25 * 15 / 63 = 
        0.25 * 18 / 63 = 0.0238095238095238 per minute
        0.25 * 9 / 63 = 0.0119047619047619 per minute
    */



    function checkBalance(uint256 count) public view returns(uint256) {
        uint256 totalValue;
        uint256 curValue;
        for(uint256 i = 1; i< count; i++){
            totalValue = totalValue.add(cycles[i].poolReward).sub(cycleClaimedReward[i]);
        }

        curValue = (address(this).balance).sub(totalValue);

        if(cycles[count - 1].totalCycleScore == 0){
            return curValue.add(cycles[count - 1].poolReward);
        }
        else{
            return curValue;
        }
    }

    modifier bookKeeping {
        if(block.timestamp > lastbookKeeping){
            curCycle++;
            uint256 dailyBalance = checkBalance(curCycle);
            cycles[curCycle].totalCycleScore = (cycles[curCycle.sub(1)].totalCycleScore).sub(totalstakedscore);
            cycles[curCycle].cycleStartTime = block.timestamp;
            cycles[curCycle].cycleEndTime = block.timestamp.add(maxCycleTime);
            lastbookKeeping = block.timestamp.add(maxCycleTime);
            cycles[curCycle].poolReward = dailyBalance;

            if(cycles[curCycle - 1].totalCycleScore == 0){
                cycles[curCycle - 1].poolReward = 0;
            }
        totalstakedscore = 0;
        }
        _;
    }

    function StakeGem(uint256 tokenId) public bookKeeping{
        StakedInfo storage user = userInfo[msg.sender];
        require(user.startTime == 0, " User Already Staked !!! ");
        uint256 userScore = getUserStakedScore(tokenId);
        gemNft.transferFrom(msg.sender,address(this),tokenId);
        user.stakedScore = userScore;

        user.startTime = block.timestamp;
        user.endTime = cycles[curCycle].cycleEndTime;
        user.cycleStake = curCycle;
        user.tokenId = tokenId;
        user.cyclePool = cycles[curCycle].poolReward;
        cycles[curCycle].totalCycleScore = cycles[curCycle].totalCycleScore.add(userScore);


        Stakers = Stakers.add(1);
    }

    function getUserStakedScore(uint256 tokenId) public view returns(uint256 userScore){
        (uint256 generation, uint256 size) = gemNft.getTokenIdInfo(tokenId);
        uint256 size_ = size.mul(sizeMultiplier);
        if(generation == 1){ userScore = (gen1Score).add(size_); }
        else if(generation == 2){ userScore = (gen2Score).add(size_); }
        else if(generation == 3){ userScore = (gen3Score).add(size_); }
        else if(generation == 4){ userScore = (gen4Score).add(size_); }
        else if(generation == 5){ userScore = (gen5Score).add(size_); }
        else if(generation == 6){ userScore = (gen6Score).add(size_); }
        else if(generation == 7){ userScore = (gen7Score).add(size_); }
        else if(generation == 8){ userScore = (gen8Score).add(size_); }
        return userScore;
    }

    function updatePoolReward() public bookKeeping {}

    function getinfo(uint256 tokenID) public view returns(uint256,uint256){
        return gemNft.getTokenIdInfo(tokenID);
    }

    function allCyclesTime(address _user) public view returns(uint256 curTime, uint256 cycTime){
        StakedInfo storage user = userInfo[_user];
        if(user.startTime > 0){
            curTime = ((block.timestamp).sub(user.startTime)).div(slotTime);
            cycTime = ((cycles[(user.cycleStake)].cycleEndTime).sub(user.startTime)).div(slotTime);
        }
            
    }

    function calculateCurCycleReward(address _user) public view returns(uint256){
        StakedInfo storage user = userInfo[_user];
        uint256 userEarn;
        uint256 userCycleReward;
        (uint256 time_, uint256 cycleTime) = allCyclesTime(_user);

        if(user.startTime > 0){
            if(time_ >= cycleTime){
                time_ = cycleTime;
                userEarn = ((user.cyclePool).mul(user.stakedScore)).div(cycles[user.cycleStake].totalCycleScore);
                userCycleReward = (userEarn).div(cycleSlots).mul(time_);
            }
            else{ 
                userEarn = ((user.cyclePool).mul(user.stakedScore)).div(cycles[user.cycleStake].totalCycleScore);
                userCycleReward = (userEarn).div(cycleSlots).mul(time_);
            }
        }
        return userCycleReward;
    }

    function calculateAllCycleReward(address _user, uint256 cycleDiff) public view returns(uint256){
        StakedInfo storage user = userInfo[_user];
        uint256 reward;
        uint256 totalRew;
        uint256 userEarn;
        uint256 _time;
        uint256 cycleEndTime_;
        if(user.startTime > 0){
            for(uint256 i =1; i<= cycleDiff; i++){
                cycleEndTime_ = cycles[(user.cycleStake) + i].cycleEndTime;
                if((block.timestamp) <= cycleEndTime_) {
                    _time = ((block.timestamp).sub(cycles[(user.cycleStake) + i].cycleStartTime)).div(slotTime);
                    userEarn = ((cycles[(user.cycleStake)+i].poolReward).mul(user.stakedScore)).div(cycles[(user.cycleStake) + i].totalCycleScore);

                    reward = (userEarn).div(cycleSlots).mul(_time);
                }
                else{
                    _time = ((cycles[(user.cycleStake) + i].cycleEndTime).sub((cycles[(user.cycleStake) + i].cycleStartTime))).div(slotTime);
                    userEarn = ((cycles[(user.cycleStake)+i].poolReward).mul(user.stakedScore)).div(cycles[(user.cycleStake) + i].totalCycleScore);
                    reward = ((userEarn).div(cycleSlots)).mul(_time);
                }
                totalRew = totalRew.add(reward);
            }
        }
        return totalRew;
    }

    function totalReward(address _user) public view returns(uint256) {
        StakedInfo storage user = userInfo[_user];
        uint256 userCycleReward;
        uint256 reward;
        uint256 finalReward;
        uint256 cycleDiff = curCycle.sub(user.cycleStake);
        userCycleReward = calculateCurCycleReward(_user);
        if(cycleDiff >= 1){
          reward  = calculateAllCycleReward(_user, cycleDiff);
        }
        if(user.startTime > 0){
            finalReward = reward.add(userCycleReward).sub(claimedReward[_user]);
        }
        return finalReward;
    }

    function claimReward() public{
        StakedInfo storage user = userInfo[msg.sender];
        require(block.timestamp >= cycles[user.cycleStake].cycleEndTime, "cycle time not completed!!");

        uint256 userReward = totalReward(msg.sender);
        payable(msg.sender).transfer(userReward);
        totalRewardedOverTime = totalRewardedOverTime.add(userReward);
        claimedReward[msg.sender] += userReward;
        cycleClaimedReward[curCycle] += userReward;
    }

    uint256 public totalstakedscore;
    function unStakeGem() public {
        claimReward();
        StakedInfo storage user = userInfo[msg.sender];
        gemNft.transferFrom(address(this),msg.sender,user.tokenId);
        totalstakedscore = totalstakedscore.add(user.stakedScore);

        user.startTime = 0;
        user.endTime = 0;
        user.cycleStake = 0;
        user.cyclePool = 0;
        user.tokenId = 0;
        claimedReward[msg.sender] = 0;
        Stakers = Stakers.sub(1);
        
        user.stakedScore = 0;
        updatePoolReward();

    }

    receive() external payable{}
 
}