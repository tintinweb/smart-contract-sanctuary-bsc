/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDexRouter {
    function factory() external pure returns (address);    
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable  returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
 
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external; 

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

interface IDexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
       
contract SwapExchange { 
 
     struct DeX {
        IDexRouter router;        
        address busd_address; 
    }

    DeX _dex = DeX(  
         IDexRouter(address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3)),
         0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7 //busd 
    ); 

    address public _owner;
 
    constructor() {       
        _owner = _msgSender(); 
    }
    

    modifier onlyOwner() {
        require(_owner == _msgSender());  _;
    }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }
        
    fallback() external payable { } 
    receive() external payable { }
     
    function rescue(uint256 amount) external onlyOwner  { 
        require(address(this).balance >= amount);
        _msgSender().transfer(amount); 
    }
     
    function rescueToken(address tokenAddress, uint256 tokens) external onlyOwner {
        require(IERC20(tokenAddress).balanceOf(address(this)) >= tokens);
        IERC20(tokenAddress).transfer(_owner, tokens);
    } 
    
   
   function getTokenPrice(address routeraddr, address busdAddress,
                          address tokenAddress, uint tokenDecimal) public view onlyOwner 
    returns(uint256 bnb_per_usd, uint256 token_per_bnb) {
        IDexRouter router = IDexRouter(routeraddr); 
        // address factoryAddress = router.factory(); address wbnb = router.WETH();  

        address[] memory pathBNB = new address[](2);
        pathBNB[0] = router.WETH();
        pathBNB[1] = busdAddress;
        uint[] memory amountsOut = router.getAmountsOut(10**18, pathBNB);
        uint256 bnbPerUSD = amountsOut[1];
  
        address[] memory pathToken = new address[](2);
        pathToken[0] = tokenAddress;
        pathToken[1] = router.WETH();

        uint[] memory amountsOut2 = router.getAmountsOut(10**tokenDecimal, pathToken);
        uint256 tokenPerBNB = amountsOut2[1];
 
        return (bnbPerUSD, tokenPerBNB);
        //uint256 resultPrice = (tokenPerBNB/10^18) * (benPerUSD/10^tokenDecimal);         
   }
     
}