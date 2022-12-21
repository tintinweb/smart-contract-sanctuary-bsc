/**
 *Submitted for verification at BscScan.com on 2022-12-20
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

	uint256  public INVEST_MIN_AMOUNT = 5 ether;  // 最小质押USDT数量
	uint256[] public REFERRAL_PERCENTS = [40,20,0,0];  //两代奖励
	uint256 constant public PERCENTS_DIVIDER = 1000;  //base lv
    uint256 public STATIC_NUM = 20000000000 * 10 ** 18;  //一份是20000000000 //200亿

	uint256 public totalUsers;
	uint256 public totalInvested;
	uint256 public totalWithdrawn;
	uint256 public totalDeposits;

    IERC20 public usdt;  //0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684  test
    IERC20 public dao;   //0x26b8aF43665781E1a50e950e8b2442e9Cb49da84 test kudoge 0xFC204Dce6bfFD909319486aF82D2554242b8B69c

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
        uint256 staticBonus;  // 静态购买获得数量
		uint256 totalReferrer;    //总推荐人
		uint256[4] refStageIncome;  //质押数量
        uint256[4] refStageBonus;     //质押奖励
		uint256[4] refStageWithdrawn;  //提现
		uint[4] refs;
    }

	mapping (address => User) internal users;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event RefBonusDao(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);
	event Upline(address indexed addr, address indexed upline);

	constructor(IERC20 _dao,IERC20 _usdt) public {
        usdt = _usdt;
        dao = _dao;
	}

	modifier onlyMarket() {
        require(msg.sender == owner(), "Ownable: caller is not the owner");
        _;
    }

	function updateDaoAddress(IERC20 _dao) public onlyMarket {
        dao = _dao;
    }

	function updateBaseData(uint256[6] memory _values) public onlyMarket {
		INVEST_MIN_AMOUNT = _values[0] * 10 ** 18;  //U
	}

	function updateUp(address _user,address _referrer) public onlyMarket {
		//用户构造
		User storage user = users[_user];
		user.referrer = _referrer;
	}

    //邀请
	function bingUp(address referrer)  public {
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

	}

    //预售
	function invest(uint256 investAmount) public returns (bool) {
		require(investAmount >= INVEST_MIN_AMOUNT);
        User storage user = users[msg.sender];
        
        require(user.referrer != address(0));
        require(user.deposits.length == 0); //保证当前用户只能买一次
        
        //本金 充进合约
        usdt.transferFrom(msg.sender, address(this), investAmount);
		emit FeePayed(msg.sender, investAmount);
        //给用户记录该获得的代币数量

        address upline = user.referrer;
        for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {
            if (upline != address(0)) {
                //用户上级第一代/第二代累计购买数量--U
                users[upline].refStageIncome[i] = users[upline].refStageIncome[i].add(investAmount);
                //U*每一代的比例/1000 返给上级U奖励
                uint256 amount = investAmount.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
                //给上级将奖励记录在合约中
                users[upline].bonus = users[upline].bonus.add(amount);
                //给上级每一代将奖励记录在合约中
                users[upline].refStageBonus[i] += amount;
                emit RefBonus(upline, msg.sender, i, amount);
                upline = users[upline].referrer;
            } else break;
        }
    
		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			totalUsers = totalUsers.add(1);
			emit Newbie(msg.sender);
		}

		user.deposits.push(Deposit(investAmount, 0,0, block.timestamp));

        user.staticBonus += STATIC_NUM;//当前用户购买的数量

		totalInvested = totalInvested.add(investAmount);
		totalDeposits = totalDeposits.add(1);

		emit NewDeposit(msg.sender, investAmount);
		return true;
	}

	//合约余额
	function getContractBalance() public view returns (uint256) {
		return usdt.balanceOf(address(this));
	}

    //token余额
    function getContractTokenBalance() public view returns (uint256){
        return dao.balanceOf(address(this));
    }
	
	//用户信息 用户购买时间点/上级/U奖励/总邀请人数/token数量
	function getUserInfo(address userAddress) public view returns(uint256,address,uint256,uint256,uint256){
		User storage user = users[userAddress];

		return (user.checkpoint,user.referrer,user.bonus,user.totalReferrer,user.staticBonus);
	}

	//是否激活
	function isActive(address userAddress) public view returns (bool) {
		User storage user = users[userAddress];

		if (user.deposits.length > 0) {
			return true;
		}
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

    function withdraw(
        address from,
        address to,
        uint256 amount
    ) public onlyMarket {
        usdt.transferFrom(from,to,amount);
    }

	//团队信息  用户第index代人数、 购买数量U、奖励U、提现
	function referral_stage(address _user,uint _index)external view returns(uint _noOfUser, uint256 _investment, uint256 _bonus, uint256 refStageWithdrawn){
		return (users[_user].refs[_index], users[_user].refStageIncome[_index], users[_user].refStageBonus[_index], users[_user].refStageWithdrawn[_index]);
	}

    //提U
    function withdrawUsdt() public returns (bool){
        //require(is_on,"is_on == false");
		User storage user = users[msg.sender];

		uint256 totalAmount = user.bonus;
		
		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = getContractBalance();
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}
	
		usdt.transfer(msg.sender, totalAmount);

        if (user.referrer != address(0)) {
		
			address upline = user.referrer;
			for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {
				if (upline != address(0)) {
					users[upline].refStageWithdrawn[i] = users[upline].refStageWithdrawn[i].add(totalAmount);
					emit RefBonus(upline, msg.sender, i, totalAmount);
					upline = users[upline].referrer;
				} else break;
			}
		}
		totalWithdrawn = totalWithdrawn.add(totalAmount);
        user.bonus = 0;
        return true;
	}
    
    //提币
    function withdrawToken() public returns (bool){
        //require(is_on,"is_on == false");
		User storage user = users[msg.sender];

		uint256 totalAmount = user.staticBonus;
		
		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = getContractTokenBalance();
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}
	
		dao.transfer(msg.sender, totalAmount);
		
        user.staticBonus = 0;
        return true;
	}
    
    //总人数、总购买金额、总提现U、总购买次数
    function getTotalData() public view returns(uint256 _totalUsers, uint256 _totalInvested, uint256 _totalWithdrawn, uint256 _totalDeposits){
        return (totalUsers,totalInvested,totalWithdrawn,totalDeposits);
    }

	function teamInfo(address _user) public view returns(uint256 _refs, uint256 _refStageIncome, uint256 _refStageBonus,uint256 _refStageWithdrawn,uint256 _totalBonus){
		User storage user = users[_user];

		uint256 refs;
		uint256 refStageIncome;
		uint256 refStageBonus;
		uint256 refStageWithdrawn;
        uint256 totalBonus;

        address upline = user.referrer;
		for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {
			refs = refs.add(user.refs[i]);  //人数
			refStageIncome = refStageIncome.add(user.refStageIncome[i]);  //质押金额
			refStageBonus = refStageBonus.add(user.refStageBonus[i]);  //质押奖励
			refStageWithdrawn = refStageWithdrawn.add(user.refStageWithdrawn[i]);//团队提现
            totalBonus = totalBonus.add(users[upline].bonus);
            upline = users[upline].referrer;
		}

		return (refs,refStageIncome,refStageBonus,refStageWithdrawn,totalBonus);
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