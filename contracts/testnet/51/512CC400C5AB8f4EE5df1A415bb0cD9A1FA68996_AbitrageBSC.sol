// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IUniswapV2Router02.sol";
import "./IERC20.sol";

contract AbitrageBSC {
    address public owner;

    address public wbnbAddress;

    uint256 public arbitrageAmount;
    uint256 public contractbalance;

    enum Exchange {
        First,
        Second,
        NONE
    }

    constructor(
        address _wbnb
    ) {     
        owner = msg.sender;
        wbnbAddress = _wbnb;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call this");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function deposit() public payable{
        contractbalance += msg.value;
    }

    function withdraw(uint256 amount, address receiveaddress)  public onlyOwner {
        require(amount <= contractbalance, "Not enough amount deposited");
        payable(receiveaddress).transfer(amount);
        contractbalance -= amount;
    }

    function withdrawwbnb(address receiveaddress, uint256 receiveamount) public onlyOwner{
        IERC20(wbnbAddress).transfer(receiveaddress, receiveamount);
    }

    function setabitrigeamount(uint256 abt_amount) public onlyOwner{
        arbitrageAmount = abt_amount;
    }

    function makeArbitrage(address temptoken,address FRouter, address SRouter) public onlyOwner{
        uint256 amountIn = arbitrageAmount;
        Exchange result = _comparePrice(amountIn, temptoken, FRouter, SRouter);
        if (result == Exchange.First) {
            // sell ETH in uniswap for DAI with high price and buy ETH from sushiswap with lower price
            uint256 amountOut = _swap(
                amountIn,
                FRouter,
                wbnbAddress,
                temptoken
            );
            uint256 amountFinal = _swap(
                amountOut,
                SRouter,
                temptoken,
                wbnbAddress
            );
            contractbalance -= arbitrageAmount;
            contractbalance += amountFinal;
        } else if (result == Exchange.Second) {
            
            uint256 amountOut = _swap(
                amountIn,
                SRouter,
                wbnbAddress,
                temptoken
            );
            uint256 amountFinal = _swap(
                amountOut,
                FRouter,
                temptoken,
                wbnbAddress
            );
            contractbalance -= arbitrageAmount;
            contractbalance += amountFinal;
        }
    }


    //MakeAbitrage with wbnb

     function makeArbitragewithwbnb(address temptoken,address FRouter, address SRouter) public onlyOwner{
        uint256 amountIn = arbitrageAmount;
        Exchange result = _comparePrice(amountIn, temptoken, FRouter, SRouter);
        if (result == Exchange.First) {
            // sell ETH in uniswap for DAI with high price and buy ETH from sushiswap with lower price
            uint256 amountOut = swap(
                amountIn,
                FRouter,
                wbnbAddress,
                temptoken
            );
            uint256 amountFinal = swap(
                amountOut,
                SRouter,
                temptoken,
                wbnbAddress
            );
            contractbalance -= arbitrageAmount;
            contractbalance += amountFinal;
        } else if (result == Exchange.Second) {
            
            uint256 amountOut = swap(
                amountIn,
                SRouter,
                wbnbAddress,
                temptoken
            );
            uint256 amountFinal = swap(
                amountOut,
                FRouter,
                temptoken,
                wbnbAddress
            );
            contractbalance -= arbitrageAmount;
            contractbalance += amountFinal;
        }
    }

    function makeArbitrageprofit(address temptoken,address FRouter, address SRouter) public onlyOwner{
        uint256 amountIn = arbitrageAmount;
          Exchange result = _comparePriceprofit(amountIn, temptoken, FRouter, SRouter);
        if (result == Exchange.First) {
            // sell ETH in uniswap for DAI with high price and buy ETH from sushiswap with lower price
            uint256 amountOut = _swap(
                amountIn,
                FRouter,
                wbnbAddress,
                temptoken
            );
            uint256 amountFinal = _swap(
                amountOut,
                SRouter,
                temptoken,
                wbnbAddress
            );
            contractbalance -= arbitrageAmount;
            contractbalance += amountFinal;
        } else if (result == Exchange.Second) {
            
            uint256 amountOut = _swap(
                amountIn,
                SRouter,
                wbnbAddress,
                temptoken
            );
            uint256 amountFinal = _swap(
                amountOut,
                FRouter,
                temptoken,
                wbnbAddress
            );
            contractbalance -= arbitrageAmount;
            contractbalance += amountFinal;
        }
    }


    //MakeAbitrage with wbnb

     function makeArbitragewithwbnbusingprofit(address temptoken,address FRouter, address SRouter) public onlyOwner{
        uint256 amountIn = arbitrageAmount;
        Exchange result = _comparePriceprofit(amountIn, temptoken, FRouter, SRouter);
        if (result == Exchange.First) {
            // sell ETH in uniswap for DAI with high price and buy ETH from sushiswap with lower price
            uint256 amountOut = swap(
                amountIn,
                FRouter,
                wbnbAddress,
                temptoken
            );
            uint256 amountFinal = swap(
                amountOut,
                SRouter,
                temptoken,
                wbnbAddress
            );
            contractbalance -= arbitrageAmount;
            contractbalance += amountFinal;
        } else if (result == Exchange.Second) {
            
            uint256 amountOut = swap(
                amountIn,
                SRouter,
                wbnbAddress,
                temptoken
            );
            uint256 amountFinal = swap(
                amountOut,
                FRouter,
                temptoken,
                wbnbAddress
            );
            contractbalance -= arbitrageAmount;
            contractbalance += amountFinal;
        }
    }


    //test

    function makeabtFS(address temptoken, address FRouter, address SRouter) public onlyOwner returns(uint256) {

            uint256 amountIn = arbitrageAmount;
            uint256 amountOut = _swap(
                amountIn,
                FRouter,
                wbnbAddress,
                temptoken
            );

            uint256 amountFinal = _swap(
                amountOut,
                SRouter,
                temptoken,
                wbnbAddress
            );
            return amountFinal;
            
    }
    
    function _swap(
        uint256 amountIn,
        address routerAddress,
        address sell_token,
        address buy_token
    ) internal returns (uint256) {

        uint256 amountOutMin = (_getPrice(
            routerAddress,
            sell_token,
            buy_token,
            amountIn
        ) * 95) / 100;

        address[] memory path = new address[](2);
        path[0] = sell_token;
        path[1] = buy_token;
        if(sell_token == wbnbAddress){
        uint256 amountOut = IUniswapV2Router02(routerAddress)
            .swapExactETHForTokens{value:amountIn}(
                amountOutMin,
                path,
                address(this),
                block.timestamp + 300
            )[1];
        return amountOut;
        }
        else{
        require(IERC20(sell_token).approve(routerAddress, amountIn + 10000), 'approval failed');
        uint256 amountOut = IUniswapV2Router02(routerAddress)
            .swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                path,
                address(this),
                block.timestamp + 300
            )[1];
        return amountOut;
        }
    }

     function swap(
        uint256 amountIn,
        address routerAddress,
        address sell_token,
        address buy_token
    ) public returns (uint256) {

        uint256 amountOutMin = (_getPrice(
            routerAddress,
            sell_token,
            buy_token,
            amountIn
        ) * 95) / 100;

        address[] memory path = new address[](2);
        path[0] = sell_token;
        path[1] = buy_token;
        if(sell_token == wbnbAddress){
        require(IERC20(sell_token).approve(routerAddress, amountIn + 10000), 'approval failed');
        uint256 amountOut = IUniswapV2Router02(routerAddress)
            .swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                path,
                address(this),
                block.timestamp + 300
            )[1];
        return amountOut;
        }
        else{
        require(IERC20(sell_token).approve(routerAddress, amountIn + 10000), 'approval failed');
        uint256 amountOut = IUniswapV2Router02(routerAddress)
            .swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                path,
                address(this),
                block.timestamp + 300
            )[1];
        return amountOut;
        }
    }

    function _comparePrice(uint256 amount, address temptoken, address FRouter, address SRouter) internal view returns (Exchange) {
        uint256 FPrice = _getPrice(
            FRouter,
            wbnbAddress,
            temptoken,
            amount
        );
        uint256 SPrice = _getPrice(
            SRouter,
            wbnbAddress,
            temptoken,
            amount
        );

        // we try to sell ETH with higher price and buy it back with low price to make profit
        if (FPrice > SPrice) {
            require(
                _checkIfArbitrageIsProfitable(
                    FPrice,
                    SPrice
                ),
                "Arbitrage not profitable"
            );
            return Exchange.First;
        } else if (FPrice < SPrice) {
            require(
                _checkIfArbitrageIsProfitable(
                    SPrice,
                    FPrice
                ),
                "Arbitrage not profitable"
            );
            return Exchange.Second;
        } else {
            return Exchange.NONE;
        }
    }
   
    function _comparePriceprofit(uint256 amount, address temptoken, address FRouter, address SRouter) internal view returns (Exchange) {
        uint256 FPrice = _getPrice(
            FRouter,
            wbnbAddress,
            temptoken,
            amount
        );
        uint256 SPrice = _getPrice(
            SRouter,
            wbnbAddress,
            temptoken,
            amount
        );

        // we try to sell ETH with higher price and buy it back with low price to make profit
        if (FPrice > SPrice) {
            uint256 tempPrice = _getPrice(SRouter, temptoken, wbnbAddress, FPrice);
            require(
               tempPrice > amount,
                "Arbitrage not profitable"
            );
            return Exchange.First;
        } else if (FPrice < SPrice) {
            uint256 tempPrice = _getPrice(FRouter, temptoken, wbnbAddress, SPrice);
            require(
               tempPrice > amount,
                "Arbitrage not profitable"
            );
            return Exchange.Second;
        } else {
            return Exchange.NONE;
        }
    }

     function checkprofit(uint256 amount, address temptoken, address FRouter, address SRouter) public view returns (bool) {
        uint256 FPrice = _getPrice(
            FRouter,
            wbnbAddress,
            temptoken,
            amount
        );
        uint256 SPrice = _getPrice(
            SRouter,
            wbnbAddress,
            temptoken,
            amount
        );

        // we try to sell ETH with higher price and buy it back with low price to make profit
        if (FPrice > SPrice) {
            uint256 tempPrice = _getPrice(SRouter, temptoken, wbnbAddress, FPrice);
            if(tempPrice > amount) { return true;}
            else{
                return false;
            }
        } else if (FPrice < SPrice) {
            uint256 tempPrice = _getPrice(FRouter, temptoken, wbnbAddress, SPrice);
            if(tempPrice > amount) { return true;}
            else{
                return false;
            }
        } else {
            return false;
        }
    }


    function _checkIfArbitrageIsProfitable(
        uint256 higherPrice,
        uint256 lowerPrice
    ) internal pure returns (bool) {
        // uniswap & sushiswap have 0.3% fee for every exchange
        // so gain made must be greater than 2 * 0.3% * arbitrage_amount

        // difference in ETH
        uint256 difference = higherPrice - lowerPrice;

        uint256 payed_fee = (2 * (lowerPrice * 3)) / 1000;  

        if (difference > payed_fee) {
            return true;
        } else {
            return false;
        }
    }

    function _getPrice(
        address routerAddress,
        address sell_token,
        address buy_token,
        uint256 amount
    ) internal view returns (uint256) {
        address[] memory pairs = new address[](2);
        pairs[0] = sell_token;
        pairs[1] = buy_token;
        uint256 price = IUniswapV2Router02(routerAddress).getAmountsOut(
            amount,
            pairs
        )[1];
        return price;
    }
}