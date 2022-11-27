/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IRouter {
    function getAmountsOut(
        uint256 amountIn,
        address[] memory path
    ) external view returns (uint[] memory amounts);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint[] memory amounts);
}


contract Test {
    /**
     * @dev routers[0] - Pancake, routers[1] - Sushi, routers[2] - Biswap
     * routers[3] - Bakery, routers[4] - Baby
     */
    address[5] public routers;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function setRouters(address[5] calldata _routers) external {
        require(msg.sender == owner, "Only owner");
        routers = _routers;
    }

    function quote(
        uint256 amountIn,
        address tokenIn,
        address tokenOut
    )
        external
        view
        returns (uint256 amountOut, address router, address[] memory path)
    {
        require(routers.length > 0, "no routers set");
        require(
            tokenIn != address(0) && tokenOut != address(0),
            "tokenIn or tokenOut is 0"
        );
        require(amountIn > 0, "amountIn is 0");
        path[0] = tokenIn;
        path[1] = tokenOut;
        uint256[] memory amountOuts;
        for (uint256 i = 0; i < routers.length; i++) {
            amountOuts = IRouter(routers[i]).getAmountsOut(amountIn, path);
            if (amountOut < amountOuts[amountOuts.length - 1]) {
                amountOut = amountOuts[amountOuts.length - 1];
                router = routers[i];
            }
        }
    }

    function swap(
        uint256 amountIn,
        uint256 amountOutMin,
        address router,
        address[] calldata path
    ) external returns (uint amountOut) {
        require(router != address(0), "Router is 0");
        require(
            amountIn > 0 && amountOutMin > 0,
            "amountIn or amountOutMin is 0"
        );
        uint256[] memory amountOuts = IRouter(router).swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp
        );
        amountOut = amountOuts[amountOuts.length - 1];
    }
}