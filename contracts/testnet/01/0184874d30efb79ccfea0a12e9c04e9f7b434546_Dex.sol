/**
 *Submitted for verification at BscScan.com on 2022-09-20
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;
 


// Dex Factory contract interface
interface IDexFactory {
    function getPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

// Dex WETH contract Interface
interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// Dex Router02 contract interface
interface IDexRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
  address token,
  uint amountTokenDesired,
  uint amountTokenMin,
  uint amountETHMin,
  address to,
  uint deadline
     )
        external
        payable
        returns (
         uint amountToken, uint amountETH, uint liquidity
        );

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

    function swapExactTokensForETH(uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline)
    external
    returns (uint[] memory amounts);

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

}
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

contract Dex{

 address private constant ROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
 address private constant FACTORY=   0x6725F303b657a9451d8BA641348b6761A6CC7a17;
 address private constant WETH = 0x5B3E2Bc1da86ff6235D9eAd4504d598caE77DBCB;
 
 function addLiquidity(
  address _tokenA,
  address _tokenB,
  uint256 _amountA,
  uint256 _amountB
     )external{
         IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountA);
         IERC20(_tokenB).transferFrom(msg.sender, address(this), _amountB);

         IERC20(_tokenA).approve(ROUTER, _amountA); 
         IERC20(_tokenB).approve(ROUTER, _amountB); 
         IDexRouter(ROUTER).addLiquidity(
            _tokenA,
            _tokenB,
            _amountA,
            _amountB,
            1, 
            1, 
            address(this),
            block.timestamp + 360
        );
     }

//to receive BNB from dexRouter when swapping
    receive() external payable {}

     function addLiquidityETH(
  address _tokenA,
  uint256 amountETH,
  uint256 _amountA
     )external payable {
         IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountA);
        //  IERC20(_tokenB).transferFrom(msg.sender, address(this), _amountB);
         payable (address(this)).transfer(msg.value);
         IERC20(_tokenA).approve(ROUTER, _amountA);
         amountETH = msg.value; 
         IDexRouter(ROUTER).addLiquidityETH{value:amountETH}(
            _tokenA,
            _amountA,
            0, 
            0, 
            address(this),
            block.timestamp + 360
        );
     }
     function removeLiquidity
     (address _tokenA, address _tokenB )external virtual {
         address pair = IDexFactory(FACTORY).getPair(_tokenA, _tokenB);
         uint256 liquidity = IERC20(pair).balanceOf(address(this));
         IERC20(pair).approve(ROUTER, liquidity);
         IDexRouter(ROUTER).removeLiquidity(
         _tokenA,
         _tokenB,
         liquidity,
         1,
         1,
         address(this),
         block.timestamp + 360
         );
      }
    function removeLiquidityETH(address token,
        address to)
        external returns (uint amountToken, uint amountETH) {
         address pair = IDexFactory(FACTORY).getPair(token, WETH);
         uint256 liquidity = IERC20(pair).balanceOf(address(this));
        IERC20(pair).approve(ROUTER, liquidity);
       IDexRouter(ROUTER).removeLiquidityETH(
            token,
            liquidity,
            1,
            1,
            to,
            block.timestamp + 360
        );
          IERC20(token).transferFrom(address(this),to, amountToken);
        IWETH(WETH).withdraw(amountETH);
        payable(to).transfer(amountETH);
    }
}