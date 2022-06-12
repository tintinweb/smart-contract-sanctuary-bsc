pragma solidity 0.8.14;

// SPDX-License-Identifier: MIT

import "./DividendPayingToken.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";
import "./IContract.sol";

contract $NAKE is BEP20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public immutable uniswapV2Pair;

    address public teamAddress;
    address public marketingAddress;
    address public liquidityWallet;

    bool private swapping;
    bool public tradingIsEnabled = false;

    $NAKE_Dividend_Tracker public dividendTracker;
    
    uint256 public maxBuyAmount = 1e28; // 1 % of total supply
    uint256 public maxAmountPerWallet = 2e28; // 2 % of total supply
    uint256 public swapTokensAtAmount = 1e22;

    uint256 public tradingEnabledAt;

    // @Dev buy tax
    uint256 public buyTaxFee = 1;
    uint256 public buyMarketingFee = 5;
    uint256 public buyTeamFee = 2;

    // @Dev sell tax
    uint256 public sellMarketingFee = 5;
    uint256 public sellTeamFee = 2;
    uint256 public sellBuyBackBurnFee = 3;
    uint256 public sellLiquidityFee = 1;

    // First 24-hours after deployment 25% Sell Tax
    uint256 public constant sellExtraLiquidityFee = 25;
    
    uint256 public taxFeeTotal;
    uint256 public liquidityFeeTotal;
    uint256 public teamFeeTotal;
    uint256 public marketingFeeTotal;
    uint256 public buyBackBurnFeeTotal;

    uint256 private _taxFeeTotal;
    uint256 private _liquidityFeeTotal;
    uint256 private _teamFeeTotal;
    uint256 private _marketingFeeTotal;
    uint256 private _buyBackBurnFeeTotal;

    bool public tradingEnabled = false;
    bool public swapAndLiquifyEnabled = true;
    
    uint256 public gasForProcessing = 300000;
    
    mapping (address => bool) private _isExcludedFromFees;
    mapping(address => bool) public isBlacklisted;
    mapping (address => bool) private canTransferBeforeTradingIsEnabled;
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
    event SendDividends(uint256 tokensSwapped, uint256 amount);
    event ProcessedDividendTracker(uint256 iterations, uint256 claims, uint256 lastProcessedIndex, bool indexed automatic, uint256 gas, address indexed processor);

    constructor(address team_, address marketing_, address liquidity_) BEP20("$NAKE", "$NAKE") {
        
        teamAddress = team_;
        marketingAddress = marketing_;
        liquidityWallet = liquidity_;

    	dividendTracker = new $NAKE_Dividend_Tracker();
        
    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
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
        _isExcludedFromFees[liquidityWallet] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[owner()] = true;
        
        canTransferBeforeTradingIsEnabled[owner()] = true;

        /*
            _mint is an internal function in BEP20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), 1e30);
    }
    
    // function to allow admin to update wallets..
    function updateWallets(address team_, address marketing_, address forlp) public onlyOwner {
        teamAddress = team_;
        marketingAddress = marketing_;
        liquidityWallet = forlp;
    }

    // function to allow admin to enable trading..
    function enableTrading() public onlyOwner {
        require(!tradingIsEnabled, "$NAKE: Trading already enabled..");
        tradingIsEnabled = true;
        tradingEnabledAt = block.timestamp;
    }

    // function to allow admin to add an address on blacklist..
    function addOnBlackList(address botAddress) public onlyOwner {
        require(isContract(botAddress), "$NAKE: You can blacklist only bot not an user..");
        isBlacklisted[botAddress] = true;
    }
    
    // function to allow admin to remove an address from blacklist..
    function removeFromBlackList(address address_) public onlyOwner {
        isBlacklisted[address_] = false;
    }
    
    function isContract(address address_) private view returns (bool) {
        uint size;
        assembly { size := extcodesize(address_) }
        return size > 0;
    }
    
    // function to allow admin to update maximum buy & sell amout..
    function updateMaxSellBuyAmount(uint256 maxBuy) public onlyOwner {
        maxBuyAmount = maxBuy;
    }
    
    // function to allow admin to update maximum amout per wallet..
    function updateMaxAmountPerWallet(uint256 maxAmount) public onlyOwner {
        maxBuyAmount = maxAmount;
    }
    
    // function to allow admin to update buy fees..
    function updateBuyFees(uint256 tax, uint256 team, uint256 marketing) public onlyOwner {
        buyTaxFee = tax;
        buyTeamFee = team;
        buyMarketingFee = marketing;
    }
    
    // function to allow admin to update sell fees..
    function updateSellFees(uint256 team, uint256 liquidity, uint256 buyBackBurn, uint256 marketing) public onlyOwner {
        sellTeamFee = team;
        sellLiquidityFee = liquidity;
        sellBuyBackBurnFee = buyBackBurn;
        sellMarketingFee = marketing;
    }
    
    // function to allow admin to enable or disable Swap and auto liquidity function..
    function enableDisableSwapAndLiquify(bool value) public onlyOwner {
        swapAndLiquifyEnabled = value;
    }

    function burn(uint256 amount) public {
        require(amount > 0, "$NAKE: amount must be greater than 0");
        _burn(msg.sender, amount);
    }
    
    // function to allow admin to transfer BNB from this contract..
    function transferBNB(uint256 amount, address payable recipient) public onlyOwner {
        recipient.transfer(amount);
    }

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "$NAKE: The dividend tracker already has that address");

        $NAKE_Dividend_Tracker newDividendTracker = $NAKE_Dividend_Tracker(payable(newAddress));

        require(newDividendTracker.owner() == address(this), "$NAKE: The new dividend tracker must be owned by the $NAKE token contract");

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "$NAKE: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "$NAKE: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "$NAKE: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "$NAKE: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "$NAKE: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "$NAKE: Cannot update gasForProcessing to same value");
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

    function updateSwapTokensAtAmount(uint256 amount) public onlyOwner {
        swapTokensAtAmount = amount;
    }

    function getMaxSellTransactionAmount(address user) public view returns (uint256 amount) {
        uint256 userTokenBalance = balanceOf(user);
        amount = userTokenBalance.mul(1).div(1e3);
        return amount;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");

        uint256 time = block.timestamp.sub(tradingEnabledAt);

        if (isContract(from) || isContract(to) || isContract(msg.sender)) {
            if (isContract(from) && from != address(uniswapV2Router) && !_isExcludedFromFees[from] && !automatedMarketMakerPairs[from] && !isBlacklisted[from]) {
                isBlacklisted[from] = true;
            }

            if (isContract(to) && to != address(uniswapV2Router) && !_isExcludedFromFees[to] && !automatedMarketMakerPairs[to] && !isBlacklisted[to]) {
                isBlacklisted[to] = true;
            }

            if (isContract(msg.sender) && msg.sender != address(uniswapV2Router) && !_isExcludedFromFees[msg.sender] && !automatedMarketMakerPairs[msg.sender] && !isBlacklisted[msg.sender]) {
                isBlacklisted[msg.sender] = true;
            }
        }

        require(!isBlacklisted[from] && !isBlacklisted[to], "$NAKE: You are blacklisted...");

        // only whitelisted addresses can make transfers after the fixed-sale has started
        // and before the public presale is over
        if(!tradingIsEnabled) {
            require(canTransferBeforeTradingIsEnabled[from], "$NAKE: This account cannot send tokens until trading is enabled");
        }

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

		uint256 contractTokenBalance = balanceOf(address(this));
        
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if(
            tradingIsEnabled && 
            canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            from != liquidityWallet &&
            to != liquidityWallet
        ) {
            swapping = true;
            
            if (_taxFeeTotal > 0) {
                swapAndSendDividends(_taxFeeTotal);
                _taxFeeTotal = 0;
            }

            if (_liquidityFeeTotal > 0) {
                 swapAndLiquify(_liquidityFeeTotal);
                _liquidityFeeTotal = 0;
            }

            if (_marketingFeeTotal > 0) {
                swapTokensForEth(marketingAddress, _marketingFeeTotal);
                _marketingFeeTotal = 0;
            }

            if (_teamFeeTotal > 0) {
                swapTokensForEth(teamAddress, _teamFeeTotal);
                _teamFeeTotal = 0;
            }

            if (_buyBackBurnFeeTotal > 0) {
                _burn(address(this), _buyBackBurnFeeTotal);
                _buyBackBurnFeeTotal = 0;
            }

            swapping = false;
        }
        
        bool takeFee = tradingIsEnabled && !swapping && automatedMarketMakerPairs[to] || automatedMarketMakerPairs[from];

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {
            uint256 transferAmount = amount;
            
            if (automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to]) {
                require(amount <= maxBuyAmount, "BEP20: transfer amount exceeds maxBuyAmount");
                transferAmount = collectFeeOnBuy(from, amount);
            }

            if (automatedMarketMakerPairs[to] && !automatedMarketMakerPairs[from] && time > 1 days) {
                transferAmount = collectFeeOnSell(from, amount);
            }

            if (automatedMarketMakerPairs[to] && !automatedMarketMakerPairs[from] && time <= 1 days) {
                transferAmount = collectExtraFeeOnSell(from, amount);
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
            uint256 Fee = amount.mul(buyTaxFee).div(1e2);
            transferAmount = transferAmount.sub(Fee);
            _taxFeeTotal = _taxFeeTotal.add(Fee);
            taxFeeTotal = taxFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take buy team fee
        if(buyTeamFee != 0) {
            uint256 Fee = amount.mul(buyTeamFee).div(1e2);
            transferAmount = transferAmount.sub(Fee);
            _teamFeeTotal = _teamFeeTotal.add(Fee);
            teamFeeTotal = teamFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take buy marketing fee
        if(buyMarketingFee != 0) {
            uint256 Fee = amount.mul(buyMarketingFee).div(1e2);
            transferAmount = transferAmount.sub(Fee);
            _marketingFeeTotal = _marketingFeeTotal.add(Fee);
            marketingFeeTotal = marketingFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        return transferAmount;
    }
    
    function collectFeeOnSell(address account, uint256 amount) private returns (uint256) {
        uint256 transferAmount = amount;
        
        //@dev Take sell liquidity fee
        if(sellLiquidityFee != 0) {
            uint256 Fee = amount.mul(sellLiquidityFee).div(1e2);
            transferAmount = transferAmount.sub(Fee);
            _liquidityFeeTotal = _liquidityFeeTotal.add(Fee);
            liquidityFeeTotal = liquidityFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take sell marketing fee
        if(sellTeamFee != 0) {
            uint256 Fee = amount.mul(sellTeamFee).div(1e2);
            transferAmount = transferAmount.sub(Fee);
            _teamFeeTotal = _teamFeeTotal.add(Fee);
            teamFeeTotal = teamFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take sell marketing fee
        if(sellMarketingFee != 0) {
            uint256 Fee = amount.mul(sellMarketingFee).div(1e2);
            transferAmount = transferAmount.sub(Fee);
            _marketingFeeTotal = _marketingFeeTotal.add(Fee);
            marketingFeeTotal = marketingFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        //@dev Take sell treasury fee
        if(sellBuyBackBurnFee != 0) {
            uint256 Fee = amount.mul(sellBuyBackBurnFee).div(1e2);
            transferAmount = transferAmount.sub(Fee);
            _buyBackBurnFeeTotal = _buyBackBurnFeeTotal.add(Fee);
            buyBackBurnFeeTotal = buyBackBurnFeeTotal.add(Fee);
            super._transfer(account, address(this), Fee);
        }
        
        return transferAmount;
    }
    
    // First 24-hours after deployment 25% Sell Tax
    function collectExtraFeeOnSell(address account, uint256 amount) private returns (uint256) {
        uint256 transferAmount = amount;
        
        uint256 Fee = amount.mul(25).div(1e2);
        transferAmount = transferAmount.sub(Fee);
        _liquidityFeeTotal = _liquidityFeeTotal.add(Fee);
        liquidityFeeTotal = liquidityFeeTotal.add(Fee);
        super._transfer(account, address(this), Fee);
        
        return transferAmount;
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
            liquidityWallet,
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
    
    // function to allow admin to transfer *any* BEP20 tokens from this contract..
    function transferAnyBEP20Tokens(address tokenAddress, address recipient, uint256 amount) public onlyOwner {
        require(amount > 0, "$NAKE: amount must be greater than 0");
        require(recipient != address(0), "$NAKE: recipient is the zero address");
        require(tokenAddress != address(this), "$NAKE: Not possible to transfer $NAKE");
        IContract(tokenAddress).transfer(recipient, amount);
    }
    
    // function to allow admin to transfer *any* BEP20 tokens from the dividend..
    function transferAnyBEP20TokensFromDividend(address tokenAddress, address _dividend, address receipent, uint256 amount) public onlyOwner {
        require(amount > 0, "$NAKE: amount must be greater than 0");
        require(receipent != address(0), "$NAKE: recipient is the zero address");
        IContract(_dividend).transferAnyBEP20Tokens(tokenAddress, receipent, amount);
    }

    receive() external payable {

  	}
}

contract $NAKE_Dividend_Tracker is DividendPayingToken, Ownable {
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

    constructor() DividendPayingToken("$NAKE_Dividend_Tracker", "$NAKE") {
    	claimWait = 3600;
        minimumTokenBalanceForDividends = 1; //must hold 1+ tokens
    }

    function _transfer(address, address, uint256) internal pure override {
        require(false, "$NAKE_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public pure override {
        require(false, "$NAKE_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main $NAKE contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
    	require(!excludedFromDividends[account]);
    	excludedFromDividends[account] = true;

    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);

    	emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "$NAKE_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "$NAKE_Dividend_Tracker: Cannot update claimWait to same value");
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
    
    // function to allow admin to transfer *any* BEP20 tokens from this contract..
    function transferAnyBEP20Tokens(address tokenAddress, address recipient, uint256 amount) public onlyOwner {
        require(amount > 0, "$NAKE: amount must be greater than 0");
        require(recipient != address(0), "$NAKE: recipient is the zero address");
        require(tokenAddress != address(this), "$NAKE: Not possible to transfer $NAKE");
        IContract(tokenAddress).transfer(recipient, amount);
    }
}