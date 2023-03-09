/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPancakeRouter {
    function WETH() external pure returns (address);
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable returns (uint[] memory amounts);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract PancakeSwapBot {
    IPancakeRouter private pancakeRouter;
    IERC20 private WETH;

    constructor() {
        pancakeRouter = IPancakeRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // TESTnet PancakeSwapRouter
        WETH = IERC20(pancakeRouter.WETH()); // Get the WETH token address from PancakeSwapRouter
    }

    function getPath(address _from, address _to) private pure returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = _from;
        path[1] = _to;
        return path;
    }
    
    receive() external payable {}
    
    function deposit() external payable {}

    function KNIGHT(address _token, uint256 _amount, uint256 _amountOutMin, uint256 _deadline) external payable {
        // Approve PancakeSwapRouter to spend the input token
        IERC20 token = IERC20(_token);
        require(token.approve(address(pancakeRouter), type(uint256).max), "Approval failed");

        // Convert BNB to WETH
        pancakeRouter.swapExactETHForTokens{value: msg.value}(
            0,
            getPath(address(WETH), _token),
            address(this),
            _deadline
        );

        // Get the amount of WETH and token
        uint256 wethBalance = WETH.balanceOf(address(this));
        uint256 tokenAmount = token.balanceOf(address(this));

        // Swap WETH for the input token
        require(WETH.approve(address(pancakeRouter), wethBalance), "Approval failed");
        pancakeRouter.swapExactTokensForTokens(
            wethBalance,
            _amountOutMin,
            getPath(address(WETH), _token),
            msg.sender,
            _deadline
        );

        // Transfer any remaining token to the caller
        require(token.transfer(msg.sender, tokenAmount - _amount), "Token transfer failed");
    }
}