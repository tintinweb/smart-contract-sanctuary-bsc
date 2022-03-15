// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

////////////////////////////////////////////
    /////KBBBBBLAH Token Contract//////
///////////////////////////////////////////

// File: contracts/KBBBBBLAH.sol

import "./KBBBBBLAHRewardsTracker.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";

import "./DividendPayingToken.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";
import "./KBBBBBLAHGame.sol";

contract KBBBBBLAH is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;

    address public immutable uniswapV2Pair;

    bool private swapping;

    KBBBBBLAHRewardsTracker public dividendTracker;

    KBBBBBLAHGame public KBBBBBLAHGameInstance;

    address public presaleAddress = address(0);
    address public presaleRouter = address(0);

    uint256 private totalSupplyTokens = 1000000000 * (10**18);
    uint256 public maxTxAmount = 2000000 * (10**18);
    uint256 public maxTxPercent = 99;
    uint256 public swapTokensAtAmount = 500000 * (10**18);
    uint256 public maxSwapTokenAmount = 5000000 * (10**18);

    address public liquidityWallet;
    address public operationsWallet =
    0x4Eec07F66825C3358e735C351E8Bb7fBc6C6d403;
    address public marketingWallet =
    0x4Ea26331A9078205a021C350917C1B4DB9b35C69;
    address private buyBackWallet =
    0xeDB5a2278e0ce8f49880784E0dA3d06bBE22780e;
    address public deadWallet =
    0x000000000000000000000000000000000000dEaD;

    uint256 public rewardsFee = 8;
    uint256 public liquidityFee = 4;
    uint256 public operationsFee = 3;
    uint256 public marketingFee = 3;
    uint256 public buyBackFee = 2;
    uint256 public totalFees;

    uint256 public sellFeeIncreaseFactor = 200;

    uint256 public gasForProcessing = 300000;

    bool public tradingEnabled;
    bool public swappingEnabled;
    bool public transferDelayEnabled = true;
    bool public gameIsEnabled;

    uint256 public contractCreated;

    uint256 public txCount = 0;

    mapping(address => uint256) private _holderLastTransferTimestamp;

    mapping(address => uint256) public _holderLastSellDate;

    mapping(address => uint256) public holderBNBUsedForBuyBacks;

    mapping(address => bool) public _isAllowedDuringDisabled;

    mapping(address => bool) public _isIgnoredAddress;

    mapping(address => bool) private _isFeeExempt;

    mapping(address => bool) public automatedMarketMakerPairs;

    mapping (address => bool) private _isMaxTxAmountExempt;

    mapping (address => bool) private _isMaxTxPercentExempt;

    mapping (address => bool) private _isTxLimitExempt;

    event UpdateUniswapV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );

    event SetAutomatedMarketMakerPair(
        address indexed pair,
        bool indexed value
    );

    event BuyBackWithNoFees(
        address indexed holder,
        uint256 indexed bnbSpent
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

    event SendDividends(
        uint256 amount
    );

    event ErrorInProcess(
        address msgSender
    );

    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );


    constructor() ERC20("KBBBBBLAH", "KB", 18) {

        dividendTracker = new KBBBBBLAHRewardsTracker();

        liquidityWallet = owner();

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        ); // TestNet

        /// IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
        /// 0x10ED43C718714eb63d5aA57B78B54704E256024E); // MainNet

        // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        contractCreated = block.timestamp;

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(address(deadWallet));
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));

        // exclude from paying fees or having max transaction amount
        addToWhitelist(liquidityWallet, true);
        addToWhitelist(owner(), true);
        addToWhitelist(address(this), true);
        addToWhitelist(address(dividendTracker), true);
        addToWhitelist(address(deadWallet), true);
        addToWhitelist(address(operationsWallet), true);
        addToWhitelist(address(buyBackWallet), true);
        addToWhitelist(address(marketingWallet), true);

        _mint(liquidityWallet, totalSupplyTokens); // 1,000,000,000
    }

    receive() external payable {

    }

    /// enable or disable custom AMMs
    function setWhiteListAMM(
        address ammAddress,
        bool isWhiteListed
    )
        external
        onlyOwner
    {
        require(
            isContract(ammAddress)
        );

        dividendTracker.setWhiteListAMM(
            ammAddress,
            isWhiteListed
        );
    }

    /// once activated, can never be turned off
    function activateContract()
        external
        onlyOwner
    {
        tradingEnabled = true;
        swappingEnabled = true;
    }

    function setTransferDelay(
        bool enabled
    )
        external
        onlyOwner()
    {
        transferDelayEnabled = enabled;
    }

    // only use to disable swap if absolutely necessary (emergency use only)
    function setSwapIsEnabled(bool enabled)
        external
        onlyOwner()
    {
        swappingEnabled = enabled;
    }

    function whitelistDxSale(
        address _presaleAddress,
        address _presaleRouter
    )
        external
        onlyOwner
    {
  	    presaleAddress = _presaleAddress;
        dividendTracker.excludeFromDividends(_presaleAddress);
        addToWhitelist(
            _presaleAddress,
            true
        );

        presaleRouter = _presaleRouter;
        dividendTracker.excludeFromDividends(_presaleRouter);
        addToWhitelist(
            _presaleRouter,
            true
        );
  	}

    function setSwapTarget(
        uint256 swapAmount,
        uint256 maxAmount
    )
        external
        onlyOwner
    {
        swapTokensAtAmount = swapAmount;
        maxSwapTokenAmount = maxAmount;
    }

    function excludeFromRewards(address account)
        external
        onlyOwner
    {
        dividendTracker.excludeFromDividends(account);
    }

    function includeInRewards(address account)
        external
        onlyOwner
    {
        dividendTracker.includeInDividends(account);
    }

    function setMinimumToEarnRewards(uint256 minimumToEarnDivs)
        external
        onlyOwner
    {
        dividendTracker.updateDividendMinimum(minimumToEarnDivs);
    }

    function updateUniswapV2Router(address newAddress)
        external
        onlyOwner
    {
        require(
            newAddress != address(uniswapV2Router)
        );
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function updateDividendUniswapV2Router(address newAddress)
        external
        onlyOwner
    {
        dividendTracker.updateDividendUniswapV2Router(newAddress);
    }

    function setIsBot(
        address account,
        bool status
    )
        external
        onlyOwner
    {
        _isIgnoredAddress[account] = status;
    }

    function setAutomatedMarketMakerPair(
        address pair,
        bool value
    )
        external
        onlyOwner
    {
        require(
            pair != uniswapV2Pair
        );

        _setAutomatedMarketMakerPair(pair, value);
    }

    function setMultipleFeeExempt(
        address[] calldata accounts,
        bool exempt
    )
        external
        onlyOwner
    {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isFeeExempt[accounts[i]] = exempt;
        }
    }

    function setWallets(
        address newLiquidityAddress,
        address newOperationsAddress,
        address newMarketingAddress,
        address newBuyBackAddress
    )
        external
        onlyOwner
    {
        require(
            newLiquidityAddress != address(0)
        );
        require(
            newOperationsAddress != address(0)
        );
        require(
            newMarketingAddress != address(0)
        );
        require(
            newBuyBackAddress != address(0)
        );

        addToWhitelist(
            newLiquidityAddress,
            true
        );
        addToWhitelist(
            newOperationsAddress,
            true
        );
        addToWhitelist(
            newMarketingAddress,
            true
        );
        addToWhitelist(
            newBuyBackAddress,
            true
        );

        liquidityWallet = newLiquidityAddress;
        operationsWallet = newOperationsAddress;
        marketingWallet = newMarketingAddress;
        buyBackWallet = newBuyBackAddress;
    }

    function setFees(
        uint256 _rewards,
        uint256 _liquidity,
        uint256 _operations,
        uint256 _buyBack,
        uint256 _marketing,
        uint256 _sellFactor
    )
        external
        onlyOwner
    {
        rewardsFee = _rewards;
        liquidityFee = _liquidity;
        operationsFee = _operations;
        buyBackFee = _buyBack;
        marketingFee = _marketing;
        sellFeeIncreaseFactor = _sellFactor;
        totalFees = rewardsFee
            .add(liquidityFee)
            .add(operationsFee)
            .add(marketingFee)
            .add(buyBackFee);
        require(totalFees <= 40);
    }

    function updateClaimWait(uint256 claimWait)
        external
        onlyOwner
        returns (bool)
    {
        dividendTracker.updateClaimWait(claimWait);
        return true;
    }

    function setIgnoreToken(
        address tokenAddress,
        bool isIgnored
    )
        external
        onlyOwner
        returns (bool)
    {
        dividendTracker.setIgnoreToken(
            tokenAddress,
            isIgnored
        );
        return true;
    }

    function rescueBNB()
        external
        onlyOwner
    {
        require (
            address(this).balance > 0,
            "Can't withdraw negative or zero"
        );
        payable(owner()).transfer(address(this).balance);
    }

    function rescueKBX(address _address)
        external
        onlyOwner
    {
        require(
            _address != address(this),
            "Prevents withdraw of tokens destined for liquidity"
        );
        require(
            IERC20(_address).balanceOf(address(this)) > 0,
            "Can't withdraw 0"
        );
        IERC20(
            _address).transfer(owner(),
            IERC20(_address).balanceOf(address(this))
        );
    }

    function manualAddLP()
        external
        onlyOwner
    {
        swapAndLiquify(balanceOf(address(this)));
    }

    function airdropToWallets(
        address[] memory airdropWallets,
        uint256[] memory amount
    )
        external
        onlyOwner()
    {
        require(
            airdropWallets.length == amount.length,
            "KBX: airdropToWallets:: Arrays must be the same length");
        for(uint256 i = 0; i < airdropWallets.length; i++){
            address wallet = airdropWallets[i];
            uint256 airdropAmount = amount[i];
            super._transfer(msg.sender, wallet, airdropAmount);
            dividendTracker.setBalance(payable(wallet), balanceOf(wallet));
        }
    }

    function setTxLimit(
        uint256 maxTxAmt,
        uint256 maxTxPct
    )
        public
        onlyOwner
    {
        require(maxTxPct < 100);

        maxTxAmount = maxTxAmt;
        maxTxPercent = maxTxPct;
    }

    function setGameIsEnabled(
        bool _gameIsEnabled
    )
        public
        onlyOwner
    {
        gameIsEnabled = _gameIsEnabled;
    }

    function setKBBBBBLAHGameAddress
    (
        address _KBBBBBLAHGameAddress
    )
        public
        onlyOwner
    {
        KBBBBBLAHGameInstance = KBBBBBLAHGame(
            _KBBBBBLAHGameAddress
        );
        addToWhitelist(
            _KBBBBBLAHGameAddress,
            true
        );
    }

    function setTxLimitExempt(
        address account,
        bool exempt
    ) public onlyOwner {
        require(
            _isTxLimitExempt[account] != exempt
        );

        _isMaxTxAmountExempt[account] = exempt;
        _isMaxTxPercentExempt[account] = exempt;
    }

    function setFeeExempt(
        address account,
        bool exempt
    )
        public
        onlyOwner
    {
        require(_isFeeExempt[account] != exempt);
        _isFeeExempt[account] = exempt;
    }

    function addToWhitelist(
        address account,
        bool exempt
    )
        public
        onlyOwner
    {
        _isMaxTxAmountExempt[account] = exempt;
        _isMaxTxPercentExempt[account] = exempt;
        _isAllowedDuringDisabled[account] = exempt;
        _isFeeExempt[account] = exempt;
    }

    function updateRewardsTracker(address newAddress)
        public
        onlyOwner
    {
        require(
            newAddress != address(dividendTracker)
        );

        KBBBBBLAHRewardsTracker newDividendTracker = KBBBBBLAHRewardsTracker(
            payable(newAddress)
        );

        require(
            newDividendTracker.owner() == address(this)
        );

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));
        newDividendTracker.excludeFromDividends(address(deadWallet));

        dividendTracker = newDividendTracker;
    }

    function updateGasForProcessing(uint256 newValue)
        public
        onlyOwner
    {
        require(
            newValue >= 200000 && newValue <= 800000
        );
        require(
            newValue != gasForProcessing
        );
        emit GasForProcessingUpdated(
            newValue,
            gasForProcessing
        );
        gasForProcessing = newValue;
    }

    // @dev Views start here ------------------------------------

    function getLastProcessedIndex()
        external
        view
        returns (uint256)
    {
        return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders()
        external
        view
        returns (uint256)
    {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function getDividendTokensMinimum()
        external
        view
        returns (uint256)
    {
        return dividendTracker.minimumTokenBalanceForDividends();
    }

    function getClaimWait()
        external
        view
        returns (uint256)
    {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed()
        external
        view
        returns (uint256)
    {
        return dividendTracker.totalDividendsDistributed();
    }

    function getAccountDividendsInfo
    (
        address account
    )
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

    function getAccountDividendsInfoAtIndex
    (
        uint256 index
    )
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

    function isAMMWhitelisted(address ammAddress)
        public
        view
        returns (bool)
    {
        return dividendTracker.ammIsWhiteListed(ammAddress);
    }

    function getUserCurrentRewardToken(address holder)
        public
        view
        returns (address)
    {
        return dividendTracker.userCurrentRewardToken(holder);
    }

    function getUserHasCustomRewardToken(address holder)
        public
        view
        returns (bool)
    {
        return dividendTracker.userHasCustomRewardToken(holder);
    }

    function getRewardTokenSelectionCount(address token)
        public
        view
        returns (uint256)
    {
        return dividendTracker.rewardTokenSelectionCount(token);
    }

    function getHolderSellFactor(address holder)
        public
        view
        returns (uint256)
    {
        uint256 timeSinceLastSale =
        (
            block.timestamp.sub(_holderLastSellDate[holder])
        ).div(2 weeks);

        if (_holderLastSellDate[holder] == 0)
        {
            return sellFeeIncreaseFactor;
        }

        if (timeSinceLastSale >= 7)
        {
            return 50;
        }

        return sellFeeIncreaseFactor - (timeSinceLastSale.mul(10));
    }

    function withdrawableDividendOf(address account)
        public
        view
        returns (uint256)
    {
        return dividendTracker.withdrawableDividendOf(account);
    }

    function isFeeExempt
    (
        address account
    )
        public
        view
        returns (bool)
    {
        return _isFeeExempt[account];
    }

    function isTxLimitExempt(address account)
        external
        view
        returns(bool)
    {
        return _isTxLimitExempt[account];
    }

    function rewardsTokenBalanceOf(address account)
        public
        view
        returns (uint256)
    {
        return dividendTracker.balanceOf(account);
    }

    function getRawBNBDividends(address holder)
        public
        view
        returns (uint256)
    {
        return dividendTracker.getRawBNBDividends(holder);
    }

    function getBNBForHolderBuyBack(address holder)
        public
        view
        returns (uint256)
    {
        return
        getRawBNBDividends(holder).sub(
            holderBNBUsedForBuyBacks[msg.sender]
        );
    }

    function isIgnoredToken
    (
        address tokenAddress
    )
        public
        view
        returns (bool)
    {
        return dividendTracker.isIgnoredToken(tokenAddress);
    }

    function isContract(address account)
        internal
        view
        returns (bool)
    {
        bytes32 codehash;
        bytes32 accountHash =
        0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    // @dev User Callable Functions start here! ---------------------------------------------

    function setRewardToken(address rewardTokenAddress)
        public
        returns (bool)
    {
        require(
            isContract(rewardTokenAddress)
        );
        require(
            rewardTokenAddress != address(this)
        );
        require(
            !isIgnoredToken(rewardTokenAddress)
        );
        dividendTracker.setRewardToken(
            msg.sender,
            rewardTokenAddress,
            address(uniswapV2Router)
        );
        return true;
    }

    /// set the reward token for the user with a custom AMM
    ///(AMM must be whitelisted).  Call from here.
    function setRewardTokenWithCustomAMM(
        address rewardTokenAddress,
        address ammContractAddress
    )
        public
        returns (bool)
    {
        require(
            isContract(rewardTokenAddress)
        );
        require(
            ammContractAddress != address(uniswapV2Router)
        );
        require(
            rewardTokenAddress != address(this)
        );
        require(
            !isIgnoredToken(rewardTokenAddress)
        );
        require(
            isAMMWhitelisted(ammContractAddress) == true
        );
        dividendTracker.setRewardToken(
            msg.sender,
            rewardTokenAddress,
            ammContractAddress
        );
        return true;
    }

    function unsetRewardToken()
        public
        returns (bool)
    {
        dividendTracker.unsetRewardToken(
            msg.sender
        );
        return true;
    }

    function buyBackTokensWithNoFees()
        external
        payable
        returns (bool)
    {
        uint256 userRawBNBDividends =
        getRawBNBDividends(
            msg.sender
        );
        require(
            userRawBNBDividends >=
                holderBNBUsedForBuyBacks[
                    msg.sender
                ].add(
                    msg.value
                )
        );

        uint256 ethAmount = msg.value;

        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        holderBNBUsedForBuyBacks[
            msg.sender
        ] = holderBNBUsedForBuyBacks[
            msg.sender
        ].add(
            msg.value
        );

        bool prevExclusion = _isFeeExempt[
            msg.sender
        ]; // ensure don't remove exclusions if is already excluded
        // make the swap to the contract first to bypass fees
        _isFeeExempt[
            msg.sender
        ] = true;

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: ethAmount
        }(
            0,
            path,
            address(msg.sender),
            block.timestamp + 360
        );

        _isFeeExempt[
            msg.sender
        ] = prevExclusion; // set value to match original value
        emit BuyBackWithNoFees(
            msg.sender,
            ethAmount
        );
        return true;
    }

    function claim()
        external
    {
        dividendTracker.processAccount(payable(msg.sender), false);
    }

    function processRewardsTracker(uint256 gas)
        external
    {
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

    // @dev Token functions

    function _setAutomatedMarketMakerPair(
        address pair,
        bool value
    )
        private
    {
        require(
            automatedMarketMakerPairs[pair] != value
        );
        automatedMarketMakerPairs[pair] = value;

        if (value)
        {
            dividendTracker.excludeFromDividends(pair);
        }
        emit SetAutomatedMarketMakerPair(
            pair,
            value
        );
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0));
        require(to != address(0));
        require(
            !_isIgnoredAddress[to] || !_isIgnoredAddress[from]
        );

        if (!tradingEnabled) {
            require(
                _isAllowedDuringDisabled[to] || _isAllowedDuringDisabled[from],
                "Trading is currently disabled"
            );
        }

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (transferDelayEnabled) {
            if (
                to != owner() &&
                to != address(uniswapV2Router) &&
                to != address(uniswapV2Pair) &&
                !_isFeeExempt[to] &&
                !_isFeeExempt[from]
            ) {
                require(
                    _holderLastTransferTimestamp[to] < block.timestamp
                );
                _holderLastTransferTimestamp[to] = block.timestamp;
            }
        }

        if (
            !isContract(to) &&
            !_isFeeExempt[to]
        ) {
            if (_holderLastSellDate[to] == 0) {
                _holderLastSellDate[to] == block.timestamp;
            }
        }

        if (
            !isContract(to) &&
            automatedMarketMakerPairs[from] &&
            !_isFeeExempt[to]
        ) {
            if (_holderLastSellDate[to] >= block.timestamp) {
                _holderLastSellDate[to] = _holderLastSellDate[to].add(
                    block.timestamp.sub(_holderLastSellDate[to]).div(3)
                );
            }
        }

        if (
            automatedMarketMakerPairs[to] &&
            from != address(uniswapV2Router) &&
            !_isTxLimitExempt[from] &&
            !_isTxLimitExempt[to]
        ) {
            require(
                amount <= maxTxAmount,
                "KBBBBBLAH: Exceeds max sell amount"
            );

            amount = amount.mul(maxTxPercent).div(100);
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
        if (contractTokenBalance > maxSwapTokenAmount){
            contractTokenBalance = maxSwapTokenAmount;
        }

        if (
            canSwap &&
            !swapping &&
            swappingEnabled &&
            !automatedMarketMakerPairs[from] &&
            !_isFeeExempt[to] &&
            !_isFeeExempt[from] &&
            totalFees > 0
        ) {
            swapping = true;

            uint256 sellTokens = contractTokenBalance;
            swapBack(sellTokens);

            swapping = false;
        }

        bool takeFee = !swapping;

        if (
            _isFeeExempt[from] ||
            _isFeeExempt[to] ||
            from == address(this)
        ) {
            takeFee = false;
        }

        if (takeFee) {
            uint256 fees = amount.mul(totalFees).div(100);

            if(automatedMarketMakerPairs[to]) {
                fees = fees.mul(getHolderSellFactor(from)).div(100);
                _holderLastSellDate[from] = block.timestamp;
            }

        	amount = amount.sub(fees);

            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);

        try dividendTracker.setBalance(
            payable(from),
            balanceOf(from)
        ) {} catch {}
        try dividendTracker.setBalance(
            payable(to),
            balanceOf(to)
        ) {} catch {}

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
            } catch {
                emit ErrorInProcess(msg.sender);
            }
        }

        if(gameIsEnabled && msg.sender != uniswapV2Pair){
            KBBBBBLAHGameInstance.endUserGames(msg.sender);
        }
    }

    function swapBack(uint256 contractTokenBalance) internal {
        uint256 amountToLiquify = contractTokenBalance
            .mul(liquidityFee)
            .div(totalFees)
            .div(2);
        uint256 amountToSwap = contractTokenBalance.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uint256 balanceBefore = address(this).balance;

        swapTokensForEth(amountToSwap);

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalBNBFee = totalFees.sub(liquidityFee.div(2));

        uint256 amountBNBLiquidity = amountBNB
            .mul(liquidityFee)
            .div(totalBNBFee)
            .div(2);
        uint256 amountBNBReflection = amountBNB
            .mul(rewardsFee)
            .div(totalBNBFee);
        uint256 amountBNBOperations = amountBNB
            .mul(operationsFee)
            .div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB
            .mul(marketingFee)
            .div(totalBNBFee);
        uint256 amountBNBBuyBack = amountBNB
            .mul(buyBackFee)
            .div(totalBNBFee);

        (bool success,) = address(dividendTracker).call{
            value: amountBNBReflection}("");

        if (success) {
            emit SendDividends(amountBNBReflection);
        }

        (success,) = address(operationsWallet).call{
            value: amountBNBOperations}("");

        (success,) = address(marketingWallet).call{
            value: amountBNBMarketing}("");

        (success,) =  address(buyBackWallet).call{
            value: amountBNBBuyBack}("");

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

    function manualSwapKB(uint256 tokenAmount) public onlyOwner {
        /// @dev only use to manualy swap contract token balance,
        ///   if auto swap malfunctions to clear stuck contract balance.
        /// Note only use if absolutely necessary (emergency use only).
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

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

    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(half);

        uint256 newBalance = address(this).balance.sub(initialBalance);

        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function buyBackTokens(uint256 bnbAmountInWei) external onlyOwner {
        // generate the uniswap pair path of weth -> eth
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: bnbAmountInWei
        }(
            0, // accept any amount of Ethereum
            path,
            address(0xdead),
            block.timestamp
        );
    }
}