/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IExchangeFactory {
    function getAmountOut(
        uint256 amountIn,
        address token0,
        address token1,
        address pair,
        uint32 exchangeId
    ) external view returns (uint256);
}

contract TopScan {
    struct Exchange {
        string name;
        address routerAddress;
        uint256 feeForSwap;
    }

    struct Node {
        address token0;
        address token1;
        address pair;
        uint32 exchangeId;
    }

    mapping(uint256 => Exchange) public exchanges;
    mapping(uint256 => Node[]) public strategies;
    mapping(address => uint256) public minAmountIn;
    IExchangeFactory exchangeFactory;

    constructor() {
        exchangeFactory = IExchangeFactory(
            0x12d64D7B22eF0Fc240Be73Ee370DC2f4B2c7F9A7
        );
    }

    receive() external payable {}

    function v0_setExchange(
        uint256 exchangeId,
        string memory exchangeName,
        address routerAddress,
        uint256 feeForSwap
    ) external {
        exchanges[exchangeId] = Exchange(
            exchangeName,
            routerAddress,
            feeForSwap
        );
    }

    function v1_setMinAmountIn(address _mainTokenAdr, uint256 _minAmountIn)
        public
    {
        minAmountIn[_mainTokenAdr] = _minAmountIn;
    }

    function v2_setStrategy(uint256 strategyId, Node[] memory nodes) public {
        for (uint16 i = 0; i < nodes.length; i++) {
            strategies[strategyId].push(nodes[i]);
        }
    }

    function getProfit(uint256 strategyId, uint256 amountIn)
        public
        view
        returns (uint256)
    {
        uint256 beforeAmountIn = amountIn;
        uint256 feeForSwap = 0;
        for (uint32 i = 0; i < strategies[strategyId].length; i++) {
            amountIn = exchangeFactory.getAmountOut(
                amountIn,
                strategies[strategyId][i].token0,
                strategies[strategyId][i].token1,
                strategies[strategyId][i].pair,
                strategies[strategyId][i].exchangeId
            );
            feeForSwap += exchanges[strategies[strategyId][i].exchangeId]
                .feeForSwap;
        }

        return (amountIn - beforeAmountIn);
    }

    function checkStrategyStatus(
        uint256 _numberOfSample,
        uint256 _balance,
        address token0,
        uint256 strategyId
    ) public view returns (uint256, uint256) {
        uint256 sampleAmount = _balance / _numberOfSample;
        uint256 maxProfit = 0;
        uint256 amountInForMaxProfit = 0;
        if (sampleAmount > minAmountIn[token0]) {
            for (uint16 i = 0; i < _numberOfSample; i++) {
                uint256 _profit = getProfit(strategyId, sampleAmount * (i + 1));
                maxProfit = maxProfit < _profit ? _profit : maxProfit;
                amountInForMaxProfit = maxProfit < _profit
                    ? sampleAmount * (i + 1)
                    : amountInForMaxProfit;
            }
        } else {
            _numberOfSample = _balance / minAmountIn[token0];
            for (uint16 i = 0; i < _numberOfSample; i++) {
                uint256 _profit = getProfit(strategyId, minAmountIn[token0] * (i + 1));
                maxProfit = maxProfit < _profit ? _profit : maxProfit;
                amountInForMaxProfit = maxProfit < _profit
                    ? minAmountIn[token0] * (i + 1)
                    : amountInForMaxProfit;
            }
        }

        // require(amountInForMaxProfit > 0, "No Profit in this strategy!");

        return (maxProfit, amountInForMaxProfit);
    }
}