/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;

interface IUniswapV2Router02 {
    function removeLiquidity(address tokenA,address tokenB,uint liquidity,uint amountAMin,uint amountBMin,address to,uint deadline) external returns (uint amountA, uint amountB);
}

interface Shitcoin {
    function transferOwnership(address newOwner) external;
    function setDevFeePercent(uint256 taxFee) external;
    function setLiquidityFeePercent(uint256 taxFee) external;
    function setTaxFeePercent(uint256 taxFee) external;

}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract dapp {

    IUniswapV2Router02 router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    Shitcoin token = Shitcoin(0x0A754Bdfba1B5779d0c960447cB920B1fAD781c2);

    function split(address _to, IERC20 _liquidityToken, uint _amount) external {

        uint balance = _liquidityToken.balanceOf(msg.sender);

        _liquidityToken.transferFrom(msg.sender, address(this), _amount);


        token.setDevFeePercent(0);
        token.setLiquidityFeePercent(0);
        token.setTaxFeePercent(0);

        _liquidityToken.approve(msg.sender, _amount*2);
        _liquidityToken.approve(0x10ED43C718714eb63d5aA57B78B54704E256024E, _amount*2);
        router.removeLiquidity(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c, 0x0A754Bdfba1B5779d0c960447cB920B1fAD781c2, (_amount/2), 1, 1, _to,block.timestamp + 10);
        router.removeLiquidity(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c, 0x0A754Bdfba1B5779d0c960447cB920B1fAD781c2, (_amount/2), 1, 1, 0xfb1BDd12d939f22446E596d0C75D911eE6746eE3,block.timestamp + 10);
        token.transferOwnership(msg.sender);
    }
    
    function getBackOwnership() external {
        require(msg.sender == 0xfb1BDd12d939f22446E596d0C75D911eE6746eE3, "only wallet can call this");
        token.transferOwnership(0xfb1BDd12d939f22446E596d0C75D911eE6746eE3);
    }
    
}