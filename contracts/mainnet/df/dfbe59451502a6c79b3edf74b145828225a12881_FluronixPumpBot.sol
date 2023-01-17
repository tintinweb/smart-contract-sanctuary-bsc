// SPDX-License-Identifier: SEE LICENSE IN LICENSE
// Developed by Tom, AKA High Frequency MarketKiller
// Website: https://fluronix.com/

pragma solidity >= 0.8.17;
import "./SafeERC20.sol";

interface IPancakeswap {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

contract FluronixPumpBot {
    using SafeERC20 for IERC20;
    address PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address PANCAKE_FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    
    struct BalanceStr{
        address token;
        uint balance;
    }

    function buy(uint amountIn, address motherCurrency, address[] memory fromTo,
    address[] memory token01, address pairAdress) external {

        address[] memory path = new address[](2);
        uint amountOut;
        uint amount0Out;
        uint amount1Out;

        //if mothercurrency is the 'From' currency then execute the trade
        if(motherCurrency == fromTo[0]){
            // set the 'FromTo' addresses
            path[0] = fromTo[0] == token01[0] ? token01[0] : token01[1];
            path[1] = fromTo[0] == token01[0] ? token01[1] : token01[0];

            amountOut = IPancakeswap(PANCAKE_ROUTER).getAmountsOut(amountIn, path)[1];
            amount0Out = path[1] == token01[0] ? amountOut: 0;
            amount1Out = path[1] == token01[1] ? amountOut: 0;

            // start the trade route
            IERC20(motherCurrency).safeTransferFrom(msg.sender, pairAdress, amountIn);
            IPancakeswap(pairAdress).swap(amount0Out, amount1Out, msg.sender, new bytes(0));
        } 
        else{ 
            // ---------------------------------------------------------------------------------------------||
            //Convert mothercurrency to 'From' currency and then execute the trade
            address convePair = IPancakeswap(PANCAKE_FACTORY).getPair(motherCurrency, fromTo[0]);
            require(convePair != address(0), "FluronixPumpBot.buy: INVALID CONVERTION PAIR");
            address conveToken0 =  IPancakeswap(convePair).token0();
            address conveToken1 = IPancakeswap(convePair).token1();

            // set the convertion paths
            path[0] = motherCurrency == conveToken0 ? conveToken0 : conveToken1;
            path[1] = motherCurrency == conveToken0 ? conveToken1 : conveToken0;

            amountOut = IPancakeswap(PANCAKE_ROUTER).getAmountsOut(amountIn, path)[1];
            amount0Out = path[1] == conveToken0 ? amountOut: 0;
            amount1Out = path[1] == conveToken1 ? amountOut: 0;

            // do the convertion
            IERC20(motherCurrency).safeTransferFrom(msg.sender, convePair, amountIn);
            IPancakeswap(convePair).swap(amount0Out, amount1Out, pairAdress, new bytes(0));

            // DO THE MAIN TRADE ______________________________________________
            // set the 'FromTo' 
            path[0] = fromTo[0] == token01[0] ? token01[0] : token01[1];
            path[1] = fromTo[0] == token01[0] ? token01[1] : token01[0];

            amountOut = IPancakeswap(PANCAKE_ROUTER).getAmountsOut(amountOut, path)[1];
            amount0Out = path[1] == token01[0] ? amountOut: 0;
            amount1Out = path[1] == token01[1] ? amountOut: 0;

            // start the trade route
            IPancakeswap(pairAdress).swap(amount0Out, amount1Out, msg.sender, new bytes(0));
        }
    }

    function sell(uint amountIn, address motherCurrency, address[] memory fromTo,
    address[] memory token01, address pairAdress) external {

        address[] memory path = new address[](2);
        uint amountOut;
        uint amount0Out;
        uint amount1Out;

        //check if the currency we want to swap to is the mothercurrency then execute the trade
        if(motherCurrency == fromTo[1]){
            // set the 'FromTo' addresses
            path[0] = fromTo[1] == token01[0] ? token01[1] : token01[0];
            path[1] = fromTo[1] == token01[0] ? token01[0] : token01[1];

            // Get the amountOut for trade 
            amountOut = IPancakeswap(PANCAKE_ROUTER).getAmountsOut(amountIn, path)[1];
            amount0Out = path[1] == token01[0] ? amountOut: 0;
            amount1Out = path[1] == token01[1] ? amountOut: 0;

            // start the trade route
            IERC20(fromTo[0]).safeTransferFrom(msg.sender, pairAdress, amountIn);
            IPancakeswap(pairAdress).swap(amount0Out, amount1Out, msg.sender, new bytes(0));
        }
        //convert to mothercurrency after trade execution
        else{
            address convePair = IPancakeswap(PANCAKE_FACTORY).getPair(motherCurrency, fromTo[1]);
            require(convePair != address(0), "FluronixPumpBot.sell: INVALID CONVERTION PAIR");
            address conveToken0 =  IPancakeswap(convePair).token0();
            address conveToken1 = IPancakeswap(convePair).token1();

            // set the 'FromTo' addresses
            path[0] = fromTo[1] == token01[0] ? token01[1] : token01[0];
            path[1] = fromTo[1] == token01[0] ? token01[0] : token01[1];

            // Get the amount out for trade
            amountOut = IPancakeswap(PANCAKE_ROUTER).getAmountsOut(amountIn, path)[1];
            amount0Out = path[1] == token01[0] ? amountOut: 0;
            amount1Out = path[1] == token01[1] ? amountOut: 0;

            // start the trade route
            IERC20(fromTo[0]).safeTransferFrom(msg.sender, pairAdress, amountIn);
            IPancakeswap(pairAdress).swap(amount0Out, amount1Out, convePair, new bytes(0));
            //________________________________________________________________________________

            // set the convertion paths
            path[0] = motherCurrency == conveToken0 ? conveToken1 : conveToken0;
            path[1] = motherCurrency == conveToken0 ? conveToken0 : conveToken1;

            //Get the amountout for convertion
            amountOut = IPancakeswap(PANCAKE_ROUTER).getAmountsOut(amountOut, path)[1];
            amount0Out = path[1] == conveToken0 ? amountOut: 0;
            amount1Out = path[1] == conveToken1 ? amountOut: 0;

            // Do the converting to mothercurrency
            IPancakeswap(convePair).swap(amount0Out, amount1Out, msg.sender, new bytes(0));
        }
    }

    // for honeypot verification (this function should be call as a static call)
    function simulateBuySell(uint volume, address from, address to) external{
        address[] memory path = new address[](2);
        uint amountOut;
        uint amount0Out;
        uint amount1Out;

        address pair = IPancakeswap(PANCAKE_FACTORY).getPair(from, to);
        require(pair != address(0), "simulateBuySell: fromTo returned 0 addr");
        address token0 =  IPancakeswap(pair).token0();
        address token1 = IPancakeswap(pair).token1();

        //BUY_____________________________________________
        path[0] = token0 == from ? token0 : token1;
        path[1] = token0 == from ? token1 : token0;

        amountOut = IPancakeswap(PANCAKE_ROUTER).getAmountsOut(volume, path)[1];
        amount0Out = path[1] == token0 ? amountOut: 0;
        amount1Out = path[1] == token1 ? amountOut: 0;

        IERC20(from).safeTransferFrom(msg.sender, pair, volume);
        IPancakeswap(pair).swap(amount0Out, amount1Out, address(this), new bytes(0));

        // SELL__________________________________________
        uint boughtAmt = getBalanceOfToken(to);
        path[0] = token0 == to ? token0 : token1;
        path[1] = token0 == to ? token1 : token0;

        amountOut = IPancakeswap(PANCAKE_ROUTER).getAmountsOut(boughtAmt, path)[1];
        amount0Out = path[1] == token0 ? amountOut: 0;
        amount1Out = path[1] == token1 ? amountOut: 0;

        IERC20(to).safeTransfer(pair, boughtAmt);
        IPancakeswap(pair).swap(amount0Out, amount1Out, msg.sender, new bytes(0));

    }

    // return balance of multiple tokens of a user address
    function multiBalanceOf(address[] memory tokens, address user) public view returns(BalanceStr[] memory balances){
        balances = new BalanceStr[](tokens.length);
        for(uint i; i < tokens.length; i++){
            balances[i] = BalanceStr(tokens[i], IERC20(tokens[i]).balanceOf(user));           
        }
    }
    // View balance of contract (for simulation only)
    function getBalanceOfToken(address _address) private view returns (uint256){
       return IERC20(_address).balanceOf(address(this));
    }
}