/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.7.0;


//import the ERC20 interface

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IUniswapV2Router {
  function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);
  
  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
  uint amountIn,
  uint amountOutMin,
  address[] calldata path,
  address to,
  uint deadline
) external;
}

interface IUniswapV2Pair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;
}

interface IUniswapV2Factory {
  function getPair(address token0, address token1) external returns (address);
}

contract tokenSwap {
    address private constant PANCAKE_V2_ROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    address private constant WBNB   = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address private constant MONSTA = 0x8A5d7FCD4c90421d21d30fCC4435948aC3618B2f;
    address private constant BUSD   = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
    address private constant myAddy = 0xD367a11440CD76f9fA6DB5FCDcA76A05b16d2827;

   function swap() external {
     uint256 amountIn = 1000000000000000;
     IERC20(WBNB).transferFrom(msg.sender, address(this), amountIn);
     IERC20(WBNB).approve(PANCAKE_V2_ROUTER, amountIn);

     address[] memory path1;
     path1 = new address[](2);
     path1[0] = WBNB;
     path1[1] = BUSD;

     uint256 amountOutBUSDFromBNB = IUniswapV2Router(PANCAKE_V2_ROUTER).getAmountsOut(amountIn, path1)[0];     
     IUniswapV2Router(PANCAKE_V2_ROUTER).swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, amountOutBUSDFromBNB, path1, myAddy, block.timestamp);    
    
     address[] memory path2;
     path2 = new address[](2);
     path2[0] = BUSD;
     path2[1] = WBNB;

     uint256 amountOutBNBFromBUSD = IUniswapV2Router(PANCAKE_V2_ROUTER).getAmountsOut(amountOutBUSDFromBNB, path2)[0];     
     IUniswapV2Router(PANCAKE_V2_ROUTER).swapExactTokensForTokensSupportingFeeOnTransferTokens(amountOutBUSDFromBNB, amountOutBNBFromBUSD, path2, myAddy, block.timestamp);    
    
    }
}