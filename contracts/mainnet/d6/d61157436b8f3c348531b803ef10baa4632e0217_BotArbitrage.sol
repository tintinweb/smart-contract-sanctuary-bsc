// SPDX-License-Identifier: MIT
pragma solidity =0.6.6;

import "PancakeRouter.sol";

contract BotArbitrage {
    IPancakeRouter02 public immutable pancakeRouter;
    address public immutable pancakePair;
    address public busdAddress;
    address public tokenAddress;
    uint256 public deadlineMin = 5;
    uint256 public SLIPPAGE = 50;
    uint256 public baseRate = 10000;
    uint256 public MAXINT = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

    address public owner;

    constructor(address _pancakeRouter, address _pancakePair, address _busdAddress, address _tokenAddress) public {
        pancakeRouter = IPancakeRouter02(_pancakeRouter);
        pancakePair = _pancakePair;
        busdAddress = _busdAddress;
        tokenAddress = _tokenAddress;
        owner = msg.sender;

        IERC20(busdAddress).approve(_pancakeRouter, MAXINT);
        IERC20(busdAddress).approve(_pancakePair, MAXINT);
        IERC20(tokenAddress).approve(_pancakeRouter, MAXINT);
        IERC20(tokenAddress).approve(_pancakePair, MAXINT);
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    function swapToken(uint256 _BUSD_BUY_WEI) public {
        address[] memory path = new address[](2);
        // Init buy
        path[0] = busdAddress;
        path[1] = tokenAddress;
        uint256 amountIn = _BUSD_BUY_WEI;
        uint256 amount = pancakeRouter.getAmountsOut(amountIn, path)[1];
        uint256 amountOut = amount - (amount * SLIPPAGE / baseRate);

        // swap buy
        uint256 realAmountOut = pancakeRouter.swapExactTokensForTokens(
            amountIn,
            amountOut,
            path,
            address(this),
            block.timestamp + (deadlineMin * 60)
        )[1];

        // Init sell
        path[0] = tokenAddress;
        path[1] = busdAddress;
        amount = pancakeRouter.getAmountsOut(realAmountOut, path)[1];
        amountIn = amount - (amount * SLIPPAGE / baseRate);

        // swap sell
        pancakeRouter.swapExactTokensForTokens(
            realAmountOut,
            amountIn,
            path,
            msg.sender,
            block.timestamp + (deadlineMin * 60)
        );
    }

    function approveToken() public onlyOwner {
        IERC20(busdAddress).approve(address(pancakeRouter), MAXINT);
        IERC20(busdAddress).approve(pancakePair, MAXINT);
        IERC20(tokenAddress).approve(address(pancakeRouter), MAXINT);
        IERC20(tokenAddress).approve(pancakePair, MAXINT);
    }

    function setTokenAddress(address _busdAddress, address _tokenAddress) public onlyOwner {
        busdAddress = _busdAddress;
        tokenAddress = _tokenAddress;
    }

    function setDealineMin(uint256 _deadlineMin) public onlyOwner {
        deadlineMin = _deadlineMin;
    }

    function setSlippage(uint256 _slippage) public onlyOwner {
        SLIPPAGE = _slippage;
    }

    function changeOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    function emergencyWithdrawVotingToken() public onlyOwner {
        uint256 withdrawAmount = IERC20(busdAddress).balanceOf(address(this));
        IERC20(busdAddress).transfer(msg.sender, withdrawAmount);
    }
}