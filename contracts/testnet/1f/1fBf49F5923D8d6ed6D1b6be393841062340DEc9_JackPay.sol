/// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

import "./library/SafeMath.sol";
import "./library/SafeMathInt.sol";
import "./interface/IERC20.sol";
import "./interface/IPancakeSwapFactory.sol";
import "./interface/IPancakeSwapRouter.sol";
import "./interface/IPancakeSwapPair.sol";
import "./Ownable.sol";
import "./ERC20Detailed.sol";

contract JackPay is ERC20Detailed, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event JackpotAwarded(address indexed receiver, uint256 amount);
    event BigBang(uint256 cashedOut, uint256 tokensOut);
    event JackpotFund(uint256 busdSent, uint256 tokenAmount);

    string public constant _name = "JackPay";
    string public constant _symbol = "JACK";
    uint8 public constant _decimals = 5;

    IPancakeSwapPair public pairContract;
    mapping(address => bool) _isFeeExempt;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }
    uint256 public maxJackpotLimitMultiplier = 5;
    uint256 public constant DECIMALS = 5;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 7;
    // At any given time, buy and sell fees can NOT exceed 25% each
    uint256 private constant TOTAL_FEES_LIMIT = 250;

    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 2 * 10**6 * 10**DECIMALS;
    uint256 private constant BNB_DECIMALS = 18;
    uint256 private constant BUSD_DECIMALS = 18;

    uint256 public liquidityFee = 20;
    uint256 public jackPayInsuranceFundFee = 25;
    uint256 public treasuryFee = 30;
    uint256 public jackpotFee = 25;

    uint256 public jackpotSellFee = 25;
    uint256 public sellFee = 15;

    uint256 public totalFee =
        liquidityFee.add(treasuryFee).add(jackPayInsuranceFundFee).add(
            jackpotFee
        );
    uint256 public constant feeDenominator = 1000;

    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    // address constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // mainnet
    address constant BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; // testnet
    // address constant BUSD = 0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6; // localhost
    uint256 private constant MAX_PCT = 10000;
    // PCS takes 0.25% fee on all txs
    uint256 private constant ROUTER_FEE = 25;

    address public autoLiquidityReceiver;
    address public treasuryReceiver;
    address public jackPayInsuranceFundReceiver;
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

    uint256 private constant MAX_SUPPLY = 21 * 1e9 * 10**DECIMALS;

    bool public _autoRebase;
    bool public _autoAddLiquidity;
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public _totalSupply;
    uint256 private _gonsPerFragment;
    bool public _isRebaseStarted;

    // 55.55% jackpot cashout to last buyer
    uint256 public jackpotCashout = 5555;
    // 90% of jackpot cashout to last buyer
    uint256 public jackpotBuyerShare = 9000;
    // Buys > 0.001 BNB will be eligible for the jackpot
    uint256 public jackpotMinBuy = 1 * 10**(BNB_DECIMALS - 3);
    // Jackpot time span is initially set to 5 mins
    uint256 public jackpotTimespan = 5 * 60;
    // Jackpot hard limit, BUSD value
    uint256 public jackpotHardLimit = 50000 * 10**(BUSD_DECIMALS);
    // Jackpot hard limit buyback share
    uint256 public jackpotHardBuyback = 5000;

    uint256 public _jackpotGonsTokens = 0;

    address private _lastBuyer = address(this);
    uint256 private _lastBuyTimestamp = 0;
    uint256 private _lastBuyBUSDValue = 0;

    address private _lastAwarded = address(0);
    uint256 private _lastAwardedCash = 0;
    uint256 private _lastAwardedTokens = 0;
    uint256 private _lastAwardedTimestamp = 0;

    uint256 private _lastBigBangCash = 0;
    uint256 private _lastBigBangTokens = 0;
    uint256 private _lastBigBangTimestamp = 0;

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

    uint8 public stackTimesOfSale = 10;
    uint256 public maxSellTransactionAmount = 1000 * 10**DECIMALS;
    uint256 public sellLimitPercent = 1;
    uint256 public buyLimitPercent = 1;

    constructor()
        ERC20Detailed("JackPay", "JACK", uint8(DECIMALS))
        Ownable()
    {
        // router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // mainnet
        router = IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // testnet
        // router = IPancakeSwapRouter(0xa513E6E4b8f2a923D98304ec87F64353C4D5C853); // localhost
        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        autoLiquidityReceiver = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        // treasuryReceiver = 0x3A456bDA98eC7cEcd7A0e224cDbdFb59F4EE1d30;
        treasuryReceiver = msg.sender;
        jackPayInsuranceFundReceiver = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        buybackWallet = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

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
        _isFeeExempt[jackPayInsuranceFundReceiver] = true;
        _isFeeExempt[buybackWallet] = true;
        _isFeeExempt[msg.sender] = true;
        _isFeeExempt[address(this)] = true;

        _transferOwnership(treasuryReceiver);
        emit Transfer(address(0x0), treasuryReceiver, _totalSupply);
    }

    function getLastBuy()
        external
        view
        returns (
            address lastBuyer,
            uint256 lastBuyBUSDValue,
            uint256 lastBuyTimestamp
        )
    {
        return (_lastBuyer, _lastBuyBUSDValue, _lastBuyTimestamp);
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

    function getLastBigBang()
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (_lastBigBangCash, _lastBigBangTokens, _lastBigBangTimestamp);
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

        if (deltaTimeFromInit <= 365 days) {
            rebaseRate = 2629;
        } else {
            rebaseRate = 250;
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
            // for the first time buy
            if (tradeData[sender].lastSellTime == 0) {
                tradeData[sender].lastSellTime = blkTime - TwentyFourhours;
            }
            uint256 curentToLastSender = blkTime -
                tradeData[sender].lastSellTime;
            if (curentToLastSender > TwentyFourhours * stackTimesOfSale) {
                curentToLastSender = stackTimesOfSale * TwentyFourhours;
            }

            uint256 stackSellAmountSender = (balanceOf(sender) *
                sellLimitPercent *
                curentToLastSender) / (TwentyFourhours * 100);

            tradeData[sender].sellAmount += stackSellAmountSender;
            tradeData[sender].lastSellTime = blkTime;

            uint256 maxStackSellAmountSender = (balanceOf(sender) *
                sellLimitPercent *
                stackTimesOfSale) / 100;
            // if (tradeData[sender].sellAmount > maxStackSellAmountSender){
            //     tradeData[sender].sellAmount = maxStackSellAmountSender;
            // }
            require(
                tradeData[sender].sellAmount <= maxStackSellAmountSender,
                "Can't sell more than limit"
            );
            require(
                amount <= tradeData[sender].sellAmount,
                "Can't sell more than limit"
            );

            tradeData[sender].sellAmount -= amount;
        }

        if (sender == pair && !excludedAccount) {
            uint256 blkTime = block.timestamp;

            uint256 onePercent = _totalSupply.mul(buyLimitPercent).div(100); //Should use variable
            require(amount <= onePercent, "ERR: Can't buy more than 1%");

            if (blkTime > tradeData[recipient].lastBuyTime + TwentyFourhours) {
                tradeData[recipient].lastBuyTime = blkTime;
                tradeData[recipient].buyAmount = amount;
            } else if (
                (blkTime <
                    tradeData[recipient].lastBuyTime + TwentyFourhours) &&
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
            processBigBang();
        } else if (shouldAwardJackpot()) {
            awardJackpot();
        }

        if (sender == pair && isJackpotEligible(amount)) {
            _lastBuyTimestamp = block.timestamp;
            _lastBuyer = recipient;
            _lastBuyBUSDValue = getBUSDValue(amount);
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

    function getBUSDValue(uint256 amount) public view returns(uint256) {
        address[] memory path = new address[](3);
            path[0] = address(this);
            path[1] = router.WETH();
            path[2] = BUSD;
            uint256 value = router.getAmountsOut(amount, path)[2];
            return value;
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

    function processBigBang() internal swapping {
        uint256 cashedOut = _pendingJackpotBalance.mul(jackpotHardBuyback).div(
            MAX_PCT
        );
        uint256 tokensGonsOut = _jackpotGonsTokens.mul(jackpotHardBuyback).div(
            MAX_PCT
        );
        _lastBigBangTokens = tokensGonsOut.div(_gonsPerFragment);

        IERC20(BUSD).transfer(buybackWallet, cashedOut);
        _basicTransfer(
            address(this),
            buybackWallet,
            tokensGonsOut.div(_gonsPerFragment)
        );

        emit BigBang(cashedOut, tokensGonsOut.div(_gonsPerFragment));

        _lastBigBangCash = cashedOut;
        _lastBigBangTimestamp = block.timestamp;

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

    function fundJackpot(uint256 tokenAmount, uint256 busdAmount) external onlyOwner {
        require(
            balanceOf(msg.sender) >= tokenAmount,
            "You don't have enough tokens to fund the jackpot"
        );
        bool isTransferBUSDSuccess = IERC20(BUSD).transferFrom(
            msg.sender,
            address(this),
            busdAmount
        );
        if(isTransferBUSDSuccess) {
            _pendingJackpotBalance = _pendingJackpotBalance.add(busdAmount);
        }
        if (tokenAmount > 0) {
            _basicTransfer(msg.sender, address(this), tokenAmount);
            _jackpotGonsTokens = _jackpotGonsTokens.add(tokenAmount.mul(_gonsPerFragment));
        }

        emit JackpotFund(busdAmount, tokenAmount);
    }

    function awardJackpot() internal swapping {
        require(
            _lastBuyer != address(0) && _lastBuyer != address(this),
            "No last buyer detected"
        );
        uint256 cashedOut = _pendingJackpotBalance.mul(jackpotCashout).div(
            MAX_PCT
        );
        if (cashedOut > _lastBuyBUSDValue.mul(maxJackpotLimitMultiplier)) {
            cashedOut = _lastBuyBUSDValue.mul(maxJackpotLimitMultiplier);
        }
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
        _lastBuyBUSDValue = 0;

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
        uint256 _jackpotFee = jackpotFee;

        if (recipient == pair) {
            _totalFee = totalFee.add(sellFee).add(jackpotSellFee);
            _treasuryFee = treasuryFee.add(sellFee);
            _jackpotFee = jackpotFee.add(jackpotSellFee);
        }

        uint256 feeAmount = gonAmount.mul(_totalFee).div(feeDenominator);

        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            gonAmount
                .mul(
                    _treasuryFee.add(jackPayInsuranceFundFee).add(jackpotFee)
                )
                .div(feeDenominator)
        );
        _gonBalances[autoLiquidityReceiver] = _gonBalances[
            autoLiquidityReceiver
        ].add(gonAmount.mul(liquidityFee).div(feeDenominator));

        _jackpotGonsTokens = _jackpotGonsTokens.add(
            gonAmount.mul(_jackpotFee).div(feeDenominator)
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
                treasuryFee.add(jackPayInsuranceFundFee).add(jackpotFee)
            )
        );

        /// Send BUSD to insurance fund
        IERC20(BUSD).transfer(
            jackPayInsuranceFundReceiver,
            amountBUSDToSend.mul(jackPayInsuranceFundFee).div(
                treasuryFee.add(jackPayInsuranceFundFee).add(jackpotFee)
            )
        );
        /// The remaining BUSD goes to jackpot
        _pendingJackpotBalance = _pendingJackpotBalance.add(
            amountBUSDToSend.mul(jackpotFee).div(
                treasuryFee.add(jackPayInsuranceFundFee).add(jackpotFee)
            )
        );
    }

    function withdrawAllToTreasury() external swapping onlyOwner {
        uint256 amountToSwap = _gonBalances[address(this)].div(
            _gonsPerFragment
        );
        require(
            amountToSwap > 0,
            "There is no JACK token deposited in token contract"
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
        if (isTakeFeeOnNormalTransfer) {
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

    function setMaxJackpotLimitMultiplier(uint256 _maxJackpotLimitMultiplier)
        external
        onlyOwner
    {
        maxJackpotLimitMultiplier = _maxJackpotLimitMultiplier;
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
        onlyOwner
    {
        isTakeFeeOnNormalTransfer = _isTakeFeeOnNormalTransfer;
    }

    function setMaxSellTransaction(uint256 _maxTxn) external onlyOwner {
        require(
            _maxTxn >= 1000 * 10**DECIMALS,
            "Max transaction must be greater than 1000"
        );
        maxSellTransactionAmount = _maxTxn;
    }

    function setSellLimitPercent(uint256 _percent) external onlyOwner {
        require(
            _percent <= 100 && _percent >= 1,
            "Percentage must be less than 100 and greater than 1"
        );
        sellLimitPercent = _percent;
    }

    function setBuyLimitPercent(uint256 _percent) external onlyOwner {
        require(
            _percent <= 100 && _percent >= 1,
            "Percentage must be less than 100 and greater than 1"
        );
        buyLimitPercent = _percent;
    }

    function setBuyFees(
        uint256 _liquidityFee,
        uint256 _jackPayInsuranceFundFee,
        uint256 _treasuryFee,
        uint256 _jackpotFee,
        uint256 _jackpotSellFee,
        uint256 _sellFee
    ) external onlyOwner {
        uint256 totalBuyFee = _liquidityFee
            .add(_jackPayInsuranceFundFee)
            .add(_treasuryFee)
            .add(_jackpotFee);
        uint256 totalSellFee = totalBuyFee.add(_jackpotSellFee).add(_sellFee);
        require(
            totalSellFee <= TOTAL_FEES_LIMIT,
            "Total fees can not exceed 25%"
        );
        liquidityFee = _liquidityFee;
        jackPayInsuranceFundFee = _jackPayInsuranceFundFee;
        treasuryFee = _treasuryFee;
        jackpotFee = _jackpotFee;
        jackpotSellFee = _jackpotSellFee;
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
        address _jackPayInsuranceFundReceiver
    ) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        treasuryReceiver = _treasuryReceiver;
        jackPayInsuranceFundReceiver = _jackPayInsuranceFundReceiver;
    }

    function setWhitelist(address _addr, bool _isWhitelisted)
        external
        onlyOwner
    {
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

    function balanceOf(address who) public view override returns (uint256) {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    function burn(uint256 amount) external onlyOwner {
        require(
            amount <= balanceOf(msg.sender),
            "You don't have enough balance to burn"
        );
        _gonBalances[msg.sender] = _gonBalances[msg.sender].sub(amount.mul(
            _gonsPerFragment
        ));

        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(msg.sender, address(0), amount);
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

/// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

/// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

interface IPancakeSwapFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

/// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

interface IPancakeSwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

/// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

interface IPancakeSwapPair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

/// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;
import "./interface/IERC20.sol";

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}