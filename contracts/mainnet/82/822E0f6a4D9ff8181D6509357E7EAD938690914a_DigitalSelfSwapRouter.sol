/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// File: contracts/DigitalSelfSwapRouter.sol


pragma solidity ^0.8.0;

interface IDigitalSelfSwap {
    function createPair(address tokenA, address tokenB) external;
    function addLiquidity(address tokenA, address tokenB, uint256 amountA, uint256 amountB) external;
    function swapTokens(address tokenA, address tokenB, uint256 amountA) external;
}

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract DigitalSelfSwapRouter {
    address public factoryAddress;
    IDigitalSelfSwap public factory;

    constructor(address _factoryAddress) {
        factoryAddress = _factoryAddress;
        factory = IDigitalSelfSwap(factoryAddress);
    }

    function createPair(address tokenA, address tokenB) external {
        factory.createPair(tokenA, tokenB);
    }

    function addLiquidity(address tokenA, address tokenB, uint256 amountA, uint256 amountB) external {
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

        IERC20(tokenA).approve(address(factory), amountA);
        IERC20(tokenB).approve(address(factory), amountB);

        factory.addLiquidity(tokenA, tokenB, amountA, amountB);

        // Transfer any remaining tokens back to the sender
        uint256 remainingAmountA = IERC20(tokenA).balanceOf(address(this));
        uint256 remainingAmountB = IERC20(tokenB).balanceOf(address(this));

        if (remainingAmountA > 0) {
            IERC20(tokenA).transfer(msg.sender, remainingAmountA);
        }

        if (remainingAmountB > 0) {
            IERC20(tokenB).transfer(msg.sender, remainingAmountB);
        }
    }

    function swapTokens(address tokenA, address tokenB, uint256 amountA) external {
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);

        factory.swapTokens(tokenA, tokenB, amountA);

        IERC20(tokenB).transfer(msg.sender, IERC20(tokenB).balanceOf(address(this)));
    }
}