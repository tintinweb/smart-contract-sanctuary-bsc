/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}





contract ERC20 is IERC20 {
    using SafeMath for uint256;
      IERC20 token;
     IERC20 nevis_token;
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 internal _limitSupply;

    string internal _name;
    string internal _symbol;
    uint8  internal _decimals;

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

   

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Context,Initializable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

      function owninitialize(address sender)  public initializer {
        address msgSender = sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
        
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) external virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() external virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
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


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract NEVISBANKv2  is ERC20,Ownable  {

    using SafeMath for uint256;
	//using SafeERC20 for IERC20;
	IUniswapV2Router02 public NevisSwapRouter;

    uint256 constant public INVEST_MIN_AMOUNT = 1e18; // 1 busd 
	uint256 constant public REFERRAL_PERCENTS 	= 500;
	uint256 constant public PROJECT_FEE = 1000;
    uint256 constant public TOKEN_FEE = 4500;
    uint256 constant public OTHER_FEE = 4500;
	uint256 constant public PERCENTS_DIVIDER = 10000;
    uint256 constant public PLANPER_DIVIDER = 1000000;

    uint256 public totalInvested;
	uint256 public totalRefBonus;	
    uint256  fInvested;
	
     struct Plan {
        uint256 time;
        uint256 percent;
    }

    Plan[] internal plans;

    address []investors;

	struct Deposit {
        uint8 plan;
		uint256 amount;
		uint256 start;
	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
        address referrer;
		uint256 bonus;
		uint256 totalBonus;
		uint256 withdrawn;
        uint256 reinvest;
        uint256 divident;
        uint256 withdrawnbonus;
        uint256 depositCount;
        SeedDeposit[] seedDeposit;
        RefSeedDeposit[] refSeedDeposit;
        address referral;
	}

    mapping (address => User) public users;
    mapping(address => address) internal referralAddress;
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 busdrecived,
        uint256 tokensIntoLiqudity
    );
    event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );
    event log(string message,uint256 value);

    address public NEVIS_TOKEN;
    address public BUSD;
    address public Pair;
    address public router;

    function initialize(address payable wallet,address Router,address Busd,address Nevis_token)  public initializer {
        Ownable.owninitialize(wallet);
        BUSD = Busd;
        router=Router;
        NEVIS_TOKEN = Nevis_token;
	    token = IERC20(BUSD);
        nevis_token = IERC20(NEVIS_TOKEN);
        plans.push(Plan(365,6027));
        IUniswapV2Router02 _NevisSwapRouter = IUniswapV2Router02(Router); 
	    NevisSwapRouter = _NevisSwapRouter;
    }

	function invest(address referrer, uint8 plan ,uint256 _amount) external payable {
	
        require(_amount >= INVEST_MIN_AMOUNT);
        require(plan < 1, "Invalid plan");

	    _approve(address(msg.sender),address(this), _amount);
        bool status=token.transferFrom(address(msg.sender),address(this), _amount);
        if(status){
		User storage user = users[msg.sender];
        	 bool    _newReferral                = true;
        if(referralLevel1Address[msg.sender] != 0x0000000000000000000000000000000000000000) {
            referrer                     = referralLevel1Address[msg.sender];
            _newReferral                    = true;
        }
        if (user.referrer == address(0)) {
                    if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
                        user.referrer = referrer;
                        address upline = user.referrer;
                        uint256 amount = _amount.mul(REFERRAL_PERCENTS).div(PERCENTS_DIVIDER);
                       // users[upline].bonus = users[upline].bonus.add(amount);
                        //users[upline].totalBonus = users[upline].totalBonus.add(amount);
                        emit RefBonus(upline, msg.sender, amount);
                        upline = users[upline].referrer;
                        user.bonus=user.bonus.add(amount);
                        user.totalBonus = user.totalBonus.add(amount);
                        
                        }                    
            }

        
        uint256 fee = _amount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);

        uint256 purchase_amount= _amount.mul(TOKEN_FEE).div(PERCENTS_DIVIDER);

        buy_token(purchase_amount.add(fee));

        uint256 purchase_TOKEN= _amount.mul(OTHER_FEE).div(PERCENTS_DIVIDER);
    
        swapAndLiquify(purchase_TOKEN);
        
        fInvested=purchase_amount.add(purchase_TOKEN);

        user.deposits.push(Deposit(plan, fInvested, block.timestamp));
       //1
        uint256 _roiincome = fInvested.mul(plans[plan].percent).div(PLANPER_DIVIDER); 
        address  _referralAdd=referrer;
        if(user.depositCount!=0)
        {
           _referralAdd=user.referrer;
        }
        distributeRef(_referralAdd, msg.sender, _newReferral,plan, _amount, _roiincome,block.timestamp); 
        user.depositCount++;
       
		totalInvested = totalInvested.add(fInvested);

        if(!includeIninvestor(msg.sender))
                    {
                        investors.push(msg.sender);
                    }
	
		emit NewDeposit(msg.sender, plan, fInvested);
        }
	}
    function buy_token(uint256 tokenAmount) private{
      
        address[] memory path = new address[](2);
		path[0] = BUSD;
		path[1] = NEVIS_TOKEN;
		IERC20(token).approve(address(NevisSwapRouter),tokenAmount);

            NevisSwapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    tokenAmount,
                    0, 
                    path,
                    address(this),
                    block.timestamp + 1000
                );
        
        emit SwapTokensForETH(tokenAmount, path);   
    }


  function swapAndLiquify(uint256 contractTokenBalance) private  {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = nevis_token.balanceOf(address(this));

        // swap tokens for ETH
        buy_token(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = nevis_token.balanceOf(address(this)).sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function addLiquidity(uint256 busdAmount,uint256 tokenAmount) private {
        // approve token transfer to cover all possible scenarios

        IERC20(token).approve(address(NevisSwapRouter),busdAmount);
        IERC20(nevis_token).approve(address(NevisSwapRouter),tokenAmount);

         NevisSwapRouter.addLiquidity(
                     BUSD,
                     NEVIS_TOKEN,
                     busdAmount,
                     tokenAmount,
                     0,
                     0,
                    address(this),
                    block.timestamp
            );
    }

 

    function withdraw() public {
		User storage user = users[msg.sender];

		uint256 totalAmount = getUserDividends(msg.sender);
        user.divident=user.divident.add(totalAmount);
		uint256 referralBonus = getUserReferralBonus(msg.sender);
        if (referralBonus > 0) {
            user.bonus = 0;
            user.withdrawnbonus = user.withdrawnbonus.add(referralBonus);
			totalAmount = totalAmount.add(referralBonus);
		}

		require(totalAmount > 0, "User has no dividends");
		user.checkpoint = block.timestamp;
        swaptoken(totalAmount);
        uint256 fee = totalAmount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        uint256 famount=totalAmount.sub(fee);
        user.withdrawn = user.withdrawn.add(totalAmount);
        token.transfer(msg.sender,famount);
		emit Withdrawn(msg.sender, totalAmount);
	}

     function getTokenPrice() public view returns(uint[] memory amounts)
        {
            address[] memory path = new address[](2);
            path[0] = BUSD;
            path[1] = NEVIS_TOKEN ;
            return NevisSwapRouter.getAmountsIn(1, path);
        }

    function swaptoken(uint256 _Amount) private {
             
            (uint256[] memory _amount)=getTokenPrice();
            uint256 famount=_Amount.div(_amount[0]);
           
            IERC20(nevis_token).approve(address(NevisSwapRouter),famount);

            address[] memory path = new address[](2);
            path[0] = NEVIS_TOKEN;
            path[1] = BUSD;
            token.approve(address(NevisSwapRouter),famount);

                NevisSwapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        famount,
                        0, 
                        path,
                        address(this),
                        block.timestamp + 1000
                ); 
                
    }


    function reinvest() public{

        User storage user = users[msg.sender];
		uint256 totalAmount = getUserDividends(msg.sender);
		uint256 referralBonus = getUserReferralBonus(msg.sender);
        user.divident=user.divident.add(totalAmount);
		if (referralBonus > 0) {
            user.bonus = 0;
            user.withdrawnbonus=user.withdrawnbonus.add(referralBonus);
			totalAmount = totalAmount.add(referralBonus);
		}
        require(totalAmount > 0, "Not able to roll");
        user.checkpoint = block.timestamp;
        user.reinvest = user.reinvest.add(totalAmount);

        uint256 fee = totalAmount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        uint256 famount=totalAmount.sub(fee);

        user.deposits.push(Deposit(0, famount, block.timestamp));
        swaptoken(fee);
	    totalInvested = totalInvested.add(famount);
		emit NewDeposit(msg.sender, 0, famount);
		
    }

    function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;
        
		for (uint256 i = 0; i < user.deposits.length; i++) {
			uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 days));
			if (user.checkpoint < finish) {
				uint256 share = user.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PLANPER_DIVIDER);
				uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
				uint256 to = finish < block.timestamp ? finish : block.timestamp;
                uint daysDiff = (to - from) / 60 / 60/ 24;
				if (from < to) {
					totalAmount = totalAmount.add(share.mul(daysDiff));
				}
			}
		}

		return totalAmount;
	}

    function includeIninvestor(address recipient) private view returns(bool _investor) {
            for (uint256 i = 0; i < investors.length; i++) {
                if (investors[i] == recipient) {
                        return true;
                }
            } 
    }

	function getUserReferralBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].bonus;
	}
    
    function getUserAmountOfRoll(address userAddress) public view returns(uint256) {
		return users[userAddress].reinvest;
	}

    function getContractBUSDBalance() public view returns (uint) {
	    return token.balanceOf(address(this));
	}  
	
	function getContractTokenBalance() public view returns (uint) {
		return nevis_token.balanceOf(address(this));
	} 

    function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

    function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}
    function getUserAvailable(address userAddress) public view returns(uint256) {
       User storage user = users[userAddress]; 
		return (user.totalBonus.sub(user.withdrawnbonus)).add(getUserDividends(userAddress));
	}
    function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}
    function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish) {
	    User storage user = users[userAddress];

		plan = user.deposits[index].plan;
		percent = plans[plan].percent;
		amount = user.deposits[index].amount;
		start = user.deposits[index].start;
		finish = user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(1 days));
	}

    function rewards(address userAddress, uint256 amount) public onlyOwner() {
        
        require(getContractBUSDBalance() > amount,"Low Balance");
        token.transfer(userAddress,amount);
       
	}

    function getSiteInfo() public view returns(uint256 _totalInvested, uint256 _totalBonus) {
		return(totalInvested, totalRefBonus);
	}
    function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawn;
	}
	function getUserInfo(address userAddress) public view returns(uint256 totalDeposit, uint256 totalWithdrawn) {
		return(getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress));
	}

    function getinfo() public view returns(uint256 paid) {
        uint256 totalamount;
		for(uint256 i = 0; i < investors.length; i++){
              User storage user = users[investors[i]];
             totalamount += getUserDividends(investors[i]).add(user.bonus.add(user.withdrawn).add(user.reinvest));
        }
          return totalamount;
	}

    function setPairaddress(address pair_address) public onlyOwner() {
          
                Pair = pair_address;
          
    }

    function setRouteraddress(address router_address) public onlyOwner() {
         
                router = router_address;
          
    }



    function getinvestor() public view returns (uint256 investor){

         return investor= investors.length;   

    }
    
    uint256 public SEED_PERCENTS;
    uint256 public SEED_DAYS;


    function Seed_value(uint256 seed_p,uint256 seed_d) public {
     SEED_PERCENTS= seed_p;
     SEED_DAYS=seed_d;
    }
    struct RefUserDetail {
        address refUserAddress;
        uint256 refLevel;
    }

    mapping(address => mapping (uint => RefUserDetail)) public RefUser;
    mapping(address => uint256) internal referralCount_;
	mapping(address => address) internal referralLevel1Address;
   
    struct SeedDeposit {
        address owneraddress;
        address downlineaddress;
        uint256 level;
        uint8 plan;
		uint256 amount;
        uint256 _roiIncome;
		uint256 start;
        uint256 perc;
        uint256 seeddays;
	}

    struct RefSeedDeposit {
        address owneraddress;
        address downlineaddress;
        uint256 level;
       	uint256 lindex;
    }
    
    function getDownlineRef(address senderAddress, uint dataId) public view returns (address,uint) { 
        return (RefUser[senderAddress][dataId].refUserAddress,RefUser[senderAddress][dataId].refLevel);
    }

    function addDownlineRef(address senderAddress, address refUserAddress, uint8 refLevel,uint8 _plan, uint256 _amount,uint256 _roiIncome,uint256 timestamp) internal {
        User storage user = users[senderAddress];
        uint8 active = 0;
       
        referralCount_[senderAddress]++;
        uint dataId = referralCount_[senderAddress];
        RefUser[senderAddress][dataId].refUserAddress = refUserAddress;
        RefUser[senderAddress][dataId].refLevel = refLevel;
        uint256 lindex =users[senderAddress].seedDeposit.length;
        user.seedDeposit.push(SeedDeposit(senderAddress,refUserAddress,refLevel,_plan, _amount, _roiIncome,timestamp,SEED_PERCENTS,SEED_DAYS));
        users[refUserAddress].refSeedDeposit.push(RefSeedDeposit(senderAddress,refUserAddress,refLevel,lindex));
        active = 1;
      
        
    }

function distributeRef(address _referredBy,address _sender, bool _newReferral,uint8 _plan, uint256 _amount,uint256 _roiIncome,uint256 timestamp) internal {
       
          address _customerAddress        = _sender;
        // Level 1
        referralLevel1Address[_customerAddress]                     = _referredBy;
        if(_newReferral == true) {
            addDownlineRef(_referredBy, _customerAddress, 1,_plan,_amount,_roiIncome,timestamp);
        }
      
    }

  
      function getUserSeedDepositInfo(address userAddress, uint256 index) public view returns(address owneraddress,address downlineaddress,uint256 level, uint256 amount, uint256 _roiIncome,uint256 percentage, uint256 start,uint256 share,uint256 seedshare) {
	    User storage user = users[userAddress];
        if(users[userAddress].seedDeposit.length > 0)
        {
            owneraddress = user.seedDeposit[index].owneraddress;
            downlineaddress = user.seedDeposit[index].downlineaddress;
            level = user.seedDeposit[index].level;
            amount = user.seedDeposit[index].amount;
            _roiIncome = user.seedDeposit[index]._roiIncome;
            percentage =user.seedDeposit[index].perc;
            start = user.seedDeposit[index].start;
            share = user.seedDeposit[index]._roiIncome.mul(plans[user.seedDeposit[index].plan].percent).div(PLANPER_DIVIDER);
            seedshare = share.mul(user.seedDeposit[index].perc).div(PERCENTS_DIVIDER);

        }

	}

    function getUserRefSeedDepositInfo(address userAddress, uint256 index) public view returns(address owneraddress,address downlineaddress,uint256 level,uint256 lindex) {
	    User storage user = users[userAddress];
        if(users[userAddress].refSeedDeposit.length > 0 && users[userAddress].refSeedDeposit.length-1 <= index)
        {
            owneraddress = user.refSeedDeposit[index].owneraddress;
            downlineaddress = user.refSeedDeposit[index].downlineaddress;
            level = user.refSeedDeposit[index].level;
            lindex = user.refSeedDeposit[index].lindex;
            
        }

	}

    /*function getUserSeedIncome(address userAddress) public view returns (uint256){
	
        uint256 seedshare;
        uint256 f_seed;
        uint256 f_amount;
        uint256 FinalAmount;
		uint256 count = referralCount_[userAddress];
		
		for	(uint256 y=1; y<= count; y++)
		{
		    uint256 level;
		    address addressdownline;
		    
		    (addressdownline,level) = getDownlineRef(userAddress, y);
		
			User storage downline =users[addressdownline];
            uint256 totaldeposite =gettotaldeposite(userAddress);
			
			for (uint256 i = 0; i < downline.deposits.length; i++) {
                
				uint256 finish = downline.deposits[i].start.add(plans[downline.deposits[i].plan].time.mul(1 days));
				if (downline.deposits[i].start < finish) {
					uint256 share = downline.deposits[i].amount.mul(plans[downline.deposits[i].plan].percent).div(PLANPER_DIVIDER);
					uint256 from = downline.deposits[i].start;
					uint256 to = finish < block.timestamp ? finish : block.timestamp;
                    uint256 daysDiff = 2;
                    seedshare = share.mul(SEED_PERCENTS).div(PERCENTS_DIVIDER);
                   
					if (from < to) {
                        f_seed =f_seed+seedshare; 
                      
                        if(totaldeposite > f_seed )
                        {
                            FinalAmount = seedshare;
                           
                            f_amount=f_amount.add(FinalAmount);
                        }
                        else
                        {
                            FinalAmount = totaldeposite;
                            f_amount=FinalAmount.mul(daysDiff);
                        }
                    }
                     
				}
			}
		
		}
		
		return f_amount;		

	} */

    function getUserSeedIncome(address userAddress) public view returns (uint256){
	
        uint256 seedshare;
        uint256 f_seed;
        uint256 f_amount;
        uint256 FinalAmount;
	    User storage user =users[userAddress];
        uint256 totaldeposite =gettotaldeposite(userAddress);
		
        for (uint256 i = 0; i < user.seedDeposit.length; i++) 
               {
 				 uint256 finish = user.seedDeposit[i].start.add(user.seedDeposit[i].seeddays.mul(1 minutes));
				     if (user.seedDeposit[i].start < finish) {
                    uint256 share = user.seedDeposit[i]._roiIncome.mul(plans[user.seedDeposit[i].plan].percent).div(PLANPER_DIVIDER);
					uint256 from = user.seedDeposit[i].start;
					uint256 to = finish < block.timestamp ? finish : block.timestamp;
                    uint daysDiff = (to - from) / 60 ;
                    seedshare = share.mul(user.seedDeposit[i].perc).div(PERCENTS_DIVIDER);

                         //uint daysDiff1=share.mul(daysDiff+1);
                        if (from < to) {
                         f_seed =f_seed+seedshare; 
                      
                        if(totaldeposite > f_seed )
                        {
                            FinalAmount = seedshare;
                           
                            f_amount=f_amount.add(FinalAmount.mul(daysDiff));
                        }
                        else
                        {
                            FinalAmount = totaldeposite;
                            f_amount=FinalAmount;
                        }
                           
                        }
                
                    }
            
                }
			
       	
     return f_amount;		
	
    } 



function gettotaldeposite(address userAddress) public view returns (uint256){
	User storage user = users[userAddress];
		
        uint256 totalAmount;
		
        for (uint256 i = 0; i < user.deposits.length; i++) {
			uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 days));
			uint256 from = user.deposits[i].start;
			uint256 to = finish < block.timestamp ? finish : block.timestamp;

				if (from < to){

                   totalAmount = totalAmount.add(user.deposits[i].amount);
				}			
		}

		return totalAmount;	
	
	} 

    function setseedpercentage(uint256 percentage) public {
        SEED_PERCENTS=percentage;
    }

    function setseeddays(uint256 dayss) public {
        SEED_DAYS= dayss;     
    }

    


}