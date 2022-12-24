/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

pragma solidity 0.5.10;

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

contract CryptoChainUSDT {
	using SafeMath for uint256;
	using SafeERC20 for IERC20;
	IERC20 public USDT;
	uint256[] public REFERRAL_PERCENTS = [100, 40, 30,20,10,10,20,30,40,100];
	uint256[] public BASE_CONDITION_AMOUNT = [0,250e18, 500e18, 1000e18,2000e18,3000e18,4000e18,5000e18,7000e18,10000e18];
	uint256[] public BASE_CONDITION_LEVEL = [0,2,3,4,5,6,7,8,9,10];
	uint256[] public PLAN_DAYS = [134,200];
	uint256[] public BASE_INTRESTS = [30,20];
	uint256 constant public PROJECT_FEE = 80;
	uint256 constant public DEV_FEE = 10;
	uint256 constant public PERCENTS_DIVIDER = 1000;
	uint256 constant public TIME_STEP = 1 days;
	uint256 public totalInvested;
	uint256 public totalRefferral;
    uint256 public WITHDRAW_MAX_AMOUNT = 1000e18;
    uint256 public WITHDRAW_MAX_AMOUNT_LEVEL1 = 50000e18;
    uint256 public MINWITHDRAW_LEVEL1 = 500e18;
    uint256 public WITHDRAW_MAX_AMOUNT_LEVEL2 = 250000e18;
    uint256 public MINWITHDRAW_LEVEL2 = 250e18;
	uint256 public WITHDRAW_MAX_AMOUNT_LEVEL3 = 500000e18;
    uint256 public MINWITHDRAW_LEVEL3 = 100e18;
	uint256 public INVEST_MIN_AMOUNT = 10e18;
	uint256 public MINWITHDRAW = 5e18;
	uint256 public INVEST_MAX_AMOUNT = 250e18;
    uint256 public INVEST_MAX_AMOUNT_2 = 2500e18;

	struct Deposit {
        uint256 intrest;
		uint256 amount;
		uint256 start;
		uint256 plandays;
        uint256 end;
	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
		address referrer;
		uint256 currentintrest;
		uint256[10] levels;
		uint256[10] levelinvestments;
		uint256 bonus;
		uint256 withdrawn;
		uint256 extrabalance;
		uint256 directbusiness;
	}
	mapping (address => User) internal users;

	uint256 public startDate;
	address payable public ceoWallet_deposit=0x280FFAAb66e09c5884D613Fe7B715b1cf1C57aA7;
	address payable public devWallet_deposit=0xE42AFc91691AC4D045E8c4Cd63408AC1fa09676b;
	address payable public devWallet2_deposit=0xDf994f5f2317d3E10EdaFc5A4ca55D61075621b7;
	address payable public ceoWallet_withdraw=0x307934b9C9537b1bAC432619ed799D1575408448;
	address payable public devWallet_withdraw=0xdaF94A35d1Cc6d7b3b1A03E7E74C6C8D9E4156c4;
	address payable public devWallet2_withdraw=0x008f0d9eAb9eA576BA3b23bF3346C1c95741b5C5;
	address payable public masterWallet=0xe12757BC774A12c37dc2770B121E59ebEA13c8BB;
	address public TokenContract=0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint256 plan, uint256 amount, uint256 time);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event RefBonusMiss(address parentaddress,uint256 reason,uint256 level,uint256 valuetobe,uint256 valueavailable);
    event LevBonusMiss(address parentaddress,uint256 reason,uint256 level,uint256 valuetobe,uint256 valueavailable);
	event FeePayed(address indexed user, uint256 totalAmount);

	constructor(uint256 start) public {
		USDT = IERC20(TokenContract);
        startDate = block.timestamp;
		if(start>0){
			startDate = start;
		}
		else{
			startDate = block.timestamp;
		}
		User storage user = users[masterWallet];
		user.checkpoint = block.timestamp;
		emit Newbie(masterWallet);
		user.currentintrest=BASE_INTRESTS[0];
		user.deposits.push(Deposit(user.currentintrest, 0, block.timestamp,0,block.timestamp));
	}
	
	function invest(address referrer, uint256 tokenAmount) public {
		require(block.timestamp > startDate, "contract does not launch yet");
		require(tokenAmount >= INVEST_MIN_AMOUNT,"error min");
		User storage user = users[msg.sender];
		require(((user.deposits.length == 0) && (tokenAmount <= INVEST_MAX_AMOUNT)) || (user.deposits.length > 0),"Max amount for first deposit is 1000");
        require(((user.deposits.length == 0) || (tokenAmount <= INVEST_MAX_AMOUNT_2)) ,"Max amount from second deposit is 2500");
        require(canuserredeposit(msg.sender), "You need to complete old ROI");
        require(tokenAmount <= USDT.allowance(msg.sender, address(this)),"Tokens not approved");
		USDT.safeTransferFrom(msg.sender, address(this), tokenAmount);
		uint256 pFee = tokenAmount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		uint256 dFee = tokenAmount.mul(DEV_FEE).div(PERCENTS_DIVIDER);
		USDT.safeTransfer(ceoWallet_deposit, pFee);
		USDT.safeTransfer(devWallet_deposit, dFee);
		USDT.safeTransfer(devWallet2_deposit, dFee);
		emit FeePayed(msg.sender, pFee.add(dFee).add(dFee));
		if ((user.referrer == address(0)) && (user.deposits.length==0)) 
		{
			if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
				user.referrer = referrer;
			}
			else
			{
				user.referrer = masterWallet;
			}
			address upline = user.referrer;
			for (uint256 i = 0; i < 10; i++) {
				if ((upline != address(0)) )
                {
					users[upline].levels[i] = users[upline].levels[i].add(1);		
					upline = users[upline].referrer;
				}
                else if(upline == address(0))
				{
					emit LevBonusMiss(upline,0,i,0,0);
					upline = users[upline].referrer;
					break;
				}
				else if(BASE_CONDITION_AMOUNT[i] > users[upline].directbusiness)
				{
					emit LevBonusMiss(upline,1,i,BASE_CONDITION_AMOUNT[i], users[upline].directbusiness);
					upline = users[upline].referrer;
				}
				else if(BASE_CONDITION_LEVEL[i] > users[upline].levels[0])
				{
					emit LevBonusMiss(upline,2,i,BASE_CONDITION_LEVEL[i],users[upline].levels[0]);
					upline = users[upline].referrer;
				}
			}
		}
		if (user.referrer != address(0)) {
			address upline = user.referrer;
			users[upline].directbusiness= users[upline].directbusiness+tokenAmount;		
            for (uint256 i = 0; i < 10; i++) {
				if ((canuserredeposit(upline) == false) && (upline != address(0)) && (BASE_CONDITION_AMOUNT[i] <= users[upline].directbusiness) && (BASE_CONDITION_LEVEL[i] <= users[upline].levels[0]))
                {
					uint256 amount = tokenAmount.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					amount=amount.min( (getUserTotalDeposits(upline).mul(2)).sub(user.withdrawn).sub(getUserAvailable(upline)));
					users[upline].bonus = users[upline].bonus.add(amount);
                    if((amount==0) || (canuserredeposit(upline)))
                    {
                        clearROI(upline);
                    }
					users[upline].levelinvestments[i] = users[upline].levelinvestments[i].add(tokenAmount);
					totalRefferral=totalRefferral.add(amount);
					emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
				}
				else if(upline == address(0))
				{
					emit RefBonusMiss(upline,0,i,0,0);
					upline = users[upline].referrer;
					break;
				}
				else if(BASE_CONDITION_AMOUNT[i] > users[upline].directbusiness)
				{
					emit RefBonusMiss(upline,1,i,BASE_CONDITION_AMOUNT[i], users[upline].directbusiness);
					upline = users[upline].referrer;
				}
				else if(BASE_CONDITION_LEVEL[i] > users[upline].levels[0])
				{
					emit RefBonusMiss(upline,2,i,BASE_CONDITION_LEVEL[i],users[upline].levels[0]);
					upline = users[upline].referrer;
				}
				else if(canuserredeposit(upline) == true)
				{
                    clearROI(upline);
					emit RefBonusMiss(upline,3,i,getUserTotalDeposits(upline).mul(2),getUserTotalWithdrawn(upline));
					upline = users[upline].referrer;
				}	
			}
		}
		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			emit Newbie(msg.sender);
			user.currentintrest=BASE_INTRESTS[0];
		}
		else
		{
			user.checkpoint = block.timestamp;
			user.currentintrest=BASE_INTRESTS[(user.deposits.length).min(BASE_INTRESTS.length-1)];
		}
        if(user.withdrawn >= getUserTotalDeposits(msg.sender).mul(2))
            clearROI(msg.sender);
		user.deposits.push(Deposit(user.currentintrest,tokenAmount,block.timestamp,PLAN_DAYS[(user.deposits.length).min(PLAN_DAYS.length-1)], (block.timestamp).add(PLAN_DAYS[(user.deposits.length).min(PLAN_DAYS.length-1)].mul(TIME_STEP))));
		totalInvested = totalInvested.add(tokenAmount);
		emit NewDeposit(msg.sender, user.currentintrest, tokenAmount, block.timestamp);
	}
	function withdraw() public {
		User storage user = users[msg.sender];
        require(user.checkpoint.add(TIME_STEP) < block.timestamp, "withdraw only once a day");
		uint256 totalAmount = getUserAvailable(msg.sender);
		require(totalAmount > 0, "User has no dividends");
		require(totalAmount > MINWITHDRAW, "Your balance less than min withdraw");
		require(canuserwithdraw(msg.sender), "You need to have referrals to withdraw");
        if (WITHDRAW_MAX_AMOUNT < totalAmount)
        {
            totalAmount=WITHDRAW_MAX_AMOUNT;
        }
        if ((WITHDRAW_MAX_AMOUNT_LEVEL1 < user.withdrawn) && (MINWITHDRAW_LEVEL1 < totalAmount))
        {
            totalAmount=MINWITHDRAW_LEVEL1;
        }
        if ((WITHDRAW_MAX_AMOUNT_LEVEL2 < user.withdrawn) && (MINWITHDRAW_LEVEL2 < totalAmount))
        {
            totalAmount=MINWITHDRAW_LEVEL2;
        }
		if ((WITHDRAW_MAX_AMOUNT_LEVEL3 < user.withdrawn) && (MINWITHDRAW_LEVEL3 < totalAmount))
        {
            totalAmount=MINWITHDRAW_LEVEL3;
        }
		uint256 contractBalance = getContractBalance();
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}
		user.checkpoint = block.timestamp;
		user.withdrawn = user.withdrawn.add(totalAmount);
        if(user.withdrawn >= getUserTotalDeposits(msg.sender).mul(2))
            clearROI(msg.sender);
        USDT.safeTransfer(devWallet_withdraw, totalAmount.mul(DEV_FEE).div(PERCENTS_DIVIDER));
        USDT.safeTransfer(devWallet2_withdraw, totalAmount.mul(DEV_FEE).div(PERCENTS_DIVIDER));
		USDT.safeTransfer(ceoWallet_withdraw, totalAmount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER));
        USDT.safeTransfer(msg.sender, totalAmount.sub(totalAmount.mul(DEV_FEE.add(PROJECT_FEE).add(DEV_FEE)).div(PERCENTS_DIVIDER)));
		emit Withdrawn(msg.sender, totalAmount);
	}
    function withdrawstatus(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];
        if(!(user.checkpoint.add(TIME_STEP) < block.timestamp))
        {
            //"withdraw only once a day"
            return 2;
        }
		uint256 totalAmount = getUserAvailable(userAddress);
		if(!(totalAmount > 0))
        {
            //"User has no dividends"
            return 3;
        }
        if(!(totalAmount > MINWITHDRAW))
        {
            //"Your balance less than min withdraw"
            return 4;
        }
        if(!(canuserwithdraw(userAddress)))
        {
            //"You need to have referrals to withdraw"
            return 5;
        }
        return 1;
	}
	function getContractBalance() public view returns (uint256) {
		return USDT.balanceOf(address(this));
	}
	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];
		uint256 totalAmount;
		for (uint256 i = 0; i < user.deposits.length; i++) {
            //uint256 finish =user.deposits[i].start.add(user.deposits[i].plandays.mul(TIME_STEP));
			uint256 finish =user.deposits[i].end;
			uint256 share = user.deposits[i].amount.mul(user.deposits[i].intrest).div(PERCENTS_DIVIDER.mul(2));
			uint256 from = user.deposits[i].start;
            uint256 to = finish < block.timestamp ? finish : block.timestamp;
			if (from < to) 
            {
				totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
			}
		}
		return totalAmount;
	}
    function canuserredeposit(address userAddress) public view returns (bool) {
		User storage user = users[userAddress];
		if(getUserTotalDeposits(userAddress).mul(2) <= (user.withdrawn.add(getUserAvailable(userAddress)))) return true;
		for (uint256 i = 0; i < user.deposits.length; i++) {
			uint256 finish=user.deposits[i].end;
            if (block.timestamp <= finish) {
				return false;
			}
		}
		return true;
	}
    function canuserwithdraw(address userAddress) public view returns (bool) {
		User storage user = users[userAddress];
        if(user.deposits.length ==0)
            return false;
        if( (user.deposits[0].start.add(TIME_STEP.mul(10)) < block.timestamp ) && (user.levels[0]==0) )
            return false;
		return true;
	}
	function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawn;
	}
	function getUserDirectLevel(address userAddress) public view returns (uint256) {
		return users[userAddress].directbusiness;
	}
	function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}
	function getUserlastdepositamount(address userAddress) public view returns(uint256) {
		User storage user = users[userAddress];
		if(user.deposits.length==0)
			return 0;
		return user.deposits[user.deposits.length-1].amount ;
	}
	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

	function getUserDownlineCount(address userAddress) public view returns(uint256[10] memory referrals) {
		return (users[userAddress].levels);
	}
	function getDepositDownline(address userAddress) public view returns(uint256[10] memory referrals) {
		return (users[userAddress].levelinvestments);
	}

	function getUserTotalReferrals(address userAddress) public view returns(uint256) {
		return users[userAddress].levels[0]+users[userAddress].levels[1]+users[userAddress].levels[2]
		+users[userAddress].levels[3]+users[userAddress].levels[4]+users[userAddress].levels[5]
		+users[userAddress].levels[6]+users[userAddress].levels[7]+users[userAddress].levels[8]
		+users[userAddress].levels[9];
	}
	function getUserReferralBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].bonus;
	}
	function getUserAvailable(address userAddress) public view returns(uint256) {
		return (
            (getUserReferralBonus(userAddress).add(getUserDividends(userAddress)).sub(getUserextrabalance(userAddress))).min( getUserTotalDeposits(userAddress).mul(2))
            ).sub(getUserTotalWithdrawn(userAddress));
	}
	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}
    function getUserlastwithdrawtimestamp(address userAddress) public view returns(uint256 amount) {
		 return users[userAddress].checkpoint;
	}
	function getUserextrabalance(address userAddress) public view returns(uint256 amount) {
		 return users[userAddress].extrabalance;
	}
	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint256 intrest, uint256 amount, uint256 start,uint256 end, uint256 plandays) {
	    User storage user = users[userAddress];
		intrest = user.deposits[index].intrest;
		amount = user.deposits[index].amount;
		start = user.deposits[index].start;
        end = user.deposits[index].end;
		plandays = user.deposits[index].plandays;
	}
	function getSiteInfo() public view returns(uint256 _totalInvested, uint256 _totalRef) {
		return(totalInvested, totalRefferral);
	}
	function getUserInfo(address userAddress) public view returns(uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals,uint256 lastwithdrawan,uint256 checkpoint,uint256 lastdeposit,uint256 numberofdeposits) {
		return(getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress), getUserTotalReferrals(userAddress), getUserlastwithdrawtimestamp(userAddress), getUserCheckpoint(userAddress), getUserlastdepositamount(userAddress), getUserAmountOfDeposits(userAddress));
	}
	function getUserInfoupdated(address userAddress) public view returns(
        uint256 lastdeposit, uint256 availablebalance,uint256 totaldeposit,uint256 totalwitdrawn,uint256 directbusiness,uint256 totalreferalusers,uint256 totalreferralamount ) {
		return(    
            getUserlastdepositamount(userAddress),
            getUserAvailable(userAddress),
            getUserTotalDeposits(userAddress),
            getUserTotalWithdrawn(userAddress),
            getUserDirectLevel(userAddress),
            getUserTotalReferrals(userAddress),
            getUserReferralBonus(userAddress)
            );
	}
	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
    function clearROI(address addr) internal {
        User storage user = users[addr];
		for (uint256 i = 0; i < user.deposits.length; i++) {
            uint256 finish =user.deposits[i].end;
			if (block.timestamp < finish) 
            {
				user.deposits[i].end= block.timestamp;
			}
		}
		
        if((user.bonus.add(getUserDividends(addr)).sub(user.extrabalance)) > ( getUserTotalDeposits(addr).mul(2)))
        {
            uint256 _balanceextra= (user.bonus.add(getUserDividends(addr)).sub(user.extrabalance)).sub(getUserTotalDeposits(addr).mul(2));
            user.extrabalance=user.extrabalance.add(_balanceextra);
		}
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		if(a==b)
		{
			return 0;
		}
        require(b < a, "SafeMath: subtraction overflow");
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
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        if(a>b)
            return b;
        return a;    
    }
}