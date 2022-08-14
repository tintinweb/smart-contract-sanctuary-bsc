/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

pragma solidity ^0.8.5;

interface getp {   
    function getPair(address tokenA, address tokenB) external returns (address pair);
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint256);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IDEXRouter {
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
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

contract csawp{


    IDEXRouter public router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public wbnb;
    getp public gp = getp(0xf182a173aB3cCe37343ffFE5f3ffb4e954e62e8D);
    constructor(){
        wbnb = router.WETH();
    }

   
    function getOut(uint256 amountIn,address[] memory path) public view returns(uint256 ){
        uint256 amountOut;
        try router.getAmountsOut(amountIn,path) returns (uint256[] memory out){ amountOut = out[out.length-1]; } catch {}  
        return amountOut;
    }

    function swapETHForTokensWithLimit( address[] memory path,uint256 limit1,uint256 limit2,uint256 outPercent) payable public {

        address pair = gp.getPair(path[path.length - 1 ],path[path.length - 2 ]);

        IERC20 token1 = IERC20(path[path.length - 2 ]);  // to lp token
        IERC20 token2 = IERC20(path[path.length - 1 ]);  // buy token

        require(token1.balanceOf(pair) > limit1 * (10 ** token1.decimals()) ,'limit1 is not' );  // number
        require(token2.balanceOf(pair) > token2.totalSupply()  * limit2 / 100 ,'limit2 is not' );  // percent

        uint256 berforNum = token2.balanceOf(msg.sender);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value:msg.value}(
            0,
            path,
            msg.sender,
            block.timestamp
        );

        uint256 newBalance = token2.balanceOf(msg.sender) - berforNum;

        address[] memory path2 = new address[](path.length);

        for(uint i;i<path.length;i++){
            path2[i] = path[path.length - 1 -i];
        }

        uint256 newETH = getOut(newBalance,path2);

        require(newETH > msg.value * outPercent / 100,'outPercent is not' );        
    }

}