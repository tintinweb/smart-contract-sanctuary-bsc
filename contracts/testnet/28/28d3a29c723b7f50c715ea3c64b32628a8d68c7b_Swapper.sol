/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IRouter {
  function swapExactTokensForTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);
}

contract Swapper {
    address public busdAddress;
    address public ethAddress;
    address public wbnbAddress;
    address public routerAddress;
    uint public deposito;
    uint public retiro;

    constructor() {
        busdAddress = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
        ethAddress = 0x8BaBbB98678facC7342735486C851ABD7A0d17Ca;
        routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        wbnbAddress = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    }

    function swapTokens(address tokenIn, address tokenOut, uint amount) internal {
        IERC20(tokenIn).approve(routerAddress, amount);
        address[] memory path = new address[](3);
        path[0] = tokenIn;
        path[1] = wbnbAddress;
        path[2] = tokenOut;
        IRouter(routerAddress).swapExactTokensForTokens(amount, 0, path, address(this), block.timestamp + 60);
    }

    function eth_retiro(uint amount) public {
        swapTokens(ethAddress, busdAddress, amount);
        retiro += amount;
    }

    function busd_deposit(uint amount) public {
        IERC20(busdAddress).transferFrom(msg.sender, address(this), amount);
        swapTokens(busdAddress, ethAddress, amount * 50 / 100);
        deposito += amount;
    }

    function busd_balance() public view returns (uint256) {
        return IERC20(busdAddress).balanceOf(address(this));
    }

    function eth_balance() public view returns (uint256) {
        return IERC20(ethAddress).balanceOf(address(this));
    }
}