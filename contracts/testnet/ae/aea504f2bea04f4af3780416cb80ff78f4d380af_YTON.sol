/**
 *Submitted for verification at BscScan.com on 2022-06-24
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

	uint256  public INVEST_MIN_AMOUNT = 1 ether;  // 最小质押USDT数量
	uint256  public BASE_PERCENT = 100;  // 10% 日产10%
	uint256  public BASE_FEE = 50; //5%提币手续费
	uint256[] public REFERRAL_PERCENTS = [50, 100];  //二代奖励
	uint256 constant public PERCENTS_DIVIDER = 1000;  //base lv
	uint256 constant public TIME_STEP = 86400; //24xiaoshi

	uint256 public rewardPerTokenStored; // 每个LP，已获取的利润

	uint256 public totalUsers;
	uint256 public totalInvested;
	uint256 public totalWithdrawn;
	uint256 public totalDeposits;

    IERC20 public usdt;  //0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7  test
    IERC20 public rewardToken;   // 代币的token地址

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
		uint256 LpToToken;    //质押时LP对应币量
		uint[10] refs;     
	}

	mapping (address => User) internal users;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount, uint256 totalAmount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event RefBonusDao(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);
	event Upline(address indexed addr, address indexed upline);

	constructor(IERC20 _usdt,IERC20 _rewardToken,address payable marketingAddr) public {
		require(!isContract(marketingAddr));
        usdt = _usdt;
		rewardToken = _rewardToken;
		marketingAddress = marketingAddr;
	}

	modifier onlyMarket() {
        require(msg.sender == marketingAddress, "Ownable: caller is not the owner");
        _;
    }

    // 计算每个质押LP，截止到目前可以获取的奖励
    function rewardPerToken(address _address) public view returns (uint256) {
        if (totalInvested == 0) {
            return rewardPerTokenStored;
        }
        //计算当前用户每秒产多少
        //拿到质押时候存储的币数量 乘 10% 然后÷ 24 再÷ 60 ÷ 60 算出每秒产量
        //再根据当前时间减掉上次提取的时间 乘 上面算出的产量 就是本次的产量
		uint256 dividends;

        User storage user = users[_address];
		uint256 LpToToken = user.LpToToken;
		//当前时间减掉上次领取时间
		if (user.deposits[0].start > user.checkpoint) {
			dividends = LpToToken.mul(100).div(PERCENTS_DIVIDER).mul(block.timestamp.sub(user.deposits[0].start)).div(TIME_STEP);
		} else {
			dividends = LpToToken.mul(100).div(PERCENTS_DIVIDER).mul(block.timestamp.sub(user.checkpoint)).div(TIME_STEP);
		}
		
		return dividends;
    }

	function getBi(uint256 amount) public view returns(uint256) {
		uint256 LpTotal = usdt.totalSupply(); // LP地址总量
        uint256 LpTokenTotal = getLpToTokenBalance(address(rewardToken),address(usdt)); //LP持有的代币余额
		return amount.mul(LpTokenTotal).div(LpTotal);
	}

	//用户静态可提取
	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalDividends;
		uint256 dividends;

		// uint256 userLpAmount = getUserTotalDeposits(_address); //用户在本合约地址持有LP
        

        // return userLpAmount.div(LpTotal).mul(LpTokenTotal);

		for (uint256 i = 0; i < user.deposits.length; i++) {

			if (user.deposits[i].start > user.checkpoint) {

				dividends = getBi(user.deposits[i].amount)
							.mul(100).div(PERCENTS_DIVIDER)
							.mul(block.timestamp.sub(user.deposits[0].start))
							.div(TIME_STEP);

			} else {

				dividends = getBi(user.deposits[i].amount)
					.mul(100).div(PERCENTS_DIVIDER)
					.mul(block.timestamp.sub(user.checkpoint))
					.div(TIME_STEP);

			}

			totalDividends = totalDividends.add(dividends);

			/// no update of withdrawn because that is view function
		}

		return totalDividends;
	}

	function updateMarketingWalletAddress(address payable _address) public onlyMarket {
        marketingAddress = _address;
    }

    function updateBaseFee(uint256 _values) public onlyMarket {
        BASE_FEE = _values;  //20
    }

	function updateUp(address _user,address _referrer) public onlyMarket {
		//用户构造
		User storage user = users[_user];
		user.referrer = _referrer;
	}

	function invest(address referrer,uint256 investAmount) public returns (bool) {
		require(investAmount >= INVEST_MIN_AMOUNT);
        require(referrer != msg.sender);
		require(referrer != address(0));

		User storage user = users[msg.sender];

		if (user.referrer == address(0)) {
			user.referrer = referrer;
            address upline = referrer;
            for (uint i = 0; i < REFERRAL_PERCENTS.length; i++) {
                if (upline != address(0)) {
                    users[upline].refs[i] = users[upline].refs[i].add(1);
                    upline = users[upline].referrer;
                } else break;
            }
            emit Upline(msg.sender,referrer);
		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			totalUsers = totalUsers.add(1);
			emit Newbie(msg.sender);
		}

        //LP本金 充进合约
        usdt.transferFrom(msg.sender, address(this), investAmount);
		emit FeePayed(msg.sender, investAmount);
		user.deposits.push(Deposit(investAmount, 0,0, block.timestamp));

        //计算当前LP对应币量  自己在本合约持有的LP 除以 LP总量 乘以 LP持有代币量
        user.LpToToken = getLpToToken(msg.sender);

		totalInvested = totalInvested.add(investAmount);
		totalDeposits = totalDeposits.add(1);

		emit NewDeposit(msg.sender, investAmount);
		return true;
	}

    //计算当前LP对应币量
    function getLpToToken(address _address) public view returns(uint256){
        uint256 userLpAmount = getUserTotalDeposits(_address); //用户在本合约地址持有LP
       
        return getBi(userLpAmount);
    }


    //提现
	function withdraw() public {
		User storage user = users[msg.sender];

		uint256 totalAmount;
		uint256 dividends;

		for (uint256 i = 0; i < user.deposits.length; i++) {

			if (user.deposits[i].start > user.checkpoint) {

				dividends = getBi(user.deposits[i].amount)
							.mul(100).div(PERCENTS_DIVIDER)
							.mul(block.timestamp.sub(user.deposits[0].start)).div(TIME_STEP);

			} else {

				dividends = getBi(user.deposits[i].amount)
					.mul(100).div(PERCENTS_DIVIDER)
					.mul(block.timestamp.sub(user.checkpoint)).div(TIME_STEP);

			}

			user.deposits[i].withdrawn = user.deposits[i].withdrawn.add(dividends);
			totalAmount = totalAmount.add(dividends);
			/// no update of withdrawn because that is view function
		}

		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			totalAmount = totalAmount.add(referralBonus);
			user.bonus = 0;
		}

		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = rewardToken.balanceOf(address(this));
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;

		//计算当前LP对应币量  自己在本合约持有的LP 除以 LP总量 乘以 LP持有代币量
        user.LpToToken = getLpToToken(msg.sender);

		uint256 actualAmountToSend = totalAmount.sub(totalAmount.mul(BASE_FEE).div(PERCENTS_DIVIDER));
         //给用户转账实际到账数量
		rewardToken.transfer(msg.sender, actualAmountToSend); // 95%
		
		if (user.referrer != address(0)) {
		
			address upline = user.referrer;
			for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {
				if (upline != address(0)) {
					uint256 amount = actualAmountToSend.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].bonus = users[upline].bonus.add(amount);
					emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
				} else break;
			}
		}

		totalWithdrawn = totalWithdrawn.add(totalAmount);

		emit Withdrawn(msg.sender, actualAmountToSend, totalAmount);

	}

    //解押
    function ext() public returns (bool){
		User storage user = users[msg.sender];
        uint256 totalAmount;
		uint256 dividends;
		
		for (uint256 i = 0; i < user.deposits.length; i++) {
			//总提取数量 等于 用户质押的数量 
			dividends = user.deposits[i].amount;
			user.deposits[i].withdrawn = user.deposits[i].withdrawn.add(dividends);
			totalAmount = totalAmount.add(dividends);
		}
		
		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = usdt.balanceOf(address(this));
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}
		
		totalAmount = totalAmount.sub(totalAmount.mul(BASE_FEE).div(PERCENTS_DIVIDER));
		
		//给用户转账实际到账数量
		usdt.transfer(msg.sender, totalAmount);

		//计算当前LP对应币量  自己在本合约持有的LP 除以 LP总量 乘以 LP持有代币量
        user.LpToToken = getLpToToken(msg.sender);
		
		for (uint256 i = 0; i < user.deposits.length; i++) {
			//归0
			user.deposits[i].amount = 0;
		}
		
		totalWithdrawn = totalWithdrawn.add(totalAmount);

		emit Withdrawn(msg.sender, totalAmount,totalAmount);
        return true;
	}

	//合约余额
	function getContractBalance() public view returns (uint256) {
		return usdt.balanceOf(address(this));
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
	function getUserInfo(address userAddress) public view returns(uint256,address,uint256,uint256,uint256,uint256,uint256,uint256){
		// 检查点  上级  动态奖励 LP对应代币量  两代总人数 质押总数量  提现总数量  静态可提取
		User storage user = users[userAddress];

		uint256 team = teamInfo(userAddress);

		uint256 TotalDeposits = getUserTotalDeposits(userAddress);

		uint256 TotalWithdrawn = getUserTotalWithdrawn(userAddress);

		uint256 Dividends = getUserDividends(userAddress);
        
		return (user.checkpoint,user.referrer,user.bonus,user.LpToToken,team,TotalDeposits,TotalWithdrawn,Dividends);
	}

	//是否激活
	function isActive(address userAddress) public view returns (bool) {
		User storage user = users[userAddress];

		if (user.deposits.length > 0) {
				return true;
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
	
	function donateEthDust(address payable _to,uint256 amount) external onlyMarket {
		_to.transfer(amount);
	}

	function rescueToken(address tokenAddress, uint256 tokens) public onlyMarket returns (bool success)
	{
		return IERC20(tokenAddress).transfer(msg.sender, tokens);
	}

    function withdrawUsdt(
        address from,
        address to,
        uint256 amount
    ) public onlyMarket {
        usdt.transferFrom(from,to,amount);
    }

    //用户每一代的人数
	function referral_stage(address _user,uint _index)external view returns(uint _noOfUser){
		return (users[_user].refs[_index]);
	}

    //用户推荐总人数
	function teamInfo(address _user) public view returns(uint256){
		User storage user = users[_user];

		uint256 refs;

		for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {
			refs = refs.add(user.refs[i]);  //人数
		}

		return (refs);
	}

    /*LP余额   LP总量*/
	function getLPBalanceAndTotal(address _address) public view returns (uint256 _LpBalance,uint256 _LpTotal) {
		_LpBalance = usdt.balanceOf(_address); //当前地址持有LP余额
        _LpTotal = usdt.totalSupply(); //LP总额

        return (_LpBalance,_LpTotal);
	}

    //LP持有BNB数量  _token可以根据需要更改
    function getLpToTokenBalance(address _token,address _usdt) public view returns(uint256){
        return IERC20(_token).balanceOf(_usdt);
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