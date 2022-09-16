/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: MIT
////////////////////////////////////////////////////////////
/////// The smart contract was developed by Magalico ///////
//////////////////////////////////////////////////////////// 
pragma solidity ^0.8.0;

interface IERC20{
    event Transfer(address indexed from, address indexed to, uint256 value); 
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

interface IUniswapV2Factory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint);
  function feeTo() external view returns (address);
  function feeToSetter() external view returns (address);
  function getPair(address tokenA, address tokenB) external view returns (address pair);
  function allPairs(uint) external view returns (address pair);
  function allPairsLength() external view returns (uint);
  function createPair(address tokenA, address tokenB) external returns (address pair);
  function setFeeTo(address) external;
  function setFeeToSetter(address) external;
}

contract ZeusVioletProtocol {

    IERC20 public violet;
    IERC20 public wbnb;

    address private constant FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    address public admin;

    IUniswapV2Router02 public uniswapV2Router;

    constructor(address _violet, address _wbnb) { 
        violet = IERC20(_violet);   
        wbnb = IERC20(_wbnb);     
        admin = msg.sender;
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    }   

    receive() external payable {}
    fallback() external payable {}

    function swapTokensForLiquidity(address _tokenA, address _tokenB, uint violetAmount) external {
        require(violetAmount > 0, 'balance too low');

        IERC20(violet).transferFrom(msg.sender, address(this), violetAmount);

        uint amountTokenA = ((violetAmount * 500) / 1000);
        uint amountTokenB = violetAmount - ((violetAmount * 500) / 1000);

        swapVioletTotokenA(_tokenA, amountTokenA);
        swapVioletTotokenB(_tokenB, amountTokenB);
    }

    function swapVioletTotokenA(address _tokenA, uint tokenAmountA) internal {
        
        address[] memory path = new address[](3);
        path[0] = address(violet);
        path[1] = address(wbnb);
        path[2] = _tokenA;        

        IERC20(violet).approve(address(uniswapV2Router), tokenAmountA);

        uniswapV2Router.swapExactTokensForTokens(
            tokenAmountA,
            0,
            path,
            msg.sender,
            block.timestamp
        );
    } 

    function swapVioletTotokenB(address _tokenB, uint tokenAmountB) internal {
        
        address[] memory path = new address[](3);
        path[0] = address(violet);
        path[1] = address(wbnb);
        path[2] = _tokenB;        

        IERC20(violet).approve(address(uniswapV2Router), tokenAmountB);

        uniswapV2Router.swapExactTokensForTokens(
            tokenAmountB,
            0,
            path,
            msg.sender,
            block.timestamp
        );
    } 

    function addLiquidityPoolFarm(address _tokenA, address _tokenB, uint tokenAmountA, uint tokenAmountB) external  { 

        IERC20(_tokenA).approve(address(uniswapV2Router), tokenAmountA);
        IERC20(_tokenB).approve(address(uniswapV2Router), tokenAmountB);

        uniswapV2Router.addLiquidity(
            address(_tokenA),
            address(_tokenB),
            tokenAmountA,
            tokenAmountB,
            0,
            0, 
            msg.sender,
            block.timestamp
        );
    }

    function removeLiquidityFromPool(address _tokenA, address _tokenB) external { 

        address pair = IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB);

        uint256 liquidity = IERC20(pair).balanceOf(msg.sender);
        IERC20(pair).approve(address(uniswapV2Router), liquidity);
            
        uniswapV2Router.removeLiquidity(
            address(_tokenB),
            address(_tokenA),
            liquidity,
            0,
            0,
            msg.sender,
            block.timestamp
        );
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, 'only admin');
        _;
    }

    function removeStuckedBNB() external onlyAdmin {        
        payable(admin).transfer(address(this).balance);
    }
    

    function removeStuckedCollateral() external onlyAdmin {
        uint256 totalVioletStucked = violet.balanceOf(address(this));
        violet.transfer(admin, totalVioletStucked);
    }

}