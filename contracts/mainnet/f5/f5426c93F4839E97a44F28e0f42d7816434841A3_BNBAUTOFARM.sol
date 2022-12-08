/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

interface IBEP20 {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

 
  function name() external view returns (string memory);


  function getOwner() external view returns (address);

 
  function balanceOf(address account) external view returns (uint256);

  
  function transfer(address recipient, uint256 amount) external returns (bool);

  
  function allowance(address _owner, address spender) external view returns (uint256);


  function approve(address spender, uint256 amount) external returns (bool);


  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

 
  event Transfer(address indexed from, address indexed to, uint256 value);


  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BNBAUTOFARM {
	using SafeMath for uint256;
	
	IBEP20 public BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); 
    IBEP20 public BAF_TOKEN;

	uint256 constant public INVEST_MIN_AMOUNT = 0.01 ether; //0.01 BNB
	uint256 constant public PROJECT_FEE = 45;
	uint256 constant public DEVELOPER_FEE = 20;
	uint256 constant public MARKETING_FEE = 35;
	uint256 constant public PERCENTS_DIVIDER = 1000;
	uint256 constant public TIME_STEP = 1 days;
	
	uint256 constant public WITHDRAWAL_LOTTERY_FEE = 25;
	uint256 constant public STAKE_LOTTERY_FEE = 5;

    uint256[] public PLAN_UNLOCK_TIME = [0 days, 2 days, 4 days, 6 days, 8 days, 10 days];
    uint256[] public PLAN_STAKE_BONUS = [10, 20, 30, 40, 50, 100];

    uint256[] public TOKENS_AIRDROP_PERCENTS = [20, 40, 60, 80, 100, 120];
	
	
	uint256[] public REFERRAL_PERCENTS = [40, 30, 15, 10, 5, 5, 3, 2, 2, 1];
	
	uint256 public constant BNB_PER_TICKET = 1e16; // 0.01 BNB
    uint256 public lotteryRound = 0;
    uint256 public currentPot = 0;
    uint256 public participants = 0;
    uint256 public totalTickets = 0;
    uint256 public LOTTERY_STEP = 6 hours; 
    uint256 public LOTTERY_START_TIME;
    
    uint256 public constant STAKE_MIN_AMOUNT = 5e18; // 5 BUSD
    uint256 public constant FINE_TIME = 3 days;

    uint256 public constant REINVEST_MIN_AMOUNT = 0.001 ether;

    uint256 public constant REINVEST_CASHBACK = 50;
	
	
	
    uint256 public totalStaked;
    uint256 public totalBusdStaked;
	uint256 public totalDeposits;
	uint256 public totalReferralEarned;

	uint256 public bafStaked;
    
    uint256 public bnbFee;

    uint256 FEE_HISTORY_UPDATE_TIME;

    struct Plan {
        uint256 time;
        uint256 percent;
    }

    Plan[] internal plans;
	Plan[] internal bafStakingPlans;

	struct Deposit {
        uint8 plan;
		uint256 percent;
		uint256 amount;
		uint256 profit;
		uint256 start;
		uint256 finish;
	}

	struct User {
		Deposit[] deposits;
		Deposit[] bafDeposits;
		uint256 bafCheckpoint;
		uint256 checkpoint;
		address payable referrer;
		uint256 referrals;
		uint256 totalBonus;
		uint256 refRewards;
		uint256 lotteryRewards;
		uint256 busdStaked;
		uint256 feeCheckpoint;
		uint256 busdStakeCheckpoint;
        uint256 bafTokensToClaim;
	}

	mapping (address => User) internal users;
	
	uint256[] public projectFeeHistory;
	
    mapping(uint256 => mapping(address => uint256)) public ticketOwners; // round => address => amount of owned tickets
    mapping(uint256 => mapping(uint256 => address)) public participantAdresses; // round => id => address

	uint256 public startUNIX;
	address payable private commissionWallet;
	address payable private developerWallet;
	address payable public marketingWallet;

    bool public launched = false;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish);
	
	event Withdrawn(address indexed user, uint256 amount);
	
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event onLotteryWinner(address indexed investor, uint256 pot, uint256 indexed round);
	

	constructor(address payable wallet, address payable _developer, address payable _marketing, IBEP20 BAF_TOKEN_ADDRESS) public {
		commissionWallet = wallet;
		developerWallet = _developer;
		marketingWallet = _marketing;

        BAF_TOKEN = BAF_TOKEN_ADDRESS;
		
		FEE_HISTORY_UPDATE_TIME = block.timestamp.add(365 days);
		startUNIX = block.timestamp.add(365 days);
		LOTTERY_START_TIME = block.timestamp.add(365 days);

        plans.push(Plan(30, 40)); // 4% per day for 30 days
        plans.push(Plan(25, 50)); // 5% per day for 25 days
        plans.push(Plan(20, 65)); // 6.5% per day for 20 days 
        plans.push(Plan(18, 80)); // 8% per day for 18 days 
        plans.push(Plan(15, 100)); // 10% per day for 15 days 
        plans.push(Plan(10, 150)); // 15% per day for 10 days 

		bafStakingPlans.push(Plan(365, 30)); // 3% per day for 365 days
	}


function launch() public {
	require(msg.sender == developerWallet, "only dev");
    if(!launched) {

        startUNIX = block.timestamp;
        FEE_HISTORY_UPDATE_TIME = block.timestamp;
        LOTTERY_START_TIME = block.timestamp;
        launched = true;
    }
}

function isPlanAvailable(uint8 plan) private view returns(bool){

    uint256 deltaTime = block.timestamp.sub(startUNIX);

    if(PLAN_UNLOCK_TIME[plan] <= deltaTime ) {

        return true;

    } else {

        return false;
    }

}


function invest(address payable referrer,uint8 plan) public payable {
        _invest(referrer, plan, payable(msg.sender), msg.value,false);
           
    }


	function _invest(address payable referrer, uint8 plan, address payable sender, uint256 value, bool reinvest) private {
		
        if(!reinvest) {
            require(value >= INVEST_MIN_AMOUNT);
        }
        require(plan < 6, "Invalid plan");
        require(startUNIX < block.timestamp, "not launched");
        require(isPlanAvailable(plan), "not available");

        
        value = value.add(value.mul(PLAN_STAKE_BONUS[plan]).div(PERCENTS_DIVIDER));

        
        
		uint256 fee = value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		commissionWallet.transfer(fee);
		uint256 developerFee = value.mul(DEVELOPER_FEE).div(PERCENTS_DIVIDER);
		developerWallet.transfer(developerFee);
		uint256 marketingFee = value.mul(MARKETING_FEE).div(PERCENTS_DIVIDER);
		marketingWallet.transfer(marketingFee);
		
		
		User storage user = users[sender];

		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != sender) {
				user.referrer = referrer;
			}

			address upline = user.referrer;
			for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) { 
				if (upline != address(0)) {
					users[upline].referrals = users[upline].referrals.add(1);
					upline = users[upline].referrer;
				} else break;
			}
		}

            _countRefRewards(sender, value);
	

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			
			
			emit Newbie(sender);
		}

		(uint256 percent, uint256 profit, uint256 finish) = getResult(plan, value);
		
		
		user.deposits.push(Deposit(plan, percent, value, profit, block.timestamp, finish));

		totalStaked = totalStaked.add(value);
		totalDeposits = totalDeposits.add(1);
		
		uint256 amountForLottery = value.mul(STAKE_LOTTERY_FEE).div(PERCENTS_DIVIDER);
 		
 		_buyTickets(sender, amountForLottery);
 		
 		bnbFee = bnbFee.add(value.mul(5).div(1000)); // 0.5%

        user.bafTokensToClaim = value.mul(TOKENS_AIRDROP_PERCENTS[plan]).div(PERCENTS_DIVIDER);
 		
 		checkFeeHistoryUpdate();
		
		emit NewDeposit(sender, plan, percent, value, profit, block.timestamp, finish);
	}

    function reInvest(address payable referrer) public payable {

        uint256 totalAmount = getUserDividends(msg.sender);

        require(totalAmount >= REINVEST_MIN_AMOUNT, "Invalid amount");

        User storage user = users[msg.sender];

		user.checkpoint = block.timestamp;

        uint8 plan = getLastAvailablePlan();

		_invest(referrer, plan, payable(msg.sender), totalAmount,true);

        uint256 cashback = totalAmount.mul(REINVEST_CASHBACK).div(PERCENTS_DIVIDER);

        payable(msg.sender).transfer(cashback);

    }

	function stakeBafTokens(uint256 bafAmount) public {
		require(getUserTotalDeposits(msg.sender) > 0, "no deposits");
		require(BAF_TOKEN.balanceOf(msg.sender) >= bafAmount, "Insuff. BAF balance");

		BAF_TOKEN.transferFrom(msg.sender, address(this), bafAmount);

		User storage user = users[msg.sender];

		user.bafCheckpoint = block.timestamp;

		uint256 percent = bafStakingPlans[0].percent;

		uint256 profit = bafAmount.mul(percent).div(PERCENTS_DIVIDER).mul(bafStakingPlans[0].time);

		uint256 finish = block.timestamp.add(bafStakingPlans[0].time.mul(TIME_STEP));

		user.bafDeposits.push(Deposit(0, percent, bafAmount, profit, block.timestamp, finish));

		bafStaked = bafStaked.add(bafAmount);




	}

	function withdrawBafDividends() public {

		User storage user = users[msg.sender];

		uint256 totalAmount = getUserBafDividends(msg.sender);

		require(totalAmount > 0, "No divs");

		user.bafCheckpoint = block.timestamp;

		BAF_TOKEN.transfer(msg.sender,totalAmount);
		

	}

	function unstakeBafTokens() public {

		User storage user = users[msg.sender];

		uint256 unstakedAmount;

		for (uint256 i = 0; i < user.bafDeposits.length; i++) {
			if (user.bafCheckpoint < user.bafDeposits[i].finish) {

				
					unstakedAmount = unstakedAmount.add(user.bafDeposits[i].amount);
					user.bafDeposits[i].finish = user.bafCheckpoint;
				
				
			}
		}

		require(unstakedAmount > 0, "zero amount");

		BAF_TOKEN.transfer(msg.sender, unstakedAmount);

		user.bafCheckpoint = block.timestamp;

    bafStaked = bafStaked.sub(unstakedAmount);



	}

	// 1 BAF = 1 BNB
	function sellBafTokens(uint256 amountToSell) public { 
		require(BAF_TOKEN.balanceOf(msg.sender) >= amountToSell, "Insuff. BAF bal.");
		require(amountToSell > 0, "zero amount");

		BAF_TOKEN.transferFrom(msg.sender, address(this), amountToSell);

		uint256 fee = amountToSell.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		commissionWallet.transfer(fee);
		uint256 developerFee = amountToSell.mul(DEVELOPER_FEE).div(PERCENTS_DIVIDER);
		developerWallet.transfer(developerFee);
		uint256 marketingFee = amountToSell.mul(MARKETING_FEE).div(PERCENTS_DIVIDER);
		marketingWallet.transfer(marketingFee);

		payable(msg.sender).transfer(amountToSell);


	}



    function claimBafTokens() public {

        User storage user = users[msg.sender];

        require(user.bafTokensToClaim > 0, "Insuff. BAF bal.");

        uint256 amount = user.bafTokensToClaim;

        user.bafTokensToClaim = 0;

        BAF_TOKEN.transfer(msg.sender, amount);
    }

    function getLastAvailablePlan() private view returns(uint8) {

        for(uint8 i = 5; i >= 0; i--){
            if(isPlanAvailable(i)) {
                return i;
            }
        }
    }
	
	function stake(uint256 busdAmount) public {
	    require(busdAmount >= STAKE_MIN_AMOUNT, "Min. is 5 BUSD");
        require(BUSD.balanceOf(msg.sender) >= busdAmount, "Insuff. busd bal.");
	    
	    uint256 totalBnbDeposits = getUserTotalDeposits(msg.sender);
	    uint256 availableBusdStake = totalBnbDeposits.mul(300).sub(users[msg.sender].busdStaked);
	    
	    require(busdAmount <= availableBusdStake, "limit is exceeded");

		BUSD.transferFrom(msg.sender,address(this),busdAmount);
	    
	    uint256 fee = busdAmount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		BUSD.transfer(commissionWallet,fee);
		uint256 developerFee = busdAmount.mul(DEVELOPER_FEE).div(PERCENTS_DIVIDER);
		BUSD.transfer(developerWallet,developerFee);
		uint256 marketingFee = busdAmount.mul(MARKETING_FEE).div(PERCENTS_DIVIDER);
		BUSD.transfer(marketingWallet,marketingFee);
	    
	    User storage user = users[msg.sender];
	    
	    if(user.busdStaked > 0) { // already have deposit
	        uint256 rewards = getBnbDividends(msg.sender);

            if(getContractBalance() < rewards) {
                rewards = getContractBalance();
            }

	        payable(msg.sender).transfer(rewards);
	    } 
	    
	    user.feeCheckpoint = bnbFee;
	    user.busdStaked = user.busdStaked.add(busdAmount);
	    user.busdStakeCheckpoint = block.timestamp;
	    
	    totalBusdStaked = totalBusdStaked.add(busdAmount);
	    
	    
	    
	}
	
	function claimBnbFee() public payable {
	    User storage user = users[msg.sender];
	    
	    uint256 rewards = getBnbDividends(msg.sender);
	    
	    require(rewards > 0, "nothing to claim");
	    
	    user.feeCheckpoint = bnbFee;

        if(getContractBalance() < rewards) {
            rewards = getContractBalance();
        }
	    
	    payable(msg.sender).transfer(rewards);
	    
	}
	
	function unstake() public payable {
	   User storage user = users[msg.sender];
	   
	   uint256 rewards = getBnbDividends(msg.sender);
	   
	   
	   
	   if(rewards > 0){

        if(getContractBalance() < rewards) {
            rewards = getContractBalance();
        }
	       payable(msg.sender).transfer(rewards);
	   }
	   
	   if(block.timestamp.sub(user.busdStakeCheckpoint) < FINE_TIME){
	       uint256 amount = user.busdStaked.mul(95).div(100);
	       if(amount > BUSD.balanceOf(address(this))){
	           amount = BUSD.balanceOf(address(this));
	       }
	       BUSD.transfer(msg.sender,amount);
	       
	   } else {
	       uint256 amount = user.busdStaked;
	       if(amount > BUSD.balanceOf(address(this))){
	           amount = BUSD.balanceOf(address(this));
	       }
	       BUSD.transfer(msg.sender,amount);
	       
	   }
	   
	   totalBusdStaked = totalBusdStaked.sub(user.busdStaked);
	   
	   user.busdStaked = 0;
	    
	   
	}
	
	function getBnbDividends(address userAddress) public view returns(uint256){
	    User storage user = users[userAddress];
	    
	    uint256 availableFee = bnbFee.sub(user.feeCheckpoint);
	    
	    return user.busdStaked.mul(availableFee).div(totalBusdStaked);
	}
	
	function _countRefRewards(address userAddress, uint256 value) private {
	        User storage user = users[userAddress];
	        
	        uint256 total = 0;
	        
	    	if (user.referrer != address(0)) {
			address payable upline = user.referrer;
			for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {  
				if (upline != address(0)) {
				
    					uint256 amount = value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
    					total = total.add(amount);
    					
    					users[upline].refRewards = users[upline].refRewards.add(amount);
				    
					
					upline = users[upline].referrer;
				} else break;
			}

		}
		
		totalReferralEarned = totalReferralEarned.add(total);
	}
	

	function withdraw() public {
		User storage user = users[msg.sender];

		uint256 totalAmount = getUserDividends(msg.sender);

		require(totalAmount > 0, "no dividends");

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;
		
 		uint256 amountForLottery = totalAmount.mul(WITHDRAWAL_LOTTERY_FEE).div(PERCENTS_DIVIDER);
 		
 		
 		_buyTickets(msg.sender, amountForLottery);
 		
 		uint256 commission = totalAmount.mul(25).div(1000); // 2.5%
 		
 		bnbFee = bnbFee.add(commission); // 2.5%
 		
 		totalAmount = totalAmount.sub(amountForLottery).sub(commission);
	

		payable(msg.sender).transfer(totalAmount);
		
		
		checkFeeHistoryUpdate();
		

		emit Withdrawn(msg.sender, totalAmount);

	}
	
	
	function withdrawRef() public {
	    User storage user = users[msg.sender];
	    require(user.refRewards > 0 , 'no rewards');
	    
	    uint256 value = user.refRewards;
	    user.refRewards = 0;
	    
	    uint256 amountForLottery = value.mul(WITHDRAWAL_LOTTERY_FEE).div(PERCENTS_DIVIDER);
	    
	    uint256 commission = value.mul(25).div(1000); // 2.5%
	    
	    bnbFee = bnbFee.add(commission);
 		
 		value = value.sub(amountForLottery).sub(commission);
 		
 		_buyTickets(msg.sender, amountForLottery);
	    
	    
	    payable(msg.sender).transfer(value);
	    
	    user.totalBonus = user.totalBonus.add(value);
	    
	    
	    
	   checkFeeHistoryUpdate();
	    
	}
	
	function claimLotteryReward() public {
        User storage user = users[msg.sender];
        require(user.lotteryRewards !=0, "Nothing to claim");
        
        uint256 amount = user.lotteryRewards;

		user.lotteryRewards = 0;
        
        payable(msg.sender).transfer(amount);
        
        
        
       
    }


      function _buyTickets(address userAddress, uint256 amount) private { // amount - BNB for purchase
    
        
        uint256 tickets = amount.mul(1e18).div(BNB_PER_TICKET);
        
        if(ticketOwners[lotteryRound][userAddress] == 0) {
            participantAdresses[lotteryRound][participants] = userAddress;
            participants = participants.add(1);
        }
        
        ticketOwners[lotteryRound][userAddress] = ticketOwners[lotteryRound][userAddress].add(tickets);
        currentPot = currentPot.add(amount);
        totalTickets = totalTickets.add(tickets);
        
        if(block.timestamp.sub(LOTTERY_START_TIME) >= LOTTERY_STEP || participants == 200){
            _chooseWinner();
        }
    }
    
    function _chooseWinner() private {
        
       uint256[] memory init_range = new uint256[](participants);
       uint256[] memory end_range = new uint256[](participants);
       
       uint256 last_range = 0;
       
       for(uint256 i = 0; i < participants; i++){
           uint256 range0 = last_range.add(1);
           uint256 range1 = range0.add(ticketOwners[lotteryRound][participantAdresses[lotteryRound][i]].div(1e18)); 
           
           init_range[i] = range0;
           end_range[i] = range1;
           
           last_range = range1;
       }
        
       uint256 random = _getRandom().mod(last_range).add(1); 
       
       for(uint256 i = 0; i < participants; i++){
           if((random >= init_range[i]) && (random <= end_range[i])){
               // winner found
               
               address winnerAddress = participantAdresses[lotteryRound][i];
               
               users[winnerAddress].lotteryRewards = users[winnerAddress].lotteryRewards.add(currentPot.mul(8).div(10));
               
               //fees and rewards
               
               uint256 fee = currentPot.mul(PROJECT_FEE).div(PERCENTS_DIVIDER); 
     		   commissionWallet.transfer(fee);
    		   uint256 developerFee = currentPot.mul(DEVELOPER_FEE).div(PERCENTS_DIVIDER); 
    		   developerWallet.transfer(developerFee);
    		   uint256 marketingFee = currentPot.mul(MARKETING_FEE).div(PERCENTS_DIVIDER); 
		       marketingWallet.transfer(marketingFee);
    		   
    		  
    		   
    		   bnbFee = bnbFee.add(currentPot.mul(10).div(100));
              
               // reset lotteryRound
               
                emit onLotteryWinner(winnerAddress, currentPot, lotteryRound);
               
               currentPot = 0;
               lotteryRound = lotteryRound.add(1);
               participants = 0;
               totalTickets = 0;
               LOTTERY_START_TIME = block.timestamp;
               
              

               break;
           }
       }
    }
    
    function checkFeeHistoryUpdate() public {
        if(block.timestamp.sub(FEE_HISTORY_UPDATE_TIME) >= 24 hours) {
            projectFeeHistory.push(bnbFee);
            FEE_HISTORY_UPDATE_TIME = block.timestamp;
        }
    }
    
    function _getRandom() private view returns(uint256){
        
        bytes32 _blockhash = blockhash(block.number-1);
        
        
        return uint256(keccak256(abi.encode(_blockhash,block.timestamp,currentPot,block.difficulty)));
    }
	

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function getPercent(uint8 plan) public view returns (uint256) {
	    
		return plans[plan].percent;
		
		
		
    }

	function getResult(uint8 plan, uint256 deposit) public view returns (uint256 percent, uint256 profit, uint256 finish) {
		percent = getPercent(plan);

	
		profit = deposit.mul(percent).div(PERCENTS_DIVIDER).mul(plans[plan].time);
	

		finish = block.timestamp.add(plans[plan].time.mul(TIME_STEP));
	}
	
    
	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;
		

		for (uint256 i = 0; i < user.deposits.length; i++) {
			if (user.checkpoint < user.deposits[i].finish) {

					    	uint256 share = user.deposits[i].amount.mul(user.deposits[i].percent).div(PERCENTS_DIVIDER);
        					uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
        					uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
        					if (from < to) {
        						totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
        					}
					
				
				
			}
		}

		return totalAmount;
	}

	function getUserBafDividends(address userAddress) public view returns(uint256) {

		User storage user = users[userAddress];

		uint256 totalAmount;
		

		for (uint256 i = 0; i < user.bafDeposits.length; i++) {
			if (user.bafCheckpoint < user.bafDeposits[i].finish) {

					    	uint256 share = user.bafDeposits[i].amount.mul(user.bafDeposits[i].percent).div(PERCENTS_DIVIDER);
        					uint256 from = user.bafDeposits[i].start > user.bafCheckpoint ? user.bafDeposits[i].start : user.bafCheckpoint;
        					uint256 to = user.bafDeposits[i].finish < block.timestamp ? user.bafDeposits[i].finish : block.timestamp;
        					if (from < to) {
        						totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
        					}
					
				
				
			}
		}

		return totalAmount;

	}

  function getContractInfo() public view returns(uint256[] memory FeeHistory, uint256 lotteryTimer, uint256 tStaked, uint256 totalBafStaked, uint256 tBusdStaked, uint256 tReferralEarned) {
    FeeHistory = projectFeeHistory;
    lotteryTimer = LOTTERY_START_TIME.add(LOTTERY_STEP);
    tStaked = totalStaked;
    totalBafStaked = bafStaked;
    tBusdStaked = totalBusdStaked;
    tReferralEarned = totalReferralEarned;
  }

	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}

	function getUserTotalBafDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].bafDeposits.length; i++) {
			if (users[userAddress].bafCheckpoint < users[userAddress].bafDeposits[i].finish) {
				amount = amount.add(users[userAddress].bafDeposits[i].amount);
			}
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

    function timeTillUnlock(uint8 plan) public view returns(uint256) {
        uint256 deltaTime = block.timestamp.sub(startUNIX);

        if(PLAN_UNLOCK_TIME[plan] >= deltaTime ) {
            return PLAN_UNLOCK_TIME[plan].sub(deltaTime);
        } else {
           return 0;
        }
    }



	function getUserInfo(address userAddress) public view returns(uint256 userBusdTimer,uint256 availableBusd, uint256 userTickets,uint256 bafTokensToClaim, uint256 availableLotteryRewards, uint256 busdStaked, uint256 refRewardsAvailable, uint256 referralTotal,address referrer,uint256 referrals){
		bafTokensToClaim = users[userAddress].bafTokensToClaim;
		availableLotteryRewards = users[userAddress].lotteryRewards;
		busdStaked = users[userAddress].busdStaked;
		refRewardsAvailable = users[userAddress].refRewards;
		referralTotal = users[userAddress].totalBonus;
		referrer = users[userAddress].referrer;
		referrals = users[userAddress].referrals;
    userTickets = ticketOwners[lotteryRound][userAddress];
    availableBusd = getUserTotalDeposits(userAddress).mul(300).sub(users[userAddress].busdStaked);
    userBusdTimer = block.timestamp.sub(users[userAddress].busdStakeCheckpoint);
	

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