// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


interface IBEP20Token
{
    function mintTokens(address receipient, uint256 tokenAmount) external returns(bool);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function balanceOf(address user) external view returns(uint256);
    function totalSupply() external view returns (uint256);
    function maxsupply() external view returns (uint256);
    function repurches(address _from, address _to, uint256 _value) external returns(bool);
    function burn_internal(uint256 _value, address _to) external returns (bool);
}


contract CSM_MasterV6{
    
    IBEP20Token public rewardToken;

    AggregatorV3Interface internal priceFeed;
    /*===============================
    =         DATA STORAGE          =
    ===============================*/

    // Public variables of the token
    using SafeMath for uint256;
    using SafeMath for uint;



    struct Deposit {
		uint256 amount;
		uint256 start;
        uint256 lastdate;
	}

    struct User {
		Deposit[] deposits;
		address referrer;
        uint256 bonus;
        uint256 totalBonus;
        uint256 totalWithdrwan;
        uint256 totalDownLineBusiness;
        uint256 totalDownLineBusinessInBnb;
        uint256 directBonusEligibility;
        uint256[15] refStageBusiness; //total business of referrer each stage
        uint256[2] refStageBonus; //bonus of referrer each stage
		uint[15] refs;  // number of referrer each stage
	}

    struct ScheduleTokenWithdrawal {
        uint256 withdrawToken;
        uint256 maturitydate;
        bool ispaid;
    }

    struct TokenStaked {
        uint256 amountOfToken;
        uint256 rewardToken;
        uint package;
    }

    struct FlushBusiness {
		uint256 groupA;
		uint256 groupB;
        uint256 groupC;
        uint256 startDate;
        uint256 endDate;
        uint cycle;
	}

    

    mapping (address => TokenStaked[]) public tokenStakes;
    mapping (address => mapping(uint => ScheduleTokenWithdrawal[])) public scheduleWithdrawals;
    mapping (address => User) public users;
    mapping (address => FlushBusiness) public flushBusiness;
    mapping (address => uint256) public principalToken;
    mapping (address => uint256) public numberOfFarming;
    mapping (address => mapping(uint => uint)) public numberOfstakeAgainstFarming;
    mapping (address => mapping(uint256 => address)) public directs;
    bool public started;
    address payable public ownerWallet;
	address payable public supportWallet;
    bool private IsInitinalized;
    uint public totalUsers;

    uint[2] public ref_bonuses; // first level bonus calculate as per the package amount.
    uint[4] public plan ; //usd
    uint[4] public plan_ref_bonuses; // Direct Bonus
    uint256 csmTokenPrice;

    uint[4] public farmingRewardPercentage; // farming percentage
    uint[4] public farmingLockPeriod; // farming locked days

    uint[7] public farmingTokenAchive; // farming locked days

    //uint[6] public Group_Rewards_Program = [10000,50000,100000,200000,500000,1000000];
    uint[6] public Group_Rewards_Program;

    //uint[3] public flushCycleDays = [90 days, 60 days, 30 days];
    uint[3] public flushCycleDays;

    uint256 public TotalInvestment;

    function initialize(address payable _ownerWallet) public {
        require (IsInitinalized == false,"Already Started");
        ref_bonuses = [0,5];
        plan = [10,50,100,200];
        plan_ref_bonuses = [10,15,20,25];
        csmTokenPrice = 0.001 ether;
        farmingRewardPercentage = [20,50,75,100];
        farmingLockPeriod = [180,365,545,730];
        farmingTokenAchive = [180,270,360,450,545,630,720];
        Group_Rewards_Program = [10,50,100,200,500,100];
        flushCycleDays = [60 minutes, 40 minutes, 20 minutes];
        priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
        ownerWallet = _ownerWallet;
        IsInitinalized = true;

	}



    function invest(address _referrer) public payable {

        
	
		if (!started) {
			if (msg.sender == ownerWallet) {
				started = true;
			} else revert("Not started yet");
		}
        User storage user = users[msg.sender];

    //    require(users[_referrer].deposits.length > 0 && _referrer != msg.sender,  "No upline found");
         
        if (user.referrer == address(0)) {
			user.referrer = _referrer;
        }
        


        uint256 geteligibleForDirectBonus = eligibleForDirectBonus(msg.value);
        user.directBonusEligibility = geteligibleForDirectBonus;

        address upline = user.referrer;
        for(uint i=0; i < 15; i++){
            if (upline != address(0)) {
                users[upline].refs[i] += 1;
                users[upline].refStageBusiness[i] = users[upline].refStageBusiness[i].add(msg.value);
                users[upline].totalDownLineBusinessInBnb += msg.value;
                users[upline].totalDownLineBusiness += uint256(TotalusdPrice(int(msg.value)));

                if(i < 2){ 
                uint256 bonus_percentage = (i==0)? users[upline].directBonusEligibility : ref_bonuses[i];
                uint256 bonus = msg.value.mul(bonus_percentage).div(100);
                users[upline].bonus += bonus;
                }
            }else break; 
          upline = users[upline].referrer;
        }

        // directs[msg.sender][user.refs[0]-1] = _referrer;

        // if(user.deposits.length == 0){
        //     flushBusiness[msg.sender].startDate = block.timestamp;
        //     flushBusiness[msg.sender].endDate = block.timestamp.add(flushCycleDays[0]);
        //     flushBusiness[msg.sender].cycle = 1;
        //     totalUsers = totalUsers.add(1);
        // }

        TotalInvestment += msg.value;
        uint256 tokenReceivedPrincipal = msg.value.div(csmTokenPrice)*1e18;
        principalToken[msg.sender] += tokenReceivedPrincipal;
        user.deposits.push(Deposit(msg.value, block.timestamp, 0));

    }

    function groupAIncome(address _userAddress) public view returns(uint256 _income){
        address groupAuser =  directs[_userAddress][0];
        _income = users[groupAuser].totalDownLineBusiness;
        _income = _income.sub(flushBusiness[msg.sender].groupA);

    }

    function groupBIncome(address _userAddress) public view returns(uint256 _income){
        address groupBuser =  directs[_userAddress][1];
        _income = users[groupBuser].totalDownLineBusiness;
        _income = _income.sub(flushBusiness[msg.sender].groupB);
    }

    function groupCIncome(address _userAddress) public view returns(uint256 _income){
         User storage user = users[_userAddress];
         for(uint i=2; i <= user.refs[0]; i++){
            address groupCuser =  directs[_userAddress][i];
            _income += users[groupCuser].totalDownLineBusiness;
            _income = _income.sub(flushBusiness[msg.sender].groupC);
         }
    }


    function payAndGetGroupReward() public payable returns(uint256){

        require(flushBusiness[msg.sender].endDate >= block.timestamp, 'time over!');
        uint256 groupRewardIncome = groupEligibilityIncome(msg.sender);
        uint256 reInvestmentAmount = groupRewardIncome.mul(25).div(100);
        uint bnb =  getCalculatedBnbRecieved(reInvestmentAmount);
        require(msg.value >= bnb, 'not enough fund!');
        flushBusiness[msg.sender].cycle +=1;
        uint nextcycledate = (flushBusiness[msg.sender].cycle >= 3) ? flushCycleDays[2] : flushCycleDays[1]; 
        flushBusiness[msg.sender].startDate = block.timestamp;
        flushBusiness[msg.sender].endDate = block.timestamp.add(nextcycledate);

        flushBusiness[msg.sender].groupA = groupAIncome(msg.sender);
        flushBusiness[msg.sender].groupB = groupBIncome(msg.sender);
        flushBusiness[msg.sender].groupC = groupCIncome(msg.sender);
        
        uint bnbtosend = getCalculatedBnbRecieved(groupRewardIncome);
        payable(msg.sender).transfer(bnbtosend);
        return 1;

    }


    function DoflushBusiness() public returns(bool){

        uint nextcycledate;
        if(flushBusiness[msg.sender].cycle == 1){
            nextcycledate = flushCycleDays[0];
        }else if(flushBusiness[msg.sender].cycle == 2){
            nextcycledate = flushCycleDays[1];
        }else if(flushBusiness[msg.sender].cycle == 3){
            nextcycledate = flushCycleDays[2];
        } 
        flushBusiness[msg.sender].startDate = block.timestamp;
        flushBusiness[msg.sender].endDate = block.timestamp.add(nextcycledate);

        flushBusiness[msg.sender].groupA = groupAIncome(msg.sender);
        flushBusiness[msg.sender].groupB = groupBIncome(msg.sender);
        flushBusiness[msg.sender].groupC = groupCIncome(msg.sender);

        return true;
    }



    function groupEligibilityIncome(address _userAddress) public view returns(uint256){

        uint256[] memory arrayIncome;
        arrayIncome[0] = groupAIncome(_userAddress);
        arrayIncome[1] = groupBIncome(_userAddress);
        arrayIncome[2] = groupCIncome(_userAddress);

        uint256 minimumBusinessFromGroup = min(arrayIncome);
        uint256 groupReward;
        if(minimumBusinessFromGroup >= Group_Rewards_Program[0] && minimumBusinessFromGroup < Group_Rewards_Program[1]){
            groupReward = Group_Rewards_Program[0];
        }else if(minimumBusinessFromGroup >= Group_Rewards_Program[1] && minimumBusinessFromGroup < Group_Rewards_Program[2]){
            groupReward = Group_Rewards_Program[1];
        }else if(minimumBusinessFromGroup >= Group_Rewards_Program[2] && minimumBusinessFromGroup < Group_Rewards_Program[3]){
            groupReward = Group_Rewards_Program[2];
        }else if(minimumBusinessFromGroup >= Group_Rewards_Program[3] && minimumBusinessFromGroup < Group_Rewards_Program[4]){
            groupReward = Group_Rewards_Program[3];
        }else if(minimumBusinessFromGroup >= Group_Rewards_Program[4] && minimumBusinessFromGroup < Group_Rewards_Program[5]){
            groupReward = Group_Rewards_Program[4];
        }else if(minimumBusinessFromGroup >= Group_Rewards_Program[5]){
            groupReward = Group_Rewards_Program[5];
        }
        return groupReward;

    }

    function min(uint256[] memory numbers) public pure returns (uint256) {
     require(numbers.length > 0); // throw an exception if the condition is not met
        uint256 minNumber; // default 0, the lowest value of `uint256`

        for (uint256 i = 0; i < numbers.length; i++) {
            if (minNumber > numbers[i]) {
                minNumber = numbers[i];
            }
        }

        return minNumber;
    }


    function stake(uint _package) public returns(bool){
        
        require(principalToken[msg.sender] >= 100*1e18, "Minimum Stake 100");
        uint256 calRewardToken = principalToken[msg.sender].mul(farmingRewardPercentage[_package]).div(100);
        tokenStakes[msg.sender].push(TokenStaked(principalToken[msg.sender], principalToken[msg.sender].add(calRewardToken),_package));
        numberOfFarming[msg.sender] += 1;

        //Basic
        if(farmingLockPeriod[_package]==180){

            uint256 receivable = principalToken[msg.sender].add(calRewardToken).div(2); 
            scheduleWithdrawals[msg.sender][numberOfFarming[msg.sender]].push(ScheduleTokenWithdrawal(receivable,180,false));
            scheduleWithdrawals[msg.sender][numberOfFarming[msg.sender]].push(ScheduleTokenWithdrawal(receivable,270,false));
            numberOfstakeAgainstFarming[msg.sender][numberOfFarming[msg.sender]] = 2;
        }
        //Premium
        if(farmingLockPeriod[_package]==365){

            uint256 receivable = principalToken[msg.sender].add(calRewardToken); 
            scheduleWithdrawals[msg.sender][numberOfFarming[msg.sender]].push(ScheduleTokenWithdrawal(receivable.mul(333).div(1000),180,false));
            scheduleWithdrawals[msg.sender][numberOfFarming[msg.sender]].push(ScheduleTokenWithdrawal(receivable.mul(333).div(1000),270,false));
            scheduleWithdrawals[msg.sender][numberOfFarming[msg.sender]].push(ScheduleTokenWithdrawal(receivable.mul(333).div(1000),365,false));
            numberOfstakeAgainstFarming[msg.sender][numberOfFarming[msg.sender]] = 3;
        }


        //Glod
        if(farmingLockPeriod[_package]==545){

            uint256 receivable = principalToken[msg.sender].add(calRewardToken); 
            scheduleWithdrawals[msg.sender][numberOfFarming[msg.sender]].push(ScheduleTokenWithdrawal(receivable.mul(200).div(1000),180,false));
            scheduleWithdrawals[msg.sender][numberOfFarming[msg.sender]].push(ScheduleTokenWithdrawal(receivable.mul(200).div(1000),270,false));
            scheduleWithdrawals[msg.sender][numberOfFarming[msg.sender]].push(ScheduleTokenWithdrawal(receivable.mul(200).div(1000),360,false));
            scheduleWithdrawals[msg.sender][numberOfFarming[msg.sender]].push(ScheduleTokenWithdrawal(receivable.mul(200).div(1000),450,false));
            scheduleWithdrawals[msg.sender][numberOfFarming[msg.sender]].push(ScheduleTokenWithdrawal(receivable.mul(200).div(1000),545,false));
            numberOfstakeAgainstFarming[msg.sender][numberOfFarming[msg.sender]] = 5;
        }

        // platinum
        if(farmingLockPeriod[_package]==720){

            uint256 receivable = principalToken[msg.sender].add(calRewardToken); 
            scheduleWithdrawals[msg.sender][numberOfFarming[msg.sender]].push(ScheduleTokenWithdrawal(receivable.mul(150).div(1000),180,false));
            scheduleWithdrawals[msg.sender][numberOfFarming[msg.sender]].push(ScheduleTokenWithdrawal(receivable.mul(150).div(1000),270,false));
            scheduleWithdrawals[msg.sender][numberOfFarming[msg.sender]].push(ScheduleTokenWithdrawal(receivable.mul(150).div(1000),360,false));
            scheduleWithdrawals[msg.sender][numberOfFarming[msg.sender]].push(ScheduleTokenWithdrawal(receivable.mul(150).div(1000),450,false));
            scheduleWithdrawals[msg.sender][numberOfFarming[msg.sender]].push(ScheduleTokenWithdrawal(receivable.mul(150).div(1000),545,false));
            scheduleWithdrawals[msg.sender][numberOfFarming[msg.sender]].push(ScheduleTokenWithdrawal(receivable.mul(150).div(1000),630,false));
            scheduleWithdrawals[msg.sender][numberOfFarming[msg.sender]].push(ScheduleTokenWithdrawal(receivable.mul(100).div(1000),720,false));
            numberOfstakeAgainstFarming[msg.sender][numberOfFarming[msg.sender]] = 7;
            
        }

        return true;

    }

    function WithdrawalToken(uint _fno, uint _sno) public {
        if( scheduleWithdrawals[msg.sender][_fno][_sno].maturitydate > 0 && block.timestamp >= scheduleWithdrawals[msg.sender][_fno][_sno].maturitydate.mul(1 days)){
            scheduleWithdrawals[msg.sender][_fno][_sno].ispaid = true;

            // Token To transfer has remainning.
        }
    }


    function getNumberOfFrearminig(address _userAddress) public view returns(uint){
        return numberOfFarming[_userAddress];
    }

    function getNumberOfStakeAgainstFrearminig(address _userAddress) public view returns(uint _NoOfFearming, uint _NoOfStakes){
        _NoOfFearming = numberOfFarming[_userAddress];
        _NoOfStakes = numberOfstakeAgainstFarming[_userAddress][_NoOfFearming];
    }


        
    function getUserDetails(address _address) public view returns(address _referrer, uint256 _bonus, uint256 _totalBonus, uint256 _totalWithdrwan, uint256 _totalDownLineBusiness ){
        User storage user = users[_address];
        return(user.referrer,user.bonus, user.totalBonus, user.totalWithdrwan, user.totalDownLineBusiness);
    }

    function eligibleForDirectBonus(uint256 amount) public view returns(uint256){

        uint256 _percent;
		uint _amount = uint(TotalusdPrice(int(amount)));

        if(_amount >= (plan[0]*1e8) && _amount < (plan[1]*1e8)){
			_percent = plan_ref_bonuses[0];
		}else if(_amount >= (plan[1]*1e8) && _amount < (plan[2]*1e8)){
			_percent = plan_ref_bonuses[1];
		}else if(_amount >= (plan[2]*1e8) && _amount < (plan[3]*1e8)){
			_percent = plan_ref_bonuses[2];
		}else if(_amount >= (plan[3]*1e8)){
			_percent = plan_ref_bonuses[3];
		}

		return (_percent);
		
	}


    function getLatestPrice() public view returns (int) {
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt */,
            /*uint timeStamp*/,
           /* uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }

    function TotalusdPrice(int _amount) public view returns (int) {
        int usdt = getLatestPrice();
        return (usdt * _amount)/1e18;
    }

    function getCalculatedBnbRecieved(uint256 _amount) public view returns(uint256) {
		uint256 usdt = uint256(getLatestPrice());
		uint256 recieved_bnb = (_amount*1e18/usdt*1e18)/1e18;
		return recieved_bnb;
	  }
    function getSystemInfo() public view returns( uint _TotalInvestment, uint _totalUsers){
        return (TotalInvestment,totalUsers);
        
    }
    function getDepositLength(address _useraddress) public view returns(uint){
        User storage u = users[_useraddress] ;
        return u.deposits.length;
    }   
    function getDepositInfo(uint _index ,address _useraddress) public view returns(uint _amount  , uint _start, uint _lastdate){
        User storage u = users[_useraddress] ;
        return (u.deposits[_index].amount , u.deposits[_index].start,u.deposits[_index].lastdate);
    }

}







//*******************************************************************//
//------------------------ SafeMath Library -------------------------//
//*******************************************************************//

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    require(c / a == b, 'SafeMath mul failed');
    return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, 'SafeMath sub failed');
    return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath add failed');
    return c;
    }
}

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}