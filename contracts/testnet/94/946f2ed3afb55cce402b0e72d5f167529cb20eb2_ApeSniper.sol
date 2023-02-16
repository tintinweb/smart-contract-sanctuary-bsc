/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IRouter {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
}

contract ApeSniper {
    IBEP20 private constant BNB = IBEP20(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);
    IRouter private constant ROUTER = IRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);

    address private _owner;
    address private _tokenAddress;
    uint private _bnbAmount;
    uint private _gasPrice;
    uint private _slippage;

    event BuyToken(address tokenAddress, uint bnbAmount, uint tokenAmount);

    constructor() {
        _owner = msg.sender;
    }

    function setBuyParams(address tokenAddress, uint bnbAmount, uint gasPrice, uint slippage) external {
        require(msg.sender == _owner, "Not authorized");
        _tokenAddress = tokenAddress;
        _bnbAmount = bnbAmount;
        _gasPrice = gasPrice;
        _slippage = slippage;
    }

    function buyToken() external {
        require(_tokenAddress != address(0), "Token address not set");
        require(_bnbAmount > 0, "BNB amount not set");

        uint bnbBalance = BNB.balanceOf(address(this));
        require(bnbBalance >= _bnbAmount, "Insufficient BNB balance");

        IBEP20 token = IBEP20(_tokenAddress);
        uint tokenBalance = token.balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = address(BNB);
        path[1] = _tokenAddress;

        uint[] memory amounts = ROUTER.getAmountsOut(_bnbAmount, path);
        require(amounts[1] > 0, "Token has no liquidity");
        uint expectedTokenAmount = amounts[1];
        uint minTokenAmount = expectedTokenAmount - expectedTokenAmount * _slippage / 100;

        if (tokenBalance < minTokenAmount) {
            uint deadline = block.timestamp + 300; // 5 minute deadline
            uint[] memory swapAmounts = ROUTER.swapExactETHForTokens{value: _bnbAmount}(
            minTokenAmount,
            path,
            address(this),
            deadline
        );

        token.transfer(msg.sender, swapAmounts[1]);
        emit BuyToken(_tokenAddress, _bnbAmount, swapAmounts[1]);
    }
}

function withdraw() external {
    require(msg.sender == _owner, "Not authorized");
    uint bnbBalance = BNB.balanceOf(address(this));
    if (bnbBalance > 0) {
        BNB.transfer(_owner, bnbBalance);
    }

    IBEP20 token = IBEP20(_tokenAddress);
    uint tokenBalance = token.balanceOf(address(this));
    if (tokenBalance > 0) {
        token.transfer(_owner, tokenBalance);
    }
}

}