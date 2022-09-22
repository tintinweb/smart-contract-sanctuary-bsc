/**
 *Submitted for verification at BscScan.com on 2022-09-22
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
    address public busd;
    address public eth;
    address public router;
    address public owner;
    uint public deposito;
    uint public retiro;


    function initialize() public {
        busd = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
        eth = 0x8BaBbB98678facC7342735486C851ABD7A0d17Ca;
        router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        owner = msg.sender;
    }

    function swap(address tokenIn, address tokenOut, uint amount) internal {
        IERC20(tokenIn).approve(router, amount);
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        IRouter(router).swapExactTokensForTokens(amount, 0, path, address(this), block.timestamp + 60);
    }

    function retiroeth(uint amount) public {
        swap(eth, busd, amount);
        retiro += amount;
    }

    function depositobusd(uint amount) public {
        IERC20(busd).transferFrom(msg.sender, address(this), amount);
        swap(busd, eth, amount * 50 / 100);
        deposito += amount;
    }

    function busd_balance() public view returns (uint256) {
        return IERC20(busd).balanceOf(address(this));
    }

    function eth_balance() public view returns (uint256) {
        return IERC20(eth).balanceOf(address(this));
    } 
}