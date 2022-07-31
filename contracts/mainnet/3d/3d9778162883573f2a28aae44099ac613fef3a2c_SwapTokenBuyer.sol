/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function burn(uint256 amount) external;
    function transfer(address to, uint256 amount) external returns (bool);
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

contract SwapTokenBuyer {
    event BuyAndBurn(uint bnbValue, uint tokenValue);

    IUniswapV2Router02 public immutable uniswapV2Router;
    IERC20 public immutable token;
    address owner;
    uint public bnbSpent;
    uint public totalBuyBack;

    constructor(IUniswapV2Router02 _uniswapV2Router, IERC20 _token) {
        uniswapV2Router = _uniswapV2Router;
        token = _token;
        owner = msg.sender;
    }

    receive() external payable {
            buyBack();
    }

    function buyBack() private {
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
        bnbSpent += bnbAmount;
        totalBuyBack += boughtTokens;

    }

    function withdrawTokens(address _tokenContract) external {
        require(msg.sender == owner, "only owner");
        IERC20 tokenContract = IERC20(_tokenContract);
        uint256 _amount = tokenContract.balanceOf(address(this));
        tokenContract.transfer(owner, _amount);
    }

    function withdraw() external {
        require(msg.sender == owner, "only owner");
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function changeOwner(address _owner) external {
        require(msg.sender == owner, "only owner");
        require(_owner != address(0), "invalid address");
        owner = _owner;
    }

}