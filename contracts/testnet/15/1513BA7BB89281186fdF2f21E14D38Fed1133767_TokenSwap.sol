/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

//import the ERC20 interface
interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function decimals() external view returns (uint8);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


//import the uniswap router
//the contract needs to use swapExactTokensForTokens
//this will allow us to import swapExactTokensForTokens into our contract

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}


interface IUniswapV2Router is IUniswapV2Router01  {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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

contract TokenSwap {
    
    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
    address private owner;
        //address of the uniswap v2 router
    address private  UNISWAP_V2_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    //main net : 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    //test net : 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
    
    address private UNISWAP_V2_FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    //main net : 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73
    //test net : 0x6725F303b657a9451d8BA641348b6761A6CC7a17
    
    //address of WETH token.  This is needed because some times it is better to trade through WETH.  
    //you might get a better price using WETH.  
    //example trading from token A to WETH then WETH to token B might result in a better price
    address private WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    //main net : 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    //test net : 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
    
    uint256 MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    constructor() payable{
        owner=msg.sender;
        // UNISWAP_V2_ROUTER = _router;
        // WETH = IUniswapV2Router(UNISWAP_V2_ROUTER).WETH();
        // UNISWAP_V2_FACTORY = IUniswapV2Router(UNISWAP_V2_ROUTER).factory();
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    function getTokensBalance(address _token) public view returns (uint) {
        return IERC20(_token).balanceOf(address(this));
    }
    
    function transferOwner(address _newOwner) public returns(address){
        require(owner == msg.sender, 'Sender is not owner: Reject!');
        owner = _newOwner;
        return owner;
    }
    
    function claimEth() public payable{
        require(owner == msg.sender, 'Sender is not owner: Reject!');
        uint256 _mybalance = address(this).balance;
        msg.sender.transfer(_mybalance);
        // IERC20(WETH).sendEther(msg.sender,address(this).balance);
    }
    
    function claimToken(address _token) public payable{
        require(owner == msg.sender, 'Sender is not owner: Reject!');
        uint256 _mybalance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).approve(msg.sender,_mybalance);
        IERC20(_token).transfer(owner,_mybalance);
        // IERC20(TOKEN).transfer(msg.sender,address(this).balance);
    }
    
    function setRouter(address _router) public{
        require(owner == msg.sender, 'Sender is not owner: Reject!');
        UNISWAP_V2_ROUTER = _router;
        WETH = IUniswapV2Router(_router).WETH();
        UNISWAP_V2_FACTORY = IUniswapV2Router(_router).factory();
    }
    
    function getRouter() public view returns(address){
        return UNISWAP_V2_ROUTER;
    }
    function getFactory() public view returns(address){
        return UNISWAP_V2_FACTORY;
    }
    function getWeth() public view returns(address){
        return WETH;
    }
    function getOwner() public view returns(address){
        return owner;
    }
    
    function ctBuyTokens( address _tokenOut, uint256 _slippage, address _to) external payable {
        // require(owner == msg.sender, 'Sender is not owner: Reject!');
        address[] memory path;
        path = new address[](2);
        path[0] = WETH;
        path[1] = _tokenOut;

        uint256[] memory pricePair = IUniswapV2Router(UNISWAP_V2_ROUTER).getAmountsOut(msg.value, path);
        uint256 tolerance = (pricePair[1] *_slippage)/100;
        uint256 amountOutMin = SafeMath.sub(pricePair[1],tolerance);
        address ctAddress = address(this);
        IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactETHForTokens{value: msg.value}(amountOutMin, path, ctAddress, block.timestamp);
        
        uint256 _balance = IERC20(_tokenOut).balanceOf(address(this));
        uint256 honeyTest = SafeMath.div(_balance,100);
        path[0] = _tokenOut;
        path[1] = WETH;
        if (getApproveCaRouterForToken(_tokenOut) < honeyTest){
            IERC20(_tokenOut).approve(UNISWAP_V2_ROUTER, MAX_INT);
        }
        IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForETHSupportingFeeOnTransferTokens(honeyTest,0, path, _to, block.timestamp);
        IERC20(_tokenOut).transfer(_to,(_balance-honeyTest));
    }
 

    function approveCaRouterForToken(address _tokenIn) public {
        require(owner == msg.sender, 'Sender is not owner: Reject!');
        // uint256 MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
        IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, MAX_INT);
    }
    function getApproveCaRouterForToken(address _tokenIn) public view returns(uint){
        return IERC20(_tokenIn).allowance(address(this),UNISWAP_V2_ROUTER);
    }
    
}