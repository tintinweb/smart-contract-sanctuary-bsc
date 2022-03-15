/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

// DuckStaking.com BNB Version
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.5;



interface ISecuredContract {
	function initiate() external;
	function getBalance() external view returns(uint);
	function getMainContract() external view returns(address);
}

contract ISECURED {

	//accept funds from MainContract
	receive() external payable {}
	address payable public MAINCONTRACT;

	constructor() {
		MAINCONTRACT = payable(msg.sender);
	}

	function initiate() public {
		require(msg.sender == MAINCONTRACT, "Forbidden");
		uint balance = address(this).balance;
		if(balance==0) return;
		MAINCONTRACT.transfer(balance);
	}

	function getBalance() public view returns(uint) {
		return address(this).balance;
	}

	function getMainContract() public view returns(address) {
		return MAINCONTRACT;
	}

}



contract DUCKSTAKE {

	//accept funds from ISecured
	receive() external payable {}

	bool public						LAUNCHED;
	address payable public			WALLET_PROJECT;
	address payable public			WALLET_DEV;
	address payable public			WALLET_MARKETING;
	address payable public			WALLET_SUBMARKETING;
	uint constant public			PERCENTS_DIVIDER				= 1000;
	uint constant public			TIME_STEP						= 1 days;
	uint256 public					INVEST_MIN_AMOUNT				= 0.1 ether;			// 0.1 BNB
	uint[] public					REFERRAL_PERCENTS				= [100, 0, 0, 0, 0];	// 10%
	uint256 public					PROJECT_FEE						= 50;					// project fee 5% of deposit
	uint256 public					DEV_FEE							= 50;					// dev fee 5% of deposit
	uint256 public					MARKETING_FEE					= 40;					// marketing fee 4% of deposit
	uint256 public					SUBMARKETING_FEE				= 10;					// sub-marketing fee 1% of deposit
	uint constant public			MAX_WITHDRAW_AMOUNT				= 5 ether;				// claim 5 BNB max
	uint constant public			WITHDRAW_COOLDOWN				= 1 days / 4;			// claim 6 times per day
	address payable public			ISECURED_CONTRACT;
	mapping (uint => uint) public	ISECURED_MAXBALANCE;
	uint constant public			ISECURED_PERCENT				= 100;					// isecured fee 10% of claim
	uint constant public			ISECURED_LOWBALANCE_PERCENT		= 250;					// protection kicks in at 25% or lower
	uint constant public			REINVEST_PERCENT				= 100;					// auto reinvest 10% of claim

	mapping (uint => THistoryDeposit) public DEPOSIT_HISTORY;
	uint public TOTAL_DEPOSITS;
	uint public TOTAL_INVESTED;
	uint public TOTAL_REFDIVIDENDS;
	uint public TOTAL_CLAIMED;
	uint public ISECURED_TRIGGER_BALANCE;
	

	struct TPlan {
		uint durationDays;
		uint percent;
	}

	struct TDeposit {
		uint planIdx;
		uint amount;
		uint timeStart;
		uint timeEnd;
		bool isReinvest;
	}

	struct THistoryDeposit {
		uint timestamp;
		uint duration;
		uint amount;
	}

	struct TUser {
		uint		checkpoint;
		TDeposit[]	deposits;
		TDeposit[]	depHistory;
		uint[5]		refCount;
		address referrer;
		uint refDividends;
		uint debtBuffer;
		uint totalInvested;
		uint totalRefDividends;
		uint totalClaimed;
	}


	TPlan[] public						PLANS;
	mapping( address => TUser ) public	USERS;

	event ProjectFeePaid(uint amount);
	event MarketingFeePaid(uint amount);
	event SubMarketingFeePaid(uint amount);
	event Reinvested(uint amount);
	event InsuranseFeePaid(uint amount);
	event Claimed(address user, uint amount);
	event InitiateISecured(uint high, uint current);
	event RefInvited(address referrer, address user);
	event RefDividends(address referrer, address user, uint refLevel, uint amount);
	event Newcomer(address user);
	event NewDeposit(address user, uint planIdx, uint amount);

	uint public		stat_maxDepositArrayLength;
	address public	stat_maxDepositArrayUser;
	uint public		stat_depositsReusedCounter;

	

	constructor(address payable _walletProject, address payable _walletDev, address payable _walletMarketing, address payable _walletSubMarketing) {

		ISECURED_CONTRACT = payable(new ISECURED());
		WALLET_PROJECT = _walletProject;
		WALLET_DEV = _walletDev;
		WALLET_MARKETING = _walletMarketing;
		WALLET_SUBMARKETING = _walletSubMarketing;

		PLANS.push( TPlan(7,170) );
		PLANS.push( TPlan(8,156) );
		PLANS.push( TPlan(9,144) );
		PLANS.push( TPlan(10,135) );
		PLANS.push( TPlan(11,127) );
		PLANS.push( TPlan(12,121) );
		PLANS.push( TPlan(13,120) );
		PLANS.push( TPlan(14,110) );
		PLANS.push( TPlan(15,106) );
		PLANS.push( TPlan(16,103) );
		PLANS.push( TPlan(17,100) );
		PLANS.push( TPlan(18,97) );
		PLANS.push( TPlan(19,95) );
		PLANS.push( TPlan(20,93) );
		PLANS.push( TPlan(21,91) );
		PLANS.push( TPlan(22,89) );
		PLANS.push( TPlan(23,87) );
		PLANS.push( TPlan(24,85) );
		PLANS.push( TPlan(25,84) );
		PLANS.push( TPlan(26,82) );
		PLANS.push( TPlan(27,81) );
		PLANS.push( TPlan(28,80) );
		PLANS.push( TPlan(29,79) );
		PLANS.push( TPlan(30,78) );

	}

	

	function invest(address _referrer, uint8 _planIdx) public payable {

		require(msg.value >= INVEST_MIN_AMOUNT, "The deposit amount is too low");
		require(_planIdx < PLANS.length, "Invalid plan index");
		if(!LAUNCHED) {
			require(msg.sender == WALLET_PROJECT, "Project has not launched yet");
			LAUNCHED = true;
		}

		//transfer project fee
		uint pfee = msg.value * PROJECT_FEE / PERCENTS_DIVIDER;
		WALLET_PROJECT.transfer(pfee);
		emit ProjectFeePaid(pfee);

		//transfer dev fee
		uint dfee = msg.value * DEV_FEE / PERCENTS_DIVIDER;
		WALLET_DEV.transfer(dfee);
		emit ProjectFeePaid(dfee);

		//transfer marketing fee
		uint mfee = msg.value * MARKETING_FEE / PERCENTS_DIVIDER;
		WALLET_MARKETING.transfer(mfee);
		emit MarketingFeePaid(mfee);

		//transfer sub-marketing fee
		uint smfee = msg.value * SUBMARKETING_FEE / PERCENTS_DIVIDER;
		WALLET_SUBMARKETING.transfer(smfee);
		emit SubMarketingFeePaid(smfee);

		_setUserReferrer(msg.sender, _referrer);

		_allocateReferralRewards(msg.sender, msg.value);

		_createDeposit( msg.sender, _planIdx, msg.value, false );

		_isecuredTrigger();
		
	}

	

	function claim() public {

		TUser storage user = USERS[msg.sender];

		uint claimAmount = _getUserDividends(msg.sender) + user.refDividends + user.debtBuffer;

		require(claimAmount > 0, "Nothing to withdraw");
		require(_canClaim(msg.sender), "Claim cooldown");

		user.checkpoint = block.timestamp;	//clear accumulated dividends
		user.refDividends = 0;				//clear refDividends
		user.debtBuffer = 0;				//clear debtBuffer


		//not enough contract balance? give what we can, promise to refund later
		uint balance = address(this).balance;
		if (claimAmount > balance) {
			user.debtBuffer += claimAmount - balance;
			claimAmount = balance;
		}

		//anti-whale protection
		if (claimAmount > MAX_WITHDRAW_AMOUNT) {
			user.debtBuffer += claimAmount - MAX_WITHDRAW_AMOUNT;
			claimAmount = MAX_WITHDRAW_AMOUNT;
		}


		//isecured
		uint isecuredAmount = claimAmount * ISECURED_PERCENT / PERCENTS_DIVIDER;
		payable(ISECURED_CONTRACT).transfer( isecuredAmount );
		emit InsuranseFeePaid(isecuredAmount);

		//reinvest
		uint reinvestAmount = claimAmount * REINVEST_PERCENT / PERCENTS_DIVIDER;
		_createDeposit( msg.sender, 0, reinvestAmount, true );
		emit Reinvested(reinvestAmount);

		claimAmount -= isecuredAmount;
		claimAmount -= reinvestAmount;

		//withdraw to user wallet
		user.totalClaimed += claimAmount;
		TOTAL_CLAIMED += claimAmount;
		payable(msg.sender).transfer( claimAmount );
		emit Claimed(msg.sender, claimAmount );

		_isecuredTrigger();

	}

	

	function _canClaim(address _user) internal view returns(bool) {
		return (block.timestamp-USERS[_user].checkpoint >= WITHDRAW_COOLDOWN);
	}

	

	function _isecuredTrigger() internal {

		uint balance = address(this).balance;
		uint todayIdx = block.timestamp/TIME_STEP;

		//new high today
		if ( ISECURED_MAXBALANCE[todayIdx] < balance ) {
			ISECURED_MAXBALANCE[todayIdx] = balance;
		}

		//high of past 7 days
		uint rangeHigh;
		for( uint i=0; i<7; i++) {
			if( ISECURED_MAXBALANCE[todayIdx-i] > rangeHigh ) {
				rangeHigh = ISECURED_MAXBALANCE[todayIdx-i];
			}
		}

		ISECURED_TRIGGER_BALANCE = rangeHigh*ISECURED_LOWBALANCE_PERCENT/PERCENTS_DIVIDER;

		//low balance - initiate ISecured
		if( balance < ISECURED_TRIGGER_BALANCE ) {
			emit InitiateISecured( rangeHigh, balance );
			ISecuredContract(ISECURED_CONTRACT).initiate();
		}
	}

	

	function _setUserReferrer(address _user, address _referrer) internal {

		if (USERS[_user].referrer != address(0)) return;	//already has a referrer
		if (USERS[_referrer].deposits.length == 0) return;	//referrer doesnt exist
		if (_user == _referrer) return;						//cant refer to yourself

		//adopt
		USERS[_user].referrer = _referrer;

		//loop through the referrer hierarchy, increase every referral Levels counter
		address upline = USERS[_user].referrer;
		for (uint i=0; i < REFERRAL_PERCENTS.length; i++) {
			if(upline==address(0)) break;
			USERS[upline].refCount[i]++;
			upline = USERS[upline].referrer;
		}

		emit RefInvited(_referrer,_user);
	}

	

	function _allocateReferralRewards(address _user, uint _depositAmount) internal {

		//loop through the referrer hierarchy, allocate refDividends
		address upline = USERS[_user].referrer;
		for (uint i=0; i < REFERRAL_PERCENTS.length; i++) {
			if (upline == address(0)) break;
			uint amount = _depositAmount * REFERRAL_PERCENTS[i] / PERCENTS_DIVIDER;
			USERS[upline].refDividends += amount;
			USERS[upline].totalRefDividends += amount;
			TOTAL_REFDIVIDENDS += amount;
			upline = USERS[upline].referrer;
			emit RefDividends(upline, _user, i, amount);
		}
	}

	

	function _createDeposit( address _user, uint _planIdx, uint _amount, bool _isReinvest ) internal returns(uint o_depIdx) {

		TUser storage user = USERS[_user];

		//first deposit: set initial checkpoint
		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			emit Newcomer(_user);
		}

		TDeposit memory newDep = TDeposit( _planIdx, _amount, block.timestamp, block.timestamp + PLANS[_planIdx].durationDays * TIME_STEP, _isReinvest );

		//reuse a deceased slot or create new
		bool found;
		for(uint i=0; i<user.deposits.length; i++) {
			if(_isDepositDeceased(_user,i)) {
				user.deposits[i] = newDep;
				o_depIdx=i;
				found=true;
				stat_depositsReusedCounter++;
				break;
			}
		}
		if(!found) {
		o_depIdx=user.deposits.length;
		user.deposits.push(newDep);
		}

		//if not reinvest - update global stats
		if(!_isReinvest) {
			user.depHistory.push(newDep);
			user.totalInvested += _amount;
			DEPOSIT_HISTORY[TOTAL_DEPOSITS] = THistoryDeposit( block.timestamp, PLANS[_planIdx].durationDays*TIME_STEP, _amount );
			TOTAL_DEPOSITS++;
			TOTAL_INVESTED += _amount;
		}

		//technical data
 		if(stat_maxDepositArrayLength < user.deposits.length) {
			stat_maxDepositArrayLength = user.deposits.length;
			stat_maxDepositArrayUser = _user;
		}

		emit NewDeposit(_user, newDep.planIdx, newDep.amount);
	}

	

	function _isDepositDeceased(address _user, uint _depIdx) internal view returns(bool) {
		return (USERS[_user].checkpoint >= USERS[_user].deposits[_depIdx].timeEnd);
	}

	

	function _calculateDepositDividends(address _user, uint _depIdx) internal view returns (uint o_amount) {

		/* use _isDepositDeceased before calling this function to save gas */

		TUser storage user = USERS[_user];
		TDeposit storage deposit = user.deposits[_depIdx];

		//calculate withdrawable dividends starting from the last Claim checkpoint
		uint totalReward = deposit.amount * PLANS[deposit.planIdx].percent / PERCENTS_DIVIDER;
		uint timeA = deposit.timeStart > user.checkpoint ? deposit.timeStart : user.checkpoint;
		uint timeB = deposit.timeEnd < block.timestamp ? deposit.timeEnd : block.timestamp;
		if (timeA < timeB) {
			o_amount = totalReward * (timeB-timeA) / TIME_STEP;
		}
	}

	

	function _getUserDividends(address _user) internal view returns (uint o_amount) {

		for(uint i=0;i<USERS[_user].deposits.length;i++) {
			if(_isDepositDeceased(_user,i)) continue;
			o_amount += _calculateDepositDividends(_user,i);
		}

	}

	

	function getProjectInfo() public view returns(uint o_totDeposits, uint o_totInvested, uint o_totRefDividends, uint o_totClaimed, uint o_ensBalance, uint o_ensTriggerBalance, uint o_timestamp) {

		uint isecuredBalance = ISecuredContract(ISECURED_CONTRACT).getBalance();
		return( TOTAL_DEPOSITS, TOTAL_INVESTED, TOTAL_REFDIVIDENDS, TOTAL_CLAIMED, isecuredBalance, ISECURED_TRIGGER_BALANCE, block.timestamp );
	}

	function getDepositHistory() public view returns(THistoryDeposit[20] memory o_historyDeposits, uint o_timestamp) {

		o_timestamp = block.timestamp;
		uint _from = TOTAL_DEPOSITS>=20 ? TOTAL_DEPOSITS-20 : 0;
		for(uint i=_from; i<TOTAL_DEPOSITS; i++) {
			o_historyDeposits[i-_from] = DEPOSIT_HISTORY[i];
		}
	}

	

	struct TPlanInfo {
		uint dividends;
		uint mActive;
		uint rActive;
	}

	struct TRefInfo {
		uint[5] count;
		uint dividends;
		uint totalEarned;
	}

	struct TUserInfo {
		uint claimable;
		uint checkpoint;
		uint totalDepositCount;
		uint totalInvested;
		uint totalClaimed;
	}

	function getUserInfo(address _user) public view returns (TPlanInfo memory o_planInfo, TRefInfo memory o_refInfo, TUserInfo memory o_userInfo, uint o_timestamp) {

		o_timestamp = block.timestamp;

		TUser storage user = USERS[_user];

		//active invest/reinvest deposits
		for(uint i=0; i<user.deposits.length; i++) {
			if(_isDepositDeceased(_user,i)) continue;
			o_planInfo.dividends += _calculateDepositDividends(_user,i);
			if(!user.deposits[i].isReinvest){ o_planInfo.mActive++; }
			else							{ o_planInfo.rActive++; }
		}

		//referral stats
		o_refInfo.count = user.refCount;
		o_refInfo.dividends = user.refDividends;
		o_refInfo.totalEarned = user.totalRefDividends;

		//user stats
		o_userInfo.claimable = o_planInfo.dividends + o_refInfo.dividends + user.debtBuffer;
		o_userInfo.checkpoint = user.checkpoint;
		o_userInfo.totalInvested = user.totalInvested;
		o_userInfo.totalDepositCount = user.depHistory.length;
		o_userInfo.totalClaimed = user.totalClaimed;

	}

	function getUserDepositHistory(address _user, uint _numBack) public view returns(TDeposit[5] memory o_deposits, uint o_total, uint o_idxFrom, uint o_idxTo, uint o_timestamp) {

		o_timestamp = block.timestamp;
		o_total = USERS[_user].depHistory.length;
		o_idxFrom = (o_total > _numBack*5) ? (o_total - _numBack*5) : 0;
		uint _cut = (o_total < _numBack*5) ? (_numBack*5 - o_total) : 0;
		o_idxTo = (o_idxFrom+5 < o_total) ? (o_idxFrom+5) - _cut : o_total;
		for(uint i=o_idxFrom; i<o_idxTo; i++) {
			o_deposits[i-o_idxFrom] = USERS[_user].depHistory[i];
		}

	}

	

	/* MOONARCH INTERFACE */

	function getUserAvailable(address _user) public view returns(uint) {
		if(!_canClaim(_user)) return 0;
		(,,TUserInfo memory userInfo,) = getUserInfo(_user);
		return userInfo.claimable;
	}

	function getUserCheckpoint(address _user) public view returns(uint) {
		return USERS[_user].checkpoint;
	}

	function getContractBalance() public view returns(uint) {
		uint isecuredBalance = ISecuredContract(ISECURED_CONTRACT).getBalance();
		return address(this).balance + isecuredBalance;
	}

	function withdraw() public {
		claim();
	}

		// Start project (Project wallet use only)
    function START_PROJECT() public {
			require(msg.sender == WALLET_PROJECT, "Project has not launched yet");
			LAUNCHED = true;
		}

		// change Project wallet (Project wallet use only)
    function CHANGE_PROJECT(address value) external {
        require(msg.sender == WALLET_PROJECT, "Project wallet use only.");
        WALLET_PROJECT = payable(value);
    }

		// change Dev wallet (Dev wallet use only)
    function CHANGE_DEV(address value) external {
        require(msg.sender == WALLET_DEV, "Dev wallet use only.");
        WALLET_DEV = payable(value);
    }

		// change Marketing wallet (Marketing wallet use only)
    function CHANGE_MARKETING(address value) external {
        require(msg.sender == WALLET_MARKETING, "Marketing wallet use only.");
        WALLET_MARKETING = payable(value);
    }

		// change SubMarketing wallet (SubMarketing wallet use only)
    function CHANGE_SUBMARKETING(address value) external {
        require(msg.sender == WALLET_SUBMARKETING, "SubMarketing wallet use only.");
        WALLET_SUBMARKETING = payable(value);
    }

}

// DuckStaking.com BNB Version
// END