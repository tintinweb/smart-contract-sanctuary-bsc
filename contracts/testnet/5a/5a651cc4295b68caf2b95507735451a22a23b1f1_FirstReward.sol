/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

interface IUniswapV2Router02  {
    function WETH() external pure returns (address);
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
}
interface IERC20 {
    function balanceOf(address account) external view returns (uint);
    function approve(address spender, uint256 amount) external returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract FirstReward {
    IUniswapV2Router02 public uniswapV2Router;
     constructor()
      {
                // MainNet
        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
        //     0x10ED43C718714eb63d5aA57B78B54704E256024E
        // );
        // TestNet
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        );
        uniswapV2Router = _uniswapV2Router;
      }   
    function swapETHForTokens(address tokenaddress) public payable {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = tokenaddress;

        // Make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: msg.value
        }(
            0, // Accept any amount of Tokens
            path,
            address(this), 
            block.timestamp
        );
    }
    function getbalance(address tokenaddress) public view returns(uint256)
    {
        return IERC20(tokenaddress).balanceOf(address(this));
    }

}