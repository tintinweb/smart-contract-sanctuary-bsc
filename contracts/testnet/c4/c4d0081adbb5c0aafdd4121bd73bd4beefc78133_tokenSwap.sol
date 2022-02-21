/**
 *Submitted for verification at BscScan.com on 2022-02-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;


//import the interface

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


contract tokenSwap {
  
    address private constant THIS_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;//PCS
    address private constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;//WBNB
    
   function swap(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, address _to) external {

    IBEP20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);

    IBEP20(_tokenIn).approve(THIS_ROUTER, _amountIn);

    address[] memory path;
    if (_tokenIn == WETH || _tokenOut == WETH) {
      path = new address[](2);
      path[0] = _tokenIn;
      path[1] = _tokenOut;
    } else {
      path = new address[](3);
      path[0] = _tokenIn;
      path[1] = WETH;
      path[2] = _tokenOut;
    }

        IDEXRouter(THIS_ROUTER).swapExactTokensForTokensSupportingFeeOnTransferTokens(_amountIn, _amountOutMin, path, _to, block.timestamp);
    }

    function getAmountOutMin(address _tokenIn, address _tokenOut, uint256 _amountIn) external view returns (uint256) {

        address[] memory path;
        if (_tokenIn == WETH || _tokenOut == WETH) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = WETH;
            path[2] = _tokenOut;
        }
        
        uint256[] memory amountOutMins = IDEXRouter(THIS_ROUTER).getAmountsOut(_amountIn, path);
        return amountOutMins[path.length -1];  
    }  
}