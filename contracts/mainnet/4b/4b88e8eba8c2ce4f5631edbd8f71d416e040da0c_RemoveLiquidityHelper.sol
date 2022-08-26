/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: MIT

interface IERC20 {
    function approve(address spender, uint256 value) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


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


    function addLiquidityETH(
        ICoSoRouter02 _routerAddress,
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin) external payable {
            IERC20(token).approve(address(_routerAddress),amountTokenDesired);
            uint256 balanceOfA_0 = IERC20(token).balanceOf(address(this));
            uint256 balanceOfB_0 = address(this).balance;
            IERC20(token).transferFrom(msg.sender,address(this),amountTokenDesired);
            uint256 balanceOfA_1 = IERC20(token).balanceOf(address(this));
            amountTokenDesired = balanceOfA_1.sub(balanceOfA_0);
            _routerAddress.addLiquidityETH{value:msg.value}(token,amountTokenDesired,amountTokenMin,amountETHMin,msg.sender,block.timestamp);
            uint256 balanceOfA_2 = IERC20(token).balanceOf(address(this));
            uint256 balanceOfB_2 = address(this).balance;
            if (balanceOfA_2>balanceOfA_0) {
               IERC20(token).transfer(msg.sender,balanceOfA_2.sub(balanceOfA_0));
            }
            if (balanceOfB_2>balanceOfB_0) {
               msg.sender.transfer(balanceOfB_2.sub(balanceOfB_0));
            }
    }

    function addLiquidity(
        ICoSoRouter02 _routerAddress,  address tokenA,address tokenB,uint256 amountADesired,uint256 amountBDesired,uint256 amountAMin,uint256 amountBMin) external {
            IERC20(tokenA).approve(address(_routerAddress),amountADesired);
            IERC20(tokenB).approve(address(_routerAddress),amountBDesired);
            uint256 balanceOfA_0 = IERC20(tokenA).balanceOf(address(this));
            uint256 balanceOfB_0 = IERC20(tokenB).balanceOf(address(this));
            IERC20(tokenA).transferFrom(msg.sender,address(this),amountADesired);
            IERC20(tokenB).transferFrom(msg.sender,address(this),amountBDesired);
            uint256 balanceOfA_1 = IERC20(tokenA).balanceOf(address(this));
            uint256 balanceOfB_1 = IERC20(tokenB).balanceOf(address(this));
            amountADesired = balanceOfA_1.sub(balanceOfA_0);
            amountBDesired = balanceOfB_1.sub(balanceOfB_0);
            _routerAddress.addLiquidity(tokenA,tokenB,amountADesired,amountBDesired,amountAMin,amountBMin,msg.sender,block.timestamp);
            uint256 balanceOfA_2 = IERC20(tokenA).balanceOf(address(this));
            uint256 balanceOfB_2 = IERC20(tokenB).balanceOf(address(this));
            if (balanceOfA_2>balanceOfA_0) {
               IERC20(tokenA).transfer(msg.sender,balanceOfA_2.sub(balanceOfA_0));
            }
            if (balanceOfB_2>balanceOfB_0) {
               IERC20(tokenA).transfer(msg.sender,balanceOfB_2.sub(balanceOfB_0));
            }
    }

    function removeLiquidity(ICoSoRouter02 _routerAddress, ICoSoPair _pairAddress,uint256 _removeRate,uint _allRate) external {
        address tokenA = _pairAddress.token0();
        address tokenB = _pairAddress.token1();
        uint256 balance = _pairAddress.balanceOf(msg.sender);
        uint256 removeAmount = balance.mul(_removeRate).div(_allRate);
        _pairAddress.transferFrom(msg.sender,address(this),removeAmount);
        uint256 balanceA_0 = IERC20(tokenA).balanceOf(address(this));
        uint256 balanceB_0 = IERC20(tokenB).balanceOf(address(this));
        _pairAddress.approve(address(_routerAddress),removeAmount);
        _routerAddress.removeLiquidity(tokenA,tokenB,removeAmount,0,0,address(this),block.timestamp);
        uint256 balanceA_1 = IERC20(tokenA).balanceOf(address(this));
        uint256 balanceB_1 = IERC20(tokenB).balanceOf(address(this));
        if (balanceA_1>balanceA_0) {
            IERC20(tokenA).transfer(msg.sender,balanceA_1.sub(balanceA_0));
        }
        if (balanceB_1>balanceB_0) {
            IERC20(tokenB).transfer(msg.sender,balanceB_1.sub(balanceB_0));
        }
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
        uint256 balanceA_0 = IERC20(token).balanceOf(address(this));
        uint256 balanceB_0 = address(this).balance;
        _routerAddress.removeLiquidityETH(token,removeAmount,0,0,address(this),block.timestamp);
        uint256 balanceA_1 = IERC20(token).balanceOf(address(this));
        uint256 balanceB_1 = address(this).balance;
        if (balanceA_1>balanceA_0) {
            IERC20(token).transfer(msg.sender,balanceA_1.sub(balanceA_0));
        }
        if (balanceB_1>balanceB_0) {
            msg.sender.transfer(balanceB_1.sub(balanceB_0));
        }
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
        uint256 balanceA_0 = IERC20(token).balanceOf(address(this));
        uint256 balanceB_0 = address(this).balance;
        _routerAddress.removeLiquidityETHSupportingFeeOnTransferTokens(token,removeAmount,0,0,address(this),block.timestamp);
        uint256 balanceA_1 = IERC20(token).balanceOf(address(this));
        uint256 balanceB_1 = address(this).balance;
        if (balanceA_1>balanceA_0) {
            IERC20(token).transfer(msg.sender,balanceA_1.sub(balanceA_0));
        }
        if (balanceB_1>balanceB_0) {
            msg.sender.transfer(balanceB_1.sub(balanceB_0));
        }
    }

    receive() payable external {}
}