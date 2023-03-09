/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8;
pragma abicoder v2;

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

interface IERC20 {
    function balanceOf(address _owner) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
}

interface IWETH {
    function deposit() external payable;
    function withdraw(uint) external;
}

contract ArbSwapper {
    address private owner;
    address wethAddress = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Forbidden");
        _;
    }

    function estimateProfitability(address buyDEXRouterAddress, address sellDEXRouterAddress, address baseToken, address tokenToArb, uint buyAmountETH) public view returns (uint totalProfit) {
        IUniswapV2Router buyDEXRouter = IUniswapV2Router(buyDEXRouterAddress);
        IUniswapV2Router sellDEXRouter = IUniswapV2Router(sellDEXRouterAddress);

        address[] memory buyPath;
        uint buyTokenOutput;

        // good until after here

        if (baseToken == wethAddress) {
            buyPath = new address[](2);
            buyPath[0] = baseToken;
            buyPath[1] = tokenToArb;
            buyTokenOutput = buyDEXRouter.getAmountsOut(buyAmountETH, buyPath)[1];
        }

        else {
            buyPath = new address[](3);
            buyPath[0] = wethAddress;
            buyPath[1] = baseToken;
            buyPath[2] = tokenToArb;  
            buyTokenOutput = buyDEXRouter.getAmountsOut(buyAmountETH, buyPath)[2];        
        }

        // --------------------------

        address[] memory sellPath;
        uint sellTokenOutput;

        if (baseToken == wethAddress) {
            sellPath = new address[](2);
            sellPath[0] = tokenToArb;
            sellPath[1] = baseToken;
            sellTokenOutput = sellDEXRouter.getAmountsOut(buyTokenOutput, sellPath)[1];
        }

        else {
            sellPath = new address[](3);
            sellPath[0] = tokenToArb;
            sellPath[1] = baseToken;
            sellPath[2] = wethAddress;  
            sellTokenOutput = sellDEXRouter.getAmountsOut(buyTokenOutput, sellPath)[2];        
        }
    
        if (sellTokenOutput < buyAmountETH) return 0;    
        else return sellTokenOutput - buyAmountETH;
    }

    function getReserves(
        address buyDEXFactoryAddress, 
        address sellDEXFactoryAddress, 
        address baseToken,
        address tokenToArb
    ) public view returns (uint reserve1_1, uint reserve1_2, uint reserve2_1, uint reserve2_2) {
        IUniswapV2Factory buyDEXFactory = IUniswapV2Factory(buyDEXFactoryAddress);
        IUniswapV2Factory sellDEXFactory = IUniswapV2Factory(sellDEXFactoryAddress);

        (reserve1_1,reserve1_2,) = IUniswapV2Pair(buyDEXFactory.getPair(baseToken, tokenToArb)).getReserves();
        (reserve2_1,reserve2_2,) = IUniswapV2Pair(sellDEXFactory.getPair(baseToken, tokenToArb)).getReserves();
    }

    function isDoubleDEXPaired(address baseToken, address tokenToCheck, address buyDEXRouterAddress, address sellDEXRouterAddress) public view returns (bool) {
        IUniswapV2Router buyDEXRouter = IUniswapV2Router(buyDEXRouterAddress);
        IUniswapV2Router sellDEXRouter = IUniswapV2Router(sellDEXRouterAddress);

        IUniswapV2Factory buyDEXFactory = IUniswapV2Factory(buyDEXRouter.factory());
        IUniswapV2Factory sellDEXFactory = IUniswapV2Factory(sellDEXRouter.factory());

        address buyTokenPair = buyDEXFactory.getPair(baseToken, tokenToCheck);
        address sellTokenPair = sellDEXFactory.getPair(baseToken, tokenToCheck);

        return (buyTokenPair != address(0) && sellTokenPair != address(0)) ? true : false;

    }

    function printCrypto(address buyDEXRouterAddress, address sellDEXRouterAddress, address baseToken, address tokenToArb) public payable onlyOwner {
        IUniswapV2Router buyDEXRouter = IUniswapV2Router(buyDEXRouterAddress);
        IUniswapV2Router sellDEXRouter = IUniswapV2Router(sellDEXRouterAddress);

        // case 1: user sends in ETH and baseToken = WETH
        // case 2: user sends in ETH and baseToken = BUSD

        uint initialBalance = IERC20(wethAddress).balanceOf(address(this));

        // (ETH -> BASE TOKEN / WETH) -> ARB TOKEN -> ARB TOKEN -> (BASE TOKEN / WETH -> ETH)

        if (baseToken != wethAddress) { //convert ETH to baseToken (if needed)
            buyDEXRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: initialBalance}(
                0,
                getPathFromTokenToToken(wethAddress, baseToken),
                address(this),
                block.timestamp
            );
        }

        else {
            IWETH(wethAddress).deposit{value: msg.value}();
        }

        // We've now either got WETH or baseToken eg. BUSD

        // baseToken -> arbToken (on exchange 1)

        buyDEXRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            buyDEXRouter.getAmountsOut(IERC20(baseToken).balanceOf(address(this)), getPathFromTokenToToken(baseToken, tokenToArb))[1],
            0,
            getPathFromTokenToToken(baseToken, tokenToArb),
            address(this),
            block.timestamp
        );

        // we've now got arbToken, sell it for baseToken on exchange 2

        // approve arbToken

        IERC20(tokenToArb).approve(sellDEXRouterAddress, type(uint).max);
        
        // arbToken -> baseToken (on exchange 2)

        sellDEXRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            buyDEXRouter.getAmountsOut(IERC20(tokenToArb).balanceOf(address(this)), getPathFromTokenToToken(tokenToArb, baseToken))[1],
            0,
            getPathFromTokenToToken(tokenToArb, baseToken),
            address(this),
            block.timestamp
        );

        if (baseToken != wethAddress) { //convert baseToken to ETH (if needed)
            sellDEXRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                sellDEXRouter.getAmountsOut(IERC20(baseToken).balanceOf(address(this)), getPathFromTokenToToken(baseToken, wethAddress))[1],
                0,
                getPathFromTokenToToken(baseToken, wethAddress),
                address(this),
                block.timestamp
            );
        }

        else {
            IWETH(wethAddress).withdraw(IERC20(wethAddress).balanceOf(address(this)));
        }
        
        uint finalBalance = address(this).balance;

        require(finalBalance > initialBalance, "Not profitable");

        payable(address(msg.sender)).transfer(address(this).balance);
    }

    function getPathFromTokenToToken(address token1, address token2) private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = token1;
        path[1] = token2;

        return path;
    }

  receive() payable external {}
}