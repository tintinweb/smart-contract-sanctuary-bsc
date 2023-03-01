/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// Sources flattened with hardhat v2.12.7 https://hardhat.org
//SPDX-License-Identifier: UNLICENSED
// File contracts/Interfaces/ILiquidityImplementation.sol

 
pragma solidity ^0.8.17;

interface ILiquidityImplementation {
    function getSwapRouter(address lpToken) external view returns (address);

    struct AddLiquidityInput {
        address lpToken;
        uint256 amountToken0;
        uint256 amountToken1;
        uint256 minAmountToken0;
        uint256 minAmountToken1;
        address to;
        uint256 deadline;
    }

    struct RemoveLiquidityInput {
        address lpToken;
        uint256 lpAmount;
        uint256 minAmountToken0;
        uint256 minAmountToken1;
        address to;
        uint256 deadline;
    }

    struct AddLiquidityOutput {
        uint256 unusedToken0;
        uint256 unusedToken1;
        uint256 lpToken;
    }

    struct RemoveLiquidityOutput {
        uint256 received0;
        uint256 received1;
    }

    // Interface function to add liquidity to the implementation DEX
    function addLiquidity(AddLiquidityInput calldata addLiquidityInput)
        external
        payable
        returns (AddLiquidityOutput memory);

    // Interface function to remove liquidity to the implementation DEX
    function removeLiquidity(RemoveLiquidityInput calldata removeLiquidityInput)
        external
        returns (RemoveLiquidityOutput memory);

    // Gets token0 for an lp token for the implementation DEX
    function token0(address lpToken) external view returns (address);

    // Gets token1 for an lp token for the implementation DEX
    function token1(address lpToken) external view returns (address);

    // Estimate the swap share
    function estimateSwapShare(uint256 amount, address lpToken)
        external
        view
        returns (uint256 share0, uint256 share1);

    // Estimate the out share
    function estimateOutShare(uint256 amount, address lpToken)
        external
        view
        returns (uint256 share0, uint256 share1);
}


// File contracts/Interfaces/IUniswapV2Pair.sol

 
pragma solidity ^0.8.17;

interface IUniswapV2Pair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint256, uint256);

    function totalSupply() external view returns (uint256);
}


// File contracts/Interfaces/IUniswapV2Router01.sol

 
pragma solidity ^0.8.17;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}


// File contracts/LiquidityImplamentations/UniswapV2LiquidityImplementation.sol

 
pragma solidity ^0.8.17;
contract UniswapV2LiquidityImplementation is ILiquidityImplementation {
    IUniswapV2Router01 immutable SwapRouter;

    constructor(address swapRouterAddress) {
        SwapRouter = IUniswapV2Router01(swapRouterAddress);
    }

    function addLiquidity(AddLiquidityInput calldata liquidityInput)
        external
        payable
        returns (AddLiquidityOutput memory)
    {
        IUniswapV2Pair pair = IUniswapV2Pair(liquidityInput.lpToken);
        (
            uint256 usedToken0,
            uint256 usedToken1,
            uint256 receivedLpValue
        ) = SwapRouter.addLiquidity(
                pair.token0(),
                pair.token1(),
                liquidityInput.amountToken0,
                liquidityInput.amountToken1,
                liquidityInput.minAmountToken0,
                liquidityInput.minAmountToken1,
                liquidityInput.to,
                liquidityInput.deadline
            );
        return
            AddLiquidityOutput(
                liquidityInput.amountToken0 - usedToken0,
                liquidityInput.amountToken1 - usedToken1,
                receivedLpValue
            );
    }

    function removeLiquidity(
        RemoveLiquidityInput calldata removeLiquidityOutput
    ) external returns (RemoveLiquidityOutput memory) {
        IUniswapV2Pair pair = IUniswapV2Pair(removeLiquidityOutput.lpToken);
        (uint256 amount0, uint256 amount1) = SwapRouter.removeLiquidity(
            pair.token0(),
            pair.token1(),
            removeLiquidityOutput.lpAmount,
            removeLiquidityOutput.minAmountToken0,
            removeLiquidityOutput.minAmountToken1,
            removeLiquidityOutput.to,
            removeLiquidityOutput.deadline
        );
        return RemoveLiquidityOutput(amount0, amount1);
    }

    function token0(address lpToken) external view returns (address) {
        return IUniswapV2Pair(lpToken).token0();
    }

    function token1(address lpToken) external view returns (address) {
        return IUniswapV2Pair(lpToken).token1();
    }

    function getSwapRouter(address lpToken) external view returns (address) {
        return address(SwapRouter);
    }

    function estimateSwapShare(uint256 amount, address lpToken)
        external
        view
        returns (uint256 share0, uint256 share1)
    {
        share0 = amount / 2;
        share1 = amount / 2;
    }

    function estimateOutShare(uint256 amount, address lpToken)
        external
        view
        returns (uint256 share0, uint256 share1)
    {
        (uint256 reserve0, uint256 reserve1) = IUniswapV2Pair(lpToken)
            .getReserves();
        uint256 totalSupply = IUniswapV2Pair(lpToken).totalSupply();

        return (
            (reserve0 * amount) / totalSupply,
            (reserve1 * amount) / totalSupply
        );
    }
}