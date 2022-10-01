// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

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
        IUniswapV2Router [] memory _routers, 
        address [] memory _connectors
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
            address [] memory _path = Arrays.new2d(tokenIn, tokenOut);
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
            amountOut = Arrays.getlastUint(res);
        }
    }
    
    /**
        Swaps tokens on router with path, should check slippage
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
        return router.swapExactTokensForTokens({
            amountIn: amountIn,
            amountOutMin: amountOutMin,
            path: path,
            to: msg.sender,
            deadline: block.timestamp
        }).last();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library Arrays {
    function last(uint256[] memory a) internal pure returns (uint256) {
        return a[a.length - 1];
    }

    function new2d(address a0, address a1) internal pure returns (address[] memory) {
        address[] memory res = new address[](2);
        res[0] = a0;
        res[1] = a1;
        return res;
    }

    function new3d(address a0, address a1, address a2) internal pure returns (address[] memory) {
        address[] memory res = new address[](3);
        res[0] = a0;
        res[1] = a1;
        res[2] = a2;
        return res;
    }
    function getlastUint(bytes memory data) internal pure returns (uint res) {
        require(data.length >= 32, "Arrays: Cannot get last uint");
        uint i = data.length - 32;
        assembly {
            res := mload(add(data, add(0x20, i)))
        }
    }
}