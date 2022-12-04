// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.5;

import "./Btree.sol";

contract POTIONMINER {

	using Btree for Btree.Tree;
	modifier NonReentrant() { require(!LOCKED, 'NonReentrant'); LOCKED = true; _; LOCKED = false; }
	modifier AdminOnly() { require( msg.sender == PROJECT, 'Admin only' ); _; }
	modifier ValidUser() { require( sys_isUser(msg.sender), 'Invalid user' ); _; }

	struct TUser {
		TPlan[]		plans;
		uint		potions;
		uint		extraMult;
		uint		ethRewards;
		address		referrer;
		uint[3]		refCount;
		uint		refRewards;
		uint		sysIngNum;
		uint		sysIngTst;
		uint		ingLvlRewarded;
		TUserLot[]	lots;
		uint		lotsCount;
	}

	struct TPlan {
		uint		mult;
		uint		workers;
		uint		workersInitial;
		uint		startTime;
		uint		checkpoint;
		uint		takenProfitEth;
		uint		finalProfitEth;
	}

	struct TUserLot {
		uint		price;
		uint		gidx;
		uint		created;
	}

	struct TPlayer {
		address		addr;
		string		data;
	}

	struct TLottery {
		bool		isFinished;
		uint		extraMult;
		uint		ethReward;
		TPlayer[]	players;
		TPlayer[]	winners;
		uint		playersCnt;
	}

	struct TAuctionLot {
		address		owner;
		uint		price;
		uint		uidx;
		uint		created;
	}

	struct THistoryDeposit {
		address		user;
		uint		mult;
		uint		amount;
		uint		timestamp;
	}

	struct THistoryAuction {
		address		seller;
		address		buyer;
		uint		price;
		uint		timestamp;
	}

	bool private							LOCKED;
	uint private							LAUNCHED;
	address private							PROJECT;
	uint private							DIVIDER =							1000;
	uint private							MINIMAL_DEPOSIT_AMOUNT =			10000000000000000;
	uint private							POTION_BASE =						1 ether;
	uint private							POTION_RATE =						1 ether;
	uint private							POTION_ROOF =						1250000000000000000;
	uint private							MODEL_POINT_0 =						333;
	uint private							MODEL_POINT_1 =						4095000000;
	uint private							MODEL_POINT_2 =						934;
	uint[3] private							PER_REFERRAL =						[70, 30, 20];
	uint private							DEFAULT_PLAN_MULT =					2;
	uint private							BURN_EXTRAMULT_NUMBER =				3;
	uint private							DEFAULT_PLAN_LENGTH =				30 days;
	uint private							DEFAULT_PLAN_UPGRADE_MULTIPLIER =	1050;
	uint private							INGREDIENT_COOLDOWN_TIME =			2 days;
	uint private							INGREDIENT_REWARD_TIMEOUT =			1 days;
	uint private							PER_DEPOSIT_AVG_REWARD_BORDER =		300;
	uint[6] private							PER_INGR_DEBUFF =					[0, 300, 400, 500, 600, 800];
	uint private							FEE_PROJECT_DEPOSIT_ETH =			60;
	uint private							FEE_PROJECT_WITHDRAW_ETH =			60;
	mapping (address => TUser) private		USERS;

	uint private							LOTTERY_LAST_CREATED;
	uint private							LOTTERY_ROUND = 0;
	mapping(uint => TLottery) private		LOTTERY;
	uint private							LOTTERY_MAX_REWARD =				10 ether;
	uint private							LOTTERY_MAX_EXTRAMULT =				1;
	uint private							LOTTERY_COOLDOWN_TIME =				3 days;

	Btree.Tree								TREE;
	mapping(uint => TAuctionLot[]) private	LOTS;
	mapping(uint => uint) private			LOTScount;

	uint private							TRAILING_TIMESTEP =	1 days;
	mapping (uint => int) private			TRAILING_IO;
	mapping (uint => uint) private			TRAILING_DEPOSIT;

	uint private							CIRCULATING_POTIONS;
	uint private							CIRCULATING_EARNINGS;
	uint private							CIRCULATING_WORKERS;
	uint private							CIRCULATING_EXTRAMULT;
	uint private							CIRCULATING_LOTS;

	uint private							HT_USERS_COUNT;
	uint private							HT_TOTAL_DEPOSIT_AMOUNT;
	uint private							HT_TOTAL_DEPOSIT_COUNT;
	uint private							HT_TOTAL_EARNING_PAYOUT;
	uint private							HT_TOTAL_REFERRAL_REWARDS;
	THistoryDeposit[] private				HT_DEPOSIT_HISTORY;
	THistoryAuction[] private				HT_AUCTION_HISTORY;

	event referralAdopted(address referrer, address user);
	event referralReward(address user, uint potions);
	event ingredientsIdleRewardApplied(uint sysIngNum);
	event ingredientsUpgradeOnDeposit();
	event ingredientsUpgradeOnRecycle();
	event planProfitsCalculated(uint ingredients, uint earnedEth);
	event planUpgraded(uint workers, uint addWorkers);
	event planDrained();
	event lotAdded(address user, uint price);
	event lotBought(address buyer, address seller, uint price);
	event lotDeleted(address user, uint uidx);

	constructor(address _project) {
		PROJECT = _project;
		sys_lottery_end();
	}

	function usr_deposit(address _referrer) public payable NonReentrant {
		require(msg.value >= MINIMAL_DEPOSIT_AMOUNT, 'Deposit amount is too low');
		if(LAUNCHED == 0) {
			require( msg.sender == PROJECT, 'The project is not launched' );
			LAUNCHED = 1670094601;
		}
		if(!sys_isUser(msg.sender)) {
			HT_USERS_COUNT++;
		}
		TUser storage user = USERS[msg.sender];
		sys_setReferrer(msg.sender, _referrer);
		sys_applyUserIngredientsIdleReward(user);
		uint extraMult = ( BURN_EXTRAMULT_NUMBER > 0 ) ? min( user.extraMult, BURN_EXTRAMULT_NUMBER ) : user.extraMult;
		TPlan memory plan = sys_makePlan(extraMult, msg.value);
		sys_createPlan( msg.sender, plan, extraMult );
		sys_upgradeIngedientsOnDeposit( msg.sender, msg.value );
		sys_logTrailingDeposit(msg.value);
		uint fee = msg.value * FEE_PROJECT_DEPOSIT_ETH / DIVIDER;
		payable(PROJECT).transfer(fee);
		sys_logIncomeOutcome(msg.value - fee, true);
		HT_DEPOSIT_HISTORY.push( THistoryDeposit(msg.sender,plan.mult,msg.value,plan.startTime) );
		HT_TOTAL_DEPOSIT_AMOUNT += msg.value;
		HT_TOTAL_DEPOSIT_COUNT++;
		sys_rate();
	}

	function usr_withdraw() public ValidUser NonReentrant {
		TUser storage user = USERS[msg.sender];
		uint ingredients = sys_applyUserIngredientsIdleReward(user);
		uint earnedEth;
		uint earnedPtn;
		for(uint i=0; i<user.plans.length; i++) {
			TPlan storage plan = user.plans[i];
			(uint eth, uint ptn)  = sys_calcPlanProfits( plan, ingredients, true );
			plan.takenProfitEth += eth;
			plan.checkpoint = block.timestamp;
			earnedEth += eth;
			earnedPtn += ptn;
			if(sys_planDrained(plan)) {
				sys_burnWorkers(plan);
				emit planDrained();
			}
		}
		emit planProfitsCalculated(ingredients, earnedEth);
		sys_burnEarnings( earnedEth );
		earnedEth += sys_ptnToEth( user.potions );
		earnedPtn += user.potions;
		sys_burnPotions(msg.sender, user.potions);
		sys_referralRewards( user.referrer, earnedPtn );
		user.sysIngNum = PER_INGR_DEBUFF.length-1;
		user.sysIngTst = block.timestamp;
		payable(msg.sender).transfer( earnedEth );
		user.ethRewards += earnedEth;
		uint fee = earnedEth * FEE_PROJECT_WITHDRAW_ETH / DIVIDER;
		payable(PROJECT).transfer(fee);
		sys_logIncomeOutcome(earnedEth + fee, false);
		HT_TOTAL_EARNING_PAYOUT += earnedEth;
		sys_rate();
	}

	function usr_recycle() public ValidUser NonReentrant {
		TUser storage user = USERS[msg.sender];
		uint ingredients = sys_applyUserIngredientsIdleReward(user);
		uint earnedPtn;
		uint totalWorkers;
		for(uint i=0; i<user.plans.length; i++) {
			TPlan storage plan = user.plans[i];
			(uint eth,uint ptn)  = sys_calcPlanProfits( plan, ingredients, false );
			plan.finalProfitEth += sys_mintEarnings(eth);
			plan.checkpoint = block.timestamp;
			earnedPtn += ptn;
			totalWorkers += plan.workers;
		}
		earnedPtn += user.potions;
		sys_burnPotions(msg.sender, user.potions);
		sys_referralRewards( user.referrer, earnedPtn );
		sys_upgradeIngedientsOnRecycle(msg.sender);
		for(uint i=0; i<user.plans.length; i++) {
			if(!sys_planDrained(user.plans[i])) {
				uint addWorkers = sys_mintWorkers( sys_ptnToWrk( ( earnedPtn * user.plans[i].workers * DEFAULT_PLAN_UPGRADE_MULTIPLIER ) / ( DIVIDER * totalWorkers  ) ) );
				emit planUpgraded(user.plans[i].workers, addWorkers);
				user.plans[i].workers += addWorkers;
			}
		}
		sys_rate();
	}

	function usr_auction_add(uint _price) public ValidUser NonReentrant {
		TUser storage user = USERS[msg.sender];
		require( user.extraMult > 0, 'You have no extra mult' );
		require( _price > 0 , 'Price is too low' ); 
		user.extraMult -= 1;
		sys_addLot( _price, msg.sender );
		emit lotAdded(msg.sender, _price);
	}

	function usr_auction_del(uint _uidx) public ValidUser NonReentrant {
		sys_delLot( msg.sender, _uidx, true );
		emit lotDeleted(msg.sender, _uidx);
	}

	function usr_auction_buy(uint _price) public payable ValidUser NonReentrant {
		require( msg.value >= _price, 'Insufficient amount' );
		require( LOTScount[_price] > 0, 'No lots with such price' );
		payable(LOTS[_price][0].owner).transfer( _price );
		USERS[msg.sender].extraMult += 1;
		HT_AUCTION_HISTORY.push( THistoryAuction( LOTS[_price][0].owner, msg.sender, _price, block.timestamp ) );
		emit lotBought(msg.sender, LOTS[_price][0].owner, _price);
		sys_delLot( LOTS[_price][0].owner, LOTS[_price][0].uidx, false  );
	}

	function adm_lottery_end() public AdminOnly {
		sys_lottery_end();
	}

	function adm_lottery_new(uint _ethReward, uint _extraMult) public AdminOnly {
		require( block.timestamp - LOTTERY_LAST_CREATED >= LOTTERY_COOLDOWN_TIME, 'Lottery cooldown' );
		require( (_ethReward>0) || (_extraMult>0) , 'Either Reward or Extramult should be specified' );
		require( (_ethReward <= LOTTERY_MAX_REWARD) && (_extraMult <= LOTTERY_MAX_EXTRAMULT) , 'Reward or Extramult is to high' );
		LOTTERY_LAST_CREATED = block.timestamp;
		LOTTERY[LOTTERY_ROUND].isFinished = true;
		LOTTERY_ROUND++;
		TLottery storage lottery = LOTTERY[LOTTERY_ROUND];
		lottery.ethReward = _ethReward;
		lottery.extraMult = _extraMult;
	}

	function adm_lottery_add(address _user, string calldata _data) public AdminOnly {
		TLottery storage lottery = LOTTERY[LOTTERY_ROUND];
		require( (LOTTERY_ROUND>0) && (!lottery.isFinished), 'Lottery is finished' );
		require( sys_isUser(_user), 'Invalid user' );
		TPlayer memory newPlayer = TPlayer(_user,_data);
		if(lottery.playersCnt >= lottery.players.length) {
			lottery.players.push( newPlayer );
		} else {
			lottery.players[lottery.playersCnt] = newPlayer;
		}
		lottery.playersCnt++;
	}

	function adm_lottery_del(address _user, bool _useIdx, uint _idx) public AdminOnly {
		TLottery storage lottery = LOTTERY[LOTTERY_ROUND];
		uint idx;
		if(!_useIdx) {
			bool found;
			for(uint i=0;i<lottery.playersCnt;i++) {
				if(lottery.players[i].addr == _user) {
					found = true;
					idx = i;
					break;
				}
			}
			require(found, 'User not found' );
		}
		else {
			idx = _idx;
		}
		if(idx != lottery.playersCnt-1) {
			lottery.players[idx] = lottery.players[lottery.playersCnt-1];
		}
		lottery.playersCnt--;
	}

	function adm_lottery_run() public AdminOnly {
		TLottery storage lottery = LOTTERY[LOTTERY_ROUND];
		require( (LOTTERY_ROUND>0) && (!lottery.isFinished), 'Lottery is finished' );
		uint idx = sys_randomBetween(0,lottery.playersCnt-1);
		TPlayer storage winner = lottery.players[idx];
		lottery.winners.push(winner);
		if(lottery.extraMult > 0) {
			sys_mintExtramult( USERS[winner.addr], lottery.extraMult );
		}
		if(lottery.ethReward > 0) {
			payable(winner.addr).transfer(lottery.ethReward);
		}
		adm_lottery_del(winner.addr, true, idx);
	}

	struct TAuctionData {
		TAuctionLot[20] lots;
		uint			count;
		uint			total;
	}

	struct TDATA_OBS {
		uint				timestamp;
		uint				balance;
		uint				MINIMAL_DEPOSIT_AMOUNT;
		uint				INGREDIENT_COOLDOWN_TIME;
		uint				INGREDIENT_REWARD_TIMEOUT;
		uint				POTION_RATE;
		uint				DEPOSIT_AVG_BORDER;
		uint				HT_USERS_COUNT;
		THistoryDeposit[50]	HT_DEPOSIT_HISTORY;
		THistoryAuction[50]	HT_AUCTION_HISTORY;
		uint				HT_TOTAL_DEPOSIT_AMOUNT;
		uint				HT_TOTAL_DEPOSIT_COUNT;
		uint				HT_TOTAL_EARNING_PAYOUT;
		uint				HT_TOTAL_REFERRAL_REWARDS;
	}

	function pub_dashboard_OBS() public view returns(TDATA_OBS memory o_MAIN, TAuctionData memory o_AUCTION, TLottery memory o_LOTTERY) {
		THistoryDeposit[50] memory historyDepositTail;
		if(HT_DEPOSIT_HISTORY.length > 0) {
			uint dlast = HT_DEPOSIT_HISTORY.length-1;
			for(uint i=0; i<50; i++) {
				if(dlast<i) break;
				historyDepositTail[i] = HT_DEPOSIT_HISTORY[dlast-i];
			}
		}
		THistoryAuction[50] memory historyAuctionTail;
		if(HT_AUCTION_HISTORY.length > 0) {
			uint alast = HT_AUCTION_HISTORY.length-1;
			for(uint i=0; i<50; i++) {
				if(alast<i) break;
				historyAuctionTail[i] = HT_AUCTION_HISTORY[alast-i];
			}
		}
		o_MAIN = TDATA_OBS(
			block.timestamp,
			address(this).balance,
			MINIMAL_DEPOSIT_AMOUNT,
			INGREDIENT_COOLDOWN_TIME,
			INGREDIENT_REWARD_TIMEOUT,
			POTION_RATE,
			sys_getDepositAvg()*PER_DEPOSIT_AVG_REWARD_BORDER/DIVIDER,
			HT_USERS_COUNT,
			historyDepositTail,
			historyAuctionTail,
			HT_TOTAL_DEPOSIT_AMOUNT,
			HT_TOTAL_DEPOSIT_COUNT,
			HT_TOTAL_EARNING_PAYOUT,
			HT_TOTAL_REFERRAL_REWARDS
		);
		uint price = TREE.first();
		while( (price>0) && (o_AUCTION.count<20) ) {
			o_AUCTION.lots[o_AUCTION.count] = LOTS[price][0];
			o_AUCTION.count++;
			price = TREE.next(price);
		}
		o_AUCTION.total = CIRCULATING_LOTS;
		return ( o_MAIN, o_AUCTION, LOTTERY[LOTTERY_ROUND] );
	}

	struct TPlanProfits {
		uint ethLeftProfits;
		uint ethF;
		uint ptnF;
		uint ethD;
		uint ptnD;
	}

	struct TUserAuction {
		TUserLot[] lots;
		uint count;
	}

	struct TDATA_USR {
		uint			timestamp;
		bool			isUser;
		uint			potions;
		uint			potionsEthValue;
		uint			extraMult;
		uint			ethRewards;
		address			referrer;
		uint[3]			refCount;
		uint			refRewards;
		uint			sysIngNum;
		uint			sysIngTst;
		uint			ingLvlRewarded;
		uint			ingredients;
		uint			planCount;
		uint			planWorkers;
		TPlanProfits	planProfits;
	}

	function pub_dashboard_USR() public view returns(TDATA_USR memory o_MAIN, TUserAuction memory o_AUCTION) {
		TUser storage user = USERS[msg.sender];
		TPlanProfits memory planProfits;
		uint ingredients = sys_userIngredients(msg.sender);
		uint pcnt;
		uint wcnt;
		for(uint i=0;i<user.plans.length;i++) {
			if(sys_planDrained(user.plans[i])) { continue; }
			pcnt++;
			wcnt += user.plans[i].workers;
			planProfits.ethLeftProfits += (user.plans[i].finalProfitEth - user.plans[i].takenProfitEth);
			(uint eF, uint pF) = sys_calcPlanProfits( user.plans[i], 0, false );
			(uint eD, uint pD) = sys_calcPlanProfits( user.plans[i], ingredients, true );
			planProfits.ethF += eF;
			planProfits.ptnF += pF;
			planProfits.ethD += eD;
			planProfits.ptnD += pD;
		}
		o_MAIN = TDATA_USR(
			block.timestamp,
			sys_isUser(msg.sender),
			user.potions,
			sys_ptnToEth(user.potions),
			user.extraMult,
			user.ethRewards,
			user.referrer,
			user.refCount,
			user.refRewards,
			user.sysIngNum,
			user.sysIngTst,
			user.ingLvlRewarded,
			ingredients,
			pcnt,
			wcnt,
			planProfits
		);
		o_AUCTION.lots = user.lots;
		o_AUCTION.count = user.lotsCount;
	}
	struct TActivePlan {
		uint			mult;
		uint			workers;
		uint			workersInitial;
		uint			startTime;
		uint			checkpoint;
		uint			finalProfitEth;
		uint			takenProfitEth;
		TPlanProfits	planProfits;
	}

	function pub_dashboard_PLANS() public view returns(uint o_timestamp, uint o_count, TActivePlan[] memory o_plans) {
		TUser storage user = USERS[msg.sender];
		for(uint i=0; i<user.plans.length; i++) {
			if(!sys_planDrained(user.plans[i])) { o_count++; }
		}
		TActivePlan[] memory activePlans = new TActivePlan[](o_count);
		uint cnt;
		uint ingredients = sys_userIngredients(msg.sender);
		for(uint i=0; i<user.plans.length; i++) {
			TPlan storage p = user.plans[i];
			if(sys_planDrained(p)) { continue; }
			TPlanProfits memory planProfits;
			planProfits.ethLeftProfits = (p.finalProfitEth - p.takenProfitEth);
			(planProfits.ethF, planProfits.ptnF) = sys_calcPlanProfits( p, 0, false );
			(planProfits.ethD, planProfits.ptnD) = sys_calcPlanProfits( p, ingredients, true );
			activePlans[cnt] = TActivePlan( p.mult, p.workers, p.workersInitial, p.startTime, p.checkpoint, p.finalProfitEth, p.takenProfitEth, planProfits );
			cnt++;
		}
		return (block.timestamp, o_count, activePlans);
	}

	function pub_getUserAvailable(address _user) public view returns(uint o_eth) {
		TUser storage user = USERS[msg.sender];
		uint ingredients = sys_userIngredients(_user);
		for(uint i=0;i<user.plans.length;i++) {
			if(sys_planDrained(user.plans[i])) { continue; }
			(uint eth,) = sys_calcPlanProfits( user.plans[i], ingredients, true );
			o_eth += eth;
		}
		o_eth += sys_ptnToEth(user.potions);
	}

	struct TStatsData {
		TUser			USERS;
		TLottery		LOTTERY;
		TAuctionLot[]	LOTS;
		uint			LOTScount;
		int				TRAILING_IO;
		uint			TRAILING_DEPOSIT;
		uint			CIRCULATING_POTIONS;
		uint			CIRCULATING_EARNINGS;
		uint			CIRCULATING_WORKERS;
		uint			CIRCULATING_EXTRAMULT;
		uint			CIRCULATING_LOTS;
	}

	function pub_dashboard_STATS(address _user, uint _lotteryRound, uint _lotsPrice, uint _trailingIdx) public view returns(uint o_timestamp, TStatsData memory o_MAIN) {
		o_MAIN = TStatsData(
			USERS[_user],
			LOTTERY[_lotteryRound],
			LOTS[_lotsPrice],
			LOTScount[_lotsPrice],
			TRAILING_IO[_trailingIdx],
			TRAILING_DEPOSIT[_trailingIdx],
			CIRCULATING_POTIONS,
			CIRCULATING_EARNINGS,
			CIRCULATING_WORKERS,
			CIRCULATING_EXTRAMULT,
			CIRCULATING_LOTS
		);
		return (block.timestamp, o_MAIN);
	}

	function min(uint a, uint b) internal pure returns (uint) {
		return ( a < b ) ? a : b;
	}

	function max(uint a, uint b) internal pure returns (uint) {
		return ( a < b ) ? b : a;
	}

	function sys_randomBetween(uint _min, uint _max) internal view returns (uint o_rnd) {
		return (uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,address(this).balance,POTION_RATE))) % (_max+1)) + _min;
	}

	function sys_ethToPtn(uint _ethAmt) internal view returns (uint o_ptnAmt) {
		return (_ethAmt * POTION_BASE) / POTION_RATE;
	}

	function sys_ptnToEth(uint _ptnAmt) internal view returns (uint o_ethAmt) {
		return (_ptnAmt * POTION_RATE) / POTION_BASE;
	}

	function sys_ptnToWrk(uint _ptnAmt) internal view returns (uint o_wrkAmt) {
		return _ptnAmt / DEFAULT_PLAN_LENGTH;
	}

	function sys_mintPotions(address _user, uint _ptnAmt) internal {
		USERS[_user].potions += _ptnAmt;
		CIRCULATING_POTIONS += _ptnAmt;
	}

	function sys_burnPotions(address _user, uint _ptnAmt) internal {
		USERS[_user].potions -= _ptnAmt;
		CIRCULATING_POTIONS -= _ptnAmt;
	}

	function sys_mintWorkers(uint _wrkAmt) internal returns (uint) {
		CIRCULATING_WORKERS += _wrkAmt;
		return _wrkAmt;
	}

	function sys_burnWorkers(TPlan storage _plan) internal {
 
		if(_plan.workers>0) {
			CIRCULATING_WORKERS -= _plan.workers;
			_plan.workers = 0;
		}
	}

	function sys_mintEarnings(uint _ethAmt) internal returns (uint) {
		CIRCULATING_EARNINGS += _ethAmt;
		return _ethAmt;
	}

	function sys_burnEarnings(uint _ethAmt) internal {
		CIRCULATING_EARNINGS -= _ethAmt;
	}

	function sys_mintExtramult(TUser storage _user, uint _num) internal {
		CIRCULATING_EXTRAMULT += _num;
		_user.extraMult += _num;
	}

	function sys_burnExtramult(TUser storage _user, uint _num) internal {
		CIRCULATING_EXTRAMULT -= _num;
		_user.extraMult -= _num;
	}

	function sys_logIncomeOutcome(uint _ethAmt, bool _positive) internal {
		uint slotIdx = block.timestamp / TRAILING_TIMESTEP;
		if(_positive)	{ TRAILING_IO[slotIdx] += int(_ethAmt); }
				else	{ TRAILING_IO[slotIdx] -= int(_ethAmt); }
	}

	function sys_logTrailingDeposit(uint _ethAmt) internal {
		uint slotIdx = block.timestamp / TRAILING_TIMESTEP;
		if ( TRAILING_DEPOSIT[slotIdx] < _ethAmt ) {
			TRAILING_DEPOSIT[slotIdx] = _ethAmt;
		}
	}

	function sys_getDepositAvg() internal view returns (uint o_rangeAvg) {
		uint slotIdx = block.timestamp / TRAILING_TIMESTEP;
		uint totAmt;
		uint dayCnt;
		for( uint i=0; i<7; i++) {
			if(TRAILING_DEPOSIT[slotIdx-i] == 0) continue;
			totAmt += TRAILING_DEPOSIT[slotIdx-i];
			dayCnt++;
		}
		return ( dayCnt > 0 ) ? ( totAmt / dayCnt ) : 0; 
	}

	function sys_rate() internal {
		if(CIRCULATING_WORKERS==0) {
			return;
		}
		uint span = ( (address(this).balance * DIVIDER) / CIRCULATING_WORKERS ) / DEFAULT_PLAN_LENGTH; 
		uint mult = (span <= MODEL_POINT_0) ? ( span**5 ) / MODEL_POINT_1 : (span/5 + MODEL_POINT_2);
		POTION_RATE = min( POTION_ROOF, max(1, (POTION_BASE * mult) / DIVIDER )  );
	}

	function sys_isUser(address _user) internal view returns (bool) {
		return USERS[_user].plans.length > 0;
	}

	function sys_userIngredients(address _user) internal view returns (uint o_ingredients) {
		TUser storage user = USERS[_user];
		uint idleReward = (block.timestamp - user.sysIngTst) / INGREDIENT_COOLDOWN_TIME;
		return ( user.sysIngNum > idleReward ) ? ( user.sysIngNum - idleReward ) : 0 ;
	}

	function sys_setReferrer(address _user, address _referrer) internal returns (address o_referrer) {
		if (USERS[_user].referrer != address(0)) return USERS[_user].referrer;
		if (!sys_isUser(_referrer)) return address(0);
		if (_user == _referrer) return address(0);
		USERS[_user].referrer = _referrer;
		emit referralAdopted(_referrer, _user);
		address upline = _referrer;
		for (uint i=0; i < PER_REFERRAL.length; i++) {
			if(upline==address(0)) break;
			USERS[upline].refCount[i]++;
			upline = USERS[upline].referrer;
		}
		return _referrer; 
	}

	function sys_referralRewards(address _referrer, uint _fullPtnAmt) internal {
		uint totalAmt;
		address upline = _referrer;
		for (uint i=0; i < PER_REFERRAL.length; i++) {
			if (upline == address(0)) break;
			uint potionAmt = _fullPtnAmt * PER_REFERRAL[i] / DIVIDER;
			sys_mintPotions(upline, potionAmt);
			USERS[upline].refRewards += potionAmt;
			emit referralReward(upline, potionAmt);
			upline = USERS[upline].referrer;
			totalAmt += potionAmt;
		}
		HT_TOTAL_REFERRAL_REWARDS += totalAmt;
	}

	function sys_applyUserIngredientsIdleReward(TUser storage user) internal returns (uint o_ingredients) {
		if(user.sysIngTst == 0) {
			user.sysIngNum = PER_INGR_DEBUFF.length-1;
			user.sysIngTst = block.timestamp;
			return user.sysIngNum;
		}
		uint idleReward = (block.timestamp - user.sysIngTst) / INGREDIENT_COOLDOWN_TIME;
		if(idleReward == 0) {
			return user.sysIngNum;
		}
		user.sysIngNum = ( user.sysIngNum > idleReward ) ? ( user.sysIngNum - idleReward ) : 0 ;
		user.sysIngTst += idleReward * INGREDIENT_COOLDOWN_TIME; 
		emit ingredientsIdleRewardApplied(user.sysIngNum);
		return user.sysIngNum;
	}

	function sys_upgradeIngedientsOnDeposit(address _user, uint _ethAmt) internal {
		TUser storage user = USERS[_user];
		if( _ethAmt >= sys_getDepositAvg()*PER_DEPOSIT_AVG_REWARD_BORDER/DIVIDER ) {
			if(user.sysIngNum > 0) {
				user.sysIngNum=0;
			}
			user.sysIngTst = block.timestamp;
			emit ingredientsUpgradeOnDeposit();
		}
	}

	function sys_upgradeIngedientsOnRecycle(address _user) internal {
		TUser storage user = USERS[_user];
		if( (block.timestamp - user.ingLvlRewarded >= INGREDIENT_REWARD_TIMEOUT) && (user.sysIngNum > 0) ) {
			user.ingLvlRewarded = block.timestamp;
			user.sysIngNum--;
			user.sysIngTst = block.timestamp;
			emit ingredientsUpgradeOnRecycle();
		}
	}

	function sys_planDrained(TPlan storage _plan) internal view returns (bool) {
		return (_plan.takenProfitEth >= _plan.finalProfitEth);
	}

	function sys_makePlan(uint _extraMult, uint _ethAmt) internal returns (TPlan memory o_plan) {
		uint mult = DEFAULT_PLAN_MULT + _extraMult;
		uint finalProfitEth = sys_mintEarnings( _ethAmt * mult );
		uint workers = sys_mintWorkers( finalProfitEth / DEFAULT_PLAN_LENGTH );
		return TPlan( mult , workers , workers, block.timestamp, block.timestamp, 0, finalProfitEth );
	}

	function sys_createPlan(address _user, TPlan memory _plan, uint _burnExtraMult) internal {
		TUser storage user = USERS[_user];
		bool found;
		for(uint i=0; i<user.plans.length; i++) {
			if(!sys_planDrained(user.plans[i])) continue;
			user.plans[i] = _plan;
			found = true;
			break;
		}
		if(!found) {
			user.plans.push( _plan );
		}
		sys_burnExtramult(user, _burnExtraMult);
	}

	function sys_calcPlanProfits(TPlan storage _plan, uint _ingrLevel, bool _debuff) internal view returns (uint o_eth, uint o_ptn) {
		if(sys_planDrained(_plan)) return (0,0);
		uint leftProfitEth = _plan.finalProfitEth - _plan.takenProfitEth;
		uint minedPotions = (block.timestamp - _plan.checkpoint) * _plan.workers;
		if(_debuff) {
			minedPotions -= minedPotions * PER_INGR_DEBUFF[_ingrLevel] / DIVIDER;
		}
		o_eth = min( leftProfitEth , sys_ptnToEth(minedPotions) );
		o_ptn = sys_ethToPtn(o_eth);
	}

	function sys_addLot(uint _price, address _owner) internal {
		TUser storage owner = USERS[_owner];
		if(!TREE.exists(_price)) {
			TREE.insert(_price);
		}
		uint new_gidx;
		TAuctionLot memory newALot = TAuctionLot( _owner, _price, 0, block.timestamp );
		if(LOTScount[_price] >= LOTS[_price].length) {
			new_gidx = LOTS[_price].length;
			LOTS[_price].push( newALot );
		} else {
			new_gidx = LOTScount[_price];
			LOTS[_price][new_gidx] = newALot;
		}
		LOTScount[_price]++;
		uint new_uidx;
		TUserLot memory newULot = TUserLot( _price, new_gidx, block.timestamp );
		if(owner.lotsCount >= owner.lots.length) {
			new_uidx = owner.lots.length;
			owner.lots.push( newULot );
		} else {
			new_uidx = owner.lotsCount;
			owner.lots[new_uidx] = newULot;
		}
		owner.lotsCount++;
		LOTS[_price][new_gidx].uidx = new_uidx;
		CIRCULATING_LOTS++;
	}

	function sys_delLot(address _owner, uint _uidx, bool _ownerReturnMult) internal {
		require( _uidx < USERS[ _owner ].lotsCount, 'User lot index does not exist');
		TUser storage downer = USERS[ _owner ];
		TUserLot storage dulot = downer.lots[_uidx]; 
		uint price = dulot.price;
		uint tgidx = LOTScount[price]-1;
		if(dulot.gidx != tgidx) {
			TUser storage towner = USERS[ LOTS[price][tgidx].owner ];
			TUserLot storage tulot = towner.lots[ LOTS[price][tgidx].uidx ];
			tulot.gidx = dulot.gidx;
			LOTS[price][dulot.gidx] = LOTS[price][tgidx];
		}
		LOTScount[price]--;
		if(LOTScount[price]==0) {
			TREE.remove(price);
		}
		if(_uidx != downer.lotsCount-1) {
			TUserLot storage tlot = downer.lots[downer.lotsCount-1];
			LOTS[tlot.price][tlot.gidx].uidx = _uidx;
			downer.lots[_uidx] = tlot;
		}
		downer.lotsCount--;
		if(_ownerReturnMult) {
			downer.extraMult += 1;
		}
		CIRCULATING_LOTS--;
	}

	function sys_lottery_end() internal {
		LOTTERY[LOTTERY_ROUND].isFinished = true;
	}
}