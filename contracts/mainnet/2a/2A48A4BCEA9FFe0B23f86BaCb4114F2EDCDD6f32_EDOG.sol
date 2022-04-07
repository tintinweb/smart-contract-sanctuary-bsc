// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./DividendPayingToken.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";
import "./IDex.sol";


library Address{
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


contract EDOG is ERC20, Ownable {
    using SafeMath for uint256;
    using Address for address payable;

    IRouter public router;
    address public  pair;

    bool private swapping;
    bool public swapEnabled = true;

    EDOGDividendTracker public dividendTracker;

    address public constant DOGE = address(0xbA2aE424d960c26247Dd6c32edC70B295c744C43); //DOGE
    address public ecosystemWallet = 0xF7A90bfc5A18b2Ec04D6f7deCA0168403639c131;
    
    uint256 public swapTokensAtAmount = 2_000_000 * 10**18;
    
            ///////////////
           //   Fees    //
          ///////////////
          
    uint256 public DOGERewardsFee = 5;
    uint256 public ecosystemFee = 10;
    uint256 public totalFees = DOGERewardsFee.add(ecosystemFee);

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;
    
         ////////////////
        //  Anti Bot  //
       ////////////////
       
       
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public automatedMarketMakerPairs;
    
        ///////////////
       //   Events  //
      ///////////////
      
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event SendDividends(uint256 tokensSwapped,uint256 amount);
    event ProcessedDividendTracker(uint256 iterations,uint256 claims,uint256 lastProcessedIndex,bool indexed automatic,uint256 gas,address indexed processor);
    

    constructor() ERC20("ECODOGE", "EDOG") {

    	dividendTracker = new EDOGDividendTracker();

    	IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a uniswap pair for this new token
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());

        router = _router;
        pair = _pair;

        _setAutomatedMarketMakerPair(_pair, true);


        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker), true);
        dividendTracker.excludeFromDividends(address(this), true);
        dividendTracker.excludeFromDividends(owner(), true);
        dividendTracker.excludeFromDividends(address(0xdead), true);
        dividendTracker.excludeFromDividends(address(_router), true);

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), 10e9 * (10**18));
    }

    receive() external payable {}

    function processDividendTracker(uint256 gas) external {
		(uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }
    
    /// @notice Manual claim the dividends after claimWait is passed
    ///    This can be useful during low volume days.
    function claim() external {
		dividendTracker.processAccount(msg.sender, false);
    }
    
    /// @notice Withdraw tokens sent by mistake.
    /// @param tokenAddress The address of the token to withdraw
    function rescueBEP20Tokens(address tokenAddress) external onlyOwner{
        IERC20(tokenAddress).transfer(msg.sender, IERC20(tokenAddress).balanceOf(address(this)));
    }
    
    /// @notice Send remaining BNB to windogeDefender
    /// @dev It will send all BNB to windogeDefender
    function forceSend() external onlyOwner{
        uint256 BNBbalance = address(this).balance;
        payable(ecosystemWallet).sendValue(BNBbalance);
    }
    
    
     /////////////////////////////////
    // Exclude / Include functions //
   /////////////////////////////////

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "EDOG: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    /// @dev "true" to exlcude, "false" to include
    function excludeFromDividends(address account, bool value) external onlyOwner{
	    dividendTracker.excludeFromDividends(account, value);
	}


     ///////////////////////
    //  Setter Functions //
   ///////////////////////


    function setEcosystemWallet(address newWallet) external onlyOwner{
        ecosystemWallet = newWallet;
    }


    /// @notice Update the threshold to swap tokens for liquidity,
    ///   marketing and dividends.
    function setSwapTokensAtAmount(uint256 amount) external onlyOwner{
        swapTokensAtAmount = amount * 10**18;
    }


    function setDOGERewardsFee(uint256 value) external onlyOwner{
        DOGERewardsFee = value;
        totalFees = DOGERewardsFee.add(ecosystemFee);
    }

    function setEcosystemFee(uint256 value) external onlyOwner{
        ecosystemFee = value;
        totalFees = DOGERewardsFee.add(ecosystemFee);
    }
    
    /// @notice Enable or disable internal swaps
    /// @dev Set "true" to enable internal swaps for liquidity, marketing and dividends
    function setSwapEnabled(bool _enabled) external onlyOwner{
        swapEnabled = _enabled;
    }

    /// @dev Set new pairs created due to listing in new DEX
    function setAutomatedMarketMakerPair(address newPair, bool value) external onlyOwner {
        _setAutomatedMarketMakerPair(newPair, value);
    }

    function _setAutomatedMarketMakerPair(address newPair, bool value) private {
        require(automatedMarketMakerPairs[newPair] != value, "EDOG: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[newPair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(newPair, true);
        }

        emit SetAutomatedMarketMakerPair(newPair, value);
    }

    /// @notice Update the gasForProcessing needed to auto-distribute rewards
    /// @param newValue The new amount of gas needed
    /// @dev The amount should not be greater than 500k to avoid expensive transactions
    function setGasForProcessing(uint256 newValue) external onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "EDOG: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "EDOG: Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    /// @dev Update the dividendTracker claimWait
    function setClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function setMinTokenBalanceForRewards(uint256 amount) external onlyOwner{
        dividendTracker.setMinTokenBalanceForRewards(amount);
    }

     //////////////////////
    // Getter Functions //
   //////////////////////

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

    function getLastProcessedIndex() external view returns(uint256) {
    	return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

     ////////////////////////
    // Transfer Functions //
   ////////////////////////

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
    
        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

		uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if( canSwap && !swapping && swapEnabled && !automatedMarketMakerPairs[from]) {
            swapping = true;

            contractTokenBalance = swapTokensAtAmount;

            if(ecosystemFee > 0){
                uint256 swapTokens = contractTokenBalance.mul(ecosystemFee).div(totalFees);
                swapForEcosystem(swapTokens);
            }
            if(DOGERewardsFee > 0){
                uint256 sellTokens = contractTokenBalance.mul(DOGERewardsFee).div(totalFees);
                swapAndSendDividends(sellTokens);
            }

            swapping = false;
        }

        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {
            uint256 fees = amount.mul(totalFees).div(100);
            amount = amount.sub(fees);
            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);

        try dividendTracker.setBalance(from, balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(to, balanceOf(to)) {} catch {}

        if(!swapping) {
	    	uint256 gas = gasForProcessing;

	    	try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
	    		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
	    	}
	    	catch {}
        }
    }

    function swapForEcosystem(uint256 tokens) private {
        uint256 initialBalance = address(this).balance;

        swapTokensForBNB(tokens);

        uint256 deltaBalance = address(this).balance - initialBalance;

        if(deltaBalance > 0){
            payable(ecosystemWallet).sendValue(deltaBalance);
        }
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
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

    function swapTokensForDOGE(uint256 tokenAmount) private {

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = router.WETH();
        path[2] = DOGE;

        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapAndSendDividends(uint256 tokens) private{
        swapTokensForDOGE(tokens);
        uint256 dividends = IERC20(DOGE).balanceOf(address(this));
        bool success = IERC20(DOGE).transfer(address(dividendTracker), dividends);

        if (success) {
            dividendTracker.distributeDOGEDividends(dividends);
            emit SendDividends(tokens, dividends);
        }
    }

    function distributeMiningRewards(uint256 tokens) external{
        require(_isExcludedFromFees[msg.sender], "Only excluded from fees addresses can call this");
        bool success = IERC20(DOGE).transferFrom(msg.sender, address(dividendTracker), tokens);
        if (success) {
            dividendTracker.distributeDOGEDividends(tokens);
        }
    }
}

contract EDOGDividendTracker is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping (address => bool) public excludedFromDividends;

    mapping (address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account, bool value);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor()  DividendPayingToken("EDOG_Dividen_Tracker", "EDOG_Dividend_Tracker") {
    	claimWait = 3600;
    	minimumTokenBalanceForDividends = 100_000 * (10**18);
    }

    function _transfer(address, address, uint256) internal pure override {
        require(false, "EDOG_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public pure override {
        require(false, "EDOG_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main EDOG contract.");
    }

    function setMinTokenBalanceForRewards(uint256 amount) external onlyOwner{
        minimumTokenBalanceForDividends = amount * 10**18;
    }

    function excludeFromDividends(address account, bool value) external onlyOwner {
    	require(excludedFromDividends[account] != value);
    	excludedFromDividends[account] = value;
      if(value == true){
        _setBalance(account, 0);
        tokenHoldersMap.remove(account);
      }
      else{
        _setBalance(account, balanceOf(account));
        tokenHoldersMap.set(account, balanceOf(account));
      }
      emit ExcludeFromDividends(account, value);

    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "EDOG_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "EDOG_Dividend_Tracker: Cannot update claimWait to same value");
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
    

    function setBalance(address account, uint256 newBalance) public onlyOwner {
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
    			if(processAccount(account, true)) {
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

    function processAccount(address account, bool automatic) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);

    	if(amount > 0) {
    		lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
    		return true;
    	}

    	return false;
    }
}