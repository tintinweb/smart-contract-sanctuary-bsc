// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./ERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router01.sol";
import "./IUniswapV2Router02.sol";
import "./DividendTracker.sol";
import "./DividendPayingToken.sol";

contract TestKBFF is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    bool private swapping;

    DividendTracker public dividendTracker;
    
    mapping(address => uint256) public holderBNBUsedForBuyBacks;
    

    address public liquidityWallet;
    address public operationsWallet;
    address public teamWallet;
    
    uint256 public swapTokensAtAmount;

    // to track last sell to reduce sell penalty over time by 10% per week the holder sells *no* tokens.
    mapping (address => uint256) public _holderLastSellDate;
    
    // fees
    uint256 public rewardsFee;
    uint256 public liquidityFee;
    uint256 public totalFees;
    uint256 public operationsFee;
    uint256 public buybackFee;
    uint256 public teamFee;
    
    bool public tradingActive;
    bool public swapEnabled;

    uint256 public sellFeeIncreaseFactor = 100; 

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
    event BuyBackWithNoFees(address indexed holder, uint256 indexed bnbSpent);

    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);
    event OperationsWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);
    event BuyBackWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);
    
    event FeesUpdated(uint256 indexed newBNBRewardsFee, uint256 indexed newLiquidityFee, uint256 newOperationsFee, uint256 newBuyBackFee);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SendDividends(
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

    constructor() ERC20("TestKBFF", "TTKBFF", 18) {
        
        uint256 _rewardsFee = 5;
        uint256 _operationsFee = 4;
        uint256 _liquidityFee = 1;
        uint256 _buybackFee = 0;
        uint256 _teamFee = 0;
        
        rewardsFee = _rewardsFee;
        operationsFee = _operationsFee;
        liquidityFee = _liquidityFee;
        buybackFee = _buybackFee;
        teamFee = _teamFee;
        totalFees = rewardsFee + operationsFee + liquidityFee + buybackFee + teamFee;

    	dividendTracker = new DividendTracker();

    	liquidityWallet = owner();
    	operationsWallet = owner();
    	teamWallet = operationsWallet;
        
    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
         // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        

        swapTokensAtAmount = 500000 * (10**18);
        
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));
        dividendTracker.excludeFromDividends(address(0xdead));
        
        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);
        
        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), 10**9 * (10**18));
    }

    receive() external payable {

  	}
  	
  	// @dev Owner functions start -------------------------------------
  	
  	// enable / disable custom AMMs
  	function setWhiteListAMM(address ammAddress, bool isWhiteListed) external onlyOwner {
  	  require(isContract(ammAddress), "TestKBFF: setWhiteListAMM:: AMM is a wallet, not a contract");
      dividendTracker.setWhiteListAMM(ammAddress, isWhiteListed);
    }
    
    // once enabled, can never be turned off
    function enableTrading() external onlyOwner {
        tradingActive = true;
        swapEnabled = true;
    }
    
    // only use to disable contract sales if absolutely necessary (emergency use only)
    function updateSwapEnabled(bool enabled) external onlyOwner(){
        swapEnabled = enabled;
    }
    
    // change the minimum amount of tokens to sell from fees
    function updateSwapTokensAtAmount(uint256 newAmount)
        external
        onlyOwner
        returns (bool)
    {
        require(
            newAmount < totalSupply(),
            "Swap amount cannot be higher than total supply."
        );
        swapTokensAtAmount = newAmount;
        return true;
    }
  	
  	// migration feature (DO NOT CHANGE WITHOUT CONSULTATION)
  	function updateDividendTracker(address newAddress) external onlyOwner {
        require(newAddress != address(dividendTracker), "TestKBFF: The dividend tracker already has that address");

        DividendTracker newDividendTracker = DividendTracker(payable(newAddress));

        require(newDividendTracker.owner() == address(this), "TestKBFF: The new dividend tracker must be owned by the TestKBFF token contract");

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));
        newDividendTracker.excludeFromDividends(address(0xdead));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }
    
    // updates the minimum amount of tokens people must hold in order to get dividends
    function updateDividendTokensMinimum(uint256 minimumToEarnDivs) external onlyOwner {
        dividendTracker.updateDividendMinimum(minimumToEarnDivs);
    }

    // updates the default router for selling tokens
    function updateUniswapV2Router(address newAddress) external onlyOwner {
        require(newAddress != address(uniswapV2Router), "TestKBFF: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }
    
    // updates the default router for buying tokens from dividend tracker
    function updateDividendUniswapV2Router(address newAddress) external onlyOwner {
        dividendTracker.updateDividendUniswapV2Router(newAddress);
    }

    // excludes wallets from max txn and fees.
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    // allows multiple exclusions at once
    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    // excludes wallets and contracts from dividends (such as CEX hotwallets, etc.)
    function excludeFromDividends(address account) external onlyOwner {
        dividendTracker.excludeFromDividends(account);
    }

    // removes exclusion on wallets and contracts from dividends (such as CEX hotwallets, etc.)
    function includeInDividends(address account) external onlyOwner {
        dividendTracker.includeInDividends(account);
    }
    
    // allow adding additional AMM pairs to the list
    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != uniswapV2Pair, "TestKBFF: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }
    
    // for one-time airdrop feature after contract launch
    function airdropToWallets(address[] memory airdropWallets, uint256[] memory amount) external onlyOwner() {
        require(airdropWallets.length == amount.length, "TestKBFF: airdropToWallets:: Arrays must be the same length");
        for(uint256 i = 0; i < airdropWallets.length; i++){
            address wallet = airdropWallets[i];
            uint256 airdropAmount = amount[i];
            super._transfer(msg.sender, wallet, airdropAmount);
            dividendTracker.setBalance(payable(wallet), balanceOf(wallet));
        }
    }
    
    // sets the wallet that receives LP tokens to lock
    function updateLiquidityWallet(address newLiquidityWallet) external onlyOwner {
        require(newLiquidityWallet != liquidityWallet, "TestKBFF: The liquidity wallet is already this address");
        excludeFromFees(newLiquidityWallet, true);
        emit LiquidityWalletUpdated(newLiquidityWallet, liquidityWallet);
        liquidityWallet = newLiquidityWallet;
    }
    
    // updates the operations wallet (marketing, charity, etc.)
    function updateOperationsWallet(address newOperationsWallet) external onlyOwner {
        require(newOperationsWallet != operationsWallet, "TestKBFF: The operations wallet is already this address");
        excludeFromFees(newOperationsWallet, true);
        emit OperationsWalletUpdated(newOperationsWallet, operationsWallet);
        operationsWallet = newOperationsWallet;
    }
    
    function updateTeamWallet(address newWallet) external onlyOwner {
        teamWallet = newWallet;
    }
    

    function updateFees(uint256 _operationsFee, uint256 _rewardsFee, uint256 _liquidityFee, uint256 _buybackFee, uint256 _teamFee) external onlyOwner {
        operationsFee = _operationsFee;
        rewardsFee = _rewardsFee;
        liquidityFee = _liquidityFee;
        buybackFee = _buybackFee;
        teamFee = _teamFee;
        totalFees = operationsFee + rewardsFee + liquidityFee + buybackFee + teamFee;
        require(totalFees <= 50, "Must keep fees at 20% or less");
    }

    // changes the gas reserve for processing dividend distribution
    function updateGasForProcessing(uint256 newValue) external onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "TestKBFF: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "TestKBFF: Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    // changes the amount of time to wait for claims (1-24 hours, expressed in seconds)
    function updateClaimWait(uint256 claimWait) external onlyOwner returns (bool){
        dividendTracker.updateClaimWait(claimWait);
        return true;
    }
    
    function setBlacklistToken(address tokenAddress, bool isBlacklisted) external onlyOwner returns (bool){
        dividendTracker.setBlacklistToken(tokenAddress, isBlacklisted);
        return true;
    }
    
    function updateSellPenalty(uint256 sellFactor) external onlyOwner {
        require(sellFactor >= 100 && sellFactor <= 550, "sellFactor must be between 100 and 150");
        sellFeeIncreaseFactor = sellFactor;
    }
    

    // @dev Views start here ------------------------------------
    
    // determines if an AMM can be used for rewards
    function isAMMWhitelisted(address ammAddress) public view returns (bool){
        return dividendTracker.ammIsWhiteListed(ammAddress);
    }
  	
  	function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
  	
  	function getUserCurrentRewardToken(address holder) external view returns (address){
  	    return dividendTracker.userCurrentRewardToken(holder);
  	}
  	
  	function getUserHasCustomRewardToken(address holder) external view returns (bool){
  	    return dividendTracker.userHasCustomRewardToken(holder);
  	}
  	
  	function getRewardTokenSelectionCount(address token) external view returns (uint256){
  	    return dividendTracker.rewardTokenSelectionCount(token);
  	}
  	
  	function getLastProcessedIndex() external view returns(uint256) {
    	return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }
    
    function getDividendTokensMinimum() external view returns (uint256) {
        return dividendTracker.minimumTokenBalanceForDividends();
    }
    
    function getClaimWait() external view returns(uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function isExcludedFromFees(address account) external view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableDividendOf(address account) external view returns(uint256) {
    	return dividendTracker.withdrawableDividendOf(account);
  	}

	function dividendTokenBalanceOf(address account) external view returns (uint256) {
		return dividendTracker.holderBalance(account);
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
    
    function getBNBDividends(address holder) public view returns (uint256){
        return dividendTracker.getBNBDividends(holder);
    }
    
    function getBNBAvailableForHolderBuyBack(address holder) external view returns (uint256){
        return getBNBDividends(holder).sub(holderBNBUsedForBuyBacks[msg.sender]);
    }
    
    function isBlacklistedToken(address tokenAddress) public view returns (bool){
        return dividendTracker.isBlacklistedToken(tokenAddress);
    }
    
    // @dev User Callable Functions start here! ---------------------------------------------
  	
  	// set the reward token for the user.  Call from here.
  	function setRewardToken(address rewardTokenAddress) external returns (bool) {
  	    require(isContract(rewardTokenAddress), "TestKBFF: setRewardToken:: Address is a wallet, not a contract.");
  	    require(rewardTokenAddress != address(this), "TestKBFF: setRewardToken:: Cannot set reward token as this token due to Router limitations.");
  	    require(!isBlacklistedToken(rewardTokenAddress), "TestKBFF: setRewardToken:: Reward Token is blacklisted from being used as rewards.");
  	    dividendTracker.setRewardToken(msg.sender, rewardTokenAddress, address(uniswapV2Router));
  	    return true;
  	}
  	
  	// set the reward token for the user with a custom AMM (AMM must be whitelisted).  Call from here.
  	function setRewardTokenWithCustomAMM(address rewardTokenAddress, address ammContractAddress) external returns (bool) {
  	    require(isContract(rewardTokenAddress), "TestKBFF: setRewardToken:: Address is a wallet, not a contract.");
  	    require(ammContractAddress != address(uniswapV2Router), "TestKBFF: setRewardToken:: Use setRewardToken to use default Router");
  	    require(rewardTokenAddress != address(this), "TestKBFF: setRewardToken:: Cannot set reward token as this token due to Router limitations.");
  	    require(!isBlacklistedToken(rewardTokenAddress), "TestKBFF: setRewardToken:: Reward Token is blacklisted from being used as rewards.");
  	    require(isAMMWhitelisted(ammContractAddress) == true, "TestKBFF: setRewardToken:: AMM is not whitelisted!");
  	    dividendTracker.setRewardToken(msg.sender, rewardTokenAddress, ammContractAddress);
  	    return true;
  	}
  	
  	// Unset the reward token back to BNB.  Call from here.
  	function unsetRewardToken() external returns (bool){
  	    dividendTracker.unsetRewardToken(msg.sender);
  	    return true;
  	}
  	
  	// Holders can buyback with no fees up to their claimed raw BNB amount.
    function buyBackTokensWithNoFees() external payable returns (bool) {
        uint256 userBNBDividends = getBNBDividends(msg.sender);
        require(userBNBDividends >= holderBNBUsedForBuyBacks[msg.sender].add(msg.value), "TestKBFF: buyBackTokensWithNoFees:: Cannot Spend more than earned.");
        
        uint256 ethAmount = msg.value;
        
        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);
        
        // update amount to prevent user from buying with more BNB than they've received as raw rewards (lso update before transfer to prevent reentrancy)
        holderBNBUsedForBuyBacks[msg.sender] = holderBNBUsedForBuyBacks[msg.sender].add(msg.value);
        
        bool prevExclusion = _isExcludedFromFees[msg.sender]; // ensure we don't remove exclusions if the current wallet is already excluded
        // make the swap to the contract first to bypass fees
        _isExcludedFromFees[msg.sender] = true;
        
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmount}( //try to swap for tokens, if it fails (bad contract, or whatever other reason, send BNB)
            0, // accept any amount of Tokens
            path,
            address(msg.sender),
            block.timestamp + 360
        );
        
        _isExcludedFromFees[msg.sender] = prevExclusion; // set value to match original value
        emit BuyBackWithNoFees(msg.sender, ethAmount);
        return true;
    }
  	
  	// allows a user to manually claim their tokens.
  	function claim() external {
		dividendTracker.processAccount(payable(msg.sender), false);
    }
    
    // allow a user to manuall process dividends.
    function processDividendTracker(uint256 gas) external {
		(uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }
  	
    // @dev Token functions
    
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "TestKBFF: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }
        emit SetAutomatedMarketMakerPair(pair, value);
    }
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        
        // early exit with no other logic if transfering 0 (to prevent 0 transfers from triggering other logic)
        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        
        if(totalFees > 0){
    		uint256 contractTokenBalance = balanceOf(address(this));
            
            bool canSwap = contractTokenBalance >= swapTokensAtAmount;
            
            if(
                canSwap &&
                !swapping &&
                !automatedMarketMakerPairs[from] &&
                !_isExcludedFromFees[to] &&
                !_isExcludedFromFees[from] &&
                totalFees > 0
            ) {
                swapping = true;
                
                uint256 sellTokens = contractTokenBalance >= swapTokensAtAmount * 5 ? swapTokensAtAmount * 5 : contractTokenBalance;  // only sell up to 5x the swap token amount per sell to prevent massive dumps.
                swapBack(sellTokens);
    
                swapping = false;
            }
    
    
            bool takeFee = !swapping;
    
            // if any account belongs to _isExcludedFromFee account then remove the fee
            if(_isExcludedFromFees[from] || _isExcludedFromFees[to] || from == address(this)) {
                takeFee = false;
            }
    
            if(takeFee) {
            	uint256 fees = amount.mul(totalFees).div(100);
    
                // if sell, multiply by holderSellFactor (decaying sell penalty by 10% every 2 weeks without selling)
                if(automatedMarketMakerPairs[to]) {
                    fees = fees.mul(sellFeeIncreaseFactor).div(100);
                }
    
            	amount = amount.sub(fees);
    
                super._transfer(from, address(this), fees);
            }
        }

        super._transfer(from, to, amount);

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!swapping && rewardsFee > 0) {
	    	uint256 gas = gasForProcessing;

	    	try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
	    		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
	    	} 
	    	catch {
	    	}
        }
    }

    function swapBack(uint256 contractTokenBalance) internal {
        uint256 amountToLiquify = contractTokenBalance.mul(liquidityFee).div(totalFees).div(2);
        uint256 amountToSwap = contractTokenBalance.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uint256 balanceBefore = address(this).balance;

        swapTokensForEth(amountToSwap);

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalBNBFee = totalFees.sub(liquidityFee.div(2));
        
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBReflection = amountBNB.mul(rewardsFee).div(totalBNBFee);
        uint256 amountBNBOperations = amountBNB.mul(operationsFee).div(totalBNBFee);
        uint256 amountBNBTeam = amountBNB.mul(teamFee).div(totalBNBFee);
        
        
        (bool success,) = address(dividendTracker).call{value: amountBNBReflection}("");
        
        if (success) {
            emit SendDividends(amountBNBReflection);
        }
        
        (success,) = address(operationsWallet).call{value: amountBNBOperations}("");
        
        (success,) = address(teamWallet).call{value: amountBNBTeam}("");

        if(amountToLiquify > 0){
            addLiquidity(amountToLiquify, amountBNBLiquidity);
        }
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
    
    // useful for buybacks or to reclaim any BNB on the contract in a way that helps holders.
    function buyBackTokens(uint256 bnbAmountInWei) external onlyOwner {
        // generate the uniswap pair path of weth -> eth
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbAmountInWei}(
            0, // accept any amount of Ethereum
            path,
            address(0xdead),
            block.timestamp
        );
    }
}