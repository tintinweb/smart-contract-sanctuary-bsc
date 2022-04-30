// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

import "./DividendPayingToken.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";
import "./IPancakeSwapV2Pair.sol";
import "./IPancakeSwapV2Factory.sol";
import "./IPancakeSwapV2Router.sol";

contract AnonPay is BEP20, Ownable {
    using SafeMath for uint256;
	
    IPancakeSwapV2Router02 public pancakeSwapV2Router;
    address public pancakeSwapV2Pair;

    bool private swapping;
	bool public swapAndLiquifyEnabled = true;
	
    APAYDividendTracker public dividendTracker;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
	address public depositWallet = 0xC9428DD83D248dEe81865cc2C82bB78736EC84eD;
	address public marketingWallet = 0x1041FAF025fD52Cea08883dA99546b6637051164;
    address public USDT = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);

    uint256 public swapTokensAtAmount = 100000 * (10**9);
	uint256 public maxTxAmount = 1000000 * (10**9);
	
	uint256[] public rewardsFee;
	uint256[] public marketingFee;
	uint256[] public liquidityFee;
	uint256[] public burnFee;
	
	uint256 private tokenToSwap;
	uint256 private tokenToMarketing;
	uint256 private tokenToLiquidity;
	uint256 private tokenToReward;
	uint256 private liquidityHalf;
	
	uint256 public rewardsFeeTotal;
	uint256 public marketingFeeTotal;
	uint256 public liquidityFeeTotal;
	
    uint256 public gasForProcessing = 300000;
	
    mapping (address => bool) private _isExcludedFromFees;
	mapping (address => bool) public isExcludedFromMaxTrxToken;
    mapping (address => bool) public automatedMarketMakerPairs;
	
	event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);
    event UpdatePancakeSwapV2Router(address indexed newAddress, address indexed oldAddress);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event SendDividends(uint256 tokensSwapped, uint256 amount);
    event ProcessedDividendTracker(uint256 iterations, uint256 claims, uint256 lastProcessedIndex, bool indexed automatic, uint256 gas, address indexed processor);

    constructor() BEP20("AnonPay", "APAY") {

    	dividendTracker = new APAYDividendTracker();
		
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

        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
		
		isExcludedFromMaxTrxToken[owner()] = true;
		
		rewardsFee.push(500);
		rewardsFee.push(500);
		rewardsFee.push(500);
		
		burnFee.push(100);
		burnFee.push(100);
		burnFee.push(100);
		
		marketingFee.push(100);
		marketingFee.push(100);
		marketingFee.push(100);
		
		liquidityFee.push(200);
		liquidityFee.push(500);
		liquidityFee.push(200);
		
        _mint(owner(), 1000000000 * (10**9));
    }

    receive() external payable {}

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "APAY: The dividend tracker already has that address");
        
		APAYDividendTracker newDividendTracker = APAYDividendTracker(payable(newAddress));
        require(newDividendTracker.owner() == address(this), "APAY: The new dividend tracker must be owned by the APAY token contract");
        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(pancakeSwapV2Router));
        
		emit UpdateDividendTracker(newAddress, address(dividendTracker));
        dividendTracker = newDividendTracker;
    }

    function updatePancakeSwapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(pancakeSwapV2Router), "APAY: The router already has that address");
        emit UpdatePancakeSwapV2Router(newAddress, address(pancakeSwapV2Router));
        pancakeSwapV2Router = IPancakeSwapV2Router02(newAddress);
        address _pancakeSwapV2Pair = IPancakeSwapV2Factory(pancakeSwapV2Router.factory()).createPair(address(this), pancakeSwapV2Router.WETH());
        pancakeSwapV2Pair = _pancakeSwapV2Pair;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "APAY: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
	
    function setMarketingWallet(address payable wallet) external onlyOwner{
	    require(wallet != address(0), "zero-address not allowed");
        marketingWallet = wallet;
    }
	
	function setDepositWallet(address wallet) external onlyOwner{
	    require(wallet != address(0), "zero-address not allowed");
        depositWallet = wallet;
    }
	
    function setRewardsFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner{
        rewardsFee[0] = buy;
		rewardsFee[1] = sell;
		rewardsFee[2] = p2p;
    }
	
    function setBurnFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner{
        burnFee[0] = buy;
		burnFee[1] = sell;
		burnFee[2] = p2p;
    }
	
    function setMarketingFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner{
        marketingFee[0] = buy;
		marketingFee[1] = sell;
		marketingFee[2] = p2p;
    }
	
	function setLiquidityFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner{
        liquidityFee[0] = buy;
		liquidityFee[1] = sell;
		liquidityFee[2] = p2p;
    }
	
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != pancakeSwapV2Pair, "APAY: The PanCakeSwap pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "APAY: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }
        emit SetAutomatedMarketMakerPair(pair, value);
    }


    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "APAY: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "APAY: Cannot update gasForProcessing to same value");
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
	
	function setSwapAndLiquifyEnabled(bool enabled) public onlyOwner {
        swapAndLiquifyEnabled = enabled;
    }
	
	function setMaxTxAmount(uint256 amount) external onlyOwner() {
	    require(amount <= totalSupply(), "Amount cannot be over the total supply.");
		maxTxAmount = amount;
	}
	
	function setSwapTokensAmount(uint256 amount) public onlyOwner {
		require(amount <= totalSupply(), "Amount cannot be over the total supply.");
		swapTokensAtAmount = amount;
	}
	
    function getAccountDividendsInfo(address account) external view returns (address, int256, int256, uint256, uint256, uint256, uint256, uint256) {
        return dividendTracker.getAccount(account);
    }

	function getAccountDividendsInfoAtIndex(uint256 index) external view returns ( address, int256, int256, uint256, uint256, uint256, uint256, uint256) {
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
		
		if(!isExcludedFromMaxTrxToken[from]) 
		{
		   require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
		}

		uint256 contractTokenBalance = balanceOf(address(this));
		if(contractTokenBalance >= maxTxAmount) 
		{
			contractTokenBalance = maxTxAmount;
		}
		
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
		
		if( canSwap && !swapping && automatedMarketMakerPairs[to] && swapAndLiquifyEnabled) {
            swapping = true;
            tokenToMarketing  = marketingFeeTotal;
			tokenToLiquidity  = liquidityFeeTotal;
			tokenToReward     = rewardsFeeTotal;
			liquidityHalf     = tokenToLiquidity.div(2);
			
			tokenToSwap = tokenToMarketing.add(liquidityHalf).add(tokenToReward);
			
			uint256 initialBalance = address(this).balance;
			swapTokensForBNB(swapTokensAtAmount);
			uint256 newBalance = address(this).balance.sub(initialBalance);
			
			uint256 marketingPart   = newBalance.mul(tokenToMarketing).div(tokenToSwap);
			uint256 liquidityPart   = newBalance.mul(liquidityHalf).div(tokenToSwap);
			uint256 rewardPart      = newBalance.sub(marketingPart).sub(liquidityPart);
			
			if(marketingPart > 0) 
			{
			    payable(marketingWallet).transfer(marketingPart);
			    marketingFeeTotal = marketingFeeTotal.sub(swapTokensAtAmount.mul(tokenToMarketing).div(tokenToSwap));
			}
			
			if(liquidityPart > 0) 
			{
			     addLiquidity(liquidityHalf, liquidityPart);
			     liquidityFeeTotal = liquidityFeeTotal.sub(swapTokensAtAmount.mul(tokenToLiquidity).div(tokenToSwap));
			}
			
			if(rewardPart > 0) 
			{
			    swapAndSendDividends(rewardPart);
				rewardsFeeTotal = rewardsFeeTotal.sub(swapTokensAtAmount.mul(tokenToReward).div(tokenToSwap));
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
			(uint256 allfee, uint256 burnfee) = collectFee(amount, automatedMarketMakerPairs[to], !automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to]);
			if(allfee > 0)
			{
			   super._transfer(from, address(this), allfee);
			   amount = amount.sub(allfee);
			}
			if(burnfee > 0)
			{
			   super._transfer(from, deadWallet, burnfee);
			   amount = amount.sub(burnfee);
			}
			
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
	
	function deposit(uint256 amount) external {
        require(amount > 0, "amount must be greater than zero");
		
        super._transfer(msg.sender, depositWallet, amount);
		
        try dividendTracker.setBalance(payable(msg.sender), balanceOf(msg.sender)) {} catch {}
        try dividendTracker.setBalance(payable(depositWallet), balanceOf(depositWallet)) {} catch {}
    }
	
	function collectFee(uint256 amount, bool sell, bool p2p) private returns (uint256, uint256) {
        uint256 totalFee;
		
        uint256 rewardFeeNew = amount.mul(p2p ? rewardsFee[2] : sell ? rewardsFee[1] : rewardsFee[0]).div(10000);
		rewardsFeeTotal = rewardsFeeTotal.add(rewardFeeNew);

		uint256 marketingFeeNew = amount.mul(p2p ? marketingFee[2] : sell ? marketingFee[1] : marketingFee[0]).div(10000);
		marketingFeeTotal = marketingFeeTotal.add(marketingFeeNew);
		
		uint256 liquidityFeeNew = amount.mul(p2p ? liquidityFee[2] : sell ? liquidityFee[1] : liquidityFee[0]).div(10000);
		liquidityFeeTotal = liquidityFeeTotal.add(liquidityFeeNew);
		
		uint256 _burnFee = amount.mul(p2p ? burnFee[2] : sell ? burnFee[1] : burnFee[0]).div(10000);
		
		totalFee = rewardFeeNew.add(marketingFeeNew).add(liquidityFeeNew);
		
        return (totalFee, _burnFee);
    }
	
	function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        _approve(address(this), address(pancakeSwapV2Router), tokenAmount);
        pancakeSwapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, 
            0,
            address(this),
            block.timestamp
        );
    }
	
    function swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeSwapV2Router.WETH();
        _approve(address(this), address(pancakeSwapV2Router), tokenAmount);
        pancakeSwapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }
	
    function swapBNBForUSDT(uint256 bnbAmount) private {
        address[] memory path = new address[](2);
        path[0] = pancakeSwapV2Router.WETH();
        path[1] = USDT;
        pancakeSwapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbAmount}(0, path, address(this), block.timestamp.add(300));
	}
	
    function swapAndSendDividends(uint256 bnb) private{
        swapBNBForUSDT(bnb);
        uint256 dividends = IBEP20(USDT).balanceOf(address(this));
        bool success = IBEP20(USDT).transfer(address(dividendTracker), dividends);
        if (success) {
            dividendTracker.distributeUSDTDividends(dividends);
        }
    }
	
	function migrateBNB(address payable _recipient) public onlyOwner {
        _recipient.transfer(address(this).balance);
    }
}

contract APAYDividendTracker is Ownable, DividendPayingToken {
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

    constructor() DividendPayingToken("APAY_Dividen_Tracker", "APAY_Dividend_Tracker") {
    	claimWait = 3600;
        minimumTokenBalanceForDividends = 100 * (10**9); //must hold 100+ tokens
    }

    function _transfer(address, address, uint256) internal pure override {
        require(false, "APAY_Dividend_Tracker: No transfers allowed");
    }
	
    function withdrawDividend() public pure override {
        require(false, "APAY_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main APAY contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
    	require(!excludedFromDividends[account]);
    	excludedFromDividends[account] = true;

    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);

    	emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "APAY_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "APAY_Dividend_Tracker: Cannot update claimWait to same value");
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