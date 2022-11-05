// SPDX-License-Identifier: Unlicensed

/*
        __  __                _    _       __               
       / / / /___  ____ ___  (_)__| |     / /___ ___________
      / /_/ / __ \/ __ `__ \/ / _ \ | /| / / __ `/ ___/ ___/
     / __  / /_/ / / / / / / /  __/ |/ |/ / /_/ / /  (__  ) 
    /_/ /_/\____/_/ /_/ /_/_/\___/|__/|__/\__,_/_/  /____/ .com 

    Battle Royale Play2Earn Powered By Binance SmartChain

*/

pragma solidity ^0.8.6;

import "./DividendPayingToken.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";
import "./IDex.sol";
import "./SafeMath.sol";

library Address{
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

contract HomieCoin is ERC20, Ownable {
    using Address for address payable;

    IRouter public router;
    address public  pair;

    bool private swapping;
    bool public swapEnabled = false;
    bool public liquidityFilled;

    
    mapping(address => uint256) public contributions;
    bool public presaleEnabled;
    uint256 public presaleRate = 48000000;
    uint256 public minPurchase = 0.001 ether;
    uint256 public maxPurchase = 10 ether;

    HomieCoinDividendTracker public dividendTracker;

    uint256 public swapTokensAtAmount = 1_000_000 * (10**18);

    uint256 public  BNBRewardsFee = 1;
    uint256 public  marketingFee = 3;
    uint256 public prizeFee = 2;
    uint256 public liquidityFee = 1;
    uint256 public buybackFee = 1;
    uint256 public  totalFees = BNBRewardsFee + marketingFee + liquidityFee + buybackFee + prizeFee;

    address public marketingWallet = 0x788CcEc0fcb141989AD1906A0e05F2865D8dE819;
    address public prizeWallet = 0x1e57aa70674e2d56102E13bE144Aaf8c6333d367;
    address public buybackWallet = 0xBa345190eBA0C9966533Dc16AedD4f7b91AfC9c7;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;

    mapping (address => bool) private _isExcludedFromFees;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);

    event Updaterouter(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);


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

     modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }

    event TokensPurchased(address user, uint256 amount, uint256 weiAmount);

    constructor()  ERC20("HomieCoin", "HomieCoin") {

    	dividendTracker = new HomieCoinDividendTracker();

    	IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        //0x10ED43C718714eb63d5aA57B78B54704E256024E
         // Create a uniswap pair for this new token
        address _pair = IFactory(_router.factory())
            .createPair(address(this), _router.WETH());

        router = _router;
        pair = _pair;

        _setAutomatedMarketMakerPair(_pair, true);

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(0x000000000000000000000000000000000000dEaD);
        dividendTracker.excludeFromDividends(address(_router));

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(marketingWallet, true);
        excludeFromFees(prizeWallet, true);
        excludeFromFees(buybackWallet, true);

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), 1e9 * (10**20));
    }

    receive() external payable {
        if(presaleEnabled){
            buyTokens();
        }
  	}

    // Presale //
    function setPresaleStatus(bool state) external onlyOwner{
        presaleEnabled = state;
    }

    function setPreasaleRate(uint256 _rate) external onlyOwner{
        presaleRate = _rate;
    }

    function setMaxAndMinPurchase(uint256 _maxInWei, uint256 _minInWei) external onlyOwner{
        require(_minInWei > 0 && _minInWei < _maxInWei, "Wrong values");
        maxPurchase = _maxInWei;
        minPurchase = _minInWei;
    }

    function buyTokens() public payable{
        require(presaleEnabled, "Presale not active");
        require(msg.value >= minPurchase, "Min purchase not reached");
        require(contributions[msg.sender] + msg.value <= maxPurchase, "You are exceeding max purchase");
        uint256 tokensAmt = msg.value * presaleRate;
        require(balanceOf(address(this))>= tokensAmt, "No enough tokens");
        contributions[msg.sender] += msg.value;
        super._transfer(address(this), msg.sender, tokensAmt);
        dividendTracker.setBalance(payable(msg.sender), balanceOf(msg.sender));
        emit TokensPurchased(msg.sender, tokensAmt, msg.value);
    }

    // Check how many tokens you get with amountInWei
    function calculateContribution(uint256 amountInWei) external view returns(uint256){
        return amountInWei * presaleRate;
    }

    // End Presale //


    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "HomieCoin: The dividend tracker already has that address");

        HomieCoinDividendTracker newDividendTracker = HomieCoinDividendTracker(payable(newAddress));

        require(newDividendTracker.owner() == address(this), "HomieCoin: The new dividend tracker must be owned by the HomieCoin token contract");

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(router));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }

    function updateRouter(address newAddress) public onlyOwner {
        require(newAddress != address(router), "HomieCoin: The router already has that address");
        emit Updaterouter(newAddress, address(router));
        router = IRouter(newAddress);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "HomieCoin: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setSwapTokensAtAmount(uint256 amount) external onlyOwner{
        swapTokensAtAmount = amount * 10**18;
    }


    function setAutomatedMarketMakerPair(address newPair, bool value) public onlyOwner {
        require(newPair != pair, "HomieCoin: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(newPair, value);
    }

    function excludeFromDividends(address account) external onlyOwner{
        dividendTracker.excludeFromDividends(account);
    }

    function _setAutomatedMarketMakerPair(address newPair, bool value) private {
        require(automatedMarketMakerPairs[newPair] != value, "HomieCoin: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[newPair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(newPair);
        }

        emit SetAutomatedMarketMakerPair(newPair, value);
    }

    /// @notice Withdraw tokens sent by mistake.
    /// @param tokenAddress The address of the token to withdraw
    function rescueBEP20Tokens(address tokenAddress) external onlyOwner{
     
        IERC20(tokenAddress).transfer(msg.sender, IERC20(tokenAddress).balanceOf(address(this)));
    }

    function rescueBNB() external onlyOwner{
        payable(owner()).sendValue(address(this).balance);
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "HomieCoin: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "HomieCoin: Cannot update gasForProcessing to same value");
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

    function setMarketingFee(uint256 newFee) external onlyOwner{
        marketingFee = newFee;
        totalFees = BNBRewardsFee + marketingFee + liquidityFee + buybackFee + prizeFee;
    }

    function setBNBRewardsFee(uint256 newFee) external onlyOwner{
        BNBRewardsFee = newFee;
        totalFees = BNBRewardsFee + marketingFee + liquidityFee + buybackFee + prizeFee;
    }

    function setLiquidityFee(uint256 newFee) external onlyOwner {
        liquidityFee = newFee;
        totalFees = BNBRewardsFee + marketingFee + liquidityFee + buybackFee + prizeFee;
    }

    function setbuybackFee(uint256 newFee) external onlyOwner {
        buybackFee = newFee;
        totalFees = BNBRewardsFee + marketingFee + liquidityFee + buybackFee + prizeFee;
    }


    function setMarketingWallet(address newWallet) external onlyOwner{
        marketingWallet = newWallet;
    }
    function setbuybackWallet(address newWallet) external onlyOwner{
        buybackWallet = newWallet;
    }

    function setSwapEnabled(bool value) external onlyOwner{
        swapEnabled = value;
    }

    function confirmLiquidityFIlled() external onlyOwner{
        liquidityFilled = true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if(!_isExcludedFromFees[from] && !_isExcludedFromFees[to]){
            require(liquidityFilled, "Token is not launched yet");
        }
        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
        if(canSwap && swapEnabled && !swapping && from != pair && !_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            if(totalFees > 0){
                swapAndLiquify(swapTokensAtAmount);
            }
        }

        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {
        	uint256 fees = amount * totalFees / 100;
        	amount = amount - fees;
            super._transfer(from, address(this), fees);
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

    function swapAndLiquify(uint256 tokens) private lockTheSwap{
        // Split the contract balance into halves
        uint256 denominator= totalFees * 2;
        uint256 tokensToAddLiquidityWith = tokens * liquidityFee / denominator;
        uint256 toSwap = tokens - tokensToAddLiquidityWith;

        uint256 initialBalance = address(this).balance;

        swapTokensForBNB(toSwap);

        uint256 deltaBalance = address(this).balance - initialBalance;
        uint256 unitBalance= deltaBalance / (denominator - liquidityFee);
        uint256 bnbToAddLiquidityWith = unitBalance * liquidityFee;

        if(bnbToAddLiquidityWith > 0){
            // Add liquidity to pancake
            addLiquidity(tokensToAddLiquidityWith, bnbToAddLiquidityWith);
        }

        
        uint256 marketingAmt = (unitBalance * 2 * marketingFee);
        if(marketingAmt > 0){
            payable(marketingWallet).sendValue(marketingAmt);
        }

        
        uint256 teamAmt = (unitBalance * 2 * buybackFee);
        if(teamAmt > 0){
            payable(buybackWallet).sendValue(teamAmt);
        }

        
        uint256 devAmt = (unitBalance * 2 * prizeFee);
        if(devAmt > 0){
            payable(prizeWallet).sendValue(devAmt);
        }

        
        uint256 dividends = unitBalance * 2 * BNBRewardsFee;
        if(dividends > 0){
            (bool success,) = address(dividendTracker).call{value: dividends}("");
            if(success)emit SendDividends(tokens, dividends);
        }

    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokenAmount);

        // add the liquidity
        router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            buybackWallet,
            block.timestamp
        );

    }

    function swapTokensForBNB(uint256 tokenAmount) private {

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

    }
}

contract HomieCoinDividendTracker is DividendPayingToken, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping (address => bool) public excludedFromDividends;

    mapping (address => uint256) public lastClaimTimes;

    uint256 public claimWait;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor()  DividendPayingToken("HomieCoin_Dividend_Tracker", "HomieCoin_Dividend_Tracker") {
    	claimWait = 3600;
    }

    function _transfer(address, address, uint256) internal pure override{
        require(false, "HomieCoin_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public pure override {
        require(false, "HomieCoin_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main HomieCoin contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
    	require(!excludedFromDividends[account]);
    	excludedFromDividends[account] = true;

    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);

    	emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "HomieCoin_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "HomieCoin_Dividend_Tracker: Cannot update claimWait to same value");
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

        _setBalance(account, newBalance);
    	tokenHoldersMap.set(account, newBalance);

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