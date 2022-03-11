/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

pragma solidity 0.5.10;

contract BNBInvestCommon11{
	using SafeMath for uint256;

	uint256[] public INVEST_MIN_AMOUNT = [0.001 ether]; 
	uint256[] public INVEST_MAX_AMOUNT = [1000 ether]; 

	uint256 public totalInvested;
	uint256 public totalUsers;

	struct Deposit {
		uint256 amount;
		uint256 start;
	}

	struct User {
		Deposit[] deposits;
        uint256 userid;
        address useraddress;
		uint256 withdrawn;
		uint256 walletBalanceAmount;
		uint256 checkpoint;
		uint bonus;
	}

	struct BetDeposit{
		address plan;
		uint256 amount;	
		uint256 start;	
	}

	struct BetUser{
		BetDeposit[] betdeposits;
	}

	uint256 constant public TIME_STEP = 1 days;

	mapping (address => User) internal users;

	mapping (address => BetUser) internal betusers;	
	
	event NewDeposit(address indexed user, uint256 amount, uint256 time);
	event Withdrawn(address indexed user, uint256 amount, uint256 time);

	function invest(uint8 depositamount) public payable {
		require(msg.value >= INVEST_MIN_AMOUNT[depositamount],"invalid min amount");
		require(msg.value <= INVEST_MAX_AMOUNT[depositamount],"invalid max amount");

		User storage user = users[msg.sender];

		user.deposits.push(Deposit(msg.value, block.timestamp));

		totalInvested = totalInvested.add(msg.value);

        totalUsers=totalUsers.add(1);

        user.userid = totalUsers;

        user.useraddress = msg.sender;

		user.walletBalanceAmount = user.walletBalanceAmount.add(msg.value);
		
		emit NewDeposit(msg.sender, msg.value, block.timestamp);
	}

	function betplaydata(address useraddress) public payable {
		BetUser storage betuser = betusers[useraddress];    
		betuser.betdeposits.push(BetDeposit(useraddress, msg.value, block.timestamp));
	}

	function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawn;
	}

	function getUserMainWalletBalance(address userAddress) public view returns (uint256) {
		return users[userAddress].walletBalanceAmount;
	}

	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
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

	function withdraw() public {
		User storage user = users[msg.sender];

		require(user.checkpoint.add(TIME_STEP) < block.timestamp, "only once a day");

		uint256 totalAmount = walletBalance(msg.sender);

		require(totalAmount > 0, "User has no withdrawal balance");

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			user.bonus = totalAmount.sub(contractBalance);
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;
		user.withdrawn = user.withdrawn.add(totalAmount);

		msg.sender.transfer(totalAmount);

		emit Withdrawn(msg.sender, totalAmount, block.timestamp);
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