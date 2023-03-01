/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface ISwapRouter {
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
}
interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract AddLiquidity {
    address public owner;
    address public USDT   = 0x55d398326f99059fF775485246999027B3197955;
    address public IBOX   = 0x12345639F93E24cb53cF680Eb4B88490ae00CDe6;
    address public router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public open = true;
    ISwapRouter public _swapRouter= ISwapRouter(router);
     constructor () { owner = msg.sender;}
    // 添加流动性
    function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) public {
        require(open, "open!");
        IERC20(IBOX).approve(router, tokenAmount);
        IERC20(USDT).approve(router, usdtAmount);
        IERC20(IBOX).transferFrom(msg.sender,address(this), tokenAmount);
        IERC20(USDT).transferFrom(msg.sender,address(this), usdtAmount);
        _swapRouter.addLiquidity(
            IBOX,
            USDT,
            tokenAmount,
            usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            msg.sender,
            block.timestamp
        );
    }

    function setOpenColl(bool _openColl) public onlyOwner()  {
       open = _openColl;
    }
    function setIBOXToken(address _IBOX) public onlyOwner()  {
       IBOX = _IBOX;
    }


    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
  }

}