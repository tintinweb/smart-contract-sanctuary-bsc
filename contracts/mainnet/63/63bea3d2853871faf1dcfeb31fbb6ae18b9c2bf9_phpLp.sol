/**
 *Submitted for verification at BscScan.com on 2022-07-24
*/

pragma solidity ^0.6.0;

library PancakeLibrary {

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash
            ))));
    }

}

interface IDEXRouter {
    function factory() external view returns (address);
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
}

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

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

contract phpLp{
    IDEXRouter public router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired
    ) external {
        IERC20 _tokenA = IERC20(tokenA);
        IERC20 _tokenB = IERC20(tokenB);

        _tokenA.transferFrom(msg.sender,address(this),amountADesired);
        _tokenB.transferFrom(msg.sender,address(this),amountBDesired);

        _tokenA.approve(address(router),amountADesired);
        _tokenB.approve(address(router),amountBDesired);

        router.addLiquidity(
        tokenA,
        tokenB,
        amountADesired,
        amountBDesired,
        0,
        0,
        msg.sender,
        block.timestamp
        );

        if(_tokenA.balanceOf(address(this)) > 1){
            _tokenA.transfer(msg.sender,_tokenA.balanceOf(address(this)));
        }
        if(_tokenB.balanceOf(address(this)) > 1){
            _tokenB.transfer(msg.sender,_tokenB.balanceOf(address(this)));
        }
        
    }

    function addLiquidityETH(
        address tokenA,
        uint amountADesired
    )  payable external {
        IERC20 _tokenA = IERC20(tokenA);

        _tokenA.transferFrom(msg.sender,address(this),amountADesired);
        _tokenA.approve(address(router),amountADesired);
        router.addLiquidityETH{value:msg.value}(
        tokenA,
        amountADesired,
        0,
        0,
        msg.sender,
        block.timestamp
        );

        if(_tokenA.balanceOf(address(this)) > 1){
            _tokenA.transfer(msg.sender,_tokenA.balanceOf(address(this)));
        }
        if(address(this).balance > 0){
            payable(msg.sender).transfer(address(this).balance);
        }
        
    }

    function getPair(address token1,address token2)public view returns(address){
        return PancakeLibrary.pairFor(router.factory(),token1,token2);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity
        
    ) external {
        IERC20 pair = IERC20(getPair(tokenA,tokenB));
        pair.transferFrom(msg.sender,address(this),liquidity);
        pair.approve(address(router),liquidity);

        router.removeLiquidity(
            tokenA,
            tokenB,
            liquidity,
            0,
            0,
            address(this),
            block.timestamp
        );

        IERC20(tokenA).transfer(msg.sender,IERC20(tokenA).balanceOf(address(this)));
        IERC20(tokenB).transfer(msg.sender,IERC20(tokenB).balanceOf(address(this)));
    } 
    function removeLiquidityETH(
        address token,
        uint liquidity        
    ) external { 
        IERC20 pair = IERC20(getPair(router.WETH(),token));
        pair.transferFrom(msg.sender,address(this),liquidity);
        pair.approve(address(router),liquidity);

        address WETH = router.WETH();

        (uint256 amountToken,uint256 amountETH) = router.removeLiquidity(
            token,
            WETH,
            liquidity,
            0,
            0,
            address(this),
            block.timestamp
        );
   

        IERC20(token).transfer(msg.sender,amountToken);
        IWETH(WETH).withdraw(amountETH);
        payable(msg.sender).transfer(amountETH);
    }


    receive () external payable {}
}