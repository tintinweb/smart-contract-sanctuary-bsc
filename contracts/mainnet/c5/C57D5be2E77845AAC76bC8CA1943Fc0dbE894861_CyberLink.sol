// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./ERC20.sol";
import "./Address.sol";

contract CyberLink is Context, ERC20, Ownable{
    
    using SafeMath for uint256;
    using Address for address;
 
    IUniswapV2Router02 public uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;

    uint256 private minimumTokensToSwap = 10000 * 10 ** 18;

    address public marketingAndDevelopmentAddress = 0xDB256B5a6f4c48B46ee7Efab87fE867fF1D21421;
    address public stake2;
    uint8 buyMarketingFee = 2;
    uint8  sellMarketingFee = 5;
    uint8  buyLiquidityFee = 1;
    uint8 sellLiquidityFee = 3;
    uint8 buyDevelopmentFee = 1;
    uint8 sellDevelopmentFee = 3;
    uint8 buyStakingFee = 1;
    uint8 sellStakingFee = 1;
    uint8 totalFeesBuy = buyMarketingFee + buyLiquidityFee + buyDevelopmentFee + buyStakingFee;
    uint8 totalFeesSell = sellMarketingFee + sellLiquidityFee + sellDevelopmentFee + sellStakingFee;
    uint8 totalFees = totalFeesBuy + totalFeesSell;
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    mapping (address => bool) private _isExcludedFromFees;
 
    event ExcludeFromFees(address indexed account, bool isExcluded);
 
    constructor(address _stake2) ERC20("CyberLink", "CBL") {
 
    	uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
 
        stake2 = _stake2;

        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
 
        _mint(owner(), 100000000 * (10**18));
    }
 
    receive() external payable {
 
  	}

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded);
        _isExcludedFromFees[account] = excluded;
 
        emit ExcludeFromFees(account, excluded);
    }

    function setMinimumTokensToOperate(uint256 minimumTokens) external onlyOwner {
        require(minimumTokens > 0);
        minimumTokensToSwap = minimumTokens;
    }

    function setAddress(address newAddress) external onlyOwner {
        marketingAndDevelopmentAddress = newAddress;
    }
    
    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapAndLiquifyEnabled = _enabled;   
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0));
        require(to != address(0));
        require(amount > 0);

        uint256 contractTokenBalance = balanceOf(address(this));
        bool tokenBeingBoughtOrSold = to == uniswapV2Pair || from == uniswapV2Pair;

        if(!inSwapAndLiquify && swapAndLiquifyEnabled && balanceOf(uniswapV2Pair) > 0 && to == uniswapV2Pair){
            if (contractTokenBalance >= minimumTokensToSwap) {
                contractTokenBalance = minimumTokensToSwap;

                swapAndLiquify(contractTokenBalance);
            }
        }

        bool takeFee = !_isExcludedFromFees[from] && !_isExcludedFromFees[to] && tokenBeingBoughtOrSold;

        _tokenTransfer(from, to, amount, takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {

        uint256 marketingAndDevelopmentBalance = contractTokenBalance.mul(buyMarketingFee + sellMarketingFee + buyDevelopmentFee + sellDevelopmentFee).div(totalFees - buyStakingFee - sellStakingFee);
        if(marketingAndDevelopmentBalance > 0) {
            contractTokenBalance = contractTokenBalance.sub(marketingAndDevelopmentBalance);
            swapTokensForEth(marketingAndDevelopmentBalance, marketingAndDevelopmentAddress);

        }

        if(contractTokenBalance > 0) {
            uint256 half = contractTokenBalance.div(2);
            uint256 otherHalf = contractTokenBalance.sub(half);

            uint256 initialBalance = address(this).balance;

            swapTokensForEth(half, address(this));

            uint256 newBalance = address(this).balance.sub(initialBalance);


            addLiquidity(otherHalf, newBalance);
            

        }
    }

    function swapTokensForEth(uint256 amount, address receiver) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), amount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, path, receiver, block.timestamp);
    }

    function addLiquidity(uint256 amount, uint256 ethAmount) private {

        _approve(address(this), address(uniswapV2Router), amount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(address(this), amount, 0, 0, owner(), block.timestamp);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if (takeFee) {
            uint256 feeAmount; 
            uint256 stakeAmount;
            if(recipient == uniswapV2Pair){
                feeAmount = amount.mul(totalFeesSell - sellStakingFee).div(100);
                stakeAmount = amount.mul(sellStakingFee).div(100);
            }
            if(sender == uniswapV2Pair){
                feeAmount = amount.mul(totalFeesBuy - buyStakingFee).div(100);
                stakeAmount = amount.mul(buyStakingFee).div(100);
            }

            if(feeAmount.add(stakeAmount) > 0) {
                super._transfer(sender, address(this), feeAmount);
                super._transfer(sender, stake2, stakeAmount);
                amount = amount.sub(feeAmount).sub(stakeAmount);
            }
        }

        if(amount > 0) {
            super._transfer(sender, recipient, amount);
        }
    }
}