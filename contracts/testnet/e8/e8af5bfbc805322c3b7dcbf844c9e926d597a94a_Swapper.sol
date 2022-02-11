// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import './pancakeswap.sol';

//import the ERC20 interface
interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract Swapper {
    
    //address of the Pancakeswap V2 ROUTER
    // Mainnet 0x10ED43C718714eb63d5aA57B78B54704E256024E
    // Testnet 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
    address private constant Pancakeswap_V2_ROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    
    //address of WBNB token.  This is needed because some times it is better to trade through WBNB.  
    //you might get a better price using WBNB.  
    //example trading from token A to WBNB then WBNB to token B might result in a better price
    // Mainnet 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    // Testnet 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
    address private constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    

    //this swap function is used to trade from one token to another
    //the inputs are self explainatory
    //token in = the token address you want to trade out of
    //token out = the token address you want as the output of this trade
    //amount in = the amount of tokens you are sending in
    //amount out Min = the minimum amount of tokens you want out of the trade
    //to = the address you want the tokens to be sent to
   function swapTokensForTokens(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, address _to) external {
      
      //first we need to transfer the amount in tokens from the msg.sender to this contract
      //this contract will have the amount of in tokens
      IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
      
      //next we need to allow the pancakeswapV2 router to spend the token we just sent to this contract
      //by calling IERC20 approve you allow the pancakeswap contract to spend the tokens in this contract 
      IERC20(_tokenIn).approve(Pancakeswap_V2_ROUTER, _amountIn);

      //path is an array of addresses.
      //this path array will have 3 addresses [tokenIn, WBNB, tokenOut]
      //the if statement below takes into account if token in or token out is WBNB.  then the path is only 2 addresses
      address[] memory path;
      if (_tokenIn == WBNB || _tokenOut == WBNB) {
        path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;
      } else {
        path = new address[](3);
        path[0] = _tokenIn;
        path[1] = WBNB;
        path[2] = _tokenOut;
      }
      //then we will call swapExactTokensForTokens
      //for the deadline we will pass in block.timestamp
      //the deadline is the latest time the trade is valid for
      IPancakeRouter02(Pancakeswap_V2_ROUTER).swapExactTokensForTokensSupportingFeeOnTransferTokens(_amountIn, _amountOutMin, path, _to, block.timestamp);
    }

    //this swap function is used to trade from one token to another
    //the inputs are self explainatory
    //token in = the token address you want to trade out of
    //token out = the token address you want as the output of this trade
    //amount out Min = the minimum amount of tokens you want out of the trade
    //to = the address you want the tokens to be sent to
   function swapWBNBForTokens(address _tokenIn, address _tokenOut, uint256 _amountOutMin, address _to) external {
      
      //first we need to transfer the amount in tokens from the msg.sender to this contract
      //this contract will have the amount of in tokens
      IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountOutMin);
      
      //next we need to allow the pancakeswapV2 router to spend the token we just sent to this contract
      //by calling IERC20 approve you allow the pancakeswap contract to spend the tokens in this contract 
      IERC20(_tokenIn).approve(Pancakeswap_V2_ROUTER, _amountOutMin);

      //path is an array of addresses.
      address[] memory path;
      path = new address[](2);
      path[0] = _tokenIn;
      path[1] = _tokenOut;

      //then we will call swapExactTokensForTokens
      //for the deadline we will pass in block.timestamp
      //the deadline is the latest time the trade is valid for
      IPancakeRouter02(Pancakeswap_V2_ROUTER).swapExactETHForTokensSupportingFeeOnTransferTokens(_amountOutMin, path, _to, block.timestamp);
    }

    //this swap function is used to trade from one token to another
    //the inputs are self explainatory
    //token in = the token address you want to trade out of
    //token out = the token address you want as the output of this trade
    //amount in = the amount of tokens you are sending in
    //amount out Min = the minimum amount of tokens you want out of the trade
    //to = the address you want the tokens to be sent to
   function swapTokensForWBNB(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, address _to) external {
      //first we need to transfer the amount in tokens from the msg.sender to this contract
      //this contract will have the amount of in tokens
      IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
      
      //next we need to allow the pancakeswapV2 router to spend the token we just sent to this contract
      //by calling IERC20 approve you allow the pancakeswap contract to spend the tokens in this contract 
      IERC20(_tokenIn).approve(Pancakeswap_V2_ROUTER, _amountIn);

      //path is an array of addresses.
      address[] memory path;
      path = new address[](2);
      path[0] = _tokenOut;
      path[1] = _tokenIn;

      //then we will call swapExactTokensForTokens
      //for the deadline we will pass in block.timestamp
      //the deadline is the latest time the trade is valid for
      IPancakeRouter02(Pancakeswap_V2_ROUTER).swapExactTokensForETHSupportingFeeOnTransferTokens(_amountIn, _amountOutMin, path, _to, block.timestamp);
    }

    //this function will return the minimum amount from a swap
    //input the 3 parameters below and it will return the minimum amount out
    //this is needed for the swap function (buy)
     function getAmountOutMin(address _tokenIn, address _tokenOut, uint256 _amountIn) external view returns (uint256) {

       //path is an array of addresses.
       //this path array will have 3 addresses [tokenIn, WBNB, tokenOut]
       //the if statement below takes into account if token in or token out is WBNB.  then the path is only 2 addresses
        address[] memory path;
        if (_tokenIn == WBNB || _tokenOut == WBNB) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = WBNB;
            path[2] = _tokenOut;
        }
        
        uint256[] memory amountOutMins = IPancakeRouter02(Pancakeswap_V2_ROUTER).getAmountsOut(_amountIn, path);
        return amountOutMins[path.length -1];
    }

    //this function will return the minimum amount from a swap
    //input the 3 parameters below and it will return the minimum amount in
    //this is needed for the swap function (sell)
     function getAmountInMin(address _tokenIn, address _tokenOut, uint256 _amountOut) external view returns (uint256) {

       //path is an array of addresses.
       //this path array will have 3 addresses [tokenIn, WBNB, tokenOut]
       //the if statement below takes into account if token in or token out is WBNB.  then the path is only 2 addresses
        address[] memory path;
        if (_tokenIn == WBNB || _tokenOut == WBNB) {
            path = new address[](2);
            path[0] = _tokenOut;
            path[1] = _tokenIn;
        } else {
            path = new address[](3);
            path[0] = _tokenOut;
            path[1] = WBNB;
            path[2] = _tokenIn;
        }

        uint256[] memory amountInMins = IPancakeRouter02(Pancakeswap_V2_ROUTER).getAmountsIn(_amountOut, path);
        return amountInMins[path.length -1];
    }
}