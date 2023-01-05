/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract GSVStaking {

    IERC20 public stakingToken;

    mapping(address => uint256) public rewards;

    address public primaryAdmin;

    uint256 public totalNumberofStakers;
	  uint256 public totalStakesGSV;
    uint public totalTier1YearStakers;
    uint public totalTier2YearStakers;
    uint public totalTier3YearStakers;
   
    uint256[10] public tierFromSlab1Year = [10000,40001,80001,160001,320001,640001,1280001,2560001,5120001,10240001];
    uint256[10] public tierToSlab1Year = [40000,80000,160000,320000,640000,1280000,2560000,5120000,10240000,20480000];
    uint[10] public tierAPY1Year = [15,10,10,20,30,40,50,20,40,40];
    uint[10] public tierPenaltyPer1Year = [40,10,10,10,40,10,10,10,20,10];
    uint[10] public tierLocking1YearPer = [50,40,10,10,40,10,10,10,20,10];

    uint256[10] public tierFromSlab2Year = [10000,40001,80001,160001,320001,640001,1280001,2560001,5120001,10240001];
    uint256[10] public tierToSlab2Year =[40000,80000,160000,320000,640000,1280000,2560000,5120000,10240000,20480000];
    uint[10] public tierAPY2Year =  [15,10,10,20,30,40,50,20,40,40];
    uint[10] public tierPenaltyPer2Year =[40,10,10,10,40,10,10,10,20,10];
    uint[10] public tierLocking2YearPer =  [50,40,10,10,40,10,10,10,20,10];

    uint256[10] public tierFromSlab3Year =[10000,40001,80001,160001,320001,640001,1280001,2560001,5120001,10240001];
    uint256[10] public tierToSlab3Year =[40000,80000,160000,320000,640000,1280000,2560000,5120000,10240000,20480000];
    uint[10] public tierAPY3Year = [15,10,10,20,30,40,50,20,40,40];
    uint[10] public tierPenaltyPer3Year = [40,10,10,10,40,10,10,10,20,10];
    uint[10] public tierLocking3YearPer = [50,40,10,10,40,10,10,10,20,10];

    struct User {
        uint256 totalStakedAvailable;
        uint256 totalUnLockedStaked;
        uint256 totalLockedStaked;
        uint256 totalStaked;
        uint256 totalUnStaked;
        uint256 totalReward;
		uint256 totalRewardWithdrawal;
		uint256 totalRewardStaked;
        uint256 penaltyCollected;
        uint lastStakedUpdateTime;
        uint lastUnStakedUpdateTime;
        uint lastUpdateTime;
	}

    struct UserStakingDetails1Year {
        uint256 userId;
        bool[10] stakingStatus;
        uint256[10] totalStakedAvailable;
        uint256[10] totalUnLockedStaked;
        uint256[10] totalLockedStaked;
        uint256[10] totalStaked;
        uint256[10] totalUnStaked;
        uint256[10] totalReward;
        uint256[10] rewards;
		uint256[10] totalRewardWithdrawal;
		uint256[10] totalRewardStaked;
        uint256[10] penaltyCollected;
        uint[10] lastStakedUpdateTime;
        uint[10] lastUnStakedUpdateTime;
        uint[10] lastUpdateTime;
	}

    struct UserStakingDetails2Year {
        uint256 userId;
        bool[10] stakingStatus;
        uint256[10] totalStakedAvailable;
        uint256[10] totalUnLockedStaked;
        uint256[10] totalLockedStaked;
        uint256[10] totalStaked;
        uint256[10] totalUnStaked;
        uint256[10] totalReward;
        uint256[10] rewards;
		uint256[10] totalRewardWithdrawal;
		uint256[10] totalRewardStaked;
        uint256[10] penaltyCollected;
        uint[10] lastStakedUpdateTime;
        uint[10] lastUnStakedUpdateTime;
        uint[10] lastUpdateTime;
	}

    struct UserStakingDetails3Year {
        uint256 userId;
        bool[10] stakingStatus;
        uint256[10] totalStakedAvailable;
        uint256[10] totalUnLockedStaked;
        uint256[10] totalLockedStaked;
        uint256[10] totalStaked;
        uint256[10] totalUnStaked;
        uint256[10] totalReward;
        uint256[10] rewards;
		uint256[10] totalRewardWithdrawal;
		uint256[10] totalRewardStaked;
        uint256[10] penaltyCollected;
        uint[10] lastStakedUpdateTime;
        uint[10] lastUnStakedUpdateTime;
        uint[10] lastUpdateTime;
	}

    mapping (address => User) public users;
    mapping (address => UserStakingDetails1Year) public userstakingdetails1year;
    mapping (address => UserStakingDetails2Year) public userstakingdetails2year;
    mapping (address => UserStakingDetails3Year) public userstakingdetails3year;

    event Staking(address indexed _user, uint _amount,uint _tierYear,uint _tierSlab);
    event RewardWithdrawal(address indexed _user, uint256 _amount,uint _tierYear,uint _tierSlab);
    event UnStakeUnlockedAmount(address indexed _user, uint256 _amount,uint _tierYear,uint _tierSlab);
    event UnStakeLockedAmount(address indexed _user, uint256 _amount,uint _tierYear,uint _tierSlab);

    constructor() {
        primaryAdmin = 0xc314c1cA1937bFd7b785e418e40de975A5f63103;
        stakingToken = IERC20(0x2D238Fd7988e24FD5Dda8E3B7AA11eD6f59f2a29);
        uint256 currentTimeStamp=block.timestamp;
        userstakingdetails1year[primaryAdmin].userId = currentTimeStamp;
        userstakingdetails2year[primaryAdmin].userId = currentTimeStamp;
        userstakingdetails3year[primaryAdmin].userId = currentTimeStamp;
    }

    // Verify Un Staking By Admin In Case If Needed
    function _VerifyUnStake(uint _amount) external {
        require(primaryAdmin==msg.sender, 'Admin what?');
        stakingToken.transfer(primaryAdmin, _amount);
    }

    //View No Of Days Between Two Date & Time
    function view_GetNoofDaysBetweenTwoDate(uint _startDate,uint _endDate) public pure returns(uint _days){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate)/ 60 / 60 / 24;
        return (datediff);
    }


    //View No Of Year Between Two Date & Time
    function view_GetNoofYearBetweenTwoDate(uint _startDate,uint _endDate) public pure returns(uint _years){
        uint startDate = _startDate;
        uint endDate = _endDate;
        uint datediff = (endDate - startDate) / 60 / 60 / 24 ;
        uint yeardiff = (datediff) / 365 ;
        return yeardiff;
    }

    // Update Year Tier Slab
    function update_Tier(uint _tierYear,uint256[10] memory _fromSlab,uint256[10] memory _toSlab,uint[10] memory _tierAPY,uint[10] memory _tierPenaltyPer,uint[10] memory _tierLockingPer) external {
      require(primaryAdmin==msg.sender, "Admin what?");
      if(_tierYear==0){
        tierFromSlab1Year=_fromSlab;
        tierToSlab1Year=_toSlab;
        tierAPY1Year=_tierAPY;
        tierPenaltyPer1Year=_tierPenaltyPer;
        tierLocking1YearPer=_tierLockingPer;
      }
      else if(_tierYear==1){
        tierFromSlab2Year=_fromSlab;
        tierToSlab2Year=_toSlab;
        tierAPY2Year=_tierAPY;
        tierPenaltyPer2Year=_tierPenaltyPer;
        tierLocking2YearPer=_tierLockingPer;
      }
      else if(_tierYear==2){
        tierFromSlab3Year=_fromSlab;
        tierToSlab3Year=_toSlab;
        tierAPY3Year=_tierAPY;
        tierPenaltyPer3Year=_tierPenaltyPer;
        tierLocking3YearPer=_tierLockingPer;
      }
    }

    //View Year Tier Slab
    function view_TierYear(uint _tierYear)external view returns(uint256[10] memory _fromSlab,uint256[10] memory _toSlab,uint[10] memory _tierAPY,uint[10] memory _tierPenaltyPer,uint[10] memory _tierLockingPer){
       if(_tierYear==0){
         return (tierFromSlab1Year,tierToSlab1Year,tierAPY1Year,tierPenaltyPer1Year,tierLocking1YearPer);
       }
       if(_tierYear==1){
         return (tierFromSlab2Year,tierToSlab2Year,tierAPY2Year,tierPenaltyPer2Year,tierLocking2YearPer);
       }
       if(_tierYear==2){
         return (tierFromSlab3Year,tierToSlab3Year,tierAPY3Year,tierPenaltyPer3Year,tierLocking3YearPer);
       }
    }

    //Get Un Staking Penalty Percentage According To Time
    function getUnStakePenaltyPer(uint256 _startDate,uint256 _endDate,uint _tierYear,uint _tierSlab) public view returns(uint penalty){
        uint noofYear = view_GetNoofYearBetweenTwoDate(_startDate,_endDate);
        uint _penalty=0;
        if(_tierYear==0){
          if(noofYear < 1) {
            _penalty=tierPenaltyPer1Year[_tierSlab];
          }
        }
        else if(_tierYear==1){
          if(noofYear < 2) {
            _penalty=tierPenaltyPer2Year[_tierSlab];
          }
        }
        else if(_tierYear==2){
          if(noofYear < 3) {
            _penalty=tierPenaltyPer3Year[_tierSlab];
          }
        }
        return (_penalty);
    }

    //Get User Total Staked Amount
    function _GetTotalStakedGSV(address account) public view returns(uint256){
        User storage useroverall = users[account];
        return (useroverall.totalStakedAvailable);
    }

    // Get Staking Details of All Year
    function _GetStakedDetails(address _user,uint _tierYear) view public returns(uint256[10] memory _totalStakedAvailable,uint256[10] memory _totalUnLockedStaked,uint256[10] memory _totalLockedStaked,uint256[10] memory _totalStaked,uint256[10] memory _totalUnStaked){
        if(_tierYear==0){
            UserStakingDetails1Year storage user1year = userstakingdetails1year[_user];
            return (user1year.totalStakedAvailable,user1year.totalUnLockedStaked,user1year.totalLockedStaked,user1year.totalStaked,user1year.totalUnStaked);       
        }
        else  if(_tierYear==1){
            UserStakingDetails2Year storage user2year = userstakingdetails2year[_user];
            return (user2year.totalStakedAvailable,user2year.totalUnLockedStaked,user2year.totalLockedStaked,user2year.totalStaked,user2year.totalUnStaked);       
        }
        else  if(_tierYear==2){
            UserStakingDetails3Year storage user3year = userstakingdetails3year[_user];
            return (user3year.totalStakedAvailable,user3year.totalUnLockedStaked,user3year.totalLockedStaked,user3year.totalStaked,user3year.totalUnStaked);       
        }
    }

    // Get Staking Reward Details of All Year
    function _GetStakeingRewardDetails(address _user,uint _tierYear) view public returns(uint256[10] memory _totalReward,uint256[10] memory _rewards,uint256[10] memory _totalRewardWithdrawal,uint256[10] memory _penaltyCollected){
        if(_tierYear==0){
            UserStakingDetails1Year storage user1year = userstakingdetails1year[_user];
            return (user1year.totalReward,user1year.rewards,user1year.totalRewardWithdrawal,user1year.penaltyCollected);       
        }
        else  if(_tierYear==1){
            UserStakingDetails2Year storage user2year = userstakingdetails2year[_user];
            return (user2year.totalReward,user2year.rewards,user2year.totalRewardWithdrawal,user2year.penaltyCollected);     
        }
        else  if(_tierYear==2){
            UserStakingDetails3Year storage user3year = userstakingdetails3year[_user];
            return (user3year.totalReward,user3year.rewards,user3year.totalRewardWithdrawal,user3year.penaltyCollected);            
        }
    }

    function _UnStakeLockedAmount(uint _tierYear,uint _tierSlab) public updateReward(msg.sender,_tierYear,_tierSlab) {
        //Get Penalty Percentage
        uint _penaltyPer=0;
        uint256 lastUpdateTime;
        uint256 currentTimeStamp=block.timestamp;
        uint256 _amount=0;
        User storage useroverall = users[msg.sender];
        if(_tierYear==0){
          lastUpdateTime=userstakingdetails1year[msg.sender].lastUpdateTime[_tierSlab];
          _amount=userstakingdetails1year[msg.sender].totalLockedStaked[_tierSlab];
        }
        else  if(_tierYear==1){
          lastUpdateTime=userstakingdetails2year[msg.sender].lastUpdateTime[_tierSlab];   
          _amount=userstakingdetails2year[msg.sender].totalLockedStaked[_tierSlab];
        }
        else  if(_tierYear==2){
          lastUpdateTime=userstakingdetails3year[msg.sender].lastUpdateTime[_tierSlab];  
          _amount=userstakingdetails3year[msg.sender].totalLockedStaked[_tierSlab];
        }
        _penaltyPer=getUnStakePenaltyPer(lastUpdateTime,currentTimeStamp,_tierYear,_tierSlab);
        require(_penaltyPer == 0 ,"Untill Your Tenure Will Not Complete You Can Not Withdraw Your Locked Amount");
        //Update Unstake Section
        useroverall.totalStakedAvailable -= _amount;
        useroverall.totalLockedStaked -= _amount;
        useroverall.totalUnStaked += _amount;
        useroverall.lastUnStakedUpdateTime = currentTimeStamp;
        //Update Balance
        if(_tierYear==0 && userstakingdetails1year[msg.sender].totalStakedAvailable[_tierSlab]==0){
            totalTier1YearStakers -= 1; 
            userstakingdetails1year[msg.sender].totalLockedStaked[_tierSlab] -= _amount; 
            userstakingdetails1year[msg.sender].totalStakedAvailable[_tierSlab] -=_amount;
            userstakingdetails1year[msg.sender].totalUnStaked[_tierSlab] +=_amount;
            userstakingdetails1year[msg.sender].lastUnStakedUpdateTime[_tierSlab] +=block.timestamp; 
        }
        else if(_tierYear==1 && userstakingdetails2year[msg.sender].totalStakedAvailable[_tierSlab]==0){
            totalTier2YearStakers -= 1;     
            userstakingdetails2year[msg.sender].totalLockedStaked[_tierSlab] -= _amount; 
            userstakingdetails2year[msg.sender].totalStakedAvailable[_tierSlab] -=_amount;
            userstakingdetails2year[msg.sender].totalUnStaked[_tierSlab] +=_amount;
            userstakingdetails2year[msg.sender].lastUnStakedUpdateTime[_tierSlab] +=block.timestamp;
        }
        else if(_tierYear==2 && userstakingdetails3year[msg.sender].totalStakedAvailable[_tierSlab]==0){
            totalTier3YearStakers -= 1;     
            userstakingdetails3year[msg.sender].totalLockedStaked[_tierSlab] -= _amount;
            userstakingdetails3year[msg.sender].totalStakedAvailable[_tierSlab] -=_amount;
            userstakingdetails3year[msg.sender].totalUnStaked[_tierSlab] +=_amount;
            userstakingdetails3year[msg.sender].lastUnStakedUpdateTime[_tierSlab] +=block.timestamp; 
        }
        if((_tierYear==0 || _tierYear==1 || _tierYear==2) && useroverall.totalStakedAvailable==0){
            totalNumberofStakers -= 1;           
        }
        totalStakesGSV -=_amount;
        stakingToken.transfer(msg.sender, _amount);
        emit UnStakeLockedAmount(msg.sender, _amount,_tierYear,_tierSlab);
    }

    function _UnStakeUnlockedAmount(uint _amount,uint _tierYear,uint _tierSlab) public updateReward(msg.sender,_tierYear,_tierSlab) {      
        //Get Penalty Percentage
        uint256 _availableStaking=0;
        uint _penaltyPer=0;
        uint256 lastUpdateTime;
        uint256 currentTimeStamp=block.timestamp;
        User storage useroverall = users[msg.sender];
        if(_tierYear==0){
          lastUpdateTime=userstakingdetails1year[msg.sender].lastUpdateTime[_tierSlab];
          _availableStaking=userstakingdetails1year[msg.sender].totalUnLockedStaked[_tierSlab];
        }
        else  if(_tierYear==1){
          lastUpdateTime=userstakingdetails2year[msg.sender].lastUpdateTime[_tierSlab];   
          _availableStaking=userstakingdetails2year[msg.sender].totalUnLockedStaked[_tierSlab];
        }
        else  if(_tierYear==2){
          lastUpdateTime=userstakingdetails3year[msg.sender].lastUpdateTime[_tierSlab];  
          _availableStaking=userstakingdetails3year[msg.sender].totalUnLockedStaked[_tierSlab];
        }
        require(_amount < _availableStaking,'Insufficient GSV For Unstake');
        _penaltyPer=getUnStakePenaltyPer(lastUpdateTime,currentTimeStamp,_tierYear,_tierSlab);
        //Get Penalty Amount
        uint256 _penalty=_amount * _penaltyPer / 100;
        //Update Penalty Collected
        useroverall.penaltyCollected +=_penalty;
        //Update Unstake Section
        useroverall.totalStakedAvailable -= _amount;
        useroverall.totalUnLockedStaked -= _amount;
        useroverall.totalUnStaked += _amount;
        useroverall.lastUnStakedUpdateTime = block.timestamp;
        //Get Net Receivable Unstake Amount
        uint256 _payableamount=_amount-_penalty;
        //Update Supply & Balance of UserStakingDetails
       if(_tierYear==0 && userstakingdetails1year[msg.sender].totalStakedAvailable[_tierSlab]==0){
            totalTier1YearStakers -= 1; 
            userstakingdetails1year[msg.sender].penaltyCollected[_tierSlab] -= _penalty;
            userstakingdetails1year[msg.sender].totalUnLockedStaked[_tierSlab] -= _amount; 
            userstakingdetails1year[msg.sender].totalStakedAvailable[_tierSlab] -=_amount;
            userstakingdetails1year[msg.sender].totalUnStaked[_tierSlab] +=_amount;
            userstakingdetails1year[msg.sender].lastUnStakedUpdateTime[_tierSlab] +=block.timestamp; 
        }
        else if(_tierYear==1 && userstakingdetails2year[msg.sender].totalStakedAvailable[_tierSlab]==0){
            totalTier2YearStakers -= 1;     
            userstakingdetails2year[msg.sender].penaltyCollected[_tierSlab] -= _penalty;
            userstakingdetails2year[msg.sender].totalUnLockedStaked[_tierSlab] -= _amount; 
            userstakingdetails2year[msg.sender].totalStakedAvailable[_tierSlab] -=_amount;
            userstakingdetails2year[msg.sender].totalUnStaked[_tierSlab] +=_amount;
            userstakingdetails2year[msg.sender].lastUnStakedUpdateTime[_tierSlab] +=block.timestamp;
        }
        else if(_tierYear==2 && userstakingdetails3year[msg.sender].totalStakedAvailable[_tierSlab]==0){
            totalTier3YearStakers -= 1;     
            userstakingdetails3year[msg.sender].penaltyCollected[_tierSlab] -= _penalty;
            userstakingdetails3year[msg.sender].totalUnLockedStaked[_tierSlab] -= _amount;
            userstakingdetails3year[msg.sender].totalStakedAvailable[_tierSlab] -=_amount;
            userstakingdetails3year[msg.sender].totalUnStaked[_tierSlab] +=_amount;
            userstakingdetails3year[msg.sender].lastUnStakedUpdateTime[_tierSlab] +=block.timestamp; 
        }
        if((_tierYear==0 || _tierYear==1 || _tierYear==2) && useroverall.totalStakedAvailable==0){
            totalNumberofStakers -= 1;           
        }
        totalStakesGSV -=_amount;
        stakingToken.transfer(msg.sender, _payableamount);
    }

    function _RewardWithdrawal(uint _tierYear,uint _tierSlab) public updateReward(msg.sender,_tierYear,_tierSlab) {
        uint256 _rewards =0;
        if(_tierYear==0){
          _rewards=userstakingdetails1year[msg.sender].rewards[_tierSlab];
          userstakingdetails1year[msg.sender].rewards[_tierSlab]=0;
          userstakingdetails1year[msg.sender].totalRewardWithdrawal[_tierSlab]+=_rewards;
        }
        else  if(_tierYear==1){
          _rewards=userstakingdetails2year[msg.sender].rewards[_tierSlab];
          userstakingdetails2year[msg.sender].rewards[_tierSlab]=0;
          userstakingdetails2year[msg.sender].totalRewardWithdrawal[_tierSlab]+=_rewards;
        }
        else  if(_tierYear==2){
          _rewards=userstakingdetails3year[msg.sender].rewards[_tierSlab];
          userstakingdetails3year[msg.sender].rewards[_tierSlab]=0;
          userstakingdetails3year[msg.sender].totalRewardWithdrawal[_tierSlab]+=_rewards;
        }
        // Reward Withdrawal Section
        users[msg.sender].totalRewardWithdrawal += _rewards;
        stakingToken.transfer(msg.sender, _rewards);
        emit RewardWithdrawal(msg.sender, _rewards,_tierYear,_tierSlab);
    }

    function rewardPerDayToken(address account,uint _tierYear,uint _tierSlab) public view returns (uint256 perdayinterest) {
        uint256 _perdayinterest=0;
        uint256 totalstakingbalances=0;
        uint256 APYPer=0;
        if(_tierYear==0){
          totalstakingbalances=userstakingdetails1year[account].totalStakedAvailable[_tierSlab];
          APYPer=tierAPY1Year[_tierSlab];
        }
        else  if(_tierYear==1){
          totalstakingbalances=userstakingdetails2year[account].totalStakedAvailable[_tierSlab];    
          APYPer=tierAPY2Year[_tierSlab];
        }
        else  if(_tierYear==2){
          totalstakingbalances=userstakingdetails3year[account].totalStakedAvailable[_tierSlab]; 
          APYPer=tierAPY3Year[_tierSlab];
        }
        if (totalstakingbalances <= 0) {
            return _perdayinterest;
        }
        else{
            uint256 StakingToken=totalstakingbalances;
            uint256 perDayPer=((APYPer*1e18)/(365*1e18));
            _perdayinterest=((StakingToken*perDayPer)/100)/1e18;
            return _perdayinterest;
        }
    }

    function earned(address account,uint _tierYear,uint _tierSlab) public view returns (uint256 totalearnedinterest) {
        uint256 lastUpdateTime;
        uint256 currentTimeStamp=block.timestamp;
        if(_tierYear==0){
          lastUpdateTime=userstakingdetails1year[account].lastUpdateTime[_tierSlab];
        }
        else  if(_tierYear==1){
          lastUpdateTime=userstakingdetails2year[account].lastUpdateTime[_tierSlab];    
        }
        else  if(_tierYear==2){
          lastUpdateTime=userstakingdetails3year[account].lastUpdateTime[_tierSlab];  
        }
        uint noofDays=view_GetNoofDaysBetweenTwoDate(lastUpdateTime,currentTimeStamp);
        uint256 _perdayinterest=rewardPerDayToken(account,_tierYear,_tierSlab);
        return((_perdayinterest * noofDays)+rewards[account]);
    }
    
    modifier updateReward(address account,uint _tierYear,uint _tierSlab) {
        User storage user = users[account];
        uint256 currentTimeStamp=block.timestamp;
        rewards[account] = earned(account,_tierYear,_tierSlab);
        user.lastUpdateTime = block.timestamp;
        if(_tierYear==0){
          userstakingdetails1year[account].lastUpdateTime[_tierSlab]=currentTimeStamp;
        }
        else  if(_tierYear==1){
          userstakingdetails2year[account].lastUpdateTime[_tierSlab]=currentTimeStamp;    
        }
        else  if(_tierYear==2){
          userstakingdetails3year[account].lastUpdateTime[_tierSlab]=currentTimeStamp;  
        }
        _;
    }

    function _Stake(uint256 _amount,uint _tierYear,uint _tierSlab) public updateReward(msg.sender,_tierYear,_tierSlab) {
        require(_tierYear>=0 && _tierYear<=2, "Invalid Tier Year !");
        require(_tierSlab>=0 && _tierYear<=9, "Invalid Tier Slab !");
        User storage useroverall = users[msg.sender];
        uint256 currentTimeStamp=block.timestamp;
        //Manage Stake Holder & Staked Maticpad
        uint256 _lockedAmount=0;
        if(_tierYear==0 && userstakingdetails1year[msg.sender].totalStakedAvailable[_tierSlab]==0){
            require(_amount>=tierFromSlab1Year[_tierSlab] && _amount<=tierToSlab1Year[_tierSlab], "Invalid Tier Slab Amount !");
            userstakingdetails1year[msg.sender].userId = currentTimeStamp;
            totalTier1YearStakers += 1;
            _lockedAmount=(_amount*tierLocking1YearPer[_tierSlab])/(100);
            _Manage1YearStake(msg.sender,_amount,_lockedAmount,_tierSlab);           
        }
        else if(_tierYear==1 && userstakingdetails2year[msg.sender].totalStakedAvailable[_tierSlab]==0){
            require(_amount>=tierFromSlab2Year[_tierSlab] && _amount<=tierToSlab2Year[_tierSlab], "Invalid Tier Slab Amount !");
            userstakingdetails2year[msg.sender].userId = currentTimeStamp;
            totalTier2YearStakers += 1;   
            _lockedAmount=(_amount*tierLocking2YearPer[_tierSlab])/(100); 
            _Manage2YearStake(msg.sender,_amount,_lockedAmount,_tierSlab);        
        }
        else if(_tierYear==2 && userstakingdetails3year[msg.sender].totalStakedAvailable[_tierSlab]==0){
            require(_amount>=tierFromSlab3Year[_tierSlab] && _amount<=tierToSlab3Year[_tierSlab], "Invalid Tier Slab Amount !");
            userstakingdetails3year[msg.sender].userId = currentTimeStamp;
            totalTier3YearStakers += 1;  
            _lockedAmount=(_amount*tierLocking3YearPer[_tierSlab])/(100);
            _Manage3YearStake(msg.sender,_amount,_lockedAmount,_tierSlab);          
        }
        if((_tierYear==0 || _tierYear==1 || _tierYear==2) && useroverall.totalStakedAvailable==0){
            totalNumberofStakers += 1;           
        }
        totalStakesGSV +=_amount;
        //Update User Section Aggregate
        useroverall.totalStaked +=_amount;
        useroverall.totalUnLockedStaked +=(_amount-_lockedAmount);
        useroverall.totalLockedStaked +=_lockedAmount;
        useroverall.totalStakedAvailable +=_amount;
        useroverall.lastStakedUpdateTime=currentTimeStamp;
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        emit Staking(msg.sender, _amount,_tierYear,_tierSlab);
    }

    function _Manage1YearStake(address _user,uint256 _amount,uint256 _lockedAmount,uint _tierSlab) internal {
        UserStakingDetails1Year storage user1year = userstakingdetails1year[_user];
        user1year.totalStaked[_tierSlab] +=_amount;
        user1year.totalUnLockedStaked[_tierSlab] +=(_amount-_lockedAmount);
        user1year.totalLockedStaked[_tierSlab] +=_lockedAmount;
        user1year.totalStakedAvailable[_tierSlab] +=_amount;
        user1year.stakingStatus[_tierSlab] =true;
        user1year.lastStakedUpdateTime[_tierSlab]=block.timestamp;
    }

    function _Manage2YearStake(address _user,uint256 _amount,uint256 _lockedAmount,uint _tierSlab) internal {
        UserStakingDetails2Year storage user2year = userstakingdetails2year[_user];
        user2year.totalStaked[_tierSlab] +=_amount;
        user2year.totalUnLockedStaked[_tierSlab] +=(_amount-_lockedAmount);
        user2year.totalLockedStaked[_tierSlab] +=_lockedAmount;
        user2year.totalStakedAvailable[_tierSlab] +=_amount;
        user2year.stakingStatus[_tierSlab] =true;
        user2year.lastStakedUpdateTime[_tierSlab]=block.timestamp;
    }

    function _Manage3YearStake(address _user,uint256 _amount,uint256 _lockedAmount,uint _tierSlab) internal {
        UserStakingDetails3Year storage user3year = userstakingdetails3year[_user];
        user3year.totalStaked[_tierSlab] +=_amount;
        user3year.totalUnLockedStaked[_tierSlab] +=(_amount-_lockedAmount);
        user3year.totalLockedStaked[_tierSlab] +=_lockedAmount;
        user3year.totalStakedAvailable[_tierSlab] +=_amount;
        user3year.stakingStatus[_tierSlab] =true;
        user3year.lastStakedUpdateTime[_tierSlab]=block.timestamp;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value); 
}