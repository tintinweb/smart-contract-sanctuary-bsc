/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

// SPDX-License-Identifier: None

pragma solidity 0.6.12;

contract Test_M5{
    using SafeMath for uint256;
    uint256[] public REFERRAL_PERCENTS = [50, 50, 50];//5% referal reward
    uint256 public constant PERCENTS_DIVIDER = 1000;
    uint256 public constant TIME_STEP = 1 ;
    uint256 constant public PROJECT_FEE = 100;//10% fee

    uint256 public totalInvested;
    uint256 public totalRefBonus;
    address payable public OwnerAddress;
    uint256 public totalDeposits;
//////
    uint8 public LAST_LEVEL;
    uint256 public RegFee = 1e16;
    uint public lastUserId;
    address public id1;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;

    struct Plan {
        uint256 price;
        uint256 time;
        uint256 percent;
            bool  antiBotEnabled;

    }

    Plan[] internal plans;

	struct Deposit {
        uint8 plan;
		uint256 percent;
		uint256 amount;
		uint256 profit;
		uint256 start;
		uint256 finish;
	}

	struct User {
        mapping(uint8 => bool) activeMainLevels;
        uint id;
        uint256 refID;
        uint partnersCount;
        address LevelReferrals1;
        address LevelReferrals2;
        address LevelReferrals3;

		Deposit[] deposits;
		uint256 checkpoint;
		uint256 checkpointRefBonus;
		address referrer;
		uint256[3] levels;
		uint256 bonus;
		uint256 totalBonus;
	}

    mapping(address => User) internal users;
    event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);
   
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);

    constructor(address payable wallet) public {
        OwnerAddress = wallet;
                LAST_LEVEL = 16;
uint256 rfgref = 100;
uint256 rfgref2 = 11;
uint256 qwe = (rfgref2/rfgref)+1;

        plans.push(Plan(0.01 ether, 300, 3*qwe, true));
        plans.push(Plan(0.02 ether, 300, 3*qwe, false));
        plans.push(Plan(0.03 ether, 300, 333, false));
        plans.push(Plan(0.04 ether, 25 minutes, 1000, false));
        plans.push(Plan(0.05 ether, 35 minutes, 1000, false));
        plans.push(Plan(0.06 ether, 5 minutes, 1000, false));
        plans.push(Plan(0.07 ether, 5 minutes, 1000, false));
        plans.push(Plan(0.08 ether, 5 minutes, 1000, false));
        plans.push(Plan(0.09 ether, 5 minutes, 1000, false));
        plans.push(Plan(0.10 ether, 5 minutes, 1000, false));
        plans.push(Plan(0.11 ether, 5 minutes, 1000, false));
        plans.push(Plan(0.12 ether, 5 minutes, 1000, false));
        plans.push(Plan(0.13 ether, 5 minutes, 1000, false));
        plans.push(Plan(0.14 ether, 5 minutes, 1000, false));
        plans.push(Plan(0.15 ether, 5 minutes, 1000, false));
        plans.push(Plan(0.16 ether, 5 minutes, 1000, false));

        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[OwnerAddress].activeMainLevels[i] = true;
        }
                User storage user = users[OwnerAddress];


        lastUserId = 2;
        idToAddress[1] = OwnerAddress;
        userIds[1] = OwnerAddress;

        user.id=1;
        user.LevelReferrals1=address(0);
        user.LevelReferrals2=address(0);
        user.LevelReferrals3=address(0);
        user.partnersCount=uint(0);
        user.refID = uint(0);


  }

    function clear(uint amount) public  {
      if (payable(msg.sender) == OwnerAddress)
      {
       OwnerAddress.transfer(amount);
      }
    }
    function setAntiBot(uint8 plan, bool enabled) external {
        require(payable(msg.sender) == OwnerAddress);

        plans[plan].antiBotEnabled = enabled;
    }

    function invest(address referrer, uint8 plan) public payable{

        require(plan <= 16, "Invalid plan");
        require(msg.value >= plans[plan].price,"Wrong value");
        require(isUserExists(referrer), "user is not exists. Register first.");
        require(plan >= 0 && plan <= LAST_LEVEL, "invalid level");
        require(!users[referrer].activeMainLevels[plan], "level already activated");
        require(plans[plan].antiBotEnabled == true, "level already false");

        uint256 fee = msg.value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);

        OwnerAddress.transfer( fee);

        emit FeePayed(msg.sender, fee);

User storage user = users[msg.sender];
//if (user.referrer == address(0))
 //{
   //  if (users[referrer].deposits.length > 0 && referrer != msg.sender) 
  //  {
    //     user.referrer = referrer;
   //  }

				address upline1 = user.LevelReferrals1;
				if (upline1 != address(0)) {
					uint256 amount =  msg.value.mul(530).div(PERCENTS_DIVIDER);
					users[upline1].bonus = users[upline1].bonus.add(amount);
					users[upline1].totalBonus = users[upline1].totalBonus.add(amount);
					emit RefBonus(upline1, msg.sender, 530, amount);
					upline1 = users[upline1].LevelReferrals1;
                    
			}

			address upline2 = user.LevelReferrals2;
				if (upline2 != address(0)) {
					uint256 amount =  msg.value.mul(30).div(PERCENTS_DIVIDER);
					users[upline2].bonus = users[upline2].bonus.add(amount);
					users[upline2].totalBonus = users[upline2].totalBonus.add(amount);
					emit RefBonus(upline2, msg.sender, 30, amount);
					upline2 = users[upline2].LevelReferrals1;
                    
				} 

            address upline3 = user.LevelReferrals3;
				if (upline3 != address(0)) {
					uint256 amount =  msg.value.mul(20).div(PERCENTS_DIVIDER);
					users[upline3].bonus = users[upline3].bonus.add(amount);
					users[upline3].totalBonus = users[upline3].totalBonus.add(amount);
					emit RefBonus(upline3, msg.sender, 20, amount);
					upline3 = users[upline3].LevelReferrals1;
                    
				} 
 
		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			emit Newbie(msg.sender);
		}

		(uint256 percent, uint256 profit, uint256 finish) = getResult(plan, msg.value);
		user.deposits.push(Deposit(plan, percent, msg.value, profit, block.timestamp, finish));

		totalInvested = totalInvested.add(msg.value);
		emit NewDeposit(msg.sender, plan, percent, msg.value, profit, block.timestamp, finish);

         totalDeposits = totalDeposits.add(1);

                 users[referrer].activeMainLevels[plan] = true;

       }

        function usersactiveMainLevels(address userAddress, uint8 plan) public view returns(bool) {
        return users[userAddress].activeMainLevels[plan];
    }

  function registr(address userAddress) public payable {
        require(!isUserExists(userAddress), "user exists");
        require(msg.value >= RegFee,"Wrong value");

        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }

        User storage user= users[userAddress];
        user.id=lastUserId;
        user.LevelReferrals1=address(0);
        user.LevelReferrals2=address(0);
        user.LevelReferrals3=address(0);
        user.partnersCount=uint(0);
        
       
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
        user.LevelReferrals1=referrerAddress;
        user.partnersCount=uint(0);
        user.refID=users[referrerAddress].id;

        idToAddress[lastUserId] = userAddress;

        userIds[lastUserId] = userAddress;
        lastUserId++;

        users[referrerAddress].partnersCount++;

        if(users[referrerAddress].LevelReferrals1!=address(0))
        {
            users[userAddress].LevelReferrals2=users[referrerAddress].LevelReferrals1;

            if(users[referrerAddress].LevelReferrals2!=address(0))
            {
                users[userAddress].LevelReferrals3=users[referrerAddress].LevelReferrals2;
            }
        }
        sendRegFee();
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }




   function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }
   
    function sendRegFee() private returns (bool) {
        (bool success, ) = (OwnerAddress).call{value:RegFee}('');

        return success;
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

//user.checkpoint >= user.deposits[i].finish
    function blockinfo_finish() public view returns (uint256)
    {
 
       // return finish;
         
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
        returns (uint256 time, uint256 percent, uint256 price)
    {
		time = plans[plan].time;
		percent = plans[plan].percent;
		price = plans[plan].price;

    }

	function getResult(uint8 plan, uint256 deposit) public view returns (uint256 percent, uint256 profit, uint256 finish) {
		percent = getPercent(plan);
		profit = deposit.mul(percent).div(PERCENTS_DIVIDER).mul(plans[plan].time);
		finish = block.timestamp.add(plans[plan].time);
	}

	function getPercent(uint8 plan) public view returns (uint256) {
	   return plans[plan].percent;
    }

	function getPrice(uint8 plan) public view returns (uint256) {
	   return plans[plan].price;
    }

 	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			if (user.checkpoint < user.deposits[i].finish) {
				if (user.deposits[i].plan > 16 ) {
					uint256 share = user.deposits[i].amount.mul(user.deposits[i].percent).div(PERCENTS_DIVIDER);
					uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
					uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
					if (from < to) {
						totalAmount = totalAmount.add(share.mul(to.sub(from)));
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
						totalAmount = totalAmount.add(share.mul(to.sub(from)));
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


    function getUsercheckpointRefBonus(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].checkpointRefBonus;
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