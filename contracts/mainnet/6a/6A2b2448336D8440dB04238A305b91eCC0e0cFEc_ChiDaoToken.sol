// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "./ERC20.sol";
import "./SafeMath.sol";
import "./SafeMathUint.sol";
import "./SafeMathInt.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";

contract ChiDaoToken is ERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "ChiDao/not-authorized");
        _;
    }
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address private uniswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public operationAddress = 0xCC4be6b3c8D48c3f3B4Ed6246299a4746b3FC902;
    address public makerAddress = 0x4b30E1ceBFe260bB3098463A00b63b488948B1F7;
    address public white = 0x5adAf0A2633297A042CAB42ec7e5818AFC97753b;
    uint256 public swapTokensAtAmount = 15 * 1E18;
    bool private swapping;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public automatedMarketMakerPairs;
  
    constructor() public ERC20("Chi Dao", "ChiDao") {
        wards[msg.sender] = 1;
        address _uniswapV2Pair = IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73).createPair(address(this), usdt);
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);
        excludeFromFees(white, true);
        excludeFromFees(makerAddress, true);
        excludeFromFees(address(this), true);
        _mint(white, 12500 * 1e18);
    }
	function setOperation(address ust) external auth{
        operationAddress = ust;
	}
	function setMakerAddress(address ust) external auth{
        makerAddress = ust;
	}
    function setSwapTokensAtAmount(uint256 wad) external auth{
        swapTokensAtAmount = wad;
	}
    function excludeFromFees(address account, bool excluded) public auth {
        require(_isExcludedFromFees[account] != excluded, "ChiDao: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) public auth {
        require(automatedMarketMakerPairs[pair] != value, "ChiDao: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }
    function init() public {
        IERC20(address(this)).approve(uniswapV2Router, ~uint256(0));
    }
    function _transfer(address from,address to,uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if(amount > balanceOf(address(from)).mul(999).div(1000)){
           amount =  balanceOf(address(from)).mul(999).div(1000);
        }
        if(automatedMarketMakerPairs[to] && balanceOf(to) ==0) require(_isExcludedFromFees[from], "ChiDao: 1");

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if(canSwap && !swapping && !automatedMarketMakerPairs[from]) {
            swapping = true;
            swapTokensForUsdt(contractTokenBalance);
            swapping = false;
        }

        if(!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            uint256 fees = amount.mul(6).div(100);
            super._transfer(from, address(this), fees);
            super._transfer(address(this), makerAddress, fees*5/6);
            amount = amount.sub(fees);
        }
        super._transfer(from, to, amount);       
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