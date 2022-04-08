/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

/*

  /$$$$$$  /$$$$$$$  /$$$$$$$  /$$$$$$ /$$$$$$$$ /$$$$$$   /$$$$$$  /$$      /$$ /$$$$$$$$
 /$$__  $$| $$__  $$| $$__  $$|_  $$_/|__  $$__//$$__  $$ /$$__  $$| $$$    /$$$| $$_____/
| $$  \ $$| $$  \ $$| $$  \ $$  | $$     | $$  | $$  \__/| $$  \ $$| $$$$  /$$$$| $$      
| $$  | $$| $$$$$$$/| $$$$$$$   | $$     | $$  | $$ /$$$$| $$$$$$$$| $$ $$/$$ $$| $$$$$   
| $$  | $$| $$__  $$| $$__  $$  | $$     | $$  | $$|_  $$| $$__  $$| $$  $$$| $$| $$__/   
| $$  | $$| $$  \ $$| $$  \ $$  | $$     | $$  | $$  \ $$| $$  | $$| $$\  $ | $$| $$      
|  $$$$$$/| $$  | $$| $$$$$$$/ /$$$$$$   | $$  |  $$$$$$/| $$  | $$| $$ \/  | $$| $$$$$$$$
 \______/ |__/  |__/|_______/ |______/   |__/   \______/ |__/  |__/|__/     |__/|________/
                                                                                          
                                                                                          
     */                                                                                     


pragma solidity 0.5.8;

contract ORBITGAME {
	using SafeMath for uint256;
    using SafeMath for uint8;

	uint256 constant public INVEST_MIN_AMOUNT = 0.05 ether; // 0.05 BNB
	uint256[] public REFERRAL_PERCENTS = [50, 25, 15,5,5];
    uint256[] public REFERRAL_MINIMUM = [0.05 ether, 0.2 ether, 0.5 ether,1.5 ether,2.5 ether];
	uint256 constant public PROJECT_FEE = 80;
	uint256 constant public DEVELOPER_FEE = 40;
	uint256 constant public PERCENT_STEP = 10;
	uint256 constant public PERCENTS_DIVIDER= 1000;
	uint256 constant public TIME_STEP = 1 days;
	
	uint256 constant public MAX_HOLD_PERCENT = 15;
	
	uint256 WITHDRAW_FEE_1 = 50; //5%
	uint256 WITHDRAW_FEE_2 = 100; //10%

    
	
	uint256 public totalStaked;
	uint256 public totalRefBonus;
	uint256 public totalUsers;
    uint public TOTAL_DEPOSITS;


    struct Plan {
        uint256 time;
        uint256 percent;
        uint256 withdrawl;
    }

    Plan[] internal plans;

	struct Deposit {
        uint8 plan;
		uint256 percent;
		uint256 amount;
		uint256 profit;
		uint256 start;
		uint256 finish;
        uint256 cooldown;
	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
		uint256 holdBonusCheckpoint;
		address payable referrer;
		uint256 referrals;
		uint256 totalBonus;
		uint256 withdrawn;
        uint256 bonus;
        uint256 invest;
        bool l2;
        bool l3;
        bool l4;
        bool l5;
	}

	struct THistoryDeposit {
		uint timestamp;
		uint duration;
		uint amount;
	}

    struct Extra {
        bool earn;
		uint256 bonus;
	}

	mapping (address => User) internal users;
    mapping (address => Extra) internal extraBonuses;
    mapping (uint => THistoryDeposit) public DEPOSIT_HISTORY;

	uint256 public startUNIX;
	address payable private commissionWallet;
	address payable private developerWallet;
    address payable private refWallet;
	
	

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
    event AddExtraBonus(address indexed user);
	event RemoveExtraBonus(address indexed user);
	event ExtraBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);

	constructor(address payable wallet, address payable _developer , address payable _ref) public {
		require(!isContract(wallet));
		commissionWallet = wallet;
		developerWallet = _developer;
        refWallet = _ref;
        startUNIX = block.timestamp.add(365 days);

        plans.push(Plan(14, 80, 0)); // 8% per day for 14 days
        plans.push(Plan(21, 60, 0)); // 6% per day for 21 days
        plans.push(Plan(28, 54, 0)); // 5,4% per day for 28 days
		plans.push(Plan(14, 86, 6)); // 8,6% per day for 14 days (Withdrawl 6 Hours)
        plans.push(Plan(21, 76, 12)); // 7.6% per day for 21 days Withdrawl 12 Hours)
        plans.push(Plan(28, 75, 24)); // 7,5% per day for 28 days (Withdrawl 24 Hours)
        plans.push(Plan(28, 96, 96)); // 7% per day for 28 days (Withdrawl 96 Hours)
        plans.push(Plan(28, 130, 7*24)); // 7% per day for 28 days (Withdrawl every Week)
	}

    function launch() public {
        require(msg.sender == developerWallet);
		startUNIX = block.timestamp;
		
        
    } 


    function invest(address payable referrer,uint8 plan) public payable {
        _invest(referrer, plan, msg.sender, msg.value);
           
    }


	function _invest(address payable referrer, uint8 plan, address payable sender, uint256 value) private {
		require(value >= INVEST_MIN_AMOUNT);
        require(plan < 8, "Invalid plan");
        require(startUNIX < block.timestamp, "contract hasn`t started yet");
		

		uint256 fee = value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		commissionWallet.transfer(fee);
		uint256 developerFee = value.mul(DEVELOPER_FEE).div(PERCENTS_DIVIDER);
		developerWallet.transfer(developerFee);
		
		User storage user = users[sender];

		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != sender) {
				user.referrer = referrer;
			}else{
                user.referrer = refWallet;
            }

			address upline = user.referrer;
			for (uint256 i = 0; i < 5; i++) {
				if (upline != address(0)) {
					users[upline].referrals = users[upline].referrals.add(1);
					upline = users[upline].referrer;
				} else break;
			}
		}


        if (user.referrer != address(0)) {
            uint256 _refBonus = 0;
            uint256 amount2 = 0;
            bool go = false;
            address payable upline = user.referrer;
            for (uint256 i = 0; i < 5; i++) {
                if (upline != address(0)) {
                    if(i==1)
                    {
                        if(users[upline].l2 == true) go = true;
                    }
                    else if(i==2)
                    {
                        if(users[upline].l3 == true) go = true;
                    }
                    else if(i==3)
                    {
                        if(users[upline].l4 == true) go = true;
                    }
                    else if(i==4)
                    {
                        if(users[upline].l5 == true) go = true;
                    }

                    for (uint256 u = 0; u < users[upline].deposits.length; u++) {
                        amount2 = amount2.add(users[upline].deposits[u].amount);
                    }

                    if(amount2 >= REFERRAL_MINIMUM[i] || go == true)
                    {
                        if(i == 0 && extraBonuses[upline].earn == true ){
                            uint256 extraAmount = msg.value.mul(extraBonuses[upline].bonus).div(PERCENTS_DIVIDER);
                            users[upline].bonus = users[upline].bonus.add(extraAmount);
                            users[upline].totalBonus = users[upline].totalBonus.add(extraAmount);
                            _refBonus = _refBonus.add(extraAmount);
                            emit ExtraBonus(upline, msg.sender, i, extraAmount);
                        }

                    
                        uint256 amount = value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
                        
                        users[upline].totalBonus = users[upline].totalBonus.add(amount);
                        upline.transfer(amount);
                        _refBonus = _refBonus.add(amount);
                    
                        emit RefBonus(upline, sender, i, amount);
                       
                    }
                    upline = users[upline].referrer;
                    amount2 = 0;
                    go = false;
                }
            }

            totalRefBonus = totalRefBonus.add(_refBonus);

        }
		

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			user.holdBonusCheckpoint = block.timestamp;
			emit Newbie(sender);
		}

		

		(uint256 percent, uint256 profit, uint256 finish) = getResult(plan, value);

        
		
		user.deposits.push(Deposit(plan, percent, value, profit, block.timestamp, finish, ( block.timestamp+(plans[plan].withdrawl*60*60))));

        DEPOSIT_HISTORY[TOTAL_DEPOSITS] = THistoryDeposit( block.timestamp, plans[plan].time, value );
	    TOTAL_DEPOSITS++;
		totalStaked = totalStaked.add(value);
        totalUsers = totalUsers.add(1);
		
		emit NewDeposit(sender, plan, percent, value, profit, block.timestamp, finish);
	}

	function withdraw() public {
		User storage user = users[msg.sender];

		uint256 totalAmount = getUserDividends(msg.sender);

		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;
		user.holdBonusCheckpoint = block.timestamp;

        for (uint256 x = 0; x < user.deposits.length; x++) {
			 if(block.timestamp > user.deposits[x].cooldown) {
                user.deposits[x].cooldown = block.timestamp+(plans[user.deposits[x].plan].withdrawl*60*60);
             }
		}        

		user.withdrawn = user.withdrawn.add(totalAmount);
		msg.sender.transfer(totalAmount);

		emit Withdrawn(msg.sender, totalAmount);

	}

	
    

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent, uint256 withdrawl) {
		time = plans[plan].time;
		percent = plans[plan].percent;
        withdrawl = plans[plan].withdrawl;
	}

	function getPercent(uint8 plan) public view returns (uint256) {
	    
			return plans[plan].percent.add(PERCENT_STEP.mul(block.timestamp.sub(startUNIX)).div(TIME_STEP));
		
    }
    

	function getResult(uint8 plan, uint256 deposit) public view returns (uint256 percent, uint256 profit, uint256 finish) {
		percent = getPercent(plan);

	
		if (plan < 3) {
			profit = deposit.mul(percent).div(PERCENTS_DIVIDER).mul(plans[plan].time);
		} else if (plan >= 3) {
            profit = deposit.mul(percent).div(PERCENTS_DIVIDER).mul(plans[plan].time);
            /*
			for (uint256 i = 0; i < plans[plan].time; i++) {
				profit = profit.add((deposit.add(profit)).mul(percent).div(PERCENTS_DIVIDER));
			}
            */
		}

		finish = block.timestamp.add(plans[plan].time.mul(TIME_STEP));
	}
	
	 function getUserPercentRate(address userAddress) public view returns (uint) {
        User storage user = users[userAddress];

        uint256 timeMultiplier = block.timestamp.sub(user.holdBonusCheckpoint).div(TIME_STEP); // +0.1% per day
            if (timeMultiplier > MAX_HOLD_PERCENT) {
                timeMultiplier = MAX_HOLD_PERCENT;
            }

         return timeMultiplier;
    }
    

	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;
		
		uint256 holdBonus = getUserPercentRate(userAddress);

		for (uint256 i = 0; i < user.deposits.length; i++) {


			if (user.checkpoint < user.deposits[i].finish) {
				if (user.deposits[i].plan < 3) {
				
					uint256 share = user.deposits[i].amount.mul(user.deposits[i].percent.add(holdBonus)).div(PERCENTS_DIVIDER);
					uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
					uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
					if (from < to) {
						uint256 _dividends = share.mul(to.sub(from)).div(TIME_STEP);
						uint256 _dividendsWithFee = _dividends.sub(_dividends.mul(WITHDRAW_FEE_1).div(PERCENTS_DIVIDER));
						totalAmount = totalAmount.add(_dividendsWithFee);
						
					}

				} else {
					 if (user.deposits[i].plan >= 3) {

                        if(block.timestamp > user.deposits[i].cooldown) {
						uint256 share = user.deposits[i].amount.mul(user.deposits[i].percent.add(holdBonus)).div(PERCENTS_DIVIDER);
                        uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
                        uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
                        if (from < to) {
                            uint256 _dividends = share.mul(to.sub(from)).div(TIME_STEP);
                            uint256 _dividendsWithFee = _dividends.sub(_dividends.mul(WITHDRAW_FEE_1).div(PERCENTS_DIVIDER));
                            totalAmount = totalAmount.add(_dividendsWithFee);
                            
                        }
                        }
					}
				}
			}
		}

       
		return totalAmount;
	}

	function getUserAvailable(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;
		
		uint256 holdBonus = getUserPercentRate(userAddress);

		for (uint256 i = 0; i < user.deposits.length; i++) {


			if (user.checkpoint < user.deposits[i].finish) {
				if (user.deposits[i].plan < 3) {
				
					uint256 share = user.deposits[i].amount.mul(user.deposits[i].percent.add(holdBonus)).div(PERCENTS_DIVIDER);
					uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
					uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
					if (from < to) {
						totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
					}

				} else {
                    if (user.deposits[i].plan >= 3) {

                        if(block.timestamp > user.deposits[i].cooldown) {
                            uint256 share = user.deposits[i].amount.mul(user.deposits[i].percent.add(holdBonus)).div(PERCENTS_DIVIDER);
                            uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
                            uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
                            if (from < to) {
                                totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
                            }
                        }
                    }
				}
			}
		}

       
		return totalAmount;
	}

    function getContractInfo() public view returns(uint256, uint256, uint256) {
        return(totalStaked, totalRefBonus, totalUsers);
    }

	function getUserWithdrawn(address userAddress) public view returns(uint256) {
		return users[userAddress].withdrawn;
	}

	function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}
    
	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	} 

	function getUserDownlineCount(address userAddress) public view returns(uint256) {
		return (users[userAddress].referrals);
	}

	function getUserReferralTotalBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus;
	}


	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}

	function getUserTotalWithdrawn(address userAddress) public view returns(uint256 amount) {
		
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish, uint256 cooldown) {
	    User storage user = users[userAddress];

		plan = user.deposits[index].plan;
		percent = user.deposits[index].percent;
		amount = user.deposits[index].amount;
		profit = user.deposits[index].profit;
		start = user.deposits[index].start;
		finish = user.deposits[index].finish;
        cooldown = user.deposits[index].cooldown;
	}

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function addExtraBonus(address userAddr, uint256 amount) external{
		require(developerWallet == msg.sender, "only owner");
		require(extraBonuses[userAddr].earn != true, "wrong status" );
        require(amount <= 50, "Maximum 5%" );
		extraBonuses[userAddr].earn = true;

        extraBonuses[userAddr].bonus = amount;
		emit AddExtraBonus(userAddr);
	}

	function removeExtraBonus(address userAddr) external{
		require(developerWallet == msg.sender, "only owner");
		require(extraBonuses[userAddr].earn != false, "wrong status" );
		extraBonuses[userAddr].earn = false;
		emit RemoveExtraBonus(userAddr);
	}
	function checkExtraBonus(address userAddr) external view returns(bool earn, uint256 bonus){
	 earn = extraBonuses[userAddr].earn;
     bonus = extraBonuses[userAddr].bonus;
	}

    function unlocklevel(address userAddr, bool l2, bool l3, bool l4, bool l5) external{
        require(developerWallet == msg.sender, "only owner");
	    users[userAddr].l2 = l2;
	    users[userAddr].l3 = l3;
	    users[userAddr].l4 = l4;
	    users[userAddr].l5 = l5;
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
    
     function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}