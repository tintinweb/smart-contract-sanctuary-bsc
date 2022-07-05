/// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

import "./SafeMath.sol";
import "./SafeMathInt.sol";
import "./IERC20.sol";
import "./IPancakeSwapFactory.sol";
import "./IPancakeSwapRouter.sol";
import "./IPancakeSwapPair.sol";
import "./Ownable.sol";
import "./ERC20Detailed.sol";

contract AbTest is ERC20Detailed, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event JackpotAwarded(address indexed receiver, uint256 amount);
    event Combustion(uint256 cashedOut, uint256 tokensOut);

    string public constant _name = "AB Test";
    string public constant _symbol = "ABT";
    uint8 public constant _decimals = 5;

    IPancakeSwapPair public pairContract;
    mapping(address => bool) _isFeeExempt;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint256 public constant DECIMALS = 5;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 7;
    // At any given time, buy and sell fees can NOT exceed 25% each
    uint256 private constant TOTAL_FEES_LIMIT = 250;

    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 10**5 * 10**DECIMALS;
    uint256 private constant BNB_DECIMALS = 18;
    uint256 private constant BUSD_DECIMALS = 18;

    uint256 public liquidityFee = 40;
    uint256 public MarketingFundFee = 20;
    uint256 public treasuryFee = 20;
    uint256 public afterburnerFee = 30;

    uint256 public afterburnerSellFee = 70;
    uint256 public sellFee = 40;

    uint256 public totalFee =
        liquidityFee.add(treasuryFee).add(MarketingFundFee).add(
            afterburnerFee
        );
    uint256 public constant feeDenominator = 1000;

    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    address constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // testnet
    // address constant BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; // mainnet
    uint256 private constant MAX_PCT = 10000;
    // PCS takes 0.25% fee on all txs
    uint256 private constant ROUTER_FEE = 25;

    address public autoLiquidityReceiver;
    address public treasuryReceiver;
    address public MarketingFundReceiver;
    address public pairAddress;
    address public buybackWallet;
    bool public constant swapEnabled = true;
    IPancakeSwapRouter public router;
    address public pair;
    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 private constant TOTAL_GONS =
        MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 private constant MAX_SUPPLY = 100 * 1e9 * 10**DECIMALS;

    uint256 public INDEX;

    bool public _autoRebase;
    bool public _autoAddLiquidity;
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public _totalSupply;
    uint256 private _gonsPerFragment;
    bool public _isRebaseStarted;

    uint public ownerRebaseRate;
    bool public isOwnerRebaseEnabled;


    // 50.00% jackpot cashout to last buyer
    uint256 public jackpotCashout = 5000;
    // 50.00% of jackpot cashout to last buyer
    uint256 public jackpotBuyerShare = 5000;
    // Buys > 0.015 BNB will be eligible for the jackpot
    uint256 public jackpotMinBuy = 1 * 10**(BNB_DECIMALS - 2);
    // Jackpot time span is initially set to 15 mins
    uint256 public jackpotTimespan = 15 * 60;
    // Jackpot hard limit, BUSD value
    uint256 public jackpotHardLimit = 100 * 10**(BUSD_DECIMALS);
    // Jackpot hard limit buyback share
    uint256 public jackpotHardBuyback = 5000;

    uint256 public _jackpotGonsTokens = 0;

    address private _lastBuyer = address(this);
    uint256 private _lastBuyTimestamp = 0;

    address private _lastAwarded = address(0);
    uint256 private _lastAwardedCash = 0;
    uint256 private _lastAwardedTokens = 0;
    uint256 private _lastAwardedTimestamp = 0;

    uint256 private _lastCombustionCash = 0;
    uint256 private _lastCombustionTokens = 0;
    uint256 private _lastCombustionTimestamp = 0;

    uint256 private _totalJackpotCashedOut = 0;
    uint256 private _totalJackpotTokensOut = 0;
    uint256 private _totalJackpotBuyer = 0;
    uint256 private _totalJackpotBuyback = 0;
    uint256 private _totalJackpotBuyerTokens = 0;
    uint256 private _totalJackpotBuybackTokens = 0;

    bool public isTakeFeeOnNormalTransfer = true;

    // Token distribution held by the contract
    uint256 public _pendingJackpotBalance = 0;

    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;

    struct user {
        uint256 firstBuy;
        uint256 lastSellTime;
        uint256 sellAmount;
        uint256 lastBuyTime;
        uint256 buyAmount;
    }

    uint256 public TwentyFourhours = 86400;

    mapping(address => user) public tradeData;
    uint256 public maxSellTransactionAmount = 100 * 10**DECIMALS;
    uint256 public sellLimitPercent = 1;
    uint256 public buyLimitPercent = 10;

    constructor()
        ERC20Detailed("AB Test", "ABT", uint8(DECIMALS))
        Ownable()
    {
        router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // testnet 
        // router = IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // mainnet
        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        autoLiquidityReceiver = 0xae8d659498C1b6b6dc8A353E7D5871c46d030B60;
        treasuryReceiver = 0xA8c6eb1Ab19da93069c6BCFfF880A44c784548f3;
        // treasuryReceiver = msg.sender;
        MarketingFundReceiver = 0x4206731A570359B6AD41cC114784bBd5FE7403B4;
        buybackWallet = 0xfa2dff639b5Bd8F781263B39f829e543aAAC7263;

        _allowedFragments[address(this)][address(router)] = uint256(-1);
        pairAddress = pair;
        pairContract = IPancakeSwapPair(pair);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[treasuryReceiver] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _initRebaseStartTime = block.timestamp;
        _lastRebasedTime = block.timestamp;
        _autoRebase = false;
        _isRebaseStarted = false;
        _autoAddLiquidity = true;
        _isFeeExempt[autoLiquidityReceiver] = true;
        _isFeeExempt[treasuryReceiver] = true;
        _isFeeExempt[MarketingFundReceiver] = true;
        _isFeeExempt[buybackWallet] = true;
        _isFeeExempt[msg.sender] = true;
        _isFeeExempt[address(this)] = true;

        INDEX = gonsForBalance(100000);

        _transferOwnership(treasuryReceiver);
        emit Transfer(address(0x0), treasuryReceiver, _totalSupply);
    }

    function setRebaseRate(uint _rebaseRate) external onlyOwner {
        ownerRebaseRate = _rebaseRate;
    }

    function toggleOwnerRebase() external onlyOwner {
        isOwnerRebaseEnabled = !isOwnerRebaseEnabled;
    }

    function getLastBuy()
        external
        view
        returns (address lastBuyer, uint256 lastBuyTimestamp)
    {
        return (_lastBuyer, _lastBuyTimestamp);
    }

    function getLastAwardedJackpot()
        external
        view
        returns (
            address lastAwarded,
            uint256 lastAwardedCash,
            uint256 lastAwardedTokens,
            uint256 lastAwardedTimestamp
        )
    {
        return (
            _lastAwarded,
            _lastAwardedCash,
            _lastAwardedTokens,
            _lastAwardedTimestamp
        );
    }

    function getPendingJackpotBalance()
        external
        view
        returns (uint256 pendingJackpotBalance)
    {
        return (_pendingJackpotBalance);
    }

    function getPendingJackpotTokens()
        external
        view
        returns (uint256 pendingJackpotTokens)
    {
        return (_jackpotGonsTokens.div(_gonsPerFragment));
    }

    function getLastCombustion()
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (_lastCombustionCash, _lastCombustionTokens, _lastCombustionTimestamp);
    }

    function getJackpot()
        public
        view
        returns (uint256 jackpotTokens, uint256 pendingJackpotAmount)
    {
        return (
            _jackpotGonsTokens.div(_gonsPerFragment),
            _pendingJackpotBalance
        );
    }

    function getLiquidityBacking(uint256 accuracy)
        external
        view
        returns (uint256)
    {
        uint256 liquidityBalance = _gonBalances[pair].div(_gonsPerFragment);
        return
            accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    function getCirculatingSupply() public view returns (uint256) {
        return
            (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(
                _gonsPerFragment
            );
    }

    function totalJackpotOut() external view returns (uint256, uint256) {
        return (_totalJackpotCashedOut, _totalJackpotTokensOut);
    }

    function totalJackpotBuyer() external view returns (uint256, uint256) {
        return (_totalJackpotBuyer, _totalJackpotBuyerTokens);
    }

    function totalJackpotBuyback() external view returns (uint256, uint256) {
        return (_totalJackpotBuyback, _totalJackpotBuybackTokens);
    }

    function startRebase() external onlyOwner {
        // execute only once
        require(!_isRebaseStarted, "Rebase already started");
        if (_isRebaseStarted) return;
        _initRebaseStartTime = block.timestamp;
        _lastRebasedTime = block.timestamp;
        _autoRebase = true;
        _isRebaseStarted = true;
    }

    function rebase() internal {
        if (inSwap) return;
        uint256 rebaseRate;
        uint256 deltaTimeFromInit = block.timestamp - _initRebaseStartTime;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(15 minutes);
        uint256 epoch = times.mul(15);

        if (deltaTimeFromInit >= (3 * 365 days)) {
            rebaseRate = 440;
        } else if (deltaTimeFromInit >= (2 * 365 days)) {
            rebaseRate = 720;
        } else if (deltaTimeFromInit >= (365 days)) {
            rebaseRate = 1000;
        } else {
            rebaseRate = 1320;
        }

        if (isOwnerRebaseEnabled) {
            rebaseRate = ownerRebaseRate;
        }

        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
                .mul((10**RATE_DECIMALS).add(rebaseRate))
                .div(10**RATE_DECIMALS);
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(15 minutes));

        pairContract.sync();

        emit LogRebase(epoch, _totalSupply);
    }

    function transfer(address to, uint256 value)
        external
        override
        validRecipient(to)
        returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {
        if (_allowedFragments[from][msg.sender] != uint256(-1)) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
                msg.sender
            ].sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(!blacklist[sender] && !blacklist[recipient], "in_blacklist");

        bool excludedAccount = _isFeeExempt[sender] || _isFeeExempt[recipient];

        if (recipient == pair && !excludedAccount) {
            require(amount <= maxSellTransactionAmount, "Error amount");

            uint256 blkTime = block.timestamp;

            uint256 onePercent = balanceOf(sender).mul(sellLimitPercent).div(
                100
            ); //Should use variable
            require(amount <= onePercent, "ERR: Can't sell more than 1%");

            if (blkTime > tradeData[sender].lastSellTime + TwentyFourhours) {
                tradeData[sender].lastSellTime = blkTime;
                tradeData[sender].sellAmount = amount;
            } else if (
                (blkTime < tradeData[sender].lastSellTime + TwentyFourhours) &&
                ((blkTime > tradeData[sender].lastSellTime))
            ) {
                require(
                    tradeData[sender].sellAmount + amount <= onePercent,
                    "ERR: Can't sell more than 1% in One day"
                );
                tradeData[sender].sellAmount =
                    tradeData[sender].sellAmount +
                    amount;
            }
        }

        if (sender == pair && !excludedAccount) {
            uint256 blkTime = block.timestamp;

            uint256 onePercent = _totalSupply.mul(buyLimitPercent).div(100); //Should use variable
            require(amount <= onePercent, "ERR: Can't buy more than 1%");

            if (blkTime > tradeData[recipient].lastBuyTime + TwentyFourhours) {
                tradeData[recipient].lastBuyTime = blkTime;
                tradeData[recipient].buyAmount = amount;
            } else if (
                (blkTime < tradeData[recipient].lastBuyTime + TwentyFourhours) &&
                ((blkTime > tradeData[recipient].lastBuyTime))
            ) {
                require(
                    tradeData[recipient].buyAmount + amount <= onePercent,
                    "ERR: Can't buy more than 1% in One day"
                );
                tradeData[recipient].buyAmount =
                    tradeData[recipient].buyAmount +
                    amount;
            }
        }

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        if (shouldRebase()) {
            rebase();
        }

        if (shouldAddLiquidity()) {
            addLiquidity();
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        if (_pendingJackpotBalance >= jackpotHardLimit) {
            processCombustion();
        } else if (shouldAwardJackpot()) {
            awardJackpot();
        }

        if (sender == pair && isJackpotEligible(amount)) {
            _lastBuyTimestamp = block.timestamp;
            _lastBuyer = recipient;
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, recipient, gonAmount)
            : gonAmount;
        _gonBalances[recipient] = _gonBalances[recipient].add(
            gonAmountReceived
        );

        emit Transfer(
            sender,
            recipient,
            gonAmountReceived.div(_gonsPerFragment)
        );
        return true;
    }

    function shouldAwardJackpot() public view returns (bool) {
        return
            _lastBuyer != address(0) &&
            _lastBuyer != address(this) &&
            block.timestamp.sub(_lastBuyTimestamp) >= jackpotTimespan;
    }

    function isJackpotEligible(uint256 tokenAmount) public view returns (bool) {
        if (jackpotMinBuy == 0) {
            return true;
        }
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);

        uint256 tokensOut = router
        .getAmountsOut(jackpotMinBuy, path)[1].mul(MAX_PCT.sub(ROUTER_FEE)).div(
                // We don't subtract the buy fee since the tokenAmount is pre-tax
                MAX_PCT
            );
        return tokenAmount >= tokensOut;
    }

    function processCombustion() internal swapping {
        uint256 cashedOut = _pendingJackpotBalance.mul(jackpotHardBuyback).div(
            MAX_PCT
        );
        uint256 tokensGonsOut = _jackpotGonsTokens.mul(jackpotHardBuyback).div(
            MAX_PCT
        );
        _lastCombustionTokens = tokensGonsOut.div(_gonsPerFragment);

        IERC20(BUSD).transfer(buybackWallet, cashedOut);
        _basicTransfer(
            address(this),
            buybackWallet,
            tokensGonsOut.div(_gonsPerFragment)
        );

        emit Combustion(cashedOut, tokensGonsOut.div(_gonsPerFragment));

        _lastCombustionCash = cashedOut;
        _lastCombustionTimestamp = block.timestamp;

        _pendingJackpotBalance = _pendingJackpotBalance.sub(cashedOut);
        _jackpotGonsTokens = _jackpotGonsTokens.sub(tokensGonsOut);

        _totalJackpotCashedOut = _totalJackpotCashedOut.add(cashedOut);
        _totalJackpotBuyback = _totalJackpotBuyback.add(cashedOut);
        _totalJackpotTokensOut = _totalJackpotTokensOut.add(
            tokensGonsOut.div(_gonsPerFragment)
        );
        _totalJackpotBuybackTokens = _totalJackpotBuybackTokens.add(
            tokensGonsOut.div(_gonsPerFragment)
        );
    }

    function awardJackpot() internal swapping {
        require(
            _lastBuyer != address(0) && _lastBuyer != address(this),
            "No last buyer detected"
        );
        uint256 cashedOut = _pendingJackpotBalance.mul(jackpotCashout).div(
            MAX_PCT
        );
        uint256 tokensGonsOut = _jackpotGonsTokens.mul(jackpotCashout).div(
            MAX_PCT
        );
        uint256 tokensOut = tokensGonsOut.div(_gonsPerFragment);
        uint256 buyerShare = cashedOut.mul(jackpotBuyerShare).div(MAX_PCT);
        uint256 tokensToBuyer = tokensOut.mul(jackpotBuyerShare).div(MAX_PCT);
        uint256 toBuyback = cashedOut - buyerShare;
        uint256 tokensToBuyback = tokensOut - tokensToBuyer;

        IERC20(BUSD).transfer(_lastBuyer, buyerShare);
        _basicTransfer(address(this), _lastBuyer, tokensToBuyer);
        IERC20(BUSD).transfer(buybackWallet, toBuyback);
        _basicTransfer(address(this), buybackWallet, tokensToBuyback);

        _pendingJackpotBalance = _pendingJackpotBalance.sub(cashedOut);
        _jackpotGonsTokens = _jackpotGonsTokens.sub(tokensGonsOut);

        _lastAwarded = _lastBuyer;
        _lastAwardedCash = cashedOut;
        _lastAwardedTimestamp = block.timestamp;
        _lastAwardedTokens = tokensToBuyer;

        emit JackpotAwarded(_lastBuyer, cashedOut);

        _lastBuyer = payable(address(this));
        _lastBuyTimestamp = 0;

        _totalJackpotCashedOut = _totalJackpotCashedOut.add(cashedOut);
        _totalJackpotTokensOut = _totalJackpotTokensOut.add(tokensOut);
        _totalJackpotBuyer = _totalJackpotBuyer.add(buyerShare);
        _totalJackpotBuyerTokens = _totalJackpotBuyerTokens.add(tokensToBuyer);
        _totalJackpotBuyback = _totalJackpotBuyback.add(toBuyback);
        _totalJackpotBuybackTokens = _totalJackpotBuybackTokens.add(
            tokensToBuyback
        );
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) internal returns (uint256) {
        uint256 _totalFee = totalFee;
        uint256 _treasuryFee = treasuryFee;
        uint256 _afterburnerFee = afterburnerFee;

        if (recipient == pair) {
            _totalFee = totalFee.add(sellFee).add(afterburnerSellFee);
            _treasuryFee = treasuryFee.add(sellFee);
            _afterburnerFee = afterburnerFee.add(afterburnerSellFee);
        }

        uint256 feeAmount = gonAmount.mul(_totalFee).div(feeDenominator);

        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            gonAmount
                .mul(
                    _treasuryFee.add(MarketingFundFee).add(afterburnerFee)
                )
                .div(feeDenominator)
        );
        _gonBalances[autoLiquidityReceiver] = _gonBalances[
            autoLiquidityReceiver
        ].add(gonAmount.mul(liquidityFee).div(feeDenominator));

        _jackpotGonsTokens = _jackpotGonsTokens.add(
            gonAmount.mul(_afterburnerFee).div(feeDenominator)
        );

        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));
        return gonAmount.sub(feeAmount);
    }

    function addLiquidity() internal swapping {
        uint256 autoLiquidityAmount = _gonBalances[autoLiquidityReceiver].div(
            _gonsPerFragment
        );
        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            _gonBalances[autoLiquidityReceiver]
        );
        _gonBalances[autoLiquidityReceiver] = 0;
        uint256 amountToLiquify = autoLiquidityAmount.div(2);
        uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);

        if (amountToSwap == 0) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHLiquidity = address(this).balance.sub(balanceBefore);

        if (amountToLiquify > 0 && amountETHLiquidity > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
        }
        _lastAddLiquidityTime = block.timestamp;
    }

    function swapBack() internal swapping {
        uint256 amountToSwap = _gonBalances[address(this)].div(
            _gonsPerFragment
        );

        if (amountToSwap == 0) {
            return;
        }

        uint256 balanceBefore = IERC20(BUSD).balanceOf(address(this));
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = router.WETH();
        path[2] = BUSD;

        router.swapExactTokensForTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBUSDToSend = IERC20(BUSD).balanceOf(address(this)).sub(
            balanceBefore
        );

        _jackpotGonsTokens = 0;

        /// Send BUSD to treasury
        IERC20(BUSD).transfer(
            treasuryReceiver,
            amountBUSDToSend.mul(treasuryFee).div(
                treasuryFee.add(MarketingFundFee).add(afterburnerFee)
            )
        );

        /// Send BUSD to insurance fund
        IERC20(BUSD).transfer(
            MarketingFundReceiver,
            amountBUSDToSend.mul(MarketingFundFee).div(
                treasuryFee.add(MarketingFundFee).add(afterburnerFee)
            )
        );
        /// The remaining BUSD goes to jackpot
        _pendingJackpotBalance = _pendingJackpotBalance.add(
            amountBUSDToSend.mul(afterburnerFee).div(
                treasuryFee.add(MarketingFundFee).add(afterburnerFee)
            )
        );
    }

    function withdrawAllToTreasury() external swapping onlyOwner {
        uint256 amountToSwap = _gonBalances[address(this)].div(
            _gonsPerFragment
        );
        require(
            amountToSwap > 0,
            "There is no ABT token deposited in token contract"
        );
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            treasuryReceiver,
            block.timestamp
        );
    }

    function shouldTakeFee(address from, address to)
        internal
        view
        returns (bool)
    {
        if(isTakeFeeOnNormalTransfer) {
            return !_isFeeExempt[from];
        }
        return (pair == from || pair == to) && !_isFeeExempt[from];
    }

    function shouldRebase() internal view returns (bool) {
        return
            _autoRebase &&
            (_totalSupply < MAX_SUPPLY) &&
            msg.sender != pair &&
            !inSwap &&
            block.timestamp >= (_lastRebasedTime + 15 minutes);
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return
            _autoAddLiquidity &&
            !inSwap &&
            msg.sender != pair &&
            block.timestamp >= (_lastAddLiquidityTime + 2 days);
    }

    function shouldSwapBack() internal view returns (bool) {
        return !inSwap && msg.sender != pair;
    }

    function setTwentyFourHour(uint256 _twentyFourHour) external onlyOwner {
        require(
            _twentyFourHour <= 86400 && _twentyFourHour >= 60,
            "Twenty four hour must be between 60 and 86400 seconds"
        );
        TwentyFourhours = _twentyFourHour;
    }

    function setIsTakeFeeOnNormalTransfer(bool _isTakeFeeOnNormalTransfer)
        external
        onlyOwner {
        isTakeFeeOnNormalTransfer = _isTakeFeeOnNormalTransfer;
    }

    function setMaxSellTransaction(uint256 _maxTxn) external onlyOwner {
        require(_maxTxn >= 100 * 10**DECIMALS, "Max transaction must be greater than 100");
        maxSellTransactionAmount = _maxTxn;
    }

    function setSellLimitPercent(uint256 _percent) external onlyOwner {
        require(_percent <= 100 && _percent >= 1, "Percentage must be less than 100 and greater than 1");
        sellLimitPercent = _percent;
    }

    function setBuyLimitPercent(uint256 _percent) external onlyOwner {
        require(_percent <= 100 && _percent >= 1, "Percentage must be less than 100 and greater than 1");
        buyLimitPercent = _percent;
    }

    function setBuyFees(
        uint256 _liquidityFee,
        uint256 _MarketingFundFee,
        uint256 _treasuryFee,
        uint256 _afterburnerFee,
        uint256 _afterburnerSellFee,
        uint256 _sellFee
    ) external onlyOwner {
        uint256 totalBuyFee = _liquidityFee
            .add(_MarketingFundFee)
            .add(_treasuryFee)
            .add(_afterburnerFee);
        uint256 totalSellFee = totalBuyFee.add(_afterburnerSellFee).add(_sellFee);
        require(
            totalSellFee <= TOTAL_FEES_LIMIT,
            "Total fees can not exceed 25%"
        );
        liquidityFee = _liquidityFee;
        MarketingFundFee = _MarketingFundFee;
        treasuryFee = _treasuryFee;
        afterburnerFee = _afterburnerFee;
        afterburnerSellFee = _afterburnerSellFee;
        sellFee = _sellFee;
    }

    function setJackpotCashout(uint256 _jackpotCashout) external onlyOwner {
        jackpotCashout = _jackpotCashout;
    }

    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp;
        } else {
            _autoRebase = _flag;
        }
    }

    function setJackpotHardBuyback(uint256 _hardBuyback) external onlyOwner {
        jackpotHardBuyback = _hardBuyback;
    }

    function setBuyBackWallet(address _wallet) external onlyOwner {
        buybackWallet = _wallet;
    }

    function setJackpotMinBuy(uint256 _minBuy) external onlyOwner {
        jackpotMinBuy = _minBuy;
    }

    function setJackpotTimespan(uint256 _timespan) external onlyOwner {
        jackpotTimespan = _timespan;
    }

    function setJackpotHardLimit(uint256 _hardlimit) external onlyOwner {
        jackpotHardLimit = _hardlimit;
    }

    function setAutoAddLiquidity(bool _flag) external onlyOwner {
        if (_flag) {
            _autoAddLiquidity = _flag;
            _lastAddLiquidityTime = block.timestamp;
        } else {
            _autoAddLiquidity = _flag;
        }
    }

    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
            spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    function manualSync() external {
        IPancakeSwapPair(pair).sync();
    }

    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _treasuryReceiver,
        address _MarketingFundReceiver
    ) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        treasuryReceiver = _treasuryReceiver;
        MarketingFundReceiver = _MarketingFundReceiver;
    }

    function setWhitelist(address _addr, bool _isWhitelisted) external onlyOwner {
        _isFeeExempt[_addr] = _isWhitelisted;
    }

    function setBotBlacklist(address _botAddress, bool _flag)
        external
        onlyOwner
    {
        require(
            isContract(_botAddress),
            "only contract address, not allowed exteranlly owned account"
        );
        blacklist[_botAddress] = _flag;
    }

    function setPairAddress(address _pairAddress) external onlyOwner {
        pairAddress = _pairAddress;
    }

    function setLP(address _address) external onlyOwner {
        pairContract = IPancakeSwapPair(_address);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function gonsForBalance(uint256 amount) public view returns (uint256) {
        return amount.mul(_gonsPerFragment);
    }

    function balanceForGons(uint256 gons) public view returns (uint256) {
        return gons.div(_gonsPerFragment);
    }

    function index() public view returns (uint256) {
        return balanceForGons(INDEX);
    }

    function balanceOf(address who) public view override returns (uint256) {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    receive() external payable {}
}