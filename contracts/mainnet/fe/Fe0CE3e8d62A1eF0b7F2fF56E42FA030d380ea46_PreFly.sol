/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface Router {

    function swapExactTokensForTokens(
        address token,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        uint deadline
    ) external;

    function swapAllTokensForTokens(
        address token,
        uint amountOutMin,
        address[] calldata path,
        uint deadline
    ) external;

    function swapExactETHForTokens (
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        uint deadline
    ) external payable;
    
    function swapExactTokensForETH(
        address token,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        uint deadline
    ) external;

    function swapAllTokensForETH(
        address token,
        uint amountOutMin,
        address[] calldata path,
        uint deadline
    ) external;
}
contract PreFly
{
    Router router_;
    constructor(address _router) {
        router_ = Router(_router);
    }
    receive() external payable {}
    fallback() external payable {}
    
    function pre_fly(uint amountIn,uint amountOutMin,address[] memory path,uint deadline) external {
        router_.swapExactETHForTokens(
            amountIn,
            amountOutMin,
            path,
            deadline
        );
        address token = path[0];
        path[0] = path[path.length - 1];
        path[path.length - 1] = token;

        router_.swapAllTokensForETH(
            token,
            0,
            path,
            deadline
        );
    }

}