// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./Oracle.sol";
import "./IERC20.sol";
import "./IUniswapV2Router.sol";

contract LoopSwap is Ownable,Oracle{
    IERC20 public loop;
    IERC20 private usdt;
    address private immutable dead = 0x000000000000000000000000000000000000dEaD;
    IUniswapV2Router02 public immutable uniswapV2Router;

    constructor(address _loop,address _usdt) {
        loop = IERC20(_loop);
        usdt = IERC20(_usdt);
        uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
    }

    function swapThisTokensToTokens(address _fromToken, address _toToken, uint256 amount) internal{
        require(amount>0,"amount must be > 0");

        address[] memory path = new address[](2);
        path[0] = address(_fromToken);
        path[1] = address(_toToken);

        IERC20(_fromToken).approve(address(uniswapV2Router), amount);
        
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of token
            path,
            address(this),
            block.timestamp
        );
    }

    function swap(uint256 _amount) public virtual onlyOracle returns(bool){
        require(usdt.balanceOf(address(this)) >= _amount,"usdt balance must be >= amount");
        swapThisTokensToTokens(address(usdt),address(loop),_amount);
        _burnToken();
        return true;
    }

    function _burnToken() internal{
        require(loop.balanceOf(address(this)) > 0,"contract balance must > 0");
        loop.transfer(dead, loop.balanceOf(address(this)));
    }
    

    
    
}