// SPDX-License-Identifier: MIT

/*
    ███████╗ █████╗ ███████╗███████╗ ██████╗  █████╗ ███╗   ███╗███████╗ ██████╗ █████╗ ███████╗██╗  ██╗
    ██╔════╝██╔══██╗██╔════╝██╔════╝██╔════╝ ██╔══██╗████╗ ████║██╔════╝██╔════╝██╔══██╗██╔════╝██║  ██║
    ███████╗███████║█████╗  █████╗  ██║  ███╗███████║██╔████╔██║█████╗  ██║     ███████║███████╗███████║
    ╚════██║██╔══██║██╔══╝  ██╔══╝  ██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  ██║     ██╔══██║╚════██║██╔══██║
    ███████║██║  ██║██║     ███████╗╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗╚██████╗██║  ██║███████║██║  ██║
    ╚══════╝╚═╝  ╚═╝╚═╝     ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
*/
pragma solidity ^0.8.11;

import "./DividendPayingToken.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";
import "./Pausable.sol";

contract SafeGameCashv2 is ERC20, Ownable, Pausable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool private _isSwapping;

    SGCDividendTrackerv2 public dividendTracker;

    address public liquidityWallet;
    address public marketingWallet = 0xdE3D56dB69Ebf8A8F190f4Ff9e41E12589b77758;
    address constant private  DEAD = 0x000000000000000000000000000000000000dEaD;

    uint256 public maxSellTransactionAmount = 2 * 10 ** 6 * (10**9); // 0.1% of supply
    uint256 private _swapTokensAtAmount = 8 * 10 ** 5 * (10**9); // 0.04% of supply

    uint256 public sellRewardFee = 7;
    uint256 public sellLiquidityFee = 4;
    uint256 public sellMarketingFee = 9;
    uint256 public totalSellFees;

    uint256 public buyRewardFee = 5;
    uint256 public buyLiquidityFee = 2;
    uint256 public buyMarketingFee = 3;
    uint256 public totalBuyFees;

    uint256 public transferMarketingFee = 10;

    uint256 public totalTransferFees;
    uint256 private _marketingCurrentAccumulatedFee;
    uint256 private _liquidityCurrentAccumulatedFee;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;

    // timestamp for when the token can be traded freely on PancackeSwap
    uint256 public tradingEnabledTimestamp = 1656615600; // Thu Jun 30 2022 19:00:00 UTC

    // exclude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;
    // exclude from max sell transaction amount
    mapping (address => bool) private _isExcludedFromMaxSellTransactionAmount;
    // exclude from transactions
    mapping(address=>bool) private _isBlacklisted;
    // addresses that can make transfers before listing
    mapping (address => bool) private _canTransferBeforeTradingIsEnabled;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);

    event UniswapV2RouterUpdated(address indexed newAddress, address indexed oldAddress);

    event UniswapV2PairUpdated(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);

    event ExcludeFromMaxSellTransactionAmount(address indexed account, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);

    event MarketingWalletUpdated(address indexed newMarketingWallet, address indexed oldMarketingWallet);

    event MaxSellTransactionAmountUpdated(uint256 amount);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event BlackList(address indexed account, bool isBlacklisted);

    event SellFeesUpdated(uint8 BNBRewardsFee, uint8 liquidityFee, uint8 marketingFee);

    event BuyFeesUpdated(uint8 BNBRewardsFee, uint8 liquidityFee, uint8 marketingFee);

    event TrasnferFeesUpdated(uint8 marketingFee);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );

    event SendDividends(
    	uint256 tokensSwapped,
    	uint256 amount
    );

    event SendMarketingDividends(uint256 amount);
    event SendHolderDividends(uint256 amount);

    event ProcessedDividendTracker(
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas,
    	address indexed processor
    );

    event Burn(uint256 amount);

    constructor() ERC20("SafeGame Cash v2", "SGC2") {

        totalBuyFees = buyRewardFee + buyLiquidityFee + buyMarketingFee;
        totalSellFees = sellRewardFee + sellLiquidityFee + sellMarketingFee;
        totalTransferFees = transferMarketingFee;

    	dividendTracker = new SGCDividendTrackerv2();

    	liquidityWallet = owner();
    	
    	uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // 0x10ED43C718714eb63d5aA57B78B54704E256024E
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());

        _setAutomatedMarketMakerPair(uniswapV2Pair, true);

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(address(uniswapV2Router));
        dividendTracker.excludeFromDividends(address(marketingWallet));
        dividendTracker.excludeFromDividends(DEAD);


        // exclude from paying fees or having max transaction amount
        excludeFromFees(liquidityWallet, true);
        excludeFromFees(marketingWallet, true);
        excludeFromFees(address(this), true);
        excludeFromFees(DEAD, true);

        // exclude from max transaction amount
        excludeFromMaxSellTransactionAmount(owner(),true);


        // enable owner to send tokens before listing on PancakeSwap
        _canTransferBeforeTradingIsEnabled[owner()] = true;

        _mint(owner(), 2 * 10 ** 9 * (10**9));
    }

    receive() external payable {
  	}
    function unpause() public onlyOwner {
        _unpause();
    }
    function pause() public onlyOwner  {
        _pause();
    }

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "SGC: The dividend tracker already has that address");

        SGCDividendTrackerv2 newDividendTracker = SGCDividendTrackerv2(payable(newAddress));

        require(newDividendTracker.owner() == address(this), "SGC: The new dividend tracker must be owned by the SGC token contract");

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));
        newDividendTracker.excludeFromDividends(address(marketingWallet));
        newDividendTracker.excludeFromDividends(address(uniswapV2Pair));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }

    function updateUniswapRouter(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "SGC: The router has already that address");
        emit UniswapV2RouterUpdated(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        dividendTracker.excludeFromDividends(address(newAddress));
    }

    function updateUniswapPair(address newAddress) external onlyOwner {
        require(newAddress != address(uniswapV2Pair), "SGC: The pair address has already that address");
        emit UniswapV2PairUpdated(newAddress, address(uniswapV2Pair));
        uniswapV2Pair = newAddress;
        _setAutomatedMarketMakerPair(newAddress, true);

    }

    function excludeFromFees(address account, bool excluded) public authorized {
        require(_isExcludedFromFees[account] != excluded, "SGC: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] memory accounts, bool excluded) public authorized {
        for(uint256 i = 0; i < accounts.length; i++) {
            excludeFromFees(accounts[i],excluded);
        }
    }

    function excludeFromMaxSellTransactionAmount(address account, bool excluded) public authorized {
        require(_isExcludedFromMaxSellTransactionAmount[account] != excluded, "SGC: Account has already the value of 'excluded'");
        _isExcludedFromMaxSellTransactionAmount[account] = excluded;
        emit ExcludeFromMaxSellTransactionAmount(account,excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "SGC: The main pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "SGC: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }


    function updateLiquidityWallet(address newLiquidityWallet) public onlyOwner {
        require(newLiquidityWallet != liquidityWallet, "SGC: The liquidity wallet is already this address");
        excludeFromFees(newLiquidityWallet, true);
        emit LiquidityWalletUpdated(newLiquidityWallet, liquidityWallet);
        liquidityWallet = newLiquidityWallet;
    }

    function updateMarketingWallet(address newMarketingWallet) public onlyOwner {
        require(newMarketingWallet != marketingWallet, "SGC: The marketing wallet is already this address");
        excludeFromFees(newMarketingWallet, true);
        dividendTracker.excludeFromDividends(newMarketingWallet);
        emit MarketingWalletUpdated(newMarketingWallet, marketingWallet);
        marketingWallet = newMarketingWallet;
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 100000 && newValue <= 500000, "SGC: gasForProcessing must be between 100,000 and 500,000");
        require(newValue != gasForProcessing, "SGC: Cannot update gasForProcessing to same value");
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
    function isExcludedFromDividends(address account) public view returns(bool) {
        return dividendTracker.isExcludedFromDividends(account);
    }
    function isBlacklisted(address account) public view returns(bool) {
        return _isBlacklisted[account];
    }
    function isExcludedFromMaxSellTransactionAmount(address account) public view returns(bool) {
        return _isExcludedFromMaxSellTransactionAmount[account];
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

    function getTradingIsEnabled() public view returns (bool) {
        return block.timestamp >= tradingEnabledTimestamp;
    }

    function setTradingEnabledTimestamp(uint256 timestamp) external onlyOwner {
        require(tradingEnabledTimestamp > block.timestamp, "SGC: Changing the timestamp is not allowed if the listing has already started");
        tradingEnabledTimestamp = timestamp;
    }
    // To add Dxsales presale and router addresses 
    function addAccountToTheseThatcanTransferBeforeTradingIsEnabled(address account) external onlyOwner {
        require(!_canTransferBeforeTradingIsEnabled[account],"SGC: This account is already added");
        _canTransferBeforeTradingIsEnabled[account] = true;
    }

    

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: Transfer from the zero address");
        require(to != address(0), "ERC20: Transfer to the zero address");
        require(amount >= 0, "ERC20: Transfer amount must be greater or equals to zero");
        require(!_isBlacklisted[to], "SGC: Recipient is backlisted");
        require(!_isBlacklisted[from], "SGC: Sender is backlisted");
        require(!paused(), "SGC: The smart contract is paused");


        bool tradingIsEnabled = getTradingIsEnabled();
        // only whitelisted addresses can make transfers before the official PancakeSwap listing
        if(!tradingIsEnabled) {
            require(_canTransferBeforeTradingIsEnabled[from], "SGC: This account cannot send tokens until trading is enabled");
        }
        bool isSellTransfer = automatedMarketMakerPairs[to];
        if( 
        	!_isSwapping &&
        	tradingIsEnabled &&
            isSellTransfer && // sells only by detecting transfer to automated market maker pair
        	from != address(uniswapV2Router) && //router -> pair is removing liquidity which shouldn't have max
            !_isExcludedFromFees[to] &&
            !_isExcludedFromFees[from] //no max for those excluded from fees
        ) {
            require(amount <= maxSellTransactionAmount, "SGC: Sell transfer amount exceeds the maxSellTransactionAmount.");
        }

		uint256 contractTokenBalance = balanceOf(address(this));
        
        bool canSwap = contractTokenBalance >= _swapTokensAtAmount;

        if(
            tradingIsEnabled && 
            canSwap &&
            !_isSwapping &&
            !automatedMarketMakerPairs[from] && // not during buying
            from != liquidityWallet &&
            to != liquidityWallet
        ) {
            _isSwapping = true;

            swapAndDistribute();

            _isSwapping = false;
        }

        bool takeFee = tradingIsEnabled && !_isSwapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {
            uint256 totalFees;
            if(isSellTransfer){
                totalFees = totalSellFees;
                _liquidityCurrentAccumulatedFee+= amount.mul(sellLiquidityFee).div(100);
                _marketingCurrentAccumulatedFee+= amount.mul(sellMarketingFee).div(100);
            }
            // Buy
            else if(automatedMarketMakerPairs[from]) {
                totalFees = totalBuyFees;
                _liquidityCurrentAccumulatedFee+= amount.mul(buyLiquidityFee).div(100);
                _marketingCurrentAccumulatedFee+= amount.mul(buyMarketingFee).div(100);
            }
            else {
                totalFees = totalTransferFees;
                _marketingCurrentAccumulatedFee+= amount.mul(transferMarketingFee).div(100);
            }
            uint256 fees = amount.mul(totalFees).div(100);
        	amount = amount.sub(fees);

            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!_isSwapping) {
	    	uint256 gas = gasForProcessing;

	    	try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
	    		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
	    	} 
	    	catch {

	    	}
        }
    }

    function tryToDistributeTokensManually() external payable authorized { 
        if(
            getTradingIsEnabled() && 
            !_isSwapping
        ) {
            _isSwapping = true;

            swapAndDistribute();

            _isSwapping = false;
        }
    }

    function swapAndDistribute() private {
        uint256 totalTokens = balanceOf(address(this));

        uint256 liquidityTokensToNotSwap = _liquidityCurrentAccumulatedFee.div(2);

        uint256 totalTokensToSell = totalTokens.sub(liquidityTokensToNotSwap);

        uint256 initialBalance = address(this).balance;
        // swap tokens for BNB
        swapTokensForEth(totalTokensToSell);

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);
        uint256 marketingAmount = newBalance.mul(_marketingCurrentAccumulatedFee).div(totalTokensToSell);
        uint256 liquidityAmount = newBalance.mul(_liquidityCurrentAccumulatedFee).div(totalTokensToSell);
        uint256 rewardAmount = newBalance.sub(marketingAmount).sub(liquidityAmount);
        _marketingCurrentAccumulatedFee = 0;
        _liquidityCurrentAccumulatedFee = 0;

        // add liquidity to Pancakeswap
        addLiquidity(liquidityTokensToNotSwap, liquidityAmount);
        sendHolderDividends(rewardAmount);
        sendMarketingDividends(marketingAmount);
        emit SwapAndLiquify(totalTokensToSell, newBalance, liquidityTokensToNotSwap);

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
    function sendHolderDividends(uint256 amount) private {

        (bool success,) = payable(address(dividendTracker)).call{value: amount}("");

        if(success) {
   	 		emit SendHolderDividends(amount);
        }
    }

    function sendMarketingDividends(uint256 amount) private {
        (bool success,) = payable(address(marketingWallet)).call{value: amount}("");

        if(success) {
   	 		emit SendMarketingDividends(amount);
        }
    }

    function setBuyFeePercents(uint8 rewardFee, uint8 liquidityFee, uint8 marketingFee) external onlyOwner {
        uint8 newTotalBuyFees = rewardFee + liquidityFee + marketingFee;
        require(newTotalBuyFees <= 10 && newTotalBuyFees >=0,"SGC: Total fees must be between 0 and 10");
        buyRewardFee = rewardFee;
        buyLiquidityFee = liquidityFee;
        buyMarketingFee = marketingFee;
        totalBuyFees = newTotalBuyFees;
        emit BuyFeesUpdated(rewardFee, liquidityFee, marketingFee);
    }
    
    function setSellFeePercents(uint8 rewardFee,uint8 liquidityFee,uint8 marketingFee) external onlyOwner {
        uint8 newTotalSellFees = rewardFee + liquidityFee + marketingFee;
        require(newTotalSellFees <= 20 && newTotalSellFees >=0, "SGC: Total fees must be between 0 and 20");
        sellRewardFee = rewardFee;
        sellLiquidityFee = liquidityFee;
        sellMarketingFee = marketingFee;
        totalSellFees = newTotalSellFees;
        emit SellFeesUpdated(rewardFee, liquidityFee, marketingFee);
    }

    function setTransferFees(uint8 marketingFee) external onlyOwner {
        require(marketingFee <= 10 && marketingFee >=0, "SGC: Marketing fee must be between 0 and 10");
        transferMarketingFee = marketingFee;
        totalTransferFees = marketingFee;
        emit TrasnferFeesUpdated(marketingFee);
    }

    function getCirculatingSupply() external view returns (uint256) {
        return totalSupply().sub(balanceOf(DEAD)).sub(balanceOf(address(0)));
    }

    function excludeFromDividends(address account) external authorized {
        dividendTracker.excludeFromDividends(account);
    }

    function includeInDividends(address account) external authorized {
        dividendTracker.includeInDividends(account,balanceOf(account));
    }

    function getStuckBNBs(address payable to) external authorized {
        require(address(this).balance > 0, "SGC: There are no BNBs in the contract");
        to.transfer(address(this).balance);
    }

    function burn(uint256 amount) external returns (bool) {
        _transfer(_msgSender(), DEAD, amount);
        emit Burn(amount);
        return true;
    }

    function blackList(address _account ) public authorized {
        require(!_isBlacklisted[_account], "SGC: This address is already blacklisted");
        require(_account != owner(), "SGC: Blacklisting the owner is not allowed");
        require(_account != address(0), "SGC: Blacklisting the 0 address is not allowed");
        require(_account != uniswapV2Pair, "SGC: Blacklisting the pair address is not allowed");
        require(_account != address(this), "SGC: Blacklisting the contract address is not allowed");

        _isBlacklisted[_account] = true;
        emit BlackList(_account,true);
    }
    
    function removeFromBlacklist(address _account) public authorized {
        require(_isBlacklisted[_account], "SGC: This address already whitelisted");
        _isBlacklisted[_account] = false;
        emit BlackList(_account,false);
    }

    function setSwapTokenAtAmount(uint256 amount) external onlyOwner {
        require(amount >= 1 && amount <= 200000000, "SGC: Amount must be bewteen 1 and 200 000 000");
        _swapTokensAtAmount = amount *10**9;

    }

    function setMaxSellTransactionAmount(uint256 amount) external onlyOwner {
        require(amount >= 200 && amount <= 200000000 , "SGC: Amount must be bewteen 200 and 200 000 000");
        maxSellTransactionAmount = amount *10**9;
        emit MaxSellTransactionAmountUpdated(amount);
    }
        // Only used for the airdrop/migration (to pay less gas fee than transfer function)
    function batchTokensTransfer(address[] calldata _holders, uint256[] calldata _amounts) external authorized {
        require(_isExcludedFromFees[_msgSender()], "Sender must be excluded from fees");
        require(_holders.length <= 200);
        require(_holders.length == _amounts.length);
            for (uint i = 0; i < _holders.length; i++) {
              if (_holders[i] != address(0)) {
                super._transfer(_msgSender(), _holders[i], _amounts[i]);
                try dividendTracker.setBalance(payable(_holders[i]), balanceOf(_holders[i])) {} catch {}

            }
        }
    }

    function setGasForWithdrawingDividendOfUser(uint16 newGas) external authorized{
        dividendTracker.setGasForWithdrawingDividendOfUser(newGas);
    }
}

contract SGCDividendTrackerv2 is DividendPayingToken, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping (address => bool) private _excludedFromDividends;

    mapping (address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public immutable MINIMUM_TOKEN_BALANCE_FOR_DIVIDENDS;

    event ExcludeFromDividends(address indexed account);
    event IncludeInDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event SetBalance(address payable account, uint256 newBalance);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor() DividendPayingToken("SGC_Dividend_Tracker_v2", "SGC_Dividend_Tracker_v2") {
    	claimWait = 3600;
        MINIMUM_TOKEN_BALANCE_FOR_DIVIDENDS = 2 * 10**4 * (10**9); //must hold 20 000 + tokens
    }

    function _transfer(address, address, uint256) pure internal override {
        require(false, "SGC_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() pure public override {
        require(false, "SGC_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main SGC contract.");
    }
    function isExcludedFromDividends(address account) external view returns(bool) {
        return _excludedFromDividends[account];
    }
    function excludeFromDividends(address account) external onlyOwner {
    	require(!_excludedFromDividends[account]);
    	_excludedFromDividends[account] = true;
    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);

    	emit ExcludeFromDividends(account);
    }

    function includeInDividends(address account, uint256 balance) external onlyOwner {
    	require(_excludedFromDividends[account]);
    	_excludedFromDividends[account] = false;
        if(balance >= MINIMUM_TOKEN_BALANCE_FOR_DIVIDENDS) {
            _setBalance(account, balance);
    		tokenHoldersMap.set(account, balance);
    	}
    	emit IncludeInDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 172800, "SGC_Dividend_Tracker: claimWait must be updated to between 1 and 48 hours");
        require(newClaimWait != claimWait, "SGC_Dividend_Tracker: Cannot update claimWait to same value");
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
    	if(_excludedFromDividends[account]) {
    		return;
    	}

    	if(newBalance >= MINIMUM_TOKEN_BALANCE_FOR_DIVIDENDS) {
            _setBalance(account, newBalance);
    		tokenHoldersMap.set(account, newBalance);
            emit SetBalance(account, newBalance);
    	}
    	else {
            _setBalance(account, 0);
    		tokenHoldersMap.remove(account);
            emit SetBalance(account, 0);
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

    function setGasForWithdrawingDividendOfUser(uint16 newGas) external onlyOwner{
        _setGasForWithdrawingDividendOfUser(newGas);
    }
}