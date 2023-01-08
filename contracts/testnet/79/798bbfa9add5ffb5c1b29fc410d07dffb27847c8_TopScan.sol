/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IExchangeFactory {
   function getAmountOut(uint256 amountIn, address token0, address token1, address pair, uint32 exchangeId) external view returns(uint256);
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
    IExchangeFactory exchangeFactory;

    constructor() {
        exchangeFactory = IExchangeFactory(0x12d64D7B22eF0Fc240Be73Ee370DC2f4B2c7F9A7);
    }

    receive() external payable {}

    function setExchange(
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

    function setStrategy(uint256 strategyId, Node[] memory nodes) public  {
        for (uint16 i = 0; i < nodes.length; i++) {
            strategies[strategyId].push(nodes[i]);
        }
    }

    function getProfit(uint256 strategyId, uint256 amountIn) public view returns(uint256){
        uint256 beforeAmountIn = amountIn;
        for(uint32 i = 0; i < strategies[strategyId].length; i++) {
            amountIn = exchangeFactory.getAmountOut(amountIn, strategies[strategyId][i].token0, strategies[strategyId][i].token1, strategies[strategyId][i].pair, strategies[strategyId][i].exchangeId);
        }

        return (amountIn - beforeAmountIn);
    }
}