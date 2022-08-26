/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

pragma solidity ^0.7.4;

interface IBEP20 {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

 
  function name() external view returns (string memory);


  function getOwner() external view returns (address);

 
  function balanceOf(address account) external view returns (uint256);

  
  function transfer(address recipient, uint256 amount) external returns (bool);

  
  function allowance(address _owner, address spender) external view returns (uint256);


  function approve(address spender, uint256 amount) external returns (bool);


  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  
  function mint(address _to, uint256 amount) external returns (bool);

 
  event Transfer(address indexed from, address indexed to, uint256 value);


  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakeSwapPair {
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

    event Mint(address indexed sender, uint amount0, uint amount1);
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

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeSwapRouter{
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

contract SMARTLEND {
	using SafeMath for uint256;
    using SafeMath for uint8;

	uint256 constant public INVEST_MIN_AMOUNT = 5e18; // 5 USD
    uint256 constant public RESTAKE_MIN_AMOUNT = 5e16; //0.05 USD
	uint256[] public REFERRAL_PERCENTS = [30, 20, 10, 10, 5];
	uint256 constant public PROJECT_FEE = 80;
	uint256 constant public DEVELOPER_FEE = 20;
    uint256 constant public SWAP_FEE = 5;

    uint256 constant public SWAP_REWARDS = 5;
	
	uint256 constant public PERCENTS_DIVIDER= 1000;
	uint256 constant public TIME_STEP = 1 days;

    IBEP20 public BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IBEP20 public USDT = IBEP20(0x55d398326f99059fF775485246999027B3197955);
    IBEP20 public USDC = IBEP20(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);
    IBEP20 public DAI = IBEP20(0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3);

    IPancakeSwapRouter public router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;
	

    
	
	uint256 public totalStaked;
	uint256 public totalRefBonus;
	uint256 public totalDeposits;
    uint256 public totalTradingVolume;

    struct Plan {
        uint256 time;
        uint256 percent;
    }

    Plan[] internal plans;
    IBEP20[] public tokens;

	struct Deposit {
        uint8 plan;
		uint256 percent;
		uint256 amount;
		uint256 profit;
		uint256 start;
		uint256 finish;
	}

	struct User {
		Deposit[] deposits;
        Deposit[] swapDeposits;
		uint256 checkpoint;
        uint256 swapCheckpoint;
		address payable referrer;
		uint256 referrals;
		uint256 totalBonus;
		uint256 withdrawn;
        uint256 swapTurnover;
	}

	mapping (address => User) internal users;
    

	uint256 public startUNIX;
	address payable private commissionWallet;
	address payable private developerWallet;
	
	

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
    event Swap(address indexed token0, address indexed token1, uint256 amount);

	constructor(address payable wallet, address payable _developer) public {
		require(!isContract(wallet));
		commissionWallet = wallet;
		developerWallet = _developer;
        startUNIX = block.timestamp.add(365 days);

         _status = _NOT_ENTERED;

        plans.push(Plan(70, 15)); // 1.5% per day for 70 days

        tokens.push(BUSD);
        tokens.push(USDT);
        tokens.push(USDC);
        tokens.push(DAI);

        
        
	}

    function launch() public {
        require(msg.sender == developerWallet);
		startUNIX = block.timestamp;
		
        
    } 

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }


    function invest(address payable referrer,uint8 plan,uint256 tokenId, uint256 amount) public {
        _invest(referrer, plan, msg.sender, amount,tokenId);
           
    }


	function _invest(address payable referrer, uint8 plan, address payable sender, uint256 value,uint256 tokenId) private {
		require(value >= INVEST_MIN_AMOUNT);
        require(plan < 1, "Invalid plan");
        require(startUNIX < block.timestamp, "contract hasn`t started yet");
        require(tokenId < 4, "Invalid token id");
		
        if(tokenId == 0) { //BUSD
            BUSD.transferFrom(sender, address(this),value);

        } else { 
            if(tokenId == 1){ //USDT
                USDT.transferFrom(sender, address(this),value);
            }

            if(tokenId == 2){ //USDC
                USDC.transferFrom(sender, address(this),value);
            }

            if(tokenId == 3){ //DAI
                DAI.transferFrom(sender, address(this),value);
            }

            value = swapTokensForBusd(tokenId,value);
        }

        uint256 fee = value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		BUSD.transfer(commissionWallet,fee);
		uint256 developerFee = value.mul(DEVELOPER_FEE).div(PERCENTS_DIVIDER);
		BUSD.transfer(developerWallet,developerFee);

		
		
		User storage user = users[sender];

		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != sender) {
				user.referrer = referrer;
			}

			address upline = user.referrer;
			for (uint256 i = 0; i < 5; i++) {
				if (upline != address(0)) {
					users[upline].referrals = users[upline].referrals.add(1);
					upline = users[upline].referrer;
				} else break;
			}
		}


				if (user.referrer != address(0)) {
					uint256 _refBonus = 0;
					address payable upline = user.referrer;
					for (uint256 i = 0; i < 5; i++) {
						if (upline != address(0)) {
							uint256 amount = value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
							
							users[upline].totalBonus = users[upline].totalBonus.add(amount);
                            BUSD.transfer(upline, amount);
							_refBonus = _refBonus.add(amount);
						
							emit RefBonus(upline, sender, i, amount);
							upline = users[upline].referrer;
						} else break;
					}

					totalRefBonus = totalRefBonus.add(_refBonus);

				}
		

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			emit Newbie(sender);
		}

		

		(uint256 percent, uint256 profit, uint256 finish) = getResult(plan, value);
		
		user.deposits.push(Deposit(plan, percent, value, profit, block.timestamp, finish));

		totalStaked = totalStaked.add(value);
        totalDeposits = totalDeposits.add(1);
		
		emit NewDeposit(sender, plan, percent, value, profit, block.timestamp, finish);
	}

    function reStake() public {
        require(startUNIX < block.timestamp, "contract hasn`t started yet");

        User storage user = users[msg.sender];

        uint256 totalAmount = getUserDividends(msg.sender);

        require(totalAmount >= RESTAKE_MIN_AMOUNT, "Invalid amount");

        uint256 fee = totalAmount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		BUSD.transfer(commissionWallet,fee);
		uint256 developerFee = totalAmount.mul(DEVELOPER_FEE).div(PERCENTS_DIVIDER);
		BUSD.transfer(developerWallet,developerFee);

        (uint256 percent, uint256 profit, uint256 finish) = getResult(0, totalAmount);

        user.deposits.push(Deposit(0, percent, totalAmount, profit, block.timestamp, finish));

        user.checkpoint = block.timestamp;

        totalStaked = totalStaked.add(totalAmount);
        totalDeposits = totalDeposits.add(1);

        emit NewDeposit(msg.sender, 0, percent, totalAmount, profit, block.timestamp, finish);

    }

	function withdraw() public {
		User storage user = users[msg.sender];

		uint256 totalAmount = getUserDividends(msg.sender);

		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = BUSD.balanceOf(address(this));
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;

		user.withdrawn = user.withdrawn.add(totalAmount);
		BUSD.transfer(msg.sender,totalAmount);

		emit Withdrawn(msg.sender, totalAmount);

	}

    function claimSwapRewards() public {
        User storage user = users[msg.sender];

		uint256 totalAmount = getUserSwapDividends(msg.sender);

		require(totalAmount > 0, "User has no rewards");

		uint256 contractBalance = BUSD.balanceOf(address(this));
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

		user.swapCheckpoint = block.timestamp;

		user.withdrawn = user.withdrawn.add(totalAmount);
		BUSD.transfer(msg.sender,totalAmount);

		emit Withdrawn(msg.sender, totalAmount);
    }

    function addSwapDeposit(uint256 value, address sender) private {

        User storage user = users[sender];

        if (user.swapDeposits.length == 0) {
			user.swapCheckpoint = block.timestamp;
			emit Newbie(sender);
		}

        (uint256 percent, uint256 profit, uint256 finish) = getResult(0, value);

        user.swapDeposits.push(Deposit(0, percent, value, profit, block.timestamp, finish));

        totalStaked = totalStaked.add(value);

        emit NewDeposit(sender, 0, percent, value, profit, block.timestamp, finish);

    }

	
    function swapTokensForBusd(uint256 tokenId, uint256 amount)  private nonReentrant returns(uint256) {

        IBEP20 _token = tokens[tokenId];

        address[] memory path = new address[](2);
        path[0] = address(_token); //token we want to swap
        path[1] = address(BUSD); //token we want to get

        uint256 contractBalanceBefore = BUSD.balanceOf(address(this));

        _token.approve(address(router), amount);

        router.swapExactTokensForTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 contractBalanceAfter = BUSD.balanceOf(address(this));

        uint256 depositedAmount = contractBalanceAfter.sub(contractBalanceBefore);

        return depositedAmount;
        
    }

    function swap(uint256 tokenId0, uint256 tokenId1, uint256 amount) public { 

        require(startUNIX < block.timestamp, "contract hasn`t started yet");
        require(tokenId0 < 4, "Invalid token in");
        require(tokenId1 < 4, "Invalid token out");

        IBEP20 _token0 = tokens[tokenId0];
        IBEP20 _token1 = tokens[tokenId1];

        _token0.transferFrom(msg.sender, address(this), amount);

        uint256 feeValue = amount.mul(SWAP_FEE).div(PERCENTS_DIVIDER);

        uint256 fee = feeValue.div(2);
		_token0.transfer(commissionWallet,fee);
		uint256 developerFee = feeValue.sub(fee);
		_token0.transfer(developerWallet,developerFee);

        uint256 newAmount = amount.sub(fee).sub(developerFee);

        address[] memory path = new address[](2);
        path[0] = address(_token0); //token we want to swap
        path[1] = address(_token1); //token we want to get

        _token0.approve(address(router), newAmount);


        router.swapExactTokensForTokens(
            newAmount,
            0,
            path,
            msg.sender,
            block.timestamp
        );

        uint256 swapRewards = amount.mul(SWAP_REWARDS).div(PERCENTS_DIVIDER);

        addSwapDeposit(swapRewards,msg.sender);

        User storage user = users[msg.sender];

        user.swapTurnover = user.swapTurnover.add(amount);
        totalTradingVolume = totalTradingVolume.add(amount);

        emit Swap(path[0],path[1],newAmount);


    }

    function swapTokensForBnb(uint256 tokenId, uint256 amount) public {

        require(startUNIX < block.timestamp, "contract hasn`t started yet");
        require(tokenId < 4, "Invalid tokenId");

        IBEP20 _token = tokens[tokenId];

         _token.transferFrom(msg.sender, address(this), amount);

        uint256 feeValue = amount.mul(SWAP_FEE).div(PERCENTS_DIVIDER);

        uint256 fee = feeValue.div(2);
		_token.transfer(commissionWallet,fee);
		uint256 developerFee = feeValue.sub(fee);
		_token.transfer(developerWallet,developerFee);

        uint256 newAmount = amount.sub(fee).sub(developerFee);
        
        address[] memory path = new address[](2);
        path[0] = address(_token);
        path[1] = router.WETH();

        _token.approve(address(router), newAmount);

        

        
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            newAmount,
            0, 
            path,
            msg.sender, 
            block.timestamp
        );

        uint256 swapRewards = amount.mul(SWAP_REWARDS).div(PERCENTS_DIVIDER);

        addSwapDeposit(swapRewards,msg.sender);

        User storage user = users[msg.sender];

        user.swapTurnover = user.swapTurnover.add(amount);
        totalTradingVolume = totalTradingVolume.add(amount);
        
         emit Swap(path[0],path[1],newAmount);
    }

    function swapBnbForTokens(uint256 tokenId) public payable {

        require(startUNIX < block.timestamp, "contract hasn`t started yet");
        require(tokenId < 4, "Invalid tokenId");

         IBEP20 _token = tokens[tokenId];

        uint256 feeValue = msg.value.mul(SWAP_FEE).div(PERCENTS_DIVIDER);

        uint256 fee = feeValue.div(2);
		commissionWallet.transfer(fee);
		uint256 developerFee = feeValue.sub(fee);
		developerWallet.transfer(developerFee);

        uint256 newAmount = msg.value.sub(fee).sub(developerFee);

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(_token);

        router.swapExactETHForTokens{value: newAmount}(
            0,
            path,
            msg.sender,
            block.timestamp.add(300)
        );



        uint256 expectedOut = router.getAmountsOut(msg.value,path)[1];

        uint256 swapRewards = expectedOut.mul(SWAP_REWARDS).div(PERCENTS_DIVIDER);

        addSwapDeposit(swapRewards,msg.sender);

        User storage user = users[msg.sender];

        user.swapTurnover = user.swapTurnover.add(expectedOut);
        totalTradingVolume = totalTradingVolume.add(expectedOut);


        emit Swap(path[0],path[1],newAmount);

    }

	function getContractBalance() public view returns (uint256) {
		return BUSD.balanceOf(address(this));
	}

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
		time = plans[plan].time;
		percent = plans[plan].percent;
	}

	function getPercent(uint8 plan) public view returns (uint256) {
	    
			return plans[plan].percent;
		
    }

    function _nonReentrantBefore() private {
        
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

       
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
    
        _status = _NOT_ENTERED;
    }

    

	function getResult(uint8 plan, uint256 deposit) public view returns (uint256 percent, uint256 profit, uint256 finish) {
		percent = getPercent(plan);

	
		
		profit = deposit.mul(percent).div(PERCENTS_DIVIDER).mul(plans[plan].time);
		

		finish = block.timestamp.add(plans[plan].time.mul(TIME_STEP));
	}
	


	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;
		

		for (uint256 i = 0; i < user.deposits.length; i++) {


			if (user.checkpoint < user.deposits[i].finish) {
				
				
					uint256 share = user.deposits[i].amount.mul(user.deposits[i].percent).div(PERCENTS_DIVIDER);
					uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
					uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
					if (from < to) {
						totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
					}

				 
					if(block.timestamp > user.deposits[i].finish) {
						totalAmount = totalAmount.add(user.deposits[i].amount);
					}
				
			}
		}

       
		return totalAmount;
	}

    function getUserSwapDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;
		

		for (uint256 i = 0; i < user.swapDeposits.length; i++) {


			if (user.swapCheckpoint < user.swapDeposits[i].finish) {
				
				
					uint256 share = user.swapDeposits[i].amount.mul(user.swapDeposits[i].percent).div(PERCENTS_DIVIDER);
					uint256 from = user.swapDeposits[i].start > user.swapCheckpoint ? user.swapDeposits[i].start : user.swapCheckpoint;
					uint256 to = user.swapDeposits[i].finish < block.timestamp ? user.swapDeposits[i].finish : block.timestamp;
					if (from < to) {
						totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
					}

				 
					if(block.timestamp > user.swapDeposits[i].finish) {
						totalAmount = totalAmount.add(user.swapDeposits[i].amount);
					}
				
			}
		}

       
		return totalAmount;
	}


    function getContractInfo() public view returns(uint256, uint256, uint256,uint256) {
        return(totalStaked, totalRefBonus, totalDeposits,totalTradingVolume);
    }

	function getUserWithdrawn(address userAddress) public view returns(uint256) {
		return users[userAddress].withdrawn;
	}

	function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}
    
	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	} 

	function getUserDownlineCount(address userAddress) public view returns(uint256) {
		return (users[userAddress].referrals);
	}

	function getUserReferralTotalBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus;
	}


	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}

    function getUserTotalSwapDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].swapDeposits.length; i++) {
			amount = amount.add(users[userAddress].swapDeposits[i].amount);
		}
	}

     function getUserSwapTurnover(address userAddress) public view returns(uint256) {
        return users[userAddress].swapTurnover;
    }

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish) {
	    User storage user = users[userAddress];

		plan = user.deposits[index].plan;
		percent = user.deposits[index].percent;
		amount = user.deposits[index].amount;
		profit = user.deposits[index].profit;
		start = user.deposits[index].start;
		finish = user.deposits[index].finish;
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
    
     function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}