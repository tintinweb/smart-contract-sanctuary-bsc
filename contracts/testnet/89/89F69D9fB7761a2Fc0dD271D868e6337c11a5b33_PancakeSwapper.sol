// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*
    ██████╗  █████╗ ███╗   ██╗ ██████╗ █████╗ ██╗  ██╗███████╗
    ██╔══██╗██╔══██╗████╗  ██║██╔════╝██╔══██╗██║ ██╔╝██╔════╝
    ██████╔╝███████║██╔██╗ ██║██║     ███████║█████╔╝ █████╗  
    ██╔═══╝ ██╔══██║██║╚██╗██║██║     ██╔══██║██╔═██╗ ██╔══╝  
    ██║     ██║  ██║██║ ╚████║╚██████╗██║  ██║██║  ██╗███████╗
    ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
                                                            
    ███████╗██╗    ██╗ █████╗ ██████╗ ██████╗ ███████╗██████╗ 
    ██╔════╝██║    ██║██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
    ███████╗██║ █╗ ██║███████║██████╔╝██████╔╝█████╗  ██████╔╝
    ╚════██║██║███╗██║██╔══██║██╔═══╝ ██╔═══╝ ██╔══╝  ██╔══██╗
    ███████║╚███╔███╔╝██║  ██║██║     ██║     ███████╗██║  ██║
    ╚══════╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝╚═╝  ╚═╝
                                                            
*/

interface ERC20 {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address _to, uint256 _value) external returns (bool);
}

interface IUniswapV2Router {
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function WETH() external pure returns (address);
}

contract PancakeSwapper {
    address public owner;

    IUniswapV2Router Router;
    address public WETH;

    event eth_in(address from, uint256 amount);

    constructor() {
        owner = msg.sender;
        Router = IUniswapV2Router(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // 0x10ED43C718714eb63d5aA57B78B54704E256024E
        WETH = Router.WETH();
    }

    function getBalance(address tokenAddr) public view returns (uint256) {
        ERC20 token = ERC20(tokenAddr);
        return token.balanceOf(address(this));
    }

    function cashout() public {
        payable(owner).transfer(address(this).balance);
    }
    
    function swap(address[] calldata buyPath, address[] calldata sellPath) public payable returns (uint256) {
        address tokenAddress = sellPath[0];
        // Buy the tokens
        Router.swapExactETHForTokens{value: msg.value}(0, buyPath, address(this), block.timestamp);
        ERC20 token = ERC20(tokenAddress);
        uint256 token_balance = token.balanceOf(address(this));
        // Sell the tokens
        token.approve(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3, token_balance);
        Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(token_balance, 0, sellPath, address(this), block.timestamp);
        uint256 WETH_balance = getBalance(WETH);
        if (WETH_balance > 0) {
            ERC20(WETH).transfer(owner, WETH_balance);
        }
        return WETH_balance;
    }
    
    receive() external payable {
        emit eth_in(msg.sender, msg.value);
    }
    
    fallback() external payable {
        emit eth_in(msg.sender, msg.value);
    }
}