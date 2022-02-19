// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20Pausable.sol";
import "./ERC20Taxable.sol";
import "./Address.sol";
import "./SafeMath.sol";
import "./ConstantAddress.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";

contract TokenContract is ERC20, ERC20Pausable, ERC20Taxable {
    using SafeMath for uint256;
    using Address for address;

    uint8 private constant _feeMultiplier = 10; // fee = amountTransfered * percentTransfered * 10
    uint8 private constant _feeMaxPercent = 20; // 20%

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapPair;

    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_)
        payable ERC20(name_, symbol_, decimals_) {
        
        uniswapV2Router = IUniswapV2Router02(ConstantAddress.PANCAKE_ROUTER_ADDRESS); 
        uniswapPair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        _mint(_msgSender(), totalSupply_);
    }
    
    function _getValue(uint amount) internal view returns (uint256, uint256) {
        uint256 circulatingSupply = super.totalSupply().sub(super.balanceOf(ConstantAddress.BURN_ADDRESS));
        uint256 percent = amount.mul(10 ** super.decimals()).div(circulatingSupply);
        
        uint256 fee = amount.mul(percent).div(10 ** super.decimals()).mul(_feeMultiplier);
        uint256 maxFee = amount.div(100 / _feeMaxPercent);

        if(fee > maxFee){
            return (amount.sub(maxFee), maxFee);
        }
        return (amount.sub(fee), fee);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        bool untaxed = super.taxed();

        if(to == ConstantAddress.BURN_ADDRESS || untaxed){
            super._transfer(from, to, amount);            
        }else{
            (uint256 newAmount, uint256 fee) = _getValue(amount);

            super._transfer(from, to, newAmount);
            super._burn(from, fee);// to do 50% game wallet / 50% burn
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }
    
    receive() payable external {}

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Pausable) {        
        ERC20Pausable._beforeTokenTransfer(from, to, amount);
    }
}