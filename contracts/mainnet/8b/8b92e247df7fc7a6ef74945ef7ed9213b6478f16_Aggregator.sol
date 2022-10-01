// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "IERC20.sol";
import "IUniswapV2Router.sol";
import "Arrays.sol";

contract Aggregator {
    using Arrays for uint[];
    IUniswapV2Router[] public routers;
    address[] public connectors;

    /**
      * @dev Constructor of contract
      * @param _routers UniswapV2-like routers 
      * @param _connectors Connectors tokens 
      */
    constructor(
        IUniswapV2Router[] memory _routers, 
        address[] memory _connectors
    ) 
    {
        routers = _routers;
        connectors = _connectors;
    }

    /**
        @dev Gets router and path that give max output amount with input amount and tokens
        @param amountIn Input amount
        @param tokenIn Source token
        @param tokenOut Destination token
        @return amountOut Output amount
        @return router Uniswap-like router
        @return path Token list to swap
     */
    function quote(
        uint amountIn,
        address tokenIn,
        address tokenOut
    ) external view returns (uint amountOut, address router, address[] memory path) {
        for (uint i = 0; i < routers.length; i++) {
            address[] memory _path = Arrays.new2d(tokenIn, tokenOut);
            uint _amountOut = getAmountOutSafe(routers[i], _path, amountIn);
            if (_amountOut > amountOut) {
                amountOut = _amountOut;
                path = _path;
                router = address(routers[i]);
            }
            for (uint j = 0; j < connectors.length; j++) {
                _path = Arrays.new3d(tokenIn, connectors[j], tokenOut);                
                _amountOut = getAmountOutSafe(routers[i], _path, amountIn);
                if (_amountOut > amountOut) {
                    amountOut = _amountOut;
                    path = _path;
                    router = address(routers[i]);
                }
            }
        }
    }

    /**
        @dev Gets amount out for router and path, zero if route is incorrect
        @param router Uniswap-like router
        @param path Token list to swap
        @param amountIn Input amount
        @return amountOut Output amount
     */
    function getAmountOutSafe(
        IUniswapV2Router router,
        address[] memory path,
        uint amountIn
    ) public view returns (uint amountOut) {
        bytes memory payload = abi.encodeWithSelector(router.getAmountsOut.selector, amountIn, path);
        (bool success, bytes memory res) = address(router).staticcall(payload);
        if (success && res.length > 32) {
            amountOut = Arrays.getLastUint(res);
        }
    }
    
    /**
        Swaps tokens on router with path
        @param amountIn Input amount
        @param amountOutMin Minumum output amount
        @param router Uniswap-like router to swap tokens on
        @param path Tokens list to swap
        @return amountOut Actual output amount
     */
    function swap(
        uint amountIn,
        uint amountOutMin,
        IUniswapV2Router router,
        address[] memory path
    ) external returns (uint amountOut) {
        IERC20 tokenIn = IERC20(path[0]);
        tokenIn.transferFrom(msg.sender, address(this), amountIn);
        tokenIn.approve(address(router), amountIn);
        return router.swapExactTokensForTokens({
            amountIn: amountIn,
            amountOutMin: amountOutMin,
            path: path,
            to: msg.sender,
            deadline: block.timestamp
        }).last();
    }
}