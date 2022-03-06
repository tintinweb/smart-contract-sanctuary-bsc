// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

import "./ERC20.sol";
import "./SafeMath.sol";
import "./SignedSafeMath.sol";
import "./SafeCast.sol";
import "./SafeToken.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
import "./MoonWalkersDividendTracker.sol";
import "./Ownable.sol";

contract MoonWalkers is ERC20, Ownable, SafeToken {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public immutable uniswapV2Pair;


    bool private inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    uint256 private nextTxSendDividends = 0;

    MoonWalkersDividendTracker public dividendTracker;

    uint256 public maxSellTransactionAmount = 100000000 * (10**9); // max sell 1% of supply
    uint256 public maxWalletAmount = 600000000 * (10**9); // max wallet amount 6%
    uint256 public swapTokensAtAmount = 2000000 * (10**9); //Max 0.02% of Supply
    
    address payable public  MarketingWallet;
    address payable public  DeadWallet;

    mapping(address => bool) public _isBlacklisted; //blacklist function

    uint256 public _liquidityShare = 25;
    uint256 public _marketingShare = 25;
    uint256 public _rewardsShare = 50;

    uint256 public _buyLiquidityFee = 1;
    uint256 public _buyMarketingFee = 4;
    uint256 public _buyRewardsFee = 6;
    uint256 public _buyBurnFee = 1;
    
    uint256 public _sellLiquidityFee = 1;
    uint256 public _sellMarketingFee = 6;
    uint256 public _sellRewardsFee = 9;
    uint256 public _sellBurnFee = 1;

    uint256 public _totalTaxIfBuying = 0;
    uint256 public _totalTaxIfSelling = 0;
    uint256 public _totalDistributionShares = 100;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 600000;

    // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isExcludedFromMaxTx;
    mapping(address => bool) public isMarketPair;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event SwapAndLiquifyEnabledUpdated(bool enabled);

    event SwapAndLiquify(
        uint256 tokensIntoLiqudity,
        uint256 ethReceived
    );

    event SendDividends(
    	uint256 tokensSwapped,
    	uint256 amount
    );

    event ProcessedDividendTracker(
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas,
    	address indexed processor
    );

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }


    function setMaxWallet(uint256 _maxWalletAmount) public onlyOwner {
        maxWalletAmount = _maxWalletAmount;
    }
    
    function setMarketingWallet(address payable _newMarketingWallet) public onlyOwner {
        MarketingWallet = _newMarketingWallet;
    }

     
    event rewardsGetBnb(uint256 amount);
    event marketingGetBnb(uint256 amount);
    event liquidityGetBnb(uint256 amount);


    constructor() ERC20("Moon Walkers", "MoonWalk") {
        MarketingWallet = payable(0x4aAB4ED440A8406eC15C140e3627dfc7701B9D0F); 
        DeadWallet = payable(0x000000000000000000000000000000000000dEaD);

        _totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee).add(_buyRewardsFee).add(_buyBurnFee); //12%
        
		_totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee).add(_sellRewardsFee).add(_sellBurnFee);//17%
        
		_totalDistributionShares = _liquidityShare.add(_marketingShare).add(_rewardsShare);
        

    	dividendTracker = new MoonWalkersDividendTracker();
        //
        //P 0x10ED43C718714eb63d5aA57B78B54704E256024E
        //T 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
	    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // **

        // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));
        dividendTracker.excludeFromDividends(0x000000000000000000000000000000000000dEaD);

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(MarketingWallet, true);
        excludeFromFees(address(this), true);
        
        // exclude from max tx
        _isExcludedFromMaxTx[owner()] = true;
        _isExcludedFromMaxTx[address(this)] = true;
        _isExcludedFromMaxTx[MarketingWallet] = true;

        isMarketPair[address(_uniswapV2Pair)] = true;
        

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), 10000000000 * (10**9));   
        }

    receive() external payable {

  	}



    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "MoonWalkers: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "MoonWalkers: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }
    
    function setExcludeFromMaxTx(address _address, bool value) public onlyOwner { 
        _isExcludedFromMaxTx[_address] = value;
    }

    function setExcludeFromAll(address _address) public onlyOwner {
        _isExcludedFromMaxTx[_address] = true;
        _isExcludedFromFees[_address] = true;
        dividendTracker.excludeFromDividends(_address);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "MoonWalkers: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }
     
    function setSWapToensAtAmount(uint256 _newAmount) public onlyOwner {
        //require(_newAmount <= 1000000000 * (10**18), "MoonWalkers: Swap Amount is limited to 0.1% of Supply");
        swapTokensAtAmount = _newAmount;
    }
    
    function blacklistAddress(address account, bool value) external onlyOwner { //blacklist function
    _isBlacklisted[account] = value;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "MoonWalkers: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 1000000, "MoonWalkers: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "MoonWalkers: Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns(uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }
    
    function isExcludedFromMaxTx(address account) public view returns(bool) {
        return _isExcludedFromMaxTx[account];
    }

    function withdrawableDividendOf(address account) public view returns(uint256) {
    	return dividendTracker.withdrawableDividendOf(account);
  	}

	function dividendTokenBalanceOf(address account) public view returns (uint256) {
		return dividendTracker.balanceOf(account);
	}

    function getAccountDividendsInfo(address account)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccount(account);
    }

	function getAccountDividendsInfoAtIndex(uint256 index)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	return dividendTracker.getAccountAtIndex(index);
    }

	function processDividendTracker(uint256 gas) external {
		(uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }

    function claim() external {
		dividendTracker.processAccount(payable(msg.sender), false);
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    //this will be used to exclude from dividends the presale smart contract address
    function excludeFromDividends(address account) external onlyOwner {
        dividendTracker.excludeFromDividends(account);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

     function setBuyTaxes(uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newRewardsTax, uint256 newBurnTax) external onlyOwner() {
         require(newLiquidityTax.add(newMarketingTax).add(newRewardsTax).add(newBurnTax) <= 18, "Tax exceeds the 18%.");
		 
        _buyLiquidityFee = newLiquidityTax;
        _buyMarketingFee = newMarketingTax;
        _buyRewardsFee = newRewardsTax;
        _buyBurnFee=newBurnTax;

        _totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee).add(_buyRewardsFee).add(_buyBurnFee);
    }

    function setSellTaxes(uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newRewardsTax, uint256 newBurnTax) external onlyOwner() {
        require(newLiquidityTax.add(newMarketingTax).add(newRewardsTax).add(newBurnTax) <= 25, "Tax exceeds the 25%.");
		
        _sellLiquidityFee = newLiquidityTax;
        _sellMarketingFee = newMarketingTax;
        _sellRewardsFee = newRewardsTax;
        _sellBurnFee = newBurnTax;

        _totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee).add(_sellRewardsFee).add(_sellBurnFee);
    }
    
    function setDistributionSettings(uint256 newLiquidityShare, uint256 newMarketingShare, uint256 newRewardsShare) external onlyOwner() {
		require(_liquidityShare.add(_marketingShare).add(_rewardsShare) == 100, "Total distribution must be 100%.");
		
		require(_rewardsShare >= 35, "Reward distribution must be at least 35%.");
        _liquidityShare = newLiquidityShare;
        _marketingShare = newMarketingShare;
        _rewardsShare = newRewardsShare;

        _totalDistributionShares = _liquidityShare.add(_marketingShare).add(_rewardsShare);
    }


    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = 0;

        uint256 burntaxamount = 0;
  
        
        if(isMarketPair[sender]) {
            feeAmount = amount.mul(_totalTaxIfBuying).div(100);
            burntaxamount=amount.mul(_buyBurnFee).div(100);
        }
        else if(isMarketPair[recipient]) {
            feeAmount = amount.mul(_totalTaxIfSelling).div(100);
            burntaxamount=amount.mul(_sellBurnFee).div(100);
        }

        feeAmount=feeAmount.sub(burntaxamount);
    
        //super._transfer(sender);
        super._burn(sender,burntaxamount);

        if(feeAmount > 0) {
            super._transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount).sub(burntaxamount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    )  internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], "Blacklisted address"); //blacklist function


       uint256 amountToSend = amount;

        

         if(to != owner() && to != address(this) && to != address(0x000000000000000000000000000000000000dEaD) && to != uniswapV2Pair && to != MarketingWallet){
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= maxWalletAmount, "wallet amount exceed maxWalletAmount");
        }

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        } 


        if(automatedMarketMakerPairs[to] && (!_isExcludedFromMaxTx[from]) && (!_isExcludedFromMaxTx[to])){
            require(amount <= maxSellTransactionAmount, "Sell transfer amount exceeds the maxSellTransactionAmount.");
        }
        

    	uint256 contractTokenBalance = balanceOf(address(this));
        
        bool overMinTokenBalance = contractTokenBalance >= swapTokensAtAmount;

        if(nextTxSendDividends >0){
            swapAndLiquifyDividends();
            nextTxSendDividends=0;
        }
       
        if(
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            !automatedMarketMakerPairs[from] && 
            swapAndLiquifyEnabled
        ) {
            swapAndLiquify(contractTokenBalance);
        }

        

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
        	amountToSend = takeFee(from, to, amount);
        }

        super._transfer(from, to, amountToSend);

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!inSwapAndLiquify) {
	    	uint256 gas = gasForProcessing;

	    	try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
	    		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
	    	} 
	    	catch {

	    	}
        }
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {

        uint256 tokensForLP = contractTokenBalance.mul(_liquidityShare).div(_totalDistributionShares).div(2);
        uint256 tokensForSwap = contractTokenBalance.sub(tokensForLP);

        swapTokensForBnb(tokensForSwap, address(this));

        uint256 amountReceived = address(this).balance;

        uint256 totalBNBFee = _totalDistributionShares.sub(_liquidityShare.div(2));
        
        uint256 amountBNBLiquidity = amountReceived.mul(_liquidityShare).div(totalBNBFee).div(2);
        uint256 amountBNBRewards   = amountReceived.mul(_rewardsShare).div(totalBNBFee);
        uint256 amountBNBMarketing = amountReceived.sub(amountBNBLiquidity).sub(amountBNBRewards);
        
        uint256 totMarkRewardsLiquidity=amountBNBLiquidity.add(amountBNBRewards).add(amountBNBMarketing);


        emit rewardsGetBnb(amountBNBRewards);
        emit marketingGetBnb(amountBNBMarketing);
        emit liquidityGetBnb(amountBNBLiquidity);

        if(amountBNBMarketing > 0)
            MarketingWallet.transfer(amountBNBMarketing);
        

        if(amountBNBLiquidity > 0 && tokensForLP > 0)
            addLiquidity(tokensForLP, amountBNBLiquidity);
        
        nextTxSendDividends=tokensForSwap;
        emit SwapAndLiquify(tokensForLP, totMarkRewardsLiquidity);
    }


    function swapAndLiquifyDividends() private lockTheSwap {
        uint256 dividends = address(this).balance;
        (bool success,) = address(dividendTracker).call{value: dividends}("");

        if(success) {
			emit SendDividends(nextTxSendDividends, dividends);
        }
    
    }

    function swapTokensForBnb(uint256 tokenAmount, address _to) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        if(allowance(address(this), address(uniswapV2Router)) < tokenAmount) {
          _approve(address(this), address(uniswapV2Router), ~uint256(0));
        }

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            _to,
            block.timestamp
        );
        
    }


    function swapAndSendBNBToMarketing(uint256 tokenAmount) private {
        swapTokensForBnb(tokenAmount, MarketingWallet);
    }
    

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
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
}