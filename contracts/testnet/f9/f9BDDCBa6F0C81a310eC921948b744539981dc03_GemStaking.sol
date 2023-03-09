/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function _approve(address owner, address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

    IERC20 public Token;
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

    uint256 public curCycle = 0;
    uint256 public cycleSlots = 720; // maxCycleTime*60 minutes
    uint256 public totalRewardedOverTime;
    uint256 sizeMultiplier = 1;
    uint256 userMaxTime = 10 minutes;
    uint256 maxCycleTime = 12 hours;

    uint256 slotTime = 1 minutes;

    struct StakedInfo{
        uint256 stakedScore;
        uint256 startTime;
        uint256 lastClaim;
        uint256 endTime;
        uint256 cycleStake;
        uint256 cyclePool;
        uint256 cycleEndTime;
        uint256 tokenId;
    }

    struct cycleInfo{
        uint256 cycleNo;
        uint256 totalCycleScore;
        uint256 cycleStartTime;
        uint256 cycleEndTime;
    }

    mapping (uint256 => cycleInfo) public cycles;
    mapping (address => StakedInfo) public userInfo;
    mapping (uint256 => uint256 ) public poolRewards;
    mapping (address => uint256) public claimedReward;


    constructor()
    {
        gemNft = IERC721(0xae52f742abA145D5a31103cB18BB8fE2fa62dFbA);
        Token = IERC20(0x5CA795BD4Ce40cc0a6a4A2dc5E696A853D06eB8B);
        poolRewards[curCycle] = 100000000000000000000;
        cycles[curCycle].cycleStartTime = block.timestamp;
        cycles[curCycle].cycleEndTime = (block.timestamp).add(maxCycleTime);
    }

    function StakeGem(uint256 tokenId) public{
        StakedInfo storage user = userInfo[msg.sender];
        require(user.startTime == 0, "User Already Staked!!");
        uint256 userScore = getUserStakedScore(tokenId);
        gemNft.transferFrom(msg.sender,address(this),tokenId);
        user.stakedScore = userScore;
        user.startTime = block.timestamp;
        user.endTime = (block.timestamp).add(userMaxTime);
        user.cycleStake = curCycle;
        user.tokenId = tokenId;
        user.cyclePool = poolRewards[curCycle];
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

    function claimReward() public{
        StakedInfo storage user = userInfo[msg.sender];
        require(block.timestamp >= cycles[user.cycleStake].cycleEndTime, "cycle time not completed!!");
        require(block.timestamp >= userInfo[msg.sender].endTime, "claim time not completed!!");
        uint256 userReward = totalReward(msg.sender);
        totalRewardedOverTime = totalRewardedOverTime.add(userReward);
        claimedReward[msg.sender] = claimedReward[msg.sender].add(userReward);
        Token.transfer(msg.sender, userReward);
    }

    function unStakeGem(uint256 tokenId) public{
        require(block.timestamp >= userInfo[msg.sender].endTime, "Unstake time not reached!!");
        claimReward();
        StakedInfo storage user = userInfo[msg.sender];
        gemNft.transferFrom(address(this),msg.sender,tokenId);
        user.startTime = 0;
        user.endTime = 0;
        Stakers = Stakers.sub(1);
    }

    function updateCycle(uint256 _cycleReward) public onlyOwner{
        if(block.timestamp > cycles[curCycle].cycleEndTime){

            curCycle = curCycle.add(1);
            cycles[curCycle].cycleNo = curCycle;
            cycles[curCycle].totalCycleScore = cycles[curCycle.sub(1)].totalCycleScore;

            cycles[curCycle].cycleStartTime = block.timestamp;
            cycles[curCycle].cycleEndTime = block.timestamp.add(maxCycleTime);

            poolRewards[curCycle] = _cycleReward;
        }
    }

    function getinfo(uint256 tokenID) public view returns(uint256,uint256){
        return gemNft.getTokenIdInfo(tokenID);
    }

    function totalReward(address _user) public view returns(uint256){
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
            finalReward = (reward.add(userCycleReward)).sub(claimedReward[_user]);
        }
        return finalReward;
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
                userEarn = ((user.cyclePool).mul(user.stakedScore)).div(cycles[curCycle].totalCycleScore);
                userCycleReward = (userEarn).div(cycleSlots).mul(time_);
            }
            else{ 
                userEarn = ((user.cyclePool).mul(user.stakedScore)).div(cycles[curCycle].totalCycleScore);
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
                    userEarn = ((poolRewards[(user.cycleStake)+i]).mul(user.stakedScore)).div(cycles[(user.cycleStake) + i].totalCycleScore);

                    reward = (userEarn).div(cycleSlots).mul(_time);
                }
                else{
                    _time = ((cycles[(user.cycleStake) + i].cycleEndTime).sub((cycles[(user.cycleStake) + i].cycleStartTime))).div(slotTime);
                    userEarn = ((poolRewards[(user.cycleStake)+i]).mul(user.stakedScore)).div(cycles[(user.cycleStake) + i].totalCycleScore);
                    reward = ((userEarn).div(cycleSlots)).mul(_time);
                }
                totalRew = totalRew.add(reward);
            }
        }
        return totalRew;
    }
 
}