/**
 *Submitted for verification at BscScan.com on 2022-10-01
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;

contract XXXXXX {
	using SafeMath for uint256;

	//uint256 constant public INVEST_MIN_AMOUNT = 0.1 ether; mainnet
	uint256 constant public INVEST_MIN_AMOUNT = 0.01 ether; //testnet
	uint256[] public REFERRAL_PERCENTS = [50, 30, 20];
    uint256[] public MAX_DEPOSIT = [100 ether, 200 ether, 300 ether, 400 ether];
    uint256[] public WITHDRAW_FEE1 = [250, 210, 200, 180, 160, 140, 130, 110, 90, 70, 50, 40, 20, 0];
    uint256[] public WITHDRAW_FEE2 = [250, 230, 210, 200, 190, 180, 170, 150, 140, 130, 120, 110, 100, 80, 70, 60, 50, 40, 20, 10, 0];
	uint256 constant public DEPOSIT_FEE = 50;
	uint256 constant public DEV_FEE = 10;
	uint256 constant public COMPOUND_FEE = 50;
	uint256 constant public PERCENT_STEP = 5;
	uint256 constant public HOLD_STEP = 1;
	uint256 constant public PERCENTS_DIVIDER = 1000;
	//uint256 constant public TIME_STEP = 1 days; mainnet
	uint256 constant public TIME_STEP = 60; // testnet
    uint256 constant public REINVEST_BONUS = 50;
    uint256 constant public ACTIVE_DEPOSIT_MAX = 300;
	uint256 constant public MAX_INVESTS = 200; 
    uint256 constant public USERS_COUNT_MAX = 1000;
    uint256 constant public USERS_COUNT_BONUS = 50;

    uint256 public lastDistribute;
    uint256 public prizeCycle;
    address[] public depositorWinners;
    address[] public leaderWinners;
    uint256 constant public RAND_PRIZE = 50;
    uint256 constant public DEPOSITOR_PRIZE = 50;
    uint256 constant public LEADER_PRIZE = 100;
	uint256 public DAILY_COUNTER = 0;

    mapping(uint => mapping(address => ProfileDay)) public dayInfo;
	mapping(uint256 => mapping(uint256 => address)) public randomDailyPrize;
    mapping(address => bool) _blacklist;

	uint256 public totalStaked;
	uint256 public totalRefBonus;
    uint256 public userCount;
    uint256 public activeDeposit;
	uint256 public totalWithdrawn;

    struct Plan {
        uint256 time;
        uint256 percent;
    }

    Plan[] internal plans;

	struct Deposit {
        uint8 plan;
		uint256 percent;
		uint256 initialAmount;
        uint256 finalAmount;
		uint256 profit;
		uint256 start;
		uint256 finish;
        uint256 checkpoint;
		uint256 withdrawn;
		bool isCompound;
		bool first1000Extra5;
		bool topDepositors5;
		bool topLeaders10;
		bool randomNewDepositors5;
	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
		address referrer;
		uint256[3] levels;
		uint256 bonus;
		uint256 totalBonus;
		uint256 excessBalance;
	}

    struct ProfileDay {
        uint256 depositAmount;
        uint256 leaderAmount;
    }

	mapping (address => User) internal users;

	uint256 public startUNIX;
	address payable public commissionWallet;
	address payable public devWallet;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish);
	event NewCompound(address indexed user, uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);
    event WithdrawnRef(address indexed user, uint256 amount);
    event BlacklistUpdated(address indexed user, bool value);
	event DistributeLeader(address indexed user, uint256 value);
	event DistributeDepositor(address indexed user, uint256 value);
	event DistributeRandom(address indexed user, uint256 value);

	constructor() {
		//commissionWallet = payable(); mainnet
		commissionWallet = payable(msg.sender); //testnet
		//devWallet = payable(); mainnet
		devWallet = payable(msg.sender); //testnet
		//startUNIX = ; mainnet
        startUNIX = block.timestamp; // testnet
        lastDistribute = startUNIX;

		depositorWinners.push(address(0));
		leaderWinners.push(address(0));

        plans.push(Plan(14, 100));
        plans.push(Plan(21, 80));
        plans.push(Plan(21, 110));
	}	

	function invest(address referrer, uint8 plan) public payable {
		require(block.timestamp > startUNIX, "not luanched yet");
		User storage user = users[msg.sender];
		uint256 depositAmount = msg.value;
		if(user.excessBalance > 0){
			depositAmount = depositAmount.add(user.excessBalance);
			user.excessBalance = 0;
		}
		require(depositAmount >= INVEST_MIN_AMOUNT, "the min amount is 0.1 BNB");
        require(!isBlackListed(msg.sender), "blacklist");
        require(plan < 3, "Invalid plan");
        if(prizeCycle < 4){
            require(depositAmount <= MAX_DEPOSIT[prizeCycle], "high amount");
        }else{
            uint256 maxAmount = activeDeposit.mul(ACTIVE_DEPOSIT_MAX).div(PERCENTS_DIVIDER);
			if(maxAmount < 1 ether){
				maxAmount = 1 ether;
			}
            require(depositAmount <= maxAmount, "high amount");
        }
		require(user.deposits.length < MAX_INVESTS, " max 200 depsoits");


		uint256 depositFee = depositAmount.mul(DEPOSIT_FEE).div(PERCENTS_DIVIDER);
		uint256 devFee = depositAmount.mul(DEV_FEE).div(PERCENTS_DIVIDER);
		commissionWallet.transfer(depositFee);
		devWallet.transfer(devFee);
		emit FeePayed(msg.sender, depositFee.add(devFee));


		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
				user.referrer = referrer;
			}

			address upline = user.referrer;
			for (uint256 i = 0; i < 3; i++) {
				if (upline != address(0)) {
					users[upline].levels[i] = users[upline].levels[i].add(1);
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 3; i++) {
				if (upline != address(0)) {
					uint256 amount = depositAmount.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].bonus = users[upline].bonus.add(amount);
					users[upline].totalBonus = users[upline].totalBonus.add(amount);
                    totalRefBonus += amount;
					emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
				} else break;
			}

		}

        // Update user daily profile
        ProfileDay storage userProfileDay = dayInfo[prizeCycle][msg.sender];
        ProfileDay storage referrerProfileDay = dayInfo[prizeCycle][user.referrer];
        userProfileDay.depositAmount += depositAmount;
        referrerProfileDay.leaderAmount += depositAmount;

        uint256 depositFinalAmount = depositAmount;
		bool isFirst1000Extra5 = false;
		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
            userCount += 1;
            if(userCount <= USERS_COUNT_MAX && user.referrer != address(0)){
                depositFinalAmount = depositFinalAmount.add(depositFinalAmount.mul(USERS_COUNT_BONUS).div(PERCENTS_DIVIDER));
				isFirst1000Extra5 = true;
            }
			emit Newbie(msg.sender);
		}

		(uint256 percent, uint256 profit, uint256 finish) = getResult(plan, depositAmount);
		user.deposits.push(Deposit(plan, percent, depositAmount, depositFinalAmount, profit, block.timestamp, finish, block.timestamp, 0, false, isFirst1000Extra5, false, false, false));

		_updateDailyPrize(msg.sender);
		DAILY_COUNTER++;
		distributeDailyPrize();

		totalStaked = totalStaked.add(depositAmount);
        activeDeposit = activeDeposit.add(depositAmount);
		emit NewDeposit(msg.sender, plan, percent, depositAmount, profit, block.timestamp, finish);
	}

	function withdraw(uint256 depositId) public {
		require(block.timestamp > startUNIX, "not luanched yet");
        require(!isBlackListed(msg.sender), "blacklist");
        User storage user = users[msg.sender];
        if(user.deposits[depositId].plan == 2){
        	require(user.deposits[depositId].checkpoint.add(TIME_STEP) < block.timestamp , "only once a day for plan 3");
        }

		uint256 totalAmount = getUserDepositDividends(msg.sender, depositId);
		require(totalAmount > 0, "User has no dividends");

		if(user.deposits[depositId].withdrawn.add(totalAmount) > user.deposits[depositId].finalAmount.mul(2)){	
			user.excessBalance = user.deposits[depositId].withdrawn.add(totalAmount).sub(user.deposits[depositId].finalAmount.mul(2));
			totalAmount = user.deposits[depositId].finalAmount.mul(2).sub(user.deposits[depositId].withdrawn);
		}

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

        if(user.deposits[depositId].plan != 1){
            uint256 withdrawFee;
            uint256 planDay = block.timestamp.sub(user.deposits[depositId].start).div(TIME_STEP);
            if(user.deposits[depositId].plan == 0){
                withdrawFee = planDay < WITHDRAW_FEE1.length ? WITHDRAW_FEE1[planDay] : 0;
            } else{
				withdrawFee = planDay < WITHDRAW_FEE2.length ? WITHDRAW_FEE2[planDay] : 0;
            }
            uint256 feeAmount = totalAmount.mul(withdrawFee).div(PERCENTS_DIVIDER);
            totalAmount = totalAmount.sub(feeAmount);
            commissionWallet.transfer(feeAmount.div(2));
		    emit FeePayed(msg.sender, feeAmount.div(2));
        }

		distributeDailyPrize();

		user.checkpoint = block.timestamp;
        user.deposits[depositId].checkpoint = block.timestamp;
		user.deposits[depositId].withdrawn = user.deposits[depositId].withdrawn.add(totalAmount);
        activeDeposit = activeDeposit.sub(totalAmount);
		totalWithdrawn = totalWithdrawn.add(totalAmount);

		payable(msg.sender).transfer(totalAmount);

		emit Withdrawn(msg.sender, totalAmount);
	}

	function preWithdraw(uint256 depositId) public view returns(uint256 toWallet, uint256 toExcess) {
		if(block.timestamp < startUNIX || isBlackListed(msg.sender)){
			return(0, 0);
		}
        User storage user = users[msg.sender];
        if(user.deposits[depositId].plan == 2 && user.deposits[depositId].checkpoint.add(TIME_STEP) > block.timestamp){
        	return(0, 0);
        }

		toWallet = getUserDepositDividends(msg.sender, depositId);

		if(user.deposits[depositId].withdrawn.add(toWallet) > user.deposits[depositId].finalAmount.mul(2)){	
			toExcess = user.deposits[depositId].withdrawn.add(toWallet).sub(user.deposits[depositId].finalAmount.mul(2));
			toWallet = user.deposits[depositId].finalAmount.mul(2).sub(user.deposits[depositId].withdrawn);
		}

		uint256 contractBalance = address(this).balance;
		if (contractBalance < toWallet) {
			toWallet = contractBalance;
		}

        if(user.deposits[depositId].plan != 1){
            uint256 withdrawFee;
            uint256 planDay = block.timestamp.sub(user.deposits[depositId].start).div(TIME_STEP);
			 if(user.deposits[depositId].plan == 0){
                withdrawFee = planDay < WITHDRAW_FEE1.length ? WITHDRAW_FEE1[planDay] : 0;
            } else{
				withdrawFee = planDay < WITHDRAW_FEE2.length ? WITHDRAW_FEE2[planDay] : 0;
            }
            uint256 feeAmount = toWallet.mul(withdrawFee).div(PERCENTS_DIVIDER);
            toWallet = toWallet.sub(feeAmount);
        }
	}

	function withdrawAll() public {
		require(block.timestamp > startUNIX, "not luanched yet");
        require(!isBlackListed(msg.sender), "blacklist");
        User storage user = users[msg.sender];
		(uint256 totalAmount, uint256 fee) = _getUserDividends(msg.sender);
		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

		totalAmount = totalAmount.sub(fee);
     	commissionWallet.transfer(fee.div(2));
		emit FeePayed(msg.sender, fee.div(2));

		distributeDailyPrize();

		user.checkpoint = block.timestamp;
     	activeDeposit = activeDeposit.sub(totalAmount);
	 	totalWithdrawn = totalWithdrawn.add(totalAmount);

		payable(msg.sender).transfer(totalAmount);

		emit Withdrawn(msg.sender, totalAmount);
	}

	function preWithdrawAll() public view returns(uint256 toWallet, uint256 toExcess){
		if(block.timestamp < startUNIX || isBlackListed(msg.sender)){
			return(0, 0);
		}
		(uint256 totalAmount, uint256 fee, uint256 excess) = _preGetUserDividends(msg.sender);

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

		totalAmount = totalAmount.sub(fee);
		toWallet = totalAmount;
		toExcess = excess;
	}

    function withdrawRef() public {
		require(block.timestamp > startUNIX, "not luanched yet");
        require(!isBlackListed(msg.sender), "blacklist");
		User storage user = users[msg.sender];
		uint256 totalAmount = 0;
		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			user.bonus = 0;
			totalAmount = totalAmount.add(referralBonus);
		}
		require(totalAmount > 0, "User has no dividends");
		require(totalAmount <= address(this).balance, "not enough BNB in contract");

		distributeDailyPrize();

		payable(msg.sender).transfer(totalAmount);
		emit WithdrawnRef(msg.sender, totalAmount);
	}

    function compound(uint256 depositId) public {
        require(block.timestamp > startUNIX, "not luanched yet");
        require(!isBlackListed(msg.sender), "blacklist");
		User storage user = users[msg.sender];
        if(user.deposits[depositId].plan == 2){
        	require(user.deposits[depositId].checkpoint.add(TIME_STEP) < block.timestamp , "only once a day for plan 3");
        }
		require(user.deposits.length < MAX_INVESTS, " max 200 depsoits");
		uint256 totalAmount = getUserDepositDividends(msg.sender, depositId);
		require(totalAmount > 0, "User has no dividends");

		uint256 compoundFee = totalAmount.mul(COMPOUND_FEE).div(PERCENTS_DIVIDER);
		uint256 devFee = totalAmount.mul(DEV_FEE).div(PERCENTS_DIVIDER);
		commissionWallet.transfer(compoundFee);
		devWallet.transfer(devFee);
		emit FeePayed(msg.sender, compoundFee.add(devFee));

		totalAmount = totalAmount.add(totalAmount.mul(REINVEST_BONUS).div(PERCENTS_DIVIDER));
		require(totalAmount >= INVEST_MIN_AMOUNT, "Reinvest amount should be more than 0.1 BNB");

		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 3; i++) {
				if (upline != address(0)) {
					uint256 amount = totalAmount.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].bonus = users[upline].bonus.add(amount);
					users[upline].totalBonus = users[upline].totalBonus.add(amount);
                    totalRefBonus += amount;
					emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
				} else break;
			}
		}

        uint8 depositPlan = user.deposits[depositId].plan;
		(uint256 percent, uint256 profit, uint256 finish) = getResult(depositPlan, totalAmount);
		user.deposits.push(Deposit(depositPlan, percent, totalAmount, totalAmount, profit, block.timestamp, finish, block.timestamp, 0, true, false, false, false, false));

		totalStaked = totalStaked.add(totalAmount);
		activeDeposit = activeDeposit.add(totalAmount);
		distributeDailyPrize();

		user.checkpoint = block.timestamp;

		emit NewCompound(msg.sender, depositPlan, percent, totalAmount, profit, block.timestamp, finish);
	}

    function _updateDailyPrize(address userAddress) private {
        User storage user = users[userAddress];
		_updateRandomPrize(userAddress);
        _updateDepositorRank(userAddress);
        _updateLeaderRank(user.referrer);
	}

    function _updateDepositorRank(address _user) private {
		if(dayInfo[prizeCycle][_user].depositAmount > dayInfo[prizeCycle][depositorWinners[prizeCycle]].depositAmount){
            depositorWinners[prizeCycle] = _user;
        }
	}

    function _updateLeaderRank(address _user) private {
		if(dayInfo[prizeCycle][_user].leaderAmount > dayInfo[prizeCycle][leaderWinners[prizeCycle]].leaderAmount){
            leaderWinners[prizeCycle] = _user;
        }
	}

    function _updateRandomPrize(address userAddress) private {
		randomDailyPrize[prizeCycle][DAILY_COUNTER] = userAddress;
	}

    function distributeDailyPrize() public {
		if(block.timestamp > (lastDistribute + TIME_STEP)){
			_distributeLeaderReward();
            _distributeRandomReward();
            _distributeDepositorReward();
			lastDistribute = block.timestamp;
            prizeCycle++;
			depositorWinners.push(address(0));
			leaderWinners.push(address(0));
		}
	}

    function _distributeLeaderReward() private {
		if(leaderWinners.length > 0 && leaderWinners[prizeCycle] != address(0)){
			User storage user = users[leaderWinners[prizeCycle]];
			uint256 winnerPrize = user.deposits[user.deposits.length - 1].initialAmount.mul(LEADER_PRIZE).div(PERCENTS_DIVIDER);
			user.deposits[user.deposits.length - 1].finalAmount += winnerPrize;
			user.deposits[user.deposits.length - 1].topLeaders10 = true;
			emit DistributeLeader(leaderWinners[prizeCycle], winnerPrize);
		}
       
	}

    function _distributeDepositorReward() private {
		if(depositorWinners.length > 0 && depositorWinners[prizeCycle] != address(0)){
			User storage user = users[depositorWinners[prizeCycle]];
			uint256 winnerPrize = user.deposits[user.deposits.length - 1].initialAmount.mul(DEPOSITOR_PRIZE).div(PERCENTS_DIVIDER);
			user.deposits[user.deposits.length - 1].finalAmount += winnerPrize;
			user.deposits[user.deposits.length - 1].topDepositors5 = true;
			emit DistributeDepositor(depositorWinners[prizeCycle], winnerPrize);
		}
	}

    function _distributeRandomReward() private {
		if(DAILY_COUNTER > 0){
			uint256 randomNumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.difficulty, DAILY_COUNTER)));
			uint256 FinalNumber = randomNumber % DAILY_COUNTER;

			User storage user = users[randomDailyPrize[prizeCycle][FinalNumber]];
			uint256 winnerPrize = user.deposits[user.deposits.length - 1].initialAmount.mul(RAND_PRIZE).div(PERCENTS_DIVIDER);
			user.deposits[user.deposits.length - 1].finalAmount += winnerPrize;
			user.deposits[user.deposits.length - 1].randomNewDepositors5 = true;
			DAILY_COUNTER = 0;
			emit DistributeRandom(randomDailyPrize[prizeCycle][FinalNumber], winnerPrize);
		}
	}

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
		time = plans[plan].time;
		percent = plans[plan].percent;
	}

	function getPercent(uint8 plan) public view returns (uint256) {
		if (block.timestamp > startUNIX) {
			return plans[plan].percent.add(PERCENT_STEP.mul(block.timestamp.sub(startUNIX)).div(TIME_STEP));
		} else {
			return plans[plan].percent;
		}
    }

    function getAllPercent() public view returns (uint256 percent0, uint256 percent1, uint256 percent2) {
		if (block.timestamp > startUNIX) {
			percent0 = plans[0].percent.add(PERCENT_STEP.mul(block.timestamp.sub(startUNIX)).div(TIME_STEP));
            percent1 = plans[1].percent.add(PERCENT_STEP.mul(block.timestamp.sub(startUNIX)).div(TIME_STEP));
            percent2 = plans[2].percent.add(PERCENT_STEP.mul(block.timestamp.sub(startUNIX)).div(TIME_STEP));
		} else {
			percent0 = plans[0].percent;
            percent0 = plans[1].percent;
            percent0 = plans[2].percent;
		}
    }

	function getResult(uint8 plan, uint256 deposit) public view returns (uint256 percent, uint256 profit, uint256 finish) {
		percent = getPercent(plan);
        profit = deposit.mul(percent).div(PERCENTS_DIVIDER).mul(plans[plan].time);
		finish = block.timestamp.add(plans[plan].time.mul(TIME_STEP));
	}

    function getUserDepositDividends(address userAddress, uint256 _depositID) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		if(user.deposits[_depositID].plan == 1){
			if (block.timestamp > user.deposits[_depositID].finish && user.deposits[_depositID].checkpoint < user.deposits[_depositID].finish) {
				totalAmount = totalAmount.add(user.deposits[_depositID].finalAmount.mul(user.deposits[_depositID].percent.mul(plans[user.deposits[_depositID].plan].time)).div(PERCENTS_DIVIDER));
				totalAmount = totalAmount.add(user.deposits[_depositID].initialAmount);
			}	
		}else{
			if (user.deposits[_depositID].checkpoint < user.deposits[_depositID].finish) {
				uint256 planPercent = user.deposits[_depositID].percent;
				if(user.deposits[_depositID].plan == 2){
					planPercent = planPercent.add(getExtraRate(userAddress, _depositID));
				}
				uint256 share = user.deposits[_depositID].finalAmount.mul(planPercent).div(PERCENTS_DIVIDER);
				uint256 from = user.deposits[_depositID].start > user.deposits[_depositID].checkpoint ? user.deposits[_depositID].start : user.deposits[_depositID].checkpoint;
				uint256 to = user.deposits[_depositID].finish < block.timestamp ? user.deposits[_depositID].finish : block.timestamp;
				if (from < to) {
					totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
				}
			}
		}
			
			
		return totalAmount;
	}

	function _getUserDividends(address userAddress) private returns (uint256, uint256) {
		User storage user = users[userAddress];
		uint256 totalAmount;
		uint256 fee;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			if(user.deposits[i].plan == 1){
				if (block.timestamp > user.deposits[i].finish && user.deposits[i].checkpoint < user.deposits[i].finish) {
					totalAmount = totalAmount.add(user.deposits[i].finalAmount.mul(user.deposits[i].percent.mul(plans[user.deposits[i].plan].time)).div(PERCENTS_DIVIDER));
					totalAmount = totalAmount.add(user.deposits[i].initialAmount);
					user.deposits[i].checkpoint = block.timestamp;
					if(user.deposits[i].withdrawn.add(totalAmount) > user.deposits[i].finalAmount.mul(2)){
						user.excessBalance = user.deposits[i].withdrawn.add(totalAmount).sub(user.deposits[i].finalAmount.mul(2));
						totalAmount = user.deposits[i].finalAmount.mul(2).sub(user.deposits[i].withdrawn);
					}
					user.deposits[i].withdrawn = user.deposits[i].withdrawn.add(totalAmount);
				}
			}else{
				if (user.deposits[i].checkpoint < user.deposits[i].finish) {
					if(user.deposits[i].plan == 2 && user.deposits[i].checkpoint.add(TIME_STEP) > block.timestamp){
						continue;
					}
					uint256 planPercent = user.deposits[i].percent;
					if(user.deposits[i].plan == 2){
						planPercent = planPercent.add(getExtraRate(userAddress, i));
					}
					uint256 share = user.deposits[i].finalAmount.mul(planPercent).div(PERCENTS_DIVIDER);
					uint256 from = user.deposits[i].start > user.deposits[i].checkpoint ? user.deposits[i].start : user.deposits[i].checkpoint;
					uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
					if (from < to) {
						totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
					}
					uint256 planDay = block.timestamp.sub(user.deposits[i].start).div(TIME_STEP);
					uint256 withdrawFee;
            		if(user.deposits[i].plan == 0){
                		withdrawFee = planDay < WITHDRAW_FEE1.length ? WITHDRAW_FEE1[planDay] : 0;
            		} else{
                		withdrawFee = planDay < WITHDRAW_FEE2.length ? WITHDRAW_FEE2[planDay] : 0;
            		}
					uint256 profitAmount = share.mul(to.sub(from)).div(TIME_STEP);
            		uint256 feeAmount = profitAmount.mul(withdrawFee).div(PERCENTS_DIVIDER);
					fee = fee.add(feeAmount);
					user.deposits[i].checkpoint = block.timestamp;
					if(user.deposits[i].withdrawn.add(totalAmount) > user.deposits[i].finalAmount.mul(2)){
						user.excessBalance = user.deposits[i].withdrawn.add(totalAmount).sub(user.deposits[i].finalAmount.mul(2));
						totalAmount = user.deposits[i].finalAmount.mul(2).sub(user.deposits[i].withdrawn);
					}
					user.deposits[i].withdrawn = user.deposits[i].withdrawn.add(totalAmount);
				}
			}
		}

		return (totalAmount, fee);
	}

	function _preGetUserDividends(address userAddress) public view returns (uint256 totalAmount, uint256 fee, uint256 excess) {
		User storage user = users[userAddress];

		for (uint256 i = 0; i < user.deposits.length; i++) {
			if(user.deposits[i].plan == 1){
				if (block.timestamp > user.deposits[i].finish && user.deposits[i].checkpoint < user.deposits[i].finish) {
					totalAmount = totalAmount.add(user.deposits[i].finalAmount.mul(user.deposits[i].percent.mul(plans[user.deposits[i].plan].time)).div(PERCENTS_DIVIDER));
					totalAmount = totalAmount.add(user.deposits[i].initialAmount);
					if(user.deposits[i].withdrawn.add(totalAmount) > user.deposits[i].finalAmount.mul(2)){
						excess = user.deposits[i].withdrawn.add(totalAmount).sub(user.deposits[i].finalAmount.mul(2));
						totalAmount = user.deposits[i].finalAmount.mul(2).sub(user.deposits[i].withdrawn);	
					}
				}
			}else{
				if (user.deposits[i].checkpoint < user.deposits[i].finish) {
					if(user.deposits[i].plan == 2 && user.deposits[i].checkpoint.add(TIME_STEP) > block.timestamp){
						continue;
					}
					uint256 planPercent = user.deposits[i].percent;
					if(user.deposits[i].plan == 2){
						planPercent = planPercent.add(getExtraRate(userAddress, i));
					}
					uint256 share = user.deposits[i].finalAmount.mul(planPercent).div(PERCENTS_DIVIDER);
					uint256 from = user.deposits[i].start > user.deposits[i].checkpoint ? user.deposits[i].start : user.deposits[i].checkpoint;
					uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
					if (from < to) {
						totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
					}
					uint256 planDay = block.timestamp.sub(user.deposits[i].start).div(TIME_STEP);
					uint256 withdrawFee;
            		if(user.deposits[i].plan == 0){
                		withdrawFee = planDay < WITHDRAW_FEE1.length ? WITHDRAW_FEE1[planDay] : 0;
            		} else{
                		withdrawFee = planDay < WITHDRAW_FEE2.length ? WITHDRAW_FEE2[planDay] : 0;
            		}
					uint256 profitAmount = share.mul(to.sub(from)).div(TIME_STEP);
            		uint256 feeAmount = profitAmount.mul(withdrawFee).div(PERCENTS_DIVIDER);
					fee = fee.add(feeAmount);
					if(user.deposits[i].withdrawn.add(totalAmount) > user.deposits[i].finalAmount.mul(2)){
						excess = user.deposits[i].withdrawn.add(totalAmount).sub(user.deposits[i].finalAmount.mul(2));
						totalAmount = user.deposits[i].finalAmount.mul(2).sub(user.deposits[i].withdrawn);
					}
				}
			}
		}

		return (totalAmount, fee, excess);
	}

	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];
		uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			if(user.deposits[i].plan == 1){
				if (block.timestamp > user.deposits[i].finish && user.deposits[i].checkpoint < user.deposits[i].finish) {
					totalAmount = totalAmount.add(user.deposits[i].finalAmount.mul(user.deposits[i].percent.mul(plans[user.deposits[i].plan].time)).div(PERCENTS_DIVIDER));
					totalAmount = totalAmount.add(user.deposits[i].initialAmount);
				}
			}else{
				if (user.deposits[i].checkpoint < user.deposits[i].finish) {
					uint256 planPercent = user.deposits[i].percent;
					if(user.deposits[i].plan == 2){
						planPercent = planPercent.add(getExtraRate(userAddress, i));
					}
					uint256 share = user.deposits[i].finalAmount.mul(planPercent).div(PERCENTS_DIVIDER);
					uint256 from = user.deposits[i].start > user.deposits[i].checkpoint ? user.deposits[i].start : user.deposits[i].checkpoint;
					uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
					if (from < to) {
						totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
					}
				}
			}
		}

		return totalAmount;
	}

    function getExtraRate(address _userAddress, uint256 _depositID) public view returns (uint256) {
        User storage user = users[_userAddress];
		if(user.deposits[_depositID].plan == 2){
			uint256 finish = user.deposits[_depositID].start.add(plans[user.deposits[_depositID].plan].time.mul(TIME_STEP));
			uint to = finish < block.timestamp ? finish : block.timestamp;
			uint256 from = user.deposits[_depositID].start > user.deposits[_depositID].checkpoint ? user.deposits[_depositID].start : user.deposits[_depositID].checkpoint;
			uint timeMultiplier = HOLD_STEP.mul(to.sub(from)).div(TIME_STEP);
			return timeMultiplier;
		}else{
			return 0;
		}
		
    }

	function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

	function getUserDownlineCount(address userAddress) public view returns(uint256, uint256, uint256) {
		return (users[userAddress].levels[0], users[userAddress].levels[1], users[userAddress].levels[2]);
	}

	function getUserReferralBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].bonus;
	}

	function getUserExcessBalance(address userAddress) public view returns(uint256) {
		return users[userAddress].excessBalance;
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

	function getUserInitialTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].initialAmount);
		}
	}

    function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].finalAmount);
		}
	}

	function getUserTotalWithdrawn(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].withdrawn);
		}
	}

	function GetUserInfo(address userAddress) public view returns(uint256 UserTotalWithdrawn, uint256 UserTotalDeposits, uint256 UserInitialTotalDeposits, uint256 UserAmountOfDeposits, uint256 UserExcessBalance, uint256 UserReferralWithdrawn, uint256 UserReferralTotalBonus) {
		UserTotalWithdrawn = getUserTotalWithdrawn(userAddress);
		UserTotalDeposits = getUserTotalDeposits(userAddress);
		UserInitialTotalDeposits = getUserInitialTotalDeposits(userAddress);
		UserAmountOfDeposits = getUserAmountOfDeposits(userAddress);
		UserExcessBalance = getUserExcessBalance(userAddress);
		UserReferralWithdrawn = getUserReferralWithdrawn(userAddress);
		UserReferralTotalBonus = getUserReferralTotalBonus(userAddress);
	}


	function returnMaximumDeposit() public view returns(uint256 amount) {
		if(prizeCycle < 4){
			amount = MAX_DEPOSIT[prizeCycle];
        }else{
            amount = activeDeposit.mul(ACTIVE_DEPOSIT_MAX).div(PERCENTS_DIVIDER);
			if(amount < 1 ether){
				amount = 1 ether;
			}
        }
	}

    function getContractInfo() public view returns(uint256, uint256, uint256, uint256, uint256, uint256) {
        return (totalStaked, totalRefBonus, userCount, activeDeposit, totalWithdrawn, getContractBalance());
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 initialAmount, uint256 finalAmount, uint256 profit, uint256 start, uint256 finish, uint256 withdrawn, uint256 available) {
	    User storage user = users[userAddress];

		plan = user.deposits[index].plan;
		percent = user.deposits[index].percent;
		initialAmount = user.deposits[index].initialAmount;
        finalAmount = user.deposits[index].finalAmount;
		profit = user.deposits[index].profit;
		start = user.deposits[index].start;
		finish = user.deposits[index].finish;
		withdrawn = user.deposits[index].withdrawn;
		available = getUserDepositDividends(userAddress, index);
	}

	function getUserExtraDepositInfo(address userAddress, uint256 index) public view returns(bool isCompound, uint256 estimateProfit, uint256 profitPerPeriod, uint256 extraRewards) {
	    User storage user = users[userAddress];

		isCompound = user.deposits[index].isCompound;
		estimateProfit = user.deposits[index].finalAmount.mul(user.deposits[index].percent).div(PERCENTS_DIVIDER).mul(plans[user.deposits[index].plan].time);
		profitPerPeriod = user.deposits[index].percent.mul(plans[user.deposits[index].plan].time);
		extraRewards = user.deposits[index].finalAmount.sub(user.deposits[index].initialAmount).div(user.deposits[index].initialAmount).mul(PERCENTS_DIVIDER);
	}

	function getUserExtraDepositInfo2(address userAddress, uint256 index) public view
	 returns(uint256 extraRate, bool first1000Extra5, bool topDepositors5, bool topLeaders10, bool randomNewDepositors5, uint256 nextTime) {
	    User storage user = users[userAddress];

		extraRate = getExtraRate(userAddress, index);
		first1000Extra5 = user.deposits[index].first1000Extra5;
		topDepositors5 = user.deposits[index].topDepositors5;
		topLeaders10 = user.deposits[index].topLeaders10;
		randomNewDepositors5 = user.deposits[index].randomNewDepositors5;
		nextTime = user.deposits[index].checkpoint.add(TIME_STEP);
	}

    function isBlackListed(address user) public view returns (bool) {
        return _blacklist[user];
    }

    function blacklistUpdate(address user, bool value) public {
        require(msg.sender == commissionWallet, "Only owner is allowed to modify blacklist.");
        _blacklist[user] = value;
    }

    function adminUpdateReferrer(address _participant, address _referrer) public {
        require(msg.sender == commissionWallet, "Only owner is allowed to modify referrer.");
        User storage user = users[_participant];
        user.referrer = _referrer;
    }

	function resetStartUnix() public { //testnet
        startUNIX = block.timestamp;
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
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