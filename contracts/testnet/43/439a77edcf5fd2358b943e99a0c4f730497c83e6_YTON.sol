/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

/*
 * 
 *   TRONex - investment platform based on TRX blockchain smart-contract technology. Safe and legit!
 *
 *   ┌───────────────────────────────────────────────────────────────────────┐  
 *   │   Website: https://tronex.net                                         │
 *   │                                                                       │  
 *   │   Telegram Live Support: https://t.me/tronexsupport                   |
 *   │   Telegram Public Group: https://t.me/tronexgroup                     |
 *   │   Telegram News Channel: https://t.me/tronexnews                      |
 *   |                                                                       |
 *   |   Twitter: https://twitter.com/tronex_net                             |
 *   |   YouTube: https://www.youtube.com/channel/UCw3ck_M-JGnEkAph4Bb2HYQ   |
 *   |   E-mail: [email protected]                                            |
 *   └───────────────────────────────────────────────────────────────────────┘ 
 *
 *   [USAGE INSTRUCTION]
 *
 *   1) Connect TRON browser extension TronLink or TronMask, or mobile wallet apps like TronWallet or Banko.
 *   2) Send any TRX amount (100 TRX minimum) using our website invest button.
 *   3) Wait for your earnings.
 *   4) Withdraw earnings any time using our website "Withdraw" button.
 *
 *   [INVESTMENT CONDITIONS]
 * 
 *   - Basic interest rate: +1% every 24 hours (+0.0416% hourly)
 *   - Personal hold-bonus: +0.1% for every 24 hours without withdraw 
 *   - Contract total amount bonus: +0.1% for every 1,000,00 TRX on platform address balance 
 * 
 *   - Minimal deposit: 100 TRX, no maximal limit
 *   - Total income: 200% (deposit included)
 *   - Earnings every moment, withdraw any time
 * 
 *   [AFFILIATE PROGRAM]
 *
 *   Share your referral link with your partners and get additional bonuses.
 *   - 3-level referral commission: 5% - 2% - 0.5%
 *
 *   [FUNDS DISTRIBUTION]
 *
 *   - 82.5% Platform main balance, participants payouts
 *   - 8% Advertising and promotion expenses
 *   - 7.5% Affiliate program bonuses
 *   - 2% Support work, technical functioning, administration fee
 *
 *   ────────────────────────────────────────────────────────────────────────
 *
 *   [LEGAL COMPANY INFORMATION]
 *
 *   - Officially registered company name: TRONex LTD (#12739027)
 *   - Company status: https://beta.companieshouse.gov.uk/company/12739027
 *   - Certificate of incorporation: https://tronex.net/img/certificate.pdf
 *
 *   [SMART-CONTRACT AUDITION AND SAFETY]
 *
 *   - Audited by independent company GROX Solutions (https://grox.solutions)
 *   - Audition certificate: https://tronex.net/audition.pdf
 *   - Video-review: https://tronex.net/review.avi
 *
 */

pragma solidity 0.5.10;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);
    function burn(address account, uint amount) external;

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract YTON is Ownable{
	using SafeMath for uint256;

	uint256  public INVEST_MIN_AMOUNT = 1;  //U
	uint256  public UP_MIN_AMOUNT = 0.001 ether;    //BNB最小质押数量
	uint256  public BASE_PERCENT = 10;  // 1%
	uint256[] public REFERRAL_PERCENTS = [30, 20, 15, 5, 5, 5, 5, 5, 5, 5];
	uint256[] public REFERRAL_DAO = [3, 2, 1];
	uint256  public MARKETING_FEE = 50;  //yingxiao
	uint256 constant public PERCENTS_DIVIDER = 1000;  //base lv
	uint256 constant public BASE_FEE = 100;  //收益分母
	uint256  public CONTRACT_BALANCE_STEP = 100000 * 10 ** 18; //U
	uint256 constant public TIME_STEP = 86400; //24xiaoshi
	uint256 public _MAX_DAO_RATE = 1 * 10 ** 18;  //持币最大算力 ..1%
	uint256 public daoholdnum = 1 * 10 ** 18;  //最少持币量
	uint256 public endTime = 1800; //最少质押时间

	uint256 public totalUsers;
	uint256 public totalInvested;
	uint256 public totalWithdrawn;
	uint256 public totalDeposits;

    IERC20 public usdt;  //0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7  test
    IERC20 public dao;   //0x6Ca36BFeCaBf83630E34B44D4d6C6983aC551403 test kudoge 

	address payable public marketingAddress;

	struct Deposit {
		uint256 amount;
		uint256 withdrawn;
        uint256 witAmount;
		uint256 start;
	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
		address referrer;
		uint256 bonus;
        uint256 otherFees;
		uint256 totalReferrer;    //总推荐人
		uint256[10] refStageIncome;  //质押数量
        uint256[10] refStageBonus;     //质押奖励
		uint256[10] refStageWithdrawn;  //提现
		uint[10] refs;     
	}

	mapping (address => User) internal users;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event RefBonusDao(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);
	event Upline(address indexed addr, address indexed upline);

	constructor(IERC20 _dao,IERC20 _usdt,address payable marketingAddr) public {
		require(!isContract(marketingAddr));
        usdt = _usdt;
        dao = _dao;
		marketingAddress = marketingAddr;
	}

	modifier onlyMarket() {
        require(msg.sender == marketingAddress, "Ownable: caller is not the owner");
        _;
    }

	function updateMarketingWalletAddress(address payable _address) public onlyMarket {
        marketingAddress = _address;
    }

	function updateDaoAddress(IERC20 _dao) public onlyMarket {
        dao = _dao;
    }

	function updateBaseData(uint256[8] memory _values) public onlyMarket {
		INVEST_MIN_AMOUNT = _values[0];  //U
		UP_MIN_AMOUNT = _values[1];    //绑定所需要最少BNB
		BASE_PERCENT = _values[3];  // 1%
		MARKETING_FEE = _values[3];  //yingxiao
		CONTRACT_BALANCE_STEP = _values[4] * 10 ** 18; //U
		_MAX_DAO_RATE = _values[5];  //持币最大算力 30 ..3%
		daoholdnum = _values[6] * 10 ** 18;  //最少持币量   100
		endTime = _values[7]; //最少质押时间
	}

	function updateUp(address _user,address _referrer) public onlyMarket {
		//用户构造
		User storage user = users[_user];
		user.referrer = _referrer;
	}

	function bingUp(address referrer)  public payable {
        require(msg.value >= UP_MIN_AMOUNT,"Min invesment 0.1 BNB");
		require(referrer != msg.sender);
		require(referrer != address(0));
        //用户构造
		User storage user = users[msg.sender];
        require(user.referrer == address(0),"Existing superior!");

		user.referrer = referrer;
		emit Upline(msg.sender,referrer);

		address upline = referrer;

		for (uint i = 0; i < REFERRAL_PERCENTS.length; i++) {
			if (upline != address(0)) {
				users[upline].refs[i] = users[upline].refs[i].add(1);
				users[upline].totalReferrer++;
				upline = users[upline].referrer;
			} else break;
		}

		//给上级 上上 上上上 赠送DAO
		for (uint256 i = 0; i < REFERRAL_DAO.length; i++) {
			if (upline != address(0)) {
				uint256 amount = REFERRAL_DAO[i] * 10 ** 18;
				if(dao.balanceOf(address(this)) >= amount){
					dao.transfer(upline,amount);
					emit RefBonusDao(upline, msg.sender, i, amount);
				}
				upline = users[upline].referrer;
			} else break;
		}
		
	}

	function invest(address referrer,uint256 investAmount) public returns (bool) {
		require(investAmount >= INVEST_MIN_AMOUNT);
        
        //本金 充进合约
        usdt.transferFrom(msg.sender, address(this), investAmount);

        usdt.transfer(marketingAddress, investAmount.mul(MARKETING_FEE).div(PERCENTS_DIVIDER)); //5%
		emit FeePayed(msg.sender, investAmount.mul(MARKETING_FEE).div(PERCENTS_DIVIDER));

		User storage user = users[msg.sender];

		if (user.referrer == address(0) && users[referrer].deposits.length > 0 && referrer != msg.sender) {
			user.referrer = referrer;
		}

		if (user.referrer != address(0)) {

			address upline = user.referrer;
			for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {
				if (upline != address(0)) {
					users[upline].refStageIncome[i] = users[upline].refStageIncome[i].add(investAmount);
					uint256 amount = investAmount.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].bonus = users[upline].bonus.add(amount);
					users[upline].refStageBonus[i] = users[upline].refStageBonus[i].add(amount);
					emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			totalUsers = totalUsers.add(1);
			emit Newbie(msg.sender);
		}

		user.deposits.push(Deposit(investAmount, 0,0, block.timestamp));

		totalInvested = totalInvested.add(investAmount);
		totalDeposits = totalDeposits.add(1);

		emit NewDeposit(msg.sender, investAmount);
		return true;
	}

	function withdraw() public {
		User storage user = users[msg.sender];

		uint256 userPercentRate = getUserPercentRate(msg.sender);

		uint256 totalAmount;
		uint256 dividends;

		for (uint256 i = 0; i < user.deposits.length; i++) {

			if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(2)) {

				if (user.deposits[i].start > user.checkpoint) {

					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(block.timestamp.sub(user.deposits[i].start))
						.div(TIME_STEP);

				} else {

					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(block.timestamp.sub(user.checkpoint))
						.div(TIME_STEP);

				}

				if (user.deposits[i].withdrawn.add(dividends) > user.deposits[i].amount.mul(2)) {
					dividends = (user.deposits[i].amount.mul(2)).sub(user.deposits[i].withdrawn);
				}

				user.deposits[i].withdrawn = user.deposits[i].withdrawn.add(dividends); /// changing of storage data
                user.deposits[i].witAmount = user.deposits[i].witAmount.add(dividends);
				totalAmount = totalAmount.add(dividends);

			}
		}

		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			totalAmount = totalAmount.add(referralBonus);
			user.bonus = 0;
		}

		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = usdt.balanceOf(address(this));
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;

		uint256 actualAmountToSend = totalAmount.mul(PERCENTS_DIVIDER.sub(MARKETING_FEE)).div(PERCENTS_DIVIDER);
         //给用户转账实际到账数量
		usdt.transfer(msg.sender, actualAmountToSend); // 95%
		
		if (user.referrer != address(0)) {
		
			address upline = user.referrer;
			for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {
				if (upline != address(0)) {
					uint256 amount = totalAmount.mul(20).div(BASE_FEE).mul(REFERRAL_PERCENTS[i]).div(BASE_FEE);
					users[upline].bonus = users[upline].bonus.add(amount);
					users[upline].refStageWithdrawn[i] = users[upline].refStageWithdrawn[i].add(actualAmountToSend);
					emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
				} else break;
			}
		}

		totalWithdrawn = totalWithdrawn.add(totalAmount);

		emit Withdrawn(msg.sender, totalAmount.mul(PERCENTS_DIVIDER.sub(MARKETING_FEE)).div(PERCENTS_DIVIDER));

	}

    function ext() public returns (bool){
		User storage user = users[msg.sender];
        //充值后30分钟内不能体现
        if(now.sub(user.deposits[user.deposits.length-1].start) < endTime){
            return  false;
        }

        //总质押金额
        uint256 totalDep = getUserTotalDeposits(msg.sender);
        //总提现金额
        uint256 totalWit =  getUserTotalWitAmount(msg.sender);

        //如果总提现 》= 总质押 那就不给退 如果小于总质押 就退 总质押-总提现
        uint256 totalAmount;
        if(totalWit < totalDep){
            totalAmount = totalDep.sub(totalWit).sub(totalDep.mul(MARKETING_FEE).div(PERCENTS_DIVIDER));
			require(totalAmount > 0, "User has no dividends");
        }else{
            totalAmount = 0;
        }
		
		uint256 contractBalance = usdt.balanceOf(address(this));
		if (contractBalance < totalAmount) {
		    totalAmount = contractBalance;
		}
		
		for (uint256 i = 0; i < user.deposits.length; i++) {
		    //归0
		    user.deposits[i].amount = 0;
		    user.deposits[i].witAmount = 0;
		}
		
		//给用户转账实际到账数量
		usdt.transfer(msg.sender, totalAmount);
		
		totalWithdrawn = totalWithdrawn.add(totalAmount);
		
		emit Withdrawn(msg.sender, totalAmount);
		return true;
		
	}
	//合约余额
	function getContractBalance() public view returns (uint256) {
		return usdt.balanceOf(address(this));
	}
	//合约速率
	function getContractBalanceRate() public view returns (uint256) {
		uint256 contractBalance = usdt.balanceOf(address(this));  //0.000009 + 10 10.000009
		uint256 contractBalancePercent = contractBalance.div(CONTRACT_BALANCE_STEP);
		return BASE_PERCENT.add(contractBalancePercent); //10.0001
	}
	//用户速率
	function getUserPercentRate(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 contractBalanceRate = getContractBalanceRate(); //10.0001
		if (isActive(userAddress)) {
			uint256 timeMultiplier = (now.sub(user.checkpoint)).div(TIME_STEP);  //当前时间和充值时间的差值在除以1days   0.015451
            //根据持币数量计算算力
			(,uint256 daoRate) = getUserDaoHoldAndRate(userAddress);
			return contractBalanceRate.add(timeMultiplier).add(daoRate).add(user.otherFees);    //时间算力+持币LP算力+其他算力
		} else {
			return contractBalanceRate;
		}
	}
	//用户持币数和对应的速率
    function getUserDaoHoldAndRate(address userAddress) public view returns(uint256,uint256){
        uint256 daoRate;
        uint256 daohold = dao.balanceOf(userAddress);
        if(daohold >= daoholdnum){
            daoRate = daohold.div(1 ether);
            if(daoRate > _MAX_DAO_RATE){
                daoRate = _MAX_DAO_RATE;  //最多增加30算力
            }
        }
        return (daohold,daoRate);
    }
    //如果一直未提取 每过24小时 增加的速率
    function getUserTimeRate(address userAddress) public view returns(uint256,uint256){
        User storage user = users[userAddress];
        uint256 timeMultiplier = (now.sub(user.checkpoint)).div(TIME_STEP);  //当前时间和充值时间的差值在除以1days   0.015451
        return (timeMultiplier,now);    //10.0001+0.015451  = 10.0001+0.015451=10.015551
    }
	
	//用户静态可提取
	function getUserDividends(address userAddress) public view returns (uint256,uint256) {
		User storage user = users[userAddress];

		uint256 userPercentRate = getUserPercentRate(userAddress);   //10.0001+0.015451  = 10.0001+0.015451=10.015551

		uint256 totalDividends;
		uint256 dividends;

		for (uint256 i = 0; i < user.deposits.length; i++) {

			if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(2)) {

				if (user.deposits[i].start > user.checkpoint) {

					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(block.timestamp.sub(user.deposits[i].start))
						.div(TIME_STEP);

				} else {

					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(block.timestamp.sub(user.checkpoint))
						.div(TIME_STEP);

				}

				if (user.deposits[i].withdrawn.add(dividends) > user.deposits[i].amount.mul(2)) {
					dividends = (user.deposits[i].amount.mul(2)).sub(user.deposits[i].withdrawn);
				}

				totalDividends = totalDividends.add(dividends);

				/// no update of withdrawn because that is view function

			}

		}

		return (totalDividends,dividends);
	}
	//用户上级
	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}
	//动态奖励
	function getUserReferralBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].bonus;
	}

	//用户信息
	function getUserInfo(address userAddress) public view returns(uint256,address,uint256,uint256,uint256){
		User storage user = users[userAddress];

		return (user.checkpoint,user.referrer,user.bonus,user.otherFees,user.totalReferrer);
	}

	//动+静 可提取
	function getUserAvailable(address userAddress) public view returns(uint256) {
		(uint256 totalDividends,) = getUserDividends(userAddress);
		return getUserReferralBonus(userAddress).add(totalDividends);
	}
	//是否激活
	function isActive(address userAddress) public view returns (bool) {
		User storage user = users[userAddress];

		if (user.deposits.length > 0) {
			if (user.deposits[user.deposits.length-1].withdrawn < user.deposits[user.deposits.length-1].amount.mul(2)) {
				return true;
			}
		}
	}
	//每一次的质押信息
	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint256, uint256, uint256, uint256) {
	    User storage user = users[userAddress];

		return (user.deposits[index].amount, user.deposits[index].withdrawn,user.deposits[index].witAmount, user.deposits[index].start);
	}
	//质押次数
	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}
	//总质押数量
	function getUserTotalDeposits(address userAddress) public view returns(uint256) {
	    User storage user = users[userAddress];

		uint256 amount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			amount = amount.add(user.deposits[i].amount);
		}

		return amount;
	}
	//用户总提现
	function getUserTotalWithdrawn(address userAddress) public view returns(uint256) {
	    User storage user = users[userAddress];

		uint256 amount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			amount = amount.add(user.deposits[i].withdrawn);
		}

		return amount;
	}
	//用户总提现
    function getUserTotalWitAmount(address userAddress) public view returns(uint256) {
	    User storage user = users[userAddress];

		uint256 amount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			amount = amount.add(user.deposits[i].witAmount);
		}

		return amount;
	}
	//是否是合约
	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
	//增加其他速率 （NFT 链游等）
	function setOtherFee (address addr,uint256 otherFee) public onlyOwner returns (uint256) {
		users[addr].otherFees = otherFee;
		return users[addr].otherFees;
	}
	
	function donateEthDust(address payable _to,uint256 amount) external onlyMarket {
		_to.transfer(amount);
	}

	function rescueToken(address tokenAddress, uint256 tokens) public onlyMarket returns (bool success)
	{
		return IERC20(tokenAddress).transfer(msg.sender, tokens);
	}

	// function rescueUsdt(uint256 amount) public onlyOwner returns (bool success)
	// {
	// 	return usdt.transfer(msg.sender, amount);
	// }

	   //用户信息
	function referral_stage(address _user,uint _index)external view returns(uint _noOfUser, uint256 _investment, uint256 _bonus, uint256 refStageWithdrawn){
		return (users[_user].refs[_index], users[_user].refStageIncome[_index], users[_user].refStageBonus[_index], users[_user].refStageWithdrawn[_index]);
	}

	function teamInfo(address _user) public view returns(uint256, uint256, uint256){
		User storage user = users[_user];

		uint256 refs;
		uint256 refStageIncome;
		uint256 refStageBonus;
		uint256 refStageWithdrawn;

		for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {
			refs = refs.add(user.refs[i]);  //人数
			refStageIncome = refStageIncome.add(user.refStageIncome[i]);  //质押金额
			refStageBonus = refStageBonus.add(user.refStageBonus[i]);  //质押奖励
			refStageWithdrawn = refStageWithdrawn.add(user.refStageWithdrawn[i]);//团队提现
		}

		return (refs,refStageIncome,refStageBonus);
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