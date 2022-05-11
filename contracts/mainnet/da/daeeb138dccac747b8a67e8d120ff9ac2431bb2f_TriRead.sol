/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

//SPDX-License-Identifier: Unlicense
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

contract TriRead {
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

    struct TokenGroup {
        address tokenA;
        address tokenB;
        address tokenC;
    }

    struct BorrowAmount {
        uint256 borrowTokenAmount;
    }

    struct TradeGroup {
        Exchange trade1Exchange;
        Exchange trade2Exchange;
        Exchange trade3Exchange;
        PairTokens trade1Pair;
        PairTokens trade2Pair;
        PairTokens trade3Pair;
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
    // Put in exact trade requirements and will check arbitrage
    function calculateArbitrage(
        address _trade1Factory,
        address _trade2Factory,
        address _trade3Factory,
        address _trade1Router,
        address _trade2Router,
        address _trade3Router,
        address _tokenA,
        address _tokenB,
        address _tokenC,
        uint256 _amountIn
    ) external view returns (bool, uint256) {
        // Trade 1
        uint256 acquiredCoinTrade1 = getAmount(
            Exchange(_trade1Factory, _trade1Router),
            PairTokens(_tokenA, _tokenB),
            _amountIn
        );

        // Trade 2
        uint256 acquiredCoinTrade2 = getAmount(
            Exchange(_trade2Factory, _trade2Router),
            PairTokens(_tokenB, _tokenC),
            acquiredCoinTrade1
        );

        // Trade 2
        uint256 acquiredCoinTrade3 = getAmount(
            Exchange(_trade3Factory, _trade3Router),
            PairTokens(_tokenC, _tokenA),
            acquiredCoinTrade2
        );

        // Check profitable
        bool isProfitable = validateProfitable(_amountIn, acquiredCoinTrade3);
        if (isProfitable) {
            return (isProfitable, acquiredCoinTrade3 - _amountIn);
        } else {
            return (isProfitable, 0);
        }
    }

    // Compares the outputs from each exchange and mixes the most favourable
    // Outputs a struct which shows the specific steps to trade
    function compareRatios(
        uint256[] memory _ratiosA,
        uint256[] memory _ratiosB,
        TokenGroup memory _tokenGroup
    ) private pure returns (TradeGroup memory) {
        // Initialise variables
        address factoryTrade1;
        address factoryTrade2;
        address factoryTrade3;
        address routerTrade1;
        address routerTrade2;
        address routerTrade3;

        // T1 Ratio Comparison
        if (_ratiosA[0] >= _ratiosB[0]) {
            factoryTrade1 = FACTORY_PANCAKE;
            routerTrade1 = ROUTER_PANCAKE;
        } else {
            factoryTrade1 = FACTORY_APESWAP;
            routerTrade1 = ROUTER_APESWAP;
        }

        // T2 Ratio Comparison
        if (_ratiosA[1] >= _ratiosB[1]) {
            factoryTrade2 = FACTORY_PANCAKE;
            routerTrade2 = ROUTER_PANCAKE;
        } else {
            factoryTrade2 = FACTORY_APESWAP;
            routerTrade2 = ROUTER_APESWAP;
        }

        // T3 Ratio Comparison
        if (_ratiosA[2] >= _ratiosB[2]) {
            factoryTrade3 = FACTORY_PANCAKE;
            routerTrade3 = ROUTER_PANCAKE;
        } else {
            factoryTrade3 = FACTORY_APESWAP;
            routerTrade3 = ROUTER_APESWAP;
        }

        // Define mix of Exchanges and Coins
        TradeGroup memory trade1Group = TradeGroup(
            Exchange(factoryTrade1, routerTrade1),
            Exchange(factoryTrade2, routerTrade2),
            Exchange(factoryTrade3, routerTrade3),
            PairTokens(_tokenGroup.tokenA, _tokenGroup.tokenB),
            PairTokens(_tokenGroup.tokenB, _tokenGroup.tokenC),
            PairTokens(_tokenGroup.tokenC, _tokenGroup.tokenA)
        );

        // Return
        return trade1Group;
    }

    // Finds arbitrage opportunities for various configurations
    // Just put in three coins and minimum test amount in USD
    // Assumed Borrow from PancakeSwap
    function findArbitrage(address[3] memory _tokens, uint256 _minBorrowAmount)
        external
        view
        returns (
            bool,
            uint256,
            TradeGroup memory
        )
    {
        // Initialise Variables
        uint256 borrowAmountInitial;
        TokenGroup memory tokenGroup = TokenGroup(
            _tokens[0],
            _tokens[1],
            _tokens[2]
        );

        // Initialise arrays for comparing most favourable prices
        uint256[] memory ratioArrayA = new uint256[](3);
        uint256[] memory ratioArrayB = new uint256[](3);

        // Get USD Equivalent of first token swap
        if (tokenGroup.tokenA != BUSD) {
            borrowAmountInitial = getAmount(
                Exchange(FACTORY_PANCAKE, ROUTER_PANCAKE),
                PairTokens(BUSD, tokenGroup.tokenA),
                _minBorrowAmount
            );
        } else {
            borrowAmountInitial = _minBorrowAmount;
        }

        BorrowAmount memory borrowAmount = BorrowAmount(borrowAmountInitial);

        // EXCHANGE A - ///////////////////////////////////////////////
        // PANCAKESWAP ONLY ///////////////////////////////////////////

        // Trade 1
        uint256 acquiredCoinT1 = getAmount(
            Exchange(FACTORY_PANCAKE, ROUTER_PANCAKE),
            PairTokens(tokenGroup.tokenA, tokenGroup.tokenB),
            borrowAmount.borrowTokenAmount
        );
        ratioArrayA[0] = acquiredCoinT1 / borrowAmount.borrowTokenAmount;

        // Trade 2
        uint256 acquiredCoinT2 = getAmount(
            Exchange(FACTORY_PANCAKE, ROUTER_PANCAKE),
            PairTokens(tokenGroup.tokenB, tokenGroup.tokenC),
            acquiredCoinT1
        );
        ratioArrayA[1] = acquiredCoinT2 / acquiredCoinT1;

        // Trade 3
        uint256 acquiredCoinT3 = getAmount(
            Exchange(FACTORY_PANCAKE, ROUTER_PANCAKE),
            PairTokens(tokenGroup.tokenC, tokenGroup.tokenA),
            acquiredCoinT2
        );
        ratioArrayA[2] = acquiredCoinT3 / acquiredCoinT2;

        if (
            validateProfitable(borrowAmount.borrowTokenAmount, acquiredCoinT3)
        ) {
            TradeGroup memory tradeGroup1 = TradeGroup(
                Exchange(FACTORY_PANCAKE, ROUTER_PANCAKE),
                Exchange(FACTORY_PANCAKE, ROUTER_PANCAKE),
                Exchange(FACTORY_PANCAKE, ROUTER_PANCAKE),
                PairTokens(tokenGroup.tokenA, tokenGroup.tokenB),
                PairTokens(tokenGroup.tokenB, tokenGroup.tokenC),
                PairTokens(tokenGroup.tokenC, tokenGroup.tokenA)
            );
            return (
                true,
                acquiredCoinT3 - borrowAmount.borrowTokenAmount,
                tradeGroup1
            );
        }

        // EXCHANGE B - ///////////////////////////////////////////////
        // APESWAP ONLY ///////////////////////////////////////////////

        // Trade 1
        acquiredCoinT1 = getAmount(
            Exchange(FACTORY_APESWAP, ROUTER_APESWAP),
            PairTokens(tokenGroup.tokenA, tokenGroup.tokenB),
            borrowAmount.borrowTokenAmount
        );
        ratioArrayB[0] = acquiredCoinT1 / borrowAmount.borrowTokenAmount;

        // Trade 2
        acquiredCoinT2 = getAmount(
            Exchange(FACTORY_APESWAP, ROUTER_APESWAP),
            PairTokens(tokenGroup.tokenB, tokenGroup.tokenC),
            acquiredCoinT1
        );
        ratioArrayB[1] = acquiredCoinT2 / acquiredCoinT1;

        // Trade 3
        acquiredCoinT3 = getAmount(
            Exchange(FACTORY_APESWAP, ROUTER_APESWAP),
            PairTokens(tokenGroup.tokenC, tokenGroup.tokenA),
            acquiredCoinT2
        );
        ratioArrayB[2] = acquiredCoinT3 / acquiredCoinT2;

        if (
            validateProfitable(borrowAmount.borrowTokenAmount, acquiredCoinT3)
        ) {
            TradeGroup memory tradeGroup2 = TradeGroup(
                Exchange(FACTORY_APESWAP, ROUTER_APESWAP),
                Exchange(FACTORY_APESWAP, ROUTER_APESWAP),
                Exchange(FACTORY_APESWAP, ROUTER_APESWAP),
                PairTokens(tokenGroup.tokenA, tokenGroup.tokenB),
                PairTokens(tokenGroup.tokenB, tokenGroup.tokenC),
                PairTokens(tokenGroup.tokenC, tokenGroup.tokenA)
            );
            return (
                true,
                acquiredCoinT3 - borrowAmount.borrowTokenAmount,
                tradeGroup2
            );
        }

        // FINAL TEST - ///////////////////////////////////////////////
        // MIXED EXCHANGES ////////////////////////////////////////////

        // Get Ratios
        TradeGroup memory tradeGroup = compareRatios(
            ratioArrayA,
            ratioArrayB,
            tokenGroup
        );

        // Trade 1
        acquiredCoinT1 = getAmount(
            tradeGroup.trade1Exchange,
            tradeGroup.trade1Pair,
            borrowAmount.borrowTokenAmount
        );

        // Trade 2
        acquiredCoinT2 = getAmount(
            tradeGroup.trade2Exchange,
            tradeGroup.trade2Pair,
            acquiredCoinT1
        );

        // Trade 3
        acquiredCoinT3 = getAmount(
            tradeGroup.trade3Exchange,
            tradeGroup.trade3Pair,
            acquiredCoinT2
        );

        // Return Output
        if (
            validateProfitable(borrowAmount.borrowTokenAmount, acquiredCoinT3)
        ) {
            return (
                true,
                acquiredCoinT3 - borrowAmount.borrowTokenAmount,
                tradeGroup
            );
        }

        // Return False
        return (false, 0, tradeGroup);
    }
}