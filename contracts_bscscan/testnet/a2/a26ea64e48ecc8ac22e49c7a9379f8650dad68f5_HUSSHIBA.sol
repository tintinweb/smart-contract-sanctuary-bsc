// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

import "./DividendPayingToken.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";

contract HUSSHIBA is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;

    bool private swapping;
	 bool public swapAndLiquifyEnabled = true;

    HSHDividendTracker public dividendTracker;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public BUSD = address(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);
	
	address payable public marketingWalletAddress = 0x19971916DF94b93848682126e41E8B16cbdaECD2;
	address payable public developmentWalletAddress = 0x51e2eE2c0db03187f5b3456b0Ef7a9cd8082c4e8;
	address payable public miningWalletAddress = 0x1ed3E90247C90f357f14a57b3cbACf508c43efD0;
	
    uint256 public swapTokensAtAmount = 10000 * (10**9);
	uint256 public maxTxAmount = 1000000 * (10**9);
	uint256 public maxBuyAmount = 1000000 * (10**9);
	uint256 public maxSaleAmount = 250000 * (10**9);
	uint256 public maxSellPerDay = 250000 * (10**9);
	uint256 public maxWalletAmount = 1000000 * (10**9);
	
	uint256[] public BUSDRewardsFee;
	uint256[] public miningFee;
	uint256[] public marketingFee;
	uint256[] public developmentFee;
	
	uint256 private tokenToSwap;
	uint256 private tokenToMarketing;
	uint256 private tokenToDevelopment;
	uint256 private tokenToMining;
	uint256 private tokenToReward;
	
	uint256 public BUSDRewardsFeeTotal;
	uint256 public miningFeeTotal;
	uint256 public marketingFeeTotal;
	uint256 public developmentFeeTotal;
	
	bool public tradingOpen = false;
    uint256 public gasForProcessing = 300000;

    mapping (address => bool) private _isExcludedFromFees;
	mapping (address => bool) public isExcludedFromMaxWalletToken;
    mapping (address => bool) public automatedMarketMakerPairs;
	mapping (address => bool) public canTransferBeforeTradingIsEnabled;
	mapping (address => bool) public isExcludedFromDailySaleLimit;
	mapping (uint256 => mapping(address => uint256)) public dailyTransfers;
	
	event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event SendDividends(uint256 tokensSwapped, uint256 amount);
    event ProcessedDividendTracker(uint256 iterations, uint256 claims, uint256 lastProcessedIndex, bool indexed automatic, uint256 gas, address indexed processor);

    constructor() public ERC20("HUSSHIBA", "HSH") {

    	dividendTracker = new HSHDividendTracker();
		
    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(deadWallet);
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));
		
		isExcludedFromMaxWalletToken[_uniswapV2Pair] = true;
		isExcludedFromMaxWalletToken[address(this)] = true;
		isExcludedFromMaxWalletToken[owner()] = true;
		
		isExcludedFromDailySaleLimit[address(this)] = true;
        isExcludedFromDailySaleLimit[owner()] = true;

        excludeFromFees(owner(), true);
        excludeFromFees(marketingWalletAddress, true);
        excludeFromFees(address(this), true);
		
		canTransferBeforeTradingIsEnabled[owner()] = true;
		
		BUSDRewardsFee.push(200);
		BUSDRewardsFee.push(200);
		BUSDRewardsFee.push(200);
		
		miningFee.push(200);
		miningFee.push(200);
		miningFee.push(200);
		
		marketingFee.push(200);
		marketingFee.push(200);
		marketingFee.push(200);
		
		developmentFee.push(200);
		developmentFee.push(200);
		developmentFee.push(200);
		
        _mint(owner(), 100000000 * (10**9));
    }

    receive() external payable {

  	}

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "HSH: The dividend tracker already has that address");
        HSHDividendTracker newDividendTracker = HSHDividendTracker(payable(newAddress));
        require(newDividendTracker.owner() == address(this), "HSH: The new dividend tracker must be owned by the HSH token contract");
        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));
        emit UpdateDividendTracker(newAddress, address(dividendTracker));
        dividendTracker = newDividendTracker;
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "HSH: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "HSH: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setMarketingWallet(address payable wallet) external onlyOwner{
	    require(wallet != address(0), "zero-address not allowed");
        marketingWalletAddress = wallet;
    }
	
	function setDevelopmentWallet(address payable wallet) external onlyOwner{
	    require(wallet != address(0), "zero-address not allowed");
        developmentWalletAddress = wallet;
    }
	
	function setMiningWallet(address payable wallet) external onlyOwner{
	    require(wallet != address(0), "zero-address not allowed");
        miningWalletAddress = wallet;
    }

    function setBUSDRewardsFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner{
        BUSDRewardsFee[0] = buy;
		BUSDRewardsFee[1] = sell;
		BUSDRewardsFee[2] = p2p;
    }
	
    function setMiningFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner{
        miningFee[0] = buy;
		miningFee[1] = sell;
		miningFee[2] = p2p;
    }
	
    function setMarketingFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner{
        marketingFee[0] = buy;
		marketingFee[1] = sell;
		marketingFee[2] = p2p;
    }
	
	function setDevelopmentFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner{
        developmentFee[0] = buy;
		developmentFee[1] = sell;
		developmentFee[2] = p2p;
    }
	
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "HSH: The PanCakeSwap pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "HSH: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }
        emit SetAutomatedMarketMakerPair(pair, value);
    }


    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "HSH: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "HSH: Cannot update gasForProcessing to same value");
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
	
	function excludeFromDailySaleLimit(address account, bool excluded) public onlyOwner {
        require(isExcludedFromDailySaleLimit[account] != excluded, "Daily sale limit exclusion is already the value of 'excluded'");
        isExcludedFromDailySaleLimit[account] = excluded;
    }
	
	function setSwapAndLiquifyEnabled(bool enabled) public onlyOwner {
        swapAndLiquifyEnabled = enabled;
    }
	
	function setMaxTxAmount(uint256 amount) external onlyOwner() {
	    require(amount <= totalSupply(), "Amount cannot be over the total supply.");
		maxTxAmount = amount;
	}
	
	function setSaleTxAmount(uint256 amount) external onlyOwner() {
	    require(amount <= totalSupply(), "Amount cannot be over the total supply.");
		maxSaleAmount = amount;
	}
	
	function setBuyTxAmount(uint256 amount) external onlyOwner() {
	    require(amount <= totalSupply(), "Amount cannot be over the total supply.");
		maxBuyAmount = amount;
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
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
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
		
		if(!automatedMarketMakerPairs[from] && automatedMarketMakerPairs[to] && from != owner() && to != owner()) 
		{
		    require(amount <= maxSaleAmount, "Transfer amount exceeds the maxSaleAmount");
		}
		
		if (!isExcludedFromDailySaleLimit[from] && !automatedMarketMakerPairs[from] && automatedMarketMakerPairs[to]) 
		{
		    require(dailyTransfers[getDay()][from].add(amount) <= maxSellPerDay, "This account has exceeded max daily sell limit");
            dailyTransfers[getDay()][from] = dailyTransfers[getDay()][from].add(amount);
		}
		
		if(automatedMarketMakerPairs[from] && to != owner()) 
		{
		    require(amount <= maxBuyAmount, "Transfer amount exceeds the maxBuyAmount");
		}
		
		uint256 contractTokenBalance = balanceOf(address(this));
		if(contractTokenBalance >= maxTxAmount) 
		{
			contractTokenBalance = maxTxAmount;
		}
		
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
		
		if( canSwap && !swapping && automatedMarketMakerPairs[to] && swapAndLiquifyEnabled) {
            swapping = true;
            tokenToMarketing    = marketingFeeTotal;
			tokenToDevelopment  = developmentFeeTotal;
			tokenToMining       = miningFeeTotal;
			tokenToReward       = BUSDRewardsFeeTotal;
			
			tokenToSwap = tokenToMarketing.add(tokenToDevelopment).add(tokenToMining).add(tokenToReward);
			
			uint256 initialBalance = address(this).balance;
			swapTokensForBNB(swapTokensAtAmount);
			uint256 newBalance = address(this).balance.sub(initialBalance);
			
			uint256 marketingPart   = newBalance.mul(tokenToMarketing).div(tokenToSwap);
			uint256 developmentPart = newBalance.mul(tokenToDevelopment).div(tokenToSwap);
			uint256 miningPart      = newBalance.mul(tokenToMining).div(tokenToSwap);
			uint256 rewardPart      = newBalance.sub(marketingPart).sub(developmentPart).sub(miningPart);
			
			if(marketingPart > 0) 
			{
			   payable(marketingWalletAddress).transfer(marketingPart);
			   marketingFeeTotal = marketingFeeTotal.sub(swapTokensAtAmount.mul(tokenToMarketing).div(tokenToSwap));
			}
			
			if(developmentPart > 0) 
			{
			    payable(developmentWalletAddress).transfer(developmentPart);
			    developmentFeeTotal = developmentFeeTotal.sub(swapTokensAtAmount.mul(tokenToDevelopment).div(tokenToSwap));
			}
			
			if(miningPart > 0) 
			{
				payable(miningWalletAddress).transfer(miningPart);
				miningFeeTotal = miningFeeTotal.sub(swapTokensAtAmount.mul(tokenToMining).div(tokenToSwap));
			}
			
			if(rewardPart > 0) 
			{
			    swapAndSendDividends(rewardPart);
				BUSDRewardsFeeTotal = BUSDRewardsFeeTotal.sub(swapTokensAtAmount.mul(tokenToReward).div(tokenToSwap));
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

    function getDay() internal view returns(uint256){
        return block.timestamp.div(1 days);
    }
	
	function collectFee(uint256 amount, bool sell, bool p2p) private returns (uint256) {
        uint256 totalFee;
		
        uint256 rewardFeeNew = amount.mul(p2p ? BUSDRewardsFee[2] : sell ? BUSDRewardsFee[1] : BUSDRewardsFee[0]).div(10000);
		BUSDRewardsFeeTotal = BUSDRewardsFeeTotal.add(rewardFeeNew);
		
		uint256 miningFeeNew = amount.mul(p2p ? miningFee[2] : sell ? miningFee[1] : miningFee[0]).div(10000);
		miningFeeTotal = miningFeeTotal.add(miningFeeNew);
		
		uint256 marketingFeeNew = amount.mul(p2p ? marketingFee[2] : sell ? marketingFee[1] : marketingFee[0]).div(10000);
		marketingFeeTotal = marketingFeeTotal.add(marketingFeeNew);
		
		uint256 developmentFeeNew = amount.mul(p2p ? developmentFee[2] : sell ? developmentFee[1] : developmentFee[0]).div(10000);
		developmentFeeTotal = developmentFeeTotal.add(developmentFeeNew);
		
		totalFee = rewardFeeNew.add(miningFeeNew).add(marketingFeeNew).add(developmentFeeNew);
        return totalFee;
    }
	
    function swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }
	
    function swapBNBForBUSD(uint256 bnbAmount) private {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = BUSD;
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbAmount}(0, path, address(this), block.timestamp.add(300));
	}
	
    function swapAndSendDividends(uint256 bnb) private{
        swapBNBForBUSD(bnb);
        uint256 dividends = IERC20(BUSD).balanceOf(address(this));
        bool success = IERC20(BUSD).transfer(address(dividendTracker), dividends);
        if (success) {
            dividendTracker.distributeBUSDDividends(dividends);
        }
    }
	
	function migrateBNB(address payable _recipient) public onlyOwner {
        _recipient.transfer(address(this).balance);
    }
}

contract HSHDividendTracker is Ownable, DividendPayingToken {
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

    constructor() public DividendPayingToken("HSH_Dividen_Tracker", "HSH_Dividend_Tracker") {
    	claimWait = 3600;
        minimumTokenBalanceForDividends = 500 * (10**9); //must hold 500+ tokens
    }

    function _transfer(address, address, uint256) internal override {
        require(false, "HSH_Dividend_Tracker: No transfers allowed");
    }
	
    function withdrawDividend() public override {
        require(false, "HSH_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main HSH contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
    	require(!excludedFromDividends[account]);
    	excludedFromDividends[account] = true;

    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);

    	emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "HSH_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "HSH_Dividend_Tracker: Cannot update claimWait to same value");
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