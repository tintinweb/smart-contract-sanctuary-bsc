// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

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

contract CakeCoin is ERC20, Ownable {
    using SafeMath for uint256;
    using Address for address payable;

    address public immutable CAKE = address(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);

    IRouter public router;
    address public  pair;

    bool private swapping;
    bool public swapEnabled = true;

    CakeCoinDividendTracker public dividendTracker;

    uint256 public swapTokensAtAmount = 10_000_000 * (10**18);

    struct Taxes {
        uint256 rewards;
        uint256 lp;
        uint256 marketing;
        uint256 burn;
    }

    Taxes public taxes = Taxes({
        rewards: 5,
        lp: 2,
        marketing: 2,
        burn: 2
    });

    uint256 public totalTax = taxes.rewards + taxes.lp + taxes.marketing + taxes.burn;

    address public marketingWallet = 0x4642F02A1A5755fEeAD4B557c0CE3302D1Ad2550;
    address public lpRecipient = 0x4642F02A1A5755fEeAD4B557c0CE3302D1Ad2550;
    
    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;

    mapping (address => bool) private _isExcludedFromFees;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    event SendDividends(uint256 tokensSwapped,uint256 amount);

    event ProcessedDividendTracker(
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas
    );

     modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }

    constructor()  ERC20("Cake Coin", "cakecoin") {

    	dividendTracker = new CakeCoinDividendTracker();

    	IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a uniswap pair for this new token
        address _pair = IFactory(_router.factory())
            .createPair(address(this), _router.WETH());

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
        excludeFromFees(marketingWallet, true);

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), 100_000_000_000 * (10**18));
    }

    receive() external payable {

  	}


    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "CakeCoin: The dividend tracker already has that address");

        CakeCoinDividendTracker newDividendTracker = CakeCoinDividendTracker(payable(newAddress));

        require(newDividendTracker.owner() == address(this), "CakeCoin: The new dividend tracker must be owned by the CakeCoin token contract");

        newDividendTracker.excludeFromDividends(address(newDividendTracker), true);
        newDividendTracker.excludeFromDividends(address(this), true);
        newDividendTracker.excludeFromDividends(owner(), true);
        newDividendTracker.excludeFromDividends(address(0xdead), true);
        newDividendTracker.excludeFromDividends(address(router), true);

        dividendTracker = newDividendTracker;
    }

    function updateRouter(address newAddress) public onlyOwner {
        require(newAddress != address(router), "CakeCoin: The router already has that address");
        router = IRouter(newAddress);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "CakeCoin: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

    }


    function setAutomatedMarketMakerPair(address newPair, bool value) public onlyOwner {
        require(newPair != pair, "CakeCoin: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(newPair, value);
    }

    function excludeFromDividends(address account, bool state) external onlyOwner{
        dividendTracker.excludeFromDividends(account, state);
    }

    function _setAutomatedMarketMakerPair(address newPair, bool value) private {
        automatedMarketMakerPairs[newPair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(newPair, true);
        }
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "CakeCoin: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "CakeCoin: Cannot update gasForProcessing to same value");
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
		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas);
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

    function setFees(uint256 _rewards, uint256 _liquidity, uint256 _marketing, uint256 _burn) external onlyOwner{
        taxes = Taxes(_rewards, _liquidity, _marketing, _burn);
        totalTax = _rewards + _liquidity + _marketing + _burn;
    }

    function setMarketingWallet(address newWallet) external onlyOwner{
        marketingWallet = newWallet;
    }

    function setLpRecipient(address newWallet) external onlyOwner{
        lpRecipient = newWallet;
    }

    function setSwapEnabled(bool value) external onlyOwner{
        swapEnabled = value;
    }

    function setSwapTokensAtAmount(uint256 amount) external onlyOwner{
        swapTokensAtAmount = amount * 10**18;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: can' transfer 0 tokens");

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
        if(canSwap && swapEnabled && !swapping && !automatedMarketMakerPairs[from] && !_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            swapping = true;
            
            if(taxes.lp + taxes.marketing > 0){
                uint256 swapTokens = swapTokensAtAmount * (taxes.lp + taxes.marketing) / totalTax;
                swapAndLiquify(swapTokens);
            }

            if(taxes.rewards > 0){
              uint256 rewardTokens = swapTokensAtAmount * taxes.rewards / totalTax;
              swapAndSendRewards(rewardTokens);
            }
            
            swapping = false;

        }

        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {
        	uint256 fees = amount * (totalTax - taxes.burn) / 100;
            uint256 burnAmt = amount * taxes.burn / 100;
        	amount = amount - fees - burnAmt;
            if(fees > 0) super._transfer(from, address(this), fees);
            if(burnAmt > 0) super._transfer(from, address(0xdead), burnAmt);
        }

        super._transfer(from, to, amount);

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!swapping) {
	    	uint256 gas = gasForProcessing;

	    	try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
	    		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas);
	    	}
	    	catch {

	    	}
        }
    }

    function swapAndLiquify(uint256 tokens) private {
        // Split the contract balance into halves
        uint256 denominator= (taxes.lp + taxes.marketing) * 2;
        uint256 tokensToAddLiquidityWith = tokens * taxes.lp / denominator;
        uint256 toSwap = tokens - tokensToAddLiquidityWith;

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(toSwap);

        uint256 deltaBalance = address(this).balance - initialBalance;
        uint256 unitBalance= deltaBalance / (denominator - taxes.lp);
        uint256 bnbToAddLiquidityWith = unitBalance * taxes.lp;

        if(bnbToAddLiquidityWith > 0){
            // Add liquidity to pancake
            addLiquidity(tokensToAddLiquidityWith, bnbToAddLiquidityWith);
        }
        //send bnb to marketing
        uint256 marketingAmt = unitBalance * 2 * taxes.marketing;
        if(marketingAmt > 0) payable(marketingWallet).sendValue(marketingAmt);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokenAmount);

        // add the liquidity
        try router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            lpRecipient,
            block.timestamp
        ) {} catch {}

    }

    function swapTokensForCAKE(uint256 tokenAmount) private {

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = router.WETH();
        path[2] = CAKE;

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

    function swapTokensForEth(uint256 tokenAmount) private {

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

    function swapAndSendRewards(uint256 tokens) private{
        swapTokensForCAKE(tokens);
        uint256 dividends = IERC20(CAKE).balanceOf(address(this));
        bool success = IERC20(CAKE).transfer(address(dividendTracker), dividends);

        if (success) {
            dividendTracker.distributeCAKEDividends(dividends);
            emit SendDividends(tokens, dividends);
        }
    }

    function rescueBNB(uint weiAmount) external onlyOwner{
        payable(owner()).transfer(weiAmount);
    }

    function rescueBEP20(address tokenAdd, uint256 amount) external onlyOwner{
        IERC20(tokenAdd).transfer(owner(), amount);
    }

  }

contract CakeCoinDividendTracker is Ownable, DividendPayingToken{
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping (address => bool) public excludedFromDividends;

    mapping (address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account, bool state);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor() DividendPayingToken("CakeCoin_DividendTracker", "CakeCoin_DividendTracker") {
    	claimWait = 3600;
        minimumTokenBalanceForDividends = 100_000 * (10**18); //must hold 1,000,000+ tokens
    }

    function _transfer(address, address, uint256) pure internal override {
        require(false, "CakeCoin_DividendTracker: No transfers allowed");
    }

    function withdrawDividend() pure public override {
        require(false, "CakeCoin_DividendTracker: withdrawDividend disabled. Use the 'claim' function on the main Revolver Token contract.");
    }

    function updateMinimumTokenBalanceForDividends(uint256 _newMinimumBalance) external onlyOwner {
        require(_newMinimumBalance != minimumTokenBalanceForDividends, "New mimimum balance for dividend cannot be same as current minimum balance");
        minimumTokenBalanceForDividends = _newMinimumBalance * (10**18);
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
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "CakeCoin_DividendTracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "CakeCoin_DividendTracker: Cannot update claimWait to same value");
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
        external view returns (
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

    function process(uint256 gas) external returns (uint256, uint256, uint256) {
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