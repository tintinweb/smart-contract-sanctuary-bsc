/**
 *Submitted for verification at BscScan.com on 2022-02-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

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

//  import pancakeswapv2 Router
//  the contract needs to use swapExactTokensForTokens
//  this will allow us to import swapExactTokensForTokens into our contract
interface IPancakeRouter02 {
    function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);

    // Receive an as many output tokens as possible for an exact amount of input tokens.
    function swapExactTokensForTokens(
        //amount of tokens we are sending in
        uint256 amountIn,
        //the minimum amount of tokens we want out of the trade
        uint256 amountOutMin,
        //list of token addresses we are going to trade in.  this is necessary to calculate amounts
        address[] calldata path,
        //this is the address we are going to send the output tokens to
        address to,
        //the last time that the trade is valid for
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    // Receive an exact amount of output tokens for as few input tokens as possible.
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    // Receive an as many output tokens as possible for an exact amount of BNB.
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    // Receive an exact amount of ETH for as few input tokens as possible.
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    // Receive an as much BNB as possible for an exact amount of input tokens.
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    // Receive an exact amount of output tokens for as little BNB as possible.
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
}

interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract TestSwap {

    // modifier ensure(uint deadline) {
    // require(deadline >= block.timestamp, 'PancakeswapV2Router: EXPIRED');
    // _;
    // }
      
    //address of the pancakeswap v2 router
    address private constant PANCAKESWAP_V2_ROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    
    //address of WBNB token.  This is needed because some times it is better to trade through WBNB.  
    //you might get a better price using WBNB.  
    //example trading from token A to WBNB then WBNB to token B might result in a better price
    address private constant WBNB = 0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F;

    //this swapToken function is used to trade from one token to another
    //the inputs are self explainatory
    //token in = the token address you want to trade out of
    //token out = the token address you want as the output of this trade
    //amount in = the amount of tokens you are sending in
    //amount out Min = the minimum amount of tokens you want out of the trade
    //to = the address you want the tokens to be sent to
    
   function swapToken(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, address _to) external {
    //first we need to transfer the amount in tokens from the msg.sender to this contract
    //this contract will have the amount of in tokens
    IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
    
    //next we need to allow the pancakeswapv2 router to spend the token we just sent to this contract
    //by calling IERC20 approve you allow the uniswap contract to spend the tokens in this contract 
    IERC20(_tokenIn).approve(PANCAKESWAP_V2_ROUTER, _amountIn);

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
    IPancakeRouter02(PANCAKESWAP_V2_ROUTER).swapExactTokensForTokens(_amountIn, _amountOutMin, path, _to, block.timestamp);
    }

    // function swapETHToToken(address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, address _to) external payable {
    //     address[] memory path;
    //     path = new address[](2);
    //     path[0] = address(WBNB);
    //     path[1] = _tokenOut;

    //     IPancakeRouter02(PANCAKESWAP_V2_ROUTER).swapExactETHForTokens{value: _amountIn}(_amountOutMin, path, _to, block.timestamp);
    // }

    //this function will return the minimum amount from a swap
       //input the 3 parameters below and it will return the minimum amount out
       //this is needed for the swap function above
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
        
        uint256[] memory amountOutMins = IPancakeRouter02(PANCAKESWAP_V2_ROUTER).getAmountsOut(_amountIn, path);
        return amountOutMins[path.length -1];  
    }  

}