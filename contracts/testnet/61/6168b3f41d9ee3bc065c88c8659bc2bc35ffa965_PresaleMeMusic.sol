/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.10;

contract PresaleMeMusic{
	using SafeMath for uint256;
    uint private constant DURATION = 7 days;
	uint256 constant public PERCENTS_DIVIDER = 100;

	uint256 public totalInvested;
	uint256 public totalUsers;

    uint256 public nft_id;
    address public nft_address;
    uint256 public price;
    uint256 public sellnftshare;
    uint256 public startDate;
    uint256 public endDate;

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

	mapping(address => uint256) public balanceOf;

	mapping (address => User) internal users;

	event NewDeposit(address indexed user, uint256 amount, uint256 time);
	event Withdrawn(address indexed user, uint256 amount, uint256 time);

	constructor(
                uint256 nftid,
                address nftaddress,
                uint256 nftprice,
                uint256 sell_nft_share,
                uint256 start
                ) {
    		require(!isContract(nftaddress));
			nft_address = nftaddress;

            start = block.timestamp;
            endDate = block.timestamp + DURATION;
			price=nftprice;
            sellnftshare=sell_nft_share;
            nft_id=nftid;
			
		}

	function deposit() public payable {

       balanceOf[msg.sender] += msg.value;

		User storage user = users[msg.sender];

		user.deposits.push(Deposit(msg.value, block.timestamp));

		totalInvested = totalInvested.add(msg.value);

        totalUsers=totalUsers.add(1);

        user.userid = totalUsers;

        user.useraddress = msg.sender;

		user.walletBalanceAmount = user.walletBalanceAmount.add(msg.value);
		
		emit NewDeposit(msg.sender, msg.value, block.timestamp);
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
		uint256 totalwallet_balance  = balanceOf[userAddress];
		return totalwallet_balance;
	}

		
	function withdraw(uint256 withdrawalamount) public payable{
        require(withdrawalamount <= balanceOf[msg.sender]);
        balanceOf[msg.sender] -= withdrawalamount;

        address payable to = payable(msg.sender);
        to.transfer(withdrawalamount);
        //msg.sender.transfer(msg.value);
		User storage user = users[msg.sender];
		user.withdrawn = user.withdrawn.add(withdrawalamount);       
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

    function randomno(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: randomno by zero");
        uint256 c = a / b;

        return c;
    }
}