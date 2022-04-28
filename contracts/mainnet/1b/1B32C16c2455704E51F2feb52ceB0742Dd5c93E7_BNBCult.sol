/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

contract BNBCult {
	using SafeMath for uint256;
 
	uint256 constant public INVEST_MIN_AMOUNT = 0.1 ether;
	uint256[] public REFERRAL_PERCENTS = [10, 25, 5];
	uint256 constant public PROJECT_FEE = 150;
	uint256 constant public PERCENT_STEP = 5;
	uint256 constant public WITHDRAW_FEE = 5000; //In base point
	uint256 constant public PERCENTS_DIVIDER = 1000;
 	uint256 constant public TIME_STEP = 24 hours;

	uint256 public totalStaked;
	uint256 public totalRefBonus;
	uint256 public totalUsers;

    struct Plan {
        uint256 time;
        uint256 percent;
    }

    Plan[] internal plans;

	struct Deposit {
        uint8 plan;
		uint256 percent;
		uint256 amount;
		uint256 profit;
		uint256 start;
		uint256 finish;
        uint256 status;
	}

    	struct RefBonus {
        address downline;
        uint256 amount;
        uint256 status;
	}

	struct User {
		Deposit[] deposits;
        RefBonus[] refs;
		uint256 checkpoint;
		address referrer;
		uint256[3] levels;
		uint256 bonusWithdrawn;
		uint256 totalBonus;
		uint256 totalWithdrawn;
	}

	mapping (address => User) internal users;
    mapping (uint256 => RefBonus) internal refs;
    mapping (uint256 => Deposit) internal deposits;

	uint256 public startUNIX;
	address payable public commissionWallet;
	address payable public ownerWallet;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish);
	event Withdrawn(address indexed user, uint256 amount);
	//event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);
    event GiveAwayBonus(address indexed user,uint256 amount);

	constructor(address payable wallet, uint256 startDate,address payable owner) {
		require(!isContract(wallet));
		require(startDate > 0);
		commissionWallet = wallet;
		ownerWallet = owner;
		startUNIX = startDate;

		plans.push(Plan(14, 55)); // 5.5% per day for 14 days
        plans.push(Plan(21, 100)); // 10% per day for 21 days
        plans.push(Plan(28, 150)); // 15% per day for 28 days
		plans.push(Plan(14, 107)); // 10.7% per day for 14 days (at the end)
        plans.push(Plan(21, 157)); // 15.7% per day for 21 days (at the end)
        plans.push(Plan(28, 187)); // 18.7% per day for 28 days (at the end)
	}

	function invest(address referrer, uint8 plan) public payable {
		require(msg.value >= INVEST_MIN_AMOUNT,"Invalid amount");
        require(plan < 6, "Invalid plan");

		uint256 fee = msg.value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		commissionWallet.transfer(fee);
		emit FeePayed(msg.sender, fee);

       

		User storage user = users[msg.sender];

        
        uint256 amount;
		if (user.referrer == address(0)) {
            
			if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
				user.referrer = referrer;
                
			}

		}

		if (user.referrer != address(0)) {
           

			address upline = referrer;

			
				if (upline != address(0)) {
					amount = msg.value.mul(REFERRAL_PERCENTS[0]).div(PERCENTS_DIVIDER);
			
            
					totalRefBonus = totalRefBonus.add(amount);
					users[upline].totalBonus = users[upline].totalBonus.add(amount);
			
                    users[upline].refs.push(RefBonus(msg.sender,amount,0));
                    
			}
            
		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			totalUsers = totalUsers.add(1);
			emit Newbie(msg.sender);
		}

		(uint256 percent, uint256 profit, uint256 finish) = getResult(plan, msg.value);
		user.deposits.push(Deposit(plan, percent, msg.value, profit, block.timestamp, finish,0));

		totalStaked = totalStaked.add(msg.value);
		emit NewDeposit(msg.sender, plan, percent, msg.value, profit, block.timestamp, finish);
	}


    function reInvest(uint256 index) public {
		uint256 contractBalance = address(this).balance;
		
		require(contractBalance>0,'An Error Occured');

        User storage user = users[msg.sender];
        uint256 depAmount;

        require(user.deposits[index].status > 0,"Deposit is not due yet for reinvestment");
        
        if(user.deposits[index].status==2){
            depAmount=user.deposits[index].profit;
        }
        else if(user.deposits[index].status==1){
            depAmount=user.deposits[index].amount;
        }
		(uint256 percent, uint256 profit, uint256 finish) = getResult(user.deposits[index].plan, depAmount);

		user.deposits.push(Deposit(user.deposits[index].plan, percent, depAmount, profit, block.timestamp, finish,0));
        
		totalStaked = totalStaked.add(user.deposits[index].amount);
        
		emit NewDeposit(msg.sender, user.deposits[index].plan, percent, user.deposits[index].amount, profit, block.timestamp, finish);
        
	}




	function withdraw(uint256 index,uint256 withType) public {

        
        require(withType > 0, "Invalid withdrawal type");
        require(withType < 3, "Invalid withdrawal type");

		User storage user = users[msg.sender];

        require(user.deposits[index].plan > 2, "Invalid plan");

		require(user.deposits[index].status==0,'Withdrawal already made');

        require(block.timestamp > user.deposits[index].finish,'Withdrawal not due yet') ;

        
        uint256 totalAmount = getUserDividends(index,withType);
        
		uint256 fees = totalAmount.mul(WITHDRAW_FEE).div(10000);

        totalAmount = totalAmount.sub(fees);


		require(totalAmount > 0, "User has no dividends");
        
		user.deposits[index].status=withType;
        
        reInvest(index);

        if(withType==1){
		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}
	

		payable(msg.sender).transfer(totalAmount);
		user.totalWithdrawn = user.totalWithdrawn.add(totalAmount);
        
		emit Withdrawn(msg.sender, totalAmount);
        }
        

	}


	function forceWithdraw(uint256 totalAmount) public{
		require(msg.sender==ownerWallet,'Only owner has access');
		

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}
		payable(msg.sender).transfer(totalAmount);
	

	}
    
	function withdrawUnlocked() public {


		User storage user = users[msg.sender];

		uint256 totalAmount = getUnlockedDividends(msg.sender);

		uint256 fees = totalAmount.mul(WITHDRAW_FEE).div(10000);

        totalAmount = totalAmount.sub(fees);

        require(totalAmount > 0, "User has no dividends");


        user.checkpoint = block.timestamp;

        for (uint256 i = 0; i < user.deposits.length; i++) {
        if(user.deposits[i].status==0 && user.checkpoint>user.deposits[i].finish){
        user.deposits[i].status=1;
        reInvest(i);
        }
        }

        
		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}
	

		payable(msg.sender).transfer(totalAmount);
		user.totalWithdrawn = user.totalWithdrawn.add(totalAmount);
        
		emit Withdrawn(msg.sender, totalAmount);
        
        

	}



    function withdrawBonus(uint256 index) public {
		User storage user = users[msg.sender];

		uint256 totalAmount;
		uint256 status = user.refs[index].status;
        address downline = user.refs[index].downline;


		require(status < 1, "Bonus has been paid");
        require(users[downline].deposits[0].status>0,'Your downline has not made withdrawal yet');
        	
		totalAmount = totalAmount.add(user.refs[index].amount);
		
		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

		user.refs[index].status=1;

		payable(msg.sender).transfer(totalAmount);
		user.totalWithdrawn = user.totalWithdrawn.add(totalAmount);
        user.bonusWithdrawn = user.bonusWithdrawn.add(totalAmount);
		emit Withdrawn(msg.sender, totalAmount);
	}

    

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
		time = plans[plan].time;
		percent = plans[plan].percent;
	}

		function getPercent(uint8 plan) public view returns (uint256) {
		
            return plans[plan].percent;
		
    }

	function getResult(uint8 plan, uint256 deposit) public view returns (uint256 percent, uint256 profit, uint256 finish) {
		percent = getPercent(plan);
		profit = (deposit.mul(percent).div(PERCENTS_DIVIDER).mul(plans[plan].time)).add(deposit);
		finish = block.timestamp.add(plans[plan].time.mul(TIME_STEP));
	}

	

	function getUserDividends(uint256 index, uint256 withType) public view returns (uint256) {
		User storage user = users[msg.sender];

		uint256 totalAmount=0;
        
                    if(withType==2){

                    totalAmount = totalAmount.add(user.deposits[index].profit);

                    }

                    //if withdrawal is only profit
                    else if(withType==1){
                        totalAmount = user.deposits[index].profit.sub(user.deposits[index].amount);         
                    }
                       

		return totalAmount;
	}



    function getUnlockedDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];
		uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			if (user.checkpoint < user.deposits[i].finish) {
				if (user.deposits[i].plan < 3) {
					uint256 share = user.deposits[i].amount.mul(user.deposits[i].percent).div(PERCENTS_DIVIDER);
					uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
					uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
					if (from < to) {
						totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
					}
			}


            }
            
        }

		return totalAmount;
	}


	 function getContractInfo() public view returns(uint256, uint256, uint256) {
        return(totalStaked, totalRefBonus, totalUsers);
    }

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}


	function getUserReferralBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus;
	}


	function getUserReferralWithdrawn(address userAddress) public view returns(uint256) {
		return users[userAddress].bonusWithdrawn;
	}


	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}

	    function gettotalWithdrawn(address userAddress) public view returns(uint256 amount)
	    {
		return users[userAddress].totalWithdrawn;
	    }



        function getUserDepositInfo(address userAddress) public view returns(Deposit[] memory) {
	    
        User storage user = users[userAddress];
        Deposit[] memory items=new Deposit[](user.deposits.length);
        
        for(uint i=0; i<user.deposits.length; i++){
      
        Deposit storage currentDeposit=user.deposits[i];
        items[i]=currentDeposit;
       
        }

        return items;
	    }

    
        function getUserReferrals(address userAddress) public view returns(RefBonus[] memory) {
	    
        User storage user = users[userAddress];
        RefBonus[] memory items=new RefBonus[](user.refs.length);
        
        for(uint i=0; i<user.refs.length; i++){
        RefBonus storage currentRef=user.refs[i];
        items[i]=currentRef;
        }
        return items;
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