/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.12;

interface IPancakeRouter{
    function WETH() external pure returns (address);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

contract EC{

    uint256 private constant MAX = ~uint256(0);

    IPancakeRouter private router;
    address private _USDT = 0x55d398326f99059fF775485246999027B3197955;
    address private _ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private _KNTC = 0x9f8c02932708Ae28a16cBB4A5eA6E2f1a4D62A99;

    TokenDistributor private _tokenDistributor;

    constructor(){
        router = IPancakeRouter(_ROUTER);
        IERC20(_KNTC).approve(_ROUTER, MAX);
        _tokenDistributor = new TokenDistributor(_USDT);
    }

    function swap(uint256 amount) public virtual returns (uint[] memory) {
        address[] memory path = new address[](2);
        path[0] = _KNTC;
        path[1] = _USDT;
        return router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
            );
    }
}