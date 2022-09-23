/**
 *Submitted for verification at BscScan.com on 2022-09-22
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
    address public constant FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address constant public burnWallet = 0x000000000000000000000000000000000000dEaD;
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

    function swapVioletForLiquidity(address _tokenA, address _tokenB, uint violetAmount) external {
        require(violetAmount > 0, 'balance too low');

        IERC20(violet).transferFrom(msg.sender, address(this), violetAmount);

        //0.5 % TAX AMOUNT for VIOLET
        uint taxAmount = violetAmount - (violetAmount * 995 / 1000);
        
        //0.1% BURN TOKENS
        uint burnAmount = violetAmount - (violetAmount * 999 / 1000);

        uint amountAfterTaxandBurn = violetAmount - taxAmount - burnAmount;       

        uint amountTokenA = ((amountAfterTaxandBurn * 500) / 1000);
        uint amountTokenB = amountAfterTaxandBurn - ((amountAfterTaxandBurn * 500) / 1000);        

        swapVioletTotokenA(_tokenA, amountTokenA);
        swapVioletTotokenB(_tokenB, amountTokenB);

        IERC20(violet).transfer(admin, taxAmount);
        IERC20(violet).transfer(burnWallet, burnAmount);
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

    function swapTokensForLiquidityByEpicViolet(address _tokenA, address _tokenB) external payable {
        require(msg.value > 0, 'balance too low');  
        uint bnbAmount = msg.value;

        //1.5 % TAX AMOUNT
        uint taxAmount = bnbAmount - (bnbAmount * 985 / 1000);

        uint totalAmount = bnbAmount - taxAmount;    

        uint amountTokenA = ((totalAmount * 500) / 1000);
        uint amountTokenB = totalAmount - ((totalAmount * 500) / 1000);        

        swapToTokenAByEpicViolet(_tokenA, amountTokenA);
        swapToTokenBByEpicViolet(_tokenB, amountTokenB);

        payable(admin).transfer(taxAmount);
       
    }

    function swapToTokenAByEpicViolet(address _tokenA, uint amountTokenA) internal {
        
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = _tokenA;                

        uniswapV2Router.swapExactETHForTokens{value: amountTokenA}(
            0,            
            path,
            msg.sender,
            block.timestamp
        );
    } 

    function swapToTokenBByEpicViolet(address _tokenB, uint amountTokenB) internal {
        
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = _tokenB;        

        uniswapV2Router.swapExactETHForTokens{value: amountTokenB}(
            0,            
            path,
            msg.sender,
            block.timestamp
        );
    } 

    function addLiquidityByEpicViolet(address _tokenA, address _tokenB, uint tokenAmountA, uint tokenAmountB) external { 
        
        require(tokenAmountA > 0, 'balance too low');
        require(tokenAmountB > 0, 'balance too low');

        IERC20(_tokenA).transferFrom(msg.sender, address(this), tokenAmountA);
        IERC20(_tokenB).transferFrom(msg.sender, address(this), tokenAmountB);

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

    function removeLiquidityByEpicViolet(address _tokenA, address _tokenB) external { 

        address pair = IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB);        
        uint liquidityTotalAmount = IERC20(pair).balanceOf(address(msg.sender));
        IERC20(pair).approve(address(uniswapV2Router), liquidityTotalAmount);
            
        uniswapV2Router.removeLiquidity(
            address(_tokenB),
            address(_tokenA),
            liquidityTotalAmount,
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

    function removeStuckedTokens(address _tokenA) external onlyAdmin{
        uint totalAmount = IERC20(_tokenA).balanceOf(address(this));
        IERC20(_tokenA).transfer(admin, totalAmount);
    }

    function removeStuckedCollateral() external onlyAdmin {
        uint256 totalVioletStucked = violet.balanceOf(address(this));
        violet.transfer(admin, totalVioletStucked);
    }
    

}