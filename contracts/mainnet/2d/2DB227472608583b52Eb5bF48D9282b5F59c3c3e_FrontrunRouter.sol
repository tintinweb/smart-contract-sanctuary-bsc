/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

//unique comment to change bytecode 258gtg95ggrewb354g

pragma solidity 0.8.14;
pragma abicoder v2;

contract Ownable {
    address private owner;

    constructor () {
      address msgSender = msg.sender;
      owner = msgSender;
    }

    modifier onlyOwner() {
      require(msg.sender == owner, "Owner access only");
      _;
    }
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
}

interface IUniswapV2Pair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface ERC20 {
    function balanceOf(address _owner) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
}

contract FrontrunRouter is Ownable {
    address WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address factoryAddress = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;

    uint txDeadline = 100;

    function getPriceImpact(uint amountIn, address[] calldata buyPath) public view returns (uint[3] memory) {
        IUniswapV2Router uniswapRouter = IUniswapV2Router(routerAddress);
        IUniswapV2Factory uniswapFactory = IUniswapV2Factory(factoryAddress);
        uint[] memory amountsOut = uniswapRouter.getAmountsOut(amountIn, buyPath);
        uint amountOutExpected = amountsOut[amountsOut.length - 1];

        address tokenAddress = buyPath[buyPath.length - 1];
        address pairAddress = uniswapFactory.getPair(WETH, tokenAddress);

        IUniswapV2Pair uniswapPair = IUniswapV2Pair(pairAddress);

        (uint reserve0, uint reserve1, ) = uniswapPair.getReserves();

        uint wethReserve;
        uint tokenReserve;

        uint wethPoolReserve = ERC20(WETH).balanceOf(pairAddress);

        if (wethPoolReserve == reserve0) {
            wethReserve = reserve0;
            tokenReserve = reserve1;
        } 
            
        else {
            wethReserve = reserve1;
            tokenReserve = reserve0;
        }

        return [amountOutExpected, wethReserve, tokenReserve];
    }

    function doBuySwap() public {
        
    }

    function honeypotCheck(address tokenAddress, uint buyAmount) public returns (uint[6] memory) {       
        uint[] memory gas = new uint[](2);

        address[] memory buyPath = getTokenPath(WETH, tokenAddress);
        address[] memory sellPath = getTokenPath(tokenAddress, WETH);

        IUniswapV2Router exchangeRouter = IUniswapV2Router(routerAddress);

        uint expectedToken = exchangeRouter.getAmountsOut(buyAmount, buyPath)[1];         

        uint startGas = gasleft();
        exchangeRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: buyAmount}(0, buyPath, address(this), block.timestamp + 20);
        gas[0] = startGas - gasleft();

        ERC20(tokenAddress).approve(routerAddress, type(uint).max);

        uint receivedToken = ERC20(tokenAddress).balanceOf(address(this));
        uint expectedWETH = exchangeRouter.getAmountsOut(receivedToken, sellPath)[1];

        startGas = gasleft();
        exchangeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(receivedToken, 0, sellPath, address(this), block.timestamp + 20);
        gas[1] = startGas - gasleft();
       
        uint receivedWETH = address(this).balance;
    
        return [expectedToken, receivedToken, gas[0], expectedWETH, receivedWETH, gas[1]];
    }

    function Buy(address tokenAddress) public payable onlyOwner {

        //MAKE SURE NOT A HONEYPOT AND NO FEES

        uint[6] memory honeypotDetails = honeypotCheck(tokenAddress, msg.value);

        if (honeypotDetails[4] >= ((honeypotDetails[3] * 90) / 100)) {
            IUniswapV2Router uniswapRouter = IUniswapV2Router(routerAddress);
            uniswapRouter.swapExactETHForTokens{value: msg.value}(0, getTokenPath(WETH, tokenAddress), msg.sender, block.timestamp + txDeadline);
        }

        else {
            revert("Honeypot");
        }
    }

    function Sell(address tokenAddress) public onlyOwner {
        IUniswapV2Router uniswapRouter = IUniswapV2Router(routerAddress);

        uint tokenBalance = ERC20(tokenAddress).balanceOf(msg.sender);

        ERC20(tokenAddress).approve(routerAddress, (2**256 - 1));
        uniswapRouter.swapExactTokensForETH(tokenBalance, 0, getTokenPath(tokenAddress, WETH), msg.sender, block.timestamp + txDeadline);
    }

    function killContract() public onlyOwner {
        address payable caller = payable(msg.sender);
        selfdestruct(caller);
    }

    function getTokenPath(address token1, address token2) private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = token1;
        path[1] = token2;

        return path;
    }

    receive() payable external {}
}