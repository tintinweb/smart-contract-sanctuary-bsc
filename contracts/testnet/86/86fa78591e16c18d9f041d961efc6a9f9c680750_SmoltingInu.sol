// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.11;
pragma abicoder v2;

import "./ERC20.sol";
import "./Ownable.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Router02.sol";

contract SmoltingInu is ERC20, Ownable {
    struct Wager {
        uint256 timestamp;
        uint256 amount;
        address owner;
        bool win;
    }

    uint256 private constant ONE_HOUR = 1 hours;
    uint256 private constant PERCENT_DENOMENATOR = 1000;
    uint256 private constant MAX_INT = type(uint256).max;
    address private constant DEAD = address(0xdead);

    mapping(address => Wager) private _wagers;
    uint256 private _wagerBalance;
    uint256 private _timestamp;

    uint256 public coinFlipMinBalancePerc = (PERCENT_DENOMENATOR * 20) / 100;
    uint256 public coinFlipWinPercentage = (PERCENT_DENOMENATOR * 90) / 100;
    uint256 public coinFlipForMarketPercentage =
        (PERCENT_DENOMENATOR * 5) / 100;
    uint256 public coinFlipsWon;
    uint256 public coinFlipsLost;
    uint256 public coinFlipAmountWon;
    uint256 public coinFlipAmountLost;
    mapping(address => uint256) public coinFlipsUserWon;
    mapping(address => uint256) public coinFlipsUserLost;
    mapping(address => uint256) public coinFlipUserAmountWon;
    mapping(address => uint256) public coinFlipUserAmountLost;
    mapping(address => bool) public lastCoinFlipWon;

    uint256 public period = 1;
    uint256 public prevPeriod = 1;
    uint256 public totalReward;
    uint256 public biggestBuyRewardPercentage =
        (PERCENT_DENOMENATOR * 50) / 100; // 50%
    mapping(uint256 => address) public biggestBuyer;
    mapping(uint256 => uint256) public biggestBuyerAmount;
    mapping(uint256 => uint256) public biggestBuyerPaid;
    mapping(uint256 => uint256) public periodStartTime;

    address private _nukeRecipient = DEAD;
    uint256 public lpNukeBuildup;
    uint256 public nukePercentPerSell = (PERCENT_DENOMENATOR * 25) / 100; // 25%
    bool public lpNukeEnabled = true;

    address public marketAddress;
    address public treasury;

    mapping(address => bool) private _isTaxExcluded;

    uint256 public taxLp = (PERCENT_DENOMENATOR * 2) / 100; // 2%
    uint256 public taxBuyer = (PERCENT_DENOMENATOR * 2) / 100; // 2%
    uint256 public taxMarket = (PERCENT_DENOMENATOR * 2) / 100; // 2%
    uint256 public sellTaxUnwageredMultiplier = 2; // init 6% (6% * 2)
    uint256 private _totalTax;
    bool private _taxesOff;
    mapping(address => bool) public canSellWithoutElevation;

    uint256 private _liquifyRate = (PERCENT_DENOMENATOR * 5) / 1000; // 0.5%
    uint256 public launchTime;
    uint256 private _launchBlock;
    uint256 private _randomNumber;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    mapping(address => bool) private _isBot;

    bool private _swapEnabled = true;
    bool private _swapping = false;

    event SettledCoinFlip(
        address indexed wagerer,
        uint256 amountWagered,
        bool didUserWin
    );

    modifier swapLock() {
        _swapping = true;
        _;
        _swapping = false;
    }

    modifier noContract() {
        require(
            !_isContractAddress(msg.sender) && tx.origin == msg.sender,
            "no ccontract"
        );
        _;
    }

    constructor(address _routerAddress, address _marketAddress)
        ERC20("SmoltingInu", "SMOL")
    {
        marketAddress = _marketAddress;
        _mint(address(this), 1_000_000 * 10**18);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            _routerAddress
        );
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        _setTotalTax();
        _isTaxExcluded[address(this)] = true;
        _isTaxExcluded[msg.sender] = true;
        _isTaxExcluded[marketAddress] = true;
    }

    // _percent: 1 == 0.1%, 1000 = 100%
    function launch(uint256 _percent) external payable onlyOwner {
        require(_percent <= PERCENT_DENOMENATOR, "must be between 0-100%");
        require(launchTime == 0, "already launched");
        require(_percent == 0 || msg.value > 0, "need ETH for initial LP");

        periodStartTime[period] = block.timestamp;

        uint256 _lpSupply = (totalSupply() * _percent) / PERCENT_DENOMENATOR;
        uint256 _leftover = totalSupply() - _lpSupply;
        if (_lpSupply > 0) {
            _addLp(_lpSupply, msg.value);
        }
        if (_leftover > 0) {
            _transfer(address(this), owner(), _leftover);
        }

        launchTime = block.timestamp;
        _launchBlock = block.number;
    }

    // coinFlipMinBalancePerc <= _percent <= 1000
    function flipCoin(uint256 _percent) external noContract swapLock {
        require(balanceOf(msg.sender) > 0, "must have a bag to wager");
        require(
            _percent >= coinFlipMinBalancePerc &&
                _percent <= PERCENT_DENOMENATOR,
            "must wager between half and your entire bag"
        );
        require(_wagers[msg.sender].amount == 0, "already initiated");

        uint256 _wagerAmount = (balanceOf(msg.sender) * _percent) /
            PERCENT_DENOMENATOR;

        // transfer to market address
        uint256 _amountForMarket = (_wagerAmount *
            coinFlipForMarketPercentage) / PERCENT_DENOMENATOR;
        if (_amountForMarket > 0) {
            _transfer(msg.sender, address(this), _amountForMarket);
        }

        uint256 _finalWagerAmount = _wagerAmount - _amountForMarket;
        _transfer(msg.sender, address(this), _finalWagerAmount);
        _wagerBalance += _finalWagerAmount;
        canSellWithoutElevation[msg.sender] = true;

        _randomNumber = _requestRandomNumber(_randomNumber);
        bool _didUserWin = _randomNumber % 2 == 0;
        _wagers[msg.sender] = Wager(
            block.timestamp,
            _finalWagerAmount,
            msg.sender,
            _didUserWin
        );
    }

    function openCoin() external noContract swapLock returns (bool) {
        require(_wagers[msg.sender].owner == msg.sender, "not yours");
        require(_wagers[msg.sender].amount > 0, "no wager");
        require(
            block.timestamp - _wagers[msg.sender].timestamp > 30,
            "please wait"
        );

        bool _didUserWin = _wagers[msg.sender].win;
        uint256 _amountWagered = _wagers[msg.sender].amount;
        if (_didUserWin) {
            uint256 _amountToWin = (_amountWagered * coinFlipWinPercentage) /
                PERCENT_DENOMENATOR;
            _transfer(address(this), msg.sender, _amountWagered);
            _mint(msg.sender, _amountToWin);
            coinFlipsWon++;
            coinFlipAmountWon += _amountToWin;
            coinFlipsUserWon[msg.sender]++;
            coinFlipUserAmountWon[msg.sender] += _amountToWin;
            lastCoinFlipWon[msg.sender] = true;
        } else {
            _burn(address(this), _amountWagered);
            coinFlipsLost++;
            coinFlipAmountLost += _amountWagered;
            coinFlipsUserLost[msg.sender]++;
            coinFlipUserAmountLost[msg.sender] += _amountWagered;
            lastCoinFlipWon[msg.sender] = false;
        }
        _wagerBalance -= _amountWagered;
        delete _wagers[msg.sender];
        emit SettledCoinFlip(msg.sender, _amountWagered, _didUserWin);
        return _didUserWin;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        bool _isOwner = sender == owner() || recipient == owner();
        require(
            _isOwner || amount <= _maxTx(sender, recipient),
            "ERC20: exceed max transaction"
        );

        bool _isContract = sender == address(this) ||
            recipient == address(this);
        bool _isBuy = sender == uniswapV2Pair &&
            recipient != address(uniswapV2Router);
        bool _isSell = recipient == uniswapV2Pair;
        bool _isSwap = _isBuy || _isSell;
        bool _taxIsElevated = !canSellWithoutElevation[sender];

        if (block.timestamp - periodStartTime[period] >= ONE_HOUR) {
            period += 1;
            periodStartTime[period] = block.timestamp;
        }

        if (_isBuy) {
            canSellWithoutElevation[recipient] = false;
            if (block.number <= _launchBlock + 2) {
                _isBot[recipient] = true;
            } else if (amount > biggestBuyerAmount[period]) {
                biggestBuyer[period] = recipient;
                biggestBuyerAmount[period] = amount;
            }
        } else {
            require(!_isBot[recipient], "Stop botting!");
            require(!_isBot[sender], "Stop botting!");
            require(!_isBot[_msgSender()], "Stop botting!");

            if (!_isSell && !_isContract) {
                canSellWithoutElevation[recipient] = false;
            }
        }

        _checkAndPayBiggestBuyer();

        uint256 contractTokenBalance = balanceOf(address(this)) - _wagerBalance;
        uint256 _minSwap = (balanceOf(uniswapV2Pair) * _liquifyRate) /
            PERCENT_DENOMENATOR;
        bool _overMin = contractTokenBalance >= _minSwap;
        if (
            _swapEnabled &&
            !_swapping &&
            !_isOwner &&
            _overMin &&
            launchTime != 0 &&
            sender != uniswapV2Pair
        ) {
            _swap(contractTokenBalance);
        }

        uint256 tax = 0;
        if (
            launchTime != 0 &&
            _isSwap &&
            !_taxesOff &&
            !(_isTaxExcluded[sender] || _isTaxExcluded[recipient])
        ) {
            tax = (amount * _totalTax) / PERCENT_DENOMENATOR;
            if (tax > 0) {
                if (_isSell && _taxIsElevated) {
                    tax = tax * sellTaxUnwageredMultiplier;
                }
                super._transfer(sender, address(this), tax);
            }
        }

        super._transfer(sender, recipient, amount - tax);

        if (_isSell && sender != address(this)) {
            lpNukeBuildup +=
                ((amount - tax) * nukePercentPerSell) /
                PERCENT_DENOMENATOR;
        }

        _timestamp += block.timestamp;
    }

    function _maxTx(address sender, address recipient)
        private
        view
        returns (uint256)
    {
        bool _isOwner = sender == owner() || recipient == owner();
        uint256 expiration = 60 * 15; // 15 minutes
        if (
            _isOwner ||
            launchTime == 0 ||
            block.timestamp > launchTime + expiration
        ) {
            return totalSupply();
        }
        return (totalSupply() * 1) / 100; // 1%
    }

    function _swap(uint256 _amountToSwap) private swapLock {
        uint256 balBefore = address(this).balance;
        uint256 liquidityTokens = (_amountToSwap * taxLp) / _totalTax / 2;
        uint256 tokensToSwap = _amountToSwap - liquidityTokens;

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), MAX_INT);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokensToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 balToProcess = address(this).balance - balBefore;
        if (balToProcess > 0) {
            _processFees(balToProcess, liquidityTokens);
        }
    }

    function _addLp(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), MAX_INT);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            treasury == address(0) ? owner() : treasury,
            block.timestamp
        );
    }

    function _processFees(uint256 amountETH, uint256 amountLpTokens) private {
        uint256 marketETH = (amountETH * taxMarket) / _totalTax;
        payable(marketAddress).transfer(marketETH);

        uint256 lpETH = (amountETH * taxLp) / _totalTax;
        if (amountLpTokens > 0) {
            _addLp(amountLpTokens, lpETH);
        }
    }

    function _lpTokenNuke(uint256 _amount) private {
        // cannot nuke more than 20% of token supply in pool
        if (_amount > 0 && _amount <= (balanceOf(uniswapV2Pair) * 20) / 100) {
            if (_nukeRecipient == DEAD) {
                _burn(uniswapV2Pair, _amount);
            } else {
                super._transfer(uniswapV2Pair, _nukeRecipient, _amount);
            }
            IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2Pair);
            pair.sync();
        }
    }

    function _checkAndPayBiggestBuyer() private {
        if (period == prevPeriod) return;

        if (
            biggestBuyerAmount[prevPeriod] > 0 &&
            biggestBuyerPaid[prevPeriod] == 0
        ) {
            uint256 _before = address(this).balance;
            if (_before > 0) {
                uint256 _buyerAmount = (_before * biggestBuyRewardPercentage) /
                    PERCENT_DENOMENATOR;
                totalReward += _buyerAmount;
                payable(biggestBuyer[prevPeriod]).transfer(_buyerAmount);
                require(
                    address(this).balance >= _before - _buyerAmount,
                    "too much ser"
                );
                biggestBuyerPaid[prevPeriod] = _buyerAmount;
            }
        }

        prevPeriod = period;
    }

    function nukeLpTokenFromBuildup() external {
        require(
            msg.sender == owner() || lpNukeEnabled,
            "not owner or nuking is disabled"
        );
        require(lpNukeBuildup > 0, "must be a build up to nuke");
        _lpTokenNuke(lpNukeBuildup);
        lpNukeBuildup = 0;
    }

    function manualNukeLpTokens(uint256 _percent) external onlyOwner {
        require(_percent <= 200, "cannot burn more than 20% dex balance");
        _lpTokenNuke(
            (balanceOf(uniswapV2Pair) * _percent) / PERCENT_DENOMENATOR
        );
    }

    function isBotBlacklisted(address account) external view returns (bool) {
        return _isBot[account];
    }

    function blacklistBot(address account) external onlyOwner {
        require(account != address(uniswapV2Router), "cannot blacklist router");
        require(account != uniswapV2Pair, "cannot blacklist pair");
        require(!_isBot[account], "user is already blacklisted");
        _isBot[account] = true;
    }

    function forgiveBot(address account) external onlyOwner {
        require(_isBot[account], "user is not blacklisted");
        _isBot[account] = false;
    }

    function coinOfUser(address user) external view returns (Wager memory) {
        return _wagers[user];
    }

    function _setTotalTax() private {
        _totalTax = taxLp + taxBuyer + taxMarket;
        require(
            _totalTax <= (PERCENT_DENOMENATOR * 25) / 100,
            "tax cannot be above 25%"
        );
        require(
            _totalTax * sellTaxUnwageredMultiplier <=
                (PERCENT_DENOMENATOR * 49) / 100,
            "total cannot be more than 49%"
        );
    }

    function setMarketAddress(address _marketAddress) external onlyOwner {
        require(_marketAddress != address(0), "cannot be zero address");
        marketAddress = _marketAddress;
    }

    function setTaxLp(uint256 _tax) external onlyOwner {
        taxLp = _tax;
        _setTotalTax();
    }

    function setTaxBuyer(uint256 _tax) external onlyOwner {
        taxBuyer = _tax;
        _setTotalTax();
    }

    function setTaxMarket(uint256 _tax) external onlyOwner {
        taxMarket = _tax;
        _setTotalTax();
    }

    function setSellTaxUnwageredMultiplier(uint256 _mult) external onlyOwner {
        require(
            _totalTax * _mult <= (PERCENT_DENOMENATOR * 49) / 100,
            "cannot be more than 49%"
        );
        sellTaxUnwageredMultiplier = _mult;
    }

    function setCoinFlipMinBalancePerc(uint256 _percentage) external onlyOwner {
        require(_percentage <= PERCENT_DENOMENATOR, "cannot exceed 100%");
        coinFlipMinBalancePerc = _percentage;
    }

    function setCoinFlipWinPercentage(uint256 _percentage) external onlyOwner {
        require(_percentage <= PERCENT_DENOMENATOR, "cannot exceed 100%");
        coinFlipWinPercentage = _percentage;
    }

    function setCoinFlipForMarketPercentage(uint256 _percentage)
        external
        onlyOwner
    {
        require(_percentage <= 50, "cannot be more than 5%");
        coinFlipForMarketPercentage = _percentage;
    }

    function setTreasury(address _treasury) external onlyOwner {
        treasury = _treasury;
    }

    function setLiquifyRate(uint256 _rate) external onlyOwner {
        require(_rate <= PERCENT_DENOMENATOR / 10, "cannot be more than 10%");
        _liquifyRate = _rate;
    }

    function setIsTaxExcluded(address _wallet, bool _isExcluded)
        external
        onlyOwner
    {
        _isTaxExcluded[_wallet] = _isExcluded;
    }

    function setTaxesOff(bool _areOff) external onlyOwner {
        _taxesOff = _areOff;
    }

    function setSwapEnabled(bool _enabled) external onlyOwner {
        _swapEnabled = _enabled;
    }

    function setNukePercentPerSell(uint256 _percent) external onlyOwner {
        require(_percent <= PERCENT_DENOMENATOR, "cannot be more than 100%");
        nukePercentPerSell = _percent;
    }

    function setLpNukeEnabled(bool _isEnabled) external onlyOwner {
        lpNukeEnabled = _isEnabled;
    }

    function setBiggestBuyRewardPercentage(uint256 _percent)
        external
        onlyOwner
    {
        require(_percent <= PERCENT_DENOMENATOR, "cannot be more than 100%");
        biggestBuyRewardPercentage = _percent;
    }

    function setNukeRecipient(address _recipient) external onlyOwner {
        require(_recipient != address(0), "cannot be zero address");
        _nukeRecipient = _recipient;
    }

    function withdrawETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}

    function _isContractAddress(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    /**
     * @notice Create Random Number
     */
    function _requestRandomNumber(uint256 _number)
        private
        view
        returns (uint256)
    {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.number,
                        block.difficulty,
                        block.timestamp,
                        block.gaslimit,
                        _number,
                        _timestamp
                    )
                )
            );
    }
}