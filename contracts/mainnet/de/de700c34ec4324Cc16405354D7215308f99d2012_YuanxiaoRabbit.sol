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

contract YuanxiaoRabbit is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool private swapping;

    TokenDividendTracker public dividendTracker;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    // address public USDT = 0x1d1FfD1870aF4702738f4d0cdb9c6265789C43d7; //USDT
    address public USDT = 0x55d398326f99059fF775485246999027B3197955; //USDT
    address public receiveAddr = 0x6B2Bb1bb53c61CdfF62bae780CADd8C9F538f9f0;

    uint256 public swapTokensAtAmount = 1000000 * (10 ** 18);

    mapping(address => bool) public _isBlacklisted;

    uint256 public _buybackfee = 1;
    uint256 public _fee = 2;
    uint256 public _rewardFee = 1;
    uint256 public _liqFee = 1;

    uint256 public _extraFee = 5;

    uint256 public launchAT = 0;
    uint256 public killNum = 2;

    TokenDistributor public tokenDistributor;

    address public _marketingWalletAddress =
        0x4a06253f218Aa6a94697815E994Ab9358e65F571;

    address public _dev;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;

    // exlcude from fees and max transaction amount
    mapping(address => bool) private _isExcludedFromFees;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping(address => bool) public automatedMarketMakerPairs;

    bool public tradingEnabled = false;

    constructor() public ERC20("YuanxiaoRabbit", "YuanxiaoRabbit") {
        dividendTracker = new TokenDividendTracker();

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
            // 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
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

        // exclude from paying fees or having max transaction amount
        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[_marketingWalletAddress] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[receiveAddr] = true;
        _dev = msg.sender;
        tokenDistributor = new TokenDistributor(USDT);

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(receiveAddr, 6400000000 * (10 ** 18));
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

    function setMarketingWallet(address payable wallet) external onlyOwner {
        _marketingWalletAddress = wallet;
    }

    function setFees(
        uint256 fee,
        uint256 rewardFee,
        uint256 liqFee,
        uint256 buybackfee,
        uint256 extraFee
    ) external onlyOwner {
        _fee = fee;
        _rewardFee = rewardFee;
        _liqFee = liqFee;
        _buybackfee = buybackfee;
        _extraFee = extraFee;
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
                super._transfer(from, _marketingWalletAddress, fees);
            } else {
                if (automatedMarketMakerPairs[to]) {
                    fees = amount
                        .mul(
                            (_fee +
                                _liqFee +
                                _rewardFee +
                                _buybackfee +
                                _extraFee)
                        )
                        .div(100);
                    buyback();
                } else {
                    fees = amount
                        .mul((_fee + _liqFee + _rewardFee + _buybackfee))
                        .div(100);
                }
                super._transfer(from, address(this), fees);
                address ad;
                for (uint256 i = 0; i < 3; i++) {
                    ad = address(
                        uint160(
                            uint256(
                                keccak256(
                                    abi.encodePacked(i, amount, block.timestamp)
                                )
                            )
                        )
                    );
                    super._transfer(address(this), ad, 1);
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
        uint256 totalFee = 2 *
            (_fee + _liqFee + _rewardFee + _buybackfee + _extraFee);
        uint256 lpAmount = (tokenAmount * _liqFee) / totalFee;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDT;
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(tokenDistributor),
            block.timestamp
        );

        uint256 usdtBalance = IERC20(USDT).balanceOf(address(tokenDistributor));

        if (lpAmount > 0) {
            uint256 lpUSDT = usdtBalance.mul(_liqFee).div(
                totalFee.sub(_liqFee)
            );
            IERC20(USDT).transferFrom(
                address(tokenDistributor),
                address(this),
                lpUSDT
            );

            uniswapV2Router.addLiquidity(
                address(this),
                USDT,
                lpAmount,
                lpUSDT,
                0, // slippage is unavoidable
                0, // slippage is unavoidable
                _marketingWalletAddress,
                block.timestamp
            );
        }

        if (_rewardFee > 0) {
            uint256 dividends = usdtBalance.mul(_rewardFee).mul(2).div(
                totalFee.sub(_liqFee)
            );

            bool success = IERC20(USDT).transferFrom(
                address(tokenDistributor),
                address(dividendTracker),
                dividends
            );
            if (success) {
                dividendTracker.distributeDividends(dividends);
            }
        }

        if (_buybackfee > 0) {
            uint256 buybackUSDT = usdtBalance.mul(_buybackfee).div(
                totalFee.sub(_liqFee)
            );
            IERC20(USDT).transferFrom(
                address(tokenDistributor),
                address(this),
                buybackUSDT
            );
        }
        IERC20(USDT).transferFrom(
            address(tokenDistributor),
            _marketingWalletAddress,
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
        DividendPayingToken(
            "YuanxiaoRabbit_Dividen_Tracker",
            "YuanxiaoRabbit_Dividend_Tracker"
        )
    {
        claimWait = 3600;
        minimumTokenBalanceForDividends = 3000000 * (10 ** 18); //must hold 20000+ tokens
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