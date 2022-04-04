pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

import "./DividendPayingToken.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";

contract VATORMASK is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    address public charityAddress;
    address public treasuryAddress;
    address public marketingAddress;
    address public creatorAddress;
    address public lpTokenRecipient;

    bool private swapping;
    bool public tradingIsEnabled = false;

    VatormaskDividendTracker public dividendTracker;

    uint256 public maxSellAmount = 1e31; // 0.1 % of total supply
    uint256 public maxBuyAmount = 1e31; // 0.1 % of total supply
    uint256 public swapTokensAtAmount = 1e23;
    
    // @Dev buy tax
    uint256 public buyTaxFee = 2e3;
    uint256 public buyLiquidityFee = 2e3;
    uint256 public buyCharityFee = 5e2;
    uint256 public buyTreasuryFee = 5e2;
    uint256 public buyMarketingFee = 1e3;
    uint256 public buyCreatorFee = 2e3;
    uint256 public buyBurnFee = 2e3;

    // @Dev sell tax
    uint256 public sellTaxFee = 2e3;
    uint256 public sellLiquidityFee = 2e3;
    uint256 public sellCharityFee = 5e2;
    uint256 public sellTreasuryFee = 5e2;
    uint256 public sellMarketingFee = 1e3;
    uint256 public sellCreatorFee = 2e3;
    uint256 public sellBurnFee = 2e3;
    
    uint256 public taxFeeTotal;
    uint256 public liquidityFeeTotal;
    uint256 public charityFeeTotal;
    uint256 public treasuryFeeTotal;
    uint256 public marketingFeeTotal;
    uint256 public creatorFeeTotal;
    uint256 public burnFeeTotal;

    uint256 private _taxFeeTotal;
    uint256 private _liquidityFeeTotal;
    uint256 private _charityFeeTotal;
    uint256 private _treasuryFeeTotal;
    uint256 private _marketingFeeTotal;
    uint256 private _creatorFeeTotal;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;

    // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;

    // blacklist bots
    mapping (address => bool) private isBlacklisted;

    // addresses that can make transfers before presale is over
    mapping (address => bool) private canTransferBeforeTradingIsEnabled;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event lpTokenRecipientUpdated(address indexed newlpTokenRecipient, address indexed oldlpTokenRecipient);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
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

    constructor(address charity_, address treasury_, address marketing_, address creator_) ERC20("VATORMASK", "VATOR") {
        
        charityAddress = charity_;
        treasuryAddress = treasury_;
        marketingAddress = marketing_;
        creatorAddress = creator_;

    	dividendTracker = new VatormaskDividendTracker();

    	lpTokenRecipient = owner();
        
    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
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

        // exclude from paying fees or having max transaction amount
        excludeFromFees(lpTokenRecipient, true);
        excludeFromFees(address(this), true);

        // enable owner and fixed-sale wallet to send tokens before presales are over
        canTransferBeforeTradingIsEnabled[owner()] = true;

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), 1e33);
    }

    receive() external payable {

  	}

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "VATOR: The dividend tracker already has that address");

        VatormaskDividendTracker newDividendTracker = VatormaskDividendTracker(payable(newAddress));

        require(newDividendTracker.owner() == address(this), "VATOR: The new dividend tracker must be owned by the VATOR token contract");

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }

    function updateWallets(address charity_, address treasury_, address marketing_, address creator_) public onlyOwner {
        charityAddress = charity_;
        treasuryAddress = treasury_;
        marketingAddress = marketing_;
        creatorAddress = creator_;
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "VATOR: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "VATOR: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "VATOR: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "VATOR: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }
    
    function addOnBlackList(address botAddress) public onlyOwner {
        require(isContract(botAddress), "VATOR: You can blacklit only bot not an user..");
        isBlacklisted[botAddress] = true;
    }
    
    function removeFromBlackList(address address_) public onlyOwner {
        isBlacklisted[address_] = false;
    }
    
    function isContract(address address_) private view returns (bool) {
        uint size;
        assembly { size := extcodesize(address_) }
        return size > 0;
    }

    function updatelpTokenRecipient(address newlpTokenRecipient) public onlyOwner {
        require(newlpTokenRecipient != lpTokenRecipient, "VATOR: The liquidity wallet is already this address");
        excludeFromFees(newlpTokenRecipient, true);
        emit lpTokenRecipientUpdated(newlpTokenRecipient, lpTokenRecipient);
        lpTokenRecipient = newlpTokenRecipient;
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "VATOR: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "VATOR: Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateMaxSellBuyAmount(uint256 maxBuy, uint256 maxSell) public onlyOwner {
        require(maxBuy >= totalSupply().mul(1e5).div(1e2) && maxSell >= totalSupply().mul(1e5).div(1e2), "VATOR: You cannot set less than 0.001% of totalSupply..");
        maxBuyAmount = maxBuy;
        maxSellAmount = maxSell;
    }

    function updateSwapTokensAtAmount(uint256 amount) public onlyOwner {
        swapTokensAtAmount = amount;
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

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "VATOR: transfer from the zero address");
        require(to != address(0), "VATOR: transfer to the zero address");
        require(!isBlacklisted[from] || !isBlacklisted[to] || isBlacklisted[msg.sender], "VATOR: No permission to trade using a bot.");

        uint256 halfBalanceOfFrom = balanceOf(from).div(2);
        
        if(!tradingIsEnabled) {
            require(canTransferBeforeTradingIsEnabled[from], "VATOR: This account cannot send tokens until trading is enabled");
        }

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if( 
        	!swapping &&
        	tradingIsEnabled &&
            automatedMarketMakerPairs[to] && // sells only by detecting transfer to automated market maker pair
        	from != address(uniswapV2Router) && //router -> pair is removing liquidity which shouldn't have max
            !_isExcludedFromFees[to] //no max for those excluded from fees
        ) {
            require(amount <= maxSellAmount, "Sell transfer amount exceeds the maxSellAmount.");
        }

        if( 
        	!swapping &&
        	tradingIsEnabled &&
            automatedMarketMakerPairs[from] && // buy only by detecting transfer to automated market maker pair
        	from != address(uniswapV2Router) && //router -> pair is adding liquidity which shouldn't have max
            !_isExcludedFromFees[from] //no max for those excluded from fees
        ) {
            require(amount <= maxBuyAmount, "buy transfer amount exceeds the maxBuyAmount.");
        }

		uint256 contractTokenBalance = balanceOf(address(this));
        
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if(
            tradingIsEnabled && 
            canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            from != lpTokenRecipient &&
            to != lpTokenRecipient
        ) {
            swapping = true;
        	
            swapAndSendDividends(_taxFeeTotal);
            swapAndLiquify(_liquidityFeeTotal);
            swapTokensForEth(charityAddress, _charityFeeTotal);
            swapTokensForEth(treasuryAddress, _treasuryFeeTotal);
            swapTokensForEth(marketingAddress, _marketingFeeTotal);
            swapTokensForEth(creatorAddress, _creatorFeeTotal);
            
            _taxFeeTotal = 0;
            _liquidityFeeTotal = 0;
            _charityFeeTotal = 0;
            _treasuryFeeTotal = 0;
            _marketingFeeTotal = 0;
            _creatorFeeTotal = 0;

            swapping = false;
        }


        bool takeFee = tradingIsEnabled && !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {
            
            uint256 transferAmount = amount;

            if (automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to]) {
                transferAmount = collectFeeOnBuy(from, amount);
            }

            if (automatedMarketMakerPairs[to] && !automatedMarketMakerPairs[from]) {
                if (amount <= halfBalanceOfFrom) {
                    transferAmount = collectFeeOnSell(from, amount);
                }

                if (amount > halfBalanceOfFrom) {
                    transferAmount = collect_2X_FeeOnSell(from, amount);
                }
            }

            amount = transferAmount;
        }

        super._transfer(from, to, amount);

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!swapping) {
	    	uint256 gas = gasForProcessing;

	    	try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
	    		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
	    	} 
	    	catch {

	    	}
        }
    }
    
    function collectFeeOnBuy(address account, uint256 amount) private returns (uint256) {
        uint256 transferAmount = amount;
        
        //@dev Take buy tax fee
        if(buyTaxFee != 0) {
            uint256 Fee = amount.mul(buyTaxFee).div(1e5);
            transferAmount = transferAmount.sub(Fee);
            _taxFeeTotal = _taxFeeTotal.add(Fee);
            taxFeeTotal = taxFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take buy liquidity fee
        if(buyLiquidityFee != 0) {
            uint256 Fee = amount.mul(buyLiquidityFee).div(1e5);
            transferAmount = transferAmount.sub(Fee);
            _liquidityFeeTotal = _liquidityFeeTotal.add(Fee);
            liquidityFeeTotal = liquidityFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take buy marketing fee
        if(buyCharityFee != 0) {
            uint256 Fee = amount.mul(buyCharityFee).div(1e5);
            transferAmount = transferAmount.sub(Fee);
            _marketingFeeTotal = _marketingFeeTotal.add(Fee);
            marketingFeeTotal = marketingFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take buy treasury fee
        if(buyTreasuryFee != 0) {
            uint256 Fee = amount.mul(buyTreasuryFee).div(1e5);
            transferAmount = transferAmount.sub(Fee);
            _treasuryFeeTotal = _treasuryFeeTotal.add(Fee);
            treasuryFeeTotal = treasuryFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take buy marketing fee
        if(buyMarketingFee != 0) {
            uint256 Fee = amount.mul(buyMarketingFee).div(1e5);
            transferAmount = transferAmount.sub(Fee);
            _marketingFeeTotal = _marketingFeeTotal.add(Fee);
            marketingFeeTotal = marketingFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take buy creator fee
        if(buyCreatorFee != 0) {
            uint256 Fee = amount.mul(buyCreatorFee).div(1e5);
            transferAmount = transferAmount.sub(Fee);
            _creatorFeeTotal = _creatorFeeTotal.add(Fee);
            creatorFeeTotal = creatorFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take buy burn fee
        if(buyBurnFee != 0) {
            uint256 Fee = amount.mul(buyBurnFee).div(1e5);
            transferAmount = transferAmount.sub(Fee);
            burnFeeTotal = burnFeeTotal.add(Fee);
            super._burn(account, Fee);
        }
        
        return transferAmount;
    }
    
    function collectFeeOnSell(address account, uint256 amount) private returns (uint256) {
        uint256 transferAmount = amount;
        
        //@dev Take sell tax fee
        if(sellTaxFee != 0) {
            uint256 Fee = amount.mul(sellTaxFee).div(1e5);
            transferAmount = transferAmount.sub(Fee);
            _taxFeeTotal = _taxFeeTotal.add(Fee);
            taxFeeTotal = taxFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take sell liquidity fee
        if(sellLiquidityFee != 0) {
            uint256 Fee = amount.mul(sellLiquidityFee).div(1e5);
            transferAmount = transferAmount.sub(Fee);
            _liquidityFeeTotal = _liquidityFeeTotal.add(Fee);
            liquidityFeeTotal = liquidityFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take sell charity fee
        if(sellCharityFee != 0) {
            uint256 Fee = amount.mul(sellCharityFee).div(1e5);
            transferAmount = transferAmount.sub(Fee);
            _charityFeeTotal = _charityFeeTotal.add(Fee);
            charityFeeTotal = charityFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take sell treasury fee
        if(sellTreasuryFee != 0) {
            uint256 Fee = amount.mul(sellTreasuryFee).div(1e5);
            transferAmount = transferAmount.sub(Fee);
            _treasuryFeeTotal = _treasuryFeeTotal.add(Fee);
            treasuryFeeTotal = treasuryFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take sell marketing fee
        if(sellMarketingFee != 0) {
            uint256 Fee = amount.mul(sellMarketingFee).div(1e5);
            transferAmount = transferAmount.sub(Fee);
            _marketingFeeTotal = _marketingFeeTotal.add(Fee);
            marketingFeeTotal = marketingFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take sell creator fee
        if(sellCreatorFee != 0) {
            uint256 Fee = amount.mul(sellCreatorFee).div(1e5);
            transferAmount = transferAmount.sub(Fee);
            _creatorFeeTotal = _creatorFeeTotal.add(Fee);
            creatorFeeTotal = creatorFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take sell burn fee
        if(sellBurnFee != 0) {
            uint256 Fee = amount.mul(sellBurnFee).div(1e5);
            transferAmount = transferAmount.sub(Fee);
            burnFeeTotal = burnFeeTotal.add(Fee);
            super._burn(account, Fee);
        }
        
        return transferAmount;
    }
    
    function collect_2X_FeeOnSell(address account, uint256 amount) private returns (uint256) {
        uint256 transferAmount = amount;
        
        //@dev Take sell tax fee
        if(sellTaxFee != 0) {
            uint256 Fee = amount.mul(sellTaxFee.mul(2)).div(1e5);
            transferAmount = transferAmount.sub(Fee);
            _taxFeeTotal = _taxFeeTotal.add(Fee);
            taxFeeTotal = taxFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take sell liquidity fee
        if(sellLiquidityFee != 0) {
            uint256 Fee = amount.mul(sellLiquidityFee.mul(2)).div(1e5);
            transferAmount = transferAmount.sub(Fee);
            _liquidityFeeTotal = _liquidityFeeTotal.add(Fee);
            liquidityFeeTotal = liquidityFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take sell charity fee
        if(sellCharityFee != 0) {
            uint256 Fee = amount.mul(sellCharityFee.mul(2)).div(1e5);
            transferAmount = transferAmount.sub(Fee);
            _charityFeeTotal = _charityFeeTotal.add(Fee);
            charityFeeTotal = charityFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take sell treasury fee
        if(sellTreasuryFee != 0) {
            uint256 Fee = amount.mul(sellTreasuryFee.mul(2)).div(1e5);
            transferAmount = transferAmount.sub(Fee);
            _treasuryFeeTotal = _treasuryFeeTotal.add(Fee);
            treasuryFeeTotal = treasuryFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take sell marketing fee
        if(sellMarketingFee != 0) {
            uint256 Fee = amount.mul(sellMarketingFee.mul(2)).div(1e5);
            transferAmount = transferAmount.sub(Fee);
            _marketingFeeTotal = _marketingFeeTotal.add(Fee);
            marketingFeeTotal = marketingFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take sell creator fee
        if(sellCreatorFee != 0) {
            uint256 Fee = amount.mul(sellCreatorFee.mul(2)).div(1e5);
            transferAmount = transferAmount.sub(Fee);
            _creatorFeeTotal = _creatorFeeTotal.add(Fee);
            creatorFeeTotal = creatorFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take sell burn fee
        if(sellBurnFee != 0) {
            uint256 Fee = amount.mul(sellBurnFee.mul(2)).div(1e5);
            transferAmount = transferAmount.sub(Fee);
            burnFeeTotal = burnFeeTotal.add(Fee);
            super._burn(account, Fee);
        }
        
        return transferAmount;
    }

    // function to allow admin to enable trading..
    function enabledTrading() public onlyOwner {
        require(!tradingIsEnabled, "VATOR: Trading already enabled..");
        tradingIsEnabled = true;
    }

    function swapAndLiquify(uint256 tokens) private {
        // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(address(this), half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(address recipient, uint256 tokenAmount) private {

        
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
            recipient,
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
            lpTokenRecipient,
            block.timestamp
        );
        
    }

    function swapAndSendDividends(uint256 tokens) private {
        swapTokensForEth(address(this), tokens);
        uint256 dividends = address(this).balance;
        (bool success,) = address(dividendTracker).call{value: dividends}("");

        if(success) {
   	 		emit SendDividends(tokens, dividends);
        }
    }
}

contract VatormaskDividendTracker is DividendPayingToken, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping (address => bool) public excludedFromDividends;

    mapping (address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public immutable minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor() DividendPayingToken("Vatormask_Dividend_Tracker", "VMDT") {
    	claimWait = 3600;
        minimumTokenBalanceForDividends = 1; //must hold 1+ token
    }

    function _transfer(address, address, uint256) internal pure override {
        require(false, "VATOR_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public pure override {
        require(false, "VATOR_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main VATOR contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
    	require(!excludedFromDividends[account]);
    	excludedFromDividends[account] = true;

    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);

    	emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "VATOR_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "VATOR_Dividend_Tracker: Cannot update claimWait to same value");
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