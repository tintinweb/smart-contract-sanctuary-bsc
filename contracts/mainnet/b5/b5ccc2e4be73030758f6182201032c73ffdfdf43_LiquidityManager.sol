/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

pragma solidity ^0.8.0;

interface I {
	function transferFrom(address from, address to, uint amount) external returns(bool);
	function sync() external; function addPool(address a) external;
	function balanceOf(address a) external view returns (uint);
	function transfer(address recipient, uint amount) external returns (bool);
	function approve(address spender, uint256 value) external returns (bool);
	function getPair(address tokenA, address tokenB) external view returns (address pair);
	function createPair(address t, address t1) external returns(address pair);
	function addLiquidity(
		address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin,	uint256 amountBMin, address to, uint256 deadline
	) external returns (uint256 amountA,uint256 amountB,uint256 liquidity);

	function removeLiquidity(
		address tokenA,	address tokenB,	uint256 liquidity,uint256 amountAMin,uint256 amountBMin,address to,	uint256 deadline
	) external returns (uint256 amountA, uint256 amountB);

	function swapExactTokensForTokens(
		uint256 amountIn,uint256 amountOutMin,address[] calldata path,address to,uint256 deadline
	) external returns (uint256[] memory amounts);

	function addLiquidityETH(
		address token,uint amountTokenDesired,uint amountTokenMin,uint amountETHMin,address to,uint deadline
	)external payable returns(uint amountToken,uint amountETH,uint liquidity);
}

contract LiquidityManager {
	
	address public router;
	address public factory;
	address public mainToken;
	address public defTokenFrom;
	address public defPoolFrom;
	address public defTokenTo;
	address public defPoolTo;
	address public liqMan;
	address public dao;
	mapping(address => uint) public amounts;

	function init() public {
		router=0x10ED43C718714eb63d5aA57B78B54704E256024E;
		factory=0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
		mainToken=0x3Fed9ed90E796E224eBFB0b4753c8e3d7a200388;//let token
		defTokenFrom=0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;//wbnb
		address LP = I(factory).getPair(mainToken,defTokenFrom);
        if (LP == address(0)) {
            LP=I(factory).createPair(mainToken, defTokenFrom);
        }
		defPoolFrom=LP;//wbnb pool
		I(mainToken).addPool(LP);
		defTokenTo=0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;//busd
		LP = I(factory).getPair(mainToken,defTokenTo);
        if (LP == address(0)) {
            LP=I(factory).createPair(mainToken, defTokenTo);
        }
		defPoolTo=LP;//busd pool
		I(mainToken).addPool(LP);
		liqMan=0xB23b6201D1799b0E8e209a402daaEFaC78c356Dc;// liquidity manager
		I(mainToken).approve(router,2**256-1); I(defTokenFrom).approve(router,2**256-1); I(defTokenTo).approve(router,2**256-1);
		I(defPoolFrom).approve(router,2**256-1); I(defPoolTo).approve(router,2**256-1);
	}

	modifier onlyLiqMan() { require(msg.sender == liqMan);_; }
	modifier onlyDao() { require(msg.sender == dao);_; }

	function approve(address token) public onlyLiqMan { I(token).approve(router,2**256-1); }

	function swapLiquidity(address tokenFrom, address tokenTo, uint percent) public onlyDao {
		address pFrom = I(factory).getPair(mainToken,tokenFrom); address pTo = I(factory).getPair(mainToken,tokenTo); uint liquidity = I(pFrom).balanceOf(address(this))*percent/100;
		if(I(mainToken).balanceOf(pTo)==0){I(mainToken).addPool(pTo);} _swapLiquidity(tokenFrom, tokenTo, liquidity);
	}

	function swapLiquidityDef(uint percent) public onlyLiqMan {
		uint amountFrom = I(mainToken).balanceOf(defPoolFrom); uint amountTo = I(mainToken).balanceOf(defPoolTo);
		uint liquidity; address tokenFrom = defTokenFrom; address tokenTo = defTokenTo;
		if(amountTo>amountFrom){ liquidity = I(defPoolTo).balanceOf(address(this)); tokenFrom = defTokenTo; tokenTo = defTokenFrom; }
		else { liquidity = I(defPoolFrom).balanceOf(address(this)); }
		liquidity = liquidity*percent/100;
		_swapLiquidity(tokenFrom, tokenTo, liquidity);
	}

	function _swapLiquidity(address tokenFrom, address tokenTo, uint liquidity) private {
		address[] memory ar =  new address[](2); ar[0]=tokenFrom; ar[1]=tokenTo;
		I(router).removeLiquidity(mainToken, tokenFrom, liquidity,0,0,address(this),2**256-1);
		I(router).swapExactTokensForTokens(I(tokenFrom).balanceOf(address(this)),0,ar,address(this),2**256-1);
		I(router).addLiquidity(mainToken,tokenTo,I(mainToken).balanceOf(address(this)),I(tokenTo).balanceOf(address(this)),0,0,address(this),2**256-1);
		address p = I(factory).getPair(mainToken,tokenTo);
		if(I(tokenTo).balanceOf(address(this))>0){
			I(tokenTo).transfer(p,I(tokenTo).balanceOf(address(this)));
			I(p).sync();
		}
		if(I(mainToken).balanceOf(address(this))>0){
			I(mainToken).transfer(p,I(mainToken).balanceOf(address(this)));
			I(p).sync();
		}
	}

	function changeDefTokenTo(address token) public onlyDao {
		defTokenTo = token; address pool = I(factory).getPair(mainToken,token);
		if(pool == address(0)){ pool=I(factory).createPair(mainToken, token); }
		defPoolTo = pool; I(defTokenTo).approve(router,2**256-1); I(defPoolTo).approve(router,2**256-1);
		I(mainToken).addPool(pool);
	}

	function addLiquidity() external payable {
		I(router).addLiquidityETH{value: address(this).balance}(mainToken, I(mainToken).balanceOf(address(this)),0,0,address(this),2**256-1);
	}

	function stakeLiquidity(uint amount) external {
		amounts[msg.sender] += amount;
		I(defPoolFrom).transferFrom(msg.sender,address(this),amount);
		uint amountFrom = I(mainToken).balanceOf(defPoolFrom);
		uint amountTo = I(mainToken).balanceOf(defPoolTo);
		if(amountTo>amountFrom){
			_swapLiquidity(defTokenFrom, defTokenTo, amount);
		}
	}

	function unstakeLiquidity(uint amount) external {
		require(amounts[msg.sender]>= amount);
		amounts[msg.sender]-= amount;
		if(I(defPoolFrom).balanceOf(address(this))>=amount){
			I(defPoolFrom).transfer(msg.sender,amount);
		} else {
			uint liquidity = I(defPoolTo).balanceOf(address(this));
			_swapLiquidity(defTokenTo, defTokenFrom, liquidity);
			I(defPoolFrom).transfer(msg.sender,amount);
			liquidity = I(defPoolFrom).balanceOf(address(this));
			_swapLiquidity(defTokenFrom, defTokenTo, liquidity);
		}
	}

	fallback() external payable {} receive() external payable {}//if uniswap sends back dust
}