// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

import "./DividendPayingToken.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";

contract DeFeed is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;

    bool private swapping;
    bool public tpbDist;

    DeFeedDividendTracker public dividendTracker;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public marketingWallet = 0xcABcCA534656dB56c3D5EAe51400481071d36179;
    address public theProsperityBankWallet = 0xa97628819dcf3d8570a2f7b5e83776D006Df583b;

    address public immutable BUSD = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); //BUSD

    uint256 public swapTokensAtAmount = 2000000 * (10**18);

    mapping(address => bool) public _isBlacklisted;

    uint256 public buyBUSDRewardsFee = 10;
    uint256 public sellBUSDRewardsFee = 10;
    uint256 public totalBUSDRewardsFee = buyBUSDRewardsFee.add(sellBUSDRewardsFee);

    uint256 public buyLiquidityFee = 4;
    uint256 public sellLiquidityFee = 4;
    uint256 public totalLiquidityFee = buyLiquidityFee.add(sellLiquidityFee);

    uint256 public buyMarketFee = 2;
    uint256 public sellMarketFee = 2;
    uint256 public totalMarketFee = buyMarketFee.add(sellMarketFee);

    uint256 public buyTpbFee = 2;
    uint256 public sellTpbFee = 2;
    uint256 public totalTpbFee = buyTpbFee.add(sellTpbFee);   

    uint256 public totalBuyFees = buyBUSDRewardsFee.add(buyLiquidityFee).add(buyMarketFee).add(buyTpbFee);
    uint256 public totalSellFees = sellBUSDRewardsFee.add(sellLiquidityFee).add(sellMarketFee).add(sellTpbFee);
    uint256 public totalFees = totalBuyFees.add(totalSellFees);
    uint256 public coolDownTPB = 604800;
    uint256 public minimumTokenBalanceForTheProsperityBank = 1000000000 * (10**18);
    uint256 public lastTimeProcessedTPB = 0;
    
    bool public indexProcessed = false;

    uint256 public txfee = 1;    


    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;

     // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;


    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);

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
    
    event FeesSent(
        uint256 tokensSwapped,
        uint256 busdSent
    );

    event ProcessedDividendTracker(
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas,
    	address indexed processor
    );

    constructor() public ERC20("DeFeed", "DeFeed") {
        require(buyBUSDRewardsFee.add(buyLiquidityFee).add(buyMarketFee).add(buyTpbFee) <= 25, "Total buy fee is under 25%");
        require(sellBUSDRewardsFee.add(sellLiquidityFee).add(sellMarketFee).add(sellTpbFee) <= 25, "Total sell fee is under 25%");        

    	dividendTracker = new DeFeedDividendTracker();

        //Pancake Mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        //Pancake Testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3

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
        dividendTracker.excludeFromDividends(deadWallet);
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));
        dividendTracker.excludeFromDividends(address(marketingWallet));
        dividendTracker.excludeFromDividends(address(theProsperityBankWallet));

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(theProsperityBankWallet), true);
        excludeFromFees(address(marketingWallet), true);
        

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), 1000000000 * (10**18));
    }

    receive() external payable {

  	}
  	
  	function setNotValidForTPB(address _liquidityPool) public onlyOwner {
  	    dividendTracker.setNotValidForTPB(_liquidityPool);
  	}
  	
  	function viewifTrue() public view returns(bool) {
  	    if(lastTimeProcessedTPB != 0) {
  	        return lastTimeProcessedTPB.add(coolDownTPB) <= block.timestamp;
  	    } else
  	    if(lastTimeProcessedTPB == 0) {
  	        return false;
  	    }
  	}
  	
  	function runTPB() public {
  	    
  	    if(viewifTrue() == true) {
  	        lastTimeProcessedTPB = block.timestamp;
  	        tpbDist = true;
  	        dividendTracker.populateTheProsperityBank(gasForProcessing);
  	    }       

  	}
  	
  	function distTPB() public {
  	    
  	    if(tpbDist == true) {
  	        tpbDist = false;
  	        dividendTracker.processTheProsperityBank(gasForProcessing);
  	    }
  	    
  	}
  	
  	function setMinimumSwapAmount(uint256 _minSwap) public onlyOwner {
  	    swapTokensAtAmount = _minSwap;
  	}
  	
  	function setDFD(IERC20 _DeFeedToken) public onlyOwner {
  	    dividendTracker.setDFD(_DeFeedToken);
  	}

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "DeFeed: The dividend tracker already has that address");

        DeFeedDividendTracker newDividendTracker = DeFeedDividendTracker(payable(newAddress));

        require(newDividendTracker.owner() == address(this), "DeFeed: The new dividend tracker must be owned by the DeFeed token contract");

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));
        newDividendTracker.excludeFromDividends(address(marketingWallet));
        newDividendTracker.excludeFromDividends(address(theProsperityBankWallet));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "DeFeed: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "DeFeed: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }
    
    function setTheProsperityBankWallet(address payable wallet) external onlyOwner {
        theProsperityBankWallet = wallet;
        dividendTracker.setTheProsperityBankWallet(wallet);
    }
    
    function setMarketingWallet(address payable wallet) external onlyOwner {
        marketingWallet = wallet;
    }

    function setBuyTaxes(uint256 liquidity, uint256 busdRewardsFee, uint256 marketFee, uint256 tpbFee) external onlyOwner {
        require(busdRewardsFee.add(liquidity).add(marketFee).add(tpbFee) <= 25, "Total buy fee is over 25%");
        buyBUSDRewardsFee = busdRewardsFee;
        buyLiquidityFee = liquidity;
        buyMarketFee = marketFee;
        buyTpbFee = tpbFee;
    }

    function setSellTaxes(uint256 liquidity, uint256 busdRewardsFee, uint256 marketFee, uint256 tpbFee) external onlyOwner {
        require(busdRewardsFee.add(liquidity).add(marketFee).add(tpbFee) <= 25, "Total sell fee is over 25%");
        sellBUSDRewardsFee = busdRewardsFee;
        sellLiquidityFee = liquidity;
        sellMarketFee = marketFee;
        sellTpbFee = tpbFee;
    }    
    
    function setTxFee(uint _value) external onlyOwner {
        txfee = _value;
    }

    function setCoolDownTPB(uint256 _time) public onlyOwner {
        coolDownTPB = _time;
    }

    function startThePresperityBank() public onlyOwner {
        require(lastTimeProcessedTPB == 0);
        lastTimeProcessedTPB = block.timestamp;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "DeFeed: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function blacklistAddress(address account, bool value) external onlyOwner{
        _isBlacklisted[account] = value;
    }


    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "DeFeed: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "DeFeed: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "DeFeed: Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function sendContractBalance(address payable to) public onlyOwner {
        require(address(this).balance > 0,"07");
        to.transfer(address(this).balance);
    }

    function withdrawExcess() public onlyOwner {
        dividendTracker.withdrawExcess();
    }

    function rescueToken(address tokenAddress, uint256 tokens,address _receiver) external onlyOwner returns (bool success){
        return IERC20(tokenAddress).transfer(_receiver, tokens);
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


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], 'Blacklisted address');

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

		uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if( canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            from != owner() &&
            to != owner()
        ) {
            swapping = true;

            uint256 swapTokens = contractTokenBalance.mul(totalLiquidityFee).div(totalFees);
            uint256 marketTokens = contractTokenBalance.mul(totalMarketFee).div(totalFees);
            uint256 tpbTokens = contractTokenBalance.mul(totalTpbFee).div(totalFees);
            
            swapAndLiquify(swapTokens);
            swapAndSendFees(marketingWallet, marketTokens);
            swapAndSendFees(theProsperityBankWallet, tpbTokens);
            

            uint256 sellTokens = balanceOf(address(this));
            swapAndSendDividends(sellTokens);
            
            if(viewifTrue() == true) {
                runTPB();
            }
            
            if(tpbDist == true) {
                distTPB();
            }

            swapping = false;
            
        }


        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee && automatedMarketMakerPairs[to] || takeFee && automatedMarketMakerPairs[from]) {
        	uint256 fees = amount.mul(totalFees).div(100);
        	if(automatedMarketMakerPairs[to]){
        	    fees += amount.mul(1).div(100);
        	}
        	amount = amount.sub(fees);

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
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }


    function swapTokensForEth(uint256 tokenAmount) private {


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

    function swapTokensForBUSD(uint256 tokenAmount) private {

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = BUSD;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
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
            address(0),
            block.timestamp
        );

    }

    function swapAndSendDividends(uint256 tokens) private{
        swapTokensForBUSD(tokens);
        uint256 dividends = IERC20(BUSD).balanceOf(address(this));
        bool success = IERC20(BUSD).transfer(address(dividendTracker), dividends);

        if (success) {
            dividendTracker.distributeBUSDDividends(dividends);
            emit SendDividends(tokens, dividends);
        }
    }
    
    function swapAndSendFees(address _to, uint256 tokens) private {
        swapTokensForBUSD(tokens);
        uint256 swappedAmt = IERC20(BUSD).balanceOf(address(this));
        
        bool success = IERC20(BUSD).transfer(address(_to), swappedAmt);
        
        if(success) {
            emit FeesSent(tokens, swappedAmt);
        }
    }
    
}

contract DeFeedDividendTracker is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;
    
    IERC20 public DFD;

    mapping (address => bool) public excludedFromDividends;

    mapping (address => uint256) public lastClaimTimes;
    
    mapping (address => bool) public eligibleForTPB;

    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;
    uint256 public balanceForUse;
    
    address payable _theProsperityBankAddress;
    
    uint256 public minimumTokenBalanceForTheProsperityBank;
    address public notValidForTPB;
    uint256 public numberEligible = 0;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor() public DividendPayingToken("DeFeed_Dividen_Tracker", "DeFeed_Dividend_Tracker") {
    	claimWait = 10;
        minimumTokenBalanceForDividends = 2000000 * (10**18); //must hold 2000000+ tokens
        minimumTokenBalanceForTheProsperityBank = 1000000000 * (10**18);
    }
    
    function setNotValidForTPB(address _liquidityPool) external onlyOwner {
        notValidForTPB = _liquidityPool;
    }
    
    function setDFD(IERC20 _DeFeedToken) external onlyOwner {
        DFD = _DeFeedToken;
    }
    
    function setMinimumTokensTPB(uint256 _minAmountTPB) external onlyOwner {
        minimumTokenBalanceForTheProsperityBank = _minAmountTPB;
    }
    
    function setTheProsperityBankWallet(address payable _wallet) external onlyOwner {
        _theProsperityBankAddress = _wallet;
    }

    function _transfer(address, address, uint256) internal override {
        require(false, "DeFeed_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public override {
        require(false, "DeFeed_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main DeFeed contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
    	require(!excludedFromDividends[account]);
    	excludedFromDividends[account] = true;

    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);

    	emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 1 && newClaimWait <= 86400, "DeFeed_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "DeFeed_Dividend_Tracker: Cannot update claimWait to same value");
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
    
    function populateTheProsperityBank(uint256 gas) external onlyOwner returns(uint256, uint256) {

        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;
        
        if(numberOfTokenHolders == 0) {
    		return (0, 0);
    	}

    	uint256 _lastProcessedIndex = lastProcessedIndex;

    	uint256 gasUsed = 0;

    	uint256 gasLeft = gasleft();

    	uint256 iterations = 0;
    	
    	while(gasUsed < gas && iterations < numberOfTokenHolders) {
    		_lastProcessedIndex++;

    		if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {
    			_lastProcessedIndex = 0;
    		}

    		address account = tokenHoldersMap.keys[_lastProcessedIndex];
    		
            if(IERC20(DFD).balanceOf(account) < minimumTokenBalanceForTheProsperityBank && eligibleForTPB[account] == true) {
    		    eligibleForTPB[account] = false;
    		} else
    	    if(IERC20(DFD).balanceOf(account) >= minimumTokenBalanceForTheProsperityBank && eligibleForTPB[account] == false || eligibleForTPB[account] == true) {
    		    eligibleForTPB[account] = true;
    		    numberEligible = numberEligible.add(1);
    		}
    		
    		iterations++;

    		uint256 newGasLeft = gasleft();

    		if(gasLeft > newGasLeft) {
    			gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
    		}

    		gasLeft = newGasLeft;
    	}

    	lastProcessedIndex = _lastProcessedIndex;
    	
    	return (iterations, lastProcessedIndex);
    	
    }
    
    function processTheProsperityBank(uint256 gas) external onlyOwner returns(uint256, uint256) {
        
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;
        
        if(numberOfTokenHolders == 0) {
    		return (0,0);
    	}

    	uint256 _lastProcessedIndex = lastProcessedIndex;

    	uint256 gasUsed = 0;

    	uint256 gasLeft = gasleft();

    	uint256 iterations = 0;
    	
    	while(gasUsed < gas && iterations < numberOfTokenHolders) {
    		_lastProcessedIndex++;

    		if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {
    			_lastProcessedIndex = 0;
    		}

    		address account = tokenHoldersMap.keys[_lastProcessedIndex];
    		
    		if(eligibleForTPB[account] == true) {
    		    uint256 startingBalance;
    		    uint256 sendAmount;
    		    
    		        if(balanceForUse == 0) {
              		    startingBalance = IERC20(BUSD).balanceOf(address(_theProsperityBankAddress));
    		            balanceForUse = startingBalance;
    		        }
    		        
    		    sendAmount = balanceForUse.div(numberEligible);
    		    IERC20(BUSD).transferFrom(_theProsperityBankAddress, account, sendAmount);
    		}
    		
    		iterations++;

    		uint256 newGasLeft = gasleft();

    		if(gasLeft > newGasLeft) {
    			gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
    		}

    		gasLeft = newGasLeft;
    	}

    	lastProcessedIndex = _lastProcessedIndex;
    	
        balanceForUse = 0;
        
        numberEligible = 0;
    	
    	return (iterations, lastProcessedIndex);
    }
}