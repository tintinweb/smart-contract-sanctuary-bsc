/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: MIT

interface ICoSoRouter01 {
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
}

interface ICoSoRouter02 is ICoSoRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
}

interface ICoSoPair {
    function balanceOf(address owner) external view returns (uint);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "e5");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "e6");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "e7");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "e8");
        uint256 c = a / b;
        return c;
    }
}

contract RemoveLiquidityHelper  {
    using SafeMath for uint256;
    function removeLiquidity(ICoSoRouter02 _routerAddress, ICoSoPair _pairAddress,uint256 _removeRate,uint _allRate) external {
        address tokenA = _pairAddress.token0();
        address tokenB = _pairAddress.token1();
        uint256 balance = _pairAddress.balanceOf(msg.sender);
        uint256 removeAmount = balance.mul(_removeRate).div(_allRate);
        _pairAddress.transferFrom(msg.sender,address(this),removeAmount);
        _pairAddress.approve(address(_routerAddress),removeAmount);
       _routerAddress.removeLiquidity(tokenA,tokenB,removeAmount,0,0,msg.sender,block.timestamp);
    }

    function removeLiquidityETH(ICoSoRouter02 _routerAddress, ICoSoPair _pairAddress,uint256 _removeRate,uint _allRate) external {
        address tokenA = _pairAddress.token0();
        address tokenB = _pairAddress.token1();
        address WETH = _routerAddress.WETH();
        address token = tokenA == WETH? tokenB:tokenA;
        uint256 balance = _pairAddress.balanceOf(msg.sender);
        uint256 removeAmount = balance.mul(_removeRate).div(_allRate);
        _pairAddress.transferFrom(msg.sender,address(this),removeAmount);
        _pairAddress.approve(address(_routerAddress),removeAmount);
       _routerAddress.removeLiquidityETH(token,removeAmount,0,0,msg.sender,block.timestamp);
    }

    function removeLiquidityETHSupportingFeeOnTransferTokens(ICoSoRouter02 _routerAddress, ICoSoPair _pairAddress,uint256 _removeRate,uint _allRate) external {
        address tokenA = _pairAddress.token0();
        address tokenB = _pairAddress.token1();
        address WETH = _routerAddress.WETH();
        address token = tokenA == WETH? tokenB:tokenA;
        uint256 balance = _pairAddress.balanceOf(msg.sender);
        uint256 removeAmount = balance.mul(_removeRate).div(_allRate);
        _pairAddress.transferFrom(msg.sender,address(this),removeAmount);
        _pairAddress.approve(address(_routerAddress),removeAmount);
       _routerAddress.removeLiquidityETHSupportingFeeOnTransferTokens(token,removeAmount,0,0,msg.sender,block.timestamp);
    }
}