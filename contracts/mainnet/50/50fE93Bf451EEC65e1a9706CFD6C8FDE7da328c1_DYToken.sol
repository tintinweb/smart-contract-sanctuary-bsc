// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "./ERC20.sol";
import "./SafeMath.sol";
import "./SafeMathUint.sol";
import "./SafeMathInt.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Router.sol";
import "./IUniswapV2Factory.sol";

contract DYToken is ERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "dy/not-authorized");
        _;
    }
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public operationAddress = 0x6e25dA0B3B1BDFd0E6E34F8CbD16c6ec6993EB6a;
    address public uniswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint256 public swapTokensAtAmount = 500 * 1E18;
    bool private swapping;
    bool public  limit;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public automatedMarketMakerPairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);
   
    constructor() public ERC20("Deify DAO", "DY") {
        wards[msg.sender] = 1;
        address _uniswapV2Pair = IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73).createPair(address(this), usdt);
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);
        excludeFromFees(owner(), true);
        excludeFromFees(operationAddress, true);
        _mint(operationAddress, 48000 * 1e18);
    }
	function setOperation(address ust) external auth{
        operationAddress = ust;
	}
    function setLimit() external auth{
        limit = !limit;
	}
    function excludeFromFees(address account, bool excluded) public auth {
        require(_isExcludedFromFees[account] != excluded, "DY: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) public auth {
        require(automatedMarketMakerPairs[pair] != value, "DY: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function _transfer(address from,address to,uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount <= 1E15) {
            super._transfer(from, to, amount);
            return;
        }
 
		uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if(canSwap && !swapping && !automatedMarketMakerPairs[from] && from != owner() && to != owner()) {
            swapping = true;
            if (totalSupply().sub(balanceOf(deadWallet)) > 1*1E22) {
                uint256 burnTokens = contractTokenBalance.mul(1).div(2);
                super._transfer(address(this),deadWallet,burnTokens);
            }
            swapAndLiquify();
            swapping = false;
        }

        if(!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            if(!limit && automatedMarketMakerPairs[from]) {
                address[] memory path = new address[](2);
                path[0] = usdt;
                path[1] = address(this);
                uint[] memory amounts = IUniswapV2Router(uniswapV2Router).getAmountsIn(amount,path);
                uint256 usdtAmount = amounts[0];
                require(usdtAmount <= 100*1E18, "Dy: 1");
            }
        	uint256 fees = amount.mul(2).div(100);
            super._transfer(from, address(this), fees);
            amount = amount.sub(fees);
        }
        super._transfer(from, to, amount);       
    }

    function init() public {
        IERC20(address(this)).approve(uniswapV2Router, ~uint256(0));
        IERC20(usdt).approve(uniswapV2Router, ~uint256(0));
    }

    function swapAndLiquify() internal {
        uint256 tokens = balanceOf(address(this));
        uint256 half = tokens.div(2);
        swapTokensForUsdt(half);
        uint256 usdtamount = IERC20(usdt).balanceOf(operationAddress); 
        IERC20(usdt).transferFrom(operationAddress,address(this),usdtamount);
        IUniswapV2Router(uniswapV2Router).addLiquidity(
            address(this),
            usdt,
            balanceOf(address(this)),
            IERC20(usdt).balanceOf(address(this)),
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            operationAddress,
            block.timestamp
        );
    }

    function swapTokensForUsdt(uint256 tokenAmount) internal{
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        IUniswapV2Router(uniswapV2Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            operationAddress,
            block.timestamp
        );
    }

    function withdraw(address asses, uint256 amount, address ust) public auth {
        IERC20(asses).transfer(ust, amount);
    }

}