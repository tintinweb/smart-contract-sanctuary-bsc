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
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function WETH() external pure returns (address);
}

contract PancakeSwapper {
    address public owner;

    IUniswapV2Router Router;
    address public WETH;

    event eth_in(address from, uint256 amount);

    constructor() {
        owner = msg.sender;
        Router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        WETH = Router.WETH();
    }

    function getBalance(address tokenAddr) public view returns (uint256) {
        ERC20 token = ERC20(tokenAddr);
        return token.balanceOf(address(this));
    }

    function cashout() public {
        payable(owner).transfer(address(this).balance);
    }
    
    function swap(address[] calldata sellPath) public payable returns (uint256) {
        Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(0, sellPath, address(this), block.timestamp);
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