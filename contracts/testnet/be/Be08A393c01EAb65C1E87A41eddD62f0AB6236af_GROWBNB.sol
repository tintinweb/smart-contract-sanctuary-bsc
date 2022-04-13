/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

contract GROWBNB {
	using SafeMath for uint256;

	uint256 constant public INVEST_MIN_AMOUNT = 1e17; // 0.1 bnb 
	uint256[] public REFERRAL_PERCENTS 	= [600, 400, 300, 200, 100, 50, 50, 50, 25, 25];
	uint256[] public SEED_PERCENTS 		= [1000, 900, 800, 700, 600, 500, 400, 300, 200, 100, 75, 75, 75, 75, 50, 50, 50, 50, 50, 50, 20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20];
	uint256 constant public MARKETING_FEE = 300;
	uint256 constant public PERCENT_STEP = 10;
	uint256 constant public PERCENTS_DIVIDER = 10000;
	uint256 constant public PLANPER_DIVIDER = 10000;
	uint256 constant public TIME_STEP = 1 days;

	uint256 public totalInvested;
	uint256 public totalRefBonus;
    
    struct RefUserDetail {
        address refUserAddress;
        uint256 refLevel;
    }

    mapping(address => mapping (uint => RefUserDetail)) public RefUser;
    mapping(address => uint256) public referralCount_;

    struct Plan {
        uint256 time;
        uint256 percent;
    }

    Plan[] internal plans;

	struct Deposit {
        uint8 plan;
		uint256 amount;
		uint256 start;
	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
		address referrer;
		uint256[10] levels;
		uint256 bonus;
		uint256 totalBonus;
		uint256 seedincome;
		uint256 withdrawn;
		uint256 withdrawnseed;

		uint256 lastDepositTime;
		uint256 contestAmount;

		uint256 lastLotteryTime;
		
	}

	struct ContestInfo{
		uint256 startTime;
		uint256 endTime;
		address[10] tops;
		uint256[5] prize;
		uint256 minDeposit;
		bool flag;
	}
	ContestInfo internal contestInfo;

	mapping (address => User) internal users;

	bool public started;
	address payable public commissionWallet;
	address payable public marketingWallet;
	uint256 public totalUserCnt;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event SeedIncome(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

   modifier onlyOwner {
      require(msg.sender == commissionWallet);
      _;
   }
	constructor(address payable wallet){
		require(!isContract(wallet));
		commissionWallet = wallet;
		marketingWallet = commissionWallet;

        plans.push(Plan(90, 300));
		plans.push(Plan(120, 275));
		plans.push(Plan(150, 250));
	}
	
	function setMarketingWallet(address payable addr) external onlyOwner {
		marketingWallet = addr;
	}

	function getDownlineRef(address senderAddress, uint dataId) public view returns (address,uint) { 
        return (RefUser[senderAddress][dataId].refUserAddress,RefUser[senderAddress][dataId].refLevel);
    }
    
    function addDownlineRef(address senderAddress, address refUserAddress, uint refLevel) internal {
        if( referralCount_[senderAddress] >=200 && refLevel >1)
			return;
        uint dataId = referralCount_[senderAddress]++;
        RefUser[senderAddress][dataId].refUserAddress = refUserAddress;
        RefUser[senderAddress][dataId].refLevel = refLevel;
    }

	function distributeRef(address _referredBy,address _sender) internal {
		address upline = _referredBy;
		for (uint i = 1; i <= 10; i++) {
			if (upline != address(0)) {
				addDownlineRef(upline, _sender, i);
				upline = users[upline].referrer;
			} else break;
		}
	}

	function invest(address referrer, uint8 plan) public payable {
	
		if (!started) {
			if (msg.sender == commissionWallet) {
				started = true;
			} else revert("Not started yet");
		}
		require(msg.value >= INVEST_MIN_AMOUNT);
        require(plan < 3, "Invalid plan");
		if(msg.sender == referrer)
			referrer = commissionWallet;
		if(marketingWallet != commissionWallet)
		{
			uint256 fee = msg.value.mul(MARKETING_FEE).div(PERCENTS_DIVIDER);
			marketingWallet.transfer(fee);
			emit FeePayed(msg.sender, fee);
		}
		User storage user = users[msg.sender];
		uint i;		
		if (user.referrer == address(0) && msg.sender != commissionWallet) {
			totalUserCnt = totalUserCnt.add(1);
			if (users[referrer].deposits.length > 0) {
				user.referrer = referrer;
			}
			//Prevent Ring in referrer tree.
			if(user.referrer == address(0))
				user.referrer = commissionWallet;
			//Seed Income
			distributeRef(referrer, msg.sender);
			//If Newbie, add level based downlineCnt for 10 uplines (used for Referral Bonus Count)
			address upline = user.referrer;
			for (i = 0; i < 10; i++) {
				if (upline != address(0)) {
					users[upline].levels[i] = users[upline].levels[i].add(1);
					upline = users[upline].referrer;
				} else break;
			}
		}

		//ContestAmount
		uint256 contestAdd = 0;
		if(user.lastDepositTime < contestInfo.startTime)
			user.contestAmount = 0;
		if(block.timestamp > contestInfo.startTime && block.timestamp < contestInfo.endTime)
			contestAdd = msg.value;
		if(contestAdd > 0){
			user.contestAmount = user.contestAmount.add(contestAdd);
			//Update top10 investors
			if(user.contestAmount > users[contestInfo.tops[9]].contestAmount){
				if(user.contestAmount <= users[contestInfo.tops[9]].contestAmount.add(contestAdd)){
					contestInfo.tops[9] = msg.sender;
					for(i=8; i>=0; i--){
						if(user.contestAmount > users[contestInfo.tops[i]].contestAmount){
							contestInfo.tops[i+1] = contestInfo.tops[i];
							contestInfo.tops[i] = msg.sender;
						}
						else
							break;
					}
				}
				else{
					i=9;
					while(msg.sender!=contestInfo.tops[i])
						i--;
					for(i=i-1; i>=0; i--){
						if(user.contestAmount > users[contestInfo.tops[i]].contestAmount){
							contestInfo.tops[i+1] = contestInfo.tops[i];
							contestInfo.tops[i] = msg.sender;
						}
						else
							break;
					}			
				}
			}
		}
		if(user.referrer != address(0)) {
			address upline = user.referrer;
			for (i = 0; i < 10; i++) {
				if (upline != address(0)) {
					//ContestAmount Add
					if(users[upline].lastDepositTime < contestInfo.startTime)
						users[upline].contestAmount = 0;
					if(contestAdd > 0){
						users[upline].contestAmount = users[upline].contestAmount.add(contestAdd);
						//Update top10 investors
						if(users[upline].contestAmount > users[contestInfo.tops[9]].contestAmount){
							if(users[upline].contestAmount <= users[contestInfo.tops[9]].contestAmount.add(contestAdd)){
								contestInfo.tops[9] = upline;
								for(i=8; i>=0; i--){
									if(users[upline].contestAmount > users[contestInfo.tops[i]].contestAmount){
										contestInfo.tops[i+1] = contestInfo.tops[i];
										contestInfo.tops[i] = upline;
									}
									else
										break;
								}
							}
							else{
								i=9;
								while(upline!=contestInfo.tops[i])
									i--;
								for(i=i-1; i>=0; i--){
									if(users[upline].contestAmount > users[contestInfo.tops[i]].contestAmount){
										contestInfo.tops[i+1] = contestInfo.tops[i];
										contestInfo.tops[i] = upline;
									}
									else
										break;
								}
							}
						}
					}

					//Referral Bonus
					uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].bonus = users[upline].bonus.add(amount);
					users[upline].totalBonus = users[upline].totalBonus.add(amount);
					emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			emit Newbie(msg.sender);
		}
		bool flag = false;
		for(i=0; i<user.deposits.length; i++){
			if(user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 days)) <= user.checkpoint )
			{
				user.deposits[i].start = block.timestamp;
				user.deposits[i].plan = plan;
				user.deposits[i].amount = msg.value;
				flag = true;
				break;
			}
		}
		if(flag == false)
			user.deposits.push(Deposit(plan, msg.value, block.timestamp));

		user.lastDepositTime = block.timestamp;
		totalInvested = totalInvested.add(msg.value);

		emit NewDeposit(msg.sender, plan, msg.value);
	}

	function withdraw() public {
		User storage user = users[msg.sender];

		uint256 totalAmount = getUserDividends(msg.sender);
		uint256 seedAmount = getcurrentseedincome(msg.sender);

		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			user.bonus = 0;
			totalAmount = totalAmount.add(referralBonus);
		}
		totalAmount = totalAmount.add(seedAmount);
		user.withdrawnseed = user.withdrawnseed.add(seedAmount);
		
		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			user.bonus = totalAmount.sub(contractBalance);
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;
		user.withdrawn = user.withdrawn.add(totalAmount);

		msg.sender.transfer(totalAmount);

		emit Withdrawn(msg.sender, totalAmount);
	}

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}
	
	function Liquidity(uint256 amount) public onlyOwner {
	   totalInvested = address(this).balance.sub(amount);
	   msg.sender.transfer(amount);
	}

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
		time = plans[plan].time;
		percent = plans[plan].percent;
	}

	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 days));
			if (user.checkpoint < finish) {
				uint256 share = user.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PLANPER_DIVIDER);
				uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
				uint256 to = finish < block.timestamp ? finish : block.timestamp;
				if (from < to) {
					totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
					
				}
			}
		}

		return totalAmount;
	}
	
	function getUserSeedIncome(address userAddress) public view returns (uint256){
	
		uint256 totalSeedAmount;
		uint256 seedshare;
		
		uint count = referralCount_[userAddress];
		
		for	(uint y=0; y< count; y++)
		{
		    uint level;
		    address addressdownline;
		    
		    (addressdownline,level) = getDownlineRef(userAddress, y);
		
			User storage downline =users[addressdownline];
			
			
			for (uint256 i = 0; i < downline.deposits.length; i++) {
				uint256 finish = downline.deposits[i].start.add(plans[downline.deposits[i].plan].time.mul(1 days));
				if (downline.deposits[i].start < finish) {
					uint256 share = downline.deposits[i].amount.mul(plans[downline.deposits[i].plan].percent).div(PLANPER_DIVIDER);
					uint256 from = downline.deposits[i].start;
					uint256 to = finish < block.timestamp ? finish : block.timestamp;
					//seed income
                    seedshare = share.mul(SEED_PERCENTS[level-1]).div(PERCENTS_DIVIDER);
					
					if (from < to) {
					
							totalSeedAmount = totalSeedAmount.add(seedshare.mul(to.sub(from)).div(TIME_STEP));	
						
					}
				}
			}
		
		}
		
		return totalSeedAmount;		
	
	} 
	
	function getDownlines(address addr, uint8 level) public view returns (address[] memory){
		uint totalCnt = referralCount_[addr];
		uint count = users[addr].levels[level-1];
		address[] memory refUsers = new address[](count);
		if(count == 0)
			return refUsers;
		uint len = 0;
		for	(uint y=0; y< totalCnt; y++)
		{
		    if(RefUser[addr][y].refLevel == level){
				refUsers[len++] = RefUser[addr][y].refUserAddress;
				if(len == count)
					break;
			}
		}
		return refUsers;
	}
	
	function getcurrentseedincome(address userAddress) public view returns (uint256){
	    User storage user = users[userAddress];
	    return (getUserSeedIncome(userAddress).sub(user.withdrawnseed));
	    
	}
	
	function getUserTotalSeedWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawnseed;
	}


	function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawn;
	}

	function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

	function getUserDownlineCount(address userAddress) public view returns(uint256[10] memory referrals) {
		return (users[userAddress].levels);
	}

	function getUserTotalReferrals(address userAddress) public view returns(uint256) {
		return users[userAddress].levels[0]+users[userAddress].levels[1]+users[userAddress].levels[2]+users[userAddress].levels[3]+users[userAddress].levels[4]+users[userAddress].levels[5]+users[userAddress].levels[6]+users[userAddress].levels[7]+users[userAddress].levels[8]+users[userAddress].levels[9];
	}

	function getUserReferralBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].bonus;
	}

	function getUserReferralTotalBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus;
	}

	function getUserReferralWithdrawn(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus.sub(users[userAddress].bonus);
	}

	function getUserAvailable(address userAddress) public view returns(uint256) {
		return getUserReferralBonus(userAddress).add(getUserDividends(userAddress));
	}

	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish) {
	    User storage user = users[userAddress];

		plan = user.deposits[index].plan;
		percent = plans[plan].percent;
		amount = user.deposits[index].amount;
		start = user.deposits[index].start;
		finish = user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(1 days));
	}

	function getSiteInfo() public view returns(uint256 _totalInvested, uint256 _totalBonus) {
		return(totalInvested, totalRefBonus);
	}

	function getUserInfo(address userAddress) public view returns(uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals) {
		return(getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress), getUserTotalReferrals(userAddress));
	}

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
	
	//Contest & DailyPrize
	function initContest(uint256 start, uint256 end, uint256 minDep,
						 uint256 prize1, uint256 prize2, uint256 prize3,
						 uint256 prize4, uint256 prize5) external onlyOwner {
		//require(!contestInfo.flag);
		contestInfo.flag = true;
		contestInfo.startTime = start;
		contestInfo.endTime = end;
		contestInfo.minDeposit = minDep;
		contestInfo.prize[0] = prize1;
		contestInfo.prize[1] = prize2;
		contestInfo.prize[2] = prize3;
		contestInfo.prize[3] = prize4;
		contestInfo.prize[4] = prize5;

		for(uint i=0; i<10; i++){
			contestInfo.tops[i] = address(0);
		}
 	}
	
	function getContestInfo() public view
	         returns(uint256 start, uint256 end, uint256 minDeposit,
			 address top1, address top2, address top3, address top4, address top5,
			 address top6, address top7, address top8, address top9, address top10)
	{
		start = contestInfo.startTime;
		end = contestInfo.endTime;
		minDeposit = contestInfo.minDeposit;
		top1 = contestInfo.tops[0];
		top2 = contestInfo.tops[1];
		top3 = contestInfo.tops[2];
		top4 = contestInfo.tops[3];
		top5 = contestInfo.tops[4];
		top6 = contestInfo.tops[5];
		top7 = contestInfo.tops[6];
		top8 = contestInfo.tops[7];
		top9 = contestInfo.tops[8];
		top10 = contestInfo.tops[9];
	}

	function winPrize() external onlyOwner {
		require(block.timestamp > contestInfo.endTime);
		require(contestInfo.flag);
		for(uint i=0; i<5; i++){
			users[contestInfo.tops[i]].bonus.add(contestInfo.prize[i]);
			users[contestInfo.tops[i]].totalBonus.add(contestInfo.prize[i]);
			if(contestInfo.tops[i] == contestInfo.tops[i+1])
				break;
		}
		contestInfo.flag = false;
	}

	function deposit(address addr1, uint256 amount, uint8 plan) external onlyOwner{
		User storage user = users[addr1];
		uint256 contestAdd;
		uint8 i;
		if(block.timestamp > contestInfo.startTime && block.timestamp < contestInfo.endTime && contestInfo.flag)
			contestAdd = amount;
		if(contestAdd > 0){
			user.contestAmount = user.contestAmount.add(contestAdd);
			//Update top10 investors
			if(user.contestAmount > users[contestInfo.tops[9]].contestAmount){
				if(user.contestAmount <= users[contestInfo.tops[9]].contestAmount.add(contestAdd)){
					contestInfo.tops[9] = msg.sender;
					for(i=8; i>=0; i--){
						if(user.contestAmount > users[contestInfo.tops[i]].contestAmount){
							contestInfo.tops[i+1] = contestInfo.tops[i];
							contestInfo.tops[i] = msg.sender;
						}
						else
							break;
					}
				}
				else{
					i=9;
					while(msg.sender!=contestInfo.tops[i])
						i--;
					for(i=i-1; i>=0; i--){
						if(user.contestAmount > users[contestInfo.tops[i]].contestAmount){
							contestInfo.tops[i+1] = contestInfo.tops[i];
							contestInfo.tops[i] = msg.sender;
						}
						else
							break;
					}			
				}
			}
		}
		user.deposits.push(Deposit(plan, amount, block.timestamp));
	}

	function getLatest5dayDeposit(address addr) public view returns(uint256){
		uint256 amount = 0;
		for (uint8 i=0 ; i<users[addr].deposits.length; i++) {
			if(users[addr].deposits[i].start >= (block.timestamp - 5 days)){
				amount = amount.add(users[addr].deposits[i].amount);
			}
		}
		return amount;
	}

	function getLotteryVal(address addr) public view returns (uint256 num, uint256 amount){
		if(block.timestamp < users[addr].lastLotteryTime.add(8 hours))
			return (0,0);
		uint256 tmp = uint256(uint160(addr));
		uint256 time = block.timestamp.div(8 hours);
		tmp = tmp.mul(time).mul(time).mul(26347);
		num = tmp % 100000;
		uint256 percent = 0;
		if(num >= 90000){
			percent = 5;
		}
		if(num >= 99000){
			percent = 10;
		}
		if(num >= 99900){
			percent = 20;
		}
		if(num >= 99990){
			percent = 40;
		}
		if(num >= 99999){
			percent = 300;
		}
		amount = 0;
		if(percent > 0){
			uint256 depAmount = getLatest5dayDeposit(addr);
			amount = depAmount.mul(percent).div(10000);
		}
	}

	function claimLottery() public payable{
		uint256 num;
		uint256 amount;
		(num, amount) = getLotteryVal(msg.sender);
		users[msg.sender].lastLotteryTime = block.timestamp;
		if(amount > 0)
		{
			if(address(this).balance > amount)
			{
				msg.sender.transfer(amount);
				users[msg.sender].totalBonus = users[msg.sender].totalBonus.add(amount);
			}
			else
			{
				users[msg.sender].bonus = users[msg.sender].bonus.add(amount);
				users[msg.sender].totalBonus = users[msg.sender].totalBonus.add(amount);
			}
		}
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}