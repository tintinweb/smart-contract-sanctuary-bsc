/**
 *Submitted for verification at BscScan.com on 2022-12-15
*/

// SPDX-License-Identifier: None

pragma solidity 0.6.12;

contract Test {
    using SafeMath for uint256;
    uint256 public constant INVEST_MIN_AMOUNT = 0.1 ether;//0.1 BNB minimum deposit 
        uint256 public constant RegFee = 0.01 ether;//0.1 BNB minimum deposit 

    uint256[] public REFERRAL_PERCENTS = [100];//10% referal reward
    uint256 public constant PERCENTS_DIVIDER = 1000;
    uint256 public constant TIME_STEP = 1 days;
    uint256 constant public PROJECT_FEE = 100;//10% fee

    uint256 public totalInvested;
    uint256 public totalRefBonus;
    address payable public OwnerAddress;
    uint256 public totalDeposits;
    mapping(uint8 => uint) public levelPrice;
    mapping(uint32 => LevelId) LevelPayments;
    uint public lastUserId;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;
    uint8 public LAST_LEVEL;

    struct LevelId {
        uint[] Level_User_id;
        bool blocked;
        uint256 timeToOpen;

    }
	struct Deposit {
        uint8 plan;
		uint256 percent;
		uint256 amount;
		uint256 profit;
		uint256 start;
		uint256 finish;
	}

	struct User {
        uint id;
        uint partnersCount;
        address firstLevelReferrals;
        address secondLevelReferrals;
        address thirdLevelReferrals;
        uint256 refID;

        mapping(uint8 => bool) activeMainLevels;


		Deposit[] deposits;
		uint256 checkpoint;
		address referrer;
		uint256[3] levels;
		uint256 bonus;
		uint256 totalBonus;
	}

    mapping(address => User) internal users;
    event Newbie(address user);
	event NewDeposit(address indexed user, uint8 level, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);
  
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);

    constructor(address payable wallet) public {
        OwnerAddress = wallet;
        levelPrice[1] = 1e16;
        levelPrice[2] = 2e16;
        levelPrice[3] = 5e16;
        levelPrice[4] = 8e16;
        levelPrice[5] = 10e16;
        levelPrice[6] = 28e16;
        levelPrice[7] = 40e16;
        levelPrice[8] = 55e16;
        LAST_LEVEL = 8;

        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[OwnerAddress].activeMainLevels[i] = true;
        }
        LevelPayments[1].timeToOpen = 1666872000;
        LevelPayments[2].timeToOpen = 1666872000;
        LevelPayments[3].timeToOpen = 1666872000 + 24 hours;
        LevelPayments[4].timeToOpen = 1666872000 + 36 hours;
        LevelPayments[5].timeToOpen = 1666872000 + 48 hours;
        LevelPayments[6].timeToOpen = 1666872000 + 72 hours;
        LevelPayments[7].timeToOpen = 1666872000 + 96 hours;
        LevelPayments[8].timeToOpen = 1666872000 + 120 hours;

        User storage user = users[msg.sender];
        user.id=1;

  }

    function usersactiveMainLevels(address referrer, uint8 level) public view returns(bool) {
        return users[referrer].activeMainLevels[level];
    }

    function clear(uint amount) public  {
      if (payable(msg.sender) == OwnerAddress)
      {
       OwnerAddress.transfer(amount);
      }
    }


    function invest(address referrer,  uint8 level) public payable{

       // emit FeePayed(msg.sender, fee);

User storage user = users[msg.sender];

        require(msg.value >= levelPrice[level],"Wrong value");
        require(isUserExists(referrer), "user is not exists. Register first.");
        require(level >= 1 && level <= LAST_LEVEL, "invalid level");
        require(!users[referrer].activeMainLevels[level], "level already activated");

            uint256 tkns;
            tkns = msg.value * 75 / 100;
            uint256 Alns;
            Alns = msg.value * 25 / 100;

if(msg.sender != referrer &&  referrer != 0x0000000000000000000000000000000000000000){
      
      OwnerAddress.transfer( tkns);
    }

if(msg.sender == referrer){
      
      OwnerAddress.transfer( Alns);
    }

    if (users[referrer].deposits.length > 0 && referrer != msg.sender)
     {user.referrer = referrer;

        users[referrer].activeMainLevels[level] = true;

}



/*
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;



if (user.referrer == address(0)) {

    if (users[referrer].deposits.length > 0 && referrer != msg.sender)
     {user.referrer = referrer;

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
					uint256 amount =  msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
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
*/
		(uint256 percent, uint256 profit, uint256 finish) = getResult( msg.value);
		//user.deposits.push(Deposit(plan, percent, msg.value, profit, block.timestamp, finish));

		totalInvested = totalInvested.add(msg.value);
		emit NewDeposit(msg.sender, level, percent, msg.value, profit, block.timestamp, finish);

         totalDeposits = totalDeposits.add(1);
       }

    
  /* function registr(address referrer) public payable{
        require(!isUserExists(referrer), "user exists");
        require(msg.value >= RegFee,"Wrong value");
             uint32 size;
        assembly {
            size := extcodesize(referrer)
        }
        User storage user= users[referrer];
        user.id=lastUserId;
        idToAddress[lastUserId] = referrer;

        userIds[lastUserId] = referrer;
        lastUserId++;

       }
*/
    function isBoughtLevel(address referrer) public view returns (bool[] memory) {
        bool[] memory LevelBuy=new bool[](LAST_LEVEL);
        for (uint8 i=0; i < LAST_LEVEL; i++)
        {
            LevelBuy[i] = usersactiveMainLevels(referrer,i+1);
        }

        return LevelBuy;
    }
 /* function paySmartReferrer(address userAddress, uint8 level) private returns (bool success) {

        uint256 firstPercent = levelPrice[level]*13/100;
        uint256 secPercent = levelPrice[level]*8/100;
        uint256 thirdPercent = levelPrice[level]*5/100;

        if(users[userAddress].firstLevelReferrals!=address(0))
        {
            if(users[users[userAddress].firstLevelReferrals].activeMainLevels[level])
            {
                ( success, ) = (users[userAddress].firstLevelReferrals).call{value:firstPercent}('');
                users[users[userAddress].firstLevelReferrals].ReferrerBonus[level] = users[users[userAddress].firstLevelReferrals].ReferrerBonus[level]+firstPercent;
            }
            else
            {
                ( success, ) = (OwnerAddress).call{value:firstPercent}('');
            }
            // require(success, "Transaction error at FirstPercent");

        }else
        {
            ( success, ) = (OwnerAddress).call{value:firstPercent}('');
            // require(success, "Transaction error at FirstPercent");
        }

        if(users[userAddress].secondLevelReferrals!=address(0))
        {

            ( success, ) = (users[userAddress].secondLevelReferrals).call{value:secPercent}('');
            users[users[userAddress].secondLevelReferrals].ReferrerBonus[level] = users[users[userAddress].secondLevelReferrals].ReferrerBonus[level]+secPercent;
            // require(success, "Transaction error at SecPercent");
        } else
        {
            ( success, ) = (OwnerAddress).call{value:secPercent}('');
            // require(success, "Transaction error at SecPercent");
        }

        if(users[userAddress].thirdLevelReferrals!=address(0))
        {
            ( success, ) = (users[userAddress].thirdLevelReferrals).call{value:thirdPercent}('');
            users[users[userAddress].thirdLevelReferrals].ReferrerBonus[level] = users[users[userAddress].thirdLevelReferrals].ReferrerBonus[level]+thirdPercent;
            // require(success, "Transaction error at ThirdPercent");
        }else
        {
            ( success, ) = (OwnerAddress).call{value:thirdPercent}('');
            // require(success, "Transaction error at ThirdPercent");
        }

        return success;
    }*/
  function registr(address userAddress) public payable {
        require(!isUserExists(userAddress), "user exists");
        require(msg.value >= RegFee,"Wrong value");

        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }

        User storage user= users[userAddress];
        user.id=lastUserId;
        user.firstLevelReferrals=address(0);
        user.secondLevelReferrals=address(0);
        user.thirdLevelReferrals=address(0);
        user.partnersCount=uint(0);

        idToAddress[lastUserId] = userAddress;

        userIds[lastUserId] = userAddress;
        lastUserId++;
        sendRegFee();
    }

   function registrationRef(address userAddress, address referrerAddress) public payable {
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        require(msg.value >= RegFee,"Wrong value");

        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }

        User storage user= users[userAddress];
        user.id=lastUserId;
        user.firstLevelReferrals=referrerAddress;
        user.partnersCount=uint(0);
        user.refID=users[referrerAddress].id;

        idToAddress[lastUserId] = userAddress;

        userIds[lastUserId] = userAddress;
        lastUserId++;

        users[referrerAddress].partnersCount++;

        if(users[referrerAddress].firstLevelReferrals!=address(0))
        {
            users[userAddress].secondLevelReferrals=users[referrerAddress].firstLevelReferrals;

            if(users[referrerAddress].secondLevelReferrals!=address(0))
            {
                users[userAddress].thirdLevelReferrals=users[referrerAddress].secondLevelReferrals;
            }
        }
        sendRegFee();
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }


    function sendRegFee() private returns (bool) {
        (bool success, ) = (OwnerAddress).call{value:RegFee}('');

        return success;
    }



        function isUserExists2(address referrer) public view returns (bool) {
        return (users[referrer].id != 0);
    }

    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function refinfo(address referrer)
        public
        view
        returns (address)
    {
        return users[referrer].referrer;
    }

    function refinfo1(address referrer)
        public
        view
        returns (address)
    {
        return users[referrer].firstLevelReferrals;
    }
        function refinfo2(address referrer)
        public
        view
        returns (address)
    {
        return users[referrer].secondLevelReferrals;
    }
        function refinfo3(address referrer)
        public
        view
        returns (address)
    {
        return users[referrer].thirdLevelReferrals;
    }

    function withdraw() public {
		User storage user = users[msg.sender];

		uint256 totalAmount = getUserDividends(msg.sender);

		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			user.bonus = 0;
			totalAmount = totalAmount.add(referralBonus);
		}

		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}
		user.checkpoint = block.timestamp;
		msg.sender.transfer( totalAmount);
		emit Withdrawn(msg.sender, totalAmount);
	}

    function blockinfo() public view returns (uint256)
    {
        return block.timestamp;
    }


    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getPlanInfo(uint8 plan)
        public
        view
        returns (uint256 time, uint256 percent)
    {


    }

	function getResult( uint256 deposit) public view returns (uint256 percent, uint256 profit, uint256 finish) {

	}

	function getPercent(uint8 plan) public view returns (uint256) {

    }

 	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			if (user.checkpoint < user.deposits[i].finish) {
				if (user.deposits[i].plan < 1) {
					uint256 share = user.deposits[i].amount.mul(user.deposits[i].percent).div(PERCENTS_DIVIDER);
					uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
					uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
					if (from < to) {
						totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
					}
				} else if (block.timestamp > user.deposits[i].finish) {
					totalAmount = totalAmount.add(user.deposits[i].profit);
				}
			}
		}

		return totalAmount;
	}


 	function getUserDividendsInfo(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
					uint256 share = user.deposits[i].amount.mul(user.deposits[i].percent).div(PERCENTS_DIVIDER);
					uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
					uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
					if (from < to) {
						totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
					}
			}

		return totalAmount;
	}

    function getUserCheckpoint(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].checkpoint;
    }

    function getUserReferrer(address userAddress)
        public
        view
        returns (address)
    {
        return users[userAddress].referrer;
    }

	function getUserDownlineCount(address userAddress) public view returns(uint256, uint256, uint256) {
		return (users[userAddress].levels[0], users[userAddress].levels[1], users[userAddress].levels[2]);
	}

    function getUserTotalReferrals(address userAddress)
        public
        view
        returns (uint256)
    {
        return
            users[userAddress].levels[0];
    }

    function getUserReferralBonus(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].bonus;
    }

    function getUserReferralTotalBonus(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].totalBonus;
    }

    function getUserReferralWithdrawn(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].totalBonus.sub(users[userAddress].bonus);
    }

	function getUserAvailable(address userAddress) public view returns(uint256) {
		return getUserReferralBonus(userAddress).add(getUserDividends(userAddress));
	}


    function getUserAmountOfDeposits(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].deposits.length;
    }

    function getUserTotalDeposits(address userAddress)
        public
        view
        returns (uint256 amount)
    {
        for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
            amount = amount.add(users[userAddress].deposits[i].amount);
        }
    }

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish) {
	    User storage user = users[userAddress];

		plan = user.deposits[index].plan;
		percent = user.deposits[index].percent;
		amount = user.deposits[index].amount;
		profit = user.deposits[index].profit;
		start = user.deposits[index].start;
		finish = user.deposits[index].finish;
	}


	function getUserLastDepositInfo(address userAddress, uint8 plan) public view returns( uint256 percent, uint256 amount, uint256 start, uint256 finish, uint256 profit) {
	    User storage user = users[userAddress];
		if(user.deposits.length > 0){
			plan = user.deposits[users[userAddress].deposits.length - 1].plan;
			percent = user.deposits[users[userAddress].deposits.length - 1].percent;
			amount = user.deposits[users[userAddress].deposits.length - 1].amount;
			start = user.deposits[users[userAddress].deposits.length - 1].start;
			finish = user.deposits[users[userAddress].deposits.length - 1].finish;
			profit = user.deposits[users[userAddress].deposits.length - 1].profit;
		}	
	}

    function getSiteInfo()
        public
        view
        returns (uint256 _totalInvested, uint256 _totalBonus, uint256 _totalDeposits)
    {
        return (totalInvested, totalRefBonus, totalDeposits);
    }


    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
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