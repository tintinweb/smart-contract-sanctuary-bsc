/**
 *Submitted for verification at BscScan.com on 2022-05-08
*/

//SPDX-License-Identifier: Unlicensed
/** 
 *  SourceUnit: /Users/moneymaster/Downloads/uniswap-arbitrage-flash-swap-main/contracts/Flashswap.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity >=0.6.2 <0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}




/** 
 *  SourceUnit: /Users/moneymaster/Downloads/uniswap-arbitrage-flash-swap-main/contracts/Flashswap.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
  function getPair(address tokenA, address tokenB) external view returns (address pair);
}




/** 
 *  SourceUnit: /Users/moneymaster/Downloads/uniswap-arbitrage-flash-swap-main/contracts/Flashswap.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}




/** 
 *  SourceUnit: /Users/moneymaster/Downloads/uniswap-arbitrage-flash-swap-main/contracts/Flashswap.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity >=0.6.2;

interface IUniswapV2Router {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
}


/** 
 *  SourceUnit: /Users/moneymaster/Downloads/uniswap-arbitrage-flash-swap-main/contracts/Flashswap.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: UNLICENSED

pragma solidity >=0.6.6 <0.8.0;

////import './interfaces/IUniswapV2Router.sol';
////import './interfaces/IUniswapV2Pair.sol';
////import './interfaces/IUniswapV2Factory.sol';
////import './interfaces/IERC20.sol';

// @author Daniel Espendiller - https://github.com/Haehnchen/uniswap-arbitrage-flash-swap - espend.de
//
// e00: out of block
// e01: no profit
// e10: Requested pair is not available
// e11: token0 / token1 does not exist
// e12: src/target router empty
// e13: pancakeCall not enough tokens for buyback
// e14: pancakeCall msg.sender transfer failed
// e15: pancakeCall owner transfer failed
// e16
contract Flashswap {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function start(
        uint _maxBlockNumber,
        address _tokenBorrow, // example BUSD
        uint256 _amountTokenPay, // example: BNB => 10 * 1e18
        address _tokenPay, // our profit and what we will get; example BNB
        address _sourceRouter,
        address _targetRouter,
        address _sourceFactory
    ) external {
        require(block.number <= _maxBlockNumber, 'e00');

        // recheck for stopping and gas usage
        (int256 profit, uint256 _tokenBorrowAmount) = check(_tokenBorrow, _amountTokenPay, _tokenPay, _sourceRouter, _targetRouter);
        require(profit > 0, 'e01');

        address pairAddress = IUniswapV2Factory(_sourceFactory).getPair(_tokenBorrow, _tokenPay); // is it cheaper to compute this locally?
        require(pairAddress != address(0), 'e10');

        address token0 = IUniswapV2Pair(pairAddress).token0();
        address token1 = IUniswapV2Pair(pairAddress).token1();

        require(token0 != address(0) && token1 != address(0), 'e11');

        IUniswapV2Pair(pairAddress).swap(
            _tokenBorrow == token0 ? _tokenBorrowAmount : 0,
            _tokenBorrow == token1 ? _tokenBorrowAmount : 0,
            address(this),
            abi.encode(_sourceRouter, _targetRouter)
        );
    }

    function check(
        address _tokenBorrow, // example: BUSD
        uint256 _amountTokenPay, // example: BNB => 10 * 1e18
        address _tokenPay, // example: BNB
        address _sourceRouter,
        address _targetRouter
    ) public view returns(int256, uint256) {
        address[] memory path1 = new address[](2);
        address[] memory path2 = new address[](2);
        path1[0] = path2[1] = _tokenPay;
        path1[1] = path2[0] = _tokenBorrow;

        uint256 amountOut = IUniswapV2Router(_sourceRouter).getAmountsOut(_amountTokenPay, path1)[1];
        uint256 amountRepay = IUniswapV2Router(_targetRouter).getAmountsOut(amountOut, path2)[1];

        return (
            int256(amountRepay - _amountTokenPay), // our profit or loss; example output: BNB amount
            amountOut // the amount we get from our input "_amountTokenPay"; example: BUSD amount
        );
    }

}