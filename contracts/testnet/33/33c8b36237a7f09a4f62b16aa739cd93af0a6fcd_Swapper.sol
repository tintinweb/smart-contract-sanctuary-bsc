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

    function swap(address tokenIn, address tokenOut, uint amount) internal {
        IERC20(tokenIn).approve(router, amount);
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        IRouter(router).swapExactTokensForTokens(amount, 0, path, address(this), block.timestamp + 60);
    }

    function retiroeth(uint amount) public {
        require(owner == msg.sender);
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