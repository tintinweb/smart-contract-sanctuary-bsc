/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

pragma solidity 0.7.1;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01{
    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

contract SwapIndacoinBNBtoToken {
    address internal constant PANCAKESWAP_ROUTER_ADDRESS = 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F;

    address internal constant PANCAKESWAP_ROUTER_ADDRESS_v2 = 0x10ED43C718714eb63d5aA57B78B54704E256024E; 

    IUniswapV2Router02 public pancakeswapRouter;
    IUniswapV2Router02 public pancakeswapRouterv2;
    
    address private tokenAddress;

    constructor() {
        pancakeswapRouter = IUniswapV2Router02(PANCAKESWAP_ROUTER_ADDRESS);
        pancakeswapRouterv2 = IUniswapV2Router02(PANCAKESWAP_ROUTER_ADDRESS_v2);
    }

    function changeTokenAddress(address _tokenAddress) private {
        tokenAddress = _tokenAddress;
    }

    // swap BNB to any other BSC token that includes a fee or tax and deposit it into any address
    function convertBnbToTokenWithFee(address _tokenAddress, address recipient) external payable {
        changeTokenAddress(_tokenAddress);
        uint[] memory _tokenAmount;
        _tokenAmount = pancakeswapRouter.getAmountsOut(msg.value, getPathForBnbToToken());
        uint preTokenAmount = _tokenAmount[1];
        uint tokenAmount100 = preTokenAmount / 100;
        uint tokenAmount = tokenAmount100 * 89;

        uint deadline = block.timestamp;

        pancakeswapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(tokenAmount, getPathForBnbToToken(), recipient, deadline);

        // refund leftover ETH to user
        (bool success,) = msg.sender.call{ value: address(this).balance }("");
        require(success, "refund failed");
    }

    // swap BNB to any other BSC token and deposit it into any address 
    function convertBnbToToken(address _tokenAddress, address recipient) external payable {
        changeTokenAddress(_tokenAddress);
        uint[] memory _tokenAmount;
        _tokenAmount = pancakeswapRouter.getAmountsOut(msg.value, getPathForBnbToToken());
        uint tokenAmount = _tokenAmount[1];

        uint deadline = block.timestamp;

        pancakeswapRouter.swapExactETHForTokens{value: msg.value}(tokenAmount, getPathForBnbToToken(), recipient, deadline);

        // refund leftover ETH to user
        (bool success,) = msg.sender.call{ value: address(this).balance }("");
        require(success, "refund failed");
    }

    function getPathForBnbToToken() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = pancakeswapRouter.WETH();
        path[1] = tokenAddress;
    
        return path; 
    }

    // swap BNB to any other BSC token that is on v2, that includes a fee or tax, and deposit it into any address
    function convertBnbToTokenWithFeeV2(address _tokenAddress, address recipient) external payable {
        changeTokenAddress(_tokenAddress);
        uint[] memory _tokenAmount;
        _tokenAmount = pancakeswapRouterv2.getAmountsOut(msg.value, getPathForBnbToTokenV2());
        uint preTokenAmount = _tokenAmount[1];
        uint tokenAmount100 = preTokenAmount / 100;
        uint tokenAmount = tokenAmount100 * 89;

        uint deadline = block.timestamp;

        pancakeswapRouterv2.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(tokenAmount, getPathForBnbToTokenV2(), recipient, deadline);

        // refund leftover ETH to user
        (bool success,) = msg.sender.call{ value: address(this).balance }("");
        require(success, "refund failed");
    }

    function getPathForBnbToTokenV2() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = pancakeswapRouterv2.WETH();
        path[1] = tokenAddress;
    
        return path; 
    }

    receive() payable external {}
}