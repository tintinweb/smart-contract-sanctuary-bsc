/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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

interface IUniswap {
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to,uint deadline) external returns(uint[] memory amounts);
    function WETH() external pure returns(address);
}

contract ACT_SWAP {

    IUniswap uniswap;
    address tokenToSwap = 0xD84779332992a3735fCc6722097F8e74FdCDA64D;
    address tokenToSwaps = 0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47;

    constructor() {
        uniswap = IUniswap(address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3));
    }

    receive() external payable {}

    function swapTokensForETH(uint amountIn) external {
        // need to have called approve on this contract first
        IERC20(tokenToSwap).transferFrom(msg.sender, address(this), amountIn);
        address[] memory path = new address[](3);
        path[0] = address(tokenToSwap);
        path[1] = uniswap.WETH(); // returns address of Wrapped Ether
        path[2] = tokenToSwaps; // returns address of Wrapped Ether
        IERC20(tokenToSwap).approve(address(uniswap), amountIn);
        uniswap.swapExactTokensForETH(
            amountIn, 
            0, 
            path, 
            address(this), 
            block.timestamp
        );
    }

}