/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

/*

OFFICIAL WEBSITE: https://build-tower.game

 /$$$$$$$            /$$ /$$       /$$       /$$$$$$$$                                                 /$$$$$$
| $$__  $$          |__/| $$      | $$      |__  $$__/                                                /$$__  $$
| $$  \ $$ /$$   /$$ /$$| $$  /$$$$$$$         | $$  /$$$$$$  /$$  /$$  /$$  /$$$$$$   /$$$$$$       | $$  \__/  /$$$$$$  /$$$$$$/$$$$   /$$$$$$
| $$$$$$$ | $$  | $$| $$| $$ /$$__  $$         | $$ /$$__  $$| $$ | $$ | $$ /$$__  $$ /$$__  $$      | $$ /$$$$ |____  $$| $$_  $$_  $$ /$$__  $$
| $$__  $$| $$  | $$| $$| $$| $$  | $$         | $$| $$  \ $$| $$ | $$ | $$| $$$$$$$$| $$  \__/      | $$|_  $$  /$$$$$$$| $$ \ $$ \ $$| $$$$$$$$
| $$  \ $$| $$  | $$| $$| $$| $$  | $$         | $$| $$  | $$| $$ | $$ | $$| $$_____/| $$            | $$  \ $$ /$$__  $$| $$ | $$ | $$| $$_____/
| $$$$$$$/|  $$$$$$/| $$| $$|  $$$$$$$         | $$|  $$$$$$/|  $$$$$/$$$$/|  $$$$$$$| $$            |  $$$$$$/|  $$$$$$$| $$ | $$ | $$|  $$$$$$$
|_______/  \______/ |__/|__/ \_______/         |__/ \______/  \_____/\___/  \_______/|__/             \______/  \_______/|__/ |__/ |__/ \_______/
*/

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function burn(uint256 amount) external;
}

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
}

contract TokenBuyer {
    event BuyAndBurn(uint bnbValue, uint tokenValue);

    IUniswapV2Router02 public immutable uniswapV2Router;
    IERC20 public immutable token;
    bool public initialLiquidityAdded;
    address immutable burnAddress = 0x000000000000000000000000000000000000dEaD;
    address owner;
    uint public bnbSpent;
    uint public tokensBurned;

    constructor(IUniswapV2Router02 _uniswapV2Router, IERC20 _token) public {
        uniswapV2Router = _uniswapV2Router;
        token = _token;
        owner = msg.sender;
    }

    receive() external payable {
        if (initialLiquidityAdded) {
            buyAndBurn();
        }
    }

    function buyAndBurn() private {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(token);
        uint bnbAmount = address(this).balance;

        // Buy tokens from liquidity pool
        IUniswapV2Router02(uniswapV2Router).swapExactETHForTokens{value: bnbAmount} (
            0,
            path,
            address(this),
            block.timestamp
        );

        // Update stat
        uint boughtTokens = token.balanceOf(address(this));
        tokensBurned += boughtTokens;
        bnbSpent += bnbAmount;

        // Burn tokens from contract
        token.burn(boughtTokens);
    }

    function initLiquidityPool() public {
        require(msg.sender == owner, "only owner can add initial liquidity");
        require(!initialLiquidityAdded, "initial liquidity is already added");
        require(address(this).balance > 0, "balance must be > 0");

        // approve token transfer
        uint tokenAmount = token.balanceOf(address(this));
        require(tokenAmount > 0, "tokens amount must be > 0");
        token.approve(address(uniswapV2Router), tokenAmount);

        // add the liquidity
        IUniswapV2Router02(uniswapV2Router).addLiquidityETH{value: address(this).balance} (
            address(token),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            burnAddress,
            block.timestamp
        );
        initialLiquidityAdded = true;
    }
}