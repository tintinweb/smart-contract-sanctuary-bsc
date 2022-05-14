// SPDX-License-Identifier: MIT

//Telegram: https://t.me/lunafoundationreserve   

pragma solidity ^0.6.2;

import "./DividendPayingToken.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";


contract LunaFoundationReserve is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;

    bool private swapping;

    LFRDividendTracker public dividendTracker;

    address public constant deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public liquidityWallet;

    address public DIVIDEND_TOKEN = address(0x156ab3346823B651294766e23e6Cf87254d68962); 

    uint256 public constant maxBuyTranscationAmount = 1000000 * (10**18); // 1% of total supply
    uint256 public constant maxSellTransactionAmount = 500000 * (10**18); // .5% of total supply
    uint256 public constant _maxWalletToken = 2000000 * (10**18); // 2% of total supply
    uint256 public swapTokensAtAmount = 200000 * (10**18);


    // addresses that can make transfers before presale is over
    mapping (address => bool) private canTransferBeforeTradingIsEnabled;
    // addresses that can make transfers before presale is over
    mapping (address => bool) private canJumpLimitOnWallet;

    mapping (address => uint256) public cumulativeDividends;


    // when the token can be traded freely on PancakeSwap
    // can only be enabled once, can never be disabled
    bool public tradingIsEnabled = false;

    mapping(address => bool) public _isBlacklisted;

    uint256 public DIVIDENDRewardsFee = 8;
    uint256 public liquidityFee = 3;
    uint256 public treasuryFee = 3;
    uint256 public totalFees = DIVIDENDRewardsFee.add(liquidityFee).add(treasuryFee);

    address public _treasuryWalletAddress = 0xaf8574bcC4C83Fe33A7894172a42620867b6Fb23;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;

     // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;


    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);

    event UpdateDividendToken(address indexed newAddress, address indexed oldAddress);

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

    event ProcessedDividendTracker(
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas,
    	address indexed processor
    );

    constructor() public ERC20("Luna Foundation Reserve", "LFR") {

    	dividendTracker = new LFRDividendTracker(DIVIDEND_TOKEN);
    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

         // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        updateLiquidityWallet(owner());

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(deadWallet);
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(_treasuryWalletAddress, true);
        excludeFromFees(address(this), true);

        canTransferBeforeTradingIsEnabled[owner()] = true;

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), 100000000 * (10**18));
    }

    receive() external payable {

  	}

  	function updateSwapTokensAtAmount(uint256 newAmount) external onlyOwner {
  	    swapTokensAtAmount = newAmount;
  	}

  	function whitelistPresaleAddress(address presaleAddress) external onlyOwner {
  	     dividendTracker.excludeFromDividends(presaleAddress);
  	     excludeFromFees(presaleAddress, true);
         canTransferBeforeTradingIsEnabled[presaleAddress] = true;
         canJumpLimitOnWallet[presaleAddress] = true;
  	}

	function changeDividend(address TokenAddress) external onlyOwner {
		emit UpdateDividendToken(address(TokenAddress), DIVIDEND_TOKEN);
		DIVIDEND_TOKEN = TokenAddress;
        dividendTracker.changeDividend(TokenAddress);
	}

	function withdrawOldDividends(address token) external {
	    dividendTracker.withdrawOldDividends(msg.sender, token);
	}

    function updateDividendTracker(address newAddress) external onlyOwner {
        require(newAddress != address(dividendTracker), "LFR: The dividend tracker already has that address");

        LFRDividendTracker newDividendTracker = LFRDividendTracker(payable(newAddress));

        require(newDividendTracker.owner() == address(this), "LFR: The new dividend tracker must be owned by the LFR token contract");

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }

    function updateUniswapV2Router(address newAddress) external onlyOwner {
        require(newAddress != address(uniswapV2Router), "LFR: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

    function updateLiquidityWallet(address newAddress) public onlyOwner {
        require(newAddress != liquidityWallet, "Thats already the liquidity wallet");
        emit LiquidityWalletUpdated(newAddress, liquidityWallet);
        liquidityWallet = newAddress;

    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "LFR: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }


    function setTradingIsEnabled() external onlyOwner {
        tradingIsEnabled = true;
    }

    function updateCanJumpLimitOnWallet(address add, bool value) external onlyOwner {
        canJumpLimitOnWallet[add] = value;
    }


    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setMarketingWallet(address payable wallet) external onlyOwner{
        _treasuryWalletAddress = wallet;
    }

    function setDIVIDENDRewardsFee(uint256 value) external onlyOwner{
        DIVIDENDRewardsFee = value;
        totalFees = DIVIDENDRewardsFee.add(liquidityFee).add(treasuryFee);
    }

    function setLiquiditFee(uint256 value) external onlyOwner{
        liquidityFee = value;
        totalFees = DIVIDENDRewardsFee.add(liquidityFee).add(treasuryFee);
    }

    function setMarketingFee(uint256 value) external onlyOwner{
        treasuryFee = value;
        totalFees = DIVIDENDRewardsFee.add(liquidityFee).add(treasuryFee);
    }


    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != uniswapV2Pair, "LFR: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function blacklistAddress(address account, bool value) external onlyOwner{
        _isBlacklisted[account] = value;
    }


    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "LFR: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }


    function updateGasForProcessing(uint256 newValue) external onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "LFR: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "LFR: Cannot update gasForProcessing to same value");
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
        return dividendTracker.totalDividendsDistributed(DIVIDEND_TOKEN);
    }

    function isExcludedFromFees(address account) external view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableDividendOf(address account) external view returns(uint256) {
    	return dividendTracker.withdrawableDividendOf(account);
  	}

	function dividendTokenBalanceOf(address account) external view returns (uint256) {
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


        if (
            from != owner() &&
            to != owner() &&
            to != address(0) &&
            to != address(0xdead) &&
            to != uniswapV2Pair &&
            !(canJumpLimitOnWallet[from] || canJumpLimitOnWallet[to])
        ) {

            if (automatedMarketMakerPairs[from]) { //buy
                require(
                    amount <= maxBuyTranscationAmount,
                    "Transfer amount exceeds the maxTxAmount."
                );
            }


            uint256 contractBalanceRecepient = balanceOf(to);
            require(
                contractBalanceRecepient + amount <= _maxWalletToken,
                "Exceeds maximum wallet token amount."
            );
        }

        if(!tradingIsEnabled) {
            require(
                canTransferBeforeTradingIsEnabled[from],
                "LFR: This account cannot send tokens until trading is enabled"
            );
        }

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if(
        	!swapping &&
        	tradingIsEnabled &&
            automatedMarketMakerPairs[to] && // sells only by detecting transfer to automated market maker pair
        	from != address(uniswapV2Router) && //router -> pair is removing liquidity which shouldn't have max
            !_isExcludedFromFees[to] //no max for those excluded from fees
        ) {
            require(
                amount <= maxSellTransactionAmount,
                "Sell transfer amount exceeds the maxSellTransactionAmount."
            );
        }


		uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if( canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            from != owner() &&
            to != owner() &&
            !(canJumpLimitOnWallet[from] || canJumpLimitOnWallet[to])
        ) {
            swapping = true;

            uint256 treasuryTokens = contractTokenBalance.mul(treasuryFee).div(totalFees);
            swapAndSendToFee(treasuryTokens);

            uint256 swapTokens = contractTokenBalance.mul(liquidityFee).div(totalFees);
            swapAndLiquify(swapTokens);

            uint256 sellTokens = balanceOf(address(this));
            swapAndSendDividends(sellTokens);

            swapping = false;
        }


        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        // normal wallet -> wallet transfers should not incur fee
        if(!(automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to])) {
            takeFee = false;
        }

        if(takeFee) {
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

    function swapTokensForDIVIDEND(uint256 tokenAmount) private {

        uint256 balanceBefore = IERC20(DIVIDEND_TOKEN).balanceOf(address(this));

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = DIVIDEND_TOKEN;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 balanceAfter = IERC20(DIVIDEND_TOKEN).balanceOf(address(this));
        cumulativeDividends[DIVIDEND_TOKEN].add(balanceAfter).sub(balanceBefore);
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

    function swapAndSendToFee(uint256 tokens) private  {

        uint256 initialDividendBalance = IERC20(DIVIDEND_TOKEN).balanceOf(address(this));

        swapTokensForDIVIDEND(tokens);
        uint256 newBalance = (IERC20(DIVIDEND_TOKEN).balanceOf(address(this))).sub(initialDividendBalance);
        IERC20(DIVIDEND_TOKEN).transfer(_treasuryWalletAddress, newBalance);
    }

    function swapAndSendDividends(uint256 tokens) private {
        swapTokensForDIVIDEND(tokens);
        uint256 dividends = IERC20(DIVIDEND_TOKEN).balanceOf(address(this));
        bool success = IERC20(DIVIDEND_TOKEN).transfer(address(dividendTracker), dividends);

        if (success) {
            dividendTracker.distributeREWARDDividends(dividends);
            emit SendDividends(tokens, dividends);
        }
    }

    function burnTokens(uint256 amount) external onlyOwner {
        _transfer(msg.sender, deadWallet, amount);
    }
}

contract LFRDividendTracker is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;


    mapping (address => bool) public excludedFromDividends;

    mapping (address => uint256) public lastClaimTimes;

    mapping(address => mapping(address => uint)) public owedDividends;

    uint256 public claimWait;
    uint256 public immutable minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    event UpdateDividendToken(address indexed oldValue, address indexed newValue);

    constructor(address _dividendToken) public DividendPayingToken("LFR_Dividen_Tracker", "LFR_Dividend_Tracker", _dividendToken) {
    	claimWait = 3600;
        minimumTokenBalanceForDividends = 20000 * (10**18); //must hold 20000+ tokens
    }

    function _transfer(address, address, uint256) internal override {
        require(false, "LFR_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public override {
        require(false, "LFR_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main LFR contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
    	require(!excludedFromDividends[account]);
    	excludedFromDividends[account] = true;

    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);

    	emit ExcludeFromDividends(account);
    }

    function changeDividend(address TokenAddress) external onlyOwner {
        emit UpdateDividendToken(DIVIDEND_TOKEN, TokenAddress);
		DIVIDEND_TOKEN = TokenAddress;
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "LFR_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "LFR_Dividend_Tracker: Cannot update claimWait to same value");
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

    function withdrawOldDividends(address payable user, address token) external onlyOwner {
        _withdrawOldDividendOfUser(user, token);
    }
}