// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "IUniswapV2Router01.sol";
import "Arrays.sol";

contract Aggregator {
    using Arrays for uint[];
    IUniswapV2Router01[] public routers;
    address[] public connectors;

    constructor(
        IUniswapV2Router01 [] memory _routers, 
        address [] memory _connectors
    ) 
    {
        routers = _routers;
        connectors = _connectors;
    }

    /**
        Gets router* and path* that give max output amount with input amount and tokens
        @param amountIn input amount
        @param tokenIn source token
        @param tokenOut destination token
        @return amountOut output amount and router and path, that give this output amount
        @return router Uniswap-like Router
        @return path token list to swap
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

    function getAmountOutSafe(
        IUniswapV2Router01 router,
        address[] memory path,
        uint amountIn
    ) public view returns (uint amountOut) {
        bytes memory payload = abi.encodeWithSelector(router.getAmountsOut.selector, amountIn, path);
        (bool success, bytes memory res) = address(router).staticcall(payload);
        if (success && res.length > 32) {
            uint i = res.length - 32;
            assembly {
                amountOut := mload(add(res, add(0x20, i)))
            }
        }
    }
    
    /**
        Swaps tokens on router with path, should check slippage
        @param amountIn input amount
        @param amountOutMin minumum output amount
        @param router Uniswap-like router to swap tokens on
        @param path tokens list to swap
        @return amountOut actual output amount
     */
    function swap(
        uint amountIn,
        uint amountOutMin,
        address router,
        address[] memory path
    ) external returns (uint amountOut) {
        // TODO
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Arrays {

    // assume that b is encoded uint[]
    function lastUint(bytes memory b) internal pure returns (uint res) {
        require(b.length >= 32, "lastUint: out of range");
        uint i = b.length - 32;
        assembly {
            res := mload(add(b, add(0x20, i)))
        }
    }

    function new2d(address a0, address a1) internal pure returns (address[] memory) {
        address[] memory p = new address[](2);
        p[0] = a0;
        p[1] = a1;
        return p;
    }

    function new3d(
        address a0,
        address a1,
        address a2
    ) internal pure returns (address[] memory) {
        address[] memory p = new address[](3);
        p[0] = a0;
        p[1] = a1;
        p[2] = a2;
        return p;
    }
}