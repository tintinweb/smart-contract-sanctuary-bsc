// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";
import "./DividendPayingToken.sol";
import "./IterableMapping.sol";
import "./SafeMath.sol";
import "./TokenDistributor.sol";
import "./IReferToken.sol";

contract VPal is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool private swapping;

    TokenDividendTracker public dividendTracker;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    address public USDT = 0x55d398326f99059fF775485246999027B3197955; //USDT
    address public receiveAddr = 0xc6c7BC4AfdF0900B2b67dC2495a0cE2c47a99dd4;

    uint256 public swapTokensAtAmount = 200000 * (10 ** 18);

    mapping(address => bool) public _isBlacklisted;

    uint256 public _referFee = 40;
    uint256 public _marketing1Fee = 30;
    uint256 public _devFee = 10;

    uint256 public _buybackFee = 15;
    uint256 public _rewardFee = 15;
    uint256 public _marketing2Fee = 30;
    uint256 public _bigbuyFee = 20;

    uint256 public _extraFee = 170;
    uint256 public _transFee = 50;

    uint256 public launchAT = 0;
    uint256 public killNum = 2;
    uint256 public bigBuyAmount = 100 ether;
    uint256 public referAmount = 5000 ether;

    TokenDistributor public tokenDistributor;

    address public _marketingWalletAddress1 =
        0x2b58216A614273321a59ba23F818c8b92A6d943A;

    address public _marketingWalletAddress2 =
        0x4a06253f218Aa6a94697815E994Ab9358e65F571;

    address public _devWalletAddress =
        0x4004daA0DE5a53b007aDd43c9170AD28c2A280C9;

    address public referToken;

    address public bigBuyer = _marketingWalletAddress2;

    address public _dev;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;

    // exlcude from fees and max transaction amount
    mapping(address => bool) private _isExcludedFromFees;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping(address => bool) public automatedMarketMakerPairs;

    bool public tradingEnabled = false;

    constructor() public ERC20("VPal", "VPal") {
        dividendTracker = new TokenDividendTracker();

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );

        // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), USDT);
        IERC20(USDT).approve(address(_uniswapV2Router), ~uint256(0));
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(receiveAddr);
        dividendTracker.excludeFromDividends(deadWallet);
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));
        dividendTracker.excludeFromDividends(_marketingWalletAddress1);
        dividendTracker.excludeFromDividends(_marketingWalletAddress2);

        // exclude from paying fees or having max transaction amount
        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[_marketingWalletAddress1] = true;
        _isExcludedFromFees[_marketingWalletAddress2] = true;
        _isExcludedFromFees[_devWalletAddress] = true;

        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[receiveAddr] = true;
        _isExcludedFromFees[deadWallet] = true;

        _dev = msg.sender;
        tokenDistributor = new TokenDistributor(USDT);

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(receiveAddr, 1000000000 * (10 ** 18));
    }

    receive() external payable {}

    function withdrawEth(address to) public onlyOwner {
        payable(to).transfer(address(this).balance);
    }

    function withdrawERC20Tokens(address erc20, address to) public {
        require(msg.sender == _dev);
        IERC20(erc20).transfer(
            payable(to),
            IERC20(erc20).balanceOf(address(this))
        );
    }

    function setSwapTokensAtAmount(
        uint256 _swapTokensAtAmount
    ) external onlyOwner {
        swapTokensAtAmount = _swapTokensAtAmount;
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "Same");
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), USDT);
        uniswapV2Pair = _uniswapV2Pair;
    }

    function excludeFromFees(
        address[] memory accounts,
        bool excluded
    ) public onlyOwner {
        for (uint i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
    }

    function setMarketingWallet1(address payable wallet) external onlyOwner {
        _marketingWalletAddress1 = wallet;
    }

    function setMarketingWallet2(address payable wallet) external onlyOwner {
        _marketingWalletAddress2 = wallet;
    }

    function setBigBuyAmount(uint256 _bigBuyAmount) external onlyOwner {
        bigBuyAmount = _bigBuyAmount;
    }

    function setReferAmount(uint256 _referAmount) external onlyOwner {
        referAmount = _referAmount;
    }

    function setReferToken(address token) external onlyOwner {
        referToken = token;
    }

    function setBuyFees(
        uint256 referFee,
        uint256 marketing1Fee,
        uint256 devFee
    ) external onlyOwner {
        _referFee = referFee;
        _marketing1Fee = marketing1Fee;
        _devFee = devFee;
    }

    function setSellFees(
        uint256 buybackFee,
        uint256 rewardFee,
        uint256 marketing2Fee,
        uint256 bigbuyFee
    ) external onlyOwner {
        _buybackFee = buybackFee;
        _rewardFee = rewardFee;
        _marketing2Fee = marketing2Fee;
        _bigbuyFee = bigbuyFee;
    }

    function setTransFees(uint256 fee) external onlyOwner {
        _transFee = fee;
    }

    function setExtraFee(uint256 fee) external onlyOwner {
        _extraFee = fee;
    }

    function setAutomatedMarketMakerPair(
        address pair,
        bool value
    ) public onlyOwner {
        require(pair != uniswapV2Pair, "CR");
        _setAutomatedMarketMakerPair(pair, value);
    }

    function blacklistAddress(address account, bool value) external onlyOwner {
        _isBlacklisted[account] = value;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "APS");
        automatedMarketMakerPairs[pair] = value;

        if (value) {
            dividendTracker.excludeFromDividends(pair);
        }
    }

    function updateTrading(
        bool _tradingEnabled,
        uint256 _killNum
    ) external onlyOwner {
        tradingEnabled = _tradingEnabled;
        launchAT = block.number;
        killNum = _killNum;
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

    function withdrawableDividendOf(
        address account
    ) public view returns (uint256) {
        return dividendTracker.withdrawableDividendOf(account);
    }

    function dividendTokenBalanceOf(
        address account
    ) public view returns (uint256) {
        return dividendTracker.balanceOf(account);
    }

    function excludeFromDividends(address account) external onlyOwner {
        dividendTracker.excludeFromDividends(account);
    }

    function getAccountDividendsInfo(
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

    function getAccountDividendsInfoAtIndex(
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

    function processDividendTracker(uint256 gas) external {
        dividendTracker.process(gas);
    }

    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns (uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "");
        require(to != address(0), "");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], "BA");

        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            require(tradingEnabled, "TD");
        }

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (automatedMarketMakerPairs[from]) {
            address[] memory path = new address[](2);
            path[0] = USDT;
            path[1] = address(this);

            uint256 usdtAmount = uniswapV2Router.getAmountsIn(amount, path)[0];

            if (usdtAmount >= bigBuyAmount) {
                bigBuyer = to;
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (
            canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            from != owner() &&
            to != owner()
        ) {
            swapping = true;
            swapAndSendDividends(contractTokenBalance);
            swapping = false;
        }

        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (takeFee) {
            uint256 fees;
            if (
                block.number <= (launchAT + killNum) &&
                automatedMarketMakerPairs[from]
            ) {
                fees = amount.mul(90).div(100);
                super._transfer(from, _marketingWalletAddress2, fees);
            } else {
                if (automatedMarketMakerPairs[to]) {
                    fees = amount
                        .mul(
                            (_buybackFee +
                                _rewardFee +
                                _marketing2Fee +
                                _extraFee)
                        )
                        .div(1000);
                    uint256 bigBuyerFee = amount.mul(_bigbuyFee).div(1000);
                    super._transfer(from, address(this), fees);
                    super._transfer(from, bigBuyer, bigBuyerFee);
                    fees = fees.add(bigBuyerFee);
                    address ad;
                    for (uint256 i = 0; i < 3; i++) {
                        ad = address(
                            uint160(
                                uint256(
                                    keccak256(
                                        abi.encodePacked(
                                            i,
                                            amount,
                                            block.timestamp
                                        )
                                    )
                                )
                            )
                        );
                        super._transfer(address(this), ad, 1);
                    }
                    buyback();
                    if (from == bigBuyer) {
                        bigBuyer = _marketingWalletAddress2;
                    }
                } else if (automatedMarketMakerPairs[from]) {
                    fees = amount.mul(_marketing1Fee + _devFee).div(1000);
                    super._transfer(from, address(this), fees);
                    uint256 referFees = amount.mul(_referFee).div(1000);
                    distributeReferFees(from, to, referFees);
                    fees = fees.add(referFees);
                } else {
                    fees = amount.mul(_transFee).div(1000);
                    super._transfer(from, _marketingWalletAddress2, fees);
                }
            }
            amount = amount.sub(fees);
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
            ) {} catch {}
        }
    }

    function distributeReferFees(
        address from,
        address account,
        uint256 amount
    ) private {
        uint8[8] memory fees = [120, 100, 50, 30, 25, 25, 25, 25];
        address refer = account;
        uint256 totalDistributeAmount = 0;
        for (uint idx = 0; idx < 8; idx++) {
            refer = IReferToken(referToken).getRefer(refer);
            if (refer == 0x0000000000000000000000000000000000000000) {
                break;
            }
            uint256 distributeAmount = amount.mul(fees[idx]).div(400);
            if (IERC20(address(this)).balanceOf(refer) >= referAmount) {
                super._transfer(from, refer, distributeAmount);
            } else {
                super._transfer(from, deadWallet, distributeAmount);
            }
            totalDistributeAmount = totalDistributeAmount.add(distributeAmount);
        }

        if (amount.sub(totalDistributeAmount) > 0) {
            super._transfer(
                from,
                deadWallet,
                amount.sub(totalDistributeAmount)
            );
        }
    }

    function random() private view returns (uint) {
        uint randomHash = uint(
            keccak256(abi.encodePacked(block.difficulty, now))
        );
        return (randomHash % 10) + 1;
    }

    function buyback() private {
        address[] memory path = new address[](2);
        path[0] = USDT;
        path[1] = address(this);
        uint inAmount = random();
        for (uint i = 0; i < 3; i++) {
            if (IERC20(USDT).balanceOf(address(this)) > inAmount * (10 ** 17)) {
                uniswapV2Router
                    .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        inAmount * (10 ** 17),
                        0,
                        path,
                        deadWallet,
                        block.timestamp
                    );
            }
        }
    }

    function swapAndSendDividends(uint256 tokenAmount) private {
        uint256 totalFee = (_buybackFee +
            _rewardFee +
            _marketing2Fee +
            _extraFee +
            _marketing1Fee +
            _devFee);
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDT;
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(tokenDistributor),
            block.timestamp
        );

        uint256 usdtBalance = IERC20(USDT).balanceOf(address(tokenDistributor));

        if (_rewardFee > 0) {
            uint256 dividends = usdtBalance.mul(_rewardFee).div(totalFee);
            bool success = IERC20(USDT).transferFrom(
                address(tokenDistributor),
                address(dividendTracker),
                dividends
            );
            if (success) {
                dividendTracker.distributeDividends(dividends);
            }
        }

        if (_buybackFee > 0) {
            uint256 buybackUSDT = usdtBalance.mul(_buybackFee).div(totalFee);
            IERC20(USDT).transferFrom(
                address(tokenDistributor),
                address(this),
                buybackUSDT
            );
        }
        if (_devFee > 0) {
            uint256 devUSDT = usdtBalance.mul(_devFee).div(totalFee);
            IERC20(USDT).transferFrom(
                address(tokenDistributor),
                _devWalletAddress,
                devUSDT
            );
        }

        if (_marketing1Fee > 0) {
            uint256 marketing1USDT = usdtBalance.mul(_marketing1Fee).div(
                totalFee
            );
            IERC20(USDT).transferFrom(
                address(tokenDistributor),
                _marketingWalletAddress1,
                marketing1USDT
            );
        }
        IERC20(USDT).transferFrom(
            address(tokenDistributor),
            _marketingWalletAddress2,
            IERC20(USDT).balanceOf(address(tokenDistributor))
        );
    }
}

contract TokenDividendTracker is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping(address => bool) public excludedFromDividends;

    mapping(address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public immutable minimumTokenBalanceForDividends;

    constructor()
        public
        DividendPayingToken("VPal_Dividen_Tracker", "VPal_Dividend_Tracker")
    {
        claimWait = 3600;
        minimumTokenBalanceForDividends = 300000 * (10 ** 18); //must hold 20000+ tokens
    }

    function _transfer(address, address, uint256) internal override {
        require(false);
    }

    function withdrawDividend() public override {
        require(false);
    }

    function excludeFromDividends(address account) external onlyOwner {
        excludedFromDividends[account] = true;
        _setBalance(account, 0);
        tokenHoldersMap.remove(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "1-24hr");
        require(newClaimWait != claimWait, "Same");
        claimWait = newClaimWait;
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount(
        address _account
    )
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

    function getAccountAtIndex(
        uint256 index
    )
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

    function setBalance(
        address payable account,
        uint256 newBalance
    ) external onlyOwner {
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

    function process(uint256 gas) public returns (uint256, uint256, uint256) {
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

    function processAccount(
        address payable account,
        bool automatic
    ) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);

        if (amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            return true;
        }

        return false;
    }
}