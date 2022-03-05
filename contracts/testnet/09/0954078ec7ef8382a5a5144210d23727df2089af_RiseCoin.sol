// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

import "./DividendPayingToken.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";
import "./IPancakeSwapV2Pair.sol";
import "./IPancakeSwapV2Factory.sol";
import "./IPancakeSwapV2Router.sol";

contract RiseCoin is BEP20, Ownable {
    using SafeMath for uint256;

    IPancakeSwapV2Router02 public pancakeSwapV2Router;
    address public  pancakeSwapV2Pair;

    bool private swapping;
	 bool public swapAndLiquifyEnabled = true;

    RSEDividendTracker public dividendTracker;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public BUSD = address(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);
	
    uint256 public swapTokensAtAmount = 1000000 * (10**18);
	uint256 public maxTxAmount = 100000000000 * (10**18);
	uint256 public maxWalletAmount = 100000000000 * (10**18);
	
	uint256[] public BUSDRewardsFee;
	uint256[] public buyBackFee;
	uint256[] public liquidityFee;
	
	uint256 private tokenToSwap;
	uint256 private tokenToLiquidity;
	uint256 private tokenToReward;
	uint256 private tokenToBuyBack;
	uint256 private tokenToLiquidityHalf;
	
	uint256 private BUSDRewardsFeeTotal;
	uint256 private liquidityFeeTotal;
	uint256 private buyBackFeeTotal;
	
	bool public tradingOpen = false;
	bool public buyBackEnabled = false;
	
	uint256 public autoBuybackBlockPeriod = 10;
	uint256 public autoBuybackBlockLast = block.number;
	uint256 public autoBuybackAmount = 5 * 10**17;
	
    uint256 public gasForProcessing = 300000;
	
    mapping (address => bool) private _isExcludedFromFees;
	mapping (address => bool) public isExcludedFromMaxWalletToken;
    mapping (address => bool) public automatedMarketMakerPairs;
	mapping (address => bool) public canTransferBeforeTradingIsEnabled;
	
	event BuyBackEnabledUpdated(bool enabled);
	event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);
    event UpdatePancakeSwapV2Router(address indexed newAddress, address indexed oldAddress);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event SendDividends(uint256 tokensSwapped, uint256 amount);
	event SwapBNBForTokens(uint256 amountIn,address[] path);
    event ProcessedDividendTracker(uint256 iterations, uint256 claims, uint256 lastProcessedIndex, bool indexed automatic, uint256 gas, address indexed processor);

    constructor() public BEP20("Rise Coin", "$RISEC") {

    	dividendTracker = new RSEDividendTracker();
		
    	IPancakeSwapV2Router02 _pancakeSwapV2Router = IPancakeSwapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        address _pancakeSwapV2Pair = IPancakeSwapV2Factory(_pancakeSwapV2Router.factory()).createPair(address(this), _pancakeSwapV2Router.WETH());

        pancakeSwapV2Router = _pancakeSwapV2Router;
        pancakeSwapV2Pair = _pancakeSwapV2Pair;

        _setAutomatedMarketMakerPair(_pancakeSwapV2Pair, true);

        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(deadWallet);
        dividendTracker.excludeFromDividends(address(_pancakeSwapV2Router));
		
		isExcludedFromMaxWalletToken[_pancakeSwapV2Pair] = true;
		isExcludedFromMaxWalletToken[address(this)] = true;
		isExcludedFromMaxWalletToken[owner()] = true;
		
		canTransferBeforeTradingIsEnabled[owner()] = true;

        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
		
		BUSDRewardsFee.push(800);
		BUSDRewardsFee.push(1600);
		BUSDRewardsFee.push(800);
		
		buyBackFee.push(200);
		buyBackFee.push(200);
		buyBackFee.push(200);
		
		liquidityFee.push(200);
		liquidityFee.push(200);
		liquidityFee.push(200);
		
        _mint(owner(), 100000000000 * (10**18));
    }

    receive() external payable {

  	}

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "$RISEC: The dividend tracker already has that address");
        RSEDividendTracker newDividendTracker = RSEDividendTracker(payable(newAddress));
        require(newDividendTracker.owner() == address(this), "$RISEC: The new dividend tracker must be owned by the RSE token contract");
        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(pancakeSwapV2Router));
        emit UpdateDividendTracker(newAddress, address(dividendTracker));
        dividendTracker = newDividendTracker;
    }

    function updatePancakeSwapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(pancakeSwapV2Router), "$RISEC: The router already has that address");
        emit UpdatePancakeSwapV2Router(newAddress, address(pancakeSwapV2Router));
        pancakeSwapV2Router = IPancakeSwapV2Router02(newAddress);
        address _pancakeSwapV2Pair = IPancakeSwapV2Factory(pancakeSwapV2Router.factory()).createPair(address(this), pancakeSwapV2Router.WETH());
        pancakeSwapV2Pair = _pancakeSwapV2Pair;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "$RISEC: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) 
		{
            _isExcludedFromFees[accounts[i]] = excluded;
        }
        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }
	
    function setBUSDRewardsFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner{
        BUSDRewardsFee[0] = buy;
		BUSDRewardsFee[1] = sell;
		BUSDRewardsFee[2] = p2p;
    }
	
    function setBuyBackFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner{
        buyBackFee[0] = buy;
		buyBackFee[1] = sell;
		buyBackFee[2] = p2p;
    }
	
    function setLiquidityFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner{
        liquidityFee[0] = buy;
		liquidityFee[1] = sell;
		liquidityFee[2] = p2p;
    }
	
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != pancakeSwapV2Pair, "$RISEC: The PanCakeSwap pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "$RISEC: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
		
        if(value) 
		{
            dividendTracker.excludeFromDividends(pair);
        }
        emit SetAutomatedMarketMakerPair(pair, value);
    }


    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "$RISEC: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "$RISEC: Cannot update gasForProcessing to same value");
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

	function excludeFromDividends(address account) external onlyOwner{
	    dividendTracker.excludeFromDividends(account);
	}
	
	function excludeFromMaxWalletToken(address account, bool excluded) public onlyOwner {
        require(isExcludedFromMaxWalletToken[account] != excluded, "Account is already the value of 'excluded'");
        isExcludedFromMaxWalletToken[account] = excluded;
    }
	
	function setSwapAndLiquifyEnabled(bool enabled) public onlyOwner {
        swapAndLiquifyEnabled = enabled;
    }
	
	function setBuyBackEnabled(bool enabled) public onlyOwner {
        buyBackEnabled = enabled;
        emit BuyBackEnabledUpdated(enabled);
    }
	
	function setMaxTxAmount(uint256 amount) external onlyOwner() {
	    require(amount <= totalSupply(), "Amount cannot be over the total supply.");
		maxTxAmount = amount;
	}
	
	function setMaxWalletAmount(uint256 amount) public onlyOwner {
		require(amount <= totalSupply(), "Amount cannot be over the total supply.");
		maxWalletAmount = amount;
	}
	
	function setSwapTokensAmount(uint256 amount) public onlyOwner {
		require(amount <= totalSupply(), "Amount cannot be over the total supply.");
		swapTokensAtAmount = amount;
	}
	
    function tradingStatus(bool enabled) public onlyOwner {
        tradingOpen = enabled;
    }
	
	function allowPreTrading(address account, bool allowed) public onlyOwner {
        require(canTransferBeforeTradingIsEnabled[account] != allowed, "Pre trading is already the value of 'excluded'");
        canTransferBeforeTradingIsEnabled[account] = allowed;
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
		dividendTracker.processAccount(msg.sender, false);
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }
	
    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
		
		if(!tradingOpen) 
		{
		    require(canTransferBeforeTradingIsEnabled[from], "Trading not open yet");
		}
		
		if(from != owner() && to != owner()) {
		   require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
		}
		
		if(!isExcludedFromMaxWalletToken[to] && !automatedMarketMakerPairs[to]) {
            uint256 balanceRecepient = balanceOf(to);
            require(balanceRecepient + amount <= maxWalletAmount, "Exceeds maximum wallet token amount");
        }
		
		uint256 contractTokenBalance = balanceOf(address(this));
		
		if(contractTokenBalance >= maxTxAmount) 
		{
			contractTokenBalance = maxTxAmount;
		}
		
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
		
		uint256 buyBackBalance = address(this).balance;
		if (buyBackEnabled && buyBackBalance >= autoBuybackAmount && block.number >= autoBuybackBlockLast.add(autoBuybackBlockPeriod)) 
		{
			swapBNBForTokens(autoBuybackAmount);
			autoBuybackBlockLast = block.number;
		}
		
		if( canSwap && !swapping && automatedMarketMakerPairs[to] && swapAndLiquifyEnabled) {
            swapping = true;
            tokenToLiquidity     = liquidityFeeTotal;
			tokenToReward        = BUSDRewardsFeeTotal;
			tokenToBuyBack       = buyBackFeeTotal;
			tokenToLiquidityHalf = tokenToLiquidity.div(2);
			tokenToSwap          = tokenToLiquidityHalf.add(tokenToReward).add(tokenToBuyBack);
			
			uint256 initialBalance = address(this).balance;
			swapTokensForBNB(swapTokensAtAmount);
			uint256 newBalance = address(this).balance.sub(initialBalance);
			
			uint256 liquidityPart   = newBalance.mul(tokenToLiquidityHalf).div(tokenToSwap);
			uint256 rewardPart      = newBalance.mul(tokenToReward).div(tokenToSwap);
			uint256 buyBackPart     = newBalance.sub(liquidityPart).sub(rewardPart);
			
			if(liquidityPart > 0) 
			{
			    addLiquidity(tokenToLiquidityHalf, liquidityPart);
				liquidityFeeTotal = liquidityFeeTotal.sub(swapTokensAtAmount.mul(tokenToLiquidity).div(tokenToSwap));
			}
			
			if(rewardPart > 0) 
			{
			    swapAndSendDividends(rewardPart);
				BUSDRewardsFeeTotal = BUSDRewardsFeeTotal.sub(swapTokensAtAmount.mul(tokenToReward).div(tokenToSwap));
			}
			
			if(buyBackPart > 0)
			{
			    buyBackFeeTotal = buyBackFeeTotal.sub(swapTokensAtAmount.mul(tokenToBuyBack).div(tokenToSwap));
			}
            swapping = false;
        }
		
        bool takeFee = !swapping;

        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) 
		{
            takeFee = false;
        }
		
		if(takeFee) 
		{
		    uint256 allfee;
		    allfee = collectFee(amount, automatedMarketMakerPairs[to], !automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to]);
			super._transfer(from, address(this), allfee);
			amount = amount.sub(allfee);
		}
		
        super._transfer(from, to, amount);
        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}
		
        if(!swapping) 
		{
	    	uint256 gas = gasForProcessing;
	    	try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) 
			{
	    		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
	    	}
	    	catch 
			{

	    	}
        }
    }
	
	function collectFee(uint256 amount, bool sell, bool p2p) private returns (uint256) {
        uint256 totalFee;
		
        uint256 rewardFeeNew = amount.mul(p2p ? BUSDRewardsFee[2] : sell ? BUSDRewardsFee[1] : BUSDRewardsFee[0]).div(10000);
		BUSDRewardsFeeTotal += rewardFeeNew;
		
		uint256 liquidityFeeNew = amount.mul(p2p ? liquidityFee[2] : sell ? liquidityFee[1] : liquidityFee[0]).div(10000);
		liquidityFeeTotal += liquidityFeeNew;
		
		uint256 buyBackFeeNew = amount.mul(p2p ? buyBackFee[2] : sell ? buyBackFee[1] : buyBackFee[0]).div(10000);
		buyBackFeeTotal += buyBackFeeNew;
		
		totalFee = rewardFeeNew.add(liquidityFeeNew).add(buyBackFeeNew);
        return totalFee;
    }
	
	function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        _approve(address(this), address(pancakeSwapV2Router), tokenAmount);
        pancakeSwapV2Router.addLiquidityETH{value: bnbAmount}(address(this), tokenAmount, 0, 0, deadWallet, block.timestamp);
    }
	
	function swapBNBForTokens(uint256 bnbAmount) private {
        address[] memory path = new address[](2);
        path[0] = pancakeSwapV2Router.WETH();
        path[1] = address(this);
		
        pancakeSwapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbAmount}(0, path, owner(), block.timestamp.add(300));
        emit SwapBNBForTokens(bnbAmount, path);
    }
	
    function swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeSwapV2Router.WETH();
        _approve(address(this), address(pancakeSwapV2Router), tokenAmount);
        pancakeSwapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp.add(300));
    }
	
    function swapBNBForBUSD(uint256 bnbAmount) private {
        address[] memory path = new address[](2);
        path[0] = pancakeSwapV2Router.WETH();
        path[1] = BUSD;
        pancakeSwapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbAmount}(0, path, address(this), block.timestamp.add(300));
	    emit SwapBNBForTokens(bnbAmount, path);
	}
	
    function swapAndSendDividends(uint256 bnb) private{
        swapBNBForBUSD(bnb);
        uint256 dividends = IBEP20(BUSD).balanceOf(address(this));
        bool success = IBEP20(BUSD).transfer(address(dividendTracker), dividends);
        if (success) {
            dividendTracker.distributeBUSDDividends(dividends);
        }
    }
	
	function migrateBNB(address payable _recipient) public onlyOwner {
        _recipient.transfer(address(this).balance);
    }
	
	function UpdateAutoBuybackBlockPeriod(uint256 newPeriod) public onlyOwner {
        autoBuybackBlockPeriod = newPeriod;
    }
	
	function UpdateAutoBuybackAmount(uint256 newAmount) public onlyOwner {
        autoBuybackAmount = newAmount;
    }
}

contract RSEDividendTracker is Ownable, DividendPayingToken {
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

    constructor() public DividendPayingToken("RSE_Dividen_Tracker", "RSE_Dividend_Tracker") {
    	claimWait = 3600;
        minimumTokenBalanceForDividends = 10000 * (10**18); //must hold 10000+ tokens
    }

    function _transfer(address, address, uint256) internal override {
        require(false, "RSE_Dividend_Tracker: No transfers allowed");
    }
	
    function withdrawDividend() public override {
        require(false, "RSE_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main RSE contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
    	require(!excludedFromDividends[account]);
    	excludedFromDividends[account] = true;

    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);

    	emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "RSE_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "RSE_Dividend_Tracker: Cannot update claimWait to same value");
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
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ? tokenHoldersMap.keys.length.sub(lastProcessedIndex) : 0;
                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }


        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);

        lastClaimTime = lastClaimTimes[account];

        nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(claimWait) : 0;
        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ? nextClaimTime.sub(block.timestamp) : 0;
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
			
			if(processAccount(payable(account), true)) {
				claims++;
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
	    if(canAutoClaim(lastClaimTimes[account])){
		    uint256 amount = _withdrawDividendOfUser(account);
			if(amount > 0) {
				lastClaimTimes[account] = block.timestamp;
				emit Claim(account, amount, automatic);
				return true;
			}
			return false;
		}
		else
		{
		   return false;
		}
    }
}