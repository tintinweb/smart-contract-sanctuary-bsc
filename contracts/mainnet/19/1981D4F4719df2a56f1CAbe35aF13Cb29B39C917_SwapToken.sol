/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;


interface IUniswapV2Router02 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IERC20 {
    function balanceOf(address owner) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
}

abstract contract Ownable {
    address private _owner;
    constructor() public {
        _owner = msg.sender;
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
}

contract SwapToken is Ownable {
    address USDT = 0x55d398326f99059fF775485246999027B3197955;
    address uniswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    constructor() public payable {
         IERC20(USDT).approve(uniswapV2Router, uint256(-1));
    }
   
    function claimToken() public onlyOwner {
        IERC20(USDT).transfer(msg.sender, IERC20(USDT).balanceOf(address(this)));
    }
    function buy(
        address token,
        uint256 amountIn
    ) public onlyOwner returns (bool) {
        address[] memory path;
        path[0]=USDT;
        path[1]=token;
        IUniswapV2Router02(uniswapV2Router)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amountIn,
                1,
                path,
                msg.sender,
                block.timestamp
            );
        return true;
    }
}