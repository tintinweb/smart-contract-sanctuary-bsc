// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./SafeToken.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
import "./DividendPayingToken.sol";
import "./Ownable.sol";

contract DualRewardTest is ERC20, Ownable, SafeToken {
    using SafeMath for uint256;
 
    IUniswapV2Router02 public uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    bool private swapping;
    bool public swapAndLiquifyEnabled = true;
   
    mapping(address => bool) public _isBlacklisted; //blacklist function
    
    TOKEN1DividendTracker  public token1DividendTracker;
    TOKEN2DividendTracker public token2DividendTracker;

    address public DeadWallet = 0x000000000000000000000000000000000000dEaD;
    address public marketingWallet = 0x4aAB4ED440A8406eC15C140e3627dfc7701B9D0F;
    
    uint256 public maxSellTransactionAmount = 1000000 * (10**9); // max sell 1% of supply
    uint256 public maxWalletAmount = 6000000 * (10**9); // max wallet amount 6%
    uint256 public swapTokensAtAmount = 100000 * 10**9; // swap at 100K tokens min
   
    // BNB              0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    // BUSD             0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    // USDT             0x55d398326f99059fF775485246999027B3197955
    // MATIC            0xCC42724C6683B7E57334c4E856f4c9965ED682bD
    // ETH              0x2170Ed0880ac9A755fd29B2688956BD959F933F8
    // CAKE             0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82    
    // BTCB             0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c
    // ADA              0x3EE2200Efb3400fAbB9AacF31297cBdD1d435D47
    // SOL              0x570A5D26f7765Ecb712C0924E4De545B89fD43dF
    // AVAX             0x1CE0c2827e2eF14D5C4f29a091d735A204794041
    // MoonWalk         0x9e566A4A22dCAfeF7De5d829Fd199d297Bb01487
    // EarthWalk
    // SunWalk
    // SaturnWalk
        
    IERC20 public TOKEN1 = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); //BUSD
    IERC20 public TOKEN2 = IERC20(0x55d398326f99059fF775485246999027B3197955); // USDT
    
    //uint256 public _liquidityShare = 25;
    //uint256 public _marketingShare = 25;
    //uint256 public _rewardsShare = 50;

    uint256 public _LiquidityFee = 1;
    uint256 public _BurnFee = 1;
    
    uint256 public _buyMarketingFee = 2;
    uint256 public _buytoken1DividendRewardsFee = 6;
    uint256 public _buytoken2DividendRewardsFee = 3;
    
    uint256 public _sellMarketingFee = 4;
    uint256 public _selltoken1DividendRewardsFee = 9;
    uint256 public _selltoken2DividendRewardsFee = 4;

    uint256 public _totalTaxIfBuying = 0;
    uint256 public _totalTaxIfSelling = 0;
    //uint256 public _totalDistributionShares = 100;

    uint256 public gasForProcessing = 300000;
 
    address public presaleAddress;

    // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isExcludedFromMaxTx;
   
    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;
 
    function setContractLimits(uint256 _maxWalletAmount, uint256 _maxSellTransactionAmount) public onlyOwner {
        maxWalletAmount = _maxWalletAmount;
        maxSellTransactionAmount = _maxSellTransactionAmount;
    }

    function setSwapTokensAtAmount(uint256 _swapAmount) external onlyOwner {
  	    swapTokensAtAmount = _swapAmount;
  	}
    
    event Updatetoken1DividendTracker(address indexed newAddress, address indexed oldAddress);
    event Updatetoken2DividendTracker(address indexed newAddress, address indexed oldAddress);
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event MarketingWalletUpdated(address indexed newMarketingWallet, address indexed oldMarketingWallet);
    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event SwapAndLiquify( uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
    event SendDividends( uint256 amount );
    event Processedtoken1DividendTracker( uint256 iterations, uint256 claims, uint256 lastProcessedIndex, bool indexed automatic, uint256 gas, address indexed processor);
    event Processedtoken2DividendTracker( uint256 iterations, uint256 claims, uint256 lastProcessedIndex, bool indexed automatic, uint256 gas, address indexed processor);
 
    constructor() ERC20("Dual Rewards Test", "DRT") {
    	token1DividendTracker = new TOKEN1DividendTracker();
    	token2DividendTracker = new TOKEN2DividendTracker();
        //P 0x10ED43C718714eb63d5aA57B78B54704E256024E
        //T 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
         // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
 
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
 
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);
        
        _totalTaxIfBuying = _LiquidityFee.add(_buyMarketingFee).add(_buytoken1DividendRewardsFee).add(_buytoken2DividendRewardsFee).add(_BurnFee); //XX%
        _totalTaxIfSelling = _LiquidityFee.add(_sellMarketingFee).add(_selltoken1DividendRewardsFee).add(_selltoken2DividendRewardsFee).add(_BurnFee);//YY%
       
        // exclude from receiving dividends
        excludeFromDividend(address(token1DividendTracker));
        excludeFromDividend(address(token2DividendTracker));
        excludeFromDividend(address(this));
        excludeFromDividend(address (owner()));
        excludeFromDividend(address(_uniswapV2Router));
        excludeFromDividend(DeadWallet);
 
        // exclude from paying fees or having max transaction amount
        excludeFromFees(marketingWallet, true);
        excludeFromFees(address(this), true);
        excludeFromFees(DeadWallet, true);
        excludeFromFees(owner(), true);
 
        // exclude from max tx
        _isExcludedFromMaxTx[owner()] = true;
        _isExcludedFromMaxTx[address(this)] = true;
        _isExcludedFromMaxTx[marketingWallet] = true;
     //   isMarketPair[address(_uniswapV2Pair)] = true;
 
        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), 100000000 * (10**9)); // 100 millions tokens
    }
 
    receive() external payable {
 
  	}
 
  	function whitelistPreSale(address _presaleAddress, address _routerAddress) external onlyOwner {
  	    presaleAddress = _presaleAddress;
        token1DividendTracker.excludeFromDividends(_presaleAddress);
        token2DividendTracker.excludeFromDividends(_presaleAddress);
        excludeFromFees(_presaleAddress, true);
 
        token2DividendTracker.excludeFromDividends(_routerAddress);
        token1DividendTracker.excludeFromDividends(_routerAddress);
        excludeFromFees(_routerAddress, true);
  	}
 
  	function prepareForPartherOrExchangeListing(address _partnerOrExchangeAddress) external onlyOwner {
  	    token1DividendTracker.excludeFromDividends(_partnerOrExchangeAddress);
        token2DividendTracker.excludeFromDividends(_partnerOrExchangeAddress);
        excludeFromFees(_partnerOrExchangeAddress, true);
  	}

 
 
  	function updateMarketingWallet(address _newWallet) external onlyOwner {
  	    require(_newWallet != marketingWallet, "DualRewardTest: The marketing wallet is already this address");
        excludeFromFees(_newWallet, true);
        emit MarketingWalletUpdated(marketingWallet, _newWallet);
  	    marketingWallet = _newWallet;
  	}

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
      swapAndLiquifyEnabled = _enabled;
 
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function updateToken1DividendTracker(address newAddress) external onlyOwner {
        require(newAddress != address(token1DividendTracker), "DualRewardTest: The dividend tracker already has that address");
 
        TOKEN1DividendTracker newtoken1DividendTracker =  TOKEN1DividendTracker(payable(newAddress));
 
        require(newtoken1DividendTracker.owner() == address(this), "DualRewardTest: The new dividend tracker must be owned by the DualRewardTest token contract");
 
        newtoken1DividendTracker.excludeFromDividends(address(newtoken1DividendTracker));
        newtoken1DividendTracker.excludeFromDividends(address(this));
        newtoken1DividendTracker.excludeFromDividends(address(uniswapV2Router));
        newtoken1DividendTracker.excludeFromDividends(address(DeadWallet));
 
        emit Updatetoken1DividendTracker(newAddress, address(token1DividendTracker));
 
        token1DividendTracker = newtoken1DividendTracker;
    }
 
    function updateToken2DividendTracker(address newAddress) external onlyOwner {
        require(newAddress != address(token2DividendTracker), "DualRewardTest: The dividend tracker already has that address");
 
        TOKEN2DividendTracker newtoken2DividendTracker = TOKEN2DividendTracker(payable(newAddress));
 
        require(newtoken2DividendTracker.owner() == address(this), "DualRewardTest: The new dividend tracker must be owned by the DualRewardTest token contract");
 
        newtoken2DividendTracker.excludeFromDividends(address(newtoken2DividendTracker));
        newtoken2DividendTracker.excludeFromDividends(address(this));
        newtoken2DividendTracker.excludeFromDividends(address(uniswapV2Router));
        newtoken2DividendTracker.excludeFromDividends(address(DeadWallet));
 
        emit Updatetoken2DividendTracker(newAddress, address(token2DividendTracker));
 
        token2DividendTracker = newtoken2DividendTracker;
    }
 
    //  Update Buy Taxes  
    function setBuyTaxes(uint256 newMarketingTax, uint256 newReward1Tax, uint256 newReward2Tax) external onlyOwner() {
      require(newMarketingTax.add(newReward1Tax).add(newReward2Tax).add(_LiquidityFee).add(_BurnFee) <= 25, "Total Tax can't exceed 25%.");
		 
      _buyMarketingFee = newMarketingTax;
      _buytoken1DividendRewardsFee = newReward1Tax;
      _buytoken2DividendRewardsFee = newReward2Tax;
 
      _totalTaxIfBuying = _LiquidityFee.add(_buyMarketingFee).add(_buytoken1DividendRewardsFee).add(_buytoken2DividendRewardsFee).add(_BurnFee);
    }
    // Update Sell Taxes 
    function setSellTaxes(uint256 newMarketingTax, uint256 newReward1Tax, uint256 newReward2Tax) external onlyOwner() {
      require(newMarketingTax.add(newReward1Tax).add(newReward2Tax).add(_LiquidityFee).add(_BurnFee) <= 25, "Total Tax can't exceed 25%.");
		
      _sellMarketingFee = newMarketingTax;
      _selltoken1DividendRewardsFee = newReward1Tax;
      _selltoken2DividendRewardsFee = newReward2Tax;

      _totalTaxIfSelling = _LiquidityFee.add(_sellMarketingFee).add(_selltoken1DividendRewardsFee).add(_selltoken2DividendRewardsFee).add(_BurnFee);
    }
    
    function SetLiquidityBurn(uint256 newLiquidityTax, uint256 newBurnTax) external onlyOwner() {
        require(newLiquidityTax.add(newBurnTax) <= 10, "Liquidity and burn Tax can't exceed 10%.");
		 
        _LiquidityFee = newLiquidityTax;
        _BurnFee=newBurnTax;

        _totalTaxIfBuying = _LiquidityFee.add(_buyMarketingFee).add(_buytoken1DividendRewardsFee).add(_buytoken2DividendRewardsFee).add(_BurnFee);
        _totalTaxIfSelling = _LiquidityFee.add(_sellMarketingFee).add(_selltoken1DividendRewardsFee).add(_selltoken2DividendRewardsFee).add(_BurnFee);
    }
    
    function excludeFromFees(address _address, bool excluded) public onlyOwner {
        _isExcludedFromFees[_address] = excluded;
        emit ExcludeFromFees(_address, excluded);
    }
 
    function excludeFromDividend(address _address) public onlyOwner {
        token1DividendTracker.excludeFromDividends(address(_address));
        token2DividendTracker.excludeFromDividends(address(_address));
    }
    
    function setExcludeFromMaxTx(address _address, bool value) external onlyOwner { 
        _isExcludedFromMaxTx[_address] = value;
    }

    function setExcludeFromAll(address _address) external onlyOwner {
        _isExcludedFromMaxTx[_address] = true;
        _isExcludedFromFees[_address] = true;
        token1DividendTracker.excludeFromDividends(address(_address));
        token2DividendTracker.excludeFromDividends(address(_address));
    }
    
 

    function updateUniswapV2Router(address newAddress) external onlyOwner {
        require(newAddress != address(uniswapV2Router), "DualRewardTest: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }
 
    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
 
        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }
    
    function blacklistAddress(address account, bool value) external onlyOwner { //blacklist function
        _isBlacklisted[account] = value;
    }
    
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "DualRewardTest: The pair cannot be removed from automatedMarketMakerPairs");
 
        _setAutomatedMarketMakerPair(pair, value);
    }
 
    function _setAutomatedMarketMakerPair(address pair, bool value) private onlyOwner {
        require(automatedMarketMakerPairs[pair] != value, "DualRewardTest: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
 
        if(value) {
            token1DividendTracker.excludeFromDividends(pair);
            token2DividendTracker.excludeFromDividends(pair);
        }
 
        emit SetAutomatedMarketMakerPair(pair, value);
    }
 
    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 1000000, "DualRewardTest: gasForProcessing must be between 200,000 and 1000,000");
        require(newValue != gasForProcessing, "DualRewardTest: Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }
 
    function updateMinimumBalanceForDividends(uint256 newMinimumBalance) external onlyOwner {
        token1DividendTracker.updateMinimumTokenBalanceForDividends(newMinimumBalance);
        token2DividendTracker.updateMinimumTokenBalanceForDividends(newMinimumBalance);
    }
 
    function updateClaimWait(uint256 claimWait) external onlyOwner {
        token1DividendTracker.updateClaimWait(claimWait);
        token2DividendTracker.updateClaimWait(claimWait);
    }
 
    function getTOKEN1ClaimWait() external view returns(uint256) {
        return token1DividendTracker.claimWait();
    }
 
    function getTOKEN2ClaimWait() external view returns(uint256) {
        return token2DividendTracker.claimWait();
    }
 
    function getTotalTOKEN1DividendsDistributed() external view returns (uint256) {
        return token1DividendTracker.totalDividendsDistributed();
    }
 
    function getTotalTOKEN2DividendsDistributed() external view returns (uint256) {
        return token2DividendTracker.totalDividendsDistributed();
    }
 
    function getIsExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }
 
    function withdrawableTOKEN1DividendOf(address account) external view returns(uint256) {
    	return token1DividendTracker.withdrawableDividendOf(account);
  	}
 
  	function withdrawableTOKEN2DividendOf(address account) external view returns(uint256) {
    	return token2DividendTracker.withdrawableDividendOf(account);
  	}
 
	function token1DividendTokenBalanceOf(address account) external view returns (uint256) {
		return token1DividendTracker.balanceOf(account);
	}
 
	function token2DividendTokenBalanceOf(address account) external view returns (uint256) {
		return token2DividendTracker.balanceOf(account);
	}
 
    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }
    
    function isExcludedFromMaxTx(address account) public view returns(bool) {
        return _isExcludedFromMaxTx[account];
    }

    function getAccounttoken1DividendsInfo(address account)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return token1DividendTracker.getAccount(account);
    }
 
    function getAccountTOKEN2DividendsInfo(address account)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return token2DividendTracker.getAccount(account);
    }
 
	function getAccountTOKEN1DividendsInfoAtIndex(uint256 index)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	return token1DividendTracker.getAccountAtIndex(index);
    }
 
    function getAccountTOKEN2DividendsInfoAtIndex(uint256 index)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	return token2DividendTracker.getAccountAtIndex(index);
    }
 
	function processDividendTracker(uint256 gas) external onlyOwner {
		(uint256 token1Iterations, uint256 token1Claims, uint256 token1LastProcessedIndex) = token1DividendTracker.process(gas);
		emit Processedtoken1DividendTracker(token1Iterations, token1Claims, token1LastProcessedIndex, false, gas, msg.sender);
 
		(uint256 token2Iterations, uint256 token2Claims, uint256 token2LastProcessedIndex) = token2DividendTracker.process(gas);
		emit Processedtoken2DividendTracker(token2Iterations, token2Claims, token2LastProcessedIndex, false, gas, msg.sender);
    }
 
    function claim() external {
		token1DividendTracker.processAccount(payable(msg.sender), false);
		token2DividendTracker.processAccount(payable(msg.sender), false);
    }
    
    function getLasttoken1DividendProcessedIndex() external view returns(uint256) {
    	return token1DividendTracker.getLastProcessedIndex();
    }
 
    function getLastTOKEN2C1DividendProcessedIndex() external view returns(uint256) {
    	return token2DividendTracker.getLastProcessedIndex();
    }
 
    function getNumberOftoken1DividendTokenHolders() external view returns(uint256) {
        return token1DividendTracker.getNumberOfTokenHolders();
    }
 
    function getNumberOfTOKEN2DividendTokenHolders() external view returns(uint256) {
        return token2DividendTracker.getNumberOfTokenHolders();
    }
    
 
 // A revoir totalement
    function _transfer( address from, address to, uint256 amount ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], "Blacklisted address"); //blacklist function

        uint256 fees = 0;           // wallet to wallet 0 tax
        uint256 burntaxamount = 0;  // wallet to wallet 0 tax

        if(to != owner() && to != address(this) && to != address(0x000000000000000000000000000000000000dEaD) && to != uniswapV2Pair && to != marketingWallet){
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= maxWalletAmount, "wallet amount exceed maxWalletAmount");
        }

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        
        if(automatedMarketMakerPairs[to] && (!_isExcludedFromMaxTx[from]) /*&& (!_isExcludedFromMaxTx[to])*/){  // sell limitation
            require(amount <= maxSellTransactionAmount, "Sell transfer amount exceeds the maxSellTransactionAmount.");
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if( automatedMarketMakerPairs[from]) {                            // buy tax applied if buy

            fees = amount.mul(_totalTaxIfBuying).div(100);  // total fee amount
            burntaxamount=amount.mul(_BurnFee).div(100); // burn amount aside
            fees=fees.sub(burntaxamount);                   // fee is total amount minus burn
        }
        else if( automatedMarketMakerPairs[to]) {                         // sell tax applied if sell
                
            fees = amount.mul(_totalTaxIfSelling).div(100); // total fee amount
            burntaxamount=amount.mul(_BurnFee).div(100);// burn amount aside
            fees=fees.sub(burntaxamount);                   // fee is total amount minus burn
        }

        // Function that tranform and send tax token collected at any transfer (buy sell transfer) and a minimum of token collected
        if (canSwap && !swapping /*&& !automatedMarketMakerPairs[from] && // only swap tax on sellsfrom != owner() && to != owner()*/) {
            
            swapping = true;
            uint SwapTax = _totalTaxIfSelling.sub(_BurnFee);
            
            uint256 initialBalance = address(this).balance;
            uint256 swapTokens = contractTokenBalance.div(SwapTax).mul(_sellMarketingFee);
            swapTokensForBNB(swapTokens);
            uint256 marketingPortion = address(this).balance.sub(initialBalance);
            address(marketingWallet).call{value: marketingPortion};
              
            uint256 liqTokens = contractTokenBalance.div(SwapTax).mul(_LiquidityFee);
            swapAndLiquify(liqTokens);
           
            uint256 token1Tokens = contractTokenBalance.div(SwapTax).mul(_selltoken1DividendRewardsFee);
            swapAndSendTOKEN1Dividends(token1Tokens);

            uint256 token2Tokens = contractTokenBalance.div(SwapTax).mul(_selltoken2DividendRewardsFee);
            swapAndSendTOKEN2Dividends(token2Tokens);
        
            swapping = false;
        }
 
        bool takeFee = !swapping;
 
        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to] || fees == 0) {takeFee = false;}

        if(takeFee) {
            super._burn(from,burntaxamount);    // burn amount 
            amount = amount.sub(fees);          // amount to send back 
            super._transfer(from, address(this), fees);
        }
 
        super._transfer(from, to, amount);
 
        try token1DividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try token2DividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try token1DividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}
        try token2DividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}
 
        if(!swapping) {
	    	uint256 gas = gasForProcessing;
 
	    	try token1DividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
	    		emit Processedtoken1DividendTracker(iterations, claims, lastProcessedIndex, true, gas, msg.sender);
	    	}
	    	catch {
 
	    	}
 
	    	try token2DividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
	    		emit Processedtoken2DividendTracker(iterations, claims, lastProcessedIndex, true, gas, msg.sender);
	    	}
	    	catch {
 
	    	}
        }
    }

    function swapAndLiquify(uint256 contractTokenBalance) private {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
 
        uint256 initialBalance = address(this).balance;
 
        swapTokensForBNB(half);
 
        uint256 newBalance = address(this).balance.sub(initialBalance);
 
        addLiquidity(otherHalf, newBalance);
 
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }
 
    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
 
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
 
        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            DeadWallet,
            block.timestamp
        );
    }
 
    function swapTokensForBNB(uint256 tokenAmount) private {
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
 
    function swapTokensForTOKEN1(uint256 _tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = address(TOKEN1);
 
        _approve(address(this), address(uniswapV2Router), _tokenAmount);
 
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _tokenAmount,
            0, // accept any amount of dividend token
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForTOKEN2(uint256 _tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = address(TOKEN2);
 
        _approve(address(this), address(uniswapV2Router), _tokenAmount);
 
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _tokenAmount,
            0, // accept any amount of dividend token
            path,
            address(this),
            block.timestamp
        );
    }

    function swapAndSendTOKEN2Dividends(uint256 tokens) private {
        swapTokensForTOKEN2(tokens);
        uint256 token2Tokens = IERC20(TOKEN2).balanceOf(address(this));
        transferDividends( address(token2DividendTracker), token2DividendTracker, token2Tokens, TOKEN2);
    }
 
  
    function swapAndSendTOKEN1Dividends(uint256 tokens) private {
        swapTokensForTOKEN1(tokens);
        uint256 token1tokens = IERC20(TOKEN1).balanceOf(address(this));
        transferDividends( address(token1DividendTracker), token1DividendTracker, token1tokens, TOKEN1);
    }
 
 
    function transferDividends(address dividendTracker, DividendPayingToken dividendPayingTracker, uint256 amount, IERC20 token) private {
        bool success = IERC20(token).transfer(dividendTracker, amount);
 
        if (success) {
            dividendPayingTracker.distributeDividends(amount);
            emit SendDividends(amount);
        }
    }
}

contract TOKEN2DividendTracker is DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;
 
    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;
 
    mapping (address => bool) public excludedFromDividends;
 
    mapping (address => uint256) public lastClaimTimes;
 
    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;
 
    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
 
    event Claim(address indexed account, uint256 amount, bool indexed automatic);
 
    constructor() DividendPayingToken("DRT_TOKEN2_Dividend_Tracker", "DRT_TOKEN2_Dividend_Tracker", 0x55d398326f99059fF775485246999027B3197955) {  //USDT
    	claimWait = 3600;
        minimumTokenBalanceForDividends = 10000 * (10**9); //must hold 10000+ tokens 0.01%
    }
 
    function _transfer(address, address, uint256) pure internal override {
        require(false, "DRT_TOKEN2_Dividend_Tracker: No transfers allowed");
    }
 
    function withdrawDividend() pure public override {
        require(false, "DRT_TOKEN2_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main DualRewardTest contract.");
    }
 
 
    function updateMinimumTokenBalanceForDividends(uint256 _newMinimumBalance) external onlyOwner {
        require(_newMinimumBalance != minimumTokenBalanceForDividends, "New mimimum balance for dividend cannot be same as current minimum balance");
        minimumTokenBalanceForDividends = _newMinimumBalance * (10**9);
    }
 
    function excludeFromDividends(address account) external onlyOwner {
    	require(!excludedFromDividends[account]);
    	excludedFromDividends[account] = true;
 
    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);
 
    	emit ExcludeFromDividends(account);
    }
 
    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "DRT_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "DRT_Dividend_Tracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }
 
    function getLastProcessedIndex() external view returns(uint256) {
    	return lastProcessedIndex;
    }
 
    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }
 
 
    function getAccount(address _account)
        public view returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable) {
        account = _account;
 
        index = tokenHoldersMap.getIndexOfKey(account);
 
        iterationsUntilProcessed = -1;
 
        if(index >= 0) {
            if(uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ?
                                                        tokenHoldersMap.keys.length.sub(lastProcessedIndex) :
                                                        0;
 
 
                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }
 
 
        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);
 
        lastClaimTime = lastClaimTimes[account];
 
        nextClaimTime = lastClaimTime > 0 ?
                                    lastClaimTime.add(claimWait) :
                                    0;
 
        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ?
                                                    nextClaimTime.sub(block.timestamp) :
                                                    0;
    }
 
    function getAccountAtIndex(uint256 index)
        public view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	if(index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);
        }
 
        address account = tokenHoldersMap.getKeyAtIndex(index);
 
        return getAccount(account);
    }
 
    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
    	if(lastClaimTime > block.timestamp)  {
    		return false;
    	}
 
    	return block.timestamp.sub(lastClaimTime) >= claimWait;
    }
 
    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
    	if(excludedFromDividends[account]) {
    		return;
    	}
 
    	if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
    		tokenHoldersMap.set(account, newBalance);
    	}
    	else {
            _setBalance(account, 0);
    		tokenHoldersMap.remove(account);
    	}
 
    	processAccount(account, true);
    }
 
    function process(uint256 gas) public returns (uint256, uint256, uint256) {
    	uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;
 
    	if(numberOfTokenHolders == 0) {
    		return (0, 0, lastProcessedIndex);
    	}
 
    	uint256 _lastProcessedIndex = lastProcessedIndex;
 
    	uint256 gasUsed = 0;
 
    	uint256 gasLeft = gasleft();
 
    	uint256 iterations = 0;
    	uint256 claims = 0;
 
    	while(gasUsed < gas && iterations < numberOfTokenHolders) {
    		_lastProcessedIndex++;
 
    		if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {
    			_lastProcessedIndex = 0;
    		}
 
    		address account = tokenHoldersMap.keys[_lastProcessedIndex];
 
    		if(canAutoClaim(lastClaimTimes[account])) {
    			if(processAccount(payable(account), true)) {
    				claims++;
    			}
    		}
 
    		iterations++;
 
    		uint256 newGasLeft = gasleft();
 
    		if(gasLeft > newGasLeft) {
    			gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
    		}
 
    		gasLeft = newGasLeft;
    	}
 
    	lastProcessedIndex = _lastProcessedIndex;
 
    	return (iterations, claims, lastProcessedIndex);
    }
 
    function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);
 
    	if(amount > 0) {
    		lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
    		return true;
    	}
 
    	return false;
    }
}
 
contract TOKEN1DividendTracker is DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;
 
    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;
 
    mapping (address => bool) public excludedFromDividends;
 
    mapping (address => uint256) public lastClaimTimes;
 
    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;
 
    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
 
    event Claim(address indexed account, uint256 amount, bool indexed automatic);
 
    constructor() DividendPayingToken("DRT_TOKEN1_Dividend_Tracker", "DRT_TOKEN1_Dividend_Tracker", 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56) {  //BUSD
    	claimWait = 3600;
        minimumTokenBalanceForDividends = 10000 * (10**9); //must hold 10000+ tokens 0.01%
    }
 
    function _transfer(address, address, uint256) pure internal override {
        require(false, "DRT_TOKEN1_Dividend_Tracker: No transfers allowed");
    }
 
    function withdrawDividend() pure public override {
        require(false, "DRT_TOKEN1_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main DualRewardTest contract.");
    }


 
    function updateMinimumTokenBalanceForDividends(uint256 _newMinimumBalance) external onlyOwner {
        require(_newMinimumBalance != minimumTokenBalanceForDividends, "New mimimum balance for dividend cannot be same as current minimum balance");
        minimumTokenBalanceForDividends = _newMinimumBalance * (10*9);
    }
 
    function excludeFromDividends(address account) external onlyOwner {
    	require(!excludedFromDividends[account]);
    	excludedFromDividends[account] = true;
 
    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);
 
    	emit ExcludeFromDividends(account);
    }
 
    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "DRT_TOKEN1_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "DRT_TOKEN1_Dividend_Tracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }
 
    function getLastProcessedIndex() external view returns(uint256) {
    	return lastProcessedIndex;
    }
 
    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }
 
 
    function getAccount(address _account)
        public view returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable) {
        account = _account;
 
        index = tokenHoldersMap.getIndexOfKey(account);
 
        iterationsUntilProcessed = -1;
 
        if(index >= 0) {
            if(uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ?
                                                        tokenHoldersMap.keys.length.sub(lastProcessedIndex) :
                                                        0;
 
 
                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }
 
 
        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);
 
        lastClaimTime = lastClaimTimes[account];
 
        nextClaimTime = lastClaimTime > 0 ?
                                    lastClaimTime.add(claimWait) :
                                    0;
 
        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ?
                                                    nextClaimTime.sub(block.timestamp) :
                                                    0;
    }
 
    function getAccountAtIndex(uint256 index)
        public view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	if(index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);
        }
 
        address account = tokenHoldersMap.getKeyAtIndex(index);
 
        return getAccount(account);
    }
 
    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
    	if(lastClaimTime > block.timestamp)  {
    		return false;
    	}
 
    	return block.timestamp.sub(lastClaimTime) >= claimWait;
    }
 
    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
    	if(excludedFromDividends[account]) {
    		return;
    	}
 
    	if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
    		tokenHoldersMap.set(account, newBalance);
    	}
    	else {
            _setBalance(account, 0);
    		tokenHoldersMap.remove(account);
    	}
 
    	processAccount(account, true);
    }
 
    function process(uint256 gas) public returns (uint256, uint256, uint256) {
    	uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;
 
    	if(numberOfTokenHolders == 0) {
    		return (0, 0, lastProcessedIndex);
    	}
 
    	uint256 _lastProcessedIndex = lastProcessedIndex;
 
    	uint256 gasUsed = 0;
 
    	uint256 gasLeft = gasleft();
 
    	uint256 iterations = 0;
    	uint256 claims = 0;
 
    	while(gasUsed < gas && iterations < numberOfTokenHolders) {
    		_lastProcessedIndex++;
 
    		if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {
    			_lastProcessedIndex = 0;
    		}
 
    		address account = tokenHoldersMap.keys[_lastProcessedIndex];
 
    		if(canAutoClaim(lastClaimTimes[account])) {
    			if(processAccount(payable(account), true)) {
    				claims++;
    			}
    		}
 
    		iterations++;
 
    		uint256 newGasLeft = gasleft();
 
    		if(gasLeft > newGasLeft) {
    			gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
    		}
 
    		gasLeft = newGasLeft;
    	}
 
    	lastProcessedIndex = _lastProcessedIndex;
 
    	return (iterations, claims, lastProcessedIndex);
    }
 
    function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);
 
    	if(amount > 0) {
    		lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
    		return true;
    	}
 
    	return false;
    }
}