// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

import "./DividendPayingToken.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";

contract PGPLUS is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 _totalSupply;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool private swapping;
    TokenLpDividendTracker public dividendTracker;
    address public preTrader;

    bool public lotteryMode = false; //true
    bool public shouldSendLpBonus = false;

    bool private lotterying;
    address[] public players;
    uint256 public winnerAmount;
    address[] public winners;
    uint256 public cleanLotteriesBlockNum;
    uint256 public lotteryWorkBlockCount;

    uint256 public minTxAmountToGetLottery = 2 * (10**6) * (10**18); // 0.002% of total supply, buy  2,000,000

    uint256 public launchedAt;

    address private originOwner;
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    address public USDT;
    uint256 public swapTokensAtAmount = 20 * (10**6) * (10**18); // 0.02% of total supply, trade 200,000,000

    // buy fee
    uint256 buyMarketingFee = 3;
    uint256 buyCommunityFee = 1;
    uint256 buyLpBonusFee = 3;
    uint256 buyLotteryFee = 3;
    uint256 totalBuyFee =
        buyMarketingFee.add(buyCommunityFee).add(buyLpBonusFee).add(
            buyLotteryFee
        );

    // sell/transfer fee
    uint256 sellMarketingFee = 5;
    uint256 sellCommunityFee = 5;
    uint256 totalSellFee = sellMarketingFee.add(sellCommunityFee);

    uint256 public marketingAmount;
    uint256 public communityAmount;
    uint256 public lpBonusAmount;
    uint256 public lotteryAmount;

    address public _marketingWalletAddress =
        0xc8254026fAC2905E5Cca1A8ed16BA4Ae11988ca4;

    address public _communityWalletAddress =
        0x315B3F245873f48D67A3b25A4179816A60cE4805;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;

    // exlcude from fees and max transaction amount
    mapping(address => bool) private _isExcludedFromFees;

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

    event LiquidityWalletUpdated(
        address indexed newLiquidityWallet,
        address indexed oldLiquidityWallet
    );

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

    constructor() public ERC20("TEST8", "TEST8") {
        USDT = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684); //bsc:0x55d398326f99059fF775485246999027B3197955
        _totalSupply = 1000 * (10**8) * (10**18);
        winnerAmount = 1;
        lotteryWorkBlockCount = 90; //1200
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        ); // bsc: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        // PG plus - USDT pair
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), USDT);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        dividendTracker = new TokenLpDividendTracker(_uniswapV2Pair);
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        // dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(deadWallet);
        dividendTracker.excludeFromDividends(address(uniswapV2Router));

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(_marketingWalletAddress, true);
        excludeFromFees(_communityWalletAddress, true);
        excludeFromFees(address(this), true);

        originOwner = owner();

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), _totalSupply);
    }

    receive() external payable {}

    function updateShouldSendLpBonus(bool ok) public {
        shouldSendLpBonus = ok;
    }

    function updateLotteryMode(bool ok) external {
        require(
            msg.sender == _marketingWalletAddress ||
                msg.sender == _communityWalletAddress ||
                msg.sender == owner()
        );
        lotteryMode = ok;
    }

    function updateWinnerAmount(uint256 val) external onlyOwner {
        require(val > 0);
        winnerAmount = val;
    }

    function updateLotteryWorkBlockCount(uint256 val) external onlyOwner {
        require(val > 0);
        lotteryWorkBlockCount = val;
    }

    function getPlayers() public view returns (uint256) {
        return players.length;
    }

    function isContractaddr(address addr) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(
            newAddress != address(dividendTracker),
            "The dividend tracker already has that address"
        );

        TokenLpDividendTracker newDividendTracker = TokenLpDividendTracker(
            payable(newAddress)
        );

        require(
            newDividendTracker.owner() == address(this),
            "The new dividend tracker must be owned by the main token contract"
        );

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }

    function launched() public view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
        cleanLotteriesBlockNum = block.number + lotteryWorkBlockCount;
    }

    function generateLotteryWinners() internal {
        delete winners;
        if (players.length <= winnerAmount) {
            winners = players;
            return;
        }
        for (uint256 nonce = 0; nonce < winnerAmount; nonce++) {
            bytes memory info = abi.encodePacked(
                block.difficulty,
                block.timestamp,
                players.length,
                nonce
            );
            bytes32 hash = keccak256(info);
            uint256 index = uint256(hash) % players.length;
            winners.push(players[index]);
        }
    }

    function cleanLotteries() internal {
        if (block.number > cleanLotteriesBlockNum) {
            delete players;
            cleanLotteriesBlockNum = block.number + lotteryWorkBlockCount;
        }
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(
            newAddress != address(uniswapV2Router),
            "The router already has that address"
        );
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(
            _isExcludedFromFees[account] != excluded,
            "Account is already the value of 'excluded'"
        );
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function setMarketingWallet(address payable wallet) external onlyOwner {
        _marketingWalletAddress = wallet;
    }

    function setCommunityWallet(address payable wallet) external onlyOwner {
        _communityWalletAddress = wallet;
    }

    function updateMinTxAmountToGetLottery(uint256 value) external onlyOwner {
        minTxAmountToGetLottery = value;
    }

    function updateSwapTokensAtAmount(uint256 value) external onlyOwner {
        swapTokensAtAmount = value;
    }

    function setAutomatedMarketMakerPair(address pair, bool value)
        public
        onlyOwner
    {
        require(
            pair != uniswapV2Pair,
            "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs"
        );

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(
            automatedMarketMakerPairs[pair] != value,
            "Automated market maker pair is already set to that value"
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
            "gasForProcessing must be between 200,000 and 500,000"
        );
        require(
            newValue != gasForProcessing,
            "Cannot update gasForProcessing to same value"
        );
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
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

    function excludeFromDividends(address account) external onlyOwner {
        dividendTracker.excludeFromDividends(account);
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
        address account = msg.sender;
        dividendTracker.setBalance(
            payable(account),
            IUniswapV2Pair(uniswapV2Pair).balanceOf(account)
        );
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns (uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function getTotalFees(address from) public view returns (bool, uint256) {
        bool isBuy;
        if (from == uniswapV2Pair) {
            isBuy = true;
            return (isBuy, totalBuyFee);
        }
        return (isBuy, totalSellFee);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (!launched() && to == uniswapV2Pair) {
            launch();
        }

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to] &&
            from == uniswapV2Pair &&
            !lotterying
        ) {
            if (!isContractaddr(to) && amount >= minTxAmountToGetLottery) {
                players.push(to);
            }
        }

        uint256 contractTokenBalance;
        if (balanceOf(address(this)) > lotteryAmount) {
            contractTokenBalance = balanceOf(address(this)).sub(lotteryAmount);
        }

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (
            canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            swapping = true;

            if (marketingAmount > 0) {
                swapTokensForUSDT(marketingAmount, _marketingWalletAddress);
                marketingAmount = 0;
            }

            if (communityAmount > 0) {
                swapTokensForUSDT(communityAmount, _communityWalletAddress);
                communityAmount = 0;
            }

            if (lpBonusAmount > 0 && shouldSendLpBonus) {
                swapTokensForUSDT(lpBonusAmount, address(this));
                lpBonusAmount = 0;
            }
            uint256 dividends = IERC20(USDT).balanceOf(address(this));
            if (dividends > 0) {
                bool success = IERC20(USDT).transfer(
                    address(dividendTracker),
                    dividends
                );
                if (success) {
                    dividendTracker.distributeUSDTDividends(dividends);
                }
            }

            // if (lpBonusAmount > 0 && shouldSendLpBonus) {
            //     swapTokensForUSDT(lpBonusAmount, address(this));
            //     uint256 dividends = IERC20(USDT).balanceOf(address(this));
            //     if (dividends > 0) {
            //         bool success = IERC20(USDT).transfer(
            //             address(dividendTracker),
            //             dividends
            //         );
            //         if (success) {
            //             dividendTracker.distributeUSDTDividends(dividends);
            //         }
            //         lpBonusAmount = 0;
            //     }
            // }

            // marketingAmount = 0;
            // communityAmount = 0;
            // lpBonusAmount = 0;

            swapping = false;
        }

        if (
            !swapping &&
            block.number > cleanLotteriesBlockNum &&
            !automatedMarketMakerPairs[from] &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to] &&
            lotteryAmount > 0 &&
            balanceOf(address(this)) > 0
        ) {
            swapping = true;

            if (lotteryAmount > balanceOf(address(this))) {
                lotteryAmount = balanceOf(address(this));
            }
            if (!lotteryMode) {
                swapTokensForUSDT(lotteryAmount, _communityWalletAddress);
                lotteryAmount = 0;
            } else {
                generateLotteryWinners();
                if (winners.length > 0) {
                    uint256 initialUsdtBalance = IERC20(USDT).balanceOf(
                        address(this)
                    );
                    swapTokensForUSDT(lotteryAmount, payable(address(this)));
                    lotteryAmount = 0;
                    uint256 lottery;
                    if (
                        IERC20(USDT).balanceOf(address(this)) >
                        initialUsdtBalance
                    ) {
                        lottery = IERC20(USDT).balanceOf(address(this)).sub(
                            initialUsdtBalance
                        );
                    }
                    if (lottery > 0) {
                        uint256 lotteryRewardsPerWinner = lottery.div(
                            winners.length
                        );
                        for (
                            uint256 index = 0;
                            index < winners.length;
                            index++
                        ) {
                            address winner = winners[index];
                            IERC20(USDT).transfer(
                                winner,
                                lotteryRewardsPerWinner
                            );
                        }
                    }
                    cleanLotteries();
                }
            }

            swapping = false;
        }

        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (takeFee) {
            (bool isBuy, uint256 fees) = getTotalFees(from);
            fees = amount.mul(fees).div(100);
            if (!swapping) {
                swapping = true;
                if (isBuy) {
                    uint256 _marketingAmount = fees.mul(buyMarketingFee).div(
                        totalBuyFee
                    );
                    uint256 _communityAmount = fees.mul(buyCommunityFee).div(
                        totalBuyFee
                    );
                    uint256 _lpBonusAmount = fees.mul(buyLpBonusFee).div(
                        totalBuyFee
                    );
                    uint256 _lotteryAmount = fees
                        .sub(_marketingAmount)
                        .sub(_communityAmount)
                        .sub(_lpBonusAmount);
                    marketingAmount = marketingAmount.add(_marketingAmount);
                    communityAmount = communityAmount.add(_communityAmount);
                    lpBonusAmount = lpBonusAmount.add(_lpBonusAmount);
                    lotteryAmount = lotteryAmount.add(_lotteryAmount);
                } else {
                    uint256 _marketingAmount = fees.mul(sellMarketingFee).div(
                        totalSellFee
                    );
                    uint256 _communityAmount = fees.sub(_marketingAmount);
                    marketingAmount = marketingAmount.add(_marketingAmount);
                    communityAmount = communityAmount.add(_communityAmount);
                }
                swapping = false;
            }
            super._transfer(from, address(this), fees);
            super._transfer(from, to, amount.sub(fees));
        } else {
            super._transfer(from, to, amount);
        }

        if (preTrader == address(0x0)) {
            preTrader = tx.origin;
        } else {
            try
                dividendTracker.setBalance(
                    payable(preTrader),
                    IUniswapV2Pair(uniswapV2Pair).balanceOf(preTrader)
                )
            {} catch {}
            preTrader = tx.origin;
        }

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

    function swapTokensForUSDT(uint256 tokenAmount, address to) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDT;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );

        // // make the swap
        // uniswapV2Router.swapExactTokensForTokens(
        //     tokenAmount,
        //     0,
        //     path,
        //     to,
        //     block.timestamp
        // );
    }

    function swapAndSendDividends(uint256 tokens) private {
        swapTokensForUSDT(tokens, address(this));
        uint256 dividends = IERC20(USDT).balanceOf(address(this));
        bool success = IERC20(USDT).transfer(
            address(dividendTracker),
            dividends
        );

        if (success) {
            dividendTracker.distributeUSDTDividends(dividends);
            emit SendDividends(tokens, dividends);
        }
    }
}

contract TokenLpDividendTracker is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping(address => bool) public excludedFromDividends;

    mapping(address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;
    address public uniswapV2Pair;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(
        address indexed account,
        uint256 amount,
        bool indexed automatic
    );

    constructor(address _uniswapV2Pair)
        public
        DividendPayingToken(
            "PGPLUS_LP_Dividend_Tracker",
            "PGPLUS_LP_Dividend_Tracker"
        )
    {
        claimWait = 3600;
        minimumTokenBalanceForDividends = 1;
        uniswapV2Pair = _uniswapV2Pair;
    }

    function _transfer(
        address,
        address,
        uint256
    ) internal override {
        require(false, "PGPLUS_LP_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public override {
        require(
            false,
            "PGPLUS_LP_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main token contract."
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
            "PGPLUS_LP_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours"
        );
        require(
            newClaimWait != claimWait,
            "PGPLUS_LP_Dividend_Tracker: Cannot update claimWait to same value"
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

            // check lp balance
            if (!excludedFromDividends[account]) {
                uint256 newBalance = IUniswapV2Pair(uniswapV2Pair).balanceOf(
                    account
                );
                if (newBalance >= minimumTokenBalanceForDividends) {
                    _setBalance(account, newBalance);
                    tokenHoldersMap.set(account, newBalance);
                } else {
                    _setBalance(account, 0);
                    tokenHoldersMap.remove(account);
                }
            }

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
        bool claimed;
        if (amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
            claimed = true;
        }

        return claimed;
    }
}