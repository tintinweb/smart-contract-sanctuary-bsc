// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./DividendPayingToken.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";

contract StayCationToken is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public constant deadAddress =
        address(0x000000000000000000000000000000000000dEaD);

    struct BuyFee {
        uint16 rewardFee;
        uint16 marketingFee;
        uint16 liquidityFee;
    }

    struct SellFee {
        uint16 rewardFee;
        uint16 marketingFee;
        uint16 liquidityFee;
        uint16 burnFee;
    }

    bool private swapping;

    BuyFee public buyFee;
    SellFee public sellFee;

    TokenDividendTracker public dividendTracker;

    uint256 public swapTokensAtAmount = 1 * 10**7 * (10**9);

    uint256 public maxBuyAmount = 1 * 10**12 * 10**9;
    uint256 public maxSellAmount = 1 * 10**12 * 10**9;
    uint256 public maxWalletAmount = 1 * 10**12 * 10**9;

    uint16 private totalBuyFee;
    uint16 private totalSellFee;

    bool public swapEnabled;
    bool public isTradingEnabled;

    address payable _marketingWallet =
        payable(address(0x9e219EE5537Ed2475B5761413A12F3697228D920)); //Marketing Address

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;
    uint256 private launchDate;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isExcludedFromLimit;
    mapping(address => bool) public _isBlackListed;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping(address => bool) public automatedMarketMakerPairs;

    event UpdateDividendTracker(
        address indexed newAddress,
        address indexed oldAddress
    );

    event UpdateUniswapV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event GasForProcessingUpdated(
        uint256 indexed newValue,
        uint256 indexed oldValue
    );

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SendDividends(uint256 tokensSwapped, uint256 amount);

    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );

    modifier lockTheSwap() {
        swapping = true;
        _;
        swapping = false;
    }

    constructor() ERC20("StayCation", "STC") {
        buyFee.rewardFee = 5;
        buyFee.marketingFee = 4;
        buyFee.liquidityFee = 3;
        totalBuyFee = 12;

        sellFee.rewardFee = 5;
        sellFee.marketingFee = 4;
        sellFee.liquidityFee = 3;
        sellFee.burnFee = 0;
        totalSellFee = 12;

        _marketingWallet = payable(
            address(0x9e219EE5537Ed2475B5761413A12F3697228D920)
        );
        dividendTracker = new TokenDividendTracker();

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 // Testnet Router
        );
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
        dividendTracker.excludeFromDividends(deadAddress);

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);

        swapEnabled = true;

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), 1000 * 10**9 * (10**9));
    }

    receive() external payable {}

    function decimals() public pure override returns (uint8) {
        return 9;
    }

    function enableTrading() external onlyOwner {
        isTradingEnabled = true;
    }

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(
            newAddress != address(dividendTracker),
            "Token: The dividend tracker already has that address"
        );

        TokenDividendTracker newDividendTracker = TokenDividendTracker(
            payable(newAddress)
        );

        require(
            newDividendTracker.owner() == address(this),
            "Token: The new dividend tracker must be owned by the Token token contract"
        );

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(
            newAddress != address(uniswapV2Router),
            "Token: The router already has that address"
        );
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(
            _isExcludedFromFees[account] != excluded,
            "Token: Account is already the value of 'excluded'"
        );
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function claimStuckTokens(address _token) external onlyOwner {
        require(_token != address(this), "No rugs");
        if (_token == address(0x0)) {
            payable(owner()).transfer(address(this).balance);
            return;
        }
        IERC20 erc20token = IERC20(_token);
        uint256 balance = erc20token.balanceOf(address(this));
        erc20token.transfer(owner(), balance);
    }

    function excludefromLimit(address account, bool excluded)
        external
        onlyOwner
    {
        _isExcludedFromLimit[account] = excluded;
    }

    function setBlackList(address addr, bool value) external onlyOwner {
        _isBlackListed[addr] = value;
    }

    function excludeFromReward(address account) external onlyOwner {
        dividendTracker.excludeFromDividends(account);
    }

    function excludeMultipleAccountsFromFees(
        address[] calldata accounts,
        bool excluded
    ) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value)
        public
        onlyOwner
    {
        require(
            pair != uniswapV2Pair,
            "Token: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs"
        );

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(
            automatedMarketMakerPairs[pair] != value,
            "Token: Automated market maker pair is already set to that value"
        );
        automatedMarketMakerPairs[pair] = value;

        if (value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(
            newValue >= 200000 && newValue <= 500000,
            "Token: gasForProcessing must be between 200,000 and 500,000"
        );
        require(
            newValue != gasForProcessing,
            "Token: Cannot update gasForProcessing to same value"
        );
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function setBuyFee(
        uint16 rewardfee,
        uint16 marketing,
        uint16 liquidity
    ) external onlyOwner {
        buyFee.rewardFee = rewardfee;
        buyFee.marketingFee = marketing;
        buyFee.liquidityFee = liquidity;
        totalBuyFee = rewardfee + marketing + liquidity;
    }

    function setSellFee(
        uint16 rewardfee,
        uint16 marketing,
        uint16 liquidity,
        uint16 burn
    ) external onlyOwner {
        sellFee.rewardFee = rewardfee;
        sellFee.marketingFee = marketing;
        sellFee.liquidityFee = liquidity;
        sellFee.burnFee = burn;
        totalSellFee = rewardfee + marketing + liquidity + burn;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns (uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableDividendOf(address account)
        public
        view
        returns (uint256)
    {
        return dividendTracker.withdrawableDividendOf(account);
    }

    function dividendTokenBalanceOf(address account)
        public
        view
        returns (uint256)
    {
        return dividendTracker.balanceOf(account);
    }

    function getAccountDividendsInfo(address account)
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccount(account);
    }

    function getAccountDividendsInfoAtIndex(uint256 index)
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccountAtIndex(index);
    }

    function processDividendTracker(uint256 gas) external {
        (
            uint256 iterations,
            uint256 claims,
            uint256 lastProcessedIndex
        ) = dividendTracker.process(gas);
        emit ProcessedDividendTracker(
            iterations,
            claims,
            lastProcessedIndex,
            false,
            gas,
            tx.origin
        );
    }

    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }

    function launch() external onlyOwner {
        launchDate = block.timestamp;
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns (uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function setMarketingWallet(address newWallet) external onlyOwner {
        _marketingWallet = payable(newWallet);
    }

    function setSwapEnabled(bool value) external onlyOwner {
        swapEnabled = value;
    }

    function setMaxWallet(uint256 value) external onlyOwner {
        maxWalletAmount = value;
    }

    function setMaxBuyAmount(uint256 value) external onlyOwner {
        maxBuyAmount = value;
    }

    function setMaxSellAmount(uint256 value) external onlyOwner {
        maxSellAmount = value;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(
            !_isBlackListed[from] && !_isBlackListed[to],
            "Account is blacklisted"
        );

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >=
            swapTokensAtAmount;

        if (
            swapEnabled &&
            !swapping &&
            from != uniswapV2Pair &&
            overMinimumTokenBalance
        ) {
            contractTokenBalance = swapTokensAtAmount;
            uint16 totalFee = totalBuyFee + totalSellFee;

            uint256 swapTokens = contractTokenBalance
                .mul(buyFee.liquidityFee + sellFee.liquidityFee)
                .div(totalFee);
            swapAndLiquify(swapTokens);

            uint256 marketingTokens = contractTokenBalance
                .mul(buyFee.marketingFee + sellFee.marketingFee)
                .div(totalFee);
            swapAndSendToMarketing(marketingTokens);

            uint256 burnTokens = contractTokenBalance.mul(sellFee.burnFee).div(
                totalFee
            );
            super._transfer(address(this), deadAddress, burnTokens);

            uint256 sellTokens = contractTokenBalance
                .mul(buyFee.rewardFee + sellFee.rewardFee)
                .div(totalFee);
            swapAndSendDividends(sellTokens);
        }

        bool takeFee = true;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (takeFee) {
            uint256 fees;

            require(isTradingEnabled, "Trading not enabled yet");

            if (automatedMarketMakerPairs[to]) {
                fees = totalSellFee;
            } else if (automatedMarketMakerPairs[from]) {
                fees = totalBuyFee;
            }

            if (!_isExcludedFromLimit[from] && !_isExcludedFromLimit[to]) {
                if (automatedMarketMakerPairs[to]) {
                    require(amount <= maxSellAmount, "Sell exceeds limit");
                } else if (automatedMarketMakerPairs[from]) {
                    require(amount <= maxBuyAmount, "Buy exceeds limit");
                }

                if (!automatedMarketMakerPairs[to]) {
                    require(
                        balanceOf(to) + amount <= maxWalletAmount,
                        "Balance exceeds limit"
                    );
                }
            }

            uint256 feeAmount = amount.mul(fees).div(100);
            amount = amount.sub(feeAmount);

            super._transfer(from, address(this), feeAmount);
        }

        super._transfer(from, to, amount);

        try
            dividendTracker.setBalance(payable(from), balanceOf(from))
        {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if (!swapping) {
            uint256 gas = gasForProcessing;

            try dividendTracker.process(gas) returns (
                uint256 iterations,
                uint256 claims,
                uint256 lastProcessedIndex
            ) {
                emit ProcessedDividendTracker(
                    iterations,
                    claims,
                    lastProcessedIndex,
                    true,
                    gas,
                    tx.origin
                );
            } catch {}
        }
    }

    function swapAndSendToMarketing(uint256 tokens) private lockTheSwap {
        uint256 initialBalance = address(this).balance;

        swapTokensForEth(tokens);
        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);
        _marketingWallet.transfer(newBalance);
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
            deadAddress,
            block.timestamp
        );
    }

    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

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

    function swapAndSendDividends(uint256 tokens) private lockTheSwap {
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(tokens);
        uint256 dividends = address(this).balance.sub(initialBalance);
        (bool success, ) = address(dividendTracker).call{value: dividends}("");

        if (success) {
            emit SendDividends(tokens, dividends);
        }
    }
}

contract TokenDividendTracker is DividendPayingToken, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping(address => bool) public excludedFromDividends;

    mapping(address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public immutable minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(
        address indexed account,
        uint256 amount,
        bool indexed automatic
    );

    constructor()
        DividendPayingToken("Token_Dividend_Tracker", "Token_Dividend_Tracker")
    {
        claimWait = 3600;
        minimumTokenBalanceForDividends = 200000 * (10**9); //must hold 200000 tokens
    }

    function _transfer(
        address,
        address,
        uint256
    ) internal pure override {
        require(false, "Token_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public pure override {
        require(
            false,
            "Token_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main Token contract."
        );
    }

    function excludeFromDividends(address account) external onlyOwner {
        require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        tokenHoldersMap.remove(account);

        emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(
            newClaimWait >= 3600 && newClaimWait <= 86400,
            "Token_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours"
        );
        require(
            newClaimWait != claimWait,
            "Token_Dividend_Tracker: Cannot update claimWait to same value"
        );
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount(address _account)
        public
        view
        returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable
        )
    {
        account = _account;

        index = tokenHoldersMap.getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if (index >= 0) {
            if (uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(
                    int256(lastProcessedIndex)
                );
            } else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length >
                    lastProcessedIndex
                    ? tokenHoldersMap.keys.length.sub(lastProcessedIndex)
                    : 0;

                iterationsUntilProcessed = index.add(
                    int256(processesUntilEndOfArray)
                );
            }
        }

        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);

        lastClaimTime = lastClaimTimes[account];

        nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(claimWait) : 0;

        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp
            ? nextClaimTime.sub(block.timestamp)
            : 0;
    }

    function getAccountAtIndex(uint256 index)
        public
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        if (index >= tokenHoldersMap.size()) {
            return (
                0x0000000000000000000000000000000000000000,
                -1,
                -1,
                0,
                0,
                0,
                0,
                0
            );
        }

        address account = tokenHoldersMap.getKeyAtIndex(index);

        return getAccount(account);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp) {
            return false;
        }

        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance)
        external
        onlyOwner
    {
        if (excludedFromDividends[account]) {
            return;
        }

        if (newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
            tokenHoldersMap.set(account, newBalance);
        } else {
            _setBalance(account, 0);
            tokenHoldersMap.remove(account);
        }

        processAccount(account, true);
    }

    function process(uint256 gas)
        public
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

        if (numberOfTokenHolders == 0) {
            return (0, 0, lastProcessedIndex);
        }

        uint256 _lastProcessedIndex = lastProcessedIndex;

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 claims = 0;

        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if (_lastProcessedIndex >= tokenHoldersMap.keys.length) {
                _lastProcessedIndex = 0;
            }

            address account = tokenHoldersMap.keys[_lastProcessedIndex];

            if (canAutoClaim(lastClaimTimes[account])) {
                if (processAccount(payable(account), true)) {
                    claims++;
                }
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;

        return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic)
        public
        onlyOwner
        returns (bool)
    {
        uint256 amount = _withdrawDividendOfUser(account);

        if (amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
            return true;
        }

        return false;
    }
}