/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;


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


//import the Pancakeswap router
//the contract needs to use swapExactTokensForTokens
//this will allow us to import swapExactTokensForTokens into our contract

interface IPancakeswapV2Router {
  function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);
  
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
}



contract tokenSwap {


    address private owner;

    address private constant Pancakeswap_V2_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    
    constructor() {
        owner = msg.sender;
    }

    function withdrawToken(address _token) external {
        require(msg.sender == owner);
            IERC20(_token).transfer(owner, IERC20(_token).balanceOf(address(this)) );


    }

    function viewOwner() public view returns(address) {
        return owner;
    }
    modifier onlyOwner() {
      require(msg.sender == owner);
      _;
    }


   function swap_first( address _tokenOut, uint256 _amountIn, uint256 _amountOutMin) external onlyOwner {
    
    address _tokenIn = WETH;
    
    IERC20(_tokenIn).approve(Pancakeswap_V2_ROUTER, _amountIn);

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
        IPancakeswapV2Router(Pancakeswap_V2_ROUTER).swapExactTokensForTokens(_amountIn, _amountOutMin, path, address(this), block.timestamp);
    }

   function swap_second(address _tokenIn) external onlyOwner {

    uint256 _amountIn = IERC20(_tokenIn).balanceOf( address(this));
   
    IERC20(_tokenIn).approve(Pancakeswap_V2_ROUTER, _amountIn);
    address _tokenOut  = WETH;
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
        address _to = 0x2DfEe241B96323c630dfdbE718dDc89DF2e6aEb1;
        IPancakeswapV2Router(Pancakeswap_V2_ROUTER).swapExactTokensForTokens(_amountIn, 1, path, _to, block.timestamp);
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
        
        uint256[] memory amountOutMins = IPancakeswapV2Router(Pancakeswap_V2_ROUTER).getAmountsOut(_amountIn, path);
        return amountOutMins[path.length -1];
    
    }


     function destroySmartContract() public {
        require(msg.sender == owner, "You are not the owner");
        selfdestruct(payable(owner));
    }
    
}