/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }
    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

contract XXXXXXX is Ownable, ReentrancyGuard {
	using SafeMath for uint256;
	using SafeERC20 for IERC20;

	//address private tokenAddr = 0x55d398326f99059fF775485246999027B3197955; // USDT
    address private tokenAddr = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; // BUSD testnet

	address private ownerWallet;
    address private projectWallet;
	address private adminFeeWallet;
	IERC20 public token;

	//uint256 public MIN_INVEST = 10 ether; //mainnet
    uint256 public MIN_INVEST = 1 ether; //testnet
	//uint256[] public REFERRAL_PERCENTS = [30, 20, 20]; //delete
	uint256[] public REFERRAL_DIVIDENDS_PERCENTS = [100, 75, 50, 40, 20, 15];
	uint256 public REFERRAL_DIVIDENDS = 300;
	uint256 public MAX_REFERRAL_PERCENT = 800;
	uint256 constant public WITHDRAW_FEE = 20;
	//uint256 constant public MIN_WITHDRAW = 10 ether; //mainnet
    uint256 public MIN_WITHDRAW = 0.01 ether; //testnet
    //uint256 constant public MIN_COMPOUND = 10 ether; //mainnets
	uint256 public MIN_COMPOUND = 0.01 ether; //testnet
	uint256 public MAX_DEPOSITS = 100;
	uint256 public RATE = 75;
	uint256 public TOTAL_RETURN = 2500;
	uint256 constant public PERCENTS_DIVIDER = 1000;
	//uint256 constant public TIME_STEP = 1 days; //mainnet
    uint256 constant public TIME_STEP = 30; //testnet
	uint256 public A_ROUND = 14 * TIME_STEP;
	uint256 public MAX_ROUND_CALCULATION = 10;

	uint256 public totalUsers;
	uint256 public totalInvested;
	uint256 public totalWithdrawn;
	uint256 public totalReinvest;
	uint256 public totalDividendsReferral;
	uint256 public totalActiveDeposits;
	uint256 public totalInsertDividends;
	uint256 public totalExitDividends;

	uint256 public currentRound = 1;

	struct Deposit {
		uint256 amount;
		uint256 withdrawn;
		uint256 start;
		bool    reinvest;
		bool    isFinished;
	}

	struct Round {
		uint256 tDeposit;
		uint256 tActiveDeposit;
		uint256 tWithdraw;
		uint256 tUsers;
		uint256 date;
		uint256 rate;
		uint256 tProfitDeposit;
		uint256 tProfitAffiliate;
		bool    injected;
	}

	struct Withdrawal {
		uint256 amount;
		uint256 date;
		bool    status;
		bool    reinvest;
	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
		address referrer;
		uint256[6] levels;
        uint256[6] teamTurnover;
		uint256[6] teamProfit;
		uint256 dividendsBonus;
		uint256 totalDividendsBonus;
		uint256 totalLostDividends;
		uint256 totalDeposit;
		uint256 totalWithdrawn;
		uint256 totalReinvest;
		uint256 reserve;
		uint256 activeDepositIndex;
	}
 
	mapping (address => User) public users;
	mapping (address => mapping(uint256 => Withdrawal)) public withdrawals;
    mapping (uint256 => uint256) public roundRates;
    mapping (uint256 => Round) public roundStats;

    mapping (address => bool) public operators;
	mapping (address => bool) public blacklist;

    modifier onlyAdmins() {
      	require(owner() == _msgSender() || operators[_msgSender()] == true, "Ownable: caller is not the owner or operator");
      	_;
    }

	modifier notContract() {
		require(!_isContract(msg.sender), "Contract not allowed");
		require(msg.sender == tx.origin, "Proxy contract not allowed");
		_;
    }

	uint256 public startDate;
	uint256 public launchDate;


	event Newbie(address user);
	event NewDeposit(address indexed user, uint256 amount, uint256 time);
	event NewCompound(address indexed user, uint256 amount, uint256 time);
	event Withdrawn(address indexed user, uint256 amount, uint256 time);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);

	constructor() {
		token = IERC20(tokenAddr);
        //projectWallet = 0x9C5e5153b87C7943b423D615Ae1aa14dEF7B12fF; // mainnet
        projectWallet = 0x32C5a1D92947c217AA0D65971E2d09114A4be787; // testnet
		//adminFeeWallet = ; // mainnet
        adminFeeWallet = 0x32C5a1D92947c217AA0D65971E2d09114A4be787; // testnet
		//ownerWallet = 0xa6B5BE64a803Cf6F1A18099AcA40363E63b89659; // mainnet
        ownerWallet = 0x32C5a1D92947c217AA0D65971E2d09114A4be787; // testnet
		
		operators[msg.sender] = true;
		//uint256 start = ; //mainnet
		//launchDate = ;  //mainnet
        uint256 start = block.timestamp; //testnet
        launchDate = start.sub(5 * TIME_STEP);
		startDate  = start.sub(A_ROUND);
	}

	function invest(address referrer, uint256 amount) public noReentrant notContract {
		require(block.timestamp > startDate,  "round does not launch yet");
		require(block.timestamp > launchDate, "contract does not launch yet");
		require(!blacklist[msg.sender], "This address is in black list");
        require(amount >= MIN_INVEST, "less than min deposit amount");
		require(amount <= token.allowance(msg.sender, address(this)),"low allowance");
		token.safeTransferFrom(msg.sender, address(this), amount);

		User storage user = users[msg.sender];
		require(user.deposits.length <= MAX_DEPOSITS, "max 100 deposits");

		updateRoundStats();

		if (user.referrer == address(0)) {
			if ((users[referrer].deposits.length > 0 && referrer != msg.sender) || referrer == ownerWallet) {
				user.referrer = referrer;
			}else{
				revert("Please enter valid referrer");
			}

			address upline = user.referrer;
			for (uint256 i = 0; i < 6; i++) {
				if (upline != address(0)) {
					users[upline].levels[i] = users[upline].levels[i].add(1);
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 6; i++) {
				if (upline != address(0)) {
					users[upline].teamTurnover[i] += amount;
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			totalUsers++;
			emit Newbie(msg.sender);
		}

		user.deposits.push(Deposit(amount, 0, block.timestamp, false, false));
		totalInvested = totalInvested.add(amount);
		totalActiveDeposits = totalActiveDeposits.add(amount);
		emit NewDeposit(msg.sender, amount, block.timestamp);
	}

	function withdraw() public noReentrant {
		require(block.timestamp > startDate,  "round does not launch yet");
		require(block.timestamp > launchDate, "contract does not launch yet");
		require(withdrawals[msg.sender][cRound()].status == false, "dividends withdrawn");
		require(!blacklist[msg.sender], "This address is in black list");
		
		updateRoundStats();

		User storage user = users[msg.sender];

		uint256 totalAmount = calUserDividends(msg.sender);
		uint256 amount = totalAmount;
		uint256 restDB = 0;
		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 6; i++) {
				uint256 refAmount = amount.mul(REFERRAL_DIVIDENDS_PERCENTS[i]).div(PERCENTS_DIVIDER);
				if (upline != address(0)) {
					users[upline].dividendsBonus += refAmount;
					users[upline].totalDividendsBonus += refAmount;
                    users[upline].teamProfit[i] += refAmount;
					totalDividendsReferral += refAmount;
					emit RefBonus(upline, msg.sender, i, refAmount);
					upline = users[upline].referrer;
				} 
				else {
					restDB += refAmount;
				}
			}
		}

		if(restDB > 0){
			token.safeTransfer(projectWallet, restDB);
            totalExitDividends += restDB;
            totalDividendsReferral += restDB;
		}

		uint256 referralDividendsBonus = user.dividendsBonus;
		uint256 userActiveIdex = user.activeDepositIndex;
		if (referralDividendsBonus > 0) {
			for (uint256 i = userActiveIdex; i < user.deposits.length; i++) {
				if(referralDividendsBonus > 0){
					uint256 depositMaxReturn = user.deposits[i].amount.mul(TOTAL_RETURN).div(PERCENTS_DIVIDER);
					uint256 RemainingCapacity = depositMaxReturn.sub(user.deposits[i].withdrawn);
					if(RemainingCapacity > referralDividendsBonus){
						user.deposits[i].withdrawn += referralDividendsBonus;
						referralDividendsBonus = 0;
						break;
					}else{
						referralDividendsBonus = referralDividendsBonus.sub(RemainingCapacity);
						user.deposits[i].withdrawn = depositMaxReturn;
						user.deposits[i].isFinished = true;
						user.activeDepositIndex += 1;
					}
				}else{
					break;
				}
			}
			totalAmount = totalAmount.add(user.dividendsBonus);
			if(referralDividendsBonus > 0) {
				user.totalLostDividends += referralDividendsBonus;
				totalAmount = totalAmount.sub(referralDividendsBonus);
			}
			user.dividendsBonus = 0;
		}
		
		uint256 reserveAmount = user.reserve;
		if (reserveAmount > 0) {
			user.reserve = 0;
			totalAmount = totalAmount.add(reserveAmount);
		}

		require(totalAmount >= MIN_WITHDRAW, "less than min amount");

		uint256 withdrawFee = totalAmount.mul(WITHDRAW_FEE).div(PERCENTS_DIVIDER);

		uint256 contractBalance = token.balanceOf(address(this));
		if (contractBalance < (totalAmount.add(withdrawFee))) {
			require(contractBalance >= withdrawFee, "Not enough contract balance");
			user.reserve = totalAmount.sub(contractBalance.sub(withdrawFee));
			totalAmount = contractBalance.sub(withdrawFee);
		}

		user.checkpoint = roundStart(cRound());
		user.totalWithdrawn = user.totalWithdrawn.add(totalAmount);
		totalWithdrawn = totalWithdrawn.add(totalAmount);
		totalExitDividends += totalAmount;
		withdrawals[msg.sender][cRound()].amount = totalAmount;
		withdrawals[msg.sender][cRound()].date = block.timestamp;
		withdrawals[msg.sender][cRound()].status = true;
		token.safeTransfer(msg.sender, totalAmount);
		token.safeTransfer(adminFeeWallet, withdrawFee);
		emit Withdrawn(msg.sender, totalAmount, block.timestamp);
	}

	function reinvest() public noReentrant {	
		require(block.timestamp > startDate,  "round does not launch yet");
		require(block.timestamp > launchDate, "contract does not launch yet");
		require(withdrawals[msg.sender][cRound()].status == false, "dividends withdrawn");
		require(!blacklist[msg.sender], "This address is in black list");
		User storage user = users[msg.sender];
		require(user.deposits.length <= MAX_DEPOSITS, "max 100 deposits");

		updateRoundStats();

		uint256 totalAmount = calUserDividends(msg.sender);
		uint256 amount = totalAmount;
		uint256 restDB = 0;
		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 6; i++) {
				uint256 refAmount = amount.mul(REFERRAL_DIVIDENDS_PERCENTS[i]).div(PERCENTS_DIVIDER);
				if (upline != address(0)) {
					users[upline].dividendsBonus += refAmount;
					users[upline].totalDividendsBonus += refAmount;
                    users[upline].teamProfit[i] += refAmount;
					totalDividendsReferral += refAmount;
					emit RefBonus(upline, msg.sender, i, refAmount);
					upline = users[upline].referrer;
				} 
				else {
					restDB += refAmount;
				}
			}
		}

		if(restDB > 0){
			token.safeTransfer(projectWallet, restDB);
            totalExitDividends += restDB;
            totalDividendsReferral += restDB;
		}

		uint256 referralDividendsBonus = user.dividendsBonus;
		uint256 userActiveIdex = user.activeDepositIndex;
		if (referralDividendsBonus > 0) {
			for (uint256 i = userActiveIdex; i < user.deposits.length; i++) {
				if(referralDividendsBonus > 0){
					uint256 depositMaxReturn = user.deposits[i].amount.mul(TOTAL_RETURN).div(PERCENTS_DIVIDER);
					uint256 RemainingCapacity = depositMaxReturn.sub(user.deposits[i].withdrawn);
					if(RemainingCapacity > referralDividendsBonus){
						user.deposits[i].withdrawn += referralDividendsBonus;
						referralDividendsBonus = 0;
						break;
					}else{
						referralDividendsBonus = referralDividendsBonus.sub(RemainingCapacity);
						user.deposits[i].withdrawn = depositMaxReturn;
						user.deposits[i].isFinished = true;
						user.activeDepositIndex += 1;
					}
				}else{
					break;
				}
			}
			totalAmount = totalAmount.add(user.dividendsBonus);
			if(referralDividendsBonus > 0) {
				user.totalLostDividends += referralDividendsBonus;
				totalAmount = totalAmount.sub(referralDividendsBonus);
			}
			user.dividendsBonus = 0;
		}
		
		uint256 reserveAmount = user.reserve;
		if (reserveAmount > 0) {
			user.reserve = 0;
			totalAmount = totalAmount.add(reserveAmount);
		}

		require(totalAmount >= MIN_COMPOUND, "less than min amount");

		user.deposits.push(Deposit(totalAmount, 0, block.timestamp, true, false));
		totalReinvest = totalReinvest.add(totalAmount);
		totalActiveDeposits = totalActiveDeposits.add(totalAmount);
		totalExitDividends += totalAmount;

		user.checkpoint = roundStart(cRound());
		user.totalReinvest = user.totalReinvest.add(totalAmount);

		withdrawals[msg.sender][cRound()].amount = totalAmount;
		withdrawals[msg.sender][cRound()].date = block.timestamp;
		withdrawals[msg.sender][cRound()].status = true;
		withdrawals[msg.sender][cRound()].reinvest = true;

		emit NewCompound(msg.sender, totalAmount, block.timestamp);
	}

	function getContractBalance() public view returns (uint256) {
		return token.balanceOf(address(this));
	}

	function calUserDividends(address userAddress) internal returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;
		uint256 dividends = 0;
		uint256 cR = cRound();
		
		if(cR > 1){
			for (uint256 i = 0; i < user.deposits.length; i++) {
				uint256 max = user.deposits[i].amount.mul(TOTAL_RETURN).div(PERCENTS_DIVIDER);
				if(user.deposits[i].withdrawn < max && !user.deposits[i].isFinished){
					for (uint256 j = 1; j < (MAX_ROUND_CALCULATION+1) ; j++) {
						if(j < cR && (cR-j) > 1){
							uint256 startRound = roundStart(cR-j);
							uint256 endRound = roundStart(cR-(j-1));
							if(startRound >= user.checkpoint && startRound >= user.deposits[i].start && roundRates[cR-j] > 0){
								uint256 share = user.deposits[i].amount.mul(roundRates[cR-j]).div(PERCENTS_DIVIDER);
								if (startRound < endRound) {
									dividends = dividends.add(share.mul(endRound.sub(startRound)).div(A_ROUND));
								}
							}
						}
					}
					if(user.deposits[i].withdrawn.add(dividends) >= max){
						dividends = max.sub(user.deposits[i].withdrawn);
						user.deposits[i].withdrawn = max;
						user.activeDepositIndex += 1;
						user.deposits[i].isFinished;
						totalActiveDeposits = totalActiveDeposits.sub(user.deposits[i].amount);
					}else{
						user.deposits[i].withdrawn += dividends;
					}
				}
				totalAmount = totalAmount.add(dividends);
				dividends = 0;
			}
		}

		return totalAmount;
	}
	
	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;
		uint256 dividends = 0;
		uint256 cR = cRound();
		if(cR > 1){
			for (uint256 i = 0; i < user.deposits.length; i++) {
				uint256 max = user.deposits[i].amount.mul(TOTAL_RETURN).div(PERCENTS_DIVIDER);
				if(user.deposits[i].withdrawn < max && !user.deposits[i].isFinished){
					for (uint256 j = 1; j < (MAX_ROUND_CALCULATION+1); j++) {
						if(j < cR && (cR-j) > 1){
							uint256 startRound = roundStart(cR-j);
							uint256 endRound = roundStart(cR-(j-1));
							if(startRound >= user.checkpoint && startRound >= user.deposits[i].start && roundRates[cR-j] > 0){
								uint256 share = user.deposits[i].amount.mul(roundRates[cR-j]).div(PERCENTS_DIVIDER);
								if (startRound < endRound) {
									dividends = dividends.add(share.mul(endRound.sub(startRound)).div(A_ROUND));
								}
							}
						}
					}
					if(user.deposits[i].withdrawn.add(dividends) > max){
						dividends = max.sub(user.deposits[i].withdrawn);
					}
				}
				totalAmount = totalAmount.add(dividends);
				dividends = 0;
			}
		}
		return totalAmount;
	}
	
	function getUserDividendsCR(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;
		uint256 dividends = 0;
		uint256 cR = cRound();
		if(cR > 1){
			for (uint256 i = 0; i < user.deposits.length; i++) {
				uint256 max = user.deposits[i].amount.mul(TOTAL_RETURN).div(PERCENTS_DIVIDER);
				if(user.deposits[i].withdrawn < max && !user.deposits[i].isFinished){
					uint256 startRound = roundStart(cR);
					uint256 endRound = roundStart(cR+1);
					if(startRound >= user.checkpoint && startRound >= user.deposits[i].start){
						uint256 share = user.deposits[i].amount.mul(RATE).div(PERCENTS_DIVIDER);
						if (startRound < endRound) {
							dividends = dividends.add(share.mul(endRound.sub(startRound)).div(A_ROUND));
						}
					}
						
					if(user.deposits[i].withdrawn.add(dividends) > max){
						dividends = max.sub(user.deposits[i].withdrawn);
					}
				}
				totalAmount = totalAmount.add(dividends);
				dividends = 0;
			}
		}

		return totalAmount;
	}

	function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].totalWithdrawn;
	}

	function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

	function getUserDownlineCount(address userAddress) public view returns(uint256[6] memory referrals) {
		return (users[userAddress].levels);
	}

    function getUserTeamTurnover(address userAddress) public view returns(uint256[6] memory turnover) {
		return (users[userAddress].teamTurnover);
	}

	function getUserTeamProfit(address userAddress) public view returns(uint256[6] memory teamProfit) {
		return (users[userAddress].teamProfit);
	}

	function getUserTotalReferrals(address userAddress) public view returns(uint256) {
		return users[userAddress].levels[0]+users[userAddress].levels[1]+users[userAddress].levels[2]+users[userAddress].levels[3]+users[userAddress].levels[4]+users[userAddress].levels[5];
	}

    function getUserTotalTeamTurnover(address userAddress) public view returns(uint256) {
		return users[userAddress].teamTurnover[0]+users[userAddress].teamTurnover[1]+users[userAddress].teamTurnover[2]+users[userAddress].teamTurnover[3]+users[userAddress].teamTurnover[4]+users[userAddress].teamTurnover[5];
	}

	function getUserTotalTeamProfit(address userAddress) public view returns(uint256) {
		return users[userAddress].teamProfit[0]+users[userAddress].teamProfit[1]+users[userAddress].teamProfit[2]+users[userAddress].teamProfit[3]+users[userAddress].teamProfit[4]+users[userAddress].teamProfit[5];
	}

	function getUserReferralDividendsBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].dividendsBonus;
	}

	function getUserReferralTotalDividendsBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].totalDividendsBonus;
	}

	function getUserTotalLostDividends(address userAddress) public view returns(uint256) {
		return users[userAddress].totalLostDividends;
	}

	function getUserAvailable(address userAddress) public view returns(uint256) {
		return getUserReferralDividendsBonus(userAddress).add(getUserDividends(userAddress));
	}

	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint256 amount, uint256 start, uint256 withdrawn, bool _reinvest) {
	    User storage user = users[userAddress];

		amount = user.deposits[index].amount;
		start = user.deposits[index].start;
		withdrawn = user.deposits[index].withdrawn;
		_reinvest = user.deposits[index].reinvest;
	}

	function getSiteInfo() public view returns(
		uint256 _totalInvested,
		uint256 _totalWithdrawn,
		uint256 _totalReinvest,
		uint256 _totalDividendsReferral,
		uint256 _totalActiveDeposits
	) {
		return(
			totalInvested,
			totalWithdrawn,
			totalReinvest,
			totalDividendsReferral,
			totalActiveDeposits
		);
	}

	function getRequiredDividends() public view returns(
		uint256 _investors, 
		uint256 _affiliates
		) {

		uint256 r = roundRates[cRound() - 1] > 0 ? roundRates[cRound() - 1] : RATE;

		_investors  = totalActiveDeposits.mul(r).div(PERCENTS_DIVIDER);
		_affiliates = _investors.mul(REFERRAL_DIVIDENDS).div(PERCENTS_DIVIDER);
		
	}

	function getRequiredDividendsByRoundAndRate(uint256 _round, uint256 _rate) public view returns(
		uint256 _Amount
		) {
		uint256 aD = roundStats[_round].tActiveDeposit > 0 ? roundStats[_round].tActiveDeposit : totalActiveDeposits;
		if(aD > 0){
			uint256 tpd = aD.mul(_rate).div(PERCENTS_DIVIDER);
			_Amount = tpd.add(tpd.mul(REFERRAL_DIVIDENDS).div(PERCENTS_DIVIDER));
			_Amount += _Amount.mul(WITHDRAW_FEE).div(PERCENTS_DIVIDER);
		}
	}

	function getUserInfo(address userAddress) public view returns(
		uint256 checkpoint, 
		uint256 tDeposit, 
		uint256 tWithdrawn, 
		uint256 tReferrals,
		uint256 tDReferrals,
		uint256 tReinvests,
		uint256 tReserve
		) {
		return(
			getUserCheckpoint(userAddress), 
			getUserTotalDeposits(userAddress), 
			getUserTotalWithdrawn(userAddress), 
			getUserTotalReferrals(userAddress),
			users[userAddress].totalDividendsBonus,
			users[userAddress].totalReinvest,
			users[userAddress].reserve
		);
	}

	function updateRoundStats() public {
		if(currentRound < cRound()){
			roundStats[currentRound].tDeposit = totalInvested;
			roundStats[currentRound].tActiveDeposit = totalActiveDeposits;
			roundStats[currentRound].tWithdraw = totalWithdrawn;
			roundStats[currentRound].tUsers = totalUsers;
			roundStats[currentRound].date = block.timestamp;
			roundStats[currentRound].tProfitDeposit;
			roundStats[currentRound].tProfitAffiliate;
			currentRound = cRound();
		}
    }

	function getRoundStats(uint256 index) public view returns (
		uint256 __tDeposit,
		uint256 __tActiveDeposit,
		uint256 __tWithdraw,
		uint256 __tUsers,
		uint256 __date,
		uint256 __tProfitDeposit,
		uint256 __tProfitAffiliate
	){
		return (
		roundStats[index].tDeposit,
		roundStats[index].tActiveDeposit,
		roundStats[index].tWithdraw,
		roundStats[index].tUsers,
		roundStats[index].date,
		roundStats[index].tProfitDeposit,
		roundStats[index].tProfitAffiliate
		);
	}

	function cRound() public view returns (uint256) {
		if(block.timestamp > startDate){
        	return ((block.timestamp - startDate) / A_ROUND) + 1;
		}
		else{
			return 0;
		}
    }

	function cRoundStart() public view returns (uint256) {
		if(block.timestamp > startDate){
        	return ((cRound() - 1) * A_ROUND) + startDate;
		}
		else{
			return startDate;
		}
    }

	function roundStart(uint256 index) public view returns (uint256) {
		if(block.timestamp > startDate && index > 0){
        	return ((index - 1) * A_ROUND) + startDate;
		}
		else{
			return startDate;
		}
    }

	function nextRoundStart() public view returns (uint256) {
        return cRoundStart() + A_ROUND;
    }

	function getRoundRate(uint256 index) public view returns (uint256) {
        return roundRates[index];
    }

	function getBalanceStats() public view returns (uint256, uint256, uint256){

		uint256 nRemain = totalInsertDividends >= totalExitDividends ? (totalInsertDividends - totalExitDividends) : 0; 
		uint256 cb = getContractBalance();
		uint256 available = cb >= nRemain ? (cb - nRemain) : 0;
		return (
			cb,
			available,
			nRemain
		);
	} 

	function setRoundRate(uint256 index, uint256 rate) public onlyAdmins{
		require(index < cRound(), "invalid round number");
		if(rate == 0){
			roundRates[index] = RATE;
			roundStats[currentRound].rate = RATE;
		}
		else{
			roundRates[index] = rate;
			roundStats[currentRound].rate = rate;
		}
		
		uint256 aD = roundStats[index].tActiveDeposit > 0 ? roundStats[index].tActiveDeposit : totalActiveDeposits;

		if(aD > 0){
			roundStats[index].tProfitDeposit = aD.mul(roundRates[index]).div(PERCENTS_DIVIDER);
			roundStats[index].tProfitAffiliate = roundStats[index].tProfitDeposit.mul(REFERRAL_DIVIDENDS).div(PERCENTS_DIVIDER);
		}
	}

	function setRoundRateWithInject(uint256 index, uint256 rate) public onlyAdmins{
		require(index < cRound(), "invalid round number");
		require(roundStats[index].injected == false, "only one time allowed");
		require(rate >= 10 && rate <= 200, "invalid round number");

		updateRoundStats();

		roundRates[index] = rate;
		roundStats[currentRound].rate = rate;
		roundStats[index].injected = true;
		
		uint256 aD = roundStats[index].tActiveDeposit > 0 ? roundStats[index].tActiveDeposit : totalActiveDeposits;
		uint256 injectAmount = 0;
		if(aD > 0){
			uint256 tpd = aD.mul(rate).div(PERCENTS_DIVIDER);
			roundStats[index].tProfitDeposit = tpd;
			roundStats[index].tProfitAffiliate = tpd.mul(REFERRAL_DIVIDENDS).div(PERCENTS_DIVIDER);
			injectAmount = tpd.add(tpd.mul(REFERRAL_DIVIDENDS).div(PERCENTS_DIVIDER));
		}

		if(injectAmount > 0){
			injectAmount += injectAmount.mul(WITHDRAW_FEE).div(PERCENTS_DIVIDER);
			insertDividends(injectAmount);
		}
	}

	function deactiveRound(uint256 index) public onlyAdmins{
		require(index < cRound(), "invalid round number");
		roundRates[index] = 0;	
	}

	function insertDividends(uint256 amount) public onlyAdmins{
		require(amount <= token.allowance(msg.sender, address(this)));
		token.safeTransferFrom(msg.sender, address(this), amount);
		totalInsertDividends += amount;
	}

	function reverseDividends(uint256 amount, address to) public onlyAdmins{
		uint256 contractBalance = token.balanceOf(address(this));
		if (contractBalance < amount) {
			revert("Not enough contract balance");
		}
		token.safeTransfer(to, amount);
		totalInsertDividends -= amount;
	}

	function withdrawProfitShare() public onlyAdmins{
		User storage user = users[ownerWallet];

		uint256 referralDividendsBonus = user.dividendsBonus;
		uint256 contractBalance = token.balanceOf(address(this));
		if (contractBalance < referralDividendsBonus) {
			user.dividendsBonus = user.dividendsBonus.sub(contractBalance);
			referralDividendsBonus = contractBalance;
		}else{
			user.dividendsBonus = 0;
		}

		require(referralDividendsBonus > 0, "Not enough profit share");

		token.safeTransfer(ownerWallet, referralDividendsBonus);
		user.totalWithdrawn += referralDividendsBonus;
		totalExitDividends += referralDividendsBonus;
		totalWithdrawn += referralDividendsBonus;
	}

	function setMinInvest(uint256 amount) public onlyAdmins{
		MIN_INVEST = amount;
	}

	function setMinWithdraw(uint256 amount) public onlyAdmins{
		MIN_WITHDRAW = amount;
	}

	function setMinCompound(uint256 amount) public onlyAdmins{
		MIN_COMPOUND = amount;
	}

	function setMaxReferralPercent(uint256 amount) public onlyAdmins{
		require(MAX_REFERRAL_PERCENT < 1000, "Wrong referral max amount");
		MAX_REFERRAL_PERCENT = amount;
	}

	function setReferralCommission(uint256 index, uint256 amount) public onlyAdmins{
		require(index < 6, "Wrong referral index");
		REFERRAL_DIVIDENDS_PERCENTS[index] = amount;
		uint256 referralTotalAmount;
		for (uint256 i = 0; i < REFERRAL_DIVIDENDS_PERCENTS.length; i++) {
			referralTotalAmount += REFERRAL_DIVIDENDS_PERCENTS[i];
		}
		require(referralTotalAmount <= MAX_REFERRAL_PERCENT, "Wrong total referral commission");
		REFERRAL_DIVIDENDS = referralTotalAmount;
	}

	function setMaxDepositCount(uint256 amount) public onlyAdmins{
		require(MAX_DEPOSITS < 1000, "Wrong max deposit count");
		MAX_DEPOSITS = amount;
	}

	function setNewDefaultRate(uint256 amount) public onlyAdmins{
		require(amount >= 10 && amount < 1000, "Wrong rate amount");
		RATE = amount;
	}

	function setTotalReturn(uint256 amount) public onlyAdmins{
		require(amount > 1000 , "Wrong total return amount");
		TOTAL_RETURN = amount;
	}

	function setMaxRoundCalculation(uint256 count) public onlyAdmins{
		require(count >= 1 && count <= 50, "Wrong round for calculation");
		MAX_ROUND_CALCULATION = count;
	}

	function setRoundDuration(uint256 roundDay) public onlyAdmins{
		require(roundDay >= 1, "Wrong round for calculation");
		A_ROUND = roundDay * TIME_STEP;
	}

	function setProjectToken(address tokenAddress) public onlyAdmins{
		token = IERC20(tokenAddress);
	}

	function claimCoin(uint256 amount) public onlyAdmins{
		payable(msg.sender).transfer(amount);
	}

	function claimProjectToken(uint256 amount, address to) public onlyAdmins{
		token.safeTransfer(to, amount);
	}

	function claimToken(address tokenAddress, uint256 amount, address to) public onlyAdmins{
		IERC20(tokenAddress).transfer(to, amount);
	}

	function setOperators(address _addr, bool _status) external onlyOwner{
		operators[_addr] = _status;
	}

	function addToBlacklist(address _addr) external onlyOwner{
		blacklist[_addr] = true;
	}

	function removeFromBlacklist(address _addr) external onlyOwner{
		blacklist[_addr] = false;
	}

	function _isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

}