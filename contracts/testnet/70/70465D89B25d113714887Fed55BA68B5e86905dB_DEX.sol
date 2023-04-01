/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: MIT

/* This smart contract swaps 1 BEP20 token for 1 USDT token. We must remember that 1 USDT token = 1e18 wei. 
For the sake of the project token address has been taken as : 0x64311F21D04534189d60848D8aDfA5Fc07E7B79e", however, in real 
scenario, it will be different. 
*/
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IPancakeRouter02 {
    function swapExactTokensForTokens(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline) external returns (uint[] memory amounts);
}

contract DEX {
    IERC20 private constant USDT = IERC20(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd); // USDT contract address
    IERC20 private constant BEP20_TOKEN = IERC20(0xcA51bA0Dbf7646C50f879222c3A647900Ab21de6); // Replace with the BEP20 token contract address

    address private constant PANCAKESWAP_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // PancakeSwap Router contract address

    address private owner;

    event Bought(uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function buy(uint256 amount) external {
        uint256 usdtBalance = USDT.balanceOf(msg.sender);
        require(usdtBalance >= amount, "Insufficient USDT balance");

        require(USDT.approve(PANCAKESWAP_ROUTER, amount), "Approval failed");

        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(BEP20_TOKEN);

        (uint256[] memory amounts) = IPancakeRouter02(PANCAKESWAP_ROUTER).swapExactTokensForTokens(
            amount,
            0,
            path,
            msg.sender,
            block.timestamp
        );

        emit Bought(amounts[1]);
    }

    function transferOwnership(address newOwner) external {
        require(msg.sender == owner, "Only owner can call this function");
        owner = newOwner;
    }

     
       function TransferETH( address payable _receiver,uint256 _Amount) public  {
        (_receiver).transfer(_Amount);
       }


/*
    function sell(uint256 amount) public {
        require(amount > 0, "You need to sell at least some tokens");
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        token.transferFrom(msg.sender, address(this), amount);
        payable(msg.sender).transfer(amount);
        emit Sold(amount);
    }
*/

}