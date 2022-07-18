/**
 *Submitted for verification at BscScan.com on 2022-07-18
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
    uint256 constant private PROJECT_FEE = 100;
    uint256 constant private NFT_FEE = 50;
	uint256 constant private PERCENTS_DIVIDER = 1000;

    IERC20 public usdt;  //0xb9DfD8FfbFFDD51A35033EFcDfCb151f85dA9516  test
    IERC20 public token;
    IERC20 public lp;

	address public adminAddress;
    address payable public marketingAddress;

    struct Token {
		uint256 amount;
		uint256 withdrawn;
		uint256 start;
	}

    struct LP {
		uint256 amount;
		uint256 withdrawn;
		uint256 start;
	}

	struct User {
        LP[] lp;
		Token[] token;
        address referrer;
        address upline;
		uint256 withdrawnAmount;
	}

    mapping (address => User) internal users;

	event WithdrawnUsdt(address indexed from, address indexed to, uint256 amount);
    event WithdrawnToken(address indexed from, address indexed to, uint256 amount);
    event WithdrawnLP(address indexed from, address indexed to, uint256 amount);
	event InvestUsdt(address indexed user, uint256 totalAmount);
    event InvestToken(address indexed user, uint256 totalAmount);
    event InvestLP(address indexed user, uint256 totalAmount);
    event InvestNFT(address indexed user, uint256 totalAmount);

	constructor(IERC20 _usdt,IERC20 _token,IERC20 _lp,address _adminAddress,address payable marketingAddr) public {
		require(!isContract(marketingAddr));
        usdt = _usdt;
        token = _token;
        lp = _lp;
        adminAddress = _adminAddress;
		marketingAddress = marketingAddr;
	}

	modifier onlyMarket() {
        require(msg.sender == adminAddress, "Ownable: caller is not the owner");
        _;
    }

    //IDO
	function investUsdt(uint256 investAmount) public returns (bool) {
		require(investAmount >= INVEST_MIN_AMOUNT);

        //IDO  10%留下 90%进固定钱包
        uint256 idofee = investAmount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        usdt.transferFrom(msg.sender, address(this), idofee);
        //90%
        usdt.transferFrom(msg.sender,marketingAddress,investAmount.sub(idofee));
		emit InvestUsdt(msg.sender, investAmount);
		
		return true;
	}

    //单币挖矿
	function investToken(uint256 investAmount) public returns (bool) {
		require(investAmount >= INVEST_MIN_AMOUNT);

        //LP本金 充进合约
        token.transferFrom(msg.sender, address(this), investAmount);
		emit InvestToken(msg.sender, investAmount);

        User storage user = users[msg.sender];

        user.token.push(Token(investAmount, 0, block.timestamp));
		
		return true;
	}

    //LP挖矿
	function investLP(uint256 investAmount) public returns (bool) {
		require(investAmount >= INVEST_MIN_AMOUNT);

        //LP本金 充进合约
        lp.transferFrom(msg.sender, address(this), investAmount);
		emit InvestLP(msg.sender, investAmount);
		
        User storage user = users[msg.sender];

        user.lp.push(LP(investAmount, 0, block.timestamp));

		return true;
	}

    //NFT中转
	function investNFT(uint256 investAmount,address to) public returns (bool) {
        //LP本金 充进合约
        uint256 nftfee = investAmount.mul(NFT_FEE).div(PERCENTS_DIVIDER);
        usdt.transferFrom(msg.sender, address(this), nftfee);
        //LP本金 充进合约
        usdt.transferFrom(msg.sender, to, investAmount.sub(nftfee));
		emit InvestNFT(msg.sender, investAmount);
		
		return true;
	}

    //提现
	function withdrawUsdt(address from,address to,uint256 amount) public onlyMarket {
		
         //给用户转账实际到账数量
        usdt.transferFrom(from,to,amount);

		emit WithdrawnUsdt(from,to,amount);

	}

     //提现LP
	function withdrawToken(address from,address to,uint256 amount) public onlyMarket {
		
         //给用户转账实际到账数量
        token.transferFrom(from,to,amount);

		emit WithdrawnToken(from,to,amount);

	}

     //解押token
	function extToken() public returns (bool) {
		User storage user = users[msg.sender];

        uint256 totalAmount;
		uint256 dividends;

        for (uint256 i = 0; i < user.token.length; i++) {
			//总提取数量 等于 用户质押的数量 
			dividends = user.token[i].amount;
			user.token[i].withdrawn = user.token[i].withdrawn.add(dividends);
			totalAmount = totalAmount.add(dividends);
		}

        require(totalAmount > 0, "User has no dividends");

        uint256 contractBalance = token.balanceOf(address(this));
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

        totalAmount = totalAmount.sub(totalAmount.mul(NFT_FEE).div(PERCENTS_DIVIDER)); //5%手续费

         //给用户转账实际到账数量
        token.transferFrom(address(this),msg.sender,totalAmount);

		emit WithdrawnToken(address(this),msg.sender,totalAmount);

        for (uint256 i = 0; i < user.token.length; i++) {
			//归0
			user.token[i].amount = 0;
		}
        return true;
	}

     //提现LP
	function withdrawLP(address from,address to,uint256 amount) public onlyMarket {
		
         //给用户转账实际到账数量
        lp.transferFrom(from,to,amount);

		emit WithdrawnLP(from,to,amount);

	}

     //解押LP
	function extLP() public returns (bool) {
		User storage user = users[msg.sender];

        uint256 totalAmount;
		uint256 dividends;

        for (uint256 i = 0; i < user.lp.length; i++) {
			//总提取数量 等于 用户质押的数量 
			dividends = user.lp[i].amount;
			user.lp[i].withdrawn = user.lp[i].withdrawn.add(dividends);
			totalAmount = totalAmount.add(dividends);
		}

        require(totalAmount > 0, "User has no dividends");

        uint256 contractBalance = lp.balanceOf(address(this));
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

        totalAmount = totalAmount.sub(totalAmount.mul(NFT_FEE).div(PERCENTS_DIVIDER)); //5%手续费

         //给用户转账实际到账数量
        lp.transferFrom(address(this),msg.sender,totalAmount);

		emit WithdrawnLP(address(this),msg.sender,totalAmount);

        for (uint256 i = 0; i < user.lp.length; i++) {
			//归0
			user.lp[i].amount = 0;
		}
        return true;
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