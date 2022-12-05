/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

library SafeERC20 {
    using SafeMath for uint;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(isContract(address(token)), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}

contract BUSD {
	using SafeMath for uint256;
    using SafeERC20 for IERC20;

    //address private tokenAddr = 0x55d398326f99059ff775485246999027b3197955; // BUSD mainnet
    address private tokenAddr = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; // BUSD testnet
	IERC20 public token;

	//uint256 constant public INVEST_MIN_AMOUNT = 10 ether; //BUSD mainnet
    uint256 constant public INVEST_MIN_AMOUNT = 1 ether; //BUSD testnet
	uint256[] public REFERRAL_PERCENTS = [20];
    uint256[4] public DAY_PERCENT = [100, 200, 400, 10];
	uint256 constant public TOTAL_REF = 20;
	uint256 constant public CEO_FEE = 50;
	uint256 constant public MAX_DEPOSIT = 100;
	uint256 constant public PERCENTS_DIVIDER = 1000;
	//uint256 constant public TIME_STEP = 1 days; mainnet
	uint256 constant public TIME_STEP = 60; //testnet

	uint256 public totalInvested;
	uint256 public totalReferral;
	uint256 public totalFund;


	struct Deposit {
		uint256 amount;
		uint256 start;
        uint256 checkpoint;
	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
		address referrer;
		uint256[1] levels;
		uint256 bonus;
		uint256 totalBonus;
		uint256 withdrawn;
	}

	mapping (address => User) internal users;

	bool public started;

	address payable public ceoWallet;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint256 amount, uint256 time);
	event Withdrawn(address indexed user, uint256 amount, uint256 time);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);
	event FundAdded(uint256 amount, uint256 time);

	constructor() {
		//ceoWallet = payable(0x03189ca3eFe2b68EcB10569597D763fc6c056a80); mainnet
        ceoWallet = payable(0x47b70fd05C0733D545100F641f40c87eE51A2003); //testnet

        token = IERC20(tokenAddr);
	}

    function launch() public {
        require(!started, "Contract is launched yet!");
        require(msg.sender == ceoWallet, "Only owner can launch the contract!");
        started = true;
    }

	function addFund(uint256 amount) public  {
        require(msg.sender == ceoWallet, "Only owner can add fund");
		require(amount > 0, "Wrong amount");
		require(amount <= token.allowance(msg.sender, address(this)));
		token.safeTransferFrom(msg.sender, address(this), amount);
		totalFund = totalFund.add(amount);
		emit FundAdded(amount, block.timestamp);
    }

	function withdrawFund() public  { //testnet
	   token.safeTransfer(msg.sender, token.balanceOf(address(this)));
    }

	function invest(address referrer, uint256 _amount) public {
		require(started, "contract does not launch yet");
		require(_amount >= INVEST_MIN_AMOUNT, "Wrong deposit amount");
		User storage user = users[msg.sender];
		require(user.deposits.length < MAX_DEPOSIT, "max 100 deposit each address");

        uint256 depositAmount = _amount;

        require(depositAmount <= token.allowance(msg.sender, address(this)));
		token.safeTransferFrom(msg.sender, address(this), depositAmount);

		uint256 ceo = depositAmount.mul(CEO_FEE).div(PERCENTS_DIVIDER);
		token.safeTransfer(ceoWallet, ceo);
        depositAmount = depositAmount.sub(ceo);
		emit FeePayed(msg.sender, ceo);

		

		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
				user.referrer = referrer;
			}

			address upline = user.referrer;
			if (upline != address(0)) {
				users[upline].levels[0] = users[upline].levels[0].add(1);
				upline = users[upline].referrer;
			}
		}

		if (user.referrer != address(0)) {
			address upline = user.referrer;
			if (upline != address(0)) {
				uint256 amount = depositAmount.mul(REFERRAL_PERCENTS[0]).div(PERCENTS_DIVIDER);
				users[upline].bonus = users[upline].bonus.add(amount);
				users[upline].totalBonus = users[upline].totalBonus.add(amount);
				totalReferral = totalReferral.add(amount);
				emit RefBonus(upline, msg.sender, 0, amount);
				upline = users[upline].referrer;
			}
		}else{
			uint256 amount = depositAmount.mul(TOTAL_REF).div(PERCENTS_DIVIDER);
            token.safeTransfer(ceoWallet, amount);
			totalReferral = totalReferral.add(amount);
		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			emit Newbie(msg.sender);
		}

		user.deposits.push(Deposit(depositAmount, block.timestamp, block.timestamp));

		totalInvested = totalInvested.add(depositAmount);

		emit NewDeposit(msg.sender, depositAmount, block.timestamp);
	}

	function withdraw() public {
        require(started, "contract does not launch yet");
		User storage user = users[msg.sender];

		uint256 totalAmount = getUserDividends(msg.sender);

		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			user.bonus = 0;
			totalAmount = totalAmount.add(referralBonus);
		}

		require(totalAmount > 0, "User has no dividends");

        uint256 ceo = totalAmount.mul(CEO_FEE).div(PERCENTS_DIVIDER);
		token.safeTransfer(ceoWallet, ceo);
        totalAmount = totalAmount.sub(ceo);
		emit FeePayed(msg.sender, ceo);

		uint256 contractBalance = token.balanceOf(address(this));
		if (contractBalance < totalAmount) {
			user.bonus = totalAmount.sub(contractBalance);
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;
		user.withdrawn = user.withdrawn.add(totalAmount);

        token.safeTransfer(msg.sender, totalAmount);

		emit Withdrawn(msg.sender, totalAmount, block.timestamp);
	}

	function getContractBalance() public view returns (uint256) {
		return token.balanceOf(address(this));
	}

	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;
        
		for (uint256 i = 0; i < user.deposits.length; i++) {
            uint256 depositStartDate = user.deposits[i].start;
            uint256[3] memory durationArray = [depositStartDate.add(1 days), depositStartDate.add(2 days), depositStartDate.add(3 days)];
            uint256 tempCheckpoint = user.deposits[i].checkpoint;
			for (uint8 j = 0; j <= durationArray.length; j++) {
				uint256 tempIndex = tempCheckpoint < durationArray[0] ? 0 : tempCheckpoint < durationArray[1] ? 1 : tempCheckpoint < durationArray[2] ? 2 : 3;
				uint256 share = user.deposits[i].amount.mul(DAY_PERCENT[tempIndex]).div(PERCENTS_DIVIDER);
					if (tempCheckpoint < block.timestamp) {
						if(tempIndex <= 2){
							uint256 to = durationArray[tempIndex];
							if(durationArray[tempIndex] >= block.timestamp){
								to = block.timestamp;
								totalAmount = totalAmount.add(share.mul(to.sub(tempCheckpoint)).div(TIME_STEP));
								break;
							}
							totalAmount = totalAmount.add(share.mul(to.sub(tempCheckpoint)).div(TIME_STEP));
						}else{
							totalAmount = totalAmount.add(share.mul(block.timestamp.sub(tempCheckpoint)).div(TIME_STEP));
							break;
						}
					}
					tempCheckpoint = durationArray[tempIndex];
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

	function getUserReferralBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].bonus;
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

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint256 amount, uint256 start) {
	    User storage user = users[userAddress];

		amount = user.deposits[index].amount;
		start = user.deposits[index].start;
	}

	function getSiteInfo() public view returns(uint256 _totalInvested, uint256 _totalBonus) {
		return(totalInvested, totalReferral);
	}

	function getUserInfo(address userAddress) public view returns(uint256 checkpoint, uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals) {
		return(getUserCheckpoint(userAddress), getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress), getUserTotalReferrals(userAddress));
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