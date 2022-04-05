/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.5;

//===============================================================================================================================================

contract Bnbclub {

	//accept funds from Insurance
	receive() external payable {}

	bool public						LAUNCHED;
	address payable public			WALLET_DEV;
	uint constant public			PERCENTS_DIVIDER				= 1000;
	uint constant public			TIME_STEP						= 1 days;
	uint constant public			INVEST_MIN_AMOUNT				= 0.01 ether;			// 0.01BNB
	uint[] public					REFERRAL_PERCENTS				= [100, 50, 30, 20, 10];	// 10% 5% 3% 2% 1%
	uint constant public			DEV_FEE							= 100;					// dev fee 10% of deposit
	uint constant public			WITHDRAW_COOLDOWN				= 1 days;			    // claim 1 time per day
    
    
	
	mapping (uint => THistoryDeposit) public DEPOSIT_HISTORY;
	uint public TOTAL_DEPOSITS;
	uint public TOTAL_INVESTED;
	uint public TOTAL_REFDIVIDENDS;
	uint public TOTAL_CLAIMED;
    uint public TOTAL_USERS;
	uint public GUARD_LOWBALANCE;

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


	TPlan[] public	PLANS;
	mapping( address => TUser ) public	USERS;

	event DevFeePaid(uint amount);
	event Reinvested(uint amount);
	event Claimed(address user, uint amount);
	event RefInvited(address referrer, address user);
	event RefDividends(address referrer, address user, uint refLevel, uint amount);
	event Newcomer(address user);
	event NewDeposit(address user, uint planIdx, uint amount);

	uint public		stat_maxDepositArrayLength;
	address public	stat_maxDepositArrayUser;
	uint public		stat_depositsReusedCounter;

	//-------------------------------------------------------------------------------------------------------------------------------------------

	constructor(address payable _walletDev) {

		WALLET_DEV = _walletDev;
		PLANS.push( TPlan(300,10) ); // 300 days 1 Percent
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------

	function invest(address _referrer, uint8 _planIdx) public payable {

		require(msg.value >= INVEST_MIN_AMOUNT, "The deposit amount is too low");
		require(_planIdx < PLANS.length, "Invalid plan index");
		if(!LAUNCHED) {
			require(msg.sender == WALLET_DEV, "Project has not launched yet");
			LAUNCHED = true;
		}

		//transfer dev fee
		uint mfee = msg.value * DEV_FEE / PERCENTS_DIVIDER;
		WALLET_DEV.transfer(mfee);
		emit DevFeePaid(mfee);

		_setUserReferrer(msg.sender, _referrer);

		_allocateReferralRewards(msg.sender, msg.value);

		_createDeposit( msg.sender, _planIdx, msg.value, false );
		
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------

	function withdraw() public {

		TUser storage user = USERS[msg.sender];

		uint claimAmount = _getUserDividends(msg.sender) + user.refDividends + user.debtBuffer;

		require(claimAmount > 0, "Nothing to withdraw");
		require(_canClaim(msg.sender), "Claim cooldown"); // Withdraw is avaliable once a day

		user.checkpoint = block.timestamp;	//clear accumulated dividends
		user.refDividends = 0;				//clear refDividends
		user.debtBuffer = 0;				//clear debtBuffer


		//not enough contract balance? give what we can, promise to refund later
		uint balance = address(this).balance;
		if (claimAmount > balance) {
			user.debtBuffer += claimAmount - balance;
			claimAmount = balance;
		}


		//withdraw to user wallet
		user.totalClaimed += claimAmount;
		TOTAL_CLAIMED += claimAmount;
		payable(msg.sender).transfer( claimAmount );
		emit Claimed(msg.sender, claimAmount );

	}

	//-------------------------------------------------------------------------------------------------------------------------------------------

	function _canClaim(address _user) internal view returns(bool) {
		return (block.timestamp-USERS[_user].checkpoint >= WITHDRAW_COOLDOWN);
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------

	

	//-------------------------------------------------------------------------------------------------------------------------------------------

	function _setUserReferrer(address _user, address _referrer) internal {

		if (USERS[_user].referrer != address(0)) return;	//already has a referrer
        if (USERS[_user].deposits.length > 0) return;	    //already deposited user cant set a referrer
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

	//-------------------------------------------------------------------------------------------------------------------------------------------

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

	//-------------------------------------------------------------------------------------------------------------------------------------------

	function _createDeposit( address _user, uint _planIdx, uint _amount, bool _isReinvest ) internal returns(uint o_depIdx) {

		TUser storage user = USERS[_user];

		//first deposit: set initial checkpoint
		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
            TOTAL_USERS++;
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

	//-------------------------------------------------------------------------------------------------------------------------------------------

	function _isDepositDeceased(address _user, uint _depIdx) internal view returns(bool) {
		return (USERS[_user].checkpoint >= USERS[_user].deposits[_depIdx].timeEnd);
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------

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

	//-------------------------------------------------------------------------------------------------------------------------------------------

	function _getUserDividends(address _user) internal view returns (uint o_amount) {

		for(uint i=0;i<USERS[_user].deposits.length;i++) {
			if(_isDepositDeceased(_user,i)) continue;
			o_amount += _calculateDepositDividends(_user,i);
		}

	}

	//-------------------------------------------------------------------------------------------------------------------------------------------

	function getProjectInfo() public view returns(uint o_totDeposits, uint o_totInvested, uint o_totRefDividends, uint o_totClaimed, uint o_balance, uint o_guardLowBalance, uint o_totUsers, uint o_timestamp) {
		return( TOTAL_DEPOSITS, TOTAL_INVESTED, TOTAL_REFDIVIDENDS, TOTAL_CLAIMED, address(this).balance, GUARD_LOWBALANCE, TOTAL_USERS, block.timestamp );
	}

	function getDepositHistory() public view returns(THistoryDeposit[20] memory o_historyDeposits, uint o_timestamp) {

		o_timestamp = block.timestamp;
		uint _from = TOTAL_DEPOSITS>=20 ? TOTAL_DEPOSITS-20 : 0;
		for(uint i=_from; i<TOTAL_DEPOSITS; i++) {
			o_historyDeposits[i-_from] = DEPOSIT_HISTORY[i];
		}
        
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------

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
        uint activeDeposit;
        uint activeReinvest;
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
			
            if(!user.deposits[i].isReinvest){ 
                o_planInfo.mActive++; 
            } else {
                o_planInfo.rActive++;
                o_userInfo.activeReinvest += user.deposits[i].amount;
            }
        
            o_userInfo.activeDeposit += user.deposits[i].amount;
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

	function getUserDepositHistory(address _user, uint _index) public view returns(TDeposit memory o_deposit, uint o_timestamp) {

		o_timestamp = block.timestamp;

        o_deposit = USERS[_user].depHistory[_index];

	}

	//-------------------------------------------------------------------------------------------------------------------------------------------

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
		return address(this).balance;
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------

}

//===============================================================================================================================================