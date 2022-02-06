// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IUniswapV2Router01.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
import "./SignedSafeMath.sol";
import "./SafeMath.sol";
import "./Context.sol";
import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Ownable.sol";
import "./IterableMapping.sol";
import "./DividendPayingTokenOptionalInterface.sol";
import "./DividendPayingTokenInterface.sol";
import "./DividendPayingToken.sol";
import "./MAMASHIBADividendTracker.sol";
import "./SafeToken.sol";
import "./LockToken.sol";
import "./IPinkAntiBot.sol";




contract MAMASHIBA is ERC20, Ownable, SafeToken, LockToken {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public immutable uniswapV2Pair;

    IPinkAntiBot public pinkAntiBot;
    bool public antiBotEnabled;

    bool private inSwapAndLiquify;

    bool public swapAndLiquifyEnabled = true;

    MAMASHIBADividendTracker public dividendTracker;

    uint256 public maxSellTransactionAmount = 10000000000 * (10**18);
    uint256 public maxWalletAmount = 20000000000 * (10**18);
    uint256 public swapTokensAtAmount = 2 * 10**4 * (10**18);
    
    uint256 public BNBRewardsFee;
    uint256 public liquidityFee;
    uint256 public totalFees;
    uint256 public totallFees;

    uint256 public extraFeeOnSell;
    uint256 public MarketingFee;
    address payable public  MarketingWallet;
    uint256 public GameFee;
    address public  GameWallet;
     uint256 public BurnFee;
    address payable public  DeadWallet;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;

    // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;
    
    mapping(address => bool) private _isExcludedFromMaxTx;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event SwapAndLiquifyEnabledUpdated(bool enabled);

    event SwapAndLiquify(
        uint256 tokensIntoLiqudity,
        uint256 ethReceived
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
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    function setFee(uint256 _bnbRewardFee, uint256 _liquidityFee, uint256 _MarketingFee, uint256 _GameFee,uint256 _BurnFee) public onlyOwner {
        BNBRewardsFee = _bnbRewardFee;
        liquidityFee = _liquidityFee;
        MarketingFee = _MarketingFee;
        GameFee = _GameFee;
        BurnFee = _BurnFee;
        
        totallFees = BNBRewardsFee.add(liquidityFee).add(MarketingFee).add(BurnFee).add(GameFee);
        totalFees = BNBRewardsFee.add(liquidityFee).add(MarketingFee); // total fee transfer and buy
    }

    function setExtraFeeOnSell(uint256 _extraFeeOnSell) public onlyOwner {
        extraFeeOnSell = _extraFeeOnSell; // extra fee on sell
    }

    function setMaxSelltx(uint256 _maxSellTxAmount) public onlyOwner {
        maxSellTransactionAmount = _maxSellTxAmount;
    }

    function setMaxWallet(uint256 _maxWalletAmount) public onlyOwner {
        maxWalletAmount = _maxWalletAmount;
    }
    
    function setMarketingWallet(address payable _newMarketingWallet) public onlyOwner {
        MarketingWallet = _newMarketingWallet;
    }

     function setGameWallet(address payable _newGameWallet) public onlyOwner {
        GameWallet = _newGameWallet;
    }


    constructor() ERC20("MAMASHIBAV5", "MAMAV5") {
        BNBRewardsFee = 5;
        liquidityFee = 3;
        extraFeeOnSell = 3; // extra fee on sell
        MarketingFee = 3;
        GameFee = 1;
        BurnFee = 1;
        MarketingWallet = payable(0xF2011f55bBa792658E29C209a33Cc82F96cab11f); 
        GameWallet = 0xa43fE58212552dAF505498612dd1bF1DF2555077;
        DeadWallet = payable(0x000000000000000000000000000000000000dEaD);
        totallFees = BNBRewardsFee.add(liquidityFee).add(MarketingFee).add(GameFee).add(BurnFee); // total fee transfer and buy
        totalFees = BNBRewardsFee.add(liquidityFee).add(MarketingFee);

    	dividendTracker = new MAMASHIBADividendTracker();
        //
        //P 0x10ED43C718714eb63d5aA57B78B54704E256024E
        //T 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
	    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // ** 

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
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));
        dividendTracker.excludeFromDividends(0x000000000000000000000000000000000000dEaD);

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(MarketingWallet, true);
        excludeFromFees(address(this), true);
        
        // exclude from max tx
        _isExcludedFromMaxTx[owner()] = true;
        _isExcludedFromMaxTx[address(this)] = true;
        _isExcludedFromMaxTx[MarketingWallet] = true;

         // Initiate PinkAntiBot instance from its address
        //pinkAntiBot = IPinkAntiBot(0x8EFDb3b642eb2a20607ffe0A56CFefF6a95Df002); //BSC-MAINNET **
        pinkAntiBot = IPinkAntiBot(0xbb06F5C7689eA93d9DeACCf4aF8546C4Fe0Bf1E5); //BSC-TESTNET **
       
        // Register deployer as the owner of this token with PinkAntiBot contract
        pinkAntiBot.setTokenOwner(msg.sender);
        // Enable using PinkAntiBot in this contract
        antiBotEnabled = true;
        

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), 1000000000000 * (10**18));
    }

    receive() external payable {

  	}

    function setUsingAntiBot(bool enabled_) external onlyOwner {
        antiBotEnabled = enabled_;
      }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "MAMASHIBA: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "MAMASHIBA: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }
    
    function setExcludeFromMaxTx(address _address, bool value) public onlyOwner { 
        _isExcludedFromMaxTx[_address] = value;
    }

    function setExcludeFromAll(address _address) public onlyOwner {
        _isExcludedFromMaxTx[_address] = true;
        _isExcludedFromFees[_address] = true;
        dividendTracker.excludeFromDividends(_address);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "MAMASHIBA: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }
     
    function setSWapToensAtAmount(uint256 _newAmount) public onlyOwner {
        swapTokensAtAmount = _newAmount;
    }
    


    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "MAMASHIBA: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "MAMASHIBA: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "MAMASHIBA: Cannot update gasForProcessing to same value");
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
    
    function isExcludedFromMaxTx(address account) public view returns(bool) {
        return _isExcludedFromMaxTx[account];
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

//this will be used to exclude from dividends the presale smart contract address
    function excludeFromDividends(address account) external onlyOwner {
        dividendTracker.excludeFromDividends(account);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    )  internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (antiBotEnabled) {
         // Check for malicious transfers
        pinkAntiBot.onPreTransferCheck(from, to, amount);
       }
  
        

         if(to != owner() && to != address(this) && to != address(0x000000000000000000000000000000000000dEaD) && to != uniswapV2Pair && to != MarketingWallet && to != GameWallet){
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= maxWalletAmount, "wallet amount exceed maxWalletAmount");
        }

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        } 


        if(automatedMarketMakerPairs[to] && (!_isExcludedFromMaxTx[from]) && (!_isExcludedFromMaxTx[to])){
            require(amount <= maxSellTransactionAmount, "Sell transfer amount exceeds the maxSellTransactionAmount.");
        }
         
        

    	uint256 contractTokenBalance = balanceOf(address(this));
        
        bool overMinTokenBalance = contractTokenBalance >= swapTokensAtAmount;
       
        if(
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            !automatedMarketMakerPairs[from] && 
            swapAndLiquifyEnabled
        ) {
            swapAndLiquify(contractTokenBalance);
        }

         uint256 gametaxamount = (amount*GameFee)/100;
         uint256 burntaxamount = (amount*BurnFee)/100;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
        	uint256 fees = (amount*totallFees)/100;
            uint256 extraFee;

            if(automatedMarketMakerPairs[to]) {
                extraFee =(amount*extraFeeOnSell)/100;
                fees=fees+extraFee;
            }
        	amount = amount-fees;
            uint256 fess = (fees-gametaxamount).sub(burntaxamount);
           
            super._transfer(from, address(this), fess); // get total fee first
        }

         
         super._transfer(from,GameWallet,gametaxamount);
         _burn(from,burntaxamount);
         

        super._transfer(from, to, amount);

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!inSwapAndLiquify) {
	    	uint256 gas = gasForProcessing;

	    	try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
	    		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
	    	} 
	    	catch {

	    	}
        }
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        
        // take liquidity fee, keep a half token
        // halfLiquidityToken = totalAmount * (liquidityFee/2totalFee)
        uint256 tokensToAddLiquidityWith = contractTokenBalance.div(totalFees.mul(2)).mul(liquidityFee);
        // swap the remaining to BNB
        uint256 toSwap = contractTokenBalance-tokensToAddLiquidityWith;
        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForBnb(toSwap, address(this)); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        uint256 deltaBalance = address(this).balance-initialBalance;

        // take worthy amount bnb to add liquidity
        // worthyBNB = deltaBalance * liquidity/(2totalFees - liquidityFee)
        uint256 bnbToAddLiquidityWith = deltaBalance.mul(liquidityFee).div(totalFees.mul(2).sub(liquidityFee));
        
        // add liquidity to uniswap
        addLiquidity(tokensToAddLiquidityWith, bnbToAddLiquidityWith);
        // worthy Marketing fee
        uint256 MarketingAmount = deltaBalance.sub(bnbToAddLiquidityWith).div(totalFees.sub(liquidityFee)).mul(MarketingFee);
        MarketingWallet.transfer(MarketingAmount);
       
        


        uint256 dividends = address(this).balance;
        (bool success,) = address(dividendTracker).call{value: dividends}("");

        if(success) {
   	 		emit SendDividends(toSwap-tokensToAddLiquidityWith, dividends);
        }
        
        emit SwapAndLiquify(tokensToAddLiquidityWith, deltaBalance);
    }

    function swapTokensForBnb(uint256 tokenAmount, address _to) private {

        
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        if(allowance(address(this), address(uniswapV2Router)) < tokenAmount) {
          _approve(address(this), address(uniswapV2Router), ~uint256(0));
        }

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            _to,
            block.timestamp
        );
        
    }


    function swapAndSendBNBToMarketing(uint256 tokenAmount) private {
        swapTokensForBnb(tokenAmount, MarketingWallet);
    }
    

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        
        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
        
    }

    
}