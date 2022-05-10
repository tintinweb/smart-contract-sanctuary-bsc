/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

interface IUniswapV2Router01 {
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

contract ArbRead {
    // Addresses
    address private constant FACTORY_PANCAKE =
        0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address private constant ROUTER_PANCAKE =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant FACTORY_APESWAP =
        0x0841BD0B734E4F5853f0dD8d7Ea041c241fb0Da6;
    address private constant ROUTER_APESWAP =
        0xcF0feBd3f17CEf5b47b0cD257aCf6025c5BFf3b7;

    address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    // Structures
    struct Exchange {
        address factory;
        address router;
    }

    struct PairTokens {
        address tokenA;
        address tokenB;
    }

    struct TradeGroup {
        Exchange fromExchange;
        Exchange toExchange;
        PairTokens fromPair;
        PairTokens toPair;
    }

    // Calculates the price of token to get n USD worth of token
    function getAmount(
        Exchange memory _exchange,
        PairTokens memory _pairTokens,
        uint256 _amountIn
    ) private view returns (uint256) {
        // Ensure pair exists
        address pair = IUniswapV2Factory(_exchange.factory).getPair(
            _pairTokens.tokenA,
            _pairTokens.tokenB
        );
        require(pair != address(0), "Pair does not exist on PancakeSwap");

        // Structure Path
        address[] memory path = new address[](2);
        path[0] = _pairTokens.tokenA;
        path[1] = _pairTokens.tokenB;

        // Get Amounts Out
        uint256[] memory amountsOut = IUniswapV2Router01(_exchange.router)
            .getAmountsOut(_amountIn, path);
        require(amountsOut.length == 2, "Amount out length should equal 2");

        // Return amount
        return amountsOut[1];
    }

    // Confirm if Profit
    function validateProfitable(uint256 _amountIn, uint256 _amountOut)
        private
        pure
        returns (bool)
    {
        return _amountOut > _amountIn;
    }

    // Performs direct Arbitrage check
    function calculateArbitrage(
        address _factoryA,
        address _factoryB,
        address _routerA,
        address _routerB,
        address _tokenA,
        address _tokenB,
        uint256 _amountIn
    ) external view returns (bool, uint256) {
        // Trade 1
        uint256 acquiredCoinT1 = getAmount(
            Exchange(_factoryA, _routerA),
            PairTokens(_tokenA, _tokenB),
            _amountIn
        );
        require(acquiredCoinT1 > 0, "Failed at Trade 1");

        // Trade 2
        uint256 acquiredCoinT2 = getAmount(
            Exchange(_factoryB, _routerB),
            PairTokens(_tokenB, _tokenA),
            acquiredCoinT1
        );
        require(acquiredCoinT2 > 0, "Failed at Trade 2");

        // Calculate profit
        bool isProfit = validateProfitable(_amountIn, acquiredCoinT2);
        if (isProfit) {
            return (isProfit, acquiredCoinT2 - _amountIn);
        } else {
            return (isProfit, 0);
        }
    }

    // Calculates and finds Arbitrage opportunity across default exchanges
    // Put tokens in any order
    function findArbitrage(address[2] memory _coins, uint256 _defaultDollars)
        external
        view
        returns (
            bool,
            uint256,
            TradeGroup memory
        )
    {
        // Perform input checks
        require(_defaultDollars > 0, "Dollar Input must be greater than zero");

        // Declare Variables
        uint256 initialAmountIn;
        uint256 acquiredCoinT2;
        address coin0 = _coins[0];
        address coin1 = _coins[1];

        // Trade possibilities
        TradeGroup[] memory tradePossibilities = new TradeGroup[](4);
        tradePossibilities[0] = TradeGroup(
            Exchange(FACTORY_PANCAKE, ROUTER_PANCAKE), // From Exchange
            Exchange(FACTORY_APESWAP, ROUTER_APESWAP), // To Exchange
            PairTokens(coin0, coin1), // From Token Pair
            PairTokens(coin1, coin0) // To Token Pair
        );
        tradePossibilities[1] = TradeGroup(
            Exchange(FACTORY_PANCAKE, ROUTER_PANCAKE), // From Exchange
            Exchange(FACTORY_APESWAP, ROUTER_APESWAP), // To Exchange
            PairTokens(coin1, coin0), // From Token Pair
            PairTokens(coin0, coin1) // To Token Pair
        );
        tradePossibilities[2] = TradeGroup(
            Exchange(FACTORY_APESWAP, ROUTER_APESWAP), // From Exchange
            Exchange(FACTORY_PANCAKE, ROUTER_PANCAKE), // To Exchange
            PairTokens(coin0, coin1), // From Token Pair
            PairTokens(coin1, coin0) // To Token Pair
        );
        tradePossibilities[3] = TradeGroup(
            Exchange(FACTORY_APESWAP, ROUTER_APESWAP), // From Exchange
            Exchange(FACTORY_PANCAKE, ROUTER_PANCAKE), // To Exchange
            PairTokens(coin1, coin0), // From Token Pair
            PairTokens(coin0, coin1) // To Token Pair
        );

        // Check for Arbitrage
        for (uint256 i = 0; i < tradePossibilities.length; i++) {
            // Initialise variables
            uint256 acquiredCoinT1;
            TradeGroup memory tradeGroup = tradePossibilities[i];
            address borrowingToken = tradeGroup.fromPair.tokenA;

            // Calculate initial borrow amount to match preferred USD starting
            if (borrowingToken != BUSD) {
                initialAmountIn = getAmount(
                    tradeGroup.fromExchange,
                    PairTokens(BUSD, borrowingToken),
                    _defaultDollars
                );
            } else {
                initialAmountIn = _defaultDollars;
            }
            require(initialAmountIn > 0, "Borrow amount calculation issue");

            // Trade 1 with borrowed coin
            acquiredCoinT1 = getAmount(
                tradeGroup.fromExchange,
                tradeGroup.fromPair,
                initialAmountIn
            );
            require(acquiredCoinT1 > 0, "Trade 1 issue");

            // Trade 2 with acquired coin
            acquiredCoinT2 = getAmount(
                tradeGroup.toExchange,
                tradeGroup.toPair,
                acquiredCoinT1
            );
            require(acquiredCoinT2 > 0, "Trade 2 issue");

            // Check if profitable
            bool isProfit = validateProfitable(initialAmountIn, acquiredCoinT2);

            // Return output
            if (isProfit) {
                return (isProfit, acquiredCoinT2 - initialAmountIn, tradeGroup);
            }
        }

        // Return False Dummy Data if no profit
        return (
            false,
            0,
            TradeGroup(
                Exchange(FACTORY_PANCAKE, ROUTER_PANCAKE), // From Exchange
                Exchange(FACTORY_APESWAP, ROUTER_APESWAP), // To Exchange
                PairTokens(coin0, coin1), // From Token Pair
                PairTokens(coin1, coin0) // To Token Pair
            )
        );
    }
}